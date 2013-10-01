# invertF0.praat
#	Version 1.0
#
# AUTHOR: J. Scott Hajek, University of Illinois at Urbana-Champaign
#	hajek3@illinois.edu
# DESCRIPTION: Make pitch tiers for WAV files 
#	and invert the F0 contour around the mean F0 of that individual sound file
# REQUIREMENTS:
#	* requires Praat version 5.1.30 or higher
# QUICK START: Put this script in a directory containing just the WAV files to be inverted,
#		open script in Praat, and run. *Note:* If copying and pasting just the
#		script text into an editor, specify the directory for inDir$ below
# FURTHER DEVELOPMENT:
# 	* add parameters for shifting mean F0 up or down
###########################################################

## BEGIN: Set Path Separator - determine operating system to set \ or / as file path separator
  if macintosh
     pathSeparator$ = "/"
  elsif windows
     pathSeparator$ = "\"
  elsif unix
     pathSeparator$ = "/"
  else
     exit ERROR: Praat could not detect the Operating System you are using, which is needed to determine whether file pathnames must be separated by forward slashes (/) or backslashes (\). 'newline$'You can edit the script to default to the one that works for your platform.
  endif
## END: Set Path Separator


# defaultDirectory$ is the directory path in which the script is opened
# To specify a different directory where all the WAV files reside, 
# delete 'defaultDirectory$' below and replace with new path (without backslash at end)

inDir$ = "'defaultDirectory$''pathSeparator$'"
invF0$ = "invF0'pathSeparator$'"
    # NOTE: invF0$ currently creates a subdirectory via RELATIVE PATH, ignoring custom settings bypassing defaultDirectory$. You can give a full path in invF0$, but make sure you have Praat version 5.1.30 or higher
createDirectory (invF0$)

Create Strings as file list... list 'inDir$'*.wav
Sort
numberOfFiles = Get number of strings

for ifile to numberOfFiles
   # Read in the next file from the directory
   select Strings list
   fileName$ = Get string... ifile
   Read from file... 'inDir$''fileName$'
   itemname$ = selected$ ("Sound")

   # Start processing the current file

   outName$ = "'itemname$'_invF0"
   ptExten$ = ".PitchTier"
   ptOutfile$ = "'invF0$''outName$''ptExten$'"
   filedelete 'ptOutfile$'
   fileappend "'ptOutfile$'" "ooTextFile"'newline$'"PitchTier"'newline$'

   select Sound 'itemname$'
   start = Get start time
   end = Get end time

   # NOTE: next line has a SPACE character at the end
   fileappend "'ptOutfile$'" 'start' 'end' 

   select Sound 'itemname$'
   # arguments of next line: [1] time step (sec), [2] min Hz, [3] max Hz
   To Manipulation... 0.01 90 300
   Extract pitch tier
   Write to PitchTier spreadsheet file... 'inDir$''itemname$'.PitchTier
   nPoints = Get number of points
   fileappend "'ptOutfile$'" 'nPoints''newline$'

   # convert PitchTier to Table
   Down to TableOfReal... Hertz
   f0mean = Get column mean (label)... F0

   for point to nPoints
      # args of Get value... [row#] [col#]
      # column #1 is Time, column #2 is F0
      time = Get value... 'point' 1
      f0 = Get value... 'point' 2
      f0inv = f0mean - (f0 - f0mean)
      fileappend "'ptOutfile$'" 'time''tab$''f0inv''newline$'
   endfor

   # CREATE RE-SYNTHESIZED WAV FILE by replacing pitchtier in Manipulation object with that of the inverted PitchTier

   Read from file... 'ptOutfile$'
   plus Manipulation 'itemname$'
   Replace pitch tier
   select Manipulation 'itemname$'
   Write to text file without Sound... 'invF0$''outName$'.Manipulation
   Get resynthesis (overlap-add)
   Write to WAV file... 'invF0$''outName$'.wav
   Remove

   # CLEAN UP OBJECTS in Praat before next iteration of for-loop (leaves Strings list)
   select Sound 'itemname$'
   plus Manipulation 'itemname$'
   plus PitchTier untitled
   plus TableOfReal untitled
   plus PitchTier 'outName$'
   Remove

endfor

select Strings list
Remove