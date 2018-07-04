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
sudo apt-get install git -y
sudo apt-get install fontconfig -y
sudo chown -R odoo:odoo /home/*
sudo su root -c "printf 'UseDNS no\n' >> /etc/ssh/sshd_config"

echo -e "\n---- Creamos un usuario (odoo) para ejecutar Odoo Server ---"
sudo adduser --disabled-password --gecos "Odoo" odoo

echo -e "\n---- Instalando y configurando Postgresql ----"
sudo apt-get install postgresql postgresql-server-dev-9.5 -y

echo -e "\n---- Creamos un usuario en postgresql, para nuestro caso también llamaremos odoo ----"
sudo su -c "createuser -s odoo" postgres

echo -e "\n---- Instalamos las dependencias en python para Odoo. ----"
sudo apt-get install python3-pip python3-dev libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev libpq-dev libpng12-dev libjpeg-dev poppler-utils node-less node-clean-css -y

echo -e "\n---- Instalamos algunas librerías extras de python ----"
sudo wget https://raw.githubusercontent.com/odoo/odoo/11.0/requirements.txt
sudo -H pip3 install -r requirements.txt

echo -e "\n---- Descargando OdooServer  (114 Mb) aprox.: ----"
sudo su - odoo -c "git clone https://github.com/odoo/odoo.git /home/odoo/odoo-11.0 -b 11.0 --depth=1"
sudo su - odoo -c "/home/odoo/odoo-11.0/odoo-bin --save --stop-after-init"
echo -e "\n---- Salimos de la sesión del usuario (odoo) en la consola: ----"
#exit

echo -e "\n---- WKHTMLTOPDF ( Version 0.12.1 ) para Odoo ----"
sudo apt-get -f install
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
#echo -e "\n---- Ejecutamos el siguiente comando: ----"
#/home/odoo/odoo-11.0/odoo-bin
#echo -e "\n---- Presiona Ctrl+C ----"
#Veremos algo así, indicando que vamos nuestra instalación:
#2017-10-05 06:00:21,746 24073 INFO ? odoo: Odoo version 11.0
#2017-10-05 06:00:21,746 24073 INFO ? odoo: addons paths: ['/home/odoo/.local/share/Odoo/addons/11.0', '/home/odoo/odoo-11.0/odoo/addons', '/home/odoo/odoo-11.0/addons']
#2017-10-05 06:00:21,746 24073 INFO ? odoo: database: default@default:default
#2017-10-05 06:00:21,784 24073 INFO ? odoo.service.server: HTTP service (werkzeug) running on 0.0.0.0:8069
#2017-10-05 06:00:22,160 24073 INFO ? odoo.addons.base.ir.ir_actions_report: You need Wkhtmltopdf to print a pdf version of the reports.
#2017-10-05 06:02:27,649 24073 INFO ? odoo.http: HTTP Configuring static files
#2017-10-05 06:02:27,789 24073 INFO ? odoo.http: Generating nondb routing
#echo -e "\n---- Vamos a crear el archivo de configuración de Odoo: ----"
echo -e "\n---- Creamos el directorio para módulos personalizados----"
sudo mkdir /home/odoo/custom
sudo mkdir /home/odoo/custom/addons

echo -e "\n---- Por lo general los archivos de configuración están dentro de /etc por que vamos a mover el archivo de configuración de OdooServer a /etc: ----"
sudo mkdir /etc/odoo
#sudo cp /home/odoo/.odoorc /etc/odoo/odoo.conf
echo -e "*---- Hemos creado el Archivo Conf, ahora lo llenamos"
sudo chown -R odoo:odoo /home/*
sudo touch /etc/odoo/odoo.conf
sudo su root -c "printf '[options]\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'addons_path = /home/odoo/odoo-11.0/odoo/addons,/home/odoo/odoo-11.0/addons,/home/odoo/custom/addons\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'admin_passwd = admin\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'csv_internal_sep = ,\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'data_dir = /home/odoo/.local/share/Odoo\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_host = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_maxconn = 64\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_name = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_password = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_port = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_sslmode = prefer\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_template = template1\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'db_user = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'dbfilter =\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'demo = {}\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'email_from = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'geoip_database = /usr/share/GeoIP/GeoLite2-City.mmdb\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'http_enable = True\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'http_interface =\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'http_port = 8069\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'import_partial =\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'limit_memory_hard = 2684354560\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'limit_memory_soft = 2147483648\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'limit_request = 8192\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'limit_time_cpu = 60\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'limit_time_real = 120\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'limit_time_real_cron = -1\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'list_db = True\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'log_db = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'log_db_level = warning\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'log_handler = :INFO\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'log_level = info\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'logfile  = /var/log/odoo/odoo-server.log\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'logrotate = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'longpolling_port = 8072\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'max_cron_threads = 2\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'osv_memory_age_limit = 1.0\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'osv_memory_count_limit = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'pg_path = None\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'pidfile = None\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'proxy_mode = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'reportgz = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'server_wide_modules = web\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'smtp_password = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'smtp_port = 25\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'smtp_server = localhost\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'smtp_ssl = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'smtp_user = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'syslog = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'test_commit = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'test_enable = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'test_file = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'test_report_directory = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'translate_modules = ['all']\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'unaccent = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'without_demo = False\n' >> /etc/odoo/odoo.conf"
sudo su root -c "printf 'workers = 0\n' >> /etc/odoo/odoo.conf"
sudo chown odoo:odoo /etc/odoo/odoo.conf
sudo chmod 640 /etc/odoo/odoo.conf

#--------------------------------------------------
# Instalamos Dependencias usando pip3
#--------------------------------------------------

sudo su - odoo -c "pip3 install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycogreen psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd"

#--------------------------------------------------
# Para Facturación Electrónica Chilena se requiere las siguientes dependencias
#--------------------------------------------------

#sudo su - odoo -c "pip3 install xmltodict dicttoxml pdf417gen pyOpenSSL cchardet urllib3 SOAPpy pysftp num2words signxml" 
sudo su - odoo -c "pip3 install lxml"
sudo su - odoo -c "pip3 install feedparser"
sudo su - odoo -c "pip3 install geopy==0.95.1 BeautifulSoup pyOpenSSL suds"
sudo su - odoo -c "pip3 install urllib3"
sudo su - odoo -c "pip3 install fabric"
sudo su - odoo -c "pip3 install pymssql"
sudo su - odoo -c "pip3 install traceback2"
sudo su - odoo -c "pip3 install markupsafe"
sudo su - odoo -c "pip3 install pyinotify"
sudo su - odoo -c "pip3 install git+https://github.com/aeroo/aeroolib.git@master"
sudo su - odoo -c "pip3 install genshi==0.6.1 BeautifulSoup odfpy werkzeug==0.8.3 http pyPdf xlrd pycups erppeek"

sudo su - odoo -c "pip3 install M2Crypto pyopenssl"

sudo su root -c "pip3 install xmltodict dicttoxml pdf417gen cchardet pyOpenSSL signxml pysftp num2words SOAPpy urllib3"


#--------------------------------------------------
# Agregamos Módulos Chilenos
#--------------------------------------------------

echo -e "*Damos permiso a las carpetas "
cd /home/odoo/custom/
sudo chmod 777 addons
cd

echo -e "*Descargamos los modulos de Facturación Electrónica "
sudo git clone https://github.com/odoocoop/facturacion_electronica  
cd facturacion_electronica
sudo cp -r ~/facturacion_electronica/l10n_cl_dte_factoring /home/odoo/custom/addons
sudo cp -r ~/facturacion_electronica/l10n_cl_dte_point_of_sale /home/odoo/custom/addons
sudo cp -r ~/facturacion_electronica/l10n_cl_fe /home/odoo/custom/addons
sudo cp -r ~/facturacion_electronica/l10n_cl_stock_picking /home/odoo/custom/addons

cd

sudo chown -R daemon:daemon /home/odoo/custom/addons/l10n_cl_dte_factoring
sudo chown -R daemon:daemon /home/odoo/custom/addons/l10n_cl_dte_point_of_sale
sudo chown -R daemon:daemon /home/odoo/custom/addons/l10n_cl_fe
sudo chown -R daemon:daemon /home/odoo/custom/addons/l10n_cl_stock_picking

cd
echo -e "* Descargamos los Módulos de contabilidad"
sudo git clone https://github.com/KonosCL/addons-konos
cd addons-konos
sudo cp -r ~/addons-konos/l10n_cl_chart_of_account /home/odoo/custom/addons
sudo cp -r ~/addons-konos/l10n_cl_hr /home/odoo/custom/addons

cd
echo -e "* Descargamos el Módulo de localización Chile "
sudo chown -R daemon:daemon /home/odoo/custom/addons/l10n_cl_chart_of_account
sudo chown -R daemon:daemon /home/odoo/custom/addons/l10n_cl_hr

cd
echo -e "*Descargamos el tema de personalización "
sudo git clone https://github.com/Openworx/backend_theme
cd backend_theme
sudo cp -r ~/backend_theme/backend_theme_v11 /home/odoo/custom/addons
sudo chown -R daemon:daemon /home/odoo/custom/addons/backend_theme_v11

cd
echo -e "*Descargamos el modulo de vista responsiva "
sudo git clone https://github.com/OCA/web
cd web
sudo cp -r ~/web/web_responsive /home/odoo/custom/addons
sudo chown -R daemon:daemon /home/odoo/custom/addons/web_responsive

cd 
echo -e "*Descargamos el modulo de Reportes "
sudo git clone https://github.com/OCA/reporting-engine
cd reporting-engine
sudo cp -r ~/reporting-engine/report_xlsx /home/odoo/custom/addons
cd
echo -e "*Descargamos el modulo de conexión de base de datos externa "
sudo git clone https://github.com/OCA/server-backend
cd server-backend
sudo cp -r ~/server-backend/base_external_dbsource /home/odoo/custom/addons
cd

cd /odoo/custom
sudo chmod 755 addons/
cd


echo -e "\n---- Editamos el archivo de configuración de OdooServer. ----"
#sudo nano /etc/odoo/odoo.conf

echo -e "\n---- Buscamos el parámetro: logfile = None y lo modificamos con el siguiente valor: ----"

# logfile = /var/log/odoo/odoo-server.log
# addons_path = /home/odoo/odoo-11.0/odoo/addons,/home/odoo/odoo-11.0/addons,/home/odoo/custom/addons
	
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
sudo reboot

echo "-----------------------------------------------------------"
echo "Listo! El servidor Odoo esta arriba y corriendo. Especificaciones:"
echo "Puerto: 8069"
echo "Usuario del servicio: ubuntu, inicie con sudo su - ubuntu"
echo "Directorio de Addons oficial: /home/odoo/11.0/addons/"
echo "Directorio para addons chilenos: /home/odoo/custom/addons/"
echo "Iniciar servicio Odoo: sudo /etc/init.d/odoo start"
echo "Detener el servicio Odoo: sudo /etc/init.d/odoo stop"
echo "Reiniciar Servicio Odoo: sudo /etc/init.d/odoo restart"
echo "Ingresamos a Odoo mediante un navegador web: http://IP_or_Dominio.com:8069"
echo "-----------------------------------------------------------"
