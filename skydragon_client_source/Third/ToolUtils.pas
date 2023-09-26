unit ToolUtils;

{$H+,I-,R-,O+,Q-}

interface

uses
  Windows, SysUtils, Classes;

type
  PIntOrFloat = ^TIntOrFloat;
  TIntOrFloat = packed record
    case Boolean of
      True: (i: Integer);
      False: (f: Single);
  end;

  TBitsStream = packed record
    Data: PByte;
    Size: Integer;
    Offset: Integer;
  end;

  PByteVector = ^TByteVector;
  TByteVector = array[0..$3FFFFFFF] of Byte;

  PWordVector = ^TWordVector;
  TWordVector = array[0..$1FFFFFFF] of Word;

const
  bsm_Addr_Data = 0;
  bsm_Addr_Size = 4;
  bsm_Addr_Offset = 8;

  log_buf_size = 16*1024;

  function TruncInt(f1: Single): Integer; overload;     // f1 需小於 100 萬
  function TruncInt(const value: TIntOrFloat): Integer; overload;
  function CeilInt(const value: TIntOrFloat): Integer;
  procedure Init_BitsStream(var BStream: TBitsStream; pData: PByte; DataSize: Integer);
  procedure Read_BitsStream(var BStream: TBitsStream; var Value: Byte; BitCount: Integer); overload;
  procedure Read_BitsStream(var BStream: TBitsStream; var Value: Word; BitCount: Integer); overload;
  procedure Read_BitsStream(var BStream: TBitsStream; var Value: DWord; BitCount: Integer); overload;
  procedure Write_BitsStream(var BStream: TBitsStream; Value: DWord; BitCount: Integer);
  procedure Seek_BitsStream(var BStream: TBitsStream; Offset: Integer);
  procedure Append_BitsStream(var BStream: TBitsStream; const ASrc: TBitsStream; BitCount: Integer);

  // 此函數只適用於 Intel CPU，不可用於 遊戲 client 端
  procedure GetCPUTimeStampCounter(Value: PInt64);

  //function GetBitsByteData(pData: Pointer; OffsetPos: Integer; Mask: Byte): Byte;
  //function GetBitsWordData(pData: Pointer; OffsetPos: Integer; Mask: Word): Word;
  //function GetBitsDWordData(pData: Pointer; OffsetPos: Integer; Mask: DWord): DWord;
  function GetBitBoolean(pData: Pointer; OffsetPos: Integer): Boolean;
  function GetBitsByteData(pData: Pointer; Mask: Byte; OffsetPos: Integer): Byte;
  function GetBitsWordData(pData: Pointer; Mask: Word; OffsetPos: Integer): Word;
  function GetBitsDWordData(pData: Pointer; Mask: DWord; OffsetPos: Integer): DWord;

  //procedure SetBitsByteData(pData: Pointer; OffsetPos: Integer; Mask, Value: Byte);
  //procedure SetBitsWordData(pData: Pointer; OffsetPos: Integer; Mask, Value: Word);
  //procedure SetBitsDWordData(pData: Pointer; OffsetPos: Integer; Mask, Value: DWord);
  procedure SetBitBoolean(pData: Pointer; Value: Boolean; OffsetPos: Integer);
  procedure SetBitsByteData(pData: Pointer; Mask: DWord; OffsetPos: Integer; Value: Byte);
  procedure SetBitsWordData(pData: Pointer; Mask: DWord; OffsetPos: Integer; Value: Word);
  procedure SetBitsDWordData(pData: Pointer; Mask: DWord; OffsetPos: Integer; Value: DWord);

  function GetAppPath: string;
  function get_noext_name(s1: string): string;
  function StringSimilar(SList: TStringList; Value: string): Boolean;

  procedure Run_Length_Code(src, dest: Pointer; PixelByte: Integer; var Size: Integer);
  function Un_Run_Length_Code(src, dest: Pointer; PixelByte: Integer; Size: Integer): Integer;
  function CountTimeGap(NowTime, PreTime: DWord): DWord;
  function CountAbsTimeGap(T1, T2: DWord): DWord;
  function TimeGoPeriod(NowTime, Period: DWord; var PreTime: DWord): Boolean;
  function AddTimeTick(ATime, AGap: DWord): DWord;
  function DecTimeTick(ATime, AGap: DWord): DWord;
  function T1AfterT2(T1, T2: DWord): Boolean;
  function StrIsInt(value: string): Boolean;
  function GetKeyName(key : word ; ShiftState : TShiftState): string;  //回傳鍵盤值名稱
  function GetLetterName(key : word): string;
  function GetShiftState(ShiftState : TShiftState): string;
  procedure CutString(linewidth : integer; s : string; var strlist : TStringList); //將字串做分段,linewidth為一段的字數
  procedure ClearDirectory(const aPath: string);      // 清除目錄下所有第一層檔案
  procedure CopyDirectory(const aSrcPath, aDestPath: string; ext: string = '');    // Copy 目錄下所有第一層檔案
  procedure CopyDirectoryButExt(const aSrcPath, aDestPath: string; ext: string);   // Copy 目錄下所有第一層檔案
  procedure MoveDirectory(const aSrcPath, aDestPath: string; ext: string = '');    // Move 目錄下所有第一層檔案
  procedure DelAllDirectory(const aPath: string);     // 移除整個目錄(包括子目錄)
  procedure CopyPartFile(const aSName, aDName: string; aSize: Integer);
  function isNumberCode(str : string):boolean;
  function isAlphabet(str : string):boolean;
  function CountCheckSum(const Buf; BufLen: Integer): DWord;
  function get_gcd(a1, b1: Integer): Integer;
  function IsSameFile(fname1, fname2: string): Boolean;

const
  max_ptr_num = 20000;

type
  TFPSCounter = class
  private
    FTicks: array of Integer;
    FTickIndex: Integer;
    //FRate: Integer;
    FPeriod: Integer;
    FCheckValue: Integer;
    FTickCount: Integer;
    FFixedRate: Boolean;
  public
    constructor Create(APeriod, Capacity: Integer; bFixedRate: Boolean = False);
    procedure Reset;
    function Tick(Stamp: Integer): Boolean;
    function FrameRate: Single;
    function GetFrameGapString(ACount: Integer): string;
  end;

  // 亂數範圍由 0..32767
  TRandomNumber = class
  private
    FSeed: DWord;
  public
    procedure SetSeed(Value: DWord);
    function GetRandom: DWord; overload;
    function GetRandom(Value: Integer): DWord; overload;
    property SeedValue: DWord read FSeed;
  end;

  TColorChange = packed record
    hue: SmallInt;
    saturation: ShortInt;
    value: ShortInt;
  end;

  TTextLogRecoder = class
  private
    FFile: TFileStream;
    FBuf: array[0..log_buf_size-1 + 32] of Byte;
    FBufLen: Integer;
  protected
    procedure FlushBuffer;
  public
    constructor Create(const fname: string);
    destructor Destroy; override;
    procedure AddLog(const txt: string);
  end;

  PAllocPtrData = ^TAllocPtrData;
  TAllocPtrData = record
    stamp: Int64;
    addr: Pointer;
    size: Integer;
    serial: Integer;
    used: Boolean;
  end;

  TPtrAnalyzer = class
  private
    FData: array[0..max_ptr_num-1] of TAllocPtrData;
    FUsedCount: Integer;
    FFixSize: Integer;
    FCostStamp: Int64;
  public
    FTotal: Integer;
    FLeakCount: Integer;
    FSerial: Integer;
    constructor Create(aFixSize: Integer = 0);
    procedure AddPtr(addr: Pointer; size: Integer);
    procedure DelPtr(addr: Pointer);
    function MinSerial(var aGap, aMaxSize, aMinSize, aGcd: Integer): Integer;
    procedure OutputInfo(var txt: TextFile);
  end;

  TMemoryStream2 = TMemoryStream;
  {TMemoryStream2 = class(TStream)
  private
    FMemory: Pointer;
    FSize, FPosition: Longint;
    FCapacity: Longint;
    procedure SetCapacity(NewCapacity: Longint);
  protected
    function Realloc(var NewCapacity: Longint): Pointer;
    procedure SetPointer(Ptr: Pointer; Size: Longint);
    property Capacity: Longint read FCapacity write SetCapacity;
  public
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SetSize(NewSize: Longint); override;
    function Write(const Buffer; Count: Longint): Longint; override;
    property Memory: Pointer read FMemory;
  end;}

  procedure ValueToColorChange(Value: Word; var Change: TColorChange);
  function ColorChangeToValue(const Change: TColorChange): Word;

