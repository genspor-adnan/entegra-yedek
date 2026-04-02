unit FAXCOMEXLib_TLB;

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

// PASTLWTR : 1.2
// File generated on 04/07/2008 10:46:00 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\WINDOWS\system32\fxscomex.dll (1)
// LIBID: {2BF34C1A-8CAC-419F-8547-32FDF6505DB8}
// LCID: 0
// Helpfile: 
// HelpString: Microsoft Fax Service Extended COM Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// Errors:
//   Error creating palette bitmap of (TFaxServer) : Server C:\WINDOWS\system32\fxscomex.dll contains no icons
//   Error creating palette bitmap of (TFaxDocument) : Server C:\WINDOWS\system32\fxscomex.dll contains no icons
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  FAXCOMEXLibMajorVersion = 1;
  FAXCOMEXLibMinorVersion = 0;

  LIBID_FAXCOMEXLib: TGUID = '{2BF34C1A-8CAC-419F-8547-32FDF6505DB8}';

  DIID_IFaxServerNotify: TGUID = '{2E037B27-CF8A-4ABD-B1E0-5704943BEA6F}';
  IID_IFaxServer: TGUID = '{475B6469-90A5-4878-A577-17A86E8E3462}';
  IID_IFaxDeviceProviders: TGUID = '{9FB76F62-4C7E-43A5-B6FD-502893F7E13E}';
  IID_IFaxDeviceProvider: TGUID = '{290EAC63-83EC-449C-8417-F148DF8C682A}';
  IID_IFaxDevices: TGUID = '{9E46783E-F34F-482E-A360-0416BECBBD96}';
  IID_IFaxDevice: TGUID = '{49306C59-B52E-4867-9DF4-CA5841C956D0}';
  IID_IFaxInboundRouting: TGUID = '{8148C20F-9D52-45B1-BF96-38FC12713527}';
  IID_IFaxInboundRoutingExtensions: TGUID = '{2F6C9673-7B26-42DE-8EB0-915DCD2A4F4C}';
  IID_IFaxInboundRoutingExtension: TGUID = '{885B5E08-C26C-4EF9-AF83-51580A750BE1}';
  IID_IFaxInboundRoutingMethods: TGUID = '{783FCA10-8908-4473-9D69-F67FBEA0C6B9}';
  IID_IFaxInboundRoutingMethod: TGUID = '{45700061-AD9D-4776-A8C4-64065492CF4B}';
  IID_IFaxFolders: TGUID = '{DCE3B2A8-A7AB-42BC-9D0A-3149457261A0}';
  IID_IFaxOutgoingQueue: TGUID = '{80B1DF24-D9AC-4333-B373-487CEDC80CE5}';
  IID_IFaxOutgoingJobs: TGUID = '{2C56D8E6-8C2F-4573-944C-E505F8F5AEED}';
  IID_IFaxOutgoingJob: TGUID = '{6356DAAD-6614-4583-BF7A-3AD67BBFC71C}';
  IID_IFaxSender: TGUID = '{0D879D7D-F57A-4CC6-A6F9-3EE5D527B46A}';
  IID_IFaxRecipient: TGUID = '{9A3DA3A0-538D-42B6-9444-AAA57D0CE2BC}';
  IID_IFaxIncomingQueue: TGUID = '{902E64EF-8FD8-4B75-9725-6014DF161545}';
  IID_IFaxIncomingJobs: TGUID = '{011F04E9-4FD6-4C23-9513-B6B66BB26BE9}';
  IID_IFaxIncomingJob: TGUID = '{207529E6-654A-4916-9F88-4D232EE8A107}';
  IID_IFaxIncomingArchive: TGUID = '{76062CC7-F714-4FBD-AA06-ED6E4A4B70F3}';
  IID_IFaxIncomingMessageIterator: TGUID = '{FD73ECC4-6F06-4F52-82A8-F7BA06AE3108}';
  IID_IFaxIncomingMessage: TGUID = '{7CAB88FA-2EF9-4851-B2F3-1D148FED8447}';
  IID_IFaxOutgoingArchive: TGUID = '{C9C28F40-8D80-4E53-810F-9A79919B49FD}';
  IID_IFaxOutgoingMessageIterator: TGUID = '{F5EC5D4F-B840-432F-9980-112FE42A9B7A}';
  IID_IFaxOutgoingMessage: TGUID = '{F0EA35DE-CAA5-4A7C-82C7-2B60BA5F2BE2}';
  IID_IFaxLoggingOptions: TGUID = '{34E64FB9-6B31-4D32-8B27-D286C0C33606}';
  IID_IFaxEventLogging: TGUID = '{0880D965-20E8-42E4-8E17-944F192CAAD4}';
  IID_IFaxActivityLogging: TGUID = '{1E29078B-5A69-497B-9592-49B7E7FADDB5}';
  IID_IFaxActivity: TGUID = '{4B106F97-3DF5-40F2-BC3C-44CB8115EBDF}';
  IID_IFaxOutboundRouting: TGUID = '{25DC05A4-9909-41BD-A95B-7E5D1DEC1D43}';
  IID_IFaxOutboundRoutingGroups: TGUID = '{235CBEF7-C2DE-4BFD-B8DA-75097C82C87F}';
  IID_IFaxOutboundRoutingGroup: TGUID = '{CA6289A1-7E25-4F87-9A0B-93365734962C}';
  IID_IFaxDeviceIds: TGUID = '{2F0F813F-4CE9-443E-8CA1-738CFAEEE149}';
  IID_IFaxOutboundRoutingRules: TGUID = '{DCEFA1E7-AE7D-4ED6-8521-369EDCCA5120}';
  IID_IFaxOutboundRoutingRule: TGUID = '{E1F795D5-07C2-469F-B027-ACACC23219DA}';
  IID_IFaxReceiptOptions: TGUID = '{378EFAEB-5FCB-4AFB-B2EE-E16E80614487}';
  IID_IFaxSecurity: TGUID = '{77B508C1-09C0-47A2-91EB-FCE7FDF2690E}';
  IID_IFaxJobStatus: TGUID = '{8B86F485-FD7F-4824-886B-40C5CAA617CC}';
  CLASS_FaxServer: TGUID = '{CDA8ACB0-8CF5-4F6C-9BA2-5931D40C8CAE}';
  CLASS_FaxDeviceProviders: TGUID = '{EB8FE768-875A-4F5F-82C5-03F23AAC1BD7}';
  CLASS_FaxDevices: TGUID = '{5589E28E-23CB-4919-8808-E6101846E80D}';
  CLASS_FaxInboundRouting: TGUID = '{E80248ED-AD65-4218-8108-991924D4E7ED}';
  CLASS_FaxFolders: TGUID = '{C35211D7-5776-48CB-AF44-C31BE3B2CFE5}';
  CLASS_FaxLoggingOptions: TGUID = '{1BF9EEA6-ECE0-4785-A18B-DE56E9EEF96A}';
  CLASS_FaxActivity: TGUID = '{CFEF5D0E-E84D-462E-AABB-87D31EB04FEF}';
  CLASS_FaxOutboundRouting: TGUID = '{C81B385E-B869-4AFD-86C0-616498ED9BE2}';
  CLASS_FaxReceiptOptions: TGUID = '{6982487B-227B-4C96-A61C-248348B05AB6}';
  CLASS_FaxSecurity: TGUID = '{10C4DDDE-ABF0-43DF-964F-7F3AC21A4C7B}';
  IID_IFaxDocument: TGUID = '{B207A246-09E3-4A4E-A7DC-FEA31D29458F}';
  CLASS_FaxDocument: TGUID = '{0F3F9F91-C838-415E-A4F3-3E828CA445E0}';
  IID_IFaxRecipients: TGUID = '{B9C9DE5A-894E-4492-9FA3-08C627C11D5D}';
  CLASS_FaxSender: TGUID = '{265D84D0-1850-4360-B7C8-758BBB5F0B96}';
  CLASS_FaxRecipients: TGUID = '{EA9BDF53-10A9-4D4F-A067-63C8F84F01B0}';
  CLASS_FaxIncomingArchive: TGUID = '{8426C56A-35A1-4C6F-AF93-FC952422E2C2}';
  CLASS_FaxIncomingQueue: TGUID = '{69131717-F3F1-40E3-809D-A6CBF7BD85E5}';
  CLASS_FaxOutgoingArchive: TGUID = '{43C28403-E04F-474D-990C-B94669148F59}';
  CLASS_FaxOutgoingQueue: TGUID = '{7421169E-8C43-4B0D-BB16-645C8FA40357}';
  CLASS_FaxIncomingMessageIterator: TGUID = '{6088E1D8-3FC8-45C2-87B1-909A29607EA9}';
  CLASS_FaxIncomingMessage: TGUID = '{1932FCF7-9D43-4D5A-89FF-03861B321736}';
  CLASS_FaxOutgoingJobs: TGUID = '{92BF2A6C-37BE-43FA-A37D-CB0E5F753B35}';
  CLASS_FaxOutgoingJob: TGUID = '{71BB429C-0EF9-4915-BEC5-A5D897A3E924}';
  CLASS_FaxOutgoingMessageIterator: TGUID = '{8A3224D0-D30B-49DE-9813-CB385790FBBB}';
  CLASS_FaxOutgoingMessage: TGUID = '{91B4A378-4AD8-4AEF-A4DC-97D96E939A3A}';
  CLASS_FaxIncomingJobs: TGUID = '{A1BB8A43-8866-4FB7-A15D-6266C875A5CC}';
  CLASS_FaxIncomingJob: TGUID = '{C47311EC-AE32-41B8-AE4B-3EAE0629D0C9}';
  CLASS_FaxDeviceProvider: TGUID = '{17CF1AA3-F5EB-484A-9C9A-4440A5BAABFC}';
  CLASS_FaxDevice: TGUID = '{59E3A5B2-D676-484B-A6DE-720BFA89B5AF}';
  CLASS_FaxActivityLogging: TGUID = '{F0A0294E-3BBD-48B8-8F13-8C591A55BDBC}';
  CLASS_FaxEventLogging: TGUID = '{A6850930-A0F6-4A6F-95B7-DB2EBF3D02E3}';
  CLASS_FaxOutboundRoutingGroups: TGUID = '{CCBEA1A5-E2B4-4B57-9421-B04B6289464B}';
  CLASS_FaxOutboundRoutingGroup: TGUID = '{0213F3E0-6791-4D77-A271-04D2357C50D6}';
  CLASS_FaxDeviceIds: TGUID = '{CDC539EA-7277-460E-8DE0-48A0A5760D1F}';
  CLASS_FaxOutboundRoutingRules: TGUID = '{D385BECA-E624-4473-BFAA-9F4000831F54}';
  CLASS_FaxOutboundRoutingRule: TGUID = '{6549EEBF-08D1-475A-828B-3BF105952FA0}';
  CLASS_FaxInboundRoutingExtensions: TGUID = '{189A48ED-623C-4C0D-80F2-D66C7B9EFEC2}';
  CLASS_FaxInboundRoutingExtension: TGUID = '{1D7DFB51-7207-4436-A0D9-24E32EE56988}';
  CLASS_FaxInboundRoutingMethods: TGUID = '{25FCB76A-B750-4B82-9266-FBBBAE8922BA}';
  CLASS_FaxInboundRoutingMethod: TGUID = '{4B9FD75C-0194-4B72-9CE5-02A8205AC7D4}';
  CLASS_FaxJobStatus: TGUID = '{7BF222F4-BE8D-442F-841D-6132742423BB}';
  CLASS_FaxRecipient: TGUID = '{60BF3301-7DF8-4BD8-9148-7B5801F9EFDF}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum FAX_PROVIDER_STATUS_ENUM
type
  FAX_PROVIDER_STATUS_ENUM = TOleEnum;
const
  fpsSUCCESS = $00000000;
  fpsSERVER_ERROR = $00000001;
  fpsBAD_GUID = $00000002;
  fpsBAD_VERSION = $00000003;
  fpsCANT_LOAD = $00000004;
  fpsCANT_LINK = $00000005;
  fpsCANT_INIT = $00000006;

// Constants for enum FAX_DEVICE_RECEIVE_MODE_ENUM
type
  FAX_DEVICE_RECEIVE_MODE_ENUM = TOleEnum;
const
  fdrmNO_ANSWER = $00000000;
  fdrmAUTO_ANSWER = $00000001;
  fdrmMANUAL_ANSWER = $00000002;

// Constants for enum FAX_RECEIPT_TYPE_ENUM
type
  FAX_RECEIPT_TYPE_ENUM = TOleEnum;
const
  frtNONE = $00000000;
  frtMAIL = $00000001;
  frtMSGBOX = $00000004;

// Constants for enum FAX_PRIORITY_TYPE_ENUM
type
  FAX_PRIORITY_TYPE_ENUM = TOleEnum;
const
  fptLOW = $00000000;
  fptNORMAL = $00000001;
  fptHIGH = $00000002;

// Constants for enum FAX_JOB_STATUS_ENUM
type
  FAX_JOB_STATUS_ENUM = TOleEnum;
const
  fjsPENDING = $00000001;
  fjsINPROGRESS = $00000002;
  fjsFAILED = $00000008;
  fjsPAUSED = $00000010;
  fjsNOLINE = $00000020;
  fjsRETRYING = $00000040;
  fjsRETRIES_EXCEEDED = $00000080;
  fjsCOMPLETED = $00000100;
  fjsCANCELED = $00000200;
  fjsCANCELING = $00000400;
  fjsROUTING = $00000800;

// Constants for enum FAX_JOB_EXTENDED_STATUS_ENUM
type
  FAX_JOB_EXTENDED_STATUS_ENUM = TOleEnum;
const
  fjesNONE = $00000000;
  fjesDISCONNECTED = $00000001;
  fjesINITIALIZING = $00000002;
  fjesDIALING = $00000003;
  fjesTRANSMITTING = $00000004;
  fjesANSWERED = $00000005;
  fjesRECEIVING = $00000006;
  fjesLINE_UNAVAILABLE = $00000007;
  fjesBUSY = $00000008;
  fjesNO_ANSWER = $00000009;
  fjesBAD_ADDRESS = $0000000A;
  fjesNO_DIAL_TONE = $0000000B;
  fjesFATAL_ERROR = $0000000C;
  fjesCALL_DELAYED = $0000000D;
  fjesCALL_BLACKLISTED = $0000000E;
  fjesNOT_FAX_CALL = $0000000F;
  fjesPARTIALLY_RECEIVED = $00000010;
  fjesHANDLED = $00000011;
  fjesCALL_COMPLETED = $00000012;
  fjesCALL_ABORTED = $00000013;
  fjesPROPRIETARY = $01000000;

// Constants for enum FAX_JOB_OPERATIONS_ENUM
type
  FAX_JOB_OPERATIONS_ENUM = TOleEnum;
const
  fjoVIEW = $00000001;
  fjoPAUSE = $00000002;
  fjoRESUME = $00000004;
  fjoRESTART = $00000008;
  fjoDELETE = $00000010;
  fjoRECIPIENT_INFO = $00000020;
  fjoSENDER_INFO = $00000040;

// Constants for enum FAX_JOB_TYPE_ENUM
type
  FAX_JOB_TYPE_ENUM = TOleEnum;
const
  fjtSEND = $00000000;
  fjtRECEIVE = $00000001;
  fjtROUTING = $00000002;

// Constants for enum FAX_LOG_LEVEL_ENUM
type
  FAX_LOG_LEVEL_ENUM = TOleEnum;
const
  fllNONE = $00000000;
  fllMIN = $00000001;
  fllMED = $00000002;
  fllMAX = $00000003;

// Constants for enum FAX_GROUP_STATUS_ENUM
type
  FAX_GROUP_STATUS_ENUM = TOleEnum;
const
  fgsALL_DEV_VALID = $00000000;
  fgsEMPTY = $00000001;
  fgsALL_DEV_NOT_VALID = $00000002;
  fgsSOME_DEV_NOT_VALID = $00000003;

// Constants for enum FAX_RULE_STATUS_ENUM
type
  FAX_RULE_STATUS_ENUM = TOleEnum;
const
  frsVALID = $00000000;
  frsEMPTY_GROUP = $00000001;
  frsALL_GROUP_DEV_NOT_VALID = $00000002;
  frsSOME_GROUP_DEV_NOT_VALID = $00000003;
  frsBAD_DEVICE = $00000004;

// Constants for enum FAX_SMTP_AUTHENTICATION_TYPE_ENUM
type
  FAX_SMTP_AUTHENTICATION_TYPE_ENUM = TOleEnum;
const
  fsatANONYMOUS = $00000000;
  fsatBASIC = $00000001;
  fsatNTLM = $00000002;

// Constants for enum FAX_ACCESS_RIGHTS_ENUM
type
  FAX_ACCESS_RIGHTS_ENUM = TOleEnum;
const
  farSUBMIT_LOW = $00000001;
  farSUBMIT_NORMAL = $00000002;
  farSUBMIT_HIGH = $00000004;
  farQUERY_JOBS = $00000008;
  farMANAGE_JOBS = $00000010;
  farQUERY_CONFIG = $00000020;
  farMANAGE_CONFIG = $00000040;
  farQUERY_IN_ARCHIVE = $00000080;
  farMANAGE_IN_ARCHIVE = $00000100;
  farQUERY_OUT_ARCHIVE = $00000200;
  farMANAGE_OUT_ARCHIVE = $00000400;

// Constants for enum FAX_SERVER_EVENTS_TYPE_ENUM
type
  FAX_SERVER_EVENTS_TYPE_ENUM = TOleEnum;
const
  fsetNONE = $00000000;
  fsetIN_QUEUE = $00000001;
  fsetOUT_QUEUE = $00000002;
  fsetCONFIG = $00000004;
  fsetACTIVITY = $00000008;
  fsetQUEUE_STATE = $00000010;
  fsetIN_ARCHIVE = $00000020;
  fsetOUT_ARCHIVE = $00000040;
  fsetFXSSVC_ENDED = $00000080;
  fsetDEVICE_STATUS = $00000100;
  fsetINCOMING_CALL = $00000200;

// Constants for enum FAX_SERVER_APIVERSION_ENUM
type
  FAX_SERVER_APIVERSION_ENUM = TOleEnum;
const
  fsAPI_VERSION_0 = $00000000;
  fsAPI_VERSION_1 = $00010000;

// Constants for enum FAX_COVERPAGE_TYPE_ENUM
type
  FAX_COVERPAGE_TYPE_ENUM = TOleEnum;
const
  fcptNONE = $00000000;
  fcptLOCAL = $00000001;
  fcptSERVER = $00000002;

// Constants for enum FAX_SCHEDULE_TYPE_ENUM
type
  FAX_SCHEDULE_TYPE_ENUM = TOleEnum;
const
  fstNOW = $00000000;
  fstSPECIFIC_TIME = $00000001;
  fstDISCOUNT_PERIOD = $00000002;

// Constants for enum FAX_ROUTING_RULE_CODE_ENUM
type
  FAX_ROUTING_RULE_CODE_ENUM = TOleEnum;
const
  frrcANY_CODE = $00000000;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IFaxServerNotify = dispinterface;
  IFaxServer = interface;
  IFaxServerDisp = dispinterface;
  IFaxDeviceProviders = interface;
  IFaxDeviceProvidersDisp = dispinterface;
  IFaxDeviceProvider = interface;
  IFaxDeviceProviderDisp = dispinterface;
  IFaxDevices = interface;
  IFaxDevicesDisp = dispinterface;
  IFaxDevice = interface;
  IFaxDeviceDisp = dispinterface;
  IFaxInboundRouting = interface;
  IFaxInboundRoutingDisp = dispinterface;
  IFaxInboundRoutingExtensions = interface;
  IFaxInboundRoutingExtensionsDisp = dispinterface;
  IFaxInboundRoutingExtension = interface;
  IFaxInboundRoutingExtensionDisp = dispinterface;
  IFaxInboundRoutingMethods = interface;
  IFaxInboundRoutingMethodsDisp = dispinterface;
  IFaxInboundRoutingMethod = interface;
  IFaxInboundRoutingMethodDisp = dispinterface;
  IFaxFolders = interface;
  IFaxFoldersDisp = dispinterface;
  IFaxOutgoingQueue = interface;
  IFaxOutgoingQueueDisp = dispinterface;
  IFaxOutgoingJobs = interface;
  IFaxOutgoingJobsDisp = dispinterface;
  IFaxOutgoingJob = interface;
  IFaxOutgoingJobDisp = dispinterface;
  IFaxSender = interface;
  IFaxSenderDisp = dispinterface;
  IFaxRecipient = interface;
  IFaxRecipientDisp = dispinterface;
  IFaxIncomingQueue = interface;
  IFaxIncomingQueueDisp = dispinterface;
  IFaxIncomingJobs = interface;
  IFaxIncomingJobsDisp = dispinterface;
  IFaxIncomingJob = interface;
  IFaxIncomingJobDisp = dispinterface;
  IFaxIncomingArchive = interface;
  IFaxIncomingArchiveDisp = dispinterface;
  IFaxIncomingMessageIterator = interface;
  IFaxIncomingMessageIteratorDisp = dispinterface;
  IFaxIncomingMessage = interface;
  IFaxIncomingMessageDisp = dispinterface;
  IFaxOutgoingArchive = interface;
  IFaxOutgoingArchiveDisp = dispinterface;
  IFaxOutgoingMessageIterator = interface;
  IFaxOutgoingMessageIteratorDisp = dispinterface;
  IFaxOutgoingMessage = interface;
  IFaxOutgoingMessageDisp = dispinterface;
  IFaxLoggingOptions = interface;
  IFaxLoggingOptionsDisp = dispinterface;
  IFaxEventLogging = interface;
  IFaxEventLoggingDisp = dispinterface;
  IFaxActivityLogging = interface;
  IFaxActivityLoggingDisp = dispinterface;
  IFaxActivity = interface;
  IFaxActivityDisp = dispinterface;
  IFaxOutboundRouting = interface;
  IFaxOutboundRoutingDisp = dispinterface;
  IFaxOutboundRoutingGroups = interface;
  IFaxOutboundRoutingGroupsDisp = dispinterface;
  IFaxOutboundRoutingGroup = interface;
  IFaxOutboundRoutingGroupDisp = dispinterface;
  IFaxDeviceIds = interface;
  IFaxDeviceIdsDisp = dispinterface;
  IFaxOutboundRoutingRules = interface;
  IFaxOutboundRoutingRulesDisp = dispinterface;
  IFaxOutboundRoutingRule = interface;
  IFaxOutboundRoutingRuleDisp = dispinterface;
  IFaxReceiptOptions = interface;
  IFaxReceiptOptionsDisp = dispinterface;
  IFaxSecurity = interface;
  IFaxSecurityDisp = dispinterface;
  IFaxJobStatus = interface;
  IFaxJobStatusDisp = dispinterface;
  IFaxDocument = interface;
  IFaxDocumentDisp = dispinterface;
  IFaxRecipients = interface;
  IFaxRecipientsDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  FaxServer = IFaxServer;
  FaxDeviceProviders = IFaxDeviceProviders;
  FaxDevices = IFaxDevices;
  FaxInboundRouting = IFaxInboundRouting;
  FaxFolders = IFaxFolders;
  FaxLoggingOptions = IFaxLoggingOptions;
  FaxActivity = IFaxActivity;
  FaxOutboundRouting = IFaxOutboundRouting;
  FaxReceiptOptions = IFaxReceiptOptions;
  FaxSecurity = IFaxSecurity;
  FaxDocument = IFaxDocument;
  FaxSender = IFaxSender;
  FaxRecipients = IFaxRecipients;
  FaxIncomingArchive = IFaxIncomingArchive;
  FaxIncomingQueue = IFaxIncomingQueue;
  FaxOutgoingArchive = IFaxOutgoingArchive;
  FaxOutgoingQueue = IFaxOutgoingQueue;
  FaxIncomingMessageIterator = IFaxIncomingMessageIterator;
  FaxIncomingMessage = IFaxIncomingMessage;
  FaxOutgoingJobs = IFaxOutgoingJobs;
  FaxOutgoingJob = IFaxOutgoingJob;
  FaxOutgoingMessageIterator = IFaxOutgoingMessageIterator;
  FaxOutgoingMessage = IFaxOutgoingMessage;
  FaxIncomingJobs = IFaxIncomingJobs;
  FaxIncomingJob = IFaxIncomingJob;
  FaxDeviceProvider = IFaxDeviceProvider;
  FaxDevice = IFaxDevice;
  FaxActivityLogging = IFaxActivityLogging;
  FaxEventLogging = IFaxEventLogging;
  FaxOutboundRoutingGroups = IFaxOutboundRoutingGroups;
  FaxOutboundRoutingGroup = IFaxOutboundRoutingGroup;
  FaxDeviceIds = IFaxDeviceIds;
  FaxOutboundRoutingRules = IFaxOutboundRoutingRules;
  FaxOutboundRoutingRule = IFaxOutboundRoutingRule;
  FaxInboundRoutingExtensions = IFaxInboundRoutingExtensions;
  FaxInboundRoutingExtension = IFaxInboundRoutingExtension;
  FaxInboundRoutingMethods = IFaxInboundRoutingMethods;
  FaxInboundRoutingMethod = IFaxInboundRoutingMethod;
  FaxJobStatus = IFaxJobStatus;
  FaxRecipient = IFaxRecipient;


