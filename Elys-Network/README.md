<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/elys.jpg?raw=true">
</p>

# Elys Testnet | Chain ID : elystestnet-1

### Explorer:
>-  https://explorer.hexnodes.co/elys-testnet

### Automatic Installer
You can setup your Elys Network fullnode in few minutes by using automated script below.
```
wget -O elys.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Elys-Network/elys.sh && chmod +x elys.sh && ./elys.sh
```

### Snapshot
```
sudo systemctl stop elysd
cp $HOME/.elys/data/priv_validator_state.json $HOME/.elys/priv_validator_state.json.backup
rm -rf $HOME/.elys/data

curl -L https://snap.hexnodes.co/elys/elys.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.elys/
mv $HOME/.elys/priv_validator_state.json.backup $HOME/.elys/data/priv_validator_state.json

sudo systemctl start elysd && sudo journalctl -fu elysd -o cat
```

### State Sync
```
sudo systemctl stop elysd
cp $HOME/.elys/data/priv_validator_state.json $HOME/.elys/priv_validator_state.json.backup
elysd tendermint unsafe-reset-all --home $HOME/.elys

STATE_SYNC_RPC=https://rpc-test.elys.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.elys/config/config.toml

mv $HOME/.elys/priv_validator_state.json.backup $HOME/.elys/data/priv_validator_state.json

sudo systemctl start elysd && sudo journalctl -u elysd -f --no-hostname -o cat
```

### Live Peers
```
PEERS="919929b0162de3c3a5a4b97d7971e043679912ea@65.108.72.253:38656,a346d8325a9c3cd40e32236eb6de031d1a2d895e@95.217.107.96:26156,f3480371baafae419bfef68a64ace00dd8944bd6@65.109.92.241:10126,904df9ac27e2ed11eb72e31d0ad8dcc3caddae8c@65.109.82.112:2236,5c2a752c9b1952dbed075c56c600c3a79b58c395@178.211.139.77:27296,d3235fc7392c1f789ce8d3176b44a378a110b99c@195.3.223.26:26656,701a382e03978c54f1176145460125516b6a4672@3.144.113.232:26656,a42cc9d7134949ce2fa703c6e341a0bd9cc1984c@65.108.206.74:16656,a98484ac9cb8235bd6a65cdf7648107e3d14dab4@116.202.231.58:15356,ef5792644c527d083665d00d4e3cb98b316a060b@51.159.210.149:26656,9e456e22da0930be2761123b7036e386a3247647@57.128.110.141:26656,c818535eb8b383614277baf4fa661c61dbf2130d@167.114.172.204:15356,78aa6b222ae1f619bef03a9d98cb958dfcccc3a8@46.4.5.45:22056,98143b5dca162ba726536d07a6af6500d3e6fe1e@65.108.200.40:38656,fed5ba77a69a4e75f44588f794999e9ca0c6b440@45.67.217.22:21956,cdf9ae8529aa00e6e6703b28f3dcfdd37e07b27c@37.187.154.66:26656,89304292aceb62aa0f2b9970a921740f114e6d60@65.109.93.35:57656,565af6e0caaedd94fe5611e5d1a6683562b5d970@89.58.16.33:38656,d907ce9285951a2a063789df2f6bd4cc86b33d53@142.132.155.178:16656,b7b044df4dc2e709972b79c04d9eb7d921e3b45f@116.202.227.117:53656,e27c08c6159ebe0fb6293336ee51e68c35fe2102@31.220.84.183:60756,b904eb8b81f58608a2c4a086860fbd52d00ccba6@65.108.226.25:36656,01aaf7bce61622ab4f2f6cedbc57fa3aa5d3cf3c@167.235.1.101:26676,0977dd5475e303c99b66eaacab53c8cc28e49b05@65.109.92.79:38656,ae22b82b1dc34fa0b1a64854168692310f562136@198.27.74.140:26656,f6480d5563172e7de0b97b666c4d503d7c4daae8@94.130.225.23:26656,8c971e7fed202339dc557c2170a5be125153436a@65.109.65.248:38656,8723618f5dff7ac9b57472f90f2e86a2eb194e0a@71.236.119.108:25656,3f30f68cb08e4dae5dd76c5ce77e6e1a15084346@167.235.21.165:56656,917f122f053424b6916959e2907130bf7d302709@168.119.226.107:22356,d8be8de0b6d67292f7b974ab9e2db84be1a9dc59@208.64.58.50:26656,967b66caf9024a876d11f7a7eef9e67a53e10e3c@165.73.113.212:26656,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@176.9.82.221:22056"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.elys/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Elys-Network/addrbook.json > $HOME/.elys/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Elys-Network/genesis.json > $HOME/.elys/config/genesis.json
```