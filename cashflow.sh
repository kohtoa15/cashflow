QUERY="$2"
INVENTORY="$(cat $1)"
echo -e "$(date '+(%d,%m,%Y)')\n$INVENTORY\n$QUERY" | cabal run
