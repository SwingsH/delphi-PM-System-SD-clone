unit TableModel;

interface

uses
  Classes, SysUtils, Grids,
  SQLConnecter, CommonSaveRecord;

type
  (********************************************************
   * 欄位 Interface, 切換各種欄位用的超型態 TMergeColumn / TColumn / TNullColumn
   * @Author Swings Huang
   * @Version 2010/03/23 v1.0
   ********************************************************)
  IColumnS  = interface
  ['{9C884CAB-BAD1-4859-9D6A-C41DC14C22AF}']
    function GetData(aIndex:Integer):rColumnEx;
    function GetName(aIndex: Integer): String;
    function GetCount: Integer;
    procedure Add(const aRSet:TRecordSet );
    property Name[aIndex: Integer]:String read GetName;  // 欄位名稱
    property Count: Integer read GetCount ;              // 欄位總數
    property Data[aIndex:Integer]:rColumnEx read GetData;
  end;

  (********************************************************
   * 欄位子表 + 總表 Column 用的 class
   ********************************************************)
  TNullColumn = class(TInterfacedObject, IColumnS)
  private
    mData: array of rColumnEx;
    mCount: Integer;
    function GetName(aIndex: Integer): string;
    function GetCount: Integer;
    function GetData(aIndex:Integer):rColumnEx;
  public
    destructor Destroy; override;
    procedure Add(const aRSet:TRecordSet );
    property Name[aIndex: Integer]:String read GetName;
    property Count: Integer read GetCount;
    property Data[aIndex:Integer]:rColumnEx read GetData;
  end;

  (********************************************************
   * [子表欄位]資料型態 TColumn
   * @Author Swings Huang
   * @Version 2010/03/23 v1.0
   ********************************************************)
  TColumnS = class(TInterfacedObject,IColumnS)
  private
    mData: array of rColumnEx ;
    mCount: Integer;
    function GetName(aIndex: Integer): String;
    function GetCount: Integer;
    function GetData(aIndex:Integer):rColumnEx;
  public
    destructor Destroy; override;
    procedure Add(const aRSet:TRecordSet );
    property Name[aIndex: Integer]:String read GetName;
    property Count: Integer read GetCount;
    property Data[aIndex:Integer]:rColumnEx read GetData;
  end;

  (********************************************************
   * [總表欄位]資料型態 MergeColumn
   * @Author Swings Huang
   * @Version 2010/03/23 v1.0
   ********************************************************)
  TMergeColumnS= class(TInterfacedObject,IColumnS)
  private
    mData: array of rColumnEx;
    mCount: Integer;
    function GetName(aIndex: Integer): String;
    function GetCount: Integer;
    function GetData(aIndex:Integer):rColumnEx;
  public
    destructor Destroy; override;
    procedure Add(const aRSet:TRecordSet );
    property Name[aIndex: Integer]:String read GetName;
    property Count: Integer read GetCount;
    property Data[aIndex:Integer]:rColumnEx read GetData;
  end;

  TGridData = class  //Grid型態(基本資料儲存型態，待改)
  private
    mTimeStamp: string;   //記錄該Grid的最新時間
    mValue: String;       //記錄該Grid的值
    mColType: string;     //記錄該Grid的型態
    mParentColID: Integer;//記錄該Grid所屬的欄位ID
    mRowID: Integer;      //記錄該Grid所屬的列ID  S.H:Add

    //property Getters and Setters
    procedure SetmTimeStamp(const Value: string);
    function GetmTimeStamp: string;
  public
    constructor Create(const aTime, aValue, aColType: string;                   // S.H Add: 新增 Row 資訊, 待 CB 修改
                       const aColID, aRowID: Integer);
    destructor Destroy; override;

    property TimeStamp: string read GetmTimeStamp write SetmTimeStamp;
    property Value: string read mValue write mValue;
    property ColType: string read mColType write mColType;
    property ParentColID: Integer read mParentColID write mParentColID;
    property RowID: Integer read mRowID write mRowID;                           // S.H Add: 新增 Row 資訊, 待 CB 修改
  end;

  TTableRow = class  //列型態
  private
    mColumns: array of TGridData;  //數個Grid組成一列

    //property Getters and Setters
    function GetColNums: Integer;
    function GetmColumns(aIndex: Integer): TGridData;
    procedure SetmColumns(aIndex: Integer; const Value: TGridData);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddGrid(const aGrid: TGridData);  //新增欄位資料

    //properties
    property Columns[aIndex: Integer]: TGridData read GetmColumns write SetmColumns;
    property ColNums: Integer read GetColNums;
  end;

  TTableModel = class  //表格型態
  private
    mRows: array of TTableRow;  //數個列組成一個表格
    mColumn  : IColumnS;        //記錄欄位資訊 S.H Add 0324
    mTableID: Integer;          //記錄表格ID
    mParentTableID: Integer;    //記錄所屬表格ID
    mColNums: Integer;          //記錄此表格的欄位數
    mLatestTime: string;        //記錄最新更新的時間(更新用)
    mTableTime: string;         //記錄最新欄位修改的時間(更新用)
    procedure Initial(const aTableID: Integer); virtual; abstract; //初始化函數，用來決定所產生的表格是總表或子表(只實作子表)
    procedure AddRow(const aRow: TTableRow);

    //property Getters and Setters
    function GetRowNums: Integer;
    function GetGridData(aCol, aRow: Integer): TGridData;
    procedure SetGridData(aCol, aRow: Integer; const Value: TGridData);
    procedure SetmLatestTime(const Value: string);
    procedure SetmTableTime(const Value: string);
    procedure SetColumnS(aColumn: IColumnS);  // S.H Add: 設置 Column的型態
    function GetmRows(aIndex: Integer): TTableRow;
  public
    constructor Create(const aMrgTableID, aTableID: Integer);
    destructor Destroy; override;

    //properties
    property Column: IColumnS read mColumn;
    property Row[aIndex: Integer]: TTableRow read GetmRows;
    property Cells[aCol: Integer; aRow: Integer]: TGridData read GetGridData write SetGridData;
    property LatestTime: string read mLatestTime write SetmLatestTime;
    property TableTime: string read mTableTime write SetmTableTime;
    property TableID: Integer read mTableID;
    property ParentTableID: Integer read mParentTableID;
    property RowNums: Integer read GetRowNums;
    property ColNums: Integer read mColNums;
  end;

  TNullTable = class(TTableModel)  //空物件
  private
    procedure Initial(const aTableID: Integer); override;
  public
    constructor Create(const aMrgTableID, aTableID: Integer);
    destructor Destroy; override;
  end;

  TSubTable = class(TTableModel)  //子表
  private
    procedure Initial(const aTableID: Integer); override;
  public
    constructor Create(const aMrgTableID, aTableID: Integer);
    destructor Destroy; override;
  end;

  TMrgTable = class(TTableModel)  //總表，只存結構，不存值
  private
    procedure Initial(const aTableID: Integer); override;
  public
    constructor Create(const aMrgTableID, aTableID: Integer); // MrgTable 不 care table id 因為會有很多個..
    destructor Destroy; override;
  end;

  TSearchNode = class  //搜尋用的簡單類別
  private
    mKeyWord: string;
    mColumnID: Integer;
    mResults: TStringList;  //列號, 對應 TableModel 的 mRow
  public
    constructor Create(const aKeyWord: string = ''; const aColumnID: Integer = 0);
    destructor Destroy; override;

    property KeyWord: string read mKeyWord write mKeyWord;
    property ColumnID: Integer read mColumnID write mColumnID;
    property Results: TStringList read mResults;
  end;

  TSearchTable = class(TTableModel)  //搜尋用的表格
  private
    mKeyWords: TList;  //關鍵字列表，儲存TSearchNode類別

    procedure Initial(const aTableID: Integer); override;
    procedure Searching(const aKeyWord: string; const aColumnID: Integer);
  public
    constructor Create(const aMrgTableID, aTableID: Integer);  //SearchTable只記錄目前搜尋的結果
    destructor Destroy; override;

    procedure AddKeyWord(const aKeyWord: string; const aColumnID: Integer);  //將關鍵字加入關鍵字列表

    property KeyWords: TList read mKeyWords;
  end;

  TTableManager = class
  private
    mSubTables: array of TTableModel;  //所有檢視過的子表表格
    mMrgTables: array of TTableModel;  //所有檢視過的總表表格
    mCurrentMrgTableID: Integer;       //目前選到的總表
    mCurrentTableID: Integer;          //目前正在檢視的表格ID

    procedure AddTable(const aMrgTableID, aTableID: Integer);               //新增表格
    procedure AddMrgTable(const aMrgTableID, aTableID: Integer);   //新增總和表格 , aMrgTableID = TableID, MrgTable 不 care table id 因為會有很多個.
    procedure ReCreateTable(const aTableID: Integer);  //在原本Table的位置上重新建立該Table

    //property Getters and Setters
    function GetmTables(aTableID: Integer): TTableModel;
    function GetmMrgTables(aTableID: Integer): TTableModel;
    function GetTableNum: Integer;
    function GetMrgTableNum: Integer;
    procedure SetmCurrentTableID(const Value: Integer);
    function GetCurrentTable: TTableModel;
    procedure SetmCurrentMrgTableID(const Value: Integer);
    function GetCurrentMrgTable: TTableModel;
  public
    constructor Create;
    destructor Destroy; override;

    procedure UpdateTable;  //只更新檢視中的表格

    //properties
    property Tables[aTableID: Integer]: TTableModel read GetmTables;
    property MrgTables[aTableID: Integer]: TTableModel read GetmMrgTables;
    property CurrentTable: TTableModel read GetCurrentTable;
    property CurrentMrgTable: TTableModel read GetCurrentMrgTable;
    property TableNums: Integer read GetTableNum;
    property MrgTableNums: Integer read GetMrgTableNum;
    property CurrentMrgTableID: Integer read mCurrentMrgTableID write SetmCurrentMrgTableID;
    property CurrentTableID: Integer read mCurrentTableID write SetmCurrentTableID;
  end;

  function TransStrToDateTime(const aStr: string): TDateTime;  //將時間的字串轉換成TDateTime
  function TransDateTimeToStr(const aTime: TDateTime): string; //將TDateTime轉換成時間的字串

