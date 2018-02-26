install.packages('foreign')
install.packages('dplyr')
install.packages('ggplot2')
install.packages('readxl')
install.packages('plotly')
install.packages('dygraphs')
install.packages('xts')
install.packages('corrplot')

library(foreign)
library(dplyr)
library(ggplot2)
library(readxl)
library(plotly)
library(dygraphs)
library(xts)
library(corrplot)

setwd('c:\\easy_r')
dataset<-read.csv('useage_2016_gwanakgu.csv')

df_dataset <-data.frame(date=dataset$date,
                        day=dataset$day,
                        useage=dataset$useage)
df_dataset$day<- as.character(df_dataset$day)
df_dataset$date<- as.Date(df_dataset$date)
head(df_dataset)


##01 relationship between day and useage  -���Ϻ��� �̿���� �Ǽ��� ���̰� �ִ°�?
#����ġ Ȯ��
#table(is.na(df_dataset$day))
#table(is.na(df_dataset$useage))
#���Ϻ� �̿����
df_day_useage<- df_dataset %>% 
  group_by(day) %>% 
  summarise(mean_useage= mean(useage, na.rm=T))
df_day_useage
#���Ϻ� HISTOGRAM
g_1<- ggplot(data=df_day_useage, aes(x=day, y=mean_useage, fill=day))+ 
  geom_col()+
  scale_x_discrete(limits= c('��','ȭ','��','��','��','��','��'))+
  scale_fill_discrete(limits= c('��','ȭ','��','��','��','��','��'))
g_1
ggplotly(g_1)


##02 relationship between date and useage  - �ð��� ���� �̿���� ���̰� �ִ°�?
#����ġ ����
df_date_useage <- df_dataset %>% 
  filter(!is.na(useage))
df_date_useage
#������ �ð迭�׷���
g_2<- ggplot(data=df_date_useage, aes(x=date, y=useage))+
  geom_point()+
  geom_line()+
  ylim(0,100)
g_2
ggplotly(g_2)




##03 relationship between weather and useage  -�ְ���¿� ���� �̿���� ���̰� �ִ°�?
#rename the variable of weather data 
weather <- read.csv('wether_2016_seoul.csv')  #2017��, ���������� 2016�⵵ ����
weather<- rename(weather,
                 date=��¥,
                 avg_tem=��ձ��,
                 highest_tem=�ְ����,
                 lowest_tem=�������,
                 avg_cloud=��տ,
                 daily_rain=�ϰ�����)
names(weather)

#join the dataset and weather by date
df_weather<- data.frame(date=weather$date,
                        avg_tem=weather$avg_tem,
                        highest_tem=weather$highest_tem,
                        lowest_tem=weather$lowest_tem) 
head(df_weather)
tail(df_weather)

df_weather$date<- as.Date(df_weather$date)
head(df_weather)
tail(df_weather)


df_weather$avg_tem<- as.character(df_weather$avg_tem)
df_weather$highest_tem<- as.character(df_weather$highest_tem)
df_weather$lowest_tem<- as.character(df_weather$lowest_tem)


class(df_weather$date)


#�� ��ȣ ����
#for-loop �� ������¡...?
fuc<- function(x){
  sub('\\��', '', x)
}
a<-df_weather$avg_tem
b<-df_weather$highest_tem
c<-df_weather$lowest_tem
df_weather$avg_tem<- fuc(a)
df_weather$highest_tem<- fuc(b)
df_weather$lowest_tem<- fuc(c)

df_weather$avg_tem<- as.numeric(df_weather$avg_tem)
df_weather$highest_tem<- as.numeric(df_weather$highest_tem)
df_weather$lowest_tem<- as.numeric(df_weather$lowest_tem)

df_weather


#all_dataset
df_all_dataset<- left_join(df_dataset, df_weather, by='date')
#names(df_all_dataset)
#head(df_all_dataset)
#tail(df_all_dataset)


