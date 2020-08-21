# rpi-zabbix
A docker container to run a Zabbix server on the Raspberry Pi

To build this container:

    git clone https://github.com/marcocspc/rpi-zabbix.git
    docker build -t rpi-zabbix .

To run the container:

    docker run -d -p 10051:10051 -p 10052:10052 -p 8080:80 rpi-zabbix 

