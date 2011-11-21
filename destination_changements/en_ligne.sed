/ofx_proc_transaction.*/ {
# sauter la ligne ofx_proc.la supprimer du tampon. charger la ligne suivante qui expose le numero de compte 
n 
# supprimer cette ligne de numero de compte : on n 'en n'a pas besoin
s/^Account.*$// 
# supprimer cette ligne vide du tampon. charger la ligne suivante dans le tampon : le type de transaction
n 
# retoucher ce type de transaction: on ne veut que la valeur du type de
# transaction, on va se passer du titre de la colonne:
s/Transaction type|//
# on va maintenant retoucher la valeur de la ligne type de transaction:
# /POS:.*/CB sabot magasin/
s/POS:.*/CB sabot magasin/
# /CHECK:.*/chèque/
s/CHECK:.*/chèque /
# /PAYMENT: Electronic payment/prélèvement automatique/
s/PAYMENT: Electronic payment/prélèvement automatique /
# /ATM:.*/retrait de liquide/
s/ATM:.*/retrait de liquide /
# DEBIT: Generic debit/prélèvement (sans précision)/
s/DEBIT:.*/prélèvement (sans précision)/
# /DIRECTDEP: Direct deposit/virement /
s/DIRECTDEP:.*/virement / 
# ajouter la ligne suivante dans le tampon sans le vider on récupère la ligne date, utile. les deux lignes forment une
# uniligne séparee par le car \n 
N
# remplacer \n par @ pour préparer formatage ligne 
s/\n/@/g
# il faut retoucher le champ date pour dégager la partie commentaire qui était
# utile uniquement lors du déboggage:
s/Date posted|//
# on obtient transaction@date. on veut encore @montant, la ligne suivante. 
# mais il nous faut le retoucher:
# on récupère notre ligne montant dans nv tampon sans éffacer la ligne construite 
N
# et on refait un remplacement de \n par @ (un seul suffira après la phase de déboggage puisque s///g
s/\n/@/g
# on fait maintenant notre retouche: on dégage la chaine "Total money amount |" on obtient transaction@date@(-)chiffre
s/Total money amount|//

# maintenant on veut zapper les trois prochaines lignes. mais on veut garder la commande en cours de construction.
# on la sauve donc
x
# on charge par trois fois les lignes suivantes dans le tampon en vidant le tampon:
# une premiere fois et on charge la ligne # of units
n
# une deuxieme fois et c 'est la ligne unit price qui est alors dans le pattern space:
n
# une troisieme fois et c'est le jetoon tamporaire d'instituttion qui est chargé.
n
# la ligne suivante par contre nous intéresse: l'identification du tiers ou le libellé de la transac
# on veut la concaténer à la ligne en construction.
# on remet donc chaine wip dans l'espace en cours de construction:
x
# on charge cette id du tiers à la suite de cette chaine, séparee par un \n:
N
# on refait un coup de nettoyage
s/\n/@/g
# on ne veut pas de la chaine "Name of payee or Transaction description |"
s/Name of payee or transaction description|//
# on ne veut pas non plus de check number. on le remplace par N°:
s/Check number|/n°/
# et finalement.... on imprime!
p
}
 
