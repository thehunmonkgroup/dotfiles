#!/usr/bin/env bash

DEFAULT_ADDRESS="bc1q6ney3se79j3lqswcg5dr2025kc2548c6p4vec2"

ADDRESS="${1:-${DEFAULT_ADDRESS}}"
SCALE=8
BTC_DIVISOR=100000000

balance=$(curl -s https://api.blockcypher.com/v1/btc/main/addrs/${ADDRESS} | jq .final_balance)
decimal_balance=$(echo "scale=${SCALE}; ${balance} / ${BTC_DIVISOR}" | bc -l)

echo "Balance for ${ADDRESS}: ${decimal_balance} BTC"

exit 0
