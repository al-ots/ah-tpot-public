#!/usr/bin/python3

# This script just takes stdin of IP addresses, one per line, and throws them into our block database for 60 days.

import sys
import IPy
import subprocess
import datetime
import psycopg2
from time import sleep

def main():
    # Read addresses from stdin
    ips = []
    for addr in sys.stdin:
        try:
            ip = IPy.IP(addr)
            ips.append(ip)
        except ValueError:
            print("%s is not a valid IP" % (addr.strip()))

    # put IPs in the minemeld DB
    if len(ips) > 0:
        conn = psycopg2.connect("dbname=minemeldlists host=db-a.ipam.yourdomain.tld user=logalerts")
        cur = conn.cursor()
        # Get list of active IPs in database
        cur.execute("SELECT ip_addr FROM blocks WHERE now() < expires ORDER BY ip_addr")
        query_result = cur.fetchall()
        active_blocks = []
        for i in query_result:
            active_blocks.append(IPy.IP(i[0]))

        for addr in ips:
            blocked = False
            for block in active_blocks:
                if addr in block:
                    blocked = True
                    break
            if not blocked:
                cur.execute("INSERT into blocks (ip_addr, created, expires, reason) values ('%s', now(), now() + interval '60 days', 'Bad actor detected by honeypot')" % (addr))
        conn.commit()
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()
