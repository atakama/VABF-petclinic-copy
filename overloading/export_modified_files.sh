#!/bin/bash

# Le hash du commit Java 8
JAVA8_COMMIT="9ecdc1111e3da388a750ace41a125287d9620534"
# Le hash du dernier commit
LAST_COMMIT="origin/HEAD"
# Répertoire où stocker les fichiers modifiés
OUTPUT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Créer le répertoire de sortie
mkdir -p $OUTPUT_DIR

# Obtenir la liste des fichiers modifiés
files=$(git diff --name-only $JAVA8_COMMIT $LAST_COMMIT)

# Copier les fichiers modifiés dans le répertoire de sortie
for file in $files; do
  # Créer les sous-répertoires nécessaires
  mkdir -p $OUTPUT_DIR/$(dirname $file)
  # Copier le fichier modifié
  cp $file $OUTPUT_DIR/$file
done
