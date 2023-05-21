#!/bin/bash

#spark version - 3.3.2 for hadoop 3.3 or more


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
        sudo apt update && sudo apt upgrade
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
cd ~
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

#DOWNLOADING SCALA FROM https://dlcdn.apache.org/spark/ go into https://dlcdn.apache.org/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz and extract to ~
#-------------------------------------------------
spark_version='3.3.2'
spark_foldername="spark-$spark_version"
hadoop_version=3

cd ~/Downloads
if [ $(find -maxdepth 1 | grep $spark_foldername-bin-hadoop$hadoop_version.tgz) ]; then
    sudo rm $spark_foldername-bin-hadoop$hadoop_version.tgz
    echo "COPY OF SPARK.TGZ DELETED. CONTINUING"
else
    echo "SPARK.TGZ FILE NOT FOUND TO DELETE. CONTINUING"
fi
cd ~

wget -P ~/Downloads wget https://dlcdn.apache.org/spark/$spark_foldername/$spark_foldername-bin-hadoop$hadoop_version.tgz

tar -zxvf ~/Downloads/$spark_foldername-bin-hadoop$hadoop_version.tgz
#-------------------------------------------------


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


# SCALA HOME SETUP :
line2="export SPARK_EXAMPLES_JAR=/home/$username/$spark_foldername-bin-hadoop$hadoop_version/examples/jars/spark-examples_2.12-3.3.1.jar"
line3="export SPARK_HOME=/home/$username/$spark_foldername-bin-hadoop$hadoop_version"
line4="export PATH=\$PATH:/home/$username/$spark_foldername-bin-hadoop$hadoop_version/bin"
echo "$line2
$line3
$line4" >> "$file1"

#-------------------------------------------------------------

#CLEANUP
#-------------------------------------------------
# $installation_method contain which option we went for installation, so do the cleanup accordingly

while true
do
    echo "Want to cleanup? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        sudo rm ~/Downloads/$spark_foldername-bin-hadoop$hadoop_version.tgz
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
    echo "Want to restart (recommended to restart, if not then restart it yourself before starting up the scala services)? ((y)es / (n)o)"
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
