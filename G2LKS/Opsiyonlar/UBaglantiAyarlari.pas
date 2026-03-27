unit UBaglantiAyarlari;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ActnList, StdActns, cxLookAndFeelPainters, cxMaskEdit, cxButtonEdit, cxTextEdit, cxLabel, cxControls, cxContainer,
  cxEdit, cxGroupBox, Menus, cxButtons, cxGraphics, cxDropDownEdit, cxImageComboBox, cxPC, ExtCtrls, cxPCdxBarPopupMenu, cxLookAndFeels,
  folderBrowse,UGENINIDuzenle,UTablo;
{$I options.inc}

type
    TBaglantiAyarlariForm = class(TFrame)
    browseForFolder: TBrowseForFolder;
    PageControlBaglantilar: TcxPageControl;
    TabSheetLogo: TcxTabSheet;
    TabSheetOrka: TcxTabSheet;
    Panel1: TPanel;
    cxGroupBox1: TcxGroupBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    EditServer: TcxTextEdit;
    EditKullanici: TcxTextEdit;
    EditSifre: TcxTextEdit;
    EditVariTabani: TcxTextEdit;
    BaglantiSina: TcxButton;
    cxGroupBox2: TcxGroupBox;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    BEFirmaNo: TcxButtonEdit;
    BEDonemNO: TcxButtonEdit;
    ComboMuhasebeProg: TcxImageComboBox;
    procedure BEDonemNOPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BaglantiSinaClick(Sender: TObject);
    procedure ComboMuhasebeProgPropertiesCloseUp(Sender: TObject);
  private
    { Private declarations }
    procedure SaveContentMsg(var Msg: TMessage);message WM_SAVECONTENT;
    procedure btnTamam;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
  end;

implementation
uses
  UOpsiyon, ECXMLParser,PrjConst,UGirisKutusuEx;

{$R *.dfm}

{ TBaglantiAyarlariForm }

procedure TBaglantiAyarlariForm.BaglantiSinaClick(Sender: TObject);
begin
  btnTamam;

  if Tablo.lksConnection.Connected then begin
    Application.MessageBox('Sýnama baðlantýsý baþarýlý oldu',PChar(uyari),0);
    Tablo.lksConnection.Connected:=False;
  end;
end;

procedure TBaglantiAyarlariForm.BEDonemNOPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NR,FIRMNR:variant;
  frm,dnm:string;
  st:TStringList;
begin
  st:=TStringList.Create;
  if Tablo.ListedenBilgiGetir('Firma Seçiniz','select C.LOGICALREF as ID,C.NAME as Firma,C.TITLE as Baþlýk,D.BEGDATE as [Baþlama Tarihi],D.ENDDATE as [Bitiþ Tarihi],D.NR as [Dönem No],D.FIRMNR as [Firma No] FROM L_CAPIFIRM C,L_CAPIPERIOD D WHERE C.NR=D.FIRMNR',st,[],'',TNotifyEvent(nil),Tablo.lksConnection,nil) then begin

         if Length(st.Strings[6])=1 then
           frm:='00'+st.Strings[6]
         else if Length(st.Strings[6])=2 then
           frm:='0'+st.Strings[6]
         else if Length(st.Strings[6])=3 then
           frm:=st.Strings[6];
         BEFirmaNo.Text := frm;

         if Length(st.Strings[5])=1 then
           dnm:='0'+st.Strings[5]
         else if Length(st.Strings[5])=2 then
           dnm:=st.Strings[5];
         BEDonemNO.Text := dnm;
  end;
  st.Free;
end;

procedure TBaglantiAyarlariForm.ComboMuhasebeProgPropertiesCloseUp(Sender: TObject);
begin
  case ComboMuhasebeProg.EditValue of
    1:begin
      TabSheetOrka.TabVisible := False;
      TabSheetLogo.TabVisible := True;
      PageControlBaglantilar.ActivePage:= TabSheetLogo;
    end;
    2:begin
      TabSheetLogo.TabVisible := False;
      TabSheetOrka.TabVisible := True;
      PageControlBaglantilar.ActivePage:= TabSheetOrka;
    end;
  end;
