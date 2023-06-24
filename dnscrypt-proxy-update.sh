#! /bin/sh

INSTALL_DIR="/etc/dnscrypt-proxy"
LATEST_URL="https://api.github.com/repos/DNSCrypt/dnscrypt-proxy/releases/latest"
DNSCRYPT_PUBLIC_KEY="RWTk1xXqcTODeYttYMCMLo0YJHaFEHn7a3akqHlb/7QvIQXHVPxKbjB5"

ARCH=$(uname -m)
if [[ "$ARCH" == x86_64* ]]; then
  dnsscrpt_arch=x86_64
elif [[ "$ARCH" == aarch64* ]]; then
    dnsscrpt_arch=arm64
else
   echo -e "${RED}This script is only for x86_64 or ARM64  Architecture !${ENDCOLOR}"
   exit 1
fi


PLATFORM="linux"
CPU_ARCH="$dnsscrpt_arch"

Update() {
  workdir="$(mktemp -d)"
  download_url="$(curl -sL "$LATEST_URL" | grep dnscrypt-proxy-${PLATFORM}_${CPU_ARCH}- | grep browser_download_url | head -1 | cut -d \" -f 4)"
  echo "[INFO] Downloading update from '$download_url'..."
  download_file="dnscrypt-proxy-update.tar.gz"
  curl --request GET -sL --url "$download_url" --output "$workdir/$download_file"
  response=$?

  if [ $response -ne 0 ]; then
    echo "[ERROR] Could not download file from '$download_url'" >&2
    rm -Rf "$workdir"
    return 1
  fi

  if [ -x "$(command -v minisign)" ]; then
    curl --request GET -sL --url "${download_url}.minisig" --output "$workdir/${download_file}.minisig"
    minisign -Vm "$workdir/$download_file" -P "$DNSCRYPT_PUBLIC_KEY"
    valid_file=$?

    if [ $valid_file -ne 0 ]; then
      echo "[ERROR] Downloaded file has failed signature verification. Update aborted." >&2
      rm -Rf "$workdir"
      return 1
    fi
  else
    echo '[WARN] minisign is not installed, downloaded file signature could not be verified.'
  fi

  echo '[INFO] Initiating update of DNSCrypt-proxy'

  tar xz -C "$workdir" -f "$workdir/$download_file" ${PLATFORM}-${CPU_ARCH}/dnscrypt-proxy &&
    mv -f "${INSTALL_DIR}/dnscrypt-proxy" "${INSTALL_DIR}/dnscrypt-proxy.old" &&
    mv -f "${workdir}/${PLATFORM}-${CPU_ARCH}/dnscrypt-proxy" "${INSTALL_DIR}/" &&
    chmod u+x "${INSTALL_DIR}/dnscrypt-proxy" &&
    cd "$INSTALL_DIR" &&
    ./dnscrypt-proxy -check && ./dnscrypt-proxy -service install 2>/dev/null || : &&
    ./dnscrypt-proxy -service restart || ./dnscrypt-proxy -service start

  updated_successfully=$?

  rm -Rf "$workdir"
  if [ $updated_successfully -eq 0 ]; then
    echo '[INFO] DNSCrypt-proxy has been successfully updated!'
    return 0
  else
    echo '[ERROR] Unable to complete DNSCrypt-proxy update. Update has been aborted.' >&2
    return 1
  fi
}

if [ ! -f "${INSTALL_DIR}/dnscrypt-proxy" ]; then
  echo "[ERROR] DNSCrypt-proxy is not installed in '${INSTALL_DIR}/dnscrypt-proxy'. Update aborted..." >&2
  exit 1
fi

local_version=$("${INSTALL_DIR}/dnscrypt-proxy" -version)
remote_version=$(curl -sL "$LATEST_URL" | grep "tag_name" | head -1 | cut -d \" -f 4)

if [ -z "$local_version" ] || [ -z "$remote_version" ]; then
  echo "[ERROR] Could not retrieve DNSCrypt-proxy version. Update aborted... " >&2
  exit 1
else
  echo "[INFO] local_version=$local_version, remote_version=$remote_version"
fi

if [ "$local_version" != "$remote_version" ]; then
  echo "[INFO] local_version not synced with remote_version, initiating update..."
  Update
  exit $?
else
  echo "[INFO] No updated needed."
  exit 0
fi
