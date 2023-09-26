unit TableModel;

interface

uses
  Classes, SysUtils, Grids,
  SQLConnecter, CommonSaveRecord;

type
  (********************************************************
   * ��� Interface, �����U�����Ϊ��W���A TMergeColumn / TColumn / TNullColumn
   * @Author Swings Huang
   * @Version 2010/03/23 v1.0
   ********************************************************)
  IColumnS  = interface
  ['{9C884CAB-BAD1-4859-9D6A-C41DC14C22AF}']
    function GetData(aIndex:Integer):rColumnEx;
    function GetName(aIndex: Integer): String;
    function GetCount: Integer;
    procedure Add(const aRSet:TRecordSet );
    property Name[aIndex: Integer]:String read GetName;  // ���W��
    property Count: Integer read GetCount ;              // ����`��
    property Data[aIndex:Integer]:rColumnEx read GetData;
  end;

  (********************************************************
   * ���l�� + �`�� Column �Ϊ� class
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
   * [�l�����]��ƫ��A TColumn
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
   * [�`�����]��ƫ��A MergeColumn
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

  TGridData = class  //Grid���A(�򥻸���x�s���A�A�ݧ�)
  private
    mTimeStamp: string;   //�O����Grid���̷s�ɶ�
    mValue: String;       //�O����Grid����
    mColType: string;     //�O����Grid�����A
    mParentColID: Integer;//�O����Grid���ݪ����ID
    mRowID: Integer;      //�O����Grid���ݪ��CID  S.H:Add

    //property Getters and Setters
    procedure SetmTimeStamp(const Value: string);
    function GetmTimeStamp: string;
  public
    constructor Create(const aTime, aValue, aColType: string;                   // S.H Add: �s�W Row ��T, �� CB �ק�
                       const aColID, aRowID: Integer);
    destructor Destroy; override;

    property TimeStamp: string read GetmTimeStamp write SetmTimeStamp;
    property Value: string read mValue write mValue;
    property ColType: string read mColType write mColType;
    property ParentColID: Integer read mParentColID write mParentColID;
    property RowID: Integer read mRowID write mRowID;                           // S.H Add: �s�W Row ��T, �� CB �ק�
  end;

  TTableRow = class  //�C���A
  private
    mColumns: array of TGridData;  //�ƭ�Grid�զ��@�C

    //property Getters and Setters
    function GetColNums: Integer;
    function GetmColumns(aIndex: Integer): TGridData;
    procedure SetmColumns(aIndex: Integer; const Value: TGridData);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddGrid(const aGrid: TGridData);  //�s�W�����

    //properties
    property Columns[aIndex: Integer]: TGridData read GetmColumns write SetmColumns;
    property ColNums: Integer read GetColNums;
  end;

  TTableModel = class  //��櫬�A
  private
    mRows: array of TTableRow;  //�ƭӦC�զ��@�Ӫ��
    mColumn  : IColumnS;        //�O������T S.H Add 0324
    mTableID: Integer;          //�O�����ID
    mParentTableID: Integer;    //�O�����ݪ��ID
    mColNums: Integer;          //�O������檺����
    mLatestTime: string;        //�O���̷s��s���ɶ�(��s��)
    mTableTime: string;         //�O���̷s���ק諸�ɶ�(��s��)
    procedure Initial(const aTableID: Integer); virtual; abstract; //��l�ƨ�ơA�ΨӨM�w�Ҳ��ͪ����O�`��Τl��(�u��@�l��)
    procedure AddRow(const aRow: TTableRow);

    //property Getters and Setters
    function GetRowNums: Integer;
    function GetGridData(aCol, aRow: Integer): TGridData;
    procedure SetGridData(aCol, aRow: Integer; const Value: TGridData);
    procedure SetmLatestTime(const Value: string);
    procedure SetmTableTime(const Value: string);
    procedure SetColumnS(aColumn: IColumnS);  // S.H Add: �]�m Column�����A
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

  TNullTable = class(TTableModel)  //�Ū���
  private
    procedure Initial(const aTableID: Integer); override;
  public
    constructor Create(const aMrgTableID, aTableID: Integer);
    destructor Destroy; override;
  end;

  TSubTable = class(TTableModel)  //�l��
  private
    procedure Initial(const aTableID: Integer); override;
  public
    constructor Create(const aMrgTableID, aTableID: Integer);
    destructor Destroy; override;
  end;

  TMrgTable = class(TTableModel)  //�`��A�u�s���c�A���s��
  private
    procedure Initial(const aTableID: Integer); override;
  public
    constructor Create(const aMrgTableID, aTableID: Integer); // MrgTable �� care table id �]���|���ܦh��..
    destructor Destroy; override;
  end;

  TSearchNode = class  //�j�M�Ϊ�²�����O
  private
    mKeyWord: string;
    mColumnID: Integer;
    mResults: TStringList;  //�C��, ���� TableModel �� mRow
  public
    constructor Create(const aKeyWord: string = ''; const aColumnID: Integer = 0);
    destructor Destroy; override;

    property KeyWord: string read mKeyWord write mKeyWord;
    property ColumnID: Integer read mColumnID write mColumnID;
    property Results: TStringList read mResults;
  end;

  TSearchTable = class(TTableModel)  //�j�M�Ϊ����
  private
    mKeyWords: TList;  //����r�C��A�x�sTSearchNode���O

    procedure Initial(const aTableID: Integer); override;
    procedure Searching(const aKeyWord: string; const aColumnID: Integer);
  public
    constructor Create(const aMrgTableID, aTableID: Integer);  //SearchTable�u�O���ثe�j�M�����G
    destructor Destroy; override;

    procedure AddKeyWord(const aKeyWord: string; const aColumnID: Integer);  //�N����r�[�J����r�C��

    property KeyWords: TList read mKeyWords;
  end;

  TTableManager = class
  private
    mSubTables: array of TTableModel;  //�Ҧ��˵��L���l����
    mMrgTables: array of TTableModel;  //�Ҧ��˵��L���`����
    mCurrentMrgTableID: Integer;       //�ثe��쪺�`��
    mCurrentTableID: Integer;          //�ثe���b�˵������ID

    procedure AddTable(const aMrgTableID, aTableID: Integer);               //�s�W���
    procedure AddMrgTable(const aMrgTableID, aTableID: Integer);   //�s�W�`�M��� , aMrgTableID = TableID, MrgTable �� care table id �]���|���ܦh��.
    procedure ReCreateTable(const aTableID: Integer);  //�b�쥻Table����m�W���s�إ߸�Table

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

    procedure UpdateTable;  //�u��s�˵��������

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

  function TransStrToDateTime(const aStr: string): TDateTime;  //�N�ɶ����r���ഫ��TDateTime
  function TransDateTimeToStr(const aTime: TDateTime): string; //�NTDateTime�ഫ���ɶ����r��

