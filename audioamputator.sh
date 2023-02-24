#!/bin/bash

function usage {
        echo "Usage:"
        echo "./$(basename $0) -i --> input file (mandatory)"
        echo "./$(basename $0) -o --> output file (mandatory)"
        echo "./$(basename $0) -s --> start cut-point (in decimal seconds) (default: start of input)"
        echo "./$(basename $0) -e --> end cut-point (in decimal seconds) (default: end of input)"
        echo "./$(basename $0) -r --> sample rate (in Hz) (default: 44100)"
        echo "./$(basename $0) -c --> number of channels (default: 2)"
        echo "./$(basename $0) -d --> bit depth (default: 16)"
        echo "./$(basename $0) -f --> format (in ffmpeg-parsable format) (default: s16le)"
}

unset -v input
unset -v output
unset -v duration2

samplerate='44100'
channels='2'
bitdepth='16'
format='s16le'
duration1='0'

optstring=":i:o:s:e:r:c:d:f:"

while getopts ${optstring} arg; do
  case ${arg} in
    i)
      input=$OPTARG
      ;;
    o)
      output=$OPTARG
      ;;
    s)
      duration1=$OPTARG
      ;;
    e)
      duration2=$OPTARG
      ;;
    r)
      samplerate=$OPTARG
      ;;
    c)
      channels=$OPTARG
      ;;
    d)
      bitdepth=$OPTARG
      ;;
    f)
      format=$OPTARG
      ;;
    :)
      echo "$0: Must supply an argument to -$OPTARG." >&2
      exit 1
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 2
      ;;
  esac
done

if [ -z "$input" ] || [ -z "$output" ]; then
        echo 'Missing -i or -o.' >&2
        usage
        exit 1
fi

#Calculate the byte offsets of the split points. I don't know of a better way to do floating point math, so I'm piping the equation into python and having it spit out an answer.
roughbytes1=$(echo 'print(round('$duration1'*'$samplerate'*'$channels'*'$bitdepth'/8))' | python)
#Round to the nearest splittable point
bytes1=$(( $roughbytes1 - ($roughbytes1 % ($bitdepth * $channels / 8) ) ))

if [ -z "$duration2" ]; then
	ffmpeg -v quiet -i "$input" -f $format - | tail -c +$(( $bytes1 + 1 )) | ffmpeg -v quiet -f $format -ac $channels -ar $samplerate -i - "$output"
	exit 0
else
	roughbytes2=$(echo 'print(round('$duration2'*'$samplerate'*'$channels'*'$bitdepth'/8))' | python)
	bytes2=$(( $roughbytes2 - ($roughbytes2 % ($bitdepth * $channels / 8) ) ))

	offset=$(( $bytes2 - $bytes1 ))

	#Do the splitting and conversions
	ffmpeg -v quiet -i "$input" -f $format - | tail -c +$(( $bytes1 + 1 )) | head -c $offset | ffmpeg -v quiet -f $format -ac $channels -ar $samplerate -i - "$output"
	exit 0
fi
