# unite_trial.praat
# This is meant to operate on files with the following name structure
# [subjectname(opt.)]_[trial]_[order]_[wordID]_[modificationID].[extension]
#
# For example, the following file name:
# list1subj1_1065_97_4_5.wav
#
# would be parsed from the right edge into:

# list1subj1_1065	_	97	_	4	_	5		.wav
# [subjectname]		_	[trial]	_	[order]	_	[wordID]	.[extension]

# Notice that the parsing happens right to left, and uses period "." and underscore "_" to parse


# BEGIN extracting trial information from filename of WAV file #

Create Strings as file list... list *.wav
Sort
numberOfFiles = Get number of strings
prevTrial = 0
withinTrialCount = 0
# soa --> Stimulus Onset Asynchrony
soa = 1
createDirectory ("combined")

for i from 1 to numberOfFiles
	withinTrialCount = withinTrialCount + 1
	select Strings list
	file$ = Get string... i
	call getTrialInfo 'file$'
	order$ [withinTrialCount] = getTrialInfo.order$
	word$ [withinTrialCount] = getTrialInfo.word$
	
	if prevTrial = 'getTrialInfo.trial$'
		Read from file... 'file$'
		soundName$ = selected$ ("Sound")
		call addComplementSilence 'soundName$' "trial'prevTrial'-'withinTrialCount'" 'soa'
		select Sound trial'prevTrial'
		plus Sound trial'prevTrial'-'withinTrialCount'
		Concatenate

		# remove objects
		select Sound trial'prevTrial'
		plus Sound trial'prevTrial'-'withinTrialCount'
		plus Sound 'soundName$'
		Remove

		select Sound chain
		Rename... trial'prevTrial'
	else
		# Moving on to new trial, so write previous combined trial to WAV file
		if prevTrial > 0
		   select Sound trial'prevTrial'
		   Save as WAV file... combined/trial'prevTrial'.wav
		   Remove
		endif

		prevTrial = 'getTrialInfo.trial$'
		withinTrialCount = 1
		Read from file... 'file$'
		soundName$ = selected$ ("Sound")
		call addComplementSilence 'soundName$' "trial'prevTrial'" 'soa'

		select Sound 'soundName$'
		Remove
	endif

endfor

# Write last combined trial to WAV file
select Sound trial'prevTrial'
Save as WAV file... combined/trial'prevTrial'.wav
Remove

# Remove object(s)
select Strings list
Remove


# END extracting trial information from filename of WAV file #

##############################
# PROCEDURES:

procedure getTrialInfo .fileName$
	.leadExtension = rindex_regex (.fileName$,"\..+$")
#	.leadModID = rindex_regex (.fileName$,"_.+$")
	.leadWord = rindex_regex (.fileName$,"_.+$")
	.leadOrder = rindex_regex (.fileName$,"_.+_.+$")
	.leadTrial = rindex_regex (.fileName$,"_.+_.+_.+$")

	.trial$ = mid$ (.fileName$,.leadTrial+1,.leadOrder-1-.leadTrial)
	.order$ = mid$ (.fileName$,.leadOrder+1,.leadWord-1-.leadOrder)
	.word$ = mid$ (.fileName$,.leadWord+1,.leadExtension-1-.leadWord)
endproc

#	#	#	#	#	#

procedure addComplementSilence .inSound$ .outSound$ .stimOnsetAsynchrony
  # Takes input sound and adds enough silence to make total duration equal specified Stimulus Onset Asynchrony
  
  select Sound '.inSound$'
  .soundDur = Get total duration

  # End execution with error if .stimOnsetAsynchrony is less than .soundDur
  if .stimOnsetAsynchrony < .soundDur
    exit Error with procedure addComplementSilence'newline$'The duration of Sound '.inSound$' ('.soundDur') is greater than the Stimulus Onset Asynchrony ('.stimOnsetAsynchrony')
  endif

  # Complement duration to the input's duration
  .soundDurCompl = .stimOnsetAsynchrony - .soundDur

  # args of Create Sound from formula...:
  #    1: soundname, 2: nChannels, 3: startTime, 4: endTime, 5: SampFreq, 6: formula
  Create Sound from formula... silence 1 0 '.soundDurCompl' 44100 0
  
  # Concatenate the input sound with silence of complementary duration
  plus Sound '.inSound$'
  Concatenate
  select Sound chain
  Rename... '.outSound$'
  select Sound silence
  Remove
endproc