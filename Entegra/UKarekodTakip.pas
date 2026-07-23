unit UKarekodTakip;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxCheckBox, cxTextEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, cxMemo, cxPC, ComCtrls, ToolWin, cxContainer,
  cxLabel, ExtCtrls, FireDAC.Comp.Client, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer,
  StdCtrls, dxSkinLiquidSky, cxMaskEdit, cxDropDownEdit, cxCalendar, Menus,
  cxLookAndFeelPainters, cxButtons, cxLookAndFeels, dxSkinsDefaultPainters, cxPCdxBarPopupMenu, dxCore, cxDateUtils, cxNavigator;

 type
    TKareKodType = record
      UrunNumarası : string;
      UrunSeriNumarası : string;
      Lotno : string;
      SonKullanım : string;
    end;
type
  TKareKodDlg = class(TForm)
    Pgizlem: TcxPageControl;
    TsKarekod: TcxTabSheet;
    TsSeriNo: TcxTabSheet;
    pnlAlt: TPanel;
    lbKayitSay: TcxLabel;
    lblKayitSayisi: TcxLabel;
    lblHataMesaj: TcxLabel;
    cxLabel3: TcxLabel;
    lblGerekliSayi: TcxLabel;
    ToolBar3: TToolBar;
    btnKaydet: TToolButton;
    ToolButton10: TToolButton;
    btnIptal: TToolButton;
    ToolButton1: TToolButton;
    tabKareKodListesi: TFDQuery;
    dtsKareKodListesi: TDataSource;
    DtsKareKodGoster: TDataSource;
    QryKareKodGoster: TFDQuery;
    Panel3: TPanel;
    cxLabel4: TcxLabel;
    EdtSiraNo1: TcxTextEdit;
    cxLabel5: TcxLabel;
    EdtLotNo: TcxTextEdit;
    cxLabel6: TcxLabel;
    DtSonKullanim: TcxDateEdit;
    EdtAdet: TcxTextEdit;
    cxLabel7: TcxLabel;
    BtnEkle: TcxButton;
    EdtBarkodNumarasi: TcxTextEdit;
    cxLabel8: TcxLabel;
    TxtTransferNo: TcxTextEdit;
    cxLabel9: TcxLabel;
    cxButton1: TcxButton;
    pgKareKod: TcxPageControl;
    shtKareKodGiris: TcxTabSheet;
    Panel2: TPanel;
    memoKareKodlar: TcxMemo;
    cxLabel1: TcxLabel;
    TreeListKareKod: TcxTreeList;
    TlcUrunAdi: TcxTreeListColumn;
    cxTreeList1Column2: TcxTreeListColumn;
    cxTreeList1Column3: TcxTreeListColumn;
    cxTreeList1Column4: TcxTreeListColumn;
    cxTreeList1Column5: TcxTreeListColumn;
    cxTreeList1Column6: TcxTreeListColumn;
    shtKareKodDuzeltSil: TcxTabSheet;
    gridKareKodListesi: TcxGrid;
    tvSeriNoListesi: TcxGridDBTableView;
    clmSeriNoSec: TcxGridDBColumn;
    clmSeriNo: TcxGridDBColumn;
    clmLotno: TcxGridDBColumn;
    clmSeriNoCikFaturaId: TcxGridDBColumn;
    tvSonKullanma: TcxGridDBColumn;
    gridKareKodListesiLevel1: TcxGridLevel;
    Panel1: TPanel;
    editKareKod: TcxTextEdit;
    cxLabel2: TcxLabel;
    procedure ToolButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KareKodIslem();
    procedure editKareKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pgKareKodChange(Sender: TObject);
    procedure memoKareKodlarPropertiesChange(Sender: TObject);
    procedure memoKareKodlarPropertiesEditValueChanged(Sender: TObject);
    procedure tabKareKodListesiBeforeEdit(DataSet: TDataSet);
    procedure tabKareKodListesiBeforePost(DataSet: TDataSet);
    procedure dtsKareKodListesiStateChange(Sender: TObject);
    procedure clmSeriNoSecPropertiesChange(Sender: TObject);
    procedure clmSeriNoSecPropertiesEditValueChanged(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    function KareKodParcala(KareKod : string): TKareKodType;
    procedure tvSeriNoListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    function AyniKarekoddanVar(SeriNo, UrunKodu: string):string;
    procedure tabKareKodListesiAfterPost(DataSet: TDataSet);
    procedure BtnEkleClick(Sender: TObject);
    function  IsInteger(S: String) : Boolean;
    function  SiraNoArtir(Serino:String;adet:Integer) : TStringList;
    procedure cxButton1Click(Sender: TObject);
    procedure TreeListeUrunEkle(Urunler:array of TKareKodType);
    procedure TreeListKareKodDataChanged(Sender: TObject);
  private
    { Private declarations }

    var
      oncekiKareKod : string;
      oncekiUrunKod : string;

  public
    { Public declarations }
  end;

var
  KareKodDlg: TKareKodDlg;
  //cagirantur : demirbaş tutanağı olabilir, fatura türleri olabilir
  //cagiranbaslikid : ana tablodaki kayıt id si
  //cagiransatirId : detay tablodaki id değeri
  KareKodTakipKAreKodsayisi,
  KareKodTakipCagiranBaslikId,
  KarekodTakipCagiranSatirId,
  KareKodTakipCagiranTur,
  KareKodTakipCagiranUrunId : Integer;
  KareKodTakipCagiranAlimGln : string;
  KareKodTakipCagiranSatilanGln : string;
  KareKodTakipislemturu : string;
  KareKodlar : array of TKareKodType;
  _Hata : string;
   //İşlem Türleri  = G : giriş, C: Çıkış, D: Düzelt , S:Sil  , GD: GirişDüzel, CD : Çıkış Düzelt
implementation
 Uses Utablo,PrjConst,UItsAraclari,UitsBusiness,UVeriMotor;//,LocOnFly;

{$R *.dfm}
function TKareKodDlg.IsInteger(S: String) : Boolean;
var
aNo,err:integer;
begin
val(S,aNo,err);
if err=0 then result:=true else
result:=false;
end;   //Eklendi

function TKareKodDlg.AyniKarekoddanVar(SeriNo, UrunKodu: string):string;
begin
if (Serino<>'') and (UrunKodu<>'') then
begin
Tablo.Query6.close;
Tablo.Query6.SQL.Text:= '';
Tablo.Query6.SQL.add(' SELECT R.FIRMA+'' dan ''+'+DbConv('FB.TARIH','varchar(20)',120)+'+'' tarihli alınan faturada ''+AD+'' isimli ürün aynı karekod a sahipdir.'' as MESAJ FROM ');
Tablo.Query6.SQL.add(' (SELECT * FROM KAREKOD KK WHERE KK.SERINO = '''+SeriNo+''' AND KK.URUNKOD = '''+UrunKodu+''' ) AS DD ');
Tablo.Query6.SQL.add(' ,FATURA F,FATBASLIK FB ,REHBER R WHERE DD.GIRFATURAID = F.ID AND FB.ID=DD.GIRFATBASID AND FB.ID=F.FATBASID AND R.ID=FB.REHBERID ');
if AktifVeriMotor = vmPG then Tablo.Query6.SQL.Text := PgSqlCevir(Tablo.Query6.SQL.Text);
tablo.Query6.Open;
Result :=Tablo.Query6.FieldByName('MESAJ').AsString;
end else Result := '';
end;  //Eklendi

procedure TKareKodDlg.btnKaydetClick(Sender: TObject);
begin
KareKodIslem();
end;


procedure TKareKodDlg.clmSeriNoSecPropertiesChange(Sender: TObject);
begin
if ( KareKodTakipislemturu = 'GD' ) and
     (tabKareKodListesi.FieldByName('CIKFATURAID').AsInteger>0) and
     (clmSeriNoSec.EditValue='True') then
   begin
        Application.MessageBox('Bu ürünün çıkışı yapılmış, Değişiklik yapılamaz','H A T A',MB_ICONERROR+MB_OK);
        clmSeriNoSec.EditValue:='False';
        clmSeriNo.Editing:=False;
        Abort;
   end;
end;  //Eklendi
procedure TKareKodDlg.clmSeriNoSecPropertiesEditValueChanged(Sender: TObject);
begin
   if clmSeriNoSec.EditValue='True' then
     begin
     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)+1);
     //lblGerekliSayi.Caption:= IntToStr(strtoint(lblGerekliSayi.Caption)+1);
     end
   else
   begin
     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)-1);
     //lblGerekliSayi.Caption:= IntToStr(strtoint(lblGerekliSayi.Caption)+1);
   end;
end;   //Eklendi
procedure TKareKodDlg.cxButton1Click(Sender: TObject);
var
PtsIstek : TPTSAlimIstek;
Yanit : TGenelYanit;
GelenHataKodu : string;
begin
PtsIstek := TPTSAlimIstek.Create;
PtsIstek.FR := GLNFirma; // GLN No : 8680001407743
PtsIstek.TRANSFERID := TxtTransferNo.Text;
GelenHataKodu := XMLGelenIsle(XMLGonderPts(PtsIstek),PtsIstek.Urunler);
if GelenHataKodu<>'' then
Application.MessageBox(PChar(GelenHataKodu),PChar(Uyari), MB_OK+ MB_ICONWARNING);
end;   //Eklendi

procedure TKareKodDlg.BtnEkleClick(Sender: TObject);
var
  I: Integer;
  Rakamlar  : Char;
  NewNode,ChildNode : TcxTreeListNode;
  DiziSiraNolar : TStringList;
 begin
 TreeListKareKod.Clear;
   if IsInteger(EdtAdet.Text)  then
   begin
    DiziSiraNolar:=SiraNoArtir(EdtSiraNo1.Text,strtoint(EdtAdet.Text));
    for I := 0 to StrToInt(EdtAdet.Text)- 1 do
    begin
      NewNode := TreeListKareKod.Add;
      NewNode.Texts[0] := EdtBarkodNumarasi.Text;
      NewNode.Texts[1] := DiziSiraNolar[I];
      NewNode.Texts[2] := EdtLotNo.Text;
      NewNode.Texts[3] := DateToStr(DtSonKullanim.Date);
     //if  (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])>=0) and (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])<>i) then
     //begin
     // ChildNode := TreeListKareKod.AddChild(NewNode, nil);
     // ChildNode.Expand(False);
     // ChildNode.Texts[0] := 'KareKod Tekrarı';
     //end;
    end;
   end
   else
   ShowMessage(Its_Islem_Secilen_Adet_Gecerli_Degil);
 end;    //Eklendi
procedure TKareKodDlg.dtsKareKodListesiStateChange(Sender: TObject);
begin
btnIptal.Enabled:= dtsKareKodListesi.State in [dsEdit,dsInsert];
end;  //Eklendi
procedure TKareKodDlg.editKareKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if Key = 38 then
    tabKareKodListesi.Prior
  else if Key = 40 then
    tabKareKodListesi.next
  else
   begin
      lblKayitSayisi.Caption:='0';
      tabKareKodListesi.Close;
      tabKareKodListesi.SQL.Text:= 'SELECT * FROM KAREKOD WHERE STOKID = '+ IntToStr(KareKodTakipCagiranUrunId)+' '+
                              ' AND SERINO LIKE '''+editKareKod.Text+'%'' ';
      if KareKodTakipislemturu = 'C' then // çıkışı yapılmamış seri numaraları
       tabKareKodListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) = 0 AND ISNULL(CIKFATURAID,0) = 0')
      else if (KareKodTakipislemturu = 'CD') and ( KareKodTakipCagiranTur in [14, 15, 16] ) then // çıkılan KareKodlar üzerinde düzeltme yapılacaksa
       tabKareKodListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) > 0 AND ISNULL(CIKFATURAID,0) = '+inttostr(KarekodTakipCagiranSatirId))
      else if (KareKodTakipislemturu = 'GD') and ( KareKodTakipCagiranTur in [10, 11, 12] ) then // Girilen KareKodlar üzerinde düzeltme yapılacaksa
       tabKareKodListesi.SQL.Add(' AND ISNULL(GIRISTURU,0) > 0 AND ISNULL(GIRFATURAID,0) = '+inttostr(KarekodTakipCagiranSatirId));
      if AktifVeriMotor = vmPG then tabKareKodListesi.SQL.Text := PgSqlCevir(tabKareKodListesi.SQL.Text);
      tabKareKodListesi.Open;
   end;
