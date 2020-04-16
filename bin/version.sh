#!/usr/bin/env bash
set -e

while getopts ":cnu" Option
do
  case ${Option} in
    c) current=true;;
    n ) next=true;;
    u ) update=true;;
  esac
done

shift $(($OPTIND - 1))

MAVEN_CMD=./mvnw

current() {
  ${MAVEN_CMD} org.apache.maven.plugins:maven-help-plugin:3.1.0:evaluate -Dexpression=project.version -q -DforceStdout
}

next() {
  a=( ${1//./ } )
  ((a[2]++))
  echo "${a[0]}.${a[1]}.${a[2]}"
}

if [[ ! -z ${current} ]]; then
  echo "$(current)"
  exit 0
fi

if [[ ! -z ${next} ]]; then
  echo "$(next $(current))"
  exit 0
fi

if [[ ! -z ${update} ]]; then
  version=$(current)
  newversion=$(next ${version})
  artifact=`${MAVEN_CMD} org.apache.maven.plugins:maven-help-plugin:3.1.0:evaluate -Dexpression=project.artifactId -q -DforceStdout`
  echo "Updating version in pom.xml for $artifact from $version to $newversion" >&2
  ${MAVEN_CMD} org.codehaus.mojo:versions-maven-plugin:2.7:set -DartifactId=${artifact} -DnewVersion=${newversion} -DgenerateBackupPoms=false -q
  echo "pom.xml"

  if [[ -d "charts" ]]; then
    for chart in charts/*; do
      sed -i -e "s/^version: .*/version: ${newversion}/" "${chart}/Chart.yaml"
      sed -i -e "s/^appVersion: .*/appVersion: ${newversion}/" "${chart}/Chart.yaml"
      if [[ -f "${chart}/Chart.yaml-e" ]]; then
        rm -f "${chart}/Chart.yaml-e"
      fi
      echo "${chart}/Chart.yaml"
    done
  fi
  exit 0
fi

echo "usage: $(basename $0) [-cnu] (current / next / update version)" >&2
exit 1