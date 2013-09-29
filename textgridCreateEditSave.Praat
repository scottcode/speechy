## Adapted by Scott Hajek 
## from script written by Katherine Crosswhite (crosswhi@ling.rochester.edu)

##               Description of Script
##  This script opens all the files in some directory that start with a given string.
##  It makes a TextGrid for each of the sound files, then throws the sound file and the
##  TextGrid into the editor so you can make marks.

##  You will have to run this script once for every word in your data set.
##  It is set up this way so that all tokens of a given word are marked in succession,
##  increasing uniformity across tokens.  To specify the word you will work on, just run
##  the script.  A form will pop up allowing you to specify your directory and the word to work on.
##  If you don't want to do it this way, just make sure to leave the "Word" field COMPLETELY BLANK
##  when you run the script -- delete any default value displayed there.  Then you will go through
##  all of the files.
##                End of Description

# The following four lines are a form, asking for the directory location you want to use.
# Note that this form specifies two variables, "Directory" and "Word."  Later in the script,
# these variables can be referred to as "directory$" and "word$", since they are both string variables.
# These lines also specify the default values for each of these variables -- "C:\My Data\" and "cat".  Edit
# these lines if you want to change the defaults, but be sure not to forget the trailing backslash at
# the end of the directory name.

form Enter directory and search string. If directory="." (period), current script directory
	sentence directory .
	sentence word
	sentence initials
endform

if directory$ = "."
	directory$ = defaultDirectory$ + "/"
elsif right$ (directory$,1) <> "/"
	exit Directory must end in slash ("/")
endif


# First we will make a list of all the sound files in your directory that begin with
# the word you specified in the form.  Note:  The next line is where you would change
# sound file extensions, such as replacing ".wav" with ".aiff".

Create Strings as file list... file-list 'directory$''word$'*.wav

# Now we will set up a "for" loop -- the loop will iterate once for every file in the list we just made.
# First we will query our list to see how many filenames are in it, and store that number using the
# variable "number_of_files".  That variable will then be used in setting up the for loop.

number_of_files = Get number of strings
for x from 1 to number_of_files

#    Now we will set up a string variable called "current_file$" and use it to store the first
#    filename from the list.  

     select Strings file-list
     current_file$ = Get string... x

#    Now that we have the filename, we read in that file:

     Read from file... 'directory$''current_file$'

#    Now I am setting up a variable called "object_name$" that will have the name of the
#    sound object.  This is basically equivalent to subtracting the ".wav" or ".aiff" from
#    the filename.  This will be useful if I want to refer to the sound object later in the script.

     object_name$ = selected$ ("Sound")

#    Now I make a text grid for the current sound file.
#    Note that I am making only one tier on which labels can occur, and it will be named
#    "vowels".  You can have multiple tiers, each with its own name.  For example, I 
#    could've made three tiers by saying  To TextGrid... "utterances words segments"

fileToCheck$ = "'directory$''object_name$'.'initials$'.TextGrid"

if fileReadable (fileToCheck$)

	Read from file... 'fileToCheck$'

else

     To TextGrid... "Response Exclusions Notes"

endif

#    Since we have just created a TextGrid, it is automatically selected (i.e., active).  We need
#    both the textgrid and the sound object to be selected together, so I am going to add the
#    sound object to the selection.  This is where removing the ".wav" extension comes in handy:

     plus Sound 'object_name$'

#    Now we want to throw those two objects -- the Sound object and the Textgrid object -- into the editor:

     Edit

#    Now, we will tell the script to pause.  This will allow the user to step in and enter the appropriate
#    marks using the mouse and keyboard.  Note that the user does not need to save the textgrid -- this is
#    built into the script later.  Just click on "continue" when you have made the marks that you want.

     pause  Mark your segments! 

#    Now we will save the TextGrid object, so that the user doesn't have to do it for each file.
#    The first step is to de-select the sound object, leaving us with only the TextGrid selected:
 
     minus Sound 'object_name$'

#    Now we save the textgrid.  Note that the textgrid will have the same filename as the
#    sound file that it goes with, except that it will have the extension ".TextGrid" -- this is another
#    instance where removing the ".wav" comes in handy:

     Write to text file... 'directory$''object_name$'.'initials$'.TextGrid

#    We are now ready to end the for loop, and go on to the next file.  However, to conserve
#    memory, we will first remove the objects that we are through with.  I like to do this by
#    selecting all the objects in the list, then de-selecting any we will still be using, such as 
#    our list of filenames.

     select all
     minus Strings file-list
     Remove

# This specifies the end of the loop:

endfor


# The next three lines just do some clean up, and display a message in the Info window
# letting you know when you've reached the end of the list.

select Strings file-list
Remove
print All files processed -- that was fun!

