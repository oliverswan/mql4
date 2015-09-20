//+------------------------------------------------------------------+
//|                                                  OrdersSuite.mq4 |
//|                                         Copyright © 2008, sx ted |
//|                                               sxted@talktalk.net |
//| Purpose.: Functions for processing the orders of Spot currency   |
//|           pairs, Spot Gold and Spot Silver with error handling.  |
//| ThankYou: Big thank you to Professor's Slawa and Stringo for the |
//|           little gems of information on coding, to Rosh and all  |
//|           the moderators for their help and patience and to the  |
//|           members of the forums who give so freely of their code |
//|           and time, from whom I have borrowed quite a bit.       |
//|           Thank you Rasoul for urging me on, hope it was worth   |
//|           waiting for.                                           |
//| Notes...: This library of functions is based on testing with     |
//|           MetaQuotes-Demo, MIG-Demo and InterbankFX-Demo only,   |
//|           and as Slawa stressed each broker's server processes   |
//|           orders slightly differently, like when a pending order |
//|           is changed to a market order it is given a new number, |
//|           so test, test the functions, testing should also be    |
//|           carried out in a fast moving market (just after news   |
//|           or a report is announced) or when it is crawling like  |
//|           just before the week end close.                        |
//|           To use the error handler the MT4 ordering functions    |
//|           OrderSend(), OrderClose(), OrderDelete(), OrderModify()|
//|           and OrderCloseBy() are to be edited in the expert by   |
//|           adding the suffix 2, for example: replace OrderClose() |
//|           with OrderClose2().                                    |
//|           GetLastError() where it is used in your EA to obtain   |
//|           the last occured error with the MT4 ordering functions |
//|           (as listed above) is to be replaced either with the    |
//|           GetLastError2() function or by refering to the value   |
//|           of the global variable giError.                        |
//|           Use the OrderError() function to print the error.      |
//|           The error handler in OrderProcess() caters for trading |
//|           both currencies and commodities with different trading |
//|           hours simultaneously, so should for example: "XAUUSD"  |
//|           (Spot Gold) be requested to be closed from a script,   |
//|           while the daily close of the exchange is taking place, |
//|           then severe error 133 ERR_TRADE_DISABLED is avoided so |
//|           as to allow the following request from the script to   |
//|           close "EURUSD" (which would not cause the error).      |
//|           Edit or add to the Sessions array with the trading     |
//|           hours of your broker's server and daily close times of |
//|           Spot Gold and Spot Silver commodities.                 |
//| WishList: Slawa it would be convenient to have a library init()  |
//|           which is initialised before the init() of an EA/script |
//|           and a library deinit() which is called before executing|
//|           the deinit() of the EA/script (example for removing a  |
//|           semaphore lock in the limited time before the EA is    |
//|           closed down).                                          |
//| Version.: 0 ?                                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, sx ted"
#property link      "sxted@talktalk.net"

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define _MILLION                      1000000                       // avoid mistyping so many zeroes!
//-------------------------------------------------------------------- Action codes in processing orders:                            
#define ACT_SUCCESS                         0                       // Success in processing the order
#define ACT_CAN_RETRY                      -1                       // Remedial action can be taken before
                                                                    // retrying to process the order    
#define ACT_EXIT_START                     -2                       // error requires that start() function be exited  
#define ACT_WAIT_FOR_SESSION               -3                       // avoid error 133 when trading currencies
                                                                    // and commodities at the same time
#define ACT_EXIT_EA                        -4                       // Program logic/System failure,
                                                                    // the expert should be terminated           
//-------------------------------------------------------------------- Color constants
#define CLR_DEF                             0                       // Indicates default gcColorScheme[] to be used 
//-------------------------------------------------------------------- Error codes
#define ERROR                              -1                       // 
#define ERR_146_MAX_TRIES                  10                       // ERR_TRADE_CONTEXT_BUSY maximum retries
#define ERR_146_MIN_SEC                    10                       // ERR_TRADE_CONTEXT_BUSY random delay min
#define ERR_146_MAX_SEC                    30                       // ERR_TRADE_CONTEXT_BUSY random delay max
//-------------------------------------------------------------------- Option() or Options[]
#define OPT_ORDER_RETRY_ATTEMPTS            0                       // index position in array Options[]
#define OPT_PRINT_MSG                       1                       // index position in array Options[]
#define OPT_TRADE_PAUSE_SECONDS             2                       // index position in array Options[]
//-------------------------------------------------------------------- Order processing:
#define ORD_CLOSE                           6                       // Request emanated from OrderClose2()
#define ORD_CLOSEBY                         7                       // Request emanated from OrderCloseBy2()
#define ORD_DELETE                          8                       // Request emanated from OrderDelete2()
#define ORD_MODIFY                          9                       // Request emanated from OrderModify2()
//-------------------------------------------------------------------- Semaphore
#define SEM_ID                "_ThreadUsedBy"                       // name for the global variable
#define SEM_PAUSE                           1                       // number of seconds to pause in between trades
//-------------------------------------------------------------------- Sessions[]
#define SES_ROWS                            4                       // number of rows in array Sessions
#define SES_SERVER                          0                       // Broker AccountServer()
#define SES_SYMBOL                          1                       // Symbol
#define SES_TRADE_START                     2                       // Trading Hours Start
#define SES_TRADE_END                       3                       // Trading Hours End
#define SES_CLOSE_START                     4                       // Daily Close Start
#define SES_CLOSE_END                       5                       // Daily Close End
//-------------------------------------------------------------------- Signal()
#define SIG_WAIT                           -2                       // no action
#define SIG_BUY                             0                       // Buy
#define SIG_SELL                            1                       // Sell
//-------------------------------------------------------------------- String
#define STR_DELIMITER                     "|"                       // delimiter character
//-------------------------------------------------------------------- Pause times
#define WAIT_GBL_INI                       30

//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
#include <TimeSuite.mqh>

//+------------------------------------------------------------------+
//| global variables to program:                                     |
//+------------------------------------------------------------------+
color  gcColorScheme[]={Blue,                                       //  0 OP_BUY       Buying position
                        Red,                                        //  1 OP_SELL      Selling position
                        DeepSkyBlue,                                //  2 OP_BUYLIMIT  Buy limit pending position
                        Magenta,                                    //  3 OP_SELLLIMIT Sell limit pending position
                        DeepSkyBlue,                                //  4 OP_BUYSTOP   Buy stop pending position
                        Magenta                                     //  5 OP_SELLSTOP  Sell stop pending position
                       };
