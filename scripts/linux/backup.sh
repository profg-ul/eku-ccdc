#!/bin/bash

# Author: Raven Dean
# backup.sh
#
# Description: This script creates a backup of the files and directories passed in the arguments.
#  This script works in tandem with ./restore.sh 
#
# Created: 02/04/2024
# Usage: <./backup.sh <directory>>

#TODO: Ask for user confirmation unlesss --confirm is set
#TODO: Add support for files
#TODO: Add support for infinite arguments
#TODO: Add terminal output for tar, chattr, and sha256sum
script_name="backup.sh"
usage="\e[31mUsage: ./$script_name <directory>\e[0m"

# Import environment variables
. ../../config_files/ekurc

if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then echo "\e[31mError: This script must be ran as root!\e[0m" >&2
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -ne 1 ]
then echo $usage
    exit 1
fi

# Create the backup directory if it doesn't already exist.
mkdir -p $backup_dir

# Check if the argument is a valid file or directory.
if [ -d "$1" ] || [ -f "$1" ] then;
    # Create a backup and save a hash of the generated archive
    
    echo "\e[32m Creating a backup of '$1'..."
    backup_path="$backup_dir/$(basename $1).tar.gz"
    tar -czvf $backup_path $1
    sha256sum $backup_path

    # Make the backups and relevant files immutable to protect backup integrity
    chattr +i $backup_path $(basename $1)-checksum
else
    echo "\e[31mError: '$1': No such file or directory.\e[0m" >&2
fi

# Backup the directory and save a hash of the generated archive
#backup_name=$(basename $1)
 # full-path should be $1
#tar -czvf $backup_dir/$backup_name.tar.gz $1
#sha256sum $backup_dir/$backup_name.tar.gz > $backup_dir/$backup_name-checksum

# Recursively change file attributes to protect backup integrity
#chattr -R +i $backup_dir/$backup_name.tar.gz
#chattr +i $backup_dir/$backup_name-checksum

# Backup complete!
echo "\e[32mThe backup of '$1' was completed successfully!\e[0m"

exit 0 # Script ended successfully
