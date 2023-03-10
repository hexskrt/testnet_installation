#
# // Copyright (C) 2023 Salman Wahib (sxlmnwb) Recoded by Hexnodes
#

echo ""
read -p "You must have more than 1000000 uojo / 1 OJO in main wallet ! (y/n) " choice1
if [ "$choice1" == "y" ]; then
    echo ""
    echo -e "\e[1m\e[31mSTARTING\e[0m"
else
    echo ""
    echo -e "\e[1m\e[31mCANCELLED\e[0m"
    echo ""
    exit
fi

#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "            Automatic Installer for Pricefeeder OjO Network v0.1.1 ";
echo -e "\e[0m"
sleep 1

# Set Wallet
if [ ! $OJO_WALLET1 ]; then
    echo -e "EXAMPLE : \e[1m\e[31mwallet\e[0m"
    echo ""
	read -p "hexskrt@hexnodes:~# [ENTER YOUR MAIN WALLET NAME] > " OJO_WALLET1
fi

# Set Wallet Price Feeder
if [ ! $OJO_WALLET_PRICEFEEDER ]; then
    echo ""
    echo -e "EXAMPLE : \e[1m\e[31mpricefeeder-wallet\e[0m"
    echo ""
	read -p "hexskrt@hexnodes:~# [ENTER YOUR WALLET PRICE FEEDER NAME] > " OJO_WALLET_PRICEFEEDER
fi

# Set Wallet Price Feeder Password
if [ ! $OJO_WALLET_PRICEFEEDER_PASSWORD ]; then
    echo ""
    echo -e "EXAMPLE : \e[1m\e[31mpassword123\e[0m"
    echo ""
	read -p "hexskrt@hexnodes:~# [ENTER YOUR WALLET PRICE FEEDER PASSWORD] > " OJO_WALLET_PRICEFEEDER_PASSWORD
fi

# Variable Ojo
export OJO=ojod
export OJO_FOLDER=.ojo
export OJO_ID=ojo-devnet
export OJO_DENOM=uojo

# Variable Price Feeder
export OJO_WALLET1=$OJO_WALLET1
export OJO_WALLET_PRICEFEEDER=$OJO_WALLET_PRICEFEEDER
export OJO_WALLET_PRICEFEEDER_PASSWORD=$OJO_WALLET_PRICEFEEDER_PASSWORD
export OJO_PRICEFEEDER=ojo-price-feeder
export OJO_PRICEFEEDER_FOLDER=.ojo-price-feeder
export OJO_PRICEFEEDER_REPO=https://github.com/ojo-network/price-feeder
export OJO_PRICEFEEDER_VERSION=v0.1.1
export OJO_PRICEFEEDER_KEYRING=os
export OJO_LISTEN_PORT=28172
export OJO_RPC_PORT=$(echo $(grep -A 9 "# TCP or UNIX socket address for the RPC server to listen on" $HOME/$OJO_FOLDER/config/config.toml | grep -oP '(?<=:)[0-9]+'))
export OJO_GRPC_PORT=$(echo $(grep -A 9 "# Address defines the gRPC server address to bind to." $HOME/$OJO_FOLDER/config/app.toml | grep -oP '(?<=:)[0-9]+'))
export OJO_VALIDATOR_ADDRESS=$(ojod keys show $OJO_WALLET1 --bech val -a)
export OJO_MAIN_WALLET_ADDRESS=$(ojod keys show $OJO_WALLET1 -a)
export OJO_PRICEFEEDER_ADDRESS=$(echo "$OJO_WALLET_PRICEFEEDER_PASSWORD" | $OJO keys show $OJO_WALLET_PRICEFEEDER --keyring-backend os -a)

echo ""
echo -e "WALLET ADDRESS : \e[1m\e[31m$OJO_MAIN_WALLET_ADDRESS\e[0m"
echo -e "PRICEFEEDER ADDRESS : \e[1m\e[31m$OJO_PRICEFEEDER_ADDRESS\e[0m"
echo -e "VALOPERWALLET ADDRESS : \e[1m\e[31m$OJO_VALIDATOR_ADDRESS\e[0m"
echo -e "RPC PORT : \e[1m\e[31m$OJO_RPC_PORT\e[0m"
echo -e "gRPC PORT : \e[1m\e[31m$OJO_GRPC_PORT\e[0m"
echo ""

read -p "Is the above information correct? (y/n) " choice2
if [ "$choice2" == "y" ]; then
    echo ""
    echo -e "\e[1m\e[31mCONTINUE\e[0m"
else
    echo ""
    echo -e "\e[1m\e[31mCANCELLED\e[0m"
    echo ""
    exit
fi

# Install GO
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get devnet pricefeeder version of ojo
cd $HOME
rm -rf price-feeder
git clone $OJO_PRICEFEEDER_REPO
cd price-feeder
git checkout $OJO_PRICEFEEDER_VERSION
make build
cd build
sudo mv price-feeder $OJO_PRICEFEEDER
sudo mv $OJO_PRICEFEEDER /usr/bin/

cd ..
rm -rf $HOME/$OJO_PRICEFEEDER_FOLDER
mkdir $HOME/$OJO_PRICEFEEDER_FOLDER
mv price-feeder.example.toml $HOME/$OJO_PRICEFEEDER_FOLDER/config.toml

# Fund the pricefeeder-wallet with some testnet tokens.
$OJO tx bank send wallet $OJO_PRICEFEEDER_ADDRESS 1000000uojo --from $OJO_WALLET1 --chain-id $OJO_ID --fees 1000uojo -y

# Delegate pricefeeder responsibility
$OJO tx oracle delegate-feed-consent $OJO_MAIN_WALLET_ADDRESS $OJO_PRICEFEEDER_ADDRESS --from $OJO_WALLET1 --fees 1000uojo -y

# Set pricefeeder configuration values
sed -i "s/^listen_addr *=.*/listen_addr = \"0.0.0.0:${OJO_LISTEN_PORT}\"/;\
s/^address *=.*/address = \"$OJO_PRICEFEEDER_ADDRESS\"/;\
s/^chain_id *=.*/chain_id = \"$OJO_ID\"/;\
s/^validator *=.*/validator = \"$OJO_VALIDATOR_ADDRESS\"/;\
s/^backend *=.*/backend = \"$OJO_PRICEFEEDER_KEYRING\"/;\
s|^dir *=.*|dir = \"$HOME/$OJO_FOLDER\"|;\
s|^grpc_endpoint *=.*|grpc_endpoint = \"localhost:${OJO_GRPC_PORT}\"|;\
s|^tmrpc_endpoint *=.*|tmrpc_endpoint = \"http://localhost:${OJO_RPC_PORT}\"|;\
s|^global-labels *=.*|global-labels = [[\"chain_id\", \"$OJO_ID\"]]|;\
s|^service-name *=.*|service-name = \"ojo-price-feeder\"|;" $HOME/$OJO_PRICEFEEDER_FOLDER/config.toml

# Create Service
sudo tee /etc/systemd/system/$OJO_PRICEFEEDER.service > /dev/null <<EOF
[Unit]
Description=$OJO_PRICEFEEDER
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $OJO_PRICEFEEDER) $HOME/$OJO_PRICEFEEDER_FOLDER/config.toml
Restart=on-failure
RestartSec=30
LimitNOFILE=65535
Environment="PRICE_FEEDER_PASS=$OJO_WALLET_PRICEFEEDER_PASSWORD"

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $OJO_PRICEFEEDER
sudo systemctl start $OJO_PRICEFEEDER

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $OJO_PRICEFEEDER -o cat\e[0m"
echo ""

# End
