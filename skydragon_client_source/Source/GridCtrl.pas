{$I define.h}
unit GridCtrl;

interface

uses
  SQLConnecter, TableModel, Grids, Classes, StdCtrls, Types, HTMLHint, Controls,Math;
const
  cFirstColCount = 1;  //實際資料在 Grid view元件上的的起始欄號,0為灰色名稱區
  cFirstRowCount = 2;  //實際資料在 Grid view元件上的的起始列號,0為灰色列號區,1為搜索用下拉式選單區

type
  IMapDataOut = Interface
  ['{6AD02418-003B-423F-987E-A03864228495}']
    procedure MapDataToView;
  end;

  TMapNothingOut = class(TInterfacedObject, IMapDataOut)  //預設的輸出模式(空物件)
  public
    procedure MapDataToView;
  end;

  TMapDefaultDataToGrid = class(TInterfacedObject, IMapDataOut)  //輸出預設資料到StringGrid
  private
    mView: TStringGrid;
    mModel: TTableModel;
  public
    constructor Create(const aView: TStringGrid; const aModel: TTableModel);
    destructor Destroy; override;

    procedure MapDataToView;
  end;

  TMapSearchDataToGrid = class(TInterfacedObject, IMapDataOut)  //輸出篩選資料到StringGrid
  private
    mView: TStringGrid;
    mModel: TSearchTable;
  public
    constructor Create(const aView: TStringGrid; const aModel: TSearchTable);
    destructor Destroy; override;

    procedure MapDataToView;
  end;
  
  (**************************************************************************
   * 管理並儲存會在 StringGrid 上出現的 ComboBox。 ComboBox的描繪與建立在 GridDrawCell中實作。
   * @Author Swings Huang
   * @Version 2010/04/16 v1.0
   *************************************************************************)
  TGridComboboxManage=class(TObject)
    mItemS: array of TCombobox;    /// idx 相同, combobox 的 reference
    mCol  : array of Integer;      /// idx 相同, 欄號
    mRow  : array of Integer;      /// idx 相同, 列號
    mChanged: array of Boolean;    /// idx 相同, 標示 combobox 是否需要重新調整位置的 flag
    mParent :TStringGrid;
  private
    function GetItemS(aCol,aRow: Integer): TCombobox;                   /// 依照欄列號取得 combobox, 若無則顯示 nil
    procedure SetChanged(aB:Boolean);
    function GetChanged: Boolean;
    function GetItemChanged(aCol, aRow: Integer): Boolean;
    procedure SetItemChanged(aCol, aRow: Integer; const Value: Boolean);
    procedure SetItemS(aCol, aRow: Integer; const Value: TCombobox);
  public
    constructor Create(aParent:TStringGrid);
    procedure Clear;
    function RegisterItem(aCol,aRow:Integer):TCombobox;     /// 新增一個 Combobox item
    function  Exist(aCol,aRow:Integer):Boolean;             /// 偵測 col, row 欄位是否有 combobox
    function IsLastItem(aCol,aRow:Integer):Boolean;         /// 以 col, row 判斷該元素是否是最後加入的 combobox
    (** Event **)
    procedure OnComboBoxExit(Sender:TObject);
    property ItemS[aCol,aRow:Integer]: TCombobox read GetItemS write SetItemS;
    property Changed: Boolean read GetChanged write SetChanged;
    property ItemChanged[aCol,aRow:Integer]: Boolean read GetItemChanged write SetItemChanged;
  end;

  (**************************************************************************
   * 管理在 StringGrid 上出現的 Hint。
   * @Author Swings Huang
   * @Version 2010/04/16 v1.0
   *************************************************************************)
  TGridHintManage=class(TObject)
  private
    mHint      : THTMLHint;
    mParent    : TStringGrid;
    mCurrentCol: Integer;
    mCurrentRow: Integer;
  public
    constructor Create(aParent:TStringGrid);
    destructor Destroy;override;
    procedure Initialize;
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState;  /// 將 Viewer的 event轉介給 Grid, 避免 event無法正常觸發
                          X, Y: Integer);
    procedure ShowHint(aGridCol,aGridRow:Integer);
  end;

  //表格助手
  TGridManage = class
  private
    mGrid: TStringGrid;
    mLockCols: Integer;            //鎖定列數
    mTableManager: TTableManager;  //表格資料
    mGridComboManage: TGridComboboxManage;   //StringGrid 上出現的 ComboBox 管理器
    mGridHintManage : TGridHintManage;
    mSearchTable: TSearchTable;    //搜尋時的表格資料

    mIsSelect: Boolean;  //是否在條件篩選中
    mSelectStr: String;  //篩選中字串

    mIsMrg: Boolean;     //是否是總表
    mIsFixMode: Boolean; //是否為修改模式
    mIsLock: Boolean;    //是否要鎖定表格

    mDataShower: IMapDataOut;   //資料輸出器

    procedure SetmIsFixMode(const Value: Boolean);
    procedure SetmIsLock(const Value: Boolean);
    procedure SetmLockCols(const Value: Integer);
    procedure SetmDataShower(const Value: IMapDataOut);
    function GetDataCellS(aCol, aRow: Integer): TGridData; /// 輸入 View(StringGrid) 的 Col, Row, 取得 Data層的 Col, Row 
    function GetColNum: Integer;
    function GetRowNum: Integer;
    function GetGridColNum: Integer;
    function GetGridRowNum: Integer;
  public
    constructor Create(aGrid:TStringGrid);
    destructor Destroy; override;
    procedure Initialize;
    procedure Update;
    function ContentLength(const aStr: string): Integer;  //取得aStr在表格中的長度
    procedure GridLocking(const aLockColNum: integer);  //鎖定表格
    procedure SetTableTitle(const aTitle: string);      //設定表格標題
    procedure ClearGrid;                                //清除表格內容
    procedure SetTable(aTableID: Integer);                //輸出資料
    procedure SelectNeed(aCol, aRow: Integer); overload;           //篩選
    procedure SelectNeed(aCol: Integer; aStr: String ); overload;  //篩選
    (** event: 操作觸發*)
    procedure TriggerGridEdit(aGridCol, aGridRow: Integer);  /// 開始表格編輯。 TODO: 後續改版, Grid 自己應該要知道何處 Col,Row被點擊
    procedure TriggerGridDelete(aGridCol,aGridRow: Integer); /// 開始表格刪除[列]。 TODO: 後續改版, Grid 自己應該要知道何處 Col,Row被點擊
    procedure TriggerGridCancelSearch;                       /// 取消表格搜索。 TODO: 後續改版, Grid 自己應該要知道何處 Col,Row被點擊
    (** event*)
    procedure OnGridMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure OnGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
                                 MousePos: TPoint; var Handled: Boolean);
    procedure OnGridMouseWheelDown(Sender: TObject; Shift: TShiftState;
                                   MousePos: TPoint; var Handled: Boolean);
    (** 資料存取區*)                               
    property ColNum: Integer read GetColNum;
    property RowNum: Integer read GetRowNum;
    property GridColNum: Integer read GetGridColNum;
    property GridRowNum: Integer read GetGridRowNum;
    property LockCols: Integer read mLockCols write SetmLockCols;

    property TableManager: TTableManager read mTableManager;
    property DataShower: IMapDataOut read mDataShower write SetmDataShower;

    property IsSelect: Boolean read mIsSelect write mIsSelect;
    property SelectStr: String read mSelectStr;
    property IsMrg: Boolean read mIsMrg;
    property IsFixMode: Boolean read mIsFixMode write SetmIsFixMode;
    property IsLock: Boolean read mIsLock write SetmIsLock;
    property DataCellS[aCol: Integer; aRow: Integer]:TGridData read GetDataCellS;
    property GridComboManage: TGridComboboxManage read mGridComboManage;
  end;

