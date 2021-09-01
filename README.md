
# buckleup

A pool of shell script to manage my remote backups.

## Install
 *Please note that rsync is required.*

First, go to the directory where you want to setup this script & clone this repository
``` bash
git clone git@github.com:SMAtaurRahman/buckleup.git && cd buckleup
```
Then create `servers.ini` file. File should contain list of servers that you want to manage backup of. See below example:
```
# Only a-z & _ is allowed in server name section
[server_1]
HostName=127.0.0.1
User=myname
Port=22
Location=/home/myname/backup/
RetainFiles=-1

[server_2]
HostName=127.0.0.2
User=myname2
Port=22
Location=/home/myname2/backup/
RetainFiles=-1
```
Here we have listed 2 servers.

`HostName` = IP of the server

`User` = SSH user name

`Port` = SSH port

`Location` = Location of backup files on this server

`RetainFiles` = Number of latest files to retain. Older files will be deleted. `-1` means unlimited. Be extra careful with this option.

After creating ini file, run
```
./fetch_backups.sh
```
A new directory called `backups` will be created in your current directory. Inside that directory, you'll find your backup files that were fetched from servers.

You can use different backup directory path by passing an argument to the command:
```
./fetch_backups.sh /path/to/backup/dir
```


