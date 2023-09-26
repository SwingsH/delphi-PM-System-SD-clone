{$I define.h}
unit CommonFunction;

interface
uses
  Classes, SysUtils;

(********************************************************
 * 字串分割
 * @param 原始字串
 * @param 分割用字元
 ********************************************************)
function SplitString(const Source,ch:String):TStringList;

function ImplodeString(aList:TStringList; aCh:String):String;
(********************************************************
 * From delphi 7
 * PosEx returns the index of SubStr in S, beginning the search at Offset.
 * If Offset is 1 (default), PosEx is equivalent to Pos.
 * PosEx returns 0 if SubStr is not found, if Offset is greater than
 * the length of S, or if Offset is less than 1.
 ********************************************************)
function PosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;

(********************************************************
 * 實體轉字串 (ineval)
 ********************************************************)
function ComponentToString(Component: TComponent): String;

(********************************************************
 * 字串轉實體 (eval)
 * 如果元件是嵌套形式則必須註冊子元件類
 * 參考RegisterClasses();UnRegisterClasses()
 ********************************************************)
function StringToComponent(Value: String; Instance: TComponent): TComponent;

(********************************************************
 * 取得系統慣用的時間格式: Client Date + Time
 ********************************************************)
function GetClientDateTime:String;

implementation

function SplitString(const Source,ch:String):TStringList;
var
  Temp:String;
  i:Integer;
  chLength:Integer;
begin
  Result:= TStringList.Create;

  if Source='' then  //如果是空字符串則返回空列表
    Exit;
    
  Temp:=Source;
  i:=Pos(ch,Source);
  chLength := Length(ch);
  while i <> 0 do
  begin
    if chLength > 1 then    // S.H mod:
      Inc(i,chLength-1);
    Result.Add(Copy(Temp,1,i - chLength));
    Delete(Temp, 1, i );
    i:= pos(ch, Temp);
  end;
  Result.Add(Temp);
end;

function ImplodeString(aList:TStringList; aCh:String):String;
var
  i:Integer;
begin
  result := '';

  for i:= 0 to aList.Count - 1 do
  begin
    result := result + aList[i];

    if i <> (aList.Count - 1) then
      result := result + aCh ;
  end;

end;

function PosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;
var
    I,X: Integer;
    Len, LenSubStr: Integer;
begin
    if Offset = 1 then
    Result := Pos(SubStr, S)
    else
    begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
        if S[I] = SubStr[1] then
        begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
        Inc(X);
        if (X = LenSubStr) then
        begin
        Result := I;
        exit;
        end;
        end;
        Inc(I);
    end;
    Result := 0;
    end;
end;

{   ComponentToString   }
function ComponentToString(Component: TComponent): String;
var  
    BinStream:   TMemoryStream;  
    StrStream:   TStringStream;  
    s:   string;
begin  
    BinStream   :=   TMemoryStream.Create;  
    try  
        StrStream   :=   TStringStream.Create(s);  
        try  
            BinStream.WriteComponent(Component);  
            BinStream.Seek(0,   soFromBeginning);  
            ObjectBinaryToText(BinStream,   StrStream);  
            StrStream.Seek(0,   soFromBeginning);  
            Result   :=   StrStream.DataString;  
        finally  
            StrStream.Free;  
        end;  
    finally  
        BinStream.Free  
    end;  
end;

{   StringToComponent   }
function StringToComponent(Value: String; Instance: TComponent): TComponent;
var  
    StrStream:   TStringStream;  
    BinStream:   TMemoryStream;  
begin  
    StrStream   :=   TStringStream.Create(Value);  
    try  
        BinStream   :=   TMemoryStream.Create;  
        try  
            ObjectTextToBinary(StrStream,   BinStream);  
            BinStream.Seek(0,   soFromBeginning);  
            Result   :=   BinStream.ReadComponent(Instance);  
        finally  
            BinStream.Free;  
        end;  
    finally  
        StrStream.Free;  
    end;  
end;

function GetClientDateTime:String;
begin
  result:= Format('%s %s', [DateToStr(NOW),TimeToStr(NOW)]);
end;

end.
