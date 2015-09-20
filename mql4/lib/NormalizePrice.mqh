//+------------------------------------------------------------------+
//|                                               NormalizePrice.mq4 |
//|                                                             GF1D |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "GF1D"

//--------------------------------------------------------------------
double NormalizePrice(double price, bool round = true)
{
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   
   int fullCount = price / tickSize;           
   double result = fullCount * tickSize;      
   

   if (round)
   {
      double mod = price - result;             
      
      if (mod >= tickSize / 2.0)            
         result = result + tickSize;        
   }
   
   return(result);
}

