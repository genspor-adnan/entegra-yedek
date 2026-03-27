unit UKurumEslestirmeleri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs,UTablo, DB, ADODB, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGrid, cxTextEdit, cxDBLookupComboBox, cxDropDownEdit,
  cxButtonEdit, Menus, StdCtrls, ExtCtrls, cxContainer, cxMaskEdit,
  cxLookupEdit, cxDBLookupEdit;
  
{$I options.inc}

type
  TkurumEslemeForm = class(TFrame)
    cxGrid1: TcxGrid;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1Level3: TcxGridLevel;
    cxGrid1Level4: TcxGridLevel;
    cxGrid1Level2: TcxGridLevel;
    kdvEslemeView: TcxGridTableView;
    kdvEslemeViewColumn1: TcxGridColumn;
    kdvEslemeViewColumn2: TcxGridColumn;
    cxGrid1Level5: TcxGridLevel;
    hastaEslemeView: TcxGridDBTableView;
    hastaEslemeViewColumn1: TcxGridDBColumn;
    hastaEslemeViewColumn2: TcxGridDBColumn;
    hastaEslemeViewColumn3: TcxGridDBColumn;
    hastaEslemeViewColumn4: TcxGridDBColumn;
    hastaEslemeViewColumn5: TcxGridDBColumn;
    kimlikTable: TADOQuery;
    kimlikTableDataSource: TDataSource;
    ReferansQuery: TADOQuery;
    ReferansQueryDataSource: TDataSource;
    referansEslemeView: TcxGridDBTableView;
    referansEslemeViewColumn1: TcxGridDBColumn;
    referansEslemeViewColumn2: TcxGridDBColumn;
    referansEslemeViewColumn3: TcxGridDBColumn;
    referansEslemeViewColumn4: TcxGridDBColumn;
    hizmetlerQuery: TADOQuery;
    HizmetlerQueryDataSource: TDataSource;
    kurumQuery: TADOQuery;
    kurumQueryDataSource: TDataSource;
    kurumView: TcxGridDBTableView;
    kurumViewColumn1: TcxGridDBColumn;
    kurumViewColumn2: TcxGridDBColumn;
    kurumViewColumn3: TcxGridDBColumn;
    hizmetEslemeView: TcxGridDBTableView;
    hizmetEslemeViewColumn1: TcxGridDBColumn;
    hizmetEslemeViewColumn2: TcxGridDBColumn;
    hizmetEslemeViewColumn3: TcxGridDBColumn;
    hizmetEslemeViewColumn4: TcxGridDBColumn;
    procedure kurumViewColumn2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure hizmetEslemeViewColumn2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure referansEslemeViewColumn3PropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure kdvEslemeViewColumn2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure hastaEslemeViewColumn4PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }

    procedure SaveContentMsg(var Msg: TMessage);message WM_SAVECONTENT;
    procedure ShowOptionMsg(var Msg: TMessage);message WM_SHOWOPTION;
    //--
    procedure LoadTaxAccountMatching;
    procedure SaveTaxAccountMatching;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;

  end;

implementation
uses
  UOpsiyon, cxLookupGrid,UHataDialog,ULksVeriArama, FetaUtil,ECXMLParser;

{$R *.dfm}

{ TkurumEsleme }

procedure FillFromDatabase(cnn: TADOConnection;sql : string;list : TStrings);
var
  temp : TADOQuery;
begin
  temp := _query_exec(cnn,sql,[],[]);
  try
    temp.Open;
    list.Clear;
    while not temp.Eof do
      begin
        list.Add(temp.Fields[0].AsString);
        temp.Next;
      end;
  finally
    temp.Free;
  end;
end;

constructor TkurumEslemeForm.Create(AOwner: TComponent);
begin
  inherited;
  hizmetlerQuery.Open;
  kurumQuery.Open;
  ReferansQuery.Open;
  LoadTaxAccountMatching;

  //kimlikTable.Open;
end;

procedure TkurumEslemeForm.SaveContentMsg(var Msg: TMessage);
begin
  SaveTaxAccountMatching;
end;