var
  GridManage: TGridManage;

implementation

uses
  (** SkyDragon *)
  TableEditor, TableHandler, Const_Template,
  (** Delphi *)
  StateCtrl, DBManager, Main, SysUtils, Dialogs;

{ TGridManage }

procedure TGridManage.ClearGrid;
var
  i, j: Integer;
begin
  for i := 0 to MainForm.Grid.RowCount - 1 do
  begin
    for j := 0 to MainForm.Grid.ColCount - 1 do
      MainForm.Grid.Cells[j, i] := '';
  end;

  MainForm.Grid.RowCount := 2;
  MainForm.Grid.ColCount := 2;
  GridManage.LockCols := 0;
end;

function TGridManage.ContentLength(const aStr: string): Integer;
var
  vLabel, vMaxLengthLabel: TLabel;
begin
  //利用TLabel的自動大小方式來取得長度
  vLabel := TLabel.Create(nil);
  vMaxLengthLabel := TLabel.Create(nil);

  vLabel.Caption := ' ' + aStr + ' ';
  vMaxLengthLabel.Caption := ' ' + '基本上一個欄位不超過這些字' + ' ';

  if vLabel.Width >= vMaxLengthLabel.Width then
    result := vMaxLengthLabel.Width
  else
    result := vLabel.Width;

  FreeAndNil(vLabel);
  FreeAndNil(vMaxLengthLabel);