// *********************************************************************//
// DispIntf:  IFaxServerNotify
// Flags:     (4096) Dispatchable
// GUID:      {2E037B27-CF8A-4ABD-B1E0-5704943BEA6F}
// *********************************************************************//
  IFaxServerNotify = dispinterface
    ['{2E037B27-CF8A-4ABD-B1E0-5704943BEA6F}']
    procedure OnIncomingJobAdded(const pFaxServer: IFaxServer; const bstrJobId: WideString); dispid 1;
    procedure OnIncomingJobRemoved(const pFaxServer: IFaxServer; const bstrJobId: WideString); dispid 2;
    procedure OnIncomingJobChanged(const pFaxServer: IFaxServer; const bstrJobId: WideString; 
                                   const pJobStatus: IFaxJobStatus); dispid 3;
    procedure OnOutgoingJobAdded(const pFaxServer: IFaxServer; const bstrJobId: WideString); dispid 4;
    procedure OnOutgoingJobRemoved(const pFaxServer: IFaxServer; const bstrJobId: WideString); dispid 5;
    procedure OnOutgoingJobChanged(const pFaxServer: IFaxServer; const bstrJobId: WideString; 
                                   const pJobStatus: IFaxJobStatus); dispid 6;
    procedure OnIncomingMessageAdded(const pFaxServer: IFaxServer; const bstrMessageId: WideString); dispid 7;
    procedure OnIncomingMessageRemoved(const pFaxServer: IFaxServer; const bstrMessageId: WideString); dispid 8;
    procedure OnOutgoingMessageAdded(const pFaxServer: IFaxServer; const bstrMessageId: WideString); dispid 9;
    procedure OnOutgoingMessageRemoved(const pFaxServer: IFaxServer; const bstrMessageId: WideString); dispid 10;
    procedure OnReceiptOptionsChange(const pFaxServer: IFaxServer); dispid 11;
    procedure OnActivityLoggingConfigChange(const pFaxServer: IFaxServer); dispid 12;
    procedure OnSecurityConfigChange(const pFaxServer: IFaxServer); dispid 13;
    procedure OnEventLoggingConfigChange(const pFaxServer: IFaxServer); dispid 14;
    procedure OnOutgoingQueueConfigChange(const pFaxServer: IFaxServer); dispid 15;
    procedure OnOutgoingArchiveConfigChange(const pFaxServer: IFaxServer); dispid 16;
    procedure OnIncomingArchiveConfigChange(const pFaxServer: IFaxServer); dispid 17;
    procedure OnDevicesConfigChange(const pFaxServer: IFaxServer); dispid 18;
    procedure OnOutboundRoutingGroupsConfigChange(const pFaxServer: IFaxServer); dispid 19;
    procedure OnOutboundRoutingRulesConfigChange(const pFaxServer: IFaxServer); dispid 20;
    procedure OnServerActivityChange(const pFaxServer: IFaxServer; lIncomingMessages: Integer; 
                                     lRoutingMessages: Integer; lOutgoingMessages: Integer; 
                                     lQueuedMessages: Integer); dispid 21;
    procedure OnQueuesStatusChange(const pFaxServer: IFaxServer; bOutgoingQueueBlocked: WordBool; 
                                   bOutgoingQueuePaused: WordBool; bIncomingQueueBlocked: WordBool); dispid 22;
    procedure OnNewCall(const pFaxServer: IFaxServer; lCallId: Integer; lDeviceId: Integer; 
                        const bstrCallerId: WideString); dispid 23;
    procedure OnServerShutDown(const pFaxServer: IFaxServer); dispid 24;
    procedure OnDeviceStatusChange(const pFaxServer: IFaxServer; lDeviceId: Integer; 
                                   bPoweredOff: WordBool; bSending: WordBool; bReceiving: WordBool; 
                                   bRinging: WordBool); dispid 25;
  end;

// *********************************************************************//
// Interface: IFaxServer
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {475B6469-90A5-4878-A577-17A86E8E3462}
// *********************************************************************//
  IFaxServer = interface(IDispatch)
    ['{475B6469-90A5-4878-A577-17A86E8E3462}']
    procedure Connect(const bstrServerName: WideString); safecall;
    function Get_ServerName: WideString; safecall;
    function GetDeviceProviders: IFaxDeviceProviders; safecall;
    function GetDevices: IFaxDevices; safecall;
    function Get_InboundRouting: IFaxInboundRouting; safecall;
    function Get_Folders: IFaxFolders; safecall;
    function Get_LoggingOptions: IFaxLoggingOptions; safecall;
    function Get_MajorVersion: Integer; safecall;
    function Get_MinorVersion: Integer; safecall;
    function Get_MajorBuild: Integer; safecall;
    function Get_MinorBuild: Integer; safecall;
    function Get_Debug: WordBool; safecall;
    function Get_Activity: IFaxActivity; safecall;
    function Get_OutboundRouting: IFaxOutboundRouting; safecall;
    function Get_ReceiptOptions: IFaxReceiptOptions; safecall;
    function Get_Security: IFaxSecurity; safecall;
    procedure Disconnect; safecall;
    function GetExtensionProperty(const bstrGUID: WideString): OleVariant; safecall;
    procedure SetExtensionProperty(const bstrGUID: WideString; vProperty: OleVariant); safecall;
    procedure ListenToServerEvents(EventTypes: FAX_SERVER_EVENTS_TYPE_ENUM); safecall;
    procedure RegisterDeviceProvider(const bstrGUID: WideString; 
                                     const bstrFriendlyName: WideString; 
                                     const bstrImageName: WideString; const TspName: WideString; 
                                     lFSPIVersion: Integer); safecall;
    procedure UnregisterDeviceProvider(const bstrUniqueName: WideString); safecall;
    procedure RegisterInboundRoutingExtension(const bstrExtensionName: WideString; 
                                              const bstrFriendlyName: WideString; 
                                              const bstrImageName: WideString; vMethods: OleVariant); safecall;
    procedure UnregisterInboundRoutingExtension(const bstrExtensionUniqueName: WideString); safecall;
    function Get_RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM; safecall;
    function Get_APIVersion: FAX_SERVER_APIVERSION_ENUM; safecall;
    property ServerName: WideString read Get_ServerName;
    property InboundRouting: IFaxInboundRouting read Get_InboundRouting;
    property Folders: IFaxFolders read Get_Folders;
    property LoggingOptions: IFaxLoggingOptions read Get_LoggingOptions;
    property MajorVersion: Integer read Get_MajorVersion;
    property MinorVersion: Integer read Get_MinorVersion;
    property MajorBuild: Integer read Get_MajorBuild;
    property MinorBuild: Integer read Get_MinorBuild;
    property Debug: WordBool read Get_Debug;
    property Activity: IFaxActivity read Get_Activity;
    property OutboundRouting: IFaxOutboundRouting read Get_OutboundRouting;
    property ReceiptOptions: IFaxReceiptOptions read Get_ReceiptOptions;
    property Security: IFaxSecurity read Get_Security;
    property RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM read Get_RegisteredEvents;
    property APIVersion: FAX_SERVER_APIVERSION_ENUM read Get_APIVersion;
  end;

// *********************************************************************//
// DispIntf:  IFaxServerDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {475B6469-90A5-4878-A577-17A86E8E3462}
// *********************************************************************//
  IFaxServerDisp = dispinterface
    ['{475B6469-90A5-4878-A577-17A86E8E3462}']
    procedure Connect(const bstrServerName: WideString); dispid 1;
    property ServerName: WideString readonly dispid 2;
    function GetDeviceProviders: IFaxDeviceProviders; dispid 3;
    function GetDevices: IFaxDevices; dispid 4;
    property InboundRouting: IFaxInboundRouting readonly dispid 5;
    property Folders: IFaxFolders readonly dispid 6;
    property LoggingOptions: IFaxLoggingOptions readonly dispid 7;
    property MajorVersion: Integer readonly dispid 8;
    property MinorVersion: Integer readonly dispid 9;
    property MajorBuild: Integer readonly dispid 10;
    property MinorBuild: Integer readonly dispid 11;
    property Debug: WordBool readonly dispid 12;
    property Activity: IFaxActivity readonly dispid 13;
    property OutboundRouting: IFaxOutboundRouting readonly dispid 14;
    property ReceiptOptions: IFaxReceiptOptions readonly dispid 15;
    property Security: IFaxSecurity readonly dispid 16;
    procedure Disconnect; dispid 17;
    function GetExtensionProperty(const bstrGUID: WideString): OleVariant; dispid 18;
    procedure SetExtensionProperty(const bstrGUID: WideString; vProperty: OleVariant); dispid 19;
    procedure ListenToServerEvents(EventTypes: FAX_SERVER_EVENTS_TYPE_ENUM); dispid 20;
    procedure RegisterDeviceProvider(const bstrGUID: WideString; 
                                     const bstrFriendlyName: WideString; 
                                     const bstrImageName: WideString; const TspName: WideString; 
                                     lFSPIVersion: Integer); dispid 21;
    procedure UnregisterDeviceProvider(const bstrUniqueName: WideString); dispid 22;
    procedure RegisterInboundRoutingExtension(const bstrExtensionName: WideString; 
                                              const bstrFriendlyName: WideString; 
                                              const bstrImageName: WideString; vMethods: OleVariant); dispid 23;
    procedure UnregisterInboundRoutingExtension(const bstrExtensionUniqueName: WideString); dispid 24;
    property RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM readonly dispid 25;
    property APIVersion: FAX_SERVER_APIVERSION_ENUM readonly dispid 26;
  end;

// *********************************************************************//
// Interface: IFaxDeviceProviders
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9FB76F62-4C7E-43A5-B6FD-502893F7E13E}
// *********************************************************************//
  IFaxDeviceProviders = interface(IDispatch)
    ['{9FB76F62-4C7E-43A5-B6FD-502893F7E13E}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(vIndex: OleVariant): IFaxDeviceProvider; safecall;
    function Get_Count: Integer; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[vIndex: OleVariant]: IFaxDeviceProvider read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxDeviceProvidersDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9FB76F62-4C7E-43A5-B6FD-502893F7E13E}
// *********************************************************************//
  IFaxDeviceProvidersDisp = dispinterface
    ['{9FB76F62-4C7E-43A5-B6FD-502893F7E13E}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[vIndex: OleVariant]: IFaxDeviceProvider readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IFaxDeviceProvider
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {290EAC63-83EC-449C-8417-F148DF8C682A}
// *********************************************************************//
  IFaxDeviceProvider = interface(IDispatch)
    ['{290EAC63-83EC-449C-8417-F148DF8C682A}']
    function Get_FriendlyName: WideString; safecall;
    function Get_ImageName: WideString; safecall;
    function Get_UniqueName: WideString; safecall;
    function Get_TapiProviderName: WideString; safecall;
    function Get_MajorVersion: Integer; safecall;
    function Get_MinorVersion: Integer; safecall;
    function Get_MajorBuild: Integer; safecall;
    function Get_MinorBuild: Integer; safecall;
    function Get_Debug: WordBool; safecall;
    function Get_Status: FAX_PROVIDER_STATUS_ENUM; safecall;
    function Get_InitErrorCode: Integer; safecall;
    function Get_DeviceIds: OleVariant; safecall;
    property FriendlyName: WideString read Get_FriendlyName;
    property ImageName: WideString read Get_ImageName;
    property UniqueName: WideString read Get_UniqueName;
    property TapiProviderName: WideString read Get_TapiProviderName;
    property MajorVersion: Integer read Get_MajorVersion;
    property MinorVersion: Integer read Get_MinorVersion;
    property MajorBuild: Integer read Get_MajorBuild;
    property MinorBuild: Integer read Get_MinorBuild;
    property Debug: WordBool read Get_Debug;
    property Status: FAX_PROVIDER_STATUS_ENUM read Get_Status;
    property InitErrorCode: Integer read Get_InitErrorCode;
    property DeviceIds: OleVariant read Get_DeviceIds;
  end;

// *********************************************************************//
// DispIntf:  IFaxDeviceProviderDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {290EAC63-83EC-449C-8417-F148DF8C682A}
// *********************************************************************//
  IFaxDeviceProviderDisp = dispinterface
    ['{290EAC63-83EC-449C-8417-F148DF8C682A}']
    property FriendlyName: WideString readonly dispid 1;
    property ImageName: WideString readonly dispid 2;
    property UniqueName: WideString readonly dispid 3;
    property TapiProviderName: WideString readonly dispid 4;
    property MajorVersion: Integer readonly dispid 5;
    property MinorVersion: Integer readonly dispid 6;
    property MajorBuild: Integer readonly dispid 7;
    property MinorBuild: Integer readonly dispid 8;
    property Debug: WordBool readonly dispid 9;
    property Status: FAX_PROVIDER_STATUS_ENUM readonly dispid 10;
    property InitErrorCode: Integer readonly dispid 11;
    property DeviceIds: OleVariant readonly dispid 12;
  end;

// *********************************************************************//
// Interface: IFaxDevices
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9E46783E-F34F-482E-A360-0416BECBBD96}
// *********************************************************************//
  IFaxDevices = interface(IDispatch)
    ['{9E46783E-F34F-482E-A360-0416BECBBD96}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(vIndex: OleVariant): IFaxDevice; safecall;
    function Get_Count: Integer; safecall;
    function Get_ItemById(lId: Integer): IFaxDevice; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[vIndex: OleVariant]: IFaxDevice read Get_Item; default;
    property Count: Integer read Get_Count;
    property ItemById[lId: Integer]: IFaxDevice read Get_ItemById;
  end;

// *********************************************************************//
// DispIntf:  IFaxDevicesDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9E46783E-F34F-482E-A360-0416BECBBD96}
// *********************************************************************//
  IFaxDevicesDisp = dispinterface
    ['{9E46783E-F34F-482E-A360-0416BECBBD96}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[vIndex: OleVariant]: IFaxDevice readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    property ItemById[lId: Integer]: IFaxDevice readonly dispid 2;
  end;

// *********************************************************************//
// Interface: IFaxDevice
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {49306C59-B52E-4867-9DF4-CA5841C956D0}
// *********************************************************************//
  IFaxDevice = interface(IDispatch)
    ['{49306C59-B52E-4867-9DF4-CA5841C956D0}']
    function Get_Id: Integer; safecall;
    function Get_DeviceName: WideString; safecall;
    function Get_ProviderUniqueName: WideString; safecall;
    function Get_PoweredOff: WordBool; safecall;
    function Get_ReceivingNow: WordBool; safecall;
    function Get_SendingNow: WordBool; safecall;
    function Get_UsedRoutingMethods: OleVariant; safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const pbstrDescription: WideString); safecall;
    function Get_SendEnabled: WordBool; safecall;
    procedure Set_SendEnabled(pbSendEnabled: WordBool); safecall;
    function Get_ReceiveMode: FAX_DEVICE_RECEIVE_MODE_ENUM; safecall;
    procedure Set_ReceiveMode(pReceiveMode: FAX_DEVICE_RECEIVE_MODE_ENUM); safecall;
    function Get_RingsBeforeAnswer: Integer; safecall;
    procedure Set_RingsBeforeAnswer(plRingsBeforeAnswer: Integer); safecall;
    function Get_CSID: WideString; safecall;
    procedure Set_CSID(const pbstrCSID: WideString); safecall;
    function Get_TSID: WideString; safecall;
    procedure Set_TSID(const pbstrTSID: WideString); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    function GetExtensionProperty(const bstrGUID: WideString): OleVariant; safecall;
    procedure SetExtensionProperty(const bstrGUID: WideString; vProperty: OleVariant); safecall;
    procedure UseRoutingMethod(const bstrMethodGUID: WideString; bUse: WordBool); safecall;
    function Get_RingingNow: WordBool; safecall;
    procedure AnswerCall; safecall;
    property Id: Integer read Get_Id;
    property DeviceName: WideString read Get_DeviceName;
    property ProviderUniqueName: WideString read Get_ProviderUniqueName;
    property PoweredOff: WordBool read Get_PoweredOff;
    property ReceivingNow: WordBool read Get_ReceivingNow;
    property SendingNow: WordBool read Get_SendingNow;
    property UsedRoutingMethods: OleVariant read Get_UsedRoutingMethods;
    property Description: WideString read Get_Description write Set_Description;
    property SendEnabled: WordBool read Get_SendEnabled write Set_SendEnabled;
    property ReceiveMode: FAX_DEVICE_RECEIVE_MODE_ENUM read Get_ReceiveMode write Set_ReceiveMode;
    property RingsBeforeAnswer: Integer read Get_RingsBeforeAnswer write Set_RingsBeforeAnswer;
    property CSID: WideString read Get_CSID write Set_CSID;
    property TSID: WideString read Get_TSID write Set_TSID;
    property RingingNow: WordBool read Get_RingingNow;
  end;

// *********************************************************************//
// DispIntf:  IFaxDeviceDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {49306C59-B52E-4867-9DF4-CA5841C956D0}
// *********************************************************************//
  IFaxDeviceDisp = dispinterface
    ['{49306C59-B52E-4867-9DF4-CA5841C956D0}']
    property Id: Integer readonly dispid 1;
    property DeviceName: WideString readonly dispid 2;
    property ProviderUniqueName: WideString readonly dispid 3;
    property PoweredOff: WordBool readonly dispid 4;
    property ReceivingNow: WordBool readonly dispid 5;
    property SendingNow: WordBool readonly dispid 6;
    property UsedRoutingMethods: OleVariant readonly dispid 7;
    property Description: WideString dispid 8;
    property SendEnabled: WordBool dispid 9;
    property ReceiveMode: FAX_DEVICE_RECEIVE_MODE_ENUM dispid 10;
    property RingsBeforeAnswer: Integer dispid 11;
    property CSID: WideString dispid 12;
    property TSID: WideString dispid 13;
    procedure Refresh; dispid 14;
    procedure Save; dispid 15;
    function GetExtensionProperty(const bstrGUID: WideString): OleVariant; dispid 16;
    procedure SetExtensionProperty(const bstrGUID: WideString; vProperty: OleVariant); dispid 17;
    procedure UseRoutingMethod(const bstrMethodGUID: WideString; bUse: WordBool); dispid 18;
    property RingingNow: WordBool readonly dispid 19;
    procedure AnswerCall; dispid 20;
  end;

// *********************************************************************//
// Interface: IFaxInboundRouting
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8148C20F-9D52-45B1-BF96-38FC12713527}
// *********************************************************************//
  IFaxInboundRouting = interface(IDispatch)
    ['{8148C20F-9D52-45B1-BF96-38FC12713527}']
    function GetExtensions: IFaxInboundRoutingExtensions; safecall;
    function GetMethods: IFaxInboundRoutingMethods; safecall;
  end;

// *********************************************************************//
// DispIntf:  IFaxInboundRoutingDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8148C20F-9D52-45B1-BF96-38FC12713527}
// *********************************************************************//
  IFaxInboundRoutingDisp = dispinterface
    ['{8148C20F-9D52-45B1-BF96-38FC12713527}']
    function GetExtensions: IFaxInboundRoutingExtensions; dispid 1;
    function GetMethods: IFaxInboundRoutingMethods; dispid 2;
  end;

// *********************************************************************//
// Interface: IFaxInboundRoutingExtensions
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2F6C9673-7B26-42DE-8EB0-915DCD2A4F4C}
// *********************************************************************//
  IFaxInboundRoutingExtensions = interface(IDispatch)
    ['{2F6C9673-7B26-42DE-8EB0-915DCD2A4F4C}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(vIndex: OleVariant): IFaxInboundRoutingExtension; safecall;
    function Get_Count: Integer; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[vIndex: OleVariant]: IFaxInboundRoutingExtension read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxInboundRoutingExtensionsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2F6C9673-7B26-42DE-8EB0-915DCD2A4F4C}
