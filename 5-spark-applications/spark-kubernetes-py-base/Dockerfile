FROM jepmam/spark-kubernetes-py:2.4.0

# Download AWS Java SDK
ARG HADOOP_AWS_VERSION=2.8.5
ADD http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar /opt/spark/jars/hadoop-aws-${HADOOP_AWS_VERSION}.jar

# # Install AWS Java SDK
# ARG AWS_JAVA_SDK_VERSION=2.3.0
# ADD http://central.maven.org/maven2/software/amazon/awssdk/sdk-core/${AWS_JAVA_SDK_VERSION}/sdk-core-${AWS_JAVA_SDK_VERSION}.jar /opt/spark/jars/aws-java-sdk-v2-${AWS_JAVA_SDK_VERSION}.zip

ARG AWS_JAVA_SDK_VERSION=1.11.336
ADD https://sdk-for-java.amazonwebservices.com/aws-java-sdk-$AWS_JAVA_SDK_VERSION.zip /tmp/aws-java-sdk-$AWS_JAVA_SDK_VERSION.zip
RUN unzip /tmp/aws-java-sdk-${AWS_JAVA_SDK_VERSION}.zip -d /tmp/ && \
    mv /tmp/aws-java-sdk-$AWS_JAVA_SDK_VERSION/lib/aws-java-sdk-$AWS_JAVA_SDK_VERSION.jar /opt/spark/jars/  && \
    mv /tmp/aws-java-sdk-$AWS_JAVA_SDK_VERSION/third-party/ /opt/spark/jars/ && \
    rm -rf /tmp/*
