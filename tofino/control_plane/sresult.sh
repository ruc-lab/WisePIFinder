#!/bin/bash
PYEXE=`which python`

PYPYTH=/usr/local/lib/python2.7/dist-packages/protobuf-3.6.1-py2.7.egg

PYPYTH=${PYPYTH}:$SDE/install/lib/python2.7/site-packages/bf-ptf
PYPYTH=${PYPYTH}:$SDE/install/lib/python2.7/site-packages/p4testutils
PYPYTH=${PYPYTH}:$SDE/install/lib/python2.7/site-packages/tofinopd
PYPYTH=${PYPYTH}:$SDE/install/lib/python2.7/site-packages/tofino
PYPYTH=${PYPYTH}:$SDE/install/lib/python2.7/site-packages
PYPYTH=${PYPYTH}:$SDE/install/lib/python2.7/site-packages/tofino/bfrt_grpc
# PYPYTH=${PYPYTH}:/usr/local/lib/python2.7/dist-packages
PYTHONPATH=${PYPYTH} $PYEXE result.py
