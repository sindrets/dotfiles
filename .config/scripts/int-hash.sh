#!/bin/bash 

# Returns the integer value of the md5 hash of the string % (2^31-1)

s=`echo -n $1 | md5sum | awk '{print $1}'`
node -p "parseInt('$s', 16) % (Math.pow(2, 31) - 1)"