double Options[]={5,                                                // 0 OPT_ORDER_RETRY_ATTEMPTS
                  true,                                             // 1 OPT_PRINT_MSG
                  1                                                 // 2 OPT_TRADE_PAUSE_SECONDS
                 },
       Price[2],
       gdPoint,
       gdSpread,
       gdStopLevel;
int    giAction,                                                    // return value of OrderProcess() and determines next move
       giCmd,                                                       // trade type or order function number
       giDigits,
       giError,                                                     // value of last call to GetLastError()
                                                                    // from within functions of OrdersSuite.mqh
       giSlippage,
       giX[]={-1,1,1,-1};                                           // Price[] multipliers;

//-------------------------------------------------------------------- Trading hours and Daily close times
string Sessions[SES_ROWS][6]={                                      /*
  For each broker, if several are used, the first row is to detail
  the default trading times for all Spot Currencies, then followed
  on the next rows with the exceptions. The trading hours are read
  by the function TimeInRange() using the notation "D HH:MM" where
  D=Day of week (0-Sunday,1,2,3,4,5,6), HH=Hour and MM=Minute.
+-------------------+---------+---------+---------+-------+-------+
|                   |         | Trading | Trading | Daily | Daily |
| Broker            |         | Hours   | Hours   | Close | Close |
| AccountServer()   | Symbol  | Start   | End     | Start | End   |
+-------------------+---------+---------+---------+-------+-------+ */
"DEFAULT"           ,"DEFAULT","0 23:00","5 23:00","00:00","00:00", // default when only currencies used by broker (in which case this would be the only row in the array)
"MIG-Demo"          ,"DEFAULT","0 23:00","5 23:00","00:00","00:00", // broker default for all Spot Currencies
"MIG-Demo"          ,"XAGUSD" ,"1 00:00","5 23:00","23:15","00:00", // broker exception for Spot Silver commodity
"MIG-Demo"          ,"XAUUSD" ,"1 00:00","5 23:00","23:15","00:00"  // broker exception for Spot Gold commodity
};
 
//+------------------------------------------------------------------+
//| Function..: CmdToStr                                             |
//+------------------------------------------------------------------+
string CmdToStr(int cmd) {
  switch(cmd) {
    case OP_BUY:       return("OP_BUY");
    case OP_SELL:      return("OP_SELL");
    case OP_BUYLIMIT:  return("OP_BUYLIMIT");
    case OP_SELLLIMIT: return("OP_SELLLIMIT");
    case OP_BUYSTOP:   return("OP_BUYSTOP");
    case OP_SELLSTOP:  return("OP_SELLSTOP");
    case ORD_CLOSE:    return("ORD_CLOSE");
    case ORD_CLOSEBY:  return("ORD_CLOSEBY");
    case ORD_DELETE:   return("ORD_DELETE");
    case ORD_MODIFY:   return("ORD_MODIFY");
    default:           return("cmd unknown");
  }
}

//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string ErrorDescription2(int error_code) {
  string error_string;
  
  switch(error_code) {
    //---- codes returned from OrdersSuite.mqh functions
    case -1:   error_string="EA terminated by user";      break;
    case -2:   error_string="retry period exceeded";      break;
    case -3:   error_string="Account/MarketInfo=0";       break;
    case -4:   error_string="wait for session to open";   break;
    case -5:   error_string="Margin call soon!!!";        break;
    default:   error_string=ErrorDescription(error_code);
  }
  return(error_string);
}

//+------------------------------------------------------------------+
//| Function..: ErrorSet                                             |
//+------------------------------------------------------------------+
int ErrorSet(int iError, int iReturn=0, int iAction=-100) {
  giError=iError;
  if(iAction!=-100) giAction=iAction;
  return(iReturn);
}

//+------------------------------------------------------------------+
//| Function..: GetLastError2                                        |
//| Purpose...: Replacement for the GetLastError() function when     |
//|             using the functions in this library.                 |
//| Returns...: Operates like GetLastError().                        |
//| Notes.....: The global variable giError may be used directly.    |
//|             The test for an error must now be: if(giError != 0)  |
//|             as new negative numbers have been added, refer to    |
//|             the ErrorDescription2() function.                    |
//+------------------------------------------------------------------+
int GetLastError2() {
  int iError=giError;
  giError=0;
  return(iError);
}

//+------------------------------------------------------------------+
//| Function..: GetMarketInfo                                        |
//| Parameters: sSymbol - Symbol for trading.                        |
//| Returns...: bool Success.                                        |
//+------------------------------------------------------------------+
bool GetMarketInfo(string sSymbol) {
  RefreshRates();
  gdPoint=MarketInfo(sSymbol,MODE_POINT);
  /*debug*/ if(GetLastError()==4106) Msg(0,"unknown symbol?",sSymbol);
  if(CompareDoubles(gdPoint,0.0)) return(false);
  Price[0]=MarketInfo(sSymbol,MODE_ASK);
  Price[1]=MarketInfo(sSymbol,MODE_BID);
  giDigits=MarketInfo(sSymbol,MODE_DIGITS);
  giSlippage=(Price[0]-Price[1])/gdPoint;
  gdSpread=MarketInfo(sSymbol,MODE_SPREAD);
  gdStopLevel=MarketInfo(sSymbol,MODE_STOPLEVEL);
  return(Price[0]>0.0 && Price[1]>0.0 && giDigits>0 && gdSpread>0 && gdStopLevel>0);
}

