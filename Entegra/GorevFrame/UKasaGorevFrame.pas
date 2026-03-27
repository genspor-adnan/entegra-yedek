unit UKasaGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, JclSysInfo,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList,UKasa,UTakvim, ExtCtrls, CategoryButtons, cxCustomData,
  System.ImageList;

type
  TKasaGorevFrame = class(TFrame)
    btnKasaTanimlari: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    Panel1: TPanel;
    btnFinansListe: TJvNavPanelButton;
    btnFinansTakvim: TJvNavPanelButton;
    PanelGiderBelge: TPanel;
    ListelerMenuGider: TCategoryButtons;
    btnSorumlulukMaliyetleme: TJvNavPanelButton;
    PanelGelirBelge: TPanel;
    ListelerMenuGelir: TCategoryButtons;
    btnGelirMerkeziTanimlari: TJvNavPanelButton;
    Panel2: TPanel;
    btnOzelDokumler: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    procedure btnKasaTanimlariClick(Sender: TObject);
    procedure btnSorumlulukMaliyetlemeClick(Sender: TObject);
    procedure btnGelirMerkeziTanimlariClick(Sender: TObject);
    procedure btnFinansListeClick(Sender: TObject);
    procedure btnFinansTakvimClick(Sender: TObject);
    procedure ListelerMenuGiderCategoryCollapase(Sender: TObject; const Category: TButtonCategory);
    procedure ListelerMenuGiderCategoryClicked(Sender: TObject; const Category: TButtonCategory);
    procedure ListelerMenuGiderButtonClicked(Sender: TObject; const Button: TButtonItem);
    procedure FrameResize(Sender: TObject);
    procedure btnUpAndDown(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
    procedure MesajAlindi(AMesaj: Variant);
    procedure TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
  public
    { Public declarations }
    FAltTur : SmallInt;    //AltTur: MasrafKalemleri:3,Sorumluluk Merkezleri:4,DaðýtýmAnahtarý:5
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
  end;

implementation

uses JvJVCLUtils, UMasrafGelir,USorumlulukMerkezleriDlg,UDagitimAnahtarlariDlg, FetaClassExtensions, UMaasTablo,
  UGenelGirisSayfasiFrame, UDokumGirisFrame, UKasalarListeFrame,Utablo,LocOnFly;

{$R *.dfm}

{ TKasaGorevFrame }

procedure TKasaGorevFrame.ListelerMenuGiderButtonClicked(Sender: TObject; const Button: TButtonItem);
begin
  if not JclSysInfo.GetKeyState(VK_CONTROL) then
     TumTusResimleriniDegistir(Button.CategoryButtons,10);

  if Button.ImageIndex = 9 then
     Button.ImageIndex :=10
  else
     Button.ImageIndex :=9;

  Tablo.FBtnIndex := Button.Index;

  btnSorumlulukMaliyetlemeClick(Sender);
end;

procedure TKasaGorevFrame.TumTusResimleriniDegistir(Menu:TCategoryButtons;ImajIndex:Integer);
var i:Integer;
begin
  for I := 0 to Menu.Categories[0].Items.Count - 1 do
    Menu.Categories[0].items[i].ImageIndex:=ImajIndex;
end;

procedure TKasaGorevFrame.ListelerMenuGiderCategoryClicked(Sender: TObject; const Category: TButtonCategory);
begin
  Category.Collapsed := not Category.Collapsed;
end;

procedure TKasaGorevFrame.btnUpAndDown(Sender: TObject);
begin
  if (Sender<>nil)and(Sender.ClassName='TJvNavPanelButton') then begin
    btnFinansListe.Down := False;
    btnFinansTakvim.Down := False;
    btnKasaTanimlari.Down := False;
    btnSorumlulukMaliyetleme.Down := False;
    btnGelirMerkeziTanimlari.Down := False;
    btnDokumler.Down := False;
    btnOzelDokumler.Down := False;
    (Sender as TJvNavPanelButton).Down := True;
  end;
end;

procedure TKasaGorevFrame.ListelerMenuGiderCategoryCollapase(Sender: TObject; const Category: TButtonCategory);
begin
  if Category.collapsed then begin
      Category.CategoryButtons.Height := 28;
      if Category.Caption='Gider' then
        PanelGiderBelge.Height:= 80
      else
        PanelGelirBelge.Height:= 80;

  end else begin

      Category.CategoryButtons.Height := 100;
      if Category.Caption='Gelir' then
        PanelGiderBelge.Height:= 154
      else
        PanelGelirBelge.Height:= 154;
  end;

end;

procedure TKasaGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ListelerMenuGider.Visible := False;
  PanelGiderBelge.height :=52;
  ListelerMenuGelir.Visible := False;
  PanelGelirBelge.height :=52;
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'K';
  btnUpAndDown(Sender);

end;

procedure TKasaGorevFrame.btnFinansListeClick(Sender: TObject);
begin
  btnUpAndDown(Sender);
  ListelerMenuGider.Visible := False;
  PanelGiderBelge.height :=52;
  ListelerMenuGelir.Visible := False;
  PanelGelirBelge.height :=52;
  with (FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TKasaDlg).Git.Ornek as TKasaDlg) do begin
    Calendar1Change(self);
  end;
