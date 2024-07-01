#!/usr/bin/env bash

# Check if a parameter is provided
if [ -z "$1" ]; then
    echo "Error: No parameter provided. Please specify testnet or mainnet"
fi

# Check if the parameter is valid
if [ "$1" != "testnet" ] && [ "$1" != "mainnet" ]; then
    echo "Error: Invalid parameter '$1'. Acceptables values: testnet or mainnet"
fi

# get the storage keys
KEYS=$(curl -sX POST https://rpc."$1".near.org -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":"dontcare","method":"query","params":{"request_type":"view_state","finality":"final","account_id":"'"$FT_CONTRACT_ID"'","prefix_base64":""}}' | jq -c '.result.values | map([.key]) | flatten')
KEYS='{"keys":'$KEYS'}'

# call the clean method of the contract
near contract call-function as-transaction "$FT_CONTRACT_ID" clean base64-args $(echo $KEYS | base64) prepaid-gas '100.0 Tgas' attached-deposit '0 NEAR' sign-as "$FT_CONTRACT_ID" network-config "$1" sign-with-legacy-keychain