// *********************************************************************//
  IFaxInboundRoutingExtensionsDisp = dispinterface
    ['{2F6C9673-7B26-42DE-8EB0-915DCD2A4F4C}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[vIndex: OleVariant]: IFaxInboundRoutingExtension readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IFaxInboundRoutingExtension
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {885B5E08-C26C-4EF9-AF83-51580A750BE1}
// *********************************************************************//
  IFaxInboundRoutingExtension = interface(IDispatch)
    ['{885B5E08-C26C-4EF9-AF83-51580A750BE1}']
    function Get_FriendlyName: WideString; safecall;
    function Get_ImageName: WideString; safecall;
    function Get_UniqueName: WideString; safecall;
    function Get_MajorVersion: Integer; safecall;
    function Get_MinorVersion: Integer; safecall;
    function Get_MajorBuild: Integer; safecall;
    function Get_MinorBuild: Integer; safecall;
    function Get_Debug: WordBool; safecall;
    function Get_Status: FAX_PROVIDER_STATUS_ENUM; safecall;
    function Get_InitErrorCode: Integer; safecall;
    function Get_Methods: OleVariant; safecall;
    property FriendlyName: WideString read Get_FriendlyName;
    property ImageName: WideString read Get_ImageName;
    property UniqueName: WideString read Get_UniqueName;
    property MajorVersion: Integer read Get_MajorVersion;
    property MinorVersion: Integer read Get_MinorVersion;
    property MajorBuild: Integer read Get_MajorBuild;
    property MinorBuild: Integer read Get_MinorBuild;
    property Debug: WordBool read Get_Debug;
    property Status: FAX_PROVIDER_STATUS_ENUM read Get_Status;
    property InitErrorCode: Integer read Get_InitErrorCode;
    property Methods: OleVariant read Get_Methods;
  end;

// *********************************************************************//
// DispIntf:  IFaxInboundRoutingExtensionDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {885B5E08-C26C-4EF9-AF83-51580A750BE1}
// *********************************************************************//
  IFaxInboundRoutingExtensionDisp = dispinterface
    ['{885B5E08-C26C-4EF9-AF83-51580A750BE1}']
    property FriendlyName: WideString readonly dispid 1;
    property ImageName: WideString readonly dispid 2;
    property UniqueName: WideString readonly dispid 3;
    property MajorVersion: Integer readonly dispid 4;
    property MinorVersion: Integer readonly dispid 5;
    property MajorBuild: Integer readonly dispid 6;
    property MinorBuild: Integer readonly dispid 7;
    property Debug: WordBool readonly dispid 8;
    property Status: FAX_PROVIDER_STATUS_ENUM readonly dispid 9;
    property InitErrorCode: Integer readonly dispid 10;
    property Methods: OleVariant readonly dispid 11;
  end;

// *********************************************************************//
// Interface: IFaxInboundRoutingMethods
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {783FCA10-8908-4473-9D69-F67FBEA0C6B9}
// *********************************************************************//
  IFaxInboundRoutingMethods = interface(IDispatch)
    ['{783FCA10-8908-4473-9D69-F67FBEA0C6B9}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(vIndex: OleVariant): IFaxInboundRoutingMethod; safecall;
    function Get_Count: Integer; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[vIndex: OleVariant]: IFaxInboundRoutingMethod read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxInboundRoutingMethodsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {783FCA10-8908-4473-9D69-F67FBEA0C6B9}
// *********************************************************************//
  IFaxInboundRoutingMethodsDisp = dispinterface
    ['{783FCA10-8908-4473-9D69-F67FBEA0C6B9}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[vIndex: OleVariant]: IFaxInboundRoutingMethod readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IFaxInboundRoutingMethod
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {45700061-AD9D-4776-A8C4-64065492CF4B}
// *********************************************************************//
  IFaxInboundRoutingMethod = interface(IDispatch)
    ['{45700061-AD9D-4776-A8C4-64065492CF4B}']
    function Get_Name: WideString; safecall;
    function Get_GUID: WideString; safecall;
    function Get_FunctionName: WideString; safecall;
    function Get_ExtensionFriendlyName: WideString; safecall;
    function Get_ExtensionImageName: WideString; safecall;
    function Get_Priority: Integer; safecall;
    procedure Set_Priority(plPriority: Integer); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    property Name: WideString read Get_Name;
    property GUID: WideString read Get_GUID;
    property FunctionName: WideString read Get_FunctionName;
    property ExtensionFriendlyName: WideString read Get_ExtensionFriendlyName;
    property ExtensionImageName: WideString read Get_ExtensionImageName;
    property Priority: Integer read Get_Priority write Set_Priority;
  end;

// *********************************************************************//
// DispIntf:  IFaxInboundRoutingMethodDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {45700061-AD9D-4776-A8C4-64065492CF4B}
// *********************************************************************//
  IFaxInboundRoutingMethodDisp = dispinterface
    ['{45700061-AD9D-4776-A8C4-64065492CF4B}']
    property Name: WideString readonly dispid 1;
    property GUID: WideString readonly dispid 2;
    property FunctionName: WideString readonly dispid 3;
    property ExtensionFriendlyName: WideString readonly dispid 4;
    property ExtensionImageName: WideString readonly dispid 5;
    property Priority: Integer dispid 6;
    procedure Refresh; dispid 7;
    procedure Save; dispid 8;
  end;

// *********************************************************************//
// Interface: IFaxFolders
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {DCE3B2A8-A7AB-42BC-9D0A-3149457261A0}
// *********************************************************************//
  IFaxFolders = interface(IDispatch)
    ['{DCE3B2A8-A7AB-42BC-9D0A-3149457261A0}']
    function Get_OutgoingQueue: IFaxOutgoingQueue; safecall;
    function Get_IncomingQueue: IFaxIncomingQueue; safecall;
    function Get_IncomingArchive: IFaxIncomingArchive; safecall;
    function Get_OutgoingArchive: IFaxOutgoingArchive; safecall;
    property OutgoingQueue: IFaxOutgoingQueue read Get_OutgoingQueue;
    property IncomingQueue: IFaxIncomingQueue read Get_IncomingQueue;
    property IncomingArchive: IFaxIncomingArchive read Get_IncomingArchive;
    property OutgoingArchive: IFaxOutgoingArchive read Get_OutgoingArchive;
  end;

// *********************************************************************//
// DispIntf:  IFaxFoldersDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {DCE3B2A8-A7AB-42BC-9D0A-3149457261A0}
// *********************************************************************//
  IFaxFoldersDisp = dispinterface
    ['{DCE3B2A8-A7AB-42BC-9D0A-3149457261A0}']
    property OutgoingQueue: IFaxOutgoingQueue readonly dispid 1;
    property IncomingQueue: IFaxIncomingQueue readonly dispid 2;
    property IncomingArchive: IFaxIncomingArchive readonly dispid 3;
    property OutgoingArchive: IFaxOutgoingArchive readonly dispid 4;
  end;

// *********************************************************************//
// Interface: IFaxOutgoingQueue
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {80B1DF24-D9AC-4333-B373-487CEDC80CE5}
// *********************************************************************//
  IFaxOutgoingQueue = interface(IDispatch)
    ['{80B1DF24-D9AC-4333-B373-487CEDC80CE5}']
    function Get_Blocked: WordBool; safecall;
    procedure Set_Blocked(pbBlocked: WordBool); safecall;
    function Get_Paused: WordBool; safecall;
    procedure Set_Paused(pbPaused: WordBool); safecall;
    function Get_AllowPersonalCoverPages: WordBool; safecall;
    procedure Set_AllowPersonalCoverPages(pbAllowPersonalCoverPages: WordBool); safecall;
    function Get_UseDeviceTSID: WordBool; safecall;
    procedure Set_UseDeviceTSID(pbUseDeviceTSID: WordBool); safecall;
    function Get_Retries: Integer; safecall;
    procedure Set_Retries(plRetries: Integer); safecall;
    function Get_RetryDelay: Integer; safecall;
    procedure Set_RetryDelay(plRetryDelay: Integer); safecall;
    function Get_DiscountRateStart: TDateTime; safecall;
    procedure Set_DiscountRateStart(pdateDiscountRateStart: TDateTime); safecall;
    function Get_DiscountRateEnd: TDateTime; safecall;
    procedure Set_DiscountRateEnd(pdateDiscountRateEnd: TDateTime); safecall;
    function Get_AgeLimit: Integer; safecall;
    procedure Set_AgeLimit(plAgeLimit: Integer); safecall;
    function Get_Branding: WordBool; safecall;
    procedure Set_Branding(pbBranding: WordBool); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    function GetJobs: IFaxOutgoingJobs; safecall;
    function GetJob(const bstrJobId: WideString): IFaxOutgoingJob; safecall;
    property Blocked: WordBool read Get_Blocked write Set_Blocked;
    property Paused: WordBool read Get_Paused write Set_Paused;
    property AllowPersonalCoverPages: WordBool read Get_AllowPersonalCoverPages write Set_AllowPersonalCoverPages;
    property UseDeviceTSID: WordBool read Get_UseDeviceTSID write Set_UseDeviceTSID;
    property Retries: Integer read Get_Retries write Set_Retries;
    property RetryDelay: Integer read Get_RetryDelay write Set_RetryDelay;
    property DiscountRateStart: TDateTime read Get_DiscountRateStart write Set_DiscountRateStart;
    property DiscountRateEnd: TDateTime read Get_DiscountRateEnd write Set_DiscountRateEnd;
    property AgeLimit: Integer read Get_AgeLimit write Set_AgeLimit;
    property Branding: WordBool read Get_Branding write Set_Branding;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutgoingQueueDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {80B1DF24-D9AC-4333-B373-487CEDC80CE5}
// *********************************************************************//
  IFaxOutgoingQueueDisp = dispinterface
    ['{80B1DF24-D9AC-4333-B373-487CEDC80CE5}']
    property Blocked: WordBool dispid 1;
    property Paused: WordBool dispid 2;
    property AllowPersonalCoverPages: WordBool dispid 3;
    property UseDeviceTSID: WordBool dispid 4;
    property Retries: Integer dispid 5;
    property RetryDelay: Integer dispid 6;
    property DiscountRateStart: TDateTime dispid 7;
    property DiscountRateEnd: TDateTime dispid 8;
    property AgeLimit: Integer dispid 9;
    property Branding: WordBool dispid 10;
    procedure Refresh; dispid 11;
    procedure Save; dispid 12;
    function GetJobs: IFaxOutgoingJobs; dispid 13;
    function GetJob(const bstrJobId: WideString): IFaxOutgoingJob; dispid 14;
  end;

// *********************************************************************//
// Interface: IFaxOutgoingJobs
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2C56D8E6-8C2F-4573-944C-E505F8F5AEED}
// *********************************************************************//
  IFaxOutgoingJobs = interface(IDispatch)
    ['{2C56D8E6-8C2F-4573-944C-E505F8F5AEED}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(vIndex: OleVariant): IFaxOutgoingJob; safecall;
    function Get_Count: Integer; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[vIndex: OleVariant]: IFaxOutgoingJob read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutgoingJobsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2C56D8E6-8C2F-4573-944C-E505F8F5AEED}
// *********************************************************************//
  IFaxOutgoingJobsDisp = dispinterface
    ['{2C56D8E6-8C2F-4573-944C-E505F8F5AEED}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[vIndex: OleVariant]: IFaxOutgoingJob readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IFaxOutgoingJob
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6356DAAD-6614-4583-BF7A-3AD67BBFC71C}
// *********************************************************************//
  IFaxOutgoingJob = interface(IDispatch)
    ['{6356DAAD-6614-4583-BF7A-3AD67BBFC71C}']
    function Get_Subject: WideString; safecall;
    function Get_DocumentName: WideString; safecall;
    function Get_Pages: Integer; safecall;
    function Get_Size: Integer; safecall;
    function Get_SubmissionId: WideString; safecall;
    function Get_Id: WideString; safecall;
    function Get_OriginalScheduledTime: TDateTime; safecall;
    function Get_SubmissionTime: TDateTime; safecall;
    function Get_ReceiptType: FAX_RECEIPT_TYPE_ENUM; safecall;
    function Get_Priority: FAX_PRIORITY_TYPE_ENUM; safecall;
    function Get_Sender: IFaxSender; safecall;
    function Get_Recipient: IFaxRecipient; safecall;
    function Get_CurrentPage: Integer; safecall;
    function Get_DeviceId: Integer; safecall;
    function Get_Status: FAX_JOB_STATUS_ENUM; safecall;
    function Get_ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM; safecall;
    function Get_ExtendedStatus: WideString; safecall;
    function Get_AvailableOperations: FAX_JOB_OPERATIONS_ENUM; safecall;
    function Get_Retries: Integer; safecall;
    function Get_ScheduledTime: TDateTime; safecall;
    function Get_TransmissionStart: TDateTime; safecall;
    function Get_TransmissionEnd: TDateTime; safecall;
    function Get_CSID: WideString; safecall;
    function Get_TSID: WideString; safecall;
    function Get_GroupBroadcastReceipts: WordBool; safecall;
    procedure Pause; safecall;
    procedure Resume; safecall;
    procedure Restart; safecall;
    procedure CopyTiff(const bstrTiffPath: WideString); safecall;
    procedure Refresh; safecall;
    procedure Cancel; safecall;
    property Subject: WideString read Get_Subject;
    property DocumentName: WideString read Get_DocumentName;
    property Pages: Integer read Get_Pages;
    property Size: Integer read Get_Size;
    property SubmissionId: WideString read Get_SubmissionId;
    property Id: WideString read Get_Id;
    property OriginalScheduledTime: TDateTime read Get_OriginalScheduledTime;
    property SubmissionTime: TDateTime read Get_SubmissionTime;
    property ReceiptType: FAX_RECEIPT_TYPE_ENUM read Get_ReceiptType;
    property Priority: FAX_PRIORITY_TYPE_ENUM read Get_Priority;
    property Sender: IFaxSender read Get_Sender;
    property Recipient: IFaxRecipient read Get_Recipient;
    property CurrentPage: Integer read Get_CurrentPage;
    property DeviceId: Integer read Get_DeviceId;
    property Status: FAX_JOB_STATUS_ENUM read Get_Status;
    property ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM read Get_ExtendedStatusCode;
    property ExtendedStatus: WideString read Get_ExtendedStatus;
    property AvailableOperations: FAX_JOB_OPERATIONS_ENUM read Get_AvailableOperations;
    property Retries: Integer read Get_Retries;
    property ScheduledTime: TDateTime read Get_ScheduledTime;
    property TransmissionStart: TDateTime read Get_TransmissionStart;
    property TransmissionEnd: TDateTime read Get_TransmissionEnd;
    property CSID: WideString read Get_CSID;
    property TSID: WideString read Get_TSID;
    property GroupBroadcastReceipts: WordBool read Get_GroupBroadcastReceipts;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutgoingJobDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6356DAAD-6614-4583-BF7A-3AD67BBFC71C}
// *********************************************************************//
  IFaxOutgoingJobDisp = dispinterface
    ['{6356DAAD-6614-4583-BF7A-3AD67BBFC71C}']
    property Subject: WideString readonly dispid 1;
    property DocumentName: WideString readonly dispid 2;
    property Pages: Integer readonly dispid 3;
    property Size: Integer readonly dispid 4;
    property SubmissionId: WideString readonly dispid 5;
    property Id: WideString readonly dispid 6;
    property OriginalScheduledTime: TDateTime readonly dispid 7;
    property SubmissionTime: TDateTime readonly dispid 8;
    property ReceiptType: FAX_RECEIPT_TYPE_ENUM readonly dispid 9;
    property Priority: FAX_PRIORITY_TYPE_ENUM readonly dispid 10;
    property Sender: IFaxSender readonly dispid 11;
    property Recipient: IFaxRecipient readonly dispid 12;
    property CurrentPage: Integer readonly dispid 13;
    property DeviceId: Integer readonly dispid 14;
    property Status: FAX_JOB_STATUS_ENUM readonly dispid 15;
    property ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM readonly dispid 16;
    property ExtendedStatus: WideString readonly dispid 17;
    property AvailableOperations: FAX_JOB_OPERATIONS_ENUM readonly dispid 18;
    property Retries: Integer readonly dispid 19;
    property ScheduledTime: TDateTime readonly dispid 20;
    property TransmissionStart: TDateTime readonly dispid 21;
    property TransmissionEnd: TDateTime readonly dispid 22;
    property CSID: WideString readonly dispid 23;
    property TSID: WideString readonly dispid 24;
    property GroupBroadcastReceipts: WordBool readonly dispid 25;
    procedure Pause; dispid 26;
    procedure Resume; dispid 27;
    procedure Restart; dispid 28;
    procedure CopyTiff(const bstrTiffPath: WideString); dispid 29;
    procedure Refresh; dispid 30;
    procedure Cancel; dispid 31;
  end;

// *********************************************************************//
// Interface: IFaxSender
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0D879D7D-F57A-4CC6-A6F9-3EE5D527B46A}
// *********************************************************************//
  IFaxSender = interface(IDispatch)
    ['{0D879D7D-F57A-4CC6-A6F9-3EE5D527B46A}']
    function Get_BillingCode: WideString; safecall;
    procedure Set_BillingCode(const pbstrBillingCode: WideString); safecall;
    function Get_City: WideString; safecall;
    procedure Set_City(const pbstrCity: WideString); safecall;
    function Get_Company: WideString; safecall;
    procedure Set_Company(const pbstrCompany: WideString); safecall;
    function Get_Country: WideString; safecall;
    procedure Set_Country(const pbstrCountry: WideString); safecall;
    function Get_Department: WideString; safecall;
    procedure Set_Department(const pbstrDepartment: WideString); safecall;
    function Get_Email: WideString; safecall;
    procedure Set_Email(const pbstrEmail: WideString); safecall;
    function Get_FaxNumber: WideString; safecall;
    procedure Set_FaxNumber(const pbstrFaxNumber: WideString); safecall;
    function Get_HomePhone: WideString; safecall;
    procedure Set_HomePhone(const pbstrHomePhone: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pbstrName: WideString); safecall;
    function Get_TSID: WideString; safecall;
    procedure Set_TSID(const pbstrTSID: WideString); safecall;
    function Get_OfficePhone: WideString; safecall;
    procedure Set_OfficePhone(const pbstrOfficePhone: WideString); safecall;
    function Get_OfficeLocation: WideString; safecall;
    procedure Set_OfficeLocation(const pbstrOfficeLocation: WideString); safecall;
    function Get_State: WideString; safecall;
    procedure Set_State(const pbstrState: WideString); safecall;
    function Get_StreetAddress: WideString; safecall;
    procedure Set_StreetAddress(const pbstrStreetAddress: WideString); safecall;
    function Get_Title: WideString; safecall;
    procedure Set_Title(const pbstrTitle: WideString); safecall;
    function Get_ZipCode: WideString; safecall;
    procedure Set_ZipCode(const pbstrZipCode: WideString); safecall;
    procedure LoadDefaultSender; safecall;
    procedure SaveDefaultSender; safecall;
    property BillingCode: WideString read Get_BillingCode write Set_BillingCode;
    property City: WideString read Get_City write Set_City;
    property Company: WideString read Get_Company write Set_Company;
    property Country: WideString read Get_Country write Set_Country;
    property Department: WideString read Get_Department write Set_Department;
    property Email: WideString read Get_Email write Set_Email;
    property FaxNumber: WideString read Get_FaxNumber write Set_FaxNumber;
    property HomePhone: WideString read Get_HomePhone write Set_HomePhone;
    property Name: WideString read Get_Name write Set_Name;
    property TSID: WideString read Get_TSID write Set_TSID;
    property OfficePhone: WideString read Get_OfficePhone write Set_OfficePhone;
    property OfficeLocation: WideString read Get_OfficeLocation write Set_OfficeLocation;
    property State: WideString read Get_State write Set_State;
    property StreetAddress: WideString read Get_StreetAddress write Set_StreetAddress;
    property Title: WideString read Get_Title write Set_Title;
    property ZipCode: WideString read Get_ZipCode write Set_ZipCode;
  end;

// *********************************************************************//
// DispIntf:  IFaxSenderDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {0D879D7D-F57A-4CC6-A6F9-3EE5D527B46A}
// *********************************************************************//
  IFaxSenderDisp = dispinterface
    ['{0D879D7D-F57A-4CC6-A6F9-3EE5D527B46A}']
    property BillingCode: WideString dispid 1;
    property City: WideString dispid 2;
    property Company: WideString dispid 3;
    property Country: WideString dispid 4;
    property Department: WideString dispid 5;
    property Email: WideString dispid 6;
    property FaxNumber: WideString dispid 7;
    property HomePhone: WideString dispid 8;
    property Name: WideString dispid 9;
    property TSID: WideString dispid 10;
    property OfficePhone: WideString dispid 11;
    property OfficeLocation: WideString dispid 12;
    property State: WideString dispid 13;
    property StreetAddress: WideString dispid 14;
    property Title: WideString dispid 15;
    property ZipCode: WideString dispid 16;
    procedure LoadDefaultSender; dispid 17;
    procedure SaveDefaultSender; dispid 18;
  end;

// *********************************************************************//
// Interface: IFaxRecipient
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9A3DA3A0-538D-42B6-9444-AAA57D0CE2BC}
// *********************************************************************//
  IFaxRecipient = interface(IDispatch)
    ['{9A3DA3A0-538D-42B6-9444-AAA57D0CE2BC}']
    function Get_FaxNumber: WideString; safecall;
    procedure Set_FaxNumber(const pbstrFaxNumber: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pbstrName: WideString); safecall;
    property FaxNumber: WideString read Get_FaxNumber write Set_FaxNumber;
    property Name: WideString read Get_Name write Set_Name;
  end;

// *********************************************************************//
// DispIntf:  IFaxRecipientDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9A3DA3A0-538D-42B6-9444-AAA57D0CE2BC}
// *********************************************************************//
  IFaxRecipientDisp = dispinterface
    ['{9A3DA3A0-538D-42B6-9444-AAA57D0CE2BC}']
    property FaxNumber: WideString dispid 1;
    property Name: WideString dispid 2;
  end;

// *********************************************************************//
// Interface: IFaxIncomingQueue
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {902E64EF-8FD8-4B75-9725-6014DF161545}
// *********************************************************************//
  IFaxIncomingQueue = interface(IDispatch)
    ['{902E64EF-8FD8-4B75-9725-6014DF161545}']
    function Get_Blocked: WordBool; safecall;
    procedure Set_Blocked(pbBlocked: WordBool); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    function GetJobs: IFaxIncomingJobs; safecall;
    function GetJob(const bstrJobId: WideString): IFaxIncomingJob; safecall;
    property Blocked: WordBool read Get_Blocked write Set_Blocked;
  end;

// *********************************************************************//
// DispIntf:  IFaxIncomingQueueDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {902E64EF-8FD8-4B75-9725-6014DF161545}
// *********************************************************************//
  IFaxIncomingQueueDisp = dispinterface
    ['{902E64EF-8FD8-4B75-9725-6014DF161545}']
    property Blocked: WordBool dispid 1;
    procedure Refresh; dispid 2;
    procedure Save; dispid 3;
    function GetJobs: IFaxIncomingJobs; dispid 4;
    function GetJob(const bstrJobId: WideString): IFaxIncomingJob; dispid 5;
  end;

