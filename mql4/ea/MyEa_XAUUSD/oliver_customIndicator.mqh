//+------------------------------------------------------------------+
//|                                       oliver_customIndicator.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


// 不分高低点按照顺序获取zigzag值，需要优化
double GetExtremumZZPrice(string sy="", int tf=0, int ne=0, // 从0开始的第几个值
                                        int dp=12, int dv=5, int bs=3) {
  if (sy=="" || sy=="0") sy=Symbol();
  double zz;
  int    i, k=iBars(sy, tf), ke=0;

  for (i=0; i<k; i++) {
    zz=iCustom(sy, tf, "ZigZag", dp, dv, bs, 0, i);
    if (zz!=0) {
      ke++;
      if (ke>ne) return(zz);
    }
  }
  Print("GetExtremumZZPrice(): 曲折号",ne,"没有找到");
  return(0);
}
