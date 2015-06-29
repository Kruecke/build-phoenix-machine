#!/bin/sh
cd ~

if [ ! -d "pyramid-phoenix" ]; then
    ### Download
    git clone https://github.com/bird-house/malleefowl.git
    git clone https://github.com/bird-house/pyramid-phoenix.git

    ### Install
    make -C malleefowl
    make -C pyramid-phoenix custom.cfg
    # Set password to "phoenix"
    sed -e "s/^\(phoenix-password = \).*/\1sha256:45bcc8442434:dc787c42f0237dfd2b2639685646f0af893ae9b58d5d1c3878d7726f261239ec/" -i pyramid-phoenix/custom.cfg
    make -C pyramid-phoenix
fi

### Start
make -C pyramid-phoenix start