end;  //Eklendi
procedure TKareKodDlg.FormCreate(Sender: TObject);
begin
//LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
lblHataMesaj.Caption:='';
end; //Eklendi
procedure TKareKodDlg.FormShow(Sender: TObject);
var
 k:word;
begin
  lblGerekliSayi.Caption:= IntToStr(KareKodTakipKAreKodsayisi);
  if (KareKodTakipislemturu = 'GD') or (KareKodTakipislemturu = 'CD') then
   begin
     btnKaydet.Caption:='Seçilen Numaraları Çıkar';
     editKareKodKeyUp(Self,k,[]);
   end
  else
  if (KareKodTakipislemturu='C') then
  begin
      btnKaydet.Caption:='Seçilen Numaraları Çıkar';
     editKareKodKeyUp(Self,k,[]);
  end else
  begin
  btnKaydet.Caption:='Seri Numaralarını Kaydet';
  EdtAdet.Text:= IntToStr(KareKodTakipKAreKodsayisi);
  end;
  //seritakipsayısı 0 gönderilirse sadece grid üzerinden seri no düzeltme işlemi yapılabilir.
  // Tablo.Query6.Close;
  // Tablo.Query6.SQL.Text:= 'SELECT GARANTISURESI FROM STOKLAR WHERE ID='+inttostr(SeriTakipCagiranUrunId)+' ';
  // Tablo.Query6.Open;
  // edGarantiSure.Value:= Tablo.Query6.Fields[0].AsInteger;
