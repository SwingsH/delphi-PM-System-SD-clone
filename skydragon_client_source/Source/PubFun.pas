unit PubFun;

interface

uses
  Classes, SysUtils;

function GetStringFromDat(const aItemIndex: integer; const aDatStr: string; aDelimiter: Char): string;
procedure WriteShareFile(aName: string; const Buf; BufSize: Integer);
procedure CheckFileExists(aName: string);
function CheckDir(aDir : string):boolean ;

implementation

function CheckDir(aDir : string):boolean ;
var
  i : integer;
  vStr : string;
  vOld : string;
begin
  vOld := aDir;
  aDir := ExtractFilePath(aDir);
  {$i-}
  MkDir(aDir);
  {$i+}
  if IOResult<>0 then
  begin
    for i := 1 to Length(aDir) do
    if aDir[i] = '\' then
    begin
      if i >= 4 then
      begin
        vStr := copy(aDir, 1, i);
        {$i-}
        MkDir(vStr);
        {$i+}
        if IOResult<>0 then
        begin
          //  MessageDlg('Can''t Create: '+s, mtError, [mbAbort], 0);
        end;
      end;
    end;
  end;
  result := true;
  exit;
end;

procedure CheckFileExists(aName: string);
var
  vf1: TFileStream;
begin
  if not FileExists(aName) then
  begin
    try
      vf1 := TFileStream.Create(aName, fmCreate);
      vf1.Free;
    except
    end;
  end;
end;

procedure WriteShareFile(aName: string; const Buf; BufSize: Integer);
var
  f1: TFileStream;
begin
  CheckFileExists(aName);
  try
    f1 := TFileStream.Create(aName, fmOpenReadWrite or fmShareDenyNone);
    f1.Write(Buf, BufSize);
    f1.Size := BufSize;
    f1.Free;
  except
  end;
end;

function GetStringFromDat(const aItemIndex: integer; const aDatStr: string; aDelimiter: Char): string;
var
  vTmpStrList: TStringList;
begin
  result := '';

  try
    if (aItemIndex < 0) then  //���X�z����m
      exit;

    vTmpStrList := TStringList.Create;

    vTmpStrList.Delimiter := aDelimiter;  //�]�w���j�r��
    vTmpStrList.DelimitedText := aDatStr; //�]�w�n�Q���j���r��AStringList�|�ۤv���}
    if (vTmpStrList.Count = 0) then       //�d�L�����j�r��
      exit;

    if (aItemIndex > vTmpStrList.Count) then  //�䤣��άO�Ӷê�
      exit;

    result := vTmpStrList.Strings[aItemIndex - 1];  //vTmpStrList.Strings��Index�q0�}�l��A�ҥH�n�qaStrIndex - 1
  Finally
    FreeAndNil(vTmpStrList);
  end;
end;

end.
