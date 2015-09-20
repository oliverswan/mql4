//+------------------------------------------------------------------+
//|                                                 ObjectSquare.mq4 |
//|                                     Copyright � 2008, Nazariy S. |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2008, Nazariy S."

// 计算对象的面积
//+------------------------------------------------------------------|
double ObjectSquare(string name)
  {
   int type=ObjectType(name);
   if(!(type==OBJ_RECTANGLE||type==OBJ_ELLIPSE||type==OBJ_TRIANGLE))
        return(-1);
      double price1=ObjectGet(name,OBJPROP_PRICE1),
             price2=ObjectGet(name,OBJPROP_PRICE2);
      int    time1=iBarShift(NULL,PERIOD_M1,
                             ObjectGet(name,OBJPROP_TIME1),true),
             time2=iBarShift(NULL,PERIOD_M1,
                             ObjectGet(name,OBJPROP_TIME2),true),
             pn=MathPow(10,Digits);
   if(time1<0||time2<0) return(-1);
   if(type==OBJ_RECTANGLE)
      return(MathAbs((time2-time1)*(price2-price1)*pn));
   if(type==OBJ_ELLIPSE) {
      double d=MathSqrt(MathPow(time2-time1,2)+
                        MathPow((price2-price1)*pn,2));
      return(MathPow(d,2)/ObjectGet(name,OBJPROP_SCALE)/2*3.1415926535);
     }
   if(type==OBJ_TRIANGLE) {
      double price3=ObjectGet(name,OBJPROP_PRICE3);
      int    time3=iBarShift(NULL,PERIOD_M1,
                          ObjectGet(name,OBJPROP_TIME3),true);
      if(time3<0) return(-1);
      double h1,h2,h3; 
      h1=MathSqrt(MathPow(time2-time1,2)+MathPow((price2-price1)*pn,2));
      h2=MathSqrt(MathPow(time3-time2,2)+MathPow((price3-price2)*pn,2));
      h3=MathSqrt(MathPow(time3-time1,2)+MathPow((price3-price1)*pn,2));
      int p=(h1+h2+h3)/2; 
      return(MathSqrt(p*(p-h1)*(p-h2)*(p-h3)));
     }
  }
//+------------------------------------------------------------------+