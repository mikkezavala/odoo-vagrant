#!/usr/bin/env bash

###############################################################
# Brought to you from your friendly and obnoxious non friend: #
# Mikke Zavala (github: mikkezavala).						  #
###############################################################

ODOO_VERSION=11.0
ODOO_RELEASE=20171021

# You can change this to your HOME if that is the case
MOUNT_DIR=/vagrant
PROVISION_DIR=${MOUNT_DIR}/provision
CONFIG_FILE=${MOUNT_DIR}/config/odoo.conf

DB_USER=odoo
DB_PASSWORD=odoo
# update / upgrade
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y yum-utils postgresql-server

# Install ODOO Dependencies
sudo yum install -y python3-pydot python3-pyldap python3-pyparsing \
        python3-vatnumber python3-vobject python3-werkzeug python3-xlrd python3-xlwt \
        python3-pytz python3-pyusb python3-qrcode python3-reportlab	python3-stdnum python3-suds \
        python3-mako python3-mock python3-num2words python3-ofxparse python3-passlib python3-psycopg2 \
        babel libxslt-python nodejs-less pychart pyparsing python3-PyPDF2 python3-babel python3-decorator \
        python3-docutils python3-feedparser python3-gevent python3-greenlet python3-html2text python3-lxml

# Install RPM & Install Package
printf "Instaling ODOO RPM v${ODOO_VERSION} with release ${ODOO_RELEASE} this could take some time.";
sudo rpm -Uhv https://nightly.odoo.com/${ODOO_VERSION}/nightly/rpm/odoo_${ODOO_VERSION}.${ODOO_RELEASE}.noarch.rpm

# DataBase Setup
sudo postgresql-setup initdb
sudo systemctl enable postgresql && sudo systemctl start postgresql

# Using default ODOO Pass otherwise verify your config
sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH password '${DB_PASSWORD}';"
sudo -u postgres psql -c "ALTER USER ${DB_USER} WITH SUPERUSER;"

# Remove pre-defined config and run custom one delete if exists)
sudo rm /etc/odoo/odoo.conf \
    && sudo rm -f ${CONFIG_FILE} \
    && sudo cp ${PROVISION_DIR}/odoo.conf.template ${CONFIG_FILE}

# Replace placeholders and Symlink-it to odoo def
sudo sed -i "s|__HOME__|$MOUNT_DIR|g" ${CONFIG_FILE} && sudo ln -s ${CONFIG_FILE} /etc/odoo/odoo.conf

# Run this baby...!
sudo systemctl enable odoo && sudo systemctl restart odoo
