unit Unit1;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWCompRadioButton, IWCompLabel, Controls, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompButton;

type
  TIWForm1 = class(TIWAppForm)
    IWBSelect: TIWButton;
    IWBClose: TIWButton;
    IWLGrup: TIWLabel;
    IWLKod: TIWLabel;
    IWLUnvan: TIWLabel;
    IWLIlgili: TIWLabel;
    IWRBaslayan: TIWRadioButton;
    IWRicindeGencer: TIWRadioButton;
  public
  private
        procedure RunSearchQuery;
  end;

implementation

{$R *.dfm}
procedure TIWForm1.RunSearchQuery;
    var
  s, Fir,Yet,Kod,TFirma,TYet,TKod, Grup :string;
begin
  s := '';
  Fir := ' R.FIRMA ';
  Yet := ' P.ADSOYAD ';
  Kod := ' R.KOD ';
  if rbBaslayan.Checked then
  begin
    TFirma := Trim(AraFirma.Text) + '%';
    TYet := Trim(AraYetkili.Text) + '%';
    TKod := Trim(AraKod.Text) + '%';
  end
  else if rbIcindeGecen.Checked then
  begin
    TFirma := '%' + Trim(AraFirma.Text) + '%';
    TYet := '%' + Trim(AraYetkili.Text) + '%';
    TKod := '%' + Trim(AraKod.Text) + '%';
  end;
  if ComboGrup.Text <> '' then
     Grup := ' and GRUP='+IntToStr(ComboGrup.Properties.Items[ComboGrup.ItemIndex].Value)
  else
     Grup := '';
  AraQuery1.Close;
  if AraFirma.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Fir + ' LIKE ''' + TFirma +''''+ Grup + ' ORDER BY FIRMA'  //   and ' + gorulmeyecekkod
  else if AraYetkili.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and ' + Yet + ' LIKE ''' + TYet +''''+ Grup +'  ORDER BY FIRMA'             // and gorulmeyecekkod
  else if AraKod.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Kod + ' LIKE ''' + TKod+'''' + Grup + '  ORDER BY ' + Kod     // and gorulmeyecekkod
  else if ComboGrup.Text <> '' then
    s := ' where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 '+Grup+ ' ORDER BY FIRMA'
  else
    Exit;
  AraQuery1.SQL.Text := ' select R.ID,KOD,FIRMA,GRUP,ADSOYAD '+
                        ' from REHBER R left outer join REHBERPERSONEL P on R.ID=P.REHBERID ';
  AraQuery1.SQL.Add(s);
  AraQuery1.open;
end;



end.
