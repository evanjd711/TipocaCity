#!/bin/bash
CYAN='\033[0;36m' # Cyan
RED='\033[0;31m' # Red
NC='\033[0m' # No Color

if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root.${NC}" 1>&2
   exit 1
fi

# Initialize
echo -e "Welcome to the Tipoca City setup!"  
echo -e "Visit the README for help using this script: ${CYAN}https://github.com/evanjd711/TipocaCity/blob/main/README.md${NC}\n"
sudo apt update
sudo apt install git curl ca-certificates gnupg ldap-utils
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
export vcenterurl=$vcenterurl

# vCenter API Account
echo -ne "${CYAN}vCenter API Account: ${NC}"
read -r vcenterusername
if [ -z "$vcenterusername" ]; then
    echo -e "${RED}[ERROR] - vCenter Username is required.${NC}"
    exit 1
fi
export vcenterusername=$vcenterusername

# vCenter API Password
echo -ne "${CYAN}vCenter API Password: ${NC}"
read -s vcenterpassword
echo
if [ -z "$vcenterpassword" ]; then
    echo -e "${RED}[ERROR] - vCenter Password is required.${NC}"
    exit 1
fi
export vcenterpassword=$vcenterpassword

# vCenter Datacenter
echo -ne "${CYAN}vCenter Datacenter: ${NC}"
read datacenter
if [ -z "$datacenter" ]; then
    echo -e "${RED}[ERROR] - vCenter Datacenter is required.${NC}"
    exit 1
fi
export datacenter=$datacenter


# vCenter Cluster or host
echo -ne "${CYAN}vCenter Cluster or Host ${NC}(for Resource Pools): "
read cluster
if [ -z "$cluster" ]; then
    echo -e "${RED}[ERROR] - vCenter Cluster or Host is required.${NC}"
    exit 1
fi
export cluster=$cluster

# Parent Resource Pool
echo -ne "${CYAN}Parent Resource Pool ${NC}(Default: Kamino): "
read parentresourcepool
parentresourcepool=${parentresourcepool:-"Kamino"}
export parentresourcepool=$parentresourcepool

# Template Resource Pool
echo -ne "${CYAN}Template Resource Pool ${NC}(Default: Kamino-Templates): "
read presettemplateresourcepool
presettemplateresourcepool=${presettemplateresourcepool:-"Kamino-Templates"}
export presettemplateresourcepool=$presettemplateresourcepool

# Destination Resource Pool for Clones
echo -ne "${CYAN}Clone Resource Pool for Clones ${NC}(Default: Kamino-Clones): "
read targetresourcepool
targetresourcepool=${targetresourcepool:-"Kamino-Clones"}
export targetresourcepool=$targetresourcepool

# Inventory Location for Kamino VMs
echo -ne "${CYAN}Inventory Location for Kamino VMs ${NC}(Default: Kamino): "
read inventorylocation
inventorylocation=${inventorylocation:-"Kamino"}
export inventorylocation=$inventorylocation

# Datastore for Kamino VMs
echo -ne "${CYAN}Datastore for Kamino VMs ${NC}: "
read datastore
if [ -z "$datastore" ]; then
    echo -e "${RED}[ERROR] - Datastore is required.${NC}"
    exit 1
fi

# WAN Port Group
echo -ne "${CYAN}WAN Port Group: ${NC}"
read wanportgroup
if [ -z "$wanportgroup" ]; then
    echo -e "${RED}[ERROR] - WAN Port Group is required.${NC}"
    exit 1
fi

# WAN Network
echo -ne "${CYAN}WAN Network ID ${NC}(e.g. 172.16): "
read firsttwooctets
if [ -z "$firsttwooctets" ]; then
    echo -e "${RED}[ERROR] - WAN Network's First Two Octets are required.${NC}"
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
export templatelocation=$templatefolder

# LDAP Password
echo -ne "${CYAN}LDAP Server Admin Password: ${NC}"
read -s ldapadminpassword
if [ -z "$ldapadminpassword" ]; then
    echo -ne "${RED}[ERROR] - LDAP Server Admin Password is required.${NC}"
    exit 1
fi
export ldapadminpassword=$ldapadminpassword

echo -ne "${CYAN}FQDN to Kamino to Use (Example: kamino.your.domain): ${NC}"
read fqdn

