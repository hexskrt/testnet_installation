<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/explorer/blob/master/public/logos/nolus.png?raw=true">
</p>

# Nolus Testnet | Chain ID : nolus-rila

### Official Documentation:
>- [Validator Setup Instructions](https://docs-nolus-protocol.notion.site/Run-a-Node-58c9af73bf5945988e902b4b8741f918)

### Explorer:
>-  https://explorer.hexskrt.net/nolus

### Automatic Installer
You can setup your Nibiru fullnode in few minutes by using automated script below.
```
wget -O nolus.sh https://raw.githubusercontent.com/hexskrt/testnet_installation/main/Nolus/nolus.sh && chmod +x nolus.sh && ./nolus.sh
```

### Snapshot (Update every 5 hours)
```
sudo systemctl stop nolusd
cp $HOME/.nolus/data/priv_validator_state.json $HOME/.nolus/data/priv_validator_state.json.backup
rm -rf $HOME/.nolus/data

curl -L http://snap.hexskrt.net/nolus/nolus-snapshot-20230301.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nolus

mv $HOME/.nolus/data/priv_validator_state.json.backup $HOME/.nolus/data/priv_validator_state.json

sudo systemctl start nolusd && sudo journalctl -fu nolusd -o cat
```

You can find more information about nolus testnet on links below:

**https://hexskrt.net/testnet/nolus**