// *********************************************************************//
// Interface: IFaxIncomingJobs
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {011F04E9-4FD6-4C23-9513-B6B66BB26BE9}
// *********************************************************************//
  IFaxIncomingJobs = interface(IDispatch)
    ['{011F04E9-4FD6-4C23-9513-B6B66BB26BE9}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(vIndex: OleVariant): IFaxIncomingJob; safecall;
    function Get_Count: Integer; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[vIndex: OleVariant]: IFaxIncomingJob read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxIncomingJobsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {011F04E9-4FD6-4C23-9513-B6B66BB26BE9}
// *********************************************************************//
  IFaxIncomingJobsDisp = dispinterface
    ['{011F04E9-4FD6-4C23-9513-B6B66BB26BE9}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[vIndex: OleVariant]: IFaxIncomingJob readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
  end;

// *********************************************************************//
// Interface: IFaxIncomingJob
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {207529E6-654A-4916-9F88-4D232EE8A107}
// *********************************************************************//
  IFaxIncomingJob = interface(IDispatch)
    ['{207529E6-654A-4916-9F88-4D232EE8A107}']
    function Get_Size: Integer; safecall;
    function Get_Id: WideString; safecall;
    function Get_CurrentPage: Integer; safecall;
    function Get_DeviceId: Integer; safecall;
    function Get_Status: FAX_JOB_STATUS_ENUM; safecall;
    function Get_ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM; safecall;
    function Get_ExtendedStatus: WideString; safecall;
    function Get_AvailableOperations: FAX_JOB_OPERATIONS_ENUM; safecall;
    function Get_Retries: Integer; safecall;
    function Get_TransmissionStart: TDateTime; safecall;
    function Get_TransmissionEnd: TDateTime; safecall;
    function Get_CSID: WideString; safecall;
    function Get_TSID: WideString; safecall;
    function Get_CallerId: WideString; safecall;
    function Get_RoutingInformation: WideString; safecall;
    function Get_JobType: FAX_JOB_TYPE_ENUM; safecall;
    procedure Cancel; safecall;
    procedure Refresh; safecall;
    procedure CopyTiff(const bstrTiffPath: WideString); safecall;
    property Size: Integer read Get_Size;
    property Id: WideString read Get_Id;
    property CurrentPage: Integer read Get_CurrentPage;
    property DeviceId: Integer read Get_DeviceId;
    property Status: FAX_JOB_STATUS_ENUM read Get_Status;
    property ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM read Get_ExtendedStatusCode;
    property ExtendedStatus: WideString read Get_ExtendedStatus;
    property AvailableOperations: FAX_JOB_OPERATIONS_ENUM read Get_AvailableOperations;
    property Retries: Integer read Get_Retries;
    property TransmissionStart: TDateTime read Get_TransmissionStart;
    property TransmissionEnd: TDateTime read Get_TransmissionEnd;
    property CSID: WideString read Get_CSID;
    property TSID: WideString read Get_TSID;
    property CallerId: WideString read Get_CallerId;
    property RoutingInformation: WideString read Get_RoutingInformation;
    property JobType: FAX_JOB_TYPE_ENUM read Get_JobType;
  end;

// *********************************************************************//
// DispIntf:  IFaxIncomingJobDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {207529E6-654A-4916-9F88-4D232EE8A107}
// *********************************************************************//
  IFaxIncomingJobDisp = dispinterface
    ['{207529E6-654A-4916-9F88-4D232EE8A107}']
    property Size: Integer readonly dispid 1;
    property Id: WideString readonly dispid 2;
    property CurrentPage: Integer readonly dispid 3;
    property DeviceId: Integer readonly dispid 4;
    property Status: FAX_JOB_STATUS_ENUM readonly dispid 5;
    property ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM readonly dispid 6;
    property ExtendedStatus: WideString readonly dispid 7;
    property AvailableOperations: FAX_JOB_OPERATIONS_ENUM readonly dispid 8;
    property Retries: Integer readonly dispid 9;
    property TransmissionStart: TDateTime readonly dispid 10;
    property TransmissionEnd: TDateTime readonly dispid 11;
    property CSID: WideString readonly dispid 12;
    property TSID: WideString readonly dispid 13;
    property CallerId: WideString readonly dispid 14;
    property RoutingInformation: WideString readonly dispid 15;
    property JobType: FAX_JOB_TYPE_ENUM readonly dispid 16;
    procedure Cancel; dispid 17;
    procedure Refresh; dispid 18;
    procedure CopyTiff(const bstrTiffPath: WideString); dispid 19;
  end;

// *********************************************************************//
// Interface: IFaxIncomingArchive
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {76062CC7-F714-4FBD-AA06-ED6E4A4B70F3}
// *********************************************************************//
  IFaxIncomingArchive = interface(IDispatch)
    ['{76062CC7-F714-4FBD-AA06-ED6E4A4B70F3}']
    function Get_UseArchive: WordBool; safecall;
    procedure Set_UseArchive(pbUseArchive: WordBool); safecall;
    function Get_ArchiveFolder: WideString; safecall;
    procedure Set_ArchiveFolder(const pbstrArchiveFolder: WideString); safecall;
    function Get_SizeQuotaWarning: WordBool; safecall;
    procedure Set_SizeQuotaWarning(pbSizeQuotaWarning: WordBool); safecall;
    function Get_HighQuotaWaterMark: Integer; safecall;
    procedure Set_HighQuotaWaterMark(plHighQuotaWaterMark: Integer); safecall;
    function Get_LowQuotaWaterMark: Integer; safecall;
    procedure Set_LowQuotaWaterMark(plLowQuotaWaterMark: Integer); safecall;
    function Get_AgeLimit: Integer; safecall;
    procedure Set_AgeLimit(plAgeLimit: Integer); safecall;
    function Get_SizeLow: Integer; safecall;
    function Get_SizeHigh: Integer; safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    function GetMessages(lPrefetchSize: Integer): IFaxIncomingMessageIterator; safecall;
    function GetMessage(const bstrMessageId: WideString): IFaxIncomingMessage; safecall;
    property UseArchive: WordBool read Get_UseArchive write Set_UseArchive;
    property ArchiveFolder: WideString read Get_ArchiveFolder write Set_ArchiveFolder;
    property SizeQuotaWarning: WordBool read Get_SizeQuotaWarning write Set_SizeQuotaWarning;
    property HighQuotaWaterMark: Integer read Get_HighQuotaWaterMark write Set_HighQuotaWaterMark;
    property LowQuotaWaterMark: Integer read Get_LowQuotaWaterMark write Set_LowQuotaWaterMark;
    property AgeLimit: Integer read Get_AgeLimit write Set_AgeLimit;
    property SizeLow: Integer read Get_SizeLow;
    property SizeHigh: Integer read Get_SizeHigh;
  end;

// *********************************************************************//
// DispIntf:  IFaxIncomingArchiveDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {76062CC7-F714-4FBD-AA06-ED6E4A4B70F3}
// *********************************************************************//
  IFaxIncomingArchiveDisp = dispinterface
    ['{76062CC7-F714-4FBD-AA06-ED6E4A4B70F3}']
    property UseArchive: WordBool dispid 1;
    property ArchiveFolder: WideString dispid 2;
    property SizeQuotaWarning: WordBool dispid 3;
    property HighQuotaWaterMark: Integer dispid 4;
    property LowQuotaWaterMark: Integer dispid 5;
    property AgeLimit: Integer dispid 6;
    property SizeLow: Integer readonly dispid 7;
    property SizeHigh: Integer readonly dispid 8;
    procedure Refresh; dispid 9;
    procedure Save; dispid 10;
    function GetMessages(lPrefetchSize: Integer): IFaxIncomingMessageIterator; dispid 11;
    function GetMessage(const bstrMessageId: WideString): IFaxIncomingMessage; dispid 12;
  end;

// *********************************************************************//
// Interface: IFaxIncomingMessageIterator
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FD73ECC4-6F06-4F52-82A8-F7BA06AE3108}
// *********************************************************************//
  IFaxIncomingMessageIterator = interface(IDispatch)
    ['{FD73ECC4-6F06-4F52-82A8-F7BA06AE3108}']
    function Get_Message: IFaxIncomingMessage; safecall;
    function Get_PrefetchSize: Integer; safecall;
    procedure Set_PrefetchSize(plPrefetchSize: Integer); safecall;
    function Get_AtEOF: WordBool; safecall;
    procedure MoveFirst; safecall;
    procedure MoveNext; safecall;
    property Message: IFaxIncomingMessage read Get_Message;
    property PrefetchSize: Integer read Get_PrefetchSize write Set_PrefetchSize;
    property AtEOF: WordBool read Get_AtEOF;
  end;

// *********************************************************************//
// DispIntf:  IFaxIncomingMessageIteratorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FD73ECC4-6F06-4F52-82A8-F7BA06AE3108}
// *********************************************************************//
  IFaxIncomingMessageIteratorDisp = dispinterface
    ['{FD73ECC4-6F06-4F52-82A8-F7BA06AE3108}']
    property Message: IFaxIncomingMessage readonly dispid 1;
    property PrefetchSize: Integer dispid 2;
    property AtEOF: WordBool readonly dispid 3;
    procedure MoveFirst; dispid 4;
    procedure MoveNext; dispid 5;
  end;

// *********************************************************************//
// Interface: IFaxIncomingMessage
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7CAB88FA-2EF9-4851-B2F3-1D148FED8447}
// *********************************************************************//
  IFaxIncomingMessage = interface(IDispatch)
    ['{7CAB88FA-2EF9-4851-B2F3-1D148FED8447}']
    function Get_Id: WideString; safecall;
    function Get_Pages: Integer; safecall;
    function Get_Size: Integer; safecall;
    function Get_DeviceName: WideString; safecall;
    function Get_Retries: Integer; safecall;
    function Get_TransmissionStart: TDateTime; safecall;
    function Get_TransmissionEnd: TDateTime; safecall;
    function Get_CSID: WideString; safecall;
    function Get_TSID: WideString; safecall;
    function Get_CallerId: WideString; safecall;
    function Get_RoutingInformation: WideString; safecall;
    procedure CopyTiff(const bstrTiffPath: WideString); safecall;
    procedure Delete; safecall;
    property Id: WideString read Get_Id;
    property Pages: Integer read Get_Pages;
    property Size: Integer read Get_Size;
    property DeviceName: WideString read Get_DeviceName;
    property Retries: Integer read Get_Retries;
    property TransmissionStart: TDateTime read Get_TransmissionStart;
    property TransmissionEnd: TDateTime read Get_TransmissionEnd;
    property CSID: WideString read Get_CSID;
    property TSID: WideString read Get_TSID;
    property CallerId: WideString read Get_CallerId;
    property RoutingInformation: WideString read Get_RoutingInformation;
  end;

// *********************************************************************//
// DispIntf:  IFaxIncomingMessageDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7CAB88FA-2EF9-4851-B2F3-1D148FED8447}
// *********************************************************************//
  IFaxIncomingMessageDisp = dispinterface
    ['{7CAB88FA-2EF9-4851-B2F3-1D148FED8447}']
    property Id: WideString readonly dispid 1;
    property Pages: Integer readonly dispid 2;
    property Size: Integer readonly dispid 3;
    property DeviceName: WideString readonly dispid 4;
    property Retries: Integer readonly dispid 5;
    property TransmissionStart: TDateTime readonly dispid 6;
    property TransmissionEnd: TDateTime readonly dispid 7;
    property CSID: WideString readonly dispid 8;
    property TSID: WideString readonly dispid 9;
    property CallerId: WideString readonly dispid 10;
    property RoutingInformation: WideString readonly dispid 11;
    procedure CopyTiff(const bstrTiffPath: WideString); dispid 12;
    procedure Delete; dispid 13;
  end;

// *********************************************************************//
// Interface: IFaxOutgoingArchive
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C9C28F40-8D80-4E53-810F-9A79919B49FD}
// *********************************************************************//
  IFaxOutgoingArchive = interface(IDispatch)
    ['{C9C28F40-8D80-4E53-810F-9A79919B49FD}']
    function Get_UseArchive: WordBool; safecall;
    procedure Set_UseArchive(pbUseArchive: WordBool); safecall;
    function Get_ArchiveFolder: WideString; safecall;
    procedure Set_ArchiveFolder(const pbstrArchiveFolder: WideString); safecall;
    function Get_SizeQuotaWarning: WordBool; safecall;
    procedure Set_SizeQuotaWarning(pbSizeQuotaWarning: WordBool); safecall;
    function Get_HighQuotaWaterMark: Integer; safecall;
    procedure Set_HighQuotaWaterMark(plHighQuotaWaterMark: Integer); safecall;
    function Get_LowQuotaWaterMark: Integer; safecall;
    procedure Set_LowQuotaWaterMark(plLowQuotaWaterMark: Integer); safecall;
    function Get_AgeLimit: Integer; safecall;
    procedure Set_AgeLimit(plAgeLimit: Integer); safecall;
    function Get_SizeLow: Integer; safecall;
    function Get_SizeHigh: Integer; safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    function GetMessages(lPrefetchSize: Integer): IFaxOutgoingMessageIterator; safecall;
    function GetMessage(const bstrMessageId: WideString): IFaxOutgoingMessage; safecall;
    property UseArchive: WordBool read Get_UseArchive write Set_UseArchive;
    property ArchiveFolder: WideString read Get_ArchiveFolder write Set_ArchiveFolder;
    property SizeQuotaWarning: WordBool read Get_SizeQuotaWarning write Set_SizeQuotaWarning;
    property HighQuotaWaterMark: Integer read Get_HighQuotaWaterMark write Set_HighQuotaWaterMark;
    property LowQuotaWaterMark: Integer read Get_LowQuotaWaterMark write Set_LowQuotaWaterMark;
    property AgeLimit: Integer read Get_AgeLimit write Set_AgeLimit;
    property SizeLow: Integer read Get_SizeLow;
    property SizeHigh: Integer read Get_SizeHigh;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutgoingArchiveDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C9C28F40-8D80-4E53-810F-9A79919B49FD}
// *********************************************************************//
  IFaxOutgoingArchiveDisp = dispinterface
    ['{C9C28F40-8D80-4E53-810F-9A79919B49FD}']
    property UseArchive: WordBool dispid 1;
    property ArchiveFolder: WideString dispid 2;
    property SizeQuotaWarning: WordBool dispid 3;
    property HighQuotaWaterMark: Integer dispid 4;
    property LowQuotaWaterMark: Integer dispid 5;
    property AgeLimit: Integer dispid 6;
    property SizeLow: Integer readonly dispid 7;
    property SizeHigh: Integer readonly dispid 8;
    procedure Refresh; dispid 9;
    procedure Save; dispid 10;
    function GetMessages(lPrefetchSize: Integer): IFaxOutgoingMessageIterator; dispid 11;
    function GetMessage(const bstrMessageId: WideString): IFaxOutgoingMessage; dispid 12;
  end;

// *********************************************************************//
// Interface: IFaxOutgoingMessageIterator
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F5EC5D4F-B840-432F-9980-112FE42A9B7A}
// *********************************************************************//
  IFaxOutgoingMessageIterator = interface(IDispatch)
    ['{F5EC5D4F-B840-432F-9980-112FE42A9B7A}']
    function Get_Message: IFaxOutgoingMessage; safecall;
    function Get_AtEOF: WordBool; safecall;
    function Get_PrefetchSize: Integer; safecall;
    procedure Set_PrefetchSize(plPrefetchSize: Integer); safecall;
    procedure MoveFirst; safecall;
    procedure MoveNext; safecall;
    property Message: IFaxOutgoingMessage read Get_Message;
    property AtEOF: WordBool read Get_AtEOF;
    property PrefetchSize: Integer read Get_PrefetchSize write Set_PrefetchSize;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutgoingMessageIteratorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F5EC5D4F-B840-432F-9980-112FE42A9B7A}
// *********************************************************************//
  IFaxOutgoingMessageIteratorDisp = dispinterface
    ['{F5EC5D4F-B840-432F-9980-112FE42A9B7A}']
    property Message: IFaxOutgoingMessage readonly dispid 1;
    property AtEOF: WordBool readonly dispid 2;
    property PrefetchSize: Integer dispid 3;
    procedure MoveFirst; dispid 4;
    procedure MoveNext; dispid 5;
  end;

// *********************************************************************//
// Interface: IFaxOutgoingMessage
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F0EA35DE-CAA5-4A7C-82C7-2B60BA5F2BE2}
// *********************************************************************//
  IFaxOutgoingMessage = interface(IDispatch)
    ['{F0EA35DE-CAA5-4A7C-82C7-2B60BA5F2BE2}']
    function Get_SubmissionId: WideString; safecall;
    function Get_Id: WideString; safecall;
    function Get_Subject: WideString; safecall;
    function Get_DocumentName: WideString; safecall;
    function Get_Retries: Integer; safecall;
    function Get_Pages: Integer; safecall;
    function Get_Size: Integer; safecall;
    function Get_OriginalScheduledTime: TDateTime; safecall;
    function Get_SubmissionTime: TDateTime; safecall;
    function Get_Priority: FAX_PRIORITY_TYPE_ENUM; safecall;
    function Get_Sender: IFaxSender; safecall;
    function Get_Recipient: IFaxRecipient; safecall;
    function Get_DeviceName: WideString; safecall;
    function Get_TransmissionStart: TDateTime; safecall;
    function Get_TransmissionEnd: TDateTime; safecall;
    function Get_CSID: WideString; safecall;
    function Get_TSID: WideString; safecall;
    procedure CopyTiff(const bstrTiffPath: WideString); safecall;
    procedure Delete; safecall;
    property SubmissionId: WideString read Get_SubmissionId;
    property Id: WideString read Get_Id;
    property Subject: WideString read Get_Subject;
    property DocumentName: WideString read Get_DocumentName;
    property Retries: Integer read Get_Retries;
    property Pages: Integer read Get_Pages;
    property Size: Integer read Get_Size;
    property OriginalScheduledTime: TDateTime read Get_OriginalScheduledTime;
    property SubmissionTime: TDateTime read Get_SubmissionTime;
    property Priority: FAX_PRIORITY_TYPE_ENUM read Get_Priority;
    property Sender: IFaxSender read Get_Sender;
    property Recipient: IFaxRecipient read Get_Recipient;
    property DeviceName: WideString read Get_DeviceName;
    property TransmissionStart: TDateTime read Get_TransmissionStart;
    property TransmissionEnd: TDateTime read Get_TransmissionEnd;
    property CSID: WideString read Get_CSID;
    property TSID: WideString read Get_TSID;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutgoingMessageDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F0EA35DE-CAA5-4A7C-82C7-2B60BA5F2BE2}
// *********************************************************************//
  IFaxOutgoingMessageDisp = dispinterface
    ['{F0EA35DE-CAA5-4A7C-82C7-2B60BA5F2BE2}']
    property SubmissionId: WideString readonly dispid 1;
    property Id: WideString readonly dispid 2;
    property Subject: WideString readonly dispid 3;
    property DocumentName: WideString readonly dispid 4;
    property Retries: Integer readonly dispid 5;
    property Pages: Integer readonly dispid 6;
    property Size: Integer readonly dispid 7;
    property OriginalScheduledTime: TDateTime readonly dispid 8;
    property SubmissionTime: TDateTime readonly dispid 9;
    property Priority: FAX_PRIORITY_TYPE_ENUM readonly dispid 10;
    property Sender: IFaxSender readonly dispid 11;
    property Recipient: IFaxRecipient readonly dispid 12;
    property DeviceName: WideString readonly dispid 13;
    property TransmissionStart: TDateTime readonly dispid 14;
    property TransmissionEnd: TDateTime readonly dispid 15;
    property CSID: WideString readonly dispid 16;
    property TSID: WideString readonly dispid 17;
    procedure CopyTiff(const bstrTiffPath: WideString); dispid 18;
    procedure Delete; dispid 19;
  end;

// *********************************************************************//
// Interface: IFaxLoggingOptions
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {34E64FB9-6B31-4D32-8B27-D286C0C33606}
// *********************************************************************//
  IFaxLoggingOptions = interface(IDispatch)
    ['{34E64FB9-6B31-4D32-8B27-D286C0C33606}']
    function Get_EventLogging: IFaxEventLogging; safecall;
    function Get_ActivityLogging: IFaxActivityLogging; safecall;
    property EventLogging: IFaxEventLogging read Get_EventLogging;
    property ActivityLogging: IFaxActivityLogging read Get_ActivityLogging;
  end;

// *********************************************************************//
// DispIntf:  IFaxLoggingOptionsDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {34E64FB9-6B31-4D32-8B27-D286C0C33606}
// *********************************************************************//
  IFaxLoggingOptionsDisp = dispinterface
    ['{34E64FB9-6B31-4D32-8B27-D286C0C33606}']
    property EventLogging: IFaxEventLogging readonly dispid 1;
    property ActivityLogging: IFaxActivityLogging readonly dispid 2;
  end;

// *********************************************************************//
// Interface: IFaxEventLogging
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0880D965-20E8-42E4-8E17-944F192CAAD4}
// *********************************************************************//
  IFaxEventLogging = interface(IDispatch)
    ['{0880D965-20E8-42E4-8E17-944F192CAAD4}']
    function Get_InitEventsLevel: FAX_LOG_LEVEL_ENUM; safecall;
    procedure Set_InitEventsLevel(pInitEventLevel: FAX_LOG_LEVEL_ENUM); safecall;
    function Get_InboundEventsLevel: FAX_LOG_LEVEL_ENUM; safecall;
    procedure Set_InboundEventsLevel(pInboundEventLevel: FAX_LOG_LEVEL_ENUM); safecall;
    function Get_OutboundEventsLevel: FAX_LOG_LEVEL_ENUM; safecall;
    procedure Set_OutboundEventsLevel(pOutboundEventLevel: FAX_LOG_LEVEL_ENUM); safecall;
    function Get_GeneralEventsLevel: FAX_LOG_LEVEL_ENUM; safecall;
    procedure Set_GeneralEventsLevel(pGeneralEventLevel: FAX_LOG_LEVEL_ENUM); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    property InitEventsLevel: FAX_LOG_LEVEL_ENUM read Get_InitEventsLevel write Set_InitEventsLevel;
    property InboundEventsLevel: FAX_LOG_LEVEL_ENUM read Get_InboundEventsLevel write Set_InboundEventsLevel;
    property OutboundEventsLevel: FAX_LOG_LEVEL_ENUM read Get_OutboundEventsLevel write Set_OutboundEventsLevel;
    property GeneralEventsLevel: FAX_LOG_LEVEL_ENUM read Get_GeneralEventsLevel write Set_GeneralEventsLevel;
  end;

// *********************************************************************//
// DispIntf:  IFaxEventLoggingDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0880D965-20E8-42E4-8E17-944F192CAAD4}
// *********************************************************************//
  IFaxEventLoggingDisp = dispinterface
    ['{0880D965-20E8-42E4-8E17-944F192CAAD4}']
    property InitEventsLevel: FAX_LOG_LEVEL_ENUM dispid 1;
    property InboundEventsLevel: FAX_LOG_LEVEL_ENUM dispid 2;
    property OutboundEventsLevel: FAX_LOG_LEVEL_ENUM dispid 3;
    property GeneralEventsLevel: FAX_LOG_LEVEL_ENUM dispid 4;
    procedure Refresh; dispid 5;
    procedure Save; dispid 6;
  end;

// *********************************************************************//
// Interface: IFaxActivityLogging
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {1E29078B-5A69-497B-9592-49B7E7FADDB5}
// *********************************************************************//
  IFaxActivityLogging = interface(IDispatch)
    ['{1E29078B-5A69-497B-9592-49B7E7FADDB5}']
    function Get_LogIncoming: WordBool; safecall;
    procedure Set_LogIncoming(pbLogIncoming: WordBool); safecall;
    function Get_LogOutgoing: WordBool; safecall;
    procedure Set_LogOutgoing(pbLogOutgoing: WordBool); safecall;
    function Get_DatabasePath: WideString; safecall;
    procedure Set_DatabasePath(const pbstrDatabasePath: WideString); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    property LogIncoming: WordBool read Get_LogIncoming write Set_LogIncoming;
    property LogOutgoing: WordBool read Get_LogOutgoing write Set_LogOutgoing;
    property DatabasePath: WideString read Get_DatabasePath write Set_DatabasePath;
  end;

// *********************************************************************//
// DispIntf:  IFaxActivityLoggingDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {1E29078B-5A69-497B-9592-49B7E7FADDB5}
// *********************************************************************//
  IFaxActivityLoggingDisp = dispinterface
    ['{1E29078B-5A69-497B-9592-49B7E7FADDB5}']
    property LogIncoming: WordBool dispid 1;
    property LogOutgoing: WordBool dispid 2;
    property DatabasePath: WideString dispid 3;
    procedure Refresh; dispid 4;
    procedure Save; dispid 5;
  end;

// *********************************************************************//
// Interface: IFaxActivity
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {4B106F97-3DF5-40F2-BC3C-44CB8115EBDF}
// *********************************************************************//
  IFaxActivity = interface(IDispatch)
    ['{4B106F97-3DF5-40F2-BC3C-44CB8115EBDF}']
    function Get_IncomingMessages: Integer; safecall;
    function Get_RoutingMessages: Integer; safecall;
    function Get_OutgoingMessages: Integer; safecall;
    function Get_QueuedMessages: Integer; safecall;
    procedure Refresh; safecall;
    property IncomingMessages: Integer read Get_IncomingMessages;
    property RoutingMessages: Integer read Get_RoutingMessages;
    property OutgoingMessages: Integer read Get_OutgoingMessages;
    property QueuedMessages: Integer read Get_QueuedMessages;
  end;

// *********************************************************************//
// DispIntf:  IFaxActivityDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {4B106F97-3DF5-40F2-BC3C-44CB8115EBDF}
// *********************************************************************//
  IFaxActivityDisp = dispinterface
    ['{4B106F97-3DF5-40F2-BC3C-44CB8115EBDF}']
    property IncomingMessages: Integer readonly dispid 1;
    property RoutingMessages: Integer readonly dispid 2;
    property OutgoingMessages: Integer readonly dispid 3;
    property QueuedMessages: Integer readonly dispid 4;
    procedure Refresh; dispid 5;
  end;

// *********************************************************************//
// Interface: IFaxOutboundRouting
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {25DC05A4-9909-41BD-A95B-7E5D1DEC1D43}
// *********************************************************************//
  IFaxOutboundRouting = interface(IDispatch)
    ['{25DC05A4-9909-41BD-A95B-7E5D1DEC1D43}']
    function GetGroups: IFaxOutboundRoutingGroups; safecall;
    function GetRules: IFaxOutboundRoutingRules; safecall;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutboundRoutingDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {25DC05A4-9909-41BD-A95B-7E5D1DEC1D43}
