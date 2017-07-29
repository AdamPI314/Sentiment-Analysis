#!/bin/sh

rm -f *.class 1>/dev/null 2>&1
hadoop com.sun.tools.javac.Main SentimentAnalysis.java 1>stdout.txt 2>stderr.txt

rm -f SentimentAnalysis.jar 1>/dev/null 2>&1
jar cf SentimentAnalysis.jar *.class 1>>stdout.txt 2>>stderr.txt

# create /setup directory
if $(hadoop fs -test -d /setup) ;
then
  echo "/setup found, delete!"; 
  hdfs dfs -rm -r /setup > /dev/null 2>&1
else 
  echo "/setup directory not found."; 
fi
hdfs dfs -mkdir /setup > /dev/null 2>&1

# put emotionCategory.txt under /setup
if $(hadoop fs -test -f /setup/emotionCategory.txt) ;
then
  echo "/setup/emotionCategory.txt found, delete!"; 
  hdfs dfs -rm /setup/emotionCategory.txt > /dev/null 2>&1
else 
  echo "/setup/emotionCategory.txt directory not found."; 
fi
hdfs dfs -put ~/src/Sentiment-Analysis/src/main/resources/emotionCategory.txt /setup > /dev/null 2>&1

# put /input
if $(hadoop fs -test -d /input) ;
then
  echo "/input found, delete!"; 
  hdfs dfs -rm -r /input > /dev/null 2>&1
else 
  echo "/input directory not found."; 
fi
hdfs dfs -put ~/src/Sentiment-Analysis/src/main/resources/input / > /dev/null 2>&1

# check /output
if $(hadoop fs -test -d /output) ;
then
  echo "/output found, delete!"; 
  hdfs dfs -rm -r /output > /dev/null 2>&1
else 
  echo "/output directory not found."; 
fi

hadoop jar SentimentAnalysis.jar SentimentAnalysis /input /output /setup/emotionCategory.txt
