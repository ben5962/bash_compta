#!/bin/bash
# ne doit être sourcé que dans les fichiers extérieurs faisant appel aux commandes. les commandes ne doivent
# pas être invoquées directement
#. ./compta.conf
CALLER=`basename $0`
TEMP="tmp"
SUCCES=0
ECHECBAL=200


#NETTOYAGE DU FICHIER TEMPORAIRE D ECRITURE
#trap "{ echo \"TRAP: recu signal EXIT\"; }" EXIT
#trap "{ echo \"TRAP: nettoyage du fichier tempoaire d écriture: $TEMP\"; rm -f $TEMP; exit 255; }" SIGINT SIGTERM SIGCHLD EXIT
# faire un trap de nettoyage si le caller est creetache et qu'on en sort EXIT
# faire un trap de nettoyage si ctrl d ou ctrl c pour dégager les ficheir teporaires SIGTERM SIGINT


trap "{ if [ \"$FUNCNAME\" != \"\" ]; then echo \"DEBUG: TRAP: SORTIE DE fonction $FUNCNAME\"; else echo \"DEBUG: TRAP: sortie de CALLER $CALLER\"; exit 255; fi;    }" EXIT


function usage()
{
if [ "$CALLER" = "journal" ]; then
	echo "ERR: $FUNCNAME: USAGE: $CALLER [-T(est seul)] [-d date] -u(til) nomutil 	-n(nummcompte) -N(omcompte) -s(ensope)D|C -m(ontantope) -l(ibelleope)"
elif [ "$CALLER" = "depart" ]; then
	echo "ERR: $FUNCNAME: USAGE: creation compte: $CALLER [-T(est seul)] -u(tilisateur) <nom util> -d|--depart <val depart>"

elif [ "$CALLER" = "solde" ]; then
	echo "ERR: $FUNCNAME: USAGE: calcul soldes: $CALLER sans param"

elif [ "$CALLER" = "courses" ]; then
	echo "ERR: $FUNCNAME: USAGE: $CALLER [-T(est seul)] -u(til) <nomutil> -m(ontant) <montant ope> [-d|--date <ladate en anglais ou AAAA-MM-J>"
else
	echo "ERR: $FUNCNAME: $CALLER: operateur non implemente. essayez journal depart ou courses, coursesco, coursespu, coursescohier"


fi
echo "ERR: $FUNCNAME: je vais maintenant quitter avec un code d erreur"
exit 1
}


function ERR(){
#"affiche la nature du message d'erreur" 
#"et renvoie code d'erreur non nul"
echo "INFO: entrée dans ERR"
echo "INFO : parametres passes à err : $@"
USAGE="ERR -m <message> -n <num erreur>" #chaine faisant doc et msg err usage
aumoinsunarg "$@"
while getopts ":m:n:f:" erropt
do
	case $erropt in
		f) FONC="${OPTARG}";;
		m) MESSAGE="${OPTARG}";;
		n) NUMBER="${OPTARG}";;
		*) echo "ERR parse des parms de ${FUNCNAME} : param ${OPTARG} pas implémenté";
			usage "${USAGE}";; #balancer msg erreur usage par appel a usage
		esac
done
shift $(( ${OPTIND} - 1 ))

echo "ERR : ${FONC} : $MESSAGE"
echo "ERR : je vais maintenant sortir avec un code d'erreur de $NUMBER"
exit "$NUMBER"

}


function aumoinsunarg(){
E_OPTERR=65
if [ "$#" -eq 0 ]
then # il faut au moins un arg
	echo "ERR: $FUNCNAME : il faut au moins un arg pour $CALLER"
	usage
fi
}


