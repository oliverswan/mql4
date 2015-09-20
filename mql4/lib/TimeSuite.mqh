//+------------------------------------------------------------------+
//|                                                    TimeSuite.mq4 |
//|                                         Copyright © 2008, sx ted |
//|                                               sxted@talktalk.net |
//| Purpose: Library of functions usefull for time calculations and  |
//|          determining if a report is imminent.                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, sx ted"
#property link      "sxted@talktalk.net"

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define TIME_ROWS              18                                   // Number of Cities catered for in table
#define TIME_STD_DIFF           0                                   // Standard offset with GMT
#define TIME_DST_DIFF           1                                   // Dailight Saving Time difference compared to GMT
#define TIME_DST_START_MN       2                                   // Dailight Saving Time start month
#define TIME_DST_START_WM       3                                   // Dailight Saving Time start Week index position in
                                                                    // month (1=1st, 2=2nd, 3=3rd, 5=last in the month)
#define TIME_DST_START_DW       4                                   // Dailight Saving Time start day of the week
                                                                    // (0=Sunday)
#define TIME_DST_END_MN         5                                   // Dailight Saving Time end month
#define TIME_DST_END_WM         6                                   // Dailight Saving Time end Week index position in
                                                                    // month (1=1st, 2=2nd, 3=3rd, 5=last in the month)
#define TIME_DST_END_DW         7                                   // Dailight Saving Time end day of the week
                                                                    // (0=Sunday)

//+------------------------------------------------------------------+
//| Function..: TimeAt                                               |
//| Parameters: t     - Time to be converted.                        |
//|             sCity - UN Locode to identify the city, for codes    |
//|                     refer to http://www.timegenie.com/city.time/ |
//|             ToGMT - 1=convert time <t> at <sCity> to GMT time,   |
//|                     0=convert GMT time <t> to time of <sCity>.   |
//| Purpose...: Convert a GMT time (current or future) to the time   |
//|             of another City, or vice versa.                      |
//| Returns...: tTime - Time at City <sCity> or -1 if City not found.|
//| Notes.....: Specs: http://webexhibits.org/daylightsaving/g.html  |
//|             Europe start & end at 1 am UTC, Moscow start & end   |
//|             at 2 am local time are ignored as fx market closed   |
//|             on the days that DST start and end.                  |
//|             Brazil rules vary quite a bit from year to year,     |
//|             data table only caters for DST Oct 2007 to Feb 2008. |
//| Example...: // if in Brussels:                                   |
/*+------------------------------------------------------------------+
Print("Time GMT: ",TimeToStr(TimeAt(0,"BEBRU"),TIME_DATE|TIME_SECONDS));
//+-----------------------------------------------------------------*/ 
datetime TimeAt(datetime t=0, string sCity="BEBRU", bool ToGMT=1) {
  int    i, iYear;
  string s[TIME_ROWS]={"BEBRU", // Brussels (Bruxelles), Belgium
                       "NZQEL", // Wellington, New Zealand
                       "AUSYD", // Sydney, New South Wales, Australia
                       "JPTYO", // Tokyo, Japan
                       "CNBJS", // Beijing (Peking), China
                       "HKHKG", // Hong Kong, Hong Kong S.A.R. (Xianggang)
                       "INBOM", // Mumbai (Bombay), India
                       "RUMOW", // Moscow (Moskva), Russian Federation
                       "SARUH", // Riyadh, Saudi Arabia
                       "ZAJNB", // Johannesburg, Gauteng, South Africa
                       "DEBER", // Berlin, Germany (Deutschland)
                       "FRPAR", // Paris, France
                       "GBLON", // London, GB (UK)
                       "GBGNW", // Greenwich, GB (UK)
                       "BRRIO", // Rio de Janeiro, Brazil
                       "USNYC", // New York, United States
                       "CAOTT", // Ottawa, Ontario, Canada
                       "CAVAN"  // Vancouver, British Columbia, Canada
                      };
  double d[TIME_ROWS][8]={ +1,+1,03,5,0,10,5,0, // BEBRU Brussels (Bruxelles), Belgium
                          +12,+1,09,5,0,04,1,0, // NZQEL Wellington, New Zealand
                          +10,+1,10,5,0,03,5,0, // AUSYD Sydney, New South Wales, Australia
                           +9,+0,00,0,0,00,0,0, // JPTYO Tokyo, Japan
                           +8,+0,00,0,0,00,0,0, // CNBJS Beijing (Peking), China
                           +8,+0,00,0,0,00,0,0, // HKHKG Hong Kong, Hong Kong S.A.R. (Xianggang)
                         +5.5,+0,00,0,0,00,0,0, // INBOM Mumbai (Bombay), India
                           +3,+1,03,5,0,10,5,0, // RUMOW Moscow (Moskva), Russian Federation
                           +3,+0,00,0,0,00,0,0, // SARUH Riyadh, Saudi Arabia
                           +2,+0,00,0,0,00,0,0, // ZAJNB Johannesburg, Gauteng, South Africa
                           +1,+1,03,5,0,10,5,0, // DEBER Berlin, Germany (Deutschland)
                           +1,+1,03,5,0,10,5,0, // FRPAR Paris, France
                           +0,+1,03,5,0,10,5,0, // GBLON London, GB (UK)
                            0,+0,00,0,0,00,0,0, // GBGNW Greenwich, GB (UK)
                           -3,+1,10,3,0,02,3,0, // BRRIO Rio de Janeiro, Brazil
                           -5,+1,03,2,0,11,1,0, // USNYC New York, United States
                           -5,+1,03,2,0,11,1,0, // CAOTT Ottawa, Ontario, Canada
                           -8,+1,03,2,0,11,1,0  // CAVAN Vancouver, British Columbia, Canada
                        };
  for(i=0; i<TIME_ROWS; i++) {
    if(s[i]==sCity) break;
  }
  if(i>=TIME_ROWS) return(-1);
  if(t==0) t=TimeCurrent();
  t=t+d[i][TIME_STD_DIFF]*PERIOD_H1*60*(1+ToGMT*(-2)); // Standard offset
  if(d[i][TIME_DST_DIFF]==0) return(t);
  if(d[i][TIME_DST_START_MN] > d[i][TIME_DST_END_MN]) iYear=PERIOD_D1*365*60;
  if((t >= TimeExSpecs(t,d[i][2],d[i][3],d[i][4])) && (t <= TimeExSpecs(t+iYear,d[i][5],d[i][6],d[i][7]))) t=t+d[i][TIME_DST_DIFF]*PERIOD_H1*60*(1+ToGMT*(-2));
  return(t); 
}

