unit UMekanMasaDizayn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, cxControls, cxContainer, cxEdit, cxImage, Menus,
  cxLookAndFeelPainters, StdCtrls, cxButtons, jpeg, cxListBox, cxTextEdit, dxSkinLondonLiquidSky, ComCtrls, ToolWin, ExtCtrls, DB, FireDAC.Comp.Client, cxLabel,
  cxGraphics, cxDropDownEdit, cxMaskEdit, cxSpinEdit, cxImageComboBox,
  cxLookAndFeels, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxNavigator, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  cxButtonEdit, dxGDIPlusClasses, JvExControls, JvButton, JvNavigationPane;

type
  TShape = class(ExtCtrls.TShape); //interposer class
  TMekanMasaDizaynDlg = class(TForm)
    Panel1: TPanel;
    ToolBar10: TToolBar;
    iletisimEkle: TToolButton;
    iletisimSil: TToolButton;
    ToolButton14: TToolButton;
    cxButton1: TcxButton;
    Label3: TLabel;
    Label4: TLabel;
    ToolButton1: TToolButton;
    Shape1: TShape;
    DizaynKaydet: TcxButton;
    ComboMasaListe: TcxComboBox;
    PanelBilgi: TPanel;
    Label1: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EditEn: TcxSpinEdit;
    EditBoy: TcxSpinEdit;
    ComboSekil: TcxImageComboBox;
    Label7: TLabel;
    Label8: TLabel;
    EditSol: TcxSpinEdit;
    EditUst: TcxSpinEdit;
    Label9: TLabel;
    Label10: TLabel;
    cxButton4: TcxButton;
    btnsil: TcxButton;
    GridMekan: TcxGrid;
    GridMekanView: TcxGridDBTableView;
    cxGridLevel5: TcxGridLevel;
    TabMekan: TFDQuery;
    DtsMekan: TDataSource;
    GridMekanViewID: TcxGridDBColumn;
    GridMekanViewMEKAN: TcxGridDBColumn;
    GridMekanViewSUBEID: TcxGridDBColumn;
    GridMekanViewSUBE: TcxGridDBColumn;
    ZeminResim: TcxImage;
    ZeminResimTus: TcxButton;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    StatusBar1: TStatusBar;
    LabelResmiSil: TcxLabel;
    procedure MekanMasaDizaynKaydet;
    procedure MekanMasaDizaynYukle;
    procedure MekanMasaDizaynTemizle;
    procedure ShapeMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure ShapeMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cxButton1Click(Sender: TObject);
    procedure btnsilClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cxButton4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditMasaKeyPress(Sender: TObject; var Key: Char);
    procedure iletisimEkleClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure iletisimSilClick(Sender: TObject);
    procedure DizaynKaydetClick(Sender: TObject);
    procedure EditEnPropertiesChange(Sender: TObject);
    procedure EditBoyPropertiesChange(Sender: TObject);
    procedure ComboSekilPropertiesChange(Sender: TObject);
    procedure EditSolPropertiesChange(Sender: TObject);
    procedure EditUstPropertiesChange(Sender: TObject);
    procedure TabMekanAfterScroll(DataSet: TDataSet);
    procedure TabMekanAfterOpen(DataSet: TDataSet);
    procedure ZeminResimTusClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure LabelResmiSilClick(Sender: TObject);
  private
    { Private declarations }
    procedure MasaComboDoldur;
    procedure MekanIsimle(Ekle:Boolean);
  public
  sayac:integer;

    { Public declarations }
  end;

  TLabelShape = class(TShape)
  private
    FCaption: string;
      procedure SetCaption(const Value: string);
  protected
    procedure Paint; override;
  published
    property Caption: string read FCaption write SetCaption;
  end;

var
  MekanMasaDizaynDlg: TMekanMasaDizaynDlg;


implementation

uses UMekanMasaGor, Utablo,FetaKurulusSiniflari, UGirisKutusuEx, PrjConst, UResim;

var
  secili : string;
  SeciliSekil : TShape;
  Resizingg : Boolean;
  LastPosition : TPoint;

{$R *.dfm}

procedure TLabelShape.Paint;
begin
    inherited Paint;
    Canvas.Font.Name :='Arial';// set the font
    Canvas.Font.Size  :=20;//set the size of the font
    Canvas.Font.Color:=clBlue;//set the color of the text
    Canvas.TextOut(10,10,Hint);