implementation

uses
  Dialogs,
  DBManager, GridCtrl, Main, TableControlPanel, StrUtils;

{ TGridData }

constructor TGridData.Create(const aTime, aValue, aColType: string; const aColID: Integer; const aRowID: Integer);
begin
  mTimeStamp := gDBManager.ConvertBig5Datetime(aTime);  //時間儲存格式為 2010-03-01 10:40:30
  mValue := aValue;                                     //欄位上的值
  mColType := aColType;
  mParentColID := aColID;
  mRowID := aRowID; 
end;

destructor TGridData.Destroy;
begin
  mTimeStamp := '';
  mValue := '';

  inherited;
end;

function TGridData.GetmTimeStamp: string;
begin
  result := mTimeStamp;
end;

procedure TGridData.SetmTimeStamp(const Value: string);
var
  vTmpValue: string;
begin
  vTmpValue := gDBManager.ConvertBig5Datetime(Value);  //將傳入的時間字串做轉換

  if (vTmpValue <> mTimeStamp) then
    mTimeStamp := vTmpValue;
end;

{ TTableRow }

procedure TTableRow.AddGrid(const aGrid: TGridData);
begin
  SetLength(mColumns, ColNums + 1);  //將原本的長度增加
  mColumns[ColNums - 1] := aGrid;    //設定最後一個元素為aGrid
