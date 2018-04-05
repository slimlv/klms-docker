FROM i386/debian:stable-slim

# klms tarball & key & unattended setup
COPY etc /docker/etc/

# system prepare: ssmtp en_US.utf8 pkill Dumper 
# downolad and install klms
# autoconfiugre klms
# overwrite init files
# cleanup
RUN apt-get update && apt-get install ssmtp locales procps perl wget -y && \
    echo "root=postmaster\nmailhub=smarthost\nFromLineOverride=YES\n" >/etc/ssmtp/ssmtp.conf && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* && \
    wget --no-verbose -O /klms.i386.deb -nc "http://products.kaspersky-labs.com/multilanguage/email_gateways/kavlinuxfreebsdmailserver/distributive/linux%20%28deb%29/klms_8.0.2-16_i386.deb" && \
    dpkg -i /klms.i386.deb && \
    sed -i 's/CUR_USER="`id -u`"/CUR_USER="0"/' /etc/init.d/klms && \
    sed -i 's/ps -p $PID -o pid=/kill $PID/' /etc/init.d/klms && \
    sed -i 's/`seq 1 15`/1 2 3 4 5 6 7 8 9 10 11 12 13 14 15/' /etc/init.d/klms && \
    mkdir -p -m 0755 /var/opt/kaspersky && \
    chown kluser:klusers /var/opt/kaspersky /var/log/kaspersky -R && \
    /usr/bin/perl /opt/kaspersky/klms/bin/klms-setup.pl --auto-install=/docker/etc/installer.info && \
    sed -i 's/shared_buffers=.*/shared_buffers=1024MB/' /var/opt/kaspersky/klms/postgresql/postgresql.conf && \
    sed -i 's/log_destination = .*/log_destination = stderr/' /var/opt/kaspersky/klms/postgresql/postgresql.conf && \
    echo "\nDEFAULT_USE_UI=no\nPOSTFIX_INTEGRATION_TYPE=afterqueue\nSTART_SMTP_PROXY=1\n" >>/var/opt/kaspersky/klms/installer.dat && \
    apt-get purge perl wget -y && apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apt/archives/* && rm  /klms.i386.deb

# import key & adjust settings
RUN cp /docker/etc/klms_filters.conf etc/opt/kaspersky/klms/ && \
    cp /docker/etc/klmsdb /etc/init.d/ && \
    cp /docker/etc/klms /etc/init.d/ && \
    /etc/init.d/klmsdb start && /etc/init.d/klms start && \
    /opt/kaspersky/klms/bin/klms-control -l  --install-active-key /docker/etc/kas.key && \
    /opt/kaspersky/klms/bin/klms-control --set-app-settings -f /docker/etc/8.0.2-16-as.xml && \
    /opt/kaspersky/klms/bin/klms-control --set-settings Updater -n -f /docker/etc/8.0.2-16-ks-Updater.xml && \
    /opt/kaspersky/klms/bin/klms-control --start-task Updater -n --progress && \
    /etc/init.d/klmsdb stop && pkill klms

VOLUME ["/var/opt/kaspersky/klms/backup","/var/opt/kaspersky/klms/reports/custom"]

EXPOSE 10025

ENTRYPOINT ["/etc/init.d/klms"]
