rm(list=ls())
require(ggplot2)
require(ggthemes)
require(readstata13)

#Set working directory
dir<-"C:/Users/admin/Box Sync/RESEARCH/Burkina Baseline Experiments/SUPERMUN"
setwd(dir)

#Read outcome data
ic.2014<-read.dta13("SUPERMUN DATA/2014_institutional_capacity.dta")
sd.2014<-read.dta13("SUPERMUN DATA/2014_service_delivery.dta")
ic.2014$year<-2014
sd.2014$year<-2014
sd.2014$commune_edited[sd.2014$commune_edited=="NOBÉRÉ"]<-"NOBERE"
sd.2014$commune_edited[sd.2014$commune_edited=="ZINIARÉ"]<-"ZINIARE"


ic.2015<-read.dta13("SUPERMUN DATA/2015_institutional_capacity.dta")
sd.2015<-read.dta13("SUPERMUN DATA/2015_service_delivery.dta")
ic.2015$year<-2015
sd.2015$year<-2015

ic.2016<-read.dta13("SUPERMUN DATA/2016_institutional_capacity.dta")
sd.2016<-read.dta13("SUPERMUN DATA/2016_service_delivery.dta")
ic.2016$year<-2016
sd.2016$year<-2016

ic.2017<-read.dta13("SUPERMUN DATA/2017_institutional_capacity.dta")
sd.2017<-read.dta13("SUPERMUN DATA/2017_service_delivery.dta")
ic.2017$year<-2017
sd.2017$year<-2017

ic.2018<-read.dta13("SUPERMUN DATA/2018_institutional_capacity.dta") 
sd.2018<-read.dta13("SUPERMUN DATA/2018_service_delivery.dta")
ic.2018$year<-2018
sd.2018$year<-2018

#Placeholder variable for personnel indicator (only scores are displayed)
ic.2014$value_personnel<-""
ic.2015$value_personnel<-""
ic.2016$value_personnel<-""
ic.2017$value_personnel<-""
ic.2018$value_personnel<-""


#Construct panel
varnames.ic<-intersect(names(ic.2014),names(ic.2015))
varnames.ic<-intersect(varnames.ic,names(ic.2016))
varnames.ic<-intersect(varnames.ic,names(ic.2017))
varnames.ic<-intersect(varnames.ic,names(ic.2018))
ic<-rbind(ic.2014[,varnames.ic],ic.2015[,varnames.ic],ic.2016[,varnames.ic],ic.2017[,varnames.ic],ic.2018[,varnames.ic])
varnames.sd<-intersect(names(sd.2014),names(sd.2015))
varnames.sd<-intersect(varnames.sd,names(sd.2016))
varnames.sd<-intersect(varnames.sd,names(sd.2017))
varnames.sd<-intersect(varnames.sd,names(sd.2018))
sd<-rbind(sd.2014[,varnames.sd],sd.2015[,varnames.sd],sd.2016[,varnames.sd],sd.2017[,varnames.sd],sd.2018[,varnames.sd])



ic$value_staffing<-
  as.numeric(ic$value_personnel1=="true")+
  as.numeric(ic$value_personnel2=="true")+
  as.numeric(ic$value_personnel3=="true")+
  as.numeric(ic$value_personnel4=="true")+
  as.numeric(ic$value_personnel5=="true")+
  as.numeric(ic$value_personnel6=="true")+
  as.numeric(ic$value_personnel7=="true")+
  as.numeric(ic$value_personnel8=="true")

#Rename overlapping variables
ic$total_points_ic<-ic$total_points
ic$stars_total_ic<-ic$stars_total
sd$total_points_sd<-sd$total_points
sd$stars_total_sd<-sd$stars_total


##FUNCTION TO MAKE TREND CHART

TrendChart<-function(data, region, commune, indicator, unit="[insert axis label]", title="[insert chart title]") {

  #Parse indicator name
  #indicator.2 <- ic$eval(parse(text=indicator))
  x=data[data$region==data$region & data$commune==commune, "year"]
  y=data[data$region==data$region & data$commune==commune, indicator]
  
  #Make trend chart
  trend.chart <- ggplot(aes(x=x, y=y),data=data.frame(x,y))+
    geom_line(size=2,color="darkorange2")+
    geom_point(size=3,color="darkorange2")+
    theme_few()+xlab("")+ylab(unit)+ggtitle(title)
    #theme(axis.text.x=element_blank(),axis.text.y=element_blank())
  trend.chart 
}

for (r in unique(ic$region)) {
  for (c in unique(ic$commune[ic$region==r])) {
    TrendChart(data=ic, region=r, commune=c, indicator="value_procurement", title="Taux d'exécution du plan de passation des marchés")
    ggsave(paste0("SUPERMUN GRAPHS/Trend Charts/",r,"_",c,"_","value_procurement",".png"))
  }
}


