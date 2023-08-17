<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/entangle.jpg?raw=true">
</p>

# Entangle Protocol | Chain ID : entangle_33133-1

### Explorer:
>-  https://explorer.hexnodes.co/entangle-testmet

### Automatic Installer
You can setup your Entangle Protocol fullnode in few minutes by using automated script below.
```
wget -O entangle.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Entangle/entangle.sh && chmod +x entangle.sh && ./entangle.sh
```

### Snapshot
```
sudo systemctl stop entangled
cp $HOME/.entangled/data/priv_validator_state.json $HOME/.entangled/priv_validator_state.json.backup
rm -rf $HOME/.entangled/data

curl -L https://snap.hexnodes.co/entangle/entangle.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.entangled/
mv $HOME/.entangled/priv_validator_state.json.backup $HOME/.entangled/data/priv_validator_state.json

sudo systemctl start entangled && sudo journalctl -fu entangled -o cat
```

### State Sync
```
sudo systemctl stop entangled
cp $HOME/.entangled/data/priv_validator_state.json $HOME/.entangled/priv_validator_state.json.backup
entangled tendermint unsafe-reset-all --home $HOME/.entangled

STATE_SYNC_RPC=https://rpc-test.entangle.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.entangled/config/config.toml

mv $HOME/.entangled/priv_validator_state.json.backup $HOME/.entangled/data/priv_validator_state.json

sudo systemctl start entangled && sudo journalctl -u entangled -f --no-hostname -o cat
```

### Live Peers
```
PEERS="78937bb32c08e4a80d112730e8c66aeb0b6fcd4f@88.198.47.154:36656,627bd0f5b91367c00bb4125e278108c60534ba4a@94.130.220.233:20656,7afbc1c83b9a116223a4417bfc429ea1073be5ca@65.109.154.181:16656,f97c0b5b018288295f158ddb43acaaf8871102d4@136.243.105.186:11656,263b106f9755656ac18594cb951754187f3d51ba@65.109.85.170:42626,dc4114a506b48ab062b0782a410d5618a22fafb7@18.207.195.188:26656,1fef0cad71ccb4a002dfbdd977af319fba0c3978@207.244.253.244:29656,f82e96fff1c29e0c2affde5e59de95a0c8d5a842@65.108.46.100:44656,f8119b27e7744d36ad1e59736b2488683be0aa3b@3.87.189.254:26656,342c1851d3ad8cc72e41c965594a0a01f190d13c@65.108.229.93:25656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.entangled/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Entangle/addrbook.json > $HOME/.entangled/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Entangle/genesis.json > $HOME/.entangled/config/genesis.json
```