FICHIERDEST="compta.txt"
DEBUG=1
FORCE=1
function ajouteentree(){

while getopts ":u:n:N:s:m:l:T-:d:F" OptionReconnue
do
	case $OptionReconnue in

		- ) echo "ERR: $FUNCNAME: options longues pas encore pretes pour ajouteentree"; 
			usage;; 
		F ) FORCE=0 ;;
		T ) DEBUG=0;;
		d ) LADATE=$(date --rfc-3339='date' --date="${OPTARG}");; 
		u ) UTIL=${OPTARG} ;;
		n ) NUMCOMPTE=${OPTARG};;
		N ) NOMCOMPTE=${OPTARG};;
		s ) if [ "${OPTARG}" != "C" ] && [ "${OPTARG}" != "D" ]
			then 
				echo "ERR: $FUNCNAME: param SENSOPE :le param s(ensope) requiert\
				       	pour arg soit D(ebit) soit C(redit)"
				exit 1
			else 
				SENSOPE=${OPTARG}
		fi;;
		m ) MONTANTOPE=${OPTARG};;
		l ) LIBOPE=${OPTARG};;
		? ) echo "ERR: $FUNCNAME: parseargs: option ${OPTARG}" inconnue; usage;;
		: ) echo "ERR: $FUNCNAME: parseargs: une option est requise pour ${OPTARG}"; usage;;
	        * ) echo "ERR: $FUNCNAME: parseargs: alors là je ne vois pas ce qui a pu se passer"; 
		usage;;	
	esac
done
shift $(($OPTIND - 1))

echo "INFO: $CALLER: $FUNCNAME: verification du fait que toutes les variables nécessaires existent"
UTIL=${UTIL:-ERREURCHPVIDE}
NUMCOMPTE=${NUMCOMPTE:-ERREURCHPVIDE}
NOMCOMPTE=${NOMCOMPTE:-ERREURCHPVIDE}
SENSOPE=${SENSOPE:-ERREURCHPVIDE}
MONTANTOPE=${MONTANTOPE:-ERREURCHPVIDE}
LIBOPE=${LIBOPE:-ERREURCHPVIDE}
LADATE=${LADATE:-`date --rfc-3339='date'`} 
echo "INFO: $CALLER: $FUNCNAME: formatage de la chaine à saisir dans le journal"
ENTETE="date:util:numcompte:nomcompte:sensope:montantope:libope"
ENTREE="$LADATE:$UTIL:$NUMCOMPTE:\"$NOMCOMPTE\":$SENSOPE:$MONTANTOPE:\"$LIBOPE\""

if [ "${FORCE}" -eq "0" ];
then	
	echo "INFO: $CALLER: $FUNCNAME: $FUNCNAME appelé avec FORCE vallant ${FORCE}"
	echo "INFO: $CALLER: $FUNCNAME: donc pas de vérif dans la valeur des parametres"
	echo "INFO: $CALLER: $FUNCNAME: c'est utile pour creer des modeles generiques"
	echo "DEBUG: $CALLER: $FUNCNAME: création du fichier d'écriture temporaire $TEMP"
	touch "$TEMP"
	if [ -e "$TEMP" ];
		then 
			echo "DEBUG: $CALLER: $FUNCNAME: le fichier temporaire $TEMP existe"
		else 
			echo "ERR: $CALLER: $FUNCNAME: le fichier temporaire $TEMP n'existe pas"
	       	usage
       fi	       
	echo "INFO: $CALLER : $FUNCNAME: écriture dans le fichier temporaire $TEMP"	
       echo "$ENTREE" > "$TEMP"
else
	echo "INFO: $CALLER: $FUNCNAME: $FUNCNAME appelé avec FORCE vallant ${FORCE}"
	echo "INFO : $CALLER : $FUNCNAME : donc vérif des params vides"
	if [ "${UTIL}" = "ERREURCHPVIDE" ] || [ "${NUMCOMPTE}" = "ERREURCHPVIDE" ];
	then
		echo "ERR: $CALLER :$FUNCNAME: l un des champs nécessaires est vide"
		echo "ERR: $CALLER: $FUNCNAME: $ENTETE"
		echo "ERR: $CALLER: $FUNCNAME: $ENTREE"
		echo "ERR: $CALLER :$FUNCNAME: je vais donc sortir en code err \
			et afficher usage cmd" 
		usage
	fi
	
	
