unit uOrtakLog;

interface
uses
  System.Classes, System.IOUtils, System.SysUtils, System.Variants;
type

  TLogMethod = procedure (_Message : string; _Provider : string = 'SOCIAL_META') of object;

  {$IFDEF WIN64}
    UINT = System.UInt64;
  {$ELSE}
    UINT = System.UInt32;
  {$ENDIF}


function IsEmptyVar(V : Variant) : Boolean;
function VarToInt(V:Variant) : Integer;
function VartoUInt(V:Variant) : UINT;
function VarToString(V : Variant):String;
function VarToBool(V : Variant):Boolean;
function VarNor(V : Variant):Variant;
function VarToBool_Nor(V : Variant; _default : boolean = False) : boolean;
function VarToInt_Nor(V : Variant; _default : integer = 0) : Integer;
function VarToUInt32_Nor(V : Variant; _default : integer = 0) : UInt32;
function VarToByte_Nor(V : Variant) : byte;
function VarToStr_Nor(V : Variant) : String;

implementation

function IsEmptyVar(V : Variant) : Boolean;
begin
  Result:=False;
  If VarIsNull(V) or
   VarIsEmpty(V) or
    (VarToStr(V)='') or
    VarIsClear(V) then
    Result:=True;
end;

function VarToInt(V : Variant):Integer;
begin
  if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) or (VarToStr(V)='') then
    Result :=0
  else
  Result := StrToIntDef(Trim(VarToStr(V)), 0);
end;

function VarToUInt(V:Variant) : UINT;
begin
  if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) or (VarToStr(V)='') then
    Result :=0
  else
  Result :=  StrToUIntDef(Trim(VarToStr(V)), 0);
end;

function VarToString(V : Variant):String;
begin
  //if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) then
  if IsEmptyVar(V) then
    Result :=''
  else
  Result:=V;
end;

function VarToBool(V : Variant):Boolean;
begin
  //if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) or (VarToStr(V)='') then
  if IsEmptyVar(V) then
    Result := False
  else
  Result:=V;
end;

function VarNor(V : Variant):Variant;
begin
   if VarIsNull(V) then
   Result:='' else
   Result:=V;
end;

function VarToBool_Nor(V : Variant; _default : boolean = False) : boolean;
begin
   if (IsEmptyVar(V) ) then
   Result := _default else
   Result := V;
end;

function VarToInt_Nor(V : Variant; _default : integer = 0) : Integer;
begin
   //if (VarIsNull(V) or VarIsEmpty(V)) then
   if (IsEmptyVar(V) ) then
   Result := _default else
   Result := V;
end;

function VarToUInt32_Nor(V : Variant; _default : integer = 0) : UInt32;
begin
   //if (VarIsNull(V) or VarIsEmpty(V)) then
   if (IsEmptyVar(V) ) then
   Result := _default else
   Result := V;
end;

function VarToByte_Nor(V : Variant) : byte;
begin
   if (VarIsNull(V) or VarIsEmpty(V)) then
   Result := 0 else
   Result := V;
end;

function VarToStr_Nor(V : Variant) : String;
begin
   if (VarIsNull(V) or VarIsEmpty(V)) then
   Result:='' else
   Result:=V;
end;


end.
