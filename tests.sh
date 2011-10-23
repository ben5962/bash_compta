#!/bin/bash
. ./rapprochement_bancaire.sh


TEST="1"
# proof of concept
if [ "$TEST" == "1" ];
then
	echo "essai de la fonction de récup des comptes sur compta.txt"
	# TODO: pb premiere ligne pas compte
	getnumcompte compta.txt |tr '\n' ' '
echo " "
echo "essai de la fonction de récup des comptes sur bq.txt"
#getnumcompte <$F_BQ
	getnumcompte bq_trie.txt |tr '\n' ' '
echo " "
fi

if [ "$TEST" == "1" ];
then
F_CPTA="compta.txt"
F_BQ="bq_trie_sans_prem_ligne.txt"
# FAIL VOLONTAIRE OK
#echo "test des err pas512"
#err_sinumcompte_pasbq "compta.txt"

#FAIL VOLONTAIRE OK
#echo "test de fichier pas existant"
#err_sinumcompte_pasbq "sqmfldqjkfjsld"

	echo "test de non-sortie sur des valeurs correctes de fichier compta |512"
#err_sinumcompte_pasbq <$F_CPTA
err_sinumcompte_pasbq $F_BQ
echo "fin du test de non-sortie. toujours là? oui? on continue!"
## verif que bon champ
echo "verif du bon fonctionnement de getmontantope"
echo " le test reussit si cela affiche des chiffres"
cat $F_CPTA |sed '1 s/.*$//' |getmontantope |tr '\n' ' '
echo " "
# ok
#ok
fi



if [ "$TEST" == "1" ]; then 
	echo "essai de modifdate.awk transforme en fonction"
	echo "tous les champs <Date posted> sont censés avoir leur date transformée selon rfc-3339=date"
	echo "si date reconnait la date alors c est bon"
	modifdateawk |grep "Date posted" | sed 's/ //g' | gawk -F'|' '{print $2;}' | tr '\n' ' ' |xargs -d " " -i -t date -d {}
fi

if [ "$TEST" == "1" ]
then
	echo "TEST lancement de cat compta.txt| getlinesfromuser co"
	echo "pour verifier que les lignes affichees ne contiennent que l util co"
	echo "le test est RATE si des champs s affichent"

cat compta.txt |getlinesfromuser "co" |grep -v "co"
        echo "meme test mais en comptant les lignes contenant co"
	echo "le test est RATE si le resultat est nul"
cat compta.txt |getlinesfromuser "co" |wc -l
fi
# okay

# tests sur triparmontant
# 1. verif de la sortie avec usage
# en cas d'absence de param
if [ "${TESTERR}" == "1" ];
then
echo "TESTERR vaut ${TESTERR}"
echo "TESTERR: triparmontant lancé sans param pour tester msg err manque param"
triparmontant 
fi
# ok
# 2. lancement avec un fichier et verif de la sortie par ordre croissant en utilisant sort.
if [ "$TEST"=="1" ];
then
	echo "TEST: triparmontant lancé avec un fichier compta.txt pour vérif tri par montant croissant"
	echo "le test fonctionne si le resultat est une suite croissante"
	triparmontant compta.txt | getmontantope |(LANG=C sort --check --numeric-sort)
	echo "résultat : $?"
	#TODO echo "si n a rien sorti c est bon: pour sort c est trie"
	echo "pour verifier la veracite du test meme chose avec du nontrie"
	echo "sort renvoie la premiere valeur non triee et sa ligne"
	getmontantope compta.txt |(LANG=C sort --check --numeric-sort )
	echo "résultat : $?"
	echo " "
fi
# ok

