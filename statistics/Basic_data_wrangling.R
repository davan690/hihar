#looking at datasets
#anthony davidson
#29072017

#setwd
setwd("C:/Users/s435389/Dropbox/Shared projects_folders/GovHack2017")

#library
library(tidyverse)
library(lubridate)
library(jagsUI)
library(cowplot)
library(Matrix)
library(ggthemes)
library(ggplot2)
library(gridExtra)
library(coda)

#------------------------import data
#wildlife calls
ass_call_wild_dat <- read.csv("Wildlife_assistance_Calls_2016_-_17.csv")

#Atlas records basic
atlas_wildlife <- read.csv("ACT_Wildlife_Atlas_Records.csv")

#street lights
street_lights <- read.csv("ACT_Streetlights.csv")

#road signs
road.signs <- read.csv("Road_Signs_in_the_ACT.csv")

#population density
current_pop <- read.csv("Estimated_resident_population_by_ACT_town_centre__Statistical_Area_3_.csv")
expect_pop_age <- read.csv("ACT_Population_Projections_by_age_groups.csv")

#projected population sizes
overall_projection <- read.csv("ACT_Population_Projections.csv")

#data structure
glimpse(ass_call_wild_dat)
glimpse(atlas_wildlife)
glimpse(street_lights)
glimpse(current_pop)
glimpse(expect_pop_age)
glimpse(overall_projection)

#----------overall observation data from 2016-2017
table(ass_call_wild_dat$WILDLIFE_TYPE)
barplot(table(ass_call_wild_dat$WILDLIFE_TYPE))

##reduce data to species
#remove species == other

dat1 <- filter(ass_call_wild_dat,!SPECIES == "OTHER") %>%
  filter(!SPECIES == "BRUSHTAIL POSSUM") %>%
  group_by(SPECIES) %>%
  summarise(count = n()) %>%
  droplevels() %>% 
  arrange(desc(count))

dat1$DIVISION
levels(dat1$SPECIES) <- as.character(c("Reptile", "Reptile", 
                         "Bird","Bird","Eastern Grey Kangaroo", "Bird", "Bird", "Bird", "Bird", "Bird","Bird"
                         ,"Bird", "Reptile", "Wallaby", "Bird", "Wallaby", "Bird",
                         "Wallaroo", "Wombat"))
dat1$SPECIES <- factor(dat1$SPECIES,
                          levels = c("Eastern Grey Kangaroo","Wallaby","Reptile","Bird",
                                      "Reptile","Bird","Wallaroo", "Wombat"))


###number by species
p1 <- ggplot(dat1,aes(y = count, x = SPECIES)) +
  geom_bar(stat = "summary", fun.y=sum) +
  labs(y = "Total recorded",
       x = "Animal") +
  theme_tufte() +
  theme_bw(base_family = "serif", base_size = 20) +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank(),
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle=element_text(size=16, hjust=0.5, face="italic", color="blue"),
        legend.key = element_blank(), 
        panel.background = element_blank(), 
        panel.border = element_blank(), 
        plot.background = element_blank(), 
        legend.position = c(0.9,0.9),
        legend.background = element_rect(fill="white", size=1, linetype="solid", colour ="black"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.title.y=element_text(colour = "black",size =18),
        axis.title.x = element_text(colour = "black",size =18),
        axis.text.y=element_text(colour = "black",size = 12), 
        axis.text.x=element_text(colour = "black",size = 12, angle = 45,hjust = 1),
        axis.ticks.x = element_line(size = 1),
        axis.ticks.y = element_line(size = 1),
        axis.line.x = element_line(size = 1),
        axis.line.y = element_line(size = 1)) +
  ggtitle("Animals hit by cars in ACT(2016-2017)")

ggsave(file="Totalanimalshitin2016_17.svg", plot=p1, width=10, height=8)
ggsave(file="Totalanimalshitin2016_17.png", plot=p1, width=10, height=8)
#------extract data on the num
glimpse(ass_call_wild_dat)

##species location data
write.csv(data.frame(table(ass_call_wild_dat$DIVISION)), "test11.csv")


##plot the locations with more than 50 animals killed over year
dat2 <- filter(ass_call_wild_dat,!SPECIES == "OTHER") %>%
  filter(!SPECIES == "BRUSHTAIL POSSUM") %>%
  group_by(DIVISION) %>%
  summarise(count = n()) %>%
  droplevels() %>% 
  arrange(desc(count))

dat2 <- filter(dat2, count > 50)%>%
  droplevels()


dat2$DIVISION <- factor(dat2$DIVISION,
                       levels = c("RURAL","KAMBAH","HUME","SYMONSTON","O'MALLEY","RED HILL","CONDER","CALWELL" ))


