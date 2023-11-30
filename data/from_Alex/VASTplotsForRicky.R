
# packages

require(dplyr)
require(ggplot2)

#### load in data
load("C:/Users/alex.hansell/Documents/GitHub/BSB.Index.Analyses/VAST/Runs/Spring/Index/parameter_estimates.RData")
Sdreport_spring <-parameter_estimates$SD

load("C:/Users/alex.hansell/Documents/GitHub/BSB.Index.Analyses/VAST/Runs/Fall/Index/parameter_estimates.RData")
Sdreport_fall <-parameter_estimates$SD




# format data for plotting 

nrow_sd <- length(Sdreport_spring$value)
year<-1989:2021
n_yea <- length(unique(year))
n_surv <- 11
n_stock<-2

df_sdreport_spring <-
  data.frame(variable = c(names(Sdreport_spring$value)),
             value = c(Sdreport_spring$value),
             sd = c(Sdreport_spring$sd),
             Season = c(rep("Spring", times = nrow_sd)))

df_sdreport_fall <-
  data.frame(variable = c(names(Sdreport_fall$value)),
             value = c(Sdreport_fall$value),
             sd = c(Sdreport_fall$sd),
             Season = c(rep("Fall", times = nrow_sd)))

#df_sdreport<-rbind(df_sdreport_spring,df_sdreport_fall)

##### COG
df_cog_spring <-
  df_sdreport_spring %>%
  dplyr::filter(variable %in% c("mean_Z_ctm"))%>%
  dplyr::mutate(variable = rep(c("Eastings", "Northings"),
                               each = n_yea*n_stock),
                Region = rep(c("North", "South"),
                            each = 1,
                            times = n_yea*n_stock),
                year   = rep(c(1989:2021),
                             each = 2,
                             times = 2))

df_cog_fall <-
  df_sdreport_fall %>%
  dplyr::filter(variable %in% c("mean_Z_ctm"))%>%
  dplyr::mutate(variable = rep(c("Eastings", "Northings"),
                               each = n_yea*n_stock),
                Region = rep(c("North", "South"),
                             each = 1,
                             times = n_yea*n_stock),
                year   = rep(c(1989:2021),
                             each = 2,
                             times = 2))

df_cog<-rbind(df_cog_spring,df_cog_fall)

a<-ggplot(data = df_cog%>%
         filter(variable == "Northings"),aes(x=year, y=value, col=Region))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_grid(~Season, scales="free")+
  ylab("Northings(Km)")+ xlab("Year")+
  theme_bw()+ theme(legend.position = "none")

b<-ggplot(data = df_cog%>%
         filter(variable == "Eastings"),aes(x=year, y=value,col=Region))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_grid(~Season, scales="free")+
  ylab("Eastings(Km)")+xlab("Year")+
  theme_bw()+theme(legend.position="bottom")

a<-ggplot(data = df_cog%>%
            filter(Season == "Fall",
                   variable == "Northings"),aes(x=year, y=value, col=Region))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_grid(~Region, scales="free")+
  ylab("Northings(Km)")+ xlab("Year")+
  theme_bw()+ theme(legend.position = "none")

b<-ggplot(data = df_cog%>%
            filter(Season == "Fall",
                   variable == "Eastings"),aes(x=year, y=value,col=Region))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_grid(~ Region, scales="free")+
  ylab("Eastings(Km)")+xlab("Year")+
  theme_bw()+theme(legend.position="bottom")

figure <- ggarrange(a, b,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)

ggsave("Fall_cog.png", width = 20, height = 20, units = "cm",dpi = 600)

# calculate avg 

spring_north<-df_cog_spring%>%
  filter(Region == "North",
         variable == "Northings")%>%
  mutate(Diff = value - lag(value))

mean(spring_north$Diff, na.rm = TRUE)
sd(spring_north$Diff, na.rm = TRUE)

sum(spring_north$Diff, na.rm = TRUE)

spring_south<-df_cog_spring%>%
  filter(Region == "South",
         variable == "Northings")%>%
  mutate(Diff = value - lag(value))

