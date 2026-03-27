unit UGrid;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, UCombo,
  Buttons, ExtCtrls, Grids, Menus, Dialogs;

type
  TGridAyarlaDlg = class(TForm)
    Bevel1: TBevel;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Grid1: TStringGrid;
    GridBaslik: TStringGrid;
    PopupMenu1: TPopupMenu;
    FontPunroayarlarnGetir1: TMenuItem;
    BurayFontPuntoiledoldur1: TMenuItem;
    N1: TMenuItem;
    Renk1: TMenuItem;
    ColorDialog1: TColorDialog;
    procedure FormShow(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure FontPunroayarlarnGetir1Click(Sender: TObject);
    procedure BurayFontPuntoiledoldur1Click(Sender: TObject);
    procedure Renk1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GridAyarlaDlg: TGridAyarlaDlg;
procedure GridIniDuzenle(AnahtarKelime1: string; Ini1: TIni; KolonSay: Integer; Baslik: string; IndexAlanSay1: Integer);

implementation
uses UMesaj, FetaUtil, UTablo;
{$R *.DFM}
var
  i, j, say, IndexAlanSay: integer;
  AnahtarKelime: string;
  Ini: TIni;
  Kurumlar, Bilgi: TStringlist;
  s: string;

procedure GridIniDuzenle(AnahtarKelime1: string; Ini1: TIni; KolonSay: Integer; Baslik: string; IndexAlanSay1: Integer);
begin
  Application.CreateForm(TGridAyarlaDlg, GridAyarlaDlg);
  GridAyarlaDlg.GridBaslik.ColCount := KolonSay;
  GridAyarlaDlg.Grid1.ColCount := KolonSay;
  AnahtarKelime := AnahtarKelime1;
  IndexAlanSay := IndexAlanSay1;
  Ini := Ini1;
  Kurumlar := TStringlist.Create;
  Bilgi := TStringlist.Create;
  Parcala(Baslik, Bilgi);
  for i := 0 to Bilgi.Count - 1 do
    GridAyarlaDlg.GridBaslik.Cells[i, 0] := Bilgi.Strings[i];
  GridAyarlaDlg.ShowModal;
    //ListeAyarlaDlg.Free;
end;

procedure TGridAyarlaDlg.FormShow(Sender: TObject);
begin
  Grid1.ColWidths[0] := 120;
  Grid1.ColWidths[1] := 80;
  GridBaslik.ColWidths[0] := 120;
  GridBaslik.ColWidths[1] := 80;
  Ini.ReadSection(AnahtarKelime, Kurumlar);
  for i := 0 to Kurumlar.Count - 1 do begin
    Grid1.RowCount := Grid1.RowCount + 1;
    if IndexAlanSay > 1 then begin
      Parcala(Kurumlar.Strings[i], Bilgi);
      for j := 0 to Bilgi.Count - 1 do
        Grid1.Cells[j, i] := Bilgi.Strings[j];
    end
    else
      Grid1.Cells[0, i] := Kurumlar.Strings[i];

//      s := Ini.ReadString(AnahtarKelime, Kurumlar.Strings[i],'');
    Parcala(Ini.ReadString(AnahtarKelime, Kurumlar.Strings[i], ''), Bilgi);
    for j := 0 to Bilgi.Count - 1 do
      Grid1.Cells[j + IndexAlanSay, i] := Bilgi.Strings[j];
  end;
  Grid1.RowCount := Grid1.RowCount - 1; //Son Satýrý siler...
end;

procedure TGridAyarlaDlg.SilTusClick(Sender: TObject);
begin
  for i := Grid1.Row to Grid1.RowCount - 1 do
    Grid1.Rows[i] := Grid1.Rows[i + 1];
  Grid1.RowCount := Grid1.RowCount - 1;
end;

procedure TGridAyarlaDlg.EkleTusClick(Sender: TObject);
var MesajOkunan: string;
begin
  if TBitBtn(Sender).Name = 'EkleTus' then
    MesajOkunan := ''
  else
    MesajOkunan := Grid1.Cells[0, Grid1.Row];

  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil, MesajOkunan, '', 'E', nil, MesajOkunan) then
    if TBitBtn(Sender).Name = 'EkleTus' then begin
      Grid1.RowCount := Grid1.RowCount + 1;
      Grid1.Row := Grid1.RowCount - 1;
    end;
  Grid1.Cells[0, Grid1.Row] := MesajOkunan;
end;

procedure TGridAyarlaDlg.BitBtn2Click(Sender: TObject);
var anah, deger: string[50];
begin
  Ini.EraseSection(AnahtarKelime);
  for i := 0 to Grid1.RowCount - 1 do begin
    anah := Grid1.Cells[0, i];
    if anah <> '' then begin
      for j := 1 to IndexAlanSay - 1 do
        anah := anah + ',' + Grid1.Cells[j, i];

      deger := Grid1.Cells[IndexAlanSay, i];
      for j := IndexAlanSay + 1 to Grid1.ColCount - 1 do
        deger := deger + ',' + Grid1.Cells[j, i];

      Ini.WriteString(AnahtarKelime, anah, deger);
    end;
  end;
end;

