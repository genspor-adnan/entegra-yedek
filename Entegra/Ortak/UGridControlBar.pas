unit UGridControlBar;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   StdCtrls, Buttons;

type
   TGridControlBar = class(TFrame)
      EkleBtn: TSpeedButton;
      KaydetBtn: TSpeedButton;
      VazgecBtn: TSpeedButton;
      SilBtn: TSpeedButton;
      CikisBtn: TSpeedButton;
   private
    { Private declarations }
   public
    { Public declarations }
   end;

implementation

{$R *.DFM}

end.
