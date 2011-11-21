#!/bin/bash - 
#===============================================================================
#
#          FILE:  ajoute_restau_rho.sh
# 
#         USAGE:  ./ajoute_restau_rho.sh 
# 
#   DESCRIPTION:  ajoute une opé de restau à RHODES
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner@fh-swf.de
#       COMPANY: FH Südwestfalen, Iserlohn
#       CREATED: 15/11/2011 03:44:27 CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


# ajoute une opé de restau à rhodes
echo "util?"
read UTIL
echo "montant?"
read MONTANT
LIB="plein essence"
echo "date?"
read DATE
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "6248" -N "Transport - divers - carburant"  -s D
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "512" -N "Banque" -s C
./bal
