<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/explorer/blob/7d35cffe8566d44a61bac5f541cc4b94940b5ae0/public/logos/dymension.png">
</p>

# Dymension Testnet | Chain ID : 35-C

### Official Documentation:
>- [Validator Setup Instructions](https://docs.dymension.xyz/validate/dymension-hub/build-dymd)

### Explorer:
>-  https://explorer.hexnodes.co/DYMENSION-TESTNET

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
PEERS="3df2154255d44bee7f036531e7575bdff152207f@51.178.65.184:27656,57a66a59cc291887f35e231b4469e2c957728862@46.4.5.45:20556,db0264c412618949ce3a63cb07328d027e433372@146.19.24.101:26646,80cce834fc749c0a9f47182665f833f97170ff4b@65.108.104.167:46656,61ddab0e1af7b8576880a6ebfd96e8a09629babc@65.21.216.73:11256,22bb74602c802bfbd4944bcadd4d5e300f2033f9@38.242.238.146:51656,290ec1fc5cc5667d4e072cf336758d744d291ef1@65.109.104.118:26656,addfc6d77659df2a91523128e40833a7cdcc603c@65.108.233.102:31656,63996f52b1dc68259ff64bb2546625c71fc9d546@176.9.48.38:26656,0d30a0790a216d01c9759ab48192d9154381e6c0@136.243.88.91:3240,77791ee9b1eb56682335c451c296f450ee649c01@44.209.89.17:26656,618ef1f11412046f6ae1230704f8d3bd9a3fee68@3.88.104.53:26656,f8175ce7bc19d015ec17083fe19b80eae2bd2a9c@65.21.239.60:46656,140d07c40c964eb063d4526561ca92e8ed796b9b@65.109.82.249:29656,998b19ed2c580acaa2fdb5057e2930a38f041750@65.109.122.105:60556,206049f230d60211e6fd746bdd430a81e53fdf3f@161.97.133.54:26656,f4be55edab4b5cb40464aa50def5d2cd39359e67@185.182.185.101:26656,513557be25d2edc51481be90c808f72cd662e1d2@167.235.250.107:26656,b37f08836471fd72e20853887b73f657d68cf96d@148.251.177.108:20556,5a0cee849e4a909b42c8b9b2df4a1e737ff2b715@194.233.90.134:26656,a98484ac9cb8235bd6a65cdf7648107e3d14dab4@116.202.231.58:14656"
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