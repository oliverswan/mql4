//+------------------------------------------------------------------+
//|                                                   GlobalInfo.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


#include <oliver_drawing.mqh>
#include <oliver_customIndicator.mqh>
#include <GlobalInfo.mqh>

#define MAGICMA  20150925

class DecisionMaker {

public:

   GlobalInfo *g;
   
   void DecisionMaker(){
      optype =0;
   }
   
   
   void makeDecision()
   {
      doOrder = false;
      doLong = false;
      doShort = false;
      
      // g.lot1 = (AccountBalance()-MathMod(AccountBalance(), 10000) )/10000;
      // 首先判断持仓
       if(CalculateCurrentOrders(Symbol())==0)
         CheckForOpen();   // start working
       else
         CheckForClose();  // otherwise, close positions
   }
   
private:
   int  c1;
   int  c2;
   int  c3;
   double SL,TP;
   int optype;// 0,1,2
   bool doLong;
   bool doShort;
   bool doOrder;
   int lastOrderReason; // 1=377,2=cross
   int useSL;
   int useTP;
   
   // TODO 这里会不会出现覆盖不满的情况
   // 这里只管开仓，不管平仓
   void determin()
   {
      //bool orderCondition = true;
      // 检查上一个单子
      /*
      int his = OrdersHistoryTotal();
      
      for(int k =his;k>0;k--)
      {
         if(OrderSelect(k,SELECT_BY_POS,MODE_HISTORY)==true)
         {
            if(OrderMagicNumber() == MAGICMA)
            {
               datetime dt = OrderCloseTime();
               int sf = iBarShift(Symbol(),g.mainTF,dt);
               if(sf<=10)
               {
                  retun;
               }
            }
         }
      }*/

      double p377  = iMA(Symbol(),g.mainTF,g.slowMASlow,0,MODE_EMA,PRICE_CLOSE,0);

      int SmaSlowPoint = MathAbs(Bid-377)/Point;
            
      useSL = g.stoplose;
      useTP = g.takeprofile;
      
      // ********做多********      
      bool l1 = g.mMaStatus == UPCROSS&&!g.nearSmaSlow;// &&g.farSMaFast&&g.sMaStatus == DOWNRUNNING &&g.mMaCrossEffect
            
      // 377，在上部运行，MA12在MA377上方
      bool l3 = g.nearSmaSlow&&(g.sMaStatus == UPCROSS || g.sMaStatus == UPRUNNING)&&g.mainUpSlow&&g.mMaStatus == UPRUNNING && lastOrderReason!=1;// &&g.rsi<25
      
      // 多头排列
      bool l4 = g.dis_betweenMMA >= 200&& MathAbs(g.dis_betweenMMA_before)<50&&lastOrderReason!=5&&!g.nearSmaSlow&&g.rsi_day<70;//&&(g.sMaStatus == UPCROSS || g.sMaStatus == UPRUNNING)
      
      
      if(l3&&!l1&&!l4){
         lastOrderReason = 1;
         useSL = g.stoplose/2;
         useTP = 1000;
      }
      if(l1)  lastOrderReason = 2;
      if(l1&&l3)lastOrderReason = 4;
      if(l4) lastOrderReason = 5;
      
      // 多单
      // 在空头氛围内向上突破
      bool l2 = g.nearSMaFast&&g.distanceMS>700&&(g.sMaStatus == UPCROSS || g.sMaStatus == UPRUNNING)&&g.mainUpSlow;

      if(l1 // 上穿
      || l3 // 377
      || l4 // 均线排列
      )
      {
         doLong = true;
         doOrder = true;
         
        // return;
      }
      
      // 空单
      // 下穿做单
      bool s1 = g.mMaStatus == DOWNCROSS&&!g.nearSmaSlow;//&&g.farSMaFast&&g.sMaStatus == UPRUNNING

      // 近200均线
      bool s2 =  g.nearSMaFast&&g.distanceMS>700&&(g.sMaStatus == DOWNCROSS || g.sMaStatus == DOWNRUNNING)&&g.mainBelowSlow;
      
      bool s3 = g.nearSmaSlow&&(g.sMaStatus == DOWNCROSS || g.sMaStatus == DOWNRUNNING)&&g.mainBelowSlow&&g.rsi>65&& lastOrderReason!=1;
      // 
      bool s4 = g.dis_betweenMMA <= -200 && MathAbs(g.dis_betweenMMA_before)<50&&lastOrderReason!=6&&!g.nearSmaSlow&&g.rsi_day>30;//&&(g.sMaStatus == DOWNCROSS || g.sMaStatus == DOWNRUNNING)
      
      bool s5 = g.nearSMaFast&&g.dis_sMAFastToSlow<-1000;
      
      if(s3&&!s1&&!s4){
         lastOrderReason = 1;
         useSL = g.stoplose/2;
         useTP = 1000;
      }
      
      if(s1)  lastOrderReason = 2;
      if(s1&&s3)lastOrderReason = 4;
      if(s4)lastOrderReason = 6;
      if(s5)lastOrderReason = 7;
      
      if(s1 
      ||s3
      ||s4
      ||s5
      )//|| s2
      {
        // optype = 2;
         doOrder = true;
         doShort =true;
         //return;
      }
      
      if(doLong&&doShort)
      {
         if(g.dis_sMAFastToSlow<1000)
         {
            doLong = false;
         }else if(g.dis_sMAFastToSlow>1000)
         {
            doShort = false;
         }
      }
      
     
     // doOrder = false;
      
   }
   
