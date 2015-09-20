//+------------------------------------------------------------------+
//|                                            ExcelExportOrders.mq4 |
//|                               Copyright 2012, Stephen Ambatoding |
//|                             http://www.forexfactory.com/sangmane |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Stephen Ambatoding"
#property link      "http://www.forexfactory.com/sangmane"

#property show_inputs

extern string Sheet = "Sheet1";
extern string CellAddress = "R2C2";
extern string CellValue = "From Indonesia with Love";

#import "ExcelExportLib.ex4"         
	int ExcelInit(string Sheet);
	void ExcelDeinit();
	int ExcelWrite(string CellAddress, string CellValue);

int start()
{
	int iRet;
	iRet = ExcelInit(Sheet);
	if (iRet == 0)
	{
		Alert("ExcelInit failed!");
		return (0);
	}

	iRet = ExcelWrite(CellAddress, CellValue);	
	if (iRet == 0)
	{
		Alert("ExcelWrite failed!");
	}
	
	ExcelDeinit();
	return (0);
}