implementation

uses
  Dialogs,
  DBManager, GridCtrl, Main, TableControlPanel, StrUtils;

{ TGridData }

constructor TGridData.Create(const aTime, aValue, aColType: string; const aColID: Integer; const aRowID: Integer);
begin
  mTimeStamp := gDBManager.ConvertBig5Datetime(aTime);  //�ɶ��x�s�榡�� 2010-03-01 10:40:30
  mValue := aValue;                                     //���W����
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
  vTmpValue := gDBManager.ConvertBig5Datetime(Value);  //�N�ǤJ���ɶ��r�갵�ഫ

  if (vTmpValue <> mTimeStamp) then
    mTimeStamp := vTmpValue;
end;

{ TTableRow }

procedure TTableRow.AddGrid(const aGrid: TGridData);
begin
  SetLength(mColumns, ColNums + 1);  //�N�쥻�����׼W�[
  mColumns[ColNums - 1] := aGrid;    //�]�w�̫�@�Ӥ�����aGrid
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

  Initial(aTableID);  //�إߪ�檺���e
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

  if (aCol < 0) or (aCol >= ColNums) then  //Cells[j, i]��index���Grid��index
    exit;
  if (aRow < 0) or (aRow >= RowNums) then  //Cells[j, i]��index���Grid��index
    exit;

  if mRows[aRow ].Columns[aCol] = nil then  //��ڨ���Ʈ�index�q0�}�l
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
  vTmpValue := gDBManager.ConvertBig5Datetime(Value);  //�N�ǤJ���ɶ��r�갵�ഫ

  if (vTmpValue <> mLatestTime) then
    mLatestTime := vTmpValue;
end;

procedure TTableModel.SetmTableTime(const Value: string);
var
  vTmpValue: string;
