#!/bin/bash - 
#===============================================================================
#
#          FILE:  deplace_nom_fichier_dest_vers_comptaconf.sh
# 
#         USAGE:  ./deplace_nom_fichier_dest_vers_comptaconf.sh 
# 
#   DESCRIPTION:  déplace le fichier de conf vers comptaconf.sh
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Dr. Fritz Mehner (fgm), mehner@fh-swf.de
#       COMPANY: FH Südwestfalen, Iserlohn
#       CREATED: 20/11/2011 01:25:27 CET
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


# copie les modifs vers le fichier de récup des changements.

# récupère un diff pour faire un rollback
# si le changement est ok... ok y va!
# le but : pouvoir effectuer les test d'écriture dans des fichiers de test
# atomique: 
# copie des fichiers contenant compta.txt (sauf le fichier de conf) dans un répertoire récupérant les changements.
# remplacement de compta.txt par $FICHIERDEST
# avec backup
function remplacer_comptatxt(){
echo "remplacement de compta.txt par FICHIERDEST"
grep -l --exclude="compta.conf" --exclude="deplace_nom_fichier_dest_vers_comptaconf.sh" --binary-files=without-match "compta.txt" * | xargs -i sh -u -c "sed -i.sanscomptatxt -e 's/compta.txt/\"\$\{FICHIERDEST\}\"/g'  '{}'  "

cd $ICI
echo "fin de remplacement de compta.txt par FICHIERDEST"
}

function remplacement_fichierdest(){
echo "suppression des lignes FICHIERDEST="

# faire les changements sur place
grep -l --binary-files=without-match 'FICHIERDEST=' | xargs -i sh -u -c "sed -i -e 's/FICHIERDEST\=.*$/\. compta.conf/g'  '{}'"  
cd $ICI
echo "fin de suppression des lignes FICHIERDEST="
}

function ajout_source_comptaconf(){
echo "ajout de la ligne de sourcage de compta.conf"
grep -l --binary-files=without-match '$FICHIERDEST' | xargs -i sh -u -c "sed -i -e '3a. compta.conf' < '{}'"
cd $ICI
echo "fin d'ajout de la ligne de sourcage de compta.conf"
}
