unit UHizliSiparisSecim;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinLondonLiquidSky, cxLabel, JvExControls, JvButton, JvNavigationPane,
  Vcl.Menus, cxTextEdit, cxDBEdit, Vcl.StdCtrls, cxButtons, cxScrollBox,cxCheckGroup,
  cxGroupBox, cxRadioGroup, cxDBLabel, cxImage, Vcl.ExtCtrls, cxCheckBox, UTouchKeyboardWindow;

type
  THizliSiparisSecim = class(TForm)
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    cxLabel8: TcxLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Resim: TcxImage;
    LabelAd: TcxLabel;
    LabelAciklama: TcxLabel;
    LabelFiyat: TcxLabel;
    RadioAdet: TcxRadioGroup;
    ScrollBox1: TcxScrollBox;
    KaydetTus: TJvNavPanelButton;
    ButtonAdet: TcxButton;
    cxLabel1: TcxLabel;
    EditMesaj: TcxTextEdit;
    CheckIkram: TcxCheckBox;
    Image3: TImage;
    procedure ButtonAdetClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure RadioAdetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CheckIkramClick(Sender: TObject);
    procedure SecimOnClick(Sender: TObject);
  private
    { Private declarations }
    Klavye1 : TKeyboardWindow;
    procedure TutarHesapla;
  public
    { Public declarations }
    StokId,FId : Integer;
    Fiyat : Currency;
  end;

var
  HizliSiparisSecim: THizliSiparisSecim;

implementation

uses UHizliGirisIsk, UTablo, FetaKurulusSiniflari,UHizliGiris,FetaUtil;

{$R *.dfm}


procedure THizliSiparisSecim.TutarHesapla;
var Adet: Real;
    i,j : smallint;
    s:string;
    SecilenTutar , Tutar : Currency;
begin
   if CheckIkram.Checked then
       Tutar := 0
   else begin
       SecilenTutar:=0;
       for I := 0 to ScrollBox1.ComponentCount-1 do
          if (ScrollBox1.Components[i] is TcxRadioGroup)  then
              SecilenTutar := SecilenTutar+TcxRadioGroup(ScrollBox1.Components[i]).Properties.Items[TcxRadioGroup(ScrollBox1.Components[i]).ItemIndex].value
          else if (ScrollBox1.Components[i] is TcxCheckGroup)  then
              for J := 0 to TcxCheckGroup(ScrollBox1.Components[i]).Properties.Items.Count-1 do
                  if TcxCheckGroup(ScrollBox1.Components[i]).States[j]=cbsChecked then begin
                     s:=TcxCheckGroup(ScrollBox1.Components[i]).Properties.Items[j].caption;// abc[7,5]
                     s:=copy(s,pos('[',s)+1, pos(CariDoviz+']',s)- pos('[',s)-2);
                     SecilenTutar := SecilenTutar+StrToFloatDef(s,0);
                  end;


       if HizliSiparisSecim.RadioAdet.ItemIndex > 0 then
          Adet := HizliSiparisSecim.RadioAdet.ItemIndex+1
       else
          Adet := StrToIntDef(HizliSiparisSecim.ButtonAdet.Caption,1);
       Tutar := Adet * (Fiyat+SecilenTutar);
   end;
   LabelFiyat.Caption:=Format( '%f '+CariDoviz, [Tutar]);
end;

procedure THizliSiparisSecim.ButtonAdetClick(Sender: TObject);
var Adet : Real;
begin
    Adet := AdetGetir('Adet giriniz','1', 0,0, False );
    if Adet<>-9999 then begin
       RadioAdet.ItemIndex := -1;
       ButtonAdet.Caption := FloatToStr(Adet);
       TutarHesapla;
    end;
end;

procedure THizliSiparisSecim.CheckIkramClick(Sender: TObject);
begin
   TutarHesapla;
end;

procedure THizliSiparisSecim.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if Klavye1 <> nil then begin
      Klavye1.HideKeyboard;
      FreeAndNil(Klavye1);
   end;
end;

procedure THizliSiparisSecim.SecimOnClick(Sender: TObject);
begin
   if Active then
      TutarHesapla;
end;

