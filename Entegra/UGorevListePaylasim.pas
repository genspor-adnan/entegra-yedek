unit UGorevListePaylasim;

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
  cxCheckBox, cxDBEdit, dxDateRanges, dxScrollbarAnnotations;

type
  TGorevListePaylasimDlg = class(TForm)
    Panel1: TPanel;
    ListeBaslik: TcxButtonEdit;
    cxLabel2: TcxLabel;
    TabKullanici: TFDQuery;
    DtsKullanici: TDataSource;
    PanelAlt: TPanel;
    KaydetTus: TBitBtn;
    CancelBtn: TBitBtn;
    CheckHerkeseAcik: TcxCheckBox;
    PanelPaylasim: TPanel;
    ToolBar3: TToolBar;
    KulEkleTus: TToolButton;
    KulSilTus: TToolButton;
    cxLabel4: TcxLabel;
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
    procedure ProjeTusClick(Sender: TObject);
    procedure CheckHerkeseAcikClick(Sender: TObject);
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
  GorevListePaylasimDlg: TGorevListePaylasimDlg;

implementation

{$R *.dfm}

uses
  UTablo, FetaKurulusSiniflari, PrjConst;

procedure TGorevListePaylasimDlg.CancelBtnClick(Sender: TObject);
begin
   if IslemOp = 'E' then Begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GOREVKULLANICI where LISTGOREVID='+IntToStr(ListeId)+' and TUR<=5',[],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GOREVLISTE where ID='+IntToStr(ListeId),[],[]);
   End;
end;

procedure TGorevListePaylasimDlg.CheckHerkeseAcikClick(Sender: TObject);
begin
   PanelPaylasim.visible := not CheckHerkeseAcik.checked;
end;

procedure TGorevListePaylasimDlg.FormShow(Sender: TObject);
begin
  TabloYenile( TabKullanici, [ListeId]);
end;

Procedure TGorevListePaylasimDlg.ListeKaydet;
var UstId:Smallint;
begin
//   if ProjeTus.Tag>0 then
//      UstId:=-3 //Proje klasörünün ID si
//   else
   UstId:=0;
   ListeId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVLISTE]([USTID],[ADI],RESIM,PROJEID,[DURUM],[EKLEYEN], HERKESEACIK)'+
         ' values('+IntToStr(UstId)+','''+StringReplace(Trim(ListeBaslik.Text),'''',' ',[rfreplaceall])+''',0,0,1,'+Kullanan+','+IntToStr(Abs(StrToInt(BoolToStr(CheckHerkeseAcik.checked))))+') select SCOPE_IDENTITY() ',[],[], True);

// gerek kalmadı
//   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
//         ' values('+IntToStr(ListeId)+',1,'+Kullanan+','+Kullanan+')', [], []);
end;

