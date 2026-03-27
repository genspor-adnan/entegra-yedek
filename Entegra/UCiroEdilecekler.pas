unit UCiroEdilecekler;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,UTablo,
  Dialogs, ComCtrls, ToolWin, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxImageComboBox,
  cxCurrencyEdit, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, StdCtrls, Menus, cxTextEdit, Grids, cxContainer,
  cxLabel, ExtCtrls, cxLookAndFeelPainters, cxButtons, cxCheckBox, cxGridBandedTableView,
  cxGridDBBandedTableView, cxLookAndFeels, cxNavigator, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TCiroEdileceklerDlg = class(TForm)
    ToolBar1: TToolBar;
    YeniCekEkle: TToolButton;
    GroupBox1: TGroupBox;
    cxGrid: TcxGrid;
    GridTvieweski: TcxGridDBTableView;
    GridTvieweskiCEKSENETID: TcxGridDBColumn;
    GridTvieweskiTUR: TcxGridDBColumn;
    GridTvieweskiDURUM: TcxGridDBColumn;
    GridTvieweskiBORDRO: TcxGridDBColumn;
    GridTvieweskiSeriNo: TcxGridDBColumn;
    GridTvieweskiTARIH: TcxGridDBColumn;
    GridTvieweskiKOD: TcxGridDBColumn;
    GridTvieweskiVADE: TcxGridDBColumn;
    GridTvieweskiCARIKOD: TcxGridDBColumn;
    GridTvieweskiCARIUNVAN: TcxGridDBColumn;
    GridTvieweskiTUTAR: TcxGridDBColumn;
    GridTvieweskiKUR: TcxGridDBColumn;
    GridTvieweskiBANKAADI: TcxGridDBColumn;
    GridTvieweskiODEMEYERI: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TabCekSenet: TFDQuery;
    DtsCekler: TDataSource;
    PopupMenu1: TPopupMenu;
    Cirola1: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    PanelAlt: TPanel;
    Label45: TcxLabel;
    GridMakbuzToplam: TStringGrid;
    EditToplam: TcxCurrencyEdit;
    btnTamam: TcxButton;
    GridTvieweskiID: TcxGridDBColumn;
    GridTvieweskiSEC: TcxGridDBColumn;
    Grid: TcxGrid;
    GridBandedTview: TcxGridDBBandedTableView;
    GridBandedTviewID: TcxGridDBBandedColumn;
    GridBandedTviewCariKod: TcxGridDBBandedColumn;
    GridBandedTviewCariUnvani: TcxGridDBBandedColumn;
    GridBandedTviewBankaAdi: TcxGridDBBandedColumn;
    GridBandedTviewVade: TcxGridDBBandedColumn;
    GridBandedTviewTutar: TcxGridDBBandedColumn;
    GridBandedTviewSec: TcxGridDBBandedColumn;
    Level: TcxGridLevel;
    GridBandedTviewKur: TcxGridDBBandedColumn;
    GridBandedTviewRehberID: TcxGridDBBandedColumn;
    procedure FormShow(Sender: TObject);
    procedure YeniCekEkleClick(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure btnTamamClick(Sender: TObject);
    procedure GridBandedTviewSecPropertiesChange(Sender: TObject);
  private
    procedure SecilenlerToplam;
    { Private declarations }
  public
    { Public declarations }
    IslemHar,DataTablo,CekSenetNot: String;
    Tur, RehberId,MasrafID,Yer_ID,CekID,Tip : Integer;     //Tip ==> Çek=1,Senet=2
    TeminatTipi:integer;    //TeminatTipi ==> Bankadan=1,Cariden=2
    Cagiran, Yeri: SmallInt;
    Tutar:Currency;
    MakbuzNo,Aciklama : String;
    MakbuzTarih : TDateTime;

  end;

var
  CiroEdileceklerDlg: TCiroEdileceklerDlg;

  function MuhKoduGetir(Tur, Durum:Smallint; Kur:String):String;
implementation


Uses UAnaForm,FetaKurulusSiniflari,UBankaSecimi,UGirisKutusuEx;

{$R *.dfm}

function OncekiMuhKoduGetir(CekId : Integer; Tarih:TDateTime):String;
var s:string[30];
begin
  Tablo.TablodanSorguAc( 1,'select MUHKODU from CEKHAREKET where CEKSENETLERID='+IntToStr(CekId)+' and TARIH<'''+FormatDateTime('yyyy-mm-dd', Tarih)+'''');
  if Tablo.Query1.RecordCount<1 then
     Tablo.TablodanSorguAc(1,'select MUHKODU from CEKLER where ID='+IntToStr(CekId));
  Result := Tablo.Query1.fields[0].AsString
end;

function MuhKoduGetir(Tur, Durum:Smallint; Kur:String):String;
var s:string[30];
begin
  if Tur = 23 then s := '101'
  else s := '103';   //kod-durum-pbirimi  101-1-1
  s:=s+IntToStr(Durum);
  if Kur<>CariDoviz then
     s:=s+'2'
  else
     s:=s+'1';
  Tablo.TablodanSorguAc(1,'select HESAPKODU from HESAPPLANI where MUHASEBE='+s);
  if Tablo.Query1.RecordCount>0 then
     Result := Tablo.Query1.fields[0].AsString
  else
     Result := '';
end;

procedure TCiroEdileceklerDlg.btnTamamClick(Sender: TObject);
var
BilgiGir:Variant;
Recordindex,i,SayFalse,ID:integer;
Kur,Pbirimi:String;
begin

  if (IslemHar='C') or (IslemHar='CD' ) then begin //Ciro işlemi ise     'CD'=Diğer Formlardan gelenler için(FormShowa bak)
    CiroGirisMi:=True;
    if GridBandedTview.DataController.RecordCount > 0 then begin

      if IslemHar='C' then begin
        RehberId := Tablo.RehberAra_IDGetir(-99);
        if RehberId < 1 then
          Abort;
      end;

      for I := 0 to GridBandedTview.DataController.RecordCount - 1 do  begin
        if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then begin

          CekID:=GridBandedTview.DataController.GetValue(i,GridBandedTviewID.Index);
          PBirimi:=GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index);
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text:='Update '+DataTablo+' set CIROREHBERID=:RehId , CIROTARIH =:Tar ,CIROMAKBUZNO=:MakNo ,CIROMASRAFID=:MasrID, CIROLU=1 ,DURUM=4 Where ID=:CekID';
          Tablo.Query1.Params[0].Value := RehberId;
          Tablo.Query1.Params[1].Value := CiroMakbuzTarih;
          Tablo.Query1.Params[2].Value := MakbuzNo;
          Tablo.Query1.Params[3].Value := MasrafID;
          Tablo.Query1.Params[4].Value := CekID;
          Tablo.Query1.ExecSQL;

          //Ciro Edildi 4
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,REHBERID,BILGI,SUBEID,TIP,ONCEKIMUHKODU,MUHKODU) VALUES('+
          IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''',4,'+IntToStr(RehberId)+','''+Tablo.AciklamaGetir('REHBER','FIRMA',IntToStr(RehberId))+''','+IntToStr(SubeId)+' ,'+IntToStr(Tip)+','''+OncekiMuhKoduGetir(CekId,CiroMakbuzTarih)+''','''+MuhKoduGetir(23,4,PBirimi)+''')',[],[]);


        end else
         inc(Sayfalse);
      end;
      if SayFalse = GridBandedTview.DataController.RecordCount then begin
        ShowMessage('Ciro edilecek kayıt seçiniz.');
        abort;
      end else if SayFalse=GridBandedTview.DataController.RecordCount-1 then begin           //bir çek cirolanıyorsa çek wizard açılıyor.
        if Tip = 1 then begin
          ID := Tablo.CekSihirbazBaslat('D', Tur{23},1,0, CekID, RehberId,-99,CiroMakbuzTarih,MakbuzNo);
          if ID < 0 then     //Ciro Edildi 4
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from CEKHAREKET Where CEKSENETLERID='+IntToStr(CekID)+' and TARIH='''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''' and REHBERID='+IntToStr(RehberId)+' and TIP='+IntToStr(Tip)+' ',[],[]);
        end;

      end else begin
     // if Tip =1 then                                                            //çok çek cirolanıyorsa makbuz wizard açılır.
        Tablo.MakbuzSihirbazBaslat('D', Tur{23},0, ID, RehberId, CiroMakbuzTarih, CiroMakbuzNo)
      end;

    end;
  End else if IslemHar='Iade' then begin //Çek İade işlemi ise
    if GridBandedTview.DataController.RecordCount > 0 then begin

      for I := 0 to GridBandedTview.DataController.RecordCount - 1 do  begin
        if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then begin

          CekID:=GridBandedTview.DataController.GetValue(i,GridBandedTviewID.Index);
          PBirimi:=GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index);
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text:='Update '+DataTablo+' set DURUM=12,DEGISTIRMETARIHI=:Tar  Where ID=:CekID';
          Tablo.Query1.Params[0].Value:=FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat);
          Tablo.Query1.Params[1].Value:=CekID;
          Tablo.Query1.ExecSQL;

          //Çek İade Edildi 12
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,REHBERID,BILGI,SUBEID,TIP,ONCEKIMUHKODU,MUHKODU) VALUES('+
          IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''',12,'+IntToStr(RehberId)+','''+Tablo.AciklamaGetir('REHBER','FIRMA',IntToStr(RehberId))+''','+IntToStr(SubeId)+' ,'+IntToStr(Tip)+','''+OncekiMuhKoduGetir(CekId,CiroMakbuzTarih)+''','''+MuhKoduGetir(23,12,PBirimi)+''')',[],[]);


        end else
         inc(Sayfalse);
      end;
      if SayFalse = GridBandedTview.DataController.RecordCount then begin
        ShowMessage('İade edilecek kayıt seçiniz.');
        abort;
      end else if SayFalse=GridBandedTview.DataController.RecordCount-1 then begin           //bir çek iade oluyorsa çek wizard açılıyor.
        if Tip = 1 then begin
          ID := Tablo.CekSihirbazBaslat('D', Tur{23},1,0, CekID, RehberId,-99,CiroMakbuzTarih,MakbuzNo);
          if ID < 0 then         //Çek iade Edildi 12
            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from CEKHAREKET Where CEKSENETLERID='+IntToStr(CekID)+' and TARIH='''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''' and REHBERID='+IntToStr(RehberId)+' ',[],[]);
        end;
      end else begin                                                             //çok çek İade ediliyorsa makbuz wizard açılır.
       // if Tip=1 then
          Tablo.MakbuzSihirbazBaslat('D', Tur{23},0, ID, RehberId, CiroMakbuzTarih, CiroMakbuzNo)
      end;

    end;
  End else if IslemHar='Takas' then begin //Takasa verildi ise
      Kur := '';
//Kur kontrolü
    for I := 0 to GridBandedTview.DataController.RecordCount - 1 do  begin
      if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then begin
        if Kur='' then
          Kur:=GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index)
        else if Kur <> GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index) then begin
          Showmessage('Farklı kur içeren '+CekSenetNot+'ler bir arada gönderilemez!');
          Abort;
        end;
      end;
    end;
         //Seçilenler gelecek
    Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
    BankaSecimDlg.RehberId := '-1';
    BankaSecimDlg.Kur := Kur;
    BankaSecimDlg.Cagiran := 25;// bizim hesap listemiz  (21)
    BankaSecimDlg.ShowModal;
    if BankaSecimDlg.ModalResult = mrOk then begin
      for I := 0 to GridBandedTview.DataController.RecordCount - 1 do  begin
        if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then begin
          CekID:=GridBandedTview.DataController.GetValue(i,GridBandedTviewID.Index);
          PBirimi:=GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index);
          RehberId:=GridBandedTview.DataController.GetValue(i,GridBandedTviewRehberID.Index);

          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update '+DataTablo+' set DURUM=5,YERI='+BankaSecimDlg.TabSubeler.FieldByname('BANKAKODU').AsString+' , YERID ='+BankaSecimDlg.TabSubeler.FieldByname('SUBEKODU').AsString+'  Where ID ='+IntToStr(CekID)+'',[],[]);
          //Takasa verildi 5
          Tablo.TablodanSorguAc(2,'Select * from BANKALAR Where BANKAKODU='+BankaSecimDlg.TabSubeler.FieldByname('BANKAKODU').AsString+' ');

          veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,BILGI,SUBEID,TIP,ONCEKIMUHKODU,MUHKODU) VALUES('+
          IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''',5,'''+Tablo.Query2.FieldByName('BANKAADI').AsString+''','+IntToStr(SubeId)+' ,'+IntToStr(Tip)+','''+OncekiMuhKoduGetir(CekId,CiroMakbuzTarih)+''','''+MuhKoduGetir(23,5,PBirimi)+''') ',[],[]);

        end;
      end;
    end;
    BankaSecimDlg.Destroy;
  end else if IslemHar='Teminat' then begin       //Teminata verildi.
         //Seçilenler gelecek     //TeminatTipi ==> Bankadan=1,Cariden=2
    if TeminatTipi=2 then begin
      RehberId := Tablo.RehberAra_IDGetir(-99);
      if RehberId >0 then begin
        if TGirisKutusuEx.BilgiAlEx('Bilgi Girişi.', TGirdiDenetimleri.Create.Edit('Teminat için açıklama giriniz.', @BilgiGir))  <> mrOk then
        Abort;
        for I := 0 to GridBandedTview.DataController.RecordCount - 1 do  begin
          if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then begin
            CekID:=GridBandedTview.DataController.GetValue(i,GridBandedTviewID.Index);
            //RehberId:=GridBandedTview.DataController.GetValue(i,GridBandedTviewRehberID.Index);
            PBirimi:=GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update '+DataTablo+' set DURUM=6 Where ID ='+IntToStr(CekID)+'',[],[]);


            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,BILGI,ACIKLAMA,SUBEID,TIP,ONCEKIMUHKODU,MUHKODU,REHBERID) VALUES('+
            IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''',6,'''+Tablo.AciklamaGetir('REHBER','FIRMA',RehberId) +''','''+BilgiGir +''','+IntToStr(SubeId)+','+IntToStr(Tip)+','''+OncekiMuhKoduGetir(CekId,CiroMakbuzTarih)+''','''+MuhKoduGetir(23,6,PBirimi)+''','+IntToStr(RehberID)+') ',[],[]);

          end;
        end;
      end;

    end else begin
      Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
      BankaSecimDlg.RehberId := '-1';
      BankaSecimDlg.Cagiran := 25;// bizim hesap listemiz
      BankaSecimDlg.ShowModal;
      if BankaSecimDlg.ModalResult = mrOk then begin
        if TGirisKutusuEx.BilgiAlEx('Bilgi Girişi.', TGirdiDenetimleri.Create.Edit('Teminat için açıklama giriniz.', @BilgiGir))  <> mrOk then
        Abort;
        for I := 0 to GridBandedTview.DataController.RecordCount - 1 do  begin
          if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then begin
            CekID:=GridBandedTview.DataController.GetValue(i,GridBandedTviewID.Index);
            RehberId:=GridBandedTview.DataController.GetValue(i,GridBandedTviewRehberID.Index);
            PBirimi:=GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update '+DataTablo+' set DURUM=6,YERI='+BankaSecimDlg.TabSubeler.FieldByname('BANKAKODU').AsString+' , YERID ='+BankaSecimDlg.TabSubeler.FieldByname('SUBEKODU').AsString+' Where ID ='+IntToStr(CekID)+'',[],[]);
            //Teminata verildi 6
             Tablo.TablodanSorguAc(2,'Select * from BANKALAR Where BANKAKODU='+BankaSecimDlg.TabSubeler.FieldByname('BANKAKODU').AsString+' ');

            veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,BILGI,ACIKLAMA,SUBEID,TIP,ONCEKIMUHKODU,MUHKODU) VALUES('+
            IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''',6,'''+Tablo.Query2.FieldByName('BANKAADI').AsString +''','''+BilgiGir +''','+IntToStr(SubeId)+','+IntToStr(Tip)+','''+OncekiMuhKoduGetir(CekId,CiroMakbuzTarih)+''','''+MuhKoduGetir(23,6,PBirimi)+''') ',[],[]);

          end;
        end;
      end;
      BankaSecimDlg.Destroy;
    end;
  end else if IslemHar = 'Icra' then begin
    RehberId := Tablo.RehberAra_IDGetir(-99);
    if RehberId < 1 then
      Exit;
    if TGirisKutusuEx.BilgiAlEx('Bilgi Girişi.', TGirdiDenetimleri.Create.Edit('İcra için açıklama giriniz.', @BilgiGir))  <> mrOk then
      Abort;
    for I := 0 to GridBandedTview.DataController.RecordCount - 1 do  begin
      if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then begin

        CekID:=GridBandedTview.DataController.GetValue(i,GridBandedTviewID.Index);
        PBirimi:=GridBandedTview.DataController.GetValue(i,GridBandedTviewKUR.Index);
                                                                            //Yeri=Seçilen Avukat Idsi verilir
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update '+DataTablo+' set DURUM=10,YERI='+IntToStr(RehberId)+' , YERID =0  Where ID ='+IntToStr(CekID)+'',[],[]);
        //Ciro Edildi 4
        veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,REHBERID,ACIKLAMA,BILGI,SUBEID,TIP,ONCEKIMUHKODU,MUHKODU ) VALUES('+
        IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd hh:nn',CiroMakbuzTarih)+''',10,'+IntToStr(RehberId)+','''+BilgiGir+''','''+Tablo.AciklamaGetir('REHBER','FIRMA',IntToStr(RehberId))+''','+IntToStr(SubeId)+' ,'+IntToStr(Tip)+','''+OncekiMuhKoduGetir(CekId,CiroMakbuzTarih)+''','''+MuhKoduGetir(23,10,PBirimi)+''')',[],[]);


      end else
       inc(Sayfalse);
    end;
  end;
  if Sender<>nil then
    ModalResult := MrOK;
