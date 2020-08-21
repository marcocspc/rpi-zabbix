# Pull base image 
FROM yummygooey/raspbian-buster
MAINTAINER marcocspc 

RUN apt-get -y update 
RUN apt-get install -y wget
RUN wget https://repo.zabbix.com/zabbix/5.0/raspbian/pool/main/z/zabbix-release/zabbix-release_5.0-1+buster_all.deb
RUN dpkg -i zabbix-release_5.0-1+buster_all.deb
RUN apt-get update

RUN echo mysql-server mysql-server/root_password select zabbix123 | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again select zabbix123 | debconf-set-selections

RUN apt-get install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent php -y

RUN cp /etc/zabbix/apache.conf /etc/apache2/conf-available/
RUN ln -s /etc/apache2/conf-available/apache.conf /etc/apache2/conf-enabled/
RUN sed -i '/DBPassword=/c\DBPassword=zabbix' /etc/zabbix/zabbix_server.conf 

VOLUME ["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]

ADD ./scripts/run.sh /bin/start-zabbix
RUN chmod 755 /bin/start-zabbix

EXPOSE 10051 10052 80
CMD ["/bin/start-zabbix"]
