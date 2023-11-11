# Use Rocky Linux as base image
FROM debian

### Required Configurations ###

# Hostname
RUN echo '127.0.0.1 ldap.kamino.labs' >> /etc/hosts
RUN hostnamectl set-hostname ldap.kamino.labs --static

### Install Dependencies ###

# Install Packages
RUN apt install -y slapd ldap-utils nodejs git wget

# Pull Kamino-Frontend
RUN git clone https://github.com/dbaseqp/kamino-frontend.git

# Pull Cyclone
RUN git clone https://github.com/dbaseqp/cyclone.git

# Install PowerShell
RUN wget -q https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt update
RUN apt install -y powershell

# Install PowerShell Modules
RUN pwsh -c "Install-Module -Name BruhArmy -Force"
RUN pwsh -c "Install-Module -Name VMware.PowerCLI -Force"