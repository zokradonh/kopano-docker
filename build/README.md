Helper container for systems where build requirements (bash, curl, jq, make) are not available (for example on Synology)

Run the following command to enter the "build environment" (command may need to be adapted if the files are cloned into a different directory):
```
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/..:/kopano-docker/ $(docker build -q .)
```

Afterwards you can execute the `setup.sh` script, modify `.env` to your liking and run any make commands:
```
bash-4.4# ./setup.sh
Creating an .env file for you
Which tag do you want to use for Kopano Core components? [latest]:
Which tag do you want to use for Kopano WebApp? [latest]:
Which tag do you want to use for Z-Push? [latest]:
Name of the Organisation for LDAP [Kopano Demo]:
FQDN to be used (for reverse proxy) [kopano.demo]:
Email address to use for Lets Encrypt. Use 'self_signed' as your email to create self signed certificates [self_signed]:
Name of the BASE DN for LDAP [dc=kopano,dc=demo]:
LDAP server to be used (defaults to the bundled OpenLDAP) [ldap://ldap:389]:
Timezone to be used [Europe/Berlin.]:
E-Mail Address displayed for the 'postmaster' [postmaster@kopano.demo]:
Name/Address of Database server (defaults to the bundled one) [db]:
Avaliable options:
  1 ) de-at
  2 ) de-ch
  3 ) de-de
  4 ) en
  5 ) en-gb
  6 ) es
  7 ) fr
  8 ) it
  9 ) nl
 10 ) pl-pl
Check language spell support (again to uncheck, ENTER when done):
Avaliable options:
  1 ) contactfax
  2 ) desktopnotifications
  3 ) filepreviewer
  4 ) files
  5 ) filesbackend-smb
  6 ) filesbackend-owncloud
  7 ) folderwidgets
  8 ) gmaps
  9 ) intranet
 10 ) mattermost
 11 ) mdm
 12 ) pimfolder
 13 ) quickitems
 14 ) smime
 15 ) titlecounter
 16 ) webappmanual
 17 ) zdeveloper
Check for additional plugins (again to uncheck, ENTER when done):
Integrate WhatsApp into DeskApp yes/no [no]:

bash-4.4# make build-all
docker build -t zokradonh/kopano_ssl ssl/
Sending build context to Docker daemon  4.608kB
[...]
```
Afterwards you can exit the container and run `docker-compose up -d` and will have the images you previously built.
