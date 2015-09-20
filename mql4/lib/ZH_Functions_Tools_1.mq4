//+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                                                 ZH_Functions_Tools_1.mq4 |
//|                                                                                                                                                 Copyright � Zhunko       |
//|07.11.2007-28.02.2008   

投放光谱

1.A function for automated distributing of Фcolor spectrum.
AutoColor (inversion of color distribution true/false = red-violet/violet-red, 
true/false = filling an array/returning a fixed value (0 - 1535),
if ArraySingle true/false = amount of spectral lines/value (1 - 1535) for calculating a spectral line,
a one-dimension arrays to be filled for ArraySingle = true); 
int AutoColor (bool InversColor, bool ArraySingle, int AmountSpectralLine, int Set_Color[]); 


2. The function returns string name of a timeframe (TF) by TF number.
NumberInString (TF number from 0 to 8); 
string NumberInString (int NumberTF); 

3. A function to calculate the register length of a number before its decimal point.
Exponent (a number for calculations, a limitation on register length calculations); 
The register length of a number in the format of 1.234х10^p is its exponent (p) with the base number of ten. 
int Exponent (double Value, int Limiter); 


4. Visualization of array data with double-precise data in comments.
DoubleArrayInComment (array name, the amount of decimal places to be visualized, 1-dimensional array to be visualized, 
2-dimensional array to be visualized); 
string DoubleArrayInComment (string NameArray, int digits, double Array1[], double Array2[][]); 

5. Visualization of array data with integer data in comments.
IntArrayInComment (array name, 1-dimensional array to be visualized, 2-dimensional array to be visualized); 
string IntArrayInComment (string NameArray, int Array1[], int Array2[][]); 

                                                                                                                         MF ZHUNKO zhunko@mail.ru |
