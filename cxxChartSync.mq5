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
input long             cxxSubKey            = 83;        // 動作キー（サブ）
input ENUM_LINE_STYLE  cxxVerticalLineType  = STYLE_DOT; // 線のタイプ
input long             cxxVerticalLineWidth = 1;         // 線の太さ
input color            cxxVerticalLineColor = clrGray;   // 線の色

// cxxParallelButtonにも同じものがあるので同期するように、クソコード
#define LINE_NAME "Cxx_Chart_Sync_Line"

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


// 時間軸を変えるだけで動作してしまうので今はコメントアウト
void OnDeinit(const int reason) {
   //ObjectDelete(0, LINE_NAME);
   //ObjectFind(0, LINE_NAME);
   //ChartRedraw();
}


void  OnChartEvent(
   const int       id,
   const long&     lparam,
   const double&   dparam,
   const string&   sparam) {
   
   static int mosueX;
   static int mosueY;
   static int subwindow;
   static datetime time;
   static double price;
   
   if (id == CHARTEVENT_MOUSE_MOVE) {
      mosueX = int(lparam);
      mosueY = int(dparam);
   }
   
   if (id == CHARTEVENT_KEYDOWN && lparam == cxxExecuteKey) {
      
      // マウスの位置の時間と値を取得
      ChartXYToTimePrice(ChartID(), mosueX, mosueY, subwindow, time, price);
      
      long nowID = ChartID();
      long chartID = ChartFirst();
      
      while(chartID != -1) {
      
         if (chartID == nowID) {
            DrawVerticalLine(chartID, LINE_NAME, time);
            chartID = ChartNext(chartID);
            continue;
         }
         
         // バー番号を取得
         int startBar = iBarShift(NULL, ChartPeriod(chartID), time, false);
         ChartNavigate(chartID, CHART_END, -startBar + int((ChartGetInteger(chartID, CHART_WIDTH_IN_BARS) / 2)));
         
         DrawVerticalLine(chartID, LINE_NAME, time);
         
         chartID = ChartNext(chartID);
      }
   }
   
   if (id == CHARTEVENT_KEYDOWN && lparam == cxxSubKey) {
   
      // 基準となるラインがあるか調べる
      if (ObjectFind(ChartID(), LINE_NAME) >= 0) {
         
         // 基準ラインの時間からバー数を計算
         datetime time = (datetime)ObjectGetInteger(ChartID(), LINE_NAME, OBJPROP_TIME);
         int startBar = iBarShift(NULL, Period(), time, false);
         
         // 基準ラインを画面中央になるようにチャートを移動させる
         ChartNavigate(ChartID(), CHART_END, -startBar + (int)(ChartGetInteger(ChartID(), CHART_VISIBLE_BARS) / 2));
      }
   }
}

//+------------------------------------------------------------------+
