<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/selfchain.jpg">
</p>

# Selfchain Devnet | Chain ID : self-dev-1

### Explorer:
>-  https://explorer.hexnodes.co/selfchain-devnet

### Automatic Installer
You can setup your Selfchain fullnode in few minutes by using automated script below.
```
wget -O selfchain.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Selfchain/selfchain.sh && chmod +x selfchain.sh && ./selfchain.sh
```

### Snapshot
```
sudo systemctl stop selfchaind
cp $HOME/.selfchain/data/priv_validator_state.json $HOME/.selfchain/priv_validator_state.json.backup
rm -rf $HOME/.selfchain/data

curl -L https://snap.hexnodes.co/selfchain/selfchain.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.selfchain/
mv $HOME/.selfchain/priv_validator_state.json.backup $HOME/.selfchain/data/priv_validator_state.json

sudo systemctl start selfchaind && sudo journalctl -fu selfchaind -o cat
```

### State Sync
```
sudo systemctl stop selfchaind
cp $HOME/.selfchain/data/priv_validator_state.json $HOME/.selfchain/priv_validator_state.json.backup
selfchaind tendermint unsafe-reset-all --home $HOME/.selfchain

STATE_SYNC_RPC=https://rpc-test.selfchain.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.selfchain/config/config.toml

mv $HOME/.selfchain/priv_validator_state.json.backup $HOME/.selfchain/data/priv_validator_state.json

sudo systemctl start selfchaind && sudo journalctl -u selfchaind -f --no-hostname -o cat
```

### Live Peers
```
PEERS="94a7baabb2bcc00c7b47cbaa58adf4f433df9599@157.230.119.165:26656,e50e9d1ad731164a54a403bd6bafda11ba13b749@170.64.141.15:26656,ca4b6131d616d4d5930e50f1f557950f17fe4091@188.166.218.244:26656,2425d2ba5f493a10d4decd0fb42ef47dc13efec2@206.189.206.88:26656,d3b5b6ca39c8c62152abbeac4669816166d96831@165.22.24.236:26656,8d3c052191b3b01ef3610b5f0bd8b6370bd5f587@136.243.95.80:12656,5ed78473db84b355e55f62f02ecb13673d13f6c3@135.181.205.80:26656,88ffe6a82f9f5425c7484d3659130db88b0907a5@38.242.230.118:57656,481c868e81e970fb63c9774e879827297779fda1@65.108.199.26:12656,18e83353cbb62095e6eeb27fff103482744b5238@95.214.55.138:7656,af04b141b490c0733fd01895d09b25c3e282eee4@65.109.122.105:60656,a036c7069184c194b1cd7663f3cf4c833190b600@146.190.142.13:19356,77a0cd799f9de5cb801c5f6a88532120aa511f87@5.181.190.161:27161,be74a34ca65acc39427c58c265e42195b549730a@65.21.230.230:12656,240c6facf89f2e7fcaa26a130fc61490b02af428@150.230.117.183:57656,8557c34c9d5173cacbfa0f18fb6588b0064fa53a@143.198.166.42:656,16ca4c47865ca661aa9586f47b2556b403b915e3@49.13.86.84:26656,e309353ea059e2a1945c29c68e14234c59ee9bec@95.216.199.225:26656,cee1b807dbe936289f207006a74f1c101457efc2@46.4.23.108:12656,5854a6ec9226632ae2f8d80e85d9eb9ba5f80dca@5.75.178.181:26656,050d8697de8aca03cad379fa7f7b5d55a62201df@144.24.55.34:26656,b4e2f257db5a42fa562901018e0aeee30ef3be78@104.36.85.247:26656,f76729a7e0e8235d867a99ecb806b7d367450c3f@65.109.237.206:26656,444b53c783a8ac970e4f69699e18bad266955cc4@51.79.82.227:14656,4bdec5933f5204775d27fbc6191785c264ab20a1@5.78.99.65:26656,3634699c5a957228d84fb0d08fe5c510a0f66e14@49.13.83.157:26656,3efebfd1a741ea4a6b5563014482804674f16081@144.91.124.126:20656,bae21418b80df93ab49f3cd612989dd1d739bdda@167.235.132.251:26656,3d8090c89c7e71ca5bcaa4884c5dfb34fe1ed290@95.216.208.150:55916,d8523afbe8138d0c66478081e82a0bf2422bd985@195.201.127.140:26656,7d6a3a6992e3c3ec816ea099751a90d74320ba8f@154.26.133.141:26656,26209117680471d5563d2fcd0423ddf132a6e01f@95.217.134.65:26656,665ad078634af2c7cfad4a033369d7b883313b9a@135.181.227.157:19356,59b50622fedb264ba4871b48c42ef21b518566da@141.94.18.48:26656,67f89f4a314c6a29c12e553eabc9bc8ec8833a47@65.21.57.141:26656,3c0d5fe98200c50b58a04b4e8f05b2657e7bfd91@116.202.241.157:44656,a5eb485d3acb8cfd455795856d49df84d3407892@65.109.116.204:20556,52e3b43d4c058dcfad673a4dc84634864e403c5d@135.181.138.160:26656,7d3292fe76e4d40da5a580c85d1bf80c956f67c6@142.132.203.115:26656,5a019e4d8ea8990f81b6276bd0b3b043683aa9dc@65.108.60.228:26656,b0c015acbbaa62c0100c0cb2b4180bb6e2fdac42@68.183.98.59:26656,db28926b9deeeb0c8922d29a0966b543bba1c0c2@167.235.204.7:26656,26ed79f959a4e2adb262d2ccd12b38c0e7b6c213@143.110.153.141:26656,6e93a2bf30f8fba046d9469a292c6f8504ea230e@167.235.57.122:26656,c244ea9c8d45923b00439617324552eaf20efd3e@5.9.61.78:33656,77370fad958c3404d0709e59839c6c8bf9b6cb12@194.163.155.84:33656,bbebcef073f20f2e3d04168368d4cc1376f5ec95@45.67.216.69:26656,184eda9af0acccc7049b378fd000fced3808e3f3@104.168.128.252:26656,d3f80eea11bf3ced317939db2228895a685bf2fc@65.109.154.182:15656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.selfchain/config/config.toml
```

### Addrbook
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Selfchain/addrbook.json > $HOME/.selfchain/config/addrbook.json
```
### Genesis
```
curl -Ls https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Selfchain/genesis.json > $HOME/.selfchain/config/genesis.json
```