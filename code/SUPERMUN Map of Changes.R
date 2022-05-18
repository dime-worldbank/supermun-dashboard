#Clear R workspace
rm(list=ls())

#Load required packages
require(readstata13)
require(ggplot2)
require(ggthemes)

#Set working directory
dir<-"C:/Users/admin/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN"
setwd(dir)

#Read in Shape Files for Map
communes<-readRDS("C:/Users/admin/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN/SUPERMUN MAPS/Shape Files/BFA_adm3.rds")
names(communes)
unique(communes$NAME_1)
unique(communes$TYPE_3)
unique(communes$VARNAME_3)
length(unique(communes$NAME_3))
length(unique(institutional.capacity$commune))
length(unique(service.delivery$commune))

provinces<-readRDS("C:/Users/admin/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN/SUPERMUN MAPS/Shape Files/BFA_adm2.rds")
regions<-readRDS("C:/Users/admin/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN/SUPERMUN MAPS/Shape Files/BFA_adm1.rds")
country<-readRDS("C:/Users/admin/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN/SUPERMUN MAPS/Shape Files/BFA_adm0.rds")
names(communes)

concordance<-read.csv("C:/Users/admin/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN/SUPERMUN MAPS/Shape Files/Commune Concordance for Shape Files 2019-02-01.csv",header=TRUE,stringsAsFactors=FALSE)

## Merge concordance with differences dataset
diff.2017.2018 <- read.dta13("SUPERMUN DATA/Differences_2017_2018.dta")
diff.2017.2018$commune_edited <- diff.2017.2018$commune
diff.2017.2018$year <- 2018
diff.2017.2018 <- merge(concordance,diff.2017.2018,by=c("region","commune_edited"),all.x=TRUE)
temp<-merge(communes@data,diff.2017.2018,by=c("NAME_1","NAME_3"),all.x=TRUE)
communes@data<-temp[order(temp$ID_3),]

## Tidy up shape files and merge information from data slot into tidied-up dataset
require(broom)
communes@data$id<-communes@data$ID_3
communes.2<-tidy(communes)
communes.2<-merge(communes.2,communes@data,by="id",all.x=TRUE)

##FUNCTION TO MAKE MAP PLOT

MakeMap<-function(year,indicator,title,scale.name,scale.min,scale.mid,scale.max,censor=TRUE,scale.colors=c("red","yellow","green")) {
  if(scale.mid=="median") {
    scale.mid<-eval(parse(text=paste("median(subset(communes.2,year==year)$",indicator,", na.rm=TRUE)",sep="")))
  }
  indicator.2<-eval(parse(text=paste0("subset(communes.2,year==year)$",indicator)))
  #Censor indicator value at the scale minimum and maximum
  if(censor==TRUE) {
    indicator.2[indicator.2>scale.max]<-scale.max
    indicator.2[indicator.2<scale.min]<-scale.min
  }
  #eval(parse(text=indicator))
  burkina.communes<-ggplot(subset(communes.2,year==year))+
    geom_polygon(aes(x=long,y=lat,group=group),alpha=0.2,data=communes.2)+
    geom_polygon(aes(x=long,y=lat,group=group,fill=indicator.2),alpha=0.8)+
    geom_polygon(aes(x=long,y=lat,group=id),color="black",fill="NA",lwd=1,data=regions)+
    theme_few()+xlab("")+ylab("")+ggtitle(paste(title," (",year,")",sep=""))+coord_equal()+
    theme(axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks.x=element_blank(),axis.ticks.y=element_blank())+
    scale_fill_gradient2(name=scale.name,limits=c(scale.min,scale.max),midpoint=scale.mid,low=scale.colors[1],mid=scale.colors[2],high=scale.colors[3])
  burkina.communes 
}

#Change in service delivery score
quantile(diff.2017.2018$total_points_sd, na.rm=TRUE)
MakeMap(year=2018, indicator="total_points_sd", title="Services Publics: Changement par rapport à l'année précédante", scale.name="Points", scale.min=-10, scale.mid=0, scale.max=10, scale.colors=c("red","yellow","green"))
ggsave(paste0("SUPERMUN MAPS/Outputs/Changes2017-18_ServiceDelivery.png"))

#Change in institutional capacity score
quantile(diff.2017.2018$total_points_ic, na.rm=TRUE)
MakeMap(year=2018, indicator="total_points_ic", title="Capacité Institutionnelle: Changement par rapport à l'année précédante", scale.name="Points", scale.min=-10, scale.mid=0, scale.max=10, scale.colors=c("red","yellow","green"))
ggsave(paste0("SUPERMUN MAPS/Outputs/Changes2017-18_InstitutionalCapacity.png"))