fi

if [ "${DEBUG}" -eq 0 ]; then
	echo "INFO : $CALLER: $FUNCNAME: DEBUG VAUT ${DEBUG}"
	echo "INFO : $CALLER: $FUNCNAME: 0 -> VRAI 1-> FAUX"
	echo "INFO : $CALLER: $FUNCNAME: lanchement en mode DEBUG: affichage seul pas ecriture fich"
	echo "DEBUG: $CALLER: $FUNCNAME: BASH_SUBSHELL vaut $BASH_SUBSHELL"
	echo "DEBUG: $CALLER: $FUNCNAME: BASHPID vaut $BASHPID"
	echo "OKAY : $CALLER: $FUNCNAME: $ENTREE"
else  
	if [ ! -e "${FICHIERDEST}" ]; then
		echo "INFO: $FUNCNAME: FICHIERDEST EXISTEPAS. je le cree"
		echo "${ENTETE}" > "${FICHIERDEST}"
	fi
	echo "OKAY : $CALLER : $FUNCNAME: ecriture dans $FICHIERDEST"
	echo "OKAY : $CALLER : $FUNCNAME: de ${ENTREE}" 
	echo "${ENTREE}" >> "$FICHIERDEST"

fi
if [ -e "$FICHIERDEST" ];  then
	echo "INFO: $FUNCNAME: le fichier $FICHIERDEST a bien ete créé"
else
	echo "INFO: $FUNCNAME: le fichier $FICHIERDEST existe pas"
fi

}


function depart()
{
echo "INFO : entree dans $FUNCNAME"
while getopts ":u:d:-:T"  OPTIONS_dep
do
	case $OPTIONS_dep in
		T) DEBUG=0;;
		u) UTILISATEUR=${OPTARG};;
		d) VAL_DEPART=${OPTARG};;
		-) LONGOPT="${OPTARG%%=*}"; LONGARG="${OPTARG#*=}";
			case $LONGOPT in 
				depart) VAL_DEPART=${LONGARG};;
				*) echo "option longue pas permise  -- $LONGOPT";
					usage;;
			esac	
			;;
	esac
done
shift $(($OPTIND - 1 ))

if [ "${DEBUG}" -eq 0 ]; then
echo "INFO: $FUNCNAME : param -T passé à $FUNCNAME donc DEBUG."
echo "INFO: $FUNCNAME : DEBUG vaut: ${DEBUG}. 0->VRAI"
echo "INFO: $FUNCNAME: ouverture compte 1/2 : ajout de la partie bq " 
echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 512 -N "Banque" -s D \
	-m ${VAL_DEPART:-ERREURCHPVIDE} -l "ouverture compte" \
       	-T

echo "INFO: $FUNCNAME: ouverture compte 2/2 : ajout de la partie capital "
echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 101 -N "Capital social" -s C \
	-m ${VAL_DEPART:-ERREURCHPVIDE} -l "ouverture compte"  \
	-T
else
echo "INFO: $FUNCNAME: ecriture compte 1/2: ajout partie bq"
echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 512 -N "Banque" \
	-s D -m ${VAL_DEPART:-ERREURCHPVIDE} -l "ouverture compte"

echo "INFO: $FUNCNAME: ecriture compte 2/2: ajout partie capital"
echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 101 -N "Capital social" \
	-s C -m ${VAL_DEPART:-ERREURCHPVIDE} -l "ouverture compte" 
	
fi

}


function calculesolde(){
#TODO fonction en cours d'écriture
#POUR CHAQUE UTILISATEUR FAIRE
 #existence fichier compta sinon erreur et sortie
 echo "INFO: $CALLER : entree dans :$FUNCNAME"
 if [ ! -e "${FICHIERDEST}" ];then 
	echo "ERR $CALLER: $FUNCNAME: le fichier ${FICHIERDEST} existe pas"
	echo "je sors avec msg erreur"
        usage
else	
	echo "INFO : $CALLER : $FUNCNAME : $FICHIERDEST existe, on continue" 
	echo "DEBUG : $CALLER : $FUNCNAME : les utilisateurs uniques de $FICHIERDEST sont"
	gawk -F: 'NR>1{print $2}' ${FICHIERDEST} |sort |uniq
	echo "DEBUG : $CALLER : $FUNCNAME les premieres depenses du cpte..." 
	# ajouter depenses courses et depenses post-datees
	# avant de continuer
fi
}



