unit UScriptEngine;

interface

uses
  uPSComponent_DB, uPSI_Registry,Controls,Classes,Forms,StdCtrls,
  uPSComponent_StdCtrls, uPSComponent_Default, uPSComponent_Controls,
  uPSComponent, uPSI_ADODBUnit,uPSCompiler,uPSComponent_Forms,
  uPSComponent_COM,uPSI_ECXMLParser,SysUtils,Dialogs, uPSI_ComCtrls_Unit,
  (*uPSI_HKMTab,*)Variants, uPSUtils;



type
  TScriptEngine = class(TObject)
  private
    FOnExecuteImport: TNotifyEvent;
    FOnAfterExecute: TNotifyEvent;
    FOnCompileImport: TNotifyEvent;
    FExtraVariables : TStringList;
    FNeedDataExtraction: Boolean;
    FOnBeforeRun: TNotifyEvent;
    procedure SetSourceCode(const Value: string);
  protected
    FSourceCode : String;
    FTargetForm     : TForm;
    FScriptEngine: TPSScriptDebugger;
    ADODBUnit: TPSImport_ADODBUnit;
    DateUtilsUnit: TPSImport_DateUtils;
    ControlsUnit: TPSImport_Controls;
    ClassesUnit: TPSImport_Classes;
    StdCtrlsUnit: TPSImport_StdCtrls;
    RegistryUnit: TPSImport_Registry;
    DatabaseUnit: TPSImport_DB;
    ComObjUnit: TPSImport_ComObj;
    FormsUnit: TPSImport_Forms;
    ComCtrlsUnit: TPSImport_ComCtrls_Unit;
    XMLParser : TPSImport_ECXMLParser;
    //HKMemTableUnit : TPSImport_HKMTab;
    FControlToStringIgnoreList: TList;
    procedure __CompileImport(Sender: TObject;
      x: TPSPascalCompiler);
    procedure __ExecuteEvent(Sender : TPSScript);
    procedure __AfterExecuteEvent(Sender : TPSScript);
    procedure CreateComponents;
    procedure DestroyComponents;
    procedure DoAfterExecute;virtual;
    procedure DoCompileImport;virtual;
    procedure DoExecuteImport;virtual;
    procedure DoBeforeRun;virtual;
    procedure AddFormComponents(ARoot: TComponent);
    procedure AssignComponentInstances(ARoot: TComponent);
    procedure SetInternalParameter(AParamName: string;AValue: Variant);virtual;
    function GetDisassembledCode: string;
    function ControlToString(AControl: TComponent): string;
  public
    constructor Create(ASourceCode: string);virtual;
    destructor Destroy;override;
    procedure InitializeEngine;
    procedure FinalizeEngine;
    function JustCompile: Boolean;
    procedure Run(ATargetForm: TForm);
    function ProcedureExists(AProcName: string): Boolean;
    function ExecuteSolidFunction(AProcName: string): Variant;
    function GetVariableValue(varName: string): Variant;
    property SourceCode : string read FSourceCode write SetSourceCode;
    property DisassembledCode : string read GetDisassembledCode;
    property Engine : TPSScriptDebugger read FScriptEngine;
    property ExtraVariables : TStringList read FExtraVariables;
    property OnAfterExecute: TNotifyEvent read FOnAfterExecute write FOnAfterExecute;
    property OnCompileImport: TNotifyEvent read FOnCompileImport write FOnCompileImport;
    property OnExecuteImport: TNotifyEvent read FOnExecuteImport write FOnExecuteImport;
    property OnBeforeRun    : TNotifyEvent read FOnBeforeRun write FOnBeforeRun;
  end;


implementation
uses
  UTextTable,ECXMLParser, Fetautil, UHataDialog, UOnayDialog, uPSDisassembly,
  JclStrings, uPSRuntime,UTablo;

var
  RegisteredClasses : TStringList;

{ Custom Functions }
function ConvertToDouble(S: string): Double;
begin
  Result := 0;
  TryStrToFloat(S,Result);
end;

function XmlToTextTable(Root: TXMLItem): string;
var
  Parser : TRTFTextTableProducer;
begin
  Parser := TRTFTextTableProducer.Create;
  try
    Result := Parser.ParseXML(Root);
  finally
    Parser.Free;
  end;