end;  //Eklendi


procedure TKareKodDlg.KareKodIslem;
procedure HataliKareKodMemoyaEkle(serino, hatamesaji:string);
var
I:Byte;
ChildNode : tcxtreelistnode;
begin
   lblHataMesaj.Visible:=True;
   lblHataMesaj.Caption:= hatamesaji;
  for I := 0 to  TreeListKareKod.Count -1 do
  begin
    if TreeListKareKod.Items[I].Texts[1] = serino then
    begin
    ChildNode := TreeListKareKod.AddChild(TreeListKareKod.Items[I], nil);
    ChildNode.Texts[0] := 'hatamesaji';
    end;
  end;

end;
function YeterliKareKodSecildi:Boolean;
 begin
      Result:=True;
      if lblKayitSayisi.Caption<>lblGerekliSayi.Caption then
       begin
         HataliKareKodMemoyaEkle('','Seçilen Seri Numarası Sayısı gereken sayıdan farklı, lütfen kontrol ediniz');
         Result:=False;
       end;
 end;
function BosSatirVar:Boolean;
var
 i : Integer;
  begin
    Result:=False;
     for i := 0 to memoKareKodlar.Lines.Count - 1 do
      begin
        if StringReplace( memoKareKodlar.Lines[i],' ','',[rfReplaceAll]) = '' then
         begin
          Result:=True;
          lblHataMesaj.Caption:= 'Seri No Listesinde Boş Satır var, Lütfen Kontrol ediniz.';
          abort;
         end;
      end;
  end;

 function AyniSeriNoVar : Boolean;