mean(spring_south$Diff, na.rm = TRUE)
sd(spring_south$Diff, na.rm = TRUE)

sum(spring_south$Diff, na.rm = TRUE)


fall_north<-df_cog_fall%>%
  filter(Region == "North",
         variable == "Northings")%>%
  mutate(Diff = value - lag(value))

mean(fall_north$Diff, na.rm = TRUE)
sd(fall_north$Diff, na.rm = TRUE)

sum(fall_north$Diff, na.rm = TRUE)


fall_south<-df_cog_fall%>%
  filter(Region == "South",
         variable == "Northings")%>%
  mutate(Diff = value - lag(value))

mean(fall_south$Diff, na.rm = TRUE)
sd(fall_south$Diff, na.rm = TRUE)

sum(fall_south$Diff, na.rm = TRUE)


fall_south2<-df_cog_fall%>%
  filter(Region == "South",
         variable == "Eastings")%>%
  mutate(Diff = value - lag(value))


library(rgdal)
#utm <- complete.cases(fall_south$value)
utm1 <- data.frame(x=fall_south2$value,y=fall_south$value) 
coordinates(utm1) <- ~x+y 
class(utm1)
proj4string(utm1) <- CRS("+proj=utm +zone=19 +datum=WGS84 +units=km +ellps=WGS84") 
utm2 <- spTransform(utm1,CRS("+proj=longlat +datum=WGS84"))

utm2<-as.data.frame(utm2)

utm2$Year<- 1989:2021


sN<-df_cog_spring%>%
  filter(variable == "Northings")%>%
  rename(northings = value)

sE<-df_cog_spring%>%
  filter(variable == "Eastings")%>%
  rename(eastings = value)%>%
  select(year, Region, eastings)

df<-full_join(sN,sE)

df2<-df%>%
  select(northings, eastings)

utm1 <- data.frame(x=df2$eastings,y=df2$northings) 
coordinates(utm1) <- ~x+y 
class(utm1)
proj4string(utm1) <- CRS("+proj=utm +zone=19 +datum=WGS84 +units=km +ellps=WGS84") 
utm2 <- spTransform(utm1,CRS("+proj=longlat +datum=WGS84"))

utm2<-as.data.frame(utm2)

df3<-cbind(df,utm2)

#############################
fN<-df_cog_fall%>%
  filter(variable == "Northings")%>%
  rename(northings = value)

fE<-df_cog_fall%>%
  filter(variable == "Eastings")%>%
  rename(eastings = value)%>%
  select(year, Region, eastings)

dff<-full_join(fN,fE)

dff2<-dff%>%
  select(northings, eastings)

utm1 <- data.frame(x=dff2$eastings,y=dff2$northings) 
coordinates(utm1) <- ~x+y 
class(utm1)
proj4string(utm1) <- CRS("+proj=utm +zone=19 +datum=WGS84 +units=km +ellps=WGS84") 
utm3 <- spTransform(utm1,CRS("+proj=longlat +datum=WGS84"))

utm3<-as.data.frame(utm2)

df4<-cbind(dff,utm3)

df4<-rbind(df3,df4)

############################

ggplot() +
   geom_point(data = df4,
              aes(y=y,x=x, col = year))+
  geom_sf(data = world) + ylab("Lat") + xlab("Lon")+
  coord_sf(xlim = c(-78, -65), ylim = c(34, 45))+ 
  scale_colour_viridis_c()+
  facet_wrap(~Region + Season)



#### Age based indices 

C:\Users\alex.hansell\Documents\GitHub\BSB.Index.Analyses\VAST\Runs\Age\spring_north

Table_for_SS3 <- read.csv("~/GitHub/BSB.Index.Analyses/VAST/Runs/Age/spring_north/Index.csv")

Table_for_SS3 <- read.csv("~/GitHub/BSB.Index.Analyses/VAST/Runs/Age/Fall/index.csv")

