
# Pre-requisites

1. Install [Rust](https://www.rust-lang.org/tools/install).

2. Install [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools).

3. Install [Git](https://git-scm.com/downloads).

4. A [GitHub account](https://github.com/).

# Setup

1. Clone the [repository](https://github.com/Bonfida/token-vesting)

    ```bash
    git clone https://github.com/Bonfida/token-vesting.git
    ```

2. Change directory to the repository.

    ```bash
    cd token-vesting
    ```

3. Create a file called `.variables` at the root of the repository.

    ```bash
    touch .variables
    ```

   **Note:**
   - The purposes of this file is to store all of the generated values.
   - After every time you edit this file, run:  

   ```bash
   source PATH_TO_FILE/.variables
   ```

# Building the Program Directory

1. Under the assumption you are in the root directory of the repository, change directory to the `program` directory.

    ```bash
    cd program
    ```

2. Update Cargo dependencies to the latest compatible versions.

    ```bash
    cargo update
    ```

3. Build the Solana program.

    ```bash
    cargo build-bpf
    ```

# Deploying the Program

1. Generate a Solana keypair for the owner.

    ```bash
    solana-keygen new --outfile ~/.config/solana/owner_id.json --force
    ```

2. Generate a Solana keypair for the initial recipient.

    ```bash
    solana-keygen new --outfile ~/.config/solana/initial_id.json --force
    ```

3. Generate a Solana keypair for the final recipient.

    ```bash
    solana-keygen new --outfile ~/.config/solana/final_id.json --force
    ```

4. Airdrop 2 SOL to the owner's Solana keypair.

    ```bash
    solana airdrop 2 --url https://api.devnet.solana.com ~/.config/solana/owner_id.json
    ```

5. Deploy the program to Solana Devnet and add the program ID to `.variables`.

    ```bash
    solana program deploy ./program/target/deploy/token_vesting.so --url https://api.devnet.solana.com --keypair ~/.config/solana/owner_id.json
    ```

    ```bash
    echo "export PROGRAM_ID=<PROGRAM_ID>" > PATH_TO_FILE/.variables
    ```

# Creating the Mint & Accounts

1. Create mint and add the mint address to `.variables`.

    ```bash
    spl-token create-token --url https://api.devnet.solana.com --fee-payer ~/.config/solana/owner_id.json
    ```

    ```bash
    echo "export MINT=<TOKEN_MINT_ADDRESS>" >> PATH_TO_FILE/.variables
    ```

2. Create an account for the owner and add the account address to `.variables`.

    ```bash
    spl-token create-account $MINT --url https://api.devnet.solana.com --owner ~/.config/solana/owner_id.json --fee-payer ~/.config/solana/owner_id.json
    ```

    ```bash
    echo "export OWNER_ACCOUNT=<OWNER_TOKEN_ACCOUNT>" >> PATH_TO_FILE/.variables
    ```

3. Mint the test token, specified by the mint address, to the owner's account.

    ```bash
    spl-token mint $MINT 100000 --url https://api.devnet.solana.com $OWNER_ACCOUNT --fee-payer ~/.config/solana/owner_id.json
    ```

4. Create an account for the initial recipient and add the account address to `.variables`.

    ```bash
    spl-token create-account $MINT --url https://api.devnet.solana.com --owner ~/.config/solana/initial_id.json --fee-payer ~/.config/solana/owner_id.json
    ```

    ```bash
    echo "export INITIAL_ACCOUNT=<INITIAL_RECIPIENT_ACCOUNT>" >> PATH_TO_FILE/.variables
    ```

5. Create an account for the final recipient and add the account address to `.variables`.

    ```bash
    spl-token create-account $MINT --url https://api.devnet.solana.com --owner ~/.config/solana/final_id.json --fee-payer ~/.config/solana/owner_id.json
    ```

    ```bash
    echo "export FINAL_ACCOUNT=<FINAL_RECIPIENT_ACCOUNT>" >> PATH_TO_FILE/.variables
    ```

# Building the CLI Directory

1. Under the assumption you are in the root directory of the repository, change directory to the `cli` directory.

    ```bash
    cd cli
    ```

2. Update Cargo dependencies to the latest compatible versions.

    ```bash
    cargo update
    ```

3. Replace all occurrences of `recent_blockhash` with `latest_blockhash` in `src/main.rs`.

4. Build the Rust program.

    ```bash
    cargo build
    ```

# Token Vesting Commands

## Creating a vesting instance with a schedule based on a list of release times

### Parameters

- `--mint_address`: The mint address of the token.
- `--source_owner`: Path to the owner's Solana keypair.
- `--source_token_address`: The account address of the owner.
- `--destination_token_address`: The account address of the initial recipient.
- `--amounts`: A list of the amounts of tokens to release at each release time.
- `--release-times`: A list of the release times in Unix timestamps.
- `--payer`: Path to the payer's Solana keypair.

### Command

```bash
echo "RUST_BACKTRACE=1 <PATH_TO_CLI_DIR>/target/debug/vesting-contract-cli \
    --url https://api.devnet.solana.com \
    --program_id $PROGRAM_ID \
    create \
    --mint_address $MINT \
    --source_owner <PATH_TO_OWNER_KEYPAIR> \
    --source_token_address $OWNER_ACCOUNT \
    --destination_token_address $INITIAL_ACCOUNT \
    --amounts <AMOUNTS> \
    --release-times <RELEASE_TIMES> \
    --payer <PATH_TO_PAYER_KEYPAIR>" --verbose | bash
```

Before running the command:

- Replace `<PATH_TO_CLI_DIR>`, `<PATH_TO_OWNER_KEYPAIR>`, `<AMOUNTS>`, `<RELEASE_TIMES>`, and `<PATH_TO_PAYER_KEYPAIR>` with the appropriate values.
- `$VARIABLES` are defined in the `.variables` file.

After running the command, save the seed value in the `.variables` file.

```bash
echo "export SEED=<SEED_VALUE>" >> <PATH_TO_FILE>/.variables
```

## Creating a vesting instance with a linear schedule

### Parameters

- `--mint_address`: The mint address of the token.
- `--source_owner`: Path to the owner's Solana keypair.
- `--source_token_address`: The account address of the owner.
- `--destination_token_address`: The account address of the initial recipient.
- `--amounts`: A list of the amounts of tokens to release at each release time.
- `--release-frequency`: The frequency of the release in seconds.
- `--start-date-time`: The start date and time of the vesting schedule in the ISO 8601 format.
- `--end-date-time`: The end date and time of the vesting schedule in the ISO 8601 format.
- `--payer`: Path to the payer's Solana keypair.

### Command

```bash
echo "RUST_BACKTRACE=1 <PATH_TO_CLI_DIR>/target/debug/vesting-contract-cli \
    --url https://api.devnet.solana.com \
    --program_id $PROGRAM_ID \
    create \
    --mint_address $MINT \
    --source_owner <PATH_TO_OWNER_KEYPAIR> \
    --source_token_address $OWNER_ACCOUNT \
    --destination_token_address $INITIAL_ACCOUNT \
    --amounts <AMOUNTS> \
    --release-frequency <RELEASE_FREQUENCY> \
    --start-date-time <START_DATE_TIME> \
    --end-date-time <END_DATE_TIME> \
    --payer <PATH_TO_PAYER_KEYPAIR>" --verbose | bash
```

Before running the command:

- Replace `<PATH_TO_CLI_DIR>`, `<PATH_TO_OWNER_KEYPAIR>`, `<AMOUNTS>`, `<RELEASE_FREQUENCY>`, `<START_DATE_TIME>`, `<END_DATE_TIME>`, and `<PATH_TO_PAYER_KEYPAIR>` with the appropriate values.
- `$VARIABLES` are defined in the `.variables` file.

After running the command, save the seed value in the `.variables` file.

```bash
echo "export SEED=<SEED_VALUE>" >> <PATH_TO_FILE>/.variables
```

## Observing the contract state

### Parameters

- `--seed`: The seed value of the vesting instance.

### Command

```bash
echo "RUST_BACKTRACE=1 <PATH_TO_CLI_DIR>/target/debug/vesting-contract-cli \
    --url https://api.devnet.solana.com \
    --program_id $PROGRAM_ID \
    info \
    --seed $SEED" | bash
```

Before running the command:

- Replace `<PATH_TO_CLI_DIR>` with the appropriate value.
- `$VARIABLES` are defined in the `.variables` file.

## Changing the destination of the tokens from the initial to final recipient

### Parameters

- `--seed`: The seed value of the vesting instance.
- `--current_destination_owner`: Path to the initial recipient's Solana keypair.
- `--new_destination_token_address`: The account address of the final recipient.
- `--payer`: Path to the payer's Solana keypair.

### Command

```bash
echo "RUST_BACKTRACE=1 <PATH_TO_CLI_DIR>/target/debug/vesting-contract-cli \
    --url https://api.devnet.solana.com \
    --program_id $PROGRAM_ID \
    change-destination \
    --seed $SEED \
    --current_destination_owner <PATH_TO_INITIAL_KEYPAIR> \
    --new_destination_token_address $FINAL_ACCOUNT \
    --payer <PATH_TO_PAYER_KEYPAIR>" | bash
```

Before running the command:

- Replace `<PATH_TO_CLI_DIR>` with the appropriate value.
- `$VARIABLES` are defined in the `.variables` file.

## Unlocking the tokens according to the schedule

### Parameters

- `--seed`: The seed value of the vesting instance.
- `--payer`: Path to the payer's Solana keypair.

### Command

```bash
echo "RUST_BACKTRACE=1 <PATH_TO_CLI_DIR>/target/debug/vesting-contract-cli \
    --url https://api.devnet.solana.com \
    --program_id $PROGRAM_ID \
    unlock \
    --seed $SEED \
    --payer <PATH_TO_PAYER_KEYPAIR>" | bash
```

Before running the command:

- Replace `<PATH_TO_CLI_DIR>` and `<PATH_TO_PAYER_KEYPAIR>` with the appropriate values.
- `$VARIABLES` are defined in the `.variables` file.

# Token Vesting Example

Coming soon.

# Checking the Token Balances

## Manual Method

```bash
spl-token balance $MINT --url https://api.devnet.solana.com --owner <PATH_TO_KEYPAIR>
```

Before running the command:

- Replace `<PATH_TO_KEYPAIR>` with the appropriate value.
- `$MINT` is defined in the `.variables` file.

## Automated Method

1. Move the file `check_balances.sh` to the `cli` directory.

2. Edit the file `check_balances.sh` and replace by replacing `<PATH_TO_FILE>` and the `PATH_TO_X_KEYPAIR`s with the appropriate values.

3. Make the file executable.

    ```bash
    chmod +x check_balances.sh
    ```

4. Run the script.

    ```bash
    ./check_balances.sh
    ```

---

*This guide was created by Saad Bhatti.*

*Last Updated: September 17, 2024.*
