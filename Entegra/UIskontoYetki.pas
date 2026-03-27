unit UIskontoYetki;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, FireDAC.Comp.Client, Vcl.ExtCtrls,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, Vcl.ComCtrls, Vcl.ToolWin, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox,
  Vcl.StdCtrls, UTablo, cxButtonEdit, Vcl.Menus, UKategori, UGirisKutusuEx, FetaKurulusSiniflari, Vcl.Buttons;

type
  TIskontoYetkiDlg = class(TForm)
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    Panel1: TPanel;
    TabIskontoYetki: TFDQuery;
    DtsIskontoYetki: TDataSource;
    Label8: TLabel;
    ComboIcerik: TcxImageComboBox;
    Label3: TLabel;
    ComboGRUBU: TcxImageComboBox;
    Label5: TLabel;
    ComboOZELLIK: TcxImageComboBox;
    Label6: TLabel;
    ComboMARKA: TcxImageComboBox;
    Label1: TLabel;
    EditKodu: TcxTextEdit;
    LabelAdi: TLabel;
    EditAdi: TcxTextEdit;
    EditKategori: TcxButtonEdit;
    Label2: TLabel;
    PopupIslemler: TPopupMenu;
    SecililereIskontoGir: TMenuItem;
    TumuneIskontoGir: TMenuItem;
    TTumRoller: TMenuItem;
    STumRoller: TMenuItem;
    cxGrid1DBTableView1: TcxGridDBTableView;
    Panel2: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    procedure AramaYap;
    Function TempTabloOlustur: String;
    Function TempTabloDoldur(TabloAdi: String): Boolean;
    procedure FormShow(Sender: TObject);
    procedure EditKoduPropertiesEditValueChanged(Sender: TObject);
    procedure EditKoduKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    Procedure GridDoldur;
    procedure EditKategoriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SecililereClick(Sender: TObject);
    procedure TumuneClick(Sender: TObject);
    function SeciliSatirIDleriniGetir:string;
    procedure KaydetTusClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    AktifTabloAdi:String;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  IskontoYetkiDlg: TIskontoYetkiDlg;

implementation

{$R *.dfm}


procedure TIskontoYetkiDlg.AramaYap;
begin
  TabIskontoYetki.Close;
  TabIskontoYetki.SQL.Text := 'select * from '+AktifTabloAdi+' where 1=1 ';
  if EditKodu.Text <> '' then
    TabIskontoYetki.SQL.Add(' and KOD like '''+EditKodu.Text+'%''');
  if EditAdi.Text <> '' then
    TabIskontoYetki.SQL.Add(' and STOKADI like '''+EditAdi.Text+'%''');
  if ComboIcerik.Text <> '' then
    TabIskontoYetki.SQL.Add(' and ICERIK='+VarToStrDef(ComboIcerik.EditValue,'0'));
  if ComboGRUBU.Text <> '' then
    TabIskontoYetki.SQL.Add(' and GRUBU='+VarToStrDef(ComboGRUBU.EditValue,'0'));
  if ComboOZELLIK.Text <> '' then
    TabIskontoYetki.SQL.Add(' and OZELLIK='+VarToStrDef(ComboOZELLIK.EditValue,'0'));
  if ComboMARKA.Text <> '' then
    TabIskontoYetki.SQL.Add(' and MARKA='+VarToStrDef(ComboMARKA.EditValue,'0'));
  if EditKategori.Text <> '' then
    TabIskontoYetki.SQL.Add(' and KATEGORI='+IntToStr(EditKategori.Tag));
  TabIskontoYetki.Open;
end;



Function TIskontoYetkiDlg.TempTabloOlustur: String;
var
  SubMenuItem:TMenuItem;
