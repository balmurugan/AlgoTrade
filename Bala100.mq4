//+------------------------------------------------------------------+
//|                                                      Bala100.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
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

 Print("orderB"+(orderB+"orderRB"+ orderRB));
   if(posB <(orderB-orderRB) && orderB!=0)
     {
    
      orderRB=Get_openorder("sell");
      SendBuyROrder(orderRB);
      orderRB=orderRB+1;
              //Alert("Bid -"+ orderB+"-"+ Bid);
     }

  }


// OPEN POSITION
void SendBuyROrder(int order)
  {
// if (OrdersTotal() < 1)

   if(order==0)
     {
      DrawSellSign("SellS"+orderB);
      order = OrderSend(Symbol(), OP_SELL, LotNormalize(Initial_Lot), Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);

     }

   if(order!=0)
     {
      DrawBuySign("BuyB"+order);
      order = OrderSend(Symbol(), OP_BUY, LotNormalize(Initial_Lot*order), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
      SLSettings(Ask,"Buy");
      DrawSellSign("BuyS"+order);
      order = OrderSend(Symbol(), OP_SELL,Initial_Lot, Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
     }

  }

// OPEN POSITION
void SendBuyOrder(int order)
  {
// if (OrdersTotal() < 1)

   if(order==0)
     {
      DrawBuySign("BuyB"+order);
      order = OrderSend(Symbol(), OP_BUY, LotNormalize(Initial_Lot), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
     }

   if(order!=0)
     {
      DrawBuySign("BuyB"+order);
      order = OrderSend(Symbol(), OP_BUY, LotNormalize(Initial_Lot*order), Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);
      SLSettings(Ask,"Buy");
      DrawSellSign("BuyS"+order);
      order = OrderSend(Symbol(), OP_SELL,Initial_Lot, Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendSellOrder(int orderB)
  {
   Print(OrdersTotal());
// if (OrdersTotal() < 1) {
   if(orderB==0)
     {
      DrawSellSign("SellS"+orderB);
      order = OrderSend(Symbol(), OP_SELL, LotNormalize(Initial_Lot), Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);

     }
   if(orderB!=0)
     {

      DrawSellSign("SellS"+orderB);
      order = OrderSend(Symbol(), OP_SELL, LotNormalize(Initial_Lot*orderB), Bid, Slippage, 0, Sell_Take_Profit, "Order Sell Send", MagicNumber, 0, clrRed);
      SLSettings(Bid,"sell");
      DrawBuySign("SellB"+orderB);
      order = OrderSend(Symbol(), OP_BUY, Initial_Lot, Ask, Slippage, 0, Buy_Take_Profit, "Order Buy Send", MagicNumber, 0, clrGreen);

     }
//

  }
//+------------------------------------------------------------------+
//|                                                                  |
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

               if(OrderModify(OrderTicket(), OpenPrice, StopLossPrice, TakeProfitPrice, OrderExpiration()))
                 {
                  // If the order is updated correctly, increment the counter of updated orders.
                  TotalUpdated++;
                 }
               else
                 {
                  // If the order fails to get updated, print the error.
                  Print("Order failed to update with error: ", GetLastError());
                 }
              }

            Print("StopLevel = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));

            if(OrderType() == OP_BUY && order_Type == "Buy")
              {
               StopLossPrice = NormalizeDouble(Price - (StopLoss * nDigits), Digits);
               Print("StopLossPrice"+StopLossPrice);
               // TakeProfitPrice = NormalizeDouble(Price + TakeProfit * nDigits, Digits);
               if(OpenPrice <= Price)
                  if(OrderModify(OrderTicket(), OpenPrice, StopLossPrice, TakeProfitPrice, OrderExpiration()))
                    {
                     // If the order is updated correctly, increment the counter of updated orders.
                     TotalUpdated++;
                    }
                  else
                    {
                     // If the order fails to get updated, print the error.
                     Print("Order failed to update with error: ", GetLastError());
                    }

              }
           }
        }
     }

  }

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
            else
              {
               // If the order fails to get updated, print the error.
               Print("Order failed to update with error: ", GetLastError());
              }


            if(OrderType() == OP_BUY && order_Type == "Buy")
              {
               TotalUpdated++;
              }
            else
              {
               // If the order fails to get updated, print the error.
               Print("Order failed to update with error: ", GetLastError());
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
   ObjectSet(objectName, OBJPROP_COLOR, Yellow);
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
