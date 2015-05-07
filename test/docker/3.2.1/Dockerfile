FROM centos:5
RUN mkdir /opt/zenoss
WORKDIR /opt/zenoss
RUN yum -y install mysql-server net-snmp net-snmp-utils gmp \
    libgomp libgcj liberation-fonts libaio wget
RUN wget http://downloads.sourceforge.net/project/zenoss/zenoss-3.2/zenoss-3.2.1/zenoss-3.2.1.el5.x86_64.rpm
RUN service mysqld start && mysqladmin -u root password '' && \
    mysqladmin -u root -h localhost password ''
RUN rpm -ivh ./zenoss-3.2.1.el5.x86_64.rpm
RUN service zenoss start
ADD remote_start.sh ./