begin // DROP EDİLMEYECEK!!!!!
  Result := '##ISKYETKI_' + IntToStr(SPID) + '_' + FormatDateTime('YYYYMMDDHHNNSSZZ', Tablo.GENINI.BugunTrhSaat);
  Tablo.TablodanSorguAc(1,'select * from ROLLER where DURUM=1');
  //tablo create edilecek
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := ' CREATE TABLE ' + Result;
  Tablo.Query2.SQL.Add(' (ID int identity(1,1),TUR int ,URUNID int,KOD nvarchar(50),STOKADI nvarchar(500),KATEGORI int,GRUBU int,MARKA int,OZELLIK int,ICERIK int');
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    Tablo.Query2.SQL.Add(' ,['+Tablo.Query1.FieldByName('ROL').AsString+'] int ');
    //hazır içeride dönüyorken popup menüye rol isimlerine göre sub menü de oluşturalım....
    SubMenuItem := PopupIslemler.CreateMenuItem;
    SubMenuItem.Caption := Tablo.Query1.FieldByName('ROL').AsString;
    SubMenuItem.Name := 'S'+StringReplace(Tablo.Query1.FieldByName('ID').AsString,'-','_',[]);
    SubMenuItem.Tag := Tablo.Query1.FieldByName('ID').AsInteger;
    SecililereIskontoGir.Add(SubMenuItem);
    SubMenuItem.OnClick := SecililereClick;

    SubMenuItem := PopupIslemler.CreateMenuItem;
    SubMenuItem.Caption := Tablo.Query1.FieldByName('ROL').AsString;
    SubMenuItem.Name := 'T'+StringReplace(Tablo.Query1.FieldByName('ID').AsString,'-','_',[]);
    SubMenuItem.Tag := Tablo.Query1.FieldByName('ID').AsInteger;
    TumuneIskontoGir.Add(SubMenuItem);
    SubMenuItem.OnClick := TumuneClick;

    Tablo.Query1.Next;
  end;
  Tablo.Query2.SQL.Add(',CONSTRAINT [PK_'+Result+'] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY])');
  Tablo.Query2.ExecSQL;
  //tabloya aramalar için bir index eklenecek
  Tablo.Query3.SQL.Text := ' CREATE NONCLUSTERED INDEX [NCI_'+Result+'] ON '+Result;
  Tablo.Query3.SQL.Add(' (TUR,URUNID,KATEGORI,GRUBU,MARKA,OZELLIK,ICERIK) include (KOD,STOKADI ');
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    Tablo.Query3.SQL.Add(' ,['+Tablo.Query1.FieldByName('ROL').AsString+'] ');
    Tablo.Query1.Next;
  end;
  Tablo.Query3.SQL.Add(') ');
  Tablo.Query3.ExecSQL;
end;

function TIskontoYetkiDlg.SeciliSatirIDleriniGetir:string;
var
  I: Integer;
  str:string;
begin
  str := '0';
  if cxGrid1DBTableView1.Controller.SelectedRecordCount > 1 then begin
    for I := 0 to cxGrid1DBTableView1.Controller.SelectedRecordCount - 1 do
      str := str + ',' + VarToStr( cxGrid1DBTableView1.Controller.SelectedRecords[i].Values[cxGrid1DBTableView1.GetColumnByFieldName('ID').Index]   );
  end;
  Result := str;
end;

procedure TIskontoYetkiDlg.SecililereClick(Sender: TObject);
var
  ctrls: TGirdiDenetimleri;
  Iskonto: Variant;
begin
  ctrls := TGirdiDenetimleri.Create.Edit('İskonto Oranını', @Iskonto);
  if TGirisKutusuEx.BilgiAlEx('İskonto Oranı', ctrls) = mrOk then begin
    if StrToIntDef(VarToStrDef(Iskonto,''),0)>0 then begin
      if cxGrid1DBTableView1.Controller.SelectedRecordCount>0 then begin
        if (Sender as TMenuItem).Tag=0 then begin
          Tablo.TablodanSorguAc(1,'select * from ROLLER');
        end else begin
          Tablo.TablodanSorguAc(1,'select * from ROLLER where ID = ' + IntToStr((Sender as TMenuItem).Tag));
        end;
        Tablo.Query1.First;
        while not Tablo.Query1.EOF do begin
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+AktifTabloAdi+' set ['+Tablo.Query1.FieldByName('ROL').AsString+']='+VarToStr(Iskonto)+' where ID in('+SeciliSatirIDleriniGetir+')',[],[]);
          Tablo.Query1.Next;
        end;
        AramaYap;
      end;
    end else
      showmessage('Geçersiz iskonto oranı girdiniz.');
  end;