type
  TLockRecord = record
    SecName: string[63];
    Key: string[63];
    Value: string[63];
  end;

  function LockFileKey(filename: string; var Data: array of TLockRecord; DataNum: Integer): Boolean;
  function UnlockFileKey(filename: string; var Data: array of TLockRecord; DataNum: Integer): Boolean;

implementation

procedure GetCPUTimeStampCounter(Value: PInt64);
asm
  push eax
  push edx
  push ecx
  mov ecx, Value
  db $0F   //  RDTSC—Read Time-Stamp Counter
  db $31
  mov [ecx],eax
  mov [ecx+4],edx
  pop ecx
  pop edx
  pop eax
end;

function TruncInt(f1: Single): Integer;
var
  tmp: TIntOrFloat;
  k, j: Integer;
begin
  tmp.f := f1;
  if (tmp.i < (127 shl 23)) then
  begin
    Result := 0;
    Exit;
  end;

  k := (tmp.i shr 23);
  j := ((tmp.i and $7FFFFF) or (1 shl 23));

  Result := (j shr (150 - k));
end;

function TruncInt(const value: TIntOrFloat): Integer;
const
  neg_check = (127 shl 23);
  bias: TIntOrFloat = (i:(1 shl 23));
asm
  mov edx, eax
  cmp eax, neg_check
  jge @trunc

@zero:
  xor eax, eax
  jmp @exit

@trunc:
  mov ecx, 150
  shr edx, 23
  and eax, $7FFFFF
  sub ecx, edx
  or eax, bias
  shr eax, cl

@exit:
end;

function CeilInt(const value: TIntOrFloat): Integer;
const
  neg_check = (127 shl 23);
  bias = (1 shl 23);
  mask: array[0..32] of DWord = ($00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF,
          $01FF, $03FF, $07FF, $0FFF, $1FFF, $3FFF, $7FFF, $FFFF,
          $01FFFF, $03FFFF, $07FFFF, $0FFFFF, $1FFFFF, $3FFFFF, $7FFFFF, $FFFFFF,
          $01FFFFFF, $03FFFFFF, $07FFFFFF, $0FFFFFFF, $1FFFFFFF, $3FFFFFFF, $7FFFFFFF, $FFFFFFFF);
asm
  mov edx, eax
  cmp eax, neg_check
  jge @celi

  cmp edx, 0
  jg @one
  xor eax, eax
  jmp @exit

@one:
  mov eax, 1
  jmp @exit

@celi:
  mov ecx, 150
  shr edx, 23
  and eax, $7FFFFF
  sub ecx, edx
  or eax, bias
  mov edx, eax
  shr eax, cl
  and edx, dword ptr [mask + ecx*4]
  jz @exit
  inc eax

@exit:
end;

function GetAppPath: string;
var
  path: array[0..255] of char;
  I, sz: Integer;
begin
  Result := '';
  sz := GetModuleFileName(0, @path[0], 255);
  if (sz > 0) and (sz <= 255) then
  begin
    for I := sz - 1 downto 0 do
    begin
      if path[I] = '\' then
      begin
        path[I+1] := #0;
        Result := path;
        break;
      end;
    end;
  end;
end;

function get_noext_name(s1: string): string;
var
  I: Integer;
begin
  s1 := ExtractFileName(s1);

  for I := Length(s1) downto 1 do
  begin
    if s1[I] = '.' then
    begin
      Result := Copy(s1, 1, I-1);
      Exit;
    end;
  end;
  Result := s1;
end;

(*function GetBitsByteData(pData: Pointer; OffsetPos: Integer; Mask: Byte): Byte;
begin
  asm
    // eax pData
    // edx OffsetPos
    // cl mask
    mov ecx, edx
    shr edx, 3
    and cl, $07
    add edx, eax
    mov ax, word ptr [edx]
    shr ax, cl
    and al, Mask
    mov Result, al
  end;
end;*)

function GetBitBoolean(pData: Pointer; OffsetPos: Integer): Boolean;
asm
  // eax pData
  // edx Offset
  mov ecx, edx
  and cl, $07
  shr edx, 3
  mov al, byte ptr [eax + edx]
  shr al, cl
  and eax, $01
end;

function GetBitsByteData(pData: Pointer; Mask: Byte; OffsetPos: Integer): Byte;
asm
  // eax pData
  // d1 mask
  // ecx OffsetPos
  push ebx
  mov ebx, ecx
  and cl, $07
  shr ebx, 3
  mov ax, word ptr [eax + ebx]
  shr ax, cl
  and al, dl
  pop ebx
end;

(*function GetBitsWordData(pData: Pointer; OffsetPos: Integer; Mask: Word): Word;
begin
  asm
    // eax pData
    // edx OffsetPos
    // cl mask
    mov ecx, edx
    shr edx, 3
    and cl, $07
    add edx, eax
    mov eax, [edx]
    shr eax, cl
    and ax, Mask
    mov Result, ax
  end;
end;*)

function GetBitsWordData(pData: Pointer; Mask: Word; OffsetPos: Integer): Word;
asm
  // eax pData
  // dx mask
  // ecx OffsetPos
  push ebx
  mov ebx, ecx
  shr ebx, 4
  and cl, $0F
  mov eax, [eax + 2*ebx]
  shr eax, cl
  and ax, dx
  pop ebx
end;

(*function GetBitsDWordData(pData: Pointer; OffsetPos: Integer; Mask: DWord): DWord;
begin
  asm
    // eax pData
    // edx OffsetPos
    // cl mask
    mov ecx, edx
    shr edx, 3
    and cl, $07
    add edx, eax
    mov eax, [edx]

    cmp cl, 0
    je @no_shift

    mov edx, [edx+4]
    shr eax, cl
    neg cl
    add cl, 32
    shl edx, cl
    or eax, edx

    @no_shift:
      and eax, Mask
      mov Result, eax
  end;
end;*)

function GetBitsDWordData(pData: Pointer; Mask: DWord; OffsetPos: Integer): DWord;
asm
  // eax pData
  // edx Mask
  // ecx OffsetPos
  push ebx
  mov ebx, ecx
  and cl, $1F
  shr ebx, 5
  shl ebx, 2
  add ebx, eax
  mov eax, [ebx]

  cmp cl, 0
  je @no_shift

  mov ebx, [ebx + 4]
  shr eax, cl
  neg cl
  add cl, 32
  shl ebx, cl
  or eax, ebx

  @no_shift:
    and eax, edx
  pop ebx
end;

(*procedure SetBitsByteData(pData: Pointer; OffsetPos: Integer; Mask, Value: Byte);
begin
  asm
    // eax pData
    // edx OffsetPos
    // cl mask
    push ebx
    mov ecx, edx
    shr edx, 3
    and cl, $07
    add edx, eax

    movzx ax, Mask
    movzx bx, Value
    shl ax, cl
    shl bx, cl

    mov cx, ax
    and bx, ax
    not cx

    and cx, word ptr [edx]
    or cx, bx
    mov word ptr [edx], cx
    pop ebx
  end;
end;*)

procedure SetBitBoolean(pData: Pointer; Value: Boolean; OffsetPos: Integer);
asm
  // eax pData
  // dl Value
  // ecx Offset
  push ebx
  mov dh, 1
  mov ebx, ecx
  and cl, $07
  shr ebx, 3
  shl dx, cl
  add ebx, eax
  not dh
  and byte ptr [ebx], dh
  or byte ptr [ebx], dl
  pop ebx
end;

