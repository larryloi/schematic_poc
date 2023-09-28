#!/bin/bash
openssl x509 -pubkey -noout -in ./keys/my.cert  > ./keys/pubkey.pem
