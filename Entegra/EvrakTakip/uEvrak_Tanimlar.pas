unit uEvrak_Tanimlar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  uTanimBaseFrame,
  uEvrakModule, dxForms,
  uTanimGridFrame,
  uTanimGrid_AltBilgiFrame,
  uTanimGrid_AntetFrame,
  uTanimGrid_ArsivKlasorleriFrame,
  uTanimGrid_DagitimFrame,
  uTanimGrid_DinamikFormFrame,
  uTanimGrid_DosyaTasnifPlanFrame,
  uTanimGrid_DosyaTasnifPlanGrupFrame,
  uTanimGrid_DosyaTasnifPlanBirimlereGoreFrame,
  uTanimGrid_DTVTBirim,
  uTanimGrid_EvrakBirimFrame,
  uTanimGrid_EvrakCinsiFrame,
  uTanimGrid_GelenKonuFrame,
  uTanimGrid_GelenYerFrame,
  uTanimGrid_GelisSekliFrame,
  uTanimGrid_GidenTurFrame,
  uTanimGrid_GizlilikFrame,
  uTanimGrid_HavaleKuralFrame,
  uTanimGrid_ImzaYoluFrame,
  uTanimGrid_MetaGrupBilgileri,
  uTanimGrid_MetaBilgileri,
  uTanimGrid_OzelAlanFrame,
  uTanimGrid_ParafFrame,
  uTanimGrid_PostaTuruFrame,
  uTanimGrid_VekaletFrame,
  uTanimGrid_YaziDurumuFrame,

  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvExControls, JvButton, JvNavigationPane, Vcl.StdCtrls, Vcl.ExtCtrls,
  JvExExtCtrls, JvExtComponent, JvPanel, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxListView, dxBarBuiltInMenu, cxPC, cxSplitter;

type
  TfrmEvrakTanim = class(TForm)
    UstPanel: TJvPanel;
    LabelAltBaslik: TLabel;
    BaslikLabel: TLabel;
    FrameListesi: TcxListView;
    cxSplitter1: TcxSplitter;
    PageTanim: TcxPageControl;
    procedure FormCreate(Sender: TObject);
    procedure FrameListesiSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FrameListesiResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FrameListesiCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
  private
    { Private declarations }
    procedure Frames_Doldur;
    //Sekme Index'i döndürür
    function SekmeIndexGetir( _FrameClass : TClass) : integer;
    function SekmeEkle( _FrameClass : TClass) : integer; overload;
    function SekmeEkle( _FramClassType : TEvrakTanimClassType) : integer;overload;
    function EvrakSinifID( _class : TClass) : integer;
  public
    { Public declarations }
  end;

var
  frmEvrakTanim: TfrmEvrakTanim;

function EvrakTanimGoster( _Tag : integer; _Owner : TComponent; _Parent : TwinControl=Nil) : integer;

type
   recTanimFrameClass = record
     Caption : string;
     Tag : integer;
     Enabled : boolean;
     FrameClass : TClass;
   end;
