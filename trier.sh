#!/bin/bash
# trie les champs par ordre croissant de valeur
# pour permettre ensuite une élimination ligne par ligne
function usage(){
echo "$0 <fichier>"
echo "tri par ordre numerique croissant"
echo "selon la valeur de l operation"
echo "but: pour une meme periode"
echo "on espere que cela permet d eliminer un maximum"
echo "d operations communes a bq et a compta"
}

function aumoinsun(){
ERR_NB_ARG="65"
echo "INFO : $0 lancé avec $# arguments"
if [ "$#" -lt 1 ];
then 
    echo "ERR: il faut au moins un arg pour $0"
    echo "ERR: je vais sortir avec un msg d erreur de $ERR_NB_ARG"
    usage
    exit $ERR_NB_ARG
fi
}

aumoinsun "$@"
sort --numeric-sort \
    --key="6" \
    --field-separator=":"\
    "$@"

