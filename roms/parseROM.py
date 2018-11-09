#!/usr/bin/python

from binascii import hexlify, unhexlify

f = open("tetris.gb", "rb")
header_b = f.read(256)
header = hexlify(header_b)

CEP_b = f.read(4)
CEP = hexlify(CEP_b)

NINTENDO_b = f.read(48)
NINTENDO = hexlify(NINTENDO_b)

gametitle_b = f.read(15)
gametitle = hexlify(gametitle_b)

todo = f.read(13)

test_b = f.read(10)
test = hexlify(test_b)

f.close()


print "0x0000 - 0x0099: Header"
print header
print


print "0x0100 - 0x0103: Code Execution Point"
print CEP
print


print "0x0104 - 0x0133: NINTENDO"
print NINTENDO
print

print "0x0134 - 0x0133: gametitle"
print gametitle_b
print

print test+"..."