<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/crossfi.jpg?raw=true">
</p>

# Crossfi Testnet | Chain ID : crossfi-evm-testnet-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/CROSSFI

### Automatic Installer
You can setup your Crossfi fullnode in few minutes by using automated script below.
```
wget -O crossfi.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Crossfi/crossfi.sh && chmod +x crossfi.sh && ./crossfi.sh
```

### Snapshot
```
sudo systemctl stop crossfid
cp $HOME/.mineplex-chain/data/priv_validator_state.json $HOME/.mineplex-chain/priv_validator_state.json.backup
rm -rf $HOME/.mineplex-chain/data

curl -L https://snap.hexnodes.co/crossfi/crossfi.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.mineplex-chain/
mv $HOME/.mineplex-chain/priv_validator_state.json.backup $HOME/.mineplex-chain/data/priv_validator_state.json

sudo systemctl start crossfid && sudo journalctl -fu crossfid -o cat
```

### State Sync
```
sudo systemctl stop crossfid
cp $HOME/.mineplex-chain/data/priv_validator_state.json $HOME/.mineplex-chain/priv_validator_state.json.backup
crossfid tendermint unsafe-reset-all --home $HOME/.mineplex-chain

STATE_SYNC_RPC=https://rpc.crossfi-test.hexnodes.one:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.mineplex-chain/config/config.toml

mv $HOME/.mineplex-chain/priv_validator_state.json.backup $HOME/.mineplex-chain/data/priv_validator_state.json

sudo systemctl start crossfid && sudo journalctl -u crossfid -f --no-hostname -o cat
```

### Live Peers
```
PEERS="66bdf53ec0c2ceeefd9a4c29d7f7926e136f114a@crossfi-testnet-peer.itrocket.net:36656,b88d969ba0e158da1b4066f5c17af9da68c52c7a@65.109.53.24:44656,5ebd3b1590d7383c0bb6696ad364934d7f1c984e@160.202.128.199:56156,dda09f9625cab3fb655c22ef85d756fc77132b9d@167.235.102.45:10956,01e0df1e6932c371640cf44e80c8f0fd28675a6b@65.109.93.58:26056,c8914e513463791d91cc9ab35035c0c1111f307f@84.247.183.225:36656,b0b01c08d7d4c6c2740cc5fe6ea74eb7fdde64f2@38.242.151.229:26656,94eac2bd4f373b31ee9897fd5a2ab4a05080390b@65.108.127.160:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.mineplex-chain/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Crossfi/addrbook.json > $HOME/.mineplex-chain/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Crossfi/genesis.json > $HOME/.mineplex-chain/config/genesis.json
```