end;

procedure TLabelShape.SetCaption(const Value: string);
begin
  FCaption := Value;
  Refresh;
end;

procedure TMekanMasaDizaynDlg.MekanMasaDizaynTemizle;
var
    i:integer;
begin
    sayac := -1;

    SeciliSekil := nil;

   for i:=(ComponentCount-1) downto 0 do
    Begin
      if (Components[i] is TShape) and (Components[i].Name<>'Shape1') Then
      begin

         with TShape(Components[i]) do begin
          free;
        end;
      end;
    end;

    //label temizlik +
    for i:=(ComponentCount-1) downto 0 do
    Begin

      if Components[i] is TcxLabel Then
      begin

         with TcxLabel(Components[i]) do begin
          free;
        end;
      end;
    End;
    //label temizlik -

end;

procedure TMekanMasaDizaynDlg.MekanMasaDizaynYukle;
begin
    SeciliSekil := nil;
    PanelBilgi.Visible := False;
    Tablo.TablodanSorguAc(1,'select * from MASALAR where MEKAN = '+TabMekan.FieldByName('ID').AsString);
    ComboMasaListe.Properties.Items.Clear;
    while not Tablo.Query1.Eof do begin
          ComboMasaListe.Properties.Items.add(Tablo.Query1.FieldByName('MASANO').AsString);
          SeciliSekil := TLabelShape.Create(MekanMasaDizaynDlg);
          with SeciliSekil do  begin
             Name:='M'+Tablo.Query1.FieldByName('ID').AsString;
             Hint:=trim(Tablo.Query1.FieldByName('MASANO').AsString);
             Tag := Tablo.Query1.FieldByName('ID').AsInteger;
             Top := Tablo.Query1.FieldByName('USTTEN').AsInteger;
             Left := Tablo.Query1.FieldByName('SOLDAN').AsInteger;
             Width := Tablo.Query1.FieldByName('EN').AsInteger;
             Height := Tablo.Query1.FieldByName('BOY').AsInteger;
             case Tablo.Query1.FieldByName('SEKIL').AsInteger of
               1 : Shape := stCircle;
               2 : Shape := stEllipse;
               3 : Shape := stRectangle;
             end;
             Parent := ZeminResim;//ScrollBox1;
             OnMouseMove := ShapeMouseMove;
             OnMousedown:= ShapeMouseDown;
             OnMouseUp:= ShapeMouseUp;
          end;
          //MasaNoYaz(SeciliSekil);
          SeciliSekil := nil;
          Tablo.Query1.Next;
    end;
end;

procedure TMekanMasaDizaynDlg.TabMekanAfterOpen(DataSet: TDataSet);
begin
   GridMekanView.ApplyBestFit(nil);
end;

procedure TMekanMasaDizaynDlg.TabMekanAfterScroll(DataSet: TDataSet);
begin
    DizaynKaydetClick(self);
    cxButton1.Enabled:=true;
    label4.Caption:=TabMekan.FieldByName('MEKAN').AsString;
    MekanMasaDizaynTemizle;
    ResimGetir(-4444, 121, TabMekan.FieldByName('ID').AsInteger, ZeminResim);
    MekanMasaDizaynYukle;
end;

procedure TMekanMasaDizaynDlg.ToolButton1Click(Sender: TObject);
begin
    MekanIsimle(False);
end;

procedure TMekanMasaDizaynDlg.ZeminResimTusClick(Sender: TObject);
begin
   Tablo.OpenPictureDialog1.Filter:= '*.jpg; *.jpeg';
   Tablo.OpenPictureDialog1.FilterIndex := 0;
   if Tablo.OpenPictureDialog1.Execute then begin
      LabelResmiSilClick(Self); //sil
      ImajTablosunaResimKaydet(Tablo.OpenPictureDialog1.FileName,nil, -4444, 121, TabMekan.FieldByName('ID').AsInteger);
      ResimGetir(-4444, 121, TabMekan.FieldByName('ID').AsInteger, ZeminResim);
   end;
end;

procedure TMekanMasaDizaynDlg.ComboSekilPropertiesChange(Sender: TObject);
begin
    if ComboSekil.ItemIndex=0 then SeciliSekil.Shape := stCircle
    else if ComboSekil.ItemIndex=1 then SeciliSekil.Shape := stEllipse
    else if ComboSekil.ItemIndex=2 then SeciliSekil.Shape := stRectangle;
end;

