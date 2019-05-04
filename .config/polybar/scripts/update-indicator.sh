#!/bin/bash

[ ! -z ${updates=`checkupdates 2> /dev/null | wc -l`} ] || updates=0
updates=$[ $updates + `yay -Qua 2> /dev/null | wc -l` ]

echo $updates