procedure TGridAyarlaDlg.UstTusClick(Sender: TObject);
begin
  if Grid1.Row = 0 then exit;
  for j := 0 to Grid1.ColCount - 1 do
    Kurumlar.Strings[j] := Grid1.Cells[j, Grid1.Row - 1];
  Grid1.Rows[Grid1.Row - 1] := Grid1.Rows[Grid1.Row];
  Grid1.Rows[Grid1.Row] := Kurumlar;
  Grid1.Row := Grid1.Row - 1;
end;

procedure TGridAyarlaDlg.AltTusClick(Sender: TObject);
begin
  if Grid1.Row = Grid1.RowCount - 1 then exit;
  for j := 0 to Grid1.ColCount - 1 do
    Kurumlar.Strings[j] := Grid1.Cells[j, Grid1.Row + 1];
  Grid1.Rows[Grid1.Row + 1] := Grid1.Rows[Grid1.Row];
  Grid1.Rows[Grid1.Row] := Kurumlar;
  Grid1.Row := Grid1.Row + 1;
end;

procedure TGridAyarlaDlg.FontPunroayarlarnGetir1Click(Sender: TObject);
  procedure YAZ;
  begin
    Ini.EraseSection(AnahtarKelime);
    for i := 0 to Grid1.RowCount - 1 do begin
      s := Grid1.Cells[1, i];
      for j := 0 to Grid1.ColCount - 3 do
        s := s + ',' + Grid1.Cells[j + 2, i];
      Ini.WriteString(AnahtarKelime, Grid1.Cells[0, i], s);
    end;
  end;
begin
  Ini.Free;
  Ini := TIni.Create('COCUKINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('DISINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('DAHILIYEINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('CILDIYEINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('ORTOPEDIINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('FTRINI', Tablo.IniSQL); YAZ;
  Ini.Free;
//   Ini := TIni.Create('PLAS_CERINI', Tablo.IniSQL);YAZ;
  Ini := TIni.Create('GOZINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('JINEKOINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('KBBINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('KARDIYOINI', Tablo.IniSQL); YAZ;
  Ini.Free;
  Ini := TIni.Create('UROLOJIINI', Tablo.IniSQL); YAZ;
  Ini.Free;

end;

procedure TGridAyarlaDlg.BurayFontPuntoiledoldur1Click(Sender: TObject);
begin
  Grid1.RowCount := 9;
  Grid1.Cells[0, 0] := 'BASLIK'; Grid1.Cells[1, 0] := 'Times New Roman'; Grid1.Cells[2, 0] := '12'; Grid1.Cells[3, 0] := 'Bold'; Grid1.Cells[4, 0] := 'clNavy';
  Grid1.Cells[0, 1] := 'GRUPBASLIK'; Grid1.Cells[1, 1] := 'Times New Roman'; Grid1.Cells[2, 1] := '11'; Grid1.Cells[3, 1] := 'Bold'; Grid1.Cells[4, 1] := 'clRed';
  Grid1.Cells[0, 2] := 'LABELEDIT'; Grid1.Cells[1, 2] := 'Times New Roman'; Grid1.Cells[2, 2] := '11'; Grid1.Cells[3, 2] := 'Bold'; Grid1.Cells[4, 2] := 'clGreen';
  Grid1.Cells[0, 3] := 'EDIT'; Grid1.Cells[1, 3] := 'Times New Roman'; Grid1.Cells[2, 3] := '11'; Grid1.Cells[3, 3] := 'Normal'; Grid1.Cells[4, 3] := 'clBlack';
  Grid1.Cells[0, 4] := 'LABELCOMBO'; Grid1.Cells[1, 4] := 'Times New Roman'; Grid1.Cells[2, 4] := '11'; Grid1.Cells[3, 4] := 'Bold'; Grid1.Cells[4, 4] := 'clGreen';
  Grid1.Cells[0, 5] := 'COMBO'; Grid1.Cells[1, 5] := 'Times New Roman'; Grid1.Cells[2, 5] := '11'; Grid1.Cells[3, 5] := 'Normal'; Grid1.Cells[4, 5] := 'clBlack';
  Grid1.Cells[0, 6] := 'RADIOBUTTON'; Grid1.Cells[1, 6] := 'Times New Roman'; Grid1.Cells[2, 6] := '11'; Grid1.Cells[3, 6] := 'Normal'; Grid1.Cells[4, 6] := 'clBlack';
  Grid1.Cells[0, 7] := 'CHECKBOX'; Grid1.Cells[1, 7] := 'Times New Roman'; Grid1.Cells[2, 7] := '11'; Grid1.Cells[3, 7] := 'Normal'; Grid1.Cells[4, 7] := 'clBlack';
  Grid1.Cells[0, 8] := 'MEMO'; Grid1.Cells[1, 8] := 'Times New Roman'; Grid1.Cells[2, 8] := '11'; Grid1.Cells[3, 8] := 'Normal'; Grid1.Cells[4, 8] := 'clBlack';
end;

procedure TGridAyarlaDlg.Renk1Click(Sender: TObject);
begin
  if ColorDialog1.Execute then
    Grid1.Cells[Grid1.Col, Grid1.Row] := colortostring(ColorDialog1.Color);
end;

end.