var
 i : Integer;
   begin

     Result:=False;
     for i := 0 to memoKareKodlar.Lines.Count - 1 do
        begin
           if  (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])>=0) and (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])<>i) then
              begin
                Result:=True;
                HataliKareKodMemoyaEkle(TreeListKareKod.Items[i].Texts[1],'Seri Numarası Listesinde tekrar eden seri numaraları var, Lütfen kontrol ediniz');
//                abort;
              end;
        end;
   end;
 function SeriNoDahaOnceGirilmismi:Boolean ;
var
 i: Integer;
begin
  Result:=False;
  for i := 0 to memoKareKodlar.Lines.Count - 1 do
   begin
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM KAREKOD WHERE STOKID = '+IntToStr(KareKodTakipCagiranUrunId)+' AND SERINO = '''+TreeListKareKod.Items[i].Texts[1]+''' ';
      if AktifVeriMotor = vmPG then Tablo.Query5.SQL.Text := PgSqlCevir(Tablo.Query5.SQL.Text);
      Tablo.Query5.Open;
      if Tablo.Query5.RecordCount>=1 then
       begin
         Result:=True;
         HataliKareKodMemoyaEkle(TreeListKareKod.Items[i].Texts[1],'Aynı ürün için listedeki seri numaraları daha önce kullanılmıştır. Lütfen kontrol ediniz');
       end;
   end;
