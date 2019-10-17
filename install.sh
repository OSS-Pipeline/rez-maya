#!/usr/bin/bash

# Will exit the Bash script the moment any command will itself exit with a non-zero status, thus an error.
set -e

EXTRACT_PATH=$1
INSTALL_PATH=${REZ_BUILD_INSTALL_PATH}
MAYA_VERSION=${REZ_BUILD_PROJECT_VERSION}
MAYA_MAJOR_VERSION=$2

# We print the arguments passed to the Bash script.
echo -e "\n"
echo -e "==============="
echo -e "=== INSTALL ==="
echo -e "==============="
echo -e "\n"

echo -e "[INSTALL][ARGS] EXTRACT PATH: ${EXTRACT_PATH}"
echo -e "[INSTALL][ARGS] INSTALL PATH: ${INSTALL_PATH}"
echo -e "[INSTALL][ARGS] MAYA VERSION: ${MAYA_VERSION}"
echo -e "[INSTALL][ARGS] MAYA MAJOR VERSION: ${MAYA_MAJOR_VERSION}"

# We check if the arguments variables we need are correctly set.
# If not, we abort the process.
if [[ -z ${EXTRACT_PATH} || -z ${INSTALL_PATH} || -z ${MAYA_VERSION} || -z ${MAYA_MAJOR_VERSION} ]]; then
    echo -e "\n"
    echo -e "[INSTALL][ARGS] One or more of the argument variables are empty. Aborting..."
    echo -e "\n"

    exit 1
fi

# We install Maya.
echo -e "\n"
echo -e "[INSTALL] Installing Maya-${MAYA_VERSION}..."
echo -e "\n"

cd ${EXTRACT_PATH}

echo -e "[INSTALL][EXTRACT] Extracting Maya's RPM..."

for rpm in `ls ${EXTRACT_PATH}/Maya*.rpm`;
do
    rpm2cpio ${rpm} | cpio -idm;
done

echo -e "[INSTALL][EXTRACT] Extracting ADLM's RPM..."

for rpm in `ls ${EXTRACT_PATH}/adlmapps*.rpm`;
do
    rpm2cpio ${rpm} | cpio -idm;
done

# We create the necessary directories in the install path.
mkdir -p \
    ${INSTALL_PATH}/maya \
    ${INSTALL_PATH}/Adlm/opt \
    ${INSTALL_PATH}/Adlm/var/opt

MAYA_EXTRACT_PATH=${EXTRACT_PATH}/usr/autodesk/maya${MAYA_MAJOR_VERSION}
ADLM_OPT_EXTRACT_PATH=${EXTRACT_PATH}/opt/Autodesk/Adlm
ADLM_VAR_EXTRACT_PATH=${EXTRACT_PATH}/var/opt/Autodesk/Adlm

# We copy the necessary data in their directories.
cp -rf ${MAYA_EXTRACT_PATH}/* ${INSTALL_PATH}/maya
cp -rf ${ADLM_OPT_EXTRACT_PATH}/* ${INSTALL_PATH}/Adlm/opt
cp -rf ${ADLM_VAR_EXTRACT_PATH}/* ${INSTALL_PATH}/Adlm/var/opt

echo -e "\n"
echo -e "[INSTALL] Finished installing Maya-${MAYA_VERSION}!"
echo -e "\n"
