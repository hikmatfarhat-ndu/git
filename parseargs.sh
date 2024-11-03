#!/bin/bash
while getopts "a:b" flag
do
	echo "${flag} = ${OPTARG}"
done
