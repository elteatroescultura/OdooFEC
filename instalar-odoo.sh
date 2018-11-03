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

##Parámetros por defecto
#odoo
OE_USER="odoo"
OE_HOME="/$OE_USER"
OE_HOME_EXT="/$OE_USER/${OE_USER}-server"
INSTALL_WKHTMLTOPDF="True"
OE_PORT="8069"
OE_SUPERADMIN="magno"
OE_CONFIG="${OE_USER}-server"


#
###  WKHTMLTOPDF necesario para crear presupuestos y generar cualquier archivo pdf
## === Opciones Ubuntu Trusty x64 & x32 === 
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb

#--------------------------------------------------
# Actualizamos el Servidor
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install git

#--------------------------------------------------
#Instalamos algunos archivos necesarios
#--------------------------------------------------
sudo apt-get install python-pip python-dev build-essential libpq-dev poppler-utils antiword libldap2-dev libsasl2-dev libssl-dev git python-dateutil python-feedparser python-gdata python-ldap python-lxml python-mako python-openid python-psycopg2 python-pychart python-pydot python-pyparsing python-reportlab python-tz python-vatnumber python-vobject python-webdav python-xlwt python-yaml python-zsi python-docutils wget python-unittest2 python-mock python-jinja2 libevent-dev bzr subversion python-svn libxslt1-dev libfreetype6-dev libjpeg8-dev python-werkzeug wkhtmltopdf libjpeg-dev nginx libcups2-dev postgresql libffi-dev
sudo apt-get install python3-pip
sudo apt-get install python3-dev python3-cffi libxml2-dev libxslt1-dev libssl-dev python3-lxml python3-cryptography python3-openssl python3-certifi python3-defusedxml

#--------------------------------------------------
# Instalamos Dependencias usando pip3
#--------------------------------------------------

pip3 install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycogreen psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd

#--------------------------------------------------
# Para Facturación Electrónica Chilena se requiere las siguientes dependencias
#--------------------------------------------------

pip3 install --user xmltodict dicttoxml pdf417gen pyOpenSSL cchardet urllib3 SOAPpy pysftp num2words signxml 
pip install lxml
pip install feedparser
pip install geopy==0.95.1 BeautifulSoup pyOpenSSL suds
pip install urllib3
pip install fabric
pip install pymssql
pip install traceback2
pip install markupsafe
pip install pyinotify
pip install git+https://github.com/aeroo/aeroolib.git@master
pip install genshi==0.6.1 BeautifulSoup odfpy werkzeug==0.8.3 http pyPdf xlrd pycups erppeek

pip install M2Crypto pyopenssl


#--------------------------------------------------
# Instalamos dependencia Wwe
#--------------------------------------------------

sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less less-plugin-clean-css
sudo apt-get install node-less


#--------------------------------------------------
# Instalamos PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Instalamos PostgreSQL Server ----"
sudo apt-get install postgresql -y

echo -e "\n---- Creamos el usuario ODOO PostgreSQL  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

echo -e "\n---- Instalamos paquetes python ----"
sudo apt-get install python-pypdf2 python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil -y
sudo pip3 install pypdf2 Babel passlib Werkzeug decorator python-dateutil pyyaml psycopg2 psutil html2text docutils lxml pillow reportlab ninja2 requests gdata XlsxWriter vobject python-openid pyparsing pydot mock mako Jinja2 ebaysdk feedparser xlwt psycogreen suds-jurko pytz pyusb greenlet xlrd 

#--------------------------------------------------
# Instalamos Wkhmltopdf
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Instala wkhtml y coloca los acceso directos en los lugares correctos for ODOO 11 ----"
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
  echo "Wkhtmltopdf no se instaló porque así lo ordeno el usuario!"
fi

echo -e "\n---- Creamos usuario de sistema ODOO ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Creamos directorio para los Logs ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

# ---------------------------------------------------
# Creamos un usuario para la base de datos Odoo
#----------------------------------------------------
sudo su postgres
cd
createuser -s odoo
createuser -s ubuntu_user_name
exit

# ---------------------------------------------------
# Creaamos el usuario Odoo y el grupo
#----------------------------------------------------
sudo adduser --system --home=/opt/odoo --group odoo

#----------------------------------------------------
# Instalamos Gdata
#----------------------------------------------------
cd /opt/odoo
sudo wget https://pypi.python.org/packages/a8/70/bd554151443fe9e89d9a934a7891aaffc63b9cb5c7d608972919a002c03c/gdata-2.0.18.tar.gz
sudo tar zxvf gdata-2.0.18.tar.gz
sudo chown -R odoo: gdata-2.0.18
sudo -s
cd gdata-2.0.18/
python setup.py install
exit


