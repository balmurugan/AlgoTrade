//+------------------------------------------------------------------+
//|                                                      Bala100.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <SL.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double EnteredAsk = 0;
// Private Vars
double Buy_Stop_Loss = 0;
double Buy_Take_Profit = 0;

double Sell_Stop_Loss = 0;
double Sell_Take_Profit = 0;

int order = 0;
int orderR = 0;
// Public Vars
extern int MagicNumber = 666666;

double EnteredBid = 0;
int orderB = 0;
int orderRB = 0;
int countsellorder=0;
int countbuyorder=0;
extern  int entrypoints=20;
// extern double Lots = 0.01;
extern string MoneyManagement = "==MONEY MANAGEMENT SETTINGS=="; //MONEY MANAGEMENT SETTINGS
extern double Initial_Lot = 0.1; //Lot Size Setting
extern double StopLoss = 10; //Stop Loss Setting
extern double TakeProfit = 0; //Take Profit Setting
extern int StartMarti = 0; //Marti Starter
extern double MartiMultiplier = 0; //Marti Multiplier
extern int Slippage = 5; //Slippage Setting
int intMarketSpreadPoints = MarketInfo(_Symbol, MODE_SPREAD);
double dblSymbolPointSize    = MarketInfo(_Symbol, MODE_POINT);
void OnStart()
{

}
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   entrypoints=entrypoints+intMarketSpreadPoints;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   Accountinfo();
   bool flag=false;

   if(EnteredAsk==0)
     {
      EnteredAsk=Ask;
     }
   if(EnteredBid==0)
     {
      EnteredBid=Bid;
     }
   double pos=((Bid-EnteredAsk)/_Point)/entrypoints;
   if(pos >order || order==0)
     {

      SendBuyOrder(order);
      order = order+1;
      orderR=0;
     }

   /* Reverse Buy */

  Print("ReverseposB"+pos+"orderB"+(order+"orderRB"+ orderR),Green);
   countbuyorder=Get_openorder("Buy");
   if((countbuyorder==0 || orderR>0)  && order!=0)
     {

    
      if(pos >(order-orderR))
        {

         Print("pos111111111"+pos+"order"+(order+"orderR"+ orderR));
         //orderRB=Get_openorder("sell");
         SendsellROrder(orderR);
         orderR=orderR+1;
         order = order-1;
        }
        else if(pos <(order-orderR))
        {
        
        if(countbuyorder==0)
        {
        order = order-1;
        }
        
        }
      //Alert("Bid -"+ orderB+"-"+ Bid);
     }
     


   /* if(pos <order)
      {
       orderR=Get_openorder("Buy");
       SendSellOrder(orderR);
      }*/
   double posB=((EnteredBid-Ask)/_Point)/entrypoints;
   if(posB >orderB || orderB==0)
     {

      SendSellOrder(orderB);
      orderB = orderB+1;
      orderRB=0;
      //Alert("Bid -"+ orderB+"-"+ Bid);
     }
 Print("posS"+posB+"orderS"+(orderB+"orderRS"+ orderRB),Red);
   countsellorder=Get_openorder("sell");
   if((countsellorder==0 || orderRB>0)  && orderB!=0)
     {

      Print("posS"+posB+"orderS"+(orderB+"orderRS"+ orderRB));
      if(posB <(orderB-orderRB))
        {

         Print("posS111111111"+posB+"orderS"+(orderB+"orderRS"+ orderRB));
         //orderRB=Get_openorder("sell");
         SendBuyROrder(orderRB);
         orderRB=orderRB+1;
         orderB = orderB-1;
        }else if(posB >(orderB-orderRB))
        {
        
        if(countsellorder==0 || countsellorder==1)
        {
         orderB = orderB-1;
        }
        
        }
        
      //Alert("Bid -"+ orderB+"-"+ Bid);
     }

  }


