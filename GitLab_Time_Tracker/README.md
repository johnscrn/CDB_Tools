# GitLab Time Tracker

This repository contains scripts for tracking and reporting time spent on GitLab issues. The repository includes two primary R scripts:

1. `GitLab_Time_Tracker.r` - For tracking time spent on issues.
2. `GitLab_Reports.r` - For generating reports based on tracked time.

### GitLab_Time_Tracker.r

The `GitLab_Time_Tracker.r` script includes four main functions that help you track time spent on GitLab issues and update your reports accordingly. To use this script, source the file in R:

```R
source("GitLab_Time_Tracker.r")
```

#### Functions
```start('###') # Replace '###' with your issue number``` begin tracking time for a specific GitLab issue.  
  
```end()``` End time tracking for the last opened issue.  
  
```sync()``` Run periodically or daly to bulk calculate the total time spent from the start and end timestamps and report this to GitLab.  
  
```update_report_data()```  Crate and update flat file with all historic time.  
  

### GitLab_Reports.r
The `GitLab_Reports.r` script loads time data updated by update_report_data() in GitLab_Time_Tracker.r, collects issue tags from GitLab, and summarizes time by tag. To use this script open in R and modify to make the plots you want. Some examples are included. 

#### NOTE: Please read comments in the scripts for more details on how to use. This was created for internal use and will need some modification for anyone else to use

# Usage Example
```
## Source the time tracker script
source("GitLab_Time_Tracker.r")

## Start tracking time for issue #123
start('123')

## ... work on the issue ...

## End tracking
end()

## Sync time to GitLab
sync()

## Update report data
update_report_data()
```
```
## Annotate and make plots in R with 
GitLab_Reports.r
```