#--------------------------------------------------
# Instalamos ODOO
#--------------------------------------------------
echo -e "\n==== Instalamos la versión más resciente de ODOO Server ===="
sudo su - odoo
git clone https://github.com/odoo/odoo.git /home/odoo/odoo-11.0 -b 11.0 --depth=1

echo -e "\n---- Creamos el directorio para módulos personalizados----"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

echo -e "\n---- configuramos los permisos de la carpeta ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Creamos el archivo config del servidor"

sudo touch /etc/${OE_CONFIG}.conf
echo -e "* Creando el archivo de configuración"
sudo su root -c "printf '[options] \n; Esta es la contraseña que permite operar la base de datos:\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'admin_passwd = ${OE_SUPERADMIN}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'xmlrpc_port = ${OE_PORT}\n' >> /etc/${OE_CONFIG}.conf"
sudo su root -c "printf 'addons_path=${OE_HOME_EXT}/addons,${OE_HOME}/custom/addons\n' >> /etc/${OE_CONFIG}.conf"
sudo chown $OE_USER:$OE_USER /etc/${OE_CONFIG}.conf
sudo chmod 640 /etc/${OE_CONFIG}.conf

echo -e "* Creamos el archivo de arranque"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/openerp-server --config=/etc/${OE_CONFIG}.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

#--------------------------------------------------
# Agregamos Módulos Chilenos
#--------------------------------------------------

echo -e "*Damos permiso a las carpetas "
cd /odoo/custom/
sudo chmod 777 addons
cd

echo -e "*Descargamos los modulos de Facturación Electrónica "
git clone https://github.com/odoocoop/facturacion_electronica  
cd facturacion_electronica
sudo cp -r ~/facturacion_electronica/l10n_cl_dte_factoring /odoo/custom/addons
sudo cp -r ~/facturacion_electronica/l10n_cl_dte_point_of_sale /odoo/custom/addons
sudo cp -r ~/facturacion_electronica/l10n_cl_fe /odoo/custom/addons
sudo cp -r ~/facturacion_electronica/l10n_cl_stock_picking /odoo/custom/addons

cd

sudo chown -R daemon:daemon /odoo/custom/addons/l10n_cl_dte_factoring
sudo chown -R daemon:daemon /odoo/custom/addons/l10n_cl_dte_point_of_sale
sudo chown -R daemon:daemon /odoo/custom/addons/l10n_cl_fe
sudo chown -R daemon:daemon /odoo/custom/addons/l10n_cl_stock_picking

cd
echo -e "* Descargamos los Módulos de contabilidad"
git clone https://github.com/KonosCL/addons-konos
cd addons-konos
sudo cp -r ~/addons-konos/l10n_cl_chart_of_account /odoo/custom/addons
sudo cp -r ~/addons-konos/l10n_cl_hr /odoo/custom/addons

cd
echo -e "* Descargamos el Módulo de localización Chile "
sudo chown -R daemon:daemon /odoo/custom/addons/l10n_cl_chart_of_account
sudo chown -R daemon:daemon /odoo/custom/addons/l10n_cl_hr

cd
echo -e "*Descargamos el tema de personalización "
git clone https://github.com/Openworx/backend_theme
cd backend_theme
sudo cp -r ~/backend_theme/backend_theme_v11 /odoo/custom/addons
sudo chown -R daemon:daemon /odoo/custom/addons/backend_theme_v11

cd
echo -e "*Descargamos el modulo de vista responsiva "
git clone https://github.com/OCA/web
cd web
sudo cp -r ~/web/web_responsive /odoo/custom/addons
sudo chown -R daemon:daemon /odoo/custom/addons/web_responsive

cd 
echo -e "*Descargamos el modulo de Reportes "
git clone https://github.com/OCA/reporting-engine
cd reporting-engine
sudo cp -r ~/reporting-engine/report_xlsx /odoo/custom/addons

cd /odoo/custom
sudo chmod 755 addons/
cd

#--------------------------------------------------
# Agregando ODOO como un deamon (initscript)
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

echo -e "* Inicio del archivo de seguridad"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "* Agregar Odoo al inicio"
sudo update-rc.d $OE_CONFIG defaults

echo -e "* iniciando los servicios Odoo"
sudo su root -c "/etc/init.d/$OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Listo! El servidor Odoo esta ariba y corriendo. Especificaciones:"
echo "Puerto: $OE_PORT"
echo "Usuario del servicio: $OE_USER"
echo "Usuario PostgreSQL: $OE_USER"
echo "Codifo de localización: $OE_USER"
echo "Directorio de Addons oficial: $OE_USER/$OE_CONFIG/addons/"
echo "Directorio para addons chilenos: $OE_USER/custom/addons/"
echo "Iniciar servicio Odoo: sudo service $OE_CONFIG start"
echo "Detener el servicio Odoo: sudo service $OE_CONFIG stop"
echo "Reiniciar Servicio Odoo: sudo service $OE_CONFIG restart"
echo "-----------------------------------------------------------"


