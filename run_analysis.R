x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

## Step 1
obs_table <- rbind(x_test, x_train) #Merges test and train data sets together in long form.
label_table <- rbind(y_test, y_train) #Merges test and train activity label set stogether ".
subject_table <- rbind(subject_test, subject_train) # Mergest test and train subject label sets together ".

##Step2

logical_activity <- grepl("std\\(\\)|mean\\(\\)", features$V2) #Logical Vector giving me column indeces of variables that measure means and std's
raw_table <- obs_table[logical_activity]

##Step 3

colnames(label_table) <- c("Activity") ## I do this to avoid confusion later on, as I have not named variable columns yet.
activity_numbered_table <- cbind(label_table, raw_table) 
#Now we replace activity numbers with activity names

for (i in 1:10299){
  if (activity_numbered_table$Activity[i] == 1){
      activity_numbered_table$Activity[i] <- "WALKING"
  }
  if (activity_numbered_table$Activity[i] == 2){
  activity_numbered_table$Activity[i] <- "WALKING_UPSTAIRS"
  }
  if (activity_numbered_table$Activity[i] == 3){
  activity_numbered_table$Activity[i] <- "WALKING_DOWNSTAIRS"
  }
  if (activity_numbered_table$Activity[i] == 4){
  activity_numbered_table$Activity[i] <- "SITTING"
  }
  if (activity_numbered_table$Activity[i] == 5){
  activity_numbered_table$Activity[i] <- "STANDING"
  }
  if (activity_numbered_table$Activity[i] == 6){
  activity_numbered_table$Activity[i] <- "LAYING"
  }
}
#Step 4, naming variables
#I'm-a go ahead and just cbind the subject_table data frame onto my existing table in order to have a comprehensive Big Table
big_table <- cbind(subject_table, activity_numbered_table)
#I will use the descriptive variable names already avaliable to me from the features.txt file
variable_list <- features[logical_activity, 2]
new_variable_list <- as.matrix(variable_list)
vector_variable_list <- as.vector(new_variable_list)
final_variable_list <- c("Subject", "Activity", vector_variable_list)

#I will use the colnames() function in order to change the column names of big_table.
colnames(big_table) <- final_variable_list

##Step 5.
final_list <- data.frame()
for (i in 1:30){
  drops <- c("Subject", "Activity")
  i_table <- big_table[big_table$Subject == i,]
  walking_table <- i_table[i_table$Activity == "WALKING",]
  dropped_walking_table <- walking_table[, !(names(walking_table) %in% drops)]
  walking <- colMeans(dropped_walking_table)
  
  walking_upstairs_table <- i_table[i_table$Activity == "WALKING_UPSTAIRS",]
  dropped_walking_upstairs_table <- walking_upstairs_table[, !(names(walking_upstairs_table) %in% drops)]
  walking_upstairs <- colMeans(dropped_walking_upstairs_table)
  
  walking_downstairs_table <- i_table[i_table$Activity == "WALKING_DOWNSTAIRS",]
  dropped_walking_downstairs_table <- walking_downstairs_table[, !(names(walking_downstairs_table) %in% drops)]
  walking_downstairs <- colMeans(dropped_walking_downstairs_table)
  
  sitting_table <- i_table[i_table$Activity == "SITTING",]
  dropped_sitting_table <- sitting_table[, !(names(sitting_table) %in% drops)]
  sitting <- colMeans(dropped_sitting_table)
  
  standing_table <- i_table[i_table$Activity == "STANDING",]
  dropped_standing_table <- standing_table[, !(names(standing_table) %in% drops)]
  standing <- colMeans(dropped_standing_table)
  
  laying_table <- i_table[i_table$Activity == "LAYING",]
  dropped_laying_table <- laying_table[, !(names(laying_table) %in% drops)]
  laying <- colMeans(dropped_laying_table)
  
  bound <- rbind(walking, walking_upstairs, walking_downstairs, sitting, standing, laying)
  sub <- data.frame(Subject = c(i, i, i, i, i, i))
  act <- data.frame(Activity = c("Walking", "Walking_Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))
  entry <- cbind(sub, act, bound)
  final_list <- rbind(final_list, entry)
}
rownames(final_list) <- NULL #The above for-loop code will also mess with the rownames of the final data frame. Here I just clean it up.
write.table(final_list, file = "tidy_data_set.txt", row.names = FALSE)
print(final_list)