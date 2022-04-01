
# credit: https://gist.github.com/jecxjo

# Requires tcllib
package require aes
package require tcl::transform::base64
package require md5

# Make some sort of key data, 16, 24, or 32 bytes long
set key [string repeat - 16]

# Generate an IV, 16 bytes long. MD5 of clock ticks, the Proc ID, and
# a random value. Take 16 bytes.
set iv [string range [md5::md5 [clock clicks]:[pid]:[expr {rand()}]] 0 15]

# Open the plain text and cipher text channels. Set them to binary mode
# so all bytes are read if not readable
set fIn [open plain.txt r]
set fOut [open cipher.dat w]
fconfigure $fIn -translation binary
fconfigure $fOut -translation binary

# Set the Output Channel to also base64 encode on the write
tcl::transform::base64 $fOut

# Stick the IV at the begining of the file (based64 encoded of course)
puts -nonewline $fOut $iv

# Do encryption, CBC Mode, with Key and IV. Directly read from In and write
# to Out. And again, automatically base64 encoded on the write.
aes::aes -mode cbc -dir encrypt -key $key -iv $iv -out $fOut -in $fIn

# Close both channels
close $fIn
close $fOut

# Open the cipher text and the destination channels. Set to binary mode.
set fIn [open cipher.dat r]
set fOut [open plain2.txt w]
fconfigure $fIn -translation binary
fconfigure $fOut -translation binary

# Set input channel to decode base64 on read.
tcl::transform::base64 $fIn

# Read 16 bytes, this is the IV
set iv [chan read $fIn 16]

# Decrypt, CBC mode, same key, IV pulled from text. And automatically
# decode base64.
aes::aes -mode cbc -dir decrypt -key $key -iv $iv -out $fOut -in $fIn

close $fIn
close $fOut