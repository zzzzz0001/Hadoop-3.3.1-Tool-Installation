#!/bin/bash

#Hive Version 3.1.2

#CHECKING IF YOU WANT TO ACTUALLY RUN IT OR NOT
#-------------------------------------------------
while true
do
    echo "Want to run this executable? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        echo "CONTINUING..."
        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "STOPPING THE EXECUTABLE..."
        exit 0

    else
        echo "Retry again"
    fi
done
#-------------------------------------------------


#UPDATE AND UPGRADE
#-----------------------------------
username=$(whoami)

while true
do
    echo "Want to update and upgrade (recommended)? ((y)es / (n)o) NOTE: current user is $username"
	read answer

    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        while true; do
            if sudo apt update; then
                echo "UPDATED"
                break
            fi
            echo "FAILED UPDATE, RETRYING"
        done
            
        while true; do
            if sudo apt upgrade; then
                echo "UPGRADED"
                break
            fi
            echo "FAILED UPGRADE, RETRYING"
        done
            break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "Skipping update and upgrade of apt."
        break

    else
        echo "Retry again"
    fi
done
#-----------------------------------


#GOING TO DEFAULT LOCATION
#-------------------------
cd /home/$username/
#-------------------------

#INSTALLING JAVA
#------------------------------
while true
do
    echo "Want to install java? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        sudo apt -y install openjdk-8-jdk
        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "SKIPPING..."
        break

    else
        echo "Retry again"
    fi
done
#------------------------------

#CHOOSING USER
#-------------------------------------------------
username=$(whoami)       #putting current username in a variable

while true
do
    echo "Continue with the current user $username? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        echo "CONTINUING..."
        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "Choose the username you would like to use from the below options available"
        users
        users_array=($(users))  #this puts all users into an array
        
        read answer

        user_exist=0
        for user in "${users_array[@]}"; do
            if [ "$user" == "$answer" ]; then
                user_exist=1
                username="$user"
            fi
        done

        if [ $user_exist == 0 ]; then
            echo "User does not exist, aborting..."
            exit 0
        fi
        

    else
        echo "Retry again"
    fi
done
#-------------------------------------------------

hive_version='3.1.2'
hive_foldername="hive-$hive_version"

#DOWNLOADING HIVE FROM https://dlcdn.apache.org/hive/ go into https://dlcdn.apache.org/hive/hive-3.1.2/ and extract to ~
#-----------------------------------------------------------------
cd /home/$username/Downloads
if [ $(find -maxdepth 1 | grep apache-$hive_foldername-bin.tar.gz) ]; then
    sudo rm apache-$hive_foldername-bin.tar.gz
    echo "COPY OF HIVE.TAR.GZ DELETED. CONTINUING"
else
    echo "HIVE.TAR.GZ FILE NOT FOUND TO DELETE. CONTINUING"
fi
cd /home/$username/

wget -P /home/$username/Downloads wget https://dlcdn.apache.org/hive/$hive_foldername/apache-$hive_foldername-bin.tar.gz

tar -zxvf /home/$username/Downloads/apache-$hive_foldername-bin.tar.gz
mv apache-$hive_foldername-bin $hive_foldername
#-----------------------------------------------------------------

#EDITING .bashrc FILE
#-------------------------------------------------------------
file1=".bashrc"

# JAVA HOME SETUP :
line1="export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64"

if grep -q "$line1" "$file1"; then
    echo SKIPPING ADDING OF JAVA_HOME again

else
    echo "ADDING JAVA_HOME LINE TO BASHRC"
    echo "$line1" >> "$file1"

fi

# HIVE HOME SETUP :
line2="export HIVE_HOME=/home/$username/$hive_foldername"
line3="export PATH=\$PATH:/home/$username/$hive_foldername/bin"
echo "$line2
$line3" >> "$file1"

#-------------------------------------------------------------

#STARTING HADOOP SERVICES
#-------------------------------------------------------------
start-dfs.sh
#-------------------------------------------------------------


#HIVE-SITE.XML - PART 1
#-------------------------------------------------------------
cd /home/$username/$hive_foldername/conf
touch hive-site.xml

file2="hive-site.xml"

