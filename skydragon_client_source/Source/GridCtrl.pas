{$I define.h}
unit GridCtrl;

interface

uses
  SQLConnecter, TableModel, Grids, Classes, StdCtrls, Types, HTMLHint, Controls,Math;
const
  cFirstColCount = 1;  //��ڸ�Ʀb Grid view����W�����_�l�渹,0���Ǧ�W�ٰ�
  cFirstRowCount = 2;  //��ڸ�Ʀb Grid view����W�����_�l�C��,0���Ǧ�C����,1���j���ΤU�Ԧ�����

type
  IMapDataOut = Interface
  ['{6AD02418-003B-423F-987E-A03864228495}']
    procedure MapDataToView;
  end;

  TMapNothingOut = class(TInterfacedObject, IMapDataOut)  //�w�]����X�Ҧ�(�Ū���)
  public
    procedure MapDataToView;
  end;

  TMapDefaultDataToGrid = class(TInterfacedObject, IMapDataOut)  //��X�w�]��ƨ�StringGrid
  private
    mView: TStringGrid;
    mModel: TTableModel;
  public
    constructor Create(const aView: TStringGrid; const aModel: TTableModel);
    destructor Destroy; override;

    procedure MapDataToView;
  end;

  TMapSearchDataToGrid = class(TInterfacedObject, IMapDataOut)  //��X�z���ƨ�StringGrid
  private
    mView: TStringGrid;
    mModel: TSearchTable;
  public
    constructor Create(const aView: TStringGrid; const aModel: TSearchTable);
    destructor Destroy; override;

    procedure MapDataToView;
  end;
  
  (**************************************************************************
   * �޲z���x�s�|�b StringGrid �W�X�{�� ComboBox�C ComboBox���yø�P�إߦb GridDrawCell����@�C
   * @Author Swings Huang
   * @Version 2010/04/16 v1.0
   *************************************************************************)
  TGridComboboxManage=class(TObject)
    mItemS: array of TCombobox;    /// idx �ۦP, combobox �� reference
    mCol  : array of Integer;      /// idx �ۦP, �渹
    mRow  : array of Integer;      /// idx �ۦP, �C��
    mChanged: array of Boolean;    /// idx �ۦP, �Х� combobox �O�_�ݭn���s�վ��m�� flag
    mParent :TStringGrid;
  private
    function GetItemS(aCol,aRow: Integer): TCombobox;                   /// �̷���C�����o combobox, �Y�L�h��� nil
    procedure SetChanged(aB:Boolean);
    function GetChanged: Boolean;
    function GetItemChanged(aCol, aRow: Integer): Boolean;
    procedure SetItemChanged(aCol, aRow: Integer; const Value: Boolean);
    procedure SetItemS(aCol, aRow: Integer; const Value: TCombobox);
  public
    constructor Create(aParent:TStringGrid);
    procedure Clear;
    function RegisterItem(aCol,aRow:Integer):TCombobox;     /// �s�W�@�� Combobox item
    function  Exist(aCol,aRow:Integer):Boolean;             /// ���� col, row ���O�_�� combobox
    function IsLastItem(aCol,aRow:Integer):Boolean;         /// �H col, row �P�_�Ӥ����O�_�O�̫�[�J�� combobox
    (** Event **)
    procedure OnComboBoxExit(Sender:TObject);
    property ItemS[aCol,aRow:Integer]: TCombobox read GetItemS write SetItemS;
    property Changed: Boolean read GetChanged write SetChanged;
    property ItemChanged[aCol,aRow:Integer]: Boolean read GetItemChanged write SetItemChanged;
  end;

  (**************************************************************************
   * �޲z�b StringGrid �W�X�{�� Hint�C
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
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState;  /// �N Viewer�� event�श�� Grid, �קK event�L�k���`Ĳ�o
                          X, Y: Integer);
    procedure ShowHint(aGridCol,aGridRow:Integer);
  end;

  //���U��
  TGridManage = class
  private
    mGrid: TStringGrid;
    mLockCols: Integer;            //��w�C��
    mTableManager: TTableManager;  //�����
    mGridComboManage: TGridComboboxManage;   //StringGrid �W�X�{�� ComboBox �޲z��
    mGridHintManage : TGridHintManage;
    mSearchTable: TSearchTable;    //�j�M�ɪ������

    mIsSelect: Boolean;  //�O�_�b����z�襤
    mSelectStr: String;  //�z�襤�r��

    mIsMrg: Boolean;     //�O�_�O�`��
    mIsFixMode: Boolean; //�O�_���ק�Ҧ�
    mIsLock: Boolean;    //�O�_�n��w���

    mDataShower: IMapDataOut;   //��ƿ�X��

    procedure SetmIsFixMode(const Value: Boolean);
    procedure SetmIsLock(const Value: Boolean);
    procedure SetmLockCols(const Value: Integer);
    procedure SetmDataShower(const Value: IMapDataOut);
    function GetDataCellS(aCol, aRow: Integer): TGridData; /// ��J View(StringGrid) �� Col, Row, ���o Data�h�� Col, Row 
    function GetColNum: Integer;
    function GetRowNum: Integer;
    function GetGridColNum: Integer;
    function GetGridRowNum: Integer;
  public
    constructor Create(aGrid:TStringGrid);
    destructor Destroy; override;
    procedure Initialize;
    procedure Update;
    function ContentLength(const aStr: string): Integer;  //���oaStr�b��椤������
    procedure GridLocking(const aLockColNum: integer);  //��w���
    procedure SetTableTitle(const aTitle: string);      //�]�w�����D
    procedure ClearGrid;                                //�M����椺�e
    procedure SetTable(aTableID: Integer);                //��X���
    procedure SelectNeed(aCol, aRow: Integer); overload;           //�z��
    procedure SelectNeed(aCol: Integer; aStr: String ); overload;  //�z��
    (** event: �ާ@Ĳ�o*)
    procedure TriggerGridEdit(aGridCol, aGridRow: Integer);  /// �}�l���s��C TODO: ����睊, Grid �ۤv���ӭn���D��B Col,Row�Q�I��
    procedure TriggerGridDelete(aGridCol,aGridRow: Integer); /// �}�l���R��[�C]�C TODO: ����睊, Grid �ۤv���ӭn���D��B Col,Row�Q�I��
    procedure TriggerGridCancelSearch;                       /// �������j���C TODO: ����睊, Grid �ۤv���ӭn���D��B Col,Row�Q�I��
    (** event*)
    procedure OnGridMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure OnGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
                                 MousePos: TPoint; var Handled: Boolean);
    procedure OnGridMouseWheelDown(Sender: TObject; Shift: TShiftState;
                                   MousePos: TPoint; var Handled: Boolean);
    (** ��Ʀs����*)                               
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
  //�Q��TLabel���۰ʤj�p�覡�Ө��o����
  vLabel := TLabel.Create(nil);
  vMaxLengthLabel := TLabel.Create(nil);

  vLabel.Caption := ' ' + aStr + ' ';
  vMaxLengthLabel.Caption := ' ' + '�򥻤W�@����줣�W�L�o�Ǧr' + ' ';

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
  else  // Search�Ҧ��U (���)Cells[j, i]��index �ëD��� (���)Grid��index, �ݸg�L�ഫ
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
  if (GridManage.IsLock) then  //�Y��ܭᵲ����
  begin
    if aLockColNum + 1 < MainForm.Grid.ColCount then
      MainForm.Grid.FixedCols := aLockColNum + 1 //�]�w�T�w���
    else if aLockColNum + 1 = MainForm.Grid.ColCount then
      MainForm.Grid.FixedCols := aLockColNum
    else
      MainForm.Grid.FixedCols := 1;
  end
  else                         //�Y�������
    MainForm.Grid.FixedCols := 1;  //�]�^�w�]
end;

procedure TGridManage.SelectNeed(aCol, aRow: Integer);
begin
  if (aCol <= 0) or (aRow <= 0) then  //���C�ƩάO���W�٧����}
    exit;

  mIsSelect := True;  //����z�襤    mGridComboManage.Changed:= true;   // flag ��e�i�����
  mGridComboManage.Changed:= true;   // flag ��e�i�����
  
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
  mSearchTable.AddKeyWord(mSelectStr, aCol - cFirstColCount);  //���B�ǤJ���Ѽ�aColumnID�HTableModel���D

  SetTable(mSearchTable.TableID);
end;

procedure TGridManage.SelectNeed(aCol: Integer; aStr: String);
begin
  if (aCol <= 0) then  //���C�ƩάO���W�٧����}
    exit;

  mIsSelect := True;  //����z�襤
  mGridComboManage.Changed:= true;   // flag ��e�i�����
  
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

  mSearchTable.AddKeyWord(aStr, aCol - cFirstColCount);  //���B�ǤJ���Ѽ�aColumnID�HTableModel���D

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
  vMRowID   := DataCells[aGridCol,aGridRow].RowID;   /// Grid RowID �ഫ�� DB RowID
  vMTableID := GridManage.TableManager.CurrentMrgTableID;

  if vMRowID <= 0 then
    exit;

  gMergeTableHandler.DeleteRow(vMTableID, vMRowID);  /// TODO: GridManage �ݧR
end;

procedure TGridManage.TriggerGridEdit(aGridCol, aGridRow: Integer);
var
  vMRowID, vMColID: Integer;
  vValue: String;
begin
  if aGridCol <= 0 then    // �I����t���Ǧ���� or �S�I��������
    exit;
  if aGridRow <= 0 then
    exit;

  vMRowID   := DataCells[aGridCol,aGridRow].RowID;   /// S.H Add �� CB �ק�
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
  mTableManager.UpdateTable;  //�ˬd����s
end;

procedure TGridManage.OnGridMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  vGridCol, vGridRow: Integer;
  vRect: TRect;
begin
  mGrid.MouseToCell(X, Y, vGridCol, vGridRow);  //���o�ƹ��Ҧb��C
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
  mGridHintManage.mHint.Hide;    // wheel���קK�ݹ�, ���� hint
end;

procedure TGridManage.OnGridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  mGridHintManage.mHint.Hide;    // wheel���קK�ݹ�, ���� hint
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
      mView.ColCount := mModel.ColNums + cFirstColCount  //�[�W�̥���
    else
      mView.ColCount := cFirstColCount+1;

    if mModel.RowNums <> 0 then
      mView.RowCount := mModel.RowNums + cFirstRowCount  //�[�W�̤W�C
    else
      mView.RowCount := cFirstRowCount+1;

    for i:=cFirstColCount to (mModel.Column.Count+cFirstColCount)-1 do    // S.H Mod: for ColumnClass 0324
    begin
      vLen := GridManage.ContentLength(mModel.Column.Name[i - 1]);        // S.H Mod: for ColumnClass 0324
      mView.ColWidths[i] := vLen;
      mView.Cols[i].Text := mModel.Column.Name[i - 1];  // S.H Mod: for ColumnClass 0324
    end;

    for i := cFirstRowCount to (mModel.RowNums+cFirstRowCount)-1 do  //�[�J�C��
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

      if mView.ColWidths[j] < vLen then  //�P�_�����e�O�_�ݭn�վ�
        mView.ColWidths[j] := vLen;

      mView.Cells[j, i] := mModel.Cells[j - cFirstColCount, i - cFirstRowCount].Value;  //���B��index���TStringGrid
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
      mView.ColCount := mModel.ColNums + cFirstColCount  //�[�W�̥���
    else
      mView.ColCount := 2;

    if TSearchNode(mModel.KeyWords.Last).Results.Count <> 0 then             //��ܷj�M�����G
      mView.RowCount := TSearchNode(mModel.KeyWords.Last).Results.Count + cFirstRowCount  //�[�W�̤W�C
    else
      mView.RowCount := 3;

    for i := cFirstColCount to (mModel.Column.Count + cFirstColCount - 1) do    //�[�J���W��
    begin
      vLen := GridManage.ContentLength(mModel.Column.Name[i - 1]);  //�p����e
      mView.ColWidths[i] := vLen;
      mView.Cols[i].Text := mModel.Column.Name[i - 1];
    end;

    for i := cFirstRowCount to (TSearchNode(mModel.KeyWords.Last).Results.Count + cFirstRowCount - 1) do  //�[�J�C��
      mView.Cells[0, i] := IntToStr(i-cFirstRowCount+1);

  except
    ShowMessage(Format('wrong in SetTable with Value ColCount, RowCount, FixedCols, FixedRows: %d, %d, %d, %d',
                       [mView.ColCount, mView.RowCount,
                        mView.FixedCols, mView.FixedRows]));
  end;

  if TSearchNode(mModel.KeyWords.Last).Results.Count <> 0 then  //��ܷj�M�����G
  begin
    for i := cFirstRowCount to (TSearchNode(mModel.KeyWords.Last).Results.Count + cFirstRowCount - 1) do
    begin
      vRow := StrToInt(TSearchNode(mModel.KeyWords.Last).Results.Strings[i - cFirstRowCount]);  //vRow�w��������TableModel�A�ҥH���ݦA�ഫ

      for j := cFirstColCount to (mModel.Column.Count + cFirstColCount - 1) do
      begin
        vLen := GridManage.ContentLength(mModel.Cells[j - cFirstColCount, vRow].Value);

        if mView.ColWidths[j] < vLen then  //�P�_�����e�O�_�ݭn�վ�
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
    GridManage.SelectNeed(vCol, TComboBox(Sender).Text);  //�̱���z��
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
  mItemS[vIdx].OnExit  := self.OnComboBoxExit;   // Exit + Enter ����L event �L��, ��]�ݬd
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
  // Hint �۹�y���൴��y��
  vRect:=mParent.CellRect(mCurrentCol,mCurrentRow); // ���o�{�b Grid ���y��

  mParent.OnMouseMove(Sender,Shift,X+vRect.Left, Y+vRect.Top);
end;

procedure TGridHintManage.ShowHint(aGridCol, aGridRow: Integer);
var
  vRect:TRect;
const
  cPadding=5;
begin
  if (aGridCol <cFirstColCount) or   //��ڸ�Ʀb Grid view����W�����_�l�渹,0���Ǧ�W�ٰ�
     (aGridRow <cFirstRowCount) then  //��ڸ�Ʀb Grid view����W�����_�l�C��,0���Ǧ�C����,1���j���ΤU�Ԧ�����
  begin
    mHint.Hide;
    exit;
  end;

  if (mCurrentCol=aGridCol) and (mCurrentRow=aGridRow) then   // ���S���ܰ�, ���έ��s�]�m
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
