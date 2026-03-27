unit Graph2010;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 40264 $
// File generated on 6/9/2011 10:37:19 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: c:\Program Files\Microsoft Office\Office14\graph.exe (1)
// LIBID: {00020802-0000-0000-C000-000000000046}
// LCID: 0
// Helpfile: c:\Program Files\Microsoft Office\Office14\VBAGR10.CHM
// HelpString: Microsoft Graph 14.0 Object Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
//   (2) v2.5 Office, (C:\Program Files\Common Files\Microsoft Shared\OFFICE14\MSO.DLL)
// Errors:
//   Hint: Parameter 'Type' of IChart.ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of IChart.Axes changed to 'Type_'
//   Hint: Symbol 'Type' renamed to 'type_'
//   Hint: Parameter 'Type' of IAxes.Item changed to 'Type_'
//   Hint: Parameter 'Type' of IPoint._ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of IPoint.ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of ISeries._ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of ISeries.ErrorBar changed to 'Type_'
//   Hint: Parameter 'Type' of ISeries.ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of ITrendlines.Add changed to 'Type_'
//   Hint: Parameter 'Type' of Chart.ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of Chart.Axes changed to 'Type_'
//   Hint: Member 'Application' of 'Application' changed to 'Application_'
//   Hint: Parameter 'Type' of Axes.Item changed to 'Type_'
//   Hint: Parameter 'Type' of Point._ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of Point.ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of Series._ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of Series.ErrorBar changed to 'Type_'
//   Hint: Parameter 'Type' of Series.ApplyDataLabels changed to 'Type_'
//   Hint: Parameter 'Type' of Trendlines.Add changed to 'Type_'
// Cmdline:
//   tlibimp  -Fe2010 -Ha- -Hs+ -Hr+ -Yp+ -HpsOfficeXP -P+ "c:\Program Files\Microsoft Office\Office14\graph.exe"
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Windows, ActiveX, Classes, Graphics, Office2010, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  GraphMajorVersion = 1;
  GraphMinorVersion = 7;

  LIBID_Graph: TGUID = '{00020802-0000-0000-C000-000000000046}';

  IID_IFont: TGUID = '{000208F3-0001-0000-C000-000000000046}';
  IID__IGlobal: TGUID = '{000208FC-0001-0000-C000-000000000046}';
  IID_IChart: TGUID = '{000208FB-0001-0000-C000-000000000046}';
  IID_IApplication: TGUID = '{000208EC-0001-0000-C000-000000000046}';
  IID_IDataSheet: TGUID = '{00024726-0001-0000-C000-000000000046}';
  IID_IRange: TGUID = '{00024727-0001-0000-C000-000000000046}';
  IID_IAutoCorrect: TGUID = '{000208D4-0001-0000-C000-000000000046}';
  IID_IBorder: TGUID = '{000208EE-0001-0000-C000-000000000046}';
  IID_IInterior: TGUID = '{000208ED-0001-0000-C000-000000000046}';
  IID_IChartFillFormat: TGUID = '{0002441C-0001-0000-C000-000000000046}';
  IID_IChartColorFormat: TGUID = '{0002441D-0001-0000-C000-000000000046}';
  IID_IAxis: TGUID = '{000208F9-0001-0000-C000-000000000046}';
  IID_IChartTitle: TGUID = '{000208F8-0001-0000-C000-000000000046}';
  IID_IAxisTitle: TGUID = '{000208F7-0001-0000-C000-000000000046}';
  IID_IChartGroup: TGUID = '{000208F6-0001-0000-C000-000000000046}';
  IID_IChartGroups: TGUID = '{000208F5-0001-0000-C000-000000000046}';
  IID_IAxes: TGUID = '{000208F4-0001-0000-C000-000000000046}';
  IID_IPoints: TGUID = '{000208F2-0001-0000-C000-000000000046}';
  IID_IPoint: TGUID = '{000208F1-0001-0000-C000-000000000046}';
  IID_ISeries: TGUID = '{000208F0-0001-0000-C000-000000000046}';
  IID_ISeriesCollection: TGUID = '{000208EF-0001-0000-C000-000000000046}';
  IID_IDataLabel: TGUID = '{000208E9-0001-0000-C000-000000000046}';
  IID_IDataLabels: TGUID = '{000208E8-0001-0000-C000-000000000046}';
  IID_ILegendEntry: TGUID = '{000208E7-0001-0000-C000-000000000046}';
  IID_ILegendEntries: TGUID = '{000208E6-0001-0000-C000-000000000046}';
  IID_ILegendKey: TGUID = '{000208E5-0001-0000-C000-000000000046}';
  IID_ITrendlines: TGUID = '{000208E4-0001-0000-C000-000000000046}';
  IID_ITrendline: TGUID = '{000208E3-0001-0000-C000-000000000046}';
  IID_ICorners: TGUID = '{000208E2-0001-0000-C000-000000000046}';
  IID_ISeriesLines: TGUID = '{000208E1-0001-0000-C000-000000000046}';
  IID_IHiLoLines: TGUID = '{000208E0-0001-0000-C000-000000000046}';
  IID_IGridlines: TGUID = '{00024700-0001-0000-C000-000000000046}';
  IID_IDropLines: TGUID = '{00024701-0001-0000-C000-000000000046}';
  IID_ILeaderLines: TGUID = '{0002441E-0001-0000-C000-000000000046}';
  IID_IUpBars: TGUID = '{00024702-0001-0000-C000-000000000046}';
  IID_IDownBars: TGUID = '{00024703-0001-0000-C000-000000000046}';
  IID_IFloor: TGUID = '{00024704-0001-0000-C000-000000000046}';
  IID_IWalls: TGUID = '{00024705-0001-0000-C000-000000000046}';
  IID_ITickLabels: TGUID = '{00024706-0001-0000-C000-000000000046}';
  IID_IPlotArea: TGUID = '{00024707-0001-0000-C000-000000000046}';
  IID_IChartArea: TGUID = '{00024708-0001-0000-C000-000000000046}';
  IID_ILegend: TGUID = '{00024709-0001-0000-C000-000000000046}';
  IID_IErrorBars: TGUID = '{0002470A-0001-0000-C000-000000000046}';
  IID_IDataTable: TGUID = '{000208FA-0001-0000-C000-000000000046}';
  IID_IDisplayUnitLabel: TGUID = '{000208D3-0001-0000-C000-000000000046}';
  DIID_Font: TGUID = '{000208F3-0000-0000-C000-000000000046}';
  DIID__Global: TGUID = '{000208FC-0000-0000-C000-000000000046}';
  DIID_Chart: TGUID = '{000208FB-0000-0000-C000-000000000046}';
  DIID_Application: TGUID = '{000208EC-0000-0000-C000-000000000046}';
  DIID_DataSheet: TGUID = '{00024726-0000-0000-C000-000000000046}';
  DIID_Range: TGUID = '{00024727-0000-0000-C000-000000000046}';
  DIID_AutoCorrect: TGUID = '{000208D4-0000-0000-C000-000000000046}';
  DIID_Border: TGUID = '{000208EE-0000-0000-C000-000000000046}';
  DIID_Interior: TGUID = '{000208ED-0000-0000-C000-000000000046}';
  DIID_ChartFillFormat: TGUID = '{0002441C-0000-0000-C000-000000000046}';
  DIID_ChartColorFormat: TGUID = '{0002441D-0000-0000-C000-000000000046}';
  DIID_Axis: TGUID = '{000208F9-0000-0000-C000-000000000046}';
  DIID_ChartTitle: TGUID = '{000208F8-0000-0000-C000-000000000046}';
  DIID_AxisTitle: TGUID = '{000208F7-0000-0000-C000-000000000046}';
  DIID_ChartGroup: TGUID = '{000208F6-0000-0000-C000-000000000046}';
  DIID_ChartGroups: TGUID = '{000208F5-0000-0000-C000-000000000046}';
  DIID_Axes: TGUID = '{000208F4-0000-0000-C000-000000000046}';
  DIID_Points: TGUID = '{000208F2-0000-0000-C000-000000000046}';
  DIID_Point: TGUID = '{000208F1-0000-0000-C000-000000000046}';
  DIID_Series: TGUID = '{000208F0-0000-0000-C000-000000000046}';
  DIID_SeriesCollection: TGUID = '{000208EF-0000-0000-C000-000000000046}';
  DIID_DataLabel: TGUID = '{000208E9-0000-0000-C000-000000000046}';
  DIID_DataLabels: TGUID = '{000208E8-0000-0000-C000-000000000046}';
  DIID_LegendEntry: TGUID = '{000208E7-0000-0000-C000-000000000046}';
  DIID_LegendEntries: TGUID = '{000208E6-0000-0000-C000-000000000046}';
  DIID_LegendKey: TGUID = '{000208E5-0000-0000-C000-000000000046}';
  DIID_Trendlines: TGUID = '{000208E4-0000-0000-C000-000000000046}';
  DIID_Trendline: TGUID = '{000208E3-0000-0000-C000-000000000046}';
  DIID_Corners: TGUID = '{000208E2-0000-0000-C000-000000000046}';
  DIID_SeriesLines: TGUID = '{000208E1-0000-0000-C000-000000000046}';
  DIID_HiLoLines: TGUID = '{000208E0-0000-0000-C000-000000000046}';
  DIID_Gridlines: TGUID = '{00024700-0000-0000-C000-000000000046}';
  DIID_DropLines: TGUID = '{00024701-0000-0000-C000-000000000046}';
  DIID_LeaderLines: TGUID = '{0002441E-0000-0000-C000-000000000046}';
  DIID_UpBars: TGUID = '{00024702-0000-0000-C000-000000000046}';
  DIID_DownBars: TGUID = '{00024703-0000-0000-C000-000000000046}';
  DIID_Floor: TGUID = '{00024704-0000-0000-C000-000000000046}';
  DIID_Walls: TGUID = '{00024705-0000-0000-C000-000000000046}';
  DIID_TickLabels: TGUID = '{00024706-0000-0000-C000-000000000046}';
  DIID_PlotArea: TGUID = '{00024707-0000-0000-C000-000000000046}';
  DIID_ChartArea: TGUID = '{00024708-0000-0000-C000-000000000046}';
  DIID_Legend: TGUID = '{00024709-0000-0000-C000-000000000046}';
  DIID_ErrorBars: TGUID = '{0002470A-0000-0000-C000-000000000046}';
  DIID_DataTable: TGUID = '{000208FA-0000-0000-C000-000000000046}';
  DIID_DisplayUnitLabel: TGUID = '{000208D3-0000-0000-C000-000000000046}';
  IID_IShape: TGUID = '{0002441F-0001-0000-C000-000000000046}';
  IID_IShapes: TGUID = '{00024420-0001-0000-C000-000000000046}';
  IID_IShapeRange: TGUID = '{00024421-0001-0000-C000-000000000046}';
  IID_IGroupShapes: TGUID = '{00024422-0001-0000-C000-000000000046}';
  IID_ITextFrame: TGUID = '{00024423-0001-0000-C000-000000000046}';
  IID_IConnectorFormat: TGUID = '{00024424-0001-0000-C000-000000000046}';
  IID_IFreeformBuilder: TGUID = '{00024425-0001-0000-C000-000000000046}';
  IID_ICanvasShapes: TGUID = '{00024426-0001-0000-C000-000000000046}';
  CLASS_Global: TGUID = '{00020800-0000-0000-C000-000000000046}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum Constants
type
  Constants = TOleEnum;
const
  xlAll = $FFFFEFF8;
  xlAutomatic = $FFFFEFF7;
  xlBoth = $00000001;
  xlCenter = $FFFFEFF4;
  xlChecker = $00000009;
  xlCircle = $00000008;
  xlCorner = $00000002;
  xlCrissCross = $00000010;
  xlCross = $00000004;
  xlDiamond = $00000002;
  xlDistributed = $FFFFEFEB;
  xlDoubleAccounting = $00000005;
  xlFixedValue = $00000001;
  xlFormats = $FFFFEFE6;
  xlGray16 = $00000011;
  xlGray8 = $00000012;
  xlGrid = $0000000F;
  xlHigh = $FFFFEFE1;
  xlInside = $00000002;
  xlJustify = $FFFFEFDE;
  xlLightDown = $0000000D;
  xlLightHorizontal = $0000000B;
  xlLightUp = $0000000E;
  xlLightVertical = $0000000C;
  xlLow = $FFFFEFDA;
  xlManual = $FFFFEFD9;
  xlMinusValues = $00000003;
  xlModule = $FFFFEFD3;
  xlNextToAxis = $00000004;
  xlNone = $FFFFEFD2;
  xlNotes = $FFFFEFD0;
  xlOff = $FFFFEFCE;
  xlOn = $00000001;
  xlPercent = $00000002;
  xlPlus = $00000009;
  xlPlusValues = $00000002;
  xlSemiGray75 = $0000000A;
  xlShowLabel = $00000004;
  xlShowLabelAndPercent = $00000005;
  xlShowPercent = $00000003;
  xlShowValue = $00000002;
  xlSimple = $FFFFEFC6;
  xlSingle = $00000002;
  xlSingleAccounting = $00000004;
  xlSolid = $00000001;
  xlSquare = $00000001;
  xlStar = $00000005;
  xlStError = $00000004;
  xlToolbarButton = $00000002;
  xlTriangle = $00000003;
  xlGray25 = $FFFFEFE4;
  xlGray50 = $FFFFEFE3;
  xlGray75 = $FFFFEFE2;
  xlBottom = $FFFFEFF5;
  xlLeft = $FFFFEFDD;
  xlRight = $FFFFEFC8;
  xlTop = $FFFFEFC0;
  xl3DBar = $FFFFEFFD;
  xl3DSurface = $FFFFEFF9;
  xlBar = $00000002;
  xlColumn = $00000003;
  xlCombination = $FFFFEFF1;
  xlCustom = $FFFFEFEE;
  xlDefaultAutoFormat = $FFFFFFFF;
  xlMaximum = $00000002;
  xlMinimum = $00000004;
  xlOpaque = $00000003;
  xlTransparent = $00000002;
  xlBidi = $FFFFEC78;
  xlLatin = $FFFFEC77;
  xlContext = $FFFFEC76;
  xlLTR = $FFFFEC75;
  xlRTL = $FFFFEC74;
  xlFullScript = $00000001;
  xlPartialScript = $00000002;
  xlMixedScript = $00000003;
  xlMixedAuthorizedScript = $00000004;
  xlDefault = $FFFFEFD1;
  xlVisualCursor = $00000002;
  xlLogicalCursor = $00000001;
  xlSystem = $00000001;
  xlPartial = $00000003;
  xlHindiNumerals = $00000003;
  xlBidiCalendar = $00000003;
  xlGregorian = $00000002;
  xlComplete = $00000004;
  xlScale = $00000003;
  xlWizardDisplayAlways = $00000001;
  xlWizardDisplayDefault = $00000000;
  xlWizardDisplayNever = $00000002;

// Constants for enum XlCreator
type
  XlCreator = TOleEnum;
const
  xlCreatorCode = $5843454C;

// Constants for enum XlChartGallery
type
  XlChartGallery = TOleEnum;
const
  xlBuiltIn = $00000015;
  xlUserDefined = $00000016;
  xlAnyGallery = $00000017;

// Constants for enum XlColorIndex
type
  XlColorIndex = TOleEnum;
const
  xlColorIndexAutomatic = $FFFFEFF7;
  xlColorIndexNone = $FFFFEFD2;

// Constants for enum XlEndStyleCap
type
  XlEndStyleCap = TOleEnum;
const
  xlCap = $00000001;
  xlNoCap = $00000002;

// Constants for enum XlRowCol
type
  XlRowCol = TOleEnum;
const
  xlColumns = $00000002;
  xlRows = $00000001;

// Constants for enum XlScaleType
type
  XlScaleType = TOleEnum;
const
  xlScaleLinear = $FFFFEFDC;
  xlScaleLogarithmic = $FFFFEFDB;

// Constants for enum XlDataSeriesType
type
  XlDataSeriesType = TOleEnum;
const
  xlAutoFill = $00000004;
  xlChronological = $00000003;
  xlGrowth = $00000002;
  xlDataSeriesLinear = $FFFFEFDC;

// Constants for enum XlAxisCrosses
type
  XlAxisCrosses = TOleEnum;
const
  xlAxisCrossesAutomatic = $FFFFEFF7;
  xlAxisCrossesCustom = $FFFFEFEE;
  xlAxisCrossesMaximum = $00000002;
  xlAxisCrossesMinimum = $00000004;

// Constants for enum XlAxisGroup
type
  XlAxisGroup = TOleEnum;
const
  xlPrimary = $00000001;
  xlSecondary = $00000002;

// Constants for enum XlBackground
type
  XlBackground = TOleEnum;
const
  xlBackgroundAutomatic = $FFFFEFF7;
  xlBackgroundOpaque = $00000003;
  xlBackgroundTransparent = $00000002;

// Constants for enum XlWindowState
type
  XlWindowState = TOleEnum;
const
  xlMaximized = $FFFFEFD7;
  xlMinimized = $FFFFEFD4;
  xlNormal = $FFFFEFD1;

// Constants for enum XlAxisType
type
  XlAxisType = TOleEnum;
const
  xlCategory = $00000001;
  xlSeriesAxis = $00000003;
  xlValue = $00000002;

// Constants for enum XlArrowHeadLength
type
  XlArrowHeadLength = TOleEnum;
const
  xlArrowHeadLengthLong = $00000003;
  xlArrowHeadLengthMedium = $FFFFEFD6;
  xlArrowHeadLengthShort = $00000001;

// Constants for enum XlVAlign
type
  XlVAlign = TOleEnum;
const
  xlVAlignBottom = $FFFFEFF5;
  xlVAlignCenter = $FFFFEFF4;
  xlVAlignDistributed = $FFFFEFEB;
  xlVAlignJustify = $FFFFEFDE;
  xlVAlignTop = $FFFFEFC0;

// Constants for enum XlTickMark
type
  XlTickMark = TOleEnum;
const
  xlTickMarkCross = $00000004;
  xlTickMarkInside = $00000002;
  xlTickMarkNone = $FFFFEFD2;
  xlTickMarkOutside = $00000003;

// Constants for enum XlErrorBarDirection
type
  XlErrorBarDirection = TOleEnum;
const
  xlX = $FFFFEFB8;
  xlY = $00000001;

// Constants for enum XlErrorBarInclude
type
  XlErrorBarInclude = TOleEnum;
const
  xlErrorBarIncludeBoth = $00000001;
  xlErrorBarIncludeMinusValues = $00000003;
  xlErrorBarIncludeNone = $FFFFEFD2;
  xlErrorBarIncludePlusValues = $00000002;

// Constants for enum XlDisplayBlanksAs
type
  XlDisplayBlanksAs = TOleEnum;
const
  xlInterpolated = $00000003;
  xlNotPlotted = $00000001;
  xlZero = $00000002;

// Constants for enum XlArrowHeadStyle
type
  XlArrowHeadStyle = TOleEnum;