//+------------------------------------------------------------------+
//| Function..: GlobalVariable                                       |
//| Parameters: sName     - Global variable name.                    |
//|             bGetValue - 1=Get current value.                     |
//|                         0=Set new value.                         |
//|             dValue    - The new numeric value.                   |
//| Purpose...: Create a global variable if not present and/or       |
//|             initialise/change it's value for multiple EA's.      | 
//| Returns...: dValue - Value of the global variable named <sName>  |
//|                      or -1 if an error occurs. Call the function |
//|                      GetLastError2() to get the detailed error   |
//|                      information or inspect the value of giError.|
//| Notes.....: Used for status of "_OpenNewOrders" & "_StopTrading".|
//|             Assumes sole use or that a SemLock() has first been  |
//|             set.                                                 |
//| Example...: if(SemLock()) {                                      |
//|               GlobalVariable("_OpenNewOrders",0,OrdersOpen()==0);|
//|               SemUnlock();                                       |
//|             }                                                    |
//+------------------------------------------------------------------+
double GlobalVariable(string sName, bool bGetValue=1, double dValue=0) {
  int iStartWaitingTime=GetTickCount();
  
  while(true) {
    if(IsStopped()) return(ErrorSet(-1,-1));
    if(GetTickCount()-iStartWaitingTime > WAIT_GBL_INI*1000) return(ErrorSet(-2,-1));
    if(bGetValue && GlobalVariableCheck(sName)) dValue=GlobalVariableGet(sName); 
    else GlobalVariableSet(sName,dValue);
    if(GetLastError()==0) return(dValue);
    Sleep(100);
    continue;
  }
}

//+------------------------------------------------------------------+
//| Function..: Msg                                                  |
//| Parameters: iReturn - value to be returned.                      |
//|             xValue1 - boolean/double/integer/string value 1.     |
//|             xValue2 - boolean/double/integer/string value 2.     |
//|             xValue3 - boolean/double/integer/string value 3.     |
//|             xValue4 - boolean/double/integer/string value 4.     |
//| Purpose...: Display error or information messages if toggle      |
//|             Options[OPT_PRINT_MSG] has been set to <true>.       |
//| Returns...: iReturn.                                             |
//| Notes.....: DateTime value to be formatted using TimeToStr().    |
//| Examples..: Msg(0,"Error:",giError,ErrorDescription2(giError));  |
//|             Msg(1,Symbol(),"bought at",Ask);                     |
//+------------------------------------------------------------------+
int Msg(int iReturn, string sVal1, string sVal2="", string sVal3="", string sVal4="") {
  if(Options[OPT_PRINT_MSG]==true) Print(sVal1," ",sVal2," ",sVal3," ",sVal4);
  return(iReturn);
}

//+------------------------------------------------------------------+
//| Function..: Option                                               |
//| Parameters: iIndex    - Index number of the option.              |
//|             bGetValue - 1=Get value of the option (the default), |
//|                         0=Set new value for the option.          |
//|             dValue    - New value for the option.                |
//| Purpose...: Set values which are to be set differently for an EA |
//|             or a script, but not using an external parameter.    |
//| Returns...: dValue - Current value of the option.                |
//| Notes.....: Index | Option                       | Default value |
//|             ------+------------------------------+-------------- |
//|              0    | OPT_ORDER_RETRY_ATTEMPTS     | 5             |
//|              1    | OPT_PRINT_MSG                | true          |
//|              2    | OPT_TRADE_PAUSE_SECONDS      | 1             |
//| Example...: if(Option[OPT_PRINT_MSG]==true) Print("Hi");         |
//+------------------------------------------------------------------+
double Option(int iIndex=0, bool bGetValue=true, double dValue=0) {
  double dCurValue=Options[iIndex];
  if(!bGetValue) Options[iIndex]=dValue;
  return(dCurValue); 
}

//+------------------------------------------------------------------+
//| Function..: OrderCheckFunds                                      |
//| Parameters: sSymbol - Symbol for trading operation.              | 
//|             cmd     - Operation type. It can be either OP_BUY or |
//|                       OP_SELL.                                   | 
//|             dLots   - Number of lots.                            |
//| Purpose...: Determine if there are sufficient funds to open a    |
//|             new position.                                        |
//| Returns...: bSuccess. In case of failure function GetLastError2()|
//|             may be called or the global variable giError may be  |
//|             used to retrieve the error number.                   |   
//+------------------------------------------------------------------+
bool OrderCheckFunds(string sSymbol, int cmd, double dLots) {
  double dVal=AccountEquity(), 
         dVal2=AccountFreeMarginCheck(sSymbol,cmd,dLots);

  if(CompareDoubles(dVal,0.0) || CompareDoubles(dVal2,0.0)) return(ErrorSet(-3,0,ACT_EXIT_START));
  if((dVal/(dVal-dVal2)) < 0.50) return(ErrorSet(-5,0,ACT_EXIT_START));
  return(1);
}
          
//+------------------------------------------------------------------+
//| Function..: OrderClose2                                          |
//| Parameters: Same as OrderClose()                                 |
//| Purpose...: Close opened order like MT4 function OrderClose()    |
//|             but with error handling.                             |
//| Returns...: bool Success.                                        |
//+------------------------------------------------------------------+
bool OrderClose2(int iTicket, double dLots, double dPrice, int iSlippage, color cColor=CLR_NONE) {
  if(!OrderSelect(iTicket,SELECT_BY_TICKET)) return(ErrorSet(GetLastError(),0,ACT_EXIT_START));
  string sMsg=StringConcatenate("OrderClose(",iTicket,",",dLots,",",dPrice,",",iSlippage,",",cColor,")");
  return(OrderProcess(ORD_CLOSE,OrderSymbol(),sMsg,iTicket,cColor,0,dLots,dPrice,iSlippage));
}   

//+------------------------------------------------------------------+
//| Function..: OrderCloseBy2                                        |
//| Parameters: Same as OrderCloseBy()                               |
//| Purpose...: Close opened order like MT4 function OrderCloseBy()  |
//|             but with error handling.                             |
//| Returns...: bool Success.                                        |
//+------------------------------------------------------------------+
bool OrderCloseBy2(int iTicket, int iOpposite, color cColor=CLR_NONE) {
  if(!OrderSelect(iTicket,SELECT_BY_TICKET)) return(ErrorSet(GetLastError(),0,ACT_EXIT_START));
  string sMsg=StringConcatenate("OrderCloseBy(",iTicket,",",iOpposite,",",cColor,")");
  return(OrderProcess(ORD_CLOSEBY,OrderSymbol(),sMsg,iTicket,cColor,iOpposite));
}  