procedure THizliSiparisSecim.FormShow(Sender: TObject);
var TopArtis,i : SmallInt;
    s:String[20];
   procedure SecimOlustur;
   begin
      Tablo.TablodanSorguAc(6,'SELECT ID, TUR,SECIMADI,TUTAR=isnull(TUTAR,0),SECILI=isnull(SECILI,0) FROM SECIMLER WHERE BAGID='+Tablo.Query8.FieldByName('SECIMID').AsString+' ORDER BY SIRA,ID');
      case Tablo.Query8.FieldByName('TUR').AsInteger of
        1 :  begin//tek seçim
              with TcxRadioGroup.Create(ScrollBox1) do begin
                Name := 'Ad'+Tablo.Query8.FieldByName('SECIMID').AsString;
                Parent := ScrollBox1;
                Caption := Tablo.Query8.FieldByName('SECIMADI').AsString;
                Tag:= Tablo.Query8.FieldByName('SECIMID').AsInteger;
                Left := 3 ;
                Top := 10 + TopArtis;
                Width := 550;
                Height := 50;//+Tablo.Query6.RecordCount*24;
                Style.Font.Name:='Trebuchet MS';
                Style.Font.Size := 10;
                OnClick := SecimOnClick;
                Properties.Columns := Tablo.Query6.RecordCount;
                while not Tablo.Query6.eof do begin
                  if Tablo.Query6.FieldByName('TUTAR').AsCurrency>0 then
                      s:=Format(' [%f '+CariDoviz+']', [Tablo.Query6.FieldByName('TUTAR').AsCurrency])
                  else
                      s := '';
                  with Properties.Items.Add do begin
                    Tag:= Tablo.Query6.FieldByName('ID').AsInteger;
                    Caption := Tablo.Query6.FieldByName('SECIMADI').AsString+s;
                    value:= Tablo.Query6.FieldByName('TUTAR').AsCurrency;
                  end;
                  Tablo.Query6.next;
                end;
                ItemIndex := 0;
              end;
              TopArtis := TopArtis+50 ;
        end;
        2 : begin//çok seçim
              with TcxCheckGroup.Create(ScrollBox1) do begin
                Name := 'Ad'+Tablo.Query8.FieldByName('SECIMID').AsString;
                Parent := ScrollBox1;
                Tag:= Tablo.Query8.FieldByName('SECIMID').AsInteger;
                Caption := Tablo.Query8.FieldByName('SECIMADI').AsString;
                Left := 3 ;
                Top := 10 + TopArtis;
                Width := 550;
                Height := 50 + (30* (Tablo.Query6.RecordCount div 6));
                Style.Font.Name:='Trebuchet MS';
                Style.Font.Size := 10;
                //Properties.OnChange := SecimOnClick;
                Properties.OnEditValueChanged := SecimOnClick;
                Properties.Columns := 3;
                i:=0;
                while not Tablo.Query6.eof do begin
                  if Tablo.Query6.FieldByName('TUTAR').AsCurrency>0 then
                      s:=Format(' [%f '+CariDoviz+']', [Tablo.Query6.FieldByName('TUTAR').AsCurrency])
                  else
                      s := '';
                  with Properties.Items.Add do begin
                    Caption := Tablo.Query6.FieldByName('SECIMADI').AsString+s;
                    if Tablo.Query6.FieldByName('SECILI').AsBoolean then
                       States[i] := cbsChecked;
                    //Tag:=StrToInt(CurrToStrF(Tablo.Query6.FieldByName('TUTAR').AsExtended*100,ffFixed, 0));
                    Tag:= Tablo.Query6.FieldByName('ID').AsInteger;
                  end;
                  inc(i);
                  Tablo.Query6.next;
                end;
                //ItemIndex := 0;
          //      ComboList.Add(TComponent(CurrentInstance));
              end;
              TopArtis := TopArtis+50 + (30* (Tablo.Query6.RecordCount div 6));
        end;
      end;
   end;
begin
   CheckIkram.Visible := Tablo.YetkiVarmi(18020612,YetkiTur_Gorme,False);
   TutarHesapla;
   Tablo.TablodanSorguAc(8,'SELECT TUR,SECIMID,SECIMADI,ZORUNLU FROM STOKSECIM SS '+
      'inner join SECIMLER S on SS.SECIMID=S.ID WHERE STOKID='+IntToStr(StokId)+' ORDER BY SS.SIRA,STOKID');
   TopArtis:=10;
   while not Tablo.Query8.eof do begin
      SecimOlustur;
      Tablo.Query8.next;
   end;
end;

procedure THizliSiparisSecim.Image3Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    EditMesaj.SetFocus;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := Top + Height-300;

  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
  end;
end;

procedure THizliSiparisSecim.KapatTusClick(Sender: TObject);
begin
   ModalResult:= mrcancel;
end;

procedure THizliSiparisSecim.KaydetTusClick(Sender: TObject);
   procedure SecimleriKaydet;
   var I,J, SecimBasId,SecimAltId: Integer;
       SecilenTutar : currency;
       s,Secili: String[30];
   begin
      for I := 0 to ScrollBox1.ComponentCount-1 do begin
          if (ScrollBox1.Components[i] is TcxRadioGroup)  then begin //Tekli seçim
              SecimBasId := TcxRadioGroup(ScrollBox1.Components[i]).Tag;
              SecimAltId := TcxRadioGroup(ScrollBox1.Components[i]).Properties.Items[TcxRadioGroup(ScrollBox1.Components[i]).ItemIndex].Tag;
              SecilenTutar := TcxRadioGroup(ScrollBox1.Components[i]).Properties.Items[TcxRadioGroup(ScrollBox1.Components[i]).ItemIndex].value / 100;
          end
          else if (ScrollBox1.Components[i] is TcxCheckGroup)  then begin
              for J := 0 to TcxCheckGroup(ScrollBox1.Components[i]).Properties.Items.Count-1 do
                  if TcxCheckGroup(ScrollBox1.Components[i]).States[j]=cbsChecked then begin
                     SecimBasId := TcxCheckGroup(ScrollBox1.Components[i]).tag;
                     SecimAltId := TcxCheckGroup(ScrollBox1.Components[i]).Properties.Items[j].tag;
                     s:=TcxCheckGroup(ScrollBox1.Components[i]).Properties.Items[j].caption;// abc[7,5]
                     s:=copy(s,pos('[',s)+1, pos(CariDoviz+']',s)- pos('[',s)-2);
                     SecilenTutar := SecilenTutar+StrToFloatDef(s,0);
                     Secili:='1';
                     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into '+HizliGirisDlg.AktifFatSecimTabloAdi+' (FATURAID,SECIMBASID,SECIMALTID,SECILI, TUTAR,KUR) values '+
                       '('+IntToStr(Fid)+','+ IntToStr(SecimBasId)+','+  IntToStr(SecimAltId)+','+Secili+','+ Float_ToStr(SecilenTutar)+',''' +CariDoviz+''')',[],[]);
                  end;
          end;
      end;
   end;
begin
   SecimleriKaydet;
   ModalResult:= mrOk;
end;

procedure THizliSiparisSecim.RadioAdetClick(Sender: TObject);
begin
   ButtonAdet.Caption := 'Özel';
   TutarHesapla;
end;

end.


