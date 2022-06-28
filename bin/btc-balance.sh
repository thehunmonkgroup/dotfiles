#!/usr/bin/env bash

DEFAULT_ADDRESSES="
bc1qurc0lf6xsm5ktmrvws0nnpwenf79qkjevpxvnj
bc1q6ney3se79j3lqswcg5dr2025kc2548c6p4vec2
"

ADDRESSES="${1:-${DEFAULT_ADDRESSES}}"
SCALE=8
BTC_DIVISOR=100000000
total=0

for address in ${ADDRESSES}; do
  balance=$(curl -s https://api.blockcypher.com/v1/btc/main/addrs/${address} | jq .final_balance)
  decimal_balance=$(echo "scale=${SCALE}; ${balance} / ${BTC_DIVISOR}" | bc -l)
  echo "Balance for ${address}: ${decimal_balance} BTC"
  total=$(echo "scale=${SCALE}; ${total} + ${decimal_balance}" | bc -l)
done

echo "Total: ${total} BTC"

exit 0
