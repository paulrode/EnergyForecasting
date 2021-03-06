

###############################################################################
#                             Set up envirment                                #
###############################################################################


# Enviroment 
# Loading and preprocessing the data
#Set up enviroment for R scrip  
# Packages for tidyverse 
library("tidyverse")
library("gridExtra")
library("lubridate")
# Package for building tables in markdown and notebook 
library("knitr")
library("kableExtra") 
library("xtable")
# Packages for forecasting
library("fable")
library("tsibble")
library("feasts")
library("tsibbledata")
# Packages for reading excel and html files and XML
library("openxlsx")
library("XML")
# Parkage for using data tables for very large data operations
library("data.table")
library("tidyfast")
library("dtplyr")
#Package for reading fixed width tables
library("utils")
# Packages for reading data through API's 
library("httr")
library("jsonlite")
# Package for performing inquires with SQL databases 
library("sqldf")
#Package for reading and writing to jpeg files
library("jpeg")

# Set proper working Dir 
if (!getwd() == "C:/Users/paulr/Documents/R/EnergyForecasting") {setwd("C:/Users/paulr/Documents/R/EnergyForecasting")}

# Check for data directory and if one is not present then make it
if (!file.exists("data")) {
  dir.create("data")


###############################################################################
#                     Read data in and get date formats right                 #
###############################################################################


setAs("character","myDate", function(from) {mdy_hm(from)})

Electric_Data <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/MACH Energy - Data (4).csv", colClasses = c(Date = "myDate", Value = "integer", Unit = "character"), stringsAsFactors = TRUE)
Electric_Data[,Value := as.integer(Value)]

Steam_Data <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/MACH Energy - Data (3).csv", colClasses = c("myDate", "integer", "Character"), stringsAsFactors = TRUE)
Steam_Data[, Value := as.integer(Value)]
Steam_Data[, ymdDate := date(Date)]
Steam_Data[, .(Value = sum(Value)), by = ymdDate] -> SteamPerDay #Summarise kWh per day. 


##########   Bring in 2018, 2019, 2020 & 2021 Cooling and Heating Data  ##########

CoolingDD2018 <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/ClimateDivisions.Cooling2018.txt") 
CoolingDD2018[Region == 3004,] -> CoolingDD2018
CoolingDD2018[,!(1), with = FALSE] -> CoolingDD2018
names <- colnames(CoolingDD2018)
CoolingDD2018 <- melt(CoolingDD2018, measure.vars = names, variable.name = "week")
CollingDD2018 <- CoolingDD2018[, week := ymd(week)] 

CoolingDD2019 <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/ClimateDivisions.Cooling2019.txt") 
CoolingDD2019[Region == 3004,] -> CoolingDD2019
CoolingDD2019[,!(1), with = FALSE] -> CoolingDD2019
names <- colnames(CoolingDD2019)
CoolingDD2019 <- melt(CoolingDD2019, measure.vars = names, variable.name = "week")
CollingDD2019 <- CoolingDD2019[, week := ymd(week)] 

CoolingDD2020 <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/ClimateDivisions.Cooling2020.txt") 
CoolingDD2020[Region == 3004,] -> CoolingDD2020
CoolingDD2020[,!(1), with = FALSE] -> CoolingDD2020
names <- colnames(CoolingDD2020)
CoolingDD2020 <- melt(CoolingDD2020, measure.vars = names, variable.name = "week")
CollingDD2020 <- CoolingDD2020[, week := ymd(week)] 

CoolingDD <- rbind(CoolingDD2018, CoolingDD2019, CoolingDD2020) 
setnames(CoolingDD, c("week", "value"), c("week", "CDD"))


HeatingDD2018 <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/ClimateDivisions.Heating2018.txt") 
HeatingDD2018[Region == 3004,] -> HeatingDD2018
HeatingDD2018[,!(1), with = FALSE] -> HeatingDD2018
names <- colnames(HeatingDD2018)
HeatingDD2018 <- melt(HeatingDD2018, measure.vars = names, variable.name = "week")
HeatingDD2018 <- HeatingDD2018[, week := ymd(week)] 

HeatingDD2019 <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/ClimateDivisions.Heating2019.txt") 
HeatingDD2019[Region == 3004,] -> HeatingDD2019
HeatingDD2019[,!(1), with = FALSE] -> HeatingDD2019
names <- colnames(HeatingDD2019)
HeatingDD2019 <- melt(HeatingDD2019, measure.vars = names, variable.name = "week")
HeatingDD2019 <- HeatingDD2019[, week := ymd(week)] 

HeatingDD2020 <- fread("C:/Users/paulr/Documents/R/EnergyForecasting/data/ClimateDivisions.Cooling2020.txt") 
HeatingDD2020[Region == 3004,] -> HeatingDD2020
HeatingDD2020[,!(1), with = FALSE] -> HeatingDD2020
names <- colnames(HeatingDD2020)
HeatingDD2020 <- melt(HeatingDD2020, measure.vars = names, variable.name = "week")
HeatingDD2020 <- HeatingDD2020[, week := ymd(week)] 

HeatingDD <- rbind(HeatingDD2018, HeatingDD2019, HeatingDD2020) 
setnames(HeatingDD, c("week", "value"), c("week", "HDD"))

DD <- CoolingDD[HeatingDD, on=.(week = week)]
DD[,TDD := CDD + HDD]

Steam_Reg <- SteamPerDay[DD, on= .(ymdDate = week)]
Steam_Reg <- Steam_Reg[year(ymdDate) > 2018]
Steam_Reg[month(ymdDate) != 01 & month(ymdDate) != 02 & month(ymdDate) != 03 & month(ymdDate) != 04 & month(ymdDate) != 05 & month(ymdDate) != 12 & month(ymdDate) != 11 & month(ymdDate) != 10 & month(ymdDate) != 09 ] -> summer

Steam_Reg[month(ymdDate) != 06 & month(ymdDate) != 07 & month(ymdDate) != 08 & month(ymdDate) != 09  & month(ymdDate) != 12 & month(ymdDate) != 11 & month(ymdDate) != 10 ] -> winter


###############################################################################
#                               Do Simple Plots                               #
###############################################################################

ggplot(Electric_Data[1:.N], aes(x=Date, y=Value)) +
  geom_line(alpha = 0.8, size = .1)



