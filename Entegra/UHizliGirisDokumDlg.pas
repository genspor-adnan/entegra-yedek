unit UHizliGirisDokumDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxControls,
  cxPC, ExtCtrls, StdCtrls, cxLookAndFeelPainters, UGentegreFrameYonetimi,
  cxContainer, cxEdit, cxGroupBox, CategoryButtons, ComCtrls, ToolWin,
  JvExExtCtrls, JvExtComponent, JvPanel, cxDBLabel, cxLabel,FireDAC.Comp.Client, DB, Buttons,
  cxTextEdit, cxDropDownEdit, UDokum, UTablo, URaporAraclari,FetaClassExtensions,
  cxSpinEdit, cxCurrencyEdit, cxMaskEdit, cxTimeEdit, cxCalendar,
  frxClass, frxDBSet, Menus, UGenelAnaSekmeFrame, dxSkinLiquidSky, cxGraphics,
  cxLookAndFeels, cxPCdxBarPopupMenu, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  THizliGirisDokumDlg = class(TForm, IPopupDialog)
    pnlDokumListe: TPanel;
    Button1: TButton;
    cxGroupBox1: TcxGroupBox;
    ScrollBoxListe: TScrollBox;
    pcArama: TcxPageControl;
    dokumListesi: TCategoryButtons;
    pnlSol: TPanel;
    Panel2: TPanel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    Label8: TcxLabel;
    LabelKullanan: TcxLabel;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    DokumTus: TToolButton;
    ToolButton6: TToolButton;
    cxTabControl2: TcxTabControl;
    YaziciYaz: TToolButton;
    ToolButton8: TToolButton;
    EditRAPORADI: TcxDBLabel;
    EditGRUBU: TcxDBLabel;
    cxDBTextEdit3: TcxDBLabel;
    cxDBTextEdit1: TcxDBLabel;
    cxDBTextEdit2: TcxDBLabel;
    cxDBTextEdit4: TcxDBLabel;
    EditRAPORKODU: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    TabDokum: TFDQuery;
    TabKosul: TFDQuery;
    qryListe: TFDQuery;
    dsListe: TDataSource;
    Panel1: TPanel;
    GBox1: TJvPanel;
    DtsDokumler: TDataSource;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    frxSQLKomut: TfrxDBDataset;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure YerBilgileriniTemizle(ACategory : TButtonCategory);
    procedure TumYerBilgileriniTemizle;
    procedure DokumleriYerlestir(ADokumEkranAdi : string);
    procedure DokumTabloAc(Modul: String);
    procedure ButonClick(Sender: TObject);
    procedure ComBoxInitPopup(Sender: TObject);
    procedure dokumListesiButtonClicked(Sender: TObject; const Button: TButtonItem);
    procedure TabDokumAfterScroll(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure DokumTusClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ScrollBox2: TScrollBox;
    komut : TStringList;
    Tut: TComponent;

    FIcerikFrameYoneticisi : TIcerikFrameYoneticisi;
    FAramaFrameYoneticisi : TAramaFrameYoneticisi;

    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure DokumIslemi;
    procedure KosullariKaydet;
    function EkranAdiAl : string;

  public
    { Public declarations }
    FDokumEkranAdi : string;
  end;

var
  HizliGirisDokumDlg: THizliGirisDokumDlg;

implementation

  Uses uKosulDetayAra, UFastRap,prjconst,LocOnFly;

{$R *.dfm}
  var
  Kontrol : array[1..12] of String[20];
  OncekiSQL : string;

type
  PYerBilgisi = ^TYerBilgisi;
  TYerBilgisi = record
    RaporAdi : ShortString;
  end;

function THizliGirisDokumDlg.EkranAdiAl: string;
begin
   Result := 'HizliGirisDokumDlg';
end;

procedure THizliGirisDokumDlg.KosullariKaydet;
var
  i : Integer;
  s : string;
begin
  i := 1;
  TabKosul.First;
  while not TabKosul.eof do begin
    Tut := ScrollBox2.FindChildControl(Kontrol[TabKosul.FieldByName('ICERIKTURU').AsInteger] + TabKosul.FieldByName('ID').AsString);
    if Tut <> nil then begin
       TabKosul.edit;
       case TabKosul.FieldByName('ICERIKTURU').AsInteger of
         1,3 : s := TcxTextEdit(Tut).Text;
         2 : s := TcxSpinEdit(Tut).Text;
         4 : s := TcxCurrencyEdit(Tut).Text;
         5 : s := FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', TcxDateEdit(Tut).Date);
         6 : s := FormatDateTime('hh:nn', TcxTimeEdit(Tut).Time);
         7 : s := TcxComBoBox(Tut).Text;
         8 : s := TcxTextEdit(Tut).Text;
       end;
       TabKosul.FieldByName('DEGER').AsString := s;//TComBoBox(Tut).Text;
       TabKosul.post;
    end;
    TabKosul.Next;
    inc(i, 5);
  end;

  Tablo.FDCnn.ExecSQL('UPDATE DOKUMLER SET SAYAC= ISNULL(SAYAC,0) + 1 , SONTARIH= GETDATE(), SONKULLANAN='''+Kullanan+''' WHERE RAPORADI ='''+TabDokum.Fieldbyname('RAPORADI').AsString +'''');
end;

procedure THizliGirisDokumDlg.DokumIslemi;
var Kosullar: array[1..10] of string[50];
  Yeri: integer;
  s: string;
  i : Integer;
  j : Integer;
begin
  Komut.Clear;
//  Komut.Clear;
  KosullariKaydet;
//  TabDokum.Refresh;
//  DokumSartDlg.TabDokum.FindKey([TabDokum.FieldByName('RAPORADI').AsString]);
  if TabDokum.FieldByName('SQL').AsString <> '' then
  begin
    Komut.Assign(TabDokum.FieldByName('SQL'));
    komut.Text := StringReplace(komut.Text,'%KullanıcıKodu%',Kullanan,[rfReplaceAll]);
    komut.Text := StringReplace(komut.Text,'%KullanıcıAdı%',KullanAdi,[rfReplaceAll]);

    i := 0; //Koşulları Diziye Al
    TabKosul.First;
    while not TabKosul.eof do
    begin
      inc(i);
      if TabKosul.FieldByName('ICERIKTURU').AsInteger = 5 then //date
         s := FormatDateTime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy', StrToDateDef(TabKosul.FieldByName('DEGER').AsString, Tablo.GENINI.BugunTrh))//date
      else
         s := TabKosul.FieldByName('DEGER').AsString;
      Komut.Text := StringReplace(komut.Text, '$'+TabKosul.FieldByName('KOD_ADI').AsString+'$', s, [rfReplaceAll]);
      TabKosul.next;
    end;
    qryListe.Close;
    qryListe.SQL.Text := Komut.Text;
    qryListe.open;
  end
  else
  ShowMessage(SQLBulunamadi);
end;

procedure THizliGirisDokumDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
 //  if not qryListe.Active then
      DokumTus.Click;

   TabKosul.First;
   while not TabKosul.Eof do begin
       DokumDegiskenListesi.Add(TabKosul.FieldByName('ACIKLAMA').AsString+'$@$'+TabKosul.FieldByName('DEGER').AsString);
       TabKosul.Next;
   end;

   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxSQLKomut);
end;


procedure THizliGirisDokumDlg.ComBoxInitPopup(Sender: TObject);
begin
   TRaporAraclari.Ini.ReadSection('Dokum_'+TabKosul.FieldByName('KOD_ADI').AsString+TabKosul.FieldByName('ID').AsString, TcxComboBox(Sender).Properties.Items);
end;

procedure THizliGirisDokumDlg.BaskiOnizlemeMenuClick(Sender: TObject);
begin
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'DokumDlg', TabDokum.FieldByName('RAPORADI').AsString);
end;

procedure THizliGirisDokumDlg.ButonClick(Sender: TObject);
var
  ad: string;
  btn: TSpeedButton;
  i: integer;
  j: integer;
begin
  btn := TSpeedButton(Sender);
  ad:=copy(btn.Name,8,100);
  j:=pos('_', Ad);
  i := strtoint(copy(Ad, 1, j - 1));
//  j := strtoint(copy(btn.Name, pos('_', btn.Name) + 1, length(btn.name)));
  EditNe := ScrollBox2.FindChildControl('Edit_' + inttostr(i)) as TcxTextEdit;
  TabKosul.First;
  TabKosul.Locate('ID', i, [loPartialKey, loCaseInsensitive]);
  Application.CreateForm(TKosulDetayAra, KosulDetayAra);
  KosulDetayAra.TabKosulInstance := TabKosul;
  KosulDetayAra.showmodal;
  KosulDetayAra.destroy;
end;

procedure THizliGirisDokumDlg.dokumListesiButtonClicked(Sender: TObject;
  const Button: TButtonItem);
begin
  TabDokum.Locate('RAPORADI',PYerBilgisi(Button.Data)^.RaporAdi,[]);
end;

procedure THizliGirisDokumDlg.DokumTabloAc(Modul: String);
begin
  TabDokum.Close;
  TabDokum.Params[0].Value := '%' + Modul + '%';
  TabDokum.Open;
end;

procedure THizliGirisDokumDlg.DokumTusClick(Sender: TObject);
begin
  DokumIslemi;
end;

procedure THizliGirisDokumDlg.FormCreate(Sender: TObject);
var
   aktifFrame : TGenelAnaSekmeFrame;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Komut := TStringList.Create;
  DokumleriYerlestir('K');

  Kontrol[1] := 'Edit_';
  Kontrol[2] := 'Spin_';
  Kontrol[3] := 'Edit_';
  Kontrol[4] := 'Money_';
  Kontrol[5] := 'Date_';
  Kontrol[6] := 'Time_';
  Kontrol[7] := 'Combo_';
  Kontrol[8] := 'Edit_';
//  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);

//  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
//  PopupMenuYaz.Images := aktifFrame.ImageList1;
end;

procedure THizliGirisDokumDlg.FormDestroy(Sender: TObject);
begin
 komut.Free;
end;

procedure THizliGirisDokumDlg.YerBilgileriniTemizle(ACategory : TButtonCategory);
var
  i : Integer;
  p : PYerBilgisi;
begin
  for I := 0 to ACategory.Items.Count - 1 do begin
    p := ACategory.Items[i].Data;
    if Assigned(p) then
      Dispose(p);
    ACategory.Items[i].Data := nil;
  end;
end;

procedure THizliGirisDokumDlg.TabDokumAfterScroll(DataSet: TDataSet);
begin
  LabelKullanan.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDokum.FieldByName('SONKULLANAN').AsString);
  TabloYenile(TabKosul, [TabDokum.Fields[0].AsInteger]);
  TDokumDlg.SartlarOlustur(HizliGirisDokumDlg.ScrollBox2, HizliGirisDokumDlg.GBox1, HizliGirisDokumDlg.Panel1,TabKosul,ButonClick,ComBoxInitPopup);
  qryListe.Close;
end;

procedure THizliGirisDokumDlg.TumYerBilgileriniTemizle;
var
  i : Integer;
begin
  for I := 0 to dokumListesi.Categories.Count - 1 do
    YerBilgileriniTemizle(dokumListesi.Categories[i]);
end;

procedure THizliGirisDokumDlg.DokumleriYerlestir(ADokumEkranAdi : string);
var
  genelKat : TButtonCategory;
  idx      : Integer;
  Tamam    : Boolean;
  yb       : PYerBilgisi;
  I: Integer;
begin
  if ADokumEkranAdi <> '' then
    FDokumEkranAdi := ADokumEkranAdi;
  TumYerBilgileriniTemizle;
  dokumListesi.Categories.Clear;
  genelKat := dokumListesi.Categories.Add;
  genelKat.Caption := 'Genel';
  genelKat.GradientColor := $004080FF;
  genelKat.Color := clWhite;
  genelKat.Collapsed := True;
  DokumTabloAc(ADokumEkranAdi);
  with TFDQuery.Create(nil) do
  try
    Connection := TabDokum.Connection;
    SQL.Assign(TabDokum.SQL);
    Params.AssignValues(TabDokum.Params);
    if Assigned(Params.FindParam('MOD')) then
      if Params.ParamByName('MOD').DataType = ftUnknown then
        Params.ParamByName('MOD').DataType := ftInteger;
    Open;
    if Eof then   //Eğer tablo boşsa sayfayı direk açsın
      DtsDokumler.DataSet := TabDokum
    else begin
      while not Eof do
      begin
        Tamam := True;

          if FieldByName('GRUBU').AsString = '' then
            with genelKat.Items.Add do begin
              Caption := FieldByName('RAPORADI').AsString;
              New(yb);
              Data := yb;
              yb^.RaporAdi := Caption;
              ImageIndex := 0;
            end
          else begin
            idx := dokumListesi.Categories.IndexOf(FieldByName('GRUBU').AsString);
            if idx <> -1 then begin
              with dokumListesi.Categories[idx].Items.Add do begin
                Caption := FieldByName('RAPORADI').AsString;
                ImageIndex := 0;
                New(yb);
                Data := yb;
                yb^.RaporAdi := Caption;
              end;
            end else begin
              with dokumListesi.Categories.Add do begin
                Caption := FieldByName('GRUBU').AsString;
                GradientColor := $004080FF;
                Color := clWhite;
                Collapsed := True;
                with Items.Add do begin
                  Caption := FieldByName('RAPORADI').AsString;
                  New(yb);
                  Data := yb;
                  yb^.RaporAdi := Caption;
                  ImageIndex := 0;
                end;
              end;
            end;
          end;
        Next;
      end;
    end;
  finally
    Free;
  end;
  for I := 0 to dokumListesi.Categories.Count-1 do
      dokumListesi.Categories[i].Collapsed  := False;
end;


end.