function courses(){
DEBUG=1
echo "INFO : entree dans $FUNCNAME"
while getopts ":u:d:-:m:T"  OPTIONS_dep
do
	case $OPTIONS_dep in
		T) DEBUG=0;;
		u) UTILISATEUR=${OPTARG};;
		d) LADATE="${OPTARG}";;
		m) MONTANT=${OPTARG};;
		-) LONGOPT="${OPTARG%%=*}"; LONGARG="${OPTARG#*=}";
			case $LONGOPT in 
				date) LADATE="${LONGARG}";;
				*) echo "option longue pas permise  -- $LONGOPT";
					usage;;
			esac	
			;;
	esac
done
shift $(($OPTIND - 1 ))
LADATE="${LADATE:-PASRENSEIGNEE}"
echo "INFO: $FUNCNAME : LADATEVAUT $LADATE"
if [ "$LADATE" = "PASRENSEIGNEE" ];
then
	if [ "${DEBUG}" -eq 0 ]; then
		echo "INFO: $FUNCNAME : param -T passé à $FUNCNAME donc DEBUG."
		#echo "INFO: $FUNCNAME : DEBUG vaut: ${DEBUG}. 0->VRAI"
		echo "INFO: $FUNCNAME: courses alimentaires 1/2 :  augmentation frais de courses" 
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 6257 -N "frais restauration" \
			-s D 	-m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires" \
       			-T

		echo "INFO: $FUNCNAME: courses alimentaires 2/2 : diminution du compte en bq "
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 512 -N "Banque" -s C \
			-m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires"  \
			-T
	else
		echo "INFO: $FUNCNAME: courses alimentaires 1/2: augmentation frais de courses"
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 6257 -N "frais restauration" \
		-s D -m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires"

		echo "INFO: $FUNCNAME: courses alimentaires 2/2: diminution du compte en bq"
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 512 -N "Banque" \
			-s C -m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires" 
	
	fi

else
	if [ "${DEBUG}" -eq 0 ]; then
		echo "INFO: $FUNCNAME : param -T passé à $FUNCNAME donc DEBUG."
		#echo "INFO: $FUNCNAME : DEBUG vaut: ${DEBUG}. 0->VRAI"
		echo "INFO: $FUNCNAME: courses alimentaires 1/2 :  augmentation frais de courses" 
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 6257 -N "frais restauration" \
			-s D 	-m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires" \
			-d "${LADATE}" \
			-T

		echo "INFO: $FUNCNAME: courses alimentaires 2/2 : diminution du compte en bq "
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 512 -N "Banque" -s C \
			-m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires"  \
			-d "${LADATE}" \
			-T

	else
		echo "INFO: $FUNCNAME: courses alimentaires 1/2: augmentation frais de courses"
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 6257 -N "frais restauration" \
		-s D -m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires" \
		-d "${LADATE}"

		echo "INFO: $FUNCNAME: courses alimentaires 2/2: diminution du compte en bq"
		echo "INFO: $FUNCNAME: appel de journal depuis $FUNCNAME"
		journal -u ${UTILISATEUR:-ERREURCHPVIDE} -n 512 -N "Banque" \
			-s C -m ${MONTANT:-ERREURCHPVIDE} -l "courses alimentaires" \
			-d "${LADATE}"
	
	fi



fi

} #fin de courses






function coursesco(){
courses -u co -m $1 
}

function coursespu(){
courses -u pu -m $1
}

function coursescohier(){
courses -u co -m $1 --date="yesterday"

}


