#!/usr/bin/env bash
TOKEN=$1
GIRA_HOME=$HOME/.gira
BIN_PATH=$GIRA_HOME/bin
PROXYCHAINS=$BIN_PATH/proxychains4
GIRA=$BIN_PATH/gira

function usage(){
  echo "usage: install <gira-token>"
  exit 0
}

function install(){

  if [ -f "$GIRA" ]; then
    echo gira is already installed in this compute!
    exit 1
  fi

  echo "installing gira"

  platform='unknown'
  unamestr=`uname`
  if [[ "$unamestr" == 'Linux' ]]; then
     platform='linux'
  elif [[ "$unamestr" == 'Darwin' ]]; then
     platform='mac'
  fi

  [ "unknown" == $platform ] && { echo "only Mac & Linux are supported yet."; exit 1; }

  mkdir -p $BIN_PATH
  chmod 700 $GIRA_HOME

  wget "https://girathisisdashassets-pnq-cc.alikunlun.com/vendor/proxychains4-$platform.bin" -O $PROXYCHAINS -q
  chmod a+x $PROXYCHAINS

  wget "https://girathisisdashassets-pnq-cc.alikunlun.com/dl/gira-$platform.bin" -O $GIRA -q
  chmod a+x $GIRA

  sudo ln -s $GIRA /usr/local/bin

  echo $TOKEN > $GIRA_HOME/conf/token
  echo "-> Done!"

  cat <<EOF

*******************************************************************************
gira installed successfully
*******************************************************************************

You can now use \`gira\` to run your applications with tcp connection proxied
EOF
}

function install_proxychains(){
  echo "installing proxychains"
  type brew > /dev/null 2>&1
}

[ -z "$TOKEN" ] && usage
install
