#!/bin/bash

# Sovrascrivi il file se esiste
> spoof_build_vars

# Leggi e processa il file JSON
while IFS= read -r line; do
  # Pulisci la riga rimuovendo i caratteri indesiderati e gli spazi
  clean_line=$(echo "$line" | sed 's/[{},":]//g' | xargs)

  # Controlla se la riga non è vuota e contiene una coppia chiave-valore valida
  if [[ ! -z "$clean_line" && "$clean_line" =~ [A-Z_]+ ]]; then
    # Sostituisci il primo spazio con un segno di uguale per creare il formato chiave=valore
    echo "$clean_line" | sed 's/ /=/' >> spoof_build_vars
  fi

  # Interrompi il processo dopo aver trovato SECURITY_PATCH
  if [[ "$clean_line" == SECURITY_PATCH* ]]; then
    break
  fi
done < pif.json
