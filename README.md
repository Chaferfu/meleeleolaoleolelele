# meleeleolaoleolelele

To test the questions detection launch dark on detectQuestion.lua.

To test the actual informations detection, go to the dark folder and launch parsing.lua with dark.

Les textes dans corpus et Smashers ont étés récupérés par le script que nous avons écrit. Le dossier Smashers contient les textes a propos des meilleurs joueurs que nous utilisons pour la detection d'informations.


Fonctionnalités :
Gere la casse dans les lexiques
levenshtein, si user ecorche le nom d'un character alors le systeme lui signale 
mode debug affiche plein d'infos (variable a mettre a true au debut de detectQuestion.lua)
se deconnecte quand on dit au revoir
"historique" on peut poser la meme question sur quelqu'un d'autre ou poser une question sur la meme personne (ex : what about ___ ?   What is his main ?)
le mot exprime son incomprehension
le bot relance le user apres ses reponses
le system fait pas trop de fautes de ponctuation (quand il dit la liste des mains il gere si y en a qu'un ou plusieurs)
TODO comprendre les question avec levenshtein 



Questions : detectees
player's character/main
player info
player nationality
tournament info
tournament date
tournament entrants

questions gérées : 
plyaer character/main
player info
pmayer nationality