end;

procedure TIskontoYetkiDlg.TumuneClick(Sender: TObject);
var
  ctrls: TGirdiDenetimleri;
  Iskonto: Variant;
begin
  ctrls := TGirdiDenetimleri.Create.Edit('İskonto Oranını', @Iskonto);
  if TGirisKutusuEx.BilgiAlEx('İskonto Oranı', ctrls) = mrOk then begin
    if StrToIntDef(VarToStrDef(Iskonto,''),0)>0 then begin
      if TabIskontoYetki.RecordCount>0 then begin
        if (Sender as TMenuItem).Tag=0 then begin
          Tablo.TablodanSorguAc(1,'select * from ROLLER');
        end else begin
          Tablo.TablodanSorguAc(1,'select * from ROLLER where ID = ' + IntToStr((Sender as TMenuItem).Tag));
        end;
        Tablo.Query1.First;
        while not Tablo.Query1.EOF do begin
          Tablo.Query2.Close;
          Tablo.Query2.SQL.Text := 'update '+AktifTabloAdi+' set ['+Tablo.Query1.FieldByName('ROL').AsString+']='+VarToStr(Iskonto)+' where 1=1';
          if EditKodu.Text <> '' then
            Tablo.Query2.SQL.Add(' and KOD like '''+EditKodu.Text+'%''');
          if EditAdi.Text <> '' then
            Tablo.Query2.SQL.Add(' and STOKADI like '''+EditAdi.Text+'%''');
          if ComboIcerik.Text <> '' then
            Tablo.Query2.SQL.Add(' and ICERIK='+VarToStrDef(ComboIcerik.EditValue,'0'));
          if ComboGRUBU.Text <> '' then
            Tablo.Query2.SQL.Add(' and GRUBU='+VarToStrDef(ComboGRUBU.EditValue,'0'));
          if ComboOZELLIK.Text <> '' then
            Tablo.Query2.SQL.Add(' and OZELLIK='+VarToStrDef(ComboOZELLIK.EditValue,'0'));
          if ComboMARKA.Text <> '' then
            Tablo.Query2.SQL.Add(' and MARKA='+VarToStrDef(ComboMARKA.EditValue,'0'));
          if EditKategori.Text <> '' then
            Tablo.Query2.SQL.Add(' and KATEGORI='+IntToStr(EditKategori.Tag));
          Tablo.Query2.ExecSQL;
          Tablo.Query1.Next;
        end;
        AramaYap;
      end;
    end else
    showmessage('Geçersiz iskonto oranı girdiniz.');
  end;
end;

procedure TIskontoYetkiDlg.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TIskontoYetkiDlg.EditKategoriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if AButtonIndex = 0 then begin
     Application.CreateForm(TKategoriDlg, KategoriDlg);
     KategoriDlg.ShowModal;
     if KategoriDlg.ModalResult = mrOk then begin
        EditKategori.Tag := KategoriDlg.KATEGORI.fieldbyname('ID').asinteger;
        EditKategori.Text := KategoriDlg.KATEGORI.fieldbyname('KOD').asstring+' '+KategoriDlg.KATEGORI.fieldbyname('AD').asstring;
     end;
     Freeandnil(KategoriDlg);
  end else if AButtonIndex = 1 then begin
    EditKategori.Tag := 0;
    EditKategori.Text := '';
  end;
end;

procedure TIskontoYetkiDlg.EditKoduKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  (Sender as TcxTextEdit).PostEditValue;
end;

procedure TIskontoYetkiDlg.EditKoduPropertiesEditValueChanged(Sender: TObject);
begin
  AramaYap;
end;

procedure TIskontoYetkiDlg.FormShow(Sender: TObject);
begin
  if TempTabloDoldur(TempTabloOlustur) then
    GridDoldur;
end;

