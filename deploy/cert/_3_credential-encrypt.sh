#!/bin/bash

# Prompt for username
echo -n "Enter username: "
read username

# Prompt for password
echo -n "Enter password: "
read -s password

# Encrypt the credentials
echo "${username}:${password}" | openssl rsautl -encrypt -inkey ./keys/pubkey.pem -pubin -out ./keys/encrypted_credentials.bin

