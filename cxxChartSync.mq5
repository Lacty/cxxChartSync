//+------------------------------------------------------------------+
//|                                                 cxxChartSync.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

input long             cxxExecuteKey        = 65;        // 動作キー
input ENUM_LINE_STYLE  cxxVerticalLineType  = STYLE_DOT; // 線のタイプ
input long             cxxVerticalLineWidth = 1;         // 線の太さ
input color            cxxVerticalLineColor = clrGray;   // 線の色

int OnInit() {
   // 自動スクロールを停止
   ChartSetInteger(0, CHART_AUTOSCROLL, false);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
   ChartSetInteger(0,CHART_EVENT_MOUSE_WHEEL,1);
   
   return(INIT_SUCCEEDED);
}


void DrawVerticalLine(long chart_id, const string object_name, datetime time) {

   ObjectCreate    (chart_id, object_name, OBJ_VLINE, 0, time, 0);
   ObjectSetInteger(chart_id, object_name, OBJPROP_WIDTH, cxxVerticalLineWidth);
   ObjectSetInteger(chart_id, object_name, OBJPROP_COLOR, cxxVerticalLineColor);
   ObjectSetInteger(chart_id, object_name, OBJPROP_BACK, true);
   ObjectSetInteger(chart_id, object_name, OBJPROP_STYLE, cxxVerticalLineType);
   
   ChartRedraw(chart_id);
}



void  OnChartEvent(
   const int       id,
   const long&     lparam,
   const double&   dparam,
   const string&   sparam) {
   
   static long MouseX;
   static double MouseY;
   static int GetSubWindow;
   static datetime GetTime;
   static double GetPrice;
   
   //static const long cxxExecuteKey = 65; // A で動作
   
   if (id == CHARTEVENT_MOUSE_MOVE) {
      MouseX = lparam;
      MouseY = dparam;
   }
   
   if (id == CHARTEVENT_KEYDOWN && lparam == cxxExecuteKey) {
      
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