// *********************************************************************//
  IFaxOutboundRoutingDisp = dispinterface
    ['{25DC05A4-9909-41BD-A95B-7E5D1DEC1D43}']
    function GetGroups: IFaxOutboundRoutingGroups; dispid 1;
    function GetRules: IFaxOutboundRoutingRules; dispid 2;
  end;

// *********************************************************************//
// Interface: IFaxOutboundRoutingGroups
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {235CBEF7-C2DE-4BFD-B8DA-75097C82C87F}
// *********************************************************************//
  IFaxOutboundRoutingGroups = interface(IDispatch)
    ['{235CBEF7-C2DE-4BFD-B8DA-75097C82C87F}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(vIndex: OleVariant): IFaxOutboundRoutingGroup; safecall;
    function Get_Count: Integer; safecall;
    function Add(const bstrName: WideString): IFaxOutboundRoutingGroup; safecall;
    procedure Remove(vIndex: OleVariant); safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[vIndex: OleVariant]: IFaxOutboundRoutingGroup read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutboundRoutingGroupsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {235CBEF7-C2DE-4BFD-B8DA-75097C82C87F}
// *********************************************************************//
  IFaxOutboundRoutingGroupsDisp = dispinterface
    ['{235CBEF7-C2DE-4BFD-B8DA-75097C82C87F}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[vIndex: OleVariant]: IFaxOutboundRoutingGroup readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    function Add(const bstrName: WideString): IFaxOutboundRoutingGroup; dispid 2;
    procedure Remove(vIndex: OleVariant); dispid 3;
  end;

// *********************************************************************//
// Interface: IFaxOutboundRoutingGroup
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CA6289A1-7E25-4F87-9A0B-93365734962C}
// *********************************************************************//
  IFaxOutboundRoutingGroup = interface(IDispatch)
    ['{CA6289A1-7E25-4F87-9A0B-93365734962C}']
    function Get_Name: WideString; safecall;
    function Get_Status: FAX_GROUP_STATUS_ENUM; safecall;
    function Get_DeviceIds: IFaxDeviceIds; safecall;
    property Name: WideString read Get_Name;
    property Status: FAX_GROUP_STATUS_ENUM read Get_Status;
    property DeviceIds: IFaxDeviceIds read Get_DeviceIds;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutboundRoutingGroupDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {CA6289A1-7E25-4F87-9A0B-93365734962C}
// *********************************************************************//
  IFaxOutboundRoutingGroupDisp = dispinterface
    ['{CA6289A1-7E25-4F87-9A0B-93365734962C}']
    property Name: WideString readonly dispid 1;
    property Status: FAX_GROUP_STATUS_ENUM readonly dispid 2;
    property DeviceIds: IFaxDeviceIds readonly dispid 3;
  end;

// *********************************************************************//
// Interface: IFaxDeviceIds
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2F0F813F-4CE9-443E-8CA1-738CFAEEE149}
// *********************************************************************//
  IFaxDeviceIds = interface(IDispatch)
    ['{2F0F813F-4CE9-443E-8CA1-738CFAEEE149}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(lIndex: Integer): Integer; safecall;
    function Get_Count: Integer; safecall;
    procedure Add(lDeviceId: Integer); safecall;
    procedure Remove(lIndex: Integer); safecall;
    procedure SetOrder(lDeviceId: Integer; lNewOrder: Integer); safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[lIndex: Integer]: Integer read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxDeviceIdsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2F0F813F-4CE9-443E-8CA1-738CFAEEE149}
// *********************************************************************//
  IFaxDeviceIdsDisp = dispinterface
    ['{2F0F813F-4CE9-443E-8CA1-738CFAEEE149}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[lIndex: Integer]: Integer readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    procedure Add(lDeviceId: Integer); dispid 2;
    procedure Remove(lIndex: Integer); dispid 3;
    procedure SetOrder(lDeviceId: Integer; lNewOrder: Integer); dispid 4;
  end;

// *********************************************************************//
// Interface: IFaxOutboundRoutingRules
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DCEFA1E7-AE7D-4ED6-8521-369EDCCA5120}
// *********************************************************************//
  IFaxOutboundRoutingRules = interface(IDispatch)
    ['{DCEFA1E7-AE7D-4ED6-8521-369EDCCA5120}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(lIndex: Integer): IFaxOutboundRoutingRule; safecall;
    function Get_Count: Integer; safecall;
    function ItemByCountryAndArea(lCountryCode: Integer; lAreaCode: Integer): IFaxOutboundRoutingRule; safecall;
    procedure RemoveByCountryAndArea(lCountryCode: Integer; lAreaCode: Integer); safecall;
    procedure Remove(lIndex: Integer); safecall;
    function Add(lCountryCode: Integer; lAreaCode: Integer; bUseDevice: WordBool; 
                 const bstrGroupName: WideString; lDeviceId: Integer): IFaxOutboundRoutingRule; safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[lIndex: Integer]: IFaxOutboundRoutingRule read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutboundRoutingRulesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DCEFA1E7-AE7D-4ED6-8521-369EDCCA5120}
// *********************************************************************//
  IFaxOutboundRoutingRulesDisp = dispinterface
    ['{DCEFA1E7-AE7D-4ED6-8521-369EDCCA5120}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[lIndex: Integer]: IFaxOutboundRoutingRule readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    function ItemByCountryAndArea(lCountryCode: Integer; lAreaCode: Integer): IFaxOutboundRoutingRule; dispid 2;
    procedure RemoveByCountryAndArea(lCountryCode: Integer; lAreaCode: Integer); dispid 3;
    procedure Remove(lIndex: Integer); dispid 4;
    function Add(lCountryCode: Integer; lAreaCode: Integer; bUseDevice: WordBool; 
                 const bstrGroupName: WideString; lDeviceId: Integer): IFaxOutboundRoutingRule; dispid 5;
  end;

// *********************************************************************//
// Interface: IFaxOutboundRoutingRule
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E1F795D5-07C2-469F-B027-ACACC23219DA}
// *********************************************************************//
  IFaxOutboundRoutingRule = interface(IDispatch)
    ['{E1F795D5-07C2-469F-B027-ACACC23219DA}']
    function Get_CountryCode: Integer; safecall;
    function Get_AreaCode: Integer; safecall;
    function Get_Status: FAX_RULE_STATUS_ENUM; safecall;
    function Get_UseDevice: WordBool; safecall;
    procedure Set_UseDevice(pbUseDevice: WordBool); safecall;
    function Get_DeviceId: Integer; safecall;
    procedure Set_DeviceId(plDeviceId: Integer); safecall;
    function Get_GroupName: WideString; safecall;
    procedure Set_GroupName(const pbstrGroupName: WideString); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    property CountryCode: Integer read Get_CountryCode;
    property AreaCode: Integer read Get_AreaCode;
    property Status: FAX_RULE_STATUS_ENUM read Get_Status;
    property UseDevice: WordBool read Get_UseDevice write Set_UseDevice;
    property DeviceId: Integer read Get_DeviceId write Set_DeviceId;
    property GroupName: WideString read Get_GroupName write Set_GroupName;
  end;

// *********************************************************************//
// DispIntf:  IFaxOutboundRoutingRuleDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {E1F795D5-07C2-469F-B027-ACACC23219DA}
// *********************************************************************//
  IFaxOutboundRoutingRuleDisp = dispinterface
    ['{E1F795D5-07C2-469F-B027-ACACC23219DA}']
    property CountryCode: Integer readonly dispid 1;
    property AreaCode: Integer readonly dispid 2;
    property Status: FAX_RULE_STATUS_ENUM readonly dispid 3;
    property UseDevice: WordBool dispid 4;
    property DeviceId: Integer dispid 5;
    property GroupName: WideString dispid 6;
    procedure Refresh; dispid 7;
    procedure Save; dispid 8;
  end;

// *********************************************************************//
// Interface: IFaxReceiptOptions
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {378EFAEB-5FCB-4AFB-B2EE-E16E80614487}
// *********************************************************************//
  IFaxReceiptOptions = interface(IDispatch)
    ['{378EFAEB-5FCB-4AFB-B2EE-E16E80614487}']
    function Get_AuthenticationType: FAX_SMTP_AUTHENTICATION_TYPE_ENUM; safecall;
    procedure Set_AuthenticationType(pType: FAX_SMTP_AUTHENTICATION_TYPE_ENUM); safecall;
    function Get_SMTPServer: WideString; safecall;
    procedure Set_SMTPServer(const pbstrSMTPServer: WideString); safecall;
    function Get_SMTPPort: Integer; safecall;
    procedure Set_SMTPPort(plSMTPPort: Integer); safecall;
    function Get_SMTPSender: WideString; safecall;
    procedure Set_SMTPSender(const pbstrSMTPSender: WideString); safecall;
    function Get_SMTPUser: WideString; safecall;
    procedure Set_SMTPUser(const pbstrSMTPUser: WideString); safecall;
    function Get_AllowedReceipts: FAX_RECEIPT_TYPE_ENUM; safecall;
    procedure Set_AllowedReceipts(pAllowedReceipts: FAX_RECEIPT_TYPE_ENUM); safecall;
    function Get_SMTPPassword: WideString; safecall;
    procedure Set_SMTPPassword(const pbstrSMTPPassword: WideString); safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    function Get_UseForInboundRouting: WordBool; safecall;
    procedure Set_UseForInboundRouting(pbUseForInboundRouting: WordBool); safecall;
    property AuthenticationType: FAX_SMTP_AUTHENTICATION_TYPE_ENUM read Get_AuthenticationType write Set_AuthenticationType;
    property SMTPServer: WideString read Get_SMTPServer write Set_SMTPServer;
    property SMTPPort: Integer read Get_SMTPPort write Set_SMTPPort;
    property SMTPSender: WideString read Get_SMTPSender write Set_SMTPSender;
    property SMTPUser: WideString read Get_SMTPUser write Set_SMTPUser;
    property AllowedReceipts: FAX_RECEIPT_TYPE_ENUM read Get_AllowedReceipts write Set_AllowedReceipts;
    property SMTPPassword: WideString read Get_SMTPPassword write Set_SMTPPassword;
    property UseForInboundRouting: WordBool read Get_UseForInboundRouting write Set_UseForInboundRouting;
  end;

// *********************************************************************//
// DispIntf:  IFaxReceiptOptionsDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {378EFAEB-5FCB-4AFB-B2EE-E16E80614487}
// *********************************************************************//
  IFaxReceiptOptionsDisp = dispinterface
    ['{378EFAEB-5FCB-4AFB-B2EE-E16E80614487}']
    property AuthenticationType: FAX_SMTP_AUTHENTICATION_TYPE_ENUM dispid 1;
    property SMTPServer: WideString dispid 2;
    property SMTPPort: Integer dispid 3;
    property SMTPSender: WideString dispid 4;
    property SMTPUser: WideString dispid 5;
    property AllowedReceipts: FAX_RECEIPT_TYPE_ENUM dispid 6;
    property SMTPPassword: WideString dispid 7;
    procedure Refresh; dispid 8;
    procedure Save; dispid 9;
    property UseForInboundRouting: WordBool dispid 10;
  end;

// *********************************************************************//
// Interface: IFaxSecurity
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {77B508C1-09C0-47A2-91EB-FCE7FDF2690E}
// *********************************************************************//
  IFaxSecurity = interface(IDispatch)
    ['{77B508C1-09C0-47A2-91EB-FCE7FDF2690E}']
    function Get_Descriptor: OleVariant; safecall;
    procedure Set_Descriptor(pvDescriptor: OleVariant); safecall;
    function Get_GrantedRights: FAX_ACCESS_RIGHTS_ENUM; safecall;
    procedure Refresh; safecall;
    procedure Save; safecall;
    function Get_InformationType: Integer; safecall;
    procedure Set_InformationType(plInformationType: Integer); safecall;
    property Descriptor: OleVariant read Get_Descriptor write Set_Descriptor;
    property GrantedRights: FAX_ACCESS_RIGHTS_ENUM read Get_GrantedRights;
    property InformationType: Integer read Get_InformationType write Set_InformationType;
  end;

// *********************************************************************//
// DispIntf:  IFaxSecurityDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {77B508C1-09C0-47A2-91EB-FCE7FDF2690E}
// *********************************************************************//
  IFaxSecurityDisp = dispinterface
    ['{77B508C1-09C0-47A2-91EB-FCE7FDF2690E}']
    property Descriptor: OleVariant dispid 1;
    property GrantedRights: FAX_ACCESS_RIGHTS_ENUM readonly dispid 2;
    procedure Refresh; dispid 3;
    procedure Save; dispid 4;
    property InformationType: Integer dispid 5;
  end;

// *********************************************************************//
// Interface: IFaxJobStatus
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8B86F485-FD7F-4824-886B-40C5CAA617CC}
// *********************************************************************//
  IFaxJobStatus = interface(IDispatch)
    ['{8B86F485-FD7F-4824-886B-40C5CAA617CC}']
    function Get_Status: FAX_JOB_STATUS_ENUM; safecall;
    function Get_Pages: Integer; safecall;
    function Get_Size: Integer; safecall;
    function Get_CurrentPage: Integer; safecall;
    function Get_DeviceId: Integer; safecall;
    function Get_CSID: WideString; safecall;
    function Get_TSID: WideString; safecall;
    function Get_ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM; safecall;
    function Get_ExtendedStatus: WideString; safecall;
    function Get_AvailableOperations: FAX_JOB_OPERATIONS_ENUM; safecall;
    function Get_Retries: Integer; safecall;
    function Get_JobType: FAX_JOB_TYPE_ENUM; safecall;
    function Get_ScheduledTime: TDateTime; safecall;
    function Get_TransmissionStart: TDateTime; safecall;
    function Get_TransmissionEnd: TDateTime; safecall;
    function Get_CallerId: WideString; safecall;
    function Get_RoutingInformation: WideString; safecall;
    property Status: FAX_JOB_STATUS_ENUM read Get_Status;
    property Pages: Integer read Get_Pages;
    property Size: Integer read Get_Size;
    property CurrentPage: Integer read Get_CurrentPage;
    property DeviceId: Integer read Get_DeviceId;
    property CSID: WideString read Get_CSID;
    property TSID: WideString read Get_TSID;
    property ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM read Get_ExtendedStatusCode;
    property ExtendedStatus: WideString read Get_ExtendedStatus;
    property AvailableOperations: FAX_JOB_OPERATIONS_ENUM read Get_AvailableOperations;
    property Retries: Integer read Get_Retries;
    property JobType: FAX_JOB_TYPE_ENUM read Get_JobType;
    property ScheduledTime: TDateTime read Get_ScheduledTime;
    property TransmissionStart: TDateTime read Get_TransmissionStart;
    property TransmissionEnd: TDateTime read Get_TransmissionEnd;
    property CallerId: WideString read Get_CallerId;
    property RoutingInformation: WideString read Get_RoutingInformation;
  end;

// *********************************************************************//
// DispIntf:  IFaxJobStatusDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8B86F485-FD7F-4824-886B-40C5CAA617CC}
// *********************************************************************//
  IFaxJobStatusDisp = dispinterface
    ['{8B86F485-FD7F-4824-886B-40C5CAA617CC}']
    property Status: FAX_JOB_STATUS_ENUM readonly dispid 1;
    property Pages: Integer readonly dispid 2;
    property Size: Integer readonly dispid 3;
    property CurrentPage: Integer readonly dispid 4;
    property DeviceId: Integer readonly dispid 5;
    property CSID: WideString readonly dispid 6;
    property TSID: WideString readonly dispid 7;
    property ExtendedStatusCode: FAX_JOB_EXTENDED_STATUS_ENUM readonly dispid 8;
    property ExtendedStatus: WideString readonly dispid 9;
    property AvailableOperations: FAX_JOB_OPERATIONS_ENUM readonly dispid 10;
    property Retries: Integer readonly dispid 11;
    property JobType: FAX_JOB_TYPE_ENUM readonly dispid 12;
    property ScheduledTime: TDateTime readonly dispid 13;
    property TransmissionStart: TDateTime readonly dispid 14;
    property TransmissionEnd: TDateTime readonly dispid 15;
    property CallerId: WideString readonly dispid 16;
    property RoutingInformation: WideString readonly dispid 17;
  end;

// *********************************************************************//
// Interface: IFaxDocument
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B207A246-09E3-4A4E-A7DC-FEA31D29458F}
// *********************************************************************//
  IFaxDocument = interface(IDispatch)
    ['{B207A246-09E3-4A4E-A7DC-FEA31D29458F}']
    function Get_Body: WideString; safecall;
    procedure Set_Body(const pbstrBody: WideString); safecall;
    function Get_Sender: IFaxSender; safecall;
    function Get_Recipients: IFaxRecipients; safecall;
    function Get_CoverPage: WideString; safecall;
    procedure Set_CoverPage(const pbstrCoverPage: WideString); safecall;
    function Get_Subject: WideString; safecall;
    procedure Set_Subject(const pbstrSubject: WideString); safecall;
    function Get_Note: WideString; safecall;
    procedure Set_Note(const pbstrNote: WideString); safecall;
    function Get_ScheduleTime: TDateTime; safecall;
    procedure Set_ScheduleTime(pdateScheduleTime: TDateTime); safecall;
    function Get_ReceiptAddress: WideString; safecall;
    procedure Set_ReceiptAddress(const pbstrReceiptAddress: WideString); safecall;
    function Get_DocumentName: WideString; safecall;
    procedure Set_DocumentName(const pbstrDocumentName: WideString); safecall;
    function Get_CallHandle: Integer; safecall;
    procedure Set_CallHandle(plCallHandle: Integer); safecall;
    function Get_CoverPageType: FAX_COVERPAGE_TYPE_ENUM; safecall;
    procedure Set_CoverPageType(pCoverPageType: FAX_COVERPAGE_TYPE_ENUM); safecall;
    function Get_ScheduleType: FAX_SCHEDULE_TYPE_ENUM; safecall;
    procedure Set_ScheduleType(pScheduleType: FAX_SCHEDULE_TYPE_ENUM); safecall;
    function Get_ReceiptType: FAX_RECEIPT_TYPE_ENUM; safecall;
    procedure Set_ReceiptType(pReceiptType: FAX_RECEIPT_TYPE_ENUM); safecall;
    function Get_GroupBroadcastReceipts: WordBool; safecall;
    procedure Set_GroupBroadcastReceipts(pbUseGrouping: WordBool); safecall;
    function Get_Priority: FAX_PRIORITY_TYPE_ENUM; safecall;
    procedure Set_Priority(pPriority: FAX_PRIORITY_TYPE_ENUM); safecall;
    function Get_TapiConnection: IDispatch; safecall;
    procedure _Set_TapiConnection(const ppTapiConnection: IDispatch); safecall;
    function Submit(const bstrFaxServerName: WideString): OleVariant; safecall;
    function ConnectedSubmit(const pFaxServer: IFaxServer): OleVariant; safecall;
    function Get_AttachFaxToReceipt: WordBool; safecall;
    procedure Set_AttachFaxToReceipt(pbAttachFax: WordBool); safecall;
    property Body: WideString read Get_Body write Set_Body;
    property Sender: IFaxSender read Get_Sender;
    property Recipients: IFaxRecipients read Get_Recipients;
    property CoverPage: WideString read Get_CoverPage write Set_CoverPage;
    property Subject: WideString read Get_Subject write Set_Subject;
    property Note: WideString read Get_Note write Set_Note;
    property ScheduleTime: TDateTime read Get_ScheduleTime write Set_ScheduleTime;
    property ReceiptAddress: WideString read Get_ReceiptAddress write Set_ReceiptAddress;
    property DocumentName: WideString read Get_DocumentName write Set_DocumentName;
    property CallHandle: Integer read Get_CallHandle write Set_CallHandle;
    property CoverPageType: FAX_COVERPAGE_TYPE_ENUM read Get_CoverPageType write Set_CoverPageType;
    property ScheduleType: FAX_SCHEDULE_TYPE_ENUM read Get_ScheduleType write Set_ScheduleType;
    property ReceiptType: FAX_RECEIPT_TYPE_ENUM read Get_ReceiptType write Set_ReceiptType;
    property GroupBroadcastReceipts: WordBool read Get_GroupBroadcastReceipts write Set_GroupBroadcastReceipts;
    property Priority: FAX_PRIORITY_TYPE_ENUM read Get_Priority write Set_Priority;
    property TapiConnection: IDispatch read Get_TapiConnection write _Set_TapiConnection;
    property AttachFaxToReceipt: WordBool read Get_AttachFaxToReceipt write Set_AttachFaxToReceipt;
  end;

// *********************************************************************//
// DispIntf:  IFaxDocumentDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B207A246-09E3-4A4E-A7DC-FEA31D29458F}
// *********************************************************************//
  IFaxDocumentDisp = dispinterface
    ['{B207A246-09E3-4A4E-A7DC-FEA31D29458F}']
    property Body: WideString dispid 1;
    property Sender: IFaxSender readonly dispid 2;
    property Recipients: IFaxRecipients readonly dispid 3;
    property CoverPage: WideString dispid 4;
    property Subject: WideString dispid 5;
    property Note: WideString dispid 6;
    property ScheduleTime: TDateTime dispid 7;
    property ReceiptAddress: WideString dispid 8;
    property DocumentName: WideString dispid 9;
    property CallHandle: Integer dispid 10;
    property CoverPageType: FAX_COVERPAGE_TYPE_ENUM dispid 11;
    property ScheduleType: FAX_SCHEDULE_TYPE_ENUM dispid 12;
    property ReceiptType: FAX_RECEIPT_TYPE_ENUM dispid 13;
    property GroupBroadcastReceipts: WordBool dispid 14;
    property Priority: FAX_PRIORITY_TYPE_ENUM dispid 15;
    property TapiConnection: IDispatch dispid 16;
    function Submit(const bstrFaxServerName: WideString): OleVariant; dispid 17;
    function ConnectedSubmit(const pFaxServer: IFaxServer): OleVariant; dispid 18;
    property AttachFaxToReceipt: WordBool dispid 19;
  end;

// *********************************************************************//
// Interface: IFaxRecipients
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B9C9DE5A-894E-4492-9FA3-08C627C11D5D}
// *********************************************************************//
  IFaxRecipients = interface(IDispatch)
    ['{B9C9DE5A-894E-4492-9FA3-08C627C11D5D}']
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(lIndex: Integer): IFaxRecipient; safecall;
    function Get_Count: Integer; safecall;
    function Add(const bstrFaxNumber: WideString; const bstrRecipientName: WideString): IFaxRecipient; safecall;
    procedure Remove(lIndex: Integer); safecall;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[lIndex: Integer]: IFaxRecipient read Get_Item; default;
    property Count: Integer read Get_Count;
  end;

// *********************************************************************//
// DispIntf:  IFaxRecipientsDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B9C9DE5A-894E-4492-9FA3-08C627C11D5D}
// *********************************************************************//
  IFaxRecipientsDisp = dispinterface
    ['{B9C9DE5A-894E-4492-9FA3-08C627C11D5D}']
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[lIndex: Integer]: IFaxRecipient readonly dispid 0; default;
    property Count: Integer readonly dispid 1;
    function Add(const bstrFaxNumber: WideString; const bstrRecipientName: WideString): IFaxRecipient; dispid 2;
    procedure Remove(lIndex: Integer); dispid 3;
  end;

