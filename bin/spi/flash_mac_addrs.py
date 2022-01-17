import sys
import shlex
import struct
import tempfile
import subprocess

MAC_ETH0_MTD = '/dev/mtd2'
MAC_ETH1_MTD = '/dev/mtd3'

mac_eth0 = sys.argv[1].strip().upper()
mac_eth1 = sys.argv[2].strip().upper()

if (not mac_eth0 or not mac_eth1):
    print "USAGE: python flash_mac_addrs.py <mac_eth0> <mac_eth1>"
    print "i.e. python flash_mac_addrs.py DE:AD:BE:EF:CE:AD AA:BB:CC:DD:EE:FF"

def write_mac(mac, mtddev):
    with tempfile.NamedTemporaryFile(mode='w+b') as tf:
        mac_str = ""
        for b in mac.split(':'):
            mac_str += '0x' + b + ','
        for b in (mac_str[:-1] + '\0'):
            tf.write(struct.pack('<B', ord(b)))
        tf.flush()
        subprocess.call(shlex.split('flash_erase {mtddev} 0 0'.format(mtddev=mtddev)))
        subprocess.call(shlex.split('nandwrite -p {mtddev} {macfile}'.format(mtddev=mtddev, macfile=tf.name)))

write_mac(mac_eth0, MAC_ETH0_MTD)
write_mac(mac_eth1, MAC_ETH1_MTD)