# INSTITUTIONAL CAPACITY INDICATORS

#Institutional capacity score
TrendChart(year=y,indicator="total_points_ic",title="Capacité institutionnelle",scale.name="Points",scale.min=0,scale.mid="median",scale.max=86)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_InstitutionalCapacity.png"))

#Municipal council meetings
TrendChart(year=y,indicator="value_meetings1",title="Nombre de sessions ordinaires du Conseil Municipal",scale.name="Nombre",scale.min=0,scale.mid=2.5,scale.max=4)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CouncilMeetings.png"))

#Cadres de concertation
TrendChart(year=y,indicator="value_meetings2",title="Nombre de cadres de concertations",scale.name="Nombre",scale.min=0,scale.mid=2.5,scale.max=4)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CadreConcertation.png"))

#Municipal council meeting attendance
TrendChart(year=y,indicator="value_attendance",title="Taux de participation aux réunions du conseil municipal",scale.name="Pourcent",scale.min=25,scale.mid=66,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CouncilAttendance.png"))

#Fiscal revenue per capita
TrendChart(year=y,indicator="value_taxes_raised",title="Récettes fiscales par habitant",scale.name="FCFA",scale.min=0,scale.mid=10000,scale.max=20000)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_TaxRevenue.png"))

#Tax recovery rate
TrendChart(year=y,indicator="value_taxes_forecast",title="Taux de recouvrement des taxes",scale.name="Pourcentage, \nen fonction des  \nprévisions",scale.min=0,scale.max=200,scale.mid=50)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_TaxCompliance.png"))

#Completion rate of procurement plan
TrendChart(year=y,indicator="value_procurement",title="Taux d'exécution du plan de passation des marchés",scale.name="Pourcent", scale.min=0,scale.mid=60,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_ProcurementPlan.png"))

#Staffed positions
TrendChart(year=y,indicator="value_staffing",title="Personnel de la municipalité",scale.name="Nombre de \npositions de \nl'organigramme \ntype", scale.min=0,scale.mid=5,scale.max=8)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_MunicipalStaff.png"))

# SERVICE DELIVERY INDICATORS

#Service delivery score
TrendChart(year=y,indicator="total_points_sd",title="Services publics",scale.name="Points",scale.min=0,scale.mid="median",scale.max=140)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_ServiceDelivery.png"))

#Primary school completion
TrendChart(year=y,indicator="value_passing_exam",title="Taux d'admission du CEP",scale.name="Ecart entre les \nrésultats de la \ncommune et la \nmoyenne nationale \n(points de %)", scale.min=min(communes.2$value_passing_exam),scale.mid=0,scale.max=max(communes.2$value_passing_exam))
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_PassingExam.png"))

#School supplies 
TrendChart(year=y,indicator="value_school_supplies",title="Retard moyen d'approvisionnement en fournitures scolaires",scale.name="Nombre de jours \naprès la \nrentrée scolaire", scale.min=0,scale.mid=30,scale.max=100,scale.colors=c("green","yellow","red"))
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_SchoolSupplies.png"))

#School latrines
TrendChart(year=y,indicator="value_school_latrines",title="Taux d'écoles avec un nombre suffisant des latrines fonctionnelles",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100,scale.colors=c("red","yellow","green"))
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_Latrines.png"))

#School wells
TrendChart(year=y,indicator="value_school_wells",title="Taux d'écoles avec un forage fonctionnel",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_SchoolWells.png"))

#Assisted births
TrendChart(year=y,indicator="value_assisted_births",title="Taux d'accouchements assistés",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_AssistedBirths.png"))

#Newborn vaccination rates
TrendChart(year=y,indicator="value_vaccines",title="Taux de nourrisons de 0-11 mois ayant reçu les vaccins recommandés",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_Vaccination.png"))

#Gas supply
TrendChart(year=y,indicator="value_csps",title="Taux de CSPS ayant reçu un stock de gaz suffisant",scale.name="Pourcent", scale.min=0,scale.mid=50,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_CSPS.png"))

#Water access
TrendChart(year=y,indicator="value_water_access",title="Accès à une source d'eau potable à <1000m pour <300 personnes",scale.name="Pourcent de la \npopulation", scale.min=0,scale.mid=50,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_WaterAccess.png"))

#Birth certificates
TrendChart(year=y,indicator="value_birth_certificates",title="Taux d'actes de naissances délivrés",scale.name="Pourcent des \nnaissances \nattendues", scale.min=0,scale.mid=50,scale.max=100)
ggsave(paste0("SUPERMUN MAPS/Outputs/",y,"_BirthCertificates.png"))