// *********************************************************************//
// The Class CoFaxServer provides a Create and CreateRemote method to          
// create instances of the default interface IFaxServer exposed by              
// the CoClass FaxServer. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxServer = class
    class function Create: IFaxServer;
    class function CreateRemote(const MachineName: string): IFaxServer;
  end;

  TFaxServerOnIncomingJobAdded = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                             const bstrJobId: WideString) of object;
  TFaxServerOnIncomingJobRemoved = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                               const bstrJobId: WideString) of object;
  TFaxServerOnIncomingJobChanged = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                               const bstrJobId: WideString; 
                                                               const pJobStatus: IFaxJobStatus) of object;
  TFaxServerOnOutgoingJobAdded = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                             const bstrJobId: WideString) of object;
  TFaxServerOnOutgoingJobRemoved = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                               const bstrJobId: WideString) of object;
  TFaxServerOnOutgoingJobChanged = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                               const bstrJobId: WideString; 
                                                               const pJobStatus: IFaxJobStatus) of object;
  TFaxServerOnIncomingMessageAdded = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                                 const bstrMessageId: WideString) of object;
  TFaxServerOnIncomingMessageRemoved = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                                   const bstrMessageId: WideString) of object;
  TFaxServerOnOutgoingMessageAdded = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                                 const bstrMessageId: WideString) of object;
  TFaxServerOnOutgoingMessageRemoved = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                                   const bstrMessageId: WideString) of object;
  TFaxServerOnReceiptOptionsChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnActivityLoggingConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnSecurityConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnEventLoggingConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnOutgoingQueueConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnOutgoingArchiveConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnIncomingArchiveConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnDevicesConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnOutboundRoutingGroupsConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnOutboundRoutingRulesConfigChange = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnServerActivityChange = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                                 lIncomingMessages: Integer; 
                                                                 lRoutingMessages: Integer; 
                                                                 lOutgoingMessages: Integer; 
                                                                 lQueuedMessages: Integer) of object;
  TFaxServerOnQueuesStatusChange = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                               bOutgoingQueueBlocked: WordBool; 
                                                               bOutgoingQueuePaused: WordBool; 
                                                               bIncomingQueueBlocked: WordBool) of object;
  TFaxServerOnNewCall = procedure(ASender: TObject; const pFaxServer: IFaxServer; lCallId: Integer; 
                                                    lDeviceId: Integer; 
                                                    const bstrCallerId: WideString) of object;
  TFaxServerOnServerShutDown = procedure(ASender: TObject; const pFaxServer: IFaxServer) of object;
  TFaxServerOnDeviceStatusChange = procedure(ASender: TObject; const pFaxServer: IFaxServer; 
                                                               lDeviceId: Integer; 
                                                               bPoweredOff: WordBool; 
                                                               bSending: WordBool; 
                                                               bReceiving: WordBool; 
                                                               bRinging: WordBool) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFaxServer
// Help String      : FaxServer Class
// Default Interface: IFaxServer
// Def. Intf. DISP? : No
// Event   Interface: IFaxServerNotify
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFaxServerProperties= class;
{$ENDIF}
  TFaxServer = class(TOleServer)
  private
    FOnIncomingJobAdded: TFaxServerOnIncomingJobAdded;
    FOnIncomingJobRemoved: TFaxServerOnIncomingJobRemoved;
    FOnIncomingJobChanged: TFaxServerOnIncomingJobChanged;
    FOnOutgoingJobAdded: TFaxServerOnOutgoingJobAdded;
    FOnOutgoingJobRemoved: TFaxServerOnOutgoingJobRemoved;
    FOnOutgoingJobChanged: TFaxServerOnOutgoingJobChanged;
    FOnIncomingMessageAdded: TFaxServerOnIncomingMessageAdded;
    FOnIncomingMessageRemoved: TFaxServerOnIncomingMessageRemoved;
    FOnOutgoingMessageAdded: TFaxServerOnOutgoingMessageAdded;
    FOnOutgoingMessageRemoved: TFaxServerOnOutgoingMessageRemoved;
    FOnReceiptOptionsChange: TFaxServerOnReceiptOptionsChange;
    FOnActivityLoggingConfigChange: TFaxServerOnActivityLoggingConfigChange;
    FOnSecurityConfigChange: TFaxServerOnSecurityConfigChange;
    FOnEventLoggingConfigChange: TFaxServerOnEventLoggingConfigChange;
    FOnOutgoingQueueConfigChange: TFaxServerOnOutgoingQueueConfigChange;
    FOnOutgoingArchiveConfigChange: TFaxServerOnOutgoingArchiveConfigChange;
    FOnIncomingArchiveConfigChange: TFaxServerOnIncomingArchiveConfigChange;
    FOnDevicesConfigChange: TFaxServerOnDevicesConfigChange;
    FOnOutboundRoutingGroupsConfigChange: TFaxServerOnOutboundRoutingGroupsConfigChange;
    FOnOutboundRoutingRulesConfigChange: TFaxServerOnOutboundRoutingRulesConfigChange;
    FOnServerActivityChange: TFaxServerOnServerActivityChange;
    FOnQueuesStatusChange: TFaxServerOnQueuesStatusChange;
    FOnNewCall: TFaxServerOnNewCall;
    FOnServerShutDown: TFaxServerOnServerShutDown;
    FOnDeviceStatusChange: TFaxServerOnDeviceStatusChange;
    FIntf:        IFaxServer;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TFaxServerProperties;
    function      GetServerProperties: TFaxServerProperties;
{$ENDIF}
    function      GetDefaultInterface: IFaxServer;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_ServerName: WideString;
    function Get_InboundRouting: IFaxInboundRouting;
    function Get_Folders: IFaxFolders;
    function Get_LoggingOptions: IFaxLoggingOptions;
    function Get_MajorVersion: Integer;
    function Get_MinorVersion: Integer;
    function Get_MajorBuild: Integer;
    function Get_MinorBuild: Integer;
    function Get_Debug: WordBool;
    function Get_Activity: IFaxActivity;
    function Get_OutboundRouting: IFaxOutboundRouting;
    function Get_ReceiptOptions: IFaxReceiptOptions;
    function Get_Security: IFaxSecurity;
    function Get_RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM;
    function Get_APIVersion: FAX_SERVER_APIVERSION_ENUM;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFaxServer);
    procedure Disconnect; override;
    procedure Connect1(const bstrServerName: WideString);
    function GetDeviceProviders: IFaxDeviceProviders;
    function GetDevices: IFaxDevices;
    procedure Disconnect1;
    function GetExtensionProperty(const bstrGUID: WideString): OleVariant;
    procedure SetExtensionProperty(const bstrGUID: WideString; vProperty: OleVariant);
    procedure ListenToServerEvents(EventTypes: FAX_SERVER_EVENTS_TYPE_ENUM);
    procedure RegisterDeviceProvider(const bstrGUID: WideString; 
                                     const bstrFriendlyName: WideString; 
                                     const bstrImageName: WideString; const TspName: WideString; 
                                     lFSPIVersion: Integer);
    procedure UnregisterDeviceProvider(const bstrUniqueName: WideString);
    procedure RegisterInboundRoutingExtension(const bstrExtensionName: WideString; 
                                              const bstrFriendlyName: WideString; 
                                              const bstrImageName: WideString; vMethods: OleVariant);
    procedure UnregisterInboundRoutingExtension(const bstrExtensionUniqueName: WideString);
    property DefaultInterface: IFaxServer read GetDefaultInterface;
    property ServerName: WideString read Get_ServerName;
    property InboundRouting: IFaxInboundRouting read Get_InboundRouting;
    property Folders: IFaxFolders read Get_Folders;
    property LoggingOptions: IFaxLoggingOptions read Get_LoggingOptions;
    property MajorVersion: Integer read Get_MajorVersion;
    property MinorVersion: Integer read Get_MinorVersion;
    property MajorBuild: Integer read Get_MajorBuild;
    property MinorBuild: Integer read Get_MinorBuild;
    property Debug: WordBool read Get_Debug;
    property Activity: IFaxActivity read Get_Activity;
    property OutboundRouting: IFaxOutboundRouting read Get_OutboundRouting;
    property ReceiptOptions: IFaxReceiptOptions read Get_ReceiptOptions;
    property Security: IFaxSecurity read Get_Security;
    property RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM read Get_RegisteredEvents;
    property APIVersion: FAX_SERVER_APIVERSION_ENUM read Get_APIVersion;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFaxServerProperties read GetServerProperties;
{$ENDIF}
    property OnIncomingJobAdded: TFaxServerOnIncomingJobAdded read FOnIncomingJobAdded write FOnIncomingJobAdded;
    property OnIncomingJobRemoved: TFaxServerOnIncomingJobRemoved read FOnIncomingJobRemoved write FOnIncomingJobRemoved;
    property OnIncomingJobChanged: TFaxServerOnIncomingJobChanged read FOnIncomingJobChanged write FOnIncomingJobChanged;
    property OnOutgoingJobAdded: TFaxServerOnOutgoingJobAdded read FOnOutgoingJobAdded write FOnOutgoingJobAdded;
    property OnOutgoingJobRemoved: TFaxServerOnOutgoingJobRemoved read FOnOutgoingJobRemoved write FOnOutgoingJobRemoved;
    property OnOutgoingJobChanged: TFaxServerOnOutgoingJobChanged read FOnOutgoingJobChanged write FOnOutgoingJobChanged;
    property OnIncomingMessageAdded: TFaxServerOnIncomingMessageAdded read FOnIncomingMessageAdded write FOnIncomingMessageAdded;
    property OnIncomingMessageRemoved: TFaxServerOnIncomingMessageRemoved read FOnIncomingMessageRemoved write FOnIncomingMessageRemoved;
    property OnOutgoingMessageAdded: TFaxServerOnOutgoingMessageAdded read FOnOutgoingMessageAdded write FOnOutgoingMessageAdded;
    property OnOutgoingMessageRemoved: TFaxServerOnOutgoingMessageRemoved read FOnOutgoingMessageRemoved write FOnOutgoingMessageRemoved;
    property OnReceiptOptionsChange: TFaxServerOnReceiptOptionsChange read FOnReceiptOptionsChange write FOnReceiptOptionsChange;
    property OnActivityLoggingConfigChange: TFaxServerOnActivityLoggingConfigChange read FOnActivityLoggingConfigChange write FOnActivityLoggingConfigChange;
    property OnSecurityConfigChange: TFaxServerOnSecurityConfigChange read FOnSecurityConfigChange write FOnSecurityConfigChange;
    property OnEventLoggingConfigChange: TFaxServerOnEventLoggingConfigChange read FOnEventLoggingConfigChange write FOnEventLoggingConfigChange;
    property OnOutgoingQueueConfigChange: TFaxServerOnOutgoingQueueConfigChange read FOnOutgoingQueueConfigChange write FOnOutgoingQueueConfigChange;
    property OnOutgoingArchiveConfigChange: TFaxServerOnOutgoingArchiveConfigChange read FOnOutgoingArchiveConfigChange write FOnOutgoingArchiveConfigChange;
    property OnIncomingArchiveConfigChange: TFaxServerOnIncomingArchiveConfigChange read FOnIncomingArchiveConfigChange write FOnIncomingArchiveConfigChange;
    property OnDevicesConfigChange: TFaxServerOnDevicesConfigChange read FOnDevicesConfigChange write FOnDevicesConfigChange;
    property OnOutboundRoutingGroupsConfigChange: TFaxServerOnOutboundRoutingGroupsConfigChange read FOnOutboundRoutingGroupsConfigChange write FOnOutboundRoutingGroupsConfigChange;
    property OnOutboundRoutingRulesConfigChange: TFaxServerOnOutboundRoutingRulesConfigChange read FOnOutboundRoutingRulesConfigChange write FOnOutboundRoutingRulesConfigChange;
    property OnServerActivityChange: TFaxServerOnServerActivityChange read FOnServerActivityChange write FOnServerActivityChange;
    property OnQueuesStatusChange: TFaxServerOnQueuesStatusChange read FOnQueuesStatusChange write FOnQueuesStatusChange;
    property OnNewCall: TFaxServerOnNewCall read FOnNewCall write FOnNewCall;
    property OnServerShutDown: TFaxServerOnServerShutDown read FOnServerShutDown write FOnServerShutDown;
    property OnDeviceStatusChange: TFaxServerOnDeviceStatusChange read FOnDeviceStatusChange write FOnDeviceStatusChange;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFaxServer
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFaxServerProperties = class(TPersistent)
  private
    FServer:    TFaxServer;
    function    GetDefaultInterface: IFaxServer;
    constructor Create(AServer: TFaxServer);
  protected
    function Get_ServerName: WideString;
    function Get_InboundRouting: IFaxInboundRouting;
    function Get_Folders: IFaxFolders;
    function Get_LoggingOptions: IFaxLoggingOptions;
    function Get_MajorVersion: Integer;
    function Get_MinorVersion: Integer;
    function Get_MajorBuild: Integer;
    function Get_MinorBuild: Integer;
    function Get_Debug: WordBool;
    function Get_Activity: IFaxActivity;
    function Get_OutboundRouting: IFaxOutboundRouting;
    function Get_ReceiptOptions: IFaxReceiptOptions;
    function Get_Security: IFaxSecurity;
    function Get_RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM;
    function Get_APIVersion: FAX_SERVER_APIVERSION_ENUM;
  public
    property DefaultInterface: IFaxServer read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFaxDeviceProviders provides a Create and CreateRemote method to          
// create instances of the default interface IFaxDeviceProviders exposed by              
// the CoClass FaxDeviceProviders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxDeviceProviders = class
    class function Create: IFaxDeviceProviders;
    class function CreateRemote(const MachineName: string): IFaxDeviceProviders;
  end;

// *********************************************************************//
// The Class CoFaxDevices provides a Create and CreateRemote method to          
// create instances of the default interface IFaxDevices exposed by              
// the CoClass FaxDevices. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxDevices = class
    class function Create: IFaxDevices;
    class function CreateRemote(const MachineName: string): IFaxDevices;
  end;

// *********************************************************************//
// The Class CoFaxInboundRouting provides a Create and CreateRemote method to          
// create instances of the default interface IFaxInboundRouting exposed by              
// the CoClass FaxInboundRouting. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxInboundRouting = class
    class function Create: IFaxInboundRouting;
    class function CreateRemote(const MachineName: string): IFaxInboundRouting;
  end;

// *********************************************************************//
// The Class CoFaxFolders provides a Create and CreateRemote method to          
// create instances of the default interface IFaxFolders exposed by              
// the CoClass FaxFolders. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxFolders = class
    class function Create: IFaxFolders;
    class function CreateRemote(const MachineName: string): IFaxFolders;
  end;

// *********************************************************************//
// The Class CoFaxLoggingOptions provides a Create and CreateRemote method to          
// create instances of the default interface IFaxLoggingOptions exposed by              
// the CoClass FaxLoggingOptions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxLoggingOptions = class
    class function Create: IFaxLoggingOptions;
    class function CreateRemote(const MachineName: string): IFaxLoggingOptions;
  end;

// *********************************************************************//
// The Class CoFaxActivity provides a Create and CreateRemote method to          
// create instances of the default interface IFaxActivity exposed by              
// the CoClass FaxActivity. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxActivity = class
    class function Create: IFaxActivity;
    class function CreateRemote(const MachineName: string): IFaxActivity;
  end;

// *********************************************************************//
// The Class CoFaxOutboundRouting provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutboundRouting exposed by              
// the CoClass FaxOutboundRouting. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutboundRouting = class
    class function Create: IFaxOutboundRouting;
    class function CreateRemote(const MachineName: string): IFaxOutboundRouting;
  end;

// *********************************************************************//
// The Class CoFaxReceiptOptions provides a Create and CreateRemote method to          
// create instances of the default interface IFaxReceiptOptions exposed by              
// the CoClass FaxReceiptOptions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxReceiptOptions = class
    class function Create: IFaxReceiptOptions;
    class function CreateRemote(const MachineName: string): IFaxReceiptOptions;
  end;

// *********************************************************************//
// The Class CoFaxSecurity provides a Create and CreateRemote method to          
// create instances of the default interface IFaxSecurity exposed by              
// the CoClass FaxSecurity. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxSecurity = class
    class function Create: IFaxSecurity;
    class function CreateRemote(const MachineName: string): IFaxSecurity;
  end;

// *********************************************************************//
// The Class CoFaxDocument provides a Create and CreateRemote method to          
// create instances of the default interface IFaxDocument exposed by              
// the CoClass FaxDocument. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxDocument = class
    class function Create: IFaxDocument;
    class function CreateRemote(const MachineName: string): IFaxDocument;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFaxDocument
// Help String      : FaxDocument Class
// Default Interface: IFaxDocument
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFaxDocumentProperties= class;
{$ENDIF}
  TFaxDocument = class(TOleServer)
  private
    FIntf:        IFaxDocument;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TFaxDocumentProperties;
    function      GetServerProperties: TFaxDocumentProperties;
{$ENDIF}
    function      GetDefaultInterface: IFaxDocument;
  protected
    procedure InitServerData; override;
    function Get_Body: WideString;
    procedure Set_Body(const pbstrBody: WideString);
    function Get_Sender: IFaxSender;
    function Get_Recipients: IFaxRecipients;
    function Get_CoverPage: WideString;
    procedure Set_CoverPage(const pbstrCoverPage: WideString);
    function Get_Subject: WideString;
    procedure Set_Subject(const pbstrSubject: WideString);
    function Get_Note: WideString;
    procedure Set_Note(const pbstrNote: WideString);
    function Get_ScheduleTime: TDateTime;
    procedure Set_ScheduleTime(pdateScheduleTime: TDateTime);
    function Get_ReceiptAddress: WideString;
    procedure Set_ReceiptAddress(const pbstrReceiptAddress: WideString);
    function Get_DocumentName: WideString;
    procedure Set_DocumentName(const pbstrDocumentName: WideString);
    function Get_CallHandle: Integer;
    procedure Set_CallHandle(plCallHandle: Integer);
    function Get_CoverPageType: FAX_COVERPAGE_TYPE_ENUM;
    procedure Set_CoverPageType(pCoverPageType: FAX_COVERPAGE_TYPE_ENUM);
    function Get_ScheduleType: FAX_SCHEDULE_TYPE_ENUM;
    procedure Set_ScheduleType(pScheduleType: FAX_SCHEDULE_TYPE_ENUM);
    function Get_ReceiptType: FAX_RECEIPT_TYPE_ENUM;
    procedure Set_ReceiptType(pReceiptType: FAX_RECEIPT_TYPE_ENUM);
    function Get_GroupBroadcastReceipts: WordBool;
    procedure Set_GroupBroadcastReceipts(pbUseGrouping: WordBool);
    function Get_Priority: FAX_PRIORITY_TYPE_ENUM;
    procedure Set_Priority(pPriority: FAX_PRIORITY_TYPE_ENUM);
    function Get_TapiConnection: IDispatch;
    procedure _Set_TapiConnection(const ppTapiConnection: IDispatch);
    function Get_AttachFaxToReceipt: WordBool;
    procedure Set_AttachFaxToReceipt(pbAttachFax: WordBool);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IFaxDocument);
    procedure Disconnect; override;
    function Submit(const bstrFaxServerName: WideString): OleVariant;
    function ConnectedSubmit(const pFaxServer: IFaxServer): OleVariant;
    property DefaultInterface: IFaxDocument read GetDefaultInterface;
    property Sender: IFaxSender read Get_Sender;
    property Recipients: IFaxRecipients read Get_Recipients;
    property TapiConnection: IDispatch read Get_TapiConnection write _Set_TapiConnection;
    property Body: WideString read Get_Body write Set_Body;
    property CoverPage: WideString read Get_CoverPage write Set_CoverPage;
    property Subject: WideString read Get_Subject write Set_Subject;
    property Note: WideString read Get_Note write Set_Note;
    property ScheduleTime: TDateTime read Get_ScheduleTime write Set_ScheduleTime;
    property ReceiptAddress: WideString read Get_ReceiptAddress write Set_ReceiptAddress;
    property DocumentName: WideString read Get_DocumentName write Set_DocumentName;
    property CallHandle: Integer read Get_CallHandle write Set_CallHandle;
    property CoverPageType: FAX_COVERPAGE_TYPE_ENUM read Get_CoverPageType write Set_CoverPageType;
    property ScheduleType: FAX_SCHEDULE_TYPE_ENUM read Get_ScheduleType write Set_ScheduleType;
    property ReceiptType: FAX_RECEIPT_TYPE_ENUM read Get_ReceiptType write Set_ReceiptType;
    property GroupBroadcastReceipts: WordBool read Get_GroupBroadcastReceipts write Set_GroupBroadcastReceipts;
    property Priority: FAX_PRIORITY_TYPE_ENUM read Get_Priority write Set_Priority;
    property AttachFaxToReceipt: WordBool read Get_AttachFaxToReceipt write Set_AttachFaxToReceipt;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFaxDocumentProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFaxDocument
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFaxDocumentProperties = class(TPersistent)
  private
    FServer:    TFaxDocument;
    function    GetDefaultInterface: IFaxDocument;
    constructor Create(AServer: TFaxDocument);
  protected
    function Get_Body: WideString;
    procedure Set_Body(const pbstrBody: WideString);
    function Get_Sender: IFaxSender;
    function Get_Recipients: IFaxRecipients;
    function Get_CoverPage: WideString;
    procedure Set_CoverPage(const pbstrCoverPage: WideString);
    function Get_Subject: WideString;
    procedure Set_Subject(const pbstrSubject: WideString);
    function Get_Note: WideString;
    procedure Set_Note(const pbstrNote: WideString);
    function Get_ScheduleTime: TDateTime;
    procedure Set_ScheduleTime(pdateScheduleTime: TDateTime);
    function Get_ReceiptAddress: WideString;
    procedure Set_ReceiptAddress(const pbstrReceiptAddress: WideString);
    function Get_DocumentName: WideString;
    procedure Set_DocumentName(const pbstrDocumentName: WideString);
    function Get_CallHandle: Integer;
    procedure Set_CallHandle(plCallHandle: Integer);
    function Get_CoverPageType: FAX_COVERPAGE_TYPE_ENUM;
    procedure Set_CoverPageType(pCoverPageType: FAX_COVERPAGE_TYPE_ENUM);
    function Get_ScheduleType: FAX_SCHEDULE_TYPE_ENUM;
    procedure Set_ScheduleType(pScheduleType: FAX_SCHEDULE_TYPE_ENUM);
    function Get_ReceiptType: FAX_RECEIPT_TYPE_ENUM;
    procedure Set_ReceiptType(pReceiptType: FAX_RECEIPT_TYPE_ENUM);
    function Get_GroupBroadcastReceipts: WordBool;
    procedure Set_GroupBroadcastReceipts(pbUseGrouping: WordBool);
    function Get_Priority: FAX_PRIORITY_TYPE_ENUM;
    procedure Set_Priority(pPriority: FAX_PRIORITY_TYPE_ENUM);
    function Get_TapiConnection: IDispatch;
    procedure _Set_TapiConnection(const ppTapiConnection: IDispatch);
    function Get_AttachFaxToReceipt: WordBool;
    procedure Set_AttachFaxToReceipt(pbAttachFax: WordBool);
  public
    property DefaultInterface: IFaxDocument read GetDefaultInterface;
  published
    property Body: WideString read Get_Body write Set_Body;
    property CoverPage: WideString read Get_CoverPage write Set_CoverPage;
    property Subject: WideString read Get_Subject write Set_Subject;
    property Note: WideString read Get_Note write Set_Note;
    property ScheduleTime: TDateTime read Get_ScheduleTime write Set_ScheduleTime;
    property ReceiptAddress: WideString read Get_ReceiptAddress write Set_ReceiptAddress;
    property DocumentName: WideString read Get_DocumentName write Set_DocumentName;
    property CallHandle: Integer read Get_CallHandle write Set_CallHandle;
    property CoverPageType: FAX_COVERPAGE_TYPE_ENUM read Get_CoverPageType write Set_CoverPageType;
    property ScheduleType: FAX_SCHEDULE_TYPE_ENUM read Get_ScheduleType write Set_ScheduleType;
    property ReceiptType: FAX_RECEIPT_TYPE_ENUM read Get_ReceiptType write Set_ReceiptType;
    property GroupBroadcastReceipts: WordBool read Get_GroupBroadcastReceipts write Set_GroupBroadcastReceipts;
    property Priority: FAX_PRIORITY_TYPE_ENUM read Get_Priority write Set_Priority;
    property AttachFaxToReceipt: WordBool read Get_AttachFaxToReceipt write Set_AttachFaxToReceipt;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFaxSender provides a Create and CreateRemote method to          
