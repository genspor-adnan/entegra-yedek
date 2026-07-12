unit UDemirbasTamirServis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics, Buttons, DB, FireDAC.Comp.Client,
  cxCurrencyEdit, cxDBEdit, cxLabel, cxButtonEdit, cxDropDownEdit,
  cxImageComboBox, cxMemo, cxControls, cxContainer, cxEdit, cxTextEdit, UTablo,
  cxMaskEdit, cxCalendar, StdCtrls, DBCtrls, ExtCtrls, ComCtrls, ToolWin, Menus, frxClass, frxDBSet,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine,
  dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TDemirbasTamirServisDLG = class(TForm, IPopupDialog)
    DtsServis: TDataSource;
    TabServis: TFDQuery;
    Panel1: TPanel;
    DBText1: TDBText;
    GbServisiadeAl: TGroupBox;
    Label20: TcxLabel;
    Label21: TcxLabel;
    Label16: TcxLabel;
    Label18: TcxLabel;
    dateDonusTarihi: TcxDBDateEdit;
    cbTeslimAlanPersonel: TcxButtonEdit;
    memoOnarimNotu: TcxDBMemo;
    editMaliyet: TcxDBCurrencyEdit;
    GbServiseGonder: TGroupBox;
    Label5: TcxLabel;
    Label13: TcxLabel;
    Label14: TcxLabel;
    LabelGonderilenFirma: TcxLabel;
    Label17: TcxLabel;
    LabeFirmaPersoneli: TcxLabel;
    dateServisTarih: TcxDBDateEdit;
    memoServiseGonderimNedeni: TcxDBMemo;
    editServisFormNo: TcxDBTextEdit;
    cbServiseGonderen: TcxButtonEdit;
    cbGonderilenFirma: TcxButtonEdit;
    cbFirmaPersoneli: TcxButtonEdit;
    ToolBar3: TToolBar;
    btnKaydet: TToolButton;
    ToolButton1: TToolButton;
    btnkapat: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    frxReport1: TfrxReport;
    frxTamirServis: TfrxDBDataset;
    cbKUR: TcxDBComboBox;
    SQLGenelServis: TcxMemo;
    EditProblem: TcxButtonEdit;
    cxLabel1: TcxLabel;
    TabGenel: TFDQuery;
    DtsGenel: TDataSource;
    procedure FormShow(Sender: TObject);
    procedure cbServiseGonderenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cbGonderilenFirmaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cbGeriAlanPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabServisNewRecord(DataSet: TDataSet);
    procedure cbTeslimAlanPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cbKabulEdenPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ServisQueryCek(ServisID, Durum, Demirbas_ID: integer);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnkapatClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
    procedure LabeFirmaPersoneliClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabGenelAfterOpen(DataSet: TDataSet);
    procedure DtsServisStateChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    SQLMemo: string;
    procedure IlgiliEkleClick(Sender: TObject);

  public
    { Public declarations }
    IslemOp: char;
    ServisOp: char;
    Degistir: Boolean;
    DemirbasID: Integer;
    ServisID, TeknikKabulSor, TeknikSerSor: integer;
    Serino, ServisFormNo: string;
  end;

var
  DemirbasTamirServisDLG: TDemirbasTamirServisDLG;

implementation

uses
  UCombo, UDemirbasWizard,UGenelAnaSekmeFrame,URaporAraclari, UServisListeDlg,UAnaform,
  UFastRap,PRJConst,FetaKurulusSiniflari,FetaClassExtensions,LocOnFly,UVeriMotor;
{$R *.dfm}

procedure TDemirbasTamirServisDLG.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
{  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);}
end;

procedure TDemirbasTamirServisDLG.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
begin
{   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxTamirServis);}
end;

function TDemirbasTamirServisDLG.EkranAdiAl: string;
begin
  Result := 'DemirbasTamirServisDlg_'+ServisOp;
end;