procedure SetBitsByteData(pData: Pointer; Mask: DWord; OffsetPos: Integer; Value: Byte);
asm
  // eax pData
  // dl mask
  // ecx OffsetPos
  push ebx
  mov ebx, ecx
  shr ebx, 3
  and cl, $07
  add ebx, eax

  movzx ax, Value
  shl dx, cl
  shl ax, cl

  mov cx, dx
  and ax, dx
  not cx

  and cx, word ptr [ebx]
  or cx, ax
  mov word ptr [ebx], cx
  pop ebx
end;

(*procedure SetBitsWordData(pData: Pointer; OffsetPos: Integer; Mask, Value: Word);
begin
  asm
    // eax pData
    // edx OffsetPos
    // cl mask
    push ebx
    mov ecx, edx
    shr edx, 3
    and cl, $07
    add edx, eax

    movzx eax, Mask
    movzx ebx, Value
    shl eax, cl
    shl ebx, cl

    mov ecx, eax
    and ebx, eax
    not ecx

    and ecx, [edx]
    or ecx, ebx
    mov [edx], ecx
    pop ebx
  end;
end;*)

procedure SetBitsWordData(pData: Pointer; Mask: DWord; OffsetPos: Integer; Value: Word);
asm
  // eax pData
  // dx mask
  // ecx OffsetPos
  push ebx
  mov ebx, ecx
  shr ebx, 4
  and cl, $0F
  shl ebx, 1
  add ebx, eax

  movzx eax, Value
  shl edx, cl
  shl eax, cl

  mov ecx, edx
  and eax, edx
  not ecx

  and ecx, [ebx]
  or ecx, eax
  mov [ebx], ecx
  pop ebx
end;

(*procedure SetBitsDWordData(pData: Pointer; OffsetPos: Integer; Mask, Value: DWord);
begin
  SetBitsWordData(pData, OffsetPos, Mask and $FFFF, Value and $FFFF);
  SetBitsWordData(pData, OffsetPos + 16, Mask shr 16, Value shr 16);
end;*)

procedure SetBitsDWordData(pData: Pointer; Mask: DWord; OffsetPos: Integer; Value: DWord);
begin
  SetBitsWordData(pData, Mask and $FFFF, OffsetPos, Value and $FFFF);
  SetBitsWordData(pData, Mask shr 16, OffsetPos + 16, Value shr 16);
end;

//----------------------- TBitsStream -----------------------

procedure Init_BitsStream(var BStream: TBitsStream; pData: PByte; DataSize: Integer);
begin
  with BStream do
  begin
    Data := pData;
    Size := DataSize;
    Offset := 0;
  end;
end;

procedure Read_BitsStream(var BStream: TBitsStream; var Value: Byte; BitCount: Integer);
const
  mask: array[0..8] of Byte = ($00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF);
{$ifdef Debug}
begin
  with BStream do
  begin
    Assert(Size*8 >= Offset + BitCount);
    Value := GetBitsByteData(Data, mask[BitCount], Offset); //  GetBitsByteData(Data, Offset, mask[BitCount]);
    Inc(Offset, BitCount);
  end;
end;
{$else}
asm
  // eax BStream
  // edx Result address
  // ecx BitCount
  push edi
  push ebx

  mov edi, edx
  mov ebx, ecx

  mov edx, [eax].bsm_Addr_Offset
  mov ecx, edx
  add [eax].bsm_Addr_Offset, ebx

  // edi Result address
  // ebx BitCount
  // ecx Offset
  shr edx, 3
  and cl, $07
  add edx, [eax].bsm_Addr_Data
  mov dx, word ptr [edx]
  shr dx, cl
  and dl, byte ptr [mask + ebx]

  mov byte ptr [edi], dl

  pop ebx
  pop edi
end;
{$endif}

procedure Read_BitsStream(var BStream: TBitsStream; var Value: Word; BitCount: Integer);
const
  mask: array[0..16] of Word = ($00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF,
          $01FF, $03FF, $07FF, $0FFF, $1FFF, $3FFF, $7FFF, $FFFF);
{$ifdef Debug}
begin
  with BStream do
  begin
    Assert(Size*8 >= Offset + BitCount);
    Value := GetBitsWordData(Data, mask[BitCount], Offset); // GetBitsWordData(Data, Offset, mask[BitCount]);
    Inc(Offset, BitCount);
  end;
end;
{$else}
asm
  // eax BStream
  // edx Result address
  // ecx BitCount
  push edi
  push ebx

  mov edi, edx
  mov ebx, ecx

  mov edx, [eax].bsm_Addr_Offset
  mov ecx, edx
  add [eax].bsm_Addr_Offset, ebx

  // edi Result address
  // ebx BitCount
  // ecx Offset
  shr edx, 4
  and cl, $0F
  shl edx, 1
  add edx, [eax].bsm_Addr_Data
  mov edx, [edx]
  shr edx, cl
  and dx, word ptr [mask + ebx*2]

  mov word ptr [edi], dx

  pop ebx
  pop edi
end;
{$endif}

procedure Read_BitsStream(var BStream: TBitsStream; var Value: DWord; BitCount: Integer);
const
  mask: array[0..32] of DWord = ($00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF,
          $01FF, $03FF, $07FF, $0FFF, $1FFF, $3FFF, $7FFF, $FFFF,
          $01FFFF, $03FFFF, $07FFFF, $0FFFFF, $1FFFFF, $3FFFFF, $7FFFFF, $FFFFFF,
          $01FFFFFF, $03FFFFFF, $07FFFFFF, $0FFFFFFF, $1FFFFFFF, $3FFFFFFF, $7FFFFFFF, $FFFFFFFF);
{$ifdef Debug}
begin
  with BStream do
  begin
    Assert(Size*8 >= Offset + BitCount);
    Value := GetBitsDWordData(Data, mask[BitCount], Offset); //  GetBitsDWordData(Data, Offset, mask[BitCount]);
    Inc(Offset, BitCount);
  end;
end;
{$else}
asm
  // eax BStream
  // edx Result address
  // ecx BitCount
  push edi
  push ebx

  mov edi, edx
  mov ebx, ecx

  mov edx, [eax].bsm_Addr_Offset
  mov ecx, edx
  add [eax].bsm_Addr_Offset, ebx

  // edi Result address
  // ebx BitCount
  // ecx Offset
  shr edx, 5
  and cl, $1F
  shl edx, 2
  add edx, [eax].bsm_Addr_Data

  mov eax, [edx]

  cmp cl, 0
  je @no_shift

  mov edx, [edx + 4]
  shr eax, cl
  neg cl
  add cl, 32
  shl edx, cl
  or eax, edx

  @no_shift:
    and eax, dword ptr [mask + ebx*4]

  mov [edi], eax

  pop ebx
  pop edi
end;
{$endif}

procedure Write_BitsStream(var BStream: TBitsStream; Value: DWord; BitCount: Integer);
const
  mask: array[0..32] of DWord = ($00, $01, $03, $07, $0F, $1F, $3F, $7F, $FF,
          $01FF, $03FF, $07FF, $0FFF, $1FFF, $3FFF, $7FFF, $FFFF,
          $01FFFF, $03FFFF, $07FFFF, $0FFFFF, $1FFFFF, $3FFFFF, $7FFFFF, $FFFFFF,
          $01FFFFFF, $03FFFFFF, $07FFFFFF, $0FFFFFFF, $1FFFFFFF, $3FFFFFFF, $7FFFFFFF, $FFFFFFFF);
begin
  with BStream do
  begin
    Assert(Size*8 >= Offset + BitCount);
    if BitCount <= 8 then
      SetBitsByteData(Data, mask[BitCount], Offset, Value) // SetBitsByteData(Data, Offset, mask[BitCount], Value)
    else if BitCount <= 16 then
      SetBitsWordData(Data, mask[BitCount], Offset, Value) // SetBitsWordData(Data, Offset, mask[BitCount], Value)
    else
      SetBitsDWordData(Data, mask[BitCount], Offset, Value); // SetBitsDWordData(Data, Offset, mask[BitCount], Value)
    Inc(Offset, BitCount);
  end;
end;

procedure Seek_BitsStream(var BStream: TBitsStream; Offset: Integer);
begin
  BStream.Offset := Offset;
end;

procedure Append_BitsStream(var BStream: TBitsStream; const ASrc: TBitsStream; BitCount: Integer);
var
  cnt, remain, I: Integer;
  pbt: PByte;
