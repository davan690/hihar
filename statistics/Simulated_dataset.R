##beginning dataset structure for analysis
##Anthony Davidson
#30072017

#seting up simulation dataset

spp <- c(rep("eg.kangaroo",20), 
         rep("wallaroo",5), 
         rep("wombat", 4)
         rep("rockwallaby",1), 
         rep("other", 10))

status <- c("dead", "injured", "absent")
time_hit <- 
time_recorded <- 
lat <-
log <- 
insurance <- 
reporter <- c("offical", "ranger", "public")

dat <- data.frame(spp, status, time_hit, 
                  time_recorded,lat, long, insurance, reporter)


####this can then be merged with the following datasets.....