end;

procedure TKasaGorevFrame.btnFinansTakvimClick(Sender: TObject);
begin
  btnUpAndDown(Sender);
  with (FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TTakvimDlg).Git.Ornek as TTakvimDlg) do begin
        YenileTusClick(Self);
  end;
end;

procedure TKasaGorevFrame.btnGelirMerkeziTanimlariClick(Sender: TObject);
begin
{  if MasrafGelirDlg =nil then begin
    Application.CreateForm(TMasrafGelirDlg, MasrafGelirDlg);
    MasrafGelirDlg.Tur := True;
    MasrafGelirDlg.Caption := 'Gelir Merkezi';
  end;
  MasrafGelirDlg.InitIslemler;
  MasrafGelirDlg.ShowModal;
}
  ListelerMenuGider.Visible := False;
  PanelGiderBelge.height :=52;
  with FFrameBilgi.IcerikGit(TMasrafGelirDlg) do begin
    with TMasrafGelirDlg(Ornek) do begin
       GELIRMI := True;
       Caption := 'Gelir Merkezi';
       InitIslemler;
    end;
  end;
end;

procedure TKasaGorevFrame.btnKasaTanimlariClick(Sender: TObject);
begin
  {if KasalarDlg2 = nil then
    Application.CreateForm(TKasalarDlg2, KasalarDlg2);
  KasalarDlg2.HedefFrameYoneticisi := FFrameBilgi.IcerikFrameYoneticisi;
  KasalarDlg2.ShowModal; }
///   FFrameBilgi.IcerikGit(TKasalarDlg);
//  if KredilerMenu.Visible then
//     KredilerMenu.Visible := False;
//  with TBankalarDlg(FFrameBilgi.IcerikGit(TBankalarDlg).Ornek) do begin
//       Yenile;
//  end;
  ListelerMenuGider.Visible := False;
  PanelGiderBelge.height :=52;
  ListelerMenuGelir.Visible := False;
  PanelGelirBelge.height :=52;
   with FFrameBilgi.IcerikGit(TKasalarListeFrame).Ornek as TKasalarListeFrame do begin
     KASALAR.Open;
   end;
  btnUpAndDown(Sender);
end;

procedure TKasaGorevFrame.btnSorumlulukMaliyetlemeClick(Sender: TObject);
var
  i:Integer;
