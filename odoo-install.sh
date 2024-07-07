#!/bin/bash

# Clear the screen for a cleaner execution view
clear

echo -e "\033[1;34m=== Actualización del Sistema Operativo ===\033[0m"
sudo apt-get update && sudo apt-get upgrade -y

echo -e "\033[1;34m=== Selección de Versión de Odoo ===\033[0m"
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
        echo -e "\033[1;31mOpción no válida. Por favor, intenta nuevamente.\033[0m"
        exit 1
        ;;
esac

os_name=$(source /etc/os-release && echo $ID)
echo -e "\n\033[1;34m=== Verificación de Sistema Operativo ===\033[0m"
if [[ "$os_name" == "ubuntu" || "$os_name" == "debian" || "$os_name" == "centos" ]]; then
    echo "Sistema operativo compatible detectado: $os_name."
else
    echo -e "\033[1;31mEste script solo es compatible con Debian, Ubuntu o CentOS.\033[0m"
    exit 1
fi

echo -e "\n\033[1;34m=== Creación de Estructura de Directorios y Descompresión de Archivos ===\033[0m"
sudo mkdir -p /opt/odoo/{config,extra-addons,source/odoo,source/enterprise}
if [ -f "Odoo.zip" ]; then
    sudo unzip Odoo.zip -d /opt/
    echo "Carpeta Base Odoo Creada Satisfactoriamente."
else
    echo -e "\033[1;31mNo se encontró el archivo Odoo.zip. Asegúrate de que el archivo esté en el directorio actual.\033[0m"
    exit 1
fi

echo -e "\n\033[1;34m=== Instalación de Docker desde el Repositorio Oficial ===\033[0m"
if ! command -v docker > /dev/null; then
    echo "Instalando Docker..."
    if [[ "$os_name" == "ubuntu" || "$os_name" == "debian" ]]; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    elif [[ "$os_name" == "centos" ]]; then
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
    fi
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker instalado y configurado correctamente."
else
    echo "Docker ya está instalado."
fi

echo -e "\n\033[1;34m=== Instalación de Docker Compose ===\033[0m"
if ! command -v docker-compose > /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose instalado correctamente."
else
    echo "Docker Compose ya está instalado."
fi

echo -e "\n\033[1;34m=== Selección de Edición de Odoo ===\033[0m"
echo "1) Community (Gratuita y Open Source)"
echo "2) Enterprise (Requiere un código de licencia y es de pago)"
read -p "Selecciona la edición que deseas instalar (1, 2): " edition_choice

echo -e "\n"
case $edition_choice in
    1)
        echo "Has seleccionado Odoo Community."
        ;;
    2)
        echo "Has seleccionado Odoo Enterprise. Por favor, asegúrate de tener un token de acceso personal de GitHub."
        read -p "Introduce tu token de acceso personal de GitHub: " github_pat
        echo -e "\nClonando el repositorio de Odoo Enterprise..."
        sudo git clone https://$github_pat@github.com/odoo/enterprise -b $odoo_version /opt/odoo/source/enterprise
        if [ $? -eq 0 ]; then
            echo -e "\n\033[1;32mRepositorio de Odoo Enterprise clonado exitosamente.\033[0m"
        else
            echo -e "\033[1;31mNo se pudo clonar el repositorio Enterprise. Verifica tu token y acceso al repositorio.\033[0m"
            exit 1
        fi
        ;;
    *)
        echo -e "\033[1;31mOpción no válida. Por favor, intenta nuevamente.\033[0m"
        exit 1
        ;;
esac

echo -e "\nClonando el repositorio de Odoo Community..."
sudo git clone https://github.com/odoo/odoo -b $odoo_version /opt/odoo/source/odoo
if [ $? -eq 0 ]; then
    echo -e "\n\033[1;32mRepositorio de Odoo clonado exitosamente en /opt/odoo/source/odoo.\033[0m"
else
    echo -e "\033[1;31mError al clonar el repositorio de Odoo. Verifica los permisos y el espacio disponible.\033[0m"
fi

echo -e "\n\033[1;32mEl proceso de instalación ha finalizado. Por favor, personaliza tu instalación de Odoo según tus necesidades específicas.\033[0m"
