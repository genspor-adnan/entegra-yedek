unit UBaglanti;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus;

type
  TBaglantiDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edIp: TEdit;
    Label2: TLabel;
    edPort: TEdit;
    btnDinle: TButton;
    listValue: TListBox;
    tcpServer: TIdTCPServer;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Open: TMenuItem;
    Exit: TMenuItem;
    Button1: TButton;
    procedure tcpServerExecute(AContext: TIdContext);
    procedure btnDinleClick(Sender: TObject);
    procedure tcpServerStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure ExitClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BaglantiDlg: TBaglantiDlg;

implementation

uses UTablo;

{$R *.dfm}

var   St:String;
procedure TBaglantiDlg.btnDinleClick(Sender: TObject);
begin
  if btnDinle.Caption='Dinle' then begin
      tcpServer.Active := False;
      with tcpServer.Bindings.Add do begin
        Ip := '127.0.0.1';
        Port := StrToInt( edPort.Text );
      end;
      tcpServer.Active := True;
      listValue.Items.Add('Dinleme başlatıldı..');
      btnDinle.Caption:='Durdur';
  end
  else begin
      tcpServer.Active := False;
      tcpServer.Bindings.Clear;
      listValue.Items.Add('Dinleme durduruldu..');
      btnDinle.Caption:='Dinle';
  end;
end;

procedure TBaglantiDlg.Button1Click(Sender: TObject);
begin
       //showmessage('aa');
//    Action := caHide;
   Hide();

end;

procedure TBaglantiDlg.ExitClick(Sender: TObject);
begin
  Close();
end;

procedure TBaglantiDlg.FormCreate(Sender: TObject);
begin
  Hide();
  WindowState := wsMinimized;
  TrayIcon1.Visible := True;
  TrayIcon1.Animate := True;
  TrayIcon1.ShowBalloonHint;
  btnDinle.Click;
end;

procedure TBaglantiDlg.OpenClick(Sender: TObject);
begin
  //TrayIcon1.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

procedure TBaglantiDlg.Panel1Click(Sender: TObject);
var
  value : string;
  i,j,RehberId,FatbasId,Tur: Integer;
begin
//Tür:1 sipariş yaz; 2:hesap yaz

//[RehberId<FatbasId>Tur]
      value := InputBox('Yazılacak Adisyon','FATBASLIK Adisyon ID:','');
     St:=  '[1<'+value+'>1,-1]';
     listValue.Items.Add(St);
     i:= pos('<',st);
//     showmessage( intTostr( i ));
     RehberId := StrToIntDef(copy(st, 2, i-2),0);
     listValue.Items.Add(copy(st, 2, i-2));

//     showmessage(intTostr(RehberId));
     j:= pos('>',st);
     FatbasId := StrToIntDef(copy(st, i+1, j-i-1),0);
     listValue.Items.Add(copy(st, i+1, j-i-1));



     Tur := StrToIntDef(copy(st, j+1, pos(',',st)-j-1),0);
     listValue.Items.Add(copy(st, j+1, pos(',',st)-j-1));
//     showmessage(intTostr(Tur));

     j:= pos(',',st);
     SubeId := StrToIntDef(copy(st, j+1, pos(']',st)-j-1),-1);

     SubeIDYazi := IntToStr(abs(SubeId));
     if length(SubeIDYazi)<2 then
        SubeIDYazi:='0'+SubeIDYazi;

     SiparisYazdirList.Items.clear;
     Tablo.GENINI.ReadSection(StrToInt('-2387'+SubeIDYazi), SiparisYazdirList);
     HesapYazdirList.Items.clear;
     Tablo.GENINI.ReadSection(StrToInt('-2388'+SubeIDYazi), HesapYazdirList);


     if Tur=1 then
        Tablo.AdisyonYaz(FatbasId, RehberId)
     else
        Tablo.HesapYaz(FatbasId, RehberId);
end;

procedure TBaglantiDlg.tcpServerExecute(AContext: TIdContext);

  function FaturaNoGetir(AStr: string): string;
  var
    idx : Integer;
    idx2 : Integer;
  begin
    Result := '';
    idx := AStr.IndexOf('[');
    if idx > -1 then begin
      idx2 := AStr.IndexOf(']',idx);
      if idx2 > -1 then begin
        Result := AStr.Substring(idx + 1, (idx2 - idx) - 1);
      end;
    end;
  end;

var
  rcvdMsg: string;
  ms:TMemoryStream;
  St:String;
  i,j,RehberId,FatbasId,Tur: Integer;
begin
     St := FaturaNoGetir(AContext.Connection.Socket.ReadLn()); //Okunan : [RehberId<FatbasId>Tur] Tür:1 sipariş yaz; 2:hesap yaz
//     St:=  '[1<38487>2,-1]';
     if Trim(St)='' then
        listValue.Items.Add('Parametre Yok')
     else begin
       try
         listValue.Items.Add('Data:' + St);
         i:= pos('<',st);
         RehberId := StrToIntDef(copy(st, 2, i-2),0);
         j:= pos('>',st);
         FatbasId := StrToIntDef(copy(st, i+1, j-i-1),0);
         Tur := StrToIntDef(copy(st, j+1, pos(',',st)-j-1),0);
         j:= pos(',',st);
         SubeId := StrToIntDef(copy(st, j+1, pos(']',st)-j-1),-1);


         SubeIDYazi := IntToStr(abs(SubeId));
         if length(SubeIDYazi)<2 then
            SubeIDYazi:='0'+SubeIDYazi;

         SiparisYazdirList.Items.clear;
         Tablo.GENINI.ReadSection(StrToInt('-2387'+SubeIDYazi), SiparisYazdirList);
         HesapYazdirList.Items.clear;
         Tablo.GENINI.ReadSection(StrToInt('-2388'+SubeIDYazi), HesapYazdirList);

         if Tur=1 then
            Tablo.AdisyonYaz(FatbasId, RehberId)
         else
            Tablo.HesapYaz(FatbasId, RehberId);
       finally
          Application.MessageBox('Tamamdır.',0, 0);
       end;
    end;
end;

procedure TBaglantiDlg.tcpServerStatus(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  listValue.Items.Add(AStatusText);
end;

end.
