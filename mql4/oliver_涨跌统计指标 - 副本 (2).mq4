//+------------------------------------------------------------------+
//|                                        deadswan_涨跌统计指标.mq4 |
//|                                      淘宝旺旺 liuxiouqian2525400 |
//|                                             http://www.waihui.ru |
//+------------------------------------------------------------------+
#property copyright "淘宝旺旺 liuxiouqian2525400"
#property link      "http://www.waihui.ru"

#property indicator_chart_window
#property indicator_buffers 3

extern string 亚洲盘始="18:00";
extern string 亚洲盘终="03:30";
extern string 欧洲盘始="03:30";
extern string 欧洲盘终="08:30";
extern string 美洲盘始="08:30";
extern string 美洲盘终="15:00";
extern double 计算天数=3;
double 亚洲盘[];
double 欧洲盘[];
double 美洲盘[];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
IndicatorBuffers(3);
SetIndexBuffer(0,亚洲盘);
SetIndexBuffer(1,欧洲盘);
SetIndexBuffer(2,美洲盘);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll();
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
if (TimeCurrent()>D'2014.02.28') //这里设定过期时间

   { 

      Alert("软件过期!请联系淘宝旺旺liuxiouqian2525400"); 

      return(0); 

   } 
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- main loop
//double k=iBarShift(NULL,30,StrToTime("2014.1.04 20:30:20"));
//Print("k:",k);
//Print("kj:",iOpen(NULL,30,k));

   for(int i=1; i<limit; i++)
   {
if(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘始)>StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终))
{
亚洲盘[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i+1],TIME_DATE)+" "+亚洲盘始))-1)
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终)));
if(iBarShift(NULL,30,StrToTime(TimeToStr(Time[i+1],TIME_DATE)+" "+亚洲盘始))-1==0
||iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终))==0
)亚洲盘[i]=88888;
if(TimeDayOfWeek(StrToTime(TimeToStr(Time[i+1],TIME_DATE)+" "+亚洲盘始))==6
||TimeDayOfWeek(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终))==0
)亚洲盘[i]=88888;
}
if(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘始)<StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终))
{   
亚洲盘[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘始))-1)
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终)));
if(iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘始))-1==0
||iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终))==0
)亚洲盘[i]=88888;
if(TimeDayOfWeek(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘始))==6
||TimeDayOfWeek(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+亚洲盘终))==0
)亚洲盘[i]=88888;

}
欧洲盘[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+欧洲盘始))-1)
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+欧洲盘终)));
if(iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+欧洲盘始))-1==0
||iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+欧洲盘终))==0
)欧洲盘[i]=88888;
if(TimeDayOfWeek(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+欧洲盘始))==6
||TimeDayOfWeek(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+欧洲盘终))==0
)欧洲盘[i]=88888;

美洲盘[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+美洲盘始))-1)
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+美洲盘终)));   
   }   
 if(iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+美洲盘始))-1==0
||iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+美洲盘终))==0
)美洲盘[i]=88888;
 if(TimeDayOfWeek(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+美洲盘始))==6
||TimeDayOfWeek(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+美洲盘终))==0
)美洲盘[i]=88888; 
int s1,s2,s3,s4,s5,s6,s7,s8;
 
   for(i=1; i<=计算天数; i++)
   {
if(亚洲盘[i]<0&&欧洲盘[i]<0&&美洲盘[i]<0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s1++;
if(亚洲盘[i]<0&&欧洲盘[i]<0&&美洲盘[i]>0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s2++;
if(亚洲盘[i]<0&&欧洲盘[i]>0&&美洲盘[i]<0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s3++;
if(亚洲盘[i]<0&&欧洲盘[i]>0&&美洲盘[i]>0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s4++;
if(亚洲盘[i]>0&&欧洲盘[i]<0&&美洲盘[i]<0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s5++;
if(亚洲盘[i]>0&&欧洲盘[i]<0&&美洲盘[i]>0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s6++;
if(亚洲盘[i]>0&&欧洲盘[i]>0&&美洲盘[i]<0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s7++;
if(亚洲盘[i]>0&&欧洲盘[i]>0&&美洲盘[i]>0&&(亚洲盘[i]!=88888&&欧洲盘[i]!=88888&&美洲盘[i]!=88888))s8++;
   } 
iDisplayInfo("s1", "亚涨欧涨美涨："+ DoubleToStr(s1,0) , 1, 20, 20, 12, "Arial", Chartreuse); 
iDisplayInfo("s2", "亚涨欧涨美跌："+ DoubleToStr(s2,0) , 1, 20, 40, 12, "Arial", Chartreuse); 
iDisplayInfo("s3", "亚涨欧跌美涨："+ DoubleToStr(s3,0) , 1, 20, 60, 12, "Arial", Chartreuse); 
iDisplayInfo("s4", "亚涨欧跌美跌："+ DoubleToStr(s4,0) , 1, 20, 80, 12, "Arial", Chartreuse); 
iDisplayInfo("s5", "亚跌欧涨美涨："+ DoubleToStr(s5,0) , 1, 20, 100, 12, "Arial", Chartreuse); 
iDisplayInfo("s6", "亚跌欧涨美跌："+ DoubleToStr(s6,0) , 1, 20, 120, 12, "Arial", Chartreuse); 
iDisplayInfo("s7", "亚跌欧跌美涨："+ DoubleToStr(s7,0) , 1, 20, 140, 12, "Arial", Chartreuse); 
iDisplayInfo("s8", "亚跌欧跌美跌："+ DoubleToStr(s8,0) , 1, 20, 160, 12, "Arial", Chartreuse); 
       
//----
   return(0);
  }
//+------------------------------------------------------------------+
void iDisplayInfo(string LableName,string LableDoc,int Corner,int LableX,int LableY,int DocSize,string DocStyle,color DocColor) 

   { 

      if (Corner == -1) return(0); 

      ObjectCreate(LableName, OBJ_LABEL, 0, 0, 0); //建立标签对象 

      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor); //定义对象属性 

      ObjectSet(LableName, OBJPROP_CORNER, Corner); //确定坐标原点0-左上角1-右上角2-左下角3-右下角-1-不显示 

      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX); //定义横坐标单位像素 

      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY); //定义纵坐标单位像素 

   } 