const
  customerTable : string = 'LG_%s_CLCARD';
  listQuery : string =
    'SELECT  C.CODE,C.DEFINITION_,' +
    ' muh.CODE AS [MUHCODE] FROM LG_%firmcode%_CLCARD C (NOLOCK) ' +
    ' RIGHT OUTER JOIN LG_%firmcode%_CRDACREF ref (NOLOCK) ON c.LOGICALREF = ref.CARDREF' +
    ' LEFT OUTER JOIN LG_%firmcode%_EMUHACC muh (NOLOCK) ON ref.ACCOUNTREF = muh.LOGICALREF ' +
    ' WHERE (C.ACTIVE = 0) and (C.CARDTYPE = 3) and (ref.TRCODE = 5) ORDER BY C.DEFINITION_';
  listQueryHizmet : string =
    'SELECT  C.CODE,C.DEFINITION_, muh.CODE AS [MUHCODE] FROM LG_%firmcode%_SRVCARD C (NOLOCK) ' +
    'RIGHT OUTER JOIN LG_%firmcode%_CRDACREF ref (NOLOCK) ON c.LOGICALREF = ref.CARDREF LEFT OUTER JOIN ' +
    'LG_%firmcode%_EMUHACC muh (NOLOCK) ON ref.ACCOUNTREF = muh.LOGICALREF  WHERE ' +
    '(C.ACTIVE = 0) and  (C.CARDTYPE=2) and (ref.TRCODE = 4)ORDER BY C.DEFINITION_';
  listQueryKasa  : string =
    'SELECT C.CODE,C.NAME, muh.CODE AS [MUHCODE] FROM LG_%firmcode%_KSCARD C (NOLOCK) ' +
    'RIGHT OUTER JOIN LG_%firmcode%_CRDACREF ref (NOLOCK) ON c.LOGICALREF = ref.CARDREF LEFT OUTER JOIN ' +
    'LG_%firmcode%_EMUHACC muh (NOLOCK) ON ref.ACCOUNTREF = muh.LOGICALREF  WHERE ' +
    '(C.ACTIVE = 0) and (ref.TRCODE = 8)ORDER BY C.NAME';
  listQueryBanka : string = 'SELECT C.CODE,C.DEFINITION_ AS [NAME], muh.CODE AS [MUHCODE] FROM LG_%firmcode%_BANKACC C (NOLOCK) ' +
    'RIGHT OUTER JOIN LG_%firmcode%_CRDACREF ref (NOLOCK) ON c.LOGICALREF = ref.CARDREF LEFT OUTER JOIN ' +
    'LG_%firmcode%_EMUHACC muh (NOLOCK) ON ref.ACCOUNTREF = muh.LOGICALREF  WHERE ' +
    '(C.ACTIVE = 0) and  (C.CARDTYPE=1) and (ref.TRCODE = 6) and (ref.TYP = %ref_type%)ORDER BY C.DEFINITION_';

  taxAccountsQuery = 'SELECT CODE,DEFINITION_ FROM LG_%firmcode%_EMUHACC WHERE (LEVEL_ = 2) and (CODE LIKE ''391.%'')';



procedure TkurumEslemeForm.ShowOptionMsg(var Msg: TMessage);
begin
  //TryToConnectDatabase;
end;

procedure TkurumEslemeForm.kurumViewColumn2PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  firmNo  : integer;
  Result  : TReturnValues;
  recNo   : integer;
  prevData: string;
  ANode   : TXMLItem;
begin
  if (AButtonIndex = 0) then
    begin
      ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
      if (Assigned(ANode)) then begin
        firmNo := StrToIntDef(ANode.Params.Values['firma'],1);
        if (Tablo.TryToConnectDatabase) then
          begin
            try
              recNo := kurumView.DataController.FocusedRecordIndex;
              if (not VarIsNull(kurumView.DataController.GetValue(recNo,1))) then
                prevData := kurumView.DataController.GetValue(recNo,1);
              Result := ShowAraForm(Tablo.lksConnection,
                StringReplace(listQuery,'%firmcode%',
                LeadingZero(firmNo,3),[rfReplaceAll]),prevData);
              if ((Length(Result) > 0) and (Result[0] <> '')) then
                begin
                  kurumQuery.Edit;
                  kurumQuery.FieldByName('CARIKODU').AsString := Result[0];
                  kurumQuery.FieldByName('MUHASEBEKODU').AsString := Result[2];
                  kurumQuery.Post;
                end;
            except
              ShowErrorDialog('Arama iletiþim penceresi açýlýrken hata.',
                'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
                'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
                'kontrol ediniz.','imgError');
            end;
          end
        else
          ShowErrorDialog('Arama iletiþim penceresi veritabaný baðlantýsý '+
            'saðlanamadýðý için açýlamadý.',
            'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
            'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
            'kontrol ediniz.','imgError');
      end;
    end;
end;


procedure TkurumEslemeForm.hizmetEslemeViewColumn2PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  firmNo  : integer;
  Result  : TReturnValues;
  recNo   : integer;
  prevData: string;
  ANode   : TXMLItem;
