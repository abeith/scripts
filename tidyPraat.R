# Wrapper for Praat function
reTime <- function(name, newName= "retimed", script = "scripts/retimeSpeech.praat", praatPath = "/Applications/Praat.app/Contents/MacOS/Praat", args = "--run"){
  system(paste(praatPath, args, script, name, newName))
}

# Extract peak density value for a duration vector
findPeak <- function(x){
  durDensity <- density(x)
  peakDensity <- durDensity$x[which.max(durDensity$y)]
  peakDensity
}

# Extract TextGrid as list of tibbles
loadGrid <- function(file, drop = NULL){
  require(rPraat)
  require(purrr)
  # Load existing text grid
  oldGrid <- tg.read(file)

  # Transform TextGrid into list of tibbles
  dat <- oldGrid %>%
    map(as_tibble) %>%
    map(select, -name, -type) 
  
  if(!is.null(drop)){dat <- discard(dat, names(dat) %in% drop)}
  
  return(dat)
}

# Extract Text Grid as one tibble
loadGridLong <- function(file, drop = NULL, intGrp = TRUE){
  require(dplyr)
  require(purrr)
  
  # Load grid list
  grid <- loadGrid(file, drop)
  
  # Get breaks for intonational phrase grouping
  if(intGrp){
    #Get intonational group onsets
    intCuts <- grid$Intonation %>%
      gather(label, times, t1:t2) %>%
      distinct(times) %>%
      pull(times)
  }
  
  # Rename labels, calculate duration, tidy
  dat <- grid %>%
    map2(.x = ., .y = names(.), function(x, y){rename(x, !!y := label)}) %>%
    map(~mutate(., duration = t2 - t1)) %>%
    reduce(full_join, by = c("t1", "t2", "duration")) %>%
    select(t1:t2, duration, everything()) %>%
    gather(level, label, -t1, -t2, -duration) %>%
    drop_na(label)
  
  if(intGrp){dat <- mutate(dat, intGrp = cut(t1, intCuts, right = FALSE))}
  
  return(dat)
}
