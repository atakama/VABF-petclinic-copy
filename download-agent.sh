#!/bin/sh
set -e

NUDGE_VABF_AGENT_DOWNLOAD_URL=${NUDGE_VABF_AGENT_DOWNLOAD_URL:-https://ph-apm.download-agent.atakama-technologies.com/java/nudge-java.zip}
NUDGE_VABF_CONFIG_DOWNLOAD_URL=${NUDGE_VABF_CONFIG_DOWNLOAD_URL:-https://ph-apm.download-agent.atakama-technologies.com/java/nudge-conf-prod.zip}
NUDGE_VABF_AGENT_FOLDER=${NUDGE_VABF_AGENT_FOLDER:-./nudge-agent}

nudge_vabf_agent_jar_path=${NUDGE_VABF_AGENT_FOLDER}/nudge.jar
nudge_vabf_agent_props_path=${NUDGE_VABF_AGENT_FOLDER}/nudge.properties

echo "Using Nudge agent download URL [NUDGE_VABF_AGENT_DOWNLOAD_URL] : ${NUDGE_VABF_AGENT_DOWNLOAD_URL}"
echo "Using Nudge config download URL [NUDGE_VABF_CONFIG_DOWNLOAD_URL] : ${NUDGE_VABF_CONFIG_DOWNLOAD_URL}"
echo "Using Nudge agent folder [env NUDGE_VABF_AGENT_FOLDER] : ${NUDGE_VABF_AGENT_FOLDER}"
echo "To change the previous parameters, use \`export [VAR_NAME]\` before executing the script"


# $1 : URL de téléchargement
# $2 : Chemin de sortie du fichier
download() {
	curl --insecure -o ${2} ${1} 2>/dev/null
}

if [ ! -f ${nudge_vabf_agent_jar_path} ] ; then
	if [ ! -f ${NUDGE_VABF_AGENT_FOLDER}/nudge.zip ] ; then
		mkdir -p ${NUDGE_VABF_AGENT_FOLDER}
		echo "Downloading Nudge agent archive in folder \`${NUDGE_VABF_AGENT_FOLDER}\`"
		download ${NUDGE_VABF_AGENT_DOWNLOAD_URL} ${NUDGE_VABF_AGENT_FOLDER}/nudge.zip
	fi
	cd ${NUDGE_VABF_AGENT_FOLDER}
	echo "Unzipping Nudge agent archive"
	unzip -o nudge.zip
	mv nudge*.jar nudge.jar
	cd ${base_dir}
else
	echo "Nudge agent is already installed in folder \`${NUDGE_VABF_AGENT_FOLDER}\`"
fi

if [ ! -f ${nudge_vabf_agent_props_path} ] ; then
	if [ ! -f ${NUDGE_VABF_AGENT_FOLDER}/nudge-conf-prod.zip ] ; then
		mkdir -p ${NUDGE_VABF_AGENT_FOLDER}
		echo "Downloading Nudge agent properties archive in folder \`${NUDGE_VABF_AGENT_FOLDER}\`"
		download ${NUDGE_VABF_CONFIG_DOWNLOAD_URL} ${NUDGE_VABF_AGENT_FOLDER}/nudge-conf-prod.zip
	fi
	cd ${NUDGE_VABF_AGENT_FOLDER}
	unzip -o nudge-conf-prod.zip
	cd ${base_dir}
	[ "$NUDGE_VABF_SKIP_CONF" != true ] && echo "Please configure the nudge.properties file before continuing. (Skip this step using NUDGE_VABF_SKIP_CONF=true)" && exit 1

else
	echo "Nudge agent properties is already present in folder \`${NUDGE_VABF_AGENT_FOLDER}\`"
fi
