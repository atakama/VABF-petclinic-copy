#!/bin/sh
set -e

# Valeurs par défaut, paramétrables via les variables d'environnement
NUDGE_VABF_AGENT_FOLDER=${NUDGE_VABF_AGENT_FOLDER:-./nudge-agent}
nudge_vabf_agent_jar_path=${NUDGE_VABF_AGENT_FOLDER}/nudge.jar
nudge_vabf_petclinic_jar=./petclinic/target/spring-petclinic-*.jar
base_dir=$(pwd)

if [ "$NUDGE_VABF_SKIP_AGENT_DOWNLOAD" != true ] ; then
	echo "Vérification de la présence de l'agent PH Nudge APM. (Cette étape peut être passée avec l'option NUDGE_VABF_SKIP_AGENT_DOWNLOAD=true)"
	source ./download-agent.sh
fi

if [ ! ls ${nudge_vabf_petclinic_jar} 1> /dev/null 2>&1 ]; then
	source ./build.sh
fi
java -javaagent:"${nudge_vabf_agent_jar_path}" -jar ${nudge_vabf_petclinic_jar}