function loyerpu(){

CHAINE="#GENERE PAR CMDLOYERPU\n"
CHAINE="${CHAINE}1/3 pmt loyerpar puce\n"
echo -e "${CHAINE}"


}



function creetypetache(){


#NECESSAIRE: NOMFICHIER 
# menu qui boucle pour chaque ligne jusque considere que fini (f + entree)
echo "DEBUG: $CALLER: $FUNCNAME: BASH_SUBSHELL vaut $BASH_SUBSHELL"
echo "DEBUG: $CALLER: $FUNCNAME: BASHPID vaut: $BASHPID"
echo "nom du fichier?"
read FICHIER
FICHIER="${FICHIER}".mod
if [ -e "${FICHIER}" ];
then
	echo "ERR : $FUNCNAME: le fichier $FICHIER existe déjà"
	echo "ERR : $FUNCNAME: je ne vais pas écraser un fichier preexistant."
	echo "ERR : $FUNCNAME: je vais donc sortir avec un msg d'erreur non nul"
	echo "ERR : $FUNCNAME: en lancant usage, le raccourcis le plus rapide"
	usage
else
	echo "INFO: $FUNCNAME: le fichier $FICHIER n'existe pas encore"
	echo "INFO: $FUNCNAME: en le creant je n'ecraserai donc aucune info existante"
	echo "INFO: $FUNCNAME: je vais donc le créer"
fi
echo "INFO: $FUNCNAME: creation de $FICHIER"
touch "${FICHIER}"
if [ -e "${FICHIER}" ];
then 
	echo "INFO: $FUNCNAME: ok $FICHIER cree."
else
	echo "ERR: $FUNCNAME: $FICHIER non cree. je vais sortir avec un msg ERR non nul"
	echo "ERR: $FUNCNAME: en appelant usage, le raccourci le plus rapide"
	usage

fi
PREDBOUCLER="True"
while [ "${PREDBOUCLER}" = "True" ];
do
	echo "$FUNCNAME: boucle lignes: rien pour l'instant"
	if [ -e "${FICHIER}" ];
	then
		echo "DEBUG: $FUNCNAME : boucle ligne : $FICHIER EXISTE. \
			on peut donc écrire une ligne dedans"
		echo "DEBUG: $FUNCNAME : boucle lignes : boucle sur les params pour 1 ligne"
		echo "DEBUG: $FUNCNAME : boucle lignes : rien pour l'instant"
		echo "DEBUG: $FUNCNAME : boucle lignes : appel de journal -T -F pour verif"
		echo "INFO: $FUNCNAME : elemt commun a chq ligne: saisie du nom de \
			l'opération"
		# éléménts commun:
		# -l "$LIBELLEOPE" -d "$LADATE" 
		# -T pour le debug sinon écrit dans compta.txt
		# -F pour le force sinon refuse les champs vides
		# -u "VIDE"
		# -d "VIDE"
		# -
		# date:util:sensope:numcpte:nomcompte:montant:libelle
		# journal u n N s m l T F
		# -u "VIDE" -d "VIDE" -T -F 
		read LIBELLEOPE
		echo "DEBUG: $FUNCNAME: boucle sur comptes à débiter"
		echo "DEBUG: $FUNCNAME: taper un numero de compte à débiter ou F pour fin"
		echo "DEBUG: $FUNCNAME: et passer aux comptes à crediter"
		while [ "$NUMCOMPTE" != "F" ];
		do
			echo "DEBUG: $FUNCNAME: boucle de saisie des cdts. (F pour sortir)"
			echo "DEBUG: $FUNCNAME: saisir un num de compte débité \
				et son nom ou F"
			read NUMCOMPTE
			if [ "$NUMCOMPTE" != "F" ];
			then
				read NOMCOMPTE
				journal -u "vide" -n "$NUMCOMPTE" -N "$NOMCOMPTE" \
					-s D -m "vide" -l "$LIBELLEOPE" -T -F
				cat "$TEMP" >> "${FICHIER}"
				echo voyons le contenu de "${FICHIER}:"
				cat "${FICHIER}"

			fi
		done
		echo "DEBUG: $FUNCNAME: boucle lignes : récupération de la valeur de entree"
		echo "DEBUG: $FUNCNAME: en dehors de journal pour voir si utilisable sans"
		echo "DEBUG: $FUNCNAME: modif de journal"
		echo "DEBUG: $FUNCNAME: en dehors de journal, ENTREE vaut $ENTREE"
		echo "DEBUG: $FUNCNAME: merche pas, vais donc utiliser le pattern fich temp"
		echo "DEBUG: $FUNCNAME: + nettoyage à la fin."
		echo "DEBUG: $FUNCNAME: lecture du fichier d'écriture temporaire $TEMP"
		cat $TEMP

	fi
	echo "DEBUG: $FUNCNAME: et maintenant passage du param PREDBOUCLER\
	       	à False pour sortir de la boucle"
	PREDBOUCLER="False"
	echo "DEBUG: $FUNCNAME: boucle lignes: \
		et maintenant je vais sortir avec un msg ERR non nul"
	usage
done




}

