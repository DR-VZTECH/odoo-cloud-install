#!/bin/bash

echo "Selecciona la versión de Odoo que deseas instalar:"
echo "1) Odoo 15.0"
echo "2) Odoo 16.0"
echo "3) Odoo 17.0"
read -p "Ingresa el número de la versión que deseas instalar (1, 2, 3): " version_choice

case $version_choice in
    1)
        odoo_version="15.0"
        ;;
    2)
        odoo_version="16.0"
        ;;
    3)
        odoo_version="17.0"
        ;;
    *)
        echo "Opción no válida. Por favor, intenta nuevamente."
        exit 1
        ;;
esac

os_name=$(grep '^ID=' /etc/os-release | cut -d '=' -f2 | tr -d '"')

if [[ "$os_name" == "ubuntu" || "$os_name" == "debian" || "$os_name" == "centos" ]]; then
    echo "Sistema operativo compatible detectado: $os_name."
else
    echo "Este script solo es compatible con Debian, Ubuntu o CentOS."
    exit 1
fi

# Crear estructura de directorios en /opt/odoo
echo "Creando estructura de directorios para Odoo en /opt/odoo..."
sudo mkdir -p /opt/odoo/{config,extra-addons,source/odoo,source/enterprise}
sudo chown -R $USER:$USER /opt/odoo
echo "Directorios creados y permisos establecidos."

# Verificar si GitHub CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "Instalando GitHub CLI..."
    if [[ "$os_name" == "debian" || "$os_name" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y software-properties-common
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
        sudo apt-add-repository https://cli.github.com/packages
        sudo apt update
        sudo apt install gh
    elif [[ "$os_name" == "centos" ]]; then
        sudo yum install -y yum-utils
        sudo yum config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo yum install gh
    fi
    echo "GitHub CLI ha sido instalado correctamente."
else
    echo "GitHub CLI ya está instalado."
fi

# Verificar si Docker y Docker Compose ya están instalados
if command -v docker > /dev/null && command -v docker-compose > /dev/null; then
    echo "Docker y Docker Compose ya están instalados. Tu sistema parece estar al día."
else
    # Instalación de Docker
    echo "Instalando Docker..."
    if [[ "$os_name" == "debian" || "$os_name" == "ubuntu" ]]; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
    elif [[ "$os_name" == "centos" ]]; then
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce
    fi
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker ha sido instalado y configurado correctamente."

    # Instalación de Docker Compose
    echo "Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose ha sido instalado correctamente."
fi

# Preguntar al usuario si desea instalar Odoo Enterprise
read -p "¿Deseas instalar Odoo en su versión Enterprise? (s/n): " install_enterprise
install_enterprise=${install_enterprise,,} # Convertir a minúsculas

if [[ "$install_enterprise" == "s" ]]; then
    echo "Autenticación necesaria para acceder al repositorio de Odoo Enterprise."
    gh auth login
    echo "Clonando el repositorio de Odoo Enterprise para la versión $odoo_version..."
    gh repo clone odoo/enterprise -- -b "$odoo_version" /opt/odoo/source/enterprise
    echo "Repositorio clonado exitosamente en /opt/odoo/source/enterprise."
fi

# Clonar el repositorio de Odoo
echo "Clonando el repositorio de Odoo para la versión $odoo_version..."
gh repo clone odoo/odoo -- -b "$odoo_version" /opt/odoo/source/odoo
echo "Repositorio de Odoo clonado exitosamente en /opt/odoo/source/odoo."

echo "El proceso de instalación ha finalizado. Por favor, personaliza tu instalación de Odoo según tus necesidades específicas."
