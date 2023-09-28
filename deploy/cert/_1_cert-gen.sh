#!/bin/bash
openssl req -x509 -newkey rsa:4096 -keyout ./keys/prikey.key -out ./keys/my.cert -days 365
