unit Unit2;

interface
const
  RFID_103_485_DLL = 'RFID_107_485.dll';

function OpenPort(Prm1: LongWord): LongWord; cdecl; External RFID_103_485_DLL name 'OpenPort';
function ClosePort(Prm1: LongWord): LongWord; cdecl; External RFID_103_485_DLL name 'ClosePort';
function CheckCard(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord): PChar; cdecl; External RFID_103_485_DLL name 'CheckCard';
function CheckReader(Prm1: LongWord; Prm2: LongWord; Prm3: LongWord): Longint; cdecl; External RFID_103_485_DLL name 'CheckReader';
function WriteWorkingType(Prm1: LongWord; Prm2: LongWord; Prm3: string; Prm4: LongWord): Longint; cdecl; External RFID_103_485_DLL name 'WriteWorkingType';
function WriteMessage(Prm1: LongWord; Prm2: LongWord; Prm3: string; Prm4: LongWord): Longint; cdecl; External RFID_103_485_DLL name 'WriteMessage';
function CardAnswer(Prm1: LongWord; Prm2: LongWord; Prm3: string; Prm4: LongWord): Longint; cdecl; External RFID_103_485_DLL name 'CardAnswer';

implementation

end.