function IsimAl(var Masa:string):Boolean;
begin
    Masa := '';
    if InputQuery('Masa Adı Değiştirme','Yeni Masa Adı Yazınız', Masa) = True then begin
        Masa := Trim(Masa);
        if Masa = '' then begin
           showmessage('Boş Giriş Yapılamaz');
           Result := False;
           exit;
        end;
        if Veritabani.VeriVarMi(Tablo.FDCnn,'select ID from MASALAR where MASANO='''+Masa+''' ',[],[]) then begin
           showmessage('Bu isim daha önce verilmiş!');
           Result := False;
           exit;
        end;
    end;
    Result := True;
end;

procedure TMekanMasaDizaynDlg.cxButton1Click(Sender: TObject);
var lbl:TLabel;
    PanelRect : TRect;
    Masa:string;
begin
    if not IsimAl(Masa) then exit;

    if Masa = '' then begin
       showmessage('Boş Giriş Yapılamaz');
       exit;
    end;


    Tablo.TablodanSorguAc(3,'insert into MASALAR(MASANO,SOLDAN,USTTEN,EN,BOY,SEKIL,KOLTUK,MEKAN,DURUM) '+
       ' values('''+Masa+''',325,250,80,80,1,1,'+TabMekan.FieldByName('ID').AsString+',0) Select SCOPE_IDENTITY() ');

    if SeciliSekil<>nil then
       SeciliSekil.Color := clWhite;

    SeciliSekil := TLabelShape.Create(MekanMasaDizaynDlg);
    with SeciliSekil do begin
        Parent := ZeminResim;//ScrollBox1;
        Name:='M'+Tablo.Query3.Fields[0].AsString;
        Hint := Masa;
        Tag := Tablo.Query3.Fields[0].AsInteger;
        Top := 250;
        Left := 325;
        Width := 100;
        Height := 80;
        color := clyellow;
        OnMouseMove := ShapeMouseMove;
        OnMousedown := ShapeMouseDown;
        OnMouseUp := ShapeMouseUp;
    end;

    //MasaNoYaz(SeciliSekil);
    //SeciliSekil := nil;
    ComboMasaListe.Properties.Items.Add(Masa);
    ShapeMouseDown(SeciliSekil, mbLeft, [], 1,1);
end;

procedure TMekanMasaDizaynDlg.cxButton4Click(Sender: TObject);
var
    Masa:string;
begin
   if IsimAl(Masa) then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set MASANO ='''+Masa+''' where MASANO='''+ComboMasaListe.Text+'''', [],[]);
        SeciliSekil.Hint := Masa;
        MasacomboDoldur;
    end;
end;

procedure TMekanMasaDizaynDlg.MasaComboDoldur;
begin
  ComboMasaListe.Text:='';
  ComboMasaListe.Properties.Items.Clear;
  Tablo.TablodanSorguAc(1,'select MASANO from MASALAR where MEKAN = '+TabMekan.FieldByName('ID').AsString);
  ComboMasaListe.Properties.Items.Clear;
  while not Tablo.Query1.Eof do begin
    ComboMasaListe.Properties.Items.add(Tablo.Query1.FieldByName('MASANO').AsString);
    Tablo.Query1.next;
  end;
end;

procedure TMekanMasaDizaynDlg.btnsilClick(Sender: TObject);
var
    i:integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
     SeciliSekil.Free;
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from MASALAR where MASANO='''+ComboMasaListe.Text+'''', [],[]);
     MasaComboDoldur;
     SeciliSekil:=nil;
  end;
end;

procedure TMekanMasaDizaynDlg.ShapeMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   Resizingg := False;
end;

procedure TMekanMasaDizaynDlg.ShapeMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i:SmallInt;
//var cntrl : TControl;
begin
{    if ((cntrl.Width - X) < 15) and ((cntrl.Height - Y) < 15) then
    begin
        LastPosition.X := X;
        LastPosition.Y := Y;
        Resizingg := True;
    end; }

   if SeciliSekil<>nil then
      SeciliSekil.Brush.color := clWhite;
   SeciliSekil := TShape(sender);
   ComboMasaListe.Text := TShape(sender).Hint;
   PanelBilgi.Visible := ComboMasaListe.Text<>'';
   if PanelBilgi.Visible then begin
      btnsil.Enabled:=true;
      cxButton4.Enabled:=true;
      //EditMasa.Text:= SeciliSekil.name;
      secili:=SeciliSekil.name;
      if SeciliSekil.Shape = stCircle then ComboSekil.ItemIndex := 0
      else if SeciliSekil.Shape = stEllipse then ComboSekil.ItemIndex := 1
      else ComboSekil.ItemIndex := 2;
      EditEn.Value := SeciliSekil.Width;
      EditBoy.Value := SeciliSekil.Height;
      EditSol.Value := SeciliSekil.Left;
      EditUst.Value := SeciliSekil.top;
      SeciliSekil.Brush.color := clYellow;

      LastPosition.X := X;
      LastPosition.Y := Y;
      Resizingg := True;
  end;
end;

procedure TMekanMasaDizaynDlg.ShapeMouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer);
var
  TempPanel: TPanel;
  AControl: TControl;
  lPoint: TPoint;
begin
{  if ssLeft in Shift then begin
      AControl := Sender as TControl;
      //SeciliSekil := Sender as TControl;
      lPoint := AControl.Parent.ScreenToClient(AControl.ClientToScreen(Point(X, Y)));
      AControl.Left := lPoint.X - AControl.Width div 2;
      AControl.Top := lPoint.Y - AControl.Height div 2;
  end; }

     AControl := Sender as TControl;
     if ssLeft in Shift then begin //sol mouse basılı
        //SeciliSekil := Sender as TControl;
        if AControl.Cursor = crSizeNWSE then   //büyütme
//    if Resizingg then
          begin
              AControl.Width := AControl.Width + (X - LastPosition.X);
              LastPosition.X := X;
              AControl.Height := AControl.Height + (Y - LastPosition.Y);
              LastPosition.Y := Y;
          end
          else
            begin //hareket
             lPoint := AControl.Parent.ScreenToClient(AControl.ClientToScreen(Point(X, Y)));
             AControl.Left := lPoint.X - AControl.Width div 2;
             AControl.Top := lPoint.Y - AControl.Height div 2;
            end
     end
     else
     begin
        if ((AControl.Width - X) < 15) and ((AControl.Height - Y) < 15) then
           AControl.Cursor := crSizeNWSE
        else
           AControl.Cursor := crSizeAll; //crDefault;
     end;
end;

procedure TMekanMasaDizaynDlg.EditBoyPropertiesChange(Sender: TObject);
begin
      SeciliSekil.Height := EditBoy.Value;
end;

procedure TMekanMasaDizaynDlg.EditEnPropertiesChange(Sender: TObject);
begin
   SeciliSekil.Width := EditEn.Value;
end;

procedure TMekanMasaDizaynDlg.EditMasaKeyPress(Sender: TObject; var Key: Char);
begin
    if key=#13 then
    begin
    cxButton4.Click;
    end;

    if key=' ' then begin key:='_'; end;
    if key='.' then begin key:='_'; end;
    if key=',' then begin key:='_'; end;
    if key='-' then begin key:='_'; end;
    if key='<' then begin key:='_'; end;
    if key='>' then begin key:='_'; end;
    if key='!' then begin key:='_'; end;
    if key='"' then begin key:='_'; end;
    if key='+' then begin key:='_'; end;
    if key='%' then begin key:='_'; end;
    if key='&' then begin key:='_'; end;
    if key='/' then begin key:='_'; end;
    if key='(' then begin key:='_'; end;
    if key=')' then begin key:='_'; end;
    if key='=' then begin key:='_'; end;
    if key='?' then begin key:='_'; end;
    if key='/' then begin key:='_'; end;
    if key='@' then begin key:='_'; end;
    if key='''' then begin key:='_'; end;
    if key='*' then begin key:='_'; end;

end;
procedure TMekanMasaDizaynDlg.EditSolPropertiesChange(Sender: TObject);
begin
    SeciliSekil.Left:= EditSol.Value;
end;

procedure TMekanMasaDizaynDlg.EditUstPropertiesChange(Sender: TObject);
begin
    SeciliSekil.Top := EditUst.Value;
end;

procedure TMekanMasaDizaynDlg.DizaynKaydetClick(Sender: TObject);
begin
   MekanMasaDizaynKaydet;
end;

procedure TMekanMasaDizaynDlg.MekanMasaDizaynKaydet;
var
    i,sekil, koltuk:integer;
    yeni:TShape;
begin
    for i:=0 to ComponentCount-1 do Begin
        if (Components[i] is TShape) and (Components[i].Name<>'Shape1') Then begin
           with TShape(Components[I]) do begin
             if Shape=stCircle then sekil := 1
             else if Shape=stEllipse then sekil := 2
             else sekil := 3;
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update MASALAR set SOLDAN='+inttostr(left)+',USTTEN='+inttostr(top)+',EN='+inttostr(width)+',BOY='+inttostr(Height)+',SEKIL='+inttostr(sekil)+',KOLTUK='+inttostr(koltuk)+' where ID='+IntToStr(Tag),[],[]);
           end;
        end;
    End;
end;

procedure TMekanMasaDizaynDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    MekanMasaDizaynKaydet;
end;

procedure TMekanMasaDizaynDlg.FormShow(Sender: TObject);
begin
    WindowState := wsMaximized;
    TabloYenile(TabMekan, []);
end;


procedure TMekanMasaDizaynDlg.MekanIsimle(Ekle:Boolean);
var
    Mekan,Sube:Variant;
    Deger : Integer;
begin
    if Ekle then
       Sube := SubeId
    else begin
       Mekan:= TabMekan.fieldByName('MEKAN').asstring;
       Sube := TabMekan.fieldByName('SUBEID').asstring;
    end;

    if TGirisKutusuEx.BilgiAlEx('Mekan / Şube Seçimi', TGirdiDenetimleri.Create.Edit('Mekan Adı :', @Mekan).ImageComboBox('Şube', @Sube,Tablo.FDCnn,'select ID,FIRMA from REHBER where ID<0 order by 1',False,nil)) <> mrOk then
       exit;
    if (mekan='')or(Sube='') then begin
            showmessage('Boş Giriş Yapılamaz');
            exit;
    end;


    //Tablo.TablodanSorguAc(1,'select top 1 BOLUM from GENINI where BOLUM=-4444 and ANAHTAR='''+mekan+''' and DIL='+VarToStr(Sube));//DIL alanında şube tutulur);
//    if Tablo.Query1.RecordCount>=1 then begin
//            showmessage(mekan+' Sisteme Kayıtlı');
//            exit;
    if Ekle then begin
       Tablo.TablodanSorguAc(1,'select isnull(max(DEGER),0)+1 from GENINI where BOLUM=-4444' );
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL) values(-4444,'''+mekan+''','+Tablo.Query1.Fields[0].AsString+','+VarToStr(Sube)+')',[],[]);
    end
    else if TabMekan.fieldByName('MEKAN').asstring='' then //MASA tablosunda bilgi olup mekan tablosunda yoksa
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL) values(-4444,'''+mekan+''','+TabMekan.FieldByName('ID').AsString+','+VarToStr(Sube)+')',[],[])
    else
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update GENINI set ANAHTAR='''+mekan+''',DIL='+IntToStr(Sube)+'  where BOLUM=-4444 and DEGER='+TabMekan.FieldByName('ID').AsString, [], []);//DIL alanında şube tutulur);
 //    Label4.Caption:='';
    TabloYenile(TabMekan, []);