//+------------------------------------------------------------------+
//| Function..: TimeExSpecs                                          |
//| Parameters: t  - Time to be used as template, usually the local  |
//|                  time.                                           |
//|             MN - Month to be used in the return value.           |
//|             WM - Week index position in the month (1=1st, 2=2nd, |
//|                  3=3rd, 4=4th, 5=last). Specifying 5 retrieves   |
//|                  the last occurence of the day of the week which |
//|                  has the value of parameter DW.                  |
//|             DW - Day of the week (0=Sunday,1,2,3,4,5,6=Saturday).|
//|             HH - Hour (24 hours) to be used in the return value. |
//|             MM - Minutes to be used in the return value.         |
//| Purpose...: Derive next report time from specs.                  |
//| Returns...: Report time.                                         |
//| Example...: // Determine start of daylight saving time in Europe |
//|             // which occurs in March on the last Sunday          |
//|             datetime tStartDST=TimeExSpecs(TimeLocal(),3,5,0);   |
//|             Print("DST in Europe ", TimeToStr(tStartDST));       |
//+------------------------------------------------------------------+ 
datetime TimeExSpecs(datetime t, int MN=1, int WM=1, int DW=0, int HH=0, int MM=0) {
  t=StrToTime(StringConcatenate(TimeYear(t),".",MN,".1 ",HH,":",MM));
  while(TimeDayOfWeek(t) != DW) t=t+PERIOD_D1*60;
  if(WM > 1) t=t+(PERIOD_W1*(WM-1))*60;
  if(TimeMonth(t) != MN) t=t-PERIOD_W1*60;
  return(t);
}

