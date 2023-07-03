<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/noria.jpg">
</p>

# Noria Testnet | Chain ID : oasis-3

### Explorer:
>-  https://explorer.hexnodes.co/NORIA-TESTNET

### Automatic Installer
You can setup your Noria Network fullnode in few minutes by using automated script below.
```
wget -O noria.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Noria/noria.sh && chmod +x noria.sh && ./noria.sh
```

### Snapshot
```
sudo systemctl stop noriad
cp $HOME/.noria/data/priv_validator_state.json $HOME/.noria/priv_validator_state.json.backup
rm -rf $HOME/.noria/data

curl -L https://snap.hexnodes.co/noria/noria.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.noria/
mv $HOME/.noria/priv_validator_state.json.backup $HOME/.noria/data/priv_validator_state.json

sudo systemctl start noriad && sudo journalctl -fu noriad -o cat
```

### State Sync
```
sudo systemctl stop noriad
cp $HOME/.noria/data/priv_validator_state.json $HOME/.noria/priv_validator_state.json.backup
noriad tendermint unsafe-reset-all --home $HOME/.noria

STATE_SYNC_RPC=https://rpc-test.noria.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.noria/config/config.toml

mv $HOME/.noria/priv_validator_state.json.backup $HOME/.noria/data/priv_validator_state.json

sudo systemctl start noriad && sudo journalctl -u noriad -f --no-hostname -o cat
```

### Live Peers
```
PEERS="b2b8e67a3158e0854570c7de61812c8c6e92e4bc@65.108.206.118:61656,200828e2327e57bc3729b9aac4cfe9bc7a139b30@65.109.95.104:27656,9e16c875dfce96fb492cf16c3221836eeaf71afc@65.21.82.203:56656,725c9918c40ab15d4309f0dc38c0040d809babdf@65.108.233.102:33656,5eedd8cf7fefc037a6233b1991c2a3b653518560@65.108.230.113:31066,f60568a6ed1f848857c1c6c113719c1bb687c656@65.108.105.48:22156,ad749d0e0c6542b89b5f98dfafe05cb527d0b9fc@65.109.6.138:26656,73e5dc6e04a1dd28e5851191eb9dede07f0b38fb@141.94.99.87:14095,6b00a46b8c79deab378a8c1d5c2a63123b799e46@34.69.0.43:26656,a3a2a86740534e67c55774bf2b37299a8e268031@107.181.236.98:26656,c70b89aaf944730a1607f4f2a712970c2de0b3a0@154.26.135.35:16156,0fbeb25dfdae849be87d96a32050741a77983b13@34.87.180.66:26656,4d8147a80c46ba21a8a276d55e6993353e03a734@165.22.42.220:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@185.16.39.172:27316,c660bf910c013c1b603371cf4eb8ebee640000dd@37.252.184.249:26656,dcc47d4c13523d5c701198d30b38bb4d589c1083@65.108.211.139:26656,a98484ac9cb8235bd6a65cdf7648107e3d14dab4@116.202.231.58:16156,c818c3aa14ae8183578b7be0572c2dcd75613e72@186.233.185.214:26656,bb04cbb3b917efce76a8296a8411f211bad14352@159.203.5.100:26656,8336e98410c1c9b91ef86f13a3254a2b30a1a263@65.108.226.183:22156,06bea1e5ad267b8d88db3cd4ac617f48ddd9b166@65.108.199.206:33656,efe1e1f891f785e6541ad18ff228ea61894dd980@65.21.225.10:51656,c91e98a2afb3cba1771f87719dc4a757d6e01ba6@188.132.129.232:26656,dfcd861d57bf2fba4f308ffeae58803e3cd3c0f1@65.109.92.148:26656,afe93314d3d1f3b0bdc20f213983bd902263e171@18.188.137.12:26656,31df60c419e4e5ab122ca17d95419a654729cbb7@102.130.121.211:26656,8dfca3c8a308fb6e682814ba5c33623dd346e572@65.109.23.114:22156,b55e2db9b3b63fde77462c4f5ce589252c5f45af@51.91.30.173:2009,60a15b1b7feb62b65d58cb4721340907c2092099@65.108.6.45:61656,0b6b896c1daf912857c16fa8d88d998dd0ef92d8@65.109.82.112:2966,c3ee892de5052c2813a7e4968a3ba5c4518455cb@37.179.170.94:26656,b3a4f9e9797a0ed73f3abc1eb02070212294b249@65.108.124.121:60756,42798554b12ff3c24107af3b47a28459d717bdf4@46.17.250.108:61356"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.noria/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Noria/addrbook.json > $HOME/.noria/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Noria/genesis.json > $HOME/.noria/config/genesis.json
```