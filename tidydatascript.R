library(data.table)
library(dplyr)
library(plyr)

#imports the training and testing data sets
x_train <- read.table("C:/Users/Kyle/Downloads/hospitaldata/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/X_train.txt")
y_train <- read.table("C:/Users/Kyle/Downloads/hospitaldata/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/Y_train.txt")
subtrain <- read.table("C:/Users/Kyle/Downloads/hospitaldata/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/subject_train.txt")
features <- read.table("C:/Users/Kyle/Downloads/hospitaldata/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/features.txt")
colnames(x_train) <- features[, 2]

View(x_train)
ncol(x_train)
ncol(subtrain)

mergeTrain <- cbind(subtrain[, 1],y_train[,1],x_train[,1:561])
rm(x_train,y_train,subtrain)

x_test <- read.table("C:/Users/Kyle/Downloads/hospitaldata/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/X_test.txt")
y_test <- read.table("C:/Users/Kyle/Downloads/hospitaldata/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/Y_test.txt")
subtest <- read.table("C:/Users/Kyle/Downloads/hospitaldata/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/subject_test.txt")
colnames(x_test) <- features[,2]

mergetest <- cbind(subtest[,1],y_test[,1],x_test[,1:561])
rm(x_test,y_test,subtest)

colnames(mergeTrain)[1:2] <- c("person.id", "activity_label")
colnames(mergetest)[1:2] <- c("person.id", "activity_label")


mergetrain <- as.data.table(mergeTrain)
mergetest <- as.data.table(mergetest)

mergetrain <- cbind("train", mergetrain)
mergetest <- cbind("test", mergetest)
colnames(mergetrain)[1] <- "Data_Set"
colnames(mergetest)[1] <- "Data_Set"

#creates the final data set and saves it
findata <- rbind(mergetrain, mergetest)
findata <- as.data.table(findata)
save(findata, file="master_data.RData")

#This will load the final data set if I decide to exit and come back later
load("master_data.RData")

#the next two lines of code change the data in activity_labels into factors
#and inputs the physical activity with the corresponding number
findata$activity_label <- factor(findata$activity_label, levels=c('1','2','3','4','5','6'), 
labels=c('Walking', 'Walking Upstairs', 'Walking Downstairs', 'Sitting', 'Standing', 'Laying'))


#extract the columns that have the mean for each row
#then find the mean for the subset of columns
meancol <- subset(findata, select=findata[,grepl("mean", names(findata))])
meancol <- sapply(meancol, mean)
meancol

#extract the columns that have the standard deviation for each row
#then find the standard deviation of the subset of columns
stdevcol <- subset(findata, select=findata[,grepl("std", names(findata))])
stdevcol <- sapply(stdevcol, sd)
stdevcol

#This makes some of the column headers easier to understand
names(findata) <- gsub("Acc", "Accelerator", names(findata))
names(findata) <- gsub("Mag", "Magnitude", names(findata))
names(findata) <- gsub("Gyro", "Gyroscope", names(findata))
names(findata) <- gsub("^t", "time", names(findata))
names(findata) <- gsub("^f", "frequency", names(findata))


#Step 5 make a tidy data set
findata <- ddply(findata, .(person.id,activity_label), numcolwise(mean))
write.table(findata, file="tidydata.csv",row.names=TRUE)
View(findata)