end;
 procedure SeriNolariGir;
  var
   i : integer;
  begin
     //fatura id si yeni kayıt sırasında oluşmamış olduğu için diziye atıyoruz, after post ta dizinden giriş kayıtları oluşuyor
     for i := 0 to TreeListKareKod.Count - 1 do
     begin
      FaturaUrunKareKodlar[i].UrunSeriNumarası:= TreeListKareKod.Items[i].Texts[1];
      FaturaUrunKareKodlar[i].UrunNumarası:= TreeListKareKod.Items[i].Texts[0];
      FaturaUrunKareKodlar[i].Lotno:= TreeListKareKod.Items[i].Texts[2];
      FaturaUrunKareKodlar[i].SonKullanım:= TreeListKareKod.Items[i].Texts[3];
     end;
  end;
 procedure SeriNolariCik;
   var
    i : integer;
    KareKodCikSeriNo : string;
  begin
    SetLength(FaturaUrunKareKodlar,tabKareKodListesi.RecordCount);
    tabKareKodListesi.First;
    i:=0;
    while not (tabKareKodListesi.Eof) do
     begin
       if clmSeriNoSec.EditValue='True' then
        begin
         //FaturaUrunKareKodlar[i].UrunSeriNumarası:= tabKareKodListesi.FieldByName('SERINO').AsString;
          FaturaUrunKareKodlar[i].UrunSeriNumarası := tabKareKodListesi.FieldByName('SERINO').AsString;
         //FaturaUrunKareKodlar[i].Lotno:= tabKareKodListesi.FieldByName('SERINO').AsString;
         //FaturaUrunKareKodlar[i].SonKullanım:= tabKareKodListesi.FieldByName('SERINO').AsString;
        i:=i+1;
        {Tablo.KareKodCikis(KareKodTakipCagiranTur,KareKodTakipCagiranUrunId, KareKodTakipCagiranBaslikId, KareKodTakipCagiranSatirId,KareKodCikSeriNo,KareKodTakipCagiranSatilanGln);
        }
        end;
      tabKareKodListesi.Next;
     end;
  end;
begin
  if shtKareKodDuzeltSil.TabVisible then
   begin
     if dtsKareKodListesi.State in [dsEdit,dsInsert] then
      tabKareKodListesi.Post;
   end;

  lblHataMesaj.Caption:='';
  if (KareKodTakipislemturu ='GD') or (KareKodTakipislemturu ='CD')  then
     clmSeriNo.Editing:= True // sadece düzeltme parametresi ile çağırılırsa ilgili kayıt düzeltilebilir.
  else
   clmSeriNo.Editing:= False;
  // clmLotno.Editing:= clmSeriNo.Editing;
{$REGION 'KareKodGiriş'}
  if KareKodTakipislemturu= 'G' then
   begin // Yeni Seri No Girişi
      if StrToInt(lblKayitSayisi.Caption) <> KareKodTakipKareKodsayisi then
       begin
         HataliKareKodMemoyaEkle('','Listedeki Seri Numarası sayısı gereken sayıdan farklı, lütfen kontrol ediniz');
         abort;
       end;
      if BosSatirVar then abort;
      if AyniSeriNoVar then Abort;
      if SeriNoDahaOnceGirilmismi then abort;

      //tüm kontrolleri geciyorsa seri no girişi yapılabilir
      SeriNolariGir;
      ModalResult:=mrOk;

   end
{$ENDREGION}
 else
{$REGION 'KareKodÇıkış'}
 if KareKodTakipislemturu = 'C' then
   begin
      if not (YeterliKareKodSecildi) then abort;
      SeriNolariCik;
      ModalResult:=mrOk;
    end
{$ENDREGION}
{$REGION 'Giriş-Çıkış Düzeltme'}
 else if (KareKodTakipislemturu = 'GD') or (KareKodTakipislemturu = 'CD') then
    begin
 
     ModalResult:= mrOk;
    //tabKareKodListesi.Refresh;
    end;
{$ENDREGION}
end;

