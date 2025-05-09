<#
.SYNOPSIS
    Creates a .env file by prompting the user for each variable, and builds the DATABASE_URL.
    Also builds a servers.json file for the pgAdmin4 connection.
.DESCRIPTION
    - Uses Read-Host to request values.
    - Overwrites existing .env / servers.json if confirmed.
    - Writes all keys to both .env and servers.json.
#>

# --- 1) Determine script directory and paths ---
if ($MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    $exePath = [Environment]::GetCommandLineArgs()[0]
    $scriptDir = Split-Path -Parent $exePath
    if (-not $scriptDir) { $scriptDir = Get-Location }
}
Set-Location $scriptDir

$envPath     = Join-Path $scriptDir '.env'
$jsonPath    = Join-Path $scriptDir 'servers.json'

# --- 2) Define all variables to prompt for ---
$varsToPrompt = @(
    @{ Key = 'POSTGRES_USER';            Prompt = 'Postgres User';                  Default = 'admin' },
    @{ Key = 'POSTGRES_PASSWORD';        Prompt = 'Postgres Password (hidden)';     Default = 'admin'; Mask = $true },
    @{ Key = 'POSTGRES_DB';              Prompt = 'Database Name';                  Default = 'scauth' },
    @{ Key = 'PGDATA';                   Prompt = 'PGDATA Path';                    Default = '/var/lib/postgresql/data/pgdata' },
    @{ Key = 'PG_PORT';                  Prompt = 'Postgres Port';                  Default = '5432' },
    @{ Key = 'PGADMIN_DEFAULT_EMAIL';    Prompt = 'pgAdmin Default Email';          Default = 'admin@example.com' },
    @{ Key = 'PGADMIN_DEFAULT_PASSWORD'; Prompt = 'pgAdmin Default Password (hidden)'; Default = 'admin'; Mask = $true },
    @{ Key = 'PGADMIN_PORT';             Prompt = 'pgAdmin Port';                   Default = '8080' }
)

# --- 3) Confirm overwrite of .env & servers.json if they exist ---
if (Test-Path $envPath) {
    $name = Split-Path $envPath -Leaf
    $ans = Read-Host "$name already exists. Overwrite? (y/N)"
    if ($ans -notin @('y','Y','yes','YES')) {
        Write-Host "Aborted. '$name' unchanged."
        exit 1
    }
}

# --- 4) Create/overwrite .env ---
"" | Out-File -FilePath $envPath -Encoding utf8
$collected = @{}
foreach ($var in $varsToPrompt) {
    $key     = $var.Key
    $prompt  = $var.Prompt
    $default = $var.Default
    $mask    = $var.ContainsKey('Mask') -and $var.Mask

    if ($mask) {
        $secure = Read-Host -Prompt "$prompt" -AsSecureString
        $value  = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
                )
    } else {
        $input  = Read-Host -Prompt "$prompt [$default]"
        $value  = if ([string]::IsNullOrWhiteSpace($input)) { $default } else { $input }
    }

    # store and write to .env
    $collected[$key] = $value
    "$key=$value" | Add-Content -Path $envPath
}

# --- 5) Add DATABASE_URL to .env ---
$databaseUrl = "postgres://$($collected.POSTGRES_USER):$($collected.POSTGRES_PASSWORD)@localhost:$($collected.PG_PORT)/$($collected.POSTGRES_DB)"
"DATABASE_URL=$databaseUrl" | Add-Content -Path $envPath
Write-Host ".env written to $envPath"

# --- 6) Load back all .env vars into $envVars ---
$envVars = Get-Content $envPath |
    Where-Object { $_ -match '^(.*?)=(.*)$' } |
    ForEach-Object {
        $parts = $_ -split '=', 2
        ,@{ Key = $parts[0]; Value = $parts[1] }
    } |
    ForEach-Object -Begin { $d = @{} } -Process { $d[$_.Key] = $_.Value } -End { $d }

# --- 7) Build servers.json with two entries ---
$serversJson = @{
    Servers = @{
        # 1 = PostgreSQL server
        "1" = @{
            Name          = "PostgreSQL"
            Group         = "Servers"
            Host          = "db-scauth"
            Port          = [int]$envVars.PG_PORT
            MaintenanceDB = $envVars.POSTGRES_DB
            Username      = $envVars.POSTGRES_USER
            SSLMode       = "prefer"
            PassFile      = "/pgpass"
        }
    }
}

# --- 8) Write servers.json ---
$serversJson |
    ConvertTo-Json -Depth 4 |
    Out-File -FilePath $jsonPath -Encoding utf8

Write-Host "servers.json written to $jsonPath"
