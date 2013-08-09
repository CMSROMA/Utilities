# lista della funzioni personali


#------------------------------
# funzione che prende il parametro di una opzione del tipo
#   --opt=parametro
# uso: var=get_par() $i
get_par(){
    echo $1 | cut -d '=' -f 2
}

#------------------------------
# funzione che prende la lista delle opzioni passate allo script

# uso: get_optlist $@
get_optlist(){
    n_nopt=0        # per la filelist
    n_opt=0    # per optlist
    for i in "$@"
    do
    # /^-/ d eliminat tutti gli argomenti che iniziano per -
      if [ -z "`echo $i | sed '/^-/ d'`" ]; then
	  optionlist[n_opt]=$i
	  let n_opt=$n_opt+1
      else
      noptionlist[$n_nopt]=$i
      let n_nopt=$n_nopt+1
      fi
    done
}