begin
  cnt := BitCount div 8;
  remain := BitCount mod 8;

  pbt := ASrc.Data;
  for I := 0 to cnt - 1 do
  begin
    Write_BitsStream(BStream, pbt^, 8);
    Inc(pbt);
  end;

  if remain > 0 then
  begin
    Write_BitsStream(BStream, pbt^, remain);
  end;
end;

function FindSmallEqualPosition(SList: TStringList; Value: string): Integer;
var
  min, max, res, middle: Integer;
begin
  Result := -1;
  if SList.Count = 0 then
    Exit;

  if SList.Count = 1 then
  begin
    res := AnsiCompareText(SList[0], Value);
    if res <= 0 then
      Result := 0;

    Exit;
  end;

  min := 0;
  max := SList.Count - 1;
  res := AnsiCompareText(SList[min], Value);
  if res > 0 then
  begin
    Result := -1;
    Exit;
  end
  else if res = 0 then
  begin
    Result := min;
    Exit;
  end;

  res := AnsiCompareText(SList[max], Value);
  if res <= 0 then
  begin
    Result := max;
    Exit;
  end;

  while (min < max - 1) do
  begin
    middle := (min + max) shr 1;
    res := AnsiCompareText(SList[middle], Value);
    if res < 0 then
    begin
      min := middle;
    end
    else if res > 0 then
    begin
      max := middle;
    end
    else begin
      Result := middle;
      Exit;
    end;
  end;

  Result := min;
end;

function StringIncluded(SList: TStringList; Value: string): Boolean;
var
  I, len: Integer;
  str: string;
begin
  Result := False;
  I := FindSmallEqualPosition(SList, Value);
  if I < 0 then
    Exit;

  len := Length(SList[I]);
  str := Copy(Value, 1, len);
  Result := (AnsiCompareText(str, SList[I]) = 0);
end;

function StringSimilar(SList: TStringList; Value: string): Boolean;
var
  len, I, add: Integer;
  str: string;
begin
  Result := True;

  len := Length(Value);
  I := 1;
  while(I <= len) do
  begin
    if Ord(Value[I]) < 128 then
    begin
      add := 1;
    end
    else
      add := 2;

    str := Copy(Value, I, len);
    if StringIncluded(SList, str) then
    begin
      Exit;
    end;
    Inc(I, add);
  end;

  Result := False;
end;

type
  PDWordArray = ^TDWordArray;
  TDWordArray = array[0..1024*1024*64 - 1] of DWord;

// Run Length 壓縮
// 參數
//   src 待壓縮連續記憶體
//   dest 儲存壓縮結果之記憶體
//   PixelByte 每一單位資料所佔 Byte 數
//   Size 傳入 待壓縮資料大小
//      傳出 壓縮後資料大小
//
// 壓縮方式
//   NumByte + Data(?)   N := (NumByte and $7F)
//   當 NumByte 大於 127 表示為下一筆資料重覆 N 次
//   當 NumByte 小於 128 表示其後為連續 N 筆資料
procedure Run_Length_Code(src, dest: Pointer; PixelByte: Integer; var Size: Integer);
var
  pbt1, pbt2: PByteVector;
  pwd1, pwd2: PWordVector;
  pdd1, pdd2: PDwordArray;
  codesz, cnt, remain: Integer;
begin
  codesz := 0;
  case PixelByte of
    1: begin
      remain := Size;
      while(remain > 0) do
      begin
        pbt1 := Pointer(Integer(src) + Size - remain);
        pbt2 := Pointer(Integer(dest) + codesz);
        if remain = 1 then
        begin
          pbt2[0] := 0;
          pbt2[1] := pbt1[0];
          Dec(remain);
          Inc(codesz, 2);
        end
        else if remain = 2 then
        begin
          if pbt1[0] = pbt1[1] then
          begin
            pbt2[0] := $80 or 1;
            pbt2[1] := pbt1[0];
            Inc(codesz, 2);
          end
          else begin
            pbt2[0] := 1;
            pbt2[1] := pbt1[0];
            pbt2[2] := pbt1[1];
            Inc(codesz, 3);
          end;
          Dec(remain, 2);
        end
        else begin
          if pbt1[0] = pbt1[1] then
          begin
            cnt := 2;
            while ((cnt < 128) and (cnt < remain)) do
            begin
              if pbt1[0] <> pbt1[cnt] then
              begin
                break;
              end;
              Inc(cnt);
            end;

            pbt2[0] := $80 or (cnt - 1);
            pbt2[1] := pbt1[0];
            Dec(remain, cnt);
            Inc(codesz, 2);
          end
          else begin
            cnt := 1;
            while ((cnt < 128) and (cnt + 1 < remain)) do
            begin
              if pbt1[cnt] = pbt1[cnt + 1] then
              begin
                break;
              end;
              Inc(cnt);
            end;

            pbt2[0] := (cnt - 1);
            Move(pbt1[0], pbt2[1], cnt);
            Dec(remain, cnt);
            Inc(codesz, cnt + 1);
          end;
        end;
      end;
    end;
    2: begin
      remain := Size;
      while(remain > 0) do
      begin
        pwd1 := Pointer(Integer(src) + Size - remain);
        pbt2 := Pointer(Integer(dest) + codesz);
        pwd2 := Pointer(Integer(dest) + codesz + 1);
        if remain = 2 then
        begin
          pbt2[0] := 0;
          pwd2[0] := pwd1[0];
          Dec(remain, 2);
          Inc(codesz, 3);
        end
        else if remain = 4 then
        begin
          if pwd1[0] = pwd1[1] then
          begin
            pbt2[0] := $80 or 1;
            pwd2[0] := pwd1[0];
            Inc(codesz, 3);
          end
          else begin
            pbt2[0] := 1;
            pwd2[0] := pwd1[0];
            pwd2[1] := pwd1[1];
            Inc(codesz, 5);
          end;
          Dec(remain, 4);
        end
        else begin
          if pwd1[0] = pwd1[1] then
          begin
            cnt := 2;
            while ((cnt < 128) and (cnt*2 < remain)) do
            begin
              if pwd1[0] <> pwd1[cnt] then
              begin
                break;
              end;
              Inc(cnt);
            end;

            pbt2[0] := $80 or (cnt - 1);
            pwd2[0] := pwd1[0];
            Dec(remain, cnt*2);
            Inc(codesz, 3);
          end
          else begin
            cnt := 1;
            while ((cnt < 128) and (cnt*2 + 2 < remain)) do
            begin
              if pwd1[cnt] = pwd1[cnt + 1] then
              begin
                break;
              end;
              Inc(cnt);
            end;

            pbt2[0] := (cnt - 1);
            Move(pwd1[0], pwd2[0], cnt*2);
            Dec(remain, cnt*2);
            Inc(codesz, cnt*2 + 1);
          end;
        end;
      end;
    end;
    4: begin
      remain := Size;
      while(remain > 0) do
      begin
        pdd1 := Pointer(Integer(src) + Size - remain);
        pbt2 := Pointer(Integer(dest) + codesz);
        pdd2 := Pointer(Integer(dest) + codesz + 1);
        if remain = 4 then
        begin
          pbt2[0] := 0;
          pdd2[0] := pdd1[0];
          Dec(remain, 4);
          Inc(codesz, 5);
        end
        else if remain = 8 then
        begin
          if pdd1[0] = pdd1[1] then
          begin
            pbt2[0] := $80 or 1;
            pdd2[0] := pdd1[0];
            Inc(codesz, 5);
          end
          else begin
            pbt2[0] := 1;
            pdd2[0] := pdd1[0];
            pdd2[1] := pdd1[1];
            Inc(codesz, 5);
          end;
          Dec(remain, 8);
        end
        else begin
          if pdd1[0] = pdd1[1] then
          begin
            cnt := 2;
            while ((cnt < 128) and (cnt*4 < remain)) do
            begin
              if pdd1[0] <> pdd1[cnt] then
              begin
                break;
              end;
              Inc(cnt);
            end;

            pbt2[0] := $80 or (cnt - 1);
            pdd2[0] := pdd1[0];
            Dec(remain, cnt*4);
            Inc(codesz, 5);
          end
          else begin
            cnt := 1;
            while ((cnt < 128) and (cnt*4 + 4 < remain)) do
            begin
              if pdd1[cnt] = pdd1[cnt + 1] then
              begin
                break;
              end;
              Inc(cnt);
            end;

            pbt2[0] := (cnt - 1);
            Move(pdd1[0], pdd2[0], cnt*4);
            Dec(remain, cnt*4);
            Inc(codesz, cnt*4 + 1);
          end;
        end;
      end;
    end;
  end;
  Size := codesz;
