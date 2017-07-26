#!/bin/sh
if $(hadoop fs -test -d /output) ;
then
  echo "/output found, delete!"; 
  hdfs dfs -rm -r /output > /dev/null 2>&1
else 
  echo "/output directory not found."; 
fi

hadoop jar SentimentAnalysis.jar SentimentAnalysis /input /output /tmp/emotionCategory.txt > log.txt 2>&1 
