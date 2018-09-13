#downloading and unzipping 
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="Dataset.zip")
unzip(zipfile="Dataset.zip")
path_rf <- file.path("UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)

#reading data from the files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)


#binding by rows from the data table
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#setting names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#merging tables to get dataframe for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)


#subseting name of features by measurements on the mean and standard deviation and 
# subsetting the data frame by selecte name feature
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#reading descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

#labelling name of features using descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# crating final tidy data set with the average of each variable for each activity and each subject
library(plyr)
Data2<-aggregate(. ~subject + activity, Data, mean)
Data_final<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data_final, file = "tidydata.txt",row.name=FALSE)