   bool condition1()
   {

     return true;
   }
   
   bool condition2()
   {

     return true;
   }
   
   bool condition3()
   {

     return true;
   }
   
   void CheckForClose()
   {
     // 良好运行时间
     int lastCrossshift = iBarShift(Symbol(),g.mainTF,g.lastmMaCrossTime);
     
     // MA12的价格
     double fastNow = iMA(Symbol(),g.mainTF,g.mainMAFast,0,MODE_EMA,PRICE_CLOSE,0);
     // MA50的价格
     double mainSNow = iMA(Symbol(),g.mainTF,g.mainMASLow,0,MODE_EMA,PRICE_CLOSE,0);
     
     // MA2377的价格
     double slowMaNow = iMA(Symbol(),g.mainTF,g.slowMASlow,0,MODE_EMA,PRICE_CLOSE,0);
     
     int nearPoint = MathAbs(Bid - slowMaNow)/Point; // 价格靠近377
     
     double devs = MathAbs(fastNow - mainSNow);
     int point2 = (mainSNow - Close[1])/Point;/* 上根收盘距离MA12的点数*/
     
     bool s2 = devs>200*Point; // 1 穿过一定距离才算
           
           
     double p377  = iMA(Symbol(),g.mainTF,g.slowMASlow,0,MODE_EMA,PRICE_CLOSE,0);
     int SmaSlowPoint = MathAbs(Bid-377)/Point;
      
     for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
     
      int point = iOrderEquitToPoint(OrderTicket());// 盈利点数
      /*
      if(point > 1000)//保本损
      {
         if(OrderType()==OP_BUY)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Point*200,OrderTakeProfit(),0,clrNONE);
         }else{
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Point*200,OrderTakeProfit(),0,clrNONE);
         }
      }*/
      // 持单时间
      datetime opentime = OrderOpenTime();
      int keepshift = iBarShift(Symbol(),g.mainTF,opentime,false);
      
      //---- 持有多单
      if(OrderType()==OP_BUY)
      {
            // 0 下穿,并且达到利润标准,不然就扫止损
            bool s1 = g.mMaStatus == DOWNCROSS;
            
            if((point >100&&s1)// 如果下穿就必须要有利润 point >100&&
            ||(point >500&&nearPoint<20 && lastOrderReason!=1&&lastCrossshift<=30) // 如果靠近377,但是良好运行的时间很长的话
            || (g.rsi_day >=80 || g.rsi >=85) // rsi值过高，可能会反转
            //|| point2>800  // point2>200表示价格下跌超过MA50了200点
            || lastCrossshift >90
            || keepshift>30&&point<500
            )// &&s2 
            {
               bool res = OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed);
               // 反手空
               if(s1&&!g.nearSmaSlow|| (g.dis_betweenMMA>200&&g.dis_betweenMMA_before<50&&!g.nearSmaSlow))//&&g.farSMaFast
               {
                   if(g.stoplose>0)
                        SL=Bid+Point*useSL;
                   if(g.takeprofile>0)
                        TP=Bid-Point*useTP;
            
                  int res2=WHCOrderSend(Symbol(),OP_SELL,g.lot1,Bid,3,SL,TP,"oliver_EA",MAGICMA,0,clrBlue);
                  if(res2<0)
                  {
                     Print("Error when opening a Buy order #",GetLastError());
                     Sleep(10000);
                  }
               }
               break;
            }   
      }
      
