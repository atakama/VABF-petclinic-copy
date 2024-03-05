#!/bin/sh
set -e

# Valeurs par défaut, paramétrables via les variables d'environnement
NUDGE_VABF_AGENT_FOLDER=${NUDGE_VABF_AGENT_FOLDER:-./nudge-agent}
nudge_vabf_agent_jar_path=${NUDGE_VABF_AGENT_FOLDER}/nudge.jar
current_dir=$(pwd)

if [ "$NUDGE_VABF_SKIP_AGENT_DOWNLOAD" != true ] ; then
	"Téléchargement de l'agent PH Nudge APM. (Cette étape peut être passée avec l'option NUDGE_VABF_SKIP_AGENT_DOWNLOAD=true)"
	source ./download-agent.sh
fi

! docker-compose -f docker-compose.yml up -d && echo "Docker is not started or is failing. See error above."

