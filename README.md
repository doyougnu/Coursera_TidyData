### Introduction

Included in this repo should be an R script calles "run_analysis.R" which should perfom all the data wrangling steps outlined in Coursera's Getting and Cleaning Data class Course Project outline. You will also find this README and a Codebook describing each variable.

### Pre-requisites to running the script 

The "run_analysis.R" script makes several assumptions about your workspace:

1. That you have dplyr installed and/or loaded
2. That the data is in the working directory such that the "test" and "train" folders are on the same level as the .Rproj Rstudio creates.

After those two requirements you should be good to go. I have not included any quality measures in this script so if you do not have dplyr installed for instance it will fail, and will not try to install the package for you or give you a helpful hint.

### What the script does 

The script, if run successfully, will perform the following steps outlined in the course project:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

For 1. I define two functions "addColNames" and "addForeignVar", then performing 3. and 4. is a matter of calling these function, then i merge test and train by calling rbind. addColNames is a function that takes a dataframe loaded into the workspace and a string that represents a text file of column names, then sets the dataframes column names to the second column in the column names dataset. Using the second column is particular to this analysis. addForeignVar takes a dataframe that is defined in the workspace, a string representing the name of a yet non-loaded dataframe but of a file in the workspace,a column index, and a string representing the new column name. addForeignVar reads in the second file as a dataframe, then merges the column from the second dataframe to the first dataframe and renames it to the string that was passed. While trivial I thought creating helper functions like this would make the script cleaner.

for 2. I create a string with words i want to match in the colnames, then i call grep to generate a list of matched columns, if you debug the script and inspect the "matchedCols" variable you will see a list of unique column names that matched, not indices. After creating the matched list i merely filter the dataframe. For some reason there is a bug with this method where the string "mean()" will match to "meanFreq()". So the line:

<!-- -->
 df.complete <- df.complete[, -grep("Freq", colnames(df.complete))]

removes the meanFreq() matches.

For 5 I give in and call dplyr. After that it is trivial to get the data into long tidy format with the mean of every combination of Activity, Subject, for each sensor type as the mean_value column.
