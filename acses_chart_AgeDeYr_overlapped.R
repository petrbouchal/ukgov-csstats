library(plyr)
library(pbtools)
source('./lib/lib_acses.R')
if (!batchproduce) {
  whitehallonly <- TRUE # uncomment line to override global WH-only set in lib
}

# Load data ---------------------------------------------------------------

filename <- 'ACSES_Gender_Dept_Age_Grade_data.tsv'
origdata <- LoadAcsesData(filename,location)

# PROCESS DATA
uu <- origdata %>%
  filter(Gender=='Total' & Civil.Service.grad=='Total' & Wage.band=='Total') %>%
  filter(Date=='2010' | Date=='2013') %>%
  AddOrgData(whitehallonly) %>%
  select(Age.band,Group,count,Whitehall,Managed,Include,Date) %>%
  filter(Age.band!='Total') %>%
  group_by(Group, Date) %>%
  mutate(total=sum(count, na.rm=TRUE)) %>%
  ungroup() %>%
  RelabelAgebands() %>%
  group_by(Group,Date, Age.band) %>%
  summarise(count=sum(count,na.rm=TRUE), total=mean(total,na.rm=TRUE)) %>%
  filter(Age.band!='Unknown age') %>%
  mutate(share=count/total) %>%
  ungroup() %>%
  mutate(Age.band = factor(Age.band))

# CREATE WHITEHALL TOTAL IF NEEDED
if(whitehallonly) {
  whtotal <- uu %>% 
    group_by(Date,Age.band) %>%
    filter(Group!='Whole Civil Service') %>%
    summarise(count=sum(count),total=sum(total), share=count/total) %>%
    mutate(Group = 'Whitehall')
  uu <- rbind(uu[uu$Group!='Whole Civil Service',],whtotal)
}

# Sort departments --------------------------------------------------------
gradevalues <- data.frame('gradeval'=c(1:length(levels(as.factor(uu$Age.band)))),
                          'Age.band'=levels(as.factor(uu$Age.band)))
uu <- uu %>%
  merge(gradevalues) %>%
  group_by(Group, Date, Age.band) %>%
  mutate(sorter=sum(share)) %>% # sum both genders withing age bands
  group_by(Group) %>%
  mutate(sorter=sum(sorter[Date==2013]*gradeval)) %>%
  ungroup() %>%
  mutate(Group=reorder(Group,sorter,mean),
         totalgroup = ifelse(Group=='Whole Civil Service' | Group=='Whitehall', 
                             TRUE, FALSE)) %>%
  arrange(Group, Age.band, Date)

# Build plot --------------------------------------------------------------

# create left and right data
uu$share2 <- uu$share/2
uu$left <- TRUE
uu2 <- uu
uu2$share2 <- -uu2$share/2
uu2$left <- FALSE

uu <- rbind(uu,uu2)
uu$grp <- paste0(uu$left, uu$Date)
uu <- arrange(uu, Group, grp)

plotname <- 'plot_AgeDeYr_overlapped'

HLcol <- ifelse(whitehallonly,ifgcolours[2,1],ifgcolours[4,1])

plottitle <- 'Civil Servants by gender and age'
xlabel='Age group (years)'
ylabel='ordered by age composition of staff (youngest workforce first)'
if(whitehallonly){
  plottitle=paste0(plottitle,' - Whitehall departments')
  ylabel=paste0('% of Civil Servants in age group. Whitehall departments ',ylabel)
  plotname=paste0(plotname,'_WH')
} else {
  plottitle=paste0(plottitle,' - departmental groups')
  ylabel=paste0('% of Civil Servants in age group. Departmental groups ',ylabel)
  plotname=paste0(plotname,'_Group')
}

uu$yvar <- uu$share2

maxY <- max(abs(uu$yvar),na.rm=FALSE)
ylimits <- c(-maxY*1.04, maxY*1.04)
ybreaks <- c(-.3,-.15,0,.15,.3)
ylabels <- paste0(abs(ybreaks*100),'%')

loadcustomthemes(ifgcolours, 'Calibri')
plot_AgeDeGe <- ggplot(uu, aes(x=Age.band, y=yvar, group=grp)) +
#   geom_rect(data = uu[uu$totalgroup,],fill=HLcol,xmin = -Inf,xmax = Inf,
#             ymin = -Inf,ymax = Inf,alpha = .05) +
  geom_rect(data = uu[uu$totalgroup,],colour=HLcol,xmin = -Inf,xmax = Inf,
            ymin = -Inf,ymax = Inf,alpha = 1,fill=NA,size=1) +
  geom_area(position='identity', width=1, aes(fill='col1'),stat='identity',
           data=uu[uu$Date==2010,]) +
  geom_area(position='identity', width=1, aes(fill='col2'),stat='identity',
           data=uu[uu$Date==2013,], alpha=0.3) +
  scale_fill_manual(values=c('col1'=ifgcolours[5,2],'col2'=ifgcolours[3,1]),
                    labels=c('2010', '2013')) +
  geom_text(data=uu[uu$grp=='TRUE2010' & uu$Age.band=='65 +',],
            aes(label=Group), colour='white',x=3,y=0, fontface='bold') +
  guides(col=guide_legend(ncol=3)) +
  scale_y_continuous(labels=ylabels,breaks=ybreaks,limits=ylimits) +
  scale_x_discrete(expand=c(0,0)) +
  facet_wrap(~Group, nrow=3) +
  ggtitle(plottitle) +
  coord_flip() +
  labs(y=ylabel,x=xlabel,title=NULL) +
  theme(panel.border=element_rect(fill=NA,color=NA,size=.5),
        axis.ticks.y=element_blank(),panel.grid=element_blank(),
        axis.title.x=element_text(),axis.title.y=element_text(angle=90),
        strip.text=element_blank(),
        legend.key.width=unit(.2,'cm'),legend.key.height=unit(.2,'cm'),
        axis.text = element_text(colour=ifgbasecolours[1]),
        strip.text=element_text(size=12),
        legend.text=element_text(size=12))
plot_AgeDeGe

# Save plot ---------------------------------------------------------------

saveplot(plotname=plotname,plotformat='pdf',ploth=10.5,plotw=17.5,
         ffamily=fontfamily, plotdir='./charts-output/',dpi=300)
