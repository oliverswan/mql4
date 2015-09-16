//+------------------------------------------------------------------+
//|                                      deadswan_修改挂单距离EA.mq4 |
//|                                      淘宝旺旺 liuxiaoqian2525400 |
//|                                             http://www.waihui.ru |
//+------------------------------------------------------------------+
#property copyright "淘宝旺旺 liuxiaoqian2525400"
#property link      "http://www.waihui.ru"
extern int 时间选择=2;
extern string 时间选择解释="1为平台时间，2为电脑时间";
extern int 停止时间时=12;
extern int 停止时间分=34;
extern int 停止时间秒=18;
extern double 挂单距离=500;
int sj;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
if (TimeCurrent()>D'2019.01.31') //这里设定过期时间

   { 

      Alert("软件过期!请联系淘宝旺旺liuxiouqian2525400"); 

      return(0); 

   } 
if(修改时间())修改挂单();
//----
   return(0);
  }
//+------------------------------------------------------------------+
void 修改挂单()
{
 int cnt, total;
 total=OrdersTotal();
 for(cnt=total-1;cnt>=0;cnt--)
  {
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUYLIMIT&&OrderSymbol()==Symbol()){
      double zhisun=OrderOpenPrice()-OrderStopLoss();
      double zhiying=OrderTakeProfit()-OrderOpenPrice();
bool chenggong= OrderModify(OrderTicket(),Close[0]-挂单距离*Point,Close[0]-zhisun-挂单距离*Point,Close[0]-挂单距离*Point+zhiying,0,CLR_NONE);
       if (chenggong)Print("单号："+OrderTicket()+"修改挂单成功");
       if (chenggong==false)Print("单号："+OrderTicket()+"修改挂单失败"+GetLastError());
      }
      if(OrderType()==OP_SELLSTOP&&OrderSymbol()==Symbol()){
      zhisun=OrderStopLoss()-OrderOpenPrice();
      zhiying=OrderOpenPrice()-OrderTakeProfit();
      chenggong= OrderModify(OrderTicket(),Close[0]-挂单距离*Point,Close[0]+zhisun-挂单距离*Point,Close[0]-挂单距离*Point-zhiying,0,CLR_NONE);
       if (chenggong)Print("单号："+OrderTicket()+"修改挂单成功");
       if (chenggong==false)Print("单号："+OrderTicket()+"修改挂单失败"+GetLastError());
      }
      
      if(OrderType()==OP_BUYSTOP&&OrderSymbol()==Symbol()){
      zhisun=OrderOpenPrice()-OrderStopLoss();
       zhiying=OrderTakeProfit()-OrderOpenPrice();
       chenggong= OrderModify(OrderTicket(),Close[0]+挂单距离*Point,Close[0]-zhisun+挂单距离*Point,Close[0]+挂单距离*Point+zhiying,0,CLR_NONE);
       if (chenggong)Print("单号："+OrderTicket()+"修改挂单成功");
       if (chenggong==false)Print("单号："+OrderTicket()+"修改挂单失败"+GetLastError());
      }
      if(OrderType()==OP_SELLLIMIT&&OrderSymbol()==Symbol()){
      zhisun=OrderStopLoss()-OrderOpenPrice();
      zhiying=OrderOpenPrice()-OrderTakeProfit();
      chenggong= OrderModify(OrderTicket(),Close[0]+挂单距离*Point,Close[0]+zhisun+挂单距离*Point,Close[0]+挂单距离*Point-zhiying,0,CLR_NONE);
       if (chenggong)Print("单号："+OrderTicket()+"修改挂单成功");
       if (chenggong==false)Print("单号："+OrderTicket()+"修改挂单失败"+GetLastError());
      }
      
      
   }   
}
bool 修改时间()
{
if(时间选择==1&&Hour()==停止时间时&&Minute()==停止时间分&&Seconds()>=停止时间秒)
{
return(false);
}
if(时间选择==1&&Hour()==停止时间时&&Minute()>停止时间分)
{
return(false);
}
if(时间选择==1&&Hour()>停止时间时)
{
return(false);
}
if(时间选择==2&&TimeHour(TimeLocal())==停止时间时&&TimeMinute(TimeLocal())==停止时间分&&TimeSeconds(TimeLocal())>=停止时间秒)
{
return(false);
}
if(时间选择==2&&TimeHour(TimeLocal())==停止时间时&&TimeMinute(TimeLocal())>停止时间分)
{
return(false);
}
if(时间选择==2&&TimeHour(TimeLocal())>停止时间时)
{
return(false);
}
else return(true);
}