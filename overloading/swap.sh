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
mkdir -p "${BACKUP_DIR}"

# Fonction pour lister les fichiers dans le répertoire Java 8
list_files_in_java8() {
  find "${JAVA8_DIR}" -type f | sed "s|^${JAVA8_DIR}/||"
}

# Fonction pour lister les fichiers spécifiques à Java 17
list_files_in_java17() {
  git diff --name-only "${JAVA8_COMMIT}" "${JAVA17_COMMIT}"
}

# Fonction pour lister les fichiers supprimés (présents dans Java 8 mais non dans Java 17)
list_deleted_files() {
  git diff --name-only --diff-filter=D "${JAVA8_COMMIT}" "${JAVA17_COMMIT}"
}

# Fonction pour vérifier si un fichier est dans le projet
file_exists_in_project() {
  local file="$1"
  [ -f "${PROJECT_DIR}/${file}" ]
}

# Fonction pour échanger les fichiers
swap_files() {
  echo "Échange des fichiers..."
  for relative_path in $(list_files_in_java8); do
    java8_file="${JAVA8_DIR}/${relative_path}"
    project_file="${PROJECT_DIR}/${relative_path}"
    backup_file="${BACKUP_DIR}/${relative_path}"

    echo "Traite le fichier : ${relative_path}"
    echo "  Fichier Java 8 : ${java8_file}"
    echo "  Fichier du projet : ${project_file}"
    echo "  Fichier de sauvegarde : ${backup_file}"

    # Sauvegarder le fichier original s'il existe
    if [ -f "${project_file}" ]; then
      mkdir -p "$(dirname "${backup_file}")"
      mv "${project_file}" "${backup_file}"
      echo "${relative_path}" >> "${LIST_FILE}"
    fi

    # Copier le fichier de Java 8 dans le projet
    mkdir -p "$(dirname "${project_file}")"
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

  # Restaurer les fichiers originaux depuis la sauvegarde
  while IFS= read -r relative_path; do
    project_file="${PROJECT_DIR}/${relative_path}"
    backup_file="${BACKUP_DIR}/${relative_path}"

    echo "Restaurer le fichier : ${relative_path}"
    echo "  Fichier du projet : ${project_file}"
    echo "  Fichier de sauvegarde : ${backup_file}"

    # Restaurer le fichier original s'il existe dans la sauvegarde
    if [ -f "${backup_file}" ]; then
      mkdir -p "$(dirname "${project_file}")"
      mv "${backup_file}" "${project_file}"
    fi
  done < "${LIST_FILE}"

  # Supprimer les fichiers qui ont été supprimés dans Java 17 (ceux de Java 8 non présents dans Java 17)
  echo "Supprimer les fichiers supprimés..."
  for relative_path in $(list_deleted_files); do
    if file_exists_in_project "${relative_path}"; then
      echo "Supprimer le fichier : ${relative_path}"
      rm "${PROJECT_DIR}/${relative_path}"
    fi
  done

  # Supprimer le fichier de liste après restauration
  rm "${LIST_FILE}"
}

# Vérifier si le script a déjà été exécuté
if [ -f "${LIST_FILE}" ]; then
  # Si le fichier de liste existe, restaurer les fichiers
  restore_files
  echo "Les fichiers ont été restaurés depuis ${BACKUP_DIR}."
else
  # Sinon, échanger les fichiers
  swap_files
  echo "Les fichiers ont été échangés et les originaux sont sauvegardés dans ${BACKUP_DIR}."
fi