end;

constructor TTableRow.Create;
begin
  SetLength(mColumns, 0);
end;

destructor TTableRow.Destroy;
var
  i: Integer;
begin
  if ColNums <> 0 then
  begin
    for i := 0 to ColNums - 1 do
      FreeAndNil(mColumns[i]);

    mColumns := nil;
  end;

  inherited;
end;

function TTableRow.GetColNums: Integer;
begin
  result := Length(mColumns);
end;

function TTableRow.GetmColumns(aIndex: Integer): TGridData;
begin
  result := TGridData.Create('', '', '', 0, 0);

  if (aIndex < 0) or (aIndex > ColNums - 1) then
    exit;

  if mColumns[aIndex] = nil then
    exit
  else
    result := mColumns[aIndex];
end;

procedure TTableRow.SetmColumns(aIndex: Integer; const Value: TGridData);
begin
  if (aIndex < 0) or (aIndex > ColNums - 1) then
    exit;

  if mColumns[aIndex] = nil then
  begin
    {$ifdef Debug}
    ShowMessage(Format('SetmColumns mColumns[%d] is nil', [aIndex]));
    {$endif}
    exit;
  end;
    
  if not ((Value.TimeStamp = mColumns[aIndex].TimeStamp) and
          (Value.Value = mColumns[aIndex].Value)) then
    mColumns[aIndex] := Value;
end;

{ TTableModel }

procedure TTableModel.AddRow(const aRow: TTableRow);
begin
  SetLength(mRows, RowNums + 1);
  mRows[RowNums - 1] := aRow;
end;

constructor TTableModel.Create(const aMrgTableID, aTableID: Integer);
begin
  SetLength(mRows, 0);
  //mColNames := TStringList.Create;
  mTableID := 0;
  mColNums := 0;
  mLatestTime := '';
  mTableTime := '';
  mParentTableID := aMrgTableID;

  Initial(aTableID);  //建立表格的內容
end;

destructor TTableModel.Destroy;
var
  i: Integer;
begin
  if RowNums <> 0 then
  begin
    for i := 0 to RowNums - 1 do
      FreeAndNil(mRows[i]);

    mRows := nil;
  end;

  //FreeAndNil(mColNames);

  mTableID := 0;
  mColNums := 0;
  mLatestTime := '';

  inherited;
end;

function TTableModel.GetGridData(aCol, aRow: Integer): TGridData;
begin
  result := TGridData.Create('', '', '', 0, 0);

  if (aCol < 0) or (aCol >= ColNums) then  //Cells[j, i]的index比照Grid的index
    exit;
  if (aRow < 0) or (aRow >= RowNums) then  //Cells[j, i]的index比照Grid的index
    exit;

  if mRows[aRow ].Columns[aCol] = nil then  //實際取資料時index從0開始
    exit
  else
    result := mRows[aRow].Columns[aCol];
