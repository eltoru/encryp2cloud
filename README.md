encryp2cloud
============

Store files encrypted in a cloud like google drive for backup

 Purpose:  Use this program to setup a crypted backup storage on an external storage location, such as google drive, drop box etc.
           As each file becomes crypted it is fast and easy to add new files to backup and to restore them localy.

 Prerequsites: A user with tiny git knowledge (http://git-scm.com)

 Possabilities/limits: Several encryp2cloud backups can be created, however encryp2cloud can only have one and same password/decryption for 
                       all encryp2cloud backups as it is stored globaly for git and not localy 

 Solution: Git, git-encrypt and openssl are the fundamental techniches used .

 Discalimer: Use it on your own risk. The Author will not take any responsability in any trouble situation regarding usage of this program.

 Usage: Use it as in disclaimer but you are free to share the program to others.

 Short Overview: 
"         A                                B                            C              "
" .--------------------.       .----------------------.        .----------------------."
" |directory to backup |  -->  | google_drive (local) |  --->  | google_drive (cloud) |"
" | pictures etc..     |       | .git db stored here  |        | .git database        |"
" | readable files     |  -->  | encrypted files here |  --->  | files encrypted      |"    
" | .git link here     |       |                      |        |                      |"
" .--------------------.       .----------------------.        .----------------------."
 
  If you place 'A' (directory to be backed up) at OTHER physical disc than 'B' (Google Drive sync folder) location
  you will have two levels of backups. 
  
 Reference:  git-encrypt (git clone https://github.com/shadowhand/git-encrypt)

 Version: 0.1

 Verified for: Mac OS (Should work on linux)
