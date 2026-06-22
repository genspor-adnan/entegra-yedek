unit UArsivdenAl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, cxControls, cxContainer, cxEdit, cxImage,
  cxLookAndFeelPainters, cxLabel, cxCheckListBox, StdCtrls, cxButtons, Menus;

type
  TArsivdenAlDlg = class(TForm)
    SadeceBuGelis: TcxButton;
    cxCheckListBox1: TcxCheckListBox;
    cxButton1: TcxButton;
    LabelEVILCE: TcxLabel;
    procedure SadeceBuGelisClick(Sender: TObject);
  private
    { Private declarations }
    Basliklar, Tablolar : TStringList;
    GId : Integer;
    procedure SadeceBuGelisGetir;
  public
    { Public declarations }
  end;

var
  ArsivdenAlDlg: TArsivdenAlDlg;

procedure ArsivdenAl(Basliklar1, Tablolar1 : TStringList);

implementation

{$R *.dfm}
Uses UTablo, FetaUtil;

(*
   ArsivBaslikList.Clear;
   ArsivBaslikList.Add('Ücret,0');
   ArsivBaslikList.Add('Tahsilat,1');
   ArsivBaslikList.Add('Fatura,2,3');
   ArsivTabloList.Add('PARA/'+ParaAlanlar);
   ArsivTabloList.Add('TAHSILAT/'+TahsilAlanlar);
   ArsivTabloList.Add('FATBASLIK/'+FatBAlanlar);
   ArsivTabloList.Add('FATURA/'+FaturaAlanlar);
   ArsivdenAl(Tablo.TabGelisler.Fields[0].AsInteger{Hasta ID'si}, ArsivBaslikList, ArsivTabloList);
*)

procedure ArsivdenAl(Basliklar1, Tablolar1 : TStringList);
var i : smallint;
begin
   Application.CreateForm(TArsivdenAlDlg, ArsivdenAlDlg);
   if ArsivdenAlDlg.Basliklar = nil then
      ArsivdenAlDlg.Basliklar := TStringList.Create;
   ArsivdenAlDlg.Basliklar.Assign(Basliklar1);
   if ArsivdenAlDlg.Tablolar = nil then
      ArsivdenAlDlg.Tablolar := TStringList.Create;
   ArsivdenAlDlg.Tablolar.Assign(Tablolar1);
   for i := 0 to ArsivdenAlDlg.Basliklar.Count-1 do begin          //  Ücret,0  Basliklardaki sağdaki rakamlar aktarımda kaç tablo ve hangilerinin kullanılacağını gösteriyor 0 tablolardaki 0 ncı tablodan alınacağını gösteriyor
       ArsivdenAlDlg.cxCheckListBox1.Items.Add;      //  Ücret,0   Aşağıda Text kısmına Ücreti DisplayName kısmına da 0 atıyoruz
       ArsivdenAlDlg.cxCheckListBox1.Items[i].Text := copy(ArsivdenAlDlg.Basliklar.Strings[i],1,pos(',', ArsivdenAlDlg.Basliklar.Strings[i])-1);
       ArsivdenAlDlg.cxCheckListBox1.Items[i].Checked := True;
//       ArsivdenAlDlg.cxCheckListBox1.Items[i].DisplayName := copy(Basliklar.Strings[i],pos(',', Basliklar.Strings[i])+1, 20);
   end;


   if ArsivdenAlDlg.Basliklar.Count = 1 then //Tek bilgi var. Sorulmadan direk arşivden getir
      ArsivdenAlDlg.SadeceBuGelisGetir
   else
      ArsivdenAlDlg.ShowModal;
   ArsivdenAlDlg.Destroy;
end;

procedure TArsivdenAlDlg.SadeceBuGelisGetir;
var i, j, yer, BasInd, BitInd : smallint;
    Tabloadi, s : String[30];
    StList : TStringList;
begin
   StList := TStringList.Create;
   for i := 0 to cxCheckListBox1.Items.Count-1 do
     if cxCheckListBox1.Items[i].Checked then begin
        //s := copy(Basliklar.Strings[i],pos(',', Basliklar.Strings[i])+1, 20);
        //Parcala(s, StList);
        Parcala(Basliklar.Strings[i], StList);
        BasInd := StrToInt(StList[1]);
        BitInd := StrToInt(StList[2]);

        for j := BasInd to BitInd do begin
//        for j := 0 to StList.Count - 1 do begin
//           k := StrToInt(Trim(StList.Strings[j]));
           yer := pos('/', Tablolar[j]);
           Tabloadi := copy(Tablolar[j], 1, yer-1);
           Tablo.SQLKomut1.CommandText := ' INSERT INTO '+Tabloadi+' ('+copy(Tablolar[j],yer+1, 500)+')'+
              ' SELECT '+copy(Tablolar[j],yer+1, 500)+' FROM [GENOTIPARSIV].[dbo].['+Tabloadi+'] WHERE DOSYANO='''+Tablo.TabGelisler.Fields[0].AsString+''' and GELISNO='+Tablo.TabGelisler.Fields[1].AsString;
           try
             Tablo.SQLKomut1.Execute;
           except
           end;
        end;
     end;

   StList.Free;
end;

procedure TArsivdenAlDlg.SadeceBuGelisClick(Sender: TObject);
begin
   SadeceBuGelisGetir;
end;
end.
