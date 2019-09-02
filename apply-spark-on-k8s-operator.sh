#!/bin/bash

kubectl create namespace spark-jobs || true
helm upgrade spark-operator sparkoperator --namespace spark-operator --install --force --debug --set sparkJobNamespace=spark-jobs --set enableWebhook=true --set serviceAccounts.spark.name=spark --set serviceAccounts.sparkoperator.name=spark-operator --repo http://storage.googleapis.com/kubernetes-charts-incubator
