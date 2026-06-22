unit USerinoTakip;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxLabel,
  cxContainer, cxEdit, cxTextEdit, cxMemo, cxPC, cxControls, Menus,
  cxLookAndFeelPainters, StdCtrls, cxButtons, ExtCtrls, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, DB, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, FireDAC.Comp.Client, cxCheckBox, ComCtrls, ToolWin,
  cxMaskEdit, cxSpinEdit, cxDBEdit, cxLookAndFeels, dxSkinsDefaultPainters, cxPCdxBarPopupMenu, cxNavigator;

type
  TSeriNoDlg = class(TForm)
    pgSeriNo: TcxPageControl;
    shtSeriNoGiris: TcxTabSheet;
    shtSeriNoDuzeltSil: TcxTabSheet;
    memoSeriNolar: TcxMemo;
    cxLabel1: TcxLabel;
    pnlAlt: TPanel;
    lbKayitSay: TcxLabel;
    lblKayitSayisi: TcxLabel;
    lblHataMesaj: TcxLabel;
    memoHataliSeriNo: TcxMemo;
    lblHataliSeriNo: TcxLabel;
    tvSeriNoListesi: TcxGridDBTableView;
    gridSeriNoListesiLevel1: TcxGridLevel;
    gridSeriNoListesi: TcxGrid;
    Panel1: TPanel;
    editSeriNo: TcxTextEdit;
    cxLabel2: TcxLabel;
    clmSeriNoSec: TcxGridDBColumn;
    clmSeriNo: TcxGridDBColumn;
    dtsSeriNoListesi: TDataSource;
    tabSeriNoListesi: TFDQuery;
    cxLabel3: TcxLabel;
    lblGerekliSayi: TcxLabel;
    clmSeriNoCikFaturaId: TcxGridDBColumn;
    ToolBar3: TToolBar;
    btnKaydet: TToolButton;
    ToolButton10: TToolButton;
    btnIptal: TToolButton;
    ToolButton1: TToolButton;
    lblGarantiSure: TcxLabel;
    edGarantiSure: TcxSpinEdit;
    clmGarantiBitis: TcxGridDBColumn;
    procedure memoSeriNolarPropertiesEditValueChanged(Sender: TObject);
    procedure btnSerinoKaydetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editSeriNoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure clmSeriNoSecPropertiesEditValueChanged(Sender: TObject);
    procedure tabSeriNoListesiBeforePost(DataSet: TDataSet);
    procedure tabSeriNoListesiBeforeEdit(DataSet: TDataSet);
    procedure clmSeriNoSecPropertiesChange(Sender: TObject);
    procedure tvSeriNoListesiStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure AksiyonEkleClick(Sender: TObject);
    procedure dtsSeriNoListesiStateChange(Sender: TObject);
    procedure pgSeriNoChange(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { Private declarations }
   var
      oncekiserino : string;
  public
    { Public declarations }
//     procedure SeriNoGiris (GirisTuru,StokID,GirFatBasID,GirFatID:integer;serino:String);
  end;

var
  SeriNoDlg: TSeriNoDlg;
  //cagirantur : demirbaş tutanağı olabilir, fatura türleri olabilir
  //cagiranbaslikid : ana tablodaki kayıt id si
  //cagiransatirId : detay tablodaki id değeri
  SeriTakipSeriNosayisi, SeriTakipCagiranBaslikId, SeriTakipCagiranSatirId, SeriTakipCagiranTur,
  SeriTakipCagiranUrunId : Integer;
  SeriTakipislemturu : string;     // G : giriş, C: Çıkış, D: Düzelt , S:Sil  , GD: GirişDüzel, CD : Çıkış Düzelt

implementation
  Uses Utablo;//,LocOnFly;
{$R *.dfm}

procedure TSeriNoDlg.AksiyonEkleClick(Sender: TObject);
begin
  if dtsSeriNoListesi.State in [dsEdit] then tabSeriNoListesi.Cancel;
end;

procedure TSeriNoDlg.btnSerinoKaydetClick(Sender: TObject);

procedure HataliSeriNoMemoyaEkle(serino, hatamesaji:string);
begin
   lblHataMesaj.Visible:=True;
   lblHataMesaj.Caption:= hatamesaji;
   lblHataliSeriNo.Visible:= serino<>'' ;
   memoHataliSeriNo.Visible:=serino<>'';
   if serino<>'' then
    memoHataliSeriNo.Lines.Add(serino);
end; //Eklendi
function YeterliSeriNoSecildi:Boolean;
 begin
      Result:=True;
      if lblKayitSayisi.Caption<>lblGerekliSayi.Caption then
       begin
         HataliSeriNoMemoyaEkle('','Seçilen Seri Numarası Sayısı gereken sayıdan farklı, lütfen kontrol ediniz');
         Result:=False;
       end;
 end;  //Eklendi
function BosSatirVar:Boolean;
var
 i : Integer;
  begin
    Result:=False;
     for i := 0 to memoSeriNolar.Lines.Count - 1 do
      begin
        if StringReplace( memoSeriNolar.Lines[i],' ','',[rfReplaceAll]) = '' then
         begin
          Result:=True;
          lblHataMesaj.Caption:= 'Seri No Listesinde Boş Satır var, Lütfen Kontrol ediniz.';
          abort;
         end;
      end;
  end; //Eklendi
function AyniSeriNoVar : Boolean;
var
 i : Integer;
   begin
     memoHataliSeriNo.Lines.Clear;
     Result:=False;
     for i := 0 to memoSeriNolar.Lines.Count - 1 do
        begin
           if  (memoSeriNolar.Lines.IndexOf(memoSeriNolar.Lines[i])>=0) and (memoSeriNolar.Lines.IndexOf(memoSeriNolar.Lines[i])<>i) then
              begin
                Result:=True;
                HataliSeriNoMemoyaEkle(memoSeriNolar.Lines[i],'Seri Numarası Listesinde tekrar eden seri numaraları var, Lütfen kontrol ediniz');
//                abort;
              end;
        end;
   end;  //eklendi
function SeriNoDahaOnceGirilmismi:Boolean ;
var
 i: Integer;
begin
  memoHataliSeriNo.Lines.Clear;
  Result:=False;

  for i := 0 to memoSeriNolar.Lines.Count - 1 do
   begin
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM SERINO WHERE STOKID = '+IntToStr(SeriTakipCagiranUrunId)+' AND SERINO = '''+memoSeriNolar.Lines[i]+''' ';
      Tablo.Query5.Open;
      if Tablo.Query5.RecordCount>=1 then
       begin
         Result:=True;
         HataliSeriNoMemoyaEkle(memoSeriNolar.Lines[i],'Aynı ürün için listedeki seri numaraları daha önce kullanılmıştır. Lütfen kontrol ediniz');
       end;
   end;
end;   //Eklendi
 procedure SeriNolariGir;
  var
   i : integer;
  begin
     //fatura id si yeni kayıt sırasında oluşmamış olduğu için diziye atıyoruz, after post ta dizinden giriş kayıtları oluşuyor
     faturaurungarantisuresi:= edGarantiSure.Value;
     for i := 0 to memoSeriNolar.Lines.Count - 1 do
        faturaurunserinolar[i]:= memoSeriNolar.Lines[i];
//        Tablo.SeriNoGiris(SeriTakipCagiranTur,SeriTakipCagiranUrunId,SeriTakipCagiranBaslikId,SeriTakipCagiranSatirId,memoSeriNolar.Lines[i]);

  end; //Eklendi
 procedure SeriNolariCik;
  var
    i : integer;
  begin
    tabSeriNoListesi.First;
    i:=0;
    while not (tabSeriNoListesi.Eof) do
     begin
       if clmSeriNoSec.EditValue='True' then
        begin
         faturaurunserinolar[i]:= tabSeriNoListesi.FieldByName('SERINO').AsString;
         i:=i+1;
        end;

//        Tablo.SeriNoCikis(SeriTakipCagiranTur,SeriTakipCagiranUrunId, SeriTakipCagiranBaslikId, SeriTakipCagiranSatirId,tabSeriNoListesi.FieldByName('SERINO').AsString);

      tabSeriNoListesi.Next;
     end;
  end;  //Eklendi
begin
  if shtSeriNoDuzeltSil.TabVisible then
   begin
     if dtsSeriNoListesi.State in [dsEdit,dsInsert] then
      tabSeriNoListesi.Post;
   end;
  memoHataliSeriNo.Visible:=False;
  lblHataliSeriNo.Visible:=False;
  lblHataMesaj.Caption:='';

  if (SeriTakipislemturu ='GD') or (SeriTakipislemturu ='CD')  then
     clmSeriNo.Editing:= True // sadece düzeltme parametresi ile çağırılırsa ilgili kayıt düzeltilebilir.
  else
   clmSeriNo.Editing:= False;

   clmGarantiBitis.Editing:= clmSeriNo.Editing;
   edGarantiSure.Visible:= SeriTakipislemturu='G';
   lblGarantiSure.Visible:= edGarantiSure.Visible;

{$REGION 'SeriNoGiriş'}
  if SeriTakipislemturu= 'G' then
   begin // Yeni Seri No Girişi
      if memoSeriNolar.Lines.Count <> SeriTakipSeriNosayisi then
       begin
         HataliSeriNoMemoyaEkle('','Listedeki Seri Numarası sayısı gereken sayıdan farklı, lütfen kontrol ediniz');
         abort;
       end;
      if BosSatirVar then abort;
      if AyniSeriNoVar then Abort;
      if SeriNoDahaOnceGirilmismi then abort;

      //tüm kontrolleri geciyorsa seri no girişi yapılabilir
      SeriNolariGir;
      ModalResult:=mrOk;

   end    //Eklendi
{$ENDREGION}
 else
{$REGION 'SeriNoÇıkış'}
 if SeriTakipislemturu = 'C' then
   begin
      if not (YeterliSeriNoSecildi) then abort;
       SeriNolariCik;
      ModalResult:=mrOk;
   end
{$ENDREGION}
{$REGION 'Giriş-Çıkış Düzeltme'}
 else if (SeriTakipislemturu = 'GD') or (SeriTakipislemturu = 'CD') then
    begin
      if not (YeterliSeriNoSecildi) then abort;

      tabSeriNoListesi.First;
      while not (tabSeriNoListesi.Eof) do
       begin
        if (clmSeriNoSec.EditValue='True') then
         begin
         {if (SeriTakipislemturu = 'GD') then
           Tablo.SeriNoSil(SeriTakipCagiranUrunId,SeriTakipCagiranTur,SeriTakipCagiranBaslikId,SeriTakipCagiranSatirId,0,0,0,tabSeriNoListesi.FieldByName('SERINO').AsString)
         else
           Tablo.SeriNoSil(SeriTakipCagiranUrunId,0,0,0,SeriTakipCagiranTur,SeriTakipCagiranBaslikId,SeriTakipCagiranSatirId,tabSeriNoListesi.FieldByName('SERINO').AsString);
              }
        end;
        tabSeriNoListesi.Next;
       end;

       ModalResult:= mrOk;

    end;
{$ENDREGION}
end;


procedure TSeriNoDlg.clmSeriNoSecPropertiesChange(Sender: TObject);
begin
  if ( SeriTakipislemturu = 'GD' ) and
     (tabSeriNoListesi.FieldByName('CIKFATURAID').AsInteger>0) and
     (clmSeriNoSec.EditValue='True') then
   begin
        Application.MessageBox('Bu ürünün çıkışı yapılmış, Değişiklik yapılamaz','H A T A',MB_ICONERROR+MB_OK);
        clmSeriNoSec.EditValue:='False';
        Abort;
   end;
end;  //eklendi

procedure TSeriNoDlg.clmSeriNoSecPropertiesEditValueChanged(Sender: TObject);
begin
   if clmSeriNoSec.EditValue='True' then
     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)+1)
   else
     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)-1);