function TKareKodDlg.KareKodParcala(KareKod: string) : TKareKodType;
  var
    strEan,strSN,str17,str10 ,strGen:string;
    PosSpecialChr,PosSpecialChrSKT:Integer;
 function PosChrSKT(str:string):Integer;
 var
  Pos17:Integer;AStr:string;
  TopPos:Integer;
 begin
  AStr:=str;
  TopPos:=0;
  Repeat
    Pos17:=Pos('17',Astr);
    if (pos17>0) then begin
     if Copy(Astr,Pos17+8,2)='10' then begin
      TopPos:=TopPos+pos17;
      result:=TopPos;
      Break;
     end
     else begin
          TopPos:=TopPos+pos17+1;// 17 yi aradan çıkaracağımız için 7 hiç hesaplanmadığından pozisyonu 1 arttırıyoruz.
          Astr:=Copy(AStr,pos17+2,1000);
     end;
    end
    else
      result:=0;
  Until pos17=0
 end; //Eklendi

begin
  if Copy(KareKod,1,2)='01' then
  begin
      PosSpecialChrSKT:= PosChrSKT(KareKod);
    if PosSpecialChrSKT>0 then
      strGen:=KareKod
    else
      strGen:='';
    strEan:= Copy(strGen,4,13);
    Result.UrunNumarası := strEan;
    strSN:=Copy(strGen,19,PosSpecialChrSKT-19 );//Pos( Char(119),strGen)
    Result.UrunSeriNumarası := Trim(strSN);
    str17:=Copy(strGen,PosSpecialChrSKT+2,6 );
    if str17<>'' then
     Result.SonKullanım:=Copy(str17,5,2)+'/'+Copy(str17,3,2)+'/'+'20'+Copy(str17,1,2)
    else
     Result.SonKullanım:='';
    str10:=Copy(strGen,PosSpecialChrSKT+10,length(strGen)-1);
    Result.Lotno:= trim(str10);
    strGen := '';
  end
  else
  begin
    result.UrunNumarası := '';
    result.UrunSeriNumarası := '';
    result.Lotno := '';
    result.SonKullanım := '';
  end;
end;  //Eklendi

procedure TKareKodDlg.memoKareKodlarPropertiesChange(Sender: TObject);
var
 i : Integer;
 NewNode, ChildNode : TcxTreeListNode;
begin
  lblKayitSayisi.Caption:='0';
  TreeListKareKod.Clear;
  setLength(KareKodlar,memoKareKodlar.Lines.Count);
  for i := 0 to memoKareKodlar.Lines.Count - 1 do
   begin
    if StringReplace(memoKareKodlar.Lines[i],' ','',[rfReplaceAll])<>'' then
     begin
     lblKayitSayisi.Caption:= IntToStr( strtoint(lblKayitSayisi.Caption)+1 );
      KareKodlar[i] := KareKodParcala(memoKareKodlar.Lines[i]);
      NewNode := TreeListKareKod.Add;
      NewNode.Texts[0] := KareKodlar[i].UrunNumarası;
      NewNode.Texts[1] := KareKodlar[i].UrunSeriNumarası;
      NewNode.Texts[2] := KareKodlar[i].Lotno;
      NewNode.Texts[3] := KareKodlar[i].SonKullanım;

     if  (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])>=0) and (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])<>i) then
     begin
      ChildNode := TreeListKareKod.AddChild(NewNode, nil);
      ChildNode.Texts[0] := 'KareKod Listesinde tekrar eden seri numaraları var, Lütfen kontrol ediniz';
     end;
     end;
   end;
end;  //Eklendi

procedure TKareKodDlg.memoKareKodlarPropertiesEditValueChanged(Sender: TObject);
var
 i : Integer;
