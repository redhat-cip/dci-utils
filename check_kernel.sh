#!/bin/sh

usage()
{
  echo "Usage: $0 --filter=[FILTER] <TOPIC> <DOWNLOAD_LOCATION>"
  echo ""
  echo "Examples:"
  echo "      $0 RHEL-9.0 /opt/dci"
  echo "      $0 --filter compose:candidate RHEL-8.7 /opt/dci"
  exit 2
}

which_kernel()
{
   compose_path=$1
   if [ -e "$compose_path/metadata/rpms.json" ]; then
      KERNEL=$(jq -r '[.payload.rpms[].x86_64 | keys | map(capture("kernel-[0-9]*:(?<ver>.*).src"))[].ver][0]' $compose_path/metadata/rpms.json)
   else
      KERNEL="no components found"
   fi
   echo "$KERNEL"
}

new_kernel()
{
    KERNEL=$(dci-rhel-latest-kernel-version --topic $TOPIC $FILTER)

    if [ $? -ne 0 ]; then
       echo "No z-stream kernel"
       exit 2
    fi

    PREV_KERNEL=$(which_kernel "$BASEDIR/$TOPIC/compose")
    PREV_NOINSTALL_KERNEL=$(which_kernel "$BASEDIR/$TOPIC/compose-noinstall")

    if [ "$KERNEL" != "$PREV_KERNEL" -a \
         "$KERNEL" != "$PREV_NOINSTALL_KERNEL" ]; then
       echo $KERNEL
       exit 0
    else
       exit 1
    fi
}

# Call getopt to validate the provided input.
options=$(getopt \
	--longoptions "filter:,help" \
	--name "$(basename $0)" \
	--options "" \
       	-- "$@") || exit
eval set -- "$options"
while [[ $# -gt 0 ]]; do
    case "$1" in
    --filter)
        FILTER=$2
        shift;
        ;;
    --help)
	usage
	;;
    --)
        shift
        break
        ;;
    *)
	break
	;;
    esac
    shift
done

TOPIC=$1
BASEDIR=$2

# TOPIC and BASEDIR are required
if [ -z "$TOPIC" -o -z "$BASEDIR" ]; then
   usage
fi

# TAG is optional
if [ -n "$FILTER" ]; then
   TAG="$(echo $FILTER| awk -F: '{print $2}')"
   if [ -z "$TAG" ]; then
      echo "Filter must be of format compose:<TAG>"
      exit 2
   fi
   FILTER="--tag $TAG"
fi

if [ -e "/etc/dci-rhel-agent/dcirc.sh" ]; then
   . /etc/dci-rhel-agent/dcirc.sh
fi

if [ -z "$DCI_CLIENT_ID" -o -z "$DCI_API_SECRET" -o -z "$DCI_CS_URL" ]; then
   echo "DCI_CLIENT_ID, DCI_API_SECRET and DCI_CS_URL must be defined"
   exit 2
fi

new_kernel