function getusers(){
# si le fichier d'acces existe, alors user est le champ numero 2
if [ -e "${FICHIERDEST}" ];
then
	#echo "DEBUG: $FUNCNAME: le fichier $FICHIERDEST existe, on va pouvoir le parser"
	CHAMPUTIL="$(  echo -e "$(tail -n +2 $FICHIERDEST)" | gawk -F : '{ print $2; }'  | sort | uniq | tr '\n' ' ')"
        #echo "$FUNCNAME: les utilisateurs sont : $CHAMPUTIL"
	echo "$CHAMPUTIL"	
else
	echo "DEBUG: $FUNCNAME: le fichier $FICHIERDEST n'existe pas. on ne peut donc pas le parser"
	echo "DEBUG: $FUNCNAME: je vais sortir avec un msg d'érreur non nul en invoquant usage"
	usage

fi



}

function filtre(){
# usage: filtre util "nomutil"
# renvoie les lignes comptenant le champ util

# verifier existence du fichier dans lequel recherche va se faire
# si fichier existe pas renvoyer message d'erreur non nul et quitter
echo "INFO : entree dans $FUNCNAME"
echo "INFO : test  existence $FICHIERDEST"
if [ ! -e "${FICHIERDEST}" ]; 
then 
	ERR -m "le fichier ${FICHIERDEST} existe pas" -f "${FUNCNAME}" -n 25
fi
echo "DEBUG : tentative d'util d'un nom de commande préfixant la cli"
echo "DEBUG : genre filtre util -u co"
echo "DEBUG : je prends le premier param pour voir"

case $1 in
	util)
#if [ "$1" == "util" ];   # DEBUT DE FILTRE UTIL
#then 
	#echo "DEBUG :le premier param vaut $1"
	#echo "DEBUG: entree dans clipase/filtre de $FUNCNAME"
	# echo "OPTIND vaut $OPTIND" #1
	shift 1 # zapper le nom de la commande "util" pour le garder que -u qqch et parser.
	#echo "OPTIND vaut $OPTIND"
	#echo "args valait $@"
	#echo "maintenant \$1 vaut: $1"
	#shift $(( $OPTIND - 1 ))
	#echo "et maintenant $1"
	#echo "OPTIND vaut $OPTIND"
	while getopts ":u:" OPTS
		do
		case $OPTS in
			u) UTIL=${OPTARG};;
			*) ERR -m "le param ${OPTARG} pas implémenté" -f "${FUNCNAME}" -n 30;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
# lancement de la commande puisque tout est en ordre
	gawk -F : "\$2 == \"${UTIL}\"" "${FICHIERDEST}";;


	*) 	echo "le filtre $1 n'est pas implémenté"
# fi # FIN DE FILTRE UTIL

esac
}