z<-Table_for_SS3%>%
  group_by(Category)%>%
  summarize(Time,
            Index = (Estimate / mean(Estimate )),
            CV = Std..Error.for.Estimate/Estimate)%>%
  rename(Year = Time,
         Age = Category)%>%
  mutate(Age = as.factor(Age))


a<- ggplot()+
   geom_errorbar(data = z,aes(x = Year, ymin=Index-(CV), ymax=Index+(CV)), width=.2,
                 position=position_dodge(.9))+
  geom_point(data = z, aes(x = Year, y= Index, col = Age))+
  geom_line(data = z, aes(x = Year, y= Index, col = Age))+ 
  theme_bw() +
facet_wrap(~ Age, scale = "free")+ scale_colour_viridis_d()

a<- ggplot()+
  geom_errorbar(data = z,aes(x = Year, ymin=Index-(CV), ymax=Index+(CV)), width=.2,
                position=position_dodge(.9))+
  geom_point(data = z, aes(x = Year, y= Index, col = Age))+
  geom_line(data = z, aes(x = Year, y= Index, col = Age))+ 
  theme_bw() +
  facet_wrap(~ Age, scale = "free")+ scale_colour_viridis_d()


figure <- ggarrange(a, b,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)

ggsave("Index_agefall.png", width = 30, height = 20, units = "cm",dpi = 600)



################# Effective Area
df_effArea_spring <-
  df_sdreport_spring %>%
  dplyr::filter(variable %in% c("effective_area_ctl"))%>%
  dplyr::mutate(Region = rep(c("North", "South"),
                           times = n_yea*n_surv))%>%
  dplyr::mutate(year   = rep(c(1989:2021),
                             each = 2,
                             times = 11),
                survey   = rep(c(1:11),
                               each = 66,
                               times = 1))

df_effArea_fall <-
  df_sdreport_fall %>%
  dplyr::filter(variable %in% c("effective_area_ctl"))%>%
  dplyr::mutate(Region = rep(c("North", "South"),
                             times = n_yea*n_surv))%>%
  dplyr::mutate(year   = rep(c(1989:2021),
                             each = 2,
                             times = 11),
                survey   = rep(c(1:11),
                               each = 66,
                               times = 1))

df_effArea<-rbind(df_effArea_spring,df_effArea_fall)

ggplot(data = df_effArea%>%
         filter( survey == 1),aes(x=year, y=value,col=Region))+
  geom_line()+
  geom_point()+
  #geom_smooth(method = "lm", se=FALSE, color="red")+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~ Season + Region, scales="free")+
  ylab("Effective area occupied (Km^2)")+xlab("Year")+
  theme_bw()

ggsave("effArea.png", width = 20, height = 20, units = "cm",dpi = 600)


figure <- ggarrange(a, b,c,
                    labels = c("A", "B","C"),
                    ncol = 2, nrow = 2)

########## Age based estimates

#### load in data
load("C:/Users/alex.hansell/Documents/GitHub/BSB.Index.Analyses/VAST/Runs/Age/North/parameter_estimates.RData")
Sdreport_spring <-parameter_estimates$SD

load("C:/Users/alex.hansell/Documents/GitHub/BSB.Index.Analyses/VAST/Runs/Age/Spring2/parameter_estimates.RData")
Sdreport_spring <-parameter_estimates$SD

load("C:/Users/alex.hansell/Documents/GitHub/BSB.Index.Analyses/VAST/Runs/Age/Fall/parameter_estimates.RData")
Sdreport_fall <-parameter_estimates$SD


nrow_sd <- length(Sdreport_spring$value)
year<-1989:2021
n_yea <- length(unique(year))
n_surv <- 11
n_stock<-2
n_ages<-8

df_sdreport_spring <-
  data.frame(variable = c(names(Sdreport_spring$value)),
             value = c(Sdreport_spring$value),
             sd = c(Sdreport_spring$sd),
             Season = c(rep("Spring", times = nrow_sd)))

nrow_sd <- length(Sdreport_fall$value)
df_sdreport_fall <-
  data.frame(variable = c(names(Sdreport_fall$value)),
             value = c(Sdreport_fall$value),
             sd = c(Sdreport_fall$sd),
             Season = c(rep("Fall", times = nrow_sd)))

