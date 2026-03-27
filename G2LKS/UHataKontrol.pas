unit UHataKontrol;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, DB, MPCommonObjects,
  EasyListview;

{$I options.inc}

type
  THataKontrolForm = class(TForm)
    Label1: TLabel;
    closeButton: TButton;
    Label2: TLabel;
    Image1: TImage;
    Panel1: TPanel;
    Splitter1: TSplitter;
    altPanel: TPanel;
    errorsListView: TEasyListview;
    procedure closeButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure errorsListView1Click(Sender: TObject);
    procedure errorsListViewItemSelectionChanged(
      Sender: TCustomEasyListview; Item: TEasyItem);
    procedure FormCreate(Sender: TObject);
  private
    function GetDosyaNo: string;
    function GetGelisNo: Integer;
    function GetHastaAdi: string;
    function GetHata: string;
    function GetHataID: Integer;
    function GetHataParams: string;
    function GetFaturaNo: string;
    function GetKartNo: Integer;
    { Private declarations }
  public
    { Public declarations }
    property HastaAdi : string read GetHastaAdi;
    property DosyaNo  : string read GetDosyaNo;
    property GelisNo  : Integer read GetGelisNo;
    property KartNo   : Integer read GetKartNo;
    property FaturaNo : string read GetFaturaNo;
    property Hata     : string read GetHata;
    property HataID   : Integer read GetHataID;
    property Params   : string read GetHataParams;
  end;

  TFrameClass = class of TFrame;

  TSolutionFrameRegistration = class(TObject)
  private
    FFrameClass : TFrameClass;
    FHataId: Integer;
    FInstance : TFrame;
  public
    constructor Create(AFrameClass: TFrameClass;AHataId: Integer);
    class procedure RegisterSolutionFrame(AFrameClass: TFrameClass;AHataId: Integer);
    class function FindSolutionFrame(AHataId: Integer): TSolutionFrameRegistration;
    class procedure LoadSolutionFrames;
    class procedure UnloadSolutionFrames;
    class procedure ShowSolutionFrame(AHataId: Integer);
    property HataId : Integer read FHataId;
    property Instance: TFrame read FInstance write FInstance;
    property FrameClass : TFrameClass read FFrameClass;
  end;

var
  HataKontrolForm: THataKontrolForm;

  procedure AddError(AFatbasID:Integer;AFIRMA,AFaturaNo: string;  AHataId: Integer;AHata: string;AParams: string);


implementation
uses
  UTablo;
{$R *.dfm}

var
  SolutionFrameList: TList;

procedure AddError(AFatbasID:Integer;AFIRMA,AFaturaNo: string; AHataId: Integer;AHata: string;AParams: string);
var
  item : TEasyItem;
begin
  if (not Assigned(HataKontrolForm)) then
    begin
      Application.CreateForm(THataKontrolForm, HataKontrolForm);
      HataKontrolForm.Show;
    end;
  with HataKontrolForm do
    begin
      item := errorsListView.Items.Add;
      item.Caption := AFIRMA;
      item.Captions[1] := AFIRMA;
      item.Captions[2] := IntToStr(AFatbasID);
      item.Captions[3] := AFaturaNo;
      item.Captions[4] := AHata;
      item.Captions[5] := IntToStr(AHataId);
      item.Captions[6] := AParams;
    end;    
end;

procedure THataKontrolForm.closeButtonClick(Sender: TObject);
begin   
  Close;
end;

procedure THataKontrolForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  TSolutionFrameRegistration.UnloadSolutionFrames;
  Action := caFree;
  HataKontrolForm := nil;
end;

procedure THataKontrolForm.errorsListView1Click(Sender: TObject);
var
  item : TEasyItem;
begin
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Tablo.TabFaturaListesi.Locate('DOSYANO;GELISNO;KARTNO',
      VarArrayOf([
        item.Caption,
        StrToInt(item.Captions[2]),
        StrToInt(item.Captions[3])]),[]);
  end;
end;

procedure THataKontrolForm.errorsListViewItemSelectionChanged(
  Sender: TCustomEasyListview; Item: TEasyItem);
begin
  if (item.Selected) then begin
    TSolutionFrameRegistration.ShowSolutionFrame(HataID);
  end else TSolutionFrameRegistration.ShowSolutionFrame(-1);
end;

function THataKontrolForm.GetDosyaNo: string;
var
  item : TEasyItem;
begin
  Result := '';
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := item.Caption;
  end;
end;

