@{
    RootModule        = 'Tol.PowerShell.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'f4664588-acd1-4c54-8f5f-92fee61f32e7'
    Author            = 'Dave Van Gool'
    CompanyName       = 'The Office Lab BV'
    Copyright         = '(c) 2026 The Office Lab BV. MIT License.'
    Description       = 'A small set of practical PowerShell tools for daily work, by The Office Lab. All commands use the Tol noun prefix.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport = @(
        'Start-TolStayAwake',
        'New-TolProject',
        'Get-TolFolderSize',
        'Backup-TolItem',
        'Get-TolPublicIP',
        'Find-TolDuplicateFile',
        'Merge-TolCsv',
        'Test-TolEndpoint',
        'Write-TolLog',
        'Get-TolAIToSolve'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('tools', 'utility', 'productivity', 'windows', 'office', 'TheOfficeLab')
            LicenseUri   = 'https://github.com/The-Office-Lab-bv/Working-tools/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/The-Office-Lab-bv/Working-tools'
            ReleaseNotes = 'Initial module release: StayAwake, New-Project, FolderSize, Backup, PublicIP, DuplicateFile, MergeCsv, TestEndpoint.'
        }
    }
}
