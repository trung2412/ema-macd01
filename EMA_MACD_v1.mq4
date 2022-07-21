//+------------------------------------------------------------------+
//|                                                         Bot1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICMA  99
input int TP;

double   ema5; 
double   ema5a; 
double   ema15;
double   ema15a;
double   ema50;
double   ema100;
double   macd;

  
     
   //+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
    
void CheckForOpen()   
   {  
      int      order;
      double SL = ema50;   
      
      macd   = iMACD (Symbol(),Period(), 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
      ema5   = iMA(Symbol(),Period(),5,0,MODE_EMA,PRICE_CLOSE,0);
      ema15  = iMA(Symbol(),Period(),15,0,MODE_EMA,PRICE_CLOSE,0);
      ema5a  = iMA(Symbol(),Period(),5,0,MODE_EMA,PRICE_CLOSE,1);
      ema15a = iMA(Symbol(),Period(),15,0,MODE_EMA,PRICE_CLOSE,1);
      ema50  = iMA(Symbol(),Period(),50,0,MODE_EMA,PRICE_CLOSE,0);
      ema100 = iMA(Symbol(),Period(),100,0,MODE_EMA,PRICE_CLOSE,0);
      
      if(ema5a>ema15a && ema5<ema15 && macd<0 && Bid<ema50 && Bid<ema100)
        {
            order = OrderSend(Symbol(),OP_SELL,0.1,Bid,5,SL,Bid - TP*Point,"",MAGICMA,0,Red);
            return;
        } 
      if(ema5a<ema15a && ema5>ema15 && macd>0 && Bid>ema50 && Bid>ema100)
        {
            order = OrderSend(Symbol(),OP_BUY,0.1,Ask,5,SL,Ask + TP*Point,"",MAGICMA,0,Green);
            return;
        }
   }

void CheckForClose()
  {
  macd   = iMACD (Symbol(),Period(), 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
  ema5   = iMA(Symbol(),Period(),5,0,MODE_EMA,PRICE_CLOSE,0);
  ema15  = iMA(Symbol(),Period(),15,0,MODE_EMA,PRICE_CLOSE,0);
  for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
      
      if(OrderType()==OP_BUY)
        {
         if(ema5<ema15 && macd<0)
           {
            if(!OrderClose(OrderTicket(),0.1,Bid,5,White))
               Print("OrderClose error ",GetLastError());
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(ema5>ema15 && macd>0)
           {
            if(!OrderClose(OrderTicket(),0.1,Ask,5,White))
               Print("OrderClose error ",GetLastError());
           }
           
        }
        break;
   }   
  }
void OnTick()
  {   

      ema50  = iMA(Symbol(),Period(),50,0,MODE_EMA,PRICE_CLOSE,0);
      ema100 = iMA(Symbol(),Period(),100,0,MODE_EMA,PRICE_CLOSE,0); 
          
      //Print("OnTick total order", CalculateCurrentOrders(Symbol()));
      //Print("Gia tri Histogram = ", macd);
      
      if(CalculateCurrentOrders(Symbol())==0)
      {
         if(ema50<Bid<ema100 && ema50>Bid>ema100)
         {
               return;
         }else 
            CheckForOpen();
      }
      else
      {      
          CheckForClose();
      }
  }
//+------------------------------------------------------------------+
