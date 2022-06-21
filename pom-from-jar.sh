#!/bin/bash
rm -rf pom_from_jar/
rm -rf temp_jar/
mkdir pom_from_jar
mkdir temp_jar

jar_path="$1"
if [ "$jar_path" == "" ]; then
  echo "Por favor especifique o caminho do jar"
  exit 1
fi

unzip -d ./temp_jar $jar_path

cat <<EOF | tee pom_from_jar/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>group-id</groupId>
  <artifactId>artifact-id</artifactId>
  <version>1.0</version>
  <packaging>jar</packaging>
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
  <dependencies>
EOF


for f in ./temp_jar/BOOT-INF/lib/*.jar; do
  sha=$(shasum -b $f | awk '{print $1}')
  url="http://search.maven.org/solrsearch/select?q=1:%22${sha}%22&rows=20&wt=json"
  
  if curl -s -o json -L $url; then
    gid=$(jq -r '.response.docs[0].g' json)
    aid=$(jq -r '.response.docs[0].a' json)
    ver=$(jq -r '.response.docs[0].v' json)
    cat <<EOF | tee -a pom_from_jar/pom.xml
    <dependency>
      <groupId>${gid}</groupId>
      <artifactId>${aid}</artifactId>
      <version>${ver}</version>
    </dependency>
EOF
    rm -f json
  fi
  
done

cat <<EOF | tee -a pom_from_jar/pom.xml
  </dependencies>
</project>
EOF