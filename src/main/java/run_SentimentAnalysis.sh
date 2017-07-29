#!/bin/sh

rm *.class 1>/dev/null 2>&1
hadoop com.sun.tools.javac.Main SentimentAnalysis.java 1>stdout.txt 2>stderr.txt

rm SentimentAnalysis.jar 1>/dev/null 2>&1
jar cf SentimentAnalysis.jar *.class 1>>stdout.txt 2>>stderr.txt


if $(hadoop fs -test -f /tmp/emotionCategory.txt) ;
then
  echo "/tmp/emotionCategory.txt found, delete!"; 
  hdfs dfs -rm /tmp/emotionCategory.txt > /dev/null 2>&1
else 
  echo "/tmp/emotionCategory.txt directory not found."; 
fi
hdfs dfs -put ~/src/Sentiment-Analysis/src/main/resources/emotionCategory.txt /tmp > /dev/null 2>&1

if $(hadoop fs -test -d /input) ;
then
  echo "/input found, delete!"; 
  hdfs dfs -rm -r /input > /dev/null 2>&1
else 
  echo "/input directory not found."; 
fi
hdfs dfs -put ~/src/Sentiment-Analysis/src/main/resources/input / > /dev/null 2>&1

if $(hadoop fs -test -d /output) ;
then
  echo "/output found, delete!"; 
  hdfs dfs -rm -r /output > /dev/null 2>&1
else 
  echo "/output directory not found."; 
fi


hadoop jar SentimentAnalysis.jar SentimentAnalysis /input /output /tmp/emotionCategory.txt 1>>stdout.txt 2>>stderr.txt
