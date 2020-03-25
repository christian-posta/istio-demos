
# sniff all packets to pcap file
kubectl sniff -i eth0 -o capture.pcap web-api-77d767dc46-qqf6n -n istioinaction

# try sniff specific IP address
kubectl sniff -i eth0 -o capture.pcap web-api-77d767dc46-qqf6n -n istioinaction -f '((tcp) and (net 10.16.1.32))'

   