      if(OrderType()==OP_SELL)
      {
            bool l1 = g.mMaStatus == UPCROSS;
           
            if((point >100&&l1)// 上穿就 point >100&&
            ||(point >500&&nearPoint<20 && lastOrderReason!=1&&lastCrossshift<=10) // 到达377附近
            ||(g.rsi_day <=20 || g.rsi <=15) // rsi值过低，可能会反弹
            //|| point2 < -800 
            || lastCrossshift >90
            )//上涨超过MA50了200点
            {
               bool res = OrderClose(OrderTicket(),OrderLots(),Ask,3,clrBlue); 
               if(l1&&!g.nearSmaSlow|| (g.dis_betweenMMA>200&&g.dis_betweenMMA_before<50&&!g.nearSmaSlow))//如果离的远&&g.farSMaFast
               {
                  // 反手多
                  if(g.stoplose>0)
                     SL=Bid-Point*useSL;
                  if(g.takeprofile>0)
                     TP=Bid+Point*useTP;
      
                  int res2=WHCOrderSend(Symbol(),OP_BUY,g.lot1,Ask,3,SL,TP,"oliver_EA",MAGICMA,0,clrRed);
                  if(res2<0)
                  {
                     Print("Error when opening a Buy order #",GetLastError());
                     Sleep(10000);
                  }
               }
               break;
            }
      }
      }
   }
   
   void CheckForOpen()
   {
      //---- go trading only for first tiks of new bar
      // TODO why?
      //if(Volume[0]>1)
      // return;
      determin();
      
      /*
      if((g.condition1&c1)>0&&doOrder)
      {
         doOrder = condition1();
      }
      
      if((g.condition1&c2)>0&&doOrder)
      {
         doOrder = condition2();
      }
      if((g.condition1&c3)>0&&doOrder)
      {
         doOrder = condition3();
         
      }
      */
      if(doOrder)
      {
         if(doLong)
         {
            if(g.stoplose>0)
               SL=Bid-Point*useSL;
            if(g.takeprofile>0)
               TP=Bid+Point*useTP;

            int res=WHCOrderSend(Symbol(),OP_BUY,g.lot1,Ask,3,SL,TP,"oliver_EA",MAGICMA,0,clrRed);
            if(res<0)
            {
               Print("Error when opening a Buy order #",GetLastError());
               Sleep(10000);
               return;
            }
         }else if(doShort)
         {
            if(g.stoplose>0)
               SL=Bid+Point*useSL;
            if(g.takeprofile>0)
               TP=Bid-Point*useTP;
            
            int res=WHCOrderSend(Symbol(),OP_SELL,g.lot1,Bid,3,SL,TP,"oliver_EA",MAGICMA,0,clrBlue);
            if(res<0)
            {
               Print("Error when opening a Buy order #",GetLastError());
               Sleep(10000);
               return;
            }
         }
      }     
   }
   
   
 /*  double LotsOptimized()
  {
  
   double lot=g.lot1;
   int    orders=HistoryTotal(); // 历史订单总量
   int    losses=0;   
//---- select lot size
   // 总资金乘以最大承受风险，除以点数
   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
//---- calcuulate number of loss orders without a break
   if(DecreaseFactor>0)
   {
      // 遍历所有的订单
      for(int i=orders-1;i>=0;i--)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
         {
            Print("Error in history!");
            break;
         }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
            continue;
         //----
         if(OrderProfit()>0)
            break;
         if(OrderProfit()<0)
            losses++;
      }
      // 如果连续亏损  
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,2);
  }
   //---- return lot size
   if(lot<0.01)
      lot=0.01;
   return(lot);
  }
  */

};




int WHCOrderSend(string    symbol,
                 int       cmd,
                 double    volume,
                 double    price,
                 int       slippage,
                 double    stoploss,
                 double    takeprofit,
                 string    comment, // 注释
                 int       magic, 
                 datetime  expiration, // 过期日期
                 color     arrow_color // 箭头颜色
                 )
 {
   int ticket=OrderSend(symbol,cmd,volume,price,slippage,0,0,comment,magic,expiration,arrow_color);
   int check=-1;
   if(ticket>0 && (stoploss!=0 || takeprofit!=0))
     {
      if(!OrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color))
        {
         check=GetLastError();
         if(check!=ERR_NO_MQLERROR)
            Print("OrderModify error: "/*,ErrorDescription(check)*/);
        }
     }
   else
     {
      check=GetLastError();
      if(check!=ERR_NO_ERROR)
         Print("OrderSend error: "/*,ErrorDescription(check)*/);
     }
   return(ticket);
}
  
int CalculateCurrentOrders(string symbol)
{
   int buys=0,sells=0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY) buys++;
         if(OrderType()==OP_SELL) sells++;
        }
   }
//---- return orders volume
   if(buys>0)
      return(buys);
   else
      return(-sells);
}


class Action {

public:
   void Action(){}
  

};


double get_MA_Window_Angle(int period,//  移动平均线平均周期
                           int shift1,// 第一根柱的索引
                           int shift2=0,// 第二根柱的索引，默认为0即当前柱
                           int time_frame=0,
                           string symbol="",
                           int ma_method=MODE_EMA,
                           int applied_price=PRICE_CLOSE,
                           int ma_shift=0){
if (symbol=="") symbol=Symbol();
double price1 = iMA(symbol,time_frame,period,ma_shift,ma_method,applied_price,shift1);
double price2 = iMA(symbol,time_frame,period,ma_shift,ma_method,applied_price,shift2);
return(MathArctan(MathTan(((price1-price2)/(WindowPriceMax()- WindowPriceMin()))/((shift2-shift1)*1.000/WindowBarsPerChart())))*180/3.14);
}


int iOrderEquitToPoint(int myTicket)
   {
      int myPoint=0;
      if (OrderSelect(myTicket,SELECT_BY_TICKET,MODE_TRADES))
         {
            if (OrderType()==OP_BUY)
               {
                  myPoint=(Bid-OrderOpenPrice())/Point;
               }
            if (OrderType()==OP_SELL)
               {
                  myPoint=(OrderOpenPrice()-Ask)/Point;
               }
         }
      return(myPoint);
   }