end;

function _StringReplace(ASource,OldStr,NewStr: string): string;
begin
  Result := StringReplace(ASource,OldStr,NewStr,[rfReplaceAll]);
end;

function _FloatToStrF(AValue: Double;Precision,Digits: Integer): string;
begin
  Result := FloatToStrF(AValue,ffNumber,Precision,Digits);
end;


{ TScriptEngine }

procedure TScriptEngine.AddFormComponents(ARoot: TComponent);
var
  i : integer;
begin
  // DevExpress componentleri ortalığı karıştırıyor
  // Bundan dolayıda eğer böyle bir component denk gelirse çıkılıyor
  if Copy(ARoot.ClassName,1,3) = 'Tcx' then Exit;
  if (not ARoot.InheritsFrom(TForm)) then begin
    if RegisteredClasses.IndexOf(ARoot.ClassName) > -1 then
      Engine.AddRegisteredVariable(ARoot.Name,ARoot.ClassName);
  end else Engine.AddRegisteredVariable(ARoot.Name,'TForm');
  for i := 0 to ARoot.ComponentCount - 1 do
    begin
      if (ARoot.Components[i].ComponentCount > 0) then
        AddFormComponents(ARoot.Components[i])
      else
        begin

          if (ARoot.Components[i] is TControl) then
            begin
              if (RegisteredClasses.IndexOf(ARoot.Components[i].ClassName) = -1) then begin
                if (ARoot.Components[i].InheritsFrom(TWinControl)) then
                  Engine.AddRegisteredVariable(ARoot.Components[i].Name,'TWinControl')
                else
                  if (ARoot.Components[i].InheritsFrom(TControl)) then
                    Engine.AddRegisteredVariable(ARoot.Components[i].Name,'TControl');
              end else Engine.AddRegisteredVariable(ARoot.Components[i].Name,ARoot.Components[i].ClassName);
            end;
        end;
    end;
end;

procedure TScriptEngine.AssignComponentInstances(ARoot: TComponent);
var
  i : integer;
begin
  if Engine.GetVariable(ARoot.Name) <> nil then
    Engine.SetVarToInstance(ARoot.Name,ARoot);
  for i := 0 to ARoot.ComponentCount - 1 do
    begin
      if (ARoot.Components[i].ComponentCount > 0) then
        AssignComponentInstances(ARoot.Components[i])
      else
        begin
          if (ARoot.Components[i] is TControl) then
            begin
              if (Engine.GetVariable(ARoot.Components[i].Name) <> nil) then
//              if RegisteredClasses.IndexOf(ARoot.Components[i].ClassName) > -1 then
                Engine.SetVarToInstance(ARoot.Components[i].Name,ARoot.Components[i]);
            end;
        end;
    end;
end;

constructor TScriptEngine.Create(ASourceCode: string);
begin
  FSourceCode := ASourceCode;
  FExtraVariables := TStringList.Create;
  FNeedDataExtraction := False;
  FControlToStringIgnoreList := TList.Create;
end;