procedure TDemirbasTamirServisDLG.btnkapatClick(Sender: TObject);
begin
   if TabServis.State in [dsInsert, dsEdit] then begin
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : btnKaydet.Click;
       IDNO  : if IslemOp='E' then begin
                  TabServis.Cancel;
                  TabGenel.Cancel;
                  Tablo.ServisSil(TabServis.Fields[0].AsInteger);
               end;
       else abort;
      end;
   end;
   ModalResult := mrCancel;
end;

procedure TDemirbasTamirServisDLG.btnKaydetClick(Sender: TObject);
var
  SonDurum: integer;
begin
  if TabServis.State in [dsInsert, dsEdit] then
     TabServis.post;
  if TabGenel.State in [dsInsert, dsEdit] then
     TabGenel.post;
  case ServisOp of
    'G': //gönder
      begin
        //if not BoslukKontrol(cbServisDurum.text, 'Durum') then
        //  Abort;
        if not BoslukKontrol(dateServisTarih.text, 'Tarih') then
            Abort;
        if not BoslukKontrol(cbServiseGonderen.text, 'Gönderen') then
            Abort;
        if (cbGonderilenFirma.visible)and( not BoslukKontrol(cbGonderilenFirma.text, 'Gönderilen Firma')) then
            Abort;
        if (EditProblem.visible)and( not BoslukKontrol(EditProblem.text, 'Problem')) then
            Abort;


        //if cbTeslimAlanPersonel.text <> '' then
        //  TabServis.FieldByName('DURUM').AsInteger := 7;

        //if (TabServis.Active) and (TabServis.State in [dsInsert, dsEdit]) then
        //  TabServis.post;
                               {
        Tablo.Query1.Close;
        Tablo.Query1.SQL.text := 'Update DEMIRBAS set DURUM=:A0 Where ID=:A1';
        Tablo.Query1.Params[0].Value := 6;
        Tablo.Query1.Params[1].Value := DemirbasID;
        Tablo.Query1.ExecSQL; }
      end;
    'I':  //iade
      begin
        if not BoslukKontrol(cbTeslimAlanPersonel.text, 'Teslim Alan') then
          Abort;
        if not BoslukKontrol(dateDonusTarihi.text, 'Teslim Alma Tarihi') then
          Abort;
        if ServisKapsami = 1 then begin// demirbaşa servis ise
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS set SERVISDURUM=0 where ID=&id ', ['&id'], [DemirbasId]);
           //TODO demirbaştan servis durumu değiştirme
           //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SERVIS set DURUM='+Tablo.GENINI.ReadString(Ops_OpsiyonServis_Varsayilan_Durum_Son,'-1')+' where ID=&id ', ['&id'], [TabServis.FieldByName('ID').AsString]);
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update SERVIS set ACKAPA=1 where ID=&id ', ['&id'], [TabServis.FieldByName('ID').AsString]);
        end;


        //if (TabServis.Active) and (TabServis.State in [dsInsert, dsEdit]) then
        //  TabServis.post;
        {
          Tablo.Query6.Close;
          Tablo.Query6.SQL.Text:= 'Select ID,DURUM FROM DEMIRBAS WHERE ID = '+TabServis.FieldByName('DEMIRBASID').AsString+' ';
          Tablo.Query6.open;
          }
        (*Tablo.Query3.Close;
        Tablo.Query3.SQL.text := ' SELECT  TOP (1) DTD.TUTANAKID, DTD.DEMIRBASID, DT.TIP, DT.TARIH, DT.ZIMMETVERENID, '+
        ' DT.ZIMMETALANID, DT.LOKASYONID,DT.DEGISTIREN ' +
        ' FROM DEMIRBAS_TUTANAK_DETAY AS DTD INNER JOIN  DEMIRBAS_TUTANAK AS DT ON DTD.TUTANAKID = DT.ID ' +
        ' WHERE (DTD.DEMIRBASID =:A0) ORDER BY DTD.TUTANAKID DESC';
        Tablo.Query3.Params[0].Value := TabServis.FieldByName('DEMIRBASID').AsInteger;
        Tablo.Query3.Open;
        if Tablo.Query3.IsEmpty then
          SonDurum := 4
        else
        Begin
          if Tablo.Query3.FieldByName('TIP').AsInteger = 5 then
            SonDurum := 1
          else
            SonDurum := Tablo.Query3.FieldByName('TIP').AsInteger;
        End;

        { if Tablo.Query3.FieldByName('TIP').AsInteger=4 then SonDurum:=0
          else SonDurum:=1;
          }

        Tablo.Query1.Close;
        Tablo.Query1.SQL.text := 'Update DEMIRBAS set DURUM=:A0 Where ID=:A1';
        Tablo.Query1.Params[0].Value := SonDurum;
        Tablo.Query1.Params[1].Value := DemirbasID;
        Tablo.Query1.ExecSQL;    *)
      end;
  end;
  ModalResult := mrOk;
