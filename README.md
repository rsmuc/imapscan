# testing only

## todos:

~~* integrate heinlein scripts (added to cron and startup)~~

~~* integrate bayes filter (sa-learn --backup > backup.txt ; sa-learn --restore backup.txt)~~

~~* show always header (added to user_prefs)~~

~~* mark with ***SPAM*** (added to user prefs)~~

~~* make learnhambox configurable~~

~~* check if spamassassin is stable (issues on debian native)~~

~~* provide patch for --dryrun and --learnspambox issue~~

~~* find better solution for report in HAM~~

~~* make HAM report configurable~~

* integrate logrotation


## features:

* Integrated a report for all HAM mails. Reachable via lighttpd e.g.: http://192.168.1.23:8000/mailreport.txt

* Integrated PUSH / IMAP IDLE support

* integrated geo database and filters for it

* focused on encrypted emails (header analysis only)

* custom spamassassin rules for Germany and header analysis (my mails are prefiltered by mailbox.org - this container is only focused to the SPAM the MBO filter does not catch)

* account information and bayes database persistent

* latest isbg + patched version

* spamassassin report will be written to SPAMs and also to HAM mails in the header

## run dockercontainer:
* sudo docker volume create bayesdb
* sudo docker volume create accounts
* sudo docker run -d --name isbg-test -v bayesdb:/var/spamassassin/bayesdb -v accounts:/root/accounts -p 8000:80 isbg-test

- if available copy the bayes_database to /root/bayesdb or use sa-learn --restore
- check if user rights for /var/spamassassin/bayeddb are correct (spamd must have read and write access)
- configure the accounts at /root/accounts
- remove the comments from crontab (crontab -e) to start automatic check


Docker container that uses [isbg](https://github.com/dc55028/isbg) and [imapfilter](https://github.com/lefcha/imapfilter) to filter out spam from a remote IMAP server.

Docker hub link: https://hub.docker.com/r/domcomte/imapscan/

[![](https://images.microbadger.com/badges/image/domcomte/imapscan.svg)] [![](https://images.microbadger.com/badges/version/domcomte/imapscan.svg)]

Configuration: There are 3 volumes, their content is initialized during container startup:

/var/spamassassin : holds the SpamAssassin data files, to keep them between container resets.
/root/.imapfilter : holds the ImapFilter configuration script.
/root/accounts : holds the IMAP accounts configuration.
To configure your IMAP accounts, edit the accounts_imap.txt and imap_accounts_learn.txt in the /root/accounts directory in the container, or in the /root/accounts volume on the host. They are tab-separated files, and the first line has the field names.

In both files, the "junk" field is where the Spam folder is, and the last field is the directory you want to scan, either to learn spam or to scan for spam.

The container runs a learning process on startup, so do not leave a configuration with a huge email directory active if you want the container to start in a reasonnable time.