// create instances of the default interface IFaxSender exposed by              
// the CoClass FaxSender. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxSender = class
    class function Create: IFaxSender;
    class function CreateRemote(const MachineName: string): IFaxSender;
  end;

// *********************************************************************//
// The Class CoFaxRecipients provides a Create and CreateRemote method to          
// create instances of the default interface IFaxRecipients exposed by              
// the CoClass FaxRecipients. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxRecipients = class
    class function Create: IFaxRecipients;
    class function CreateRemote(const MachineName: string): IFaxRecipients;
  end;

// *********************************************************************//
// The Class CoFaxIncomingArchive provides a Create and CreateRemote method to          
// create instances of the default interface IFaxIncomingArchive exposed by              
// the CoClass FaxIncomingArchive. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxIncomingArchive = class
    class function Create: IFaxIncomingArchive;
    class function CreateRemote(const MachineName: string): IFaxIncomingArchive;
  end;

// *********************************************************************//
// The Class CoFaxIncomingQueue provides a Create and CreateRemote method to          
// create instances of the default interface IFaxIncomingQueue exposed by              
// the CoClass FaxIncomingQueue. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxIncomingQueue = class
    class function Create: IFaxIncomingQueue;
    class function CreateRemote(const MachineName: string): IFaxIncomingQueue;
  end;

// *********************************************************************//
// The Class CoFaxOutgoingArchive provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutgoingArchive exposed by              
// the CoClass FaxOutgoingArchive. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutgoingArchive = class
    class function Create: IFaxOutgoingArchive;
    class function CreateRemote(const MachineName: string): IFaxOutgoingArchive;
  end;

// *********************************************************************//
// The Class CoFaxOutgoingQueue provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutgoingQueue exposed by              
// the CoClass FaxOutgoingQueue. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutgoingQueue = class
    class function Create: IFaxOutgoingQueue;
    class function CreateRemote(const MachineName: string): IFaxOutgoingQueue;
  end;

// *********************************************************************//
// The Class CoFaxIncomingMessageIterator provides a Create and CreateRemote method to          
// create instances of the default interface IFaxIncomingMessageIterator exposed by              
// the CoClass FaxIncomingMessageIterator. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxIncomingMessageIterator = class
    class function Create: IFaxIncomingMessageIterator;
    class function CreateRemote(const MachineName: string): IFaxIncomingMessageIterator;
  end;

// *********************************************************************//
// The Class CoFaxIncomingMessage provides a Create and CreateRemote method to          
// create instances of the default interface IFaxIncomingMessage exposed by              
// the CoClass FaxIncomingMessage. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxIncomingMessage = class
    class function Create: IFaxIncomingMessage;
    class function CreateRemote(const MachineName: string): IFaxIncomingMessage;
  end;

// *********************************************************************//
// The Class CoFaxOutgoingJobs provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutgoingJobs exposed by              
// the CoClass FaxOutgoingJobs. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutgoingJobs = class
    class function Create: IFaxOutgoingJobs;
    class function CreateRemote(const MachineName: string): IFaxOutgoingJobs;
  end;

// *********************************************************************//
// The Class CoFaxOutgoingJob provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutgoingJob exposed by              
// the CoClass FaxOutgoingJob. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutgoingJob = class
    class function Create: IFaxOutgoingJob;
    class function CreateRemote(const MachineName: string): IFaxOutgoingJob;
  end;

// *********************************************************************//
// The Class CoFaxOutgoingMessageIterator provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutgoingMessageIterator exposed by              
// the CoClass FaxOutgoingMessageIterator. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutgoingMessageIterator = class
    class function Create: IFaxOutgoingMessageIterator;
    class function CreateRemote(const MachineName: string): IFaxOutgoingMessageIterator;
  end;

// *********************************************************************//
// The Class CoFaxOutgoingMessage provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutgoingMessage exposed by              
// the CoClass FaxOutgoingMessage. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutgoingMessage = class
    class function Create: IFaxOutgoingMessage;
    class function CreateRemote(const MachineName: string): IFaxOutgoingMessage;
  end;

// *********************************************************************//
// The Class CoFaxIncomingJobs provides a Create and CreateRemote method to          
// create instances of the default interface IFaxIncomingJobs exposed by              
// the CoClass FaxIncomingJobs. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxIncomingJobs = class
    class function Create: IFaxIncomingJobs;
    class function CreateRemote(const MachineName: string): IFaxIncomingJobs;
  end;

// *********************************************************************//
// The Class CoFaxIncomingJob provides a Create and CreateRemote method to          
// create instances of the default interface IFaxIncomingJob exposed by              
// the CoClass FaxIncomingJob. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxIncomingJob = class
    class function Create: IFaxIncomingJob;
    class function CreateRemote(const MachineName: string): IFaxIncomingJob;
  end;

// *********************************************************************//
// The Class CoFaxDeviceProvider provides a Create and CreateRemote method to          
// create instances of the default interface IFaxDeviceProvider exposed by              
// the CoClass FaxDeviceProvider. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxDeviceProvider = class
    class function Create: IFaxDeviceProvider;
    class function CreateRemote(const MachineName: string): IFaxDeviceProvider;
  end;

// *********************************************************************//
// The Class CoFaxDevice provides a Create and CreateRemote method to          
// create instances of the default interface IFaxDevice exposed by              
// the CoClass FaxDevice. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxDevice = class
    class function Create: IFaxDevice;
    class function CreateRemote(const MachineName: string): IFaxDevice;
  end;

// *********************************************************************//
// The Class CoFaxActivityLogging provides a Create and CreateRemote method to          
// create instances of the default interface IFaxActivityLogging exposed by              
// the CoClass FaxActivityLogging. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxActivityLogging = class
    class function Create: IFaxActivityLogging;
    class function CreateRemote(const MachineName: string): IFaxActivityLogging;
  end;

// *********************************************************************//
// The Class CoFaxEventLogging provides a Create and CreateRemote method to          
// create instances of the default interface IFaxEventLogging exposed by              
// the CoClass FaxEventLogging. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxEventLogging = class
    class function Create: IFaxEventLogging;
    class function CreateRemote(const MachineName: string): IFaxEventLogging;
  end;

// *********************************************************************//
// The Class CoFaxOutboundRoutingGroups provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutboundRoutingGroups exposed by              
// the CoClass FaxOutboundRoutingGroups. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutboundRoutingGroups = class
    class function Create: IFaxOutboundRoutingGroups;
    class function CreateRemote(const MachineName: string): IFaxOutboundRoutingGroups;
  end;

// *********************************************************************//
// The Class CoFaxOutboundRoutingGroup provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutboundRoutingGroup exposed by              
// the CoClass FaxOutboundRoutingGroup. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutboundRoutingGroup = class
    class function Create: IFaxOutboundRoutingGroup;
    class function CreateRemote(const MachineName: string): IFaxOutboundRoutingGroup;
  end;

// *********************************************************************//
// The Class CoFaxDeviceIds provides a Create and CreateRemote method to          
// create instances of the default interface IFaxDeviceIds exposed by              
// the CoClass FaxDeviceIds. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxDeviceIds = class
    class function Create: IFaxDeviceIds;
    class function CreateRemote(const MachineName: string): IFaxDeviceIds;
  end;

// *********************************************************************//
// The Class CoFaxOutboundRoutingRules provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutboundRoutingRules exposed by              
// the CoClass FaxOutboundRoutingRules. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutboundRoutingRules = class
    class function Create: IFaxOutboundRoutingRules;
    class function CreateRemote(const MachineName: string): IFaxOutboundRoutingRules;
  end;

// *********************************************************************//
// The Class CoFaxOutboundRoutingRule provides a Create and CreateRemote method to          
// create instances of the default interface IFaxOutboundRoutingRule exposed by              
// the CoClass FaxOutboundRoutingRule. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxOutboundRoutingRule = class
    class function Create: IFaxOutboundRoutingRule;
    class function CreateRemote(const MachineName: string): IFaxOutboundRoutingRule;
  end;

// *********************************************************************//
// The Class CoFaxInboundRoutingExtensions provides a Create and CreateRemote method to          
// create instances of the default interface IFaxInboundRoutingExtensions exposed by              
// the CoClass FaxInboundRoutingExtensions. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxInboundRoutingExtensions = class
    class function Create: IFaxInboundRoutingExtensions;
    class function CreateRemote(const MachineName: string): IFaxInboundRoutingExtensions;
  end;

// *********************************************************************//
// The Class CoFaxInboundRoutingExtension provides a Create and CreateRemote method to          
// create instances of the default interface IFaxInboundRoutingExtension exposed by              
// the CoClass FaxInboundRoutingExtension. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxInboundRoutingExtension = class
    class function Create: IFaxInboundRoutingExtension;
    class function CreateRemote(const MachineName: string): IFaxInboundRoutingExtension;
  end;

// *********************************************************************//
// The Class CoFaxInboundRoutingMethods provides a Create and CreateRemote method to          
// create instances of the default interface IFaxInboundRoutingMethods exposed by              
// the CoClass FaxInboundRoutingMethods. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxInboundRoutingMethods = class
    class function Create: IFaxInboundRoutingMethods;
    class function CreateRemote(const MachineName: string): IFaxInboundRoutingMethods;
  end;

// *********************************************************************//
// The Class CoFaxInboundRoutingMethod provides a Create and CreateRemote method to          
// create instances of the default interface IFaxInboundRoutingMethod exposed by              
// the CoClass FaxInboundRoutingMethod. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxInboundRoutingMethod = class
    class function Create: IFaxInboundRoutingMethod;
    class function CreateRemote(const MachineName: string): IFaxInboundRoutingMethod;
  end;

// *********************************************************************//
// The Class CoFaxJobStatus provides a Create and CreateRemote method to          
// create instances of the default interface IFaxJobStatus exposed by              
// the CoClass FaxJobStatus. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxJobStatus = class
    class function Create: IFaxJobStatus;
    class function CreateRemote(const MachineName: string): IFaxJobStatus;
  end;

// *********************************************************************//
// The Class CoFaxRecipient provides a Create and CreateRemote method to          
// create instances of the default interface IFaxRecipient exposed by              
// the CoClass FaxRecipient. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFaxRecipient = class
    class function Create: IFaxRecipient;
    class function CreateRemote(const MachineName: string): IFaxRecipient;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoFaxServer.Create: IFaxServer;
begin
  Result := CreateComObject(CLASS_FaxServer) as IFaxServer;
end;

class function CoFaxServer.CreateRemote(const MachineName: string): IFaxServer;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxServer) as IFaxServer;
end;

procedure TFaxServer.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{CDA8ACB0-8CF5-4F6C-9BA2-5931D40C8CAE}';
    IntfIID:   '{475B6469-90A5-4878-A577-17A86E8E3462}';
    EventIID:  '{2E037B27-CF8A-4ABD-B1E0-5704943BEA6F}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFaxServer.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IFaxServer;
  end;
end;

procedure TFaxServer.ConnectTo(svrIntf: IFaxServer);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TFaxServer.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TFaxServer.GetDefaultInterface: IFaxServer;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TFaxServer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFaxServerProperties.Create(Self);
{$ENDIF}
end;

destructor TFaxServer.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFaxServer.GetServerProperties: TFaxServerProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TFaxServer.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    1: if Assigned(FOnIncomingJobAdded) then
         FOnIncomingJobAdded(Self,
                             IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                             Params[1] {const WideString});
    2: if Assigned(FOnIncomingJobRemoved) then
         FOnIncomingJobRemoved(Self,
                               IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                               Params[1] {const WideString});
    3: if Assigned(FOnIncomingJobChanged) then
         FOnIncomingJobChanged(Self,
                               IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                               Params[1] {const WideString},
                               IUnknown(TVarData(Params[2]).VPointer) as IFaxJobStatus {const IFaxJobStatus});
    4: if Assigned(FOnOutgoingJobAdded) then
         FOnOutgoingJobAdded(Self,
                             IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                             Params[1] {const WideString});
    5: if Assigned(FOnOutgoingJobRemoved) then
         FOnOutgoingJobRemoved(Self,
                               IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                               Params[1] {const WideString});
    6: if Assigned(FOnOutgoingJobChanged) then
         FOnOutgoingJobChanged(Self,
                               IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                               Params[1] {const WideString},
                               IUnknown(TVarData(Params[2]).VPointer) as IFaxJobStatus {const IFaxJobStatus});
    7: if Assigned(FOnIncomingMessageAdded) then
         FOnIncomingMessageAdded(Self,
                                 IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                                 Params[1] {const WideString});
    8: if Assigned(FOnIncomingMessageRemoved) then
         FOnIncomingMessageRemoved(Self,
                                   IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                                   Params[1] {const WideString});
    9: if Assigned(FOnOutgoingMessageAdded) then
         FOnOutgoingMessageAdded(Self,
                                 IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                                 Params[1] {const WideString});
    10: if Assigned(FOnOutgoingMessageRemoved) then
         FOnOutgoingMessageRemoved(Self,
                                   IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                                   Params[1] {const WideString});
    11: if Assigned(FOnReceiptOptionsChange) then
         FOnReceiptOptionsChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    12: if Assigned(FOnActivityLoggingConfigChange) then
         FOnActivityLoggingConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    13: if Assigned(FOnSecurityConfigChange) then
         FOnSecurityConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    14: if Assigned(FOnEventLoggingConfigChange) then
         FOnEventLoggingConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    15: if Assigned(FOnOutgoingQueueConfigChange) then
         FOnOutgoingQueueConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    16: if Assigned(FOnOutgoingArchiveConfigChange) then
         FOnOutgoingArchiveConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    17: if Assigned(FOnIncomingArchiveConfigChange) then
         FOnIncomingArchiveConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    18: if Assigned(FOnDevicesConfigChange) then
         FOnDevicesConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    19: if Assigned(FOnOutboundRoutingGroupsConfigChange) then
         FOnOutboundRoutingGroupsConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    20: if Assigned(FOnOutboundRoutingRulesConfigChange) then
         FOnOutboundRoutingRulesConfigChange(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    21: if Assigned(FOnServerActivityChange) then
         FOnServerActivityChange(Self,
                                 IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                                 Params[1] {Integer},
                                 Params[2] {Integer},
                                 Params[3] {Integer},
                                 Params[4] {Integer});
    22: if Assigned(FOnQueuesStatusChange) then
         FOnQueuesStatusChange(Self,
                               IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                               Params[1] {WordBool},
                               Params[2] {WordBool},
                               Params[3] {WordBool});
    23: if Assigned(FOnNewCall) then
         FOnNewCall(Self,
                    IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                    Params[1] {Integer},
                    Params[2] {Integer},
                    Params[3] {const WideString});
    24: if Assigned(FOnServerShutDown) then
         FOnServerShutDown(Self, IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer});
    25: if Assigned(FOnDeviceStatusChange) then
         FOnDeviceStatusChange(Self,
                               IUnknown(TVarData(Params[0]).VPointer) as IFaxServer {const IFaxServer},
                               Params[1] {Integer},
                               Params[2] {WordBool},
                               Params[3] {WordBool},
                               Params[4] {WordBool},
                               Params[5] {WordBool});
  end; {case DispID}
end;

function TFaxServer.Get_ServerName: WideString;
begin
    Result := DefaultInterface.ServerName;
end;

function TFaxServer.Get_InboundRouting: IFaxInboundRouting;
begin
    Result := DefaultInterface.InboundRouting;
end;

function TFaxServer.Get_Folders: IFaxFolders;
begin
    Result := DefaultInterface.Folders;
end;

function TFaxServer.Get_LoggingOptions: IFaxLoggingOptions;
begin
    Result := DefaultInterface.LoggingOptions;
end;

function TFaxServer.Get_MajorVersion: Integer;
begin
    Result := DefaultInterface.MajorVersion;
end;

function TFaxServer.Get_MinorVersion: Integer;
begin
    Result := DefaultInterface.MinorVersion;
end;

function TFaxServer.Get_MajorBuild: Integer;
begin
    Result := DefaultInterface.MajorBuild;
end;

function TFaxServer.Get_MinorBuild: Integer;
begin
    Result := DefaultInterface.MinorBuild;
end;

function TFaxServer.Get_Debug: WordBool;
begin
    Result := DefaultInterface.Debug;
end;

function TFaxServer.Get_Activity: IFaxActivity;
begin
    Result := DefaultInterface.Activity;
end;

function TFaxServer.Get_OutboundRouting: IFaxOutboundRouting;
begin
    Result := DefaultInterface.OutboundRouting;
end;

function TFaxServer.Get_ReceiptOptions: IFaxReceiptOptions;
begin
    Result := DefaultInterface.ReceiptOptions;
end;

function TFaxServer.Get_Security: IFaxSecurity;
begin
    Result := DefaultInterface.Security;
end;

function TFaxServer.Get_RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM;
begin
    Result := DefaultInterface.RegisteredEvents;
end;

function TFaxServer.Get_APIVersion: FAX_SERVER_APIVERSION_ENUM;
begin
    Result := DefaultInterface.APIVersion;
end;

procedure TFaxServer.Connect1(const bstrServerName: WideString);
begin
  DefaultInterface.Connect(bstrServerName);
end;

function TFaxServer.GetDeviceProviders: IFaxDeviceProviders;
begin
  Result := DefaultInterface.GetDeviceProviders;
end;

function TFaxServer.GetDevices: IFaxDevices;
begin
  Result := DefaultInterface.GetDevices;
end;

procedure TFaxServer.Disconnect1;
begin
  DefaultInterface.Disconnect;
end;

function TFaxServer.GetExtensionProperty(const bstrGUID: WideString): OleVariant;
begin
  Result := DefaultInterface.GetExtensionProperty(bstrGUID);
end;

procedure TFaxServer.SetExtensionProperty(const bstrGUID: WideString; vProperty: OleVariant);
begin
  DefaultInterface.SetExtensionProperty(bstrGUID, vProperty);
end;

procedure TFaxServer.ListenToServerEvents(EventTypes: FAX_SERVER_EVENTS_TYPE_ENUM);
begin
  DefaultInterface.ListenToServerEvents(EventTypes);
end;

procedure TFaxServer.RegisterDeviceProvider(const bstrGUID: WideString; 
                                            const bstrFriendlyName: WideString; 
                                            const bstrImageName: WideString; 
                                            const TspName: WideString; lFSPIVersion: Integer);
begin
  DefaultInterface.RegisterDeviceProvider(bstrGUID, bstrFriendlyName, bstrImageName, TspName, 
                                          lFSPIVersion);
end;

procedure TFaxServer.UnregisterDeviceProvider(const bstrUniqueName: WideString);
begin
  DefaultInterface.UnregisterDeviceProvider(bstrUniqueName);
end;

procedure TFaxServer.RegisterInboundRoutingExtension(const bstrExtensionName: WideString; 
                                                     const bstrFriendlyName: WideString; 
                                                     const bstrImageName: WideString; 
                                                     vMethods: OleVariant);
begin
  DefaultInterface.RegisterInboundRoutingExtension(bstrExtensionName, bstrFriendlyName, 
                                                   bstrImageName, vMethods);
end;

procedure TFaxServer.UnregisterInboundRoutingExtension(const bstrExtensionUniqueName: WideString);
begin
  DefaultInterface.UnregisterInboundRoutingExtension(bstrExtensionUniqueName);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFaxServerProperties.Create(AServer: TFaxServer);
begin
  inherited Create;
  FServer := AServer;
end;

function TFaxServerProperties.GetDefaultInterface: IFaxServer;
begin
  Result := FServer.DefaultInterface;
end;

function TFaxServerProperties.Get_ServerName: WideString;
begin
    Result := DefaultInterface.ServerName;
end;

function TFaxServerProperties.Get_InboundRouting: IFaxInboundRouting;
begin
    Result := DefaultInterface.InboundRouting;
end;

function TFaxServerProperties.Get_Folders: IFaxFolders;
begin
    Result := DefaultInterface.Folders;
end;

function TFaxServerProperties.Get_LoggingOptions: IFaxLoggingOptions;
begin
    Result := DefaultInterface.LoggingOptions;
end;

function TFaxServerProperties.Get_MajorVersion: Integer;
begin
    Result := DefaultInterface.MajorVersion;
end;

function TFaxServerProperties.Get_MinorVersion: Integer;
begin
    Result := DefaultInterface.MinorVersion;
end;

function TFaxServerProperties.Get_MajorBuild: Integer;
begin
    Result := DefaultInterface.MajorBuild;
end;

function TFaxServerProperties.Get_MinorBuild: Integer;
begin
    Result := DefaultInterface.MinorBuild;
end;

function TFaxServerProperties.Get_Debug: WordBool;
begin
    Result := DefaultInterface.Debug;
end;

function TFaxServerProperties.Get_Activity: IFaxActivity;
begin
    Result := DefaultInterface.Activity;
end;

function TFaxServerProperties.Get_OutboundRouting: IFaxOutboundRouting;
begin
    Result := DefaultInterface.OutboundRouting;
end;

function TFaxServerProperties.Get_ReceiptOptions: IFaxReceiptOptions;
begin
    Result := DefaultInterface.ReceiptOptions;
end;

function TFaxServerProperties.Get_Security: IFaxSecurity;
begin
    Result := DefaultInterface.Security;
end;

function TFaxServerProperties.Get_RegisteredEvents: FAX_SERVER_EVENTS_TYPE_ENUM;
begin
    Result := DefaultInterface.RegisteredEvents;
end;

function TFaxServerProperties.Get_APIVersion: FAX_SERVER_APIVERSION_ENUM;
begin
    Result := DefaultInterface.APIVersion;
end;

{$ENDIF}

class function CoFaxDeviceProviders.Create: IFaxDeviceProviders;
begin
  Result := CreateComObject(CLASS_FaxDeviceProviders) as IFaxDeviceProviders;
end;

class function CoFaxDeviceProviders.CreateRemote(const MachineName: string): IFaxDeviceProviders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxDeviceProviders) as IFaxDeviceProviders;
end;

class function CoFaxDevices.Create: IFaxDevices;
begin
  Result := CreateComObject(CLASS_FaxDevices) as IFaxDevices;
end;

class function CoFaxDevices.CreateRemote(const MachineName: string): IFaxDevices;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxDevices) as IFaxDevices;
end;

class function CoFaxInboundRouting.Create: IFaxInboundRouting;
begin
  Result := CreateComObject(CLASS_FaxInboundRouting) as IFaxInboundRouting;
end;

class function CoFaxInboundRouting.CreateRemote(const MachineName: string): IFaxInboundRouting;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxInboundRouting) as IFaxInboundRouting;
end;

class function CoFaxFolders.Create: IFaxFolders;
begin
  Result := CreateComObject(CLASS_FaxFolders) as IFaxFolders;
end;

class function CoFaxFolders.CreateRemote(const MachineName: string): IFaxFolders;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxFolders) as IFaxFolders;
end;

class function CoFaxLoggingOptions.Create: IFaxLoggingOptions;
begin
  Result := CreateComObject(CLASS_FaxLoggingOptions) as IFaxLoggingOptions;