end;

procedure TDemirbasTamirServisDLG.cbGeriAlanPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then
  begin
    TabServis.Edit;
    TabServis.FieldByName('TESLIM_ALAN').AsInteger := ID;
    cbTeslimAlanPersonel.text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
  end;
end;

procedure TDemirbasTamirServisDLG.cbGonderilenFirmaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(-1);
  if ID > 0 then
  begin
    TabServis.Edit;
    TabServis.FieldByName('GONDERILENFIRMA').AsInteger := ID;
    cbGonderilenFirma.text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
//    Tablo.Query1.Close;
//    Tablo.Query1.SQL.text := ' select ID from REHBERPERSONEL where REHBERID = ' + IntToStr(ID);
//    Tablo.Query1.Open;
   // TabServis.FieldByName('FIRMAPERSONELI').AsInteger := Tablo.Query1.FieldByName('ID').AsInteger;
   // cbKabulEdenPersonel.text := Tablo.AciklamaGetir('REHBERPERSONEL', 'ADSOYAD', Tablo.Query1.FieldByName('ID').AsInteger);

  end;
end;

procedure TDemirbasTamirServisDLG.cbKabulEdenPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st:Tstringlist;
begin
  try//rehberpersonelden aranacak
    st := Tstringlist.create;
    //IlgiliEkleClick
    if Tablo.ListedenBilgiGetir(MusteriilgiliSec,'select ID, ADSOYAD from REHBERPERSONEL where REHBERID='+TabServis.FieldByName('GONDERILENFIRMA').AsString+' and ADSOYAD like''%<ara>%''  order by 2 ',st,[],'',TNotifyEvent(nil),Tablo.FDCnn,IlgiliEkleClick) then begin
      TabServis.Edit;
      TabServis.FieldByName('FIRMAPERSONELI').AsString := st.Strings[0];
      CbFirmaPersoneli.text := st.Strings[1];
      TabServis.Post;
    end;
  finally
    st.free;
  end;

end;


procedure TDemirbasTamirServisDLG.IlgiliEkleClick(Sender: TObject);
var ID : Integer;
begin
  ID := Tablo.RehberSihirbazBaslat(4,TabServis.FieldByName('GONDERILENFIRMA').AsInteger,-1,-1,False);
  if ID>0 then begin
    TabServis.Edit;
    TabServis.FieldByName('FIRMAPERSONELI').Value := ID;
    CbFirmaPersoneli.Text := Tablo.AciklamaGetir('REHBERPERSONEL','ADSOYAD',ID);
    TabServis.Post;
  end;
end;

procedure TDemirbasTamirServisDLG.cbServiseGonderenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then
  begin
    TabServis.Edit;
    TabServis.FieldByName('MUS_ILGILI').AsInteger := ID;
    cbServiseGonderen.text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
  end;
end;

procedure TDemirbasTamirServisDLG.cbTeslimAlanPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then
  begin
    TabServis.Edit;
    TabServis.FieldByName('TESLIM_ALAN').AsInteger := ID;
    cbTeslimAlanPersonel.text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
  end;
end;