begin
  btnUpAndDown(Sender);

    with FFrameBilgi.IcerikGit(TMasrafGelirDlg) do begin
        if Sender.ClassName='TJvNavPanelButton' then begin
          Tablo.FBtnIndex := -1;
          FAltTur := -1;
          TumTusResimleriniDegistir(ListelerMenuGider,10);
          TumTusResimleriniDegistir(ListelerMenuGelir,10);
        end;
        case TComponent(Sender).Tag of

                10:begin      ///Gider
                    ListelerMenuGider.Categories[0].Collapsed := False;
                    ListelerMenuGider.Visible := True;
                    PanelGiderBelge.height := 154;
                    PanelGelirBelge.height := 52;

                    for I := 0 to ListelerMenuGider.Categories[0].items.Count - 1 do
                      if ListelerMenuGider.Categories[0].items[i].ImageIndex = 9 then begin
                         case StrToInt(ListelerMenuGider.Categories[0].items[i].Hint) of
                            3:begin
                                 with FFrameBilgi.IcerikGit(TMasrafGelirDlg) do begin
                                      with TMasrafGelirDlg(Ornek) do begin
                                         GELIRMI := False;
                                         Caption := 'Masraf Merkezi';
                                         InitIslemler;
                                      end;
                                  end;
                            end;
                            4:begin
                                   with FFrameBilgi.IcerikGit(TSorumlulukMerkezListeDlg) do begin
                                      with TSorumlulukMerkezListeDlg(Ornek) do begin
                                        GELIRMI := False;
                                        TabloYenile(TabSRMMerkezListe,[GELIRMI]);
                                      end;
                                   end;
                            end;
                            5:begin
                                   with FFrameBilgi.IcerikGit(TDagitimAnahtarlariDlg) do begin
                                      with TDagitimAnahtarlariDlg(Ornek) do begin
                                        GELIRMI := False;
                                        TabloYenile(TabDagitim,[GELIRMI]);
                                        TabloYenile(TabDagitimDetay,[TabDagitim.FieldByName('ID').AsInteger,GELIRMI]);
                                      end;
                                   end;
                            end;
                         end;
                     end;
                end;
                11:begin    /// Gelir
                    ListelerMenuGelir.Categories[0].Collapsed := False;
                    ListelerMenuGelir.Visible := True;
                    PanelGelirBelge.height := 154;
                    PanelGiderBelge.height := 52;

                    for I := 0 to ListelerMenuGelir.Categories[0].items.Count - 1 do
                      if ListelerMenuGelir.Categories[0].items[i].ImageIndex = 9 then begin
                         case StrToInt(ListelerMenuGelir.Categories[0].items[i].Hint) of
                            3:begin
                                 with FFrameBilgi.IcerikGit(TMasrafGelirDlg) do begin
                                      with TMasrafGelirDlg(Ornek) do begin
                                         GELIRMI := True;
                                         Caption := 'Gelir Merkezi';
                                         InitIslemler;
                                      end;
                                  end;
                            end;
                            4:begin
                                   with FFrameBilgi.IcerikGit(TSorumlulukMerkezListeDlg) do begin
                                      with TSorumlulukMerkezListeDlg(Ornek) do begin
                                        GELIRMI := True;
                                        TabloYenile(TabSRMMerkezListe,[GELIRMI]);
                                      end;
                                   end;
                            end;
                            5:begin
                                   with FFrameBilgi.IcerikGit(TDagitimAnahtarlariDlg) do begin
                                      with TDagitimAnahtarlariDlg(Ornek) do begin
                                        GELIRMI := True;
                                        TabloYenile(TabDagitim,[GELIRMI]);
                                        TabloYenile(TabDagitimDetay,[TabDagitim.FieldByName('ID').AsInteger,GELIRMI]);
                                      end;
                                   end;
                            end;
                         end;
                     end;
                end;

        end;
    end;
end;
procedure TKasaGorevFrame.FrameResize(Sender: TObject);
begin
  ListelerMenuGider.Visible := False;
  PanelGiderBelge.height :=52;
  ListelerMenuGelir.Visible := False;
  PanelGelirBelge.height :=52;
end;

procedure TKasaGorevFrame.MesajAlindi(AMesaj: Variant);
begin

end;

procedure TKasaGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Value.IcerikFrameYoneticisi.OnMesaj.Add(MesajAlindi);
  btnKasaTanimlari.Visible := Tablo.YetkiVarmi(2301,YetkiTur_Gorme);
  //btnMasrafMerkeziTanimlari.Visible := Tablo.YetkiVarmi(2311,YetkiTur_Gorme);
  btnGelirMerkeziTanimlari.Visible := Tablo.YetkiVarmi(2321,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(2399,YetkiTur_Gorme);
  if (not Tablo.YetkiVarmi(2305,YetkiTur_Gorme))and(not Tablo.YetkiVarmi(2306,YetkiTur_Gorme)) then
    Panel1.Visible:=False
  else if not Tablo.YetkiVarmi(2305,YetkiTur_Gorme) then begin
    btnFinansListe.Visible:=False;
    btnFinansTakvim.Align:=alClient;
  end else if not Tablo.YetkiVarmi(2306,YetkiTur_Gorme) then
    btnFinansTakvim.Visible := False;

  if not Tablo.YetkiVarmi(2313,YetkiTur_Gorme) then begin
      ListelerMenuGider.Categories[0].items[2].Free; //
      ListelerMenuGider.Categories[0].items[1].Free; //Daðýtým
      ListelerMenuGelir.Categories[0].items[2].Free; //
      ListelerMenuGelir.Categories[0].items[1].Free; //Daðýtým
  end;

end;

initialization
  RegisterClass(TKasaGorevFrame);
end.