const
  xlArrowHeadStyleClosed = $00000003;
  xlArrowHeadStyleDoubleClosed = $00000005;
  xlArrowHeadStyleDoubleOpen = $00000004;
  xlArrowHeadStyleNone = $FFFFEFD2;
  xlArrowHeadStyleOpen = $00000002;

// Constants for enum XlArrowHeadWidth
type
  XlArrowHeadWidth = TOleEnum;
const
  xlArrowHeadWidthMedium = $FFFFEFD6;
  xlArrowHeadWidthNarrow = $00000001;
  xlArrowHeadWidthWide = $00000003;

// Constants for enum XlHAlign
type
  XlHAlign = TOleEnum;
const
  xlHAlignCenter = $FFFFEFF4;
  xlHAlignCenterAcrossSelection = $00000007;
  xlHAlignDistributed = $FFFFEFEB;
  xlHAlignFill = $00000005;
  xlHAlignGeneral = $00000001;
  xlHAlignJustify = $FFFFEFDE;
  xlHAlignLeft = $FFFFEFDD;
  xlHAlignRight = $FFFFEFC8;

// Constants for enum XlTickLabelPosition
type
  XlTickLabelPosition = TOleEnum;
const
  xlTickLabelPositionHigh = $FFFFEFE1;
  xlTickLabelPositionLow = $FFFFEFDA;
  xlTickLabelPositionNextToAxis = $00000004;
  xlTickLabelPositionNone = $FFFFEFD2;

// Constants for enum XlLegendPosition
type
  XlLegendPosition = TOleEnum;
const
  xlLegendPositionBottom = $FFFFEFF5;
  xlLegendPositionCorner = $00000002;
  xlLegendPositionLeft = $FFFFEFDD;
  xlLegendPositionRight = $FFFFEFC8;
  xlLegendPositionTop = $FFFFEFC0;
  xlLegendPositionCustom = $FFFFEFBF;

// Constants for enum XlChartPictureType
type
  XlChartPictureType = TOleEnum;
const
  xlStackScale = $00000003;
  xlStack = $00000002;
  xlStretch = $00000001;

// Constants for enum XlChartPicturePlacement
type
  XlChartPicturePlacement = TOleEnum;
const
  xlSides = $00000001;
  xlEnd = $00000002;
  xlEndSides = $00000003;
  xlFront = $00000004;
  xlFrontSides = $00000005;
  xlFrontEnd = $00000006;
  xlAllFaces = $00000007;

// Constants for enum XlOrientation
type
  XlOrientation = TOleEnum;
const
  xlDownward = $FFFFEFB6;
  xlHorizontal = $FFFFEFE0;
  xlUpward = $FFFFEFB5;
  xlVertical = $FFFFEFBA;

// Constants for enum XlTickLabelOrientation
type
  XlTickLabelOrientation = TOleEnum;
const
  xlTickLabelOrientationAutomatic = $FFFFEFF7;
  xlTickLabelOrientationDownward = $FFFFEFB6;
  xlTickLabelOrientationHorizontal = $FFFFEFE0;
  xlTickLabelOrientationUpward = $FFFFEFB5;
  xlTickLabelOrientationVertical = $FFFFEFBA;

// Constants for enum XlBorderWeight
type
  XlBorderWeight = TOleEnum;
const
  xlHairline = $00000001;
  xlMedium = $FFFFEFD6;
  xlThick = $00000004;
  xlThin = $00000002;

// Constants for enum XlDataSeriesDate
type
  XlDataSeriesDate = TOleEnum;
const
  xlDay = $00000001;
  xlMonth = $00000003;
  xlWeekday = $00000002;
  xlYear = $00000004;

// Constants for enum XlUnderlineStyle
type
  XlUnderlineStyle = TOleEnum;
const
  xlUnderlineStyleDouble = $FFFFEFE9;
  xlUnderlineStyleDoubleAccounting = $00000005;
  xlUnderlineStyleNone = $FFFFEFD2;
  xlUnderlineStyleSingle = $00000002;
  xlUnderlineStyleSingleAccounting = $00000004;

// Constants for enum XlErrorBarType
type
  XlErrorBarType = TOleEnum;
const
  xlErrorBarTypeCustom = $FFFFEFEE;
  xlErrorBarTypeFixedValue = $00000001;
  xlErrorBarTypePercent = $00000002;
  xlErrorBarTypeStDev = $FFFFEFC5;
  xlErrorBarTypeStError = $00000004;

// Constants for enum XlTrendlineType
type
  XlTrendlineType = TOleEnum;
const
  xlExponential = $00000005;
  xlLinear = $FFFFEFDC;
  xlLogarithmic = $FFFFEFDB;
  xlMovingAvg = $00000006;
  xlPolynomial = $00000003;
  xlPower = $00000004;

// Constants for enum XlLineStyle
type
  XlLineStyle = TOleEnum;
const
  xlContinuous = $00000001;
  xlDash = $FFFFEFED;
  xlDashDot = $00000004;
  xlDashDotDot = $00000005;
  xlDot = $FFFFEFEA;
  xlDouble = $FFFFEFE9;
  xlSlantDashDot = $0000000D;
  xlLineStyleNone = $FFFFEFD2;

// Constants for enum XlDataLabelsType
type
  XlDataLabelsType = TOleEnum;
const
  xlDataLabelsShowNone = $FFFFEFD2;
  xlDataLabelsShowValue = $00000002;
  xlDataLabelsShowPercent = $00000003;
  xlDataLabelsShowLabel = $00000004;
  xlDataLabelsShowLabelAndPercent = $00000005;
  xlDataLabelsShowBubbleSizes = $00000006;

// Constants for enum XlMarkerStyle
type
  XlMarkerStyle = TOleEnum;
const
  xlMarkerStyleAutomatic = $FFFFEFF7;
  xlMarkerStyleCircle = $00000008;
  xlMarkerStyleDash = $FFFFEFED;
  xlMarkerStyleDiamond = $00000002;
  xlMarkerStyleDot = $FFFFEFEA;
  xlMarkerStyleNone = $FFFFEFD2;
  xlMarkerStylePicture = $FFFFEFCD;
  xlMarkerStylePlus = $00000009;
  xlMarkerStyleSquare = $00000001;
  xlMarkerStyleStar = $00000005;
  xlMarkerStyleTriangle = $00000003;
  xlMarkerStyleX = $FFFFEFB8;

// Constants for enum XlPictureConvertorType
type
  XlPictureConvertorType = TOleEnum;
const
  xlBMP = $00000001;
  xlCGM = $00000007;
  xlDRW = $00000004;
  xlDXF = $00000005;
  xlEPS = $00000008;
  xlHGL = $00000006;
  xlPCT = $0000000D;
  xlPCX = $0000000A;
  xlPIC = $0000000B;
  xlPLT = $0000000C;
  xlTIF = $00000009;
  xlWMF = $00000002;
  xlWPG = $00000003;

// Constants for enum XlPattern
type
  XlPattern = TOleEnum;
const
  xlPatternAutomatic = $FFFFEFF7;
  xlPatternChecker = $00000009;
  xlPatternCrissCross = $00000010;
  xlPatternDown = $FFFFEFE7;
  xlPatternGray16 = $00000011;
  xlPatternGray25 = $FFFFEFE4;
  xlPatternGray50 = $FFFFEFE3;
  xlPatternGray75 = $FFFFEFE2;
  xlPatternGray8 = $00000012;
  xlPatternGrid = $0000000F;
  xlPatternHorizontal = $FFFFEFE0;
  xlPatternLightDown = $0000000D;
  xlPatternLightHorizontal = $0000000B;
  xlPatternLightUp = $0000000E;
  xlPatternLightVertical = $0000000C;
  xlPatternNone = $FFFFEFD2;
  xlPatternSemiGray75 = $0000000A;
  xlPatternSolid = $00000001;
  xlPatternUp = $FFFFEFBE;
  xlPatternVertical = $FFFFEFBA;
  xlPatternLinearGradient = $00000FA0;
  xlPatternRectangularGradient = $00000FA1;

// Constants for enum XlChartSplitType
type
  XlChartSplitType = TOleEnum;
const
  xlSplitByPosition = $00000001;
  xlSplitByPercentValue = $00000003;
  xlSplitByCustomSplit = $00000004;
  xlSplitByValue = $00000002;

// Constants for enum XlDisplayUnit
type
  XlDisplayUnit = TOleEnum;
const
  xlHundreds = $FFFFFFFE;
  xlThousands = $FFFFFFFD;
  xlTenThousands = $FFFFFFFC;
  xlHundredThousands = $FFFFFFFB;
  xlMillions = $FFFFFFFA;
  xlTenMillions = $FFFFFFF9;
  xlHundredMillions = $FFFFFFF8;
  xlThousandMillions = $FFFFFFF7;
  xlMillionMillions = $FFFFFFF6;

// Constants for enum XlDataLabelPosition
type
  XlDataLabelPosition = TOleEnum;
const
  xlLabelPositionCenter = $FFFFEFF4;
  xlLabelPositionAbove = $00000000;
  xlLabelPositionBelow = $00000001;
  xlLabelPositionLeft = $FFFFEFDD;
  xlLabelPositionRight = $FFFFEFC8;
  xlLabelPositionOutsideEnd = $00000002;
  xlLabelPositionInsideEnd = $00000003;
  xlLabelPositionInsideBase = $00000004;
  xlLabelPositionBestFit = $00000005;
  xlLabelPositionMixed = $00000006;
  xlLabelPositionCustom = $00000007;

// Constants for enum XlTimeUnit
type
  XlTimeUnit = TOleEnum;
const
  xlDays = $00000000;
  xlMonths = $00000001;
  xlYears = $00000002;

// Constants for enum XlCategoryType
type
  XlCategoryType = TOleEnum;
const
  xlCategoryScale = $00000002;
  xlTimeScale = $00000003;
  xlAutomaticScale = $FFFFEFF7;

// Constants for enum XlBarShape
type
  XlBarShape = TOleEnum;
const
  xlBox = $00000000;
  xlPyramidToPoint = $00000001;
  xlPyramidToMax = $00000002;
  xlCylinder = $00000003;
  xlConeToPoint = $00000004;
  xlConeToMax = $00000005;

// Constants for enum XlChartType
type
  XlChartType = TOleEnum;
const
  xlColumnClustered = $00000033;
  xlColumnStacked = $00000034;
  xlColumnStacked100 = $00000035;
  xl3DColumnClustered = $00000036;
  xl3DColumnStacked = $00000037;
  xl3DColumnStacked100 = $00000038;
  xlBarClustered = $00000039;
  xlBarStacked = $0000003A;
  xlBarStacked100 = $0000003B;
  xl3DBarClustered = $0000003C;
  xl3DBarStacked = $0000003D;
  xl3DBarStacked100 = $0000003E;
  xlLineStacked = $0000003F;
  xlLineStacked100 = $00000040;
  xlLineMarkers = $00000041;
  xlLineMarkersStacked = $00000042;
  xlLineMarkersStacked100 = $00000043;
  xlPieOfPie = $00000044;
  xlPieExploded = $00000045;
  xl3DPieExploded = $00000046;
  xlBarOfPie = $00000047;
  xlXYScatterSmooth = $00000048;
  xlXYScatterSmoothNoMarkers = $00000049;
  xlXYScatterLines = $0000004A;
  xlXYScatterLinesNoMarkers = $0000004B;
  xlAreaStacked = $0000004C;
  xlAreaStacked100 = $0000004D;
  xl3DAreaStacked = $0000004E;
  xl3DAreaStacked100 = $0000004F;
  xlDoughnutExploded = $00000050;
  xlRadarMarkers = $00000051;
  xlRadarFilled = $00000052;
  xlSurface = $00000053;
  xlSurfaceWireframe = $00000054;
  xlSurfaceTopView = $00000055;
  xlSurfaceTopViewWireframe = $00000056;
  xlBubble = $0000000F;
  xlBubble3DEffect = $00000057;
  xlStockHLC = $00000058;
  xlStockOHLC = $00000059;
  xlStockVHLC = $0000005A;
  xlStockVOHLC = $0000005B;
  xlCylinderColClustered = $0000005C;
  xlCylinderColStacked = $0000005D;
  xlCylinderColStacked100 = $0000005E;
  xlCylinderBarClustered = $0000005F;
  xlCylinderBarStacked = $00000060;
  xlCylinderBarStacked100 = $00000061;
  xlCylinderCol = $00000062;
  xlConeColClustered = $00000063;
  xlConeColStacked = $00000064;
  xlConeColStacked100 = $00000065;
  xlConeBarClustered = $00000066;
  xlConeBarStacked = $00000067;
  xlConeBarStacked100 = $00000068;
  xlConeCol = $00000069;
  xlPyramidColClustered = $0000006A;
  xlPyramidColStacked = $0000006B;
  xlPyramidColStacked100 = $0000006C;
  xlPyramidBarClustered = $0000006D;
  xlPyramidBarStacked = $0000006E;
  xlPyramidBarStacked100 = $0000006F;
  xlPyramidCol = $00000070;
  xl3DColumn = $FFFFEFFC;
  xlLine = $00000004;
  xl3DLine = $FFFFEFFB;
  xl3DPie = $FFFFEFFA;
  xlPie = $00000005;
  xlXYScatter = $FFFFEFB7;
  xl3DArea = $FFFFEFFE;
  xlArea = $00000001;
  xlDoughnut = $FFFFEFE8;
  xlRadar = $FFFFEFC9;

// Constants for enum XlChartItem
type
  XlChartItem = TOleEnum;
const
  xlDataLabel = $00000000;
  xlChartArea = $00000002;
  xlSeries = $00000003;
  xlChartTitle = $00000004;
  xlWalls = $00000005;
  xlCorners = $00000006;
  xlDataTable = $00000007;
  xlTrendline = $00000008;
  xlErrorBars = $00000009;
  xlXErrorBars = $0000000A;
  xlYErrorBars = $0000000B;
  xlLegendEntry = $0000000C;
  xlLegendKey = $0000000D;
  xlShape = $0000000E;
  xlMajorGridlines = $0000000F;
  xlMinorGridlines = $00000010;
  xlAxisTitle = $00000011;
  xlUpBars = $00000012;
  xlPlotArea = $00000013;
  xlDownBars = $00000014;
  xlAxis = $00000015;
  xlSeriesLines = $00000016;
  xlFloor = $00000017;
  xlLegend = $00000018;
  xlHiLoLines = $00000019;
  xlDropLines = $0000001A;
  xlRadarAxisLabels = $0000001B;
  xlNothing = $0000001C;
  xlLeaderLines = $0000001D;
  xlDisplayUnitLabel = $0000001E;
  xlPivotChartFieldButton = $0000001F;
  xlPivotChartDropZone = $00000020;

// Constants for enum XlSizeRepresents
type
  XlSizeRepresents = TOleEnum;
const
  xlSizeIsWidth = $00000002;
  xlSizeIsArea = $00000001;

// Constants for enum XlInsertShiftDirection
type
  XlInsertShiftDirection = TOleEnum;
const
  xlShiftDown = $FFFFEFE7;
  xlShiftToRight = $FFFFEFBF;

// Constants for enum XlDeleteShiftDirection
type
  XlDeleteShiftDirection = TOleEnum;
const
  xlShiftToLeft = $FFFFEFC1;
  xlShiftUp = $FFFFEFBE;

// Constants for enum XlDirection
type
  XlDirection = TOleEnum;
const
  xlDown = $FFFFEFE7;
  xlToLeft = $FFFFEFC1;
  xlToRight = $FFFFEFBF;
  xlUp = $FFFFEFBE;

// Constants for enum XlConsolidationFunction
type
  XlConsolidationFunction = TOleEnum;
const
  xlAverage = $FFFFEFF6;
  xlCount = $FFFFEFF0;
  xlCountNums = $FFFFEFEF;
  xlMax = $FFFFEFD8;
  xlMin = $FFFFEFD5;
  xlProduct = $FFFFEFCB;
  xlStDev = $FFFFEFC5;
  xlStDevP = $FFFFEFC4;
  xlSum = $FFFFEFC3;
  xlVar = $FFFFEFBC;
  xlVarP = $FFFFEFBB;
  xlUnknown = $000003E8;

// Constants for enum XlSheetType
type
  XlSheetType = TOleEnum;
const
  xlChart = $FFFFEFF3;
  xlDialogSheet = $FFFFEFEC;
  xlExcel4IntlMacroSheet = $00000004;
  xlExcel4MacroSheet = $00000003;
  xlWorksheet = $FFFFEFB9;

// Constants for enum XlLocationInTable
type
  XlLocationInTable = TOleEnum;
const
  xlColumnHeader = $FFFFEFF2;
  xlColumnItem = $00000005;
  xlDataHeader = $00000003;
  xlDataItem = $00000007;
  xlPageHeader = $00000002;
  xlPageItem = $00000006;
  xlRowHeader = $FFFFEFC7;
  xlRowItem = $00000004;
  xlTableBody = $00000008;

// Constants for enum XlFindLookIn
type
  XlFindLookIn = TOleEnum;
const
  xlFormulas = $FFFFEFE5;
  xlComments = $FFFFEFD0;
  xlValues = $FFFFEFBD;

// Constants for enum XlWindowType
type
  XlWindowType = TOleEnum;
const
  xlChartAsWindow = $00000005;
  xlChartInPlace = $00000004;
  xlClipboard = $00000003;
  xlInfo = $FFFFEFDF;
  xlWorkbook = $00000001;

// Constants for enum XlPivotFieldDataType
type
  XlPivotFieldDataType = TOleEnum;
const
  xlDate = $00000002;
  xlNumber = $FFFFEFCF;
  xlText = $FFFFEFC2;

// Constants for enum XlCopyPictureFormat
type
  XlCopyPictureFormat = TOleEnum;
const
  xlBitmap = $00000002;
  xlPicture = $FFFFEFCD;

// Constants for enum XlPivotTableSourceType
type
  XlPivotTableSourceType = TOleEnum;
const
  xlScenario = $00000004;
  xlConsolidation = $00000003;
  xlDatabase = $00000001;
  xlExternal = $00000002;
  xlPivotTable = $FFFFEFCC;

// Constants for enum XlReferenceStyle
type
  XlReferenceStyle = TOleEnum;
const
  xlA1 = $00000001;
  xlR1C1 = $FFFFEFCA;

// Constants for enum XlPivotFormatType
type
  XlPivotFormatType = TOleEnum;
const
  xlReport1 = $00000000;
  xlReport2 = $00000001;
  xlReport3 = $00000002;
  xlReport4 = $00000003;
  xlReport5 = $00000004;
  xlReport6 = $00000005;
  xlReport7 = $00000006;
  xlReport8 = $00000007;
  xlReport9 = $00000008;
  xlReport10 = $00000009;
  xlTable1 = $0000000A;
  xlTable2 = $0000000B;
  xlTable3 = $0000000C;
  xlTable4 = $0000000D;
  xlTable5 = $0000000E;
  xlTable6 = $0000000F;
  xlTable7 = $00000010;
  xlTable8 = $00000011;
  xlTable9 = $00000012;
  xlTable10 = $00000013;
  xlPTClassic = $00000014;
  xlPTNone = $00000015;