end;

constructor TGridManage.Create(aGrid:TStringGrid);
begin
  mGrid:= aGrid;
  mTableManager := TTableManager.Create;
  mGridComboManage:= TGridComboboxManage.Create(MainForm.Grid);
  mGridHintManage := TGridHintManage.Create(MainForm.Grid);
  mDataShower := TMapNothingOut.Create;
  mIsFixMode := false;
  mLockCols := 0;
  Initialize;
end;

destructor TGridManage.Destroy;
begin
  FreeAndNil(mTableManager);
  FreeAndNil(mSearchTable);
  mDataShower := nil;

  inherited;
end;

function TGridManage.GetColNum: Integer;
begin
  result := mTableManager.CurrentTable.ColNums;
end;

function TGridManage.GetDataCellS(aCol, aRow: Integer): TGridData;
var
  vSearchRowNum, vModelRow, vModelCol: Integer;
begin
  result := TGridData.Create('', '', '', 0, 0);
  
  if not mIsSelect then
    result:= mTableManager.CurrentTable.Cells[aCol - cFirstColCount, aRow - cFirstRowCount]
  else  // Search模式下 (資料)Cells[j, i]的index 並非比照 (顯示)Grid的index, 需經過轉換
  begin
    inherited;
    aCol:= aCol - cFirstColCount;
    aRow:= aRow - cFirstRowCount;

    vSearchRowNum:= TSearchNode(mSearchTable.KeyWords.Last).Results.Count;
    if (aCol < 0) or (aCol >= mSearchTable.ColNums) and
       (aRow < 0) or (aRow >= vSearchRowNum) then
      exit;

    vModelRow:= StrToInt(TSearchNode(mSearchTable.KeyWords.Last).Results.Strings[aRow]);
    vModelCol:= aCol;

    result:= mSearchTable.Cells[vModelCol, vModelRow];
  end;
end;

function TGridManage.GetGridColNum: Integer;
begin
  result:= MainForm.Grid.ColCount;
end;

function TGridManage.GetRowNum: Integer;
begin
  result := mTableManager.CurrentTable.RowNums;
end;

function TGridManage.GetGridRowNum: Integer;
begin
  result:= MainForm.Grid.RowCount;
end;

procedure TGridManage.GridLocking(const aLockColNum: integer);
begin
  if (GridManage.IsLock) then  //若選擇凍結視窗
  begin
    if aLockColNum + 1 < MainForm.Grid.ColCount then
      MainForm.Grid.FixedCols := aLockColNum + 1 //設定固定欄位
    else if aLockColNum + 1 = MainForm.Grid.ColCount then
      MainForm.Grid.FixedCols := aLockColNum
    else
      MainForm.Grid.FixedCols := 1;
  end
  else                         //若取消選擇
    MainForm.Grid.FixedCols := 1;  //設回預設
end;

procedure TGridManage.SelectNeed(aCol, aRow: Integer);
begin
  if (aCol <= 0) or (aRow <= 0) then  //選到列數或是欄位名稱均離開
    exit;

  mIsSelect := True;  //條件篩選中    mGridComboManage.Changed:= true;   // flag 欄寬可能改變
  mGridComboManage.Changed:= true;   // flag 欄寬可能改變
  
  if (mSearchTable <> nil) then
  begin
    if (mSearchTable.TableID <> mTableManager.CurrentTableID) then
    begin
      FreeAndNil(mSearchTable);
      mSearchTable := TSearchTable.Create(mTableManager.CurrentMrgTable.TableID, mTableManager.CurrentTable.TableID);
    end;
  end
  else
    mSearchTable := TSearchTable.Create(mTableManager.CurrentMrgTable.TableID, mTableManager.CurrentTable.TableID);

  mSelectStr := MainForm.Grid.Cells[aCol, aRow];
  mSearchTable.AddKeyWord(mSelectStr, aCol - cFirstColCount);  //此處傳入的參數aColumnID以TableModel為主

  SetTable(mSearchTable.TableID);