#df_sdreport<-rbind(df_sdreport_spring,df_sdreport_fall)

##### COG
df_cog_spring <-
  df_sdreport_spring %>%
  dplyr::filter(variable %in% c("mean_Z_ctm"))%>%
  dplyr::mutate(variable = rep(c("Eastings", "Northings"),
                               each = n_yea*n_ages),
                Age = rep(c(1:8),
                             each = 1,
                             times = n_yea*2),
                year   = rep(c(1989:2021),
                             each = 8,
                             times = 2))

df_cog_fall <-
  df_sdreport_fall %>%
  dplyr::filter(variable %in% c("mean_Z_ctm"))%>%
  dplyr::mutate(variable = rep(c("Eastings", "Northings"),
                               each = n_yea*n_ages),
                Age = rep(c(1:8),
                          each = 1,
                          times = n_yea*2),
                year   = rep(c(1989:2021),
                             each = 8,
                             times = 2))

df_cog<-rbind(df_cog_spring,df_cog_fall)

a<-ggplot(data = df_cog_spring%>%
         filter(variable == "Northings"),aes(x=year, y=value, col=Age))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~Age, scales="free")+
  ylab("Northings(Km)")+ xlab("Year")+
  theme_bw()+ theme(legend.position = "none")+ scale_colour_viridis_c()


b<-ggplot(data = df_cog_spring%>%
         filter(variable == "Eastings"),aes(x=year, y=value, col=Age))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~Age, scales="free")+
  ylab("Eastings(Km)")+ xlab("Year")+
  theme_bw()+ theme(legend.position = "bottom")+ scale_colour_viridis_c()

c<-ggplot(data = df_cog_fall%>%
            filter(variable == "Northings"),aes(x=year, y=value, col=Age))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~Age, scales="free")+
  ylab("Northings(Km)")+ xlab("Year")+
  theme_bw()+ theme(legend.position = "none")+ scale_colour_viridis_c()


d<-ggplot(data = df_cog_fall%>%
            filter(variable == "Eastings"),aes(x=year, y=value, col=Age))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~Age, scales="free")+
  ylab("Eastings(Km)")+ xlab("Year")+
  theme_bw()+ theme(legend.position = "none")+ scale_colour_viridis_c()


ggplot(data = df_cog_fall,aes(x=year, y=value, col=as.factor(Age)))+
  geom_line()+
  geom_point()+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~variable, scales="free")+
  ylab("Northings(Km)")+ xlab("Year")+
  theme_bw()+ theme(legend.position = "none")+ scale_colour_viridis_d()



figure <- ggarrange(a, b,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)
ggsave("Age_spring.png", width = 20, height = 30, units = "cm",dpi = 600)


figure <- ggarrange(c, d,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)
ggsave("Age_fall.png", width = 20, height = 30, units = "cm",dpi = 600)



################# Effective Area


df_effA_spring <-
  df_sdreport_spring %>%
  dplyr::filter(variable %in% c("effective_area_ctl"))%>%
  dplyr::mutate(
                Age = rep(c(1:8),
                          each = 1,
                          times = n_yea*1),
                year   = rep(c(1989:2021),
                             each = 8,
                             times = 1))
nrow(df_effA_fall)
df_effA_fall <-
  df_sdreport_fall %>%
  dplyr::filter(variable %in% c("effective_area_ctl"))%>%
  dplyr::mutate(
    Age = rep(c(1:8),
              each = 1,
              times = n_yea*2),
    year   = rep(c(1989:2021),
                 each = 8,
                 times = 2))


df_effA_fall2<-df_effA_fall[c(1:264),]

df_effA_fall3<-df_effA_fall[c(265:528),]


df_effArea<-rbind(df_effA_spring,df_effA_fall)

a<-ggplot(data = df_effA_spring,aes(x=year, y=value,col=Age))+
  geom_line()+
  geom_point()+
  #geom_smooth(method = "lm", se=FALSE, color="red")+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~Age, scales="free")+
  ylab("Effective area occupied (Km^2)")+xlab("Year")+
  scale_colour_viridis_c()+
  theme_bw()+theme(legend.position = "none")