end;

function TTableModel.GetmRows(aIndex: Integer): TTableRow;
begin
  result := TTableRow.Create;
  result.AddGrid(TGridData.Create('', '', '', 0, 0));

  if (aIndex < 0) or (aIndex > RowNums - 1) then
    exit;

  if mRows[aIndex] = nil then
    exit
  else
  begin
    FreeAndNil(result);
    result := mRows[aIndex];
  end;
end;

function TTableModel.GetRowNums: Integer;
begin
  result := Length(mRows);
end;

procedure TTableModel.SetColumnS(aColumn: IColumnS);
begin
  mColumn := aColumn;
end;

procedure TTableModel.SetGridData(aCol, aRow: Integer;
  const Value: TGridData);
begin
  if (aCol < 0) or (aCol > ColNums) then
    exit;
  if (aRow < 0) or (aRow > RowNums) then
    exit;

  if mRows[aRow - 1].Columns[aCol - 1] = nil then
  begin
    {$ifdef Debug}
    ShowMessage(Format('SetGridData mRows[%d - 1].Columns[%d - 1] is nil', [aRow, aCol]));
    {$endif}
    exit;
  end;

  mRows[aRow - 1].Columns[aCol - 1] := Value;
end;

function TransStrToDateTime(const aStr: string): TDateTime;
begin
  result := 0;

  if aStr = '' then
    exit;

  try
    result := StrToDateTime(StringReplace(aStr, '-', DateSeparator, [rfReplaceAll]));
  except
    exit;
  end;
end;

function TransDateTimeToStr(const aTime: TDateTime): string;
begin
  result := '';

  try
    result := gDBManager.ConvertBig5Datetime(DateTimeToStr(aTime));
  except
    exit;
  end;
end;

procedure TTableModel.SetmLatestTime(const Value: string);
var
  vTmpValue: string;
begin
  vTmpValue := gDBManager.ConvertBig5Datetime(Value);  //將傳入的時間字串做轉換

  if (vTmpValue <> mLatestTime) then
    mLatestTime := vTmpValue;
end;

procedure TTableModel.SetmTableTime(const Value: string);
var
  vTmpValue: string;
begin
  vTmpValue := gDBManager.ConvertBig5Datetime(Value);  //將傳入的時間字串做轉換

  if (vTmpValue <> mTableTime) then
    mTableTime := vTmpValue;
end;

{ TTableManager }

procedure TTableManager.AddMrgTable(const aMrgTableID, aTableID: Integer);
begin
  SetLength(mMrgTables, MrgTableNums + 1);
  mMrgTables[MrgTableNums - 1] := TMrgTable.Create(aMrgTableID, aTableID);
end;

procedure TTableManager.AddTable(const aMrgTableID, aTableID: Integer);
begin
  SetLength(mSubTables, TableNums + 1);
  mSubTables[TableNums - 1] := TSubTable.Create(aMrgTableID, aTableID);

  // 設置 mrgtable
  CurrentMrgTableID:= aMrgTableID;
end;

constructor TTableManager.Create;
begin
  SetLength(mSubTables, 0);
  mCurrentTableID := 0;
end;

destructor TTableManager.Destroy;
var
  i: Integer;
begin
  if TableNums <> 0 then
  begin
    for i := 0 to TableNums - 1 do
      FreeAndNil(mSubTables[i]);

    mSubTables := nil;
  end;

  mCurrentTableID := 0;

  inherited;
end;

function TTableManager.GetCurrentTable: TTableModel;
begin
  result := Tables[mCurrentTableID];
end;

function TTableManager.GetCurrentMrgTable: TTableModel;
begin
  result := MrgTables[mCurrentMrgTableID];
end;

function TTableManager.GetmTables(aTableID: Integer): TTableModel;
var
  i: Integer;
begin
  result := TNullTable.Create(0, 0);

  for i := 0 to TableNums - 1 do
  begin
    if mSubTables[i].TableID = aTableID then
    begin
      result := mSubTables[i];
      break;
    end;
  end;
end;

function TTableManager.GetmMrgTables(aTableID: Integer): TTableModel;
var
  i: Integer;
begin
  result := TNullTable.Create(0, 0);

  for i := 0 to MrgTableNums - 1 do
  begin
    if mMrgTables[i].TableID = aTableID then
    begin
      result := mMrgTables[i];
      break;
    end;
  end;
end;

function TTableManager.GetTableNum: Integer;
begin
  result := Length(mSubTables);
end;


