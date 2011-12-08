#!/bin/bash - 
#===============================================================================
#
#          FILE:  ajoute_loyer.sh
# 
#         USAGE:  ./ajoute_loyer.sh 
# 
#   DESCRIPTION:  ajoute une opé d'avance de loyer par puce ou de remb par co 
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

# définitions 
# affectation de compte: commande journal .... ajoute un montant à un compte
# opération : plusieurs affectations de comptes de man à être équilibrée : montant D = montant C de l'opé
# procédure : plusieurs opérations sur des comptes réciproques chez co et puce
# fiche de procédures : ce programme : mise dans un meme lieu de procédures sur un meme theme

# methode: 
# 1) écrire en deux mots les procédures devant se trouver dans la fiche de proc
# 2) pour chaque proc écrire analyse comptable avec le tableau APCPi et commentaires.sh. écrire le tab des var et cocher var dyn
# 3) écrire le code de manière à affecter les variables dans le bon ordre:
# 	les variables des plus communes, factorisables, au moins communes, factorisables
#  	- lister les variables communes à toute la fiche de procédure: souvent date, montant, parfois util, parfois lib.
#	=> elles seront affectées avant la var de choix de procédure
#       -> ECRIRE CETTE AFFECTATION
#	- lister les variables affectées par la procédure  


# application méthode.
# 2 procédures 
# remboursement de loyer par corentin
# avance de puce

# si l'util est co, c'est un remboursement
#. compta.conf
FICHIERDEST="essai"
# ajoute un remb de demi loyer par co
./commentaire.sh "début opé"
./commentaire.sh "remboursement de loyer par co"
echo "utilisateur? si 'co' remboursement de loyer, si 'pu' avance de loyer"
read SWUTIL
MONTANT=350
echo "mois de remb?"
read LOB
echo "date?"





case $SWUTIL in 
	co)

# méthode affectation des variables: 
# mise en place des valeurs de var communes  à l'opé de D et à celle de C 
# puis mise en place lors appel de journal des valeurs manquantes
# donc pointage
# paramétrage des variables so far: 
# pour les procédures comportant deux opérations (untruc dans le compte de l'un, un truc dans le compte de lautre)
# on a : cproc variables communes à toutes les procédures. à affecter avant l ' affectation de variable décidant de la proc lancée
# on a : c2 variables communes aux deux opérations
# 	c1 variable valable que pour cette opé
# 	todo dyn var dyna à affecter lors appel de journal
# nomvar	@	UTIL 		| DATE 	| LIB 		| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# -----------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ todo:c1 :set to co	|  ok	| ok 		| todo dyn	| todo	dyn	| todo dyn	| ok c2 
# ------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@ todo:c1 :set to co	|  ok	| c2:concat $LOB| todo 		| todo		| todo		| ok c2		
# "[  ]" = "to be done"


# paramétrage des variables so far: 
# nomvar	@	UTIL 			| DATE | LIB 		| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# ----------------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ [ c1todo:set to co	]	|  ok	| ok 		| todo		| todo		| todo		| ok
# ----------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@ todo: set to co		|  ok	| concat $LOB	| todo 		| todo		| todo		| ok

UTIL="co"

# paramétrage des variables so far: 
# nomvar	@	UTIL 	| DATE 	| LIB 		| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# ----------------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ 	ok	|  ok	| ok 		| todo		| todo		| todo		| ok
# ----------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@  	ok	|  ok	| [concat $LOB]	| todo 		| todo		| todo		| ok


LIB="remboursement dette 1/2 loyer par corentin ${LOB}"

# paramétrage des variables so far: 
# nomvar	@	UTIL 	| DATE 	| LIB 		| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# ----------------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ 	ok	|  ok	| ok 		| [todo]	| [todo]	| [todo]	| ok
# ----------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@  	ok	|  ok	| ok 		| todo 		| todo		| todo		| ok




./commentaire.sh " 1/2 extinction de la dette dans compte corentin"
./commentaire.sh " 512	|                 "
./commentaire.sh "  /x	|                 "
./commentaire.sh " ---------------        "
./commentaire.sh " 	| 4O1             "
./commentaire.sh "	| x/              "
./journal -u "co" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "401IOUCP" -N "IOU - Co doit à puce "  -s D
./journal -u "co" -d "$DATE" -l "$LIB" -m "$MONTANT" -n "512" -N "Banque" -s C
	
# paramétrage des variables so far: 
# nomvar	@	UTIL 	| DATE 	| LIB 		| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# ----------------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ 	ok	|  ok	| ok 		| ok		|    ok		| 	ok	| ok
# ----------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@  	ok	|  ok	| ok 		| ok 		|    ok		|   ok		| ok




# -----------------------------------------------------------------------------------------------------------------------
#   MEME PROCEDURE / AUTRE OPE / NOUVELLE AFFECTATION DES VARIABLES 
# ------------------------------------------------------------------------------------------------------------------------