#relationship between date and highest_tem
df_date_highest_tem <- df_all_dataset %>% 
  select(date, highest_tem)
df_date_highest_tem

g_3<- ggplot(data=df_date_highest_tem, aes(x=date, y=highest_tem))+
  geom_line()+
  ylim(-20,40)
g_3
ggplotly(g_3)


#relationship between date and lowest_tem
df_date_lowest_tem<- df_all_dataset %>% 
  select(date, lowest_tem)
df_date_lowest_tem

g_4<- ggplot(data=df_date_lowest_tem, aes(x=date, y=lowest_tem))+
  geom_line()+
  ylim(-20,40)
g_4
ggplotly(g_4)



#���� �� ǥ���ϱ� page 296 
#�ð迭�׷��� - ��ձ��, �ְ����, �������
daavg <- xts(df_all_dataset$avg_tem, order.by=df_all_dataset$date)
dahigh <- xts(df_all_dataset$highest_tem, order.by=df_all_dataset$date)
dalow <- xts(df_all_dataset$lowest_tem, order.by=df_all_dataset$date)
dabind <- cbind(daavg, dahigh, dalow)
colnames(dabind) <- c('��ձ��','�ְ����','�������')
head(dabind)
g_5 <- dygraph(dabind) %>% dyRangeSelector()
g_5
#result 
#trend ����


###############������ ���� ������ ��#############
#Correlation Analysis 
# between useage and avgerage temperature 
test_df_all_dataset <- df_all_dataset %>% 
  select(useage, avg_tem) %>% 
  filter(!is.na(useage))
test_df_all_dataset$useage<- as.numeric(test_df_all_dataset$useage)
head(test_df_all_dataset)

cor.test(test_df_all_dataset$useage, test_df_all_dataset$avg_tem)
#result 
#p-value < 0.05,  �̿������ ����� ����� ��������� �����ϴ� (�ΰ�X)
#cor 0.433951  .....��...trend �����ϱ� ����
#      ��º� Ȥ�� ������ ���ָ� �ΰ� �м��ϴ°��� �� ���ǹ���

df_num_dataset <- df_all_dataset %>% 
  select(useage,  highest_tem, lowest_tem) %>% 
  filter(!is.na(useage))
cor_1 <- cor(df_num_dataset)
round(cor_1, 3)
corrplot(cor_1)

##remove the trend 
##�õ� seasonality, trend, random ��ҷ� �����ؼ� �׸���

try <- df_all_dataset %>% 
  select(date, useage, avg_tem) %>% 
  filter(!is.na(useage))
head(try)
plot(try, s.window = 'date')

#��¿� ���� �������� �ٸ���?
out=lm(useage~avg_tem, try)
summary(out)
plot(useage~avg_tem, try)
abline(out, col='red')
g_6 <- ggplot(data=try,aes(x=avg_tem,y=useage))+
  geom_count()+
  geom_smooth(method="lm")
g_6
ggplotly(g_6)
#################################################



#weather temperature 5���� ���� ����, 
#categorise the temperature variable in weaterdataset 
#           to cold, cool, mild, hot 
df_all_dataset <- df_all_dataset %>% 
  mutate(Tem = ifelse(avg_tem <0 , 'cold',
                      ifelse(avg_tem <=15, 'cool',
                             ifelse(avg_tem <=25 ,'mild','hot'))))
head(df_all_dataset)
table(df_all_dataset$Tem)

df_Tem_useage<-df_all_dataset %>%
  filter(!is.na(useage)) %>% 
  group_by(Tem) %>% 
  summarise(sum_useage=sum(useage))

df_Tem_useage
g_7<- ggplot(data= df_Tem_useage, aes(x=Tem, y=sum_useage))+
  geom_col()+
  scale_x_discrete(limits= c('cold', 'cool','mild','hot'))

g_7
ggplotly(g_7)

#Tem �� useage �׸���
df_Tem_useage$cold
