#!/bin/bash

echo "Enter drive to use for installation"
read DRIVE

echo "This script will delete all partitions, if you want to cancel press (ctrl + c)"

sfdisk --delete $DRIVE