# paramétrage des variables so far: 
# pour les procédures comportant deux opérations (untruc dans le compte de l'un, un truc dans le compte de lautre)
# on a : c2 variables communes aux deux opérations
# 	c1 variable valable que pour cette opé
# 	todo dyn var dyna à affecter lors appel de journal
# nomvar	@	UTIL 		| DATE 	| LIB 		| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# -----------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ todo:c1 :set to co	|  ok	| ok 		| todo dyn	| todo	dyn	| todo dyn	| ok c2 
# ------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@ todo:c1 :set to co	|  ok	| c2:concat $LOB| todo 		| todo		| todo		| ok c2		
# "[  ]" = "to be done"
# "="  = rien à faire
# si que des "=" en bas de tableau alors plus rien à faire
# "=" <=> "=" ligne du dessus
#  
# transformation du tableau précédent:  col "ok c2 en bas " => devient "=" sur toutes lignes
# nomvar	@	UTIL 		| DATE 	| LIB 			| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# -----------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ todo:c1 :set to co	|  ok	| ok 			| todo dyn	| todo	dyn	| todo dyn	| ok c2 
# ------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@ todo:c1 :set to co	|  ok	|[c2:concat $LOB]	| todo 		| todo		| todo		| [ok c2]		

# nomvar	@	UTIL 		| DATE 	| LIB 		| NUMCOMPTE 	| NOMCOMPTE 	| SENSOPE  	| MONTANTOPE
# -----------------------------------------------------------------------------------------------------------------------------
# saisieutil?	@ todo:c1 :set to co	|  ok	| = 		| todo dyn	| todo	dyn	| todo dyn	| = 
# ------------------------------------------------------------------------------------------------------------------------------
# valvarprete?	@ todo:c1 :set to co	|  ok	| =		| todo 		| todo		| todo		| =		




./commentaire.sh "2/2 extinction de la creance dans le compte puce"
./commentaire.sh "la créance est éteinte"
./commentaire.sh "411	|			"
./commentaire.sh " /x	|			"
./commentaire.sh "------------------------------"
./commentaire.sh " contre une augmentation du solde du compte en banque"
./commentaire.sh " 	| 512			"
./commentaire.sh "	| x/			"
./journal -u "pu" -d "$DATE" -l "$LIB" 
# gestion des ious:
# cas 1 : c'est corentin qui a payé => il a une créance sur puce de 16E contre un transfert de ch 7xx
#  corentin
#  401IOUPCdx	|		créance sur puce "401 (cré cli) IOU Puce doit à CO"
#  		| 791 cx	.. car charge transférée
#
# montant : MONTANT/2









NVMONTANT=$(echo "scale=2; $MONTANT / 2" |bc)
./commentaire.sh "$COMMENTAIRE créance de co sur pu vue depuis compte co"
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "401IOUPC" -N "IOU Puce doit à co" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "791" -N "Transferts de charge d'exploitation" -s C 

#         et dans le compte de puce , elle a une dette de 16E  contre un ajout de ch. "ch transférée (sans typologie)
#  puce
#  65555dx	|            charge dans ta face par transfert
# 		| 411IOUPCcx		... pas encore payée " 411(dette fou) IOU  Puce doit à Co"
./commentaire.sh "$COMMENTAIRE créance de co sur pu vue depuis compte pu"

UTIL="pu"
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "65555EDF" -N "Quote-part de charges sur opérations communes - EDF" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "411IOUPC" -N "IOU Puce doit à co" -s C
UTIL="co"
;;

	pu)

		
LIB="AVANCE DE LOYER PAR PUCE ${LOB}"
	
		
# cas 2 : c'est puce qui a payé => elle a une créance
# puce
#  401IOUCPdx	|		créance sur puce "401 (cré cli) IOU Co doit à pu"
#  		| 791 cx	.. car charge transférée
#
# montant : MONTANT/2
NVMONTANT=$(echo "scale=2; $MONTANT / 2" |bc)
./commentaire.sh "$COMMENTAIRE créance de puce sur co vue depuis compte pu"

./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "401IOUCP" -N "IOU co doit à pu" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "791" -N "Transferts de charge d'exploitation" -s C 
#         et dans le compte de co , il a une dette de 16E  contre un ajout de ch. "ch transférée (sans typologie)
#  co
#  65555dx	|            charge dans ta face par transfert
# 		| 411IOUCPcx		... pas encore payée " 411(dette fou) IOU  co doit à pu"
UTIL="co"

./comentaire.sh "$COMMENTAIRE créance de puce sur co vue depuis compte co"

./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "65555EDF" -N "Quote-part de charges sur opérations communes - EDF" -s D
./journal -u "$UTIL" -l "$LIB" -m "$NVMONTANT" -n "411IOUCP" -N "IOU co doit à pu" -s C
UTIL="pu"

;;
	*) echo "util $UTIL pas prévu"
		;;

esac
commentaire



./bal


