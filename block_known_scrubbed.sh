#!/bin/bash

#Wrapper to run the curl script to get the IPs and dump that output to the blocking python script

./t-pot_known.sh | ./send_blocks_to_db.py