end;

procedure TCiroEdileceklerDlg.FormShow(Sender: TObject);
var
i,j:integer;
begin
  case Tip of
    1:begin
      DataTablo:='CEKLER';
      CekSenetNot:='Çek';
    end;
    2:begin
      DataTablo:='SENETLER';
      CekSenetNot:='Senet';
    end;
  end;
  TabCekSenet.SQL.Text:=' SELECT C.*,CARIKOD = R.KOD, CARIUNVAN = R.FIRMA,C.HESAPNO, BS.BANKAKODU, B.BANKAADI, BS.SUBEKODU, BS.SUBEADI'+
      ' FROM CEKLER C  LEFT OUTER JOIN REHBER R ON C.REHBERID=R.ID  LEFT OUTER JOIN BANKASUBELER BS ON BS.ID = C.BANKASUBELERID '+
      ' LEFT OUTER JOIN BANKALAR B ON B.BANKAKODU = BS.BANKAKODU where C.CEKSENET='+IntToStr(Tip)+' and  C.TUR = '+IntToStr(Tur)+' and C.DURUM=1  and isnull(C.CIROLU,0) <> 1 Order by Vade';
  TabloYenile(TabCekSenet,[]);
  GroupBox1.Caption:='Portföydeki ciro yapılabilecek '+CekSenetNot+' listesi';

  if IslemHar='C' then begin          //CekListeFrame den geliyorsa
   YeniCekEkle.Visible:=False

  end else if IslemHar='R' then  begin    //RehberAraDlg  den geliyorsa
    IslemHar:='CD'
  end else if IslemHar='K' then  begin          //Kasa   dan geliyorsa
    IslemHar:='CD'
  end else if IslemHar='M' then  begin             //Makbuz  dan geliyorsa
    IslemHar:='CD'
  end else if IslemHar='Takas' then  begin         //Takasa Verildi ise.

  end;
  if CekIdTut.Count > 0  then begin
    for I := 0 to CekIdTut.Count-1 do begin
       for j := 0 to GridBandedTview.DataController.RecordCount - 1 do begin
         if VarToStr(GridBandedTview.DataController.GetValue(j,GridBandedTviewID.Index))=CekIdTut.Strings[i] then

