#!/bin/bash

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
    echo "Want to install java-8 (recommended)? ((y)es / (n)o)"
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

hadoop_version='3.3.1'
hadoop_foldername="hadoop-$hadoop_version"

#DOWNLOADING HADOOP FROM https://hadoop.apache.org/releases.html and extract to ~
#-----------------------------------------------------------------


cd /home/$username/Downloads
if [ $(find -maxdepth 1 | grep $hadoop_foldername.tar.gz) ]; then
    sudo rm $hadoop_foldername.tar.gz
    echo "COPY OF HADOOP.TAR.GZ DELETED. CONTINUING"
else
    echo "HADOOP.TAR.GZ FILE NOT FOUND TO DELETE. CONTINUING"
fi
cd /home/$username/Downloads

wget https://dlcdn.apache.org/hadoop/common/$hadoop_foldername/$hadoop_foldername.tar.gz

cd /home/$username/

tar -zxvf /home/$username/Downloads/$hadoop_foldername.tar.gz
#-----------------------------------------------------------------



#EDITING .bashrc FILE
#-------------------------------------------------------------
file1=".bashrc"

# JAVA HOME SETUP :
line1="export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64"

# HADOOP HOME SETUP :
line2="export HADOOP_HOME=/home/$username/$hadoop_foldername/"
line3="export HADOOP_INSTALL=\$HADOOP_HOME"
line4="export HADOOP_MAPRED_HOME=\$HADOOP_HOME"
line5="export HADOOP_COMMON_HOME=\$HADOOP_HOME"
line6="export HADOOP_HDFS_HOME=\$HADOOP_HOME"
line7="export HADOOP_YARN_HOME=\$HADOOP_HOME"
line8="export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native"
line9="export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin"
line10="export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib/native\""

echo "$line1
$line2
$line3
$line4
$line5
$line6
$line7
$line8
$line9
$line10" >> "$file1"
#-------------------------------------------------------------


#INSTALLING SSH
#------------------------
while true
do
    echo "Want to install ssh (recommended)? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        sudo apt-get -y install ssh
        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "SKIPPING..."
        break

    else
        echo "Retry again"
    fi
done
#------------------------


#CHANGING SOME XML FILES
#-----------------------------------------------------------------------
cd /home/$username/$hadoop_foldername/etc/hadoop

#1. HADOOP-EVN.SH
#----------------------------------------
file2="hadoop-env.sh"
line14="JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64"

echo "$line14" >> "$file2"
#----------------------------------------

#2. CORE-SITE.XML
#----------------------------------------
file3="core-site.xml"

line15='<?xml version="1.0" encoding="UTF-8"?>'
line16='<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>'
line17="<!--"
line18='    Licensed under the Apache License, Version 2.0 (the "License");'
line19="    you may not use this file except in compliance with the License."
line20="    You may obtain a copy of the License at"
line21=""
line22='    http://www.apache.org/licenses/LICENSE-2.0'
line23=""
line24="    Unless required by applicable law or agreed to in writing, software"
line25='    distributed under the License is distributed on an "AS IS" BASIS,'
line26="    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."
line27="    See the License for the specific language governing permissions and"
line28="    limitations under the License. See accompanying LICENSE file."
line29="-->"
line30=""
line31="<!-- Put site-specific property overrides in this file. -->"
line32=""
line33="<configuration>"
line34="    <property>"
line35="        <name>fs.defaultFS</name>"
line36="        <value>hdfs://localhost:9000</value>"
line37="    </property>"
line38="</configuration>"


echo "$line15
$line16
$line17
$line18
$line19
$line20
$line21
$line22
$line23
$line24
$line25
$line26
$line27
$line28
$line29
$line30
$line31
$line32
$line33
$line34
$line35
$line36
$line37
$line38" > "$file3"
#----------------------------------------

cd /home/$username/$hadoop_foldername
mkdir hadoop_data_namenode_datanode
mkdir hadoop_data_namenode_datanode/namenode
mkdir hadoop_data_namenode_datanode/datanode

cd /home/$username/$hadoop_foldername/etc/hadoop

#3. HDFS-SITE.XML
#----------------------------------------
file4="hdfs-site.xml"

