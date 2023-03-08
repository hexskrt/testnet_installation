#
# // Copyright (C) 2023 Airdrop Finder Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "             Automatic Installer for Deinfra Testnet Phase II";
echo -e "\e[0m"
sleep 3

echo "==========INSTALLING DEPENDENCIES=========="
sleep 2

apt -y install erlang-base erlang-public-key erlang-ssl docker-compose

if [ -f /usr/local/bin/tp ]; then
   rm -rf /usr/local/bin/tp
fi

sudo wget https://tea.thepower.io/tp -O /usr/local/bin/tp
sudo chmod a+x /usr/local/bin/tp

if [ -d /opt/thepower ]; then
    rm -rf /opt/thepower
fi

echo "==========CREATING THEPOWER FOLDER=========="
sleep 2
mkdir -p {/opt/thepower/db/cert,/opt/thepower/log}

echo "==========GENERATING KEY=========="
sleep 2

cd /opt/thepower
tp --genkey --ed25519

echo "==========INITIALIZE CONFIG=========="
sleep 2

read -p "Masukan hostname: " HOSTNAME
read -p "Masukan upstream link: " UPSTREAM
read -p "Masukan email: " EMAIL

sudo tee /opt/thepower/node.config > /dev/null <<EOF
{tpic,#{peers => [],port => 1800}}.


% ====== [ here is an example of configuration ] ======

{discovery,#{addresses =>[
#{address => "$HOSTNAME", port => 1800, proto => tpic},
#{address => "$HOSTNAME", port => 1443, proto => apis},
#{address => "$HOSTNAME", port => 1080, proto => api}
]}}.

{replica, true}.

{hostname, "$HOSTNAME"}.

{upstream, [
    $UPSTREAM
]}.

% ======= [ end of example ] ========


{dbsuffix,""}.
{loglevel, info}.
{info_log, "log/info.log"}.
{error_log, "log/error.log"}.
{debug_log, "log/debug.log"}.
{rpcsport, 1443}.
{rpcport, 1080}.
EOF

grep priv tpcli.key >> node.config

echo "==========GETTING SSL=========="
sleep 2

sudo ufw allow 80
sudo ufw allow 1443
sudo ufw allow 1080
sudo ufw allow 1800

apt-get install socat
curl https://get.acme.sh | sh -s email=$EMAIL
cd $HOME/.acme.sh
./acme.sh --server letsencrypt --issue --standalone -d $HOSTNAME

./acme.sh --install-cert -d $HOSTNAME \
--cert-file /opt/thepower/db/cert/$HOSTNAME.crt \
--key-file /opt/thepower/db/cert/$HOSTNAME.key \
--ca-file /opt/thepower/db/cert/$HOSTNAME.crt.ca.crt

./acme.sh --info -d $HOSTNAME

sudo tee /opt/thepower/docker-compose.yml > /dev/null <<EOF
version: "3.3"

services:

  tpnode:
    restart: unless-stopped
    container_name: tpnode
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    image: thepowerio/tpnode
    volumes:
      - type: bind
        source: /opt/thepower/node.config
        target: /opt/thepower/node.config
        read_only: true
      - type: bind
        source: /opt/thepower/db
        target: /opt/thepower/db
      - type: bind
        source: /opt/thepower/log
        target: /opt/thepower/log
    network_mode: 'host'

  watchtower:
    restart: unless-stopped
    container_name: watchtower
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 3600 --cleanup
EOF

echo "==========SETUP FINISHED=========="
sleep 2