procedure TGorevListePaylasimDlg.ProjeTusClick(Sender: TObject);
//var
//  st: Tstringlist;
//  komut: string;
begin
{st := Tstringlist.create;                     //  ProjeDurum.ANAHTAR PROJE     ProjeTuru.ANAHTAR PROJE  ProjeSonuc.ANAHTAR PROJE ProjeAsama.ANAHTAR PROJE
    komut := ' select ID,PROJEKODU,KONUSU, DURUM,TURU, SONUC,ASAMA FROM PROJELER P where DURUM <> 2 AND ISNULL(KONUSU,'''') like ''%<ara>%'' ';
    if Tablo.ListedenBilgiGetir(ProjeSecimi, komut, st,[nil,nil,Tablo.repProjeDurum,Tablo.repProjeTuru,Tablo.repProjeSonuc,Tablo.repProjeAsama]) then
    begin
       ProjeTus.Tag :=StrToInt( st.Strings[0]);
       ListeBaslik.text := st.Strings[1];

      {if DtsGorev.State = dsBrowse then
        TabGorev.Edit;
      TabGorev.FieldByName('PROJEID').AsString := st.Strings[0];
      BeditProje.Text := st.Strings[1];
      BeditProje.Hint := BeditProje.Text;
    end;
    st.free; }
end;

procedure TGorevListePaylasimDlg.KaydetTusClick(Sender: TObject);
begin
   ListeBaslik.text:=Trim(ListeBaslik.text);
   if ListeBaslik.text='' then begin
      ShowMessage(BaslikAdiniGirin);
      exit;
   end;


   if ListeId = 0 then //yeni liste
      ListeKaydet
   else
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update [GOREVLISTE] set ADI='''+StringReplace(Trim(ListeBaslik.Text),'''',' ',[rfreplaceall])+''''+
        ',HERKESEACIK='+IntToStr(Abs(StrToInt(BoolToStr(CheckHerkeseAcik.checked))))+', DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=GETDATE() where ID='+IntToStr(ListeId),[],[]);
   ModalResult := mrOK;
end;

procedure TGorevListePaylasimDlg.KisiMenuClick(Sender: TObject);
var  Sonuc:TStringList;
     sqltext : string;
     I:Integer;
begin
   if Trim(ListeBaslik.text)='' then
      Showmessage('Liste adı dolu olmalı!')
   else begin
      if ListeId = 0 then //yeni liste
         ListeKaydet;

      case TMenuItem(Sender).Tag of
       4: sqltext:=' SELECT ID, FIRMA FROM REHBER WHERE ID < 0 order by ID desc';
       3: sqltext:='Select ID=DEGER, Departman=ANAHTAR  from GENINI G where G.BOLUM=-2251 order by 2';
       2: sqltext:='Select ID=DEGER, Görev=ANAHTAR  from GENINI G where G.BOLUM=-2252 order by 2';
       1: sqltext:= 'SELECT R.ID,KULLANICI=R.FIRMA,ROL=(select ROL FROM ROLLER RO WHERE RO.ID=K.ROLID),R.GRUP,R.KATEGORI,R.SINIF  FROM KULLANICI K INNER JOIN REHBER R  ON K.REHBERID=R.ID'
      end;

    //              ,[nil,nil,nil,Tablo.RepCariGrup,Tablo.RepCaribolum,Tablo.RepCariSinif],['Id','Kullanıcı','Rol','Grup','Kategori','Sınıf']);
      Sonuc := TStringList.Create;
      Sonuc := Tablo.ListedenCokluSecim(Sube, sqltext,[],[]);
      if Sonuc.Count > 0 then
         for I := 0 to Sonuc.Count - 1 do
               //AliciEkle(TMenuItem(Sender).Tag, StrToIntDef(Sonuc[I], 0));
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
               ' values('+IntToStr(ListeId)+','+IntToStr(TMenuItem(Sender).Tag)+','+IntToStr(StrToIntDef(Sonuc[I], 0))+','+Kullanan+')', [],[]);
      Sonuc.Free;
      Tabloyenile(TabKullanici,[ListeId]);
   end;
{
var
  Kullanicilar:TstringList;
//  Secilmis:string;
  i:integer;
begin
 if Trim(ListeBaslik.text)='' then
     Showmessage('Liste adı dolu olmalı!')
  else begin
      if ListeId = 0 then //yeni liste
         ListeKaydet;
      Kullanicilar := TStringlist.Create;
      Kullanicilar := Tablo.ListedenCokluSecim('',StringReplace(SQLKullan.text,'@@LISTID', IntToStr(ListeId),[]),[nil,nil,nil,nil,nil,nil,nil],
                                                 ['Id','Ad','Görev','Departman','Şube','Kategori','Tür']);
      if Kullanicilar.Count>0 then begin
         for I := 0 to Kullanicilar.Count - 1 do begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
               ' values('+IntToStr(ListeId)+',2,'+copy(Kullanicilar[i],2,8)+','+Kullanan+')', [],[]);
         end;
         Tabloyenile(TabKullanici,[ListeId]);
      end;
      Kullanicilar.Free;
  end;}

end;

procedure TGorevListePaylasimDlg.KulSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
//   if TabKullanici.FieldByName('TUR').AsInteger <> 1 then
      TabKullanici.Delete;
end;

end.