function essaifiltre(){
# usage: filtre <params> <fichier>
# -u nomd'util -> renvoie lignes comportant utilisateur valide
#while getopts ":u:" OptionRec
#do
#	case $OptionRec in
#		u) UTILI="${OPTARG}" ;;

#		*) echo "${OPTARG}: pas implemente";;

#	esac
#done
#shift $(( ${OPTIND} - 1 ))
# si c'est util, lancer le grep avec la recherche du champ util
# j'aimerais un accesseur qui donne le bon format en respectant 
# l'entete de fichier: 
# un entete UTIL:a:b
# donnerait une accession via: --UTIL="aa"
#           ou -a="qsfdq"
#           ou -b="dqfds"
# pour l'instant essai avec AA.txt
# DEBUT BAC A SABLE
#BAS: creation données
echo "DEBUG: $FUNCNAME: BAC A SABLE"
FICHIER="essai.txt" #note: dernier arg: nomfichier=${!#} et si existepas val par def ${1:-Defaultval}
touch $FICHIER
echo ":u:d:m:" > $FICHIER # on s'en tient à un seul caractere pour l'instant chp longs apres.
echo "corentin:$(date --rfc-3339='date'):16.09" >> $FICHIER
echo "DEBUG : $FUNCNAME contenu de $FICHIER:"
cat $FICHIER
#BAS : récupération param: 
#premiere ligne fichier formatee: sépa champs = ":"
CHPS=$(head -n 1 $FICHIER)

# getops recoit le bloc premiere ligne
while getopts "${CHPS}" Opts
# on recupere donc chaque clef dans une chaine Opts
# qui vaut je suppose chaque param séparé d'un espace. 
# pas sur en fait
echo "DEBUG: $FUNCNAME : Opts vaut $Opts"
do
	# splitter les champs dans une array
	# ben non pas besoin
	# bensi gencode
	function gencodecase(){
	CHAINECASE=""
		while IFS=':'; read CHAMPS; do
			 for i in "${CHAMPS[@]}"; do
				 CHAINECASE="${CHAINECASE}\n$i\) $i=${OPTARG:-$iVIDE};;\n"
			 done
			 CHAINECASE="${CHAINECASE}\n\*\) echo \"$FUNCNAME: ERR: pas implémenté ${OPTARG}\""
		
		 done<<<"${Opts}"
		 echo "$CHAINECASE" 
	}
	echo "DEBUG: $FUNCNAME: le resultat de l'appel de gencodecase vaut: "
	echo "DEBUG: $FUNCNAME: $(gencodecase<<"$Opts")"
	echo "DEBUG: $FUNCNAME: son appel donne: "
	#case $Opts in
	#	$( gencodecase ) 
	#esac


			

done
shift $(( ${OPTIND} - 1 ))		
#creation dyna des options avec premiere ligne du fichier


}


function getsumcredits(){
if [ -e "${FICHIERDEST}" ];
then
	SOMMECDT=`grep ":C:" compta.txt | gawk -F :  'BEGIN { A = 0; } { A = A + $6; }  END { print A; }'`
	echo $SOMMECDT
else
	echo "ERR: $FUNCNAME: $FICHIERDEST existe pas"
fi

}



function getsumdebits(){
if [ -e "${FICHIERDEST}" ];
then
	SOMMECDT=`grep ":D:" compta.txt | gawk -F :  'BEGIN { A = 0; } { A = A + $6; }  END { print A; }'`
	echo $SOMMECDT
else
	echo "ERR: $FUNCNAME: $FICHIERDEST existe pas"
fi

}


function printsumsDC(){
gawk -F : 	'BEGIN	{ D = 0 ; C = 0 ; print "cumuls"; print "-----------"; }\
    			{ 
				if ( $5 == "D")  \
					D = D + $6 ; \
					if ( D == C) print "D:",D,"C:",C, "DERNIER EQUILIBRE: LIGNE ", NR ;\
					else print "D:",D,"C:",C;
				if ( $5 == "C") \
					C = C + $6 ;\
					if ( D == C ) print "D:",D,"C:",C, "DERNIER EQUILIBRE: LIGNE ", NR ;\
					else 
						print "D:",D,"C:",C;
			}\
		END 	{ print "sommes D   C"; print "----------"; print D, C; print "derniere ligne equilibree: ",L; }' $1

}


