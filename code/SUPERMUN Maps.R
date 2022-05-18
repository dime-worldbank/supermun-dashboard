rm(list=ls())
require(ggplot2)
require(ggthemes)
require(broom)
require(grid)
require(foreign)
require(readstata13)
require(rgdal)
require(dplyr)
require(maps)
require(maptools)
require(mapdata)
require(ggmap)
require(sp)

#Set working directory
dir<-"D:/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN"
setwd(dir)

# #Read in Municipal Performance Data
# service.delivery<-read.dta13("SUPERMUN DATA/INDICATOR DATA/2018_service_delivery.dta")
# service.delivery$year<-2018
# ##--> Fix year in file name
# institutional.capacity<-read.dta13("SUPERMUN DATA/INDICATOR DATA/2018_institutional_capacity.dta") 
# institutional.capacity$year<-2018

#Read in Municipal Performance Data
#service.delivery<-read.dta13("SUPERMUN DATA/INDICATOR DATA/2017_service_delivery.dta")
#service.delivery$year<-2017
##--> Fix year in file name
#institutional.capacity<-read.dta13("SUPERMUN DATA/INDICATOR DATA/2017_institutional_capacity.dta") 
#institutional.capacity$year<-2017

#Read in Municipal Performance Data
service.delivery<-read.dta13("SUPERMUN DATA/INDICATOR DATA/2019_service_delivery.dta")
service.delivery$year<-2019
##--> Fix year in file name
institutional.capacity<-read.dta13("SUPERMUN DATA/INDICATOR DATA/2019_institutional_capacity.dta") 
institutional.capacity$year<-2019

institutional.capacity$value_staffing<-
  as.numeric(institutional.capacity$value_personnel1=="true")+
  as.numeric(institutional.capacity$value_personnel2=="true")+
  as.numeric(institutional.capacity$value_personnel3=="true")+
  as.numeric(institutional.capacity$value_personnel4=="true")+
  as.numeric(institutional.capacity$value_personnel5=="true")+
  as.numeric(institutional.capacity$value_personnel6=="true")+
  as.numeric(institutional.capacity$value_personnel7=="true")+
  as.numeric(institutional.capacity$value_personnel8=="true")

#Rename overlapping variables
institutional.capacity$total_points_ic<-institutional.capacity$total_points
institutional.capacity$stars_total_ic<-institutional.capacity$stars_total
institutional.capacity$quantile_ic[is.na(institutional.capacity$total_points_ic)==FALSE]<-rank(institutional.capacity$total_points_ic[is.na(institutional.capacity$total_points)==FALSE])/length(institutional.capacity$total_points_ic[is.na(institutional.capacity$total_points_ic)==FALSE])

service.delivery$total_points_sd<-service.delivery$total_points
service.delivery$stars_total_sd<-service.delivery$stars_total
service.delivery$quantile_sd[is.na(service.delivery$total_points_sd)==FALSE]<-rank(service.delivery$total_points_sd[is.na(service.delivery$total_points_sd)==FALSE])/length(service.delivery$total_points_sd[is.na(service.delivery$total_points_sd)==FALSE])

names(service.delivery)
dim(service.delivery)

names(institutional.capacity)
dim(institutional.capacity)

#Read in Shape Files for Map
communes<-readRDS("SUPERMUN MAPS/Shape Files/BFA_adm3.rds")
names(communes)
unique(communes$NAME_1)
unique(communes$TYPE_3)
unique(communes$VARNAME_3)
length(unique(communes$NAME_3))
length(unique(institutional.capacity$commune))
length(unique(service.delivery$commune))

provinces<-readRDS("SUPERMUN MAPS/Shape Files/BFA_adm2.rds")
regions<-readRDS("SUPERMUN MAPS/Shape Files/BFA_adm1.rds")
country<-readRDS("SUPERMUN MAPS/Shape Files/BFA_adm0.rds")
names(communes)

concordance<-read.csv("SUPERMUN MAPS/Shape Files/Commune Concordance for Shape Files 2019-02-01.csv",header=TRUE,stringsAsFactors=FALSE)
#service.delivery$commune[!(service.delivery$commune%in%intersect(concordance$commune,service.delivery$commune))]

