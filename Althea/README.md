<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/althea.png?raw=true">
</p>

# Althea Network Testnet | Chain ID : althea_417834-3

### Explorer:
>-  https://explorer.hexnodes.co/ALTHEA-TESTNET

### Automatic Installer
You can setup your Althea Network fullnode in few minutes by using automated script below.
```
wget -O althea.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Althea/althea.sh && chmod +x althea.sh && ./althea.sh
```

### Snapshot
```
sudo systemctl stop althea
cp $HOME/.althea/data/priv_validator_state.json $HOME/.althea/priv_validator_state.json.backup
rm -rf $HOME/.althea/data

curl -L https://snap.hexnodes.co/althea/althea.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.althea/
mv $HOME/.althea/priv_validator_state.json.backup $HOME/.althea/data/priv_validator_state.json

sudo systemctl start althea && sudo journalctl -fu althea -o cat
```

### State Sync
```
sudo systemctl stop althea
cp $HOME/.althea/data/priv_validator_state.json $HOME/.althea/priv_validator_state.json.backup
althea tendermint unsafe-reset-all --home $HOME/.althea

STATE_SYNC_RPC=https://rpc-test.althea.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.althea/config/config.toml

mv $HOME/.althea/priv_validator_state.json.backup $HOME/.althea/data/priv_validator_state.json

sudo systemctl start althea && sudo journalctl -u althea -f --no-hostname -o cat
```

### Live Peers
```
PEERS="79875677d71e3213d34bd0fb8ede172d376bcff5@144.76.97.251:35656,99323e9d082db6f9ba44e62f54e3b96a8c9d8153@185.239.209.180:34656,3b4f15d5c9860e731380e4df3c895a1b8a6bc297@173.249.59.70:30656,bc47f3e8f9134a812462e793d8767ef7334c0119@65.19.136.133:23296,0625e17766ed71dda6e447f5a079937d7fcd08f3@31.220.84.183:26656,2ed1209b8b0a0da1e753c3900dd57e62b4729f16@65.108.229.120:36656,12ebdeffa1af6d7d1a596e80ccaa56f6858a0ccb@176.9.121.109:41256,5b5e69cea6371e6537ffa00e64f8ef2b1c0e9548@162.19.238.210:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.althea/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Althea/addrbook.json > $HOME/.althea/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Althea/genesis.json > $HOME/.althea/config/genesis.json
```