echo -ne "${CYAN}Password for pfSense NAT Template: ${NC}(Default: pfsense): "
read -s pfsensepassword
pfsensepassword=${pfsensepassword:-"pfsense"}
export pfsensepassword=$pfsensepassword

# Setting Configs
echo -e "${CYAN}Configurating...${NC}"

# Create config files
echo "Creating config files..."
cat << EOF > cyclone/config.conf
startingportgroup = $startingportgroup
endingportgroup = $endingportgroup
https = $https
key = "./tls/key.pem"
cert = "./tls/cert.pem"
port = 8080
vCenterURL = "$vcenterurl"
vCenterUsername = "$vcenterusername"
vCenterPassword = "$vcenterpassword"
ldapadminpassword = "$ldapadminpassword"
datacenter = "$datacenter"
presettemplateresourcepool = "$presettemplateresourcepool"
targetresourcepool  = "$targetresourcepool"
domain = "kamino.labs"
wanportgroup = "$wanportgroup"
maxpodlimit = $maxpodlimit
logPath = "/opt/cyclone/logs/cyclone.log"
maindistributedswitch = "$maindistributedswitch"
EOF

# Create SSL Certs
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=US/ST=CA/L=Pomona/O=Kamino/OU=Kamino/CN=tipoca.kamino.labs"
mkdir ./cyclone/tls
cp *.pem ./cyclone/tls/
mkdir ./kamino-frontend/tls
cp *.pem ./kamino-frontend/tls/

#Configure Kamino Frontend
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/pages/Dashboard/*.vue
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/pages/UserProfile/*.vue
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/pages/*.vue
sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/kamino-frontend/src/router/*.js

# Setup Cyclone
mkdir /opt/TipocaCity/cyclone/logs
mkdir ./cyclone/lib
mkdir ./cyclone/lib/creds
sed -i "s/{vcenterfqdn}/$vcenterurl/g" /opt/TipocaCity/cyclone/pwsh/*.ps1

sed -i "s/{fqdn}/https:\/\/$fqdn/g" /opt/TipocaCity/cyclone/main.go
sed -i "s/{portgroupsuffix}/$portgroupsuffix/g" /opt/TipocaCity/cyclone/vsphere.go
sed -i "s/{templatefolder}/$templatefolder/g" /opt/TipocaCity/cyclone/vsphere.go

# Setup Kamino PowerShell Module
sed -i "s/{firsttwooctets}/$firsttwooctets/g" /opt/TipocaCity/cyclone/pwsh/Kamino/Kamino.psm1
sed -i "s/{portgroupsuffix}/$portgroupsuffix/g" /opt/TipocaCity/cyclone/pwsh/Kamino/Kamino.psm1
sed -i "s/{inventorylocation}/$inventorylocation/g" /opt/TipocaCity/cyclone/pwsh/Kamino/Kamino.psm1
sed -i "s/{datastore}/$datastore/g" /opt/TipocaCity/cyclone/pwsh/Kamino/Kamino.psm1
sed -i "s/{targetresourcepool}/$targetresourcepool/g" /opt/TipocaCity/cyclone/pwsh/Kamino/Kamino.psm1
sed -i "s/{maindistributedswitch}/$maindistributedswitch/g" /opt/TipocaCity/cyclone/pwsh/Kamino/Kamino.psm1

cd /opt/TipocaCity
docker-compose up -d

if [ $https == "true" ]; then
    url="https://$fqdn:8080/ping"
else
    url="http://$fqdn:8080/ping"
fi 

while true; do
    response=$(curl -o /dev/null -s -w "%{http_code}\n" "$url" -k)

    if [ "$response" -eq 200 ]; then
        echo -e "${CYAN}Kamino is now running.${NC}"
        break
    else
        echo -e "${RED}Waiting for Kamino to start...${NC}"
        sleep 5
    fi
done

# Cleanup
rm /opt/TipocaCity/*.pem
rm -rf /opt/TipocaCity/cyclone/pwsh/install
rm /opt/TipocaCity/install.sh
rm-rf /opt/TipocaCity/ldap
chmod 600 /opt/TipocaCity/cyclone/lib/creds/*
chmod 600 /opt/TipocaCity/cyclone/config.conf