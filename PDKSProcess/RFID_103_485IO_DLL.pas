unit RFID_103_485IO_DLL;

interface

const
  RFID_103_485IO = 'RFID_103_485IO.dll';

function OSearchPort(Prm1: LongWord): LongWord; cdecl; External RFID_103_485IO name 'SearchPort';
function OCheckPort(Prm1: LongWord): LongWord; cdecl; External RFID_103_485IO name 'CheckPort';
function OSearchReader(Prm1: LongWord; Prm2: LongWord): LongWord; cdecl; External RFID_103_485IO name 'SearchReader';
function OCheckReader(Prm1: LongWord; Prm2: LongWord): LongWord; cdecl; External RFID_103_485IO name 'CheckReader';
function OGetCardID(Prm1: LongWord; Prm2: LongWord): LongWord; cdecl; External RFID_103_485IO name 'GetCardID';
function OClearScreen(Prm1: LongWord; Prm2: LongWord): LongWord; cdecl; External RFID_103_485IO name 'ClearScreen';
function OWriteText(Prm1: LongWord; Prm2: LongWord; Prm3: string): LongWord; cdecl; External RFID_103_485IO name 'WriteText';
function OErrorBeep(Prm1: LongWord; Prm2: LongWord): LongWord; cdecl; External RFID_103_485IO name 'ErrorBeep';
function OShowBitmap(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord): LongWord; cdecl; External RFID_103_485IO name 'ShowBitmap';
function OSetBaudRate(Prm1: LongWord): LongWord; cdecl; External RFID_103_485IO name 'SetBaudRate';
function OGetBaudRate(): LongWord; cdecl; External RFID_103_485IO name 'GetBaudRate';
function OSendMifare(Prm1: LongWord; Prm2: LongWord; Prm3: string): PChar; cdecl; External RFID_103_485IO name 'SendMifare';
function OOpenPort(Prm1: LongWord): LongWord; cdecl; External RFID_103_485IO name 'OpenPort';
function OClosePort(Prm1: LongWord): LongWord; cdecl; External RFID_103_485IO name 'ClosePort';
function ORelay(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord): LongWord; cdecl; External RFID_103_485IO name 'Relay';

function OGetCardIDIO(Prm1: LongWord; Prm2: LongWord): LongWord; cdecl; External RFID_103_485IO name 'GetCardIDIO';

function OLogin(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: string): LongWord; cdecl; External RFID_103_485IO name 'Login';
function OLoginChange(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: string): LongWord; cdecl; External RFID_103_485IO name 'LoginChange';

function ORead(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: LongWord): PChar; cdecl; External RFID_103_485IO name 'Read';
function OWrite(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: LongWord; Prm5: string): LongWord; cdecl; External RFID_103_485IO name 'Write';
//  Function ReadData     (Prm1:LongWord; Prm2:LongWord; Prm3:LongWord; Prm4:LongWord)               :PChar;    cdecl; External RFID_103_485IO name 'ReadData';
//  Function WriteData    (Prm1:LongWord; Prm2:LongWord; Prm3:LongWord; Prm4:LongWord; Prm5:String)  :LongWord; cdecl; External RFID_103_485IO name 'WriteData';
function OReadValue(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: LongWord): PChar; cdecl; External RFID_103_485IO name 'ReadValue';
function OWriteValue(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: LongWord; Prm5: LongWord): LongWord; cdecl; External RFID_103_485IO name 'WriteValue';

function OIncrement(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: LongWord; Prm5: LongWord): LongWord; cdecl; External RFID_103_485IO name 'Increment';
function ODecrement(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord; Prm4: LongWord; Prm5: LongWord): LongWord; cdecl; External RFID_103_485IO name 'Decrement';

function OSendText(Prm1: LongWord; Prm2: LongWord; Prm3: string): LongWord; cdecl; External RFID_103_485IO name 'SendText';

implementation

end.
