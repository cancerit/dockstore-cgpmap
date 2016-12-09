#!/bin/bash

TIME_FORMAT='command:%C\nreal:%e\nuser:%U\nsys:%S\npctCpu:%P\ntext:%Xk\ndata:%Dk\nmax:%Mk\n';

set -e

echo -e "\nStart workflow: `date`\n"

declare -a PRE_EXEC
declare -a POST_EXEC

if [ -z ${PARAM_FILE+x} ] ; then
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

if [ -d $INPUT ] ; then
  INPUT="$INPUT/*"
fi

set -u
echo -e "\tSAMPLE_NAME : $SAMPLE_NAME"
echo -e "\tINPUT : $INPUT"
echo -e "\tREF_BASE : $REF_BASE"
echo -e "\tCRAM : $CRAM"
if [ -z ${SCRAMBLE+x} ]; then
  echo -e "\tSCRAMBLE : <NOTSET>"
else
  echo -e "\tSCRAMBLE : $SCRAMBLE"
fi
if [ -z ${BWA_PARAM+x} ]; then
  echo -e "\tBWA_PARAM : <NOTSET>"
else
  echo -e "\tBWA_PARAM : $BWA_PARAM"
fi
set +u

if [ ${#PRE_EXEC[@]} -eq 0 ]; then
  PRE_EXEC='echo No PRE_EXEC defined'
fi

if [ ${#POST_EXEC[@]} -eq 0 ]; then
  POST_EXEC='echo No POST_EXEC defined'
fi

set -u
mkdir -p $OUTPUT_DIR

# run any pre-exec step before attempting to access BAMs
# logically the pre-exec could be pulling them
if [ ! -f $OUTPUT_DIR/pre-exec.done ]; then
  echo -e "\nRun PRE_EXEC: `date`"

  for i in "${PRE_EXEC[@]}"; do
    set -x
    $i
    { set +x; } 2> /dev/null
  done
  touch $OUTPUT_DIR/pre-exec.done
fi

ADD_ARGS=''
if [ $CRAM -gt 0 ]; then
  ADD_ARGS="$ADD_ARGS -c"
  if [ ! -z ${SCRAMBLE+x} ]; then
    ADD_ARGS="$ADD_ARGS -sc '$SCRAMBLE'";
  fi
fi


# use a different malloc library when cores for mapping are over 8
if [ $CPU -gt 7 ]; then
  ADD_ARGS="$ADD_ARGS -l /usr/lib/libtcmalloc_minimal.so"
fi

# if BWA_PARAM set
if [ ! -z ${BWA_PARAM+x} ]; then
  ADD_ARGS="$ADD_ARGS -b '$BWA_PARAM'"
fi

set -x
/usr/bin/time -f $TIME_FORMAT -o $OUTPUT_DIR/$SAMPLE_NAME.bam.maptime \
 bwa_mem.pl -o $OUTPUT_DIR \
 -r $REF_BASE/genome.fa \
 -s $SAMPLE_NAME \
 -f 25 \
 -t $CPU \
 -mt $CPU \
 $ADD_ARGS \
 $INPUT
{ set +x; } 2> /dev/null

# run any post-exec step
echo -e "\nRun POST_EXEC: `date`"
for i in "${POST_EXEC[@]}"; do
  set -x
  $i
  { set +x; } 2> /dev/null
done

echo -e "\nWorkflow end: `date`"
