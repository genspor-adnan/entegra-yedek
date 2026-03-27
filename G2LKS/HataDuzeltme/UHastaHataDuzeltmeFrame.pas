unit UHastaHataDuzeltmeFrame;

interface



uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel, StdCtrls,
  DBCtrls, Mask, DB, ADODB, Buttons, DBNavToolBtn, UTablo;

{$I options.inc}

type
  THastaHataDuzeltmeFrame = class(TFrame)
    JvPanel1: TJvPanel;
    hataStaticText: TStaticText;
    Bevel1: TBevel;
    kodDBText: TDBText;
    HastaTableDataSource: TDataSource;
    HastaTable: TADOQuery;
    karsiKodDBEdit: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    karsiMuhasebeKodDBEdit: TDBEdit;
    araButton: TSpeedButton;
    DBNavToolBtn1: TDBNavToolBtn;
    DBNavToolBtn2: TDBNavToolBtn;
    procedure araButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure ShowSolution(var Msg: TMessage);message WM_SHOWSOLUTION;
  public
    { Public declarations }
  end;

implementation
uses
  UHataKontrol, UHataDialog, ECXMLParser, ULksVeriArama, FetaUtil;

{$R *.dfm}

{ TReferansHataDuzeltmeFrame }

procedure THastaHataDuzeltmeFrame.ShowSolution(var Msg: TMessage);
begin
  hataStaticText.Caption := HataKontrolForm.Hata;
  HastaTable.Close;
  HastaTable.Parameters[0].Value := HataKontrolForm.Params;
  HastaTable.Open;
end;

const
  listQuery : string =
    'SELECT  C.CODE,C.DEFINITION_,' +
    ' muh.CODE AS [MUHCODE] FROM LG_%firmcode%_CLCARD C (NOLOCK) ' +
    ' RIGHT OUTER JOIN LG_%firmcode%_CRDACREF ref (NOLOCK) ON c.LOGICALREF = ref.CARDREF' +
    ' LEFT OUTER JOIN LG_%firmcode%_EMUHACC muh (NOLOCK) ON ref.ACCOUNTREF = muh.LOGICALREF ' +
    ' WHERE (C.ACTIVE = 0) and (C.CARDTYPE = 3) and (ref.TRCODE = 5) ORDER BY C.DEFINITION_';

procedure THastaHataDuzeltmeFrame.araButtonClick(Sender: TObject);
var
  firmNo  : integer;
  Result  : TReturnValues;
  ANode   : TXMLItem;
begin
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
  if (Assigned(ANode)) then begin
    firmNo := StrToIntDef(ANode.Params.Values['firma'],1);
    if (Tablo.TryToConnectDatabase) then
      begin
        try
          Result := ShowAraForm(Tablo.lksConnection,
            StringReplace(listQuery,'%firmcode%',LeadingZero(firmNo,3),[rfReplaceAll]),
            HastaTable.FieldByName('CARIKODU').AsString);
          if ((Length(Result) > 0) and (Result[0] <> '')) then
            begin
              HastaTable.Edit;
              HastaTable.FieldByName('CARIKODU').AsString := Result[0];
              HastaTable.FieldByName('MUHASEBEKODU').AsString := Result[2];
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
  TSolutionFrameRegistration.RegisterSolutionFrame(THastaHataDuzeltmeFrame,300);
end.
