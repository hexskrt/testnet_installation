<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/bonus.jpg?raw=true">
</p>

# Bonus Blockchain Testnet | Chain ID : blocktopia-01

### Explorer:
>-  https://explorer.hexnodes.co/BONUS-TESTNET

### Automatic Installer
You can setup your Bonus Blockchain fullnode in few minutes by using automated script below.
```
wget -O bonus.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BonusBlock/bonus.sh && chmod +x bonus.sh && ./bonus.sh
```

## Snapshot
```
sudo systemctl stop bonus-blockd
cp $HOME/.bonusblock/data/priv_validator_state.json $HOME/.bonusblock/priv_validator_state.json.backup
rm -rf $HOME/.bonusblock/data

curl -L https://snap.hexnodes.co/bonusblock/bonusblock.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.bonusblock/
mv $HOME/.bonusblock/priv_validator_state.json.backup $HOME/.bonusblock/data/priv_validator_state.json

sudo systemctl start bonus-blockd && sudo journalctl -fu bonus-blockd -o cat
```

### State Sync
```
sudo systemctl stop bonus-blockd
cp $HOME/.bonusblock/data/priv_validator_state.json $HOME/.bonusblock/priv_validator_state.json.backup
bonus-blockd tendermint unsafe-reset-all --home $HOME/.bonusblock

STATE_SYNC_RPC=https://rpc-test.bonusblock.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.bonusblock/config/config.toml

mv $HOME/.bonusblock/priv_validator_state.json.backup $HOME/.bonusblock/data/priv_validator_state.json

sudo systemctl start bonus-blockd && sudo journalctl -u bonus-blockd -f --no-hostname -o cat
```

### Live Peers
```
PEERS="f0dd223dfe4afd1d03c175aa4eaa0cd7ae9daffa@38.242.230.118:58656,21bfbe5831068af98b6669866698599dcf283155@57.128.106.249:26656,e127400d9db770f2d89b468dee896b4a9f193e33@65.108.206.118:61256,f526b6405d841c689182de56df829b95baf70bce@65.108.199.120:47356,95f15068d2cbca97c6962303838311447203d898@146.190.90.155:26656,f5b0881977c1b6a17123ccd78d702d24d42466c5@65.109.70.45:22656,128edee71eecac9c9abcd13fcb5407be9e22451c@109.123.253.226:26656,ecb1e528eaf8bac94a3e65e2366b32e54f7103fd@102.182.132.127:26656,9ebf38c9597b0aef184d0424c487c7cc7bc6ad17@65.108.230.113:16096,27b0297b916781ab02cf5cef9d28166a345a3da8@46.17.250.108:36656,f93dbc56c81b4eaf09d8ee7342a96e86d766c695@154.26.136.69:26656,bb3d6e6884c31a03c7e48e25e303b1fad8fcf346@38.242.148.96:26656,8b11e072886f3b29b73f25e125c40cfb97ff4c30@65.109.108.150:56656,2501d22acb69740cea14a61e0a91db7b7cc618b0@65.21.232.160:32656,ebec235a110a61253d0dc462ccdfce8f6fcf8592@142.93.105.112:26656,49c8d12913dc3be424943181b9ed35ee7d74dd71@170.64.184.251:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.bonusblock/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BonusBlock/addrbook.json > $HOME/.bonusblock/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/BonusBlock/genesis.json > $HOME/.bonusblock/config/genesis.json
```