procedure TDemirbasTamirServisDLG.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
//  if TabServis.State in[dsEdit,dsInsert] then
//     TabServis.Post;
  Tablo.ServisBilgiyeEkle(TabGenel, TabServis.Fields[0].AsInteger, 210, True);
  TabloYenile(TabGenel,[TabServis.Fields[0].AsInteger])
end;

procedure TDemirbasTamirServisDLG.DtsServisStateChange(Sender: TObject);
begin
   btnKaydet.Visible := (DtsServis.State in [dsEdit,dsInsert])or(DtsGenel.State in [dsEdit,dsInsert]);
   //btnSil1.Visible   := (IslemOp='D')and((DtsServis.State in [dsEdit,dsInsert])or(DtsGenel.State in [dsEdit,dsInsert]));
end;

procedure TDemirbasTamirServisDLG.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if btnKaydet.Visible then begin
      if Application.MessageBox(PChar(DDKaydedilsinmi),PChar(Uyari), MB_YESNO) = IDYES then
          btnKaydet.Click
      else begin
          if IslemOp='E' then begin
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISBILGI where SERVISID=&id ', ['&id'], [TabServis.FieldByName('ID').AsInteger]);
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISHIZMET where SERVISID=&id ', ['&id'], [TabServis.FieldByName('ID').AsInteger]);
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVIS where ID=&id ', ['&id'], [TabServis.FieldByName('ID').AsInteger]);
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS set SERVISDURUM=0 where ID=&id ', ['&id'], [DemirbasId]);
          end;
          ModalResult := mrOk;
      end;
   end;


(*  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDNO then begin
    Abort;
  end else   begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DEMIRBAS_SERVIS where ID=&id ', ['&id'], [TabServis.FieldByName('ID').AsInteger]);

    Tablo.Query3.Close;
    Tablo.Query3.SQL.text := ' SELECT  TOP (1) DTD.TUTANAKID, DTD.DEMIRBASID, DT.TIP, DT.TARIH, DT.ZIMMETVERENID, '+
    ' DT.ZIMMETALANID, DT.LOKASYONID,DT.DEGISTIREN ' +
    ' FROM DEMIRBAS_TUTANAK_DETAY AS DTD INNER JOIN  DEMIRBAS_TUTANAK AS DT ON DTD.TUTANAKID = DT.ID ' +
    ' WHERE (DTD.DEMIRBASID =:A0) ORDER BY DTD.TUTANAKID DESC';
    Tablo.Query3.Params[0].Value := TabServis.FieldByName('DEMIRBASID').AsInteger;
    Tablo.Query3.Open;
    if Tablo.Query3.IsEmpty then
      SonDurum := 4
    else
    Begin
      if Tablo.Query3.FieldByName('TIP').AsInteger = 5 then
        SonDurum := 1
      else
        SonDurum := Tablo.Query3.FieldByName('TIP').AsInteger;
    End;

    { if Tablo.Query3.FieldByName('TIP').AsInteger=4 then SonDurum:=0
      else SonDurum:=1;
      }

    Tablo.Query1.Close;
    Tablo.Query1.SQL.text := 'Update DEMIRBAS set DURUM=:A0 Where ID=:A1';
    Tablo.Query1.Params[0].Value := SonDurum;
    Tablo.Query1.Params[1].Value := DemirbasID;
    Tablo.Query1.ExecSQL;
  end;
   *)

end;