end;

constructor TBaglantiAyarlariForm.Create(AOwner: TComponent);
var
  node : TXMLItem;
begin
  inherited;
//  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=aktarim_yolu',Tablo.configuration.Root);
//  aktarimYoluEdit.Text := node.Params.Values['yol'];

 case Tablo.GENINI.ReadInteger(Ops_G2LKS_VarsayilanMuhasebeProg,G2MuhEnt_LKS) of
   G2MuhEnt_LKS:begin
      PageControlBaglantilar.ActivePage:= TabSheetLogo;
      TabSheetOrka.TabVisible := False;
      TabSheetLogo.TabVisible := True;
    end;
   G2MuhEnt_Orka :begin
      PageControlBaglantilar.ActivePage:= TabSheetOrka;
      TabSheetLogo.TabVisible := False;
      TabSheetOrka.TabVisible := True;
    end;
  end;

  EditServer.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_Server,'-999');
  EditKullanici.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_Kullanici,'-999');
  EditSifre.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_Sifre,'-999');
  EditVariTabani.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_VeriTabani,'-999');
  BEFirmaNo.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_FirmaNo,'-999');
  BEDonemNO.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_DonemNo,'-999');

  //Tablo.GENINI.ReadImageSection(Ops_G2LKS_MuhasebeProg, ComboMuhasebeProg.Properties.Items, False);
  ComboMuhasebeProg.EditValue := Tablo.GENINI.ReadInteger(Ops_G2LKS_VarsayilanMuhasebeProg,1);
end;
procedure TBaglantiAyarlariForm.SaveContentMsg(var Msg: TMessage);
var
  node : TXMLItem;
begin
//  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=aktarim_yolu',Tablo.configuration.Root);
//  node.Params.Values['yol'] := IncludeTrailingBackslash(aktarimYoluEdit.Text);
  btnTamam;
end;
Procedure TBaglantiAyarlariForm.btnTamam;
var
  CstLOGO:String;
begin

  if Tablo.lksConnection.Connected then begin
     Tablo.lksConnection.Connected:=False;
  end;
 case ComboMuhasebeProg.EditValue of
 G2MuhEnt_LKS:begin
      Tablo.GENINI.WriteString(Ops_G2LKS_Server,EditServer.Text);
      Tablo.GENINI.WriteString(Ops_G2LKS_Kullanici,EditKullanici.Text);
      Tablo.GENINI.WriteString(Ops_G2LKS_Sifre,EditSifre.Text);
      Tablo.GENINI.WriteString(Ops_G2LKS_VeriTabani,EditVariTabani.Text);

      CstLOGO:='Provider=SQLOLEDB.1; Password='+EditSifre.Text+';Persist Security Info=True;User ID='+EditKullanici.Text+'; Initial Catalog='+EditVariTabani.Text+'; Data Source='+EditServer.Text+';Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=KURTPC;Use Encryption for Data=False;Tag with column collation when possible=False ';
      GenRegIni.RegWriteString('', 'ConnectionStringLOGO', CstLOGO, 'C');

      Tablo.lksConnection.ConnectionString := CstLOGO;

      try
        Tablo.lksConnection.Open;
      except
        Application.MessageBox('Sýnama baðlantýsý baþarýsýz oldu',PChar(uyari),0);
      end;

      Tablo.GENINI.WriteString(Ops_G2LKS_FirmaNo,BEFirmaNo.Text);
      Tablo.GENINI.WriteString(Ops_G2LKS_DonemNo,BEDonemNO.Text);
   end;
       G2MuhEnt_Orka:begin
   end;
 end;
  Tablo.GENINI.WriteInteger(Ops_G2LKS_VarsayilanMuhasebeProg,ComboMuhasebeProg.EditValue);
end;

initialization
  RegisterOption(5,'Genel/Baglanti Ayarlari',TBaglantiAyarlariForm);
end.