// Constants for enum XlCmdType
type
  XlCmdType = TOleEnum;
const
  xlCmdCube = $00000001;
  xlCmdSql = $00000002;
  xlCmdTable = $00000003;
  xlCmdDefault = $00000004;

// Constants for enum XlColumnDataType
type
  XlColumnDataType = TOleEnum;
const
  xlGeneralFormat = $00000001;
  xlTextFormat = $00000002;
  xlMDYFormat = $00000003;
  xlDMYFormat = $00000004;
  xlYMDFormat = $00000005;
  xlMYDFormat = $00000006;
  xlDYMFormat = $00000007;
  xlYDMFormat = $00000008;
  xlSkipColumn = $00000009;
  xlEMDFormat = $0000000A;

// Constants for enum XlQueryType
type
  XlQueryType = TOleEnum;
const
  xlODBCQuery = $00000001;
  xlDAORecordset = $00000002;
  xlWebQuery = $00000004;
  xlOLEDBQuery = $00000005;
  xlTextImport = $00000006;
  xlADORecordset = $00000007;

// Constants for enum XlWebSelectionType
type
  XlWebSelectionType = TOleEnum;
const
  xlEntirePage = $00000001;
  xlAllTables = $00000002;
  xlSpecifiedTables = $00000003;

// Constants for enum XlCubeFieldType
type
  XlCubeFieldType = TOleEnum;
const
  xlHierarchy = $00000001;
  xlMeasure = $00000002;
  xlSet = $00000003;

// Constants for enum XlWebFormatting
type
  XlWebFormatting = TOleEnum;
const
  xlWebFormattingAll = $00000001;
  xlWebFormattingRTF = $00000002;
  xlWebFormattingNone = $00000003;

// Constants for enum XlDisplayDrawingObjects
type
  XlDisplayDrawingObjects = TOleEnum;
const
  xlDisplayShapes = $FFFFEFF8;
  xlHide = $00000003;
  xlPlaceholders = $00000002;

// Constants for enum XlSubtototalLocationType
type
  XlSubtototalLocationType = TOleEnum;
const
  xlAtTop = $00000001;
  xlAtBottom = $00000002;

// Constants for enum XlDataLabelSeparator
type
  XlDataLabelSeparator = TOleEnum;
const
  xlDataLabelSeparatorDefault = $00000001;

// Constants for enum XlRangeValueDataType
type
  XlRangeValueDataType = TOleEnum;
const
  xlRangeValueDefault = $0000000A;
  xlRangeValueXMLSpreadsheet = $0000000B;
  xlRangeValueMSPersistXML = $0000000C;

// Constants for enum XlInsertFormatOrigin
type
  XlInsertFormatOrigin = TOleEnum;
const
  xlFormatFromLeftOrAbove = $00000000;
  xlFormatFromRightOrBelow = $00000001;

// Constants for enum XlArabicModes
type
  XlArabicModes = TOleEnum;
const
  xlArabicNone = $00000000;
  xlArabicStrictAlefHamza = $00000001;
  xlArabicStrictFinalYaa = $00000002;
  xlArabicBothStrict = $00000003;

// Constants for enum XlImportDataAs
type
  XlImportDataAs = TOleEnum;
const
  xlQueryTable = $00000000;
  xlPivotTableReport = $00000001;
  xlTable = $00000002;

// Constants for enum XlCalculatedMemberType
type
  XlCalculatedMemberType = TOleEnum;
const
  xlCalculatedMember = $00000000;
  xlCalculatedSet = $00000001;

// Constants for enum XlHebrewModes
type
  XlHebrewModes = TOleEnum;
const
  xlHebrewFullScript = $00000000;
  xlHebrewPartialScript = $00000001;
  xlHebrewMixedScript = $00000002;
  xlHebrewMixedAuthorizedScript = $00000003;

// Constants for enum XlThemeFont
type
  XlThemeFont = TOleEnum;
const
  xlThemeFontNone = $00000000;
  xlThemeFontMajor = $00000001;
  xlThemeFontMinor = $00000002;

// Constants for enum XlFixedFormatType
type
  XlFixedFormatType = TOleEnum;
const
  xlTypePDF = $00000000;
  xlTypeXPS = $00000001;

// Constants for enum XlFixedFormatQuality
type
  XlFixedFormatQuality = TOleEnum;
const
  xlQualityStandard = $00000000;
  xlQualityMinimum = $00000001;

// Constants for enum XlChartElementPosition
type
  XlChartElementPosition = TOleEnum;
const
  xlChartElementPositionAutomatic = $FFFFEFF7;
  xlChartElementPositionCustom = $FFFFEFEE;

// Constants for enum XlGenerateTableRefs
type
  XlGenerateTableRefs = TOleEnum;
const
  xlGenerateTableRefA1 = $00000000;
  xlGenerateTableRefStruct = $00000001;

// Constants for enum XlGradientFillType
type
  XlGradientFillType = TOleEnum;
const
  xlGradientFillLinear = $00000000;
  xlGradientFillPath = $00000001;

// Constants for enum XlThreadMode
type
  XlThreadMode = TOleEnum;
const
  xlThreadModeAutomatic = $00000000;
  xlThreadModeManual = $00000001;

// Constants for enum XlOartHorizontalOverflow
type
  XlOartHorizontalOverflow = TOleEnum;
const
  xlOartHorizontalOverflowOverflow = $00000000;
  xlOartHorizontalOverflowClip = $00000001;

// Constants for enum XlOartVerticalOverflow
type
  XlOartVerticalOverflow = TOleEnum;
const
  xlOartVerticalOverflowOverflow = $00000000;
  xlOartVerticalOverflowClip = $00000001;
  xlOartVerticalOverflowEllipsis = $00000002;

// Constants for enum XlAllocation
type
  XlAllocation = TOleEnum;
const
  xlManualAllocation = $00000001;
  xlAutomaticAllocation = $00000002;

// Constants for enum XlAllocationValue
type
  XlAllocationValue = TOleEnum;
const
  xlAllocateValue = $00000001;
  xlAllocateIncrement = $00000002;

// Constants for enum XlAllocationMethod
type
  XlAllocationMethod = TOleEnum;
const
  xlEqualAllocation = $00000001;
  xlWeightedAllocation = $00000002;

// Constants for enum XlCellChangedState
type
  XlCellChangedState = TOleEnum;
const
  xlCellNotChanged = $00000001;
  xlCellChanged = $00000002;
  xlCellChangeApplied = $00000003;

// Constants for enum XlPivotFieldRepeatLabels
type
  XlPivotFieldRepeatLabels = TOleEnum;
const
  xlDoNotRepeatLabels = $00000001;
  xlRepeatLabels = $00000002;

// Constants for enum XlPieSliceIndex
type
  XlPieSliceIndex = TOleEnum;
const
  xlOuterCounterClockwisePoint = $00000001;
  xlOuterCenterPoint = $00000002;
  xlOuterClockwisePoint = $00000003;
  xlMidClockwiseRadiusPoint = $00000004;
  xlCenterPoint = $00000005;
  xlMidCounterClockwiseRadiusPoint = $00000006;
  xlInnerClockwisePoint = $00000007;
  xlInnerCenterPoint = $00000008;
  xlInnerCounterClockwisePoint = $00000009;

// Constants for enum XlSpanishModes
type
  XlSpanishModes = TOleEnum;
const
  xlSpanishTuteoOnly = $00000000;
  xlSpanishTuteoAndVoseo = $00000001;
  xlSpanishVoseoOnly = $00000002;

// Constants for enum XlSlicerCrossFilterType
type
  XlSlicerCrossFilterType = TOleEnum;
const
  xlSlicerNoCrossFilter = $00000001;
  xlSlicerCrossFilterShowItemsWithDataAtTop = $00000002;
  xlSlicerCrossFilterShowItemsWithNoData = $00000003;

// Constants for enum XlSlicerSort
type
  XlSlicerSort = TOleEnum;
const
  xlSlicerSortDataSourceOrder = $00000001;
  xlSlicerSortAscending = $00000002;
  xlSlicerSortDescending = $00000003;

// Constants for enum XlPieSliceLocation
type
  XlPieSliceLocation = TOleEnum;
const
  xlHorizontalCoordinate = $00000001;
  xlVerticalCoordinate = $00000002;

// Constants for enum XlPortugueseReform
type
  XlPortugueseReform = TOleEnum;
const
  xlPortuguesePreReform = $00000001;
  xlPortuguesePostReform = $00000002;
  xlPortugueseBoth = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IFont = interface;
  _IGlobal = interface;
  IChart = interface;
  IApplication = interface;
  IDataSheet = interface;
  IRange = interface;
  IAutoCorrect = interface;
  IBorder = interface;
  IInterior = interface;
  IChartFillFormat = interface;
  IChartColorFormat = interface;
  IAxis = interface;
  IChartTitle = interface;
  IAxisTitle = interface;
  IChartGroup = interface;
  IChartGroups = interface;
  IAxes = interface;
  IPoints = interface;
  IPoint = interface;
  ISeries = interface;
  ISeriesCollection = interface;
  IDataLabel = interface;
  IDataLabels = interface;
  ILegendEntry = interface;
  ILegendEntries = interface;
  ILegendKey = interface;
  ITrendlines = interface;
  ITrendline = interface;
  ICorners = interface;
  ISeriesLines = interface;
  IHiLoLines = interface;
  IGridlines = interface;
  IDropLines = interface;
  ILeaderLines = interface;
  IUpBars = interface;
  IDownBars = interface;
  IFloor = interface;
  IWalls = interface;
  ITickLabels = interface;
  IPlotArea = interface;
  IChartArea = interface;
  ILegend = interface;
  IErrorBars = interface;
  IDataTable = interface;
  IDisplayUnitLabel = interface;
  Font = dispinterface;
  _Global = dispinterface;
  Chart = dispinterface;
  Application = dispinterface;
  DataSheet = dispinterface;
  Range = dispinterface;
  AutoCorrect = dispinterface;
  Border = dispinterface;
  Interior = dispinterface;
  ChartFillFormat = dispinterface;
  ChartColorFormat = dispinterface;
  Axis = dispinterface;
  ChartTitle = dispinterface;
  AxisTitle = dispinterface;
  ChartGroup = dispinterface;
  ChartGroups = dispinterface;
  Axes = dispinterface;
  Points = dispinterface;
  Point = dispinterface;
  Series = dispinterface;
  SeriesCollection = dispinterface;
  DataLabel = dispinterface;
  DataLabels = dispinterface;
  LegendEntry = dispinterface;
  LegendEntries = dispinterface;
  LegendKey = dispinterface;
  Trendlines = dispinterface;
  Trendline = dispinterface;
  Corners = dispinterface;
  SeriesLines = dispinterface;
  HiLoLines = dispinterface;
  Gridlines = dispinterface;
  DropLines = dispinterface;
  LeaderLines = dispinterface;
  UpBars = dispinterface;
  DownBars = dispinterface;
  Floor = dispinterface;
  Walls = dispinterface;
  TickLabels = dispinterface;
  PlotArea = dispinterface;
  ChartArea = dispinterface;
  Legend = dispinterface;
  ErrorBars = dispinterface;
  DataTable = dispinterface;
  DisplayUnitLabel = dispinterface;
  IShape = interface;
  IShapes = interface;
  IShapeRange = interface;
  IGroupShapes = interface;
  ITextFrame = interface;
  IConnectorFormat = interface;
  IFreeformBuilder = interface;
  ICanvasShapes = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Global = _Global;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PUserType1 = ^TGUID; {*}
  PShortint1 = ^Shortint; {*}
  PPShortint1 = ^PShortint1; {*}
  PUserType2 = ^DISPPARAMS; {*}


