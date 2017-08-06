#Download Data 

URL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL,destfile = "./data/dataset.zip",method = "curl")

#Unzip Data 
library(utils)
unzip("./data/dataset.zip")

#Reading Train Table
x_train<-read.table("./UCI HAR Dataset/train/x_train.txt")
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")

#Reading Test Table
x_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")

#Reading Features
features<-read.table("./UCI HAR Dataset/features.txt")

#Reading activity labels

activityLabels = read.table("./UCI HAR Dataset/activity_labels.txt")



#After finalizing data import process now we will assign coloumn names to our data. 

colnames(x_train) <- features[,2] 
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

colnames(activityLabels) <- c('activityId','activityType')


#Now we will merge all test and train data into one table

train<-cbind(x_train,y_train,subject_train) #merges data coloumn by coloumn, coloumn order should be same for both tables
test<-cbind(x_test,y_test,subject_test)


append_all<-rbind(test,train) #now we will merge two tables which are in indentical format 

#Extracting only Standart deviations and averages from the table

mean_or_std <- (grepl("activityId" , colnames(append_all)) | 
                         grepl("subjectId" , colnames(append_all)) | 
                         grepl("mean.." , colnames(append_all)) | 
                         grepl("std.." , colnames(append_all)) )
#Grepl will provide us logical vector indicating which of the coloumns complies with our "keywords"

#now we are able to subset our data

selected<-append_all[ , mean_or_std==TRUE]

#Now we will change activityIDs with activity names. To do this we will left join our labels with activity IDs 

selected_labeled<-merge(selected,activityLabels,by="activityId",all.x=TRUE)

#Creating the tidy data with averages with Acitivity Ids and sujectIds

tidy_data<-aggregate(. ~subjectId  + activityType, data= selected_labeled, mean)
write.table(tidy_data,"averages_data.txt",row.names=FALSE)