function TTableManager.GetMrgTableNum: Integer;
begin
  result := Length(mMrgTables);
end;

procedure TTableManager.ReCreateTable(const aTableID: Integer);
var
  i: Integer;
begin
  try
    for i := 0 to TableNums - 1 do
    begin
      if mSubTables[i].TableID = aTableID then
      begin
        FreeAndNil(mSubTables[i]);  //將原本的資料刪除
        mSubTables[i] := TSubTable.Create(mCurrentMrgTableID, aTableID);
      end;
    end;
  except
    on E : Exception do
      ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;
end;

procedure TTableManager.SetmCurrentMrgTableID(const Value: Integer);
begin
  if Value <> 0 then  //表格ID不為0，才可建立新表格
  begin
    if MrgTables[Value].TableID = 0 then  //目前尚無此總表格內容
      AddMrgTable(Value,Value);           //建立新總表, 總表無須子表 ID
  end;

  if Value <> mCurrentMrgTableID then
    mCurrentMrgTableID := Value;
end;

procedure TTableManager.SetmCurrentTableID(const Value: Integer);
begin
  if Value <> 0 then  //表格ID不為0，才可建立新表格
  begin
    if Tables[Value].TableID = 0 then  //目前尚無此表格內容
      AddTable(mCurrentMrgTableID, Value);
  end;

  if Value <> mCurrentTableID then
    mCurrentTableID := Value;
end;

(*******************************************************
 * TODO: 總表更新模式問題, 總表更新, 其餘對應的 N個子表也要更新, 因此後續再做。
 *******************************************************)
procedure TTableManager.UpdateTable;
var
  vTmpData, vTimeSet: TRecordSet;
  vCol, vRow: Integer;
  i: Integer;
begin
  try
    if mCurrentTableID = 0 then  //尚無檢視的表格，不需要更新
      exit;

    vTimeSet := gDBManager.DBTest_GetTableUpdateTime(mCurrentTableID, CurrentTable.TableTime);  //取得表格欄位最後修改的資料

    if vTimeSet.RowNums <> 0 then  //若欄位被修改過，需要重新建立表格內容
    begin
      ReCreateTable(mCurrentTableID);       //重新建立表格內容
      GridManage.SetTable(mCurrentTableID); //重新輸出表格內容
      exit;
    end;

    vTmpData := gDBManager.DBTest_ForUpdateUse;  //取得columnvalue更新資料

    if vTmpData.RowNums = 0 then  //目前無較新資料，不需更新
      exit;

    if (vTmpData.RowNums <> Tables[mCurrentTableID].RowNums) then  //新增或是刪除數筆資料
    begin
      ReCreateTable(mCurrentTableID);  //重新建立表格內容
    end
    else
    begin
      for i := 0 to vTmpData.RowNums - 1 do
      begin
        vCol := StrToInt(vTmpData.Row[i, 'column_id']);
        vRow := StrToInt(vTmpData.Row[i, 'column_row_id']);

        if (vCol > Tables[mCurrentTableID].ColNums) then
        begin
          ReCreateTable(mCurrentTableID);  //當範圍超過原本的範圍時，表示有新增數筆資料或是新增欄位(此為緩兵之計)
          break;
        end;

        Tables[mCurrentTableID].Cells[vCol - 1, vRow - 1].TimeStamp := vTmpData.Row[i, 'datetime'];
        Tables[mCurrentTableID].Cells[vCol - 1, vRow - 1].Value := vTmpData.Row[i, 'value'];

        if TransStrToDateTime(Tables[mCurrentTableID].LatestTime) < TransStrToDateTime(vTmpData.Row[i, 'datetime']) then
          Tables[mCurrentTableID].LatestTime := vTmpData.Row[i, 'datetime'];
      end;
    end;

    GridManage.SetTable(mCurrentTableID);
  except
    on E : Exception do
      ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;  
end;

{ TSubTable }

constructor TSubTable.Create(const aMrgTableID, aTableID: Integer);
begin
  SetColumnS(TColumnS.Create);  // 建立子表的 Column型態
  inherited;
end;

destructor TSubTable.Destroy;
begin
  mColumn := nil;
  inherited;
end;

procedure TSubTable.Initial(const aTableID: Integer);
var
  i: Integer;
  vRowNum: Integer;
  vValueSet, vColSet, vTimeSet: TRecordSet;
  vTmpRow: TTableRow;