//+------------------------------------------------------------------+
//| Function..: OrderDelete2                                         |
//| Parameters: Same as OrderDelete()                                |
//| Purpose...: Cancel pending order like MT4 function OrderDelete() |
//|             but with error handling.                             |
//| Returns...: bool Success.                                        |
//+------------------------------------------------------------------+
bool OrderDelete2(int iTicket, color cColor=CLR_NONE) {
  if(!OrderSelect(iTicket,SELECT_BY_TICKET)) return(ErrorSet(GetLastError(),0,ACT_EXIT_START));
  string sMsg=StringConcatenate("OrderDelete(",iTicket,",",cColor,")");
  return(OrderProcess(ORD_DELETE,OrderSymbol(),sMsg,iTicket,cColor));
}

//+------------------------------------------------------------------+
//| Function..: OrderError                                           |
//+------------------------------------------------------------------+
void OrderError() {
  if(giCmd<=OP_SELLSTOP) Print("Order:new  Error:",giError," ",ErrorDescription2(giError));
  else Print("Order:",OrderTicket(),"  Error:",giError," ",ErrorDescription2(giError));
}

//+------------------------------------------------------------------+
//| Function..: OrderModify2                                         |
//| Parameters: Same as OrderModify()                                |
//| Purpose...: Modification of characteristics for the previously   |
//|             opened position or pending orders like MT4 function  |
//|             OrderModify() but with error handling.               | 
//| Returns...: bool Success.                                        |
//| Notes.....: The order is submitted for modification only if      |
//|             there is a change in one or more of the values.      |
//|             If error 130 ERR_INVALID_STOPS is triggered then the |
//|             order is cancelled if it is pending, or the market   |
//|             order is closed.                                     |
//+------------------------------------------------------------------+
bool OrderModify2(int iTicket, double dPrice, double dSL, double dTP, datetime tExpire, color cColor=CLR_NONE) {
  string sMsg;
  
  if(!OrderSelect(iTicket,SELECT_BY_TICKET)) return(ErrorSet(GetLastError(),0,ACT_EXIT_START));
  if(!GetMarketInfo(OrderSymbol())) return(ErrorSet(-3,0,ACT_CAN_RETRY));
  if(OrderType()<=OP_SELL) {
    dSL=NormalizeDouble(dSL,giDigits);
    dTP=NormalizeDouble(dTP,giDigits);
    if(dSL!=OrderStopLoss() || dTP!=OrderTakeProfit()) {
      sMsg=StringConcatenate("Ask=",Price[0]," Bid=",Price[1]," MarketInfo(",OrderSymbol(),",MODE_STOPLEVEL)=",gdStopLevel," cmd=",CmdToStr(OrderType())," OrderModify(",iTicket,",",OrderOpenPrice(),",",dSL,",",dTP,",",OrderExpiration(),",",cColor,")");
      return(OrderProcess(ORD_MODIFY,OrderSymbol(),sMsg,iTicket,cColor,0,0,OrderOpenPrice(),dSL,dTP,OrderExpiration()));
    }
  }
  else {
    dPrice=NormalizeDouble(dPrice,giDigits);
    if(dPrice!=OrderOpenPrice() || tExpire!=OrderExpiration()) {
      sMsg=StringConcatenate("Ask=",Price[0]," Bid=",Price[1]," MarketInfo(",OrderSymbol(),",MODE_STOPLEVEL)=",gdStopLevel," cmd=",CmdToStr(OrderType())," OrderModify(",iTicket,",",dPrice,",",OrderStopLoss(),",",OrderTakeProfit(),",",tExpire,",",cColor,")");
      return(OrderProcess(ORD_MODIFY,OrderSymbol(),sMsg,iTicket,cColor,0,0,dPrice,OrderStopLoss(),OrderTakeProfit(),tExpire));
    }
  }
  return(true); // but no modifications
}
 
//+------------------------------------------------------------------+
//| Function..: OrderOpenPos                                         |
//| Thank you.: KimIV reference http://forum.mql4.com/ru/6688        |
//| Parameters: sym - Symbol/Instrument, defaults to current symbol, |
//|             op  - Order type, (-1 is any type),                  |
//|             mn  - Magic number, (-1 is any Magic number).        |
//| Purpose...: Locate position number of order that was last opened |
//|             in the trading pool.                                 |
//| Returns...: iPosition or -1 (not found).                         |
//+------------------------------------------------------------------+
int OrderOpenPos(string sym="", int op=-1, int mn=-1) {
  datetime t;
  int      i, j=-1, k=OrdersTotal();
 
  if (sym=="") sym=Symbol();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==sym) {
        if (op<0 || OrderType()==op) {
          if (mn<0 || OrderMagicNumber()==mn) {
            if (t<OrderOpenTime()) {
              t=OrderOpenTime();
              j=i;
            }
          }
        }
      }
    }
  }
  return(j);
}