end;

procedure TGridManage.SelectNeed(aCol: Integer; aStr: String);
begin
  if (aCol <= 0) then  //選到列數或是欄位名稱均離開
    exit;

  mIsSelect := True;  //條件篩選中
  mGridComboManage.Changed:= true;   // flag 欄寬可能改變
  
  if (mSearchTable <> nil) then
  begin
    if (mSearchTable.TableID <> mTableManager.CurrentTableID) then
    begin
      FreeAndNil(mSearchTable);
      mSearchTable := TSearchTable.Create(mTableManager.CurrentMrgTable.TableID, mTableManager.CurrentTable.TableID);
    end;
  end
  else
    mSearchTable := TSearchTable.Create(mTableManager.CurrentMrgTable.TableID, mTableManager.CurrentTable.TableID);

  mSearchTable.AddKeyWord(aStr, aCol - cFirstColCount);  //此處傳入的參數aColumnID以TableModel為主

  SetTable(mSearchTable.TableID);
end;

procedure TGridManage.SetmDataShower(const Value: IMapDataOut);
begin
  mDataShower := Value;
end;

procedure TGridManage.SetmIsFixMode(const Value: Boolean);
begin
  if Value <> mIsFixMode then
    mIsFixMode := Value;
end;

procedure TGridManage.SetmIsLock(const Value: Boolean);
begin
  if Value <> mIsLock then
    mIsLock := Value;
end;

procedure TGridManage.SetmLockCols(const Value: Integer);
begin
  if (Value >= 1) and (Value <= MainForm.Grid.ColCount) then
  begin
    if Value <> mLockCols then
      mLockCols := Value;
  end;
end;

procedure TGridManage.SetTable(aTableID: Integer);
begin
  MainForm.AddNewBtn.Enabled := true;

  if not mIsSelect then
  begin
    mDataShower := TMapDefaultDataToGrid.Create(MainForm.Grid, mTableManager.CurrentTable);
  end
  else
  begin
    mDataShower := TMapSearchDataToGrid.Create(MainForm.Grid, mSearchTable);
  end;

  mDataShower.MapDataToView;
end;

procedure TGridManage.SetTableTitle(const aTitle: string);
begin
  MainForm.Grid.Cells[0, 0] := aTitle;
end;

procedure TGridManage.TriggerGridCancelSearch;
begin
  mIsSelect := False;
  mSelectStr := '';
  FreeAndNil(mSearchTable);
  SetTable(mTableManager.CurrentTableID);
  GridManage.GridComboManage.Clear;
end;

procedure TGridManage.TriggerGridDelete(aGridCol,aGridRow: Integer);
var
  vMRowID, vMTableID: Integer;
begin
  vMRowID   := DataCells[aGridCol,aGridRow].RowID;   /// Grid RowID 轉換成 DB RowID
  vMTableID := GridManage.TableManager.CurrentMrgTableID;

  if vMRowID <= 0 then
    exit;

  gMergeTableHandler.DeleteRow(vMTableID, vMRowID);  /// TODO: GridManage 待刪
end;

procedure TGridManage.TriggerGridEdit(aGridCol, aGridRow: Integer);
var
  vMRowID, vMColID: Integer;
  vValue: String;
begin
  if aGridCol <= 0 then    // 點到邊緣的灰色欄位 or 沒點到任何欄位
    exit;
  if aGridRow <= 0 then
    exit;

  vMRowID   := DataCells[aGridCol,aGridRow].RowID;   /// S.H Add 待 CB 修改
  vMColID   := DataCells[aGridCol,aGridRow].ParentColID;

  if vMRowID <= 0 then
    exit;
  if vMColID <= 0 then
    exit;
    
  vValue    := DataCells[aGridCol,aGridRow].Value;
  gTableEditor.TriggerShow(GridManage.TableManager.CurrentMrgTable.Column, vValue,
                           vMColID, vMRowID);
end;

procedure TGridManage.Update;
begin
  mTableManager.UpdateTable;  //檢查表格更新
end;

procedure TGridManage.OnGridMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  vGridCol, vGridRow: Integer;
  vRect: TRect;
