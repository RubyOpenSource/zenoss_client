FROM centos:6
RUN mkdir /opt/zenoss
WORKDIR /opt/zenoss
RUN yum -y install wget which
ADD https://raw.githubusercontent.com/zenoss/core-autodeploy/4.2.5/core-autodeploy.sh ./
ADD https://raw.githubusercontent.com/zenoss/core-autodeploy/4.2.5/secure_zenoss.sh ./
ADD https://raw.githubusercontent.com/zenoss/core-autodeploy/4.2.5/zenpack_actions.txt ./
RUN chmod +x /core-autodeploy.sh
RUN echo -e "\ny\n" | /core-autodeploy.sh
ADD remote_start.sh ./
