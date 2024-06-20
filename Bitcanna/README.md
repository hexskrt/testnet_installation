<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/bcna.jpg?raw=true">
</p>

# Bitcanna Testnet | Chain ID : bitcanna-dev-1

### Explorer:
>-  [https://explorer.hexnodes.co/bitcanna-testnet](https://explorer.hexnodes.one/BITCANNA-TESTNET)

### Automatic Installer
You can setup your Bitcanna fullnode in few minutes by using automated script below.
```
wget -O bitcanna.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Bitcanna/bitcanna.sh && chmod +x bitcanna.sh && ./bitcanna.sh
```

### State Sync
```
sudo systemctl stop bcnad
cp $HOME/.bcna/data/priv_validator_state.json $HOME/.bcna/priv_validator_state.json.backup
bcnad tendermint unsafe-reset-all --home $HOME/.bcna

STATE_SYNC_RPC=https://rpc.bitcanna-dev.hexnodes.one:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo $SYNC_BLOCK_HEIGHT $LATEST_HEIGHT $SYNC_BLOCK_HASH

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.bcna/config/config.toml

mv $HOME/.bcna/priv_validator_state.json.backup $HOME/.bcna/data/priv_validator_state.json

sudo systemctl start bcnad && sudo journalctl -u bcnad -f --no-hostname -o cat
```

### Live Peers
```
PEERS="$(curl -sS https://rpc.bitcanna-dev.hexnodes.one/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.bcna/config/config.toml
```

### Bitcanna CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
bcnad keys add wallet
```

Recover Wallet
```
bcnad keys add wallet --recover
```

List Wallet
```
bcnad keys list
```

Delete Wallet
```
bcnad keys delete wallet
```

Check Wallet Balance
```
bcnad q bank balances $(bcnad keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
bcnad tx staking create-validator \
  --chain-id bitcanna-dev-1 \
  --pubkey="$(bcnad tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000ubcna \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000ubcna \
  -y
```

Edit Validator
```
bcnad tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id bitcanna-dev-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
bcnad tx slashing unjail --from wallet --chain-id bitcanna-dev-1 --gas auto -y
```

Check Jailed Reason
```
bcnad query slashing signing-info $(bcnad tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
bcnad tx distribution withdraw-all-rewards --from wallet --chain-id bitcanna-dev-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ubcna" -y
```

Withdraw Rewards with Comission
```
bcnad tx distribution withdraw-rewards $(bcnad keys show wallet --bech val -a) --commission --from wallet --chain-id bitcanna-dev-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ubcna" -y
```

Delegate Token to your own validator
```
bcnad tx staking delegate $(bcnad keys show wallet --bech val -a) 100000000ubcna --from wallet --chain-id bitcanna-dev-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ubcna" -y
```

Delegate Token to other validator
```
bcnad tx staking redelegate $(bcnad keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000ubcna --from wallet --chain-id bitcanna-dev-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ubcna" -y
```

Unbond Token from your validator
```
bcnad tx staking unbond $(bcnad keys show wallet --bech val -a) 100000000ubcna --from wallet --chain-id bitcanna-dev-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ubcna" -y
```

Send Token to another wallet
```
bcnad tx bank send wallet <TO_WALLET_ADDRESS> 100000000ubcna --from wallet --chain-id bitcanna-dev-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
bcnad tx gov vote 1 yes --from wallet --chain-id bitcanna-dev-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ubcna" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=100` To any other ports
```
CUSTOM_PORT=100
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}58\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}56\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.bcna/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.bcna/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.bcna/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.bcna/config/config.toml
```

Reset Chain Data
```
bcnad tendermint unsafe-reset-all --home $HOME/.bcna --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove bitcanna

```
sudo systemctl stop bcnad && \
sudo systemctl disable bcnad && \
rm /etc/systemd/system/bcnad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .bcna && \
rm -rf $(which bcnad)
```
