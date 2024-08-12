library(gitlabr)
library(dplyr)
library(ggplot2)

##########################################################################################
## This script is designed to summarize and plot data from the file generated by update_report_data() in GitLab_Time_Tracker.r
## Refer to that file for Gitlab token questions or project ID

## Things to note about my workflow:
## 1. All 'issues' in the repository must have a label attached to them. Specifically all Principle Investigators have a label that looks like Lab::Coulombe
##########################################################################################

load(paste0(Sys.getenv('HOME'),'/GITLAB_TOKEN'))

my_gitlab <- gl_connection(gitlab_url = "https://git.....",
                           private_token = GITLAB_COM_TOKEN)
set_gitlab_connection(my_gitlab)
my_project <- ####

## collect annotation data for each issue
issues.annotation <-
    gl_list_issues(my_project, max_page=99) %>%
    select(iid, title, starts_with('labels')) %>%
    mutate(LAB = 'default') %>%
    as.data.frame()

## Find the "Lab::" the issue is associated with for proper attribution
for(i in 1:nrow(issues.annotation)){
    issues.annotation[i,"LAB"] <- issues.annotation[i,grepl('Lab::',issues.annotation[i,])]
}

## If you get this error Error in x[[jj]][iseq] <- vjj : replacement has length zero
## Then one of the issues does not have a lab attached to it on github
## Running this should tell you which issue it is:
## issues.annotation$iid[which(issues.annotation$LAB=='default')[1]]

issues.annotation <- issues.annotation %>% select(iid, title, LAB)

## This file is from GitLab_Time_Tracker.r's update_report_data()
data <- read.table('E:/GitLab_Repos/cdb_bfx/Maintenance/GitLab_Time_Data.txt',
                   sep=',', header=T)

## attach Lab information to the data table
ix <- match(data$iid, issues.annotation$iid)
data <- data %>% mutate("Lab"=issues.annotation$LAB[ix])

### Convert Time to time in minutes
time <- data$Time
time.in.minutes <- NULL
for(i in 1:length(time)){
    entry <- unlist(strsplit(time[i], ' '))
    minutes <- 0
    if(any(grepl('D',entry))){
        days <- as.numeric(gsub('D','',entry[grep('D',entry)]))
        minutes <- minutes + days*8*60
    }
    if(any(grepl('H',entry))){
        hours <- as.numeric(gsub('H','',entry[grep('H',entry)]))
        minutes <- minutes + hours*60
    }
    if(any(grepl('M',entry))){
        mins <- as.numeric(gsub('M','',entry[grep('M',entry)]))
        minutes <- minutes + mins
    }
    time.in.minutes[i] <- minutes
}
data$Time <- time.in.minutes

## convert date to month.year
year.month <- unlist(lapply(strsplit(data$date,'-'),
                            function(X){paste(X[1],X[2],sep='.')}))
data$date <- year.month
data$iid <- as.character(data$iid)

sum.of.min <- data %>%
    group_by(date, iid) %>%
    summarise(total.minutes.iid = sum(Time))

## Saving these RDS for use in internal plotting tool Some possible plots are listed below
setwd('E:/GitLab_Repos/cdb_bfx/Maintenance/Time_Reporting_Shiny')
saveRDS(sum.of.min, file='sum.of.min.RDS')
saveRDS(issues.annotation, file='issues.annotation.RDS')

### Testing possible plots for shiny app
## final.df <- left_join(sum.of.min, issues.annotation, by="iid") %>%
##     group_by(date, LAB) %>%
##     summarise(total.minutes.user = sum(total.minutes.iid)) %>%
##     group_by(date) %>%
##     arrange(date, desc(LAB)) %>%
##     mutate(lab_ypos = cumsum(total.minutes.user) - .5*total.minutes.user)

## library(plotly)
## p <- ggplot(final.df, aes(x=date, y=total.minutes.user,
##                           text = paste('</br> Lab: ', gsub('Lab::','',LAB),
##                                        '</br> Time(minutes): ', total.minutes.user))) +
##     geom_col(aes(fill=LAB), width=.7) +
##     geom_text(aes(y=lab_ypos, label=gsub('Lab::','',LAB), group=LAB), color='black')  +
##     theme(axis.text.x=element_text(angle=-90, vjust=.5))  +
##     xlab("Year.Month") + ylab("Total Minutes") + labs(title='Minutes each month per Lab')

##  ggplotly(p, tooltip = "text")


## giger.df <- left_join(sum.of.min, issues.annotation, by="iid") %>%
##     filter(LAB=='Lab::Giger') %>%
##     group_by(date) %>%
##     arrange(date, desc(iid)) %>%
##     mutate(lab_ypos = cumsum(total.minutes.iid)-.5*total.minutes.iid)

## p <- ggplot(giger.df, aes(x=date, y=total.minutes.iid,
##                            text = paste('</br> Issue: ', iid,
##                                         '</br> Title: ', title,
##                                         '</br> Time(minutes): ', total.minutes.iid))) +
##     geom_col(aes(fill=as.character(iid)), width=.7) +
##     geom_text(aes(y=lab_ypos, label=iid, group=iid), color='black') +
##     theme(axis.text.x=element_text(angle=-90, vjust=.5), legend.position='none')  +
##     xlab("Year.Month") + ylab("Total Minutes") + labs(title='values = Issue IDs (iid)')
## ggplotly(p, tooltip = "text")