end;   //Eklendi

procedure TSeriNoDlg.pgSeriNoChange(Sender: TObject);
var
 k : Word;
begin
  if pgSeriNo.ActivePage= shtSeriNoGiris then
   memoSeriNolarPropertiesEditValueChanged(Self)
  else
     editSeriNoKeyUp(Self,k,[]);
end;    //eklendi

procedure TSeriNoDlg.dtsSeriNoListesiStateChange(Sender: TObject);
begin
   btnIptal.Enabled:= dtsSeriNoListesi.State in [dsEdit,dsInsert];
end;   //eklendi

procedure TSeriNoDlg.editSeriNoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    tabSeriNoListesi.Prior
  else if Key = 40 then
    tabSeriNoListesi.next
  else
   begin
      lblKayitSayisi.Caption:='0';
      tabSeriNoListesi.Close;
      tabSeriNoListesi.SQL.Text:= 'SELECT * FROM SERINO WHERE STOKID = '+ IntToStr(SeriTakipCagiranUrunId)+' '+
                              ' AND SERINO LIKE '''+editSeriNo.Text+'%'' ';
      if SeriTakipislemturu = 'C' then // çıkışı yapılmamış seri numaraları
       tabSeriNoListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) = 0 AND ISNULL(CIKFATURAID,0) = 0')
      else if (SeriTakipislemturu = 'CD') and ( SeriTakipCagiranTur in [14, 15, 16] ) then // çıkılan seri nolar üzerinde düzeltme yapılacaksa
       tabSeriNoListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) > 0 AND ISNULL(CIKFATURAID,0) = '+inttostr(SeriTakipCagiranSatirId))
      else if (SeriTakipislemturu = 'GD') and ( SeriTakipCagiranTur in [7, 10, 11, 12] ) then // Girilen seri nolar üzerinde düzeltme yapılacaksa
       tabSeriNoListesi.SQL.Add(' AND ISNULL(GIRISTURU,0) > 0 AND ISNULL(GIRFATURAID,0) = '+inttostr(SeriTakipCagiranSatirId));
      tabSeriNoListesi.Open;
   end;