//+------------------------------------------------------------------+
//| Function..: OrderProcess                                         |
//| Purpose...: Process all orders of an EA.                         |
//|             It includes error handling, so as to stay in the     |
//|             brokers good books, but mainly protect our money.    |
//| Returns...: If the call to OrderProcess() was made from function |
//|             OrderSend2() then the iTicket number is returned,    |
//|             for the other ordering functions a boolean value is  |
//|             returned. In case of failure function GetLastError2()|
//|             may be called or the value of the global variable    |
//|             giError may be inspected.                            |
//| Notes.....: The global variable giAction returns the severity of |
//|             the error and has the following values:              | 
//|             ACT_SUCCESS           0 No errors encountered, can   |
//|                                     proceed to the next order,   |
//|             ACT_CAN_RETRY        -1 MarketInfo()=0, should exit  |
//|                                     start() function, and retry, |  
//|             ACT_EXIT_START       -2 The EA must exit the start() |
//|                                     function, and retried at the |
//|                                     next tick,                   |
//|             ACT_WAIT_FOR_SESSION -3 Exit start() to avoid error  |
//|                                     133 if currencies and        |
//|                                     commodities traded at the    |
//|                                     same time, but with different|
//|                                     daily close times,           |
//|             ACT_EXIT_EA          -4 Program logic/System failure,|
//|                                     the EA should be stopped.    |
//+------------------------------------------------------------------+
int OrderProcess(int cmd, string sSymbol, string sMsg="", int iTicket=0, color cColor=CLR_NONE,
                 int iOpposite=0, double dLots=0, double dPrice=0, int iSlippage=0, double dSL=0,
                 double dTP=0, datetime tExpire=0, string sComment="", int iMagic=0) {
  bool     ok;
  int      i, iCnt, iPreviousCmd, iReturn;
  string   sServer=AccountServer();
  datetime t=TimeCurrent();
    
  giAction=ACT_CAN_RETRY;
  giCmd=cmd;
  if(cmd <= OP_SELLSTOP) iReturn=-1;                          
  //------------------------------------------------------------------ validate
  if(GlobalVariable("_StopTrading")==true) giAction=ACT_EXIT_EA;    // enforce warning received from broker  
  else {
    OrderResume();                                                  // check if EA is to be delayed
    //---------------------------------------------------------------- check if trading session open for symbol and avoid error 133 when trading currencies and commodities simultaneously
    for(i=SES_ROWS-1; i>=0; i--) {
      if(Sessions[i][SES_SERVER]==sServer   && Sessions[i][SES_SYMBOL]==sSymbol)   break;
      if(Sessions[i][SES_SERVER]==sServer   && Sessions[i][SES_SYMBOL]=="DEFAULT") break;
      if(Sessions[i][SES_SERVER]=="DEFAULT" && Sessions[i][SES_SYMBOL]=="DEFAULT") break;
    }
    if(TimeInRange(t,Sessions[i][SES_TRADE_START],Sessions[i][SES_TRADE_END])==0 || TimeInDailyClose(t,Sessions[i][SES_CLOSE_START],Sessions[i][SES_CLOSE_END])>0) ErrorSet(-4,iReturn,ACT_WAIT_FOR_SESSION);
  }
  //------------------------------------------------------------------ process order
  while(giAction == ACT_CAN_RETRY) {
    if(!GetMarketInfo(sSymbol)) return(ErrorSet(-3,iReturn,ACT_CAN_RETRY));
    t=TimeCurrent();                                                // record time stamp
    if(cmd <= OP_SELL)          dPrice=Price[cmd%2];
    if(cmd <= OP_SELLSTOP)      iTicket=OrderSend(sSymbol,cmd,dLots,dPrice,iSlippage,dSL,dTP,sComment,iMagic,tExpire,cColor);
    else if(cmd == ORD_CLOSE)   OrderClose(iTicket,dLots,Price[1-OrderType()],iSlippage,cColor);
    else if(cmd == ORD_CLOSEBY) OrderCloseBy(iTicket,iOpposite,cColor);
    else if(cmd == ORD_DELETE)  OrderDelete(iTicket,cColor);
    else if(cmd == ORD_MODIFY)  OrderModify(iTicket,dPrice,dSL,dTP,tExpire,cColor);
    iPreviousCmd=cmd;                                               // remember previous command
    //---------------------------------------------------------------- handle errors
    giError=GetLastError();
    switch(giError) {
      case    0: // ERR_NO_ERROR
      case  144: // The order was discarded by the client during manual confirmation.
                 giAction=ACT_SUCCESS;
                 break;
      case    1: // ERR_NO_RESULT
      case  129: // ERR_INVALID_PRICE
      case  136: // ERR_OFF_QUOTES // unconfirmed prices/fast market
      case  137: // ERR_BROKER_BUSY 
                 Sleep(5000+MathMod(MathRand(),1000));
                 if(giError==1) giAction=ACT_EXIT_START; // give market time to move away from stop loss level/change code
                 break;
      case    3: // ERR_INVALID_TRADE_PARAMETERS - program logic or can occur when trying to cancel a pending order when too close to market which has reversed
      case    4: // ERR_SERVER_BUSY
      case    8: // ERR_TOO_FREQUENT_REQUESTS - program logic must be changed
      case  132: // ERR_MARKET_CLOSED
                 OrderResume(TimeCurrent()+3*60);
                 giAction=ACT_EXIT_START;
                 break;
      case    6: // ERR_NO_CONNECTION
                 for(i=0; i < 6; i++) {
                   Sleep(5000);
                   if(IsConnected()) break;
                 }
                 giAction=ACT_EXIT_START;
                 break;
      case  128: // ERR_TRADE_TIMEOUT  ** ok ** OrderSend()
      case  142: // Order has been enqueued: server disconnected during op
      case  143: // Order was accepted by the dealer for execution: server disconnected during op.
                 // Ensure that trading operation has not really succeeded  ** ok ** w/ OrderModify()
                 // (a new position has not been opened, or the existing order has not been modified
                 // or deleted, or the existing position has not been closed) before retry
                 ok=false;
                 if(cmd<=OP_SELLSTOP) ok=(OrderOpenPos(sSymbol,cmd,iMagic)>0 && OrderOpenTime()>=t);
                 else if(cmd==ORD_CLOSE || cmd==ORD_CLOSEBY || cmd==ORD_DELETE) ok=(OrderSelect(iTicket,SELECT_BY_TICKET) && (OrderCloseTime() > 0));
                 else if(cmd==ORD_MODIFY) ok=(OrderSelect(iTicket,SELECT_BY_TICKET) && (OrderStopLoss() == dSL && OrderTakeProfit() == dTP && OrderOpenPrice() == dPrice && OrderExpiration() == tExpire));
                 if(ok) giAction=ACT_SUCCESS;
                 else   Sleep(65000);
                 break;
      case  130: // ERR_INVALID_STOPS
                 if(!GetMarketInfo(sSymbol)) return(ErrorSet(-3,iReturn,ACT_CAN_RETRY));
                 if((cmd>OP_SELL) && (cmd<=OP_SELLSTOP)) {
                   if(MathAbs(dPrice-Price[cmd%2]) < gdStopLevel*gdPoint) cmd=cmd%2; // change to market order request ** ok **
                 }
                 else if(cmd==ORD_MODIFY) {
                   if((OrderType()>OP_SELL) && (MathAbs(dPrice-Price[OrderType()%2]) < gdStopLevel*gdPoint)) cmd=ORD_DELETE; // market volatile!
                   if((OrderType()<=OP_SELL) && ((MathAbs(dSL-Price[OrderType()%2]) < gdStopLevel*gdPoint) || (MathAbs(dTP-Price[OrderType()%2]) < gdStopLevel*gdPoint))) cmd=ORD_CLOSE; // market volatile!
                 }
                 Sleep(5000+MathMod(MathRand(),1000));
                 break;
      case  134: // ERR_NOT_ENOUGH_MONEY
                 dLots=ReduceLots(dLots,MarketInfo(sSymbol,MODE_MARGINREQUIRED),MarketInfo(sSymbol,MODE_LOTSTEP));
                 if(dLots>0.0) Sleep(5000);
                 else GlobalVariable("_StopTrading",0,true);
                 break;
      case  135: // ERR_PRICE_CHANGED
      case  138: // ERR_REQUOTE // prices out of date or bid & ask mixed up or fast market
                 break; 
      case  145: // ERR_TRADE_MODIFY_DENIED
                 Sleep(16000+MathMod(MathRand(),2000));
                 break;
      case  146: // ERR_TRADE_CONTEXT_BUSY
                 for(i=-1; i < ERR_146_MAX_TRIES; i++) {
                   Sleep(ERR_146_MIN_SEC*1000+MathMod(MathRand(),(ERR_146_MAX_SEC-ERR_146_MIN_SEC)*1000)); // random delay
                   if(!IsTradeContextBusy()) break;
                 }
                 if(i >= ERR_146_MAX_TRIES) giAction=ACT_EXIT_START;
                 break;
      case  147: // ERR_TRADE_EXPIRATION_DENIED 
                 tExpire=0;
                 break;
      case  148: // ERR_TRADE_TOO_MANY_ORDERS
                 GlobalVariable("_OpenNewOrders",0,false);
                 giAction=ACT_EXIT_START;
                 break;
      case 4107: // ERR_INVALID_PRICE_PARAM - Invalid price ** ok ** with OrderSend() 
                 if(((cmd>OP_SELL) && (cmd<=OP_SELLSTOP)) || (cmd==ORD_MODIFY)) dPrice=NormalizeDouble(dPrice,giDigits);
                 break;
      case 4108: // ERR_INVALID_TICKET can occur with OrderClose(), OrderCloseBy(), OrderDelete() or
                 // OrderModify() when the position has reached it's TP, SL or Expiration time just
                 // before or while the EA has issued the order (for example: processing time for
                 // trade requests can be from 2 to 7 seconds, but the variable Option[OPT_TRADE_PAUSE_SECONDS]
                 // has been set to 10 seconds)
                 giAction=ACT_EXIT_START;
                 iCnt=0; // note
                 break;                                       
      default:   //   2: ERR_COMMON_ERROR
                 //   5: ERR_OLD_VERSION
                 //  64: ERR_ACCOUNT_DISABLED
                 //  65: ERR_INVALID_ACCOUNT
                 // 131: ERR_INVALID_TRADE_VOLUME (Program logic)
                 // 133: ERR_TRADE_DISABLED
                 // 139: ERR_ORDER_LOCKED // order locked (and can not be cancelled), program logic must be changed
                 // 140: ERR_LONG_POSITIONS_ONLY_ALLOWED
                 // 141: ERR_TOO_MANY_REQUESTS
                 GlobalVariable("_StopTrading",0,true);
                 break;
    }
    //---------------------------------------------------------------- publish errors encountered
    if(giAction != ACT_SUCCESS) {
      Msg(0,"OrderProcess: error",giError,ErrorDescription2(giError),sMsg);
      if(cmd!=iPreviousCmd) Msg(0,"OrderProcess: changing cmd from",CmdToStr(iPreviousCmd),"to",CmdToStr(cmd));
      if(iCnt>Options[OPT_ORDER_RETRY_ATTEMPTS]) Msg(GlobalVariable("_StopTrading",0,true),"OrderProcess: retries exceeded:");
      if(GlobalVariable("_StopTrading")==true) giAction=Msg(ACT_EXIT_EA,"OrderProcess: severe error - EXITING EA!");
    }
    giCmd=cmd;
    iCnt++;
  }
  if(cmd<=OP_SELLSTOP) return(iTicket);
  return(giAction == ACT_SUCCESS);
}

