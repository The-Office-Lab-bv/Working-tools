function Get-TolAIToSolve {
    <#
    .SYNOPSIS
        Sends a prompt to an AI provider of your choice and returns the answer.

    .DESCRIPTION
        One command, five providers. Pick the model family with -Provider (Claude,
        ChatGPT, Gemini, Mistral/LeChat, or local Ollama) and give it three things:
          -Prompt   what to do      (the instruction)
          -Data     what to work on (any variable; objects are JSON-encoded for you)
          -Skillset who should do it (the expertise the AI applies)
        You get the answer back as text. Use -AsJson to ask for and parse a JSON object.

        Each provider needs an API key. By default the key is read from an environment
        variable (see the table below); you can also pass one with -ApiKey.

        | Provider | -Provider value      | API key environment variable |
        |----------|----------------------|------------------------------|
        | Claude   | Claude               | ANTHROPIC_API_KEY            |
        | ChatGPT  | ChatGPT              | OPENAI_API_KEY              |
        | Gemini   | Gemini               | GEMINI_API_KEY             |
        | Le Chat  | Mistral (or LeChat)  | MISTRAL_API_KEY            |
        | Ollama   | Ollama               | none (runs locally, free)   |

        COST: the four cloud providers (Claude, ChatGPT, Gemini, Mistral) are paid
        APIs. Every call spends money on your own account, billed per token by the
        provider. Ollama runs locally on your machine and is free. Mind your usage.

    .PARAMETER Prompt
        The question or task to send. Accepts pipeline input.

    .PARAMETER Provider
        Which AI to use: Claude (default), ChatGPT, Gemini, Mistral, LeChat, or
        Ollama. The cloud providers cost money per call; Ollama runs locally and free.

    .PARAMETER Model
        Override the model. Each provider has a sensible default (see DEFAULT MODELS).

    .PARAMETER ApiKey
        The API key. If omitted, it is read from the provider's environment variable.

    .PARAMETER Skillset
        The expertise you want the AI to apply, in plain words, e.g. "senior front-end
        designer", "financial analyst", "Belgian VAT accountant". It becomes the AI's
        role so the answer comes from that angle. The three building blocks are:
        Prompt = what to do, Data = what to work on, Skillset = who should do it.

    .PARAMETER System
        Advanced: a raw system prompt, for full control over the AI's instructions. If
        you also pass -Skillset, both are combined. Most people only need -Skillset.

    .PARAMETER Data
        Data to give the AI alongside the prompt. Accepts any object: strings are sent
        as-is, anything else (arrays, hashtables, objects from Get-* commands) is turned
        into JSON automatically. The prompt is your instruction, the data is the input.

    .PARAMETER AsJson
        Ask the AI for JSON and return it as a parsed PowerShell object instead of text.

    .PARAMETER MaxTokens
        Maximum length of the answer, in tokens. Default 1024. Raise it for long output
        such as a full HTML report (e.g. -MaxTokens 4096), or it will be cut off.

    .EXAMPLE
        Get-TolAIToSolve "Explain DNS in one sentence."

    .EXAMPLE
        Get-TolAIToSolve -Provider ChatGPT -Prompt "Summarize the CAP theorem."

    .EXAMPLE
        $obj = Get-TolAIToSolve -Provider Gemini -AsJson `
            -Prompt "Give me name and capital for 3 EU countries as JSON."
        $obj.countries

    .EXAMPLE
        # Prompt + Data + Skillset: turn a variable into a designed HTML report
        $stats = Get-TolFolderSize -Path C:\Logs
        Get-TolAIToSolve -Skillset "senior front-end designer" -Data $stats -MaxTokens 4096 `
            -Prompt "Build a clean, modern HTML report from this data. Return only the HTML, no code fences." |
            Out-File report.html

    .NOTES
        DEFAULT MODELS (override with -Model; update as providers release newer ones):
          Claude   -> claude-opus-4-8
          ChatGPT  -> gpt-4o
          Gemini   -> gemini-1.5-pro-latest
          Mistral  -> mistral-large-latest
          Ollama   -> llama3.2  (must be pulled first: `ollama pull llama3.2`)

        Ollama uses a local server. Default address http://localhost:11434; override
        with the OLLAMA_HOST environment variable to point at another machine.

        Cross-platform. Cloud providers need internet + a paid API key and cost money
        per call. Ollama needs a running local Ollama install and is free.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Prompt,
        [ValidateSet('Claude', 'ChatGPT', 'Gemini', 'Mistral', 'LeChat', 'Ollama')]
        [string]$Provider = 'Claude',
        [string]$Model,
        [string]$ApiKey,
        [string]$Skillset,
        [string]$System,
        [object]$Data,
        [switch]$AsJson,
        [int]$MaxTokens = 1024
    )
    begin {
        # LeChat is Mistral's chat product; route it to the Mistral API.
        if ($Provider -eq 'LeChat') { $Provider = 'Mistral' }

        $defaults = @{
            Claude  = @{ Model = 'claude-opus-4-8';        EnvKey = 'ANTHROPIC_API_KEY' }
            ChatGPT = @{ Model = 'gpt-4o';                 EnvKey = 'OPENAI_API_KEY' }
            Gemini  = @{ Model = 'gemini-1.5-pro-latest';  EnvKey = 'GEMINI_API_KEY' }
            Mistral = @{ Model = 'mistral-large-latest';   EnvKey = 'MISTRAL_API_KEY' }
            Ollama  = @{ Model = 'llama3.2';               EnvKey = $null }
        }
        $cfg = $defaults[$Provider]
        if (-not $Model) { $Model = $cfg.Model }

        # Ollama is local and needs no key; the cloud providers do.
        if ($Provider -ne 'Ollama') {
            if (-not $ApiKey) { $ApiKey = [Environment]::GetEnvironmentVariable($cfg.EnvKey) }
            if (-not $ApiKey) {
                throw "No API key for $Provider. Set `$env:$($cfg.EnvKey) or pass -ApiKey."
            }
        }
    }
    process {
        # Build the effective system prompt from Skillset (friendly) + System (raw).
        $sys = $System
        if ($Skillset) {
            $role = "You are an expert $Skillset. Apply that expertise to the task."
            $sys = if ($System) { "$role`n$System" } else { $role }
        }

        $userText = $Prompt
        if ($PSBoundParameters.ContainsKey('Data') -and $null -ne $Data) {
            $dataText = if ($Data -is [string]) { $Data } else { $Data | ConvertTo-Json -Depth 10 }
            $userText += "`n`n--- DATA ---`n$dataText"
        }
        if ($AsJson) {
            $userText += "`n`nRespond with valid JSON only. No markdown, no code fences, no commentary."
        }

        try {
            switch ($Provider) {
                'Claude' {
                    $body = [ordered]@{
                        model      = $Model
                        max_tokens = $MaxTokens
                        messages   = @(@{ role = 'user'; content = $userText })
                    }
                    if ($sys) { $body.system = $sys }
                    $resp = Invoke-RestMethod -Method Post -Uri 'https://api.anthropic.com/v1/messages' `
                        -Headers @{
                            'x-api-key'         = $ApiKey
                            'anthropic-version' = '2023-06-01'
                            'content-type'      = 'application/json'
                        } -Body ($body | ConvertTo-Json -Depth 10) -ErrorAction Stop
                    $text = ($resp.content | Where-Object { $_.type -eq 'text' } | Select-Object -First 1).text
                }
                'Ollama' {
                    $base = [Environment]::GetEnvironmentVariable('OLLAMA_HOST')
                    if (-not $base) { $base = 'http://localhost:11434' }
                    $messages = @()
                    if ($sys) { $messages += @{ role = 'system'; content = $sys } }
                    $messages += @{ role = 'user'; content = $userText }
                    $body = [ordered]@{
                        model    = $Model
                        messages = $messages
                        stream   = $false
                    }
                    if ($AsJson) { $body.format = 'json' }
                    $resp = Invoke-RestMethod -Method Post -Uri "$($base.TrimEnd('/'))/api/chat" `
                        -Headers @{ 'content-type' = 'application/json' } `
                        -Body ($body | ConvertTo-Json -Depth 10) -ErrorAction Stop
                    $text = $resp.message.content
                }
                'Gemini' {
                    $body = [ordered]@{
                        contents = @(@{ parts = @(@{ text = $userText }) })
                    }
                    if ($sys)  { $body.system_instruction = @{ parts = @(@{ text = $sys }) } }
                    if ($AsJson)  { $body.generationConfig = @{ response_mime_type = 'application/json' } }
                    $uri = "https://generativelanguage.googleapis.com/v1beta/models/$Model:generateContent"
                    $resp = Invoke-RestMethod -Method Post -Uri $uri `
                        -Headers @{ 'content-type' = 'application/json'; 'x-goog-api-key' = $ApiKey } `
                        -Body ($body | ConvertTo-Json -Depth 10) -ErrorAction Stop
                    $text = ($resp.candidates[0].content.parts | Select-Object -First 1).text
                }
                default {
                    # ChatGPT (OpenAI) and Mistral share the same chat-completions shape.
                    $uri = if ($Provider -eq 'ChatGPT') {
                        'https://api.openai.com/v1/chat/completions'
                    } else {
                        'https://api.mistral.ai/v1/chat/completions'
                    }
                    $messages = @()
                    if ($sys) { $messages += @{ role = 'system'; content = $sys } }
                    $messages += @{ role = 'user'; content = $userText }
                    $body = [ordered]@{
                        model      = $Model
                        max_tokens = $MaxTokens
                        messages   = $messages
                    }
                    if ($AsJson) { $body.response_format = @{ type = 'json_object' } }
                    $resp = Invoke-RestMethod -Method Post -Uri $uri `
                        -Headers @{ 'Authorization' = "Bearer $ApiKey"; 'content-type' = 'application/json' } `
                        -Body ($body | ConvertTo-Json -Depth 10) -ErrorAction Stop
                    $text = $resp.choices[0].message.content
                }
            }
        }
        catch {
            throw "$Provider request failed: $($_.Exception.Message)"
        }

        if (-not $AsJson) { return $text }

        # Strip any stray code fences, then parse.
        $clean = ($text -replace '(?s)^\s*```(?:json)?\s*', '' -replace '(?s)\s*```\s*$', '').Trim()
        try {
            return $clean | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Write-Warning "Response was not valid JSON; returning raw text."
            return $text
        }
    }
}
