unit UTanim;

interface

   // ///******************************************************************/
   // ///*                            Constant                            */
   // ///******************************************************************/
   // ////=============== Protocol Type ===============//
     Const
     PROTOCOL_TCPIP  = 0;                // TCP/IP
     PROTOCOL_UDP  = 1;                  // UDP
   // ////////////////////Lisans Numarasý ////////////////////7
     LISANS_NUMARASI = 1263;
   ////////////////////////////////////////////////////////7///
   // ////=============== Backup Number Constant ===============//
     BACKUP_FP_0  = 0 ;                  // Finger 0
     BACKUP_FP_1  = 1 ;                  // Finger 1
     BACKUP_FP_2  = 2 ;                  // Finger 2
     BACKUP_FP_3  = 3 ;                  // Finger 3
     BACKUP_FP_4  = 4 ;                  // Finger 4
     BACKUP_FP_5  = 5 ;                  // Finger 5
     BACKUP_FP_6  = 6 ;                  // Finger 6
     BACKUP_FP_7  = 7 ;                  // Finger 7
     BACKUP_FP_8  = 8 ;                  // Finger 8
     BACKUP_FP_9  = 9 ;                  // Finger 9
     BACKUP_PSW  = 10 ;                  // Password
     BACKUP_CARD  = 11 ;                 // Card

    ////=============== Manipulation of SuperLogData ===============//
     LOG_ENROLL_USER  = 3      ;         // Enroll-User
     LOG_ENROLL_MANAGER  = 4   ;         // Enroll-Manager
     LOG_ENROLL_DELFP  = 5     ;         // FP Delete
     LOG_ENROLL_DELPASS  = 6   ;         // Pass Delete
     LOG_ENROLL_DELCARD  = 7   ;         // Card Delete
     LOG_LOG_ALLDEL  = 8       ;         // LogAll Delete
     LOG_SETUP_SYS  = 9        ;         // Setup Sys
     LOG_SETUP_TIME  = 10      ;         // Setup Time
     LOG_SETUP_LOG  = 11       ;         // Setup Log
     LOG_SETUP_COMM  = 12      ;         // Setup Comm
     LOG_PASSTIME  = 13        ;         // Pass Time Set
     LOG_SETUP_DOOR  = 14      ;         // Door Set Log

    ////=============== VerifyMode of GeneralLogData ===============//
     LOG_FPVERIFY = 1          ;       // Fp Verify
     LOG_PASSVERIFY = 2        ;       // Pass Verify
     LOG_CARDVERIFY = 3        ;       // Card Verify
     LOG_FPPASS_VERIFY = 4     ;       // Pass+Fp Verify
     LOG_FPCARD_VERIFY = 5     ;       // Card+Fp Verify
     LOG_PASSFP_VERIFY = 6     ;       // Pass+Fp Verify
     LOG_CARDFP_VERIFY = 7     ;       // Card+Fp Verify
     LOG_JOB_NO_VERIFY = 8     ;       // Job number Verify
     LOG_CARDPASS_VERIFY = 9   ;       // Card+Pass Verify
     LOG_CLOSE_DOOR = 10       ;       // Door Close
     LOG_OPEN_HAND = 11        ;       // Hand Open
     LOG_PROG_OPEN = 12        ;       // Open by PC
     LOG_PROG_CLOSE = 13       ;       // Close by PC
     LOG_OPEN_IREGAL = 14      ;       // Iregal Open
     LOG_CLOSE_IREGAL = 15     ;       // Iregal Close
     LOG_OPEN_COVER = 16       ;       // Cover Open
     LOG_CLOSE_COVER = 17      ;       // Cover Close
     LOG_OPEN_DOOR = 32        ;       // Door Open
     LOG_OPEN_THREAT = 48      ;       // Door Open as threat

    ////=============== IOMode of GeneralLogData ===============//
     LOG_IOMODE_IN  = 0         ;
     LOG_IOMODE_OUT  = 1        ;
     LOG_IOMODE_OVER_IN  = 2    ;// = LOG_IOMODE_IO
     LOG_IOMODE_OVER_OUT  = 3   ;

    ////=============== Machine Privilege ===============//
     MP_NONE  = 0               ;       // General user
     MP_ALL  = 1                ;        // Manager

    ////=============== Index of  GetDeviceStatus ===============//
     GET_MANAGERS  = 1          ;
     GET_USERS  = 2             ;
     GET_FPS  = 3               ;
     GET_PSWS  = 4              ;
     GET_SLOGS  = 5             ;
     GET_GLOGS  = 6             ;
     GET_ASLOGS  = 7            ;
     GET_AGLOGS  = 8            ;
     GET_CARDS  = 9             ;

    ////=============== Index of  GetDeviceInfo ===============//
     DI_MANAGERS  = 1           ;        // Numbers of Manager
     DI_MACHINENUM  = 2         ;        // Device ID
     DI_LANGAUGE  = 3           ;        // Language
     DI_POWEROFF_TIME  = 4      ;        // Auto-PowerOff Time
     DI_LOCK_CTRL  = 5          ;        // Lock Control
     DI_GLOG_WARNING  = 6       ;        // General-Log Warning
     DI_SLOG_WARNING  = 7       ;        // Super-Log Warning
     DI_VERIFY_INTERVALS  = 8   ;        // Verify Interval Time
     DI_RSCOM_BPS  = 9          ;        // Comm Buadrate
     DI_DATE_SEPARATE  = 10     ;        // Date Separate Symbol
     DI_VERIFY_KIND  = 24       ;        // Verify Kind Symbol

    ////=============== Baudrate = value of DI_RSCOM_BPS ===============//
     BPS_9600  = 3              ;
     BPS_19200  = 4             ;
     BPS_38400  = 5             ;
     BPS_57600  = 6             ;
     BPS_115200  = 7            ;

    ////=============== Product Data Index ===============//
     PRODUCT_SERIALNUMBER  = 1  ;   // Serial Number
     PRODUCT_BACKUPNUMBER  = 2  ;   // Backup Number
     PRODUCT_CODE  = 3          ;   // Product code
     PRODUCT_NAME  = 4          ;   // Product name
     PRODUCT_WEB  = 5           ;   // Product web
     PRODUCT_DATE  = 6          ;   // Product date
     PRODUCT_SENDTO  = 7        ;   // Product sendto

    ////=============== Door Status ===============//
     DOOR_CONROLRESET  = 0      ;
     DOOR_OPEND  = 1            ;
     DOOR_CLOSED  = 2           ;
     DOOR_COMMNAD  = 3          ;

    ////=============== Error code ===============//
     RUN_SUCCESS  = 1           ;
     RUNERR_NOSUPPORT  = 0      ;
     RUNERR_UNKNOWNERROR  = -1  ;
     RUNERR_NO_OPEN_COMM  = -2  ;
     RUNERR_WRITE_FAIL  = -3    ;
     RUNERR_READ_FAIL  = -4     ;
     RUNERR_INVALID_PARAM  = -5 ;
     RUNERR_NON_CARRYOUT  = -6  ;
     RUNERR_DATAARRAY_END  = -7 ;
     RUNERR_DATAARRAY_NONE  = -8;
     RUNERR_MEMORY  = -9        ;
     RUNERR_MIS_PASSWORD  = -10 ;
     RUNERR_MEMORYOVER  = -11   ;
     RUNERR_DATADOUBLE  = -12   ;
     RUNERR_MANAGEROVER  = -14  ;
     RUNERR_FPDATAVERSION  = -15;


