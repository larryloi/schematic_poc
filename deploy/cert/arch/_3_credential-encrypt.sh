#!/bin/bash
echo "schematic:schematic123" | openssl rsautl -encrypt -inkey ./keys/pubkey.pem -pubin -out ./keys/encrypted_credentials.bin