function bal(){
C=$(getsumcredits)
D=$(getsumdebits)
echo "DEBUG: $FUNCNAME: credits: $C, débits: $D"
if [ "$C" != "$D" ];
then 
	echo "INFO: $FUNCNAME: credits et débits diffèrent, il y a une erreur"
	printsumsDC ${FICHIERDEST} 
	exit $ECHECBAL
else
	echo "INFO: $FUNCNAME: credits et debits identiques, les comptes sont équilibrés"
	exit $SUCCES
fi

}




function iou(){
COURSESTOTAL=$(grep `date +%Y-%m` ${FICHIERDEST} | grep 6257 | grep D | gawk -F : 'BEGIN { A = 0;} { A = A + $6 } END { print A;}')

MOY=$( echo "scale = 2; ${COURSESTOTAL} / 2;" |bc ) 

COURSESPUCE=$(grep `date +%Y-%m` ${FICHIERDEST} | grep 6257 | grep D | grep pu\
	| gawk -F : 'BEGIN { A = 0; } { A = A + $6 } END { print A;}')

COURSESCO=$(grep `date +%Y-%m` ${FICHIERDEST} | grep 6257 | grep D | grep co\
	| gawk -F : 'BEGIN { A = 0; } { A = A + $6 } END { print A; }')

echo "DEBUG: $FUNCNAME: COURSESTOTAL vaut ${COURSESTOTAL}, MOY vaut ${MOY}, COURSESPUCE vaut ${COURSESPUCE}, COURSESCO vaut ${COURSESCO}"
echo "DEBUG: $FUNCNAME: problème: l'accesseur des lignes corentin ne prend pas en compte le "
echo "	champ utilisateur co mais toutes les lignes contenant co "
echo "	ce qui donne des résultats erronés "
echo "	il faut une vraie commande qui n'affiche que les lignes où le champ qui va bien "
echo "	vaut co: filtre"
}


case $CALLER in
	journal ) echo "INFO: CLIPARSE: les parametres: $@ sont passes a journal"; 
		aumoinsunarg "$@"; 
		ajouteentree "$@" ;;

	depart ) echo "INFO: CLIPARSE: les parametres: $@ sont passes a dep"; 
		aumoinsunarg "$@"; 
		depart "$@" ;;

	soldes ) echo "INFO: CLIPARSE: calculsolde lance sans param"; 
		calculesolde ;;

	courses ) echo "INFO: CLIPARSE: les params $@ st passes a courses"; 
		aumoinsunarg "$@";
		courses "$@";;
	coursesco) echo "INFO: CLIPARSE: les params $@ st passes a courseco";
		aumoinsunarg "$@";
		coursesco "$@";;
	
	coursespu) echo "INFO: CLIPARSE: les params $@ st passes a coursepu";
		aumoinsunarg "$@";
		coursespu "$@";;
	coursescohier) echo "INFO: CLIPARSE: les params $@ st passes a coursecohier";
		aumoinsunarg "$@";
		coursescohier "$@";;
	loyerpu) loyerpu;;
	
	creetache) creetypetache;;

	getusers) getusers;;
	filtre) echo "INFO: CLIPARSE: les param $@ sont passés à filtre";
		aumoinsunarg "$@";
		filtre "$@";; 

	bal) bal;;
	iou) iou;;
	ERR) echo "INFO :CLIPARSE: les params $@ sont passés à ERR";
		ERR "$@";;


	* ) echo "ERR: CLIPARSE: appelant $CALLER non reconnu";;
esac
#TODO : getparamutil doit etre parametre pour etre universel : getparam util|compte | comptutil $util | sDu(til)cpt  $util $cpte 
# sCu(itl)cpt $util cpte | opesutilcpteD | opesutilcpteC 


#DONE : ajouter une commande de vérif de balanc
#TODO : gencodecase marche PAS!!!!!
