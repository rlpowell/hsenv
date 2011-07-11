#!/bin/bash

if [ -n "${VIRTHUALENV}" ]; then
    echo "There is already active ${VIRTHUALENV_NAME} Virtual Haskell Environment (at ${VIRTHUALENV})."
    echo "Deactivate it first (using 'deactivate' command), to create another environment."
    exit 1
fi

VIRTHUALENV_SCRIPT_DIR="$(dirname ${0})"
CABAL_CONFIG_SKEL="${VIRTHUALENV_SCRIPT_DIR}/cabal_config"
CABAL_WRAPPER_SKEL="${VIRTHUALENV_SCRIPT_DIR}/cabal"
ACTIVATE_SKEL="${VIRTHUALENV_SCRIPT_DIR}/activate"
ORIG_CABAL_BINARY="$(which cabal)"

VIRTHUALENV_NAME="${1}"
VIRTHUALENV="$(pwd)/${VIRTHUALENV_NAME}"
GHC_ARCH_OS_VER=i386-linux-7.0.4
GHC_PACKAGE_PATH="${VIRTHUALENV}/.ghc/${GHC_ARCH_OS_VER}/package.conf.d"
CABAL_DIR="${VIRTHUALENV}/.cabal"
CABAL_CONFIG="${CABAL_DIR}/config"
VIRTHUALENV_DIR="${VIRTHUALENV}/.virthualenv"
VIRTHUALENV_BIN_DIR="${VIRTHUALENV_DIR}/bin"
ACTIVATE_SCRIPT="${VIRTHUALENV_BIN_DIR}/activate"
CABAL_WRAPPER="${VIRTHUALENV_BIN_DIR}/cabal"
BOOT_PACKAGES="ffi rts ghc-prim integer-gmp base array containers filepath old-locale old-time unix directory pretty process Cabal bytestring ghc-binary bin-package-db hpc template-haskell ghc"

mkdir "${VIRTHUALENV}"
mkdir "${CABAL_DIR}"
mkdir "${VIRTHUALENV_DIR}"
mkdir "${VIRTHUALENV_BIN_DIR}"

ghc-pkg init "${GHC_PACKAGE_PATH}"

for package in ${BOOT_PACKAGES}; do
    ghc-pkg describe "${package}" | (GHC_PACKAGE_PATH="${GHC_PACKAGE_PATH}" ghc-pkg register -)
done

cat "${CABAL_CONFIG_SKEL}" | sed "s:<VIRTHUALENV>:${VIRTHUALENV}:g" | sed "s:<GHC_PACKAGE_PATH>:${GHC_PACKAGE_PATH}:g" > "${CABAL_CONFIG}"

# GHC_PACKAGE_PATH="${GHC_PACKAGE_PATH}" cabal --config-file="${CABAL_CONFIG}" update
cp -r /tmp/packages "${CABAL_DIR}"

cat "${ACTIVATE_SKEL}" | sed "s:<VIRTHUALENV_NAME>:${VIRTHUALENV_NAME}:g" | sed "s:<VIRTHUALENV>:${VIRTHUALENV}:g" | sed "s:<GHC_PACKAGE_PATH>:${GHC_PACKAGE_PATH}:g" >> "${ACTIVATE_SCRIPT}"

cat "${CABAL_WRAPPER_SKEL}" | sed "s:<ORIG_CABAL_BINARY>:${ORIG_CABAL_BINARY}:g" > "${CABAL_WRAPPER}"
chmod +x "${CABAL_WRAPPER}"