end;

class function CoFaxLoggingOptions.CreateRemote(const MachineName: string): IFaxLoggingOptions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxLoggingOptions) as IFaxLoggingOptions;
end;

class function CoFaxActivity.Create: IFaxActivity;
begin
  Result := CreateComObject(CLASS_FaxActivity) as IFaxActivity;
end;

class function CoFaxActivity.CreateRemote(const MachineName: string): IFaxActivity;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxActivity) as IFaxActivity;
end;

class function CoFaxOutboundRouting.Create: IFaxOutboundRouting;
begin
  Result := CreateComObject(CLASS_FaxOutboundRouting) as IFaxOutboundRouting;
end;

class function CoFaxOutboundRouting.CreateRemote(const MachineName: string): IFaxOutboundRouting;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutboundRouting) as IFaxOutboundRouting;
end;

class function CoFaxReceiptOptions.Create: IFaxReceiptOptions;
begin
  Result := CreateComObject(CLASS_FaxReceiptOptions) as IFaxReceiptOptions;
end;

class function CoFaxReceiptOptions.CreateRemote(const MachineName: string): IFaxReceiptOptions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxReceiptOptions) as IFaxReceiptOptions;
end;

class function CoFaxSecurity.Create: IFaxSecurity;
begin
  Result := CreateComObject(CLASS_FaxSecurity) as IFaxSecurity;
end;

class function CoFaxSecurity.CreateRemote(const MachineName: string): IFaxSecurity;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxSecurity) as IFaxSecurity;
end;

class function CoFaxDocument.Create: IFaxDocument;
begin
  Result := CreateComObject(CLASS_FaxDocument) as IFaxDocument;
end;

class function CoFaxDocument.CreateRemote(const MachineName: string): IFaxDocument;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxDocument) as IFaxDocument;
end;

procedure TFaxDocument.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0F3F9F91-C838-415E-A4F3-3E828CA445E0}';
    IntfIID:   '{B207A246-09E3-4A4E-A7DC-FEA31D29458F}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFaxDocument.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IFaxDocument;
  end;
end;

procedure TFaxDocument.ConnectTo(svrIntf: IFaxDocument);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TFaxDocument.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TFaxDocument.GetDefaultInterface: IFaxDocument;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TFaxDocument.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFaxDocumentProperties.Create(Self);
{$ENDIF}
end;

destructor TFaxDocument.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFaxDocument.GetServerProperties: TFaxDocumentProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TFaxDocument.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TFaxDocument.Set_Body(const pbstrBody: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := pbstrBody;
end;

function TFaxDocument.Get_Sender: IFaxSender;
begin
    Result := DefaultInterface.Sender;
end;

function TFaxDocument.Get_Recipients: IFaxRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TFaxDocument.Get_CoverPage: WideString;
begin
    Result := DefaultInterface.CoverPage;
end;

procedure TFaxDocument.Set_CoverPage(const pbstrCoverPage: WideString);
  { Warning: The property CoverPage has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.CoverPage := pbstrCoverPage;
end;

function TFaxDocument.Get_Subject: WideString;
begin
    Result := DefaultInterface.Subject;
end;

procedure TFaxDocument.Set_Subject(const pbstrSubject: WideString);
  { Warning: The property Subject has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Subject := pbstrSubject;
end;

function TFaxDocument.Get_Note: WideString;
begin
    Result := DefaultInterface.Note;
end;

procedure TFaxDocument.Set_Note(const pbstrNote: WideString);
  { Warning: The property Note has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Note := pbstrNote;
end;

function TFaxDocument.Get_ScheduleTime: TDateTime;
begin
    Result := DefaultInterface.ScheduleTime;
end;

procedure TFaxDocument.Set_ScheduleTime(pdateScheduleTime: TDateTime);
begin
  DefaultInterface.Set_ScheduleTime(pdateScheduleTime);
end;

function TFaxDocument.Get_ReceiptAddress: WideString;
begin
    Result := DefaultInterface.ReceiptAddress;
end;

procedure TFaxDocument.Set_ReceiptAddress(const pbstrReceiptAddress: WideString);
  { Warning: The property ReceiptAddress has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ReceiptAddress := pbstrReceiptAddress;
end;

function TFaxDocument.Get_DocumentName: WideString;
begin
    Result := DefaultInterface.DocumentName;
end;

procedure TFaxDocument.Set_DocumentName(const pbstrDocumentName: WideString);
  { Warning: The property DocumentName has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.DocumentName := pbstrDocumentName;
end;

function TFaxDocument.Get_CallHandle: Integer;
begin
    Result := DefaultInterface.CallHandle;
end;

procedure TFaxDocument.Set_CallHandle(plCallHandle: Integer);
begin
  DefaultInterface.Set_CallHandle(plCallHandle);
end;

function TFaxDocument.Get_CoverPageType: FAX_COVERPAGE_TYPE_ENUM;
begin
    Result := DefaultInterface.CoverPageType;
end;

procedure TFaxDocument.Set_CoverPageType(pCoverPageType: FAX_COVERPAGE_TYPE_ENUM);
begin
  DefaultInterface.Set_CoverPageType(pCoverPageType);
end;

function TFaxDocument.Get_ScheduleType: FAX_SCHEDULE_TYPE_ENUM;
begin
    Result := DefaultInterface.ScheduleType;
end;

procedure TFaxDocument.Set_ScheduleType(pScheduleType: FAX_SCHEDULE_TYPE_ENUM);
begin
  DefaultInterface.Set_ScheduleType(pScheduleType);
end;

function TFaxDocument.Get_ReceiptType: FAX_RECEIPT_TYPE_ENUM;
begin
    Result := DefaultInterface.ReceiptType;
end;

procedure TFaxDocument.Set_ReceiptType(pReceiptType: FAX_RECEIPT_TYPE_ENUM);
begin
  DefaultInterface.Set_ReceiptType(pReceiptType);
end;

function TFaxDocument.Get_GroupBroadcastReceipts: WordBool;
begin
    Result := DefaultInterface.GroupBroadcastReceipts;
end;

procedure TFaxDocument.Set_GroupBroadcastReceipts(pbUseGrouping: WordBool);
begin
  DefaultInterface.Set_GroupBroadcastReceipts(pbUseGrouping);
end;

function TFaxDocument.Get_Priority: FAX_PRIORITY_TYPE_ENUM;
begin
    Result := DefaultInterface.Priority;
end;

procedure TFaxDocument.Set_Priority(pPriority: FAX_PRIORITY_TYPE_ENUM);
begin
  DefaultInterface.Set_Priority(pPriority);
end;

function TFaxDocument.Get_TapiConnection: IDispatch;
begin
    Result := DefaultInterface.TapiConnection;
end;

procedure TFaxDocument._Set_TapiConnection(const ppTapiConnection: IDispatch);
  { Warning: The property TapiConnection has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.TapiConnection := ppTapiConnection;
end;

function TFaxDocument.Get_AttachFaxToReceipt: WordBool;
begin
    Result := DefaultInterface.AttachFaxToReceipt;
end;

procedure TFaxDocument.Set_AttachFaxToReceipt(pbAttachFax: WordBool);
begin
  DefaultInterface.Set_AttachFaxToReceipt(pbAttachFax);
end;

function TFaxDocument.Submit(const bstrFaxServerName: WideString): OleVariant;
begin
  Result := DefaultInterface.Submit(bstrFaxServerName);
end;

function TFaxDocument.ConnectedSubmit(const pFaxServer: IFaxServer): OleVariant;
begin
  Result := DefaultInterface.ConnectedSubmit(pFaxServer);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFaxDocumentProperties.Create(AServer: TFaxDocument);
begin
  inherited Create;
  FServer := AServer;
end;

function TFaxDocumentProperties.GetDefaultInterface: IFaxDocument;
begin
  Result := FServer.DefaultInterface;
end;

function TFaxDocumentProperties.Get_Body: WideString;
begin
    Result := DefaultInterface.Body;
end;

procedure TFaxDocumentProperties.Set_Body(const pbstrBody: WideString);
  { Warning: The property Body has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Body := pbstrBody;
end;

function TFaxDocumentProperties.Get_Sender: IFaxSender;
begin
    Result := DefaultInterface.Sender;
end;

function TFaxDocumentProperties.Get_Recipients: IFaxRecipients;
begin
    Result := DefaultInterface.Recipients;
end;

function TFaxDocumentProperties.Get_CoverPage: WideString;
begin
    Result := DefaultInterface.CoverPage;
end;

procedure TFaxDocumentProperties.Set_CoverPage(const pbstrCoverPage: WideString);
  { Warning: The property CoverPage has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.CoverPage := pbstrCoverPage;
end;

function TFaxDocumentProperties.Get_Subject: WideString;
begin
    Result := DefaultInterface.Subject;
end;

procedure TFaxDocumentProperties.Set_Subject(const pbstrSubject: WideString);
  { Warning: The property Subject has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Subject := pbstrSubject;
end;

function TFaxDocumentProperties.Get_Note: WideString;
begin
    Result := DefaultInterface.Note;
end;

procedure TFaxDocumentProperties.Set_Note(const pbstrNote: WideString);
  { Warning: The property Note has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.Note := pbstrNote;
end;

function TFaxDocumentProperties.Get_ScheduleTime: TDateTime;
begin
    Result := DefaultInterface.ScheduleTime;
end;

procedure TFaxDocumentProperties.Set_ScheduleTime(pdateScheduleTime: TDateTime);
begin
  DefaultInterface.Set_ScheduleTime(pdateScheduleTime);
end;

function TFaxDocumentProperties.Get_ReceiptAddress: WideString;
begin
    Result := DefaultInterface.ReceiptAddress;
end;

procedure TFaxDocumentProperties.Set_ReceiptAddress(const pbstrReceiptAddress: WideString);
  { Warning: The property ReceiptAddress has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ReceiptAddress := pbstrReceiptAddress;
end;

function TFaxDocumentProperties.Get_DocumentName: WideString;
begin
    Result := DefaultInterface.DocumentName;
end;

procedure TFaxDocumentProperties.Set_DocumentName(const pbstrDocumentName: WideString);
  { Warning: The property DocumentName has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.DocumentName := pbstrDocumentName;
end;

function TFaxDocumentProperties.Get_CallHandle: Integer;
begin
    Result := DefaultInterface.CallHandle;
end;

procedure TFaxDocumentProperties.Set_CallHandle(plCallHandle: Integer);
begin
  DefaultInterface.Set_CallHandle(plCallHandle);
end;

function TFaxDocumentProperties.Get_CoverPageType: FAX_COVERPAGE_TYPE_ENUM;
begin
    Result := DefaultInterface.CoverPageType;
end;

procedure TFaxDocumentProperties.Set_CoverPageType(pCoverPageType: FAX_COVERPAGE_TYPE_ENUM);
begin
  DefaultInterface.Set_CoverPageType(pCoverPageType);
end;

function TFaxDocumentProperties.Get_ScheduleType: FAX_SCHEDULE_TYPE_ENUM;
begin
    Result := DefaultInterface.ScheduleType;
end;

procedure TFaxDocumentProperties.Set_ScheduleType(pScheduleType: FAX_SCHEDULE_TYPE_ENUM);
begin
  DefaultInterface.Set_ScheduleType(pScheduleType);
end;

function TFaxDocumentProperties.Get_ReceiptType: FAX_RECEIPT_TYPE_ENUM;
begin
    Result := DefaultInterface.ReceiptType;
end;

procedure TFaxDocumentProperties.Set_ReceiptType(pReceiptType: FAX_RECEIPT_TYPE_ENUM);
begin
  DefaultInterface.Set_ReceiptType(pReceiptType);
end;

function TFaxDocumentProperties.Get_GroupBroadcastReceipts: WordBool;
begin
    Result := DefaultInterface.GroupBroadcastReceipts;
end;

procedure TFaxDocumentProperties.Set_GroupBroadcastReceipts(pbUseGrouping: WordBool);
begin
  DefaultInterface.Set_GroupBroadcastReceipts(pbUseGrouping);
end;

function TFaxDocumentProperties.Get_Priority: FAX_PRIORITY_TYPE_ENUM;
begin
    Result := DefaultInterface.Priority;
end;

procedure TFaxDocumentProperties.Set_Priority(pPriority: FAX_PRIORITY_TYPE_ENUM);
begin
  DefaultInterface.Set_Priority(pPriority);
end;

function TFaxDocumentProperties.Get_TapiConnection: IDispatch;
begin
    Result := DefaultInterface.TapiConnection;
end;

procedure TFaxDocumentProperties._Set_TapiConnection(const ppTapiConnection: IDispatch);
  { Warning: The property TapiConnection has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.TapiConnection := ppTapiConnection;
end;

function TFaxDocumentProperties.Get_AttachFaxToReceipt: WordBool;
begin
    Result := DefaultInterface.AttachFaxToReceipt;
end;

procedure TFaxDocumentProperties.Set_AttachFaxToReceipt(pbAttachFax: WordBool);
begin
  DefaultInterface.Set_AttachFaxToReceipt(pbAttachFax);
end;

{$ENDIF}

class function CoFaxSender.Create: IFaxSender;
begin
  Result := CreateComObject(CLASS_FaxSender) as IFaxSender;
end;

class function CoFaxSender.CreateRemote(const MachineName: string): IFaxSender;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxSender) as IFaxSender;
end;

class function CoFaxRecipients.Create: IFaxRecipients;
begin
  Result := CreateComObject(CLASS_FaxRecipients) as IFaxRecipients;
end;

class function CoFaxRecipients.CreateRemote(const MachineName: string): IFaxRecipients;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxRecipients) as IFaxRecipients;
end;

class function CoFaxIncomingArchive.Create: IFaxIncomingArchive;
begin
  Result := CreateComObject(CLASS_FaxIncomingArchive) as IFaxIncomingArchive;
end;

class function CoFaxIncomingArchive.CreateRemote(const MachineName: string): IFaxIncomingArchive;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxIncomingArchive) as IFaxIncomingArchive;
end;

class function CoFaxIncomingQueue.Create: IFaxIncomingQueue;
begin
  Result := CreateComObject(CLASS_FaxIncomingQueue) as IFaxIncomingQueue;
end;

class function CoFaxIncomingQueue.CreateRemote(const MachineName: string): IFaxIncomingQueue;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxIncomingQueue) as IFaxIncomingQueue;
end;

class function CoFaxOutgoingArchive.Create: IFaxOutgoingArchive;
begin
  Result := CreateComObject(CLASS_FaxOutgoingArchive) as IFaxOutgoingArchive;
end;

class function CoFaxOutgoingArchive.CreateRemote(const MachineName: string): IFaxOutgoingArchive;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutgoingArchive) as IFaxOutgoingArchive;
end;

class function CoFaxOutgoingQueue.Create: IFaxOutgoingQueue;
begin
  Result := CreateComObject(CLASS_FaxOutgoingQueue) as IFaxOutgoingQueue;
end;

class function CoFaxOutgoingQueue.CreateRemote(const MachineName: string): IFaxOutgoingQueue;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutgoingQueue) as IFaxOutgoingQueue;
end;

class function CoFaxIncomingMessageIterator.Create: IFaxIncomingMessageIterator;
begin
  Result := CreateComObject(CLASS_FaxIncomingMessageIterator) as IFaxIncomingMessageIterator;
end;

class function CoFaxIncomingMessageIterator.CreateRemote(const MachineName: string): IFaxIncomingMessageIterator;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxIncomingMessageIterator) as IFaxIncomingMessageIterator;
end;

class function CoFaxIncomingMessage.Create: IFaxIncomingMessage;
begin
  Result := CreateComObject(CLASS_FaxIncomingMessage) as IFaxIncomingMessage;
end;

class function CoFaxIncomingMessage.CreateRemote(const MachineName: string): IFaxIncomingMessage;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxIncomingMessage) as IFaxIncomingMessage;
end;

class function CoFaxOutgoingJobs.Create: IFaxOutgoingJobs;
begin
  Result := CreateComObject(CLASS_FaxOutgoingJobs) as IFaxOutgoingJobs;
end;

class function CoFaxOutgoingJobs.CreateRemote(const MachineName: string): IFaxOutgoingJobs;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutgoingJobs) as IFaxOutgoingJobs;
end;

class function CoFaxOutgoingJob.Create: IFaxOutgoingJob;
begin
  Result := CreateComObject(CLASS_FaxOutgoingJob) as IFaxOutgoingJob;
end;

class function CoFaxOutgoingJob.CreateRemote(const MachineName: string): IFaxOutgoingJob;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutgoingJob) as IFaxOutgoingJob;
end;

class function CoFaxOutgoingMessageIterator.Create: IFaxOutgoingMessageIterator;
begin
  Result := CreateComObject(CLASS_FaxOutgoingMessageIterator) as IFaxOutgoingMessageIterator;
end;

class function CoFaxOutgoingMessageIterator.CreateRemote(const MachineName: string): IFaxOutgoingMessageIterator;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutgoingMessageIterator) as IFaxOutgoingMessageIterator;
end;

class function CoFaxOutgoingMessage.Create: IFaxOutgoingMessage;
begin
  Result := CreateComObject(CLASS_FaxOutgoingMessage) as IFaxOutgoingMessage;
end;

class function CoFaxOutgoingMessage.CreateRemote(const MachineName: string): IFaxOutgoingMessage;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutgoingMessage) as IFaxOutgoingMessage;
end;

class function CoFaxIncomingJobs.Create: IFaxIncomingJobs;
begin
  Result := CreateComObject(CLASS_FaxIncomingJobs) as IFaxIncomingJobs;
end;

class function CoFaxIncomingJobs.CreateRemote(const MachineName: string): IFaxIncomingJobs;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxIncomingJobs) as IFaxIncomingJobs;
end;

class function CoFaxIncomingJob.Create: IFaxIncomingJob;
begin
  Result := CreateComObject(CLASS_FaxIncomingJob) as IFaxIncomingJob;
end;

class function CoFaxIncomingJob.CreateRemote(const MachineName: string): IFaxIncomingJob;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxIncomingJob) as IFaxIncomingJob;
end;

class function CoFaxDeviceProvider.Create: IFaxDeviceProvider;
begin
  Result := CreateComObject(CLASS_FaxDeviceProvider) as IFaxDeviceProvider;
end;

class function CoFaxDeviceProvider.CreateRemote(const MachineName: string): IFaxDeviceProvider;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxDeviceProvider) as IFaxDeviceProvider;
end;

class function CoFaxDevice.Create: IFaxDevice;
begin
  Result := CreateComObject(CLASS_FaxDevice) as IFaxDevice;
end;

class function CoFaxDevice.CreateRemote(const MachineName: string): IFaxDevice;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxDevice) as IFaxDevice;
end;

class function CoFaxActivityLogging.Create: IFaxActivityLogging;
begin
  Result := CreateComObject(CLASS_FaxActivityLogging) as IFaxActivityLogging;
end;

class function CoFaxActivityLogging.CreateRemote(const MachineName: string): IFaxActivityLogging;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxActivityLogging) as IFaxActivityLogging;
end;

class function CoFaxEventLogging.Create: IFaxEventLogging;
begin
  Result := CreateComObject(CLASS_FaxEventLogging) as IFaxEventLogging;
end;

class function CoFaxEventLogging.CreateRemote(const MachineName: string): IFaxEventLogging;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxEventLogging) as IFaxEventLogging;
end;

class function CoFaxOutboundRoutingGroups.Create: IFaxOutboundRoutingGroups;
begin
  Result := CreateComObject(CLASS_FaxOutboundRoutingGroups) as IFaxOutboundRoutingGroups;
end;

class function CoFaxOutboundRoutingGroups.CreateRemote(const MachineName: string): IFaxOutboundRoutingGroups;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutboundRoutingGroups) as IFaxOutboundRoutingGroups;
end;

class function CoFaxOutboundRoutingGroup.Create: IFaxOutboundRoutingGroup;
begin
  Result := CreateComObject(CLASS_FaxOutboundRoutingGroup) as IFaxOutboundRoutingGroup;
end;

class function CoFaxOutboundRoutingGroup.CreateRemote(const MachineName: string): IFaxOutboundRoutingGroup;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutboundRoutingGroup) as IFaxOutboundRoutingGroup;
end;

class function CoFaxDeviceIds.Create: IFaxDeviceIds;
begin
  Result := CreateComObject(CLASS_FaxDeviceIds) as IFaxDeviceIds;
end;

class function CoFaxDeviceIds.CreateRemote(const MachineName: string): IFaxDeviceIds;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxDeviceIds) as IFaxDeviceIds;
end;

class function CoFaxOutboundRoutingRules.Create: IFaxOutboundRoutingRules;
begin
  Result := CreateComObject(CLASS_FaxOutboundRoutingRules) as IFaxOutboundRoutingRules;
end;

class function CoFaxOutboundRoutingRules.CreateRemote(const MachineName: string): IFaxOutboundRoutingRules;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutboundRoutingRules) as IFaxOutboundRoutingRules;
end;

class function CoFaxOutboundRoutingRule.Create: IFaxOutboundRoutingRule;
begin
  Result := CreateComObject(CLASS_FaxOutboundRoutingRule) as IFaxOutboundRoutingRule;
end;

class function CoFaxOutboundRoutingRule.CreateRemote(const MachineName: string): IFaxOutboundRoutingRule;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxOutboundRoutingRule) as IFaxOutboundRoutingRule;
end;

class function CoFaxInboundRoutingExtensions.Create: IFaxInboundRoutingExtensions;
begin
  Result := CreateComObject(CLASS_FaxInboundRoutingExtensions) as IFaxInboundRoutingExtensions;
end;

class function CoFaxInboundRoutingExtensions.CreateRemote(const MachineName: string): IFaxInboundRoutingExtensions;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxInboundRoutingExtensions) as IFaxInboundRoutingExtensions;
end;

class function CoFaxInboundRoutingExtension.Create: IFaxInboundRoutingExtension;
begin
  Result := CreateComObject(CLASS_FaxInboundRoutingExtension) as IFaxInboundRoutingExtension;
end;

class function CoFaxInboundRoutingExtension.CreateRemote(const MachineName: string): IFaxInboundRoutingExtension;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxInboundRoutingExtension) as IFaxInboundRoutingExtension;
end;

class function CoFaxInboundRoutingMethods.Create: IFaxInboundRoutingMethods;
begin
  Result := CreateComObject(CLASS_FaxInboundRoutingMethods) as IFaxInboundRoutingMethods;
end;

class function CoFaxInboundRoutingMethods.CreateRemote(const MachineName: string): IFaxInboundRoutingMethods;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxInboundRoutingMethods) as IFaxInboundRoutingMethods;
end;

class function CoFaxInboundRoutingMethod.Create: IFaxInboundRoutingMethod;
begin
  Result := CreateComObject(CLASS_FaxInboundRoutingMethod) as IFaxInboundRoutingMethod;
end;

class function CoFaxInboundRoutingMethod.CreateRemote(const MachineName: string): IFaxInboundRoutingMethod;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxInboundRoutingMethod) as IFaxInboundRoutingMethod;
end;

class function CoFaxJobStatus.Create: IFaxJobStatus;
begin
  Result := CreateComObject(CLASS_FaxJobStatus) as IFaxJobStatus;
end;

class function CoFaxJobStatus.CreateRemote(const MachineName: string): IFaxJobStatus;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxJobStatus) as IFaxJobStatus;
end;

class function CoFaxRecipient.Create: IFaxRecipient;
begin
  Result := CreateComObject(CLASS_FaxRecipient) as IFaxRecipient;
end;

class function CoFaxRecipient.CreateRemote(const MachineName: string): IFaxRecipient;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FaxRecipient) as IFaxRecipient;
end;

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TFaxServer, TFaxDocument]);
end;

end.
