unit ULKSTransformator;

interface
uses
 UScriptEngine, uPSCompiler,uPSComponent,uPSRuntime,Dialogs,SysUtils, DB, DateUtils;

type
  TLksTransformator = class(TScriptEngine)
  private
  protected
    procedure DoCompileImport; override;
    procedure DoExecuteImport; override;
  public
    procedure Initialize;
    function RunEx(AListTable: TDataSet;Tur:string;MuhAktar:integer): Boolean;
    procedure RunProc(AProcName: string);
    procedure Finalize;
  end;

implementation
uses
  Fetautil,UTablo, UHataKontrol, JclStrings,PrjConst;

{ TLksTransformator }

procedure TLksTransformator.DoCompileImport;
begin
  inherited;
  //Engine.AddRegisteredVariable('Tablo.GENINI','Tablo.GENINI');
  Engine.AddRegisteredVariable('FatbasID','Integer');
  Engine.AddRegisteredVariable('StokID','Integer');
  Engine.AddRegisteredVariable('CariID','Integer');
  Engine.AddRegisteredVariable('SubeID','Integer');
  Engine.AddRegisteredVariable('Dil','Integer');
  Engine.AddRegisteredVariable('BirimSetiKodu','String');
  Engine.AddRegisteredVariable('exportpath','String');
  Engine.AddRegisteredVariable('SUCCESS','Boolean');
  Engine.AddRegisteredVariable('SystemConnection','TADOConnection');
  Engine.AddRegisteredVariable('LKSConnection','TADOConnection');
  Engine.AddRegisteredVariable('configuration','TECXMLParser');
  //tablolar
  Engine.AddRegisteredVariable('FaturaListesi','TADOQuery');
  Engine.AddRegisteredVariable('CariListesi','TADOQuery');
  Engine.AddRegisteredVariable('StokListesi','TADOQuery');
  Engine.AddRegisteredVariable('TahsilatListesi','TADOQuery');
  //procedure ve fonksiyonlar
  Engine.AddMethod(Tablo,@TTablo.GetNode,'function GetNode(APath: string;ARootNode: TXMLItem): TXMLItem;');
  Engine.AddMethod(Tablo,@TTablo.TryToConnectDatabase,'function TryToConnectDatabase: Boolean;');
  Engine.AddFunction(@AddError,'procedure AddError(FatbasID:Integer;FIRMA,FaturaNo: string;' +
    'HataId: Integer;Hata: string;Params: string);');

  Engine.AddFunction(@DeleteFiles,'procedure DeleteFiles(Path: string;Mask: string)');
  Engine.AddFunction(@MonthOf,'function MonthOf(const AValue: TDateTime): Word');
  Engine.AddFunction(@YearOf,'function YearOf(const AValue: TDateTime): Word');
end;

procedure TLksTransformator.DoExecuteImport;
begin
  inherited;
 // Engine.SetVarToInstance('GENINI',Tablo.GENINI);
  Engine.SetVarToInstance('SystemConnection',Tablo.cnn);
  Engine.SetVarToInstance('LKSConnection',Tablo.lksConnection);
  Engine.SetVarToInstance('configuration',Tablo.configuration);
  Engine.SetVarToInstance('FaturaListesi',Tablo.TabFaturaListesi);
  Engine.SetVarToInstance('TahsilatListesi',Tablo.tabTahsilatListesi);
  Engine.SetVarToInstance('CariListesi',Tablo.TabCariler);
  Engine.SetVarToInstance('StokListesi',Tablo.TabStoklar);
end;

procedure TLksTransformator.Finalize;
begin
  DestroyComponents;
end;

procedure TLksTransformator.Initialize;
var
  s: string;
  i: Integer;
begin
  CreateComponents;        
  Engine.Exec.CallCleanup := False;
  if (Length(FSourceCode) = 0) then
      raise Exception.Create('Aktarým için kod bulunamadý!');
  if (not Engine.Compile) then
    begin
      s := '';
      for i := 0 to Engine.CompilerMessageCount - 1 do
        begin
          s := s + Engine.CompilerMessages[i].MessageToString + #13#10;
        end;
      raise Exception.Create('Derleme hatasý'#13#10 + s);
    end;
//  else
//    StringToFile('C:\disss.txt',GetDisassembledCode);
end;


function TLksTransformator.RunEx(AListTable: TDataSet;Tur:string;MuhAktar:integer): Boolean;
var
  p : PIFVariant;
begin
  Result := False;
  case MuhAktar of
    0:begin
      if (Tur='TabSheetSatisBelgeleri') or (Tur='TabSheetAlisBelgeleri') then  begin

        p := Engine.GetVariable('FatbasID');
        if (p <> nil) then PPSVariantS32(p).Data := AListTable.FieldByName('ID').AsInteger;
      end else  if Tur='TabSheetTahsilatlar' then begin


      end  else  if Tur='TabSheetStokListesi' then begin
        p := Engine.GetVariable('StokID');
        if (p <> nil) then PPSVariantS32(p).Data := AListTable.FieldByName('ID').AsInteger;
        p := Engine.GetVariable('BirimSetiKodu');
        if (p <> nil) then PPSVariantUString(p).Data := BirimSetiKodu;
      end else  if Tur='TabSheetCariListesi' then begin
        p := Engine.GetVariable('CariID');
        if (p <> nil) then PPSVariantS32(p).Data := AListTable.FieldByName('ID').AsInteger;
      end;

      p := Engine.GetVariable('Dil');
      if (p <> nil) then PPSVariantS8(p).Data := Dil;
      p := Engine.GetVariable('exportpath');
      if (p <> nil) then PPSVariantUString(p).Data := Tablo.GENINI.ReadString(Ops_G2LKS_LOGOExportPath,'C:\Gen2005\XML');
      p := Engine.GetVariable('SubeID');
      if (p <> nil) then PPSVariantS8(p).Data := SubeId;

      p := Engine.GetVariable('SUCCESS');
      if (p <> nil) then PPSVariantU8(p).Data := 1;

      if (not Engine.Execute) then
        begin
          raise Exception.Create('Kod çalýþtýrýlamadý.'#13#10 +
            'Hata : ' + Engine.ExecErrorToString + #13#10 +
            'Satýr : ' + IntToStr(Engine.ExecErrorRow) + '  Sütun : ' + IntToStr(Engine.ExecErrorCol));
        end;
      p := Engine.GetVariable('SUCCESS');
      if (p <> nil) then
        Result := Boolean(PPSVariantU8(p).Data)
      else
        Result := False;
    end;
    2:begin
       Result := true;;
    end;
  end;
end;

procedure TLksTransformator.RunProc(AProcName: string);
begin
  try
    DoExecuteImport;
    if (Engine.Exec.GetProc(AProcName) <> InvalidVal) then
      Engine.Exec.RunProcPN([],AProcName);
  except
    ShowMessage(Engine.ExecErrorToString + IntToStr(Engine.ExecErrorRow) + '-' + IntToStr(Engine.ExecErrorCol));
  end;
end;

end.