//+------------------------------------------------------------------+
//| Function..: OrderResume                                          |
//| Parameters: tResume - time, based on TimeCurrent(), at which     |
//|                       trading may be resumed.                    |
//|                       If the parameter is not passed then the    |
//|                       execution of the expert is suspended for   |
//|                       the interval between the current time and  |
//|                       the time previously passed to the function.|
//| Purpose...: Get/Set time at which trading may be resumed.        |
//+------------------------------------------------------------------+
void OrderResume(datetime tResume=0) {
  static datetime t;
  
  if(tResume>0) t=MathMax(t,tResume);
  else if(t>TimeCurrent()) Sleep((t-TimeCurrent())*1000);
}

//+------------------------------------------------------------------+
//| Function..: OrderSend2                                           |
//| Parameters: Same as OrderSend() except for:                      |
//|             cColor - Color of the opening arrow on the chart.    |
//|                      If the parameter is passed as CLR_DEF the   |
//|                      default color scheme of gcColorScheme[] is  |
//|                      used.                                       | 
//| Purpose...: Open a position or place a pending order like MT4    |
//|             function OrderSend() but with error handling.        |
//| Returns...: iTicket - ticket number assigned to the order by the |
//|             trade server, or -1 if it fails. GetLastError2() may |
//|             be called or giError value retrieved to obtain the   |
//|             error information. The value of the global variable  |
//|             giAction indicates the severity of the error, refer  |
//|             to the notes of OrderProcess().                      | 
//| Notes.....: Adjusts the opening price of a pending order if it   |
//|             is too close to the market.                          |
//|             Adjusts StopLoss and TakeProfit if too close to the  |
//|             market.                                              |
//|             Converts pending orders rejected by the server for   |
//|             being too close to market automatically into market  |
//|             orders.                                              |
//|             Prevents trading after severe warnings on system     |
//|             failure or program logic.                            |
//|             Enforces closure of all orders after error 148 has   |
//|             been issued before a new order can be placed.        |
//|             Verifies that funds are sufficient to place an order.|
//+------------------------------------------------------------------+
int OrderSend2(string sSymbol, int cmd, double dLots, double dPrice, int iSlippage, double dSL, double dTP, string sComment="", int iMagic=0, datetime tExpire=0, color cColor=CLR_DEF) {
  int k=cmd%2;                                                      // determine if Buy/Sell type of order to be made
  
  if(GlobalVariable("_OpenNewOrders")==false) GlobalVariable("_OpenNewOrders",0,OrdersOpen()==0);
  if(GlobalVariable("_OpenNewOrders")==false) {
    giAction=ACT_EXIT_START;                                        // sin bin!
    return(-1);
  }
  if(!OrderCheckFunds(sSymbol,k,dLots)) return(-1);
  //------------------------------------------------------------------
  if(cColor==CLR_DEF)                           cColor=gcColorScheme[cmd];
  if(!GetMarketInfo(sSymbol))                   return(ErrorSet(-3,-1,ACT_CAN_RETRY));
  if(cmd<=OP_SELL)                              dPrice=Price[k];
  else if(cmd==OP_BUYLIMIT || cmd==OP_SELLSTOP) dPrice=NormalizeDouble(MathMin(dPrice,Price[k]-gdStopLevel*gdPoint),giDigits);
  else if(cmd==OP_SELLLIMIT || cmd==OP_BUYSTOP) dPrice=NormalizeDouble(MathMax(dPrice,Price[k]+gdStopLevel*gdPoint),giDigits);
  if(dSL!=0) {
    if(k==OP_BUY) dSL=MathMin(dSL,dPrice-(gdStopLevel+gdSpread)*gdPoint);
    else          dSL=MathMax(dSL,dPrice+(gdStopLevel+gdSpread)*gdPoint);
  }
  if(dTP!=0) {
    if(k==OP_BUY) dTP=MathMax(dTP,dPrice+gdStopLevel*gdPoint);
    else          dTP=MathMin(dTP,dPrice-(gdStopLevel+gdSpread)*gdPoint);
  }
  dSL=NormalizeDouble(dSL,giDigits);
  dTP=NormalizeDouble(dTP,giDigits);
  string sMsg=StringConcatenate("Ask=",Price[0]," Bid=",Price[1]," MarketInfo(",sSymbol,",MODE_STOPLEVEL)=",gdStopLevel," OrderSend(",sSymbol,",",CmdToStr(cmd),",",dLots,",",dPrice,",",iSlippage,",",dSL,",",dTP,",",sComment,",",iMagic,",",tExpire,",",cColor,")");
  return(OrderProcess(cmd,sSymbol,sMsg,-1,cColor,0,dLots,dPrice,iSlippage,dSL,dTP,tExpire,sComment,iMagic));
}

