//+------------------------------------------------------------------+
//|                                                 cxxChartSync.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "A key で動作"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+



int OnInit() {
   // 自動スクロールを停止
   ChartSetInteger(0, CHART_AUTOSCROLL, false);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   ChartSetInteger(0,CHART_EVENT_MOUSE_WHEEL,1);
   
   return(INIT_SUCCEEDED);
}


void DrawVerticalLine(long chart_id, const string object_name, datetime time) {

   ObjectCreate    (chart_id, object_name, OBJ_VLINE, 0, time, 0);
   ObjectSetInteger(chart_id, object_name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, clrMaroon);
   ObjectSetInteger(chart_id, object_name, OBJPROP_BACK, true);
   ObjectSetInteger(chart_id, object_name, OBJPROP_STYLE, STYLE_DOT);
   
   ChartRedraw(chart_id);
}



void  OnChartEvent(
   const int       id,       // event ID 
   const long&     lparam,   // long type event parameter
   const double&   dparam,   // double type event parameter
   const string&   sparam) { // string type event parameter
   
   static long MouseX;
   static double MouseY;
   static int GetSubWindow;
   static datetime GetTime;
   static double GetPrice;
   
   static const long ExecuteKey = 65; // A key
   
   if (id == CHARTEVENT_MOUSE_MOVE) {
      MouseX = lparam;
      MouseY = dparam;
   }
   
   if (id == CHARTEVENT_KEYDOWN && lparam == ExecuteKey) {
      
      // マウスの位置の時間と値を取得
      ChartXYToTimePrice(ChartID(), MouseX, MouseY, GetSubWindow, GetTime, GetPrice);
      
      long nowID = ChartID();
      
      long firstVisibleBar = ChartGetInteger(nowID,CHART_FIRST_VISIBLE_BAR);
      long visibleBars     = ChartGetInteger(nowID, CHART_VISIBLE_BARS);
      long widthInBars     = ChartGetInteger(nowID, CHART_WIDTH_IN_BARS);
      
      
      long chartID = ChartFirst();
      
      while(chartID != -1) {
      
         if (chartID == nowID) {
            DrawVerticalLine(chartID, "Time_Vertical_Line", GetTime);
            chartID = ChartNext(chartID);
            continue;
         }
         
         long fvb = ChartGetInteger(nowID, CHART_FIRST_VISIBLE_BAR);
         long vb  = ChartGetInteger(nowID, CHART_VISIBLE_BARS);
         long b   = (firstVisibleBar < visibleBars) ? firstVisibleBar : visibleBars;
         
         // バー番号を取得
         int startBar = iBarShift(NULL, ChartPeriod(chartID), GetTime, false);
         ChartNavigate(chartID, CHART_END, -startBar + (ChartGetInteger(chartID, CHART_WIDTH_IN_BARS) / 2));
         
         DrawVerticalLine(chartID, "Time_Vertical_Line", GetTime);
         
         chartID = ChartNext(chartID);
      }
   }
}

//+------------------------------------------------------------------+
