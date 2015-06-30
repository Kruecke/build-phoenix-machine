#!/bin/bash
cd ~

if [ ! -d "pyramid-phoenix" ]; then
    ### Download
    git clone https://github.com/bird-house/malleefowl.git
    git clone https://github.com/bird-house/pyramid-phoenix.git

    ### Install
    make -C malleefowl 2>&1 | tee make_mallefowl.log
    make -C pyramid-phoenix custom.cfg
    # Set password to "password"
    sed -e "s/^\(phoenix-password = \).*/\1sha256:5a0e483e03a4:1929ff5ef14c6ceb70eb70c0131fc77ded67c3dfedad53ad49b490a7d8d9996f/" -i pyramid-phoenix/custom.cfg
    make -C pyramid-phoenix 2>&1 | tee make_phoenix.log
fi

### Start
make -C pyramid-phoenix start

exit 0
