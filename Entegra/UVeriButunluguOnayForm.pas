unit UVeriButunluguOnayForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, JvExControls, JvInstallLabel, ImgList;

type
  TVeriButunluguOnayForm = class(TForm)
    Panel1: TPanel;
    Label2: TLabel;
    Label1: TLabel;
    Panel2: TPanel;
    durumLabel: TJvInstallLabel;
    ImgList: TImageList;
    Panel3: TPanel;
    Label3: TLabel;
    evetButton: TButton;
    hayirButton: TButton;
    Bevel2: TBevel;
  private
    FSonucGirildi: Boolean;
    FProtokolNoGirildi: Boolean;
    FIstisnaiDurumGirildi: Boolean;
    FTaniGirildi: Boolean;
    FHastaCikisOzetiGirildi: Boolean;
    FTaburcuKoduGirildi: Boolean;
    procedure SetHastaCikisOzetiGirildi(const Value: Boolean);
    procedure SetIstisnaiDurumGirildi(const Value: Boolean);
    procedure SetProtokolNoGirildi(const Value: Boolean);
    procedure SetSonucGirildi(const Value: Boolean);
    procedure SetTaburcuKoduGirildi(const Value: Boolean);
    procedure SetTaniGirildi(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    property ProtokolNoGirildi : Boolean read FProtokolNoGirildi write SetProtokolNoGirildi;
    property TaniGirildi : Boolean read FTaniGirildi write SetTaniGirildi;
    property IstisnaiDurumGirildi : Boolean read FIstisnaiDurumGirildi write SetIstisnaiDurumGirildi;
    property TaburcuKoduGirildi   : Boolean read FTaburcuKoduGirildi write SetTaburcuKoduGirildi;
    property SonucGirildi : Boolean read FSonucGirildi write SetSonucGirildi;
    property HastaCikisOzetiGirildi : Boolean read FHastaCikisOzetiGirildi write SetHastaCikisOzetiGirildi;
  end;

var
  VeriButunluguOnayForm: TVeriButunluguOnayForm;

implementation
uses
  FetaUtil,FetaKurulusSiniflari,FetaClassExtensions;

{$R *.dfm}

{ TVeriButunluguOnayForm }

procedure TVeriButunluguOnayForm.SetHastaCikisOzetiGirildi(
  const Value: Boolean);
begin
  FHastaCikisOzetiGirildi := Value;
  durumLabel.SetImage(5,IIf(Value,1,0));
end;

procedure TVeriButunluguOnayForm.SetIstisnaiDurumGirildi(const Value: Boolean);
begin
  FIstisnaiDurumGirildi := Value;
  durumLabel.SetImage(2,IIf(Value,1,0));
end;

procedure TVeriButunluguOnayForm.SetProtokolNoGirildi(const Value: Boolean);
begin
  FProtokolNoGirildi := Value;
  durumLabel.SetImage(0,IIf(Value,1,0));
end;

procedure TVeriButunluguOnayForm.SetSonucGirildi(const Value: Boolean);
begin
  FSonucGirildi := Value;
  durumLabel.SetImage(4,IIf(Value,1,0));

end;

procedure TVeriButunluguOnayForm.SetTaburcuKoduGirildi(const Value: Boolean);
begin
  FTaburcuKoduGirildi := Value;
  durumLabel.SetImage(3,IIf(Value,1,0));
end;

procedure TVeriButunluguOnayForm.SetTaniGirildi(const Value: Boolean);
begin
  FTaniGirildi := Value;
  durumLabel.SetImage(1,IIf(Value,1,0));
end;

end.
