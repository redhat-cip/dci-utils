
# How to use

Mount the directory you are downloading the distros to /opt
To check if the latest compose has a newer compose and filter by candidate

```console
. dcirc.sh
podman run -v /opt/dci:/opt -e DCI_CLIENT_ID=$DCI_CLIENT_ID \
                            -e DCI_API_SECRET=$DCI_API_SECRET \
                            -e DCI_CS_URL=$DCI_CS_URL quay.io/distributedci/dci-utils \
                            check_kernel.sh --filter compose:candidate RHEL-8.8 /opt
```

Same as above but also download the compose if the kernel is new

```console
. dcirc.sh
podman run -v /opt/dci:/opt -e DCI_CLIENT_ID=$DCI_CLIENT_ID \
                            -e DCI_API_SECRET=$DCI_API_SECRET \
                            -e DCI_CS_URL=$DCI_CS_URL quay.io/distributedci/dci-utils \
                            check_kernel.sh --filter compose:candidate RHEL-8.8 /opt && \
podman run -v /opt/dci:/opt -e DCI_CLIENT_ID=$DCI_CLIENT_ID \
                            -e DCI_API_SECRET=$DCI_API_SECRET \
                            -e DCI_CS_URL=$DCI_CS_URL quay.io/distributedci/dci-utils \
                            dci-downloader --filter compose:candidate RHEL-8.8 /opt
```