begin
  vColSet := gDBManager.GetInfoByTableID(aTableID);    //取出表單欄位資料

  if (vColSet.RowNums = 0) or (vColSet = nil) then   //表示無此tableID或無資料
  begin
    ShowMessage(Format('Cannot find Table ID = %d !!', [aTableID]));
    exit;
  end;

  vTimeSet := gDBManager.GetTable(aTableID);

  if vTimeSet.RowNums <> 0 then
  begin
    if TransStrToDateTime(gDBManager.ConvertBig5Datetime(vTimeSet.Row[0, 'table_update_time'])) >= TransStrToDateTime(mTableTime) then
      mTableTime := gDBManager.ConvertBig5Datetime(vTimeSet.Row[0, 'table_update_time']);
  end
  else  //若無資料表示DB端搜不到此aTableID的資料
    exit;

  mTableID := aTableID;         //記錄目前要建立的表格ID
  mColNums := vColSet.RowNums;  //記錄欄位數量

  mColumn.Add(vColSet); // S.H Add

  vValueSet := gDBManager.GetTable_ColumnvalueS(mTableID);  //取出表單資料

  if vValueSet.RowNums = 0 then
  begin
{$ifdef Debug}
    ShowMessage(Format('Table has no data !! (ID = %d)', [mTableID]));
{$endif}
    exit;
  end;

  vTmpRow := TTableRow.Create;   //建立一列

  for i := 0 to vValueSet.RowNums - 1 do
  begin
    vRowNum := StrToInt(vValueSet.Row[i, 'column_row_id']);

    vTmpRow.AddGrid(TGridData.Create(vValueSet.Row[i, 'datetime'],   //加入Grid的資料
                                     vValueSet.Row[i, 'value'],
                                     vColSet.Row[i mod mColNums, 'mergecolumn_type'],
                                     StrToIntDef(vColSet.Row[i mod mColNums, 'mergecolumn_id'], i mod mColNums),
                                     StrToIntDef(vValueSet.Row[i, 'column_row_id'],0)));  // S.H Add: 新增 Row 資訊

    if TransStrToDateTime(vValueSet.Row[i, 'datetime']) >= TransStrToDateTime(mLatestTime) then  //採高水位標記法記錄最新時間
      mLatestTime := gDBManager.ConvertBig5Datetime(vValueSet.Row[i, 'datetime']);

    if (i + 1) < vValueSet.RowNums then
    begin
      if (vRowNum <> StrToInt(vValueSet.Row[i + 1, 'column_row_id'])) then  //若RowNums 與 column_row_id 不同，就表示該換行了
      begin
        AddRow(vTmpRow);                 //將資料加到mRows
        vTmpRow := TTableRow.Create;     //建立新的一列
      end;
    end
    else
      AddRow(vTmpRow);                 //將資料加到mRows
  end;

  FreeAndNil(vValueSet);
  FreeAndNil(vColSet);
end;

{ TMergeColumnS }

procedure TMergeColumnS.Add(const aRSet: TRecordSet);
var
  i: Integer;
begin
  SetLength(mData, aRSet.RowNums);
  mCount:=aRSet.RowNums;
  
  for i:=0 to aRSet.RowNums-1 do
  begin
    mData[i].TableID      := StrToIntDef(aRSet.Row[i, 'mergetable_id'],0);
    mData[i].ColumnID     := StrToIntDef(aRSet.Row[i, 'mergecolumn_id'],0);
    mData[i].ColumnName   := aRSet.Row[i, 'column_name'];
    mData[i].ColumnDesc   := aRSet.Row[i, 'column_description'];
    mData[i].CreateUserID := StrToIntDef(aRSet.Row[i, 'mergecolumn_create_user_id'],0);
    mData[i].CreateTime   := aRSet.Row[i, 'mergecolumn_create_time'];
    mData[i].Priority     := StrToIntDef(aRSet.Row[i, 'mergecolumn_priority'],0);
    mData[i].ColumnType   := aRSet.Row[i, 'mergecolumn_type'];
    mData[i].TypeSet      := aRSet.Row[i, 'mergecolumn_typeset'];
    mData[i].Width        := StrToIntDef(aRSet.Row[i, 'column_width'],0);
    mData[i].Height       := StrToIntDef(aRSet.Row[i, 'column_height'],0);
    (** Extra, merge 的部份, 不需要用到, 資料與上面是一樣的*)
    mData[i].MTableID     := StrToIntDef(aRSet.Row[i, 'mergetable_id'],0);
    mData[i].MColumnID    := StrToIntDef(aRSet.Row[i, 'mergecolumn_id'],0);
    mData[i].PositionID   := StrToIntDef(aRSet.Row[i, 'mergecolumn_position_id'],0);
  end;
end;

destructor TMergeColumnS.Destroy;
begin
  fillchar(mData, sizeof(mData), 0);
end;

function TMergeColumnS.GetCount: Integer;
begin
  result:= mCount;
end;

function TMergeColumnS.GetData(aIndex: Integer): rColumnEx;
begin
  fillchar(result,sizeof(result),0);
  if (aIndex > mCount-1) or(aIndex<0)then
    exit;
  result:= mData[aIndex];
end;

