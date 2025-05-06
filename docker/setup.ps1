<#
.SYNOPSIS
    Initializes a .env file by prompting the user for each variable.

.DESCRIPTION
    - Uses Read-Host to request values.
    - Uses Test-Path to detect prior existence.
    - Uses Out-File / Add-Content to write the .env file.
#>

# Relative path to the script
$envPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath ".env"

# Variables to prompt: key and prompt
$varsToPrompt = @(
    @{ Key = "POSTGRES_USER"         ; Prompt = "Postgres User" ; Default = "admin" },
    @{ Key = "POSTGRES_PASSWORD"     ; Prompt = "Postgres Password (hidden)" ; Mask = $true ; Default = "admin" },
    @{ Key = "POSTGRES_DB"           ; Prompt = "Database Name" ; Default = "scauth" },
    @{ Key = "PGDATA"                ; Prompt = "PGDATA Path" ; Default = "/var/lib/postgresql/data/pgdata" },
    @{ Key = "PG_PORT"               ; Prompt = "Postgres Port" ; Default = "5432" },
    @{ Key = "PGADMIN_DEFAULT_EMAIL" ; Prompt = "pgAdmin Email" ; Default = "admin@example.com" },
    @{ Key = "PGADMIN_DEFAULT_PASSWORD"; Prompt = "pgAdmin Password (hidden)" ; Mask = $true ; Default = "admin" },
    @{ Key = "PGADMIN_PORT"          ; Prompt = "pgAdmin Port" ; Default = "8080" }
)

# If .env exists, confirm before overwriting
if (Test-Path -Path $envPath) {
        $ans = Read-Host "The .env file already exists. Overwrite? (y/N)"
        if ($ans -notin @("y","Y","yes","YES")) {
                Write-Host "Aborted. No changes were made."
                exit 1
        }
}

# Initialize the file (overwrites if it exists)
"" | Out-File -FilePath $envPath -Encoding utf8

foreach ($var in $varsToPrompt) {
        $key     = $var.Key
        $prompt  = $var.Prompt
        $default = $var.Default
        $mask    = $var.Mask -eq $true

        if ($mask) {
                # Read password in hidden mode
                $value = Read-Host -Prompt "$prompt" -AsSecureString 
                $value = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                                        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($value)
                                )
        }
        else {
                if ($default) {
                        $value = Read-Host -Prompt "$prompt [$default]"
                        if ([string]::IsNullOrWhiteSpace($value)) { $value = $default }
                }
                else {
                        $value = Read-Host -Prompt "$prompt"
                }
        }

        # Write line KEY=value
        "$key=$value" | Add-Content -Path $envPath
}

Write-Host "✔ .env file generated at $envPath"