end;

procedure TMekanMasaDizaynDlg.iletisimEkleClick(Sender: TObject);
begin
   MekanIsimle(True);
   PanelBilgi.Visible:=False;
end;

procedure TMekanMasaDizaynDlg.iletisimSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
     Tablo.TablodanSorguAc(1,'select top 1 ID  from MASALAR where MEKAN='''+TabMekan.FieldByName('ID').AsString+''' ');
     if Tablo.Query1.RecordCount>=1 then begin
        showmessage('Önce Kayıtlı Masaları Siliniz');
        exit;
     end else begin
        LabelResmiSilClick(Self); //sil
        Veritabani.BasitKomutÇalıştır( Tablo.FDCnn,'delete from GENINI where DEGER='+TabMekan.FieldByName('ID').AsString+' and BOLUM=-4444 ',[],[]);//DIL alanında şube tutulur,[],[]);
     end;
     Label4.Caption:='';
     TabloYenile(TabMekan, []);
     PanelBilgi.Visible:=False;
  end;
end;



procedure TMekanMasaDizaynDlg.KapatTusClick(Sender: TObject);
begin
  Close;
end;

procedure TMekanMasaDizaynDlg.LabelResmiSilClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from IMAJ where REHBERID=-4444 and YERI=121 and YER_ID='+TabMekan.FieldByName('ID').AsString, [],[]);
   ZeminResim.Clear;
end;

end.



