unit UVadesiGelmisler;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Grids, DBGrids, StdCtrls, Buttons, ComCtrls, ToolWin;

type
  TVadesiGelmislerDlg = class(TForm)
    Panel1 :TPanel;
    Panel2 :TPanel;
    Panel3 :TPanel;
    DBGrid1 :TDBGrid;
    GrupIslemTuru :TRadioGroup;
    DateTimeBasla :TDateTimePicker;
    DateTimeBitis :TDateTimePicker;
    Label1 :TLabel;
    Label2 :TLabel;
    ToolBar1 :TToolBar;
    EkranYaz :TToolButton;
    YaziciYaz :TToolButton;
    DBGrid2 :TDBGrid;
    ToolButton1 :TToolButton;
    ToolButton2 :TToolButton;
    procedure BitBtn1Click(Sender :TObject);
    procedure FormCreate(Sender :TObject);
    procedure GrupIslemTuruClick(Sender :TObject);
    procedure ToolButton1Click(Sender :TObject);
    procedure YaziciYazClick(Sender :TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VadesiGelmislerDlg :TVadesiGelmislerDlg;
  Sorgu :string;

implementation
uses uTablo, UAnaform,PrjConst,LocOnFly;
{$R *.DFM}

procedure TVadesiGelmislerDlg.BitBtn1Click(Sender :TObject);
begin
  Self.Close;
end;

procedure TVadesiGelmislerDlg.FormCreate(Sender :TObject);
begin
// Added by Adnan Odabaþý 27/10/2009 16:39:55
{
  sorgu := 'SELECT ' +
    ' CARIKOD ,CARIAD,ACIKLAMA,GIREN,CIKAN,HESAPKODU,HESAPADI,VADE,KUR' +
    ' FROM ' +
    '	KASA ' +
    '  WHERE	VADE  BETWEEN :VADEBASLA AND :VADEBITIS ';           }

    if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TVadesiGelmislerDlg.GrupIslemTuruClick(Sender :TObject);
begin
  case GrupIslemTuru.ItemIndex of
    0 :
      begin
        Tablo.qryVadesiGelmisIslemler.Close;
        Tablo.qryVadesiGelmisIslemler.SQL.Text := sorgu;
        Tablo.qryVadesiGelmisIslemler.Params[0].Value := FormatDateTime('yyyy-mm-dd 00:00', DateTimeBasla.Date);
        Tablo.qryVadesiGelmisIslemler.Params[1].Value := FormatDateTime('yyyy-mm-dd 23:59', DateTimeBitis.Date);
        Tablo.qryVadesiGelmisIslemler.Open;
      end;
    1 :
      begin
        Tablo.qryVadesiGelmisIslemler.Close;
        Tablo.qryVadesiGelmisIslemler.SQL.Text := sorgu + ' AND BORC>0';
        Tablo.qryVadesiGelmisIslemler.Params[0].Value := FormatDateTime('yyyy-mm-dd 00:00', DateTimeBasla.Date);
        Tablo.qryVadesiGelmisIslemler.Params[1].Value := FormatDateTime('yyyy-mm-dd 23:59', DateTimeBitis.Date);
        Tablo.qryVadesiGelmisIslemler.Open;
      end;
    2 :
      begin
        Tablo.qryVadesiGelmisIslemler.Close;
        Tablo.qryVadesiGelmisIslemler.SQL.Text := sorgu + ' AND CIKAN>0';
        Tablo.qryVadesiGelmisIslemler.Params[0].Value := FormatDateTime('yyyy-mm-dd 00:00', DateTimeBasla.Date);
        Tablo.qryVadesiGelmisIslemler.Params[1].Value := FormatDateTime('yyyy-mm-dd 23:59', DateTimeBitis.Date);
        Tablo.qryVadesiGelmisIslemler.Open;
      end;
  end;
end;

procedure TVadesiGelmislerDlg.ToolButton1Click(Sender :TObject);
begin
  Self.Close;
end;

procedure TVadesiGelmislerDlg.YaziciYazClick(Sender :TObject);
begin  {
  RapTablo.VADEISLEM.Close;
  RapTablo.VADEISLEM.SQL.Text := Tablo.qryVadesiGelmisIslemler.SQL.Text;
  RapTablo.VADEISLEM.ParamCheck;
  RapTablo.VADEISLEM.Params[0].Value := FormatDateTime('yyyy-mm-dd 00:00', DateTimeBasla.Date);
  RapTablo.VADEISLEM.Params[1].Value := FormatDateTime('yyyy-mm-dd 23:59', DateTimeBitis.Date);
  RapTablo.VADEISLEM.Open;  }
  //TabloDokum.Ekran_Yazici_Islemi(Sender);
end;

end.


