run_analysis <- function() {
  
  addColNames <- function(dataframe, dataset_column_names) {
    #takes loaded dataframe, string of text file, than replaces column names in loaded dataframe
    #with column in text file. Hardcoded particular to this assignment for time
    dfColNames <- read.table(dataset_column_names, header=F)
    colnames(dataframe) <- dfColNames[,2]
    dataframe
  }
  
  addForeignVar <- function(dataframe, foreign_dataset, column_index, colname) {
    #takes two datasets, a column index as int, and a string for column name then grabs the column
    #at column_index from foreign_dataset and adds it to dataframe as colname
    df_foreign <- read.table(foreign_dataset, header=F)
    dataframe[, colname] <- df_foreign[, column_index]
    dataframe
  }
  
  #load train/test data frames
  df.X_test <- read.table("test/X_test.txt", header=F)
  df.X_train <- read.table("train/X_train.txt", header=F)
  
  #create column names, then add the Y's, this could probably be cleaned up with an lapply
  #like step that would process a list of functions on each dataset
  df.X_test <- addColNames(df.X_test, "features.txt")
  df.X_train <- addColNames(df.X_train, "features.txt")
  
  df.X_test <- addForeignVar(df.X_test, "test/y_test.txt", 1, "Activity")
  df.X_train <- addForeignVar(df.X_train, "train/y_train.txt", 1, "Activity")
  
  df.X_test <- addForeignVar(df.X_test, "test/subject_test.txt", 1, "Subject")
  df.X_train <- addForeignVar(df.X_train, "train/subject_train.txt", 1, "Subject")
  
  df.complete <- rbind(df.X_train, df.X_test)
  
  #select mean and sd only columns, I use grep to return pattern matched colnames, doing so also
  #returns meanFreq() colnames for some reason, hence the -grep to remove them, this could be
  #done much better with the right regex, but for now its functional
  toMatch <- c("mean()", "std()", "Subject", "Activity")
  matchedCols <- unique(grep(paste(toMatch, collapse="|"), colnames(df.complete), value=T))
  df.complete <- df.complete[, matchedCols]
  df.complete <- df.complete[, -grep("Freq", colnames(df.complete))]
  
  #Do an inside merge of Activity numbers to Activity Labels
  activity_table <- read.table("activity_labels.txt", header=F)
  df.complete <- merge(df.complete, activity_table, by.x = "Activity", by.y = "V1")
  names(df.complete)[names(df.complete) == "V2"] <- "Activity_Label"
  df.complete <- subset(df.complete, select=- c(Activity))
  
  #create tidy dataset with mean of every var for each combination of Activity and Subject
  #tried to only use base but dplyr comes to the rescue i suppose
  library(dplyr) #assume dplyr installed, should wrap lib call with try/catch later
  df.complete %>%
    gather(sensor, value, -Activity_Label, -Subject) %>%
    group_by(Activity_Label, Subject, sensor) %>%
    mutate(sensor_mean = mean(value)) %>%
    select(-value) %>%
    unique() %>%
    arrange(Subject, Activity_Label)   
}