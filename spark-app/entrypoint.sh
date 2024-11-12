#!/bin/bash

if [ "$1" = "data_analysis" ]; then
    exec /opt/bitnami/spark/bin/spark-submit \
        --master spark://spark-master:7077 \
        --packages org.postgresql:postgresql:42.2.23 \
        --conf spark.driver.extraJavaOptions=-Duser.home=$HOME \
        --conf spark.executor.extraJavaOptions=-Duser.home=$HOME \
        /app/data_analysis.py
elif [ "$1" = "test_cpu_usage" ]; then
    exec python /app/test_cpu_usage.py
else
    # Default command to keep the container running
    exec tail -f /dev/null
fi
