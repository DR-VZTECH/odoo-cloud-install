#!/bin/bash

# Clear the screen for a cleaner execution view
clear

echo -e "\033[1;34m=== Actualización del Sistema Operativo ===\033[0m"
sudo apt-get update && sudo apt-get upgrade -y

echo -e "\n\033[1;34m=== Creación de Estructura de Directorios y Descompresión de Archivos ===\033[0m"
if [ -f "Odoo.zip" ]; then
    sudo unzip Odoo.zip -d /opt/
    echo -e "\033[1;32mCarpeta Base Odoo creada y archivo descomprimido correctamente en /opt/odoo.\033[0m"
else
    echo -e "\033[1;31mNo se encontró el archivo Odoo.zip. Asegúrate de que el archivo esté en el directorio actual.\033[0m"
    exit 1
fi

echo -e "\n\033[1;34m=== Instalación de Docker desde el Repositorio Oficial ===\033[0m"
if ! command -v docker > /dev/null; then
    echo "Instalando Docker..."
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    elif [[ "$ID" == "centos" ]]; then
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
    fi
    sudo systemctl start docker
    sudo systemctl enable docker
    echo -e "\033[1;32mDocker instalado y configurado correctamente.\033[0m"
else
    echo "Docker ya está instalado."
fi

echo -e "\n\033[1;34m=== Instalación de Docker Compose ===\033[0m"
if ! command -v docker-compose > /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "\033[1;32mDocker Compose instalado correctamente.\033[0m"
else
    echo "Docker Compose ya está instalado."
fi

echo -e "\n\033[1;34m=== Selección de Versión de Odoo ===\033[0m"
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

echo -e "\n\033[1;34m=== Selección de Edición de Odoo ===\033[0m"
echo "1) Community (Gratuita y Open Source)"
echo "2) Enterprise (Requiere un código de licencia y es de pago)"
read -p "Selecciona la edición que deseas instalar (1, 2): " edition_choice

case $edition_choice in
    1)
        echo -e "\033[1;32mHas seleccionado Odoo Community.\033[0m"
        echo -e "\n"
	echo -e "\nClonando el repositorio de Odoo Base..."
        sudo git clone https://github.com/odoo/odoo -b $odoo_version /opt/odoo/source/odoo
        if [ $? -eq 0 ]; then
                echo -e "\n\033[1;32mRepositorio de Odoo clonado exitosamente en /opt/odoo/source/odoo.\033[0m"
        else
                echo -e "\033[1;31mError al clonar el repositorio de Odoo. Verifica los permisos y el espacio disponible.\033[0m"
        fi
        echo -e "\n"
;;
    2)
	echo -e "\nClonando el repositorio de Odoo Base..."
	sudo git clone https://github.com/odoo/odoo -b $odoo_version /opt/odoo/source/odoo
	if [ $? -eq 0 ]; then
    		echo -e "\n\033[1;32mRepositorio de Odoo clonado exitosamente en /opt/odoo/source/odoo.\033[0m"
	else
    		echo -e "\033[1;31mError al clonar el repositorio de Odoo. Verifica los permisos y el espacio disponible.\033[0m"
	fi
	echo -e "\n"
        echo -e "\033[1;32mHas seleccionado Odoo Enterprise. Por favor, asegúrate de tener un token de acceso personal de GitHub.\033[0m"
        read -p "Introduce tu token de acceso personal de GitHub: " github_pat
        echo -e "\n\033[1;34mClonando el repositorio de Odoo Enterprise...\033[0m"
        sudo git clone https://$github_pat@github.com/odoo/enterprise -b $odoo_version /opt/odoo/source/enterprise
        if [ $? -eq 0 ]; then
            echo -e "\033[1;32mRepositorio de Odoo Enterprise clonado exitosamente.\033[0m"
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

echo -e "\n\033[1;34m=== Configuración y Ejecución de Odoo con Docker ===\033[0m"
cd /opt/odoo/config
sudo docker build --pull --rm -f "Dockerfile" -t odoo:latest "."
if [ $? -eq 0 ]; then
    sudo docker-compose -f "docker-compose.yml" up -d --build
    if [ $? -eq 0 ]; then
        echo -e "\n\033[1;32mOdoo $odoo_version está ejecutándose en http://localhost:8069\033[0m"
        echo -e "\033[1;32mTodo fue realizado de manera satisfactoria.\033[0m"
    else
        echo -e "\033[1;31mError al iniciar Odoo con Docker Compose. Revisa la configuración.\033[0m"
    fi
else
    echo -e "\033[1;31mError al construir la imagen de Docker. Revisa el Dockerfile y los permisos.\033[0m"
fi

echo -e "\n\033[1;32mEl proceso de instalación ha finalizado. Por favor, personaliza tu instalación de Odoo según tus necesidades específicas.\033[0m"
