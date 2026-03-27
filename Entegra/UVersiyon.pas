unit UVersiyon;

interface

uses
  Windows, Messages, Classes, SysUtils, Graphics, Controls, StdCtrls, Forms,StrUtils,
  Dialogs, DBGrids, Grids, ExtCtrls, CheckLst, Menus, Buttons, jpeg, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, FireDAC.Comp.Client, cxImageComboBox, cxDropDownEdit, cxTextEdit, cxLabel, cxContainer, cxMaskEdit, cxCalendar,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, Vcl.ComCtrls, dxCore,
  cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  cxImage, dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TVersiyonDlg  = class(TForm)
    PanelAlt :TPanel;
    Memo1 :TMemo;
    PopupMenu1 :TPopupMenu;
    Komutugster1 :TMenuItem;
    CheckListBox1 :TCheckListBox;
    Panel3 :TPanel;
    btnUygula: TBitBtn;
    Image1 :TImage;
    Splitter1 :TSplitter;
    Ver20090701: TMemo;
    TabOlaylar: TFDQuery;
    DtsTabOlaylar: TDataSource;
    OlaylarGrid: TcxGrid;
    OlaylarGridView: TcxGridDBTableView;
    OlaylarGridLevel3: TcxGridLevel;
    OlaylarGridViewID: TcxGridDBColumn;
    OlaylarGridViewBILGI: TcxGridDBColumn;
    OlaylarGridViewEKLEMETARIHI: TcxGridDBColumn;
    btnKodGetir: TSpeedButton;
    btnUygula1: TSpeedButton;
    OlaylarGridViewBILGINO: TcxGridDBColumn;
    OlaylarGridViewDURUM: TcxGridDBColumn;
    PmDurum: TPopupMenu;
    Yapld1: TMenuItem;
    Yaplmad1: TMenuItem;
    Label1: TLabel;
    Panel2: TPanel;
    cxDateEdit1: TcxDateEdit;
    cxDateEdit2: TcxDateEdit;
    cxLabel1: TcxLabel;
    cxTextEdit1: TcxTextEdit;
    cxImageComboBox1: TcxImageComboBox;
    cxLabel3: TcxLabel;
    N1: TMenuItem;
    HepsiniSe1: TMenuItem;
    procedure DBGrid1DblClick(Sender :TObject);
    procedure CheckListBox1Click(Sender :TObject);
    procedure btnUygulaClick(Sender :TObject);
    procedure FormCreate(Sender :TObject);
    procedure Memo1KeyPress(Sender :TObject; var Key :Char);
    procedure btnKodGetirClick(Sender: TObject);
    procedure btnUygula1Click(Sender: TObject);
    procedure OlaylarGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure Yapld1Click(Sender: TObject);
    procedure OlaylarGridViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure TabOlaylarBeforeOpen(DataSet: TDataSet);
    procedure cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
    procedure HepsiniSe1Click(Sender: TObject);
    procedure cxTextEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private

    { private declarations }
  public
    { public declarations }
  end;

var
  VersiyonDlg :TVersiyonDlg;


implementation

uses UAnaForm,UTablo,GenUpdateWS,FetaKurulusSiniflari,FetaClassExtensions,PrjConst,LocOnFly;

{$R *.DFM}
var
  Ver :string[20];
  m :TMemo;
  GResult:ArrayOfGenUpdateWS_komutListe;
  SatirID:integer;

procedure TVersiyonDlg.DBGrid1DblClick(Sender :TObject);
begin
  Memo1.Visible := True;
end;

procedure TVersiyonDlg.CheckListBox1Click(Sender :TObject);
Var Versiyon:String;
begin
{  if copy(CheckListBox1.Items[CheckListBox1.ItemIndex], 5, 1) = '9' then
  begin
    Ver := copy(CheckListBox1.Items[CheckListBox1.ItemIndex], 1, 12);
    Ver := copy(ver, 1, 3) + copy(ver, 5, 1) + copy(ver, 7, 1) + copy(ver, 9, 1) + copy(ver, 11, 2);
    m := TMemo(VersiyonDlg.FindComponent(trim(ver)));
    Memo1.Text := m.text;
  end
  else
  begin
    Ver := copy(CheckListBox1.Items[CheckListBox1.ItemIndex], 1, 9);
    Ver := copy(ver, 1, 3) + copy(ver, 5, 2) + copy(ver, 8, 2);
    m := TMemo(VersiyonDlg.FindComponent(ver));
    Memo1.Text := m.text;
  end
}
  Versiyon := CheckListBox1.Items[CheckListBox1.ItemIndex];
  Versiyon := StringReplace(Versiyon,'Ver ','Ver',[]);
  Versiyon := copy( Versiyon, 1, pos(' ', Versiyon)-1 );
  Versiyon := StringReplace(Versiyon,'.','',[rfreplaceall]);
  ver:=  Versiyon ;

  m := TMemo(VersiyonDlg.FindComponent(ver));
   Memo1.Text := m.text;

