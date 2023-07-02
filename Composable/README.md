<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/composable.jpg?raw=true">
</p>

# Composable Testnet | Chain ID : banksy-testnet-2 & banksy-testnet-3

### Explorer:
>-  https://explorer.hexnodes.co/COMPOSABLE-2 (banksy-testnet-2)
>-  https://explorer.hexnodes.co/COMPOSABLE-3 (banksy-testnet-3)

### Automatic Installer
You can setup your Composable fullnode in few minutes by using automated script below.

## banksy-testnet-2
```
wget -O comp2.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Composable/comp2.sh && chmod +x comp2.sh && ./comp2.sh
```

## Snapshot
```
sudo systemctl stop banksyd
cp $HOME/.banksy/data/priv_validator_state.json $HOME/.banksy/priv_validator_state.json.backup
rm -rf $HOME/.banksy/data

curl -L https://snap.hexnodes.co/composable-2/composable.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.banksy/
mv $HOME/.banksy/priv_validator_state.json.backup $HOME/.banksy/data/priv_validator_state.json

sudo systemctl start banksyd && sudo journalctl -fu banksyd -o cat
```

### State Sync
```
sudo systemctl stop banksyd
cp $HOME/.banksy/data/priv_validator_state.json $HOME/.banksy/priv_validator_state.json.backup
banksyd tendermint unsafe-reset-all --home $HOME/.banksy

STATE_SYNC_RPC=https://rpc-test.banksy2.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.banksy/config/config.toml

mv $HOME/.banksy/priv_validator_state.json.backup $HOME/.banksy/data/priv_validator_state.json

sudo systemctl start banksyd && sudo journalctl -u banksyd -f --no-hostname -o cat
```

### Live Peers
```
PEERS="81d301d1c191facb4e658ac8765f96f1c8b072f6@137.184.119.85:26656,3048acfb1de9230e1f6c417c32f4bf2dca1420af@144.91.84.21:26666,0b9d9c0d6f1ff6d63f6e164895351e184c046ca2@134.209.38.116:26656,8b25a4db346430963f94b383898c5b09b5c6ba91@65.21.200.54:30656,f9cf7b4b1df105e67c632364847a4a00f86aa5c8@93.115.28.169:36656,18f86a7b2b8233e340b85733b77c649daa2533dc@138.201.59.93:26656,d9b5a5910c1cf6b52f79aae4cf97dd83086dfc25@65.108.229.93:27656,561b5acc7d6ae8994442855aac6b9a2ea94970d1@5.161.97.184:26656,a8da45683cc35c4743e27eac5e2d33498b7a700d@65.108.225.126:26656,7fc16efbb3e56d81245a0828198d580b3f246f58@51.91.30.173:3000,7521d65a4102259fa26816383fea2f8f21a3b1ea@65.109.116.21:11154,5c2a752c9b1952dbed075c56c600c3a79b58c395@185.16.39.172:26976,28880b0f91c244f9c3ab0380fc585934d1aebc37@38.242.205.80:15956,553afa41ab1fed3bf2d604c6d432861f7bd620b4@65.21.232.33:2000,ba3157b6a0015737cf10949a1398cdd2e7383694@45.33.25.190:26656,fe82bb3e15e4cee715f47a9ccb925134b9131669@46.4.213.193:26656,20f2608c9bc262df91d96027e1d5054ddee9c86c@142.132.209.236:22256,068fbf2425c5f024986444f1388fc1cabff3d733@46.4.5.45:22256,0c156c138d744ab18e92f303c5b1e1337e62b970@176.9.2.2:40656,a667fe45e2dab62237999b32b444195bc2a4e4b5@65.109.93.58:30656,a482022fa54abaf84474e49858f505682dacf2da@207.180.234.69:26656,3e4ee01fd4c412a1d061467cd8f807cfbd80aaac@148.251.177.108:22256,8abec431c7e7067286403122e4fc715aa6016d5e@194.163.166.56:25656,6070848e92aa3c9dd741acc2f9d962c193447aa9@62.171.158.156:26656,0d533334454f9b95b01cb53c2704c7d48f19806c@71.236.119.108:41656,182d2e7cb0443863386703eb1bd7a72833665c4e@65.108.52.52:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.banksy/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Composable/composable-2/addrbook.json > $HOME/.banksy/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Composable/composable-2/genesis.json > $HOME/.banksy/config/genesis.json
```

## banksy-testnet-3
```
wget -O comp3.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Composable/composable-3/comp3.sh && chmod +x comp3.sh && ./comp3.sh
```

## Snapshot
```
sudo systemctl stop centaurid
cp $HOME/.banksy/data/priv_validator_state.json $HOME/.banksy/priv_validator_state.json.backup
rm -rf $HOME/.banksy/data

curl -L https://snap.hexnodes.co/composable-3/composable.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.banksy/
mv $HOME/.banksy/priv_validator_state.json.backup $HOME/.banksy/data/priv_validator_state.json

sudo systemctl start centaurid && sudo journalctl -fu centaurid -o cat
```

### State Sync
```
sudo systemctl stop centaurid
cp $HOME/.banksy/data/priv_validator_state.json $HOME/.banksy/priv_validator_state.json.backup
centaurid tendermint unsafe-reset-all --home $HOME/.banksy

STATE_SYNC_RPC=https://rpc-test.banksy3.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.banksy/config/config.toml

mv $HOME/.banksy/priv_validator_state.json.backup $HOME/.banksy/data/priv_validator_state.json

sudo systemctl start centaurid && sudo journalctl -u centaurid -f --no-hostname -o cat
```

### Live Peers
```
PEERS="93418eb0d95d34dfda8818e7abf4cd4679f51e39@91.144.171.205:26656,b2a5b6c11e7d71c2a43d88a73b9dcff3352f4302@57.128.86.7:26656,488f98949ba03931c433aaf12d799bb1cd6f3942@65.21.225.10:47656,e6a21ccb5175df638723eec2bc4f6ed95717acd3@135.181.216.54:3050,df49f4fee2fe62bc0ca8c27ee0dbae3f0abec98f@46.38.232.86:24656,3f0727b11da4dc792fe2dfb34214cf45fadd4a15@95.216.67.178:26656,0a68e21ab47c15f634a97019c2a0b8d3bea09622@185.190.142.177:26656,48fcc78c5f960d1e2ab1deb85a5f4e0198a976fd@144.76.174.27:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@195.3.220.21:26976,76bde904c1f177a2c8c1123150073be38c27ad5f@75.119.146.244:26656,a98484ac9cb8235bd6a65cdf7648107e3d14dab4@116.202.231.58:15956,c241d021004ad9b0fe7fa2d967ff9f1f3b20c1f0@136.243.172.166:15956,211bebc24e286a973d3038f2fbbf5f673badc190@51.250.4.215:27656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:15956,a3ddd1ffc5d24bd12fc4b2af5d2769776f5ce67d@65.109.92.240:21206,c866bd14649bb402dcb08c861add820b152e39e3@173.212.233.177:15956,3351847a55dd16faf533f3a02caba9610cc87320@158.220.100.228:27656,ab771b5501a129c0d26cdef4bd3db1638702a24b@65.109.99.156:26656,3461731f09871909987fa3df99c9ac623ea303b3@207.180.241.219:26656,783e682b38c0565082fe5d897b24feebf687c52b@65.108.13.154:37656,f306956520010c5ddd0e67c69f61f1de3fa91552@88.198.52.46:22256"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.banksy/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Composable/composable-3/addrbook.json > $HOME/.banksy/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Composable/composable-3/genesis.json > $HOME/.banksy/config/genesis.json
```