//function OnCompilerBeforeCleanup(
//  Sender: TPSPascalCompiler): Boolean;
//
//  function ParamDeclToString(P: TPSParametersDecl): string;
//  var
//    i : Integer;
//  begin
//    Result := '(';
//    for i := 0 to P.ParamCount - 1 do begin
//      Result := Result + P.Params[i].OrgName + ':' + P.Params[i].aType.OriginalName +';';
//    end;
//    if Length(Result) > 1 then Delete(Result,Length(Result),1);
//    Result := Result + ')'
//  end;
//
//var
//  s: string;
//  i: Integer;
//  j: Integer;
//  t : TPSType;
//  bt: TPSType;
//  cl : TPSClassType;
//  ci : TPSDelphiClassItem;
//begin
//  s := '';
//  for i := 0 to Sender.GetTypeCount - 1 do begin
//    t := Sender.GetType(i);
//    if (t.BaseType = btClass) then begin
//      if TPSClassType(t).Cl.ClassInheritsFrom <> nil then
//        s := s + TPSClassType(t).Cl.aType.OriginalName + ' = class(' + TPSClassType(t).Cl.ClassInheritsFrom.aType.OriginalName + ')'#13#10'public'#13#10
//      else
//        s := s + TPSClassType(t).Cl.aType.OriginalName + ' = class'#13#10'public'#13#10;
//      for j := 0 to TPSClassType(t).Cl.Count - 1 do begin
//        ci := TPSClassType(t).Cl.Items[j];
//        if ci is TPSDelphiClassItemProperty then begin
//          s := s + '  property ' + TPSDelphiClassItemProperty(ci).OrgName + ':' +
//            TPSDelphiClassItemProperty(ci).Decl.Result.OriginalName+#13#10;
//        end else if ci is TPSDelphiClassItemConstructor then begin
//          s := s + '  constructor Create' +
//            ParamDeclToString(TPSDelphiClassItemConstructor(ci).Decl)+#13#10;
//        end else if ci is TPSDelphiClassItemMethod then begin
//          if TPSDelphiClassItemMethod(ci).Decl.Result <> nil then
//            s := s + '  function ' + TPSDelphiClassItemMethod(ci).OrgName +
//              ParamDeclToString(TPSDelphiClassItemMethod(ci).Decl) + ':' +
//                TPSDelphiClassItemMethod(ci).Decl.Result.OriginalName + ';'#13#10
//          else
//            s := s + '  procedure ' + TPSDelphiClassItemMethod(ci).OrgName +
//              ParamDeclToString(TPSDelphiClassItemMethod(ci).Decl) +';'#13#10;
//        end;
//      end;
//      s := s + 'end;'#13#10#13#10;
//    end;
//  end;
//  StringToFile('c:\export_class.txt',s);
//end;

procedure TScriptEngine.CreateComponents;
begin
   //FScriptEngine
  FScriptEngine := TPSScriptDebugger.Create(nil);

  //ADODBUnit
  ADODBUnit := TPSImport_ADODBUnit.Create(nil);

  //DateUtilsUnit
  DateUtilsUnit := TPSImport_DateUtils.Create(nil);

  //ControlsUnit
  ControlsUnit := TPSImport_Controls.Create(nil);

  //ClassesUnit
  ClassesUnit := TPSImport_Classes.Create(nil);

  //StdCtrlsUnit
  StdCtrlsUnit := TPSImport_StdCtrls.Create(nil);

  //RegistryUnit
  RegistryUnit := TPSImport_Registry.Create(nil);

  //DatabaseUnit
  DatabaseUnit := TPSImport_DB.Create(nil);

  //ComObjUnit
  ComObjUnit := TPSImport_ComObj.Create(nil);

  //FormsUnit
  FormsUnit := TPSImport_Forms.Create(nil);

  //XmlParser

  XMLParser := TPSImport_ECXMLParser.Create(nil);

  // ComCtrlsUnit

  ComCtrlsUnit := TPSImport_ComCtrls_Unit.Create(nil);

  // HKMemTableUnit
  //HKMemTableUnit := TPSImport_HKMTab.Create(nil);
  
  //ComObjUnit
  ComObjUnit.Name := 'ComObjUnit';

  //FormsUnit
  FormsUnit.Name := 'FormsUnit';
  FormsUnit.EnableForms := True;
  FormsUnit.EnableMenus := True;

  //FScriptEngine
  FScriptEngine.Name := 'FScriptEngine';
  FScriptEngine.CompilerOptions := [];
  FScriptEngine.OnCompImport := __CompileImport;
  FScriptEngine.OnExecute := __ExecuteEvent;
  FScriptEngine.OnAfterExecute := __AfterExecuteEvent;
  FScriptEngine.Script.Text := FSourceCode;
  FScriptEngine.Exec.CallCleanup := False;
  //FScriptEngine.Comp.OnBeforeCleanup := OnCompilerBeforeCleanup;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := ClassesUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := ControlsUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := StdCtrlsUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := DateUtilsUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := DatabaseUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := ADODBUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := RegistryUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := FormsUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := ComObjUnit;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := XMLParser;
  end;

  with TpsPluginItem(FScriptEngine.Plugins.Add) do
  begin
    Plugin := ComCtrlsUnit;
  end;