begin
  mGrid.MouseToCell(X, Y, vGridCol, vGridRow);  //取得滑鼠所在欄列
  mGridHintManage.ShowHint(vGridCol, vGridRow);
end;

procedure TGridManage.Initialize;
begin
  if mGrid=nil then
    exit;
  mGrid.OnMouseMove:= OnGridMouseMove;
  mGrid.OnMouseWheelDown:= OnGridMouseWheelDown;
  mGrid.OnMouseWheelUp  := OnGridMouseWheelUp;
end;

procedure TGridManage.OnGridMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  mGridHintManage.mHint.Hide;    // wheel中避免殘像, 取消 hint
end;

procedure TGridManage.OnGridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  mGridHintManage.mHint.Hide;    // wheel中避免殘像, 取消 hint
end;

{ TMapNothingOut }

procedure TMapNothingOut.MapDataToView;
begin
  //do nothing!
end;

{ TMapDefaultDataToGrid }

constructor TMapDefaultDataToGrid.Create(const aView: TStringGrid;
  const aModel: TTableModel);
begin
  mView := aView;
  mModel := aModel;
end;

destructor TMapDefaultDataToGrid.Destroy;
begin
  inherited;
end;

procedure TMapDefaultDataToGrid.MapDataToView;
var
  i, j: Integer;
  vLen: Integer;
begin
  try
    mView.FixedCols := 1;
    mView.FixedRows := 1;

    if mModel.ColNums <> 0 then
      mView.ColCount := mModel.ColNums + cFirstColCount  //加上最左欄
    else
      mView.ColCount := cFirstColCount+1;

    if mModel.RowNums <> 0 then
      mView.RowCount := mModel.RowNums + cFirstRowCount  //加上最上列
    else
      mView.RowCount := cFirstRowCount+1;

    for i:=cFirstColCount to (mModel.Column.Count+cFirstColCount)-1 do    // S.H Mod: for ColumnClass 0324
    begin
      vLen := GridManage.ContentLength(mModel.Column.Name[i - 1]);        // S.H Mod: for ColumnClass 0324
      mView.ColWidths[i] := vLen;
      mView.Cols[i].Text := mModel.Column.Name[i - 1];  // S.H Mod: for ColumnClass 0324
    end;

    for i := cFirstRowCount to (mModel.RowNums+cFirstRowCount)-1 do  //加入列號
      mView.Cells[0, i] := IntToStr(i-cFirstRowCount+1);
  except
    ShowMessage(Format('wrong in SetTable with Value ColCount, RowCount, FixedCols, FixedRows: %d, %d, %d, %d',
                       [mView.ColCount, mView.RowCount,
                        mView.FixedCols, mView.FixedRows]));
  end;

  try
  for i := cFirstRowCount to (mModel.RowNums + cFirstRowCount) - 1 do
  begin
    for j := cFirstColCount to (mModel.ColNums + cFirstColCount) - 1 do
    begin
      vLen := GridManage.ContentLength(mModel.Cells[j - cFirstColCount, i - cFirstRowCount].Value);

      if mView.ColWidths[j] < vLen then  //判斷表格欄寬是否需要調整
        mView.ColWidths[j] := vLen;

      mView.Cells[j, i] := mModel.Cells[j - cFirstColCount, i - cFirstRowCount].Value;  //此處的index比照TStringGrid
    end;
  end;
  except
    ShowMessage('Something wrong at TMapDefaultDataToGrid.MapDataToView(model output area)');
  end;
end;

{ TMapSearchDataToGrid }

constructor TMapSearchDataToGrid.Create(const aView: TStringGrid;
  const aModel: TSearchTable);
begin
  mView := aView;
  mModel := aModel;
end;

destructor TMapSearchDataToGrid.Destroy;
begin
  inherited;
end;

procedure TMapSearchDataToGrid.MapDataToView;
var
  i, j: Integer;
  vRow, vLen: Integer;
