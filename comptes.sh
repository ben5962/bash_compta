#!/bin/bash
gawk -F: '{print $3 $4 }' compta.txt  |sort |uniq
