//+------------------------------------------------------------------+
//|                                        deadswan_’«µ¯Õ≥º∆÷∏±Í.mq4 |
//|                                      Ã‘±¶Õ˙Õ˙ liuxiouqian2525400 |
//|                                             http://www.waihui.ru |
//+------------------------------------------------------------------+
#property copyright "Ã‘±¶Õ˙Õ˙ liuxiouqian2525400"
#property link      "http://www.waihui.ru"

#property indicator_chart_window
#property indicator_buffers 3

extern string —«÷ﬁ≈Ã º="18:00";
extern string —«÷ﬁ≈Ã÷’="03:30";
extern string ≈∑÷ﬁ≈Ã º="03:30";
extern string ≈∑÷ﬁ≈Ã÷’="08:30";
extern string √¿÷ﬁ≈Ã º="08:30";
extern string √¿÷ﬁ≈Ã÷’="15:00";
extern double º∆À„ÃÏ ˝=100;
double —«÷ﬁ≈Ã[];
double ≈∑÷ﬁ≈Ã[];
double √¿÷ﬁ≈Ã[];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
IndicatorBuffers(3);
SetIndexBuffer(0,—«÷ﬁ≈Ã);
SetIndexBuffer(1,≈∑÷ﬁ≈Ã);
SetIndexBuffer(2,√¿÷ﬁ≈Ã);
   
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
if (TimeCurrent()>D'2014.02.28') //’‚¿Ô…Ë∂®π˝∆⁄ ±º‰

   { 

      Alert("»Ìº˛π˝∆⁄!«Î¡™œµÃ‘±¶Õ˙Õ˙liuxiouqian2525400"); 

      return(0); 

   } 
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- main loop
   for(int i=0; i<limit; i++)
   {
if(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+—«÷ﬁ≈Ã º)>StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+—«÷ﬁ≈Ã÷’))
—«÷ﬁ≈Ã[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i+1],TIME_DATE)+" "+—«÷ﬁ≈Ã º)))
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+—«÷ﬁ≈Ã÷’)));

if(StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+—«÷ﬁ≈Ã º)>StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+—«÷ﬁ≈Ã÷’))
   
—«÷ﬁ≈Ã[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+—«÷ﬁ≈Ã º)))
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+—«÷ﬁ≈Ã÷’)));
≈∑÷ﬁ≈Ã[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+≈∑÷ﬁ≈Ã º)))
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+≈∑÷ﬁ≈Ã÷’)));
√¿÷ﬁ≈Ã[i]=iOpen(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+√¿÷ﬁ≈Ã º)))
-iClose(NULL,30,iBarShift(NULL,30,StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+√¿÷ﬁ≈Ã÷’)));   
   }   
   
int s1,s2,s3,s4,s5,s6,s7,s8;
 
   for(i=1; i<=º∆À„ÃÏ ˝; i++)
   {
if(—«÷ﬁ≈Ã[i]>0&&≈∑÷ﬁ≈Ã[i]>0&&√¿÷ﬁ≈Ã[i]>0)s1++;
if(—«÷ﬁ≈Ã[i]>0&&≈∑÷ﬁ≈Ã[i]>0&&√¿÷ﬁ≈Ã[i]<0)s2++;
if(—«÷ﬁ≈Ã[i]>0&&≈∑÷ﬁ≈Ã[i]<0&&√¿÷ﬁ≈Ã[i]>0)s3++;
if(—«÷ﬁ≈Ã[i]>0&&≈∑÷ﬁ≈Ã[i]<0&&√¿÷ﬁ≈Ã[i]<0)s4++;
if(—«÷ﬁ≈Ã[i]<0&&≈∑÷ﬁ≈Ã[i]>0&&√¿÷ﬁ≈Ã[i]>0)s5++;
if(—«÷ﬁ≈Ã[i]<0&&≈∑÷ﬁ≈Ã[i]>0&&√¿÷ﬁ≈Ã[i]<0)s6++;
if(—«÷ﬁ≈Ã[i]<0&&≈∑÷ﬁ≈Ã[i]<0&&√¿÷ﬁ≈Ã[i]>0)s7++;
if(—«÷ﬁ≈Ã[i]<0&&≈∑÷ﬁ≈Ã[i]<0&&√¿÷ﬁ≈Ã[i]<0)s8++;
   } 
iDisplayInfo("s1", "—«’«≈∑’«√¿’«£∫"+ DoubleToStr(s1,0) , 1, 20, 20, 12, "Arial", Chartreuse); 
iDisplayInfo("s2", "—«’«≈∑’«√¿µ¯£∫"+ DoubleToStr(s2,0) , 1, 20, 40, 12, "Arial", Chartreuse); 
iDisplayInfo("s3", "—«’«≈∑µ¯√¿’«£∫"+ DoubleToStr(s3,0) , 1, 20, 60, 12, "Arial", Chartreuse); 
iDisplayInfo("s4", "—«’«≈∑µ¯√¿µ¯£∫"+ DoubleToStr(s4,0) , 1, 20, 80, 12, "Arial", Chartreuse); 
iDisplayInfo("s5", "—«µ¯≈∑’«√¿’«£∫"+ DoubleToStr(s5,0) , 1, 20, 100, 12, "Arial", Chartreuse); 
iDisplayInfo("s6", "—«µ¯≈∑’«√¿µ¯£∫"+ DoubleToStr(s6,0) , 1, 20, 120, 12, "Arial", Chartreuse); 
iDisplayInfo("s7", "—«µ¯≈∑µ¯√¿’«£∫"+ DoubleToStr(s7,0) , 1, 20, 140, 12, "Arial", Chartreuse); 
iDisplayInfo("s8", "—«µ¯≈∑µ¯√¿µ¯£∫"+ DoubleToStr(s8,0) , 1, 20, 160, 12, "Arial", Chartreuse); 
       
//----
   return(0);
  }
//+------------------------------------------------------------------+
void iDisplayInfo(string LableName,string LableDoc,int Corner,int LableX,int LableY,int DocSize,string DocStyle,color DocColor) 

   { 

      if (Corner == -1) return(0); 

      ObjectCreate(LableName, OBJ_LABEL, 0, 0, 0); //Ω®¡¢±Í«©∂‘œÛ 

      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor); //∂®“Â∂‘œÛ Ù–‘ 

      ObjectSet(LableName, OBJPROP_CORNER, Corner); //»∑∂®◊¯±Í‘≠µ„™®0-◊Û…œΩ«™®1-”“…œΩ«™®2-◊Ûœ¬Ω«™®3-”“œ¬Ω«™®-1-≤ªœ‘ æ 

      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX); //∂®“Â∫·◊¯±Í™®µ•ŒªœÒÀÿ 

      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY); //∂®“Â◊›◊¯±Í™®µ•ŒªœÒÀÿ 

   } 