#!/bin/sh
set -e

NUDGE_VABF_AGENT_DOWNLOAD_URL=${NUDGE_VABF_AGENT_DOWNLOAD_URL:-https://ph-apm.download-agent.atakama-technologies.com/java/nudge-java.zip}
NUDGE_VABF_CONFIG_DOWNLOAD_URL=${NUDGE_VABF_CONFIG_DOWNLOAD_URL:-https://ph-apm.download-agent.atakama-technologies.com/java/nudge-conf-prod.zip}
NUDGE_VABF_AGENT_FOLDER=${NUDGE_VABF_AGENT_FOLDER:-./nudge-agent}
nudge_vabf_agent_jar_path=${NUDGE_VABF_AGENT_FOLDER}/nudge.jar
nudge_vabf_agent_props_path=${NUDGE_VABF_AGENT_FOLDER}/nudge.properties

# $1 : URL de téléchargement
# $2 : Chemin de sortie du fichier
download() {
	if which curl >/dev/null ; then
		echo "Téléchargement via curl de ${1} sur ${2}"
		curl --insecure -o ${2} ${1}
	else
		echo "Impossible de télécharger, wget ou curl ne sont pas disponibles."
	fi
}

if [ ! -f ${nudge_vabf_agent_jar_path} ] ; then
	if [ ! -f ${NUDGE_VABF_AGENT_FOLDER}/nudge.zip ] ; then
		echo "Aucun agent ni archive trouvé dans ${NUDGE_VABF_AGENT_FOLDER}"

		mkdir -p ${NUDGE_VABF_AGENT_FOLDER}
		download ${NUDGE_VABF_AGENT_DOWNLOAD_URL} ${NUDGE_VABF_AGENT_FOLDER}/nudge.zip
		echo "Téléchargement de ${nudge_vabf_agent_jar_path}"
	fi
	echo "Aucun agent trouvé dans ${NUDGE_VABF_AGENT_FOLDER}. Utilisation de l'archive ${NUDGE_VABF_AGENT_FOLDER}/nudge.zip"
	cd ${NUDGE_VABF_AGENT_FOLDER}
	unzip -o nudge.zip
	echo "Dézippage terminé"
	mv nudge*.jar nudge.jar
	cd ${base_dir}
fi

if [ ! -f ${nudge_vabf_agent_props_path} ] ; then
	if [ ! -f ${NUDGE_VABF_AGENT_FOLDER}/nudge-conf-prod.zip ] ; then
		mkdir -p ${NUDGE_VABF_AGENT_FOLDER}
		download ${NUDGE_VABF_CONFIG_DOWNLOAD_URL} ${NUDGE_VABF_AGENT_FOLDER}/nudge-conf-prod.zip
	fi
	cd ${NUDGE_VABF_AGENT_FOLDER}
	unzip -o nudge-conf-prod.zip
	cd ${base_dir}
	[ "$NUDGE_VABF_SKIP_CONF" != true ] && echo "Merci de configurer le fichier de propriétés de la sonde avant de continuer. (Ce message peut être passé avec l'option NUDGE_VABF_SKIP_CONF=true)" && exit 1
fi