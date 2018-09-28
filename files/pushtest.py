# Open a connection in IDLE mode and wait for notifications from the
# server.

from imapclient import IMAPClient
import subprocess
import csv
import logging
import datetime

# read account information
account = list(csv.reader(open('/root/accounts/imap_accounts.txt', 'rb'), delimiter='\t'))
logging.basicConfig(filename='/var/log/pushtest.log',level=logging.INFO, format='%(asctime)s %(message)s')


HOST = account[1][0] 
USERNAME = account[1][1]
PASSWORD = account[1][2]

def scan_spam():
    logging.info("Scanning for SPAM")
    p = subprocess.Popen('/root/scan_spam.sh', stdout=subprocess.PIPE)
    logging.info(p.communicate())

def login():
    #login to server
    while True:
        try:
            server = IMAPClient(HOST)
            server.login(USERNAME, PASSWORD)
            server.select_folder('INBOX')
            # Start IDLE mode
            server.idle()
            logging.info("Connection is now in IDLE mode")
        except Exception as e:
            logging.info("Failed to connect - try again")
            logging.info(e.message)
            continue
        return server


def logoff(server):
    server.idle_done()
    logging.info(("\nIDLE mode done"))
    server.logout()

def pushing(server):
    """run IMAP idle until an exception (like no response) happens"""
    count = 0
    while True:
        try:
            # Wait for up to 30 seconds for an IDLE response
            responses = server.idle_check(timeout=29)           

            if responses:
                logging.info(responses)               
                
            else:
                logging.info("Response: nothing")
                count = count + 1
             
            if count > 5:
                logging.info("No responses from Server - Scan for Spam, then Restart")
                scan_spam()
                count = 0
                raise Exception("No response")
            
            for response in responses:
                count = 0
                if response[1] == "RECENT" or response[1] == "EXISTS":
                    scan_spam()
            
                
        except KeyboardInterrupt:
            break
        except Exception as e:
            logging.info("Push error")
            count = 0
            logging.info(str(e.message))
            break

# run IMAP IDLE until CTRL-C is pressed.
while True:
    try:
        logging.info("Login to IMAP")
        server = login()
        logging.info("Start IAMP IDLE")
        pushing(server)
        logging.info("Logoff from IMAP")
        logoff(server)

    except KeyboardInterrupt:
        break
    except Exception as e:
        logging.info("Exception in Mainloop:")
        logging.info(str(e.message))

# logoff
logoff(server)
logging.info("Pushtest exited")

