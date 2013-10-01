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