line4="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?><!--
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the \"License\"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an \"AS IS\" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--><configuration>



  <!-- Hive Execution Parameters -->



  <property>
    <name>hive.execution.engine</name>
    <value>spark</value>
    <description>Execution engine for Hive queries</description>
  </property>

  <property>
    <name>spark.master</name>
    <value>spark://localhost:4040</value>
    <description>Spark master URL</description>
  </property>

  <property>
    <name>spark.submit.deployMode</name>
    <value>cluster</value>
    <description>Deploy mode for Spark applications</description>
  </property>

  <property>
    <name>hive.hadoop.configured.resources</name>
    <value>/home/$username/hadoop-3.3.1/etc/hadoop/core-site.xml,/home/$username/hadoop-3.3.1/etc/hadoop/hdfs-site.xml</value>
    <description>Comma-separated list of Hadoop configuration files</description>
  </property>

  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/user/hive/warehouse</value>
    <description>location of default database for the warehouse</description>
  </property>"




echo "$line4" >> "$file2"
#-------------------------------------------------------------


#HIVE-SITE.XML - PART 2
#-------------------------------------------------------------
while true
do
    echo "Database to be used for Hive Metastore"
    echo "1. Derby (inbuilt tool)"
    echo "2. PostgreSQL"
	read answer
    if [ "$answer" == "1" ]; then
        echo "1st Option Chosen, Continuing with Derby...."

        #CONFIGURE HIVE-SITE.XML
        #---------------------------------------------------------
        line5="  <property>
            <name>hive.metastore.db.type</name>
            <value>DERBY</value>
            <description>
              Expects one of [derby, oracle, mysql, mssql, postgres].
              Type of database used by the metastore. Information schema JDBCStorageHandler depend on it.
            </description>
          </property>
        
          <property>
            <name>javax.jdo.option.ConnectionURL</name>
            <value>jdbc:derby:;databaseName=/home/$username/$hive_foldername/metastore_db;create=true</value>
            <description>JDBC connection URL for the embedded Derby metastore database</description>
          </property>
        
          <property>
            <name>derby.stream.error.file</name>
            <value>/home/$username/$hive_foldername/derby.log</value>
            <description>Error log file default location</description>
          </property>
        
        </configuration>"

        echo "$line5" >> "$file2"
        #---------------------------------------------------------

        cd /home/$username/$hive_foldername
        bin/schematool -dbType derby -initSchema

        break

    #https://docs.ezmeral.hpe.com/datafabric-customer-managed/72/Hive/config-remote-postgres-db-hive-metastore.html#:~:text=Before%20you%20can%20run%20the,account%20for%20the%20Hive%20user.
    #https://cwiki.apache.org/confluence/display/Hive/AdminManual+Metastore+3.0+Administration#AdminManualMetastore3.0Administration-LessCommonlyChangedConfigurationParameters
    elif [ "$answer" == "2" ]; then
        echo "2nd Option Chosen, Continuing with PostgreSQL...."

        #DOWNLOADING JDBC OF POSTGRESQL FROM https://jdbc.postgresql.org/download/ go into https://jdbc.postgresql.org/download/postgresql-42.6.0.jar and extract to ~
        #-----------------------------------------------------------------
        cd /home/$username/Downloads
        if [ $(find -maxdepth 1 | grep postgresql-42.6.0.jar) ]; then
            sudo rm postgresql-42.6.0.jar
            echo "COPY OF POSTGRESQL JDBC DELETED. CONTINUING"
        else
            echo "POSTGRESQL JDBC FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        cd /home/$username/

        wget -P /home/$username/Downloads wget https://jdbc.postgresql.org/download/postgresql-42.6.0.jar

        sudo mv /home/$username//Downloads/postgresql-42.6.0.jar /home/$username/$hive_foldername/lib/postgresql-jdbc.jar
        sudo chmod 644 /home/$username/$hive_foldername/lib/postgresql-jdbc.jar
        #-----------------------------------------------------------------

        #DOWNLOADING POSTGRESQL AND CONFIGURE
        #------------------------------------------------------------------------
        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

        while true; do
            if sudo apt-get update; then
                echo "UPDATED"
                break
            fi
            echo "FAILED UPDATE, RETRYING"
        done

        echo "Postgresql version = (please use integer number like 13, 14)"
        read postgresql_version

        while true; do
            if sudo apt-get -y install postgresql-$postgresql_version; then
                echo "POSTGRES INSTALLED"
                break
            fi
        done
        

        echo "Password of Postgres User (ADMINISTRATOR) : "
        read postgres_password
        echo "Password of Hive User (ADMINISTRATOR) : "
        read postgres_hive_password 

        cd /home/$username/Downloads
        