function ReturnResultPrint(ResultCode : Integer):string;
function VerifyModeResultPrint( ResultCode: Integer):string;
function IOModeResultPrint( ResultCode: Integer):string;

implementation
function ReturnResultPrint( ResultCode: Integer):string;
begin

 case ResultCode of
    RUN_SUCCESS : Result := 'Baþarýlý';
    RUNERR_NOSUPPORT : Result := 'Herhangi bir veri yok.';
    RUNERR_UNKNOWNERROR : Result := 'Bilinmeyen hata.';
    RUNERR_NO_OPEN_COMM : Result := 'Com açýlamadý.';
    RUNERR_WRITE_FAIL : Result := 'Yazma hatasý.';
    RUNERR_READ_FAIL : Result := 'Okuma hatasý.';
    RUNERR_INVALID_PARAM : Result := 'Parametre hatasý.';
    RUNERR_NON_CARRYOUT : Result := 'Komut yürütme iþlemi baþarýsýz oldu.';
    RUNERR_DATAARRAY_END : Result := 'Veri sonu.';
    RUNERR_DATAARRAY_NONE : Result := 'Veri yok.';
    RUNERR_MEMORY : Result := 'Bellek ayrýlmasý hatasý.';
    RUNERR_MIS_PASSWORD : Result := 'Lisans hatasý.';
    RUNERR_MEMORYOVER : Result := 'Veri taþma hatasý(Hafýza dolu).';
    RUNERR_DATADOUBLE : Result := 'Bu kimlik zaten var.';
    RUNERR_MANAGEROVER : Result := 'Veri taþma hatasý(Yönetici dolu).';
    RUNERR_FPDATAVERSION : Result := 'Versiyon hatasý.';
 else Result := 'Bilinmeyen hata.';
 end;
end;
function VerifyModeResultPrint( ResultCode: Integer):string;
begin
 case ResultCode of
     LOG_FPVERIFY : Result :=         ' Fp Verify           ';
     LOG_PASSVERIFY : Result :=       ' Pass Verify         ';
     LOG_CARDVERIFY : Result :=       ' Card Verify         ';
     LOG_FPPASS_VERIFY : Result :=    ' Pass+Fp Verify      ';
     LOG_FPCARD_VERIFY : Result :=    ' Card+Fp Verify      ';
     LOG_PASSFP_VERIFY : Result :=    ' Pass+Fp Verify      ';
     LOG_CARDFP_VERIFY : Result :=    ' Card+Fp Verify      ';
     LOG_JOB_NO_VERIFY : Result :=    ' Job number Verify   ';
     LOG_CARDPASS_VERIFY : Result :=  ' Card+Pass Verify    ';
     LOG_CLOSE_DOOR : Result :=       ' Door Close          ';
     LOG_OPEN_HAND : Result :=        ' Hand Open           ';
     LOG_PROG_OPEN : Result :=        ' Open by PC          ';
     LOG_PROG_CLOSE : Result :=       ' Close by PC         ';
     LOG_OPEN_IREGAL : Result :=      ' Iregal Open         ';
     LOG_CLOSE_IREGAL : Result :=     ' Iregal Close        ';
     LOG_OPEN_COVER : Result :=       ' Cover Open          ';
     LOG_CLOSE_COVER : Result :=      ' Cover Close         ';
     LOG_OPEN_DOOR : Result :=        ' Door Open           ';
     LOG_OPEN_THREAT : Result :=      ' Door Open as threat ';
 else Result := 'Bilinmeyen doðrulama modu.';
 end;
end;
function IOModeResultPrint( ResultCode: Integer):string;
begin
 case ResultCode of
     LOG_IOMODE_IN : Result :=           ' In   ';
     LOG_IOMODE_OUT : Result :=          ' Out  ';
     LOG_IOMODE_OVER_IN : Result :=      ' Over In';
     LOG_IOMODE_OVER_OUT : Result :=     ' Over Out';
 else Result := 'Bilinmeyen doðrulama modu.';
 end;
end;



begin


end.
