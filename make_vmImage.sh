#!/bin/bash
lockdir="/tmp/job1_site"
mkdir $lockdir 2>/dev/null || exit $?

dt1=`date "+%F %T"`

res1=$(date +%s.%N)


PROJECT_NAME=$(curl -fs http://metadata.google.internal/computeMetadata/v1/project/attributes/PROJECT_NAME -H "Metadata-Flavor: Google")
HOST_NAME=$(curl -fs http://metadata.google.internal/computeMetadata/v1/instance/hostname -H Metadata-Flavor:Google | cut -d . -f1)
STORAGE_NAME=$(curl -fs http://metadata.google.internal/computeMetadata/v1/project/attributes/PRIMARY_STORAGE_NAME -H "Metadata-Flavor: Google")
PROJECT_ID=$(curl -fs http://metadata.google.internal/computeMetadata/v1/project/attributes/PROJECT_ID -H "Metadata-Flavor: Google")
SERVICE_ACCT=$(curl -fs http://metadata.google.internal/computeMetadata/v1/project/attributes/SERVICE_ACCT -H "Metadata-Flavor: Google")

#gcloud auth activate-service-account $SERVICE_ACCT

#gcloud config set account "$SERVICE_ACCT"

#gcloud compute images create $HOST_NAME --source-snapshot=$HOST_NAME

gcloud compute images export --destination-uri gs://$STORAGE_NAME/vm-images/$HOST_NAME.tar.gz --image $HOST_NAME --project $PROJECT_ID

res2=$(date +%s.%N)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)
j=$(printf "%02d:%02.2f\n"   $dm $ds)

#echo [Snapshot][Snapshot Name:$HOST_NAME],[Snapshot Size:$var],[Snapshot Date:$dt1],[Host:$HOST_NAME],[TimeTaken:$j]  >> /var/log/generallog

rm -rf $lockdir
