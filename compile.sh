#!/bin/bash
CWD=$(pwd)

if [ ! -f ${CWD}/.settings ]; then
		echo "ERROR: Create a .settings file."
		exit 1
fi

source ${CWD}/.settings

if [ -d ${DEST_DIR} ]; then
		rm -r ${DEST_DIR}
fi

# Prepare output env
cp -r ${SRC_DIR} ${DEST_DIR}

# Compile
coffee simple-coffee-dependencies.coffee -I "${SRC_DIR}" -F "${SRC_DIR}/Main.coffee" > "${DEST_DIR}/nodeproxy.coffee"
coffee -o "${DEST_DIR}/" -c "${DEST_DIR}/nodeproxy.coffee"

# Clean up old coffee files
find ${DEST_DIR} -type f -name "*.coffee" -exec rm -f {} \;
