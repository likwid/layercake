FROM ubuntu:14.04

RUN apt-get update \
  && apt-get -q -y install wget git openjdk-7-jre-headless vim \
  && echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list \
  && wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/
  #  && wget -q -O /usr/share/jenkins/jenkins.war http://mirrors.jenkins-ci.org/war-rc/2.0/jenkins.war

VOLUME /var/lib/jenkins
ENV JENKINS_HOME /var/lib/jenkins

EXPOSE 8080

ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

CMD /usr/local/bin/run
