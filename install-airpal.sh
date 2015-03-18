#!/bin/bash 
#
# Installs the Airbnb Airpal UI on EMR
#
# Arguments (optional):
# Parameter 1 is your hive properties with the metastore you want to use for presto
# Parameter 2 is your presto JVM settings
# Parameter 3 is your airpal reference file


aws s3 cp $1 /home/hadoop/presto-server/etc/catalog/hive.properties
aws s3 cp $2 /home/hadoop/presto-server/etc/catalog/jvm.config


#Kill presto to pick up new credentials
PRESTOID=`ps -aux | grep -i /home/hadoop/.versions/presto-server-0.78 | grep -i java | gawk -F " " '{print $2}'`
sudo kill -9 $PRESTOID

#Install Gradle
sudo yum install git -y
gradle_version=1.11
sudo mkdir /opt/gradle
sydo wget -N http://services.gradle.org/distributions/gradle-${gradle_version}-all.zip
sudo unzip -oq ./gradle-${gradle_version}-all.zip -d /opt/gradle
ln -sfnv gradle-${gradle_version} /opt/gradle/latest
printf "export GRADLE_HOME=/opt/gradle/latest\nexport PATH=\$PATH:\$GRADLE_HOME/bin" > /etc/profile.d/gradle.sh
sudo  /etc/profile.d/gradle.sh
rehash ; sync
# check installation
gradle -v

#download and build airpal
sudo git clone https://github.com/airbnb/airpal.git /home/hadoop/airpal
cd /home/hadoop/airpal
sudo ./gradlew clean shadowJar
sudo aws s3 cp $3  /home/hadoop/airpal/reference.yml
sudo java -Duser.timezone=UTC -cp build/libs/airpal-*-all.jar com.airbnb.airpal.AirpalApplication db migrate reference.yml

#Make it available on port 80
sudo /sbin/iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8081

#Start the server
nohup sudo java -server -Duser.timezone=UTC -cp build/libs/airpal-*-all.jar com.airbnb.airpal.AirpalApplication server reference.yml &
exit 0