NewNode, ChildNode : TcxTreeListNode;
begin
  lblKayitSayisi.Caption:='0';
  setLength(KareKodlar,memoKareKodlar.Lines.Count);
  TreeListKareKod.Clear;
  for i := 0 to memoKareKodlar.Lines.Count - 1 do
   begin
    if StringReplace(memoKareKodlar.Lines[i],' ','',[rfReplaceAll])<>'' then
     begin
      lblKayitSayisi.Caption:= IntToStr( strtoint(lblKayitSayisi.Caption)+1 );
      KareKodlar[i] := KareKodParcala(memoKareKodlar.Lines[i]);
      NewNode := TreeListKareKod.Add;
      NewNode.Texts[0] := KareKodlar[i].UrunNumarası;
      NewNode.Texts[1] := KareKodlar[i].UrunSeriNumarası;
      NewNode.Texts[2] := KareKodlar[i].Lotno;
      NewNode.Texts[3] := KareKodlar[i].SonKullanım;
     if  (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])>=0) and (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])<>i) then
     begin
      ChildNode := TreeListKareKod.AddChild(NewNode, nil);
      ChildNode.Expand(False);
      ChildNode.Texts[0] := 'KareKod Tekrarı';
     end;
     end;
   end;
end;  //Eklendi

procedure TKareKodDlg.pgKareKodChange(Sender: TObject);
var
 k : Word;
begin
  if pgKareKod.ActivePage= shtKareKodGiris then
   memoKareKodlarPropertiesEditValueChanged(Self)
  else
     editKareKodKeyUp(Self,k,[]);

end; //Eklendi

function TKareKodDlg.SiraNoArtir(Serino: String; adet: Integer): TStringList;
var
Metin,Rakamlar,Harfler : string;
i:Byte;  Bulunan,ErrorCode:Integer;
begin
Metin := Serino;
  Rakamlar:='';
  for i:=1 to length(Metin) do
  begin
    if Metin[i] in ['0'..'9']  then
    begin
      if (Metin[i]='0') and (length(rakamlar)=0) then  Harfler:= Harfler+Metin[i] else
      Rakamlar:=Rakamlar+Metin[i]
    end
    else
      Harfler:= Harfler+Metin[i]
  end;

  Val(Rakamlar,Bulunan,ErrorCode);
  Result := tstringlist.create;
  for I := 0 to adet-1 do
  begin
  Result.add(Harfler + IntToStr(Bulunan + I ));
  end;
end; //Eklendi

procedure TKareKodDlg.tabKareKodListesiAfterPost(DataSet: TDataSet);
begin
if dtsKareKodListesi.State in [dsEdit,dsInsert] then
begin
tabKareKodListesi.FieldByName('MALALINANGLN').AsString:= KareKodTakipCagiranAlimGln;
tabKareKodListesi.FieldByName('MALSATILANGLN').AsString:= KareKodTakipCagiranSatilanGln;
end;
end;  //Eklendi

procedure TKareKodDlg.tabKareKodListesiBeforeEdit(DataSet: TDataSet);
begin
oncekiKareKod:= tabKareKodListesi.FieldByName('SERINO').AsString;
oncekiUrunKod:= tabKareKodListesi.FieldByName('URUNKOD').AsString;
end;  //Eklendi