function THataKontrolForm.GetGelisNo: Integer;
var
  item : TEasyItem;
begin
  Result := 0;
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := StrToIntDef(item.Captions[2],0);
  end;
end;

function THataKontrolForm.GetHastaAdi: string;
var
  item : TEasyItem;
begin
  Result := '';
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := item.Captions[1];
  end;

end;

function THataKontrolForm.GetHata: string;
var
  item : TEasyItem;
begin
  Result := '';
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := item.Captions[5];
  end;
end;

function THataKontrolForm.GetHataID: Integer;
var
  item : TEasyItem;
begin
  Result := 0;
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := StrToIntDef(item.Captions[6],0);
  end;
end;

function THataKontrolForm.GetHataParams: string;
var
  item : TEasyItem;
begin
  Result := '';
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := item.Captions[7];
  end;
end;

function THataKontrolForm.GetFaturaNo: string;
var
  item : TEasyItem;
begin
  Result := '';
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := item.Captions[4];
  end;
end;

function THataKontrolForm.GetKartNo: Integer;
var
  item : TEasyItem;
begin
  Result := 0;
  if errorsListView.Selection.Count > 0 then begin
    item := errorsListView.Selection.First;
    Result := StrToIntDef(item.Captions[3],0);
  end;
end;

procedure UnregisterSolutionFrames;
var
  p : TSolutionFrameRegistration;
begin
  while SolutionFrameList.Count > 0 do begin
    p := SolutionFrameList.Extract(SolutionFrameList[0]);
    p.Free;
  end;
end;

{ TSolutionFrameRegistration }

constructor TSolutionFrameRegistration.Create(AFrameClass: TFrameClass;
  AHataId: Integer);
begin
  FFrameClass := AFrameClass;
  FHataId := AHataId;
end;

class function TSolutionFrameRegistration.FindSolutionFrame(
  AHataId: Integer): TSolutionFrameRegistration;
var
  i : Integer;
begin
  Result := nil;
  for i := 0 to SolutionFrameList.Count - 1 do begin
    if TSolutionFrameRegistration(SolutionFrameList[i]).HataId = AHataId then begin
      Result := TSolutionFrameRegistration(SolutionFrameList[i]);
      Exit;
    end;
  end;
end;

class procedure TSolutionFrameRegistration.LoadSolutionFrames;
var
  i : Integer;
  solution: TSolutionFrameRegistration;
begin
  for i := 0 to SolutionFrameList.Count - 1 do begin
    solution := TSolutionFrameRegistration(SolutionFrameList[i]);
    solution.Instance := TFrame(solution.FrameClass.NewInstance);
    solution.Instance.Create(HataKontrolForm);
    solution.Instance.Parent := HataKontrolForm.altPanel;
    solution.Instance.Visible := False;
  end;
end;

class procedure TSolutionFrameRegistration.RegisterSolutionFrame(
  AFrameClass: TFrameClass; AHataId: Integer);
var
  p : TSolutionFrameRegistration;
begin
  p := TSolutionFrameRegistration.Create(AFrameClass,AHataId);
  SolutionFrameList.Add(p);
end;

class procedure TSolutionFrameRegistration.ShowSolutionFrame(
  AHataId: Integer);
var
  sol : TSolutionFrameRegistration;
  i   : Integer;
begin
  for i := 0 to SolutionFrameList.Count - 1 do begin
    sol := TSolutionFrameRegistration(SolutionFrameList[i]);
    if Assigned(sol.Instance) then begin
      if (sol.HataId = AHataId) then begin
        SendMessage(sol.Instance.Handle,WM_SHOWSOLUTION,0,0);
        sol.Instance.Visible := True;
      end else sol.Instance.Visible := False;
    end;
  end;
end;

class procedure TSolutionFrameRegistration.UnloadSolutionFrames;
var
  i : Integer;
  solution: TSolutionFrameRegistration;
begin
  for i := 0 to SolutionFrameList.Count - 1 do begin
    solution := TSolutionFrameRegistration(SolutionFrameList[i]);
    if Assigned(solution.Instance) then begin
      solution.Instance.Free;
      solution.Instance := nil;
    end;
  end;

end;

procedure THataKontrolForm.FormCreate(Sender: TObject);
begin
  TSolutionFrameRegistration.LoadSolutionFrames;
end;


initialization
  SolutionFrameList := TList.Create;
finalization
  UnregisterSolutionFrames;
  SolutionFrameList.Free;
end.
