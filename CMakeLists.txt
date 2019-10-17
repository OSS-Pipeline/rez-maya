CMAKE_MINIMUM_REQUIRED(VERSION 3.0)

include(RezBuild)
include(RezRepository)
include(ExternalProject)

# We split the Maya version string in multiple ones.
string(REPLACE "." ";" MAYA_VERSION_LIST ${REZ_BUILD_PROJECT_VERSION})
list(GET MAYA_VERSION_LIST 0 MAYA_MAJOR_VERSION)
list(GET MAYA_VERSION_LIST 1 MAYA_MINOR_VERSION)
list(GET MAYA_VERSION_LIST 2 MAYA_PATCH_VERSION)

# The Maya product key and ADLM versions, the first one always changing between Maya versions, and the second potentially.
if(${MAYA_MAJOR_VERSION} EQUAL 2018)
    set(MAYA_PRODUCT_KEY 657J1)
    set(ADLM_RELEASE R14)
elseif(${MAYA_MAJOR_VERSION} EQUAL 2019)
    set(MAYA_PRODUCT_KEY 657K1)
    set(ADLM_RELEASE R14)
endif()

# We check if we have the correct license information. If not, we abort the build process.
string(COMPARE EQUAL "$ENV{AUTODESK_LICENSE_SERVER}" "" NO_AUTODESK_LICENSE_SERVER)
string(COMPARE EQUAL "$ENV{MAYA_SERIAL_NUMBER}" "" NO_MAYA_SERIAL_NUMBER)

if (${NO_AUTODESK_LICENSE_SERVER} OR ${NO_MAYA_SERIAL_NUMBER})
    message(FATAL_ERROR
        "The AUTODESK_LICENSE_SERVER and/or MAYA_SERIAL_NUMBER environment variables are not properly setup, "
        "thus we miss some license information to properly setup Maya. Aborting the build process...")

    return()
endif()

# We setup the local variables related to the license information.
set(AUTODESK_LICENSE_SERVER $ENV{AUTODESK_LICENSE_SERVER})
set(MAYA_SERIAL_NUMBER $ENV{MAYA_SERIAL_NUMBER})

# Maya
rez_set_archive(
    # This is a relative path from the ${REZ_REPO_PAYLOAD_DIR} environment variable,
    # that is pointing to the root directory where we can find all the archives of the package
    # we can build, using the following hierarchy:
    # "${REZ_REPO_PAYLOAD_DIR}/project_name/archive.what.ever"
    MAYA_URL maya/Autodesk_Maya_${MAYA_MAJOR_VERSION}_${MAYA_PATCH_VERSION}_Update_Linux_64bit.tgz
    https://url.to/maya/package.tgz
)

# We configure a number of files, by replacing some placeholders variables with CMake variables.
configure_file(config/Adlm/AdlmThinClientCustomEnv.xml.in config/Adlm/AdlmThinClientCustomEnv.xml @ONLY)
configure_file(config/bin/maya.in config/bin/maya @ONLY)
configure_file(config/bin/maya_license_register.in config/bin/maya_license_register @ONLY)
configure_file(config/maya/bin/License.env.in config/maya/bin/License.env @ONLY)
configure_file(config/maya/maya.lic.in config/maya/maya.lic @ONLY)

# The environment variable REZ_TMP_PATH is meant to point to a location, such as "/tmp/rez".
set(EXTRACT_DIR $ENV{REZ_TMP_PATH}/maya/${REZ_BUILD_PROJECT_VERSION})
set(BUILD_DIR ${EXTRACT_DIR}/build)

# We configure/build/install Maya through the ExternalProject_Add macro,
# using three different shell scripts for each of these steps.
# If necessary, it is possible to skip one of these steps by replacing the command
# by "", an empty string.
ExternalProject_Add(
    REZ_MAYA
    URL ${MAYA_URL}
    PREFIX maya
    SOURCE_DIR ${EXTRACT_DIR}
    PATCH_COMMAND ""
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND bash ${CMAKE_SOURCE_DIR}/install.sh ${EXTRACT_DIR} ${MAYA_MAJOR_VERSION}
)

# We install the files we previously configured in the installation directory.
rez_install_files(
    ${CMAKE_CURRENT_BINARY_DIR}/config/Adlm/AdlmThinClientCustomEnv.xml
    RELATIVE build/platform-linux/config/Adlm
    DESTINATION Adlm
)
rez_install_files(
    ${CMAKE_CURRENT_BINARY_DIR}/config/maya/bin/License.env
    RELATIVE build/platform-linux/config/maya/bin
    DESTINATION maya/bin
)
rez_install_files(
    ${CMAKE_CURRENT_BINARY_DIR}/config/maya/maya.lic
    RELATIVE build/platform-linux/config/maya
    DESTINATION maya
)
install(PROGRAMS
    ${CMAKE_CURRENT_BINARY_DIR}/config/bin/maya
    ${CMAKE_CURRENT_BINARY_DIR}/config/bin/maya_license_register
    DESTINATION bin
)

# We use a bogus CMake "install" step in order to be able to properly finish
# and get out of the CMake script.
install(
    CODE
    "execute_process(
        COMMAND echo \"\n[CMAKE] Maya-${REZ_BUILD_PROJECT_VERSION} PACKAGE SETUP FINISHED!\n\"
    )"
)