end;

// Un Run Length 解壓縮
// 參數
//   src 待解壓縮連續記憶體
//   dest 儲存解壓縮結果之記憶體
//   PixelByte 每一單位資料所佔 Byte 數
//   Size 待解壓縮資料大小
//
// 傳回值
//   解壓縮後資料大小
function Un_Run_Length_Code(src, dest: Pointer; PixelByte: Integer; Size: Integer): Integer;
var
  pbt1, pbt2: PByteVector;
  pwd1, pwd2: PWordVector;
  pdd1, pdd2: PDwordArray;
  I, codesz, cnt, remain: Integer;
begin
  codesz := 0;
  case PixelByte of
    1: begin
      remain := Size;
      while (remain > 0) do
      begin
        pbt1 := Pointer(Integer(src) + Size - remain);
        pbt2 := Pointer(Integer(dest) + codesz);

        cnt := (pbt1[0] and $7F) + 1;
        if pbt1[0] >= 128 then
        begin
          FillChar(pbt2[0], cnt, pbt1[1]);
          Dec(remain, 2);
          Inc(codesz, cnt);
        end
        else begin
          Move(pbt1[1], pbt2[0], cnt);
          Dec(remain, 1 + cnt);
          Inc(codesz, cnt);
        end;
      end;
    end;
    2: begin
      remain := Size;
      while (remain > 0) do
      begin
        pbt1 := Pointer(Integer(src) + Size - remain);
        pwd1 := Pointer(Integer(src) + Size - remain + 1);
        pwd2 := Pointer(Integer(dest) + codesz);

        cnt := (pbt1[0] and $7F) + 1;
        if pbt1[0] >= 128 then
        begin
          for I := 0 to cnt - 1 do
            pwd2[I] := pwd1[0];
          Dec(remain, 3);
          Inc(codesz, cnt*2);
        end
        else begin
          Move(pwd1[0], pwd2[0], cnt*2);
          Dec(remain, 1 + cnt*2);
          Inc(codesz, cnt*2);
        end;
      end;
    end;
    4: begin
      remain := Size;
      while (remain > 0) do
      begin
        pbt1 := Pointer(Integer(src) + Size - remain);
        pdd1 := Pointer(Integer(src) + Size - remain + 1);
        pdd2 := Pointer(Integer(dest) + codesz);

        cnt := (pbt1[0] and $7F) + 1;
        if pbt1[0] >= 128 then
        begin
          for I := 0 to cnt - 1 do
            pdd2[I] := pdd1[0];
          Dec(remain, 5);
          Inc(codesz, cnt*4);
        end
        else begin
          Move(pdd1[0], pdd2[0], cnt*4);
          Dec(remain, 1 + cnt*4);
          Inc(codesz, cnt*4);
        end;
      end;
    end;
  end;

  Result := codesz;
end;

function CountTimeGap(NowTime, PreTime: DWord): DWord;
begin
  if NowTime >= PreTime then
  begin
    Result := NowTime - PreTime;
  end
  else begin
    Result := NowTime + 1 + (not PreTime);
  end;
end;

function CountAbsTimeGap(T1, T2: DWord): DWord;
begin
  if T1 >= T2 then
    Result := T1 - T2
  else
    Result := T2 - T1;
end;

function TimeGoPeriod(NowTime, Period: DWord; var PreTime: DWord): Boolean;
var
  Gap: DWord;
begin
  if NowTime >= PreTime then
  begin
    Gap := NowTime - PreTime;
  end
  else begin
    Gap := NowTime + 1 + not PreTime;
  end;

  if Gap >= Period then
  begin
    if Gap >= ((Period*3) shr 1) then
    begin
      PreTime := NowTime;
    end
    else begin
      Dec(Gap, Period);
      if NowTime >= Gap then
        PreTime := NowTime - Gap
      else
        PreTime := 0;
    end;

    Result := True;
  end
  else
    Result := False;
end;

function AddTimeTick(ATime, AGap: DWord): DWord;
var
  v0: Int64;
begin
  v0 := ATime + AGap;
  Result := (v0 and $FFFFFFFF);
end;

function DecTimeTick(ATime, AGap: DWord): DWord;
begin
  if ATime >= AGap then
    Result := ATime - AGap
  else begin
    AGap := AGap - ATime;
    Result := (not AGap) + 1;
  end;
end;

function T1AfterT2(T1, T2: DWord): Boolean;
begin
  if T1 >= T2 then
  begin
    if (T1 > $FFFFF000) and (T2 < 10000) then
      Result := False
    else
      Result := True;
  end
  else begin
    if (T2 > $FFFFF000) and (T1 < 10000) then
      Result := True
    else
      Result := False;
  end;
end;

function StrIsInt(value: string): Boolean;
var
  I, Len, st: Integer;
begin
  Result := False;

  if value = '' then
    Exit;

  Len := Length(value);
  if value[1] = '$' then
  begin
    if Len = 1 then
      Exit;

    for I := 2 to Len do
    begin
      if not (value[I] in ['0'..'9', 'A'..'F', 'a'..'f']) then
        Exit;
    end;
  end
  else begin
    if value[1] = '-' then
      st := 2
    else
      st := 1;

    if Len < st then
      Exit;

    for I := st to Len do
    begin
      if not (value[I] in ['0'..'9']) then
        Exit;
    end;
  end;

  Result := True;
end;


// -------------------- TFPSCounter --------------------

constructor TFPSCounter.Create(APeriod, Capacity: Integer; bFixedRate: Boolean);
begin
  inherited Create;

  FFixedRate := bFixedRate;
  //FRate := Rate;
  FPeriod := APeriod; //1000 div Rate;
  FCheckValue := (Capacity*FPeriod - FPeriod div 2);
  SetLength(FTicks, Capacity);
  Reset;
end;

procedure TFPSCounter.Reset;
var
  len: Integer;
begin
  len := Length(FTicks);
  FillChar(FTicks[0], sizeof(FTicks[0])*len, 0);
  FTickIndex := 0;
  FTickCount := 0;
end;

function TFPSCounter.Tick(Stamp: Integer): Boolean;
var
  pretick: Integer;
begin
  if FTickCount <= Length(FTicks) then
  begin
    //ticknum := 1000 div FRate;
    if (not FFixedRate) or (FTickCount = 0) or ((FTickCount*FPeriod - FPeriod div 2) < (Stamp - FTicks[0])) then
    begin
      FTicks[FTickIndex] := Stamp;
      Inc(FTickIndex);
      if FTickIndex >= Length(FTicks) then
        FTickIndex := 0;

      Result := True;
      Inc(FTickCount);
    end
    else
      Result := False;
  end
  else if (not FFixedRate) or (Stamp - FTicks[FTickIndex] > FCheckValue) then
  begin
    // 不固定 FrameRate 或 已延遲太久
    FTicks[FTickIndex] := Stamp;
    Inc(FTickIndex);
    if FTickIndex >= Length(FTicks) then
      FTickIndex := 0;

    Result := True;
  end
  else begin
    if FTickIndex = 0 then
      pretick := Length(FTicks) - 1
    else
      pretick := FTickIndex - 1;

    if Stamp > FTicks[pretick] + FPeriod then
    begin
      FTicks[FTickIndex] := Stamp;
      Inc(FTickIndex);
      if FTickIndex >= Length(FTicks) then
        FTickIndex := 0;

      Result := True;
    end
    else
      Result := False;
  end;
end;

function TFPSCounter.FrameRate: Single;
var
  nowind, cnt: Integer;
