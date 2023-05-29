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

hive_version='3.1.2'
hive_foldername="hive-$hive_version"

#DOWNLOADING HIVE FROM https://dlcdn.apache.org/hive/ go into https://dlcdn.apache.org/hive/hive-3.1.2/ and extract to ~
#-----------------------------------------------------------------
cd ~/Downloads
if [ $(find -maxdepth 1 | grep apache-$hive_foldername-bin.tar.gz) ]; then
    sudo rm apache-$hive_foldername-bin.tar.gz
    echo "COPY OF HIVE.TAR.GZ DELETED. CONTINUING"
else
    echo "SPARK.TGZ FILE NOT FOUND TO DELETE. CONTINUING"
fi
cd ~

wget -P ~/Downloads wget https://dlcdn.apache.org/hive/$hive_foldername/apache-$hive_foldername-bin.tar.gz

tar -zxvf ~/Downloads/apache-$hive_foldername-bin.tar.gz
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

#CLEANUP
#-------------------------------------------------
# $installation_method contain which option we went for installation, so do the cleanup accordingly

while true
do
    echo "Want to cleanup? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        sudo rm ~/Downloads/apache-$hive_foldername-bin.tar.gz
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
