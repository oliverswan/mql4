//+------------------------------------------------------------------+
//|                                               ExcelExportLib.mq4 |
//|                               Copyright 2012, Stephen Ambatoding |
//|                             http://www.forexfactory.com/sangmane |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Stephen Ambatoding"
#property link      "http://www.forexfactory.com/sangmane"
#property library

#define		APPCLASS_STANDARD            	0x00000000
#define		APPCMD_CLIENTONLY            	0x00000010
#define		DMLERR_NO_ERROR                    	  0
#define		XTYP_POKE               		0x4090
#define 		CF_TEXT             				1

#import "user32.dll"
	int DdeInitializeA(int pidInst[], int pfnCallback, int afCmd, int ulRes);
	int DdeUninitialize(int idInst);
	int DdeCreateStringHandleA(int idInst, string psz, int iCodePage=0);
	int DdeFreeStringHandle(int idInst, int iStrHandle);	
	int DdeConnect(int idInst, int iService, int iSheet, int pCC=0);
	int DdeDisconnect(int iConv);
	int DdeClientTransaction(string szData, int cbData, int iConv, int iItem, int wFmt, int wType, int dwTimeout, int pdwResult=0);	

int idInst=0, iConv=0;

int ExcelInit(string Sheet)
{
	int ptr[1] = {0};
	int iRet = DdeInitializeA(ptr, 0, APPCLASS_STANDARD | APPCMD_CLIENTONLY, 0);
	if (iRet != DMLERR_NO_ERROR)
	{
		return(0);
	}
	idInst = ptr[0];
	
	int iService = DdeCreateStringHandleA(idInst, "EXCEL", 0);
	int iSheet = DdeCreateStringHandleA(idInst, Sheet, 0);
	iConv = DdeConnect(idInst, iService, iSheet, 0);
	DdeFreeStringHandle(idInst, iService);
	DdeFreeStringHandle(idInst, iSheet);
	if (iConv == 0)
	{
		DdeUninitialize(idInst);
		return(0);
	}
	return(1);
}

void ExcelDeinit()
{
	if (iConv > 0)
		DdeDisconnect(iConv);
	if (idInst > 0)
		DdeUninitialize(idInst);
}

int ExcelWrite(string CellAddress, string CellValue)
{
	int iItem = DdeCreateStringHandleA(idInst, CellAddress, 0);
	int iRet = DdeClientTransaction(CellValue, StringLen(CellValue)+1, iConv, iItem, CF_TEXT, XTYP_POKE, 1000, 0);
	DdeFreeStringHandle(idInst, iItem);	
	return (iRet);
}
//+------------------------------------------------------------------+