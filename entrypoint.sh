#!/bin/bash

AGENT_JAR_URL="https://ph-apm.download-agent.atakama-technologies.com/java/nudge-java.zip"
AGENT_CONF_URL="https://ph-apm.download-agent.atakama-technologies.com/java/nudge-conf-prod.zip"

[ -z "${AGENT_FOLDER}" ] && echo "Var AGENT_FOLDER is empty" && exit 1
[ -z "${AGENT_JAR}" ] && echo "Var AGENT_JAR is empty" && exit 1

mkdir -p ${AGENT_FOLDER}

# Check if the agent exists
if [ ! -f "${AGENT_JAR}" ]; then
  echo "[Entrypoint] Agent not found. Downloading..."
  wget -q -O ${AGENT_FOLDER}/nudge.zip ${AGENT_JAR_URL}
  unzip ${AGENT_FOLDER}/nudge.zip -d ${AGENT_FOLDER}
  mv ${AGENT_FOLDER}/nudge*.jar ${AGENT_JAR}
  rm ${AGENT_FOLDER}/nudge.zip
else
  echo "[Entrypoint] Agent found. Proceeding..."
fi

# Check if the agent exists
if [ ! -f "${AGENT_FOLDER}/nudge.properties" ]; then
  echo "[Entrypoint] Conf not found. Downloading..."
  mkdir -p ${AGENT_FOLDER}
  wget -q -O ${AGENT_FOLDER}/nudge-conf.zip ${AGENT_CONF_URL}
  unzip ${AGENT_FOLDER}/nudge-conf.zip -d ${AGENT_FOLDER}
  rm ${AGENT_FOLDER}/nudge-conf.zip
  echo "[Entrypoint] Configuration file downloaded, please edit it before continuing"
  exit 1
else
  echo "[Entrypoint] Conf found. Proceeding..."
fi

exec "$@"
