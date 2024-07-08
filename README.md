# Script de Instalación de Odoo en Servidores Linux

Este script automatiza la instalación de Odoo en un servidor Linux, simplificando el proceso de configuración y despliegue, garantizando que todos los requisitos y dependencias sean instalados correctamente.

## Características

- **Instalación Automática**: Instala Odoo y todas sus dependencias de manera automática.
- **Compatibilidad**: Funciona en distribuciones populares de Linux como Ubuntu, Debian y CentOS.
- **Configuración Personalizable**: Permite la configuración de parámetros importantes como la versión de Odoo, el nombre de la base de datos y las credenciales de usuario.
- **Seguridad**: Incluye configuraciones de seguridad básicas, como la creación de un usuario dedicado para Odoo y la configuración de firewall.
- **Soporte para Nginx y PostgreSQL**: Configura y optimiza Nginx como proxy inverso y PostgreSQL como base de datos.

## Requisitos

- Un servidor Linux actualizado.
- Acceso root o permisos de sudo.

## Instrucciones de Uso

1. **Clonar el Repositorio Actual**:
   ```bash
   git clone https://github.com/tu_usuario/odoo-cloud-install.git
   cd odoo-cloud-install
   
2. **Dar Permisos de Ejecucion**:
   ```bash
   chmod +x install-odoo.sh
   
3. **Dar Permisos de Ejecucion**:
   ```bash
   sudo bash install-odoo.sh

3.1. **O en su Defecto Usar ./ Para Ejecucion**:
   ```bash
   ./install-odoo.sh
   ```

4. **Dar Permisos de Ejecucion**: Seguir las instrucciones del script dependiendo de la version de Odoo que desee instalar (15.0, 16.0 , 17.0)

## Componentes Instalados

- **Odoo**: El software principal.
- **PostgreSQL**: Base de datos relacional utilizada por Odoo.
- **Nginx**: Servidor web y proxy inverso.
- **Python**: Lenguaje de programación necesario para ejecutar Odoo y sus dependencias.

## Personalización

El script puede ser modificado para adaptarse a configuraciones específicas. Los parámetros como la versión de Odoo y la configuración de la base de datos pueden ser ajustados editando las variables correspondientes en el script.

## Contribuciones

Las contribuciones son bienvenidas. Si encuentras un problema o tienes una mejora, por favor abre un issue o envía un pull request.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Para más detalles, consulta el archivo LICENSE.
