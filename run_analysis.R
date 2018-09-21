# Gettting and cleaning data course project
# Author: Amber Z.

## Requirements

#1. Merges the training and the test sets to create one data set. 
#2. Extracts only the measurements on the mean and the standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set. 
#4. Appropriately labels the data set with descriptive variable names.
#5. From the data set in step 4, creates a second, independent tidy data set with the average 
#   of each variables for each activity and each subject.

## Steps 

# Download data and read it into R
if(!file.exists("./courseproject")) {dir.create("./courseproject")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./courseproject/dataFiles.zip")
unzip(zipfile = "./courseproject/dataFiles.zip")

# Load activity labels and features
library(data.table)
activityLabels <- fread("./courseproject/UCI HAR Dataset/activity_labels.txt",
                        col.names = c("classLables", "activityName"))
features <- fread("./courseproject/UCI HAR Dataset/features.txt",
                  col.names = c("index", "featureNames"))
featuresIndex <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresIndex, featureNames]
measurements <- gsub("[()]", " ", measurements)

# Load train datasets
train <- fread("./courseproject/UCI HAR Dataset/train/X_train.txt")[, featuresIndex, 
                                                                    with = FALSE]
setnames(train, colnames(train), measurements)
trainActivities <- fread("./courseproject/UCI HAR Dataset/train/y_train.txt",
                         col.names = "Activity")
trainSubjects <- fread("./courseproject/UCI HAR Dataset/train/subject_train.txt",
                       col.names = "subjectNum")
train <- cbind(trainSubjects, trainActivities, train)

# Load test datasets
test <- fread("./courseproject/UCI HAR Dataset/test/X_test.txt")[,featuresIndex,
                                                                 with = FALSE]
setnames(test, colnames(test), measurements)
testActivities <- fread("./courseproject/UCI HAR Dataset/test/y_test.txt" ,
                        col.names = "Activity")
testSubjects <- fread("./courseproject/UCI HAR Dataset/test/subject_test.txt",
                      col.names = "subjectNum")
test <- cbind(testSubjects, testActivities, test)

# Merge datasets
combined <- rbind(train, test)

# Convert class labels to activityNames
combined$Activity <- factor(combined[,Activity],
                            levels = activityLabels$classLables,
                            labels = activityLabels$activityName
                            )
combined$subjectNum <- as.factor(combined[, subjectNum])
library(reshape2)
combined <- melt(combined, id = c("subjectNum", "Activity"))
combined <- dcast(combined, subjectNum + Activity ~ variable, fun.aggregate = mean)
fwrite(combined, file = "./courseproject/cleandata.csv", quote = FALSE)







