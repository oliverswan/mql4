//+------------------------------------------------------------------+
//|                                                            k.mq4 |
//|                                                        oliverlee |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "oliverlee"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+



extern int             time1=15;
extern int             time2=240;
extern int             time3=1440;

extern color           hColor=Red;     // Line color
extern color           fhColor=Blue;
extern color           dColor=Yellow;

extern ENUM_LINE_STYLE style1=STYLE_DASH;
extern ENUM_LINE_STYLE style2=STYLE_DASH; 
extern ENUM_LINE_STYLE style3=STYLE_DASH; 

extern int             InpWidth=1;          // Line width
extern bool            InpBack=false;       // Background line
extern bool            InpSelection=true;   // Highlight to move
extern bool            InpHidden=true;      // Hidden in the object list
extern long            InpZOrder=0;         // Priority for mouse click

                                            // -------------------------------------

string ExtName="Oliver";


int timeframes[3]={60,240,1440};

string hnames[]={"hup,hmid,hbtm"};
string fnames[] ={"fup,fmid,fbtm"};
string dnames[] ={"dup,dmid,dbtm"};

int create=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   HLineDelete(0,"hup");
   HLineDelete(0,"hmid");
   HLineDelete(0,"hbtm");

   HLineDelete(0,"fhup");
   HLineDelete(0,"fhmid");
   HLineDelete(0,"fhbtm");

   HLineDelete(0,"dup");
   HLineDelete(0,"dmid");
   HLineDelete(0,"dbtm");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
// 输出标签(标签显示位置x+600,标签显示位置y-100,"price","当前价格: "+DoubleToStr(High[0]),Yellow); 
//--- indicator buffers mapping
// int dayofweektoday= TimeDayOfWeek(Time[0]);// 主要用于判断K线是哪天的，用K线计算出属于的星期然后与目标对比
   IndicatorShortName(ExtName);//  设置指标简称
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   显示布林位置();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double 布林上轨(int time)
  {
   return iBands(NULL,time,20,2,0,PRICE_CLOSE,MODE_LOW,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double 布林中轨(int time)
  {
   return iBands(NULL,time,20,2,0,PRICE_CLOSE,MODE_MAIN,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double 布林下轨(int time)
  {
   return iBands(NULL,time,20,2,0,PRICE_CLOSE,MODE_HIGH,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void 显示布林位置()
  {

   if(create<0)
     {
      HLineCreate(0,"hup",0,布林上轨(time1),hColor,style1,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
      HLineCreate(0,"hmid",0,布林中轨(time1),hColor,style2,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
      HLineCreate(0,"hbtm",0,布林下轨(time1),hColor,style3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);

      HLineCreate(0,"fhup",0,布林上轨(time2),fhColor,style1,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
      HLineCreate(0,"fhmid",0,布林中轨(time2),fhColor,style2,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
      HLineCreate(0,"fhbtm",0,布林下轨(time2),fhColor,style3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);

      HLineCreate(0,"dup",0,布林上轨(time3),dColor,style1,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
      HLineCreate(0,"dmid",0,布林中轨(time3),dColor,style2,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
      HLineCreate(0,"dbtm",0,布林下轨(time3),dColor,style3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);

      create=1;
     }
   else
     {
      HLineMove(0,"hup",布林上轨(time1));
      HLineMove(0,"hmid",布林中轨(time1));
      HLineMove(0,"hbtm",布林下轨(time1));

      HLineMove(0,"fhup",布林上轨(time2));
      HLineMove(0,"fhmid",布林中轨(time2));
      HLineMove(0,"fhbtm",布林下轨(time2));

      HLineMove(0,"dup",布林上轨(time3));
      HLineMove(0,"dmid",布林中轨(time3));
      HLineMove(0,"dbtm",布林下轨(time3));

      ChartRedraw();

      Sleep(500);

     }

/*
   int count=ArraySize(timeframes);
   if(create<0)
     {
      for(int i=0;i<count;i++)
        {
         int time= timeframes[i];
         if(time == 60)
           {

            HLineCreate(0,"hup",0,布林上轨(time),InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
            HLineCreate(0,"hmid",0,布林中轨(time),InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
            HLineCreate(0,"hbtm",0,布林下轨(time),InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
           }

         if(time==240)
           {
            color color2=Blue;
            HLineCreate(0,fnames[0],0,布林上轨(time),color2,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
            HLineCreate(0,fnames[1],0,布林中轨(time),color2,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
            HLineCreate(0,fnames[2],0,布林下轨(time),color2,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
           }

         if(time==1440)
           {
            color color3=Black;
            HLineCreate(0,dnames[0],0,布林上轨(time),color3,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
            HLineCreate(0,dnames[1],0,布林中轨(time),color3,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
            HLineCreate(0,dnames[2],0,布林下轨(time),color3,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
           }

        }
      create=1;
     }

   else
     {
      for(int i=0;i<count;i++)
        {
         int time= timeframes[i];
         if(time == 60)
           {
            HLineMove(0,hnames[0],布林上轨(time));
            HLineMove(0,hnames[1],布林中轨(time));
            HLineMove(0,hnames[2],布林下轨(time));
           }

         if(time==240)
           {
            HLineMove(0,fnames[0],布林上轨(time));
            HLineMove(0,fnames[1],布林中轨(time));
            HLineMove(0,fnames[2],布林下轨(time));
           }

         if(time==1440)
           {
            HLineMove(0,dnames[0],布林上轨(time));
            HLineMove(0,dnames[1],布林中轨(time));
            HLineMove(0,dnames[2],布林下轨(time));
           }

        }
     }
*/
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move horizontal line                                             |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,   // chart's ID
               const string name="HLine", // line name
               double       price=0)      // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete a horizontal line                                         |
//+------------------------------------------------------------------+
bool HLineDelete(const long   chart_ID=0,   // chart's ID
                 const string name="HLine") // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a horizontal line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
