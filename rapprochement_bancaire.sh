#!/bin/bash
# rapprochement bancaire
ERR_NB_PARAM=65
ERR_FICHIER_EXISTEPAS=100
ERR_PAS_512=200
SUCCES="0"
# les valeurs qu'on peut passer à 1
# avant d invoquer rapprochement_bancaire:
# DEBUG
# TESTERR pour tester que les fonctions sortent bien si param incorrects
# TEST pour tester les fonctions en env normal


###########################
#   0 utilitaires
##############################
function aumoinsun(){



if [ "$DEBUG"=="1" ]; then echo "DEBUG : $FONCTION lancé avec $# arguments"; fi
if [ "$#" -lt 1 ];
then 
    echo "ERR: il faut au moins un arg pour $FONCTION"
    echo "ERR: je vais afficher le message dutilsation de la fonction"
    usage
    echo "ERR: je vais sortir avec un msg d erreur de $ERR_NB_PARAM"
    exit $ERR_NB_PARAM
fi
}


#################################
# 1 VERIF DES ENTREES UTILISATEUR
##################################


# prend deux fichiers au format compta.txt en entree
#prendre deux parametres
#si nb param <2 sortir 
function rapprochement(){
function usage(){ echo "$0 <fich cpta|512 trié[montant]> <bq trié[montant]>"; }
[ $# -lt 2 ] && echo "ERR: $0: nombre de param insuffisant: 2 attendus $# obtenus" \
&& exit  $ERR_NB_PARAM
F_CPTA="$1"
F_BQ="$2"
##TODO ecrire la fonction de rapprochement bancaire (main)
}


#verifier que les deux param correspondent à des ficheirs 
# restreints aux comptes bancaires
#pour chaque fichier faire...
# pour chaque ligne faire..
#  si champ_num_cpte(ligne) different de 512 produire erreur et sortir
# tries par ordre de montant croissants


########################################
# FEATURE SORTIE SI NUMCOMPTE /= 512
########################################

# une fonc pour choper les num de comptes
function getallnumcomptes(){
# lignes non vides | 3eme champ
USAGE="$FUNCNAME <fichier_compta>"
[ $# -ge 2 ] && echo "ERR: $FUNCNAME a recu $# parm necess 1 param: $USAGE" && exit $ERR_NB_PARAM
if [ $# -eq 1 ]; then
FICHIER="$1"
# supprimer premiere ligne
cat "$FICHIER" |\
       	sed '1 s/^.*$//'|\
       	gawk 'NF' |\
       # afficher que le parm3 \
       gawk -F: '{print $3}'
else
# 0 param. on suppose que ca vient d un pipe.
       	sed '1 s/^.*$//'|\
       	gawk 'NF' |\
       # afficher que le parm3 \
       gawk -F: '{print $3}'
fi
}
# si les num de comptes diff de 512 on sort 


function err_sinumcompte_pasbq(){
USAGE="$FUNCNAME <fich_cpta|512>"
[ $# -ne 1 ] && echo "ERR: $FUNCNAME a recu $# parm necess 1 param: $USAGE" && exit $ERR_NB_PARAM
FICHIER="$1"
[ ! -e "$FICHIER" ] && echo "ERR: $FUNCNAME: fichier $FICHIER existe pas " && return $ERR_FICHIER_EXISTEPAS
while read F 
do
    [ "$F" != "512" ] && echo "ERR: $FUNCNAME: sur fichier $FICHIER ligne $F differe de 512" && return $ERR_PAS_512
done  <   <(getallnumcomptes "$FICHIER")
# was : done <     <(getallnumcomptes <$FICHIER) avec aucune verif du nb param de getallnumcomptes. là si. 
return $SUCCES
}


###############################################################
# 2. depuis compta.txt multi util multi comptes 
# produire un fichier compta.txt|util | 512 trié ordre csst montant opé
############################################################




#############################################################
# 3. depuis un fichier mono-utilisateur ofx
# produire un fichier bq.txt | (forcément monoutil) trié par ordre csst montant opé
###############################################################
# ./modifdate.awk |sed -n -f en_ligne.sed | ./danslordre.awk

function modifdateawk(){
ofxdump todo.ofx 2>OFXDUMP_ERR.TXT |\
	sed -e 's/: /|/' -e 's/^ *//' |\
	gawk -F"|" \
	'$1 != "Date posted"; 
	$1 == "Date posted" 	{ 
		SAUVERLALIGNEGAWK=$0;
	       	SAUVERDATEPOSTED=$1	
		#cmd="date"; print "contenu de $2 de awk: "$2; 
		SAUVERDATE=$2; 
		#cmd|getline; 
		#RESULTATCMD=$0; 
		#close(cmd); 
		#print "0) DEBUG : preuve sauvegarde ligne gawk complete : " SAUVERLALIGNEGAWK ; 
		#print "1) DEBUG :  resultat de date|getline :" RESULTATCMD; 
		#print  "=============="; 
		#tmp=(cmd" " SAUVERDATE);
		#print "2) DEBUG: preuve concatenation date et var gawk SAUVERDATE :" tmp;
		#tmp | getline;
		#RES=$0; 
		#close(tmp);
		#print "***********";
		#print "3) DEBUG: marchera pas nécessite retouche, execution ligne concaténée date et var gawk SAUVERDATE : " RES; 
		#print "-----------";
		#CMD=("date --date=\"" "$(echo \"" SAUVERDATE "\"|sed 's/CEST//')\"");
		#print "4) DEBUG: tentative de creation d une chaine complete de pipes a executer sans getlines intermediaires :" CMD; 
		#CMD|getline;
		#resres=$0;
		#close("CMD" );
		#print "5) DEBUG: resultat de l execution de la commande date --date $(date sans CEST) : " resres;
		#print "/*/*/*//*//*/*/*/*//*";
		cmd=("date --rfc-3339='date' --date=\"" SAUVERDATE "\"");
		cmd|getline;
		RES=$0;
		close(cmd);
		#print "6) DEBUG: resultat de date --date $(date avec CEST):" SAUVERLALIGNEGAWK" "RES;
		print SAUVERDATEPOSTED"| "RES;
	};'
}

# 1 test de modif date






###################################################################
# 4. afficher les lignes presentant les memes soldes en cpta et bq
###################################################################
# bah. 1 lister les soldes uniques 2 greper .. simple.
# recuperer les montants
function getmontantope(){
# lignes non vides | 6eme champ
USAGE="$FUNCNAME <fich_cpta>"
if [ "$DEBUG" == "1" ];
then
[ $# -ne 1 ] && echo "ERR: $FUNCNAME a recu $# parm necess 1 param: $USAGE" && exit $ERR_NB_PARAM
fi
if [ $# -eq 1 ];
then	
FICHIER="$1"
[ ! -e "$FICHIER" ] && echo "ERR: $FUNCNAME: fichier $FICHIER existe pas " && exit $ERR_FICHIER_EXISTEPAS
gawk 'NF' "$FICHIER" | gawk -F: '{print $6}' 
else
	#soyons tolérant envers les pipes
gawk 'NF' | gawk -F: '{print $6}'
fi
}

# obtenir un fichier contenant uniquement les champs d un utilisateur
function filtre_getlinesfromuser(){
UTIL="$1"
gawk -v util="$UTIL" -F: "\$2 == util"
}


# test du concept
# cat compta.txt |getlinesfromuser "co" |getonlybanq 
# getmontantope    := getmontants  #TODO: trier !!!
# => getmontants compta.txt
# getmontantopé bq.txt # TODO: trier !!!
# cat $(montants bq) $(montants cpta) | sort -n.... | uniq
# filtrer par montant <montant> bq
# filtrer par montant <montant> cpta



# trie les champs par ordre croissant de valeur
# pour permettre ensuite une élimination ligne par ligne
#TODO debut du chantier
# DONE fonction tri numerique par val csste
# fonction tri numerique par date

#DONE tr en here_doc



function triparmontant(){
FONCTION=$FUNCNAME
function usage(){
cat << EOD
"$FONCTION <fichier>"
"tri par ordre numerique croissant"
"selon la valeur de l operation"
"but: pour une meme periode"
"on espere que cela permet d eliminer un maximum"
"d operations communes a bq et a compta"
EOD
}


aumoinsun "$@"
# nimporte lequel des sort numeriques fonctionne
# a partir du moment ou on fournit un
# prefixe LANG=C
# ainsi le separateur de virgule pour les flottants est "." sinon
# fr_FR.utf8-> ","
LANG=C sort --numeric-sort \
    --key="6" \
    --field-separator=":"\
    "$@"
}
######################################################################
# 5. produire des opés sur les dates ds bq| mono util
# pour restreindre le rap bq à des opérations 
# postérieures au premier enregistrement du cpte de compta
##########################################################

#########################################################
# 6. produire des opés sur cpta pour effectuer les opérations 
# complémentaires EN CROYANT COMPLETEMENT LE CPTE BQ
# pour REMONTER LE TPS SUR LES COMPTES
###########################################################


