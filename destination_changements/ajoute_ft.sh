#!/bin/bash - 
#===============================================================================
#
#          FILE:  ajoute_ft.sh
# 
#         USAGE:  ./ajoute_ft.sh 
# 
#   DESCRIPTION:  ajoute le pmt d'une facture FT ds compte le payant. ajoute rel de C/D aussi sur les ious.
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
# charge FICHIERDEST
. ./compta.conf
# ajoute des courses par bq
echo "util?"
read UTIL
echo "NUM facture?"
read NUM_FACT
# montant abo fixe: 32E
MONTANT=32
echo "période couverte par la fa?"
read PERIODE
echo "date de la fa?"
read DATEFA
echo "échéance de la fa?"
read ECHE
echo "preuve de pmt?"
ls -d /home/corentin/archives/preuve_pmt*
ls -lR /home/corentin/archives/preuve_pmt*
read PREUVE
# libellé tjs le meme: pmt facture ft n° $NUM_FACT du $DATEFA échéance $ECHE pour la période $PERIODE par téléreglement par $UTIL
LIB="pmt facture ft n° ${NUM_FACT} du ${DATEFA} échéance ${ECHE} pour la période ${PERIODE} par téléreglement par ${UTIL} preuve pmt ${PREUVE}"
COMMENTAIRE="pmt facture ft"
# utiliser la commande de commentaires
./commentaire.sh "$COMMENTAIRE"
# paiement par utilisateur
./journal -u "$UTIL"  -l "${LIB}" -m "${MONTANT}" -n "6261" -N "Frais postaux et télécom - ligne fixe FT"  -s D
./journal -u "$UTIL"  -l "$LIB" -m "$MONTANT" -n "512" -N "Banque" -s C


case $UTIL in 
	co)
# gestion des ious:
# cas 1 : c'est corentin qui a payé => il a une créance sur puce de 16E contre un transfert de ch 7xx
#  corentin
#  401IOUPCdx	|		créance sur puce "401 (cré cli) IOU Puce doit à CO"
#  		| 791 cx	.. car charge transférée
#
# montant : MONTANT/2
NVMONTANT=$(echo "$MONTANT / 2" |bc)
./commentaire.sh "$COMMENTAIRE créance de co sur pu vue depuis compte co"
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "401IOUPC" -N "IOU Puce doit à co" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "791" -N "Transferts de charge d'exploitation" -s C 

#         et dans le compte de puce , elle a une dette de 16E  contre un ajout de ch. "ch transférée (sans typologie)
#  puce
#  65555dx	|            charge dans ta face par transfert
# 		| 411IOUPCcx		... pas encore payée " 411(dette fou) IOU  Puce doit à Co"
./commentaire.sh "$COMMENTAIRE créance de co sur pu vue depuis compte pu"

UTIL="pu"
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "65555FT" -N "Quote-part de charges sur opérations communes - FT" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "411IOUPC" -N "IOU Puce doit à co" -s C
UTIL="co"
;;

	pu)
# cas 2 : c'est puce qui a payé => elle a une créance
# puce
#  401IOUCPdx	|		créance sur puce "401 (cré cli) IOU Co doit à pu"
#  		| 791 cx	.. car charge transférée
#
# montant : MONTANT/2
NVMONTANT=$(echo "$MONTANT / 2" |bc)
./commentaire.sh "$COMMENTAIRE créance de puce sur co vue depuis compte pu"

./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "401IOUCP" -N "IOU co doit à pu" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "791" -N "Transferts de charge d'exploitation" -s C 
#         et dans le compte de co , il a une dette de 16E  contre un ajout de ch. "ch transférée (sans typologie)
#  co
#  65555dx	|            charge dans ta face par transfert
# 		| 411IOUCPcx		... pas encore payée " 411(dette fou) IOU  co doit à pu"
UTIL="co"
./comentaire.sh "$COMMENTAIRE créance de puce sur co vue depuis compte co"
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "65555FT" -N "Quote-part de charges sur opérations communes - FT" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "411IOUCP" -N "IOU co doit à pu" -s C
UTIL="pu"

;;
	*) echo "util $UTIL pas prévu"
		;;

esac
./bal
