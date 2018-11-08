#!/usr/bin/python


import re


file = open('test.asm', 'r') 
for line in file: 
  temp = line.strip()
  re.sub( ' +', ' ', str(temp) ).strip()
  print temp

file.close()