begin
  cnt := Length(FTicks) - 1;
  nowind := FTickIndex - 1;
  if nowind < 0 then
    nowind := cnt;

  if (FTicks[nowind] - FTicks[FTickIndex]) = 0 then
  begin
    Result := 0;
    Exit;
  end;

  Result := cnt*1000/(FTicks[nowind] - FTicks[FTickIndex]);
end;

{$J+}
function TFPSCounter.GetFrameGapString(ACount: Integer): string;
//const
//  maxgap: Integer = 0;
var
  I, J, stamp, gap, cnt, maxgap: Integer;
begin
  Result := '';
  J := FTickIndex - 1 - ACount;
  if J < 0 then
    Inc(J, Length(FTicks));
  stamp := FTicks[J];

  cnt := 0;
  maxgap := 0;
  for I := 0 to ACount - 1 do
  begin
    Inc(J);
    if J >= Length(FTicks) then
      J := 0;

    gap := FTicks[J] - stamp;
    Result := Result + ' ' + IntToStr(gap);
    stamp := FTicks[J];

    if gap <> FPeriod then
    begin
      Inc(cnt);
      if maxgap < Abs(gap - FPeriod) then
        maxgap := Abs(gap - FPeriod);
    end;
  end;

  if (cnt <> 0) and (maxgap <> 0) then
    Result := Format('%s %d %d', [Result, cnt, maxgap]);
end;
{$J-}


// ------------------ TRandomNumber ------------------

const
  rand_k_A: DWord = 1103515245;
  rand_k_C: DWord = 12345;

procedure TRandomNumber.SetSeed(Value: DWord);
begin
  FSeed := Value;
end;

function TRandomNumber.GetRandom: DWord;
asm
  // m_currentSeed = k_A * m_currentSeed + k_C;
  // resultShifted = (m_currentSeed >> 16) & 0x7FFF;
  mov ecx, eax
  mov eax, [eax].FSeed
  mul eax, rand_k_A
  add eax, rand_k_C
  mov [ecx].FSeed, eax
  shr eax, 16
  and ax, $7FFF
end;

function TRandomNumber.GetRandom(Value: Integer): DWord;
asm
  // m_currentSeed = k_A * m_currentSeed + k_C;
  // resultShifted = (m_currentSeed >> 16) & 0x7FFF;
  mov ecx, eax
  push edx
  mov eax, [eax].FSeed
  mul eax, rand_k_A
  add eax, rand_k_C
  pop edx
  mov [ecx].FSeed, eax
  mul edx
  mov eax, edx
end;

// Hue  (6 bit)  0..59  *6   Saturation   (6 bit)  -32 .. 31 *4   Value   (4 bit)  -16 .. 15 *8
procedure ValueToColorChange(Value: Word; var Change: TColorChange);
var
  h, s, v: Integer;
begin
  h := (Value shr 10);
  s := (Value shr 4) and $3F;
  v := Value and $0F;

  Change.hue := h*6;
  Change.saturation := s*4 - 100;
  Change.value := v*8 - 100;
end;

function ColorChangeToValue(const Change: TColorChange): Word;
var
  h, s, v: Byte;
begin
  h := Change.hue div 6;
  s := (Change.saturation + 100) div 4;
  v := (Change.value + 100) div 8;
  Result := h shl 10 + s shl 4 + v;
end;

function FindSectionKey(s1: TStringList; SecName, Key: string): string;
var
  I, k1, k2, start: Integer;
  str, str1: string;
begin
  Result := '';

  start := -1;
  for I := 0 to s1.Count - 1 do
  begin
    str := s1[I];
    k1 := Pos('[', str);
    k2 := Pos(']', str);
    if (k1 > 0) and (k2 > k1) then
    begin
      if SameText(Trim(Copy(str, k1 + 1, k2-k1-1)), SecName) then
      begin
        start := I + 1;
        break;
      end;
    end;
  end;

  if start < 0 then
    Exit;

  for I := start to s1.Count - 1 do
  begin
    str := s1[I];
    k1 := Pos('[', str);
    k2 := Pos(']', str);
    if (k1 > 0) and (k2 > k1) then  // next section
      Exit;

    k1 := Pos('=', str);
    if k1 > 0 then
    begin
      str1 := Copy(str, 1, k1-1);

      if SameText(Trim(str1), Key) then
      begin
        Delete(str, 1, k1);
        Result := Trim(str);
        break;
      end;
    end;
  end;
end;

function InsertSectionKey(s1: TStringList; SecName, Key, Value: string): Boolean;
var
  I, k1, k2, start: Integer;
  str: string;
begin
  Result := False;

  start := -1;
  for I := 0 to s1.Count - 1 do
  begin
    str := s1[I];
    k1 := Pos('[', str);
    k2 := Pos(']', str);
    if (k1 > 0) and (k2 > k1) then
    begin
      if SameText(Trim(Copy(str, k1 + 1, k2-k1-1)), SecName) then
      begin
        start := I + 1;
        break;
      end;
    end;
  end;

  if start < 0 then
    Exit;

  s1.Insert(start, Key + '=' + Value);
  Result := True;
end;

function DelSectionKey(s1: TStringList; SecName, Key, Value: string): Boolean;
var
  I, k1, k2, start: Integer;
  str, str1: string;
begin
  Result := False;

  start := -1;
  for I := 0 to s1.Count - 1 do
  begin
    str := s1[I];
    k1 := Pos('[', str);
    k2 := Pos(']', str);
    if (k1 > 0) and (k2 > k1) then
    begin
      if SameText(Trim(Copy(str, k1 + 1, k2-k1-1)), SecName) then
      begin
        start := I + 1;
        break;
      end;
    end;
  end;

  if start < 0 then
    Exit;

  for I := start to s1.Count - 1 do
  begin
    str := s1[I];
    k1 := Pos('[', str);
    k2 := Pos(']', str);
    if (k1 > 0) and (k2 > k1) then  // next section
      Exit;

    k1 := Pos('=', str);
    if k1 > 0 then
    begin
      str1 := Copy(str, 1, k1-1);
      Delete(str, 1, k1);

      if SameText(Trim(str1), Key) and SameText(Trim(str), Value) then
      begin
        s1.Delete(I);
        Result := True;
        break;
      end;
    end;
  end;
end;

function LockFileKey(filename: string; var Data: array of TLockRecord; DataNum: Integer): Boolean;
var
  f1: TFileStream;
  s1: TStringList;
  I: Integer;
  str: string;
  bEnd: Boolean;
begin
  Result := False;

  try
    // 鎖定檔案
    f1 := TFileStream.Create(filename, fmOpenReadWrite or fmShareExclusive);
  except
    Exit;
  end;

  // 所有操作在 s1 上
  s1 := TStringList.Create;
  f1.Position := 0;
  s1.LoadFromStream(f1);

  try
    bEnd := False;
    for I := 0 to DataNum - 1 do
    begin
      str := FindSectionKey(s1, Data[I].SecName, Data[I].Key);
      if str <> '' then
      begin
        Data[I].Value := str;
        bEnd := True;
        break;
      end;
    end;

    if not bEnd then
    begin
      for I := 0 to DataNum - 1 do
      begin
        if not InsertSectionKey(s1, Data[I].SecName, Data[I].Key, Data[I].Value) then
        begin
          bEnd := True;
          break;
        end;
      end;
    end;

    Result := not bEnd;
    if Result then
    begin
      f1.Size := 0;
      f1.Position := 0;
      s1.SaveToStream(f1);
    end;
  finally
    s1.Free;
    f1.Free;
  end;
end;

function UnlockFileKey(filename: string; var Data: array of TLockRecord; DataNum: Integer): Boolean;
var
  f1: TFileStream;
  s1: TStringList;
  I: Integer;
  bEnd: Boolean;
