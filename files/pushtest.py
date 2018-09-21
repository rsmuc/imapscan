# Open a connection in IDLE mode and wait for notifications from the
# server.

from imapclient import IMAPClient
import subprocess
import csv
import logging

# read account information
account = list(csv.reader(open('/root/accounts/imap_accounts.txt', 'rb'), delimiter='\t'))
logging.basicConfig(filename='/var/log/pushest.log',level=logging.INFO)


HOST = account[1][0] 
USERNAME = account[1][1]
PASSWORD = account[1][2]

server = IMAPClient(HOST)
server.login(USERNAME, PASSWORD)
server.select_folder('INBOX')

# Start IDLE mode
server.idle()
logging.info("Connection is now in IDLE mode")

while True:
    try:
        # Wait for up to 30 seconds for an IDLE response
        responses = server.idle_check(timeout=120)
        for response in responses:
            if response[1] == "RECENT":
                p = subprocess.Popen('/root/scan_spam.sh', stdout=subprocess.PIPE)
                logging.info(p.communicate())
    except KeyboardInterrupt:
        break

server.idle_done()
logging.info(("\nIDLE mode done"))
server.logout()