procedure TDemirbasTamirServisDLG.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TDemirbasTamirServisDLG.FormShow(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
begin
{   aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
   YaziciYaz.Caption := ra;
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1; }


   //TabServis.SQL.Text := SQLGenelServis.Text;
   LabelGonderilenFirma.Visible := False;
   cbGonderilenFirma.Visible := False;
   LabeFirmaPersoneli.Visible := False;
   CbFirmaPersoneli.Visible := False;

   TabloYenile(TabServis, [ServisID]);
  case IslemOp of
    'E': begin
          TabServis.Append; // Ekleme
          TabServis.Post;
          if TeknikSerSor>0 then //teknik servis sorumlusu varsa onu da insert etmeli
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GOREVKULLANICI (LISTGOREVID,TUR,REHBERID,EKLEYEN,EKLEMETARIHI) '+
                     ' values('+TabServis.FieldByName('ID').AsString+',12,'+IntToStr(TeknikSerSor)+','+Kullanan+','+
                     ''''+FormatDateTime('yyyy-mm-dd', Tablo.GenIni.BugunTrhSaat)+''')',[],[]);

          //TabloYenile(TabGenel, [TabServis.Fields[0].AsInteger]);
         // TabGenel.Append; // Ekleme
         // TabGenel.Post;
          TabServis.Edit;
      end;
    'D':TabloYenile(TabGenel, [TabServis.Fields[0].AsInteger]);
    end;

    GbServiseGonder.Enabled := ServisOp='G';//gönderim
    GbServisiadeAl.Enabled := ServisOp='I';//İade
    if ServisOp='I' then begin
       TabServis.Edit; //
       TabServis.FieldByName('TESLIM_TARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
       TabServis.FieldByName('TESLIM_ALAN').AsString := Kullanan;
    end;


    if TabServis.FieldByName('MUS_ILGILI').AsString <> '' then
       cbServiseGonderen.text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabServis.FieldByName('MUS_ILGILI').AsString);


    if (cbGonderilenFirma.visible)and(TabServis.FieldByName('GONDERILENFIRMA').AsString <> '') then
       cbGonderilenFirma.text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabServis.FieldByName('GONDERILENFIRMA').AsString);

    if (CbFirmaPersoneli.visible)and(TabServis.FieldByName('FIRMAPERSONELI').AsString <> '') then
       CbFirmaPersoneli.text := Tablo.AciklamaGetir('REHBERPERSONEL', 'ADSOYAD', TabServis.FieldByName('FIRMAPERSONELI').AsString);

    if (cbTeslimAlanPersonel.visible)and(TabServis.FieldByName('TESLIM_ALAN').AsString <> '') then
        cbTeslimAlanPersonel.text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabServis.FieldByName('TESLIM_ALAN').AsString);

