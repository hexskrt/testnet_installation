<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/althea.jpg?raw=true">
</p>

# Althea Network Testnet | Chain ID : althea_7357-1

### Explorer:
>-  https://explorer.hexnodes.co/althea-testnet

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
PEERS="a51b45869b5403dc71251a69879c1eb1c3042bed@65.108.134.215:29336,c215cf295b05c1338fdf5070a7b2abde873f5a88@95.217.40.230:26656,79d18c52d35ddd204f61e9be8aa3c7b35d75cab7@65.108.139.20:26656,8cd0cf98fa86c01796b07d230aa5261e06b1b37d@95.217.206.246:26656,7eb055628aee375914d7d265ef4bc01ea692fe95@65.109.82.106:31656,17edf24237b1c2b5b196d344761f964407d05862@65.108.233.109:12456,24ae39234e1ceddc1585af9be8a6484edac79123@49.12.123.97:26656,762cdf9d5e6005aedfbfca83afae5856c35839ef@65.108.203.149:22246,ff3fe47b494b0bf3dedf2d47dc9acf0e2ba3b7ae@65.108.43.113:52656,382264d78149b62e679bf6d0b93dc74dd033fc05@65.108.2.41:26656,a3ac64c5c84817f3694a866298399e6ad71ff26c@65.21.53.39:26656,019988ce47565ad683b7675216e8fbcb171b841c@107.155.125.170:26656,65bdea10d472c592640167e59eb1ba41ce590c5b@65.108.238.147:36656,f1d120c40d9104f7560a49a58d120a0fc637c829@49.12.123.87:26656,eab7a70812ba39094fc8bbf4f69f099123863b38@81.30.157.35:11656,6c3d7683bf40a521b7c22391fd6c989b46a2e0e2@78.46.106.75:27656,ee22e048af133e8e83d594314a67b89be964eb37@138.201.225.104:47856,c1ad743c152d67dea9df71e3de2024cddd57c0cb@31.220.84.183:26656,cd71580f8ab4af6beeaf867702a86ca6f9331f71@65.19.136.133:23296,87b67a8758306c61f8bb7504a0881cc837373633@140.82.38.208:26656,96320aaab7794933fddbc2bb101e54b8697c58e7@141.95.65.26:26656,ba247bdf826a9636a8276d6a00d8004755f6bb18@162.19.238.210:26656,11e8f38e3c5601e4ab2333d5a5bbb108a39b8e1c@159.69.110.238:26656,1991a3263255fc32d65b49335bcaee19f607c934@185.16.39.99:26656,bdf94092f6dc380f6526f7b8b46b63192e95a033@173.212.222.167:29656,e5990247cc7fde4f94b44f687e0a9bda84fffe55@141.94.193.28:55766,937dcf8c45b7c64e5188a7036427f2ce86383035@95.165.89.222:24126,6d97969912514e3583dee8e0cca15a383adbde6c@213.246.57.175:26656"
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