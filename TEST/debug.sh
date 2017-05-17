#!/bin/sh
set -x
cd ..
dmd prettify.d -debug -gc
ddd prettify --backup TEST/BACKUP_FOLDER/ --output TEST/OUTPUT_FOLDER/ "TEST/test.*"
