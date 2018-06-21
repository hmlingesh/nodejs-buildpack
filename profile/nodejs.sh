calculate_concurrency() {
  MEMORY_AVAILABLE=${MEMORY_AVAILABLE-$(detect_memory 512)}
  WEB_MEMORY=${WEB_MEMORY-512}
  WEB_CONCURRENCY=${WEB_CONCURRENCY-$((MEMORY_AVAILABLE/WEB_MEMORY))}
  if (( WEB_CONCURRENCY < 1 )); then
    WEB_CONCURRENCY=1
  fi
  WEB_CONCURRENCY=$WEB_CONCURRENCY
}

log_concurrency() {
  echo "Detected $MEMORY_AVAILABLE MB available memory, $WEB_MEMORY MB limit per process (WEB_MEMORY)"
  echo "Recommending WEB_CONCURRENCY=$WEB_CONCURRENCY"
}

detect_memory() {
  local default=$1
  local limit=$(ulimit -u)

  case $limit in
    256) echo "512";;      # Standard-1X
    512) echo "1024";;     # Standard-2X
    16384) echo "2560";;   # Performance-M
    32768) echo "14336";;  # Performance-L
    *) echo "$default";;
  esac
}

install_oracle_libraries() {
  echo "Installing oracle libraries"
  local ORACLE_DIR=$HOME/.cloudfoundry/oracle
  mkdir -p $ORACLE_DIR
  cd $ORACLE_DIR
  basic_download_url="https://s3.amazonaws.com/covisintrnd.com-software/instantclient-basic.zip"
  sdk_download_url="https://s3.amazonaws.com/covisintrnd.com-software/instantclient-sdk.zip"
  curl -LOk "$basic_download_url"
  echo "Downloaded [$basic_download_url]"
  curl -LOk "$sdk_download_url"
  echo "Downloaded [$sdk_download_url]"
  echo $PWD
  echo "unzipping libraries"
   unzip instantclient-basic.zip
   unzip instantclient-sdk.zip
  mv instantclient_12_2 instantclient
  cd instantclient
  echo $PWD
  ln -s libclntsh.so.12.1 libclntsh.so
  echo $PWD
}

install_oracle_libraries

echo "----setting oracle env vars----"
echo "home path = $HOME"
echo "ld library path = ${LD_LIBRARY_PATH:-}"
export LD_LIBRARY_PATH=$HOME/.cloudfoundry/oracle/instantclient:${LD_LIBRARY_PATH:-}
export OCI_LIB_DIR=$HOME/.cloudfoundry/oracle/instantclient
export OCI_INC_DIR=$HOME/.cloudfoundry/oracle/instantclient/sdk/include
echo "ld library path = ${LD_LIBRARY_PATH:-}"
echo "----/setting oracle env vars----"

calculate_concurrency

export MEMORY_AVAILABLE=$MEMORY_AVAILABLE
export WEB_MEMORY=$WEB_MEMORY
export WEB_CONCURRENCY=$WEB_CONCURRENCY

if [ "$LOG_CONCURRENCY" = "true" ]; then
  log_concurrency
fi