const
   cListEvrakTanimClass : array[0..24] of recTanimFrameClass = (
   (Caption : 'Alt Bilgi';                          Tag:1;  Enabled: True;   FrameClass: TEvrakTanimAltBilgiFrame),
   (Caption : 'Paraf ';                             Tag:2;  Enabled: True;   FrameClass: TEvrakTanimParafFrame),
   (Caption : 'Havale Kural';                       Tag:3;  Enabled: True;   FrameClass: TEvrakTanimHavaleKuralFrame),
   (Caption : 'Daðýtým';                            Tag:4;  Enabled: True;   FrameClass: TEvrakTanimDagitimFrame),
   (Caption : 'Evrak Özel ALan';                    Tag:5;  Enabled: True;   FrameClass: TEvrakTanimOzelAlanFrame),
   (Caption : 'Gelen Konu Tanýmlama';               Tag:6;  Enabled: True;   FrameClass: TEvrakTanimGelenKonuFrame),
   (Caption : 'Gelen Yer Tanýmlama';                Tag:7;  Enabled: True;   FrameClass: TEvrakTanimGelenYerFrame),
   (Caption : 'Antet';                              Tag:8;  Enabled: True;   FrameClass: TEvrakTanimAntetFrame),
   (Caption : 'Evrak Birimi';                       Tag:9;  Enabled: True;   FrameClass: TEvrakTanimEvrakBirimiFrame),
   (Caption : 'Dosya Tasnif Plan Gruplarý';         Tag:10; Enabled: False;   FrameClass: TEvrakTanimDosyaTasnifPlanGrupFrame),
   (Caption : 'Dosya Tasnif Planý';                 Tag:11; Enabled: False;   FrameClass: TEvrakTanimDosyaTasnifPlanFrame),
   (Caption : 'Dosya Tasnif Planý (Birimlere Göre)'; Tag:12;Enabled: False;   FrameClass: TEvrakTanimDosyaTasnifPlanBirimlererGoreFrame),
   (Caption : 'Gizlilik';                           Tag:13; Enabled: False;   FrameClass: TEvrakTanimGizlilikFrame),
   (Caption : 'Yazý Durmu';                         Tag:14; Enabled: False;   FrameClass: TEvrakTanimYaziDurumuFrame),
   (Caption : 'Geliþ Þekli';                        Tag:15; Enabled: True;   FrameClass: TEvrakTanimGelisSekliFrame),
   (Caption : 'Giden Tür';                          Tag:16; Enabled: True;   FrameClass: TEvrakTanimGidenTurFrame),
   (Caption : 'Posta Tür';                          Tag:17; Enabled: False;   FrameClass: TEvrakTanimPostaTurFrame),
   (Caption : 'Evrak Cinsi';                        Tag:18; Enabled: False;   FrameClass: TEvrakTanimEvrakCinsiFrame),
   (Caption : 'Ýmza Yolu';                          Tag:19; Enabled: True;   FrameClass: TEvrakTanimImzaYoluFrame),
   (Caption : 'Arþiv Klasörleri';                   Tag:20; Enabled: False;   FrameClass: TEvrakTanimArsivKlasorleriFrame),
   (Caption : 'Meta Grup Bilgileri';                Tag:21; Enabled: False;   FrameClass: TEvrakTanimMetaGrupBilgileri),
   (Caption : 'Meta Bilgileri';                     Tag:22; Enabled: False;   FrameClass: TEvrakTanimMetaBilgileriFrame),
   (Caption : 'Vekalet';                            Tag:23; Enabled: True;   FrameClass: TEvrakTanimVekaletFrame),
   (Caption : 'DTVT Birim Bilgileri';               Tag:24; Enabled: True;   FrameClass: TEvrakTanimDTVTBirimFrame),
   (Caption : 'Dinamik Form Oluþtur';               Tag:25; Enabled: False;    FrameClass: TEvrakTanimDinamikFormFrame)
   );

implementation

{$R *.dfm}
{
  EvrakTanimGoster : Tag -1 Tüm Taným Sýnýflarý sekmelerini gösterir
                     Tag 1..25 Yalnýzca ilgili Taným sýnýfýný gösterir
}
function EvrakTanimGoster( _Tag : integer; _Owner : TComponent; _Parent : TwinControl=Nil) : integer;
var
  frmEvrakTanim: TfrmEvrakTanim;
begin
   {
   if (_Tag>0) and (_Tag<High(cListEvrakTanimClass)) then
     begin
       if not cListEvrakTanimClass[_Tag].Enabled then
         Exit(-1);
     end
    else
      Exit(-1);
    }
   frmEvrakTanim:= TfrmEvrakTanim.Create(_Owner);
   if Assigned( _Parent) then
     frmEvrakTanim.Parent := _Parent;

   try
     if (_Tag>0) and (_Tag<High(cListEvrakTanimClass)) then
       begin

       end
       else
         begin
            frmEvrakTanim.ShowModal;
         end;
   finally
      frmEvrakTanim.Free;
   end;

end;

function TfrmEvrakTanim.EvrakSinifID(_class: TClass): integer;
var
 i : integer;
begin
   Result := -1;
   for i := Low(cListEvrakTanimClass) to High(cListEvrakTanimClass) do
     if cListEvrakTanimClass[i].FrameClass = _class then
      begin
        Exit(i);
      end;
end;


procedure TfrmEvrakTanim.FormCreate(Sender: TObject);
begin
   FrameListesi.Items.Clear;
   Frames_Doldur;
   PageTanim.Properties.HideTabs := True;
end;

procedure TfrmEvrakTanim.FormResize(Sender: TObject);
begin
  FrameListesiResize(FrameListesi);
end;

procedure TfrmEvrakTanim.FrameListesiCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  itemEnabled : boolean;
  classIndex : integer;
  frameClassType : TEvrakTanimClassType;
begin
  itemEnabled := False;
  if Assigned(Item.Data) then
    begin
      classIndex := EvrakSinifID(TClass(Item.Data));
      if classIndex>-1 then
        itemEnabled := cListEvrakTanimClass[classIndex].Enabled;
    end;

  if itemEnabled then
   Sender.Canvas.Font.Color := clWindowText
     else
      Sender.Canvas.Font.Color := clGray;
  DefaultDraw := True;
end;

procedure TfrmEvrakTanim.FrameListesiResize(Sender: TObject);
begin
   FrameListesi.Columns[0].Width := TcxListView(Sender).Width - 16;
end;

procedure TfrmEvrakTanim.FrameListesiSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  classIndex : integer;
  frameClass : TEvrakTanimBaseFrame;
  frameClassType : TEvrakTanimClassType;
  isEnabled : boolean;
