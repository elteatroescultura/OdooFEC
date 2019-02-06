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
# sudo chmod +x instalar-odoo.sh
# Ejecute el archivo para instalar Odoo:
# ./instalar-odoo.sh
################################################################################

#--------------------------------------------------
# Actualizamos el Servidor
#--------------------------------------------------
echo -e "\n---- Actualizamos servidor e instalamos git ----"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install git -y
sudo apt-get install fontconfig -y
#sudo chown -R odoo:odoo /home/*
#sudo su root -c "printf 'UseDNS no\n' >> /etc/ssh/sshd_config"


##fixed parameters
#odoo
OE_USER="odoo"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
#The default port where this Odoo instance will run under (provided you use the command -c in the terminal)
#Set to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"
#Set the default Odoo port (you still have to use -c /etc/odoo-server.conf for example to use this.)
OE_PORT="8069"
#Choose the Odoo version which you want to install. For example: 11.0, 10.0, 9.0 or saas-18. When using 'master' the master version will be installed.
#IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 11.0
OE_VERSION="11.0"
# Set this to True if you want to install Odoo 11 Enterprise!
IS_ENTERPRISE="False"
#set the superadmin password
OE_SUPERADMIN="admin"
OE_CONFIG="${OE_USER}-server"

##
###  WKHTMLTOPDF download links
## === Ubuntu Trusty x64 & x32 === (for other distributions please replace these two links,
## in order to have correct version of wkhtmltox installed, for a danger note refer to 
## https://www.odoo.com/documentation/8.0/setup/install.html#deb ):
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'
sudo apt-get install postgresql-11 -y


echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n--- Installing Python 3 + pip3 --"
sudo apt-get install python3 python3-pip

echo -e "\n---- Install tool packages ----"
sudo apt-get install wget git bzr python-pip gdebi-core -y

echo -e "\n---- Install python packages ----"
sudo apt-get install python-pypdf2 python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil -y
sudo pip3 install pypdf2 Babel passlib Werkzeug decorator python-dateutil pyyaml psycopg2 psutil html2text docutils lxml pillow reportlab ninja2 requests gdata XlsxWriter vobject python-openid pyparsing pydot mock mako Jinja2 ebaysdk feedparser xlwt psycogreen suds-jurko pytz pyusb greenlet xlrd 

echo -e "\n---- Install python libraries ----"
# This is for compatibility with Ubuntu 16.04. Will work on 14.04, 15.04 and 16.04
sudo apt-get install python3-suds

echo -e "\n--- Install other required packages"
sudo apt-get install node-clean-css -y
sudo apt-get install node-less -y
sudo apt-get install python-gevent -y

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 11 ----"
  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" == "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url
  sudo gdebi --n `basename $_url`
  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
fi

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER


#echo -e "\n---- Vamos a crear el archivo de configuración de Odoo: ----"
echo -e "\n---- Creamos el directorio para módulos personalizados----"
sudo mkdir /home/odoo/custom
sudo mkdir /home/odoo/custom/addons



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



#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/odoo $OE_HOME_EXT/

if [ $IS_ENTERPRISE = "True" ]; then
    # Odoo Enterprise install!
    echo -e "\n--- Create symlink for node"
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo su $OE_USER -c "mkdir $OE_HOME/enterprise"
    sudo su $OE_USER -c "mkdir $OE_HOME/enterprise/addons"

    GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/enterprise "$OE_HOME/enterprise/addons" 2>&1)
    while [[ $GITHUB_RESPONSE == *"Authentication"* ]]; do
        echo "------------------------WARNING------------------------------"
        echo "Your authentication with Github has failed! Please try again."
        printf "In order to clone and install the Odoo enterprise version you \nneed to be an offical Odoo partner and you need access to\nhttp://github.com/odoo/enterprise.\n"
        echo "TIP: Press ctrl+c to stop this script."
        echo "-------------------------------------------------------------"
        echo " "
        GITHUB_RESPONSE=$(sudo git clone --depth 1 --branch $OE_VERSION https://www.github.com/odoo/enterprise "$OE_HOME/enterprise/addons" 2>&1)
    done

    echo -e "\n---- Added Enterprise code under $OE_HOME/enterprise/addons ----"
    echo -e "\n---- Installing Enterprise specific libraries ----"
    sudo pip3 install num2words ofxparse
    sudo apt-get install nodejs npm
    sudo npm install -g less
    sudo npm install -g less-plugin-clean-css
fi

echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Create server config file"

sudo touch /etc/${OE_CONFIG}.conf
echo -e "* Creating server config file"
sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'admin_passwd = ${OE_SUPERADMIN}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'xmlrpc_port = ${OE_PORT}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'logfile = /var/log/${OE_USER}/${OE_CONFIG}.log\n' >> /etc/${OE_CONFIG}.conf"
if [ $IS_ENTERPRISE = "True" ]; then
    sudo su root -c "printf 'addons_path=${OE_HOME}/enterprise/addons,${OE_HOME_EXT}/addons\n' >> /etc/${OE_CONFIG}.conf"
else
    sudo su root -c "printf 'addons_path=${OE_HOME_EXT}/addons,${OE_HOME}/custom/addons\n' >> /etc/${OE_CONFIG}.conf"
fi
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
cat <<EOF > ~/$OE_CONFIG
#!/bin/sh
### BEGIN INIT INFO
# Provides: $OE_CONFIG
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Should-Start: \$network
# Should-Stop: \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Enterprise Business Applications
# Description: ODOO Business Applications
### END INIT INFO
PATH=/bin:/sbin:/usr/bin
DAEMON=$OE_HOME_EXT/odoo-bin
NAME=$OE_CONFIG
DESC=$OE_CONFIG
# Specify the user name (Default: odoo).
USER=$OE_USER
# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="/etc/${OE_CONFIG}.conf"
# pidfile
PIDFILE=/var/run/\${NAME}.pid
# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"
[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0
checkpid() {
[ -f \$PIDFILE ] || return 1
pid=\`cat \$PIDFILE\`
[ -d /proc/\$pid ] && return 0
return 1
}
case "\${1}" in
start)
echo -n "Starting \${DESC}: "
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
stop)
echo -n "Stopping \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
echo "\${NAME}."
;;
restart|force-reload)
echo -n "Restarting \${DESC}: "
start-stop-daemon --stop --quiet --pidfile \$PIDFILE \
--oknodo
sleep 1
start-stop-daemon --start --quiet --pidfile \$PIDFILE \
--chuid \$USER --background --make-pidfile \
--exec \$DAEMON -- \$DAEMON_OPTS
echo "\${NAME}."
;;
*)
N=/etc/init.d/\$NAME
echo "Usage: \$NAME {start|stop|restart|force-reload}" >&2
exit 1
;;
esac
exit 0
EOF

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults

echo -e "* Starting Odoo Service"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Addons folder: $OE_USER/$OE_CONFIG/addons/"
echo "Start Odoo service: sudo service $OE_CONFIG start"
echo "Stop Odoo service: sudo service $OE_CONFIG stop"
echo "Restart Odoo service: sudo service $OE_CONFIG restart"
echo "-----------------------------------------------------------"











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
sudo su root -c "printf 'http_port = 8068\n' >> /etc/odoo/odoo.conf"
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
# sudo reboot

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