begin
  vTmpValue := gDBManager.ConvertBig5Datetime(Value);  //�N�ǤJ���ɶ��r�갵�ഫ

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

  // �]�m mrgtable
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
        FreeAndNil(mSubTables[i]);  //�N�쥻����ƧR��
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
  if Value <> 0 then  //���ID����0�A�~�i�إ߷s���
  begin
    if MrgTables[Value].TableID = 0 then  //�ثe�|�L���`��椺�e
      AddMrgTable(Value,Value);           //�إ߷s�`��, �`��L���l�� ID
  end;

  if Value <> mCurrentMrgTableID then
    mCurrentMrgTableID := Value;
end;

procedure TTableManager.SetmCurrentTableID(const Value: Integer);
begin
  if Value <> 0 then  //���ID����0�A�~�i�إ߷s���
  begin
    if Tables[Value].TableID = 0 then  //�ثe�|�L����椺�e
      AddTable(mCurrentMrgTableID, Value);
  end;

  if Value <> mCurrentTableID then
    mCurrentTableID := Value;
end;

(*******************************************************
 * TODO: �`���s�Ҧ����D, �`���s, ��l������ N�Ӥl��]�n��s, �]������A���C
 *******************************************************)
procedure TTableManager.UpdateTable;
var
  vTmpData, vTimeSet: TRecordSet;
  vCol, vRow: Integer;
  i: Integer;
