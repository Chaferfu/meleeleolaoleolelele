README : smash.gg API

Les données sur divers tournois, dont ceux de SSBM peuvent être récupérées de manière structurée sous format JSON.

Syntaxe : https://api.smash.gg/<object_type>/<object_name>?<infos_voulues>
<infos_voulues> : sous la forme expand[]=<info1>&expand[]=<info2>& ...

Example : tournament Genesis5, joueurs entrants :
    https://api.smash.gg/tournament/genesis-5?expand[]=entrants

Options possibles :

    event - Will return all the events in the tournament
    phase - Will return all the phases in the tournament
    groups - Will return all the phase groups in the tournament
    stations - Will return all the stations/streams in the tournament
    sets - Will return all the sets of the phase group
    entrants - Will return all the entrants in the phase group
    standings - Will return standings data if used in conjunction with the seeds expand
    seeds - Use in conjunction with standings to get standings data. This gives you seeds for the bracket as well.
    
Pour plus de détails : https://help.smash.gg/faq/misc/api-access