Function TIskontoYetkiDlg.TempTabloDoldur(TabloAdi: String): Boolean;
begin
  AktifTabloAdi := TabloAdi;
  //önce stoklar insert edilir..
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := ' insert into ' + TabloAdi;
  Tablo.Query2.SQL.Add('(TUR,URUNID,KOD,STOKADI,KATEGORI,GRUBU,MARKA,OZELLIK,ICERIK)');
  Tablo.Query2.SQL.Add(' select 1,ID,KOD,STOKADI,KATEGORI,GRUBU,MARKA,OZELLIK,ICERIK from STOKLAR where DURUM=1');
  Tablo.Query2.ExecSQL;
  //daha sonra rol yetkileri update edilir..
  Tablo.TablodanSorguAc(1,'select * from ROLLER where DURUM=1');
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := '';
  while not Tablo.Query1.Eof do begin
    Tablo.Query3.SQL.Add(' update ' + TabloAdi + ' set [' + Tablo.Query1.FieldByName('ROL').AsString + '] = MAXISKONTO from ISKONTOYETKI ');
    Tablo.Query3.SQL.Add(' where ISKONTOYETKI.TUR=' + TabloAdi + '.TUR and ISKONTOYETKI.URUNID=' + TabloAdi + '.URUNID and ISKONTOYETKI.ROLID = ' + Tablo.Query1.FieldByName('ID').AsString);
    Tablo.Query3.SQL.Add('  ');
    Tablo.Query1.Next;
  end;
  try
    Tablo.Query3.ExecSQL;
    AramaYap;
    Result := True;
  except
    Result := False;
  end;
end;

Procedure TIskontoYetkiDlg.GridDoldur;
var i:integer;
begin
  cxGrid1DBTableView1.DataController.CreateAllItems(True);
  for I := cxGrid1DBTableView1.ColumnCount - 1 downto 0 do begin
    if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='TUR' then begin
      cxGrid1DBTableView1.Columns[i].RepositoryItem := Tablo.RepFatDetayTur;
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'Tür';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='URUNID' then begin
      cxGrid1DBTableView1.Columns[i].Visible := False;
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='KOD' then begin
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'Kod';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='STOKADI' then begin
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'Ad';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='KATEGORI' then begin
      cxGrid1DBTableView1.Columns[i].RepositoryItem := Tablo.repStokKategori;
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'Kategori';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='GRUBU' then begin
      cxGrid1DBTableView1.Columns[i].RepositoryItem := Tablo.repStokGrubu;
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'Grubu';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='MARKA' then begin
      cxGrid1DBTableView1.Columns[i].RepositoryItem := Tablo.repStokMarka;
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'Marka';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='OZELLIK' then begin
      cxGrid1DBTableView1.Columns[i].RepositoryItem := Tablo.repStokOzellik;
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'Özellik';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='ICERIK' then begin
      cxGrid1DBTableView1.Columns[i].RepositoryItem := Tablo.repStokIcerik;
      cxGrid1DBTableView1.Columns[i].Options.Editing := False;
      cxGrid1DBTableView1.Columns[i].Caption := 'İçerik';
    end else if cxGrid1DBTableView1.Columns[i].DataBinding.FieldName='ID' then begin
      cxGrid1DBTableView1.Columns[i].Visible := False;
    end else begin


    end;
  end;
  cxGrid1DBTableView1.ApplyBestFit;
end;


procedure TIskontoYetkiDlg.KaydetTusClick(Sender: TObject);
begin
  Tablo.TablodanSorguAc(1,'select * from ROLLER where DURUM=1');
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'truncate table ISKONTOYETKI ';
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    Tablo.Query3.SQL.Add(' insert into ISKONTOYETKI (TUR,URUNID,ROLID,MAXISKONTO) ');
    Tablo.Query3.SQL.Add(' select TUR,URUNID,'+Tablo.Query1.FieldByName('ID').AsString+',['+Tablo.Query1.FieldByName('ROL').AsString+']');
    Tablo.Query3.SQL.Add(' from '+AktifTabloAdi);
    Tablo.Query3.SQL.Add('  ');
    Tablo.Query1.Next;
  end;
  Tablo.Query3.ExecSQL;
  ModalResult := mrOk;
end;

end.



