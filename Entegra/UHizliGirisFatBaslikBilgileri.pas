unit UHizliGirisFatBaslikBilgileri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics,
  JvExControls, JvButton, JvNavigationPane, cxMaskEdit, cxDropDownEdit,
  cxDBEdit, cxMemo, cxTextEdit, cxControls, cxContainer, cxEdit, cxLabel,
  UHizliGiris,UTouchKeyboardWindow, ImgList, PngImageList,FetaKurulusSiniflari, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine,
  dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  THizliGirisFatBaslikBilgileriDlg = class(TForm)
    PanelHizliGirisFatDetay: TPanel;
    Label22: TcxLabel;
    Label24: TcxLabel;
    Label2: TcxLabel;
    Label25: TcxLabel;
    Label3: TcxLabel;
    Label26: TcxLabel;
    EditBASLIK: TcxTextEdit;
    MemoFatAdres: TcxMemo;
    EditILCE: TcxTextEdit;
    EditVD: TcxTextEdit;
    EditVNo: TcxTextEdit;
    EditIl: TcxTextEdit;
    PngImageList1: TPngImageList;
    MemoAciklama: TcxMemo;
    cxLabel1: TcxLabel;
    Panel2: TPanel;
    BtnTamam: TJvNavPanelButton;
    BtnIptal: TJvNavPanelButton;
    JvNavPanelButton1: TJvNavPanelButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnTamamClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    Klavye1:TKeyboardWindow;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HizliGirisFatBaslikBilgileriDlg: THizliGirisFatBaslikBilgileriDlg;

implementation

uses
  Utablo, UHizliGirisAnaMenu,LocOnFly;

{$R *.dfm}

procedure THizliGirisFatBaslikBilgileriDlg.BtnIptalClick(Sender: TObject);
begin
  ModalResult:=MrCancel;
end;

procedure THizliGirisFatBaslikBilgileriDlg.BtnTamamClick(Sender: TObject);
begin
  ModalResult:=MrOk;
end;

procedure THizliGirisFatBaslikBilgileriDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.TablodanSorguAc(1,'select ILADI from ILLER  where ILNO<100 order by 1');
   Tablo.Query1.First ;
   while not Tablo.Query1.Eof do begin
       EditIL.Properties.LookUpItems.Add(Tablo.Query1.Fields[0].AsString);
       Tablo.Query1.Next;
   end;
   Tablo.TablodanSorguAc(1,'select VD from VDLISTE order by 1');
   Tablo.Query1.First ;
   while not Tablo.Query1.Eof do begin
       EditVD.Properties.LookUpItems.Add(Tablo.Query1.Fields[0].AsString);
       Tablo.Query1.Next;
   end;
   Tablo.AlanOlustur(THizliGirisFatBaslikBilgileriDlg(Self), -1,HizliGirisAnaMenu.DtsFatBaslik);
end;

procedure THizliGirisFatBaslikBilgileriDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos,clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos :=Self.ScreenToClient(Mouse.CursorPos);
  if Key = 13 then // ENTER
     BtnTamamClick(Self)
  else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then begin   //Yeni Bileşen Ekle
     ctrl := FindVCLWindow(Mouse.CursorPos);
     if Assigned(ctrl) then begin
        OutputDebugString(PChar(ctrl.Name));
        ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
        Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),THizliGirisFatBaslikBilgileriDlg(Self),HizliGirisAnaMenu.DtsFatBaslik);
     end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bileşen Düzenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
       OutputDebugString(PChar(ctrl.Name));
       ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
       Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
       Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(PanelHizliGirisFatDetay.Name),THizliGirisFatBaslikBilgileriDlg(Self),HizliGirisAnaMenu.DtsFatBaslik);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('S')) then  begin  //Bileşen Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
       OutputDebugString(PChar(ctrl.Name));
       ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      if ctrl.Name <> '' then begin
         Tablo.TablodanSorguAc(1,'Select CAPTION,ALANADI,TAG from ALANLAR Where TAG='+IntToStr(ctrl.Tag)+' and TUR <> 11 ');
         if Application.MessageBox(PChar(Tablo.Query1.FieldByName('CAPTION').AsString+' alanını silmek istiyor musunuz ?'),'UYARI',MB_YESNO)=mrYes then  begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from ALANLAR Where TAG ='+IntToStr(ctrl.Tag)+' ',[],[]);
         try
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Alter table DEMIRBAS drop column '+Tablo.Query1.FieldByName('ALANADI').AsString+' ',[],[]);
         except
         end;
         Tablo.AlanOlustur(THizliGirisFatBaslikBilgileriDlg(Self),-1,HizliGirisAnaMenu.DtsFatBaslik);
       end;
     end;
    end;
  end;

end;

procedure THizliGirisFatBaslikBilgileriDlg.JvNavPanelButton1Click(
  Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := Top + Height;
  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;
end;

end.