//  with TpsPluginItem(FScriptEngine.Plugins.Add) do
//  begin
//    Plugin := HKMemTableUnit;
//  end;

  //ADODBUnit
  ADODBUnit.Name := 'ADODBUnit';

  //DateUtilsUnit
  DateUtilsUnit.Name := 'DateUtilsUnit';

  //ControlsUnit
  ControlsUnit.Name := 'ControlsUnit';
  ControlsUnit.EnableStreams := True;
  ControlsUnit.EnableGraphics := True;
  ControlsUnit.EnableControls := True;

  //ClassesUnit
  ClassesUnit.Name := 'ClassesUnit';
  ClassesUnit.EnableStreams := True;
  ClassesUnit.EnableClasses := True;

  //StdCtrlsUnit
  StdCtrlsUnit.Name := 'StdCtrlsUnit';
  StdCtrlsUnit.EnableExtCtrls := True;
  StdCtrlsUnit.EnableButtons := True;

  //RegistryUnit
  RegistryUnit.Name := 'RegistryUnit';

  //DatabaseUnit
  DatabaseUnit.Name := 'DatabaseUnit';

  //XMLParser
  XMLParser.Name := 'XMLParser';
end;

destructor TScriptEngine.Destroy;
begin
  FExtraVariables.Free;
  FControlToStringIgnoreList.Free;
  inherited;
end;

procedure TScriptEngine.DestroyComponents;
begin
  FScriptEngine.Free;
  ADODBUnit.Free;
  DateUtilsUnit.Free;
  ControlsUnit.Free;
  ClassesUnit.Free;
  StdCtrlsUnit.Free;
  RegistryUnit.Free;
  DatabaseUnit.Free;
  ComObjUnit.Free;
  FormsUnit.Free;
  XMLParser.Free;
  ComCtrlsUnit.Free;
  //HKMemTableUnit.Free;
end;


procedure TScriptEngine.DoAfterExecute;
begin
  if (Assigned(FOnAfterExecute)) then
    FOnAfterExecute(Self);
end;

procedure TScriptEngine.DoCompileImport;
var
  i : Integer;
  s : string;
  varType :String;
begin
  Engine.AddFunction(@ConvertToDouble,'function ConvertToDouble(S: string): Double;');
  Engine.AddFunction(@XmlToTextTable,'function XmlToTextTable(Root: TXMLItem): string;');
  Engine.AddFunction(@_StringReplace,'function StringReplace(ASource,OldStr,NewStr: string): string;');
  Engine.AddFunction(@_FloatToStrF,'function FloatToStrF(AValue: Double;Precision,Digits: Integer): string;');
  Engine.AddMethod(FTargetForm,@TForm.ShowModal,'function ShowModal: Integer;');
  Engine.AddMethod(Self,@TScriptEngine.ControlToString,'function ControlToString(AControl: TComponent): string;');
  Engine.AddMethod(Self,@TScriptEngine.SetInternalParameter,'procedure SetInternalParameter(AParamName: string;AValue: Variant);');
  Engine.AddFunction(@GetDelimitedString,'function GetDelimitedString(var s : string): string;');
  Engine.AddFunction(@DateTimeToStr,'function DateTimeToStr(const DateTime: TDateTime): string;');
  Engine.AddFunction(@StrToIntDef,'function StrToIntDef(const S: string; Default: Integer): Integer;');
  Engine.AddFunction(@StrToBoolDef,'function StrToBoolDef(const S: string; const Default: Boolean): Boolean;');
  Engine.AddFunction(@LeadingZero,'function LeadingZero(value: Integer;lz: byte): string;');
//  Engine.AddFunction(@Date,'function Date: TDateTime;');
//  Engine.AddFunction(@Time,'function Time: TDateTime;');
//  Engine.AddFunction(@Now,'function Now: TDateTime;');

  Engine.AddFunction(@GetDelimitedStringEx,'function GetDelimitedStringEx(var s : string;delimiter : string): string;');
  Engine.AddFunction(@IIf,'function IIf(condition: Boolean;IfTrue: string;IfFalse: string): string;');