b<-ggplot(data = df_effA_fall3,aes(x=year, y=value,col=Age))+
  geom_line()+
  geom_point()+
  #geom_smooth(method = "lm", se=FALSE, color="red")+
  geom_errorbar(aes(ymin=value-sd, ymax=value+sd))+
  facet_wrap(~Age, scales="free")+
  ylab("Effective area occupied (Km^2)")+xlab("Year")+
  scale_colour_viridis_c()+
  theme_bw()+theme(legend.position = "bottom")

figure <- ggarrange(a, b,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)

ggsave("effArea_Age.png", width = 20, height = 30, units = "cm",dpi = 600)


#########################################

# reorganize_____ this needs to be cleaned up but works as is
Table_for_SS3 <- read.csv("~/GitHub/BSB.Index.Analyses/VAST/Runs/Spring/noEnv/Index.csv")

north<-Table_for_SS3%>%
  filter(#Fleet == 1, 
    Category == 1)%>%
  mutate( Unit = "North", 
          CV_north = Std..Error.for.Estimate/Estimate)%>%
  dplyr::rename(North = Estimate,
                Year = Time)%>%
  select(Year,North,CV_north)

south<-Table_for_SS3%>%
  filter(#Fleet == 1, 
    Category == 2)%>%
  mutate( Unit = "South", 
          CV_south = Std..Error.for.Estimate/Estimate)%>%
  dplyr::rename(South = Estimate)%>%
  select(Unit,South,CV_south)

x<-cbind(north,south)

df_p<-x%>%
  mutate(Proportion_South = (South/(North + South))*100,
         Proportion_North = (North/(North + South))*100)

N<-df_p%>%
  select(Year,Proportion_North)%>%
  rename(Proportion = Proportion_North)%>%
  mutate(Region = "North")

S<-df_p%>%
  select(Year,Proportion_South,Unit)%>%
  rename(Proportion = Proportion_South)

names(S)<-names(N)

x<-rbind(N,S)

a<-ggplot(x, aes(fill=Region, y=Proportion, x=Year)) + 
  geom_bar(position="stack", stat="identity") + 
  theme_bw()+theme(legend.position = "none")


# reorganize_____ this needs to be cleaned up but works as is
Table_for_SS3 <- read.csv("~/GitHub/BSB.Index.Analyses/VAST/Runs/Fall/Index/Table_for_SS3.csv")

north<-Table_for_SS3%>%
  filter(#Fleet == 1, 
    Category == 1)%>%
  mutate( Unit = "North", 
          CV_north = SD_mt/Estimate_metric_tons)%>%
  dplyr::rename(North = Estimate_metric_tons)%>%
  select(Year,North,CV_north)

south<-Table_for_SS3%>%
  filter(#Fleet == 1, 
    Category == 2)%>%
  mutate( Unit = "South", 
          CV_south = SD_mt/Estimate_metric_tons)%>%
  dplyr::rename(South = Estimate_metric_tons)%>%
  select(Unit,South,CV_south)

y<-cbind(north,south)

df_p<-y%>%
  mutate(Proportion_South = (South/(North + South))*100,
         Proportion_North = (North/(North + South))*100)

N<-df_p%>%
  select(Year,Proportion_North)%>%
  rename(Proportion = Proportion_North)%>%
  mutate(Region = "North")

S<-df_p%>%
  select(Year,Proportion_South,Unit)%>%
  rename(Proportion = Proportion_South)

names(S)<-names(N)

y<-rbind(N,S)

b<-ggplot(y, aes(fill=Region, y=Proportion, x=Year)) + 
  geom_bar(position="stack", stat="identity") + 
  theme_bw()+theme(legend.position = "bottom")

figure <- ggarrange(a, b,
                    labels = c("A", "B"),
                    ncol = 1, nrow = 2)

ggsave("prop.png", width = 20, height = 30, units = "cm",dpi = 600)

