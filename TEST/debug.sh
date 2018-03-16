#!/bin/sh
set -x
cd ..
dmd prettify.d -debug -g
nemiver prettify --backup TEST/BACKUP_FOLDER/ --output TEST/OUTPUT_FOLDER/ "TEST/test.*"
