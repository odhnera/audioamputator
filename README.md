# audioamputator
Bash wrapper for coreutils (head and tail commands), ffmpeg, and python. Cuts audio files at precise intervals (unlike ffmpeg alone, which is often off by a few milliseconds).

This project was inspired by an issue that I had with old Digital8 tapes. I initally digitized these tapes using dvgrab, and they played without issue. However, when re-encoded to a more modern format, the audio and video would drift out of sync. The original transfer did not suffer this problem because the audio and the video were stored interleaved, allowing the player to drop frames to keep the A/V sync. To work around this problem, I split the original DV stream into multiple short segments. I used ffprobe to determine the length of these segments, and attempted to use ffmpeg to extract the audio and pad the ends of each segment with just enough silence to render the audio and the video exactly the same length. This required millisecond-level accuracy, and ffmpeg's seeking just wasn't that accurate. After writing audioamputator, I was able to precisely trim the audio segments, which I then concatenated and muxed with the video track for a perfectly in-sync re-encoded DV transfer.

Usage:
-i --> input file (mandatory)
-o --> output file (mandatory)
-s --> start cut-point (in decimal seconds) (default: start of input)
-e --> end cut-point (in decimal seconds) (default: end of input)
-r --> sample rate (in Hz) (default: 44100)
-c --> number of channels (default: 2)
-d --> bit depth (default: 16)
-f --> format (in ffmpeg-parsable format) (default: s16le)
