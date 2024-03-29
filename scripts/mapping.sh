#!/bin/bash

TIME_FORMAT='command:%C\\nreal:%e\\nuser:%U\\nsys:%S\\npctCpu:%P\\ntext:%Xk\\ndata:%Dk\\nmax:%Mk\\n';

set -e

echo -e "\nStart workflow: `date`\n"

declare -a PRE_EXEC
declare -a POST_EXEC

if [[ $# -eq 1 ]] ; then
  PARAM_FILE=$1
elif [ -z ${PARAM_FILE+x} ] ; then
  PARAM_FILE=$HOME/run.params
fi

echo "Loading user options from: $PARAM_FILE"
if [ ! -f $PARAM_FILE ]; then
  echo -e "\tERROR: file indicated by PARAM_FILE not found: $PARAM_FILE" 1>&2
  exit 1
fi
source $PARAM_FILE

if [ -z ${CPU+x} ]; then
  CPU=`grep -c ^processor /proc/cpuinfo`
fi

if [ -d "$INPUT" ] ; then
  INPUT="$INPUT/*"
fi

set -u
echo -e "\tSAMPLE_NAME : $SAMPLE_NAME"
echo -e "\tINPUT : $INPUT"
echo -e "\tREF_BASE : $REF_BASE"
echo -e "\tCRAM : $CRAM"
echo -e "\tCSI : $CSI"
echo -e "\tMMQC : $MMQC"
if [ -z ${BWA_PARAM+x} ]; then
  echo -e "\tBWA_PARAM : <NOTSET>"
else
  echo -e "\tBWA_PARAM : $BWA_PARAM"
fi
if [ -z ${GROUPINFO+x} ]; then
  echo -e "\tGROUPINFO : <NOTSET>"
else
  echo -e "\tGROUPINFO : $GROUPINFO"
fi
if [ -z ${DUPMODE+x} ]; then
  echo -e "\tDUPMODE : <NOTSET>"
else
  echo -e "\tDUPMODE : $DUPMODE"
fi
if [ -z ${SEQSLICE+x} ]; then
  echo -e "\tSEQSLICE : <NOTSET>"
else
  echo -e "\tSEQSLICE : $SEQSLICE"
fi
echo -e "\tBWAMEM2 : $BWAMEM2"
echo -e "\tBWAKIT : $BWAKIT"
echo -e "\tNOMARKDUP : $NOMARKDUP"
echo -e "\tLEGACY : $LEGACY"
set +u

if [ ${#PRE_EXEC[@]} -eq 0 ]; then
  PRE_EXEC='echo No PRE_EXEC defined'
fi

if [ ${#POST_EXEC[@]} -eq 0 ]; then
  POST_EXEC='echo No POST_EXEC defined'
fi

set -u
mkdir -p $OUTPUT_DIR

TIME_EXT="bam"

ADD_ARGS=''
if [ $CRAM -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS -c"
  TIME_EXT="cram"
  if [ ! -z ${SCRAMBLE+x} ]; then
    ADD_ARGS="$ADD_ARGS -sc ' $SCRAMBLE'";
  fi
fi

# use a different malloc library when cores for mapping are over 8
if [ $CPU -gt 7 ]; then
  ADD_ARGS="$ADD_ARGS -l /usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"
fi

# if BWA_PARAM set
if [ ! -z ${BWA_PARAM+x} ]; then
  ADD_ARGS="$ADD_ARGS -b '$BWA_PARAM'"
fi

# if GROUPINFO set
if [ ! -z ${GROUPINFO+x} ]; then
  ADD_ARGS="$ADD_ARGS -g $GROUPINFO"
fi

# if CSI set
if [ $CSI -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS --csi"
fi

# if MMQC set
if [ $MMQC -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS --mmqc"
  if [ ! -z ${MMQCFRAC+x} ]; then
    ADD_ARGS="$ADD_ARGS --mmqcfrac $MMQCFRAC"
  fi
fi

# if DUPMODE set
if [ ! -z ${DUPMODE+x} ]; then
  ADD_ARGS="$ADD_ARGS --dupmode $DUPMODE"
fi

# if BWAMEM2 set
if [ $BWAMEM2 -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS --bwamem2"
fi

# if BWAKIT set
if [ $BWAKIT -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS --bwakit"
fi

# if NOMARKDUP set
if [ $NOMARKDUP -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS --nomarkdup"
fi

# if LEGACY set
if [ $LEGACY -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS --legacy"
fi

# if SEQSLICE set
if [ ! -z ${SEQSLICE+x} ]; then
  ADD_ARGS="$ADD_ARGS --seqslice $SEQSLICE"
fi

# -f set to be unfeasibly large to prevent splitting of lane data.
set -x
bash -c "/usr/bin/time -f $TIME_FORMAT -o $OUTPUT_DIR/$SAMPLE_NAME.$TIME_EXT.maptime \
 bwa_mem.pl -o $OUTPUT_DIR \
 -r $REF_BASE/genome.fa \
 -s $SAMPLE_NAME \
 -f 1000000 \
 -t $CPU \
 -mt $CPU \
 $ADD_ARGS \
 $INPUT"
{ set +x; } 2> /dev/null

# cleanup reference area, see ds-cgpmap.pl
if [ $CLEAN_REF -gt 0 ]; then
  rm -rf $REF_BASE
fi

echo -e "\nWorkflow end: `date`"
