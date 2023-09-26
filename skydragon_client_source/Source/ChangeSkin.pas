unit ChangeSkin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,jpeg;

type
  TChangeSkinForm = class(TForm)
    SkinList: TListBox;
    Image1: TImage;
    OkBtn: TButton;
    CancelBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SkinListClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    mPicList:TstringList;       //預覽圖清單
  public
    { Public declarations }
  end;

var
  ChangeSkinForm: TChangeSkinForm;

implementation

uses
  Main;

{$R *.dfm}

procedure TChangeSkinForm.FormCreate(Sender: TObject);
var
  S: string;
  F: TSearchRec;
begin
  mPicList := TStringList.Create;
  if (FindFirst(Main.SkinPath+'*.skn',faAnyFile,F) = 0) then
  begin
    repeat
      if (F.Name <> '.') and (F.Name <> '..') then
        SkinList.Items.Add(ChangeFileExt(F.Name,''));
    until FindNext(F) <> 0;
    FindClose(F);
  end;
  if (FindFirst(Main.SkinPath+'*.jpg',faAnyFile,F) = 0) then
  begin
    repeat
      if (F.Name <> '.') and (F.Name <> '..') then
      begin
        S := Main.SkinPath  + F.Name;
        mPicList.Add(S);
      end;
    until FindNext(F) <> 0;
    FindClose(F);
  end;
end;

procedure TChangeSkinForm.SkinListClick(Sender: TObject);
var
  i: integer;
  vFileName:string;
begin
  for i:=0 to mPicList.Count-1 do
  begin
    vFileName:=ChangeFileExt(ExtractFileName(mPicList[i]),'');
    if CompareText(SkinList.items[SkinList.itemindex],vFileName)=0 then
    begin
      Image1.Picture.LoadFromFile(mPicList[i]);
      exit;
    end;
  end;
  Image1.Picture:=nil;
end;

procedure TChangeSkinForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TChangeSkinForm.OkBtnClick(Sender: TObject);
var
  vSkin:string;
begin
  vSkin:='..\skin\'+SkinList.items[SkinList.itemindex]+'.skn';
  MainForm.MyIniFile.DeleteKey('public','SkinData');
  MainForm.MyIniFile.WriteString('public','SkinData',vSkin);
  MainForm.MyIniFile.DeleteKey('public','SkinVersion');
  MainForm.MyIniFile.WriteString('public','SkinVersion','2.60');
  vSkin:=StringReplace(vSkin,'..',ExcludeTrailingPathDelimiter(AppPath),[rfIgnoreCase]);
  MainForm.SkinData.LoadFromFile(vSkin);
  if MainForm.SkinData.Active then
    MainForm.SkinData.DoSkinChanged
  else
  begin
    MainForm.SkinData.Active := True;
    MainForm.SkinData.DoSkinChanged
  end;
  Close;
end;

end.