#plot
p2 <- ggplot(dat2,aes(y = count, x = DIVISION)) +
  geom_bar(stat = "summary", fun.y=sum) +
  labs(y = "Total recorded",
       x = "Suburb") +
  theme_tufte() +
  theme_bw(base_family = "serif", base_size = 20) +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank(),
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle=element_text(size=16, hjust=0.5, face="italic", color="blue"),
        legend.key = element_blank(), 
        panel.background = element_blank(), 
        panel.border = element_blank(), 
        plot.background = element_blank(), 
        legend.position = c(0.9,0.9),
        legend.background = element_rect(fill="white", size=1, linetype="solid", colour ="black"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.title.y=element_text(colour = "black",size =18),
        axis.title.x = element_text(colour = "black",size =18),
        axis.text.y=element_text(colour = "black",size = 12), 
        axis.text.x=element_text(colour = "black",size = 12),
        axis.ticks.x = element_line(size = 1),
        axis.ticks.y = element_line(size = 1),
        axis.line.x = element_line(size = 1),
        axis.line.y = element_line(size = 1)) +
  ggtitle("More than 50 animals hit by cars by suburb(2016-2017)")

ggsave(file="More_than_50animals_hit2016_17.svg", plot=p2, width=10, height=8)
ggsave(file="More_than_50animals_hit2016_17.png", plot=p2, width=10, height=8)


#-----------------------------###season.....

ass_call_wild_dat$CREATED_DATE <- as.Date(ass_call_wild_dat$CREATED_DATE)


##plot the locations with more than 50 animals killed over year
dat3 <- filter(ass_call_wild_dat,!SPECIES == "OTHER") %>%
  filter(!SPECIES == "BRUSHTAIL POSSUM") %>%
  filter(!CREATED_DATE == "2017-07-01") %>%
  mutate(month = format(CREATED_DATE, "%m"), 
         year = format(CREATED_DATE, "%Y"),
         link = factor(paste(year,month))) %>%
  droplevels()

str(dat3$link)

labels1 = c("July 2016","August 2016","September 2016", "October 2016", "November 2016", "December 2016", "January 2017",
           "February 2017", "March 2017", "April 2017", "May 2017", "June 2017")
 


levels(dat3$SPECIES) <- as.character(c("Reptile", "Reptile", 
                                         "Bird","Bird","Eastern Grey Kangaroo", "Bird", "Bird", "Bird", "Bird", "Bird","Bird"
                                         ,"Bird", "Reptile", "Wallaby", "Bird", "Wallaby", "Bird",
                                         "Wallaroo", "Wombat"))
dat3$SPECIES <- factor(dat3$SPECIES,
                       levels = c("Eastern Grey Kangaroo","Wallaby","Reptile","Bird",
                                  "Reptile","Bird","Wallaroo", "Wombat"))

head(dat3)

dat3 <- dat3 %>%
  group_by(link, SPECIES,month,year,link)%>%
  summarise(count = n())





str(dat3$link)
unique(dat3$link)






# dat2 <- filter(dat2, count > 50)%>%
#   droplevels()
# 
# 
# dat3$DIVISION <- factor(dat2$DIVISION,
#                         levels = c("RURAL","KAMBAH","HUME","SYMONSTON","O'MALLEY","RED HILL","CONDER","CALWELL" ))


#plot
p3 <- ggplot(dat3,aes(y = count, x = link, colour = SPECIES)) +
  geom_point() +
  geom_line(aes(group = SPECIES)) +
  labs(y = "Total recorded",
       x = "Year") +
  scale_x_discrete(labels = labels1) +
  theme_tufte() +
  theme_bw(base_family = "serif", base_size = 20) +
  theme(strip.background = element_blank(),
        strip.text.x = element_blank(),
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle=element_text(size=16, hjust=0.5, face="italic", color="blue"),
        legend.key = element_blank(), 
        panel.background = element_blank(), 
        panel.border = element_blank(), 
        plot.background = element_blank(), 
        legend.position = c(0.9,0.55),
        legend.background = element_rect(fill="white", size=1, linetype="solid", colour ="black"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.title.y=element_text(colour = "black",size =18),
        axis.title.x = element_text(colour = "black",size =18),
        axis.text.y=element_text(colour = "black",size = 12), 
        axis.text.x=element_text(colour = "black", size = 12, hjust = 1, angle = 45),
        axis.ticks.x = element_line(size = 1),
        axis.ticks.y = element_line(size = 1),
        axis.line.x = element_line(size = 1),
        axis.line.y = element_line(size = 1)) +
  ggtitle("Reported seasonal trends per species group(2016-2017)")

ggsave(file="Seasonal_reported_roadkill_2016_17.svg", plot=p3, width=15, height=8)
ggsave(file="Seasonal_reported_roadkill_2016_17.png", plot=p3, width=15, height=8)



###############matching the latlongs with the data sheet


##species location data
data.frame(table(ass_call_wild_dat$DIVISION))

dat_div <- read.csv("divisions.csv")

dat7 <- select(dat_div,Division, Longitude,Lattitude)