end;

procedure TVersiyonDlg.cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
begin
  TabOlaylar.Close;
  TabOlaylar.Open;
end;

procedure TVersiyonDlg.cxTextEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  TabOlaylar.SQL.Text := 'Select * from OLAYLAR where KATEGORI=101 and EKLEMETARIHI between '''+
                        FormatDateTime('yyyy-MM-dd 00:00',cxDateEdit1.Date)+''' and '''+
                        FormatDateTime('yyyy-MM-dd 23:59',cxDateEdit2.Date)+''' and BILGI like ''%'+ cxTextEdit1.Text+'%''  ';
 if cxImageComboBox1.EditValue >=0 then
    TabOlaylar.SQL.Add(' and DURUM='+ IntToStr(cxImageComboBox1.EditValue));
 TabOlaylar.SQL.Add(' order by 1 desc');
 TabOlaylar.Open;
end;

procedure TVersiyonDlg.btnKodGetirClick(Sender: TObject);
var
i,j,KomutNo:integer;
begin
  Memo1.Lines.Clear;
  SatirID:=OlaylarGridView.DataController.FocusedRecordIndex;
  KomutNo:=TabOlaylar.FieldByName('BILGINO').AsInteger;
  GResult:=Guncelleme.guncelleme(1,KomutNo,KomutNo);
  for i := 0 to Length(GResult) - 1 do
    Memo1.Lines.Add(GResult[i].KOMUT);
  Memo1.Tag := TabOlaylar.FieldByName('ID').AsInteger;
end;

procedure TVersiyonDlg.btnUygula1Click(Sender: TObject);
var AltSorguHataSay:Integer;
begin
  if OlaylarGridView.Controller.SelectedRecordCount > 0 then begin
    if Trim(Memo1.Text)='' then
      ShowMessage(Uygulanacak_Komut_Hatasi)
    else Begin
      SatirID:=OlaylarGridView.DataController.FocusedRecordIndex;
      if TabOlaylar.Locate('ID',Memo1.Tag,[]) then begin
        Tablo.GuncellemeSatiriCalistir(Memo1.Text,AltSorguHataSay);
        if AltSorguHataSay=0 then begin
          TabOlaylar.Edit;
          TabOlaylar.FieldByName('DURUM').AsInteger:=1;
          TabOlaylar.Post;
          ShowMessage(Uygulama_tamam);
        end else begin
          ShowMessage(IntToStr(AltSorguHataSay)+Uygulanamayan_alt_sorgu_sayisi);
        end;
       end;
      TabOlaylar.Close;
      TabOlaylar.Open;
      OlaylarGridView.DataController.FocusedRecordIndex:=SatirID;
      OlaylarGridView.ViewData.Records[SatirID].Selected:=true;
    End;
  end else
    ShowMessage(Guncelleme_Satiri_Hatasi);
end;

procedure TVersiyonDlg.btnUygulaClick(Sender :TObject);
var
  kom :TStringList;
  i :smallint;

  procedure uyg;
  begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Clear;
    Tablo.Query1.SQL.AddStrings(kom);
    kom.clear;
    try
      Tablo.Query1.ExecSQL;
    except
      ShowMessage(Uygulandi);
    end;

  end;
  
begin
  { kom:=TStringList.Create;
   for i:=0 to Memo1.Lines.Count-1 do
      if Trim(Memo1.Lines[i])='GO' then
         uyg
      else
         kom.Add(Memo1.Lines[i]);
   if (pos('ALTER',uppercase(kom.Text))>0)or(pos('UPDATE',uppercase(kom.Text))>0)or(pos('INSERT',uppercase(kom.Text))>0) then
       uyg;
   Komutugster1Click(self);
   kom.free;    }

end;

procedure TVersiyonDlg.FormCreate(Sender :TObject);
var
  slist :TStringList;
  i, j :Smallint;
begin
{  slist := TStringList.Create;
  ReherIni.ReadSectionValues('Versiyonlar', slist);
  for i := 0 to slist.Count - 1 do
  begin
    ver := copy(slist.Strings[i], 1, 3) + ' ' + copy(slist.Strings[i], 4, 2) + '.' + copy(slist.Strings[i], 6, 2);
    for j := 0 to CheckListBox1.Items.Count - 1 do
      if pos(ver, CheckListBox1.Items[j]) > 0 then
        CheckListBox1.Checked[j] := True;
  end;
  slist.free;
}
  { slist := TStringList.Create;
   ReherIni.ReadSectionValues('Versiyonlar',slist);
   for i := 0 to slist.Count - 1 do begin
      ver:=copy(slist.Strings[i],1,3)+' '+copy(slist.Strings[i],4,1)+'.'+copy(slist.Strings[i],5,1)+'.'+copy(slist.Strings[i],6,1)+'.'+copy(slist.Strings[i],7,1);
      for j:=0 to CheckListBox1.Items.Count - 1 do
          if pos(ver, CheckListBox1.Items[j])>0 then
             CheckListBox1.Checked[j] := True;
   end;
   slist.free;
  }

    if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //OlaylarGridView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\OlaylarGüncellemeGridi',true,false,[gsoUseFilter],'OlaylarGüncellemeGridi');
  Tablo.GridAyarRestore('OlaylarGüncellemeGridi',OlaylarGridView );

  Tablo.GridTurkcelestir;

  cxDateEdit2.Date := Tablo.GENINI.BugunTrh;
end;

procedure TVersiyonDlg.HepsiniSe1Click(Sender: TObject);
begin
OlaylarGridView.DataController.SelectAll;
end;

procedure TVersiyonDlg.Memo1KeyPress(Sender :TObject; var Key :Char);
begin
  if (Key in ['A'..'Z']) or (Key in ['a'..'z']) then
    raise exception.Create(Degistirilmez)
end;

procedure TVersiyonDlg.OlaylarGridViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=OlaylarGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=OlaylarGridView;
  AnaForm.pmGridStil.Tags.Values[OlaylarGrid.Name] := 'OlaylarGüncellemeGridi';
end;

procedure TVersiyonDlg.OlaylarGridViewSelectionChanged(Sender: TcxCustomGridTableView);
begin
  if SatirID<>OlaylarGridView.DataController.FocusedRecordIndex then
    Memo1.Lines.Clear;
end;

procedure TVersiyonDlg.TabOlaylarBeforeOpen(DataSet: TDataSet);
begin
  TabOlaylar.SQL.Text := 'Select * from OLAYLAR where KATEGORI=101 and EKLEMETARIHI between '''+
                        FormatDateTime('yyyy-MM-dd 00:00',cxDateEdit1.Date)+''' and '''+
                        FormatDateTime('yyyy-MM-dd 23:59',cxDateEdit2.Date)+''' and BILGI like ''%'+ cxTextEdit1.Text+'%''  ';
 if cxImageComboBox1.EditValue >=0 then
    TabOlaylar.SQL.Add(' and DURUM='+ IntToStr(cxImageComboBox1.EditValue));
 TabOlaylar.SQL.Add(' order by 1 desc');
end;

procedure TVersiyonDlg.Yapld1Click(Sender: TObject);
var
i,OlayID,Recordindex:integer;
begin
  if OlaylarGridView.DataController.GetSelectedCount = 1 then begin
    TabOlaylar.Edit;
    TabOlaylar.FieldByName('DURUM').AsInteger:=(Sender as TMenuItem).Tag;
    TabOlaylar.Post;
  end else  if OlaylarGridView.DataController.GetSelectedCount > 1 then begin
    for I := 0 to OlaylarGridView.DataController.GetSelectedCount - 1 do begin
      Recordindex := OlaylarGridView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
      OlayID := OlaylarGridView.DataController.Values[Recordindex,TabOlaylar.FieldByName('ID').Index];
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update OLAYLAR set DURUM ='+IntToStr((Sender as TMenuItem).Tag)+' Where ID ='+IntToStr(OlayID)+' ',[],[]);
    end;
    TabOlaylar.Close;
    TabOlaylar.Open;
  end else begin
    ShowMessage(Listeden_sec);
    Abort;
  end;
end;

end.





