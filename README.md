# Treesize for Linux

Questo tool permette di generare un report con l'elenco di tutte le directory in ordine di dimensione.

# Utilizzo

E' necessaio (ma non obbligatorio) eseguire lo script come amministratore.

./treesize.sh [OPTION] [DIRECTORY]

Senza opzioni la directory di default è / senza le directory di sistema

| **Opzione** | **Descrizione** |
| ----------- | --------------- |
| -i | Include directory|

# Esempio

./treesize.sh -i /data /var/log /tmp

