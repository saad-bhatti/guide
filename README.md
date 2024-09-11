
# Setup

1. Install rust and solana CLI.

2. Clone the repository.

3. Create a file called `.variables` within the repository.

   **Note:**
   - This file will store all of the generated values.
   - Each time adding a new value, run `source .variables`.

# Program Build (Start from Base Directory)

1. Change directory to the directory containing the program.

    ```bash
    token-vesting$ cd program
    ```

2. Update Cargo dependencies to the latest compatible versions.

    ```bash
    token-vesting/program$ cargo update
    ```

3. Build Solana programs for the BPF target.

    ```bash
    token-vesting/program$ cargo build-bpf
    ```

# Program Deploy (Start from Base Directory)

1. Generate an owner Solana keypair.

    ```bash
    token-vesting$ solana-keygen new --outfile ~/.config/solana/owner_id.json --force
    ```

2. Generate an initial recipient Solana keypair.

    ```bash
    token-vesting$ solana-keygen new --outfile ~/.config/solana/initial_id.json --force
    ```

3. Generate a final recipient Solana keypair.

    ```bash
    token-vesting$ solana-keygen new --outfile ~/.config/solana/final_id.json --force
    ```

4. Airdrop 2 SOL to the owner's Solana keypair.

    ```bash
    token-vesting$ solana airdrop 2 --url https://api.devnet.solana.com ~/.config/solana/owner_id.json
    ```

5. Deploy the program to Solana Devnet and add the program ID to `.variables`.

    ```bash
    token-vesting$ solana program deploy ./program/target/deploy/token_vesting.so --url https://api.devnet.solana.com --keypair ~/.config/solana/owner_id.json
    token-vesting$ echo "export PROGRAM_ID=<PROGRAM_ID>" > ./.variables
    ```

# Create Mint & Account (Start from Base Directory)

1. Create mint and add the mint address to `.variables`.

    ```bash
    token-vesting$ spl-token create-token --url https://api.devnet.solana.com --fee-payer ~/.config/solana/owner_id.json
    token-vesting$ echo "export MINT=<TOKEN_MINT_ADDRESS>" >> ./.variables
    ```

2. Create owner account and add the account address to `.variables`.

    ```bash
    token-vesting$ spl-token create-account $MINT --url https://api.devnet.solana.com --owner ~/.config/solana/owner_id.json --fee-payer ~/.config/solana/owner_id.json
    token-vesting$ echo "export OWNER_ACCOUNT=<OWNER_TOKEN_ACCOUNT>" >> ./.variables
    ```

3. Mint the test token from the mint address to the owner account.

    ```bash
    token-vesting$ spl-token mint $MINT 100000 --url https://api.devnet.solana.com $OWNER_ACCOUNT --fee-payer ~/.config/solana/owner_id.json
    ```

4. Create initial recipient token account and add the account address to `.variables`.

    ```bash
    token-vesting$ spl-token create-account $MINT --url https://api.devnet.solana.com --owner ~/.config/solana/initial_id.json --fee-payer ~/.config/solana/owner_id.json
    token-vesting$ echo "export INITIAL_ACCOUNT=<INITIAL_RECIPIENT_ACCOUNT>" >> ./.variables
    ```

5. Create final recipient token account and add the account address to `.variables`.

    ```bash
    token-vesting$ spl-token create-account $MINT --url https://api.devnet.solana.com --owner ~/.config/solana/final_id.json --fee-payer ~/.config/solana/owner_id.json
    token-vesting$ echo "export FINAL_ACCOUNT=<FINAL_RECIPIENT_ACCOUNT>" >> ./.variables
    ```

# CLI Build (Start from Base Directory)

1. Change directory to the directory containing the CLI.

    ```bash
    token-vesting$ cd cli
    ```

2. Update Cargo dependencies to the latest compatible versions.

    ```bash
    token-vesting/cli$ cargo update
    ```

3. Replace all occurrences of `recent_blockhash` with `latest_blockhash` in `src/main.rs`.

4. Build the CLI.

    ```bash
    token-vesting/cli$ cargo build
    ```

# Token Vesting (Start from Base Directory)

1. Change directory to the directory containing the CLI.

    ```bash
    token-vesting$ cd cli
    ```

2. Create the vesting instance and add the seed to `.variables`.

    ```bash
    token-vesting/cli$ echo "RUST_BACKTRACE=1 ./target/debug/vesting-contract-cli \
        --url https://api.devnet.solana.com \
        --program_id $PROGRAM_ID \
        create \
        --mint_address $MINT \
        --source_owner ~/.config/solana/owner_id.json \
        --source_token_address $OWNER_ACCOUNT \
        --destination_token_address $INITIAL_ACCOUNT \
        --amounts 2,1,3,! \
        --release-times 1,28504431,2850600000000000,! \
        --payer ~/.config/solana/owner_id.json" --verbose | bash
    token-vesting/cli$ echo "export SEED=<SEED_VALUE>" >> ../.variables
    ```

3. Observe the contract state.

    ```bash
    token-vesting/cli$ echo "RUST_BACKTRACE=1 ./target/debug/vesting-contract-cli \
        --url https://api.devnet.solana.com \
        --program_id $PROGRAM_ID \
        info \
        --seed $SEED" | bash
    ```

4. Change the holder of the tokens from the initial recipient to the final recipient.

    ```bash
    token-vesting/cli$ echo "RUST_BACKTRACE=1 ./target/debug/vesting-contract-cli \
        --url https://api.devnet.solana.com \
        --program_id $PROGRAM_ID \
        change-destination \
        --seed $SEED \
        --current_destination_owner ~/.config/solana/initial_id.json \
        --new_destination_token_address $FINAL_ACCOUNT \
        --payer ~/.config/solana/owner_id.json" | bash
    ```

5. Unlock the tokens according to the schedule.

    ```bash
    token-vesting/cli$ echo "RUST_BACKTRACE=1 ./target/debug/vesting-contract-cli \
        --url https://api.devnet.solana.com \
        --program_id $PROGRAM_ID \
        unlock \
        --seed $SEED \
        --payer ~/.config/solana/owner_id.json" | bash
    ```

# Linear Token Vesting (Start from Base Directory)

1. Change directory to the directory containing the CLI.

    ```bash
    token-vesting$ cd cli
    ```

2. Create linear vesting, transferring the tokens to the final recipient.

    ```bash
    token-vesting/cli$ echo "RUST_BACKTRACE=1 ./target/debug/vesting-contract-cli \
        --url https://api.devnet.solana.com \
        --program_id $PROGRAM_ID \
        create \
        --mint_address $MINT \
        --source_owner ~/.config/solana/owner_id.json \
        --source_token_address $OWNER_ACCOUNT \
        --destination_token_address $INITIAL_ACCOUNT \
        --amounts 42,! \
        --release-frequency 'P1D' \
        --start-date-time '2024-09-10T00:00:00Z' \
        --end-date-time '2024-09-17T00:00:00Z' \
        --payer ~/.config/solana/owner_id.json" --verbose | bash
    ```

---

*This guide was created by Saad Bhatti.*
*Last Updated: September 10, 2024.*
