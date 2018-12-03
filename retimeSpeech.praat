form Specify file
    text name
    text newName
endform

wd$ = "./"
inPath$ = wd$ + "audio/" + name$ + ".wav"
outPath$ = wd$ + "outputs/" + name$ + "_" + newName$ + ".wav"
inGrid$ = wd$ + "newGrids/" + name$ + ".TextGrid"

sound = Read from file: inPath$
textGrid = Read from file: inGrid$

select sound
manipulation = To Manipulation... 0.01 75 600
durationTier = Extract duration tier

select textGrid
nIntervals = Get number of intervals... 1

for iInterval to nIntervals
   select textGrid
   startOld = Get start point... 1 iInterval
   endOld = Get end point... 1 iInterval
   startNew = Get start point... 2 iInterval
   endNew = Get end point... 2 iInterval
   durationOld = endOld-startOld
   durationNew = endNew-startNew
   factor = durationNew/durationOld
   select durationTier
   Add point... startOld+0.01 factor
   Add point... endOld-0.01 factor
endfor
  
select manipulation
plus durationTier
Replace duration tier

select manipulation
outSound = Get resynthesis (overlap-add)

select outSound
Save as WAV file: outPath$