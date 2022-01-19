rm(list = ls())

data <- read.csv("/Users/jinghuang/Desktop/Northeastern University Aly 6000/marketing_campaign.csv")
data$Education = as.factor(data$Education)
attach(data)

summary(data)
# step 1: clean the data
# number of record reduce from 2240 to 2216
data <- na.omit(data) 
describe(data)

# want to find out is meat or fish more popular ?  so we only keep this two columns
#new_data <- data.frame(ID, Education , MntMeatProducts, MntFishProducts)
# since I have cleaned the data, there will be no valid percentage
library(janitor)
t <- tabyl(data$Education, sort = TRUE) 
t
# pie chart count
library(plotrix)

# pie chart of count
slices <- t[,2]
lbls <- t[,1]
pie3D(slices,labels=lbls,explode=0.1, main="Pie Chart of Education Level")

education_level <- t[,1]
df <- split(data, education_level)

newd1 <- df$`2n Cycle`
newd2 <- df$Basic
newd3 <- df$Graduation
newd4 <- df$Master
newd5 <- df$PhD

spent_meat <- c(sum(newd1$MntMeatProducts), sum(newd2$MntMeatProducts),
                sum(newd3$MntMeatProducts), sum(newd4$MntMeatProducts), 
                sum(newd5$MntMeatProducts))

spent_fish <- c(sum(newd1$MntFishProducts), sum(newd2$MntFishProducts),
                sum(newd3$MntFishProducts), sum(newd4$MntFishProducts),
                sum(newd5$MntFishProducts))

df <- data.frame(spent_meat , spent_fish)
df

barplot(height = as.matrix(df), main="Barplot of money spent on meat vs fish", ylab="money$", beside=TRUE, col=rainbow(5))

boxplot(data$MntMeatProducts, data$MntFishProducts,names=c("MntMeatProducts", "MntFinshProducts"))

out <- boxplot.stats(data$MntMeatProducts)$out
min(out)
data <- subset(data, MntMeatProducts<min(out))
boxplot(data$MntMeatProducts, data$MntFishProducts,names=c("MntMeatProducts", "MntFinshProducts"))


df <- split(data, education_level)

newd1 <- df$`2n Cycle`
newd2 <- df$Basic
newd3 <- df$Graduation
newd4 <- df$Master
newd5 <- df$PhD

spent_meat <- c(sum(newd1$MntMeatProducts), sum(newd2$MntMeatProducts),
                sum(newd3$MntMeatProducts), sum(newd4$MntMeatProducts), 
                sum(newd5$MntMeatProducts))

spent_fish <- c(sum(newd1$MntFishProducts), sum(newd2$MntFishProducts),
                sum(newd3$MntFishProducts), sum(newd4$MntFishProducts),
                sum(newd5$MntFishProducts))

df <- data.frame(spent_meat , spent_fish)
df

barplot(height = as.matrix(df), main="Barplot of money spent on meat vs fish without outlier", ylab="money$", beside=TRUE, col=rainbow(5))

boxplot(data$MntMeatProducts, data$MntFishProducts,names=c("MntMeatProducts", "MntFinshProducts"))
#out <- boxplot.stats(data$MntFishProducts)$out
#min(out)
#data <- subset(data, MntFishProducts<min(out))
#boxplot(data$MntMeatProducts, data$MntFishProducts,names=c("MntMeatProducts", "MntFinshProducts"))


# difference
data$diff_meatvsfish <- data$MntMeatProducts - data$MntFishProducts
summary(data$diff_meatvsfish)
barplot(data$diff_meatvsfish)
