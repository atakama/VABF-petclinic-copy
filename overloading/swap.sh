#!/bin/bash

# Définir les variables
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
JAVA8_DIR="${SCRIPT_DIR}/java8"
PROJECT_DIR="${SCRIPT_DIR}/.."
BACKUP_DIR="${SCRIPT_DIR}/backup_files"
LIST_FILE="${SCRIPT_DIR}/switch_list.txt"
JAVA8_COMMIT="9ecdc1111e3da388a750ace41a125287d9620534"
JAVA17_COMMIT="d8fcd11e677102a795326ef73df09b50a646f849"

# Créer le répertoire de sauvegarde si nécessaire
mkdir -p ${BACKUP_DIR}

# Fonction pour lister les fichiers à échanger
list_files() {
  find "${JAVA8_DIR}" -type f | sed "s|^${JAVA8_DIR}/||"
}

# Fonction pour échanger les fichiers
swap_files() {
  echo "Échange des fichiers..."
  for relative_path in $(list_files); do
    java8_file="${JAVA8_DIR}/${relative_path}"
    project_file="${PROJECT_DIR}/${relative_path}"
    backup_file="${BACKUP_DIR}/${relative_path}"

    # Sauvegarder le fichier original s'il existe
    if [ -f "${project_file}" ]; then
      mkdir -p $(dirname "${backup_file}")
      mv "${project_file}" "${backup_file}"
      echo "${relative_path}" >> "${LIST_FILE}"
    fi

    # Copier le fichier de Java 8 dans le projet
    mkdir -p $(dirname "${project_file}")
    cp "${java8_file}" "${project_file}"
  done
}

# Fonction pour restaurer les fichiers originaux
restore_files() {
  echo "Restauration des fichiers..."
  if [ ! -f "${LIST_FILE}" ]; then
    echo "Aucun fichier à restaurer."
    exit 1
  fi

  while IFS= read -r relative_path; do
    project_file="${PROJECT_DIR}/${relative_path}"
    backup_file="${BACKUP_DIR}/${relative_path}"

    # Restaurer le fichier original
    if [ -f "${backup_file}" ]; then
      mv "${backup_file}" "${project_file}"
    else
      # Supprimer les fichiers qui n'existaient pas dans Java 8
      rm "${project_file}"
    fi
  done < "${LIST_FILE}"

  # Supprimer les fichiers restants dans le répertoire du projet qui n'existaient pas dans le commit Java 8
  for relative_path in $(list_java8_only_files); do
    project_file="${PROJECT_DIR}/${relative_path}"
    if [ -f "${project_file}" ]; then
      rm "${project_file}"
    fi
  done

  rm "${LIST_FILE}"
}

# Fonction pour lister les fichiers spécifiques à Java 17
list_java17_files() {
  git diff --name-only ${JAVA8_COMMIT} ${JAVA17_COMMIT}
}

# Fonction pour lister les fichiers spécifiques à Java 8
list_java8_only_files() {
  git diff --name-only ${JAVA17_COMMIT} ${JAVA8_COMMIT}
}

# Vérifier si le script a déjà été exécuté
if [ -f "${LIST_FILE}" ]; then
  # Si le fichier de liste existe, restaurer les fichiers
  restore_files
  echo "Les fichiers ont été restaurés depuis ${BACKUP_DIR}."
else
  # Sinon, échanger les fichiers
  swap_files

  # Lister les fichiers spécifiques à Java 17 et les supprimer
  for relative_path in $(list_java17_files); do
    project_file="${PROJECT_DIR}/${relative_path}"
    if [ -f "${project_file}" ] && [ ! -f "${JAVA8_DIR}/${relative_path}" ]; then
      rm "${project_file}"
    fi
  done

  echo "Les fichiers ont été échangés et les originaux sont sauvegardés dans ${BACKUP_DIR}."
fi
