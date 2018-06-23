#!/bin/bash

TO=$1
SUBJECT=$2
BODY=$3

DB="zabbix_support"
TABLE="zabbix_to_elasticsearch"

LOG="/var/log/zabbix_to_elasticsearch_step1.sh.log"

date >> ${LOG}

HOST=$(echo "${BODY}" | grep -Po '_HOST:\K.*')
TRIGGER=$(echo "${BODY}" | grep -Po '_TRIGGER_NAME:\K.*' | sed -e "s/\"/'/g;s/@e:\[.*//g")
TS_STARTED=$(echo "${BODY}" | grep -Po '_DATE_TIME:\K.*')
TS_FINISHED=$(echo "${BODY}" | grep -Po '_EVENT_RECOVERY_DATE_TIME:\K.*')
STATUS=$(echo "${BODY}" | grep -Po '_TRIGGER_STATUS:\K.*')
SEVERITY=$(echo "${BODY}" | grep -Po '_TRIGGER_SEVERITY:\K.*')
NSEVERITY=$(echo "${BODY}" | grep -Po '_TRIGGER_NSEVERITY:\K.*')
TRIGGERID=$(echo "${BODY}" | grep -Po '_TRIGGER_ID:\K.*')
EVENTID=$(echo "${BODY}" | grep -Po '_EVENT_ID:\K.*')
EVENTRECOVERYID=$(echo "${BODY}" | grep -Po '_EVENT_RECOVERY_ID:\K.*')

if [ -n "${EVENTRECOVERYID}" ]
then
    SQL="UPDATE ${DB}.${TABLE} SET triggerdescription=\"${TRIGGER}\", finished = \"${TS_FINISHED}\",
    eventrecoveryid = ${EVENTRECOVERYID}, severity = \"${SEVERITY}\", nseverity = \"${NSEVERITY}\"
    WHERE eventid = ${EVENTID}"
else
    SQL="INSERT INTO ${DB}.${TABLE} (\`hostname\`,\`triggerdescription\`,\`started\`,\`severity\`,
    \`nseverity\`,\`triggerid\`,\`eventid\`) VALUES (\"${HOST}\", \"${TRIGGER}\", \"${TS_STARTED}\",
    \"${SEVERITY}\", \"${NSEVERITY}\", ${TRIGGERID}, ${EVENTID});"
fi

# uncomment this if you want to see queries in the log file
# echo "${SQL}" >>${LOG}

echo "${SQL}" | mysql 2>>${LOG}

