# load libraries
library(dplyr)

# download data into data folder, check if data folder already exists first
# if data folder doesn't exist, create it

if (!file.exists("data")) {
  dir.create("data")
}

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./data/dataset.zip", method = "curl")

# unzip dataset (unless folder "UCI HAR Dataset" already exists)
if (!file.exists("UCI HAR Dataset")) {
  unzip("./data/dataset.zip")
}

# make dataframes of all necessary txt files and assign column names

measurements <- read.table("UCI HAR Dataset/features.txt", col.names = c("id", "measurement"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_number", "activity_label"))

# name the columns of the x_train dataframe with the values of the measurements dataframe 
train_values <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = measurements$measurement)
train_activities <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")

# we name the columns of the x_test dataframe with the values of the measurements dataframe 
test_values <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = measurements$measurement)
test_activities <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activity")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

# 1) MERGE THE TRAINING AND TEST SETS TO CREATE ONE DATA SET

# stack (row-bind) the train/test values, activities, and subjects, then column bind together
values_stacked <- rbind(train_values, test_values)
activities_stacked <- rbind(train_activities, test_activities)
subjects_stacked <- rbind(train_subjects, test_subjects)

merged_df <- cbind(subjects_stacked, activities_stacked, values_stacked)

# 2) EXTRACT ONLY THE MEASUREMENTS ON THE MEAN AND STANDARD DEVIATION
merged_df_filtered <- select(merged_df, subject, activity, matches("std|mean"))

# 3) USE DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITIES IN THE DATA SET
merged_df_filtered$activity <- activities[merged_df_filtered$activity, 2]

# use a different df for the final steps
tidy_df <- merged_df_filtered


# 4) APPROPRIATELY LABEL THE DATA SET WITH DESCRIPTIVE VARIABLE NAMES

names(tidy_df) <- gsub("Mag", "Magnitude", names(tidy_df))
names(tidy_df) <- gsub("BodyBody", "Body", names(tidy_df))
names(tidy_df) <- gsub("Acc", "Accelerometer", names(tidy_df))
names(tidy_df) <- gsub("Gyro", "Gyroscope", names(tidy_df))
names(tidy_df) <- gsub("gravity", "Gravity", names(tidy_df))
names(tidy_df) <- gsub("angle", "Angle", names(tidy_df))
names(tidy_df) <- gsub("^t", "Time", names(tidy_df))
names(tidy_df) <- gsub("^f", "Frequency", names(tidy_df))
names(tidy_df) <- gsub("\\.mean", "Mean", names(tidy_df))
names(tidy_df) <- gsub("\\.std", "STD", names(tidy_df))

# 5) CREATE A SECOND, INDEPENDENT TIDY DATASET WITH THE AVERAGE OF EACH VARIABLE FOR EACH ACTIVITY AND EACH SUBJECT

#turn subject and activity into factor levels
tidy_df$activity <- as.factor(tidy_df$activity)
tidy_df$subject <- as.factor(tidy_df$subject)

tidy_output <- aggregate(. ~subject + activity, tidy_df, mean)
tidy_output <- tidy_output[order(tidy_output$subject, tidy_output$activity), ]
write.table(tidy_output, file = "tidy_dataset.txt", row.names = FALSE)

