# Wrapper for Praat function
reTime <- function(name, newName= "retimed", script = "/retimeSpeech.praat", praatPath = "C:\\Program Files\\praat6043_win64\\Praat.exe", args = "--run"){
  # Quote path if using Windows
  if(.Platform$OS.type == "windows"){
    praatPath <- paste0("\"", praatPath, "\"")}
  
  # No need in Unix based system
  if(.Platform$OS.type == "unix"){
    praatPath <- "praat"
  }
  
  scriptPath <- paste0("\"", getwd(), script, "\"")
  
  system(paste(praatPath, args, scriptPath, name, newName))
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
  require(dplyr)
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
loadGridLong <- function(file, drop = NULL, group = NULL){
  require(dplyr)
  require(tidyr)
  require(purrr)
  
  # Load grid list
  grid <- loadGrid(file, drop)
  
  # Get breaks for intonational phrase grouping
  if(!is.null(group)){
    #Get intonational group onsets
    cuts <- grid %>%
      pluck(group) %>%
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
  
  if(!is.null(group)){dat <- mutate(dat, group = cut(t1, cuts, right = FALSE))}
  
  return(dat)
}
