#!/bin/bash
gawk -F: '{print $3 $4 $7}' compta.txt  |sort |uniq
