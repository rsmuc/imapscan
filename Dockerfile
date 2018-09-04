FROM debian:stable-slim

# shell to start from Kitematic
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

WORKDIR /root

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
      python-sphinx \
      unattended-upgrades && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    \
    \
    pip install sphinx_rtd_theme html recommonmark typing && \
    \
    \
	 cd /root && \
    wget https://github.com/rsmuc/isbg/archive/master.zip && \
    unzip master.zip && \
    cd isbg-master && \
    python setup.py install && \
    cd .. && \
    rm -Rf isbg-master && \
    rm master.zip && \
    \
    \
    cd /root && \ 
    wget https://github.com/rsmuc/imapscan/archive/master.zip && \
    unzip master.zip && \
    cd imapscan-master/files && \
    cp * /root && \
    cd && \
    rm -Rf /root/imapscan-master && \
    rm /root/master.zip && \
    apt-get remove wget python-pip python-setuptools unzip -y && \
    apt-get autoremove -y

#ADD files/* /root/

# prepare directories and files
RUN mkdir /root/accounts ; \
	 mkdir /root/.spamassassin; \
	 cp /root/spamassassin_user_prefs /root/.spamassassin/user_prefs ;\
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

# integrate geo database
RUN apt-get update && apt-get install cpanminus make wget -y &&\
		cpanm  YAML &&\
		cpanm Geography::Countries &&\
		cpanm Geo::IP IP::Country::Fast &&\
		cd /tmp && \
		wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz &&\
		gunzip GeoIP.dat.gz &&\
		mkdir /usr/local/share/GeoIP/ &&\
		mv GeoIP.dat /usr/local/share/GeoIP/ &&\
		echo "loadplugin Mail::SpamAssassin::Plugin::RelayCountry" >> /etc/spamassassin/init.pre


# volumes
VOLUME /var/spamassassin/bayesdb
VOLUME /root/accounts

CMD /root/startup && tail -n 0 -F /var/log/*.log