sudo -iu postgres psql <<EOF
alter role postgres with password '$postgres_password';
create user hiveuser with password '$postgres_hive_password' login;
alter user hiveuser createdb;
create database metastore owner hiveuser;
EOF

echo "Created database metastore"

        cd /etc/postgresql/$postgresql_version/main
        sudo chmod o+rw pg_hba.conf         #making sure that we can easily echo into the file

        file3="pg_hba.conf"

        line5="# PostgreSQL Client Authentication Configuration File
        # ===================================================
        #
        # Refer to the \"Client Authentication\" section in the PostgreSQL
        # documentation for a complete description of this file.  A short
        # synopsis follows.
        #
        # This file controls: which hosts are allowed to connect, how clients
        # are authenticated, which PostgreSQL user names they can use, which
        # databases they can access.  Records take one of these forms:
        #
        # local         DATABASE  USER  METHOD  [OPTIONS]
        # host          DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
        # hostssl       DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
        # hostnossl     DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
        # hostgssenc    DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
        # hostnogssenc  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
        #
        # (The uppercase items must be replaced by actual values.)
        #
        # The first field is the connection type:
        # - \"local\" is a Unix-domain socket
        # - \"host\" is a TCP/IP socket (encrypted or not)
        # - \"hostssl\" is a TCP/IP socket that is SSL-encrypted
        # - \"hostnossl\" is a TCP/IP socket that is not SSL-encrypted
        # - \"hostgssenc\" is a TCP/IP socket that is GSSAPI-encrypted
        # - \"hostnogssenc\" is a TCP/IP socket that is not GSSAPI-encrypted
        #
        # DATABASE can be \"all\", \"sameuser\", \"samerole\", \"replication\", a
        # database name, or a comma-separated list thereof. The \"all\"
        # keyword does not match \"replication\". Access to replication
        # must be enabled in a separate record (see example below).
        #
        # USER can be \"all\", a user name, a group name prefixed with \"+\", or a
        # comma-separated list thereof.  In both the DATABASE and USER fields
        # you can also write a file name prefixed with \"@\" to include names
        # from a separate file.
        #
        # ADDRESS specifies the set of hosts the record matches.  It can be a
        # host name, or it is made up of an IP address and a CIDR mask that is
        # an integer (between 0 and 32 (IPv4) or 128 (IPv6) inclusive) that
        # specifies the number of significant bits in the mask.  A host name
        # that starts with a dot (.) matches a suffix of the actual host name.
        # Alternatively, you can write an IP address and netmask in separate
        # columns to specify the set of hosts.  Instead of a CIDR-address, you
        # can write \"samehost\" to match any of the server''s own IP addresses,
        # or \"samenet\" to match any address in any subnet that the server is
        # directly connected to.
        #
        # METHOD can be \"trust\", \"reject\", \"md5\", \"password\", \"scram-sha-256\",
        # \"gss\", \"sspi\", \"ident\", \"peer\", \"pam\", \"ldap\", \"radius\" or \"cert\".
        # Note that \"password\" sends passwords in clear text; \"md5\" or
        # \"scram-sha-256\" are preferred since they send encrypted passwords.
        #
        # OPTIONS are a set of options for the authentication in the format
        # NAME=VALUE.  The available options depend on the different
        # authentication methods -- refer to the \"Client Authentication\"
        # section in the documentation for a list of which options are
        # available for which authentication methods.
        #
        # Database and user names containing spaces, commas, quotes and other
        # special characters must be quoted.  Quoting one of the keywords
        # \"all\", \"sameuser\", \"samerole\" or \"replication\" makes the name lose
        # its special character, and just match a database or username with
        # that name.
        #
        # This file is read on server startup and when the server receives a
        # SIGHUP signal.  If you edit the file on a running system, you have to
        # SIGHUP the server for the changes to take effect, run \"pg_ctl reload\",
        # or execute \"SELECT pg_reload_conf()\".
        #
        # Put your actual configuration here
        # ----------------------------------
        #
        # If you want to allow non-local connections, you need to add more
        # \"host\" records.  In that case you will also need to make PostgreSQL
        # listen on a non-local interface via the listen_addresses
        # configuration parameter, or via the -i or -h command line switches.
        
        
        
        
        # DO NOT DISABLE!
        # If you change this first entry you will need to make sure that the
        # database superuser can access the database using some other method.
        # Noninteractive access to all databases is required during automatic
        # maintenance (custom daily cronjobs, replication, and similar tasks).
        #
        # Database administrative login by Unix domain socket
        #local   all             postgres                                peer
        
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        
        # \"local\" is for Unix domain socket connections only
        local   all             all                                     scram-sha-256
        # IPv4 local connections:
        host    metastore       hiveuser        127.0.0.1/32            trust
        host    all             all             127.0.0.1/32            scram-sha-256
        # IPv6 local connections:
        host    all             all             ::1/128                 scram-sha-256
        # Allow replication connections from localhost, by a user with the
        # replication privilege.
        local   replication     all                                     scram-sha-256
        host    replication     all             127.0.0.1/32            scram-sha-256
        host    replication     all             ::1/128                 scram-sha-256"


        echo "$line5" > "$file3"

        sudo chmod o-rw pg_hba.conf

        sudo systemctl restart postgresql

        cd /home/$username/Desktop
        touch POSTGRESQL_DATABASE_ROLE.txt
