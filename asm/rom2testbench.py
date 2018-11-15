#!/usr/bin/python

from binascii import hexlify

ofile = open("memory_model.vhd", "w")


ofile.write("  -------------------------------------------------------------------------------\n");
ofile.write("  -- MEMORY MODEL\n");
ofile.write("  -------------------------------------------------------------------------------\n");
ofile.write("  PMUX: process(ROM_address)\n");
ofile.write("  begin\n");
ofile.write("    case ROM_address is\n");

address = 0
nops = 0

with open("example.gb", "rb") as ifile:
  byte = ifile.read(1)
  while byte != b"":
    if hexlify(byte) != "00":
      # only the non-zero bytes are enumerated
      # the others are covered with "others =>"
      line = "      when x\""+((hex(address))[2:]).zfill(4)+"\" => ROM_dataout_i <= x\""+hexlify(byte)+"\";\n";
      ofile.write(line)
    else:
      nops += 1
    address += 1
    byte = ifile.read(1)


ofile.write("      when others => ROM_dataout_i <= x\"00\";\n");
ofile.write("    end case;\n");
ofile.write("  end process;\n");

ofile.close()

print "number of addresses read: "+str(address)
print "  - NOPS: "+str(nops)