institutional.capacity<-merge(concordance,institutional.capacity,by=c("region","commune","commune_edited"),all.x=TRUE)
names(institutional.capacity)
#institutional.capacity$tax_recovery<-institutional.capacity$tax/institutional.capacity$taxes_forecast
service.delivery<-merge(concordance,service.delivery,by=c("region","commune","commune_edited"),all.x=TRUE)
names(service.delivery)

#institutional.capacity
temp<-merge(communes@data,institutional.capacity,by=c("NAME_1","NAME_3"),all.x=TRUE)
communes@data<-temp[order(temp$ID_3),]
#plot(communes,col=as.factor(communes@data$NAME_1))

#service.delivery
temp<-merge(communes@data,service.delivery,by=c("NAME_1","NAME_3","region","province","commune","commune_edited","year"),all.x=TRUE)
communes@data<-temp[order(temp$ID_3),]

#Tidy up shape files and merge information from data slot into tidied-up dataset
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
    geom_polygon(aes(x=long,y=lat,group=group,fill=indicator.2), color="white", alpha=0.8)+
    geom_polygon(aes(x=long,y=lat,group=id),color="black",fill="NA",lwd=1,data=regions)+
    geom_text(aes(x=0, y=9.8, label="Author: Malte Lierl (German Institute of Global and Area Studies)"), color="gray60", size=2.5) + 
    theme_few()+xlab("")+ylab("")+ggtitle(paste(title," (",year,")",sep=""))+coord_equal()+
    theme(axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks.x=element_blank(),axis.ticks.y=element_blank())+
    scale_fill_gradient2(name=scale.name,limits=c(scale.min,scale.max),midpoint=scale.mid,low=scale.colors[1],mid=scale.colors[2],high=scale.colors[3])
  burkina.communes 
}

ic.pca<-princomp(~value_meetings1+value_meetings2+value_attendance_cm+value_attendance_ds+value_attendance+value_taxes_raised+value_taxes_forecast+value_procurement+value_staffing, data=institutional.capacity, na.action = na.exclude, cor = TRUE)
ic.pca$loadings
institutional.capacity$ic.pc1<-ic.pca$scores[,"Comp.1"]

sd.pca<-princomp(~scale(value_passing_exam)+scale(value_school_supplies)+scale(value_school_latrines)+scale(value_school_wells)+scale(value_assisted_births)+scale(value_vaccines)+scale(value_csps)+scale(value_water_access)+scale(value_birth_certificates),data=service.delivery, na.action = na.exclude, cor = TRUE)
sd.pca$loadings
service.delivery$sd.pc1<-sd.pca$scores[,"Comp.1"]

indicators<-merge(institutional.capacity,service.delivery,by=c("region","commune","year"))
plot.cor<-ggplot(aes(ic.pc1,sd.pc1),data=indicators[indicators$year==2017,])+
  geom_point(aes(color=region),alpha=0.5)+geom_smooth(method="lm")+
  theme_few()
plot.cor

## 2019 SUMMARY INDICATORS BY QUANTILE
y <- 2019

#Institutional capacity quantile
ic_quantile <- MakeMap(year=y,indicator="quantile_ic",title="Capacité institutionnelle",scale.name="Quantile",scale.min=0,scale.mid=0.5,scale.max=1)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_InstitutionalCapacityQuantile.png"), plot=ic_quantile, dpi=300)
rm(list="ic_quantile")

#Service delivery quantile
sd_quantile <- MakeMap(year=y,indicator="quantile_sd",title="Services publics",scale.name="Quantile",scale.min=0,scale.mid=0.5,scale.max=1)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_ServiceDeliveryQuantile.png"), plot=sd_quantile, dpi=300)
rm(list="sd_quantile")


