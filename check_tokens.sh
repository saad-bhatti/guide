#!/bin/bash

# Source environment variables from the .variables file
source <PATH_TO_FILE>/.variables

# Check if the MINT variable is set
if [ -z "$MINT" ]; then
  echo "Error: MINT variable is not set. Please define it in <PATH_TO_FILE>/.variables."
  exit 1
fi

# Command to check owner tokens
echo "Owner tokens:"
spl-token balance $MINT --url https://api.devnet.solana.com --owner <PATH_TO_OWNER_KEYPAIR>

# Command to check initial recipient tokens
echo "Initial recipient tokens:"
spl-token balance $MINT --url https://api.devnet.solana.com --owner <PATH_TO_INITIAL_KEYPAIR>

# Command to check final recipient tokens
echo "Final recipient tokens:"
spl-token balance $MINT --url https://api.devnet.solana.com --owner <PATH_TO_FINAL_KEYPAIR>
