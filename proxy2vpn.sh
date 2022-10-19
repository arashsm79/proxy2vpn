#!/run/current-system/sw/bin/bash

print_usage() {
	echo "
Usage:
    proxytovpn stop ssh_addr
    proxytovpn start proxy_addr ssh_addr
Example:
    proxytovpn start 127.0.0.1:8010 192.168.76.2
    "
}


case $1 in
"stop")
    if [ "$#" -ne 2 ]; then
        print_usage
    fi
	killall badvpn-tun2socks
	ifconfig tun0 down
	route del default gw 10.0.0.2 metric 6
    current_default_route="$(route -n | grep -i 0.0.0.0 | head -n1 | awk '{print $2}')"
    route del "$2" gw "$current_default_route" metric 5
    route del 8.8.8.8 gw "$current_default_route" metric 5
	route del 1.1.1.1 gw "$current_default_route" metric 5
	echo "VPN Disconnected"
	exit
;;
"start")
    if [ "$#" -ne 3 ]; then
        print_usage
    fi
	#create tun device
    ip tuntap add mode tun dev tun0

	#configure ip new tun device
	ifconfig tun0 10.0.0.1 netmask 255.255.255.0

	#start tun2socks
	#tun2socks with udpgw
	# badvpn-tun2socks --tundev tun0 --loglevel none --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 127.0.0.1:1080 --udpgw-remote-server-addr 127.0.0.1:7100 --udpgw-connection-buffer-size 32768 --udpgw-transparent-dns &
	#tun2socks without udpgw
    badvpn-tun2socks --tundev tun0 --loglevel error --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0  --socks-server-addr "$2" &

    current_default_route="$(route -n | grep -i 0.0.0.0 | head -n1 | awk '{print $2}')"
	#add route to the SSH
	route add "$3" gw "$current_default_route" metric 5

	#add route to DNS
	route add 8.8.8.8 gw "$current_default_route" metric 5
	route add 1.1.1.1 gw "$current_default_route" metric 5

	#add a default route to virtual router
	route add default gw 10.0.0.2 metric 6
	echo "VPN Connected"
;;
*)
    print_usage
;;
esac