//+------------------------------------------------------------------+
//| Function..: OrdersOpen                                           |
//| Purpose...: Determine the number of positions open and orders    |
//|             pending.                                             |
//| Returns...: iOrders - Count of market and pending orders,        |
//|             or -1 if an error was encountered.                   |
//| Notes.....: Anomaly with OrdersTotal() which includes cancelled  |
//|             and closed orders.                                   |
//+------------------------------------------------------------------+
int OrdersOpen() {
  int iTotal=OrdersTotal(), iOrders, i;
  
  for(i=0; i < iTotal; i++) {                                       // For all orders of the terminal
    if(!OrderSelect(i, SELECT_BY_POS)) return(-1);
    if(OrderCloseTime()==0) iOrders++;
  }
  return(iOrders);
}

//+------------------------------------------------------------------+
//| Function..: ReduceLots                                           |
//| Purpose...: recalculate lots after error 134 ERR_NOT_ENOUGH_MONEY|
//+------------------------------------------------------------------+
double ReduceLots(double dLotPrevious, double dMarginRequired, double dLotStep) {
  if(dMarginRequired<=0.0 || dLotStep<=0.0) return(0.0);
  double vol=NormalizeDouble(AccountFreeMargin()/(dMarginRequired*2),2)*dLotStep;
  if(vol<dLotPrevious && vol>0.0) return(vol);
  return(0.0);
}