//        GridBandedTview.DataController.SetValue(j,GridBandedTviewSec.Index,True);
           GridBandedTview.DataController.Values[j,GridBandedTviewSec.Index]:=True;
       end;
    end;
    SecilenlerToplam;
  end;
  CekIdTut.Clear;
end;

procedure TCiroEdileceklerDlg.GridBandedTviewSecPropertiesChange(Sender: TObject);
begin
   SecilenlerToplam;
end;

procedure TCiroEdileceklerDlg.SecilenlerToplam;
var
i:integer;
Toplam:Variant;
begin
   Toplam:=0;
   for I := 0 to GridBandedTview.DataController.RecordCount - 1 do begin
      if GridBandedTview.DataController.GetValue(i, GridBandedTviewSec.Index) = True then
         Toplam:= Toplam + GridBandedTview.DataController.GetValue(i,GridBandedTviewTutar.Index);
   end;
   EditToplam.EditValue:=Toplam;
end;
procedure TCiroEdileceklerDlg.YeniCekEkleClick(Sender: TObject);
begin
   CiroYeniCilck:=true;
   Visible:=False;
   Tablo.CekSihirbazBaslat('E',Tur ,1,0, -1, RehberId,-1,MakbuzTarih,'');
   ModalResult:=mrCancel;
end;

procedure TCiroEdileceklerDlg.ToolButton3Click(Sender: TObject);
begin
   ModalResult:=mrClose;
end;

end.