end;    //Eklendi

procedure TSeriNoDlg.FormCreate(Sender: TObject);
begin
 // LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  lblHataMesaj.Caption:='';
end;   //eklendi

procedure TSeriNoDlg.FormShow(Sender: TObject);
var
 k:word;
begin
  lblGerekliSayi.Caption:= IntToStr(SeriTakipSeriNosayisi);
{
  if (SeriTakipislemturu = 'GD') or (SeriTakipislemturu = 'CD') then
   begin
     btnSerinoKaydet.Caption:='Seçilen Numaraları Çıkar';
     editSeriNoKeyUp(Self,k,[]);
   end
  else
   btnSerinoKaydet.Caption:='Seri Numaralarını Kaydet';
}
  //seritakipsayısı 0 gönderilirse sadece grid üzerinden seri no düzeltme işlemi yapılabilir.
   Tablo.Query6.Close;
   Tablo.Query6.SQL.Text:= 'SELECT GARANTISURESI FROM STOKLAR WHERE ID='+inttostr(SeriTakipCagiranUrunId)+' ';
   Tablo.Query6.Open;
   edGarantiSure.Value:= Tablo.Query6.Fields[0].AsInteger;
end;   //eklendi

procedure TSeriNoDlg.memoSeriNolarPropertiesEditValueChanged(Sender: TObject);
var
 i : Integer;
