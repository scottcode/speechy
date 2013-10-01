speechy
=======

Python and Praat scripts for annotating speech and processing and analyzing speech annotation data

## Descriptions

### parseTextGrid.py

* **Purpose:** to read in TextGrid files (which are created with Praat for annotation of sound files)
* **Output:** object which is a dictionary of dictionaries (Python object type). See comments in script for more information.

### invertF0_v1-0.praat

* **Purpose:** Praat script to invert the fundamental frequency contour of a sound file
* **Output:** WAV files

### proc_addComplementSilence.praat

* **Purpose:** Praat script to paste sound clips together, adding in silence to ensure that the onset of each clip starts at even inter-stimulus intervals.
* **Output:** WAV files
