unit GenoTIP.Ortak.GridPivotUtils;

interface
uses
  SysUtils, Windows, Classes, cxCustomPivotGrid, cxDBPivotGrid, ExcelXP,
  Generics.Collections,
  cxGridExportLink, ComObj, Variants, cxGridTableView, cxGridDBTableView, cxGrid,
  cxEdit,cxCurrencyEdit,FetaClassExtensions,FetaKurulusSiniflari;
  //GenoTIP.Ortak.Extensions, GenoTIP.Ortak.YardSiniflar,
function ExportToExcelPivot(ADosyaAdý: string;AListeGrid: TcxGrid;ATableView:
  TcxGridDBTableView; APivot: TcxCustomPivotGrid): Boolean;

implementation
uses
  ShellApi;//, GenoTIP.Analist.RaporAraclarý;

function ExportToExcelPivot;
var
  app       : OleVariant;
  wb        : OleVariant;
  pc        : OleVariant;
  sh        : OleVariant;
  pt        : OleVariant;
  i         : Integer;
  pf        : TcxDBPivotGridField;
  pff       : OleVariant;
  firstRC   : OleVariant;
  dataRange : string;
  tmp       : string;
  pvfList   : TList<TcxDBPivotGridField>;
  grp       : TGroupBy<TcxPivotGridFieldArea,TcxDBPivotGridField>;
  grpItem   : TGrouping<TcxPivotGridFieldArea,TcxDBPivotGridField>;
  oby       : TOrderBy<Integer,TcxDBPivotGridField>;
  rcCount   : Integer;
  dataCount : Integer;
  tblCol    : TcxGridDBColumn;
  //özTipi    : TPivotKolonÖzellikTipi;
  numFormat : string;
  position  : Integer;
begin
  Result := False;
  // Pivotta görünen fakat Grid de görünmeyen bir kolon olduðunda
  // Excel sorun çýkarmakta bundan dolayý pivotta görünen gridde görünmeyen
  // kolonlarý görünür yapalým
  for i := 0 to APivot.FieldCount - 1 do begin
    pf := TcxDBPivotGridField(APivot.Fields[i]);
    tblCol := ATableView.GetColumnByFieldName(pf.DataBinding.FieldName);
    if Assigned(tblCol) and not tblCol.Visible and pf.Visible then begin
      tblCol.Visible := True;
    end;
  end;
  if ADosyaAdý.EndsWith('.xlsx') then
    ExportGridToXLSX(ADosyaAdý,AListeGrid)
  else
    ExportGridToExcel(ADosyaAdý,AListeGrid);
  if ATableView.DataController.RecordCount = 0 then begin
    Result := True;
    Exit;
  end;
  app := CreateOleObject('Excel.Application');
  pvfList := TList<TcxDBPivotGridField>.Create;
  try
    wb := app.Workbooks.Open(ADosyaAdý);
    sh := wb.Worksheets[1];
    sh.Name := 'DataSheet';
    sh := wb.Sheets.Add;
    sh.Name := 'PivotSheet';
    dataRange := Format('DataSheet!R1C1:R%dC%d',[ATableView.DataController.RecordCount + 1, ATableView.VisibleColumnCount]);
    pc := wb.PivotCaches.Add(xlDatabase, dataRange);
    pt := pc.CreatePivotTable(sh.Name + '!R3C1', 'AnalistPivot',Null, xlPivotTableVersion10);
    sh.Select;
    // görünen alanlarý yeni bir listeye ekle
    // bu listeyi gruplamak ve sýralamak için kullanacaðýz
    for i := 0 to APivot.FieldCount - 1 do begin
      pf := TcxDBPivotGridField(APivot.Fields[i]);
      if pf.Visible then
        pvfList.Add(pf);
    end;
    // gruplama iþi
    grp := TGroupBy<TcxPivotGridFieldArea,TcxDBPivotGridField>.Create(pvfList,
      function(A: TcxDBPivotGridField): TcxPivotGridFieldArea
      begin
        Result := A.Area;
      end
    );
    rcCount := 0;
    dataCount := 0;
    // Amaç: Area alanýna göre gruplayýp ve AreaIndex'e göre sýralayýp
    // Pivot alanlarýný bu þekilde oluþturmak
    for grpItem in grp do begin
      // sýralama iþi
      position := 1;
      oby := TOrderBy<Integer,TcxDBPivotGridField>.Create(grpItem,
        function(A: TcxDBPivotGridField): Integer begin Result := A.AreaIndex; end);

      for pf in oby do begin
        {özTipi := TPivotKolonÖzellikTipi(pf.Tags.ValueAsInteger('Format',0));
        case özTipi of
          pkötYok: numFormat := '';
          pkötPara0: numFormat := '#.##0 ' + FormatSettings.CurrencyString;
          pkötPara2: numFormat := '#.##0,00 ' + FormatSettings.CurrencyString;
          pkötSayý0: numFormat := '#.##0';
          pkötSayý2: numFormat := '#.##0,00';
        end; }
        pff := pt.PivotFields(pf.DataBinding.FieldName);
        case pf.Area of
          faColumn: begin
             pff.Orientation := xlColumnField;
          end;
          faRow: begin
            pff.Orientation := xlRowField;
            if pf.AreaIndex = 0 then
              firstRC := pff;
            Inc(rcCount);
          end;
          faFilter: pff.Orientation := xlPageField;
          faData: begin
            Inc(dataCount);
            pff.Orientation := xlDataField;
            if (numFormat <> '') then
              pff.NumberFormat := numFormat;
            case pf.SummaryType of
              stCount: pff.Function := Integer(xlCount);
              stSum: pff.Function := Integer(xlSum);
              stMin: pff.Function := Integer(xlMin);
              stMax: pff.Function := Integer(xlMax);
              stAverage: pff.Function := Integer(xlAverage);
              stStdDev: pff.Function := Integer(xlStDev);
              stStdDevP: pff.Function := Integer(xlStDevP);
              stVariance: pff.Function := Integer(xlVar);
              stVarianceP: pff.Function := Integer(xlVarP);
            end;
          end;
        end;
        pff.Position := position;
        pff.Caption := ' ' + pf.Caption;
        Inc(position);
      end;
      oby.Free;
    end;
    grp.Free;
    pt.TableStyle2 := 'PivotStyleMedium2';
    if (dataCount > 1) then
      pt.DataPivotField.Orientation := xlColumnField;
    if not VarIsEmpty(firstRC) and (rcCount > 1) then
      firstRC.ShowDetail := false;
    //pt.DataPivotField.Position := 1;
    //pt.HasAutoFormat := False;
    wb.Save;
    Result := True;
  finally
    app.Quit;
    app := Null;
    pvfList.Free;
  end;
end;


end.
