#!/bin/bash

#scala version 2.12.15

#eclipse website to install - https://www.eclipse.org/downloads/download.php?file=/oomph/epp/2023-03/R/eclipse-inst-jre-linux64.tar.gz&mirror_id=1135
#jetbrains toolbox to install - https://www.jetbrains.com/toolbox-app/download/download-thanks.html?platform=linux
#jetbrains sbt version for project choosing - https://stackoverflow.com/questions/49000201/whats-the-relationship-of-the-versions-of-scala-when-i-use-sbt-to-build-a-scala

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


scala_version='2.12.15'
scala_foldername="scala-$scala_version"

#DOWNLOADING SCALA FROM https://www.scala-lang.org/download/ go into https://www.scala-lang.org/download/2.12.15.html and extract to ~
#-----------------------------------------------------------------
while true
do
    echo "INSTALLATION METHOD"
	echo "1. DEB FILE INSTALATION (recommended)"
	echo "2. APT BASED INSTALLATION"
	echo "3. BINARY FILE INSTALATION"   #https://downloads.lightbend.com/scala/2.12.15/scala-2.12.15.tgz     https://www.scala-lang.org/download/install.html
    
	read installation_method
    if [ "$installation_method" == "1" ]; then

        cd ~/Downloads
        if [ $(find -maxdepth 1 | grep $scala_foldername.deb) ]; then
            sudo rm $scala_foldername.deb
            echo "COPY OF SCALA.DEB DELETED. CONTINUING"
        else
            echo "SCALA.DEB FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        cd ~

        
		wget -P ~/Downloads https://downloads.lightbend.com/scala/$scala_version/$scala_foldername.deb
		sudo apt install ~/Downloads/$scala_foldername.deb
        break

    elif [ "$installation_method" == "2" ]; then
        sudo apt-get install scala=$scala_version
        
        if [ $? -ne 0 ]; then
            echo "SCALA NOT INSTALLED (VERSION NOT FOUND)"
        fi

		exit 0
        
    elif [ "$installation_method" == "3" ]; then

        cd ~/Downloads
        if [ $(find -maxdepth 1 | grep $scala_foldername.tgz) ]; then
            sudo rm $scala_foldername.tgz
            echo "COPY OF SCALA.TGZ DELETED. CONTINUING"
        else
            echo "SCALA.TGZ FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        cd ~

        
        wget -P ~/Downloads https://downloads.lightbend.com/scala/$scala_version/$scala_foldername.tgz
        tar -zxvf ~/Downloads/$scala_foldername.tgz
		break
        
    else
        echo "Retry again"
    fi
done


#-----------------------------------------------------------------


#GOING TO DEFAULT LOCATION
#-------------------------
cd ~
#-------------------------


#INSTALLING ECLIPSE
#-------------------------------------------------
while true
do
    echo "Want to install eclipse 2023? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then

        cd ~/Downloads
        if [ $(find -maxdepth 1 | grep eclipse-inst-jre-linux) ]; then
            sudo rm eclipse-inst-jre-linux64.tar.gz
            echo "COPY OF ECLIPSE TOOLS DELETED. CONTINUING"
        else
            echo "ECLIPSE FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        cd ~

        firefox https://www.eclipse.org/downloads/download.php?file=/oomph/epp/2023-03/R/eclipse-inst-jre-linux64.tar.gz\&mirror_id\=1135

        echo "WARNING, WAIT FOR THE FILE TO BE FULLY DOWNLOADED BEFORE YOU HIT ANY KEY"
        read answer

        tar -zxvf ~/Downloads/eclipse-inst-jre-linux64.tar.gz

        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "SKIPPING..."
        break

    else
        echo "Retry again"
    fi
done
#-------------------------------------------------


#INSTALLING JETBRAINS TOOLBOX
#-------------------------------------------------
while true
do
    echo "Want to install jetbrains toolbox (to install intellij)? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then
        cd ~/Downloads
        if [ $(find -maxdepth 1 | grep jetbrains-toolbox) ]; then
            sudo rm jetbrains-toolbox-1.28.1.15219.tar.gz
            echo "COPY OF JETBRAINS TOOLS DELETED. CONTINUING"
        else
            echo "JETBRAINS TOOLS FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        cd ~

        firefox https://www.jetbrains.com/toolbox-app/download/download-thanks.html?platform=linux

        echo "WARNING, WAIT FOR THE FILE TO BE FULLY DOWNLOADED BEFORE YOU HIT ANY KEY"
        read answer

        tar -zxvf ~/Downloads/jetbrains-toolbox-1.28.1.15219.tar.gz

        break

    elif [ "$answer" == "no" ] || [ "$answer" == "n" ]; then
        echo "SKIPPING..."
        break

    else
        echo "Retry again"
    fi
done
#-------------------------------------------------


#----------------------------------------------------

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

if [ "$installation_method" == 3 ]; then    #this means with the binary so we need to fill out bashrc
    # SCALA HOME SETUP :
    line2="export SCALA_HOME=~/$scala_foldername/"
    line3="export PATH=\$PATH:\$SCALA_HOME/bin"

    echo "$line2
    $line3" >> "$file1"
fi
#-------------------------------------------------------------


#CLEANUP
#-------------------------------------------------
# $installation_method contain which option we went for installation, so do the cleanup accordingly

while true
do
    echo "Want to cleanup? ((y)es / (n)o)"
	read answer
    if [ "$answer" == "yes" ] || [ "$answer" == "y" ]; then

        cd ~/Downloads

        if [ $(find -maxdepth 1 | grep $scala_foldername.deb) ]; then
            sudo rm $scala_foldername.deb
            echo "COPY OF SCALA.DEB DELETED. CONTINUING"
        else
            echo "SCALA.DEB FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        
        if [ $(find -maxdepth 1 | grep $scala_foldername.tgz) ]; then
            sudo rm $scala_foldername.tgz
            echo "COPY OF SCALA.TGZ DELETED. CONTINUING"
        else
            echo "SCALA.TGZ FILE NOT FOUND TO DELETE. CONTINUING"
        fi

        if [ $(find -maxdepth 1 | grep eclipse-inst-jre-linux) ]; then
            sudo rm eclipse-inst-jre-linux64.tar.gz
            echo "COPY OF ECLIPSE.TAR.GZ DELETED. CONTINUING"
        else
            echo "ECLIPSE.TAR.GZ FILE NOT FOUND TO DELETE. CONTINUING"
        fi

        if [ $(find -maxdepth 1 | grep jetbrains-toolbox) ]; then
            sudo rm jetbrains-toolbox-1.28.1.15219.tar.gz
            echo "COPY OF JETBRAINS-TOOLBOX DELETED. CONTINUING"
        else
            echo "JETBRAINS-TOOLBOX FILE NOT FOUND TO DELETE. CONTINUING"
        fi
        
        cd ~

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
