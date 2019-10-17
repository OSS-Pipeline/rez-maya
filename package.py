# Based and improved from https://github.com/piratecrew/rez-maya

name = "maya"

version = "2018.0.6"

authors = [
    "Autodesk"
]

description = \
    """
    Autodesk Maya offers a comprehensive creative feature set for 3D computer animation, modeling, simulation,
    rendering, and compositing on a highly extensible production platform.
    """

requires = [
    "cmake-3+",
    "license_manager"
]

variants = [
    ["platform-linux"]
]

tools = [
    "maya",
    "maya2018",
    "maya_license_register"
]

build_system = "cmake"

with scope("config") as config:
    config.build_thread_count = "logical_cores"

uuid = "maya-{version}".format(version=str(version))

def commands():
    env.PATH.prepend("{root}/bin")
    env.PATH.prepend("{root}/maya/bin")
    env.MAYA_LOCATION.set("{root}/maya")
    env.MAYA_VP2_USE_GPU_MAX_TARGET_SIZE.set("1")
    env.AUTODESK_ADLM_THINCLIENT_ENV.set("{root}/Adlm/AdlmThinClientCustomEnv.xml")

    # Helper environment variables.
    env.MAYA_BINARY_PATH.set("{root}/maya/bin")
    env.MAYA_INCLUDE_PATH.set("{root}/maya/include")
    env.MAYA_LIBRARY_PATH.set("{root}/maya/lib")

    # We setup the .flexlmrc file in the home directory of the user, in order to fetch up a license properly.
    import fileinput
    import os
    import sys

    file_path = "{home_folder}/.flexlmrc".format(home_folder=os.environ.get("HOME"))
    license_variable = "ADSKFLEX_LICENSE_FILE"
    license_path = str(env.MAYA_LOCATION)
    is_license_setup = False

    if not os.path.exists(file_path):
        os.system("touch {file_path}".format(file_path=file_path))

    for line in fileinput.input(file_path, inplace=True):
        # We clean the line of potential trailing spaces at the end of the line.
        line = line.rstrip()

        # Check for the correct variable.
        if line.startswith("{license_variable}=".format(license_variable=license_variable)):
            # Add the license path if it is not set in the variable.
            if license_path not in line:
                line += ":{license_path}".format(license_path=license_path)

            # If we at least did find the license variable in the file, i.e. it is correctly set up already, or we add
            # the needed path to it), we confirm it in the boolean.
            is_license_setup = True

        # Write the line back.
        sys.stdout.write(line + "\n")

    # If the license variable was not found in the file, we added it at the end of the file with the correct path.
    if not is_license_setup:
        file_lines = open(file_path, "r").readlines()
        license_file = "{license_variable}={license_path}\n".format(
            license_variable=license_variable,
            license_path=license_path
        )

        # In case we have an empty file...
        if not file_lines:
            file_lines.append(license_file)
        # If the last line is either empty or an escape character...
        elif file_lines[-1] in ["", "\n"]:
            file_lines[-1] = license_file
        # If we need to create an actual new line...
        else:
            file_lines.append(license_file)

        open(file_path, "w").writelines(file_lines)
