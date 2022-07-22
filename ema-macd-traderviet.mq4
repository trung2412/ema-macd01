//+------------------------------------------------------------------+
//|                                          ema-macd-traderviet.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define MAGICMA  99
input int TP;
input int SL;

double ema200;
double macd;
double macd_1;
double macdsig;
double macdsig_1;
double macdhis;
double macdhis_1;

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
int order;

ema200     = iMA(Symbol(),Period(),200,0,MODE_EMA,PRICE_CLOSE,0);
macdhis_1  = iMACD (Symbol(),Period(), 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
macdhis    = iMACD (Symbol(),Period(), 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
macdsig_1  = iMACD (Symbol(),Period(), 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
macdsig    = iMACD (Symbol(),Period(), 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
macd       = macdhis + macdsig;
macd_1     = macdhis_1 +  macdsig_1; 

   if(macdhis < 0 && Bid > ema200 && macd < 0 && macdsig < 0 && macd_1 < macdsig_1 && macd > macdsig)
   {
      order = OrderSend(Symbol(),OP_BUY,0.1,Ask,5,Ask - SL*Point,Ask + TP*Point,"",MAGICMA,0,Green);
      return;
   }
   if(macdhis > 0 && Bid < ema200 && macd > 0 && macdsig > 0 && macd_1 > macdsig_1 && macd < macdsig)
   {
      order = OrderSend(Symbol(),OP_SELL,0.1,Bid,5,Bid + SL*Point,Ask - TP*Point,"",MAGICMA,0,Red);
      return;
   }
}

void CheckForClose()
{
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      
      
      if(OrderType()==OP_BUY)
        {
         if(macd < macdsig && macdhis > 0)
           {
            if(!OrderClose(OrderTicket(),0.1,Bid,5,White))
               Print("OrderClose error ",GetLastError());
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(macd > macdsig && macdhis < 0)
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

   if(CalculateCurrentOrders(Symbol())==0)
      {
         
          
          CheckForOpen();
      }
      else
      {      
          CheckForClose();
      }
  }
//+------------------------------------------------------------------+
