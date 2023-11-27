#!/bin/bash

CYAN='\033[0;36m' # Cyan
RED='\033[0;31m' # Red
NC='\033[0m' # No Color

# Initialize
echo -e "Welcome to the Tipoca City setup!"  
echo -e "Visit the README for help using this script: ${CYAN}https://github.com/evanjd711/TipocaCity/blob/main/README.md${NC}\n"
sudo apt update
sudo apt install git curl ca-certificates gnupg
sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
git clone --recursive https://github.com/evanjd711/TipocaCity /opt/TipocaCity
cd /opt/TipocaCity
 
# Starting Port Group
echo -ne "${CYAN}Enter Starting Port Group ${NC}(1000-4096, Default: 1801): "
read startingportgroup
startingportgroup=${startingportgroup:-1801}
echo 
# Ending Port Group
echo -ne "${CYAN}Enter Ending Port Group ${NC}(1000-4096, Default: 4000): "
read endingportgroup
endingportgroup=${endingportgroup:-4000}

# Use HTTPS
echo -ne "${CYAN}Use HTTPS ${NC}(Y/N, Default: Y): "
read https
if [ -z "$https" ]; then
    https="true"
elif [[ "$https" =~ ^[Yy]$ ]]; then
    https="true"
elif [[ "$https" =~ ^[Nn]$ ]]; then
    https="false"
fi

# vCenter FQDN
echo -ne "${CYAN}vCenter FQDN: ${NC}"
read vcenterurl
if [ -z "$vcenterurl" ]; then
    echo -e "${RED}[ERROR] - vCenter FQDN is required.${NC}"
    exit 1
fi

# vCenter API Account
echo -ne "${CYAN}vCenter API Account: ${NC}"
read -r vcenterusername
if [ -z "$vcenterusername" ]; then
    echo -e "${RED}[ERROR] - vCenter Username is required.${NC}"
    exit 1
fi

# vCenter API Password
echo -ne "${CYAN}vCenter API Password: ${NC}"
read -s vcenterpassword
echo
if [ -z "$vcenterpassword" ]; then
    echo -e "${RED}[ERROR] - vCenter Password is required.${NC}"
    exit 1
fi

# vCenter Datacenter
echo -ne "${CYAN}vCenter Datacenter: ${NC}"
read datacenter
if [ -z "$datacenter" ]; then
    echo -e "${RED}[ERROR] - vCenter Datacenter is required.${NC}"
    exit 1
fi

# Parent Resource Pool
echo -ne "${CYAN}Parent Resource Pool ${NC}(Default: Kamino): "
read parentresourcepool
parentresourcepool=${parentresourcepool:-"Kamino"}

# Template Resource Pool
echo -ne "${CYAN}Template Resource Pool ${NC}(Default: Kamino-Templates): "
read presettemplateresourcepool
presettemplateresourcepool=${presettemplateresourcepool:-"Kamino-Templates"}

# Destination Resource Pool for Clones
echo -ne "${CYAN}Destination Resource Pool for Clones ${NC}(Default: Kamino-Clones): "
read targetresourcepool
targetresourcepool=${targetresourcepool:-"Kamino-Clones"}

# WAN Port Group
echo -ne "${CYAN}WAN Port Group: ${NC}"
read wanportgroup
if [ -z "$wanportgroup" ]; then
    echo -e "${RED}[ERROR] - WAN Port Group is required.${NC}"
    exit 1
fi

# Maximum Pods per User
echo -ne "${CYAN}Maximum Pods per User ${NC}(Default: 5):"
read maxpodlimit
maxpodlimit=${maxpodlimit:-5}

# vSphere Distributed Switch
echo -ne "${CYAN}vSphere Distributed Switch: ${NC}"
read maindistributedswitch
if [ -z "$maindistributedswitch" ]; then
    echo -e "${RED}[ERROR] - vSphere Distributed Switch is required.${NC}"
    exit 1
fi

# Kamino Port Groups Suffix
echo -ne "${CYAN}Kamino Port Groups Suffix ${NC}(Default: KaminoNetwork): "
read portgroupsuffix
portgroupsuffix=${portgroupsuffix:-"KaminoNetwork"}

# VM Template Folder
echo -ne "${CYAN}VM Template Folder ${NC}(Default: Templates): "
read templatefolder
templatefolder=${templatefolder:-"Templates"}

# Create config files
echo "Creating config files..."
cat << EOF > cyclone/config.conf
startingportgroup = $startingportgroup
endingportgroup = $endingportgroup
https = $https
key = ".//tls//key.pem"
cert = ".//tls//cert.pem"
port = 8080
vCenterURL = "$vcenterurl"
vCenterUsername = "$vcenterusername"
vCenterPassword = "$vcenterpassword"
datacenter = "$datacenter"
presettemplateresourcepool = "$presettemplateresourcepool"
targetresourcepool  = "$targetresourcepool"
domain = "kamino.labs"
wanportgroup = "$wanportgroup"
maxpodlimit = $maxpodlimit
logPath = ".//Logs//kamino.log"
maindistributedswitch = "$maindistributedswitch"
portgroupsuffix = "$portgroupsuffix"
templatefolder = "$templatefolder"
EOF

# Create SSL Certs
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=US/ST=CA/L=Pomona/O=Kamino/OU=Kamino/CN=tipoca.kamino.labs"
mkdir ./cyclone/tls
cp *.pem ./cyclone/tls/
mkdir ./kamino-frontend/tls
cp *.pem ./kamino-frontend/tls/

# Setting Configs
echo -e "${CYAN}Configurating...${NC}"
echo -e "${CYAN}FQDN to Access the Web Application (Example: kamino.sdc.cpp): ${NC}"
read fqdn
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/pages/Dashboard/*.vue
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/pages/UserProfile/*.vue
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/pages/*.vue
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/router/*.js
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/cyclone/main.go

# Setup Cyclone
mkdir ./cyclone/lib
mkdir ./cyclone/lib/creds

cd /opt/TipocaCity
docker-compose up