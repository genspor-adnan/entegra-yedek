unit UMesajGrup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, Data.DB, cxDBData, Vcl.ComCtrls, Vcl.ToolWin, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxLabel, cxTextEdit, cxMaskEdit, cxButtonEdit,
  Vcl.ExtCtrls, FireDAC.Comp.Client, Vcl.StdCtrls, Vcl.Buttons, Vcl.Menus, cxButtons,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  cxCheckBox, cxDBEdit;

type
  TMesajGrupDlg = class(TForm)
    Panel1: TPanel;
    ListeBaslik: TcxButtonEdit;
    cxLabel2: TcxLabel;
    TabKullanici: TFDQuery;
    DtsKullanici: TDataSource;
    PanelAlt: TPanel;
    KaydetTus: TBitBtn;
    CancelBtn: TBitBtn;
    PanelPaylasim: TPanel;
    ToolBar3: TToolBar;
    KulEkleTus: TToolButton;
    KulSilTus: TToolButton;
    GridKullan: TcxGrid;
    GridKullanView: TcxGridDBTableView;
    GridKullanViewKULLANICI: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    PopupMenuPaylasilan: TPopupMenu;
    SubeMenu: TMenuItem;
    DepartmanMenu: TMenuItem;
    GorevMenu: TMenuItem;
    KisiMenu: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure KulSilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure KisiMenuClick(Sender: TObject);
  private
    { Private declarations }
    Procedure ListeKaydet;
  public
    { Public declarations }
    ListeId:Integer;
    IslemOp:Char;
  end;

var
  MesajGrupDlg: TMesajGrupDlg;

implementation

{$R *.dfm}

uses
  UTablo, FetaKurulusSiniflari, PrjConst;

procedure TMesajGrupDlg.CancelBtnClick(Sender: TObject);
begin
   if IslemOp = 'E' then Begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM=99 and DIL='+IntToStr(ListeId),[],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBER where ID='+IntToStr(ListeId),[],[]);
   End;
end;

procedure TMesajGrupDlg.FormShow(Sender: TObject);
begin
  TabloYenile( TabKullanici, [ListeId]);
end;

Procedure TMesajGrupDlg.ListeKaydet;
begin
   Tablo.TablodanSorguAc(1,'select max(ID)+1 from REHBER');
   ListeId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBER(KOD,FIRMA,GRUP,DURUM,EKLEYEN)'+
         ' values('''+Tablo.Query1.Fields[0].AsString+''','''+StringReplace(Trim(ListeBaslik.Text),'''',' ',[rfreplaceall])+''',99,1,'+Kullanan+') select SCOPE_IDENTITY() ',[],[], True);
end;

procedure TMesajGrupDlg.KaydetTusClick(Sender: TObject);
begin
   ListeBaslik.text:=Trim(ListeBaslik.text);
   if ListeBaslik.text='' then begin
      ShowMessage(BaslikAdiniGirin);
      exit;
   end;


   if ListeId = -9999 then //yeni liste
      ListeKaydet
   else
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBER set FIRMA='''+StringReplace(Trim(ListeBaslik.Text),'''',' ',[rfreplaceall])+''''+
        ', DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=GETDATE() where ID='+IntToStr(ListeId),[],[]);
   ModalResult := mrOK;
end;

procedure TMesajGrupDlg.KisiMenuClick(Sender: TObject);
var  Sonuc:TStringList;
     sqltext : string;
     I:Integer;
begin
   if Trim(ListeBaslik.text)='' then
      Showmessage('Liste adı dolu olmalı!')
   else begin
      if ListeId = -9999 then //yeni liste
         ListeKaydet;

      case TMenuItem(Sender).Tag of
       4: sqltext:=' SELECT ID, FIRMA FROM REHBER WHERE ID < 0 order by ID desc';
       3: sqltext:='Select ID=DEGER, Departman=ANAHTAR  from GENINI G where G.BOLUM=-2251 order by 2';
       2: sqltext:='Select ID=DEGER, Görev=ANAHTAR  from GENINI G where G.BOLUM=-2252 order by 2';
       1: sqltext:= 'SELECT R.ID,KULLANICI=R.FIRMA,ROL=(select ROL FROM ROLLER RO WHERE RO.ID=K.ROLID),R.GRUP,R.KATEGORI,R.SINIF '+
                    ' FROM KULLANICI K INNER JOIN REHBER R  ON K.REHBERID=R.ID AND R.DURUM>0 '
      end;

    //              ,[nil,nil,nil,Tablo.RepCariGrup,Tablo.RepCaribolum,Tablo.RepCariSinif],['Id','Kullanıcı','Rol','Grup','Kategori','Sınıf']);
      Sonuc := TStringList.Create;
      Sonuc := Tablo.ListedenCokluSecim(Sube, sqltext,[],[]);
      if Sonuc.Count > 0 then begin
         //önce kendini eklesin
         //bölüm sabit 99;  anahtara grubun adı;  Degere seçilen kişinin rehberid; dile  grubun id (rehber tablosunda grup 99 olarak kayıtlı); sıra ise 1 kişi/2 görev/3 departman/4 şube
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)'+
               ' values(99,'''+ListeBaslik.Text+''','+kullanan+','+IntToStr(ListeId)+','+IntToStr(TMenuItem(Sender).Tag)+')', [],[]);
         //sonra seçtiklerini
         for I := 0 to Sonuc.Count - 1 do
               //AliciEkle(TMenuItem(Sender).Tag, StrToIntDef(Sonuc[I], 0));
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)'+
               ' values(99,'''+ListeBaslik.Text+''','+IntToStr(StrToIntDef(Sonuc[I], 0))+','+IntToStr(ListeId)+','+IntToStr(TMenuItem(Sender).Tag)+')', [],[]);
      end;
      Sonuc.Free;
      Tabloyenile(TabKullanici,[ListeId]);
   end;
end;

procedure TMesajGrupDlg.KulSilTusClick(Sender: TObject);
begin
   if TabKullanici.FieldByName('TUR').AsInteger <> 1 then
      TabKullanici.Delete;
end;

end.



