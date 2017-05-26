rm(list=ls())
library(reshape2)

# Load labels and column names
labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract mean and standard deviation for each measurement
meanstd <- grepl("mean|std", features)

# Load data
Xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
Xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(Xtest) = features
names(Xtrain) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
Xtest = Xtest[,meanstd]
Xtrain = Xtrain[,features]

# Load activity labels
ytest[,2] = labels[ytest[,1]]
names(ytest) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

ytrain[,2] = labels[ytrain[,1]]
names(ytrain) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind test and train data
testdata <- cbind(as.data.table(subject_test), ytest, Xtest)
traindata <- cbind(as.data.table(subject_train), ytrain, Xtrain)

# Merge test and train data
data = rbind(testdata, traindata,fill=TRUE)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy, file = "./tidy_data.txt")
