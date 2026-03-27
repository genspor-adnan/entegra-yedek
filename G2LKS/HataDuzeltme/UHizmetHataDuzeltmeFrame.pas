unit UHizmetHataDuzeltmeFrame;

interface



uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel, StdCtrls,
  DBCtrls, Mask, DB, ADODB, Buttons, DBNavToolBtn, UTablo;

{$I options.inc}

type
  THizmetHataDuzeltmeFrame = class(TFrame)
    JvPanel1: TJvPanel;
    hataStaticText: TStaticText;
    Bevel1: TBevel;
    kodDBText: TDBText;
    HizmetTableDataSource: TDataSource;
    HizmetTable: TADOQuery;
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

procedure THizmetHataDuzeltmeFrame.ShowSolution(var Msg: TMessage);
begin
  hataStaticText.Caption := HataKontrolForm.Hata;
  HizmetTable.Close;
  HizmetTable.Parameters[0].Value := HataKontrolForm.Params;
  HizmetTable.Open;
end;

const
  listQueryHizmet : string =
    'SELECT  C.CODE,C.DEFINITION_, muh.CODE AS [MUHCODE] FROM LG_%firmcode%_SRVCARD C (NOLOCK) ' +
    'RIGHT OUTER JOIN LG_%firmcode%_CRDACREF ref (NOLOCK) ON c.LOGICALREF = ref.CARDREF LEFT OUTER JOIN ' +
    'LG_%firmcode%_EMUHACC muh (NOLOCK) ON ref.ACCOUNTREF = muh.LOGICALREF  WHERE ' +
    '(C.ACTIVE = 0) and  (C.CARDTYPE=2) and (ref.TRCODE = 4)ORDER BY C.DEFINITION_';

procedure THizmetHataDuzeltmeFrame.araButtonClick(Sender: TObject);
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
            StringReplace(listQueryHizmet,'%firmcode%',LeadingZero(firmNo,3),[rfReplaceAll]),
            HizmetTable.FieldByName('OZELKOD').AsString);
          if ((Length(Result) > 0) and (Result[0] <> '')) then
            begin
              HizmetTable.Edit;
              HizmetTable.FieldByName('OZELKOD').AsString := Result[0];
              HizmetTable.FieldByName('MUHKODU').AsString := Result[2];
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
  TSolutionFrameRegistration.RegisterSolutionFrame(THizmetHataDuzeltmeFrame,2010);
end.
