#!/usr/bin/env bash
export SPARK_HOME={{ .Values.global.spark_home }}
export MODELS_HOME={{ .Values.analytics.home }}/models-{{ .Values.model_version }}
export DP_LOGS={{ .Values.analytics.home }}/logs/data-products

cd {{ .Values.analytics.home }}/scripts
source model-config.sh
source replay-utils.sh

job_config=$(config $1 '__endDate__')
start_date=$2
end_date=$3

echo "Running the $1 updater replay..." >> "$DP_LOGS/$end_date-$1-replay.log"
$SPARK_HOME/bin/spark-submit --master local[*] --jars $MODELS_HOME/analytics-framework-2.0.jar --class org.ekstep.analytics.job.ReplaySupervisor $MODELS_HOME/batch-models-2.0.jar --model "$1" --fromDate "$start_date" --toDate "$end_date" --config "$job_config" >> "$DP_LOGS/$end_date-$1-replay.log"

if [ $? == 0 ] 
	then
  	echo "$1 updater replay executed successfully..." >> "$DP_LOGS/$end_date-$1-replay.log"
else
 	echo "$1 updater replay failed" >> "$DP_LOGS/$end_date-$1-replay.log"
 	exit 1
fi
