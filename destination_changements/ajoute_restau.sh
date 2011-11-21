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


# ajoute un restau par bq
echo "util?"
read UTIL
echo "montant?"
read MONTANT
echo "libellé?"
read LIB
LOB="restau  - "
LIB="$LOB $LIB"
echo "date?"
read DATE
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "6257" -N "Réceptions - Frais restauration"  -s D
./journal -u "$UTIL" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "512" -N "Banque" -s C
./bal
