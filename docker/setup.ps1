<#
.SYNOPSIS
    Initializes a .env file by prompting the user for each variable, and builds a DATABASE_URL.
.DESCRIPTION
    - Uses Read-Host to request values.
    - Uses Test-Path to detect prior existence.
    - Uses Out-File / Add-Content to write the .env file.
    - After collecting credentials, constructs DATABASE_URL in the form:
      postgres://<POSTGRES_USER>:<POSTGRES_PASSWORD>@localhost:<PG_PORT>/<POSTGRES_DB>
#>

# Determine script directory
if ($MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
} else {
    $exePath   = [Environment]::GetCommandLineArgs()[0]
    $scriptDir = Split-Path -Parent -Path $exePath
    if (-not $scriptDir) { $scriptDir = Get-Location }
}

Set-Location $scriptDir

$envPath = Join-Path -Path $scriptDir -ChildPath ".env"

# Define variables to prompt
$varsToPrompt = @(
    @{ Key = 'POSTGRES_USER'; Prompt = 'Postgres User'; Default = 'admin' },
    @{ Key = 'POSTGRES_PASSWORD'; Prompt = 'Postgres Password (hidden)'; Mask = $true; Default = 'admin' },
    @{ Key = 'POSTGRES_DB'; Prompt = 'Database Name'; Default = 'scauth' },
    @{ Key = 'PGDATA'; Prompt = 'PGDATA Path'; Default = '/var/lib/postgresql/data/pgdata' },
    @{ Key = 'PG_PORT'; Prompt = 'Postgres Port'; Default = '5432' },
    @{ Key = 'PGADMIN_DEFAULT_EMAIL'; Prompt = 'pgAdmin Email'; Default = 'admin@example.com' },
    @{ Key = 'PGADMIN_DEFAULT_PASSWORD'; Prompt = 'pgAdmin Password (hidden)'; Mask = $true; Default = 'admin' },
    @{ Key = 'PGADMIN_PORT'; Prompt = 'pgAdmin Port'; Default = '8080' }
)

# Confirm overwrite if exists
if (Test-Path -Path $envPath) {
    $ans = Read-Host "The .env file already exists. Overwrite? (y/N)"
    if ($ans -notin @('y','Y','yes','YES')) {
        Write-Host 'Aborted. No changes were made.'
        exit 1
    }
}

# Start .env
"" | Out-File -FilePath $envPath -Encoding utf8

# Collect and write values
$collected = @{}
foreach ($var in $varsToPrompt) {
    $key     = $var.Key
    $prompt  = $var.Prompt
    $default = $var.Default
    $mask    = $var.Mask -eq $true

    if ($mask) {
        $secure = Read-Host -Prompt "$prompt" -AsSecureString
        $value  = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
                )
    } else {
        if ($default) {
            $input = Read-Host -Prompt "$prompt [$default]"
            $value = if ([string]::IsNullOrWhiteSpace($input)) { $default } else { $input }
        } else {
            $value = Read-Host -Prompt "$prompt"
        }
    }

    # Save and write
    $collected[$key] = $value
    "${key}=$value" | Add-Content -Path $envPath
}

# Construct DATABASE_URL
$uriUser     = $collected['POSTGRES_USER']
$uriPassword = $collected['POSTGRES_PASSWORD']
$uriHost     = 'localhost'
$uriPort     = $collected['PG_PORT']
$uriDb       = $collected['POSTGRES_DB']

$databaseUrl = "postgres://${uriUser}:${uriPassword}@${uriHost}:${uriPort}/${uriDb}"
"DATABASE_URL=$databaseUrl" | Add-Content -Path $envPath

Write-Host ".env file generated at $envPath with DATABASE_URL."
