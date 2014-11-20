//+------------------------------------------------------------------+
//|                                            deadswan_价格指标.mq4 |
//|                                      淘宝旺旺 liuxiaoqian2525400 |
//|                                             http://www.waihui.ru |
//+------------------------------------------------------------------+
#property copyright "淘宝旺旺 liuxiaoqian2525400"
#property link      "http://www.waihui.ru"

#property indicator_chart_window
extern string 计算时间="2013.03.10 20:30:20";
double jiage;
int sj;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
if(TimeLocal()<StrToTime(计算时间))sj=1;
if(TimeLocal()>=StrToTime(计算时间))sj=0;

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
if(sj==0)jiage=Open[0];
if(sj==1&&TimeLocal()<StrToTime(计算时间)){ jiage=Open[0];}

if(sj==1&&TimeLocal()>=StrToTime(计算时间)){ jiage=Close[0]; sj=2;}
if(jiage!=0&&Close[0]>=jiage) 
iDisplayInfo("jgc", DoubleToStr((MathAbs((Close[0]-jiage))/Point)/100,3), 0, 30, 30, 60, "微软雅黑", Red); 
if(jiage!=0&&Close[0]<jiage) 
iDisplayInfo("jgc", DoubleToStr((MathAbs((Close[0]-jiage))/Point)/100,3), 0, 30, 30, 60, "微软雅黑", Green); 
Print("jiage");
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