begin
  if (AButtonIndex = 0) then
    begin
      ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
      if (Assigned(ANode)) then begin
        firmNo := StrToIntDef(ANode.Params.Values['firma'],1);
        if (Tablo.TryToConnectDatabase) then
          begin
            try
              recNo := hizmetEslemeView.DataController.FocusedRecordIndex;
              if (not VarIsNull(hizmetEslemeView.DataController.GetValue(recNo,2))) then
                prevData := hizmetEslemeView.DataController.GetValue(recNo,2);
              Result := ShowAraForm(Tablo.lksConnection,
                StringReplace(listQueryHizmet,'%firmcode%',
                LeadingZero(firmNo,3),[rfReplaceAll]),prevData);
              if ((Length(Result) > 0) and (Result[0] <> '')) then
                begin
                  hizmetlerQuery.Edit;
                  hizmetlerQuery.FieldByName('OZELKOD').AsString := Result[0];
                  hizmetlerQuery.FieldByName('MUHKODU').AsString := Result[2];
                  hizmetlerQuery.Post;
                end;
            except
              ShowErrorDialog('Arama iletiþim penceresi açýlýrken hata.',
                'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
                'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
                'kontrol ediniz.','imgError');
            end;
          end
        else
          ShowErrorDialog('Arama iletiþim penceresi veritabaný baðlantýsý '+
            'saðlanamadýðý için açýlamadý.',
            'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
            'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
            'kontrol ediniz.','imgError');
      end;
    end;
end;

procedure TkurumEslemeForm.referansEslemeViewColumn3PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  firmNo  : integer;
  Result  : TReturnValues;
  recNo   : integer;
  prevData: string;
  ANode   : TXMLItem;
begin
  if (AButtonIndex = 0) then
    begin
      ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
      if (Assigned(ANode)) then begin
        firmNo := StrToIntDef(ANode.Params.Values['firma'],1);
        if (Tablo.TryToConnectDatabase) then
          begin
            try
              recNo := referansEslemeView.DataController.FocusedRecordIndex;
              if (not VarIsNull(referansEslemeView.DataController.GetValue(recNo,2))) then
                prevData := referansEslemeView.DataController.GetValue(recNo,2);
              Result := ShowAraForm(Tablo.lksConnection,
                StringReplace(listQuery,'%firmcode%',
                LeadingZero(firmNo,3),[rfReplaceAll]),prevData);
              if ((Length(Result) > 0) and (Result[0] <> '')) then
                begin
                  ReferansQuery.Edit;
                  ReferansQuery.FieldByName('CARIKODU').AsString := Result[0];
                  ReferansQuery.FieldByName('MUHKODU').AsString := Result[2];
                  ReferansQuery.Post;
                end;
            except
              ShowErrorDialog('Arama iletiþim penceresi açýlýrken hata.',
                'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
                'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
                'kontrol ediniz.','imgError');
            end;
          end
        else
          ShowErrorDialog('Arama iletiþim penceresi veritabaný baðlantýsý '+
            'saðlanamadýðý için açýlamadý.',
            'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
            'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
            'kontrol ediniz.','imgError');
      end;
    end;
end;

procedure TkurumEslemeForm.LoadTaxAccountMatching;
var
  ARoot : TXMLItem;
procedure BuildMatchingNode;
var
  item : TXMLItem;
begin
  ARoot.Clear;
  ARoot.Name := 'KDV_ESLEMELERI';
  item := ARoot.New;
  item.Name := 'KDV_ESLEMESI';
  item.Params.Add('kod=8');
  item.Params.Add('donusmus1=');
  item := ARoot.New;
  item.Name := 'KDV_ESLEMESI';
  item.Params.Add('kod=18');
  item.Params.Add('donusmus1=');
end;

procedure AddToView(AValues: array of string);
var
  i : Integer;
  j : Integer;
begin
  with kdvEslemeView do begin
    j := DataController.AppendRecord;
    for i := Low(AValues) to High(AValues) do begin
      DataController.SetValue(j,i,AValues[i]);
    end;
  end;
end;


procedure LoadNode;
var
  i : Integer;
begin
  for i := 0 to ARoot.Count - 1 do begin
    AddToView([
      ARoot[i].Params.Values['kod'],
      ARoot[i].Params.Values['donusmus1']]);
  end;
end;