for (y in c(2019)) {
  
  # INSTITUTIONAL CAPACITY INDICATORS
  
  #Institutional capacity score
  MakeMap(year=y,indicator="total_points_ic",title="Capacité institutionnelle",scale.name="Points",scale.min=0,scale.mid="median",scale.max=86)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_InstitutionalCapacity.png"))

  #Institutional capacity quantile
  MakeMap(year=y,indicator="quantile_ic",title="Capacité institutionnelle",scale.name="Quantile",scale.min=0,scale.mid=0.5,scale.max=1)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_InstitutionalCapacityQuantile.png"))
  
  #Municipal council meetings
  MakeMap(year=y,indicator="value_meetings1",title="Nombre de sessions ordinaires du Conseil Municipal",scale.name="Nombre",scale.min=0,scale.mid=2.5,scale.max=4)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CouncilMeetings.png"))
  
  #Cadres de concertation
  MakeMap(year=y,indicator="value_meetings2",title="Nombre de cadres de concertations",scale.name="Nombre",scale.min=0,scale.mid=2.5,scale.max=4)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CadreConcertation.png"))
  
  #Municipal council meeting attendance
  MakeMap(year=y,indicator="value_attendance",title="Taux de participation aux réunions du conseil municipal",scale.name="Pourcent",scale.min=25,scale.mid=66,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CouncilAttendance.png"))
  
  #Fiscal revenue per capita
  MakeMap(year=y,indicator="value_taxes_raised",title="Récettes fiscales par habitant",scale.name="FCFA",scale.min=0,scale.mid=10000,scale.max=20000)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_TaxRevenue.png"))
  
  #Tax recovery rate
  MakeMap(year=y,indicator="value_taxes_forecast",title="Taux de recouvrement des taxes",scale.name="Pourcentage, \nen fonction des  \nprévisions",scale.min=0,scale.max=200,scale.mid=50)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_TaxCompliance.png"))
  
  #Completion rate of procurement plan
  MakeMap(year=y,indicator="value_procurement",title="Taux d'exécution du plan de passation des marchés",scale.name="Pourcent", scale.min=0,scale.mid=60,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_ProcurementPlan.png"))
  
  #Staffed positions
  MakeMap(year=y,indicator="value_staffing",title="Personnel de la municipalité",scale.name="Nombre de \npositions de \nl'organigramme \ntype", scale.min=0,scale.mid=5,scale.max=8)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_MunicipalStaff.png"))
  
  # SERVICE DELIVERY INDICATORS
  
  #Service delivery score
  MakeMap(year=y,indicator="total_points_sd",title="Services publics",scale.name="Points",scale.min=0,scale.mid="median",scale.max=140)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_ServiceDelivery.png"))
  
  #Service delivery quantile
  MakeMap(year=y,indicator="quantile_sd",title="Services publics",scale.name="Quantile",scale.min=0,scale.mid=0.5,scale.max=1)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_ServiceDeliveryQuantile.png"))
  
  #Primary school completion
  MakeMap(year=y,indicator="value_passing_exam",title="Taux d'admission du CEP",scale.name="Ecart entre les \nrésultats de la \ncommune et la \nmoyenne nationale \n(points de %)", scale.min=min(communes.2$value_passing_exam),scale.mid=0,scale.max=max(communes.2$value_passing_exam))
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_PassingExam.png"))
  
  #School supplies 
  MakeMap(year=y,indicator="value_school_supplies",title="Retard moyen d'approvisionnement en fournitures scolaires",scale.name="Nombre de jours \naprès la \nrentrée scolaire", scale.min=0,scale.mid=30,scale.max=100,scale.colors=c("green","yellow","red"))
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_SchoolSupplies.png"))
  
  #School latrines
  MakeMap(year=y,indicator="value_school_latrines",title="Taux d'écoles avec un nombre suffisant des latrines fonctionnelles",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100,scale.colors=c("red","yellow","green"))
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_Latrines.png"))
  
  #School wells
  MakeMap(year=y,indicator="value_school_wells",title="Taux d'écoles avec un forage fonctionnel",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_SchoolWells.png"))
  
  #Assisted births
  MakeMap(year=y,indicator="value_assisted_births",title="Taux d'accouchements assistés",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_AssistedBirths.png"))
  
  #Newborn vaccination rates
  MakeMap(year=y,indicator="value_vaccines",title="Taux de nourrisons de 0-11 mois ayant reçu les vaccins recommandés",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_Vaccination.png"))
  
  #Gas supply
  MakeMap(year=y,indicator="value_csps",title="Taux de CSPS ayant reçu un stock de gaz suffisant",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CSPS.png"))
  
  #Water access
  MakeMap(year=y,indicator="value_water_access",title="Accès à une source d'eau potable à <1000m pour <300 personnes",scale.name="Pourcent de la \npopulation", scale.min=0,scale.mid=50,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_WaterAccess.png"))
  
  #Birth certificates
  MakeMap(year=y,indicator="value_birth_certificates",title="Taux d'actes de naissances délivrés",scale.name="Pourcent des \nnaissances \nattendues", scale.min=0,scale.mid=50,scale.max=100)
  ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_BirthCertificates.png"))
  
}



