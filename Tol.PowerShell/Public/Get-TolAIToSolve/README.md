# Get-TolAIToSolve

Send a prompt to an AI provider of your choice and get the answer back, as text or
as parsed JSON. One command for **Claude, ChatGPT, Gemini, Mistral (Le Chat),** and
**Ollama** (local).

> 💸 **This costs money.** The four cloud providers are paid APIs billed to *your*
> account, per token, on every call. **Ollama runs locally on your own machine and is
> free.** Keep an eye on your usage, especially in loops.

## Why

Switch between AI models without rewriting code. Same command, same parameters, you
just change `-Provider`.

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7+
- For the cloud providers: an account and an API key with that provider
- For Ollama: a running [Ollama](https://ollama.com) install and a pulled model
  (`ollama pull llama3.2`)

## Setup: API keys

Each cloud provider reads its key from an environment variable. Set it once per
session, or permanently in your profile / system settings.

| Provider | `-Provider` value     | Environment variable | Get a key at |
|----------|-----------------------|----------------------|--------------|
| Claude   | `Claude` (default)    | `ANTHROPIC_API_KEY`  | console.anthropic.com |
| ChatGPT  | `ChatGPT`             | `OPENAI_API_KEY`     | platform.openai.com |
| Gemini   | `Gemini`              | `GEMINI_API_KEY`     | aistudio.google.com |
| Le Chat  | `Mistral` / `LeChat`  | `MISTRAL_API_KEY`    | console.mistral.ai |
| Ollama   | `Ollama`              | none (local, free)   | ollama.com |

Set a key for the current session:

```powershell
$env:ANTHROPIC_API_KEY = "sk-ant-..."
```

You can also pass a key inline with `-ApiKey` (handy for testing), but the
environment variable is the recommended way. **Never hard-code keys into scripts you
commit or share.**

Ollama needs no key. It talks to `http://localhost:11434` by default; point it at
another machine with `$env:OLLAMA_HOST = "http://17.10.72.107:11434"`.

## Usage

```powershell
# Simplest: Claude (the default provider), text answer
Get-TolAIToSolve "Explain DNS in one sentence."

# Pick a different provider
Get-TolAIToSolve -Provider ChatGPT -Prompt "Summarize the CAP theorem."
Get-TolAIToSolve -Provider Gemini  -Prompt "Give me a haiku about backups."
Get-TolAIToSolve -Provider Mistral -Prompt "Translate 'good morning' to Dutch."

# Local and free via Ollama
Get-TolAIToSolve -Provider Ollama -Model llama3.2 -Prompt "Name three sorting algorithms."

# Get structured JSON back as a PowerShell object
$data = Get-TolAIToSolve -Provider Gemini -AsJson `
    -Prompt "List 3 EU countries with name and capital as JSON."
$data.countries

# Add a system instruction to steer the style
Get-TolAIToSolve -Prompt "What is a vector database?" -System "Answer like a teacher, one paragraph."

# Pipe the prompt in
"What is the speed of light in km/s?" | Get-TolAIToSolve
```

### Prompt + Data + Skillset

Think of every call as three building blocks:

| Block | Parameter | What it is |
|-------|-----------|------------|
| **What to do** | `-Prompt` | The instruction. |
| **What to work on** | `-Data` | Any variable. Strings go in as-is; objects, arrays, and hashtables are turned into JSON for you. |
| **Who should do it** | `-Skillset` | The expertise the AI applies, in plain words ("senior front-end designer", "VAT accountant"). |

That lets you hand the AI a variable of data and have it produce something polished,
like a designed HTML report:

```powershell
# Build a modern HTML report from a variable, as a front-end designer would
$stats = Get-TolFolderSize -Path C:\Logs
Get-TolAIToSolve -Skillset "senior front-end designer" -Data $stats -MaxTokens 4096 `
    -Prompt "Build a clean, modern HTML report from this data. Return only the HTML, no code fences." |
    Out-File report.html

# Summarize a CSV you already loaded, as a data analyst
$rows = Import-Csv .\sales.csv
Get-TolAIToSolve -Skillset "data analyst" -Data $rows `
    -Prompt "Give me the top 3 takeaways from this sales data."

# Anonymize personal data in a message, as a GDPR officer (local Ollama, see note)
$clean = Get-TolAIToSolve -Provider Ollama -Skillset "GDPR / data-privacy officer" -Data $message `
    -Prompt "Anonymize all personal data: names, emails, phone numbers, addresses, national IDs. Return only the cleaned text."
```

> 🔒 **Privacy note for the anonymization case:** if you send personal data to a
> *cloud* provider to clean it, the original data has already left your machine and
> reached that provider. To anonymize genuinely sensitive content, use the **local
> Ollama** provider (`-Provider Ollama`), as shown above, so nothing leaves your box.

> ℹ️ For long output like a full HTML report, raise `-MaxTokens` (e.g. `4096`) or the
> answer gets cut off. Asking for "only the HTML, no code fences" gives you a file you
> can save and open directly.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Prompt` | string | required | The instruction (what to do). Accepts pipeline input. |
| `-Data` | object | none | The input to work on (any variable; objects become JSON). |
| `-Skillset` | string | none | The expertise the AI should apply (who should do it). |
| `-Provider` | string | `Claude` | `Claude`, `ChatGPT`, `Gemini`, `Mistral`, `LeChat`, or `Ollama`. |
| `-Model` | string | per provider | Override the model (see default models below). |
| `-ApiKey` | string | from env var | The API key; falls back to the provider's environment variable. |
| `-System` | string | none | Advanced: a raw system prompt. Combined with `-Skillset` if both are given. |
| `-AsJson` | switch | off | Ask for JSON and return it as a parsed object. |
| `-MaxTokens` | int | `1024` | Maximum answer length, in tokens. Raise it for long output (reports). |

### Default models

Override any of these with `-Model`. They are current at time of writing; update as
providers release newer ones.

| Provider | Default model |
|----------|---------------|
| Claude   | `claude-opus-4-8` |
| ChatGPT  | `gpt-4o` |
| Gemini   | `gemini-1.5-pro-latest` |
| Mistral  | `mistral-large-latest` |
| Ollama   | `llama3.2` |

## Return value

- Without `-AsJson`: the answer as a **string**.
- With `-AsJson`: a **parsed object** (`ConvertFrom-Json`). The tool strips stray
  code fences before parsing. If the response is not valid JSON, it warns and returns
  the raw text so you do not lose the answer.

## How it works

Every provider is the same shape under the hood: an HTTPS `POST` with your key in a
header and a JSON body. They differ only in the URL, the auth header, the body
layout, and where the answer sits in the response. This command hides those
differences behind one interface:

| Provider | Endpoint | Auth |
|----------|----------|------|
| Claude   | `api.anthropic.com/v1/messages` | `x-api-key` + `anthropic-version` header |
| ChatGPT  | `api.openai.com/v1/chat/completions` | `Authorization: Bearer` |
| Gemini   | `generativelanguage.googleapis.com/.../generateContent` | `x-goog-api-key` |
| Mistral  | `api.mistral.ai/v1/chat/completions` | `Authorization: Bearer` |
| Ollama   | `localhost:11434/api/chat` | none (local) |

## Troubleshooting

| Symptom | Likely cause / fix |
|---------|--------------------|
| `No API key for <provider>` | The environment variable is not set in this session. Set it, or pass `-ApiKey`. |
| `... request failed: 401` | The key is wrong, expired, or for the wrong provider. |
| `... request failed: 429` | Rate limit or no billing/credit on the provider account. |
| Ollama: connection refused | Ollama is not running, or `OLLAMA_HOST` points at the wrong address. Start it and `ollama pull <model>`. |
| `Response was not valid JSON` | The model wrapped or chatted around the JSON. Retry, tighten the prompt, or drop `-AsJson`. |

## Security

- Keep API keys in environment variables or a secrets manager, never in committed code.
- Treat prompts and responses as data leaving your machine: do not send secrets,
  credentials, or confidential content to a cloud provider. For sensitive work, use
  the local Ollama provider.

## Notes

Cross-platform (Windows, macOS, Linux). The cloud providers require internet access
and incur cost; Ollama is local and free.