begin
  try
    mView.FixedCols := 1;
    mView.FixedRows := 1;

    if mModel.ColNums <> 0 then
      mView.ColCount := mModel.ColNums + cFirstColCount  //加上最左欄
    else
      mView.ColCount := 2;

    if TSearchNode(mModel.KeyWords.Last).Results.Count <> 0 then             //表示搜尋有結果
      mView.RowCount := TSearchNode(mModel.KeyWords.Last).Results.Count + cFirstRowCount  //加上最上列
    else
      mView.RowCount := 3;

    for i := cFirstColCount to (mModel.Column.Count + cFirstColCount - 1) do    //加入欄位名稱
    begin
      vLen := GridManage.ContentLength(mModel.Column.Name[i - 1]);  //計算欄寬
      mView.ColWidths[i] := vLen;
      mView.Cols[i].Text := mModel.Column.Name[i - 1];
    end;

    for i := cFirstRowCount to (TSearchNode(mModel.KeyWords.Last).Results.Count + cFirstRowCount - 1) do  //加入列號
      mView.Cells[0, i] := IntToStr(i-cFirstRowCount+1);

  except
    ShowMessage(Format('wrong in SetTable with Value ColCount, RowCount, FixedCols, FixedRows: %d, %d, %d, %d',
                       [mView.ColCount, mView.RowCount,
                        mView.FixedCols, mView.FixedRows]));
  end;

  if TSearchNode(mModel.KeyWords.Last).Results.Count <> 0 then  //表示搜尋有結果
  begin
    for i := cFirstRowCount to (TSearchNode(mModel.KeyWords.Last).Results.Count + cFirstRowCount - 1) do
    begin
      vRow := StrToInt(TSearchNode(mModel.KeyWords.Last).Results.Strings[i - cFirstRowCount]);  //vRow已直接對應TableModel，所以不需再轉換

      for j := cFirstColCount to (mModel.Column.Count + cFirstColCount - 1) do
      begin
        vLen := GridManage.ContentLength(mModel.Cells[j - cFirstColCount, vRow].Value);

        if mView.ColWidths[j] < vLen then  //判斷表格欄寬是否需要調整
          mView.ColWidths[j] := vLen;

        mView.Cells[j, i] := mModel.Cells[j - cFirstColCount, vRow].Value;
      end;
    end;
  end
  else
    mView.Cells[cFirstColCount, cFirstRowCount] := '';
end;

{ TGridComboboxManage }

procedure TGridComboboxManage.Clear;
var
  i:Integer;
begin
  for i:=0 to Length(mItemS)-1 do
  begin
    freeandnil(mItemS[i]);
  end;

  SetLength(mItemS,0);
  SetLength(mRow,0);
  SetLength(mCol,0);
end;

constructor TGridComboboxManage.Create(aParent:TStringGrid);
begin
  SetLength(mItemS,0);
  SetLength(mCol,0);
  SetLength(mRow,0);
  SetLength(mChanged,0);

  mParent:= aParent;
end;

function TGridComboboxManage.Exist(aCol, aRow: Integer): Boolean;
var
  vLength, i: Integer;
begin
  result:= false;
  
  vLength:= Length(mItemS);
  for i:=0 to vLength-1 do
    if (mCol[i] = aCol) and (mRow[i] = aRow) then
    begin
      result:= true;
      exit;
    end;
end;

function TGridComboboxManage.GetChanged: Boolean;
var
  vLength, i: Integer;
begin
  result:= false;
  
  vLength:= Length(mChanged);
  for i:=0 to vLength-1 do
    if mChanged[i] then
    begin
      result:= true;
      exit;
    end;
end;

function TGridComboboxManage.GetItemChanged(aCol, aRow: Integer): Boolean;
var
  vLength, i :Integer;
begin
  result:= false;
  
  vLength:= Length(mChanged);
  for i:=0 to vLength-1 do
    if (mCol[i] = aCol) and (mRow[i] = aRow) then
    begin
      result:= mChanged[i];
      exit;
    end;
end;

function TGridComboboxManage.GetItemS(aCol,aRow: Integer): TCombobox;
var
  vLength, i: Integer;
begin
  result:= nil;
  
  vLength:= Length(mItemS);
  for i:=0 to vLength-1 do
    if (mCol[i] = aCol) and (mRow[i] = aRow) then
    begin
      result:= mItemS[i];
      exit;
    end;
end;

function TGridComboboxManage.IsLastItem(aCol, aRow: Integer): Boolean;
begin
  result:= false;
  if (mCol[Length(mCol)-1] = aCol)and
     (mRow[Length(mRow)-1] = aRow)then
    result:= true; 
end;

procedure TGridComboboxManage.OnComboBoxExit(Sender: TObject);
var
  vCol:Integer;
  vSearchStr: String;