//+------------------------------------------------------------------+
//| Function..: SemLock                                              |
//| Thank You.: Andrey Khatimlianskyi for his code & exposé on how to|
//|             handle semaphore locks http://articles.mql4.com/141  |
//|             Adapted for OrdersSuite.mqh                          |
//| Parameters: iID    - Unique number identifying the Expert or a   |
//|                      process within the expert, or a different   |
//|                      number for each chart when using the same   |
//|                      expert.                                     |
//|                      Number to be in the range 1 to one million. |
//|             iRetry - Number of seconds to wait for the semaphore |
//|                      to be unlocked.                             |
//|             iPause - Pause (in seconds) required to be enforced  |
//|                      after the semaphore is unlocked. Example a  |
//|                      Server might require a pause of 3 seconds   |
//|                      in between placing or closing orders.       |
//| Purpose...: Obtain the sole handle for trading via the use of a  |
//|             semaphore and enforce a pause between trades of the  |
//|             expert(s) as directed by the value of <iPause> and   |
//|             avoid error 146 (ERR_TRADE_CONTEXT_BUSY).            |
//|             When the semaphore is locked it acquires the value   |
//|             of <iID>, otherwise the value indicates the time     |
//|             that the semaphore was last accessed.                |
//| Returns...: bool Success - The global variable SEM was assigned  |
//|                            with value <iID>,                     |
//|                  False   - The semaphore could not be locked,    |
//|                            the error number can be obtained from |
//|                            GetLastError2() or giError.           |
//| Notes.....: In case of abnormal termination (caused by the PC or |
//|             the user) the semaphore lock, if present, should be  |
//|             removed by adding on the first line of the expert    |
//|             deinit() function the following code (replacing iID  |
//|             with the number identifying the expert or process):  |
/*+------------------------------------------------------------------+       
                if(!IsTesting() &&
                GlobalVariableSetOnCondition(SEM_ID,TimeLocal(),iID))
                Print("semaphore unlocked");
//+-----------------------------------------------------------------*/                 
//|             As a last resort pressing F3 gives access to the     |
//|             GlobalVariable "_ThreadUsedBy" which can be either   |
//|             deleted or modified, and the other experts closed    |
//|             and rerun.                                           |
//|             To allow a script to close all orders promptly while |
//|             other experts are running, do not call SemLock() from|
//|             within the script.                                   |
//+------------------------------------------------------------------+
bool SemLock(int iID=1, int iRetry=30, int iPause=SEM_PAUSE) {
  giError=0;
  GetLastError();
  if(IsTesting()) return(true);
  int    iStartWaitingTime=GetTickCount(), i;
  double dSemVal;
  
  while(true) {
    if(IsStopped()) return(Msg(ErrorSet(-1),"SemLock() Error: -1",ErrorDescription2(-1)));
    if(GetTickCount()-iStartWaitingTime > iRetry*1000) return(ErrorSet(-2)); // note error msg not printed
    if(GlobalVariableCheck(SEM_ID)) break;
    else {
      giError=GetLastError();
      if(giError!=0) {
        Sleep(Msg(100,"SemLock() GlobalVariableCheck Error:",giError,ErrorDescription2(giError)));
        continue;
      }
    }
    if(GlobalVariableSet(SEM_ID,iID ) > 0 ) return(ErrorSet(0,1));
    else {
      giError=GetLastError();
      if(giError!=0) {
        Sleep(Msg(100,"SemLock() GlobalVariableSet Error:",giError,ErrorDescription2(giError)));
        continue;
      }
    }
  }
  while(true) {
    if(IsStopped()) return(Msg(ErrorSet(-1),"SemLock() Error: -1",ErrorDescription2(-1))); 
    if(GetTickCount()-iStartWaitingTime > iRetry*1000) return(ErrorSet(-2)); // note error msg not printed
    dSemVal=GlobalVariableGet(SEM_ID);
    if(dSemVal==0) {
      giError=GetLastError();
      Sleep(Msg(100,"SemLock() GlobalVariableGet Error:",giError,ErrorDescription2(giError)));
      continue;
    }
    if(dSemVal > _MILLION && GlobalVariableSetOnCondition(SEM_ID, iID, dSemVal)) {
      while(TimeLocal()-dSemVal < iPause) i+=0; // enforce the trade pause  
      return(ErrorSet(0,1));
    }
    else {
      // if not, 2 reasons for it are possible: SemLock() has the value of another <iID> (then one has to wait),
      // or an error occurred (this is what we will check)
      giError=GetLastError();
      if(giError!=0) {
        Msg(0,"SemLock() GlobalVariableSetOnCondition Error:",giError,ErrorDescription2(giError));
        continue;
      }
    }
    // if there is no error, it means that 0 < SemLock() < _MILLION (another expert is trading),
    // then display information and wait...
    Comment(StringConcatenate("Thread locked by ",dSemVal));
    Sleep(1000);
    Comment("");
  }
}

//+------------------------------------------------------------------+
//| Function..: SemUnlock                                            |
//| Thank You.: Andrey Khatimlianskyi for his code & exposé on how to|
//|             handle semaphore locks http://articles.mql4.com/141  |
//|             Adapted for OrdersSuite.mqh                          |     
//| Parameters: iID    - Unique number identifying the Expert or a   |
//|                      process within the expert.                  |
//|                      Number to be in the range 1 to one million. |
//|             iRetry - Number of seconds to wait for the semaphore |
//|                      to be unlocked.                             |
//| Purpose...: Release sole handle for trading by the EA.           |
//|             The semaphore global variable <SEM_ID> is created if |
//|             it does not exist.                                   |
//| Returns...: bool Success - The semaphore was unlocked.           |
//|                  False   - The semaphore could not be unlocked,  |
//|                            the error number can be obtained from |
//|                            GetLastError2() or giError.           |
//+------------------------------------------------------------------+
bool SemUnlock(int iID=1, int iRetry=30) {
  giError=0;
  GetLastError();
  if(IsTesting()) return(true); 
  int iStartWaitingTime=GetTickCount();
  
  while(true) {
    if(IsStopped()) return(Msg(ErrorSet(-1),"SemUnlock() Error: -1",ErrorDescription2(-1)));
    if(GetTickCount()-iStartWaitingTime > iRetry*1000) return(ErrorSet(-2)); // note error msg not printed
    if(GlobalVariableCheck(SEM_ID)) {
      if(GlobalVariableGet(SEM_ID) > _MILLION) return(ErrorSet(0,1));
      return(ErrorSet(0,GlobalVariableSetOnCondition(SEM_ID,TimeLocal(),iID)));
    }
    if(GlobalVariableSet(SEM_ID,TimeLocal()) > 0) return(ErrorSet(0,1));
    else {
      giError=GetLastError();
      if(giError!=0) Msg(0,"SemUnlock() GlobalVariableSet Error:",giError,ErrorDescription2(giError));
    }
    Sleep(100);
  }
}

//+------------------------------------------------------------------+
//| Function..: SeqNum                                               |
//| Parameters: None.                                                |
//| Purpose...: Generate a sequential number.                        |
//| Returns...: dSeqNum - next sequence number or -1 if an error     |
//|                       occured, which can be determined by        |
//|                       calling GetLastError2() or giError.        |
//| Notes.....: MT4 keeps the value of the global variable at the    |
//|             client terminal for 4 weeks since the last access.   |                        
//|             Use SeqNum() to generate a unique identity for each  |
//|             order (and passed via parameter <magic> number, or   |
//|             converted to a string and passed via parameter       |
//|             <comment> to the OrderSend2 function) as the trade   |
//|             servers of some brokers do modify the ticket number  |
//|             of a pending order when it changes to a market order.|
//|             The same sequence number could, for example, be used |
//|             to identify the two positions of a straddle order.   |
//|             Use SemLock() and SemUnlock() if the sequence number |
//|             is shared across experts.                            |
//| Example...: if(SemLock()) {                                      |
//|               double dSeqNum=SeqNum();                           |
//|               SemUnlock();                                       |
//|             }                                                    |
//+------------------------------------------------------------------+
double SeqNum() {
  double dSeqNum=1;
  
  if(GlobalVariableCheck("_SequenceNumber")) {
    dSeqNum=GlobalVariableGet("_SequenceNumber")+1;
    if(dSeqNum==1) dSeqNum=-1;
  }
  if((dSeqNum>0) && (GlobalVariableSet("_SequenceNumber",dSeqNum) == 0)) dSeqNum=-1;
  if(dSeqNum==-1) ErrorSet(GetLastError());
  return(dSeqNum);
}
//+------------------------------------------------------------------+