begin
    //BaslikLabel.Caption :=  recTanimFrameClass(
    classIndex := EvrakSinifID(TClass(Item.Data));
    isEnabled := False;
    if classIndex>-1 then
     begin
       BaslikLabel.Caption := cListEvrakTanimClass[classIndex].Caption;
       {UNUTMA}LabelAltBaslik.Caption := TClass(Item.Data).ClassName;
       frameClassType := TEvrakTanimClassType(cListEvrakTanimClass[classIndex].FrameClass);
       frameClass := TEvrakTanimBaseFrame(cListEvrakTanimClass[classIndex].FrameClass);
       isEnabled := cListEvrakTanimClass[classIndex].Enabled;
     end
       else
        frameClass := Nil;

   if Assigned(frameClass) and (isEnabled) then
    begin
       //SekmeEkle(TClass(Item.Data));
       SekmeEkle(frameClassType);
    end;
end;

procedure TfrmEvrakTanim.Frames_Doldur;
var
  i  : integer;
  Item : TListItem;
begin
  FrameListesi.Items.Clear;
  for i := Low(cListEvrakTanimClass) to High(cListEvrakTanimClass) do
    begin
       Item := FrameListesi.Items.Add;
       Item.Caption := cListEvrakTanimClass[i].Caption;
       Item.Data := cListEvrakTanimClass[i].FrameClass;
    end;

end;

function TfrmEvrakTanim.SekmeEkle(_FrameClass: TClass): integer;
var
  indexSekme : integer;
  sekme : TcxTabSheet;
  newFrameClass : TEvrakTanimBaseFrame;
  classID : Integer;
begin
  Result := -1;
  {
  indexSekme := SekmeIndexGetir(_FrameClass);
  if indexSekme = -1 then
    begin
       sekme := TcxTabSheet.Create(Self);
       sekme.PageControl := PageTanim;
       PageTanim.ActivePage := sekme;
       Result := sekme.TabIndex;
       newFrameClass := TEvrakTanimClassType(_FrameClass).Create(Self);
       newFrameClass.Parent := sekme;
       newFrameClass.Align := alClient;
       sekme.Tag := Integer(_FrameClass);
       classID := EvrakSinifID(_FrameClass);
       if classID>-1 then
         sekme.Caption := cListEvrakTanimClass[classID].Caption;
       // FocusIlkControl kaldýrýlabilir.
       if newFrameClass is TEvrakTanimHavaleKuralFrame then
         newFrameClass.FocusIlkControl(TEvrakTanimHavaleKuralFrame(newFrameClass).GridPanel2)
         else
       if newFrameClass is TEvrakTanimDagitimFrame then
        begin
        end
       else
         newFrameClass.FocusIlkControl(TEvrakTanimGridFrame(newFrameClass).GridPanel1);
    end
     else
       PageTanim.ActivePageIndex := indexSekme;
       }
end;

function TfrmEvrakTanim.SekmeEkle(_FramClassType: TEvrakTanimClassType): integer;
var
  indexSekme : integer;
  sekme : TcxTabSheet;
  newFrameClass : TEvrakTanimBaseFrame;
  classID : Integer;
begin
  indexSekme := SekmeIndexGetir(_FramClassType);
  if indexSekme = -1 then
    begin
       sekme := TcxTabSheet.Create(Self);
       sekme.PageControl := PageTanim;
       PageTanim.ActivePage := sekme;
       Result := sekme.TabIndex;
       newFrameClass := TEvrakTanimClassType(_FramClassType).Create(Self);
       newFrameClass.Parent := sekme;
       newFrameClass.Align := alClient;
       {$ifdef WIN64}
       sekme.Tag := NativeInt(_FramClassType);
       {$else}
       sekme.Tag := Integer(_FramClassType);
       {$endif}
       classID := EvrakSinifID(_FramClassType);
       if classID>-1 then
         sekme.Caption := cListEvrakTanimClass[classID].Caption;
       // FocusIlkControl kaldýrýlabilir.
       if newFrameClass is TEvrakTanimHavaleKuralFrame then
         newFrameClass.FocusIlkControl(TEvrakTanimHavaleKuralFrame(newFrameClass).GridPanel2)
         else
       if newFrameClass is TEvrakTanimDagitimFrame then
        begin
        end
       else
         newFrameClass.FocusIlkControl(TEvrakTanimGridFrame(newFrameClass).GridPanel1);
    end
     else
       PageTanim.ActivePageIndex := indexSekme;
end;

function TfrmEvrakTanim.SekmeIndexGetir(_FrameClass: TClass): integer;
var
 i : integer;
begin
 Result := -1;
 for i := 0 to PageTanim.PageCount-1  do
   begin
     if TClass(Pointer(PageTanim.Pages[i].Tag)) = _FrameClass then
       Exit(i);
   end;
end;

end.
