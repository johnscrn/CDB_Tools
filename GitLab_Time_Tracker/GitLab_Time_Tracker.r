## devtools::install_github("statnmap/gitlabr")
library(gitlabr)
library(dplyr)
library(lubridate)

##########################################################################################
## ## This has to be done every year now
## ## Create a Token in GitLab that allows complete read and write access 'api'
## ## Save it in a RDS that isn't readable by humans in your home directory 'My Documents'
## GITLAB_COM_TOKEN <- '<token>' #replace with real token
## save(GITLAB_COM_TOKEN, file=paste0(Sys.getenv('HOME'),'/GITLAB_TOKEN'))
##########################################################################################

## Load Gitlab token
load(paste0(Sys.getenv('HOME'),'/GITLAB_TOKEN'))

## Connect to Gitlab
my_gitlab <- gl_connection(gitlab_url = "https://git......",
                           private_token = GITLAB_COM_TOKEN)
set_gitlab_connection(my_gitlab)

## Project ID Number. You can see this on Gitlab at Settings -> General
my_project <- ####

##########################################################################################
######################### The functions needed for time tracking #########################
##########################################################################################

## After sourcing this file these are the commands you can use
## Note that you can only have 1 issue open at a time

## start('111') will open a file at H:/CJ_Time_Tracking with the information issue 111 and start time
## The tempfile attached a random value to the filename to allow the same issue to have multiple times in a day
start <- function(issue){
    f.name <- tempfile(pattern=paste0(Sys.Date(), '_Issue-', issue,'_'), tmpdir='H:/CJ_Time_Tracking')
    line1 <- paste0('Issue = ',issue)
    line2 <- paste0('Start Time = ', Sys.time())
    sink(f.name)
    cat(paste0(line1, "\n", line2))
    sink()
}

## end() will find the most recently updated  file at H:/CJ_Time_Tracking and add  information end time
end <- function(){
    files <- list.files(path="H:/CJ_Time_Tracking", full.names = TRUE,recursive = TRUE)
    f.name <- files[which.max(file.mtime(files))]
    line1 <- paste0('\n','End Time = ', Sys.time(), '\n')
    sink(f.name, append=TRUE)
    cat(line1)
    sink()
}

## Sync()
## Daily/Periodically run this to update time files
## calculated the difference between start and end time and add to file
## Submit that to each Gitlab issue in the repository
## move file to the new folder H:/CJ_Time_Tracking_Cleared
Sync <- function(){
    files <- list.files(path="H:/CJ_Time_Tracking", full.names = TRUE,recursive = TRUE)
    for(i in 1:length(files)){
        Ls <- suppressWarnings(readLines(files[i], n=3))
        Issue <- gsub('Issue = ','',Ls[1])
        Start <- strptime(gsub('Start Time = ', '', Ls[2]), format = "%Y-%M-%d %H:%M:%S")
        End <- strptime(gsub('End Time = ', '', Ls[3]), format = "%Y-%M-%d %H:%M:%S")
        if(!is.na(End)){
            Dif <- seconds_to_period(difftime(End, Start, units="secs"))
            gl_comment_issue(project = my_project, id = Issue, text=paste0('/spend ',Dif))
            sink(files[i], append=TRUE)
            cat(paste0('Time Spent = ', Dif))
            sink()
            file.rename(files[i], gsub('Tracking','Tracking_Cleared',files[i]))
        } else {
            print(paste0(files[i], ' was not synced'))
        }
    }
}
## update_report_data()
## When someone wants a report
## Check the cleared folder for cleared time files
## Load the file that contains all historical time (backed up on Gitlab)
## Add the new information and move the cleared files to raw files backup folder (May never use these again)
## Save the table back to Gitlab and use this file to make plots or whatever
update_report_data <- function(){
    files <- list.files(path="H:/CJ_Time_Tracking_Cleared", full.names = TRUE,recursive = TRUE)
    time.table <- read.table('E:/GitLab_Repos/cdb_bfx/Maintenance/GitLab_Time_Data.txt',
                             sep=',', header=T)
    if(length(files)==0){
        print('There are no knew files at H:/CJ_Time_Tracking_Cleared')
    } else {
        for(i in 1:length(files)){
            Ls <- suppressWarnings(readLines(files[i], n=4))
            date <- unlist(strsplit(Ls[3], ' '))[4]
            iid <- unlist(strsplit(Ls[1], ' '))[3]
            time <- paste(unlist(strsplit(Ls[4], ' '))[c(-1,-2,-3)], collapse=' ')
            time.table <- rbind(time.table, c('johnscrn',date, iid, time))
            file.rename(files[i], gsub('CJ_Time_Tracking_Cleared','GitLab_Reports_Raw_Files',files[i]))
        }
        write.table(time.table,
                    file='E:/GitLab_Repos/cdb_bfx/Maintenance/GitLab_Time_Data.txt',
                    sep=',', row.names=F, quote=F)
    }
}





