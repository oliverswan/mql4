#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

class KeyPrice {

private:
	int _priority; // 重复次数
	double _price; // 价格


public:
 	 KeyPrice() {  
 	    _priority=1;
 	    _price=0;     
    }

    void addPriority()
    {
    	_priority+=1;
    } 

    int getPriority()
    {
    	return _priority;
    }  

    void setPriority(int p)
    {
    	_priority = p;
    }

    double getPrice()
    {
    	return _price;
    }

    void setPrice(double price)
    {
    	_price = price;
    }
    
   static void findRepeat(double &data[], // 计算的数据
                     double deviations,// 误差
                     KeyPrice* &kp[] // 计算结果
   )
   {
   ArraySort(data,WHOLE_ARRAY,0,MODE_DESCEND);
	int count=ArraySize(data);
   double standard = 0.0; 
	int pos = 0;
	KeyPrice *k = new KeyPrice();
		
	ArrayResize(kp,pos+1,0);
	kp[pos] = k;
   bool inRange =false;
   
	for(int i=0;i<count-1;i++){
 
	   double tobeCompared = data[i];
	   if(inRange)
	   {
	      tobeCompared = standard;
	   }
	   
	   
	
		if(MathAbs(tobeCompared-data[i+1])<=deviations )
        {
            inRange = true;
            if(standard==0)
            {
               standard = data[i];
            }
            k.addPriority();
            
            if(count-i<=2)
            {
               double total = 0;
           	   for(int j=0;j<k.getPriority();j++)
            	{
           		total += data[i+2-k.getPriority()+j];
           	   }
           	   k.setPrice(total/k.getPriority());
           	   return;
            }
   
        }else
        {
           	double total = 0;
           	for(int j=0;j<k.getPriority();j++)
           	{
           		total += data[i+1-k.getPriority()+j];
           	}
           	k.setPrice(total/k.getPriority());
            
            
            if(i<count-2)
            {
               pos+=1;
            	k = new KeyPrice();
           	   ArrayResize(kp,pos+1,0);
           	   kp[pos] = k;
            	standard = 0;
           	   inRange = false;
            }
           
       }
	}
   }


};