//+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������������� ��� ������ � ������� ��������� �������� ZZ_AIASM X-XXXX, ZM_AIASM Checking Files.                                                               |
//| ����� �������. ����� ������� ������� ������������ ������������ � ������ ���������� ���������.                                                                            |
//+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| 1.������� ��� ��������������� ������������� ������� �����.---------------------------------------------------------------------------------------------------------------+
//|   AutoColor (�������� ������������� ����� true/false = �������-����������/����������-�������, true/false = ���������� �������/������� �������������� �������� (0 - 1535),|
//|              ���� ArraySingle true/false = ���������� ������������ �����/�������� (1 - 1535) ��� ���������� ����� ������������ �����,                                    |
//|              ���������� ������ ��� ���������� ��� ArraySingle = true);                                                                                                   |
//|   int AutoColor (bool InversColor, bool ArraySingle, int AmountSpectralLine, int Set_Color[]);                                                                           |
//| 2.������� ���������� ��������� �������� �� �� ������ ��.-----------------------------------------------------------------------------------------------------------------+
//|   NumberInString (����� �� �� "0" �� "8");                                                                                                                               |
//|   string NumberInString (int NumberTF);                                                                                                                                  |
//| 3.������� ��� ���������� ���������� �������� ����� �� ���������� �����.--------------------------------------------------------------------------------------------------+
//|   Exponent (����� ��� ����������, ����������� ���������� ��������);                                                                                                      |
//|   ���������� �������� ����� ������� 1,234�10^p ��� ���������� ������� (p) ��� ��������� ������.                                                                          |
//|   int Exponent (double Value, int Limiter);                                                                                                                              |
//| 4.������������ ������ ������� � ������� ������� �������� � ������������.-------------------------------------------------------------------------------------------------+
//|   DoubleArrayInComment (��� �������, ��������������� ���������� ������ ����� �������, 1-� ������ ��������������� ������, 2-� ������ ��������������� ������);             |
//|   string DoubleArrayInComment (string NameArray, int digits, double Array1[], double Array2[][]);                                                                        |
//| 5.������������ ������ ������� � �������������� ������� � ������������.---------------------------------------------------------------------------------------------------+
//|   IntArrayInComment (��� �������, 1-� ������ ��������������� ������, 2-� ������ ��������������� ������);                                                                 |
//|   string IntArrayInComment (string NameArray, int Array1[], int Array2[][]);                                                                                             |
//+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright � 2007 Zhunko"
#property link      "zhunko@mail.ru"
#property library
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
//1===������ ��� ��������������� ������������� ������� ����� �� �������.==================================================================================================================================
// AutoColor (�������� ������������� ����� true/false = ����������-�������/�������-����������, true/false = ���������� �������/������� �������������� �������� (0 - 1535),
//            ���� ArraySingle true/false = ���������� ������������ �����/�������� (0 - 1535) ��� ���������� ����� ������������ �����, ���������� ������ ��� ���������� ��� ArraySingle = true);
// ��� ������ ������� � ������ ArraySingle = true ���� �������� ������ "Set_Color[]".
int AutoColor (bool& InversColor, bool& ArraySingle, int& AmountSpectralLine, int& Set_Color[])
 {
  int Begin;
  int End;
  int i, j;
  int n = 0;
  int RC, GC, BC;
  int StepColor;
  // �������� �� ������������ ��������.
  if (InversColor == true)
   {
    if (AmountSpectralLine < 0) return (16711680);
    if (AmountSpectralLine > 1535) return (16711935);
   }
  if (InversColor == false)
   {
    if (AmountSpectralLine < 0) return (16711935);
    if (AmountSpectralLine > 1535) return (16711680);
   }
  // ���������� ������ ������.
  if (ArraySingle == true) // ��� ������ �������� ����� � ������.
   {
    Begin = 0;
    End = 1535;
    StepColor = 1535 / AmountSpectralLine;
   }
  else // ��� �������� �������������� ��������.
   {
    Begin = AmountSpectralLine;
    End = AmountSpectralLine;
    StepColor = 1;
   }
  // ����� � ����������.
  for (j = Begin; j <= End; j += StepColor, n++)
   {
    if (InversColor == true) i = MathAbs (j + StepColor - 1535);
    if (InversColor == false) i = j;
    //----
    if (0 <= i && i <= 255) // ���� �1.
     {
      RC = 255;
      GC = 0;
      BC = 16711680 - 65536 * i;
     }
    if (256 <= i && i <= 511) // ���� �2.
     {
      RC = 255;
      GC = 256 * (i - 256);
      BC = 0;
     }
    if (512 <= i && i <= 767) // ���� �3.
     {
      RC = 767 - i;
      GC = 65280;
      BC = 0;
     }
    if (768 <= i && i <= 1023) // ���� �4.
     {
      RC = 0;
      GC = 65280;
      BC = 65536 * (i - 768);
     }
    if (1024 <= i && i <= 1279) // ���� �5.
     {
      RC = 0;
      GC = 65280 - 256 * (i - 1024);
      BC = 16711680;
     }
    if (1280 <= i && i <= 1535) // ���� �6.
     {
      RC = i - 1280;
      GC = 0;
      BC = 16711680;
     }
    if (ArraySingle == true)
     {
      ArrayResize (Set_Color, n + 1);
      Set_Color[n] = RC + GC + BC;
     }
   }
  return (RC + GC + BC);
 }
//========================================================================================================================================================================================================
//2===������� �������������� ����������� ������������� �� � ��������� �� ������ ��.=======================================================================================================================
// ������� ���������� ��������� �������� �� �� ������ ��.
// NumberInString (����� �� �� "0" �� "8");
string NumberTFInStringName (int NumberTF)
 {
  int    i;
  string TimeFram = "";
  int    TimFram_Sym[9][3] = {77, 49, 0, 77, 53, 0, 77, 49, 53, 77, 51, 48, 72, 49, 0, 72, 52, 0, 68, 49, 0, 87, 49, 0, 77, 78, 49}; // ���������� ������������� ��������� �������� ��.
  //----
  for (i = 0; i < 3; i++) TimeFram = TimeFram + StringSetChar ("", 0, TimFram_Sym[NumberTF][i]);
  return (StringTrimRight (TimeFram));
 }