// *********************************************************************//
// Interface: IFont
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F3-0001-0000-C000-000000000046}
// *********************************************************************//
  IFont = interface(IDispatch)
    ['{000208F3-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Background(out RHS: OleVariant): HResult; stdcall;
    function Set_Background(RHS: OleVariant): HResult; stdcall;
    function Get_Bold(out RHS: OleVariant): HResult; stdcall;
    function Set_Bold(RHS: OleVariant): HResult; stdcall;
    function Get_Color(out RHS: OleVariant): HResult; stdcall;
    function Set_Color(RHS: OleVariant): HResult; stdcall;
    function Get_ColorIndex(out RHS: OleVariant): HResult; stdcall;
    function Set_ColorIndex(RHS: OleVariant): HResult; stdcall;
    function Get_FontStyle(out RHS: OleVariant): HResult; stdcall;
    function Set_FontStyle(RHS: OleVariant): HResult; stdcall;
    function Get_Italic(out RHS: OleVariant): HResult; stdcall;
    function Set_Italic(RHS: OleVariant): HResult; stdcall;
    function Get_Name(out RHS: OleVariant): HResult; stdcall;
    function Set_Name(RHS: OleVariant): HResult; stdcall;
    function Get_OutlineFont(out RHS: OleVariant): HResult; stdcall;
    function Set_OutlineFont(RHS: OleVariant): HResult; stdcall;
    function Get_Shadow(out RHS: OleVariant): HResult; stdcall;
    function Set_Shadow(RHS: OleVariant): HResult; stdcall;
    function Get_Size(out RHS: OleVariant): HResult; stdcall;
    function Set_Size(RHS: OleVariant): HResult; stdcall;
    function Get_Strikethrough(out RHS: OleVariant): HResult; stdcall;
    function Set_Strikethrough(RHS: OleVariant): HResult; stdcall;
    function Get_Subscript(out RHS: OleVariant): HResult; stdcall;
    function Set_Subscript(RHS: OleVariant): HResult; stdcall;
    function Get_Superscript(out RHS: OleVariant): HResult; stdcall;
    function Set_Superscript(RHS: OleVariant): HResult; stdcall;
    function Get_Underline(out RHS: OleVariant): HResult; stdcall;
    function Set_Underline(RHS: OleVariant): HResult; stdcall;
    function Get_ThemeColor(out RHS: OleVariant): HResult; stdcall;
    function Set_ThemeColor(RHS: OleVariant): HResult; stdcall;
    function Get_TintAndShade(out RHS: OleVariant): HResult; stdcall;
    function Set_TintAndShade(RHS: OleVariant): HResult; stdcall;
    function Get_ThemeFont(out RHS: XlThemeFont): HResult; stdcall;
    function Set_ThemeFont(RHS: XlThemeFont): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: _IGlobal
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208FC-0001-0000-C000-000000000046}
// *********************************************************************//
  _IGlobal = interface(IDispatch)
    ['{000208FC-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: Application): HResult; stdcall;
    function Get_CommandBars(out RHS: CommandBars): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IChart
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208FB-0001-0000-C000-000000000046}
// *********************************************************************//
  IChart = interface(IDispatch)
    ['{000208FB-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Activate: HResult; stdcall;
    function ApplyDataLabels(Type_: OleVariant; LegendKey: OleVariant; AutoText: OleVariant; 
                             HasLeaderLines: OleVariant): HResult; stdcall;
    function Get_Area3DGroup(out RHS: ChartGroup): HResult; stdcall;
    function AreaGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function AutoFormat(Gallery: Integer; Format: OleVariant): HResult; stdcall;
    function Get_AutoScaling(out RHS: WordBool): HResult; stdcall;
    function Set_AutoScaling(RHS: WordBool): HResult; stdcall;
    function Axes(Type_: OleVariant; AxisGroup: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_Bar3DGroup(out RHS: ChartGroup): HResult; stdcall;
    function BarGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_ChartArea(out RHS: ChartArea): HResult; stdcall;
    function ChartGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_ChartTitle(out RHS: ChartTitle): HResult; stdcall;
    function Get_Colors(Index: OleVariant; out RHS: OleVariant): HResult; stdcall;
    function Set_Colors(Index: OleVariant; RHS: OleVariant): HResult; stdcall;
    function Get_Column3DGroup(out RHS: ChartGroup): HResult; stdcall;
    function ColumnGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_CommandBars(out RHS: CommandBars): HResult; stdcall;
    function Get_Corners(out RHS: Corners): HResult; stdcall;
    function Get_DataTable(out RHS: DataTable): HResult; stdcall;
    function Get_DepthPercent(out RHS: Integer): HResult; stdcall;
    function Set_DepthPercent(RHS: Integer): HResult; stdcall;
    function Deselect: HResult; stdcall;
    function Get_DisplayBlanksAs(out RHS: XlDisplayBlanksAs): HResult; stdcall;
    function Set_DisplayBlanksAs(RHS: XlDisplayBlanksAs): HResult; stdcall;
    function DoughnutGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_Elevation(out RHS: Integer): HResult; stdcall;
    function Set_Elevation(RHS: Integer): HResult; stdcall;
    function Get_Floor(out RHS: Floor): HResult; stdcall;
    function Get_GapDepth(out RHS: Integer): HResult; stdcall;
    function Set_GapDepth(RHS: Integer): HResult; stdcall;
    function Get_HasAxis(Index1: OleVariant; Index2: OleVariant; out RHS: OleVariant): HResult; stdcall;
    function Set_HasAxis(Index1: OleVariant; Index2: OleVariant; RHS: OleVariant): HResult; stdcall;
    function Get_HasDataTable(out RHS: WordBool): HResult; stdcall;
    function Set_HasDataTable(RHS: WordBool): HResult; stdcall;
    function Get_HasLegend(out RHS: WordBool): HResult; stdcall;
    function Set_HasLegend(RHS: WordBool): HResult; stdcall;
    function Get_HasTitle(out RHS: WordBool): HResult; stdcall;
    function Set_HasTitle(RHS: WordBool): HResult; stdcall;
    function Get_Height(out RHS: OleVariant): HResult; stdcall;
    function Set_Height(RHS: OleVariant): HResult; stdcall;
    function Get_HeightPercent(out RHS: Integer): HResult; stdcall;
    function Set_HeightPercent(RHS: Integer): HResult; stdcall;
    function Get_Left(out RHS: OleVariant): HResult; stdcall;
    function Set_Left(RHS: OleVariant): HResult; stdcall;
    function Get_Legend(out RHS: Legend): HResult; stdcall;
    function Get_Line3DGroup(out RHS: ChartGroup): HResult; stdcall;
    function LineGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function OmitBackground(out RHS: OleVariant): HResult; stdcall;
    function Get_Perspective(out RHS: Integer): HResult; stdcall;
    function Set_Perspective(RHS: Integer): HResult; stdcall;
    function Get_Pie3DGroup(out RHS: ChartGroup): HResult; stdcall;
    function PieGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_PlotArea(out RHS: PlotArea): HResult; stdcall;
    procedure _Dummy44; stdcall;
    function RadarGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_RightAngleAxes(out RHS: OleVariant): HResult; stdcall;
    function Set_RightAngleAxes(RHS: OleVariant): HResult; stdcall;
    function Get_Rotation(out RHS: OleVariant): HResult; stdcall;
    function Set_Rotation(RHS: OleVariant): HResult; stdcall;
    function SeriesCollection(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function SetEchoOn(EchoOn: OleVariant; out RHS: OleVariant): HResult; stdcall;
    function Get_SubType(out RHS: OleVariant): HResult; stdcall;
    function Set_SubType(RHS: OleVariant): HResult; stdcall;
    function Get_SurfaceGroup(out RHS: ChartGroup): HResult; stdcall;
    function Get_Top(out RHS: OleVariant): HResult; stdcall;
    function Set_Top(RHS: OleVariant): HResult; stdcall;
    function Get_type_(out RHS: Integer): HResult; stdcall;
    function Set_type_(RHS: Integer): HResult; stdcall;
    function Get_ChartType(out RHS: XlChartType): HResult; stdcall;
    function Set_ChartType(RHS: XlChartType): HResult; stdcall;
    function ApplyCustomType(ChartType: XlChartType; TypeName: OleVariant): HResult; stdcall;
    function Get_Walls(out RHS: Walls): HResult; stdcall;
    function Get_WallsAndGridlines2D(out RHS: WordBool): HResult; stdcall;
    function Set_WallsAndGridlines2D(RHS: WordBool): HResult; stdcall;
    function Get_Width(out RHS: OleVariant): HResult; stdcall;
    function Set_Width(RHS: OleVariant): HResult; stdcall;
    function XYGroups(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_BarShape(out RHS: XlBarShape): HResult; stdcall;
    function Set_BarShape(RHS: XlBarShape): HResult; stdcall;
    function Export(const FileName: WideString; FilterName: OleVariant; Interactive: OleVariant; 
                    out RHS: WordBool): HResult; stdcall;
    function Refresh: HResult; stdcall;
    function Get_PlotOnX(out RHS: Integer): HResult; stdcall;
    function Set_PlotOnX(RHS: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IApplication
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208EC-0001-0000-C000-000000000046}
// *********************************************************************//
  IApplication = interface(IDispatch)
    ['{000208EC-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: Application): HResult; stdcall;
    function Get_CommandBars(out RHS: CommandBars): HResult; stdcall;
    function AddChartAutoFormat(const Name: WideString; Description: OleVariant): HResult; stdcall;
    function Get_CellDragAndDrop(out RHS: WordBool): HResult; stdcall;
    function Set_CellDragAndDrop(RHS: WordBool): HResult; stdcall;
    function Chart(out RHS: Chart): HResult; stdcall;
    function Get_ChartWizardDisplay(out RHS: OleVariant): HResult; stdcall;
    function Set_ChartWizardDisplay(RHS: OleVariant): HResult; stdcall;
    function Get_DataSheet(out RHS: DataSheet): HResult; stdcall;
    function _Set_DataSheet(const RHS: DataSheet): HResult; stdcall;
    function DeleteChartAutoFormat(const Name: WideString): HResult; stdcall;
    function Get_DisplayAlerts(out RHS: WordBool): HResult; stdcall;
    function Set_DisplayAlerts(RHS: WordBool): HResult; stdcall;
    function Evaluate(const Name: WideString; out RHS: OleVariant): HResult; stdcall;
    function FileImport(const FileName: WideString; Password: OleVariant; ImportRange: OleVariant; 
                        WorksheetName: OleVariant; OverwriteCells: OleVariant): HResult; stdcall;
    function Get_HasLinks(out RHS: WordBool): HResult; stdcall;
    function Set_HasLinks(RHS: WordBool): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
    function Set_Height(RHS: Double): HResult; stdcall;
    function ImportChart(const FileName: WideString; Password: OleVariant; ImportRange: OleVariant; 
                         WorksheetName: OleVariant; OverwriteCells: OleVariant): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_MoveAfterReturn(out RHS: WordBool): HResult; stdcall;
    function Set_MoveAfterReturn(RHS: WordBool): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Set_Name(const RHS: WideString): HResult; stdcall;
    function Get_PlotBy(out RHS: XlRowCol): HResult; stdcall;
    function Set_PlotBy(RHS: XlRowCol): HResult; stdcall;
    function Quit: HResult; stdcall;
    function SaveAs(const FileName: WideString): HResult; stdcall;
    function SaveAsOldFileFormat(MajorVersion: OleVariant; MinorVersion: OleVariant): HResult; stdcall;
    function SetDefaultChart(FormatName: OleVariant; Gallery: OleVariant): HResult; stdcall;
    function Get_ShowChartTipNames(out RHS: WordBool): HResult; stdcall;
    function Set_ShowChartTipNames(RHS: WordBool): HResult; stdcall;
    function Get_ShowChartTipValues(out RHS: WordBool): HResult; stdcall;
    function Set_ShowChartTipValues(RHS: WordBool): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Update: HResult; stdcall;
    function Get_Version(out RHS: WideString): HResult; stdcall;
    function Get_Visible(out RHS: WordBool): HResult; stdcall;
    function Set_Visible(RHS: WordBool): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Set_Width(RHS: Double): HResult; stdcall;
    function Get_WindowState(out RHS: XlWindowState): HResult; stdcall;
    function Set_WindowState(RHS: XlWindowState): HResult; stdcall;
    function Get_AutoCorrect(out RHS: AutoCorrect): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDataSheet
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024726-0001-0000-C000-000000000046}
// *********************************************************************//
  IDataSheet = interface(IDispatch)
    ['{00024726-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Activate: HResult; stdcall;
    function Get_Cells(out RHS: Range): HResult; stdcall;
    function Get_Columns(out RHS: Range): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function _Set_Font(const RHS: Font): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
    function Set_Height(RHS: Double): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Range(Range1: OleVariant; Range2: OleVariant; out RHS: Range): HResult; stdcall;
    function Get_Rows(out RHS: Range): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Set_Width(RHS: Double): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IRange
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024727-0001-0000-C000-000000000046}
// *********************************************************************//
  IRange = interface(IDispatch)
    ['{00024727-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function AutoFit: HResult; stdcall;
    function Get_Cells(out RHS: Range): HResult; stdcall;
    function Clear: HResult; stdcall;
    function ClearContents: HResult; stdcall;
    function ClearFormats: HResult; stdcall;
    function Get_Columns(out RHS: Range): HResult; stdcall;
    function Get_ColumnWidth(out RHS: OleVariant): HResult; stdcall;
    function Set_ColumnWidth(RHS: OleVariant): HResult; stdcall;
    function Copy(Destination: OleVariant): HResult; stdcall;
    function Cut(Destination: OleVariant): HResult; stdcall;
    function Delete(Shift: OleVariant): HResult; stdcall;
    function ImportData(FileName: OleVariant; Range: OleVariant): HResult; stdcall;
    function Get_Include(out RHS: OleVariant): HResult; stdcall;
    function Set_Include(RHS: OleVariant): HResult; stdcall;
    function Insert(Shift: OleVariant): HResult; stdcall;
    function Get_Item(RowIndex: OleVariant; ColumnIndex: OleVariant; lcid: Integer; 
                      out RHS: OleVariant): HResult; stdcall;
    function Set_Item(RowIndex: OleVariant; ColumnIndex: OleVariant; lcid: Integer; RHS: OleVariant): HResult; stdcall;
    function Get__NewEnum(out RHS: IUnknown): HResult; stdcall;
    function Get_NumberFormat(out RHS: OleVariant): HResult; stdcall;
    function Set_NumberFormat(RHS: OleVariant): HResult; stdcall;
    function Paste(Link: OleVariant): HResult; stdcall;
    function Get_Rows(out RHS: Range): HResult; stdcall;
    function Get_Value(RangeValueDataType: OleVariant; lcid: Integer; out RHS: OleVariant): HResult; stdcall;
    function Set_Value(RangeValueDataType: OleVariant; lcid: Integer; RHS: OleVariant): HResult; stdcall;
    function Get__Default(RowIndex: OleVariant; ColumnIndex: OleVariant; lcid: Integer; 
                          out RHS: OleVariant): HResult; stdcall;
    function Set__Default(RowIndex: OleVariant; ColumnIndex: OleVariant; lcid: Integer; 
                          RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAutoCorrect
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208D4-0001-0000-C000-000000000046}
// *********************************************************************//
  IAutoCorrect = interface(IDispatch)
    ['{000208D4-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function AddReplacement(const What: WideString; const Replacement: WideString; 
                            out RHS: OleVariant): HResult; stdcall;
    function Get_CapitalizeNamesOfDays(out RHS: WordBool): HResult; stdcall;
    function Set_CapitalizeNamesOfDays(RHS: WordBool): HResult; stdcall;
    function DeleteReplacement(const What: WideString; out RHS: OleVariant): HResult; stdcall;
    function Get_ReplacementList(Index: OleVariant; out RHS: OleVariant): HResult; stdcall;
    function Set_ReplacementList(Index: OleVariant; RHS: OleVariant): HResult; stdcall;
    function Get_ReplaceText(out RHS: WordBool): HResult; stdcall;
    function Set_ReplaceText(RHS: WordBool): HResult; stdcall;
    function Get_TwoInitialCapitals(out RHS: WordBool): HResult; stdcall;
    function Set_TwoInitialCapitals(RHS: WordBool): HResult; stdcall;
    function Get_CorrectSentenceCap(out RHS: WordBool): HResult; stdcall;
    function Set_CorrectSentenceCap(RHS: WordBool): HResult; stdcall;
    function Get_CorrectCapsLock(out RHS: WordBool): HResult; stdcall;
    function Set_CorrectCapsLock(RHS: WordBool): HResult; stdcall;
    function Get_DisplayAutoCorrectOptions(out RHS: WordBool): HResult; stdcall;
    function Set_DisplayAutoCorrectOptions(RHS: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IBorder
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208EE-0001-0000-C000-000000000046}
// *********************************************************************//
  IBorder = interface(IDispatch)
    ['{000208EE-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Color(out RHS: OleVariant): HResult; stdcall;
    function Set_Color(RHS: OleVariant): HResult; stdcall;
    function Get_ColorIndex(out RHS: OleVariant): HResult; stdcall;
    function Set_ColorIndex(RHS: OleVariant): HResult; stdcall;
    function Get_LineStyle(out RHS: OleVariant): HResult; stdcall;
    function Set_LineStyle(RHS: OleVariant): HResult; stdcall;
    function Get_Weight(out RHS: OleVariant): HResult; stdcall;
    function Set_Weight(RHS: OleVariant): HResult; stdcall;
    function Get_ThemeColor(out RHS: OleVariant): HResult; stdcall;
    function Set_ThemeColor(RHS: OleVariant): HResult; stdcall;
    function Get_TintAndShade(out RHS: OleVariant): HResult; stdcall;
    function Set_TintAndShade(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IInterior
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208ED-0001-0000-C000-000000000046}
// *********************************************************************//
  IInterior = interface(IDispatch)
    ['{000208ED-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Color(out RHS: OleVariant): HResult; stdcall;
    function Set_Color(RHS: OleVariant): HResult; stdcall;
    function Get_ColorIndex(out RHS: OleVariant): HResult; stdcall;
    function Set_ColorIndex(RHS: OleVariant): HResult; stdcall;
    function Get_InvertIfNegative(out RHS: OleVariant): HResult; stdcall;
    function Set_InvertIfNegative(RHS: OleVariant): HResult; stdcall;
    function Get_Pattern(out RHS: OleVariant): HResult; stdcall;
    function Set_Pattern(RHS: OleVariant): HResult; stdcall;
    function Get_PatternColor(out RHS: OleVariant): HResult; stdcall;
    function Set_PatternColor(RHS: OleVariant): HResult; stdcall;
    function Get_PatternColorIndex(out RHS: OleVariant): HResult; stdcall;
    function Set_PatternColorIndex(RHS: OleVariant): HResult; stdcall;
    function Get_ThemeColor(out RHS: OleVariant): HResult; stdcall;
    function Set_ThemeColor(RHS: OleVariant): HResult; stdcall;
    function Get_TintAndShade(out RHS: OleVariant): HResult; stdcall;
    function Set_TintAndShade(RHS: OleVariant): HResult; stdcall;
    function Get_PatternThemeColor(out RHS: OleVariant): HResult; stdcall;
    function Set_PatternThemeColor(RHS: OleVariant): HResult; stdcall;
    function Get_PatternTintAndShade(out RHS: OleVariant): HResult; stdcall;
    function Set_PatternTintAndShade(RHS: OleVariant): HResult; stdcall;
    function Get_Gradient(out RHS: IDispatch): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IChartFillFormat
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0002441C-0001-0000-C000-000000000046}
// *********************************************************************//
  IChartFillFormat = interface(IDispatch)
    ['{0002441C-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function OneColorGradient(Style: MsoGradientStyle; Variant: Integer; Degree: Single): HResult; stdcall;
    function TwoColorGradient(Style: MsoGradientStyle; Variant: Integer): HResult; stdcall;
    function PresetTextured(PresetTexture: MsoPresetTexture): HResult; stdcall;
    function Solid: HResult; stdcall;
    function Patterned(Pattern: MsoPatternType): HResult; stdcall;
    function UserPicture(PictureFile: OleVariant; PictureFormat: OleVariant; 
                         PictureStackUnit: OleVariant; PicturePlacement: OleVariant): HResult; stdcall;
    function UserTextured(const TextureFile: WideString): HResult; stdcall;
    function PresetGradient(Style: MsoGradientStyle; Variant: Integer; 
                            PresetGradientType: MsoPresetGradientType): HResult; stdcall;
    function Get_BackColor(out RHS: ChartColorFormat): HResult; stdcall;
    function Get_ForeColor(out RHS: ChartColorFormat): HResult; stdcall;
    function Get_GradientColorType(out RHS: MsoGradientColorType): HResult; stdcall;
    function Get_GradientDegree(out RHS: Single): HResult; stdcall;
    function Get_GradientStyle(out RHS: MsoGradientStyle): HResult; stdcall;
    function Get_GradientVariant(out RHS: Integer): HResult; stdcall;
    function Get_Pattern(out RHS: MsoPatternType): HResult; stdcall;
    function Get_PresetGradientType(out RHS: MsoPresetGradientType): HResult; stdcall;
    function Get_PresetTexture(out RHS: MsoPresetTexture): HResult; stdcall;
    function Get_TextureName(out RHS: WideString): HResult; stdcall;
    function Get_TextureType(out RHS: MsoTextureType): HResult; stdcall;
    function Get_type_(out RHS: MsoFillType): HResult; stdcall;
    function Get_Visible(out RHS: MsoTriState): HResult; stdcall;
    function Set_Visible(RHS: MsoTriState): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IChartColorFormat
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0002441D-0001-0000-C000-000000000046}
// *********************************************************************//
  IChartColorFormat = interface(IDispatch)
    ['{0002441D-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_SchemeColor(out RHS: Integer): HResult; stdcall;
    function Set_SchemeColor(RHS: Integer): HResult; stdcall;
    function Get_RGB(out RHS: Integer): HResult; stdcall;
    function Get__Default(out RHS: Integer): HResult; stdcall;
    function Get_type_(out RHS: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAxis
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F9-0001-0000-C000-000000000046}
// *********************************************************************//
  IAxis = interface(IDispatch)
    ['{000208F9-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_AxisBetweenCategories(out RHS: WordBool): HResult; stdcall;
    function Set_AxisBetweenCategories(RHS: WordBool): HResult; stdcall;
    function Get_AxisGroup(out RHS: XlAxisGroup): HResult; stdcall;
    function Get_AxisTitle(out RHS: AxisTitle): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Get_Crosses(out RHS: XlAxisCrosses): HResult; stdcall;
    function Set_Crosses(RHS: XlAxisCrosses): HResult; stdcall;
    function Get_CrossesAt(out RHS: Double): HResult; stdcall;
    function Set_CrossesAt(RHS: Double): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_HasMajorGridlines(out RHS: WordBool): HResult; stdcall;
    function Set_HasMajorGridlines(RHS: WordBool): HResult; stdcall;
    function Get_HasMinorGridlines(out RHS: WordBool): HResult; stdcall;
    function Set_HasMinorGridlines(RHS: WordBool): HResult; stdcall;
    function Get_HasTitle(out RHS: WordBool): HResult; stdcall;
    function Set_HasTitle(RHS: WordBool): HResult; stdcall;
    function Get_MajorGridlines(out RHS: Gridlines): HResult; stdcall;
    function Get_MajorTickMark(out RHS: XlTickMark): HResult; stdcall;
    function Set_MajorTickMark(RHS: XlTickMark): HResult; stdcall;
    function Get_MajorUnit(out RHS: Double): HResult; stdcall;
    function Set_MajorUnit(RHS: Double): HResult; stdcall;
    function Get_MajorUnitIsAuto(out RHS: WordBool): HResult; stdcall;
    function Set_MajorUnitIsAuto(RHS: WordBool): HResult; stdcall;
    function Get_MaximumScale(out RHS: Double): HResult; stdcall;
    function Set_MaximumScale(RHS: Double): HResult; stdcall;
    function Get_MaximumScaleIsAuto(out RHS: WordBool): HResult; stdcall;
    function Set_MaximumScaleIsAuto(RHS: WordBool): HResult; stdcall;
    function Get_MinimumScale(out RHS: Double): HResult; stdcall;
    function Set_MinimumScale(RHS: Double): HResult; stdcall;
    function Get_MinimumScaleIsAuto(out RHS: WordBool): HResult; stdcall;
    function Set_MinimumScaleIsAuto(RHS: WordBool): HResult; stdcall;
    function Get_MinorGridlines(out RHS: Gridlines): HResult; stdcall;
    function Get_MinorTickMark(out RHS: XlTickMark): HResult; stdcall;
    function Set_MinorTickMark(RHS: XlTickMark): HResult; stdcall;
    function Get_MinorUnit(out RHS: Double): HResult; stdcall;
    function Set_MinorUnit(RHS: Double): HResult; stdcall;
    function Get_MinorUnitIsAuto(out RHS: WordBool): HResult; stdcall;
    function Set_MinorUnitIsAuto(RHS: WordBool): HResult; stdcall;
    function Get_ReversePlotOrder(out RHS: WordBool): HResult; stdcall;
    function Set_ReversePlotOrder(RHS: WordBool): HResult; stdcall;
    function Get_ScaleType(out RHS: XlScaleType): HResult; stdcall;
    function Set_ScaleType(RHS: XlScaleType): HResult; stdcall;
    function Get_TickLabelPosition(out RHS: XlTickLabelPosition): HResult; stdcall;
    function Set_TickLabelPosition(RHS: XlTickLabelPosition): HResult; stdcall;
    function Get_TickLabels(out RHS: TickLabels): HResult; stdcall;
    function Get_TickLabelSpacing(out RHS: Integer): HResult; stdcall;
    function Set_TickLabelSpacing(RHS: Integer): HResult; stdcall;
    function Get_TickMarkSpacing(out RHS: Integer): HResult; stdcall;
    function Set_TickMarkSpacing(RHS: Integer): HResult; stdcall;
    function Get_type_(out RHS: XlAxisType): HResult; stdcall;
    function Set_type_(RHS: XlAxisType): HResult; stdcall;
    function Get_BaseUnit(out RHS: XlTimeUnit): HResult; stdcall;
    function Set_BaseUnit(RHS: XlTimeUnit): HResult; stdcall;
    function Get_BaseUnitIsAuto(out RHS: WordBool): HResult; stdcall;
    function Set_BaseUnitIsAuto(RHS: WordBool): HResult; stdcall;
    function Get_MajorUnitScale(out RHS: XlTimeUnit): HResult; stdcall;
    function Set_MajorUnitScale(RHS: XlTimeUnit): HResult; stdcall;
    function Get_MinorUnitScale(out RHS: XlTimeUnit): HResult; stdcall;
    function Set_MinorUnitScale(RHS: XlTimeUnit): HResult; stdcall;
    function Get_CategoryType(out RHS: XlCategoryType): HResult; stdcall;
    function Set_CategoryType(RHS: XlCategoryType): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
    function Get_DisplayUnit(out RHS: XlDisplayUnit): HResult; stdcall;
    function Set_DisplayUnit(RHS: XlDisplayUnit): HResult; stdcall;
    function Get_DisplayUnitCustom(out RHS: Double): HResult; stdcall;
    function Set_DisplayUnitCustom(RHS: Double): HResult; stdcall;
    function Get_HasDisplayUnitLabel(out RHS: WordBool): HResult; stdcall;
    function Set_HasDisplayUnitLabel(RHS: WordBool): HResult; stdcall;
    function Get_DisplayUnitLabel(out RHS: DisplayUnitLabel): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IChartTitle
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F8-0001-0000-C000-000000000046}
// *********************************************************************//
  IChartTitle = interface(IDispatch)
    ['{000208F8-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_Caption(out RHS: WideString): HResult; stdcall;
    function Set_Caption(const RHS: WideString): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_HorizontalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_HorizontalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Orientation(out RHS: OleVariant): HResult; stdcall;
    function Set_Orientation(RHS: OleVariant): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function Get_Text(out RHS: WideString): HResult; stdcall;
    function Set_Text(const RHS: WideString): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_VerticalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_VerticalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_ReadingOrder(out RHS: Integer): HResult; stdcall;
    function Set_ReadingOrder(RHS: Integer): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAxisTitle
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F7-0001-0000-C000-000000000046}
// *********************************************************************//
  IAxisTitle = interface(IDispatch)
    ['{000208F7-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_Caption(out RHS: WideString): HResult; stdcall;
    function Set_Caption(const RHS: WideString): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_HorizontalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_HorizontalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Orientation(out RHS: OleVariant): HResult; stdcall;
    function Set_Orientation(RHS: OleVariant): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function Get_Text(out RHS: WideString): HResult; stdcall;
    function Set_Text(const RHS: WideString): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_VerticalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_VerticalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_ReadingOrder(out RHS: Integer): HResult; stdcall;
    function Set_ReadingOrder(RHS: Integer): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IChartGroup
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F6-0001-0000-C000-000000000046}
// *********************************************************************//
  IChartGroup = interface(IDispatch)
    ['{000208F6-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_AxisGroup(out RHS: XlAxisGroup): HResult; stdcall;
    function Set_AxisGroup(RHS: XlAxisGroup): HResult; stdcall;
    function Get_DoughnutHoleSize(out RHS: Integer): HResult; stdcall;
    function Set_DoughnutHoleSize(RHS: Integer): HResult; stdcall;
    function Get_DownBars(out RHS: DownBars): HResult; stdcall;
    function Get_DropLines(out RHS: DropLines): HResult; stdcall;
    function Get_FirstSliceAngle(out RHS: Integer): HResult; stdcall;
    function Set_FirstSliceAngle(RHS: Integer): HResult; stdcall;
    function Get_GapWidth(out RHS: Integer): HResult; stdcall;
    function Set_GapWidth(RHS: Integer): HResult; stdcall;
    function Get_HasDropLines(out RHS: WordBool): HResult; stdcall;
    function Set_HasDropLines(RHS: WordBool): HResult; stdcall;
    function Get_HasHiLoLines(out RHS: WordBool): HResult; stdcall;
    function Set_HasHiLoLines(RHS: WordBool): HResult; stdcall;
    function Get_HasRadarAxisLabels(out RHS: WordBool): HResult; stdcall;
    function Set_HasRadarAxisLabels(RHS: WordBool): HResult; stdcall;
    function Get_HasSeriesLines(out RHS: WordBool): HResult; stdcall;
    function Set_HasSeriesLines(RHS: WordBool): HResult; stdcall;
    function Get_HasUpDownBars(out RHS: WordBool): HResult; stdcall;
    function Set_HasUpDownBars(RHS: WordBool): HResult; stdcall;
    function Get_HiLoLines(out RHS: HiLoLines): HResult; stdcall;
    function Get_Index(out RHS: Integer): HResult; stdcall;
    function Get_Overlap(out RHS: Integer): HResult; stdcall;
    function Set_Overlap(RHS: Integer): HResult; stdcall;
    function Get_RadarAxisLabels(out RHS: TickLabels): HResult; stdcall;
    function SeriesCollection(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_SeriesLines(out RHS: SeriesLines): HResult; stdcall;
    function Get_SubType(out RHS: Integer): HResult; stdcall;
    function Set_SubType(RHS: Integer): HResult; stdcall;
    function Get_type_(out RHS: Integer): HResult; stdcall;
    function Set_type_(RHS: Integer): HResult; stdcall;
    function Get_UpBars(out RHS: UpBars): HResult; stdcall;
    function Get_VaryByCategories(out RHS: WordBool): HResult; stdcall;
    function Set_VaryByCategories(RHS: WordBool): HResult; stdcall;
    function Get_SizeRepresents(out RHS: XlSizeRepresents): HResult; stdcall;
    function Set_SizeRepresents(RHS: XlSizeRepresents): HResult; stdcall;
    function Get_BubbleScale(out RHS: Integer): HResult; stdcall;
    function Set_BubbleScale(RHS: Integer): HResult; stdcall;
    function Get_ShowNegativeBubbles(out RHS: WordBool): HResult; stdcall;
    function Set_ShowNegativeBubbles(RHS: WordBool): HResult; stdcall;
    function Get_SplitType(out RHS: XlChartSplitType): HResult; stdcall;
    function Set_SplitType(RHS: XlChartSplitType): HResult; stdcall;
    function Get_SplitValue(out RHS: OleVariant): HResult; stdcall;
    function Set_SplitValue(RHS: OleVariant): HResult; stdcall;
    function Get_SecondPlotSize(out RHS: Integer): HResult; stdcall;
    function Set_SecondPlotSize(RHS: Integer): HResult; stdcall;
    function Get_Has3DShading(out RHS: WordBool): HResult; stdcall;
    function Set_Has3DShading(RHS: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IChartGroups
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F5-0001-0000-C000-000000000046}
// *********************************************************************//
  IChartGroups = interface(IDispatch)
    ['{000208F5-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Count(out RHS: Integer): HResult; stdcall;
    function Item(Index: OleVariant; out RHS: ChartGroup): HResult; stdcall;
    function _NewEnum(out RHS: IUnknown): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IAxes
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F4-0001-0000-C000-000000000046}
// *********************************************************************//
  IAxes = interface(IDispatch)
    ['{000208F4-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Count(out RHS: Integer): HResult; stdcall;
    function Item(Type_: XlAxisType; AxisGroup: XlAxisGroup; out RHS: Axis): HResult; stdcall;
    function _NewEnum(out RHS: IUnknown): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPoints
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F2-0001-0000-C000-000000000046}
// *********************************************************************//
  IPoints = interface(IDispatch)
    ['{000208F2-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Count(out RHS: Integer): HResult; stdcall;
    function Item(Index: Integer; out RHS: Point): HResult; stdcall;
    function _NewEnum(out RHS: IUnknown): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPoint
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F1-0001-0000-C000-000000000046}
// *********************************************************************//
  IPoint = interface(IDispatch)
    ['{000208F1-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function _ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                              HasLeaderLines: OleVariant; out RHS: OleVariant): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Get_DataLabel(out RHS: DataLabel): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Explosion(out RHS: Integer): HResult; stdcall;
    function Set_Explosion(RHS: Integer): HResult; stdcall;
    function Get_HasDataLabel(out RHS: WordBool): HResult; stdcall;
    function Set_HasDataLabel(RHS: WordBool): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_InvertIfNegative(out RHS: WordBool): HResult; stdcall;
    function Set_InvertIfNegative(RHS: WordBool): HResult; stdcall;
    function Get_MarkerBackgroundColor(out RHS: Integer): HResult; stdcall;
    function Set_MarkerBackgroundColor(RHS: Integer): HResult; stdcall;
    function Get_MarkerBackgroundColorIndex(out RHS: XlColorIndex): HResult; stdcall;
    function Set_MarkerBackgroundColorIndex(RHS: XlColorIndex): HResult; stdcall;
    function Get_MarkerForegroundColor(out RHS: Integer): HResult; stdcall;
    function Set_MarkerForegroundColor(RHS: Integer): HResult; stdcall;
    function Get_MarkerForegroundColorIndex(out RHS: XlColorIndex): HResult; stdcall;
    function Set_MarkerForegroundColorIndex(RHS: XlColorIndex): HResult; stdcall;
    function Get_MarkerSize(out RHS: Integer): HResult; stdcall;
    function Set_MarkerSize(RHS: Integer): HResult; stdcall;
    function Get_MarkerStyle(out RHS: XlMarkerStyle): HResult; stdcall;
    function Set_MarkerStyle(RHS: XlMarkerStyle): HResult; stdcall;
    function Get_PictureType(out RHS: XlChartPictureType): HResult; stdcall;
    function Set_PictureType(RHS: XlChartPictureType): HResult; stdcall;
    function Get_PictureUnit(out RHS: Integer): HResult; stdcall;
    function Set_PictureUnit(RHS: Integer): HResult; stdcall;
    function Get_ApplyPictToSides(out RHS: WordBool): HResult; stdcall;
    function Set_ApplyPictToSides(RHS: WordBool): HResult; stdcall;
    function Get_ApplyPictToFront(out RHS: WordBool): HResult; stdcall;
    function Set_ApplyPictToFront(RHS: WordBool): HResult; stdcall;
    function Get_ApplyPictToEnd(out RHS: WordBool): HResult; stdcall;
    function Set_ApplyPictToEnd(RHS: WordBool): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function Get_SecondaryPlot(out RHS: WordBool): HResult; stdcall;
    function Set_SecondaryPlot(RHS: WordBool): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                             HasLeaderLines: OleVariant; ShowSeriesName: OleVariant; 
                             ShowCategoryName: OleVariant; ShowValue: OleVariant; 
                             ShowPercentage: OleVariant; ShowBubbleSize: OleVariant; 
                             Separator: OleVariant; out RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISeries
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208F0-0001-0000-C000-000000000046}
// *********************************************************************//
  ISeries = interface(IDispatch)
    ['{000208F0-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function _ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                              HasLeaderLines: OleVariant; out RHS: OleVariant): HResult; stdcall;
    function Get_AxisGroup(out RHS: XlAxisGroup): HResult; stdcall;
    function Set_AxisGroup(RHS: XlAxisGroup): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function DataLabels(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function ErrorBar(Direction: XlErrorBarDirection; Include: XlErrorBarInclude; 
                      Type_: XlErrorBarType; Amount: OleVariant; MinusValues: OleVariant; 
                      out RHS: OleVariant): HResult; stdcall;
    function Get_ErrorBars(out RHS: ErrorBars): HResult; stdcall;
    function Get_Explosion(out RHS: Integer): HResult; stdcall;
    function Set_Explosion(RHS: Integer): HResult; stdcall;
    function Get_HasDataLabels(out RHS: WordBool): HResult; stdcall;
    function Set_HasDataLabels(RHS: WordBool): HResult; stdcall;
    function Get_HasErrorBars(out RHS: WordBool): HResult; stdcall;
    function Set_HasErrorBars(RHS: WordBool): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_InvertIfNegative(out RHS: WordBool): HResult; stdcall;
    function Set_InvertIfNegative(RHS: WordBool): HResult; stdcall;
    function Get_MarkerBackgroundColor(out RHS: Integer): HResult; stdcall;
    function Set_MarkerBackgroundColor(RHS: Integer): HResult; stdcall;
    function Get_MarkerBackgroundColorIndex(out RHS: XlColorIndex): HResult; stdcall;
    function Set_MarkerBackgroundColorIndex(RHS: XlColorIndex): HResult; stdcall;
    function Get_MarkerForegroundColor(out RHS: Integer): HResult; stdcall;
    function Set_MarkerForegroundColor(RHS: Integer): HResult; stdcall;
    function Get_MarkerForegroundColorIndex(out RHS: XlColorIndex): HResult; stdcall;
    function Set_MarkerForegroundColorIndex(RHS: XlColorIndex): HResult; stdcall;
    function Get_MarkerSize(out RHS: Integer): HResult; stdcall;
    function Set_MarkerSize(RHS: Integer): HResult; stdcall;
    function Get_MarkerStyle(out RHS: XlMarkerStyle): HResult; stdcall;
    function Set_MarkerStyle(RHS: XlMarkerStyle): HResult; stdcall;
    function Get_PictureType(out RHS: XlChartPictureType): HResult; stdcall;
    function Set_PictureType(RHS: XlChartPictureType): HResult; stdcall;
    function Get_PictureUnit(out RHS: Integer): HResult; stdcall;
    function Set_PictureUnit(RHS: Integer): HResult; stdcall;
    function Points(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_Smooth(out RHS: WordBool): HResult; stdcall;
    function Set_Smooth(RHS: WordBool): HResult; stdcall;
    function Trendlines(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_type_(out RHS: Integer): HResult; stdcall;
    function Set_type_(RHS: Integer): HResult; stdcall;
    function Get_ChartType(out RHS: XlChartType): HResult; stdcall;
    function Set_ChartType(RHS: XlChartType): HResult; stdcall;
    function ApplyCustomType(ChartType: XlChartType): HResult; stdcall;
    function Get_BarShape(out RHS: XlBarShape): HResult; stdcall;
    function Set_BarShape(RHS: XlBarShape): HResult; stdcall;
    function Get_ApplyPictToSides(out RHS: WordBool): HResult; stdcall;
    function Set_ApplyPictToSides(RHS: WordBool): HResult; stdcall;
    function Get_ApplyPictToFront(out RHS: WordBool): HResult; stdcall;
    function Set_ApplyPictToFront(RHS: WordBool): HResult; stdcall;
    function Get_ApplyPictToEnd(out RHS: WordBool): HResult; stdcall;
    function Set_ApplyPictToEnd(RHS: WordBool): HResult; stdcall;
    function Get_Has3DEffect(out RHS: WordBool): HResult; stdcall;
    function Set_Has3DEffect(RHS: WordBool): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function Get_HasLeaderLines(out RHS: WordBool): HResult; stdcall;
    function Set_HasLeaderLines(RHS: WordBool): HResult; stdcall;
    function Get_LeaderLines(out RHS: LeaderLines): HResult; stdcall;
    function ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                             HasLeaderLines: OleVariant; ShowSeriesName: OleVariant; 
                             ShowCategoryName: OleVariant; ShowValue: OleVariant; 
                             ShowPercentage: OleVariant; ShowBubbleSize: OleVariant; 
                             Separator: OleVariant; out RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISeriesCollection
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208EF-0001-0000-C000-000000000046}
// *********************************************************************//
  ISeriesCollection = interface(IDispatch)
    ['{000208EF-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Count(out RHS: Integer): HResult; stdcall;
    function Item(Index: OleVariant; out RHS: Series): HResult; stdcall;
    function _NewEnum(out RHS: IUnknown): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDataLabel
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E9-0001-0000-C000-000000000046}
// *********************************************************************//
  IDataLabel = interface(IDispatch)
    ['{000208E9-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_Caption(out RHS: WideString): HResult; stdcall;
    function Set_Caption(const RHS: WideString): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_HorizontalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_HorizontalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Orientation(out RHS: OleVariant): HResult; stdcall;
    function Set_Orientation(RHS: OleVariant): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function Get_Text(out RHS: WideString): HResult; stdcall;
    function Set_Text(const RHS: WideString): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_VerticalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_VerticalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_ReadingOrder(out RHS: Integer): HResult; stdcall;
    function Set_ReadingOrder(RHS: Integer): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
    function Get_AutoText(out RHS: WordBool): HResult; stdcall;
    function Set_AutoText(RHS: WordBool): HResult; stdcall;
    function Get_NumberFormat(out RHS: WideString): HResult; stdcall;
    function Set_NumberFormat(const RHS: WideString): HResult; stdcall;
    function Get_NumberFormatLocal(out RHS: OleVariant): HResult; stdcall;
    function Set_NumberFormatLocal(RHS: OleVariant): HResult; stdcall;
    function Get_ShowLegendKey(out RHS: WordBool): HResult; stdcall;
    function Set_ShowLegendKey(RHS: WordBool): HResult; stdcall;
    function Get_type_(out RHS: OleVariant): HResult; stdcall;
    function Set_type_(RHS: OleVariant): HResult; stdcall;
    function Get_Position(out RHS: XlDataLabelPosition): HResult; stdcall;
    function Set_Position(RHS: XlDataLabelPosition): HResult; stdcall;
    function Get_ShowSeriesName(out RHS: WordBool): HResult; stdcall;
    function Set_ShowSeriesName(RHS: WordBool): HResult; stdcall;
    function Get_ShowCategoryName(out RHS: WordBool): HResult; stdcall;
    function Set_ShowCategoryName(RHS: WordBool): HResult; stdcall;
    function Get_ShowValue(out RHS: WordBool): HResult; stdcall;
    function Set_ShowValue(RHS: WordBool): HResult; stdcall;
    function Get_ShowPercentage(out RHS: WordBool): HResult; stdcall;
    function Set_ShowPercentage(RHS: WordBool): HResult; stdcall;
    function Get_ShowBubbleSize(out RHS: WordBool): HResult; stdcall;
    function Set_ShowBubbleSize(RHS: WordBool): HResult; stdcall;
    function Get_Separator(out RHS: OleVariant): HResult; stdcall;
    function Set_Separator(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDataLabels
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E8-0001-0000-C000-000000000046}
// *********************************************************************//
  IDataLabels = interface(IDispatch)
    ['{000208E8-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    procedure _Dummy8; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_HorizontalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_HorizontalAlignment(RHS: OleVariant): HResult; stdcall;
    procedure _Dummy11; stdcall;
    function Get_Orientation(out RHS: OleVariant): HResult; stdcall;
    function Set_Orientation(RHS: OleVariant): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    procedure _Dummy14; stdcall;
    procedure _Dummy15; stdcall;
    function Get_VerticalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_VerticalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_ReadingOrder(out RHS: Integer): HResult; stdcall;
    function Set_ReadingOrder(RHS: Integer): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
    function Get_AutoText(out RHS: WordBool): HResult; stdcall;
    function Set_AutoText(RHS: WordBool): HResult; stdcall;
    function Get_NumberFormat(out RHS: WideString): HResult; stdcall;
    function Set_NumberFormat(const RHS: WideString): HResult; stdcall;
    function Get_NumberFormatLocal(out RHS: OleVariant): HResult; stdcall;
    function Set_NumberFormatLocal(RHS: OleVariant): HResult; stdcall;
    function Get_ShowLegendKey(out RHS: WordBool): HResult; stdcall;
    function Set_ShowLegendKey(RHS: WordBool): HResult; stdcall;
    function Get_type_(out RHS: OleVariant): HResult; stdcall;
    function Set_type_(RHS: OleVariant): HResult; stdcall;
    function Get_Position(out RHS: XlDataLabelPosition): HResult; stdcall;
    function Set_Position(RHS: XlDataLabelPosition): HResult; stdcall;
    function Get_ShowSeriesName(out RHS: WordBool): HResult; stdcall;
    function Set_ShowSeriesName(RHS: WordBool): HResult; stdcall;
    function Get_ShowCategoryName(out RHS: WordBool): HResult; stdcall;
    function Set_ShowCategoryName(RHS: WordBool): HResult; stdcall;
    function Get_ShowValue(out RHS: WordBool): HResult; stdcall;
    function Set_ShowValue(RHS: WordBool): HResult; stdcall;
    function Get_ShowPercentage(out RHS: WordBool): HResult; stdcall;
    function Set_ShowPercentage(RHS: WordBool): HResult; stdcall;
    function Get_ShowBubbleSize(out RHS: WordBool): HResult; stdcall;
    function Set_ShowBubbleSize(RHS: WordBool): HResult; stdcall;
    function Get_Separator(out RHS: OleVariant): HResult; stdcall;
    function Set_Separator(RHS: OleVariant): HResult; stdcall;
    function Get_Count(out RHS: Integer): HResult; stdcall;
    function Item(Index: OleVariant; out RHS: DataLabel): HResult; stdcall;
    function _NewEnum(out RHS: IUnknown): HResult; stdcall;
    procedure _Dummy34; stdcall;
  end;

// *********************************************************************//
// Interface: ILegendEntry
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E7-0001-0000-C000-000000000046}
// *********************************************************************//
  ILegendEntry = interface(IDispatch)
    ['{000208E7-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_Index(out RHS: Integer): HResult; stdcall;
    function Get_LegendKey(out RHS: LegendKey): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ILegendEntries
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E6-0001-0000-C000-000000000046}
// *********************************************************************//
  ILegendEntries = interface(IDispatch)
    ['{000208E6-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Count(out RHS: Integer): HResult; stdcall;
    function Item(Index: OleVariant; out RHS: LegendEntry): HResult; stdcall;
    function _NewEnum(out RHS: IUnknown): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ILegendKey
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E5-0001-0000-C000-000000000046}
// *********************************************************************//
  ILegendKey = interface(IDispatch)
    ['{000208E5-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_InvertIfNegative(out RHS: WordBool): HResult; stdcall;
    function Set_InvertIfNegative(RHS: WordBool): HResult; stdcall;
    function Get_MarkerBackgroundColor(out RHS: Integer): HResult; stdcall;
    function Set_MarkerBackgroundColor(RHS: Integer): HResult; stdcall;
    function Get_MarkerBackgroundColorIndex(out RHS: XlColorIndex): HResult; stdcall;
    function Set_MarkerBackgroundColorIndex(RHS: XlColorIndex): HResult; stdcall;
    function Get_MarkerForegroundColor(out RHS: Integer): HResult; stdcall;
    function Set_MarkerForegroundColor(RHS: Integer): HResult; stdcall;
    function Get_MarkerForegroundColorIndex(out RHS: XlColorIndex): HResult; stdcall;
    function Set_MarkerForegroundColorIndex(RHS: XlColorIndex): HResult; stdcall;
    function Get_MarkerSize(out RHS: Integer): HResult; stdcall;
    function Set_MarkerSize(RHS: Integer): HResult; stdcall;
    function Get_MarkerStyle(out RHS: XlMarkerStyle): HResult; stdcall;
    function Set_MarkerStyle(RHS: XlMarkerStyle): HResult; stdcall;
    function Get_PictureType(out RHS: Integer): HResult; stdcall;
    function Set_PictureType(RHS: Integer): HResult; stdcall;
    function Get_PictureUnit(out RHS: Integer): HResult; stdcall;
    function Set_PictureUnit(RHS: Integer): HResult; stdcall;
    function Get_Smooth(out RHS: WordBool): HResult; stdcall;
    function Set_Smooth(RHS: WordBool): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITrendlines
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E4-0001-0000-C000-000000000046}
// *********************************************************************//
  ITrendlines = interface(IDispatch)
    ['{000208E4-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Add(Type_: XlTrendlineType; Order: OleVariant; Period: OleVariant; 
                 Forward: OleVariant; Backward: OleVariant; Intercept: OleVariant; 
                 DisplayEquation: OleVariant; DisplayRSquared: OleVariant; Name: OleVariant; 
                 out RHS: Trendline): HResult; stdcall;
    function Get_Count(out RHS: Integer): HResult; stdcall;
    function Item(Index: OleVariant; out RHS: Trendline): HResult; stdcall;
    function _NewEnum(out RHS: IUnknown): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITrendline
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E3-0001-0000-C000-000000000046}
// *********************************************************************//
  ITrendline = interface(IDispatch)
    ['{000208E3-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Backward(out RHS: Integer): HResult; stdcall;
    function Set_Backward(RHS: Integer): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Get_DataLabel(out RHS: DataLabel): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_DisplayEquation(out RHS: WordBool): HResult; stdcall;
    function Set_DisplayEquation(RHS: WordBool): HResult; stdcall;
    function Get_DisplayRSquared(out RHS: WordBool): HResult; stdcall;
    function Set_DisplayRSquared(RHS: WordBool): HResult; stdcall;
    function Get_Forward(out RHS: Integer): HResult; stdcall;
    function Set_Forward(RHS: Integer): HResult; stdcall;
    function Get_Index(out RHS: Integer): HResult; stdcall;
    function Get_Intercept(out RHS: Double): HResult; stdcall;
    function Set_Intercept(RHS: Double): HResult; stdcall;
    function Get_InterceptIsAuto(out RHS: WordBool): HResult; stdcall;
    function Set_InterceptIsAuto(RHS: WordBool): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Set_Name(const RHS: WideString): HResult; stdcall;
    function Get_NameIsAuto(out RHS: WordBool): HResult; stdcall;
    function Set_NameIsAuto(RHS: WordBool): HResult; stdcall;
    function Get_Order(out RHS: Integer): HResult; stdcall;
    function Set_Order(RHS: Integer): HResult; stdcall;
    function Get_Period(out RHS: Integer): HResult; stdcall;
    function Set_Period(RHS: Integer): HResult; stdcall;
    function Get_type_(out RHS: XlTrendlineType): HResult; stdcall;
    function Set_type_(RHS: XlTrendlineType): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ICorners
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E2-0001-0000-C000-000000000046}
// *********************************************************************//
  ICorners = interface(IDispatch)
    ['{000208E2-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISeriesLines
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E1-0001-0000-C000-000000000046}
// *********************************************************************//
  ISeriesLines = interface(IDispatch)
    ['{000208E1-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IHiLoLines
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E0-0001-0000-C000-000000000046}
// *********************************************************************//
  IHiLoLines = interface(IDispatch)
    ['{000208E0-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IGridlines
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024700-0001-0000-C000-000000000046}
// *********************************************************************//
  IGridlines = interface(IDispatch)
    ['{00024700-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDropLines
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024701-0001-0000-C000-000000000046}
// *********************************************************************//
  IDropLines = interface(IDispatch)
    ['{00024701-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ILeaderLines
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0002441E-0001-0000-C000-000000000046}
// *********************************************************************//
  ILeaderLines = interface(IDispatch)
    ['{0002441E-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IUpBars
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024702-0001-0000-C000-000000000046}
// *********************************************************************//
  IUpBars = interface(IDispatch)
    ['{00024702-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDownBars
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024703-0001-0000-C000-000000000046}
// *********************************************************************//
  IDownBars = interface(IDispatch)
    ['{00024703-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IFloor
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024704-0001-0000-C000-000000000046}
// *********************************************************************//
  IFloor = interface(IDispatch)
    ['{00024704-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_PictureType(out RHS: OleVariant): HResult; stdcall;
    function Set_PictureType(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IWalls
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024705-0001-0000-C000-000000000046}
// *********************************************************************//
  IWalls = interface(IDispatch)
    ['{00024705-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_PictureType(out RHS: OleVariant): HResult; stdcall;
    function Set_PictureType(RHS: OleVariant): HResult; stdcall;
    function Get_PictureUnit(out RHS: OleVariant): HResult; stdcall;
    function Set_PictureUnit(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITickLabels
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024706-0001-0000-C000-000000000046}
// *********************************************************************//
  ITickLabels = interface(IDispatch)
    ['{00024706-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_NumberFormat(out RHS: WideString): HResult; stdcall;
    function Set_NumberFormat(const RHS: WideString): HResult; stdcall;
    function Get_NumberFormatLocal(out RHS: OleVariant): HResult; stdcall;
    function Set_NumberFormatLocal(RHS: OleVariant): HResult; stdcall;
    function Get_Orientation(out RHS: XlTickLabelOrientation): HResult; stdcall;
    function Set_Orientation(RHS: XlTickLabelOrientation): HResult; stdcall;
    function Get_ReadingOrder(out RHS: Integer): HResult; stdcall;
    function Set_ReadingOrder(RHS: Integer): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
    function Get_Offset(out RHS: Integer): HResult; stdcall;
    function Set_Offset(RHS: Integer): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IPlotArea
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024707-0001-0000-C000-000000000046}
// *********************************************************************//
  IPlotArea = interface(IDispatch)
    ['{00024707-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
    function Set_Height(RHS: Double): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Set_Width(RHS: Double): HResult; stdcall;
    function Get_InsideLeft(out RHS: Double): HResult; stdcall;
    function Get_InsideTop(out RHS: Double): HResult; stdcall;
    function Get_InsideWidth(out RHS: Double): HResult; stdcall;
    function Get_InsideHeight(out RHS: Double): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IChartArea
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024708-0001-0000-C000-000000000046}
// *********************************************************************//
  IChartArea = interface(IDispatch)
    ['{00024708-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Clear(out RHS: OleVariant): HResult; stdcall;
    function ClearContents(out RHS: OleVariant): HResult; stdcall;
    function Copy(out RHS: OleVariant): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
    function Set_Height(RHS: Double): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Set_Width(RHS: Double): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ILegend
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024709-0001-0000-C000-000000000046}
// *********************************************************************//
  ILegend = interface(IDispatch)
    ['{00024709-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function LegendEntries(Index: OleVariant; out RHS: IDispatch): HResult; stdcall;
    function Get_Position(out RHS: XlLegendPosition): HResult; stdcall;
    function Set_Position(RHS: XlLegendPosition): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function Clear(out RHS: OleVariant): HResult; stdcall;
    function Get_Height(out RHS: Double): HResult; stdcall;
    function Set_Height(RHS: Double): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_Width(out RHS: Double): HResult; stdcall;
    function Set_Width(RHS: Double): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IErrorBars
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0002470A-0001-0000-C000-000000000046}
// *********************************************************************//
  IErrorBars = interface(IDispatch)
    ['{0002470A-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function ClearFormats(out RHS: OleVariant): HResult; stdcall;
    function Get_EndStyle(out RHS: XlEndStyleCap): HResult; stdcall;
    function Set_EndStyle(RHS: XlEndStyleCap): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDataTable
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208FA-0001-0000-C000-000000000046}
// *********************************************************************//
  IDataTable = interface(IDispatch)
    ['{000208FA-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_ShowLegendKey(out RHS: WordBool): HResult; stdcall;
    function Set_ShowLegendKey(RHS: WordBool): HResult; stdcall;
    function Get_HasBorderHorizontal(out RHS: WordBool): HResult; stdcall;
    function Set_HasBorderHorizontal(RHS: WordBool): HResult; stdcall;
    function Get_HasBorderVertical(out RHS: WordBool): HResult; stdcall;
    function Set_HasBorderVertical(RHS: WordBool): HResult; stdcall;
    function Get_HasBorderOutline(out RHS: WordBool): HResult; stdcall;
    function Set_HasBorderOutline(RHS: WordBool): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Delete: HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDisplayUnitLabel
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208D3-0001-0000-C000-000000000046}
// *********************************************************************//
  IDisplayUnitLabel = interface(IDispatch)
    ['{000208D3-0001-0000-C000-000000000046}']
    function Get_Application(out RHS: Application): HResult; stdcall;
    function Get_Creator(out RHS: XlCreator): HResult; stdcall;
    function Get_Parent(out RHS: IDispatch): HResult; stdcall;
    function Get_Name(out RHS: WideString): HResult; stdcall;
    function Get_Border(out RHS: Border): HResult; stdcall;
    function Delete(out RHS: OleVariant): HResult; stdcall;
    function Get_Interior(out RHS: Interior): HResult; stdcall;
    function Get_Fill(out RHS: ChartFillFormat): HResult; stdcall;
    function Get_Caption(out RHS: WideString): HResult; stdcall;
    function Set_Caption(const RHS: WideString): HResult; stdcall;
    function Get_Font(out RHS: Font): HResult; stdcall;
    function Get_HorizontalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_HorizontalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_Left(out RHS: Double): HResult; stdcall;
    function Set_Left(RHS: Double): HResult; stdcall;
    function Get_Orientation(out RHS: OleVariant): HResult; stdcall;
    function Set_Orientation(RHS: OleVariant): HResult; stdcall;
    function Get_Shadow(out RHS: WordBool): HResult; stdcall;
    function Set_Shadow(RHS: WordBool): HResult; stdcall;
    function Get_Text(out RHS: WideString): HResult; stdcall;
    function Set_Text(const RHS: WideString): HResult; stdcall;
    function Get_Top(out RHS: Double): HResult; stdcall;
    function Set_Top(RHS: Double): HResult; stdcall;
    function Get_VerticalAlignment(out RHS: OleVariant): HResult; stdcall;
    function Set_VerticalAlignment(RHS: OleVariant): HResult; stdcall;
    function Get_ReadingOrder(out RHS: Integer): HResult; stdcall;
    function Set_ReadingOrder(RHS: Integer): HResult; stdcall;
    function Get_AutoScaleFont(out RHS: OleVariant): HResult; stdcall;
    function Set_AutoScaleFont(RHS: OleVariant): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Font
// Flags:     (4096) Dispatchable
// GUID:      {000208F3-0000-0000-C000-000000000046}
// *********************************************************************//
  Font = dispinterface
    ['{000208F3-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Background: OleVariant dispid 180;
    property Bold: OleVariant dispid 96;
    property Color: OleVariant dispid 99;
    property ColorIndex: OleVariant dispid 97;
    property FontStyle: OleVariant dispid 177;
    property Italic: OleVariant dispid 101;
    property Name: OleVariant dispid 110;
    property OutlineFont: OleVariant dispid 221;
    property Shadow: OleVariant dispid 103;
    property Size: OleVariant dispid 104;
    property Strikethrough: OleVariant dispid 105;
    property Subscript: OleVariant dispid 179;
    property Superscript: OleVariant dispid 178;
    property Underline: OleVariant dispid 106;
    property ThemeColor: OleVariant dispid 2365;
    property TintAndShade: OleVariant dispid 2366;
    property ThemeFont: XlThemeFont dispid 2367;
  end;

// *********************************************************************//
// DispIntf:  _Global
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208FC-0000-0000-C000-000000000046}
// *********************************************************************//
  _Global = dispinterface
    ['{000208FC-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: Application readonly dispid 150;
    property CommandBars: CommandBars readonly dispid 1439;
  end;

// *********************************************************************//
// DispIntf:  Chart
// Flags:     (4096) Dispatchable
// GUID:      {000208FB-0000-0000-C000-000000000046}
// *********************************************************************//
  Chart = dispinterface
    ['{000208FB-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    procedure Activate; dispid 304;
    procedure ApplyDataLabels(Type_: OleVariant; LegendKey: OleVariant; AutoText: OleVariant; 
                              HasLeaderLines: OleVariant); dispid 1922;
    property Area3DGroup: ChartGroup readonly dispid 17;
    function AreaGroups(Index: OleVariant): IDispatch; dispid 9;
    procedure AutoFormat(Gallery: Integer; Format: OleVariant); dispid 114;
    property AutoScaling: WordBool dispid 107;
    function Axes(Type_: OleVariant; AxisGroup: OleVariant): IDispatch; dispid 23;
    property Bar3DGroup: ChartGroup readonly dispid 18;
    function BarGroups(Index: OleVariant): IDispatch; dispid 10;
    property ChartArea: ChartArea readonly dispid 80;
    function ChartGroups(Index: OleVariant): IDispatch; dispid 8;
    property ChartTitle: ChartTitle readonly dispid 81;
    property Colors[Index: OleVariant]: OleVariant dispid 286;
    property Column3DGroup: ChartGroup readonly dispid 19;
    function ColumnGroups(Index: OleVariant): IDispatch; dispid 11;
    property CommandBars: CommandBars readonly dispid 1439;
    property Corners: Corners readonly dispid 79;
    property DataTable: DataTable readonly dispid 1395;
    property DepthPercent: Integer dispid 48;
    procedure Deselect; dispid 1120;
    property DisplayBlanksAs: XlDisplayBlanksAs dispid 93;
    function DoughnutGroups(Index: OleVariant): IDispatch; dispid 14;
    property Elevation: Integer dispid 49;
    property Floor: Floor readonly dispid 83;
    property GapDepth: Integer dispid 50;
    property HasAxis[Index1: OleVariant; Index2: OleVariant]: OleVariant dispid 52;
    property HasDataTable: WordBool dispid 1396;
    property HasLegend: WordBool dispid 53;
    property HasTitle: WordBool dispid 54;
    property Height: OleVariant dispid 123;
    property HeightPercent: Integer dispid 55;
    property Left: OleVariant dispid 127;
    property Legend: Legend readonly dispid 84;
    property Line3DGroup: ChartGroup readonly dispid 20;
    function LineGroups(Index: OleVariant): IDispatch; dispid 12;
    property Name: WideString readonly dispid 110;
    function OmitBackground: OleVariant; dispid 1098;
    property Perspective: Integer dispid 57;
    property Pie3DGroup: ChartGroup readonly dispid 21;
    function PieGroups(Index: OleVariant): IDispatch; dispid 13;
    property PlotArea: PlotArea readonly dispid 85;
    procedure _Dummy44; dispid 65580;
    function RadarGroups(Index: OleVariant): IDispatch; dispid 15;
    property RightAngleAxes: OleVariant dispid 58;
    property Rotation: OleVariant dispid 59;
    function SeriesCollection(Index: OleVariant): IDispatch; dispid 68;
    function SetEchoOn(EchoOn: OleVariant): OleVariant; dispid 1133;
    property SubType: OleVariant dispid 109;
    property SurfaceGroup: ChartGroup readonly dispid 22;
    property Top: OleVariant dispid 126;
    property type_: Integer dispid 108;
    property ChartType: XlChartType dispid 1400;
    procedure ApplyCustomType(ChartType: XlChartType; TypeName: OleVariant); dispid 1401;
    property Walls: Walls readonly dispid 86;
    property WallsAndGridlines2D: WordBool dispid 210;
    property Width: OleVariant dispid 122;
    function XYGroups(Index: OleVariant): IDispatch; dispid 16;
    property BarShape: XlBarShape dispid 1403;
    function Export(const FileName: WideString; FilterName: OleVariant; Interactive: OleVariant): WordBool; dispid 1414;
    procedure Refresh; dispid 1417;
    property PlotOnX: Integer dispid 1775;
  end;

// *********************************************************************//
// DispIntf:  Application
// Flags:     (4096) Dispatchable
// GUID:      {000208EC-0000-0000-C000-000000000046}
// *********************************************************************//
  Application = dispinterface
    ['{000208EC-0000-0000-C000-000000000046}']
    property Application_: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: Application readonly dispid 150;
    property CommandBars: CommandBars readonly dispid 1439;
    procedure AddChartAutoFormat(const Name: WideString; Description: OleVariant); dispid 216;
    property CellDragAndDrop: WordBool dispid 320;
    function Chart: Chart; dispid 7;
    property ChartWizardDisplay: OleVariant dispid 1129;
    property DataSheet: DataSheet dispid 1101;
    procedure DeleteChartAutoFormat(const Name: WideString); dispid 217;
    property DisplayAlerts: WordBool dispid 343;
    function Evaluate(const Name: WideString): OleVariant; dispid 1;
    procedure FileImport(const FileName: WideString; Password: OleVariant; ImportRange: OleVariant; 
                         WorksheetName: OleVariant; OverwriteCells: OleVariant); dispid 1191;
    property HasLinks: WordBool dispid 1094;
    property Height: Double dispid 123;
    procedure ImportChart(const FileName: WideString; Password: OleVariant; 
                          ImportRange: OleVariant; WorksheetName: OleVariant; 
                          OverwriteCells: OleVariant); dispid 1099;
    property Left: Double dispid 127;
    property MoveAfterReturn: WordBool dispid 374;
    property Name: WideString dispid 110;
    property PlotBy: XlRowCol dispid 202;
    procedure Quit; dispid 302;
    procedure SaveAs(const FileName: WideString); dispid 1925;
    procedure SaveAsOldFileFormat(MajorVersion: OleVariant; MinorVersion: OleVariant); dispid 1091;
    procedure SetDefaultChart(FormatName: OleVariant; Gallery: OleVariant); dispid 219;
    property ShowChartTipNames: WordBool dispid 1207;
    property ShowChartTipValues: WordBool dispid 1208;
    property Top: Double dispid 126;
    procedure Update; dispid 680;
    property Version: WideString readonly dispid 392;
    property Visible: WordBool dispid 558;
    property Width: Double dispid 122;
    property WindowState: XlWindowState dispid 396;
    property AutoCorrect: AutoCorrect readonly dispid 1145;
  end;

// *********************************************************************//
// DispIntf:  DataSheet
// Flags:     (4096) Dispatchable
// GUID:      {00024726-0000-0000-C000-000000000046}
// *********************************************************************//
  DataSheet = dispinterface
    ['{00024726-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    procedure Activate; dispid 304;
    property Cells: Range readonly dispid 238;
    property Columns: Range readonly dispid 241;
    property Font: Font dispid 146;
    property Height: Double dispid 123;
    property Left: Double dispid 127;
    property Range[Range1: OleVariant; Range2: OleVariant]: Range readonly dispid 197;
    property Rows: Range readonly dispid 258;
    property Top: Double dispid 126;
    property Width: Double dispid 122;
  end;

// *********************************************************************//
// DispIntf:  Range
// Flags:     (4096) Dispatchable
// GUID:      {00024727-0000-0000-C000-000000000046}
// *********************************************************************//
  Range = dispinterface
    ['{00024727-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    procedure AutoFit; dispid 237;
    property Cells: Range readonly dispid 238;
    procedure Clear; dispid 111;
    procedure ClearContents; dispid 113;
    procedure ClearFormats; dispid 112;
    property Columns: Range readonly dispid 241;
    property ColumnWidth: OleVariant dispid 242;
    procedure Copy(Destination: OleVariant); dispid 551;
    procedure Cut(Destination: OleVariant); dispid 565;
    procedure Delete(Shift: OleVariant); dispid 117;
    procedure ImportData(FileName: OleVariant; Range: OleVariant); dispid 1100;
    property Include: OleVariant dispid 165;
    procedure Insert(Shift: OleVariant); dispid 252;
    property Item[RowIndex: OleVariant; ColumnIndex: OleVariant]: OleVariant dispid 170;
    property _NewEnum: IUnknown readonly dispid -4;
    property NumberFormat: OleVariant dispid 193;
    procedure Paste(Link: OleVariant); dispid 211;
    property Rows: Range readonly dispid 258;
    property Value[RangeValueDataType: OleVariant]: OleVariant dispid 6;
    property _Default[RowIndex: OleVariant; ColumnIndex: OleVariant]: OleVariant dispid 0;
  end;

// *********************************************************************//
// DispIntf:  AutoCorrect
// Flags:     (4096) Dispatchable
// GUID:      {000208D4-0000-0000-C000-000000000046}
// *********************************************************************//
  AutoCorrect = dispinterface
    ['{000208D4-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    function AddReplacement(const What: WideString; const Replacement: WideString): OleVariant; dispid 1146;
    property CapitalizeNamesOfDays: WordBool dispid 1150;
    function DeleteReplacement(const What: WideString): OleVariant; dispid 1147;
    property ReplacementList[Index: OleVariant]: OleVariant dispid 1151;
    property ReplaceText: WordBool dispid 1148;
    property TwoInitialCapitals: WordBool dispid 1149;
    property CorrectSentenceCap: WordBool dispid 1619;
    property CorrectCapsLock: WordBool dispid 1620;
    property DisplayAutoCorrectOptions: WordBool dispid 1926;
  end;

// *********************************************************************//
// DispIntf:  Border
// Flags:     (4096) Dispatchable
// GUID:      {000208EE-0000-0000-C000-000000000046}
// *********************************************************************//
  Border = dispinterface
    ['{000208EE-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Color: OleVariant dispid 99;
    property ColorIndex: OleVariant dispid 97;
    property LineStyle: OleVariant dispid 119;
    property Weight: OleVariant dispid 120;
    property ThemeColor: OleVariant dispid 2365;
    property TintAndShade: OleVariant dispid 2366;
  end;

// *********************************************************************//
// DispIntf:  Interior
// Flags:     (4096) Dispatchable
// GUID:      {000208ED-0000-0000-C000-000000000046}
// *********************************************************************//
  Interior = dispinterface
    ['{000208ED-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Color: OleVariant dispid 99;
    property ColorIndex: OleVariant dispid 97;
    property InvertIfNegative: OleVariant dispid 132;
    property Pattern: OleVariant dispid 95;
    property PatternColor: OleVariant dispid 100;
    property PatternColorIndex: OleVariant dispid 98;
    property ThemeColor: OleVariant dispid 2365;
    property TintAndShade: OleVariant dispid 2366;
    property PatternThemeColor: OleVariant dispid 2368;
    property PatternTintAndShade: OleVariant dispid 2369;
    property Gradient: IDispatch readonly dispid 2370;
  end;

// *********************************************************************//
// DispIntf:  ChartFillFormat
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0002441C-0000-0000-C000-000000000046}
// *********************************************************************//
  ChartFillFormat = dispinterface
    ['{0002441C-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    procedure OneColorGradient(Style: MsoGradientStyle; Variant: Integer; Degree: Single); dispid 1621;
    procedure TwoColorGradient(Style: MsoGradientStyle; Variant: Integer); dispid 1624;
    procedure PresetTextured(PresetTexture: MsoPresetTexture); dispid 1625;
    procedure Solid; dispid 1627;
    procedure Patterned(Pattern: MsoPatternType); dispid 1628;
    procedure UserPicture(PictureFile: OleVariant; PictureFormat: OleVariant; 
                          PictureStackUnit: OleVariant; PicturePlacement: OleVariant); dispid 1629;
    procedure UserTextured(const TextureFile: WideString); dispid 1634;
    procedure PresetGradient(Style: MsoGradientStyle; Variant: Integer; 
                             PresetGradientType: MsoPresetGradientType); dispid 1636;
    property BackColor: ChartColorFormat readonly dispid 1638;
    property ForeColor: ChartColorFormat readonly dispid 1639;
    property GradientColorType: MsoGradientColorType readonly dispid 1640;
    property GradientDegree: Single readonly dispid 1641;
    property GradientStyle: MsoGradientStyle readonly dispid 1642;
    property GradientVariant: Integer readonly dispid 1643;
    property Pattern: MsoPatternType readonly dispid 95;
    property PresetGradientType: MsoPresetGradientType readonly dispid 1637;
    property PresetTexture: MsoPresetTexture readonly dispid 1626;
    property TextureName: WideString readonly dispid 1644;
    property TextureType: MsoTextureType readonly dispid 1645;
    property type_: MsoFillType readonly dispid 108;
    property Visible: MsoTriState dispid 558;
  end;

// *********************************************************************//
// DispIntf:  ChartColorFormat
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0002441D-0000-0000-C000-000000000046}
// *********************************************************************//
  ChartColorFormat = dispinterface
    ['{0002441D-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property SchemeColor: Integer dispid 1646;
    property RGB: Integer readonly dispid 1055;
    property _Default: Integer readonly dispid 0;
    property type_: Integer readonly dispid 108;
  end;

// *********************************************************************//
// DispIntf:  Axis
// Flags:     (4096) Dispatchable
// GUID:      {000208F9-0000-0000-C000-000000000046}
// *********************************************************************//
  Axis = dispinterface
    ['{000208F9-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property AxisBetweenCategories: WordBool dispid 45;
    property AxisGroup: XlAxisGroup readonly dispid 47;
    property AxisTitle: AxisTitle readonly dispid 82;
    property Border: Border readonly dispid 128;
    property Crosses: XlAxisCrosses dispid 42;
    property CrossesAt: Double dispid 43;
    function Delete: OleVariant; dispid 117;
    property HasMajorGridlines: WordBool dispid 24;
    property HasMinorGridlines: WordBool dispid 25;
    property HasTitle: WordBool dispid 54;
    property MajorGridlines: Gridlines readonly dispid 89;
    property MajorTickMark: XlTickMark dispid 26;
    property MajorUnit: Double dispid 37;
    property MajorUnitIsAuto: WordBool dispid 38;
    property MaximumScale: Double dispid 35;
    property MaximumScaleIsAuto: WordBool dispid 36;
    property MinimumScale: Double dispid 33;
    property MinimumScaleIsAuto: WordBool dispid 34;
    property MinorGridlines: Gridlines readonly dispid 90;
    property MinorTickMark: XlTickMark dispid 27;
    property MinorUnit: Double dispid 39;
    property MinorUnitIsAuto: WordBool dispid 40;
    property ReversePlotOrder: WordBool dispid 44;
    property ScaleType: XlScaleType dispid 41;
    property TickLabelPosition: XlTickLabelPosition dispid 28;
    property TickLabels: TickLabels readonly dispid 91;
    property TickLabelSpacing: Integer dispid 29;
    property TickMarkSpacing: Integer dispid 31;
    property type_: XlAxisType dispid 108;
    property BaseUnit: XlTimeUnit dispid 1647;
    property BaseUnitIsAuto: WordBool dispid 1648;
    property MajorUnitScale: XlTimeUnit dispid 1649;
    property MinorUnitScale: XlTimeUnit dispid 1650;
    property CategoryType: XlCategoryType dispid 1651;
    property Left: Double readonly dispid 127;
    property Top: Double readonly dispid 126;
    property Width: Double readonly dispid 122;
    property Height: Double readonly dispid 123;
    property DisplayUnit: XlDisplayUnit dispid 1779;
    property DisplayUnitCustom: Double dispid 1780;
    property HasDisplayUnitLabel: WordBool dispid 1781;
    property DisplayUnitLabel: DisplayUnitLabel readonly dispid 1782;
  end;

// *********************************************************************//
// DispIntf:  ChartTitle
// Flags:     (4096) Dispatchable
// GUID:      {000208F8-0000-0000-C000-000000000046}
// *********************************************************************//
  ChartTitle = dispinterface
    ['{000208F8-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property Caption: WideString dispid 139;
    property Font: Font readonly dispid 146;
    property HorizontalAlignment: OleVariant dispid 136;
    property Left: Double dispid 127;
    property Orientation: OleVariant dispid 134;
    property Shadow: WordBool dispid 103;
    property Text: WideString dispid 138;
    property Top: Double dispid 126;
    property VerticalAlignment: OleVariant dispid 137;
    property ReadingOrder: Integer dispid 975;
    property AutoScaleFont: OleVariant dispid 1525;
  end;

// *********************************************************************//
// DispIntf:  AxisTitle
// Flags:     (4096) Dispatchable
// GUID:      {000208F7-0000-0000-C000-000000000046}
// *********************************************************************//
  AxisTitle = dispinterface
    ['{000208F7-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property Caption: WideString dispid 139;
    property Font: Font readonly dispid 146;
    property HorizontalAlignment: OleVariant dispid 136;
    property Left: Double dispid 127;
    property Orientation: OleVariant dispid 134;
    property Shadow: WordBool dispid 103;
    property Text: WideString dispid 138;
    property Top: Double dispid 126;
    property VerticalAlignment: OleVariant dispid 137;
    property ReadingOrder: Integer dispid 975;
    property AutoScaleFont: OleVariant dispid 1525;
  end;

// *********************************************************************//
// DispIntf:  ChartGroup
// Flags:     (4096) Dispatchable
// GUID:      {000208F6-0000-0000-C000-000000000046}
// *********************************************************************//
  ChartGroup = dispinterface
    ['{000208F6-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property AxisGroup: XlAxisGroup dispid 47;
    property DoughnutHoleSize: Integer dispid 1126;
    property DownBars: DownBars readonly dispid 141;
    property DropLines: DropLines readonly dispid 142;
    property FirstSliceAngle: Integer dispid 63;
    property GapWidth: Integer dispid 51;
    property HasDropLines: WordBool dispid 61;
    property HasHiLoLines: WordBool dispid 62;
    property HasRadarAxisLabels: WordBool dispid 64;
    property HasSeriesLines: WordBool dispid 65;
    property HasUpDownBars: WordBool dispid 66;
    property HiLoLines: HiLoLines readonly dispid 143;
    property Index: Integer readonly dispid 486;
    property Overlap: Integer dispid 56;
    property RadarAxisLabels: TickLabels readonly dispid 144;
    function SeriesCollection(Index: OleVariant): IDispatch; dispid 68;
    property SeriesLines: SeriesLines readonly dispid 145;
    property SubType: Integer dispid 109;
    property type_: Integer dispid 108;
    property UpBars: UpBars readonly dispid 140;
    property VaryByCategories: WordBool dispid 60;
    property SizeRepresents: XlSizeRepresents dispid 1652;
    property BubbleScale: Integer dispid 1653;
    property ShowNegativeBubbles: WordBool dispid 1654;
    property SplitType: XlChartSplitType dispid 1655;
    property SplitValue: OleVariant dispid 1656;
    property SecondPlotSize: Integer dispid 1657;
    property Has3DShading: WordBool dispid 1658;
  end;

// *********************************************************************//
// DispIntf:  ChartGroups
// Flags:     (4096) Dispatchable
// GUID:      {000208F5-0000-0000-C000-000000000046}
// *********************************************************************//
  ChartGroups = dispinterface
    ['{000208F5-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Count: Integer readonly dispid 118;
    function Item(Index: OleVariant): ChartGroup; dispid 170;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  Axes
// Flags:     (4096) Dispatchable
// GUID:      {000208F4-0000-0000-C000-000000000046}
// *********************************************************************//
  Axes = dispinterface
    ['{000208F4-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Count: Integer readonly dispid 118;
    function Item(Type_: XlAxisType; AxisGroup: XlAxisGroup): Axis; dispid 170;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  Points
// Flags:     (4096) Dispatchable
// GUID:      {000208F2-0000-0000-C000-000000000046}
// *********************************************************************//
  Points = dispinterface
    ['{000208F2-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Count: Integer readonly dispid 118;
    function Item(Index: Integer): Point; dispid 170;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  Point
// Flags:     (4096) Dispatchable
// GUID:      {000208F1-0000-0000-C000-000000000046}
// *********************************************************************//
  Point = dispinterface
    ['{000208F1-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    function _ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                              HasLeaderLines: OleVariant): OleVariant; dispid 151;
    property Border: Border readonly dispid 128;
    function ClearFormats: OleVariant; dispid 112;
    property DataLabel: DataLabel readonly dispid 158;
    function Delete: OleVariant; dispid 117;
    property Explosion: Integer dispid 182;
    property HasDataLabel: WordBool dispid 77;
    property Interior: Interior readonly dispid 129;
    property InvertIfNegative: WordBool dispid 132;
    property MarkerBackgroundColor: Integer dispid 73;
    property MarkerBackgroundColorIndex: XlColorIndex dispid 74;
    property MarkerForegroundColor: Integer dispid 75;
    property MarkerForegroundColorIndex: XlColorIndex dispid 76;
    property MarkerSize: Integer dispid 231;
    property MarkerStyle: XlMarkerStyle dispid 72;
    property PictureType: XlChartPictureType dispid 161;
    property PictureUnit: Integer dispid 162;
    property ApplyPictToSides: WordBool dispid 1659;
    property ApplyPictToFront: WordBool dispid 1660;
    property ApplyPictToEnd: WordBool dispid 1661;
    property Shadow: WordBool dispid 103;
    property SecondaryPlot: WordBool dispid 1662;
    property Fill: ChartFillFormat readonly dispid 1663;
    function ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                             HasLeaderLines: OleVariant; ShowSeriesName: OleVariant; 
                             ShowCategoryName: OleVariant; ShowValue: OleVariant; 
                             ShowPercentage: OleVariant; ShowBubbleSize: OleVariant; 
                             Separator: OleVariant): OleVariant; dispid 1922;
  end;

// *********************************************************************//
// DispIntf:  Series
// Flags:     (4096) Dispatchable
// GUID:      {000208F0-0000-0000-C000-000000000046}
// *********************************************************************//
  Series = dispinterface
    ['{000208F0-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    function _ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                              HasLeaderLines: OleVariant): OleVariant; dispid 151;
    property AxisGroup: XlAxisGroup dispid 47;
    property Border: Border readonly dispid 128;
    function ClearFormats: OleVariant; dispid 112;
    function DataLabels(Index: OleVariant): IDispatch; dispid 157;
    function Delete: OleVariant; dispid 117;
    function ErrorBar(Direction: XlErrorBarDirection; Include: XlErrorBarInclude; 
                      Type_: XlErrorBarType; Amount: OleVariant; MinusValues: OleVariant): OleVariant; dispid 152;
    property ErrorBars: ErrorBars readonly dispid 159;
    property Explosion: Integer dispid 182;
    property HasDataLabels: WordBool dispid 78;
    property HasErrorBars: WordBool dispid 160;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property InvertIfNegative: WordBool dispid 132;
    property MarkerBackgroundColor: Integer dispid 73;
    property MarkerBackgroundColorIndex: XlColorIndex dispid 74;
    property MarkerForegroundColor: Integer dispid 75;
    property MarkerForegroundColorIndex: XlColorIndex dispid 76;
    property MarkerSize: Integer dispid 231;
    property MarkerStyle: XlMarkerStyle dispid 72;
    property PictureType: XlChartPictureType dispid 161;
    property PictureUnit: Integer dispid 162;
    function Points(Index: OleVariant): IDispatch; dispid 70;
    property Smooth: WordBool dispid 163;
    function Trendlines(Index: OleVariant): IDispatch; dispid 154;
    property type_: Integer dispid 108;
    property ChartType: XlChartType dispid 1400;
    procedure ApplyCustomType(ChartType: XlChartType); dispid 1401;
    property BarShape: XlBarShape dispid 1403;
    property ApplyPictToSides: WordBool dispid 1659;
    property ApplyPictToFront: WordBool dispid 1660;
    property ApplyPictToEnd: WordBool dispid 1661;
    property Has3DEffect: WordBool dispid 1665;
    property Shadow: WordBool dispid 103;
    property HasLeaderLines: WordBool dispid 1394;
    property LeaderLines: LeaderLines readonly dispid 1666;
    function ApplyDataLabels(Type_: XlDataLabelsType; LegendKey: OleVariant; AutoText: OleVariant; 
                             HasLeaderLines: OleVariant; ShowSeriesName: OleVariant; 
                             ShowCategoryName: OleVariant; ShowValue: OleVariant; 
                             ShowPercentage: OleVariant; ShowBubbleSize: OleVariant; 
                             Separator: OleVariant): OleVariant; dispid 1922;
  end;

// *********************************************************************//
// DispIntf:  SeriesCollection
// Flags:     (4096) Dispatchable
// GUID:      {000208EF-0000-0000-C000-000000000046}
// *********************************************************************//
  SeriesCollection = dispinterface
    ['{000208EF-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Count: Integer readonly dispid 118;
    function Item(Index: OleVariant): Series; dispid 170;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  DataLabel
// Flags:     (4096) Dispatchable
// GUID:      {000208E9-0000-0000-C000-000000000046}
// *********************************************************************//
  DataLabel = dispinterface
    ['{000208E9-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property Caption: WideString dispid 139;
    property Font: Font readonly dispid 146;
    property HorizontalAlignment: OleVariant dispid 136;
    property Left: Double dispid 127;
    property Orientation: OleVariant dispid 134;
    property Shadow: WordBool dispid 103;
    property Text: WideString dispid 138;
    property Top: Double dispid 126;
    property VerticalAlignment: OleVariant dispid 137;
    property ReadingOrder: Integer dispid 975;
    property AutoScaleFont: OleVariant dispid 1525;
    property AutoText: WordBool dispid 135;
    property NumberFormat: WideString dispid 193;
    property NumberFormatLocal: OleVariant dispid 1097;
    property ShowLegendKey: WordBool dispid 171;
    property type_: OleVariant dispid 108;
    property Position: XlDataLabelPosition dispid 133;
    property ShowSeriesName: WordBool dispid 1930;
    property ShowCategoryName: WordBool dispid 1931;
    property ShowValue: WordBool dispid 1932;
    property ShowPercentage: WordBool dispid 1933;
    property ShowBubbleSize: WordBool dispid 1934;
    property Separator: OleVariant dispid 1935;
  end;

// *********************************************************************//
// DispIntf:  DataLabels
// Flags:     (4096) Dispatchable
// GUID:      {000208E8-0000-0000-C000-000000000046}
// *********************************************************************//
  DataLabels = dispinterface
    ['{000208E8-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    procedure _Dummy8; dispid 65544;
    property Font: Font readonly dispid 146;
    property HorizontalAlignment: OleVariant dispid 136;
    procedure _Dummy11; dispid 65547;
    property Orientation: OleVariant dispid 134;
    property Shadow: WordBool dispid 103;
    procedure _Dummy14; dispid 65550;
    procedure _Dummy15; dispid 65551;
    property VerticalAlignment: OleVariant dispid 137;
    property ReadingOrder: Integer dispid 975;
    property AutoScaleFont: OleVariant dispid 1525;
    property AutoText: WordBool dispid 135;
    property NumberFormat: WideString dispid 193;
    property NumberFormatLocal: OleVariant dispid 1097;
    property ShowLegendKey: WordBool dispid 171;
    property type_: OleVariant dispid 108;
    property Position: XlDataLabelPosition dispid 133;
    property ShowSeriesName: WordBool dispid 1930;
    property ShowCategoryName: WordBool dispid 1931;
    property ShowValue: WordBool dispid 1932;
    property ShowPercentage: WordBool dispid 1933;
    property ShowBubbleSize: WordBool dispid 1934;
    property Separator: OleVariant dispid 1935;
    property Count: Integer readonly dispid 118;
    function Item(Index: OleVariant): DataLabel; dispid 170;
    function _NewEnum: IUnknown; dispid -4;
    procedure _Dummy34; dispid 65570;
  end;

// *********************************************************************//
// DispIntf:  LegendEntry
// Flags:     (4096) Dispatchable
// GUID:      {000208E7-0000-0000-C000-000000000046}
// *********************************************************************//
  LegendEntry = dispinterface
    ['{000208E7-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    function Delete: OleVariant; dispid 117;
    property Font: Font readonly dispid 146;
    property Index: Integer readonly dispid 486;
    property LegendKey: LegendKey readonly dispid 174;
    property AutoScaleFont: OleVariant dispid 1525;
    property Left: Double readonly dispid 127;
    property Top: Double readonly dispid 126;
    property Width: Double readonly dispid 122;
    property Height: Double readonly dispid 123;
  end;

// *********************************************************************//
// DispIntf:  LegendEntries
// Flags:     (4096) Dispatchable
// GUID:      {000208E6-0000-0000-C000-000000000046}
// *********************************************************************//
  LegendEntries = dispinterface
    ['{000208E6-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Count: Integer readonly dispid 118;
    function Item(Index: OleVariant): LegendEntry; dispid 170;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  LegendKey
// Flags:     (4096) Dispatchable
// GUID:      {000208E5-0000-0000-C000-000000000046}
// *********************************************************************//
  LegendKey = dispinterface
    ['{000208E5-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Border: Border readonly dispid 128;
    function ClearFormats: OleVariant; dispid 112;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property InvertIfNegative: WordBool dispid 132;
    property MarkerBackgroundColor: Integer dispid 73;
    property MarkerBackgroundColorIndex: XlColorIndex dispid 74;
    property MarkerForegroundColor: Integer dispid 75;
    property MarkerForegroundColorIndex: XlColorIndex dispid 76;
    property MarkerSize: Integer dispid 231;
    property MarkerStyle: XlMarkerStyle dispid 72;
    property PictureType: Integer dispid 161;
    property PictureUnit: Integer dispid 162;
    property Smooth: WordBool dispid 163;
    property Left: Double readonly dispid 127;
    property Top: Double readonly dispid 126;
    property Width: Double readonly dispid 122;
    property Height: Double readonly dispid 123;
    property Shadow: WordBool dispid 103;
  end;

// *********************************************************************//
// DispIntf:  Trendlines
// Flags:     (4096) Dispatchable
// GUID:      {000208E4-0000-0000-C000-000000000046}
// *********************************************************************//
  Trendlines = dispinterface
    ['{000208E4-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    function Add(Type_: XlTrendlineType; Order: OleVariant; Period: OleVariant; 
                 Forward: OleVariant; Backward: OleVariant; Intercept: OleVariant; 
                 DisplayEquation: OleVariant; DisplayRSquared: OleVariant; Name: OleVariant): Trendline; dispid 181;
    property Count: Integer readonly dispid 118;
    function Item(Index: OleVariant): Trendline; dispid 170;
    function _NewEnum: IUnknown; dispid -4;
  end;

// *********************************************************************//
// DispIntf:  Trendline
// Flags:     (4096) Dispatchable
// GUID:      {000208E3-0000-0000-C000-000000000046}
// *********************************************************************//
  Trendline = dispinterface
    ['{000208E3-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Backward: Integer dispid 185;
    property Border: Border readonly dispid 128;
    function ClearFormats: OleVariant; dispid 112;
    property DataLabel: DataLabel readonly dispid 158;
    function Delete: OleVariant; dispid 117;
    property DisplayEquation: WordBool dispid 190;
    property DisplayRSquared: WordBool dispid 189;
    property Forward: Integer dispid 191;
    property Index: Integer readonly dispid 486;
    property Intercept: Double dispid 186;
    property InterceptIsAuto: WordBool dispid 187;
    property Name: WideString dispid 110;
    property NameIsAuto: WordBool dispid 188;
    property Order: Integer dispid 192;
    property Period: Integer dispid 184;
    property type_: XlTrendlineType dispid 108;
  end;

// *********************************************************************//
// DispIntf:  Corners
// Flags:     (4112) Hidden Dispatchable
// GUID:      {000208E2-0000-0000-C000-000000000046}
// *********************************************************************//
  Corners = dispinterface
    ['{000208E2-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
  end;

// *********************************************************************//
// DispIntf:  SeriesLines
// Flags:     (4096) Dispatchable
// GUID:      {000208E1-0000-0000-C000-000000000046}
// *********************************************************************//
  SeriesLines = dispinterface
    ['{000208E1-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
  end;

// *********************************************************************//
// DispIntf:  HiLoLines
// Flags:     (4096) Dispatchable
// GUID:      {000208E0-0000-0000-C000-000000000046}
// *********************************************************************//
  HiLoLines = dispinterface
    ['{000208E0-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
  end;

// *********************************************************************//
// DispIntf:  Gridlines
// Flags:     (4096) Dispatchable
// GUID:      {00024700-0000-0000-C000-000000000046}
// *********************************************************************//
  Gridlines = dispinterface
    ['{00024700-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
  end;

// *********************************************************************//
// DispIntf:  DropLines
// Flags:     (4096) Dispatchable
// GUID:      {00024701-0000-0000-C000-000000000046}
// *********************************************************************//
  DropLines = dispinterface
    ['{00024701-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
  end;

// *********************************************************************//
// DispIntf:  LeaderLines
// Flags:     (4096) Dispatchable
// GUID:      {0002441E-0000-0000-C000-000000000046}
// *********************************************************************//
  LeaderLines = dispinterface
    ['{0002441E-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Border: Border readonly dispid 128;
    procedure Delete; dispid 117;
  end;

// *********************************************************************//
// DispIntf:  UpBars
// Flags:     (4096) Dispatchable
// GUID:      {00024702-0000-0000-C000-000000000046}
// *********************************************************************//
  UpBars = dispinterface
    ['{00024702-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
  end;

// *********************************************************************//
// DispIntf:  DownBars
// Flags:     (4096) Dispatchable
// GUID:      {00024703-0000-0000-C000-000000000046}
// *********************************************************************//
  DownBars = dispinterface
    ['{00024703-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
  end;

// *********************************************************************//
// DispIntf:  Floor
// Flags:     (4096) Dispatchable
// GUID:      {00024704-0000-0000-C000-000000000046}
// *********************************************************************//
  Floor = dispinterface
    ['{00024704-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function ClearFormats: OleVariant; dispid 112;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property PictureType: OleVariant dispid 161;
  end;

// *********************************************************************//
// DispIntf:  Walls
// Flags:     (4096) Dispatchable
// GUID:      {00024705-0000-0000-C000-000000000046}
// *********************************************************************//
  Walls = dispinterface
    ['{00024705-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function ClearFormats: OleVariant; dispid 112;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property PictureType: OleVariant dispid 161;
    property PictureUnit: OleVariant dispid 162;
  end;

// *********************************************************************//
// DispIntf:  TickLabels
// Flags:     (4096) Dispatchable
// GUID:      {00024706-0000-0000-C000-000000000046}
// *********************************************************************//
  TickLabels = dispinterface
    ['{00024706-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    function Delete: OleVariant; dispid 117;
    property Font: Font readonly dispid 146;
    property Name: WideString readonly dispid 110;
    property NumberFormat: WideString dispid 193;
    property NumberFormatLocal: OleVariant dispid 1097;
    property Orientation: XlTickLabelOrientation dispid 134;
    property ReadingOrder: Integer dispid 975;
    property AutoScaleFont: OleVariant dispid 1525;
    property Offset: Integer dispid 254;
  end;

// *********************************************************************//
// DispIntf:  PlotArea
// Flags:     (4096) Dispatchable
// GUID:      {00024707-0000-0000-C000-000000000046}
// *********************************************************************//
  PlotArea = dispinterface
    ['{00024707-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function ClearFormats: OleVariant; dispid 112;
    property Height: Double dispid 123;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property Left: Double dispid 127;
    property Top: Double dispid 126;
    property Width: Double dispid 122;
    property InsideLeft: Double readonly dispid 1667;
    property InsideTop: Double readonly dispid 1668;
    property InsideWidth: Double readonly dispid 1669;
    property InsideHeight: Double readonly dispid 1670;
  end;

// *********************************************************************//
// DispIntf:  ChartArea
// Flags:     (4096) Dispatchable
// GUID:      {00024708-0000-0000-C000-000000000046}
// *********************************************************************//
  ChartArea = dispinterface
    ['{00024708-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Clear: OleVariant; dispid 111;
    function ClearContents: OleVariant; dispid 113;
    function Copy: OleVariant; dispid 551;
    property Font: Font readonly dispid 146;
    property Shadow: WordBool dispid 103;
    function ClearFormats: OleVariant; dispid 112;
    property Height: Double dispid 123;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property Left: Double dispid 127;
    property Top: Double dispid 126;
    property Width: Double dispid 122;
    property AutoScaleFont: OleVariant dispid 1525;
  end;

// *********************************************************************//
// DispIntf:  Legend
// Flags:     (4096) Dispatchable
// GUID:      {00024709-0000-0000-C000-000000000046}
// *********************************************************************//
  Legend = dispinterface
    ['{00024709-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Font: Font readonly dispid 146;
    function LegendEntries(Index: OleVariant): IDispatch; dispid 173;
    property Position: XlLegendPosition dispid 133;
    property Shadow: WordBool dispid 103;
    function Clear: OleVariant; dispid 111;
    property Height: Double dispid 123;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property Left: Double dispid 127;
    property Top: Double dispid 126;
    property Width: Double dispid 122;
    property AutoScaleFont: OleVariant dispid 1525;
  end;

// *********************************************************************//
// DispIntf:  ErrorBars
// Flags:     (4096) Dispatchable
// GUID:      {0002470A-0000-0000-C000-000000000046}
// *********************************************************************//
  ErrorBars = dispinterface
    ['{0002470A-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    function ClearFormats: OleVariant; dispid 112;
    property EndStyle: XlEndStyleCap dispid 1124;
  end;

// *********************************************************************//
// DispIntf:  DataTable
// Flags:     (4096) Dispatchable
// GUID:      {000208FA-0000-0000-C000-000000000046}
// *********************************************************************//
  DataTable = dispinterface
    ['{000208FA-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property ShowLegendKey: WordBool dispid 171;
    property HasBorderHorizontal: WordBool dispid 1671;
    property HasBorderVertical: WordBool dispid 1672;
    property HasBorderOutline: WordBool dispid 1673;
    property Border: Border readonly dispid 128;
    property Font: Font readonly dispid 146;
    procedure Delete; dispid 117;
    property AutoScaleFont: OleVariant dispid 1525;
  end;

// *********************************************************************//
// DispIntf:  DisplayUnitLabel
// Flags:     (4096) Dispatchable
// GUID:      {000208D3-0000-0000-C000-000000000046}
// *********************************************************************//
  DisplayUnitLabel = dispinterface
    ['{000208D3-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 148;
    property Creator: XlCreator readonly dispid 149;
    property Parent: IDispatch readonly dispid 150;
    property Name: WideString readonly dispid 110;
    property Border: Border readonly dispid 128;
    function Delete: OleVariant; dispid 117;
    property Interior: Interior readonly dispid 129;
    property Fill: ChartFillFormat readonly dispid 1663;
    property Caption: WideString dispid 139;
    property Font: Font readonly dispid 146;
    property HorizontalAlignment: OleVariant dispid 136;
    property Left: Double dispid 127;
    property Orientation: OleVariant dispid 134;
    property Shadow: WordBool dispid 103;
    property Text: WideString dispid 138;
    property Top: Double dispid 126;
    property VerticalAlignment: OleVariant dispid 137;
    property ReadingOrder: Integer dispid 975;
    property AutoScaleFont: OleVariant dispid 1525;
  end;

// *********************************************************************//
// Interface: IShape
// Flags:     (4112) Hidden Dispatchable
// GUID:      {0002441F-0001-0000-C000-000000000046}
// *********************************************************************//
  IShape = interface(IDispatch)
    ['{0002441F-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: IShapes
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024420-0001-0000-C000-000000000046}
// *********************************************************************//
  IShapes = interface(IDispatch)
    ['{00024420-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: IShapeRange
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024421-0001-0000-C000-000000000046}
// *********************************************************************//
  IShapeRange = interface(IDispatch)
    ['{00024421-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: IGroupShapes
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024422-0001-0000-C000-000000000046}
// *********************************************************************//
  IGroupShapes = interface(IDispatch)
    ['{00024422-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: ITextFrame
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024423-0001-0000-C000-000000000046}
// *********************************************************************//
  ITextFrame = interface(IDispatch)
    ['{00024423-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: IConnectorFormat
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024424-0001-0000-C000-000000000046}
// *********************************************************************//
  IConnectorFormat = interface(IDispatch)
    ['{00024424-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: IFreeformBuilder
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024425-0001-0000-C000-000000000046}
// *********************************************************************//
  IFreeformBuilder = interface(IDispatch)
    ['{00024425-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// Interface: ICanvasShapes
// Flags:     (4112) Hidden Dispatchable
// GUID:      {00024426-0001-0000-C000-000000000046}
// *********************************************************************//
  ICanvasShapes = interface(IDispatch)
    ['{00024426-0001-0000-C000-000000000046}']
  end;

// *********************************************************************//
// The Class CoGlobal provides a Create and CreateRemote method to          
// create instances of the default interface _Global exposed by              
// the CoClass Global. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGlobal = class
    class function Create: _Global;
    class function CreateRemote(const MachineName: string): _Global;
  end;

implementation

uses ComObj;

class function CoGlobal.Create: _Global;
begin
  Result := CreateComObject(CLASS_Global) as _Global;
end;

class function CoGlobal.CreateRemote(const MachineName: string): _Global;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Global) as _Global;
end;

end.
