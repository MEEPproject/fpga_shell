#!/bin/bash


hex_date=$(cat content)

#Converts the hex value stored in hex_date to a decimal value
fpgadate=$(echo $((16#`echo $hex_date`)))

#echo $fpgadate
# converts the Unix timestamp into a human-readable format
date --date @${fpgadate}

rm content
