#!/bin/bash
# rapprochement bancaire
ERR_NB_PARAM=65
ERR_FICHIER_EXISTEPAS=100
ERR_PAS_512=200




#################################
# 1 VERIF DES ENTREES UTILISATEUR
##################################


# prend deux fichiers au format compta.txt en entree
#prendre deux parametres
#si nb param <2 sortir 
function usage(){ echo "$0 <fich cpta|512 trié[montant]> <bq trié[montant]>"; }
[ $# -lt 2 ] && echo "ERR: $0: nombre de param insuffisant: 2 attendus $# obtenus" \
&& exit  $ERR_NB_PARAM
F_CPTA="$1"
F_BQ="$2"
#verifier que les deux param correspondent à des ficheirs 
# restreints aux comptes bancaires
#pour chaque fichier faire...
# pour chaque ligne faire..
#  si champ_num_cpte(ligne) different de 512 produire erreur et sortir
# tries par ordre de montant croissants

# une fonc pour choper les num de comptes
function getnumcompte(){
# lignes non vides | 3eme champ
 gawk 'NF' | gawk -F: '{print $3}' 
}
# proof of concept
#getnumcompte <$F_CPTA
#getnumcompte <$F_BQ


# si les num de comptes diff de 512 on sort 
function err_sinumcompte_pasbq(){
USAGE="$FUNCNAME <fich_cpta|512>"
[ $# -ne 1 ] && echo "ERR: $FUNCNAME a recu $# parm necess 1 param: $USAGE" && exit $ERR_NB_PARAM
FICHIER="$1"
[ ! -e "$FICHIER" ] && echo "ERR: $FUNCNAME: fichier $FICHIER existe pas " && exit $ERR_FICHIER_EXISTEPAS
while read F 
do
    [ "$F" != "512" ] && echo "ERR: $FUNCNAME: sur fichier $FICHIER ligne $F differe de 512" && exit $ERR_PAS_512
done  <   <(getnumcompte <"$FICHIER")
}

# test des err pas512
#err_sinumcompte_pasbq "compta.txt"
# test de fichier pas existant
# err_sinumcompte_pasbq "sqmfldqjkfjsld"

#echo "fcompta $F_CPTA    fbq $F_BQ"
#err_sinumcompte_pasbq <$F_CPTA
#err_sinumcompte_pasbq <$F_BQ
#ok 

###################################################################
# 2. afficher les lignes presentant les memes soldes en cpta et bq
###################################################################
# bah. 1 lister les soldes uniques 2 greper .. simple.
# recuperer les montants
function getmontantope(){
# lignes non vides | 6eme champ
 gawk 'NF' | gawk -F: '{print $6}' 
}

# verif que bon champ
# getmontantope <$F_CPTA
# ok
# obtenir un fichier contenant uniquement les champs d un utilisateur
function getlinesfromuser(){
UTIL="$1"
gawk -v util="$UTIL" -F: "\$2 == util"
}


# test du concept
# cat compta.txt |getlinesfromuser "co"
# okay

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
# fonction tri numerique par val csste
# fonction tri numerique par date

# tr en here_doc
function usage(){
cat << EOD
"$0 <fichier>"
"tri par ordre numerique croissant"
"selon la valeur de l operation"
"but: pour une meme periode"
"on espere que cela permet d eliminer un maximum"
"d operations communes a bq et a compta"
EOD
}


function aumoinsun(){



if [ "$DEBUG" ]; then echo "DEBUG : $0 lancé avec $# arguments"; fi
if [ "$#" -lt 1 ];
then 
    echo "ERR: il faut au moins un arg pour $0"
    echo "ERR: je vais sortir avec un msg d erreur de $ERR_NB_ARG"
    usage
    exit $ERR_NB_ARG
fi
}


aumoinsun "$@"
function triparmontant(){


cat << EOD
"$0 <fichier>"
"tri par ordre numerique croissant"
"selon la valeur de l operation"
"but: pour une meme periode"
"on espere que cela permet d eliminer un maximum"
"d operations communes a bq et a compta"
EOD


aumoinsun "$@"
sort --numeric-sort \
    --key="6" \
    --field-separator=":"\
    "$@"
}
