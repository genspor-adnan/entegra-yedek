unit UMesaj;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, comctrls, Sysutils, cxImageComboBox, Variants, dxSkinsCore,
  dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxLabel, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinLiquidSky, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TMesajForm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    MesajLabel1: TcxLabel;
    MesajLabel2: TcxLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MesajForm: TMesajForm;
function MesajStrAl(Baslik, Etiket1: string; Tur1: Char; stlist1: TStrings; var OkuStr1: string; Etiket2: string; Tur2: Char; stlist2: TStrings; var OkuStr2: string): Boolean;

implementation
uses
utablo,PrjConst,LocOnFly;

{$R *.DFM}
var Edit1, Edit2: TEdit;
  Combobox1, Combobox2: TCombobox;
  DateTimePicker1, DateTimePicker2: TDateTimePicker;
  IComboBox1, ICombobox2: TcxImageComboBox;
  RadioGroup1, RadioGroup2: TRadioGroup;
  Tur11: Char;


function MesajStrAl(Baslik, Etiket1: string; Tur1: Char; stlist1: TStrings; var OkuStr1: string; Etiket2: string; Tur2: Char; stlist2: TStrings; var OkuStr2: string): Boolean;
  procedure olustur(var Editx: TEdit; var Comboboxx: TCombobox;var ImageComboboxx : TcxImageComboBox; var stlist: TStrings; var DateTimePickerx: TDateTimePicker;var RadioGroupx:TRadioGroup; Turu: char; OkuStr, Ad: string; Yuk: integer);
  begin
    case Turu of
      'E','P': begin Editx := TEdit.Create(Editx);
            with Editx do begin
              Name := Ad;
              Parent := MesajForm;
              Autoselect := False;
              Text := OkuStr;
              Left := 40;
              Top := Yuk;
              Width := 265;
              Height := 21;
              if Turu ='P' then Editx.PasswordChar := '*';
            end;
          end;
      'C':begin Comboboxx := TCombobox.Create(Comboboxx);
            with Comboboxx do begin
              Name := Ad;
              Parent := MesajForm;
              Text := OkuStr;
              Left := 40;
              Top := Yuk;
              Width := 265;
              Height := 21;
              Style := csOwnerDrawFixed;
              Comboboxx.Items.AddStrings(stList);
              Comboboxx.ItemIndex := 0;
            end;
          end;
      'D':begin DateTimePickerx := TDateTimePicker.Create(DateTimePickerx);
            with DateTimePickerx do begin
              Name := Ad;
              Parent := MesajForm;
              Date := StrToDateTime(OkuStr);
              Left := 40;
              Top := Yuk;
              Width := 265;
              Height := 21;
            end;
          end;
          'R': begin RadioGroupx := TRadioGroup.Create(RadioGroupx);
            with RadioGroupx do begin
              Name := Ad;
              Parent := MesajForm;
              Items.AddStrings(stList);
              ItemIndex := 0;
              Caption :=OkuStr;
              Left := 8;
              Top := 8;
              Width := 305;
              Height := 121;
            end;
          end;
      'I': begin ImageComboboxx := TcxImageComboBox.Create(ImageComboboxx);
            with ImageComboboxx do Begin
              Name := Ad;
              Parent := MesajForm;
              Left := 40;
              Top := Yuk;
              Width := 265;
              Height := 21;
              Properties := Tablo.imgComboboxInit(stlist[0]);
              EditValue := StrToIntDef(OkuStr, -1);
            End;
          end;
    end;
  end;
begin
  MesajStrAl := False;
  Application.CreateForm(TMesajForm, MesajForm);
  MesajForm.Caption := Baslik;
  MesajForm.MesajLabel1.Caption := Etiket1;
  Tur11 := Tur1;
  olustur(Edit1, Combobox1,IComboBox1, StList1, DateTimePicker1,RadioGroup1, Tur1, OkuStr1, 'Ad1', 41);

  if Etiket2 <> '' then begin
    MesajForm.MesajLabel2.Visible := True;
    MesajForm.MesajLabel2.Caption := Etiket2;
    olustur(Edit2, Combobox2,IComboBox2, StList2, DateTimePicker2,RadioGroup2, Tur2, OkuStr2, 'Ad2', 91);
  end;

  if MesajForm.ShowModal = mrOk then
    MesajStrAl := True
  else
    MesajStrAl := False;

  case Tur1 of
    'E','P': begin OkuStr1 := Edit1.Text; Edit1.Free; Edit1 := nil end;
    'C': begin OkuStr1 := ComboBox1.Text; ComboBox1.Free; ComboBox1 := nil end;
    'D': begin OkuStr1 := DateTimeToStr(DateTimePicker1.Date); DateTimePicker1.Free; DateTimePicker1 := nil end;
    'R': begin OkuStr1 := IntToStr(RadioGroup1.ItemIndex); RadioGroup1.Free; RadioGroup1 := nil end;
    'I': begin OkuStr1 := VarToStr(IComboBox1.EditValue); IComboBox1.Free; IComboBox1 := nil end;
  end;
  if Etiket2 <> '' then
    case Tur2 of
      'E','P': begin OkuStr2 := Edit2.Text; Edit2.Free; Edit2 := nil end;
      'C': begin OkuStr2 := ComboBox2.Text; ComboBox2.Free; ComboBox2 := nil end;
      'D': begin OkuStr2 := DateTimeToStr(DateTimePicker2.Date); DateTimePicker2.Free; DateTimePicker2 := nil end;
      'R': begin OkuStr2 := IntToStr(RadioGroup2.ItemIndex); RadioGroup2.Free; RadioGroup2 := nil end;
      'I': begin OkuStr2 := VarToStr(IComboBox2.EditValue); IComboBox2.Free; IComboBox2 := nil end;
    end;
  OkuStr1 := Trim(OkuStr1); OkuStr2 := Trim(OkuStr2);
  MesajForm.Free;
end;

procedure TMesajForm.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TMesajForm.FormShow(Sender: TObject);
begin
  case Tur11 of
    'E': begin Edit1.SetFocus; Edit1.SelStart := 100; end;
    'C': ComboBox1.SetFocus;
    'D': DateTimePicker1.SetFocus;
  end;
end;

end.