begin
  Result := False;

  I := 0;
  f1 := nil;
  while(I < 3) do
  begin
    try
      // 鎖定檔案
      f1 := TFileStream.Create(filename, fmOpenReadWrite or fmShareExclusive);
      break;
    except
    end;
    Inc(I);
    Sleep(200);
  end;

  if I >= 3 then
    Exit;

  if f1 = nil then
    Exit;

  // 所有操作在 s1 上
  s1 := TStringList.Create;
  f1.Position := 0;
  s1.LoadFromStream(f1);

  try
    bEnd := False;
    for I := 0 to DataNum - 1 do
    begin
      if not DelSectionKey(s1, Data[I].SecName, Data[I].Key, Data[I].Value) then
      begin
        bEnd := True;
      end;
    end;

    Result := not bEnd;
    if Result then
    begin
      f1.Size := 0;
      f1.Position := 0;
      s1.SaveToStream(f1);
    end;
  finally
    s1.Free;
    f1.Free;
  end;
end;

function GetKeyName(key : word ; ShiftState : TShiftState): string;  //回傳鍵盤值名稱
var
  letter,keystate : string;
begin
  letter :=  GetLetterName(key);
  if letter = '' then
  begin
    Result := '';
    exit;
  end;
  keystate := GetShiftState(ShiftState);
  if keystate = '' then
    Result := letter
  else
    Result := keystate + '+' + letter;
end;