// OPEN POSITION
void SendBuyROrder(int O_order)
  {
// if (OrdersTotal() < 1)



   if(O_order==0)
     {
      DrawSellSign("SellRRS"+O_order);
      OrderSend(Symbol(), OP_SELL, LotNormalize(Initial_Lot), Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
     }
   if(order!=0)
     {
      DrawBuySign("BuyRRB"+O_order);
     OrderSend(Symbol(), OP_BUY, LotNormalize(Initial_Lot*O_order), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
      SLSettings(Ask,"Buy");
      DrawSellSign("BuyRRS"+O_order);
      OrderSend(Symbol(), OP_SELL,Initial_Lot, Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
     }



  }

// OPEN POSITION
void SendsellROrder(int O_order)
  {

   Print("Sell"+O_order);
// if (OrdersTotal() < 1)

   if(O_order==0)
     {
      DrawBuySign("BuyRB"+O_order);
      OrderSend(Symbol(), OP_BUY, LotNormalize(Initial_Lot), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
     }

   if(O_order!=0)
     {
      DrawBuySign("BuyRB"+O_order);
      OrderSend(Symbol(), OP_SELL, LotNormalize(Initial_Lot*O_order), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
      SLSettings(Bid,"sell");
      DrawSellSign("BuyRS"+O_order);
      OrderSend(Symbol(), OP_BUY,Initial_Lot, Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
     }

  }

// OPEN POSITION
void SendBuyOrder(int O_order)
  {
// if (OrdersTotal() < 1)

   if(O_order==0)
     {
      Print("Buy"+O_order);
      DrawBuySign("BuyB"+O_order);
      OrderSend(Symbol(), OP_BUY, LotNormalize(Initial_Lot), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
     }
   if(O_order!=0)
     {
      Print("Buy"+O_order);
      DrawBuySign("BuyB"+O_order);
      OrderSend(Symbol(), OP_BUY, LotNormalize(Initial_Lot*O_order), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
      SLSettings(Ask,"Buy");
      DrawSellSign("BuyS"+O_order);
      OrderSend(Symbol(), OP_SELL,Initial_Lot, Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendSellOrder(int O_order)
  {
   Print(OrdersTotal());
// if (OrdersTotal() < 1) {
   if(O_order==0)
     {
      DrawSellSign("SellS"+O_order);
      OrderSend(Symbol(), OP_SELL, LotNormalize(Initial_Lot), Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);

     }
   if(O_order!=0)
     {

      DrawSellSign("SellS"+O_order);
      OrderSend(Symbol(), OP_SELL, LotNormalize(Initial_Lot*O_order), Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
      SLSettings(Bid,"sell");
      DrawBuySign("SellB"+O_order);
      OrderSend(Symbol(), OP_BUY, Initial_Lot, Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);

     }
//

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Get_openorder(string order_Type)
  {

   int TotalUpdated = 0;  // Counter for how many orders have been updated.

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      // Select an order by index i, selecting by position and from the pool of market trades.
      // If the selection is successful, proceed with the update.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         // Check if the order is for the current chart's currency pair.
         if(OrderSymbol() == Symbol())
           {
            double OpenPrice = 0;
            double StopLossPrice = 0;
            double TakeProfitPrice = 0;
            // Get the open price.
            OpenPrice = OrderOpenPrice();
            // Calculate the stop-loss and take-profit price depending on the type of order.
            if(OrderType() == OP_SELL && order_Type == "sell")
              {

               // If the order is updated correctly, increment the counter of updated orders.
               TotalUpdated++;
              }



            if(OrderType() == OP_BUY && order_Type == "Buy")
              {
               TotalUpdated++;
              }



           }
        }

     }

   return(TotalUpdated);

  }
// Lot Calculation
double LotNormalize(double initialLot)
  {
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double lotToUse = lotStep * NormalizeDouble(initialLot / lotStep, 0);
   lotToUse = MathMax(MathMin(maxLot, lotToUse), minLot);
   return(lotToUse);
  }



// DRAW OBJECTd
void DrawBuySign(string objectName)
  {
   ObjectCreate(objectName, OBJ_ARROW_BUY, 0, 0, 0);
   ObjectSet(objectName, OBJPROP_ARROWCODE, 233);
   ObjectSet(objectName, OBJPROP_COLOR, Green);
   ObjectSet(objectName, OBJPROP_WIDTH, 3);
   ObjectSet(objectName, OBJPROP_TIME1, Time[0]);
   ObjectSet(objectName, OBJPROP_PRICE1, Low[0] - 10 * _Point);
   ObjectCreate(objectName+"BL", OBJ_TEXT, 0, 0, 0);
   ObjectSetText(objectName+"BL",Ask,10,"Times New Roman",Green);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSellSign(string objectName)
  {
   ObjectCreate(objectName, OBJ_ARROW_SELL, 0, 0, 0);
   ObjectSet(objectName, OBJPROP_ARROWCODE, 234);
   ObjectSet(objectName, OBJPROP_COLOR, Red);
   ObjectSet(objectName, OBJPROP_WIDTH, 3);
   ObjectSet(objectName, OBJPROP_TIME1, Time[0]);
   ObjectSet(objectName, OBJPROP_PRICE1, High[0] + 10 * _Point);
   ObjectCreate(objectName+"SL", OBJ_TEXT, 0, 0, 0);
   ObjectSetText(objectName+"SL",Bid,10,"Times New Roman",Green);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateNormalizedDigits()
  {
   if(Digits <= 3)
     {
      return(0.01);
     }
   else
      if(Digits >= 4)
        {
         return(0.0001);
        }
      else
         return(0);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---\`

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+

void SLSettings(double Price,string order_Type)
  {
   int TotalUpdated = 0;  // Counter for how many orders have been updated.

   double nDigits = CalculateNormalizedDigits();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      // Select an order by index i, selecting by position and from the pool of market trades.
      // If the selection is successful, proceed with the update.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         // Check if the order is for the current chart's currency pair.
         if(OrderSymbol() == Symbol())
           {
            double OpenPrice = 0;
            double StopLossPrice = 0;
            double TakeProfitPrice = 0;
            // Get the open price.
            OpenPrice = OrderOpenPrice();
            // Calculate the stop-loss and take-profit price depending on the type of order.
            if(OrderType() == OP_SELL && order_Type == "sell")
              {
               StopLossPrice = NormalizeDouble(Price + (StopLoss * nDigits), Digits);
               // TakeProfitPrice = NormalizeDouble(Price + TakeProfit * nDigits, Digits);
               if(OpenPrice >= Price)
                 {
                  if(OrderModify(OrderTicket(), OpenPrice, StopLossPrice, TakeProfitPrice, OrderExpiration()))
                    {
                     // If the order is updated correctly, increment the counter of updated orders.
                     TotalUpdated++;
                    }
                  else
                    {
                     // If the order fails to get updated, print the error.
                     Print("Order failed to update with Serror: ", GetLastError());
                    }


                 }
              }

            Print("StopLevel = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));

            if(OrderType() == OP_BUY && order_Type == "Buy")
              {
               StopLossPrice = NormalizeDouble(Price - (StopLoss * nDigits), Digits);
               Print("StopLossPrice"+StopLossPrice);
               // TakeProfitPrice = NormalizeDouble(Price + TakeProfit * nDigits, Digits);
               if(OpenPrice <= Price)
                 {
                  if(OrderModify(OrderTicket(), OpenPrice, StopLossPrice, TakeProfitPrice, OrderExpiration()))
                    {
                     // If the order is updated correctly, increment the counter of updated orders.
                     TotalUpdated++;
                    }
                  else
                    {
                     // If the order fails to get updated, print the error.
                     Print("Order failed to update with Berror: ", GetLastError());
                    }

                 }
              }
           }
        }
     }

  }