begin
  try
    if mCurrentTableID = 0 then  //�|�L�˵������A���ݭn��s
      exit;

    vTimeSet := gDBManager.DBTest_GetTableUpdateTime(mCurrentTableID, CurrentTable.TableTime);  //���o������̫�ק諸���

    if vTimeSet.RowNums <> 0 then  //�Y���Q�ק�L�A�ݭn���s�إߪ�椺�e
    begin
      ReCreateTable(mCurrentTableID);       //���s�إߪ�椺�e
      GridManage.SetTable(mCurrentTableID); //���s��X��椺�e
      exit;
    end;

    vTmpData := gDBManager.DBTest_ForUpdateUse;  //���ocolumnvalue��s���

    if vTmpData.RowNums = 0 then  //�ثe�L���s��ơA���ݧ�s
      exit;

    if (vTmpData.RowNums <> Tables[mCurrentTableID].RowNums) then  //�s�W�άO�R���Ƶ����
    begin
      ReCreateTable(mCurrentTableID);  //���s�إߪ�椺�e
    end
    else
    begin
      for i := 0 to vTmpData.RowNums - 1 do
      begin
        vCol := StrToInt(vTmpData.Row[i, 'column_id']);
        vRow := StrToInt(vTmpData.Row[i, 'column_row_id']);

        if (vCol > Tables[mCurrentTableID].ColNums) then
        begin
          ReCreateTable(mCurrentTableID);  //��d��W�L�쥻���d��ɡA��ܦ��s�W�Ƶ���ƩάO�s�W���(�����w�L���p)
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
  SetColumnS(TColumnS.Create);  // �إߤl�� Column���A
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
  vColSet := gDBManager.GetInfoByTableID(aTableID);    //���X��������

  if (vColSet.RowNums = 0) or (vColSet = nil) then   //��ܵL��tableID�εL���
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
  else  //�Y�L��ƪ��DB�ݷj���즹aTableID�����
    exit;

  mTableID := aTableID;         //�O���ثe�n�إߪ����ID
  mColNums := vColSet.RowNums;  //�O�����ƶq

  mColumn.Add(vColSet); // S.H Add

  vValueSet := gDBManager.GetTable_ColumnvalueS(mTableID);  //���X�����

  if vValueSet.RowNums = 0 then
  begin
{$ifdef Debug}
    ShowMessage(Format('Table has no data !! (ID = %d)', [mTableID]));
{$endif}
    exit;
  end;

  vTmpRow := TTableRow.Create;   //�إߤ@�C

  for i := 0 to vValueSet.RowNums - 1 do
  begin
    vRowNum := StrToInt(vValueSet.Row[i, 'column_row_id']);

    vTmpRow.AddGrid(TGridData.Create(vValueSet.Row[i, 'datetime'],   //�[�JGrid�����
                                     vValueSet.Row[i, 'value'],
                                     vColSet.Row[i mod mColNums, 'mergecolumn_type'],
                                     StrToIntDef(vColSet.Row[i mod mColNums, 'mergecolumn_id'], i mod mColNums),
                                     StrToIntDef(vValueSet.Row[i, 'column_row_id'],0)));  // S.H Add: �s�W Row ��T

    if TransStrToDateTime(vValueSet.Row[i, 'datetime']) >= TransStrToDateTime(mLatestTime) then  //�İ�����аO�k�O���̷s�ɶ�
      mLatestTime := gDBManager.ConvertBig5Datetime(vValueSet.Row[i, 'datetime']);

    if (i + 1) < vValueSet.RowNums then
    begin
      if (vRowNum <> StrToInt(vValueSet.Row[i + 1, 'column_row_id'])) then  //�YRowNums �P column_row_id ���P�A�N��ܸӴ���F
      begin
        AddRow(vTmpRow);                 //�N��ƥ[��mRows
        vTmpRow := TTableRow.Create;     //�إ߷s���@�C
      end;
    end
    else
      AddRow(vTmpRow);                 //�N��ƥ[��mRows
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
    (** Extra, merge ������, ���ݭn�Ψ�, ��ƻP�W���O�@�˪�*)
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
    (** Extra, �ˬd merge ������, �קK��ƥX�� *)
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
  SetColumnS(TNullColumn.Create);  // �إߤl�� Column���A
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
  vColSet := gDBManager.GetMergeTable_ColumnS(aTableID);  //���X��������

  if (vColSet.RowNums = 0) or (vColSet = nil) then   //��ܵL��tableID�εL���
  begin
    ShowMessage(Format('Cannot find Table ID = %d !!', [aTableID]));
    exit;
  end;

  mTableID := aTableID;         //�O���ثe�n�إߪ����ID
  mColNums := vColSet.RowNums;  //�O�����ƶq

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

  if aColumnID > ColNums - 1 then  //�����줣��
    exit;

  if mKeyWords.Count = 0 then
    mKeyWords.Add(vTmp)
  else
  begin
    for i := 0 to mKeyWords.Count - 1 do
    begin
      if TSearchNode(mKeyWords.Items[i]).mColumnID = aColumnID then  //�P�_�P�@���O�_�w����L����r
      begin
        if TSearchNode(mKeyWords.Items[i]).mKeyWord = aKeyWord then   //�ۦP����r�A�����j�M�A���}�����j�M
          exit
        else      //���P����r
        begin
          TSearchNode(mKeyWords.Items[i]).mKeyWord := aKeyWord;
          TSearchNode(mKeyWords.Items[i]).Results.Clear;  //�M�Ť��e���j�M���G
          break;  //���X�j��
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
  mTableID := GridManage.TableManager.Tables[aTableID].TableID; //SearchTable���VDB�n��ơA�qcache�ݨ��oTableID(�Hcache��search)

  SetColumnS(GridManage.TableManager.Tables[aTableID].Column);  // �إߤl�� Column���A

  mColNums := GridManage.TableManager.Tables[aTableID].ColNums;

  for i := 0 to GridManage.TableManager.Tables[aTableID].RowNums - 1 do  //���B��TableModel��TableModel���ƻs�A�]��index�P�~���s�����P
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
  if mKeyWords.Count = 1 then  //�|�L�j�M�L�A�]��KeyWords��[�J
  begin
    for i := cFirstRowCount to (RowNums + cFirstRowCount - 1) do   //�j�M��H������
    begin
      if AnsiContainsText(Cells[aColumnID, i - cFirstRowCount].Value, aKeyWord) then  //aColumnID�w�g��������TableModel�A�ҥH���ݦA�ഫ
        TSearchNode(mKeyWords.Items[0]).Results.Add(IntToStr(i - cFirstRowCount));    //�[�J�C��(��ڹ���TableModel)
    end;
  end
  else  //�w�g�j�M�L
  begin
    for i := 1 to TSearchNode(mKeyWords.Items[mKeyWords.Count - 2]).Results.Count do  //�j�M��H���e�@���j�M���G
    begin
      vRow := StrToInt(TSearchNode(mKeyWords.Items[mKeyWords.Count - 2]).Results.Strings[i - 1]);  //�e�@���[�J���C���A�w�g��������TableModel�A�ҥH���ݦA�ഫ

      if AnsiContainsText(Cells[aColumnID, vRow].Value, aKeyWord) then  //aColumnID�w�g��������TableModel�A�ҥH���ݦA�ഫ
        TSearchNode(mKeyWords.Last).Results.Add(IntToStr(vRow));  //�[�J�C��
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