function GetLetterName(key : word): string;
var str : string;
begin
//主鍵
  str := '';
  case key of
    VK_F1     : str := 'F1'; //F1 key
    VK_F2     : str := 'F2'; //F2 key
    VK_F3     : str := 'F3'; //F3 key
    VK_F4     : str := 'F4'; //F4 key
    VK_F5     : str := 'F5'; //F5 key
    VK_F6     : str := 'F6'; //F6 key
    VK_F7     : str := 'F7'; //F7 key
    VK_F8     : str := 'F8'; //F8 key
    VK_F9     : str := 'F9'; //F9 key
    VK_F10    : str := 'F10'; //F10 key
    VK_F11    : str := 'F11'; //F10 key
    VK_F12    : str := 'F12'; //F10 key
    VK_BACK   : str := 'Back';
    32        : str := 'Space';
    186       : str := ';';
    187       : str := '=';
    188       : str := ',';
    189       : str := '-';
    190       : str := '.';
    191       : str := '/';
    192       : str := '~';
    219       : str := '[';
    220       : str := '\';
    221       : str := ']';
    222       : str := '''';
  end;
  if str = '' then
  begin
    if key <> 0 then
      str := Chr(key);
  end;
  Result := str;
end;

function GetShiftState(ShiftState : TShiftState): string;
var str : string;
begin
//組合鍵
  if ShiftState <> [] then
  begin
    if ssShift in ShiftState then
      str := 'S';
    if ssAlt	 in ShiftState then
      str := 'A';
    if ssCtrl	 in ShiftState then
      str := 'C';
  end;
  Result := str;
end;

procedure CutString(linewidth : integer; s : string; var strlist : TStringList);
var
  i : integer;
  tmpStr, newStr : string;
  cursor : integer;
begin
  strlist.Clear;

  if length(s) > linewidth then
  begin

    while(length(s) > 0)do
    begin
      if (length(s) <= linewidth) then
      begin
        strlist.Add(s);
        exit;
      end;

      //
      cursor := linewidth+1;

      case ByteType (s, cursor-1) of
        mbSingleByte:
        begin
          // nothing
        end;

        mbLeadByte:
        begin
          cursor:=cursor-1;
        end;

        mbTrailByte:
        begin
          if ByteType(s, cursor) = mbTrailByte then//檢查下個字元是否也是 mbTrailByte
          begin
            //
            for i:=cursor-1 downto 1 do
              if ByteType(s, i) = mbLeadByte then
              begin
                cursor := i;
                break;
              end;
            //
          end;
        end;

      end;
      //
      tmpStr := copy(s, 1, cursor-1);
      newStr := copy(s, cursor, length(s)-cursor+1);
      s := newStr;
      //擷取好的字串
      strlist.Add(tmpStr);
    end;
  end
  else begin
    strlist.Add(s);
  end;
end;

procedure ClearDirectory(const aPath: string);
var
  sr: TSearchRec;
  str: string;
begin
  str := aPath + '*.*';
  if FindFirst(str, faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> faDirectory then
      begin
        DeleteFile(aPath + sr.Name);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;

procedure CopyDirectory(const aSrcPath, aDestPath: string; ext: string);
var
  sr: TSearchRec;
  str: string;
begin
  if ext = '' then
    str := aSrcPath + '*.*'
  else
    str := aSrcPath + '*.' + ext;

  if FindFirst(str, faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> faDirectory then
      begin
        CopyFile(PChar(aSrcPath + sr.Name), PChar(aDestPath + sr.Name), True);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;

procedure CopyDirectoryButExt(const aSrcPath, aDestPath: string; ext: string);
var
  sr: TSearchRec;
  str,  strext: string;
  len, len1: Integer;
begin
  str := aSrcPath + '*.*';
  len := Length(ext);

  if FindFirst(str, faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> faDirectory then
      begin
        len1 := Length(sr.Name);
        strext := Copy(sr.Name, len1 - len + 1, len);
        if not SameText(ext, strext) then
          CopyFile(PChar(aSrcPath + sr.Name), PChar(aDestPath + sr.Name), True);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;

procedure MoveDirectory(const aSrcPath, aDestPath: string; ext: string);
var
  sr: TSearchRec;
  str: string;
begin
  if ext = '' then
    str := aSrcPath + '*.*'
  else
    str := aSrcPath + '*.' + ext;

  if FindFirst(str, faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> faDirectory then
      begin
        MoveFileEx(PChar(aSrcPath + sr.Name), PChar(aDestPath + sr.Name),
          MOVEFILE_COPY_ALLOWED or MOVEFILE_REPLACE_EXISTING);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;

procedure DelAllDirectory(const aPath: string);
var
  sr: TSearchRec;
  str: string;
begin
  str := aPath + '*.*';
  if FindFirst(str, faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> faDirectory then
      begin
        DeleteFile(aPath + sr.Name);
      end
      else begin
        if (sr.Name <> '.') and (sr.Name <> '..') then
        begin
          DelAllDirectory(aPath + sr.Name + '\');
          RemoveDirectory(PChar(aPath + sr.Name));
        end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

  RemoveDirectory(PChar(aPath));
end;

procedure CopyPartFile(const aSName, aDName: string; aSize: Integer);
const
  cpsz = 16*1024;
var
  buf: array[0..cpsz-1] of Byte;
  f1, f2: TFileStream;
  I, cnt, rm, sz: Integer;
begin
  f1 := TFileStream.Create(aSName, fmOpenReadWrite or fmShareDenyNone);
  try
    sz := f1.Size;
    if sz < aSize then
      aSize := sz;

    cnt := aSize div cpsz;
    rm := aSize mod cpsz;

    f2 := TFileStream.Create(aDName, fmCreate);
    try
      for I := 0 to cnt - 1 do
      begin
        f1.Read(buf, cpsz);
        f2.Write(buf, cpsz);
      end;

      if rm > 0 then
      begin
        f1.Read(buf, rm);
        f2.Write(buf, rm);
      end;
    finally
      f2.Free;
    end;
  finally
    f1.Free;
  end;
end;

function isNumberCode(str : string):boolean;
begin
  if str <> '' then
  begin
    if (byte(str[1]) >= 48) and (byte(str[1]) <= 57) then
      Result := true
    else
      Result := false
  end
  else
    Result := False;
end;

function isAlphabet(str : string):boolean;
begin
  if str <> '' then
  begin
    if (byte(str[1]) >= 65) and (Byte(str[1]) <=90) or
       (byte(str[1]) >= 97) and (byte(str[1]) <=122) then
      Result := true
    else
      Result := false
  end
  else
    Result := False;
end;

function CountCheckSum(const Buf; BufLen: Integer): DWord;
var
  pbt: PByte;
  I: Integer;
begin
  Result := 0;
  pbt := @Buf;
  for I := 1 to BufLen do
  begin
    Inc(Result, pbt^);
    Inc(pbt);
  end;
end;

function get_gcd(a1, b1: Integer): Integer;
var
  i1: Integer;
begin
  repeat
    i1 := a1 mod b1;
    a1 := b1;
    b1 := i1;
  until i1 = 0;

  Result := a1;
end;

function IsSameFile(fname1, fname2: string): Boolean;
var
  f1, f2: File of Byte;
  I, sz1, sz2: Integer;
  m1, m2: TMemoryStream;
  pbt1, pbt2: PByte;
begin
  Result := False;

  AssignFile(f1, fname1);
  Reset(f1);
  sz1 := FileSize(f1);
  CloseFile(f1);

  AssignFile(f2, fname2);
  Reset(f2);
  sz2 := FileSize(f2);
  CloseFile(f2);

  if sz1 <> sz2 then
    Exit;

  m1 := TMemoryStream.Create;
  m2 := TMemoryStream.Create;

  m1.LoadFromFile(fname1);
  m2.LoadFromFile(fname2);

  pbt1 := m1.Memory;
  pbt2 := m2.Memory;

  Result := True;
  for I := 0 to m1.Size - 1 do
  begin
    if pbt1^ <> pbt2^ then
    begin
      Result := False;
      break;
    end;

    Inc(pbt1);
    Inc(pbt2);
  end;

  m1.Free;
  m2.Free;
end;

// ------------------ TTextLogRecoder -------------------

constructor TTextLogRecoder.Create(const fname: string);
begin
  inherited Create;

  FFile := TFileStream.Create(fname, fmCreate or fmShareDenyNone);
  FBufLen := 0;
end;

destructor TTextLogRecoder.Destroy;
begin
  FlushBuffer;
  FFile.Free;

  inherited;
end;

procedure TTextLogRecoder.AddLog(const txt: string);
const
  linereturn: Word = $0A0D;
var
  len: Integer;
begin
  if txt <> '' then
  begin
    len := Length(txt);
    if len + 2 + FBufLen <= log_buf_size then
    begin
      Move(txt[1], FBuf[FBufLen], len);
      Inc(FBufLen, len);
      FBuf[FBufLen] := 13;
      Inc(FBufLen);
      FBuf[FBufLen] := 10;
      Inc(FBufLen);
      Exit;
    end;

    FlushBuffer;

    if len + 2 + FBufLen <= log_buf_size then
    begin
      Move(txt[1], FBuf[FBufLen], len);
      Inc(FBufLen, len);
      FBuf[FBufLen] := 13;
      Inc(FBufLen);
      FBuf[FBufLen] := 10;
      Inc(FBufLen);
    end
    else begin
      FFile.Write(txt[1], len);
      FFile.Write(linereturn, 2);
    end;
  end;
end;

procedure TTextLogRecoder.FlushBuffer;
begin
  if FBufLen > 0 then
  begin
    FFile.Write(FBuf, FBufLen);
    FBufLen := 0;
  end;
end;


// ------------------ TPtrAnalyzer ---------------------

constructor TPtrAnalyzer.Create(aFixSize: Integer);
begin
  inherited Create;

  FFixSize := aFixSize;
end;

procedure TPtrAnalyzer.AddPtr(addr: Pointer; size: Integer);
var
  I, J: Integer;
begin
  if (FFixSize > 0) and (FFixSize > size) then
    Exit;

  if FLeakCount < max_ptr_num then
  begin
    Inc(FSerial);

    J := -1;
    if FUsedCount > FLeakCount then
    begin
      for I := 0 to FUsedCount - 1 do
      begin
        if not FData[I].used then
        begin
          J := I;
          break;
        end;
      end;
    end
    else begin
      J := FUsedCount;
      Inc(FUsedCount);
    end;

    if J <> -1 then
    begin
      FData[J].stamp := FCostStamp;
      FData[J].addr := addr;
      FData[J].size := size;
      FData[J].serial := FSerial;
      FData[J].used := True;
      Inc(FLeakCount);
      Inc(FTotal, size);
      FCostStamp := FCostStamp + size;
    end;
  end;
end;

procedure TPtrAnalyzer.DelPtr(addr: Pointer);
var
  I: Integer;
begin
  for I := 0 to FUsedCount - 1 do
  begin
    if FData[I].used and (FData[I].addr = addr) then
    begin
      FData[I].used := False;
      Dec(FLeakCount);
      Dec(FTotal, FData[I].size);
      Exit;
    end;
  end;
end;

function TPtrAnalyzer.MinSerial(var aGap, aMaxSize, aMinSize, aGcd: Integer): Integer;
var
  I: Integer;
  st: Int64;
begin
  Result := FSerial;
  aMaxSize := 0;
  aGcd := 0;
  aMinSize := 1024*1024;
  st := FCostStamp;
  for I := 0 to FUsedCount - 1 do
  begin
    if FData[I].used then
    begin
      aGcd := get_gcd(aGcd, FData[I].size);
      if FData[I].size > aMaxSize then
        aMaxSize := FData[I].size;

      if FData[I].size < aMinSize then
        aMinSize := FData[I].size;

      if (FData[I].serial < Result) then
      begin
        Result := FData[I].serial;
        st := FData[I].stamp;
      end;
    end;
  end;

  aGap := FCostStamp - st;
end;

procedure TPtrAnalyzer.OutputInfo(var txt: TextFile);
var
  inf: array[0..1023] of record
                           sz: Integer;
                           cnt: Integer;
                         end;
  data1, data2: string;
  I, J, ind: Integer;
begin
  FillChar(inf, sizeof(inf), 0);

  J := 0;
  for I := 0 to FUsedCount - 1 do
  begin
    if FData[I].used then
    begin
      if FData[I].size > J then
        J := FData[I].size;

      ind := (FData[I].size + 255) div 256;
      Inc(inf[ind].cnt);
    end;
  end;

  J := (J + 255) div 256;
  data1 := '';
  data2 := '';
  for I := 0 to J do
  begin
    data1 := data1 + Format('%.6d ', [I*256]);
    data2 := data2 + Format('%.6d ', [inf[I].cnt]);
  end;

  Writeln(txt, data1);
  Writeln(txt, data2);
end;


// ------------------ TMemoryStream2 -------------------

(*destructor TMemoryStream2.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TMemoryStream2.SetPointer(Ptr: Pointer; Size: Longint);
begin
  FMemory := Ptr;
  FSize := Size;
end;

function TMemoryStream2.Read(var Buffer; Count: Longint): Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := FSize - FPosition;
    if Result > 0 then
    begin
      if Result > Count then Result := Count;
      Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
      Inc(FPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;

function TMemoryStream2.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: Inc(FPosition, Offset);
    soFromEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

procedure TMemoryStream2.SaveToStream(Stream: TStream);
begin
  if FSize <> 0 then Stream.WriteBuffer(FMemory^, FSize);
end;

procedure TMemoryStream2.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStream2.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

procedure TMemoryStream2.LoadFromStream(Stream: TStream);
var
  Count: Longint;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then Stream.ReadBuffer(FMemory^, Count);
end;

procedure TMemoryStream2.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStream2.SetCapacity(NewCapacity: Longint);
begin
  SetPointer(Realloc(NewCapacity), FSize);
  FCapacity := NewCapacity;
end;

procedure TMemoryStream2.SetSize(NewSize: Longint);
var
  OldPosition: Longint;
begin
  OldPosition := FPosition;
  SetCapacity(NewSize);
  FSize := NewSize;
  if OldPosition > NewSize then Seek(0, soFromEnd);
end;

function TMemoryStream2.Realloc(var NewCapacity: Longint): Pointer;
const
  MemoryDelta = $2000; { Must be a power of 2 }
begin
  if (NewCapacity > 0) and (NewCapacity <> FSize) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
      FreeMem(Memory);
      Result := nil;
    end
    else begin
      if Capacity = 0 then
        GetMem(Result, NewCapacity)
      else
        ReallocMem(Result, NewCapacity);

      if Result = nil then
        raise Exception.Create('memstream2 out of memory');
    end;
  end;
end;

function TMemoryStream2.Write(const Buffer; Count: Longint): Longint;
var
  Pos: Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Pos := FPosition + Count;
    if Pos > 0 then
    begin
      if Pos > FSize then
      begin
        if Pos > FCapacity then
          SetCapacity(Pos);
        FSize := Pos;
      end;
      System.Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
      FPosition := Pos;
      Result := Count;
      Exit;
    end;
  end;
  Result := 0;
end;*)

end.
