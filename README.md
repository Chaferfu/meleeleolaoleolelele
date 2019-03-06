# meleeleolaoleolelele

To test the questions detection launch dark on detectQuestion.lua.

To test the actual informations detection, go to the dark folder and launch parsing.lua with dark.

Les textes dans corpus et Smashers ont étés récupérés par le script que nous avons écrit. Le dossier Smashers contient les textes a propos des meilleurs joueurs que nous utilisons pour la detection d'informations.


Fonctionnalités :
<br/>Gere la casse dans les lexiques
<br/>levenshtein, si user ecorche le nom d'un character alors le systeme lui signale 
<br/>mode debug affiche plein d'infos (variable a mettre a true au debut de detectQuestion.lua)
<br/>se deconnecte quand on dit au revoir
<br/>"historique" on peut poser la meme question sur quelqu'un d'autre ou poser une question sur la meme personne (ex : what about ___ ?   What is his main ?)
<br/>le mot exprime son incomprehension
<br/>le bot relance le user apres ses reponses
<br/>le system fait pas trop de fautes de ponctuation (quand il dit la liste des mains il gere si y en a qu'un ou plusieurs)
<br/>TODO implementer levenshtein pour les autres lexiques (eventuellement trouver une meilleure maniere de faire)
<br/>TODO comprendre les question avec levenshtein (faire en sorte que le systeme reponde quand meme a la question meme si faute d'othographe)





Questions : detectees

player's character/main

player info

player nationality

tournament info

tournament date

tournament entrants

TODO autre formulations ?


questions gérées : 

plyaer character/main

player info

player nationality

TODO les questions detectées mais non gérées




TODO generer des stats de reussite en utilisant les données structurées 

TODO faire quelque chose de special quand user repond oui a la question de bienvenue 