//+------------------------------------------------------------------+
//| Function..: TimeInDailyClose                                     |
//| Parameters: tTime   - Time to be checked.                        |
//|             sStart  - Start time of the range for which <tTime>  |
//|                       is to be verified, using the notation      |
//|                       "HH:MM" where: HH=Hour and MM=Minute.      |
//|             sEnd    - End time of the range, ditto.              |
//|             iAdjust - Number of minutes to adjust range times:   |
//|                       (defaults to 15 minutes)                   |
//|                       <sStart> is adjusted to start earlier by   |
//|                                the value of <iAdjust> and,       |
//|                       <sEnd>   is adjusted to start later by     |
//|                                the number of <iAdjust> minutes.  |
//| Purpose...: Determine if the time <tTime> falls in the Daily     |
//|             Close period of an exchange defined by <sStart> and  |
//|             <sEnd>.                                              |
//| Returns...: Zero if time <tTime> is not in the range defined by  |
//|             the <sStart> and <sEnd> parameters, or the number of |
//|             seconds remaining before the end of the range period |
//|             <sEnd> is reached.                                   |
//| Example...: if(TimeInDailyClose(TimeCurrent(),"23:15","00:00")>0)|
//|               return(-1);  // can not trade                      |
//| See Also..: TimeInRange()                                        |
//+------------------------------------------------------------------+
int TimeInDailyClose(datetime tTime, string sStart, string sEnd, int iAdjust=15) {
  if(sStart==sEnd) return(0);
  datetime tStart=(tTime/86400)*86400 + StrToInteger(StringSubstr(sStart,0,2))*3600 + StrToInteger(StringSubstr(sStart,3,2))*60 - iAdjust*60;
  datetime tEnd=(tTime/86400)*86400 + StrToInteger(StringSubstr(sEnd,0,2))*3600 + StrToInteger(StringSubstr(sEnd,3,2))*60 + iAdjust*60;
  
  if(tTime<=tEnd && tStart>tEnd) return(tEnd-tTime);
  if(tEnd<tStart) tEnd=tEnd+86400*7;
  if(tTime>=tStart && tTime<=tEnd) return(tEnd-tTime);
  return(0);
}

//+------------------------------------------------------------------+
//| Function..: TimeInRange                                          |
//| Parameters: tTime   - Time to be checked.                        |
//|             sStart  - Start time of the range for which <tTime>  |
//|                       is to be verified, using the notation      |
//|                       "D HH:MM" where:                           |
//|                       D=Day of week (0-Sunday,1,2,3,4,5,6),      |
//|                       HH=Hour and MM=Minute.                     |
//|             sEnd    - End time of the range, ditto.              |
//|             iAdjust - Number of minutes to adjust range times:   |
//|                       (defaults to 15 minutes)                   |
//|                       <sStart> is adjusted to start later by the |
//|                                number of <iAdjust> minutes and,  |
//|                       <sEnd>   is adjusted to start earlier by   |
//|                                the number of <iAdjust> minutes.  |
//| Purpose...: Determine if the time <tTime> falls in the period    |
//|             between <sStart> and <sEnd>.                         |
//| Returns...: Zero if time <tTime> is not in the range defined by  |
//|             the <sStart> and <sEnd> parameters, or the number of |
//|             seconds remaining before the end of the range period |
//|             <sEnd> is reached.                                   |
//| Notes.....: Adjust times to finish earlier or re-start later to  |
//|             avoid possible volatility if using the function to   |
//|             check for trading session, or use <iAdjust>.         |
//| Example...: // Sleep during week end!                            |
//|           Sleep(TimeInRange(TimeAt()),"0 23:30","5 21:30")*1000);|  
//| See Also..: TimeInDailyClose()                                   |
//+------------------------------------------------------------------+
int TimeInRange(datetime tTime, string sStart, string sEnd, int iAdjust=15) {
  int      iDOW=TimeDayOfWeek(tTime);
  datetime tStart=(tTime/86400)*86400 + (StrToInteger(StringSubstr(sStart,0,1)) - iDOW)*86400 + StrToInteger(StringSubstr(sStart,2,2))*3600 + StrToInteger(StringSubstr(sStart,5,2))*60 + iAdjust*60;
  datetime tEnd=(tTime/86400)*86400 + (StrToInteger(StringSubstr(sEnd,0,1)) - iDOW)*86400 + StrToInteger(StringSubstr(sEnd,2,2))*3600 + StrToInteger(StringSubstr(sEnd,5,2))*60 - iAdjust*60;
  
  if(tTime<=tEnd && tStart>tEnd) return(tEnd-tTime);
  if(tEnd<tStart) tEnd=tEnd+86400*7;
  if(tTime>=tStart && tTime<=tEnd) return(tEnd-tTime);
  return(0);
}
//+------------------------------------------------------------------+

