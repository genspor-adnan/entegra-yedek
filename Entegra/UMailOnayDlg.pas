unit UMailOnayDlg;

// e-Arsiv akisinda alicinin email adres(ler)ini onayina sunan modal dialog.
// Mevcut email gosterilir, kullanici onayla veya degistirebilir.
// Birden fazla email virgulle ayrilabilir.

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxLabel, cxButtons, cxLookAndFeels, cxLookAndFeelPainters, dxCore,
  dxCoreGraphics, dxSkinsCore, dxSkinscxPCPainter, dxSkinLondonLiquidSky;

type
  TMailOnayDlg = class(TForm)
    PanelUst: TPanel;
    LblBaslik: TcxLabel;
    LblCariAdi: TcxLabel;
    LblMailAciklama: TcxLabel;
    EditMail: TcxTextEdit;
    PanelAlt: TPanel;
    BtnOnayla: TcxButton;
    BtnIptal: TcxButton;
    procedure BtnOnaylaClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
  private
    function EmailGecerliMi(const AMail: string): Boolean;
  end;

/// Modal mail onay dialogu. ACariAdi+AMevcutMail ile acilir, kullanici
/// onayladigi (veya duzenledigi) mail listesini AYeniMail'e yazar.
/// Result: True = onaylandi, False = iptal.
function MailOnayAl(const ACariAdi: string; const AMevcutMail: string;
  out AYeniMail: string): Boolean;

implementation

{$R *.dfm}

uses System.StrUtils, System.RegularExpressions;

function TMailOnayDlg.EmailGecerliMi(const AMail: string): Boolean;
// RFC 5322 basitlestirilmis regex � pratik kontrol
const
  C_PATTERN = '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$';
var
  Tmp: string;
begin
  Tmp := Trim(AMail);
  if (Tmp = '') or (Length(Tmp) > 254) then Exit(False);
  if Pos(' ', Tmp) > 0 then Exit(False);
  // Birden fazla '@' veya ardisik '.' kabul edilmez
  if Length(Tmp) - Length(StringReplace(Tmp, '@', '', [rfReplaceAll])) <> 1 then
    Exit(False);
  if Pos('..', Tmp) > 0 then Exit(False);
  Result := TRegEx.IsMatch(Tmp, C_PATTERN);
end;

procedure TMailOnayDlg.BtnOnaylaClick(Sender: TObject);
var
  Parcalar: TArray<string>;
  Tek: string;
  Hatali: TStringList;
begin
  if Trim(EditMail.Text) = '' then begin
    ShowMessage('Mail adresi boş olamaz.');
    EditMail.SetFocus;
    Exit;
  end;
  Parcalar := SplitString(EditMail.Text, ',');
  Hatali := TStringList.Create;
  try
    for Tek in Parcalar do
      if not EmailGecerliMi(Tek) then Hatali.Add(Trim(Tek));
    if Hatali.Count > 0 then begin
      ShowMessage('Geçersiz mail formatı:' + sLineBreak + Hatali.Text);
      EditMail.SetFocus;
      Exit;
    end;
  finally
    Hatali.Free;
  end;
  ModalResult := mrOk;
end;

procedure TMailOnayDlg.BtnIptalClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function MailOnayAl(const ACariAdi: string; const AMevcutMail: string;
  out AYeniMail: string): Boolean;
var
  Dlg: TMailOnayDlg;
begin
  Result := False;
  AYeniMail := '';
  Dlg := TMailOnayDlg.Create(nil);
  try
    Dlg.LblCariAdi.Caption := ACariAdi;
    Dlg.EditMail.Text := AMevcutMail;
    if Trim(AMevcutMail) = '' then
      Dlg.LblMailAciklama.Caption := 'Müşterinin kayıtlı mail adresi yok. Lütfen girin (birden fazla için virgülle ayırın):'
    else
      Dlg.LblMailAciklama.Caption := 'Mevcut mail adres(ler)i — onaylayın veya düzenleyin (birden fazla için virgülle):';
    if Dlg.ShowModal = mrOk then begin
      AYeniMail := Trim(Dlg.EditMail.Text);
      Result := AYeniMail <> '';
    end;
  finally
    Dlg.Free;
  end;
end;

end.