begin
  kdvEslemeView.DataController.BeginFullUpdate;
  try
    while kdvEslemeView.DataController.RecordCount > 0 do
      kdvEslemeView.DataController.DeleteRecord(0);
    ARoot := Tablo.GetNode('LKS/ESLEMELER/KDV_ESLEMELERI',Tablo.configuration.Root);
    if (Assigned(ARoot) and (ARoot.Count > 0)) then begin
      LoadNode;
    end else begin
      BuildMatchingNode;
      LoadNode;
    end;
  finally
    kdvEslemeView.DataController.EndFullUpdate;
  end;
end;

procedure TkurumEslemeForm.SaveTaxAccountMatching;
var
  ARoot : TXMLItem;
  ANew  : TXMLItem;
  i     : Integer;
begin
  ARoot := Tablo.GetNode('LKS/ESLEMELER/KDV_ESLEMELERI',Tablo.configuration.Root);
  ARoot.Clear;
  ARoot.Name := 'KDV_ESLEMELERI';
  with kdvEslemeView do begin
    for i := 0 to DataController.RecordCount - 1 do begin
      if DataController.GetValue(i,1) <> '' then begin
        ANew := ARoot.New;
        ANew.Name := 'KDV_ESLEMESI';
        ANew.Params.Add('kod=' + DataController.GetValue(i,0));
        ANew.Params.Add('donusmus1=' + DataController.GetValue(i,1));
      end;
    end;
  end;
end;

procedure TkurumEslemeForm.kdvEslemeViewColumn2PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  firmNo  : integer;
  Result  : TReturnValues;
  recNo   : integer;
  prevData: string;
  ANode   : TXMLItem;
begin
  if (AButtonIndex = 0) then
    begin
      ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
      if (Assigned(ANode)) then begin
        firmNo := StrToIntDef(ANode.Params.Values['firma'],1);
        if (Tablo.TryToConnectDatabase) then
          begin
            try
              recNo := kdvEslemeView.DataController.FocusedRecordIndex;
              if (not VarIsNull(kdvEslemeView.DataController.GetValue(recNo,1))) then
                prevData := kdvEslemeView.DataController.GetValue(recNo,1);
              Result := ShowAraForm(Tablo.lksConnection,
                StringReplace(taxAccountsQuery,'%firmcode%',
                LeadingZero(firmNo,3),[rfReplaceAll]),prevData);
              if ((Length(Result) > 0) and (Result[0] <> '')) then
                begin
                  kdvEslemeView.DataController.SetValue(recNo,1,Result[0]);
                end;
            except
              ShowErrorDialog('Arama iletiþim penceresi açýlýrken hata.',
                'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
                'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
                'kontrol ediniz.','imgError');
            end;
          end
        else
          ShowErrorDialog('Arama iletiþim penceresi veritabaný baðlantýsý '+
            'saðlanamadýðý için açýlamadý.',
            'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
            'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
            'kontrol ediniz.','imgError');
      end;
    end;
end;

procedure TkurumEslemeForm.hastaEslemeViewColumn4PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  firmNo  : integer;
  Result  : TReturnValues;
  prevData: string;
  ANode   : TXMLItem;
begin
  if (AButtonIndex = 0) then begin
    ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
    firmNo := StrToIntDef(ANode.Params.Values['firma'],1);
    if (Tablo.TryToConnectDatabase) then
      begin
        try
          prevData := kimlikTable.FieldByName('CARIKODU').AsString;
          Result := ShowAraForm(Tablo.lksConnection,
            StringReplace(listQuery,'%firmcode%',
            LeadingZero(firmNo,3),[rfReplaceAll]),prevData);
          if ((Length(Result) > 0) and (Result[0] <> '')) then
            begin
              kimlikTable.Edit;
              kimlikTable.FieldByName('CARIKODU').AsString := Result[0];
              kimlikTable.FieldByName('MUHASEBEKODU').AsString := Result[2];   
              kimlikTable.Post;
            end;
        except
          ShowErrorDialog('Arama iletiþim penceresi açýlýrken hata.',
            'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
            'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
            'kontrol ediniz.','imgError');
        end;
      end
    else
      ShowErrorDialog('Arama iletiþim penceresi veritabaný baðlantýsý '+
        'saðlanamadýðý için açýlamadý.',
        'Að baðlantýlarý veya yanlýþ yapýlandýrmadan kaynaklanabilir.',
        'Lütfen Genel/Logo Parametreleri seçeneðinde bulunan ayarlarý '+
        'kontrol ediniz.','imgError');
  end;
end;

initialization
  //RegisterOption(100,'Aktarým/Eþleþtirme',TkurumEslemeForm);

end.