begin
  vCol:= TComboBox(Sender).Tag;
  vSearchStr:= TComboBox(Sender).Text;

  if vSearchStr <> '' then
    GridManage.SelectNeed(vCol, TComboBox(Sender).Text);  //依條件篩選
end;

function TGridComboboxManage.RegisterItem(aCol,aRow:Integer):TComboBox;
var
  vIdx: Integer;
begin
  vIdx:= Length(mItemS);
  SetLength(mItemS, vIdx+1);
  SetLength(mCol  , vIdx+1);
  SetLength(mRow  , vIdx+1);
  SetLength(mChanged, vIdx+1);

  mItemS[vIdx]:= TComboBox.Create(mParent);
  mItemS[vIdx].Parent  := mParent;
  mItemS[vIdx].Style   := csDropDown;
  mItemS[vIdx].OnExit  := self.OnComboBoxExit;   // Exit + Enter 的其他 event 無效, 原因待查
  mItemS[vIdx].Tag     := aCol;

  mCol[vIdx]  := aCol;
  mRow[vIdx]  := aRow;
  mChanged[vIdx]:= true;
  
  result:= mItemS[vIdx];
end;

procedure TGridComboboxManage.SetChanged(aB: Boolean);
var
  vLength, i: Integer;
begin
  vLength:= Length(mChanged);
  for i:=0 to vLength-1 do
    mChanged[i]:= aB;
end;

procedure TGridComboboxManage.SetItemChanged(aCol, aRow: Integer;
  const Value: Boolean);
var
  vLength, i :Integer;  
begin
  vLength:= Length(mChanged);
  for i:=0 to vLength-1 do
    if (mCol[i] = aCol) and (mRow[i] = aRow) then
    begin
      mChanged[i]:= Value;
      exit;
    end;
end;

procedure TGridComboboxManage.SetItemS(aCol, aRow: Integer;
  const Value: TCombobox);
var
  vLength, i: Integer;
begin
  vLength:= Length(mItemS);
  for i:=0 to vLength-1 do
    if (mCol[i] = aCol) and (mRow[i] = aRow) then
    begin
      mItemS[i]:= Value;
      exit;
    end;
end;

{ TGridHintManage }

constructor TGridHintManage.Create(aParent:TStringGrid);
begin
  mHint:= THTMLHint.Create(aParent);
  mParent:= aParent;
  mCurrentCol:= -1;
  mCurrentRow:= -1;
  Initialize;
end;

destructor TGridHintManage.Destroy;
begin
  freeandnil(mHint);
  inherited;
end;

procedure TGridHintManage.Initialize;
begin
  if mParent=nil then
  begin
{$ifdef Debug}
    ShowMessage('TGridHintManage.Initialize error !!');
{$endif}
    exit;
  end;
  mHint.Viewer.OnMouseMove:= Self.OnMouseMove;
  mHint.Hide;
end;

procedure TGridHintManage.OnMouseMove(Sender: TObject; Shift: TShiftState;X, Y: Integer);
var
  vRect: TRect;
begin
  // Hint 相對座標轉絕對座標
  vRect:=mParent.CellRect(mCurrentCol,mCurrentRow); // 取得現在 Grid 的座標

  mParent.OnMouseMove(Sender,Shift,X+vRect.Left, Y+vRect.Top);
end;

procedure TGridHintManage.ShowHint(aGridCol, aGridRow: Integer);
var
  vRect:TRect;
const
  cPadding=5;
begin
  if (aGridCol <cFirstColCount) or   //實際資料在 Grid view元件上的的起始欄號,0為灰色名稱區
     (aGridRow <cFirstRowCount) then  //實際資料在 Grid view元件上的的起始列號,0為灰色列號區,1為搜索用下拉式選單區
  begin
    mHint.Hide;
    exit;
  end;

  if (mCurrentCol=aGridCol) and (mCurrentRow=aGridRow) then   // 欄位沒有變動, 不用重新設置
    exit;

  mCurrentCol:= aGridCol;
  mCurrentRow:= aGridRow;

  vRect:=mParent.CellRect(aGridCol,aGridRow);

  //mHint.SetCoordinate(min((vRect.Left+vRect.Right) div 2,vRect.Left+20),vRect.Bottom);
  mHint.SetCoordinate(vRect.Left+cPadding,vRect.Bottom+cPadding);
  mHint.SetContent(Template_GridHint('00:','11',true));

  mHint.Show;
end;

end.
