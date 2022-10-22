/*

   Simple Order Panel.mq5

   Copyright 2022, Orchard Forex
   https://orchardforex.com

*/

#property copyright "Copyright 2022, Orchard Forex"
#property link "https://orchardforex.com"
#property version "1.00"

#include <Trade/Trade.mqh>
CTrade                 Trade;

// Set the initial corner for the trade panel
const ENUM_BASE_CORNER PanelCorner  = CORNER_RIGHT_UPPER;

// Gaps from top and side of screen
const int              YMargin      = 20;
const int              XMargin      = 20;

// gaps between elements
const int              XGap         = 10;
const int              YGap         = 10;

// Size of the elements, buttons first because text depends on that
const int              ButtonWidth  = 50;
const int              ButtonHeight = 20;
const int              TextWidth    = (ButtonWidth * 2) + XGap;
const int              TextHeight   = 20;

// To make things easier below, also set the locations
// Caution, placing in top right but measuring to lower left of each element
const int              TextX        = XMargin + TextWidth;
const int              TextY        = YMargin + TextHeight;
const int              SellX        = XMargin + ButtonWidth;
const int              SellY        = TextY + YGap + ButtonHeight;
const int              BuyX         = SellX + XGap + ButtonWidth; // could also just be TextX
const int              BuyY         = TextY + YGap + ButtonHeight;

// Names of the screen elements
const string           TextName     = "Text_Volume";
const string           BuyName      = "Buy_Button";
const string           SellName     = "Sell_Button";

// set up an initial value for lot size
double                 TradeVolume  = 0.01;

;
int OnInit() {

   CreatePanel();

   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   ObjectDelete(0, TextName);
   ObjectDelete(0, BuyName);
   ObjectDelete(0, SellName);
}

void OnTick() {}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if (id == CHARTEVENT_OBJECT_ENDEDIT && sparam == TextName) {
      string volumeText = ObjectGetString(0, TextName, OBJPROP_TEXT);
      SetVolume(volumeText);
      ObjectSetString(0, TextName, OBJPROP_TEXT, string(TradeVolume));
      return;
   }
   else if (id == CHARTEVENT_OBJECT_CLICK) {
      if (sparam == BuyName) {
         ObjectSetInteger(0, BuyName, OBJPROP_STATE, false);
         OpenTrade(ORDER_TYPE_BUY, TradeVolume);
         return;
      }
      else if (sparam == SellName) {
         ObjectSetInteger(0, SellName, OBJPROP_STATE, false);
         OpenTrade(ORDER_TYPE_SELL, TradeVolume);
         return;
      }
   }
}

void CreatePanel() {

   // First just get rid of any existing elements
   ObjectDelete(0, TextName);
   ObjectDelete(0, BuyName);
   ObjectDelete(0, SellName);

   EditCreate(0, TextName, 0, TextX, TextY, TextWidth, TextHeight, string(TradeVolume), "Arial", 10, ALIGN_LEFT, false, PanelCorner, clrBlack, clrWhite, clrBlack, false, false,
              false, 0);
   ButtonCreate(0, BuyName, 0, BuyX, BuyY, ButtonWidth, ButtonHeight, PanelCorner, "Buy", "Arial", 10, clrBlack, clrFireBrick, clrBlack, false, false, false, false, 0);
   ButtonCreate(0, SellName, 0, SellX, SellY, ButtonWidth, ButtonHeight, PanelCorner, "Sell", "Arial", 10, clrBlack, clrCyan, clrBlack, false, false, false, false, 0);
}

void SetVolume(string volumeText) {

   double newVolume = StringToDouble(volumeText);
   if (newVolume < 0) {
      Print("Invalid volume specified");
      return;
   }
   TradeVolume = newVolume;
}

bool OpenTrade(ENUM_ORDER_TYPE type, double volume) {
   double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) : SymbolInfoDouble(Symbol(), SYMBOL_BID);
   return Trade.PositionOpen(Symbol(), type, volume, price, 0, 0, "");
}

bool ButtonCreate(const long             chart_ID   = 0,                 // chart's ID
                  const string           name       = "Button",          // button name
                  const int              sub_window = 0,                 // subwindow index
                  const int              x          = 0,                 // X coordinate
                  const int              y          = 0,                 // Y coordinate
                  const int              width      = 50,                // button width
                  const int              height     = 18,                // button height
                  const ENUM_BASE_CORNER corner     = CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string           text       = "Button",          // text
                  const string           font       = "Arial",           // font
                  const int              font_size  = 10,                // font size
                  const color            clr        = clrBlack,          // text color
                  const color            back_clr   = clrGray,           // background color
                  const color            border_clr = clrNONE,           // border color
                  const bool             state      = false,             // pressed/released
                  const bool             back       = false,             // in the background
                  const bool             selection  = false,             // highlight to move
                  const bool             hidden     = true,              // hidden in the object list
                  const long             z_order    = 0                  // priority for mouse click
) {
   //--- reset the error value
   ResetLastError();
   //--- create the button
   if (!ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0)) {
      Print(__FUNCTION__, ": failed to create the button! Error code = ", GetLastError());
      return (false);
   }
   //--- set button coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
   //--- set button size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
   //--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
   //--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
   //--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
   //--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
   //--- set text color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   //--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   //--- set border color
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   //--- set button state
   ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
   //--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
   //--- successful execution
   return (true);
}

bool EditCreate(const long             chart_ID   = 0,                 // chart's ID
                const string           name       = "Edit",            // object name
                const int              sub_window = 0,                 // subwindow index
                const int              x          = 0,                 // X coordinate
                const int              y          = 0,                 // Y coordinate
                const int              width      = 50,                // width
                const int              height     = 18,                // height
                const string           text       = "Text",            // text
                const string           font       = "Arial",           // font
                const int              font_size  = 10,                // font size
                const ENUM_ALIGN_MODE  align      = ALIGN_CENTER,      // alignment type
                const bool             read_only  = false,             // ability to edit
                const ENUM_BASE_CORNER corner     = CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr        = clrBlack,          // text color
                const color            back_clr   = clrWhite,          // background color
                const color            border_clr = clrNONE,           // border color
                const bool             back       = false,             // in the background
                const bool             selection  = false,             // highlight to move
                const bool             hidden     = true,              // hidden in the object list
                const long             z_order    = 0                  // priority for mouse click
) {
   //--- reset the error value
   ResetLastError();
   //--- create edit field
   if (!ObjectCreate(chart_ID, name, OBJ_EDIT, sub_window, 0, 0)) {
      Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ", GetLastError());
      return (false);
   }
   //--- set object coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
   //--- set object size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
   //--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
   //--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
   //--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
   //--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID, name, OBJPROP_ALIGN, align);
   //--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID, name, OBJPROP_READONLY, read_only);
   //--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
   //--- set text color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   //--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
   //--- set border color
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   //--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
   //--- successful execution
   return (true);
}
