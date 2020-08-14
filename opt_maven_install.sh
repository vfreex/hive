#!/bin/bash -x

set -eo pipefail

# $1=OPENSHIFT_CI=true means running in CI
if [[ "$1" == "true" ]]; then

	yum -y install --setopt=skip_missing_names_on_install=False \
		java-1.8.0-openjdk \
		java-1.8.0-openjdk-devel

	pushd /tmp
	curl -o maven.tgz https://downloads.apache.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
	tar zxvf maven.tgz
	export M2_HOME=/tmp/apache-maven-3.3.9
	export PATH=${PATH}:${M2_HOME}/bin
	popd

  	mvn -B -e -T 1C -DskipTests=true -DfailIfNoTests=false -Dtest=false clean package -Pdist
else
    # Otherwise this is a production brew build by ART
	export RH_HIVE_PATCH_VERSION=00002
	export HIVE_VERSION=2.3.3

	export HIVE_RELEASE_URL=http://download.eng.bos.redhat.com/brewroot/packages/org.apache.hive-hive/${HIVE_VERSION}.redhat_${RH_HIVE_PATCH_VERSION}/1/maven/org/apache/hive/hive-packaging/${HIVE_VERSION}.redhat-${RH_HIVE_PATCH_VERSION}/hive-packaging-${HIVE_VERSION}.redhat-${RH_HIVE_PATCH_VERSION}-bin.tar.gz
	export HIVE_OUT=/build/packaging/target/apache-hive-$HIVE_VERSION-bin/apache-hive-$HIVE_VERSION-bin

	curl -fSLs \
	  $HIVE_RELEASE_URL \
	  -o /tmp/hive-bin.tar.gz

	mkdir -p $(dirname $HIVE_OUT) && \
	  tar -xvf /tmp/hive-bin.tar.gz -C /tmp \
	  && mv /tmp/apache-hive-${HIVE_VERSION}.redhat-${RH_HIVE_PATCH_VERSION}-bin/ \
	  $HIVE_OUT
fi
