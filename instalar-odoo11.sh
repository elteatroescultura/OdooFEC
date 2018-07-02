#!/bin/bash
################################################################################
# Script para instalar Odoo versión 11 Comunity en Ubuntu 16.04 con módulos para 
# Facturación electronica chilena, recursos humanos y contabilidad chilena
# Por: Edgar Rodríguez
#-------------------------------------------------------------------------------
# Este script va a instalar Odoo en su servidor Ubuntu 16.04. Puede realizar
# distintas instalaciones de odoo en un solo servidor Ubuntu por su difernetes
# xmlrpc_ports
#-------------------------------------------------------------------------------
# Hacer un nuevo arhivo:
# sudo nano instalar-odoo.sh
# Coloque este contenido en el archivo y hágalo ejecutable:
# sudo chmod +x odoo-install.sh
# Ejecute el archivo para instalar Odoo:
# ./instalar Odoo
################################################################################

#--------------------------------------------------
# Actualizamos el Servidor
#--------------------------------------------------
echo -e "\n---- Actualizamos servidor e instalamos git ----"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install git
sudo apt-get install fontconfig


echo -e "\n---- Creamos un usuario (odoo) para ejecutar Odoo Server ---"
sudo adduser --disabled-password --gecos "Odoo" odoo

echo -e "\n---- Instalando y configurando Postgresql ----"
sudo apt-get install postgresql postgresql-server-dev-9.5 -y


echo -e "\n---- Creamos un usuario en postgresql, para nuestro caso también llamaremos odoo ----"
sudo su -c "createuser -s odoo" postgres

echo -e "\n---- Instalamos las dependencias en python para Odoo. ----"
sudo apt-get install python3-pip python3-dev libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev libpq-dev libpng12-dev libjpeg-dev poppler-utils node-less node-clean-css -y

echo -e "\n---- Instalamos algunas librerías extras de python ----"
wget https://raw.githubusercontent.com/odoo/odoo/11.0/requirements.txt
sudo -H pip3 install -r requirements.txt

echo -e "\n---- Descargando OdooServer  (114 Mb) aprox.: ----"
sudo su - odoo
git clone https://github.com/odoo/odoo.git /home/odoo/odoo-11.0 -b 11.0 --depth=1

echo -e "\n---- WKHTMLTOPDF ( Version 0.12.1 ) para Odoo ----"
sudo apt-get -f install
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf

echo -e "\n---- Ejecutamos el siguiente comando: ----"
/home/odoo/odoo-11.0/odoo-bin


echo -e "\n---- Presiona Ctrl+C ----"

#Veremos algo así, indicando que vamos nuestra instalación:
#2017-10-05 06:00:21,746 24073 INFO ? odoo: Odoo version 11.0
#2017-10-05 06:00:21,746 24073 INFO ? odoo: addons paths: ['/home/odoo/.local/share/Odoo/addons/11.0', '/home/odoo/odoo-11.0/odoo/addons', '/home/odoo/odoo-11.0/addons']
#2017-10-05 06:00:21,746 24073 INFO ? odoo: database: default@default:default
#2017-10-05 06:00:21,784 24073 INFO ? odoo.service.server: HTTP service (werkzeug) running on 0.0.0.0:8069
#2017-10-05 06:00:22,160 24073 INFO ? odoo.addons.base.ir.ir_actions_report: You need Wkhtmltopdf to print a pdf version of the reports.
#2017-10-05 06:02:27,649 24073 INFO ? odoo.http: HTTP Configuring static files
#2017-10-05 06:02:27,789 24073 INFO ? odoo.http: Generating nondb routing


echo -e "\n---- Vamos a crear el archivo de configuración de Odoo: ----"
/home/odoo/odoo-11.0/odoo-bin --save --stop-after-init

echo -e "\n---- Salimos de la sesión del usuario (odoo) en la consola: ----"
exit

echo -e "\n---- Por lo general los archivos de configuración están dentro de /etc por que vamos a mover el archivo de configuración de OdooServer a /etc: ----"
sudo mkdir /etc/odoo
sudo cp /home/odoo/.odoorc /etc/odoo/odoo.conf
sudo chown -R odoo /etc/odoo

echo -e "\n---- Creamos un directorio donde el servicio de Odoo almacenará los archivos del log. ----"
sudo mkdir /var/log/odoo
sudo chown odoo /var/log/odoo

echo -e "\n---- Creamos el directorio para módulos personalizados----"
sudo mkdir /home/odoo/custom
sudo mkdir /home/odoo/custom/addons

echo -e "\n---- Editamos el archivo de configuración de OdooServer. ----"
sudo nano /etc/odoo/odoo.conf

echo -e "\n---- Buscamos el parámetro: logfile = None y lo modificamos con el siguiente valor: ----"

# logfile = /var/log/odoo/odoo-server.log

	
echo -e "\n---- Script de inicio automático de Odoo-Server: ---- "
sudo cp /home/odoo/odoo-11.0/debian/init /etc/init.d/odoo
sudo chmod +x /etc/init.d/odoo

echo -e "\n---- Creamos el siguiente enlace para ejecutar Odoo: ----"
sudo ln -s /home/odoo/odoo-11.0/odoo-bin /usr/bin/odoo
sudo chown -h odoo /usr/bin/odoo

echo -e "\n---- Hacemos que Odoo se inicie automáticamente cuando se reinicie nuestro servidor: ----"
sudo update-rc.d odoo defaults

echo -e "\n---- Iniciamos Odoo: ----"
sudo /etc/init.d/odoo start

echo "-----------------------------------------------------------"
echo "Listo! El servidor Odoo esta ariba y corriendo. Especificaciones:"
echo "Puerto: 8069"
echo "Usuario del servicio: ubuntu, inicie con sudo su - ubuntu"
echo "Directorio de Addons oficial: /home/odoo/11.0/addons/"
echo "Directorio para addons chilenos: /home/odoo/custom/addons/"
echo "Iniciar servicio Odoo: sudo /etc/init.d/odoo start"
echo "Detener el servicio Odoo: sudo /etc/init.d/odoo stop"
echo "Reiniciar Servicio Odoo: sudo /etc/init.d/odoo restart"
echo "Ingresamos a Odoo mediante un navegador web: http://IP_or_Dominio.com:8069"
echo "-----------------------------------------------------------"