//========================================================================================================================================================================================================
//3===������� ��� ���������� ���������� �������� ����� �� ���������� �����.===============================================================================================================================
// Exponent (����� ��� ����������, ����������� ���������� ��������);
// ���������� �������� ����� ������� 1,234�10^p ��� ���������� ������� (p) ��� ��������� ������.
int Exponent (double& Value, int& Limiter)
 {
  int n;
  int pow; // ���������� �������.
  int value = MathAbs (Value);                        // ���� ���������� ��������. 
  //----
  if (value * MathPow (10, Limiter) == 0) return (0); // ���� ����� ����� ����, �� ���������� ����.
  if (value < 1)                                      // ���� ����� ������ �������.
   {
    for (pow = 0; pow <= Limiter; pow++)
     {
      n = value * MathPow (10, pow);
      if (1 <= n && n < 10) break;                    // ���������� �� ��������� ������� �������. 
     }
   }
  if (value >= 1)                                     // ���� ����� ������ ��� ����� �������.
   {
    for (pow = 0; pow >= -Limiter; pow--)
     {
      n = value * MathPow (10, pow);
      if (1 <= n && n < 10) break;                    // ���������� �� ��������� ������� �������. 
     }
   } 
  return (-pow);                                      // ���������� � �������� ������. 
 }
//========================================================================================================================================================================================================
//4===������������ ������ ������� � ������� ������� �������� � ������������.==============================================================================================================================
// string DoubleArrayInComment (��� �������, ��������������� ���������� ������ ����� �������, 1-� ������ ��������������� ������, 2-� ������ ��������������� ������);
// ������� ���������� �����, ���������� ���������������� �������.
string DoubleArrayInComment (string& NameArray, int& digits, double& Array1[], double& Array2[][])
 {
  int    i1, i2;
  string Headline = "";
  string Str[];
  int Range11 = ArrayRange (Array1, 0);
  int Range21 = ArrayRange (Array2, 0);
  int Range22 = ArrayRange (Array2, 1);
  int Cycle1 = MathMax (Range11, Range21);
  int Cycle2 = Range22;
  ArrayResize (Str, Cycle1 + 1);
  //----
  for (i1 = 0; i1 < Cycle1; i1++)
   {
    if (Range11 != 0) Str[i1] = NameArray + "[" + Range11 + "] = {";
    if (Range21 != 0 && Range22 != 0) Str[i1] = NameArray + "[" + i1 + "][" + Range22 + "] = {";   
    if (Range11 != 0) Str[i1] = Str[i1] + DoubleToStr (Array1[i1], digits) + ", ";
    for (i2 = 0; i2 < Cycle2; i2++) if (Range21 != 0 && Range22 != 0) Str[i1] = Str[i1] + DoubleToStr (Array2[i1][i2], digits) + ", ";
    Str[i1] = StringSubstr (Str[i1], 0, StringLen (Str[i1]) - 2) + "};\n";
   }
  for (i1 = 0; i1 < Cycle1; i1++) Headline = Headline + Str[i1];
  Comment (Headline);
  return (Headline);
 }
//========================================================================================================================================================================================================
//5===������������ ������ ������� � �������������� ������� � ������������.================================================================================================================================
// string DoubleArrayInComment (��� �������, ��������������� ���������� ������ ����� �������, 1-� ������ ��������������� ������, 2-� ������ ��������������� ������);
// ������� ���������� �����, ���������� ���������������� �������.
string IntArrayInComment (string& NameArray, int& Array1[], int& Array2[][])
 {
  int    i1, i2;
  string Headline = "";
  string Str[];
  int Range11 = ArrayRange (Array1, 0);
  int Range21 = ArrayRange (Array2, 0);
  int Range22 = ArrayRange (Array2, 1);
  int Cycle1 = MathMax (Range11, Range21);
  int Cycle2 = Range22;
  ArrayResize (Str, Cycle1 + 1);
  //----
  for (i1 = 0; i1 < Cycle1; i1++)
   {
    if (Range11 != 0) Str[i1] = NameArray + "[" + Range11 + "] = {";
    if (Range21 != 0 && Range22 != 0) Str[i1] = NameArray + "[" + i1 + "][" + Range22 + "] = {";   
    if (Range11 != 0) Str[i1] = Str[i1] + DoubleToStr (Array1[i1], 0) + ", ";
    for (i2 = 0; i2 < Cycle2; i2++) if (Range21 != 0 && Range22 != 0) Str[i1] = Str[i1] + DoubleToStr (Array2[i1][i2], 0) + ", ";
    Str[i1] = StringSubstr (Str[i1], 0, StringLen (Str[i1]) - 2) + "};\n";
   }
  for (i1 = 0; i1 < Cycle1; i1++) Headline = Headline + Str[i1];
  Comment (Headline);
  return (Headline);
 }
//========================================================================================================================================================================================================
//�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������