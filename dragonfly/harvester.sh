#!/bin/bash

# Description: Uses Foundry to harvest smart contract source code and ABIs from Etherscan for a list of addresses.
# Usage: Set the following enviroment variables and run the script. It will output a ready-to-go Foundry folder and artifact for each target contract.
# ETHERSCAN_API_KEY: Your Etherscan API key for fetching contract ABIs.
# TARGETS: A space-separated list of Ethereum contract addresses to harvest (e.g., "0x123 0xabc").
# CHAIN_ID: The ID of the Ethereum chain to target (e.g., "1" for Mainnet).

# Get the absolute path of the script's parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse flags
FORCE=false
if [[ "$1" == "-f" || "$1" == "--force" ]]; then
    FORCE=true
fi

# Load required variables from .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    # Export variables, properly handling spaces in values
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
else
    echo "Error: Config file not found at $SCRIPT_DIR/.env"
    exit 1
fi

# Convert space-separated TARGETS string into a proper BASH array
TARGETS=($TARGETS)

# Verify that required variables are set
if [ -z "$ETHERSCAN_API_KEY" ] || [ ${#TARGETS[@]} -eq 0 ] || [ -z "$CHAIN_ID" ]; then
    echo "Error: One or more required variables are not set."
    exit 1
else
    echo "Loaded Etherscan API Key: $ETHERSCAN_API_KEY"
    echo "Loaded Chain ID: $CHAIN_ID"
    echo "Loaded Target List: ${#TARGETS[@]}"
fi

# Iterate over the addresses to collect each contract
for ADDRESS in "${TARGETS[@]}"; do
    # Trim whitespace from the address loop variable
    ADDRESS=$(echo "$ADDRESS" | xargs)

    TARGET_DIR="$SCRIPT_DIR/$ADDRESS"
    ARTIFACT="$TARGET_DIR/${ADDRESS}.txt"
    
    # Contract verification check
    IS_VERIFIED=$(curl -s "https://api.etherscan.io/v2/api?chainid=$CHAIN_ID&module=contract&action=getabi&address=$ADDRESS&apikey=$ETHERSCAN_API_KEY" | jq -r '.status')
    
    if [ "$IS_VERIFIED" != "1" ] && [ "$FORCE" = false ]; then
        echo "Contract not verified. Skipping (use -f/--force to override)..."
        continue
    fi

    echo "Generating contract artifact: $ARTIFACT"

    # Remove existing output folder to start fresh (if it exists)
    if [ -d "$TARGET_DIR" ]; then
        echo "Existing output found, updating..."
        rm -rf "$TARGET_DIR"
    fi

    # Use forge clone to fetch the source and setup the project for testing
    forge clone "$ADDRESS" "$TARGET_DIR" --chain "$CHAIN_ID" --etherscan-api-key "$ETHERSCAN_API_KEY" >/dev/null 2>&1
    
    # Enter directory to handle test scaffolding and artifact compilation
    cd "$TARGET_DIR" || exit
    mkdir -p test
    [[ ! -d "lib/forge-std" ]] && forge install foundry-rs/forge-std --no-commit --quiet >/dev/null 2>&1

    # Fetch contract ABI from Etherscan and save to artifact
    echo "--- START: ABI ---" > "$ARTIFACT"
    ABI_RAW=$(curl -s "https://api.etherscan.io/v2/api?chainid=$CHAIN_ID&module=contract&action=getabi&address=$ADDRESS&apikey=$ETHERSCAN_API_KEY" | jq -r '.result')
    echo "$ABI_RAW" >> "$ARTIFACT"
    echo -e "\n--- END: ABI ---" >> "$ARTIFACT"

    # Extract contract source from cloned files to artifact
    find src -type f -name "*.sol" | while read -r FILE; do
        echo -e "  -> Adding File: $FILE"

        {
            echo "--- START: $FILE ---"
            cat "$FILE"
            echo -e "\n--- END: $FILE ---"
        } >> "$ARTIFACT"
    done

    # Back out to script directory
    cd "$SCRIPT_DIR"

    if [ -f "$ARTIFACT" ]; then
        echo "Finished extracting contract source to $ARTIFACT (lines: $(wc -l < "$ARTIFACT"))"
    else
        echo "An error occurred while extracting contract source."
    fi
done

# Print artifacts manifest
echo "Done! All contracts downloaded:"
for dir in "$SCRIPT_DIR"/0x*; do
  if [ -d "$dir" ]; then
      echo "- $dir"
  fi
done
