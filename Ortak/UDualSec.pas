unit UDualSec;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, UCombo,
  Buttons, ExtCtrls, Dialogs;

type
  TDualListDlg = class(TForm)
    SrcList: TListBox;
    DstList: TListBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Bevel1: TBevel;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExcAllBtnClick(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DualListDlg: TDualListDlg;

procedure Dual_Liste_Ayarlama(Ini1 : TIni; Baslik1:String);

implementation

uses UMesaj;

var i     : integer;
    Ini   : TIni;
    Baslik:String;

{$R *.DFM}

procedure Dual_Liste_Ayarlama(Ini1 : TIni; Baslik1:String);
begin
  Ini := Ini1;
  Baslik := Baslik1;
  Application.CreateForm(TDualListDlg, DualListDlg);
  DualListDlg.ShowModal;
  DualListDlg.Destroy;
end;

procedure TDualListDlg.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  MoveSelected(SrcList, DstList.Items);
  SetItem(SrcList, Index);
end;

procedure TDualListDlg.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items);
  SetItem(DstList, Index);
end;

procedure TDualListDlg.IncAllBtnClick(Sender: TObject);
begin
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
  SrcList.Items.Clear;
  SetItem(SrcList, 0);
end;

procedure TDualListDlg.ExcAllBtnClick(Sender: TObject);
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
end;

procedure TDualListDlg.MoveSelected(List: TCustomListBox; Items: TStrings);
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

procedure TDualListDlg.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end;

function TDualListDlg.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TDualListDlg.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;

procedure TDualListDlg.FormCreate(Sender: TObject);
begin
   Ini.ReadSection(Baslik, SrcList.Items);
   for i := SrcList.Items.Count-1 downto 0 do
     SrcList.Selected[i] := Ini.ReadString(Baslik, SrcList.Items[i],'0')='0';
   MoveSelected(SrcList, DstList.Items);
   SetButtons;
end;

procedure TDualListDlg.BitBtn1Click(Sender: TObject);
begin
   Ini.EraseSection(Baslik);
   for i := 0 to SrcList.Items.Count-1 do
     Ini.WriteString(Baslik, SrcList.Items[i],'1');
   for i := 0 to DstList.Items.Count-1 do
     Ini.WriteString(Baslik, DstList.Items[i],'0');
end;

procedure TDualListDlg.EkleTusClick(Sender: TObject);
var MesajOkunan : String;
begin
  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then
     SrcList.Items.Add(MesajOkunan);
  SetButtons;
end;

procedure TDualListDlg.SilTusClick(Sender: TObject);
begin
  if MessageDlg(SrcList.Items[SrcList.ItemIndex]+' silinecektir!!! Ýþleme devam edilsin mi?',
                      mtConfirmation, [mbYes,mbNo], 0) = mrYES then begin
     SrcList.Items.Delete(SrcList.ItemIndex) ;
     Ini.DeleteKey(Baslik, SrcList.Items[SrcList.ItemIndex]);
     SetButtons;
  end;
end;

procedure TDualListDlg.UstTusClick(Sender: TObject);
begin
   if (SrcList.Items.Count < 2)or(SrcList.ItemIndex = 0) then exit;
   SrcList.Items.Exchange(SrcList.ItemIndex, SrcList.ItemIndex-1) ;
end;

procedure TDualListDlg.AltTusClick(Sender: TObject);
begin
   if (SrcList.Items.Count < 2)or(SrcList.ItemIndex = SrcList.Items.Count-1) then exit;
   SrcList.Items.Exchange(SrcList.ItemIndex, SrcList.ItemIndex+1) ;
end;

end.