//  Engine.AddFunction(@FormatDateTime,'function FormatDateTime(const Format: string; DateTime: TDateTime): string;');
  Engine.AddFunction(@_query_exec,'function query_exec(cnn : TADOConnection;sql: string;paramNames : '+
    'array of string;params:array of variant;UseDataSource: TDataSource) : TADOQuery;');
  Engine.AddFunction(@ShowErrorDialog,'procedure ShowErrorDialog(description,causes,resolution: string);');
  Engine.AddFunction(@ShowConfirmDialog,'function ShowConfirmDialog(description: string;'+
    'buttons : array of string;enableInterval: Integer): Integer;');
  Engine.AddRegisteredVariable('Mouse','TMouse');

  for i := 0 to FExtraVariables.Count - 1 do begin
    s := FExtraVariables.ValueFromIndex[i];
    if Pos('~',s) > 0 then
      varType := Copy(s,1,Pos('~',s) - 1)
    else
      varType := s;
    Engine.AddRegisteredVariable(FExtraVariables.Names[i],varType);
  end;
  if (Assigned(FOnCompileImport)) then
    FOnCompileImport(Self);
  if Assigned(FTargetForm) then
    AddFormComponents(FTargetForm);
  //DoPostCompile;
end;

procedure TScriptEngine.DoExecuteImport;
var
  i : Integer;
  p : PIFVariant;
  s : string;
  varType: string;
begin
  Engine.SetVarToInstance('Mouse',Mouse); 
  if (Assigned(FOnExecuteImport)) then
    FOnExecuteImport(Self);
  for i := 0 to FExtraVariables.Count - 1 do begin
    if Assigned(FExtraVariables.Objects[i]) then
      Engine.SetVarToInstance(FExtraVariables.Names[i],FExtraVariables.Objects[i])
    else
      begin
        s := FExtraVariables.ValueFromIndex[i];
        if Pos('~',s) > 0 then begin
          varType := UpperCase(Copy(s,1,Pos('~',s) - 1));
          Delete(s,1,Pos('~',s));
          case CaseOf(varType,['STRING','INTEGER','BOOLEAN']) of
            0: begin
              p := Engine.GetVariable(FExtraVariables.Names[i]);
              if (p <> nil) then PPSVariantAString(p).Data := s;
            end;
            1: begin
              p := Engine.GetVariable(FExtraVariables.Names[i]);
              if (p <> nil) then PPSVariantS32(p).Data := StrToInt(s);
            end;
            2: begin
              p := Engine.GetVariable(FExtraVariables.Names[i]);
              if (p <> nil) then PPSVariantU8(p).Data := StrToInt(s);
            end;
          end;
        end;
      end;
  end;
  if Assigned(FTargetForm) then
    AssignComponentInstances(FTargetForm);
end;

function TScriptEngine.ExecuteSolidFunction(AProcName: string): Variant;
begin
  Result := NULL;
  if ProcedureExists(AProcName) then
    Result := Engine.Exec.RunProcPN([],AProcName);
end;

function TScriptEngine.GetDisassembledCode: string;
var
  s : AnsiString;
begin
  Engine.Comp.GetOutput(s);
  IFPS3DataToText(s,Result);
end;

function TScriptEngine.ProcedureExists(AProcName: string): Boolean;
begin
  Result := Engine.Exec.GetProc(AProcName) <> InvalidVal;
end;

procedure TScriptEngine.Run(ATargetForm: TForm);
var
  s: string;
  i: Integer;
  j: Integer;
  p : PIFVariant;
 // P: TPSTypeRec;
  t : TPSType;
  bt: TPSType;
  cl : TPSClassType;
  ci : TPSDelphiClassItem;
begin
  FTargetForm := ATargetForm;
  DoBeforeRun;
  CreateComponents;
  try
    if (Length(FSourceCode) = 0) then
      SourceCode := 'begin ShowModal; end.';
    if (Engine.Compile) then
      begin 