function TMergeColumnS.GetName(aIndex: Integer): String;
begin
  result:= '';
  if aIndex > Length(mData)-1 then
    exit;

  result:= mData[aIndex].ColumnName;
end;

{ TColumnS }

procedure TColumnS.Add(const aRSet: TRecordSet);
var
  i: Integer;
begin
  SetLength(mData, aRSet.RowNums);
  mCount:=aRSet.RowNums;

  for i:=0 to aRSet.RowNums-1 do
  begin
    mData[i].TableID      := StrToIntDef(aRSet.Row[i, 'table_id'],0);
    mData[i].ColumnID     := StrToIntDef(aRSet.Row[i, 'column_id'],0);
    mData[i].ColumnName   := aRSet.Row[i, 'column_name'];
    mData[i].ColumnDesc   := aRSet.Row[i, 'column_description'];
    mData[i].CreateUserID := StrToIntDef(aRSet.Row[i, 'column_create_user_id'],0);
    mData[i].CreateTime   := aRSet.Row[i, 'column_create_time'];
    mData[i].Priority     := StrToIntDef(aRSet.Row[i, 'column_priority'],0);
    mData[i].ColumnType   := aRSet.Row[i, 'column_type'];
    mData[i].TypeSet      := aRSet.Row[i, 'column_typeset'];
    mData[i].Width        := StrToIntDef(aRSet.Row[i, 'column_width'],0);
    mData[i].Height       := StrToIntDef(aRSet.Row[i, 'column_height'],0);
    (** Extra, 檢查 merge 的部份, 避免資料出錯 *)
    if aRSet.ColumnExist('mergetable_id') then
      mData[i].MTableID     := StrToIntDef(aRSet.Row[i, 'mergetable_id'],0);
    if aRSet.ColumnExist('mergecolumn_id') then
      mData[i].MColumnID    := StrToIntDef(aRSet.Row[i, 'mergecolumn_id'],0);
    if aRSet.ColumnExist('mergecolumn_position_id') then
      mData[i].PositionID   := StrToIntDef(aRSet.Row[i, 'mergecolumn_position_id'],0);
  end;
end;

destructor TColumnS.Destroy;
begin
  fillchar(mData, sizeof(mData), 0);
end;

function TColumnS.GetCount: Integer;
begin
  result:= mCount;
end;

function TColumnS.GetData(aIndex: Integer): rColumnEx;
begin
  fillchar(result,sizeof(result),0);
  if (aIndex > mCount-1)or(aIndex<0)then
    exit;
  result:= mData[aIndex];
end;

function TColumnS.GetName(aIndex: Integer): String;
begin
  result:= '';
  if aIndex > Length(mData)-1 then
    exit;

  result:= mData[aIndex].ColumnName;
end;

{ TNullTable }

constructor TNullTable.Create(const aMrgTableID, aTableID: Integer);
begin
  SetColumnS(TNullColumn.Create);  // 建立子表的 Column型態
  inherited;
end;

destructor TNullTable.Destroy;
begin
  mColumn := nil;
  inherited;
end;

procedure TNullTable.Initial(const aTableID: Integer);
var
  vRow: TTableRow;
begin
  vRow := TTableRow.Create;

  vRow.AddGrid(TGridData.Create('', '', '', 0, 0));
  mColNums := 1;

  AddRow(vRow);
end;

{ TNullColumn }

procedure TNullColumn.Add(const aRSet: TRecordSet);
begin
  SetLength(mData, 1);
  mCount := 1;

  fillChar(mData[0], Sizeof(rColumnEx), 0);
end;

destructor TNullColumn.Destroy;
begin
  fillchar(mData, sizeof(mData), 0);
  
  inherited;
end;

function TNullColumn.GetCount: Integer;
begin
  result := mCount;
end;

function TNullColumn.GetData(aIndex: Integer): rColumnEx;
begin
  result := mData[0]; 
end;

function TNullColumn.GetName(aIndex: Integer): string;
begin
  result:= '';
end;

{ TMrgTable }

constructor TMrgTable.Create(const aMrgTableID, aTableID: Integer);
begin
  SetColumnS(TMergeColumnS.Create);
  inherited;
end;

destructor TMrgTable.Destroy;
begin
  mColumn := nil;
  inherited;
end;

procedure TMrgTable.Initial(const aTableID: Integer);
var
  vColSet: TRecordSet;
begin
  vColSet := gDBManager.GetMergeTable_ColumnS(aTableID);  //取出表單欄位資料

  if (vColSet.RowNums = 0) or (vColSet = nil) then   //表示無此tableID或無資料
  begin
    ShowMessage(Format('Cannot find Table ID = %d !!', [aTableID]));
    exit;
  end;

  mTableID := aTableID;         //記錄目前要建立的表格ID
  mColNums := vColSet.RowNums;  //記錄欄位數量

  mColumn.Add(vColSet);

  FreeAndNil(vColSet);
