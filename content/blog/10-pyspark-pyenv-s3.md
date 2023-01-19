+++
title = "09 - Connect pyspark to local s3 like storage"
date = 2023-01-11
tags = ["pyenv","python","spark","linux"]
draft = true
+++

``` bash
apt-get update
apt-get install openjdk-11-jdk python3 python3-pip wget

pip3 install pyspark==3.2.1

cd /usr/local/lib/python3.11/dist-packages/pyspark/

wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.901/aws-java-sdk-bundle-1.11.901.jar -P jars/
wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar -P jars/
```

# Install pyenv
# Enable pyenv venv
# Install pyspark on pyenv
# Adding jar dependencies to spark installation in pyenv
