<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/explorer/blob/7d35cffe8566d44a61bac5f541cc4b94940b5ae0/public/logos/dymension.png">
</p>

# Dymension Testnet | Chain ID : froopyland_100-1

### Official Documentation:
>- [Validator Setup Instructions](https://docs.dymension.xyz/validate/dymension-hub/build-dymd)

### Explorer:
>-  https://explorer.hexnodes.co/dymension-testnet

### Automatic Installer
You can setup your Dymension fullnode in few minutes by using automated script below.
```
wget -O dymension.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Dymension/dymension.sh && chmod +x dymension.sh && ./dymension.sh
```

## Snapshot
```
sudo systemctl stop dymd
cp $HOME/.dymension/data/priv_validator_state.json $HOME/.dymension/priv_validator_state.json.backup
rm -rf $HOME/.dymension/data

curl -L https://snap.hexnodes.co/dymension/dymension.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.dymension/
mv $HOME/.dymension/priv_validator_state.json.backup $HOME/.dymension/data/priv_validator_state.json

sudo systemctl start dymd && sudo journalctl -fu dymd -o cat
```

### State Sync
```
sudo systemctl stop dymd
cp $HOME/.dymension/data/priv_validator_state.json $HOME/.dymension/priv_validator_state.json.backup
dymd tendermint unsafe-reset-all --home $HOME/.dymension

STATE_SYNC_RPC=https://rpc-test.dymension.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.dymension/config/config.toml

mv $HOME/.dymension/priv_validator_state.json.backup $HOME/.dymension/data/priv_validator_state.json

sudo systemctl start dymd && sudo journalctl -u dymd -f --no-hostname -o cat
```

### Live Peers
```
PEERS="d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:14656,83433e3a264a81b7e6c9ead46d259d0d861b3afa@135.181.165.80:26656,1e92b79a713b18dffd4e075ddfa1dab87dd215a9@70.34.197.147:26656,3410e9bc9c429d6f35e868840f6b7a0ccb29020b@46.4.5.45:20556,cb120ed9625771d57e06f8d449cb10ab99a58225@57.128.114.155:26656,4b6475a413379d086abf3cd27e06fd5fa4a51651@38.146.3.200:20556,3943ac701aed59f13ac2d65b80eaa6951b17bfcb@65.108.132.239:26656,e7857b8ed09bd0101af72e30425555efa8f4a242@148.251.177.108:20556,e28bf506aaba23c890e9d6cd5cf64b8e627b7e12@80.240.29.76:26656,f85a4dd43cc31b2ef7363667fcfcf2c5cd25ef04@88.99.164.158:17086"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.dymension/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Dymension/addrbook.json > $HOME/.dymension/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Dymension/genesis.json > $HOME/.dymension/config/genesis.json
```