end;

{ TSearchTable }

procedure TSearchTable.AddKeyWord(const aKeyWord: string; const aColumnID: Integer);
var
  i: Integer;
  vTmp: TSearchNode;
begin
  vTmp := TSearchNode.Create(aKeyWord, aColumnID);

  if aColumnID > ColNums - 1 then  //表格欄位不符
    exit;

  if mKeyWords.Count = 0 then
    mKeyWords.Add(vTmp)
  else
  begin
    for i := 0 to mKeyWords.Count - 1 do
    begin
      if TSearchNode(mKeyWords.Items[i]).mColumnID = aColumnID then  //判斷同一欄位是否已有其他關鍵字
      begin
        if TSearchNode(mKeyWords.Items[i]).mKeyWord = aKeyWord then   //相同關鍵字，不予搜尋，離開此次搜尋
          exit
        else      //不同關鍵字
        begin
          TSearchNode(mKeyWords.Items[i]).mKeyWord := aKeyWord;
          TSearchNode(mKeyWords.Items[i]).Results.Clear;  //清空之前的搜尋結果
          break;  //跳出迴圈
        end
      end
      else
      begin
        mKeyWords.Add(vTmp);
        break;
      end;
    end;
  end;

  Searching(aKeyWord, aColumnID);
end;

constructor TSearchTable.Create(const aMrgTableID, aTableID: Integer);
begin
  inherited;
end;

destructor TSearchTable.Destroy;
var
  i: Integer;
begin
  for i := 0 to mKeyWords.Count - 1 do
    TSearchNode(mKeyWords.Items[i]).Free;

  mKeyWords.Clear;

  FreeAndNil(mKeyWords);

  inherited;
end;

procedure TSearchTable.Initial(const aTableID: Integer);
var
  i, j: Integer;
  vRow: TTableRow;
  vTmpGrid: TGridData;
begin
  mKeyWords := TList.Create;
  mTableID := GridManage.TableManager.Tables[aTableID].TableID; //SearchTable不向DB要資料，從cache端取得TableID(以cache做search)

  SetColumnS(GridManage.TableManager.Tables[aTableID].Column);  // 建立子表的 Column型態

  mColNums := GridManage.TableManager.Tables[aTableID].ColNums;

  for i := 0 to GridManage.TableManager.Tables[aTableID].RowNums - 1 do  //此處為TableModel對TableModel的複製，因此index與外部存取不同
  begin
    vRow := TTableRow.Create;

    for j := 0 to GridManage.TableManager.Tables[aTableID].ColNums - 1 do
    begin
      vTmpGrid := GridManage.TableManager.Tables[aTableID].Cells[j, i];
      vRow.AddGrid(TGridData.Create(vTmpGrid.TimeStamp, vTmpGrid.Value, vTmpGrid.ColType, vTmpGrid.ParentColID, vTmpGrid.RowID));
    end;

    AddRow(vRow);
  end;
end;

procedure TSearchTable.Searching(const aKeyWord: string; const aColumnID: Integer);
var
  i: Integer;
  vRow: Integer;
begin
  if mKeyWords.Count = 1 then  //尚無搜尋過，因為KeyWords剛加入
  begin
    for i := cFirstRowCount to (RowNums + cFirstRowCount - 1) do   //搜尋對象為全部
    begin
      if AnsiContainsText(Cells[aColumnID, i - cFirstRowCount].Value, aKeyWord) then  //aColumnID已經直接對應TableModel，所以不需再轉換
        TSearchNode(mKeyWords.Items[0]).Results.Add(IntToStr(i - cFirstRowCount));    //加入列號(實際對應TableModel)
    end;
  end
  else  //已經搜尋過
  begin
    for i := 1 to TSearchNode(mKeyWords.Items[mKeyWords.Count - 2]).Results.Count do  //搜尋對象為前一次搜尋結果
    begin
      vRow := StrToInt(TSearchNode(mKeyWords.Items[mKeyWords.Count - 2]).Results.Strings[i - 1]);  //前一次加入的列號，已經直接對應TableModel，所以不需再轉換

      if AnsiContainsText(Cells[aColumnID, vRow].Value, aKeyWord) then  //aColumnID已經直接對應TableModel，所以不需再轉換
        TSearchNode(mKeyWords.Last).Results.Add(IntToStr(vRow));  //加入列號
    end;
  end;
end;

{ TSearchNode }

constructor TSearchNode.Create(const aKeyWord: string;
  const aColumnID: Integer);
begin
  mKeyWord := aKeyWord;
  mColumnID := aColumnID;
  mResults := TStringList.Create;
end;

destructor TSearchNode.Destroy;
begin
  inherited;
end;

end.
