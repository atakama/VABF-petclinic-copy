#!/bin/bash

# Définir les variables
REPO_URL="https://github.com/atakama/VABF-petclinic-copy"
JAVA8_COMMIT="9ecdc1111e3da388a750ace41a125287d9620534"
LAST_COMMIT="d8fcd11e677102a795326ef73df09b50a646f849"
OUTPUT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/java8

# Créer le répertoire de sortie
mkdir -p $OUTPUT_DIR

# Obtenir la liste des fichiers modifiés
files=$(git diff --name-only $JAVA8_COMMIT $LAST_COMMIT)

# Télécharger chaque fichier modifié depuis GitHub
for file in $files; do
  # Créer les sous-répertoires nécessaires
  mkdir -p $OUTPUT_DIR/$(dirname $file)
  # Télécharger le fichier modifié depuis le dépôt GitHub
  wget -qO $OUTPUT_DIR/$file $REPO_URL/raw/$JAVA8_COMMIT/$file
done
