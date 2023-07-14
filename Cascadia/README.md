<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/cascadia.jpg?raw=true">
</p>

# Cascadia Testnet | Chain ID : cascadia_6102-1
### Official Documentation:
>- [Validator Setup Instructions](https://cascadia.gitbook.io/gitbook/validators)

### Explorer:
>-  https://explorer.hexnodes.co/cascadia-testnet

### Automatic Installer
You can setup your Cascadia fullnode in few minutes by using automated script below.
```
wget -O cascadia.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Cascadia/cascadia.sh && chmod +x cascadia.sh && ./cascadia.sh
```

### Snapshot
```
sudo systemctl stop cascadiad
cp $HOME/.cascadiad/data/priv_validator_state.json $HOME/.cascadiad/priv_validator_state.json.backup
rm -rf $HOME/.cascadiad/data

curl -L https://snap.hexnodes.co/cascadia/cascadia.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.cascadiad/
mv $HOME/.cascadiad/priv_validator_state.json.backup $HOME/.cascadiad/data/priv_validator_state.json

sudo systemctl start cascadiad && sudo journalctl -fu cascadiad -o cat
```

### State Sync
```
sudo systemctl stop cascadiad
cp $HOME/.cascadiad/data/priv_validator_state.json $HOME/.cascadiad/priv_validator_state.json.backup
cascadiad tendermint unsafe-reset-all --home $HOME/.cascadiad

STATE_SYNC_RPC=https://rpc-test.cascadia.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.cascadiad/config/config.toml

mv $HOME/.cascadiad/priv_validator_state.json.backup $HOME/.cascadiad/data/priv_validator_state.json

sudo systemctl start cascadiad && sudo journalctl -u cascadiad -f --no-hostname -o cat
```

### Live Peers
```
PEERS="b77f7c4b9ca2c52745e28d8aa6d225383299e48e@37.27.1.244:26656,de11c79dab6ea248fb72f9d93c2ff0eace14a5ac@94.250.201.130:26656,9b8709383584dd4b59ad7e732d4ae70890e7d27b@65.108.244.137:18656,3314288924c02fd0c983ef99cf2d1d607b620b80@46.4.90.188:26656,354a840362324f8b87d01c1b30cc09da4724c2f9@75.119.158.213:26656,696a08d3d8099e43f07a15c79a4c57e47b23842c@158.220.106.219:26656,f55eaf24fe87dfe4c5feb64ba2e2f5b730901927@185.255.131.190:26656,f88ec43f46bf2e20e9ef8560c9e3e484d78fa6b5@194.163.187.112:26656,c2ef0140958982dae978e8830003158bade2a1c6@185.249.225.63:26656,f4242842d8ab0ba390d16b583ae97d962484e223@38.242.220.255:26656,11f2e6b2ce7845d738262d160be5a1249b0e1ae9@31.220.77.238:26656,a98484ac9cb8235bd6a65cdf7648107e3d14dab4@116.202.231.58:15556,98712592c3ab584011237c7a780a7a07a6be106f@149.102.128.245:26656,d527aed8bb6361293748ff4fcf442d9823b80b59@207.180.229.183:26656,298ab716b52eddc843609a684c6637c2f66edb54@65.109.93.58:38656,dd225f803eb3ae4bba2eef4628bebd6fc52092c2@65.108.97.111:36656,2e12218b2f0f46ec81f09637d08c98ffba22a792@173.212.211.137:26656,040d0b6ffefba3283b5763e26c352c7b1b232c1f@65.109.90.171:34656,a17329edf8fbfec12c9b87d1f11102252d881cbf@167.114.119.77:55656,717deddb07d6a6990d876bf3d9bf974ca30223a2@173.249.53.21:656,dd7e5c9a876c715a08a2c8b9cc9a7b0a1c1bae75@94.249.192.73:26656,29d2152e682620918152152a393b8c7d2ca86a0d@167.114.119.78:55656,cb982373f6d5c40efe85a8364d9d9d7a5a2e6adc@116.202.85.52:18656,79bc3b609c1103e3a621c30ce78047b6c0039946@80.254.8.54:55656,2293093dc070cfa0b0a6650eaaaab55b4e92c2e2@194.163.168.62:15556,c1466fa6f873826054585f903652ac2e9bd1f9d3@65.109.154.182:43656,de5eb38c7192856306d708e9cbf7814ca075dbd8@38.242.227.84:15556,2baf385057bf62c8a0b0404627ac673f44821040@75.119.154.2:55656,d09997af02acdbc0c9bdeda6e43e9db498506f77@86.48.30.243:18656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.cascadiad/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Cascadia/addrbook.json > $HOME/.cascadiad/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Cascadia/genesis.json > $HOME/.cascadiad/config/genesis.json
```