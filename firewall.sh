#!/bin/bash
#801159, Gallardo Sánchez, Víctor, T, 1, B
#806955, Franco Ramírez, Jan Carlos, T, 1, B
if [ $EUID -ne 0 ];
then 
	echo -e "ERROR. PERMISO DENEGADO"
	exit 0
fi


#Borrado de reglas
iptables -F
iptables -t nat -F



#Conexion entrante redireccionada al servidor ssh de Debian5, ssh tiene su propio puerto
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 22 -j DNAT --to 192.168.3.1  

#Conexion entrante redireccionada al servidor web apache de Debian2
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 80 -j DNAT --to 192.168.1.55


#Direccion IP origen de paquetes del Host ahora es la direccion publica del firewall
iptables -t nat -A POSTROUTING -o enp0s8 -j SNAT --to-source 192.168.56.2


#Restringimos el envio de paquetes ping desde Host
iptables -A INPUT -i enp0s8 -s 192.168.56.0/24 -p icmp --icmp-type 8 -j DROP

#Rechazamos el resto de trafico
iptables -A INPUT -i enp0s8 -j DROP

iptables -A INPUT -i enp0s3 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o enp0s3 -j SNAT --to-source 192.168.56.2
iptables -A INPUT -i enp0s3 -j DROP #rechazamos los paquetes que vengan de la nat

iptables-save > /etc/iptables/rules.v4



