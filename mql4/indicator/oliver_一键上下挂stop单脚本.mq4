//+------------------------------------------------------------------+
//|                                deadswan_一键上下挂STOP单脚本.mq4 |
//|                                      淘宝旺旺 liuxiaoqian2525400 |
//|                                             http://www.waihui.ru |
//+------------------------------------------------------------------+
#property copyright "淘宝旺旺 liuxiaoqian2525400"
#property link      "http://www.waihui.ru"
#property show_inputs
double 开仓价格=0;
extern bool 是否挂buystop=true;
extern bool 是否挂sellstop=true;
extern double 第一单与现价距离=200;
extern double 间隔点数=250;
extern int 下单数量=1;
extern double 每单手数=0.5;
extern int 止损点数=400;
extern int 止盈点数=700;
extern int 滑点偏移点数=10;
string 注释="赢家外汇论坛 www.yingjia.im QQ:29996044";
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
  if (TimeCurrent()>D'2014.02.10') //这里设定过期时间

   { 

      Alert("软件过期!请联系淘宝旺旺liuxiouqian2525400"); 

      return(0); 

   } 

  int Ticket;
  int Ticket1;
  if(开仓价格==0){开仓价格=Close[0];}
  for(int i=0;i<=下单数量-1;i++){
  double 挂多价格=开仓价格+第一单与现价距离*Point+间隔点数*Point*i;
  double 挂空价格=开仓价格-第一单与现价距离*Point-间隔点数*Point*i;
  if(是否挂buystop){
  Ticket=OrderSend(Symbol(),OP_BUYSTOP,每单手数,挂多价格,滑点偏移点数,挂多价格-止损点数*Point,挂多价格+止盈点数*Point,注释,0,0,0);
      if(Ticket<0)
      {
      Print("挂多单入场失败"+GetLastError()); 
      }}
  if(是否挂sellstop){
  Ticket1=OrderSend(Symbol(),OP_SELLSTOP,每单手数,挂空价格,滑点偏移点数,挂空价格+止损点数*Point,挂空价格-止盈点数*Point,注释,0,0,0); 
      if(Ticket1<0)
     {
     Print("挂空单入场失败"+GetLastError()); 
     }}
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

