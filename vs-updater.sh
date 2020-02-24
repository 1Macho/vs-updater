echo "Checking currently installed version..."
CURRENT_VS_VERSION="$(cat ~/.vsversion)"

if [[ $CURRENT_VS_VERSION == "" ]]
then
  echo "Unabe to determine current version. Assuming the game is not installed."
  read -p "Would you like to install the game? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "Okay!"
  else
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  fi
else
  echo "Current version is ${OUTPUT}"
fi

echo "Checking latest stable version..."
LATEST_STABLE_VS_VERSION=$(curl http://api.vintagestory.at/lateststable.txt)

if [[ $LATEST_STABLE_VS_VERSION == "" ]]
then
  echo "Unable to determine the latest stable version. Either curl is not installed, or you can't connect to the api server."
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo "Latest stable version is ${LATEST_STABLE_VS_VERSION}"

if [[ $LATEST_STABLE_VS_VERSION == $CURRENT_VS_VERSION ]]
then
  echo ""
else
  if [[ $CURRENT_VS_VERSION == "" ]]
  then
    echo ""
  else
    read -p "Would you like to update the game? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo "Okay!"
    else
      echo "Launching the game without updating."
      mono ~/ApplicationData/vintagestory/VintageStory.exe
      [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi
  fi

  echo "Creating temporary directory for download..."

  START_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  WORK_DIR=`mktemp -d`
  CLEAN="FALSE"

  if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    echo "Could not create temp dir"
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  fi

  function cleanup {
    if [[ $CLEAN == "FALSE" ]]
    then
      rm -rf "$WORK_DIR"
      echo "Deleted temp working directory $WORK_DIR"
      cd $START_DIR
      CLEAN="TRUE"
    fi
  }

  trap cleanup EXIT
  echo "Downloading version ${LATEST_STABLE_VS_VERSION}..."
  cd $WORK_DIR
  wget "https://cdn.vintagestory.at/gamefiles/stable/vs_archive_${LATEST_STABLE_VS_VERSION}.tar.gz"
  tar -xzvf "vs_archive_${LATEST_STABLE_VS_VERSION}.tar.gz"
  cd "vintagestory"
  echo "Installing the game"
  ./install.sh
  echo "Install done."
  echo "${LATEST_STABLE_VS_VERSION}" > ~/.vsversion
  cleanup
fi

echo "You're up to date! Launching the game..."
mono ~/ApplicationData/vintagestory/Vintagestory.exe