begin
  lblKayitSayisi.Caption:='0';
  for i := 0 to memoSeriNolar.Lines.Count - 1 do
   begin
    if StringReplace(memoSeriNolar.Lines[i],' ','',[rfReplaceAll])<>'' then
     lblKayitSayisi.Caption:= IntToStr( strtoint(lblKayitSayisi.Caption)+1 );
   end;
end;  //eklendi

procedure TSeriNoDlg.tabSeriNoListesiBeforeEdit(DataSet: TDataSet);
begin
  oncekiserino:= tabSeriNoListesi.FieldByName('SERINO').AsString;
end;   //eklendi

procedure TSeriNoDlg.tabSeriNoListesiBeforePost(DataSet: TDataSet);
begin
  if oncekiserino<>tabSeriNoListesi.FieldByName('SERINO').AsString then
   begin
     if (SeriTakipCagiranTur in [7, 10, 11, 12]) and (tabSeriNoListesi.FieldByName('CIKFATURAID').AsInteger>0 ) then
      begin
        Application.MessageBox('Bu ürünün çıkışı yapılmış, Seri Numarası değiştirilemez','H A T A',MB_ICONERROR+MB_OK);
        Abort;
      end;
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM SERINO WHERE '+
                              ' STOKID = '+IntToStr(SeriTakipCagiranUrunId)+' AND SERINO = '''+tabSeriNoListesi.FieldByName('SERINO').AsString+''' '+
                              ' AND ID <>'+tabSeriNoListesi.FieldByName('ID').AsString+' ';
      Tablo.Query5.Open;
     if Tablo.Query5.RecordCount>0 then
      begin
         Application.MessageBox(PChar(tabSeriNoListesi.FieldByName('SERINO').AsString+' seri numarası bu ürün için daha önce kullanılmış, tekrar girilemez') ,'H A T A',MB_ICONERROR+ MB_OK);
         Abort;
      end;
   end;
end;  //Eklendi

procedure TSeriNoDlg.ToolButton1Click(Sender: TObject);
begin
  ModalResult:= mrCancel;
  Close;
end;    //Eklendi

procedure TSeriNoDlg.tvSeriNoListesiStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
 AColumn : TcxGridColumn;
begin
      AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('CIKFATURAID');
      if AColumn <> nil then
        if (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '') and
           (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '0')
         then
            AStyle := tablo.cxStSerinoCikilmis;
end;    //eklendi

end.

