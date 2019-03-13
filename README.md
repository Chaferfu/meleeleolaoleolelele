# meleeleolaoleolelele

NOTE IMPORTANTE : LE FICHIER GENERE PAR PARSING.LUA EST MAINTENANT FILEH.TXT

Ceci est un ssyteme de dialogu qui parle de melee 

To test the questions detection launch dark on detectQuestion.lua.

To test the actual informations detection, go to the dark folder and launch parsing.lua with dark.

Les textes dans corpus et Smashers ont étés récupérés par le script que nous avons écrit. Le dossier Smashers contient les textes a propos des meilleurs joueurs que nous utilisons pour la detection d'informations.


# Trucs que le système fait bien

Fonctionnalités :
* Gere la casse dans les lexiques
* levenshtein, si user ecorche le nom d'un character alors le systeme lui signale 
* mode debug affiche plein d'infos (variable a mettre a true au debut de detectQuestion.lua)
* se deconnecte quand on dit au revoir ou qu'on le drague
* "historique" on peut poser la meme question sur quelqu'un d'autre ou poser une question sur la meme personne (ex : what about ___ ?   What is his main ?)
* le mot exprime son incomprehension et signale s'il ne connaît pas la réponse 
* le bot relance le user apres ses reponses
* le system fait pas trop de fautes de ponctuation (quand il dit la liste des mains il gere si y en a qu'un ou plusieurs)
* TODO dplementer levenshtein pour les autres lexiques (eventuellement trouver une meilleure maniere de faire)
* Comprendre les question avec levenshtein (faire en sorte que le systeme reponde quand meme a la question meme si faute d'othographe)
* Dis quelque chose de special si on repond "yes" a la premiere quesiton 
* TODO gerer pleins de cas ou ça marche pas si les majuscules son tpas la 





Questions detectees :
* player's character/main
* player info
* player nationality
* player rank
* player nicknames
* tournament info
* tournament date
* tournament entrants
* qui  joue ça ?


questions gérées : 
* plyaer character/main
* player info
* player nationality
* player rank
* player nicknames
* TODO les questions detectées mais non gérées
* (gere si le joueur n'a pas de surnoms)


# TODO 
* generer des stats de reussite en utilisant les données structurées 
* finir les questions
* pouvoir demander le meilleur joueur
* pourvoir comparer sur autre chose (ex somme argent gagnée)
* pourvoir demander des trucs ?

