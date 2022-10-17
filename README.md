1. Setup a sshd server on your android device.

2. Copy public key
```bashe
cat ~/.ssh/id_rsa.pub | ssh -p 8022 user@192.168.43.2 "cat >> ~/authorized_keys"
```
3. Start proxy2vpn on your linux machine.