echo "# USERS                                PASSWORD
--------------------------------------------------------------------------
  postgres                             $postgres_password
  hiveuser                             $postgres_hive_password" > "POSTGRESQL_DATABASE_ROLE.txt"

echo 'YOUR DATABASE ROLES AND ITS PASSWORDS HAVE BEEN SAVED TO FILE "POSTGRESQL_DATABASE_ROLE.txt" IN DESKTOP OF THE USER YOU HAVE SELECTED.'

        touch logs_of_hive.txt
        echo "Logs of hive can be found in location /tmp/$username/hive.log" > "logs_of_hive.txt"
        #------------------------------------------------------------------------

        #CONFIGURE HIVE-SITE.XML
        #---------------------------------------------------------
        cd /home/$username/$hive_foldername/conf

        line6="  <property>
        <name>hive.metastore.db.type</name>
        <value>postgres</value>
        <description>
            Expects one of [derby, oracle, mysql, mssql, postgres].
            Type of database used by the metastore. Information schema JDBCStorageHandler depend on it.
        </description>
        </property>
        
        <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://localhost:5432/metastore</value>
        <description>JDBC connection URL for the embedded Derby metastore database</description>
        </property>
        
        <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
        <description>Driver name to be used for connecting</description>
        </property>
        
        <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>hiveuser</value>
        <description>Role name of postgres to log in</description>
        </property>
        
        <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>$postgres_hive_password</value>
        <description>Password of role while creating the user</description>
        </property>
        
        <property>
        <name>datanucleus.schema.autoCreateAll</name>
        <value>false</value>
        <description>
        Auto creates the necessary schema in the RDBMS at startup if one does not exist.
        Set this to false (default value) after creating it once.
        To enable auto create also set metastore.schema.verification = false.
        Auto creation is not recommended in production; run schematool instead.
        </description>
        </property>

        <property>
        <name>metastore.schema.verification</name>
        <value>true</value>
        <description>
        Enforce metastore schema version consistency. When set to true: verify that version
        informatoin stored in rthe RDBMS is compatible with the version of the Metastore jar.
        Also diable automatic schema migration. Users are required to manually migrate the
        schema after upgrade, which ensures proper schema migration. This setting is strongly
        recommended in production. When set to false: warn if the version information stored
        in RDBMS doesn't match the version of the Metastore jar and allow auto schema migration.
        </description>
        </property>

        </configuration>"

        echo "$line6" >> "$file2"
        #---------------------------------------------------------

        cd /home/$username/$hive_foldername
        bin/schematool -dbType postgres -initSchema
        bin/schematool -validate -dbType postgres

        break      

    else
        echo "Retry again"
    fi
done
#-------------------------------------------------------------




#CLEANUP
#-------------------------------------------------
# $installation_method contain which option we went for installation, so do the cleanup accordingly

while true
do
    echo "Want to cleanup? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        sudo rm /home/$username/Downloads/apache-$hive_foldername-bin.tar.gz
        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "SKIPPING CLEANUP..."
		break
        
    else
        echo "Retry again"
    fi
done
#-------------------------------------------------


#RESTART THE OS
#-----------------------------------
while true
do
    echo "Want to restart (recommended to restart, if not then restart it yourself before starting up the hive services)? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        sudo reboot
        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "SKIPPING RESTART..."
		break
        
    else
        echo "Retry again"
    fi
done
#-----------------------------------
