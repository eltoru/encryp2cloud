#!/bin/sh 
#
# Author: Tobias Rundgren
# Date: 2014-05-02
#
# Purpose:  Use this program to setup an encrypted backup storage on an external storage location, such as google drive, drop box etc.
#           As each file becomes encrypted it is fast and easy to add new files to backup and to restore them localy.
#
# Prerequsites: A user with tiny git knowledge (http://git-scm.com)
#
# Possabilities/limits: Several encryp2cloud backups can be created, however encryp2cloud can only have one and same password/decryption for 
#                       all encryp2cloud backups as it is stored globaly for git and not localy 
#
# Solution: Git, git-encrypt and openssl are the fundamental techniches used .
#
# Discalimer: Use it on your own risk. The Author will not take any responsability in any trouble situation regarding usage of this program.
#
# Usage: Use it as in disclaimer but you are free to share the program to others.
#
# Short Overview: 
#             A                          B                                   C
#     .--------------------.       .----------------------.           .----------------------.
#     |directory to backup |  -->  | google_drive (local) |   --->    | google_drive (cloud) | 
#     | pictures etc..     |       | .git db stored here  |           | .git database        |
#     | readable files     |       | encrypted files here |           | files encrypted      |
#     | .git link here     |       |                      |           |                      |
#     .--------------------.       .----------------------.           .----------------------.
# 
#  If you place 'A' (directory to be backed up) at OTHER physical disc than 'B' (Google Drive sync folder) location
#  you will have two levels of backups. 
#  
# Reference:  git-encrypt (git clone https://github.com/shadowhand/git-encrypt)
#
# Version: 0.1
#
# Verified for: Mac OS
#
# Verify decryption: 
# 
# Check a file in .git database like this
# git ls-tree HEAD
# git cat-file -p "TheBlobObjectSHA" | openssl enc -d -base64 -aes-256-ecb -k "password" > your_secret_file_will_be_visable_now



cwd=`pwd`

install_git()
{
    echo "install git from this url: http://git-scm.com/download/"
    echo "before proceed.."
    exit 1
}

install_openssl()
{
    echo "install openssl from this url: https://www.openssl.org/source/"
    echo "before continue.."
    exit 1
}

install_git_crypt()
{
    tmp=./tmp_gitencrypt$$
    mkdir -p $tmp
    cd $tmp
    git clone https://github.com/shadowhand/git-encrypt || cp `dirname $0`/git-encrypt . || (echo "Error: can not find git-encrypt package to install.."; exit 1)
    git_bin_exec=`which git`
    git_bin=`dirname ${git_bin_exec}` 
    sudo rm -f  ${git_bin}/../git-encrypt
    sudo mv git-encrypt ${git_bin}/../.
    cd ${git_bin}
    sudo rm -f gitcrypt
    sudo ln -s ${git_bin}/../git-encrypt/gitcrypt gitcrypt
    sudo chmod 0755 ${git_bin}/../git-encrypt/gitcrypt
    cd $cwd
    rm -rf $tmp
}

setup_new_or_existing()
{
    echo "Give path to point out where to place your encrypted stored backup (path to Google Drive, Dropbox etc..):"
    read -p "path:" backpath
    [ -d $backpath ] && echo "check path -ok" || (echo "check path -failed- no such directory"; exit 1)
    [ $? -gt 0 ] && exit 1

    read -p "Setup a (N)ew dir or (E)xisting directory to be encrypted (N/E):" resp
    if [ "$resp" = "E" ]; then
      read -p "Existing directory path:" crydir
    else
      read -p "New directory path:" crydir
    fi
}

prereq()
{
    which openssl >/dev/null 2>&1 || install_open_ssl 

    which git >/dev/null 2>&1 || install_git

    which gitcrypt >/dev/null 2>&1 || install_git_crypt
}

setup()
{
    setup_new_or_existing

    [ ! -d "$backpath"/`basename $crydir`.encryp2cloud.git ] || (echo "backup dir with that name already exists.."; exit 1)
    [ $? -gt 0 ] && exit 1

    mkdir -p $crydir
    cd $crydir

    git init --separate-git-dir "$backpath"/`basename $crydir`.encryp2cloud.git
    cp $cwd/$0 "$backpath"/`basename $crydir`.encryp2cloud.git/.

    #Before use gitcrypt make sure to store SALT and PASS outside backup folder before proceed.
    cat `which gitcrypt` | sed -e 's#git config gitcrypt.#git config --global gitcrypt.#g' > ./gitcrypt.tmp$$
    sudo cp ./gitcrypt.tmp$$ `which gitcrypt`
    rm -f ./gitcrypt.tmp$$

    gitcrypt init
     
    git config --global --list | grep gitcrypt > $HOME/important.`basename $crydir`.gitcrypt

    echo "!!!! Key file is created and needs to be saved on a safe place outside your computer!!!!"
    echo "Keyfile for decrypting encryp2cloud backup: $HOME/important.gitcrypt"
    echo ""
    echo "For easy recovery, encryp2cloud.sh has been copied to backup driver at "
    echo "path:  "$backpath"/`basename $crydir`.encryp2cloud.git/encryp2cloud.sh"
    echo "Your encryp2cloud directory is ready to use: $crydir "
    echo ""
    echo "Use plain git commands to add files for backup:  "
    echo "-----------------------------------------------------------------------------------------------"
    echo "Add all new files to backup:            git add ."
    echo "Set a commit baseline for tracability:  git commit -m \"Added famaly photos for backup 2014\""
}

restore()
{
    [ -f $KEYFILE ] || (echo "Key file for encryp2cloud missing..exit"; exit 1) 
    [ $? -gt 0 ] && exit 1

    if [ -f $HOME/.gitconfig ]; then
      git config --global --list | grep gitcrypt >/dev/null 2>&1 || (cat $KEYFILE | sed -e "s#gitcrypt#git config --global gitcrypt#g" | sed -e "s#=# #g" > tmpfile$$)
    else
      cat $KEYFILE | sed -e "s#gitcrypt#git config --global gitcrypt#g" | sed -e "s#=# #g" > tmpfile$$
    fi
    source tmpfile$$
    rm -f tmpfile$$
    prereq

    read -p "Give path and filename to your filename.encryp2cloud.git :" restore_db
    [ -d $restore_db ] || (echo "Can not find $restore_db"; exit 1)
    [ $? -gt 0 ] && exit 1

    cry_db_name=`basename $restore_db | sed -e 's#.encryp2cloud.git##'` 
    echo "The remote encryp2cloud backup will be restored localy, give a path where to place the recovered database"
    read -p "Path:" newpath
    [ -d $newpath/$cry_db_name ] && (echo "Error: already exists: $newpath/$cry_db_name"; exit 1) || mkdir -p $newpath/$cry_db_name
    [ $? -gt 0 ] && exit 1

    cd $newpath/$cry_db_name
    echo "gitdir: $restore_db" > .git
    git status

    echo "Use plain git commands to restore/decrypt your files from encryp2cloud backup"
    echo "-------------------------------------------------------------------------"
    echo "Restore all files: git checkout master"
    echo "Restore a specific file: git checkout -- filename"
}


function usage()
{
    head -45 $0 | grep -v '#!/'
    echo "\tUsage:"
    echo "\t./$0 --setup"
    echo "\tor"
    echo "\t./$0 --restore=/path/to/important_keys.encryp2cloud"
    echo "\t-h --help"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --setup)
            prereq
            setup
            exit
            ;;
        --restore)
            KEYFILE=$VALUE
            restore
            exit
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

usage
exit 1
