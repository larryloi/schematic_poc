#!/bin/bash
openssl rsautl -decrypt -inkey ./keys/prikey.key -in ./keys/encrypted_credentials.bin