line39="<configuration>"
line40="    <property>"
line41="        <name>dfs.replication</name>"
line42="        <value>1</value>"
line43="    </property>"
line44="    <property>"
line45="        <name>dfs.name.dir</name>"
line46="        <value>file:///home/$username/$hadoop_foldername/hadoop_data_namenode_datanode/namenode</value>"
line47="    </property>"
line48="    <property>"
line49="        <name>dfs.data.dir</name>"
line50="        <value>file:///home/$username/$hadoop_foldername/hadoop_data_namenode_datanode/datanode</value>"
line51="    </property>"
line52="</configuration>"


echo "$line15
$line16
$line17
$line18
$line19
$line20
$line21
$line22
$line23
$line24
$line25
$line26
$line27
$line28
$line29
$line30
$line31
$line32
$line39
$line40
$line41
$line42
$line43
$line44
$line45
$line46
$line47
$line48
$line49
$line50
$line51
$line52" > "$file4"
#----------------------------------------

#4. MAPRED-SITE.XML
#----------------------------------------
file5="mapred-site.xml"

line15_='<?xml version="1.0"?>'

line56="<configuration>"
line57="    <property>"
line58="        <name>mapreduce.framework.name</name>"
line59="        <value>yarn</value>"
line60="    </property>"
line61="    <property>"
line62="        <name>mapreduce.application.classpath</name>"
line63="        <value>\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*,\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>"
line64="    </property>"
line65="    <property>"
line66="        <name>yarn.app.mapreduce.am.env</name>"
line67="        <value>HADOOP_MAPRED_HOME=/home/$username/$hadoop_foldername</value>"
line68="    </property>"
line69="    <property>"
line70="        <name>mapreduce.map.env</name>"
line71="        <value>HADOOP_MAPRED_HOME=/home/$username/$hadoop_foldername</value>"
line72="    </property>"
line73="    <property>"
line74="        <name>mapreduce.reduce.env</name>"
line75="        <value>HADOOP_MAPRED_HOME=/home/$username/$hadoop_foldername</value>"
line76="    </property>"
line77="</configuration>"

echo "$line15_
$line16
$line17
$line18
$line19
$line20
$line21
$line22
$line23
$line24
$line25
$line26
$line27
$line28
$line29
$line30
$line31
$line32
$line56
$line57
$line58
$line59
$line60
$line61
$line62
$line63
$line64
$line65
$line66
$line67
$line68
$line69
$line70
$line71
$line72
$line73
$line74
$line75
$line76
$line77" > "$file5"
#----------------------------------------

#5. YARN-SITE.XML
#----------------------------------------
file6="yarn-site.xml"

#17-32

line78="<configuration>"
line79="    <property>"
line80="        <name>yarn.nodemanager.aux-services</name>"
line81="        <value>mapreduce_shuffle</value>"
line82="    </property>"
line83="</configuration>"

echo "$line15_
$line17
$line18
$line19
$line20
$line21
$line22
$line23
$line24
$line25
$line26
$line27
$line28
$line29
$line30
$line31
$line32
$line78
$line79
$line80
$line81
$line82
$line83" > "$file6"
#----------------------------------------

#-----------------------------------------------------------------------

#SSH-connection SETUP FOR LOCALHOST
#---------------------------------------
cd /home/$username/

$hadoop_foldername/bin/hdfs namenode -format

cd /home/$username/.ssh
ssh-keygen -t ed25519 -C "loalhost connection of hadoop" -f /home/$username/.ssh/hadoop_localhost_connect -N ""

ssh-copy-id -i hadoop_localhost_connect.pub -o StrictHostKeyChecking=no localhost
#---------------------------------------



#CLEANUP
#-------------------------------------------------
while true
do
    echo "Want to cleanup? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        cd /home/$username/Downloads
        if [ $(find -maxdepth 1 | grep $hadoop_foldername.tar.gz) ]; then
            sudo rm $hadoop_foldername.tar.gz
            echo "COPY OF HADOOP.TAR.GZ DELETED. CONTINUING"
        else
            echo "HADOOP.TAR.GZ FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        cd /home/$username/

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
    echo "Want to restart (recommended to restart, if not then restart it yourself before starting up the hadoop services)? ((y)es / (n)o)"
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
