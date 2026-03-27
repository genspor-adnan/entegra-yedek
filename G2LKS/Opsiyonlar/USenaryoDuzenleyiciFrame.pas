unit USenaryoDuzenleyiciFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, ExtCtrls, SynEditHighlighter,
  SynHighlighterPas, SynEdit, ActnList, ADODB, DB, SynHighlighterXML, System.Actions;

{$I options.inc}

type
  TSenaryoDuzenleyiciFrame = class(TFrame)
    kodListesiComboBox: TComboBox;
    Panel1: TPanel;
    Label1: TLabel;
    yukleButton: TButton;
    kaydetButton: TButton;
    SenaryoDuzenleyiciSynEdit: TSynEdit;
    SynPasSyn2: TSynPasSyn;
    yeniButton: TButton;
    Label2: TLabel;
    suAnkiSenaryoAdiLabel: TLabel;
    Bevel1: TBevel;
    KodDuzenActionList: TActionList;
    YukleAction: TAction;
    YeniAction: TAction;
    SaklaAction: TAction;
    Button1: TButton;
    SilAction: TAction;
    SynXMLSyn: TSynXMLSyn;
    procedure YukleActionUpdate(Sender: TObject);
    procedure YukleActionExecute(Sender: TObject);
    procedure SaklaActionExecute(Sender: TObject);
    procedure YeniActionExecute(Sender: TObject);
    procedure SenaryoDuzenleyiciSynEditChange(Sender: TObject);
    procedure SaklaActionUpdate(Sender: TObject);
    procedure SilActionUpdate(Sender: TObject);
    procedure SilActionExecute(Sender: TObject);
  private
    { Private declarations }
    FLoadedScript : string;
    FScriptLoaded : Boolean;
    FScriptModified : Boolean;
    procedure SaveContentMsg(var Msg: TMessage);message WM_SAVECONTENT;
    procedure LoadScriptList;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
  end;

implementation
uses
  UOpsiyon, UTablo, UOnayDialog, Fetautil;
  
{$R *.dfm}
procedure TSenaryoDuzenleyiciFrame.YukleActionUpdate(Sender: TObject);
begin
  YukleAction.Enabled := kodListesiComboBox.ItemIndex > -1;     
end;

procedure TSenaryoDuzenleyiciFrame.YukleActionExecute(Sender: TObject);
var
  r : integer;
begin               
  if (FScriptLoaded and FScriptModified) then begin
    r := (ShowConfirmDialog('Senaryo üzerinde deðiþiklik yaptýnýz. Kaydetmek ister misiniz ?', ['@Evet','Hayýr','Ýptal'],0));
    if (r = 0) then SaklaAction.Execute
    else if (r = 2) then begin
      kodListesiComboBox.ItemIndex := kodListesiComboBox.Items.IndexOf(FLoadedScript);
      Exit;
    end;
  end;
  SenaryoDuzenleyiciSynEdit.Lines.Text := Tablo.GetCode(kodListesiComboBox.Text,'begin ShowModal; end.');
  if ((ExtractFileExt(kodListesiComboBox.Text) = '.config') or
      (ExtractFileExt(kodListesiComboBox.Text) = '.xml')) then
    SenaryoDuzenleyiciSynEdit.Highlighter := SynXMLSyn
  else
    SenaryoDuzenleyiciSynEdit.Highlighter := SynPasSyn2;
  FScriptLoaded := True;
  FLoadedScript := kodListesiComboBox.Text;
  FScriptModified := False;
  SaklaAction.Enabled := True;
  suAnkiSenaryoAdiLabel.Caption := FLoadedScript;
  SenaryoDuzenleyiciSynEdit.Enabled := True;
end;

constructor TSenaryoDuzenleyiciFrame.Create(AOwner: TComponent);
begin
  inherited;
  FLoadedScript := '';
  FScriptLoaded := False;
  FScriptModified := False;
  SaklaAction.Enabled := False;
  SenaryoDuzenleyiciSynEdit.Enabled := False;
  LoadScriptList;
end;

procedure TSenaryoDuzenleyiciFrame.SaklaActionExecute(Sender: TObject);
begin
  Tablo.SetCode(FLoadedScript,SenaryoDuzenleyiciSynEdit.Lines.Text);
  FScriptModified := False;
end;

procedure TSenaryoDuzenleyiciFrame.SaveContentMsg(var Msg: TMessage);
var
  r: integer;
begin
  if (FScriptLoaded and FScriptModified) then begin
    r := (ShowConfirmDialog('Senaryo üzerinde deðiþiklik yaptýnýz. Kaydetmek ister misiniz ?',
      ['@Evet','Hayýr','Ýptal'],0));
    if (r = 0) then SaklaAction.Execute;
  end;
end;

procedure TSenaryoDuzenleyiciFrame.LoadScriptList;
var
  temp : TADOQuery;
begin
  temp := _query_exec(Tablo.cnn,'SELECT ADI FROM SENARYO WHERE MODUL=%MODULKODU%', ['%MODULKODU%'],[lisansModul]);
  kodListesiComboBox.Items.Clear;
  try
    temp.Open;
    while not temp.Eof do begin
      kodListesiComboBox.Items.Add(temp.FieldByName('ADI').AsString); 
      temp.Next;
    end;
  finally
    temp.Free;
  end;
end;

procedure TSenaryoDuzenleyiciFrame.YeniActionExecute(Sender: TObject);
var
  senaryoAdi : string;
begin
  senaryoAdi := InputBox('Yeni Senaryo','Senaryo adý :','');
  if (senaryoAdi <> '') then begin
    if (not Tablo.IsCodeExists(senaryoAdi)) then begin
      Tablo.SetCode(senaryoAdi,'begin'#13#10'  ShowModal;'#13#10'end.');
      LoadScriptList;
      kodListesiComboBox.ItemIndex :=
        kodListesiComboBox.Items.IndexOf(senaryoAdi);
      if (kodListesiComboBox.ItemIndex <> -1) then begin
        YukleAction.Execute;
      end else
        MessageDlg('Senaryo adýna konumlanma baþarýsýz! (' + senaryoAdi + ')',mtError,[mbOK],0);
    end else MessageDlg('Ayný senaryo adýndan mevcut! (' + senaryoAdi + ')' ,mtError,[mbOK],0);
  end;
end;

procedure TSenaryoDuzenleyiciFrame.SenaryoDuzenleyiciSynEditChange(
  Sender: TObject);
begin
  FScriptModified := True;
end;

procedure TSenaryoDuzenleyiciFrame.SaklaActionUpdate(Sender: TObject);
begin
  SaklaAction.Enabled := FScriptModified;
end;

procedure TSenaryoDuzenleyiciFrame.SilActionUpdate(Sender: TObject);
begin
  SilAction.Enabled := kodListesiComboBox.ItemIndex > -1;  
end;

procedure TSenaryoDuzenleyiciFrame.SilActionExecute(
  Sender: TObject);
var
  r : Integer;
begin
  r := (ShowConfirmDialog('Senaryo''yu gerçekten silmek istiyor musunuz ?',
    ['Evet','@Hayýr'],0));
  if (r = 1) then Exit;
  Tablo.RemoveCode(FLoadedScript);
  suAnkiSenaryoAdiLabel.Caption := '';
  SenaryoDuzenleyiciSynEdit.Lines.Clear;
  LoadScriptList;
end;

initialization
  RegisterOption(4,'Genel/Senaryolar',TSenaryoDuzenleyiciFrame);
end.                                                                                                                                                            
