#!/bin/bash

# --- 1) Determine script directory and paths ---
script_dir=$(dirname "$(readlink -f "$0")")
env_path="$script_dir/.env"
json_path="$script_dir/servers.json"

# --- 2) Define all variables to prompt for ---
declare -A vars_to_prompt=(
    ["POSTGRES_USER"]="Postgres User:admin"
    ["POSTGRES_PASSWORD"]="Postgres Password (hidden):admin:hidden"
    ["POSTGRES_DB"]="Database Name:scauth"
    ["PGDATA"]="PGDATA Path:/var/lib/postgresql/data/pgdata"
    ["PG_PORT"]="Postgres Port:5432"
    ["PGADMIN_DEFAULT_EMAIL"]="pgAdmin Default Email:admin@example.com"
    ["PGADMIN_DEFAULT_PASSWORD"]="pgAdmin Default Password (hidden):admin:hidden"
    ["PGADMIN_PORT"]="pgAdmin Port:8080"
)

# --- 3) Confirm overwrite of .env & servers.json if they exist ---
if [[ -f "$env_path" ]]; then
    read -p "$(basename "$env_path") already exists. Overwrite? (y/N): " ans
    if [[ ! "$ans" =~ ^[yY](es)?$ ]]; then
        echo "Aborted. '$(basename "$env_path")' unchanged."
        exit 1
    fi
fi

# --- 4) Create/overwrite .env ---
> "$env_path"
declare -A collected
for key in "${!vars_to_prompt[@]}"; do
    IFS=":" read -r prompt default mask <<< "${vars_to_prompt[$key]}"
    if [[ "$mask" == "hidden" ]]; then
        read -s -p "$prompt: " value
        echo
    else
        read -p "$prompt [$default]: " value
    fi
    value=${value:-$default}
    collected["$key"]="$value"
    echo "$key=$value" >> "$env_path"
done

# --- 5) Add DATABASE_URL to .env ---
database_url="postgres://${collected[POSTGRES_USER]}:${collected[POSTGRES_PASSWORD]}@localhost:${collected[PG_PORT]}/${collected[POSTGRES_DB]}"
echo "DATABASE_URL=$database_url" >> "$env_path"
echo ".env written to $env_path"

# --- 6) Load back all .env vars into env_vars ---
declare -A env_vars
while IFS="=" read -r key value; do
    env_vars["$key"]="$value"
done < <(grep -E '^[^#]+=' "$env_path")

# --- 7) Build servers.json with two entries ---
read -r -d '' servers_json <<EOF
{
    "Servers": {
        "1": {
            "Name": "PostgreSQL",
            "Group": "Servers",
            "Host": "db-scauth",
            "Port": ${env_vars[PG_PORT]},
            "MaintenanceDB": "${env_vars[POSTGRES_DB]}",
            "Username": "${env_vars[POSTGRES_USER]}",
            "SSLMode": "prefer",
            "PassFile": "/pgpass"
        }
    }
}
EOF

# --- 8) Write servers.json ---
echo "$servers_json" | jq '.' > "$json_path"
echo "servers.json written to $json_path"