procedure TKareKodDlg.tabKareKodListesiBeforePost(DataSet: TDataSet);
begin
  if oncekiUrunKod+oncekiKareKod<>tabKareKodListesi.FieldByName('URUNKOD').AsString+tabKareKodListesi.FieldByName('SERINO').AsString then
  begin
   Tablo.Query5.Close;
   Tablo.Query5.sql.Clear;
   Tablo.Query5.SQL.Add('SELECT * FROM KAREKOD WHERE ALIM_DURUM = ''00000-Doğru Bildirim.'' ');
   Tablo.Query5.SQL.Add(' AND URUNKOD = '''+oncekiUrunKod+''' AND SERINO = '''+oncekiKareKod+''' ');
   if AktifVeriMotor = vmPG then Tablo.Query5.SQL.Text := PgSqlCevir(Tablo.Query5.SQL.Text);
   Tablo.Query5.Open;
   if Tablo.Query5.RecordCount>0 then
    begin
    Application.MessageBox('Ürünün alım bildirimi yapılmış.Değiştirmek için alımı iptal etmeniz gerekmektedir.','H A T A',MB_ICONERROR+MB_OK);
    Abort;
    end;
  end;
  if oncekiUrunKod+oncekiKareKod<>tabKareKodListesi.FieldByName('URUNKOD').AsString+tabKareKodListesi.FieldByName('SERINO').AsString then
  begin
   Tablo.Query5.Close;
   Tablo.Query5.sql.Clear;
   Tablo.Query5.SQL.Add('SELECT * FROM KAREKOD WHERE SATIS_DURUM = ''00000-Doğru Bildirim.'' ');
   Tablo.Query5.SQL.Add(' AND URUNKOD = '''+oncekiUrunKod+''' AND SERINO = '''+oncekiKareKod+''' ');
   if AktifVeriMotor = vmPG then Tablo.Query5.SQL.Text := PgSqlCevir(Tablo.Query5.SQL.Text);
   Tablo.Query5.Open;
   if Tablo.Query5.RecordCount>0 then
    begin
    Application.MessageBox('Ürünün satış bildirimi yapılmış.Değiştirmek için satışı iptal etmeniz gerekmektedir.','H A T A',MB_ICONERROR+MB_OK);
    Abort;
    end;
  end;
  if oncekiUrunKod+oncekiKareKod<>tabKareKodListesi.FieldByName('URUNKOD').AsString+tabKareKodListesi.FieldByName('SERINO').AsString then
   begin
     if (KareKodTakipCagiranTur in [10, 11, 12]) and (tabKareKodListesi.FieldByName('CIKFATURAID').AsInteger>0 ) then
      begin
        Application.MessageBox('Bu ürünün çıkışı yapılmış değiştirilemez','H A T A',MB_ICONERROR+MB_OK);
        Abort;
      end;
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM KAREKOD WHERE '+
                              ' SERINO = '''+tabKareKodListesi.FieldByName('SERINO').AsString+''' '+
                              ' AND URUNKOD = '''+tabKareKodListesi.FieldByName('URUNKOD').AsString+''' '+
                              ' AND ID <>'+tabKareKodListesi.FieldByName('ID').AsString+' ';
      if AktifVeriMotor = vmPG then Tablo.Query5.SQL.Text := PgSqlCevir(Tablo.Query5.SQL.Text);
      Tablo.Query5.Open;
     if Tablo.Query5.RecordCount>0 then
      begin
         Application.MessageBox(PChar(tabKareKodListesi.FieldByName('URUNKOD').AsString+' numaralı bu ürün için daha önce kullanılmış, tekrar girilemez') ,'H A T A',MB_ICONERROR+ MB_OK);
         Abort;
      end;
   end;
   if (oncekiUrunKod+oncekiKareKod<>tabKareKodListesi.FieldByName('URUNKOD').AsString+tabKareKodListesi.FieldByName('SERINO').AsString)
   then
    _Hata := AyniKarekoddanVar(tabKareKodListesi.FieldByName('SERINO').AsString,tabKareKodListesi.FieldByName('URUNKOD').AsString);
    if _Hata<>'' then
    begin
      Application.MessageBox(pchar(_Hata),'H A T A',MB_ICONERROR+MB_OK);
      Abort;
    end;
end;   //Eklendi

procedure TKareKodDlg.ToolButton1Click(Sender: TObject);
begin
 ModalResult:= mrCancel;
 Close;
end;   //Eklendi

procedure TKareKodDlg.TreeListeUrunEkle(Urunler: array of TKareKodType);
var
I:Integer;
NewNode ,ChildNode: TcxTreeListNode;
begin
TreeListKareKod.Clear;
  for I := 0 to Length(Urunler) do
    begin
    NewNode := TreeListKareKod.Add;
    NewNode.Texts[0] := Urunler[I].UrunNumarası;
    NewNode.Texts[1] := Urunler[I].UrunSeriNumarası;
    NewNode.Texts[2] := Urunler[I].Lotno;
    NewNode.Texts[3] := Urunler[I].SonKullanım;
    end;
    for I := 1 to  Length(Urunler)  do
    begin
    if TreeListKareKod.Items[I].Texts[1] = TreeListKareKod.Items[I-1].Texts[1] then
      begin
      ChildNode := TreeListKareKod.AddChild(TreeListKareKod.Items[I], nil);
      ChildNode.Expand(True);
      ChildNode.Texts[0] := 'KareKod Tekrarı';
      end;
    end;
end;   //Eklendi

procedure TKareKodDlg.TreeListKareKodDataChanged(Sender: TObject);
begin
lblKayitSayisi.Caption:= IntToStr(TreeListKareKod.Count);
end; //Eklendi

procedure TKareKodDlg.tvSeriNoListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
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
end; //Eklendi

end.


