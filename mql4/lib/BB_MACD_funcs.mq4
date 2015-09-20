//+------------------------------------------------------------------+
//|                                                BB_MACD_funcs.mq4 |
//|                                         Author:  Paladin80       |
//|                                         E-mail:  forevex@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Paladin 80"
#property link      "forevex@mail.ru"
#property library
//--------------------------------------------- iBandsfunc() - start ---------------------------------------------------------
//+----------------------------------------------------------------------------+
//| Input parameters:                                                          |
//|   Sy - Symbol.                                                             |
//|   Tf - Timeframe.                                                          |
//|   BBper - Averaging period to calculate the main line.                     |
//|   BBdev - Deviation from the main line.                                    |
//|   BBshift - The indicator shift relative to the chart.                     |
//|   Applied_price - Applied price.                                           |
//|   Mode_ind - Indicator line index.                                         |
//|   MA_mode - Applied MA method.                                             |
//|   Shift - Index of the value taken from the indicator buffer.              |
//+----------------------------------------------------------------------------+
//|   In contrast to standard function iBands the function iBandsfunc          |
//}   calculates Bollinger Bands with deviation as a double value              |
//|   and with all moving averages, not only on SMA.                           |
//+----------------------------------------------------------------------------+
double iBandsfunc(string Sy,int Tf,int BBper,double BBdev,int BBshift,int Applied_price,int Mode_ind,int MA_mode,int Shift)
{  
   double ML, sum=0.0, a; int coef;
   if (Sy=="" || Sy=="0") Sy=Symbol();
   
   ML=iMA(Sy,Tf,BBper,BBshift,MA_mode,Applied_price,Shift);
   for (int i=Shift; i<=BBper-1+Shift; i++)
   {  switch(Applied_price)   
      {  case PRICE_CLOSE:    a=iClose(Sy,Tf,i+BBshift)-ML; break;
         case PRICE_OPEN:     a=iOpen (Sy,Tf,i+BBshift)-ML; break;
         case PRICE_HIGH:     a=iHigh (Sy,Tf,i+BBshift)-ML; break;
         case PRICE_LOW:      a=iLow  (Sy,Tf,i+BBshift)-ML; break;
         case PRICE_MEDIAN:   a=(iHigh(Sy,Tf,i+BBshift)+iLow(Sy,Tf,i+BBshift))/2.0-ML; break;
         case PRICE_TYPICAL:  a=(iHigh(Sy,Tf,i+BBshift)+iLow(Sy,Tf,i+BBshift)+iClose(Sy,Tf,i+BBshift))/3.0-ML; break;
         case PRICE_WEIGHTED: a=(iHigh(Sy,Tf,i+BBshift)+iLow(Sy,Tf,i+BBshift)+2*iClose(Sy,Tf,i+BBshift))/4.0-ML; break;
         default: a=0.0;
      }
      sum+=a*a;
   }
   double semi_res=BBdev*MathSqrt(sum/BBper);   
      switch (Mode_ind)
      {  case 1:  coef=1;   break;
         case 2:  coef=-1;  break;
         default: coef=0;
      }
   return (ML+coef*semi_res);
}
//--------------------------------------------- iBandsfunc() - end ----------------------------------------------------------

//--------------------------------------------- iMACDfunc() - start ---------------------------------------------------------
//+----------------------------------------------------------------------------+
//| Input parameters:                                                          |
//|   Sy - Symbol.                                                             |
//|   Tf - Timeframe.                                                          |
//|   Fast_period - Number of periods for fast moving average calculation.     |
//|   Slow_period - Number of periods for slow moving average calculation.     |
//|   MACD_MA_mode - MA method for MACD calculation.                           |
//|   Signal_period - Number of periods for signal moving average calculation. |
//|   Signal_MA_mode - MA method for signal line calculation.                  |
//|   Applied_price - Applied price.                                           |
//|   Mode_ind - Indicator line index.                                         |
//|   Shift - Index of the value taken from the indicator buffer.              |
//+----------------------------------------------------------------------------+---------------+
//|   Formulas for calculation of MACD (http://codebase.mql4.com/258)                          |
//|   MACD = MACD_MA_mode(Applied_price, Fast_period)-MACD_MA_mode(Applied_price, Slow_period) |
//|   SIGNAL = Signal_MA_mode(MACD, Signal_period)                                             |
//+--------------------------------------------------------------------------------------------+
double iMACDfunc(string Sy,int Tf,int Fast_period,int Slow_period,int MACD_MA_mode,
                 int Signal_period,int Signal_MA_mode,int Applied_price,int Mode_ind,int Shift)
{
   double MacdBuffer[], Signal, result;
   if (Sy=="" || Sy=="0") Sy=Symbol();
   
   int limit=MathMax(MathMax(Fast_period,Slow_period),Signal_period)-1+Shift;      
   ArrayResize(MacdBuffer,limit);
      for (int i=0; i<=limit; i++)
      {
      MacdBuffer[i]=iMA(Sy,Tf,Fast_period,0,MACD_MA_mode,Applied_price,i)-iMA(Sy,Tf,Slow_period,0,MACD_MA_mode,Applied_price,i);
      }
   ArraySetAsSeries(MacdBuffer,true);
   Signal=iMAOnArray(MacdBuffer,0,Signal_period,0,Signal_MA_mode,Shift);
      switch(Mode_ind)
      {  case MODE_MAIN:   result=MacdBuffer[Shift]; break;
         case MODE_SIGNAL: result=Signal;            break;
      }
   return(result);
}
//--------------------------------------------- iMACDfunc() - end ----------------------------------------------------------









