#!/bin/bash

# Définir les variables
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
JAVA8_DIR="${SCRIPT_DIR}/java8"
PROJECT_DIR="${SCRIPT_DIR}/.."
BACKUP_DIR="${SCRIPT_DIR}/backup_files"
LIST_FILE="${SCRIPT_DIR}/switch_list.txt"
STATUS_FILE="${SCRIPT_DIR}/status.txt" # Fichier pour enregistrer l'état
JAVA8_COMMIT="9ecdc1111e3da388a750ace41a125287d9620534"

# Obtenir le commit actuel de la branche
CURRENT_COMMIT=$(git rev-parse HEAD)

# Créer le répertoire de sauvegarde si nécessaire
mkdir -p "${BACKUP_DIR}"

# Fonction pour lister les fichiers dans le répertoire Java 8
list_files_in_java8() {
  find "${JAVA8_DIR}" -type f | sed "s|^${JAVA8_DIR}/||"
}

# Fonction pour lister les fichiers spécifiques au dernier commit
list_files_in_latest() {
  git diff --name-only "${JAVA8_COMMIT}" "${CURRENT_COMMIT}"
}

# Fonction pour lister les fichiers supprimés entre Java 8 et le dernier commit
list_deleted_files() {
  git diff --name-only --diff-filter=D "${JAVA8_COMMIT}" "${CURRENT_COMMIT}"
}

# Fonction pour vérifier l'état actuel
check_status() {
  if [ -f "${STATUS_FILE}" ]; then
    current_status=$(cat "${STATUS_FILE}")
  else
    current_status=""
  fi
  echo "${current_status}"
}

# Fonction pour définir l'état actuel
set_status() {
  echo "$1" > "${STATUS_FILE}"
}

# Fonction pour échanger les fichiers
swap_files() {
  echo "Échange des fichiers Java 8 avec les fichiers actuels..."
  > "${LIST_FILE}" # Assurez-vous que le fichier de liste est vide avant d'ajouter des éléments

  for relative_path in $(list_files_in_java8); do
    java8_file="${JAVA8_DIR}/${relative_path}"
    project_file="${PROJECT_DIR}/${relative_path}"
    backup_file="${BACKUP_DIR}/${relative_path}"

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

  # Mettre à jour l'état
  set_status "java8"
  echo "Les fichiers Java 8 ont été échangés et sauvegardés."
}

# Fonction pour restaurer les fichiers originaux
restore_files() {
  echo "Restauration des fichiers depuis la sauvegarde..."
  if [ ! -f "${LIST_FILE}" ]; then
    echo "Aucun fichier à restaurer. Vérifiez si le fichier switch_list.txt existe et contient des fichiers."
    exit 1
  fi

  # Restaurer les fichiers originaux depuis la sauvegarde
  while IFS= read -r relative_path; do
    project_file="${PROJECT_DIR}/${relative_path}"
    backup_file="${BACKUP_DIR}/${relative_path}"

    # Restaurer le fichier original s'il existe dans la sauvegarde
    if [ -f "${backup_file}" ]; then
      mkdir -p "$(dirname "${project_file}")"
      mv "${backup_file}" "${project_file}"
      echo "Fichier restauré : ${relative_path}"
    fi
  done < "${LIST_FILE}"

  # Supprimer les fichiers spécifiques à Java 8 qui n'existent plus dans Java 17
  for relative_path in $(list_deleted_files); do
    project_file="${PROJECT_DIR}/${relative_path}"
    if [ -f "${project_file}" ] && [ ! -f "${JAVA8_DIR}/${relative_path}" ]; then
      rm "${project_file}"
      echo "Fichier supprimé : ${relative_path}"
    fi
  done

  # Supprimer le fichier de liste après restauration
  rm "${LIST_FILE}"

  # Mettre à jour l'état
  set_status "latest"
  echo "Les fichiers ont été restaurés et nettoyés."
}

# Vérifier l'état actuel
current_status=$(check_status)

if [ "${current_status}" == "latest" ] || [ -z "${current_status}" ]; then
  # Si l'état est le dernier commit ou si l'état est vide (première exécution), échanger les fichiers
  swap_files
elif [ "${current_status}" == "java8" ]; then
  # Sinon, restaurer les fichiers
  restore_files
else
  echo "État inconnu : ${current_status}. Veuillez vérifier le fichier de statut."
  exit 1
fi
