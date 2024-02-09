#!/bin/sh
set -e

NUDGE_VABF_AGENT_FOLDER=${NUDGE_VABF_AGENT_FOLDER:-./agent/}
NUDGE_VABF_AGENT_JAR_FILENAME=${NUDGE_VABF_AGENT_JAR_FILENAME:-nudge.jar}
NUDGE_VABF_AGENT_JAR_PATH=${NUDGE_VABF_AGENT_FOLDER}${NUDGE_VABF_AGENT_JAR_FILENAME}
NUDGE_VABF_AGENT_DOWNLOAD_URL=${NUDGE_VABF_AGENT_DOWNLOAD_URL:-https://github-registry-files.githubusercontent.com/320222873/849a2d00-038e-11ee-9040-b4fbe556eb72?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240208%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240208T100137Z&X-Amz-Expires=300&X-Amz-Signature=c0b43e559d8576bdf4271826cd44283daca38cd01c5814cb597e1ab308fa47ca&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=320222873&response-content-disposition=filename%3Dprobe-agent-4.0.3.jar&response-content-type=application%2Foctet-stream}
NUDGE_VABF_DOCKER_COMPOSE_FILE=${NUDGE_VABF_DOCKER_COMPOSE_FILE:-docker-compose.yml}

download() {
	if which wget >/dev/null ; then
		echo "Téléchargement via wget de ${1} sur ${2}"
		echo "wuh $2 $1"
		wget -O ${2} ${1}
		echo "huh"
	elif which curl >/dev/null ; then
		echo "Téléchargement via curl de ${1} sur ${2}"
		curl -o ${2} ${1}
	else
		echo "Impossible de télécharger, wget ou curl ne sont pas disponibles."
	fi
}

if [ ! -f ${NUDGE_VABF_AGENT_JAR_PATH} ] ; then
	mkdir -p ${NUDGE_VABF_AGENT_FOLDER}
	download ${NUDGE_VABF_AGENT_DOWNLOAD_URL} ${NUDGE_VABF_AGENT_JAR_PATH}
	echo "Téléchargement de l'agent terminé dans ${NUDGE_VABF_AGENT_JAR_PATH}"
fi

docker-compose -f ${NUDGE_VABF_DOCKER_COMPOSE_FILE} up -d

