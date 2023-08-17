<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/arkeo.jpg?raw=true">
</p>

# Arkeo Network Testnet | Chain ID : arkeo

### Explorer:
>-  https://explorer.hexnodes.co/arkeo-testnet

### Automatic Installer
You can setup your Arkeo Network fullnode in few minutes by using automated script below.
```
wget -O arkeo.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Arkeo/arkeo.sh && chmod +x arkeo.sh && ./arkeo.sh
```

### Snapshot
```
sudo systemctl stop arkeod
cp $HOME/.arkeo/data/priv_validator_state.json $HOME/.arkeo/priv_validator_state.json.backup
rm -rf $HOME/.arkeo/data

curl -L https://snap.hexnodes.co/arkeo/arkeo.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.arkeo/
mv $HOME/.arkeo/priv_validator_state.json.backup $HOME/.arkeo/data/priv_validator_state.json

sudo systemctl start arkeo && sudo journalctl -fu arkeo -o cat
```

### State Sync
```
sudo systemctl stop arkeod
cp $HOME/.arkeo/data/priv_validator_state.json $HOME/.arkeo/priv_validator_state.json.backup
arkeod tendermint unsafe-reset-all --home $HOME/.arkeo

STATE_SYNC_RPC=https://rpc-test.arkeo.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.arkeo/config/config.toml

mv $HOME/.arkeo/priv_validator_state.json.backup $HOME/.arkeo/data/priv_validator_state.json

sudo systemctl start arkeod && sudo journalctl -u arkeod -f --no-hostname -o cat
```

### Live Peers
```
PEERS="b7ab002fd8d92182b1bdc24e0ea11c7936a5731f@176.9.110.12:60656,d228db1ef905886f0c0511a5830eda4e94611038@65.108.206.74:29656,f51558158dfd6b86e9a08e7f187665bc8d95b0c7@65.109.82.112:14256,3f9bc5552f02dce211db24d5e42c118c61c4abde@65.108.8.28:60656,8e7c1c3d2416acf5fc9c9b6b74a8d9f53db1f567@94.130.220.233:26646,5a9d5e29069da8e7fc40c45ae6a0460363bdec0d@65.109.95.104:14356,be6bdd4a121962aa99da65e61763dc4a4a3f0bc0@95.217.83.224:16656,2adb01b36ed01c6d613a6af6ff88e13f64d3f173@88.198.18.88:58656,9aac4f5660f62bb0c1c1a1b43c1ea211df7ff9df@193.26.159.34:12656,cb717d9709b967a9cdf9c3b6cdcbdcc3e0b44086@5.189.137.206:26656,e033753cac027fc6605a95dab3b3fc5550d4b9bf@65.109.84.33:40656,54ba4c385f7c8c9f20c4f26388a50157039e68db@95.216.7.136:24656,719df9d2a4c9b4343b801f3a7d5d4845ace47451@65.108.200.40:42656,1eaeb5b9cb2cc1ae5a14d5b87d65fef89998b467@65.108.141.109:17656,e6b058d1d6be000d67b87e9d11cb0de1bba1e477@65.109.65.248:42656,8e8686ab21fd31bb082458fffc3e885587511435@161.97.121.198:26656,25a9af68f987e254e50d6d7e6a1e68a5a40c1b7c@65.109.92.148:60556,51fd59e037b43fe0e562de5985999845fd5f877e@65.21.200.54:40656,c34a4f5a59e81dd1974873641ceb9889a7e8d71a@161.35.113.45:24656,3ac29399fd34c262a4012320c9808a677d81481b@95.214.55.138:2656,c9b8962c35cd81a56ed9a96794a667e152d3d5c9@65.109.23.114:22856,226d6291ec9c26a8d1214a46c946cd4b5abd6572@147.182.244.252:12656,a6f2c440a81ffaeac80c9b50fd63edd0b23a5146@38.45.67.174:26656,65c95f70cf0ca8948f6ff59e83b22df3f8484edf@65.108.226.183:22856,6735c18102370ecfabd89e0b34e6cfdd96ee3285@94.190.90.38:47656,2d373b02e7c1d0e3c251bc4ae2b1b7708f252fc8@65.109.93.58:40656,3129d08bf0c3a9d32ef2b04a13b5f7b98f0371e3@65.108.13.154:42656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.arkeo/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BlockX/addrbook.json > $HOME/.arkeo/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BlockX/genesis.json > $HOME/.arkeo/config/genesis.json
```