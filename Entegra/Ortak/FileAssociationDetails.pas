unit FileAssociationDetails;


interface

uses Classes, Controls, Graphics, SysUtils, ShellAPI, Windows, Commctrl, ShlObj;

type
  TFileAssociationDetails = class(TObject)
  private
    FImages : TImageList;
    FExtensions : TStringList;
    FDescriptions : TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddFile(FileName : string);
    procedure AddExtension(Extension : string);
    procedure Clear;
    procedure GetFileIconsAndDescriptions;

    property Images : TImageList read FImages;
    property Extensions : TStringList read FExtensions;
    property Descriptions : TStringList read FDescriptions;

    function GetGenericFileIcon(AExtension: string): TIcon;
    function GetGenericFileType(AExtension: string): string;
    function GetGenericIconIndex(AExtension: string): integer;
    procedure GetIconFromFile(aFile: String; var aIcon: TIcon; SHIL_FLAG: Cardinal);
    function GetImageListSH(SHIL_FLAG: Cardinal): HIMAGELIST;
  end;

implementation

const
  SHIL_LARGE     = $00;  //The image size is normally 32x32 pixels. However, if the Use large icons option is selected from the Effects section of the Appearance tab in Display Properties, the image is 48x48 pixels.
  SHIL_SMALL     = $01;  //These images are the Shell standard small icon size of 16x16, but the size can be customized by the user.
  SHIL_EXTRALARGE= $02;  //These images are the Shell standard extra-large icon size. This is typically 48x48, but the size can be customized by the user.
  SHIL_SYSSMALL  = $03;  //These images are the size specified by GetSystemMetrics called with SM_CXSMICON and GetSystemMetrics called with SM_CYSMICON.
  SHIL_JUMBO     = $04;  //Windows Vista and later. The image is normally 256x256 pixels.
  IID_IImageList: TGUID= '{46EB5926-582E-4017-9FDF-E8998DAA0950}';


{ TFileAssociationDetails }

constructor TFileAssociationDetails.Create;
begin
  try
    inherited;

    FExtensions := TStringList.Create;
    FExtensions.Sorted := true;
    FDescriptions := TStringList.Create;
    FImages := TImageList.Create(nil);
  except
  end;
end;

destructor TFileAssociationDetails.Destroy;
begin
  try
    FExtensions.Free;
    FDescriptions.Free;
    FImages.Free;
  finally
    inherited;
  end;
end;

procedure TFileAssociationDetails.AddFile(FileName: string);
begin
  AddExtension(ExtractFileExt(FileName));
end;

procedure TFileAssociationDetails.AddExtension(Extension : string);
begin
  Extension := UpperCase(Extension);
  if (Trim(Extension) <> '') and
     (FExtensions.IndexOf(Extension) = -1) then
    FExtensions.Add(Extension);
end;

procedure TFileAssociationDetails.Clear;
begin
  FExtensions.Clear;
end;

procedure TFileAssociationDetails.GetFileIconsAndDescriptions;
var
  Icon: TIcon;
  iCount : integer;
  Extension : string;
  FileInfo : SHFILEINFO;
begin
  FImages.Clear;
  FDescriptions.Clear;

  Icon := TIcon.Create;
  try
    // Loop through all stored extensions and retrieve relevant info
    for iCount := 0 to FExtensions.Count - 1 do
    begin
      Extension := '*' + FExtensions.Strings[iCount];

      // Get description type
      SHGetFileInfo(PChar(Extension),
                    FILE_ATTRIBUTE_NORMAL,
                    FileInfo,
                    SizeOf(FileInfo),
                    SHGFI_TYPENAME or SHGFI_USEFILEATTRIBUTES
                    );
      FDescriptions.Add(FileInfo.szTypeName);

      // Get icon and copy into ImageList
      SHGetFileInfo(PChar(Extension),
                    FILE_ATTRIBUTE_NORMAL,
                    FileInfo,
                    SizeOf(FileInfo),
                    SHGFI_ICON or SHGFI_SMALLICON or
                    SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES
                    );
      Icon.Handle := FileInfo.hIcon;
      FImages.AddIcon(Icon);
    end;
  finally
    Icon.Free;
  end;
end;

function TFileAssociationDetails.GetGenericFileType( AExtension: string ): string;
{ Get file type for an extension }
var
  AInfo: TSHFileInfo;
begin
  SHGetFileInfo( PChar( AExtension ), FILE_ATTRIBUTE_NORMAL, AInfo, SizeOf( AInfo ),
    SHGFI_TYPENAME or SHGFI_USEFILEATTRIBUTES );
  Result := AInfo.szTypeName;
end;

function TFileAssociationDetails.GetGenericIconIndex( AExtension: string ): integer;
{ Get icon index for an extension type }
var
  AInfo: TSHFileInfo;
begin
  if SHGetFileInfo( PChar( AExtension ), FILE_ATTRIBUTE_NORMAL, AInfo, SizeOf( AInfo ),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_USEFILEATTRIBUTES ) <> 0 then
  Result := AInfo.iIcon
  else
    Result := -1;
end;

function TFileAssociationDetails.GetGenericFileIcon( AExtension: string ): TIcon;
{ Get icon for an extension }
var
  AInfo: TSHFileInfo;
  AIcon: TIcon;
begin
  if SHGetFileInfo( PChar( AExtension ), FILE_ATTRIBUTE_NORMAL, AInfo, SizeOf( AInfo ),
    SHGFI_SYSICONINDEX or SHGFI_LARGEICON or SHGFI_USEFILEATTRIBUTES ) <> 0 then
  begin
    AIcon := TIcon.Create;
    try
      AIcon.Handle := AInfo.hIcon;
      Result := AIcon;
    except
      AIcon.Free;
      raise;
    end;
  end
  else
    Result := nil;
end;


function TFileAssociationDetails.GetImageListSH(SHIL_FLAG:Cardinal): HIMAGELIST;
type
  _SHGetImageList = function (iImageList: integer; const riid: TGUID; var ppv: Pointer): hResult; stdcall;
var
  Handle        : THandle;
  SHGetImageList: _SHGetImageList;
begin
  Result:= 0;
  Handle:= LoadLibrary('Shell32.dll');
  if Handle<> S_OK then
  try
    SHGetImageList:= GetProcAddress(Handle, PChar(727));
    if Assigned(SHGetImageList) and (Win32Platform = VER_PLATFORM_WIN32_NT) then
      SHGetImageList(SHIL_FLAG, IID_IImageList, Pointer(Result));
  finally
    FreeLibrary(Handle);
  end;
end;


Procedure TFileAssociationDetails.GetIconFromFile(aFile:String; var aIcon : TIcon;SHIL_FLAG:Cardinal);
var
  aImgList    : HIMAGELIST;
  SFI         : TSHFileInfo;
Begin
    //Get the index of the imagelist
    SHGetFileInfo(PChar(aFile), FILE_ATTRIBUTE_NORMAL, SFI,
                 SizeOf( TSHFileInfo ), SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SHELLICONSIZE or
                 SHGFI_SYSICONINDEX or SHGFI_TYPENAME or SHGFI_DISPLAYNAME );

    if not Assigned(aIcon) then
    aIcon:= TIcon.Create;
    //get the imagelist
    aImgList:= GetImageListSH(SHIL_FLAG);
    //extract the icon handle
    aIcon.Handle:= ImageList_GetIcon(aImgList, Pred(ImageList_GetImageCount(aImgList)), ILD_NORMAL);
End;

end.