//        StringToFile('C:\disss.txt',GetDisassembledCode);
        if (not Engine.Execute) then begin
            MessageDlg('Kod çalıştırılamadı.'#13#10 +
              'Hata : ' + Engine.ExecErrorToString + #13#10 +
              'Satır : ' + IntToStr(Engine.ExecErrorRow) +
              '  Sütun : ' + IntToStr(Engine.ExecErrorCol),mtError,[mbOK],0);
        end;
      end
    else
      begin
        s := '';
        for i := 0 to Engine.CompilerMessageCount - 1 do
          begin
            s := s + Engine.CompilerMessages[i].MessageToString + #13#10;
          end;
        MessageDlg('Derleme hatası'#13#10 + s,mtError,[mbOK],0);
      end;
  finally
    DestroyComponents;
  end;
end;

procedure TScriptEngine.SetSourceCode(const Value: string);
begin
  FSourceCode := Value;
end;

procedure TScriptEngine.__AfterExecuteEvent(Sender: TPSScript);
begin
  DoAfterExecute;
end;

procedure TScriptEngine.__CompileImport(Sender: TObject;
  x: TPSPascalCompiler);
begin
  DoCompileImport;
end;

procedure TScriptEngine.__ExecuteEvent(Sender: TPSScript);
begin
  DoExecuteImport;
end;

function TScriptEngine.ControlToString(AControl: TComponent): string;

  function ParseHint(s: string): string;
  begin
    //Öykü : @  #
    Result := Trim(Copy(s, 3, Pos('@', s) - 3));
  end;

  function GetTitle: string;
  begin
    Result := '';
    if AControl is TControl then
      Result := ' ' + TurkishUppercaseString(ParseHint(
        StringReplace(TControl(AControl).Hint,':','',[rfReplaceAll]))) + ' => ';
  end;

var
  i : Integer;
begin
  Result := '';
  if FControlToStringIgnoreList.IndexOf(AControl) > -1 then Exit; 
  if AControl is TGroupBox then
    Result := Result + TGroupBox(AControl).Caption + ':{ '
  else if (AControl is TEdit) and (TEdit(AControl).Text <> '') then
    Result := Result + GetTitle + TEdit(AControl).Text + ' '
  else if AControl is TComboBox and (TComboBox(AControl).Text <> '') then
    Result := Result + GetTitle + TComboBox(AControl).Text + ' '
  else if AControl is TMemo and (TMemo(AControl).Lines.Text <> '') then
    Result := Result + GetTitle + TMemo(AControl).Lines.Text + ' '
  else if (AControl is TCheckBox) and (TCheckBox(AControl).Checked) then
    Result := Result + TurkishUppercaseString(TCheckBox(AControl).Caption) + ' => ' + IIf(TCheckBox(AControl).Checked,'Evet ','Hayır ')
  else if (AControl is TRadioButton) then
    Result := Result + IIf(TRadioButton(AControl).Checked,TurkishUppercaseString(TRadioButton(AControl).Caption) + ' => ','') + ' ';
  if AControl is TWinControl then
    for i := 0 to TWinControl(AControl).ControlCount - 1 do
      Result := Result + ControlToString(TWinControl(AControl).Controls[i]);
  if AControl is TGroupBox then
    if Result = TGroupBox(AControl).Caption + ':{ ' then
      Result := ''
    else
      Result := '/' + Result + '} ';
end;

procedure TScriptEngine.SetInternalParameter(AParamName: string;
  AValue: Variant);
begin

end;

function TScriptEngine.GetVariableValue(varName: string): Variant;
var
  P: PIFVariant;
begin
  p := Engine.GetVariable(varName);
  if (p <> nil) then
    PIFVariantToVariant(p,Result)
  else
    Result := '';
end;

procedure TScriptEngine.FinalizeEngine;
begin
  DestroyComponents;
end;

procedure TScriptEngine.InitializeEngine;
begin
  CreateComponents;
end;

function TScriptEngine.JustCompile: Boolean;
begin
  if Engine.Compile then begin
    DoExecuteImport;
    Result := True;
  end else Result := False;
end;

procedure TScriptEngine.DoBeforeRun;
begin
  if (Assigned(FOnBeforeRun)) then
    FOnBeforeRun(Self);
end;

initialization
  RegisteredClasses := TStringList.Create;
  with RegisteredClasses do begin
    Add('TLabel');
    Add('TEdit');
    Add('TMemo');
    Add('TCheckBox');
    Add('TRadioButton');
    Add('TComboBox');
    Add('TGroupBox');
    Add('TBitBtn');
    Add('TScrollBox');
    Add('TSpeedButton');
  end;
finalization
  RegisteredClasses.Free;
end.


