#!/bin/bash


hex_date=$1

fpgadate=$(echo $((16#`echo $hex_date`)))

echo $fpgadate
# ... so it can be read by date
date --date @${fpgadate}

