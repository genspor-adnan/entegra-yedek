unit URichEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, ComCtrls,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, cxTextEdit, cxMemo, cxRichEdit, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.StdCtrls, cxButtons;

type
  TRichEditDlg = class(TForm)
    Panel2: TPanel;
    RichEdit: TcxRichEdit;
    Panel1: TPanel;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    procedure cxButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    rtfString : Ansistring;
    YorumId, PersId : Integer;
    EkleTarih:TDateTime;
  end;

var
  RichEditDlg: TRichEditDlg;

function RichEditYorum(var Rtf : Ansistring; YorumId1:integer=0) : Integer;

implementation

uses UTablo, UGirisKutusuEx, PrjConst, FetaKurulusSiniflari;

{$R *.dfm}

function RichEditYorum(var Rtf : Ansistring; YorumId1:integer=0) : Integer;
begin
   Application.CreateForm(TRichEditDlg, RichEditDlg);
   RichEditDlg.rtfString := Rtf;
   RichEditDlg.YorumId := YorumId1;
   RichEditDlg.ShowModal;
   Result := RichEditDlg.ModalResult;
   Rtf := RichEditDlg.rtfString;
   RichEditDlg.Destroy;
end;


procedure TRichEditDlg.cxButton1Click(Sender: TObject);
//var stream    : TMemoryStream;
begin
    //Save to stream
{02/12/2022 AO bu kod yerine alttaki tek satır kod kullanıldı
    stream := TMemoryStream.Create;
    stream.Clear;

    RichEdit.Lines.SaveToStream(stream);
    stream.Position := 0;

    //Read from the stream into an AnsiString (rtfString)
    if (stream.Size > 0) then begin
        SetLength(rtfString, stream.Size);
        if (stream.Read(rtfString[1], stream.Size) <= 0) then
            raise EStreamError.CreateFmt('End of stream reached with %d bytes left to read.', [stream.Size]);
    end;

    stream.Free; }
    rtfString := RichEdit.EditValue;
end;

procedure TRichEditDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var Tarih, Personel:Variant;
    ctrls: TGirdiDenetimleri;
begin
  if (Shift = [ssAlt,ssCtrl]) and(
     (Key = Ord('d'))or(Key = Ord('D'))or(Key = Ord('t'))or(Key = Ord('T'))) then  begin

    Tarih := Tablo.GENINI.BugunTrhSaat;
    Personel:=Kullanan;
    ctrls := TGirdiDenetimleri.Create
       .ImageComboBox(kullanici, @Personel, Tablo.FDCnn, 'select ID, FIRMA,* from REHBER where GRUP=335 and DURUM>0 order by 2',False,nil)
       .DateTimePicker(BGTarih_gir+':', @Tarih, dtkDate);
    if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls) = mrOk then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update GOREVYORUM set EKLEYEN='+VarToStr(Personel)+',EKLEMETARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn', VarToDateTime(Tarih))+''' where ID='+IntToStr(YorumId),[],[]);

       //EkleTarih := Tarih;
       //PersId := Personel;
    end;
  end;

end;

procedure TRichEditDlg.FormShow(Sender: TObject);
var stream    : TMemoryStream;
begin
    //Get the data from the database as AnsiString
    //rtfString := sql.FieldByName('rtftext').AsAnsiString;
    //   sql.SQL.Text:= 'SELECT * FROM GOREVYORUM WHERE ID=1 ' ;
    //   sql.OPEN;
    //rtfString := sql.FieldByName('yorum').AsAnsiString;

    //Write the string into a stream
    stream := TMemoryStream.Create;
    stream.Clear;
    stream.Write(PAnsiChar(rtfString)^, Length(rtfString));
    stream.Position := 0;

    //Load the stream into the RichEdit
    //???? RichEdit.PlainText := False;
    RichEdit.Lines.LoadFromStream(stream);

    stream.Free;
end;

end.