(*      begin
        case ServisOp of
          'G':
            begin
              if Degistir then
              begin
                ServisQueryCek(DemirbasServisID, 6, DemirbasID);
                if TabServis.IsEmpty then
                begin
                  ServisQueryCek(DemirbasServisID, 7, DemirbasID);
                end
                else
                  GbServisiadeAl.Enabled := False;
              end
              else
              begin
                TabServis.Edit; // Değiştirme
                TabServis.FieldByName('DONUSTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
              end;
            end;
          'I':
            begin
              if Degistir then
              begin
                ServisQueryCek(DemirbasServisID, 7, DemirbasID);
              end
              else
              begin
                ServisQueryCek(DemirbasServisID, 6, DemirbasID);
                GbServiseGonder.Enabled := False;
              end;
            end;
        end;
        case ServisOp of
          'G':
            begin
              //
              TabServis.Edit; // Değiştirme
              TabServis.FieldByName('DURUM').AsInteger := 6;
            end;
          'I':
            begin
              TabServis.Edit; // Değiştirme
              TabServis.FieldByName('DONUSTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
              TabServis.FieldByName('DURUM').AsInteger := 7;
            end;
        end;

      end;
  end;
*)
end;

procedure TDemirbasTamirServisDLG.LabeFirmaPersoneliClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := Tablo.RehberSihirbazBaslat(4, TabServis.FieldByName('GONDERILENFIRMA').AsInteger,-1, -1, False);
  if ID > 0 then
  begin
    TabServis.Edit;
    TabServis.FieldByName('FIRMAPERSONELI').AsInteger := ID;
    CbFirmaPersoneli.Text := Tablo.AciklamaGetir('REHBERPERSONEL', 'ADSOYAD', ID);
  end;
end;

procedure TDemirbasTamirServisDLG.ServisQueryCek(ServisID, Durum, Demirbas_ID: integer);
begin
  TabServis.Close;
  if SQLMemo = '' then
    SQLMemo := TabServis.SQL.text;
  TabServis.SQL.text := SQLMemo;
  TabServis.SQL.text := TabServis.SQL.text + ' where 1=1 ';
  if Degistir then
    TabServis.SQL.text := TabServis.SQL.text + ' and S.ID =:A0';
  TabServis.SQL.text := TabServis.SQL.text + ' and S.DURUM =:A1 ';
  TabServis.SQL.text := TabServis.SQL.text + ' and S.DEMIRBASID =:A2';
  if Degistir then
  begin
    TabServis.Params[0].Value := ServisID;
    TabServis.Params[1].Value := Durum;
    TabServis.Params[2].Value := Demirbas_ID;
  end
  else
  begin
    TabServis.Params[0].Value := Durum;
    TabServis.Params[1].Value := Demirbas_ID;
  end;
  TabServis.Open;
end;

procedure TDemirbasTamirServisDLG.TabServisNewRecord(DataSet: TDataSet);
var
  belgeno : TBelgeNo;
begin
      TabServis.FieldByName('ACIL').Value := False;
      TabServis.FieldByName('DISSERVIS').Value := False;
      TabServis.FieldByName('EKIPMANID').AsInteger := DemirbasID;
      TabServis.FieldByName('SERINO').AsString := Serino;
      TabServis.FieldByName('MUS_ILGILI').AsString := Kullanan;
      TabServis.FieldByName('REHBERID').AsString:= Kullanan;
      TabServis.FieldByName('DEMIRBAS').AsBoolean := True;

      TabServis.FieldByName('KAPSAM').AsInteger := Tablo.repServisKapsam.Properties.Items[0].Value;
      TabServis.FieldByName('KABUL_SEKLI').AsInteger := Tablo.repServisKabulSekli.Properties.Items[0].Value;


      TabServis.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      TabServis.FieldByName('FIYAT_LISTESI').AsInteger := VarsSatisFiyatID;
      TabServis.FieldByName('DEPO').AsInteger := VarsDepo;
      TabServis.FieldByName('ACKAPA').AsBoolean := False;
      TabServis.FieldByName('TESLIM_SEKLI').AsInteger:= 1;
      TabServis.FieldByName('DURUM').AsInteger := 0;//Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_Varsayilan_Durum_Yeni,1);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DEMIRBAS set SERVISDURUM=1 where ID =&id ', ['&id'], [DemirbasId]);


      TabServis.FieldByName('NOTLAR').AsString := '';
      TabServis.FieldByName('EKLEYEN').AsString := Kullanan;
      TabServis.FieldByName('KABUL_EDEN').AsInteger  := TeknikKabulSor;
//      TabServis.FieldByName('SORUMLU').AsInteger  := TeknikSerSor;
      belgeno:= SiradakiBelgeNumarasi(TabNo_SERVIS,Tablo.GENINI.BugunTrhSaat);
      TabServis.FieldByName('SERVISNO').AsString := belgeno.belgeno;
     // TabServis.FieldByName('SERVISSERI').AsString := belgeno.serino;
     // TabServis.FieldByName('KOCANNO').AsInteger := KocannoBul(TabNo_SERVIS); //KOCAN numarası
      TabServis.FieldByName('SUBEID').AsInteger := SubeID;
end;
`r`n
procedure TDemirbasTamirServisDLG.TabGenelAfterOpen(DataSet: TDataSet);
begin
   Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'sl.AD from SERVISBILGI SB inner join SERVISLISTE SL on SB.SERVISTUR=210 '+
      ' and SB.SERVISLISTEID=SL.ID and SB.SERVISID='+TabServis.Fields[0].AsString+' '+DbSinir(1));
   EditProblem.Text := Tablo.Query1.Fields[0].AsString;
   memoServiseGonderimNedeni.Enabled := True;
end;

end.






