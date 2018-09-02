FROM debian:latest

# shell to start from Kitematic
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# install dependencies
RUN apt-get update && \
    apt-get install -y \
      cron \
      #imapfilter \
      nano \
      python \
      python-pip \
      python-setuptools \
      #pyzor \
      #razor \
      rsyslog \
      spamassassin \
      spamc \
      unzip \
      wget \
      python-sphinx\
    && \
    apt-get clean #&& \
    #rm -rf /var/lib/apt/lists/* && \
    #pip install --upgrade pip && \
    #pip install wheel && \
    #pip install docopt==0.6.2

WORKDIR /root

RUN pip install sphinx_rtd_theme html recommonmark typing

RUN cd /root && \
    wget https://github.com/rsmuc/isbg/archive/master.zip && \
    unzip master.zip && \
    cd isbg-master && \
    python setup.py install && \
    cd .. && \
    rm -Rf isbg-master && \
    rm master.zip
    
RUN cd /root && \ 
    wget https://github.com/rsmuc/imapscan/archive/master.zip && \
    unzip master.zip && \
    cd imapscan-master/files && \
    cp * /root && \
    cd && \
    rm -Rf /root/imapscan-master && \
    rm /root/master.zip

#ADD files/* /root/

# prepare directories and files
RUN mkdir /root/accounts ; \
    #mv *.txt /root/accounts ;\
    #mkdir /root/.imapfilter ; \
    cd /root && \ 
    mkdir -p /var/spamassassin/bayesdb ; \
    chown -R debian-spamd:mail /var/spamassassin ; \
    chmod u+x startup ; \
    chmod u+x *.sh ; \
    crontab /root/cron_scans && rm /root/cron_scans ; \
    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/spamassassin ; \
    sed -i 's/CRON=0/CRON=1/' /etc/default/spamassassin ; \
    sed -i 's/^OPTIONS=".*"/OPTIONS="--allow-tell --max-children 5 --helper-home-dir -u debian-spamd -x --virtual-config-dir=\/var\/spamassassin -s mail"/' /etc/default/spamassassin ; \
    echo "bayes_path /var/spamassassin/bayesdb/bayes" >> /etc/spamassassin/local.cf ; \
    echo "allow_user_rules 1" >> /etc/spamassassin/local.cf ; \
    mv 9*.cf /etc/spamassassin/ ; \
    echo "alias logger='/usr/bin/logger -e'" >> /etc/bash.bashrc ; \
    echo "LANG=en_US.UTF-8" > /etc/default/locale ; \
    unlink /etc/localtime ; \
    ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime ; \
    unlink /etc/timezone ; \
    ln -s /usr/share/zoneinfo/Europe/Berlin /etc/timezone

# volumes
VOLUME /var/spamassassin
VOLUME /root/.imapfilter
VOLUME /root/accounts

CMD /root/startup && tail -n 0 -F /var/log/*.log