Simple Ruby File Upload Script
==============================

A ruby script created to uploads files. Currently, only the FTP protocol is supported.
___________

How to use:
==============================

Start the script with the following arguments:

* The first arguement should be the server address, username, and password (in that order) for the FTP transfer with the information separated by a single space. 

       * Any information not provided will be requested when the script runs. I.E. providing "ftp.server.com username1 password1" would automatically start uploading, whereas "ftp.server.com username1" would require the user to type in the password for the username before the transfer would start.
* Each following argument should be the absolute path of a file to upload. No file limit.

* Once the script has the login credentials it will begin uploading the files. 
* When finished the script will wait for the user to press a key to confirm they have seen that the upload has completed. Once a key has been pressed the script will close.