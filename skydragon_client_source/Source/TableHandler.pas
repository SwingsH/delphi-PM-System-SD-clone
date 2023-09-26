{$I define.h}
unit TableHandler;
(**************************************************************************
 * �t�Τ��� ���(Excel)/���/��줺�e �B�z��, Control Layer
 *************************************************************************)
interface

uses
  (** Delphi *)
  Dialogs, SqlExpr, SysUtils, Classes, DBManager, SQLConnecter,Forms,Windows;

type
  (********************************************************
   * ����Ƶ��G: ���\, ��줣�s�b, ��J���~, �������~
   ********************************************************)
  TModifyResult = (Success, NotExist, InputError, ModifyError);
  TLogType      = (ltNew, ltMod, ltDel);

  /// TODO: �ഫ�ާ@ �@���� TTableHandler �M�`�� TMergeTableHandler ��
  ITableHandle = interface
  ['{0F4B6790-F2D7-4925-AB07-480DD21C426B}']
    function NewRow(aMTableID, aMRowID: Integer): Integer;
    function  GetEnableLog: Boolean;
    procedure SetEnableLog(const Value:Boolean );
    property EnableLog: Boolean read GetEnableLog write SetEnableLog;
  end;

  (********************************************************
   * �t�Τ��� ���(Excel)/���/��줺�e �B�z��
   * ���W�� Handler �D Manager �O�]���䬰 MVC ���� Control,
   * �t�d�B�z�y�{, �Ӥ��d�s Data
   *
   * 1. �O�� ���(Excel)/���/��줺�e �ާ@���v���� scs_table_log
   * 2. �M�� �X�֪�� scs_mergetable / ��� scs_table ������
   * @Author  Swings Huang
   * @Version 2010/01/28
   ********************************************************)
  TTableHandler = class(TInterfacedObject,ITableHandle)
  private
    mEnableLog: Boolean;
    function GetEnableLog: Boolean;
    procedure SetEnableLog(const Value: Boolean);
    function SaveLog(aTableID, aUserID:Integer; vMessage:String; aValid:Byte):Boolean;  /// (TODO:�@�o..���O �ثe���ӴN�u�� MergeTableHandler)
  protected
  public
    constructor Create;
    function NewTable(aTableName, aTableDesc: String;                           /// (TODO:)�إ߷s���: �^�� -1 in false or ID in Success
                      aUserID, aOrganizeID, aProjectID: Integer): Integer; virtual;
    function NewColumn: Integer; virtual;                                       /// (TODO:)�s�W���
    function NewColumnvalue: Integer; virtual;                                  /// (TODO:)�s�W��줺�e
    function NewRow(aTableID, aRowID: Integer): Integer; overload; virtual;     /// �s�W�@�C = �s�W�h�� RowID �@�˪� Columnvalue, ������w�]��   (TODO:���򦳮ɶ��ɶq������@�禡��)
    function NewRow(aTableID, aRowID:Integer;                                   /// �s�W�@�C = �s�W�h�� RowID �@�˪� Columnvalue, ������!!     (TODO:���򦳮ɶ��ɶq������@�禡��)
                    aValueList:TStringList):Integer;overload;
    function DeleteRow(aTableID, aRowID: Integer): Integer;                     /// �R���@�C = �s�W�h�� RowID �@�˪� Columnvalue
    function ModifyTable: Integer; virtual;                                     /// (TODO:)
    function ModifyColumn: Integer;  virtual;                                   /// (TODO:)
    function ModifyColumnvalue(aTableID, aColumnID, aColumnRowID: Integer;      /// �����줺�e: �^�� TModifyResult (TODO:���򦳮ɶ��ɶq������@�禡��)
                               aValue: String; aCheck:Boolean= False): TModifyResult; virtual;
    function SelectListToString( aSelectList: TStringList ):String;             /// scs_column.type_set, �U�Ԧ���� StringList �ഫ�� String
    function StringToSelectList( aSelectString: String):TStringList;            /// scs_column.type_set, �U�Ԧ���� String �ഫ�� StringList
    property EnableLog: Boolean read GetEnableLog write SetEnableLog;
  end;
  
  (********************************************************
   * �`�� (�X�֪��/MergeTable) ���B�z��
   * �t�d�P�B�`��(MergeTable)��ƨ�������l���(Table)
   * ���I�}�o
   * @Author  Swings Huang
   * @Version 2010/02/02
   * @Todo    1. ���������ˬd, �ˬd�`��U���l���, �O���O����b�`��䪺�����,
   *             �S���ʺ|�����C
   *          2. �P�B�ˬd, �ˬd�`��U���l��檺�Ҧ� [��줺�e] & [�C��] �O�_�@�P�C
   *          3. �s�W�e�]�n�P�B�ˬd�C
   ********************************************************)
  TMergeTableHandler = class(TInterfacedObject,ITableHandle)
  private
    mEnableLog: Boolean;  /// �O�_�n�}���x�s Log ���\��C scs_table_log
    mTableIDs: array of Integer;
    function  GetEnableLog: Boolean;
    procedure SetEnableLog(const Value: Boolean);
    procedure ValueSOfChildTable(aMTableID:Integer;aValList:TStringList;        /// ���`���� �ন���h�Ӥl�����
                                 out aArrValList: array of TStringList);
    procedure SaveTableIDs(aRSet: TRecordSet);                                  /// TODO: �ϥ� RSet �x�s�@���`��U���X�Ӥl��
  public
    constructor Create;
    function CheckMergeTableExist(aMTableID: Integer):Boolean ;
    function NewRow(aMTableID, aMRowID: Integer): Integer;overload;             /// �s�W�@�C = �s�W�h�� RowID �@�˪� Columnvalue, ������w�]�� (TODO:���򦳮ɶ��ɶq������@�禡��)
    function NewRow(aMTableID, aMRowID:Integer;                                 /// �s�W�@�C = �s�W�h�� RowID �@�˪� Columnvalue, ������!!  (TODO:���򦳮ɶ��ɶq������@�禡��)
                    aValueList:TStringList):Integer;overload;
    function DeleteRow(aMTableID, aMRowID: Integer): Integer;                   /// �R���@�C = �s�W�h�� RowID �@�˪� Columnvalue
    function ModifyColumnvalue(aLogID,aMTableID, aMColumnID, aMColumnRowID: Integer;   /// �����줺�e: �^�� TModifyResult, �ݭn�ǤJ LogID, �_�h�L�k�x�s�@�Ӱʧ@�ק�h����쪺 LOG (TODO:���򦳮ɶ��ɶq������@�禡��)
                               aMValue: String; aCheck:Boolean= false; aRefreshAllTable:Boolean= false): TModifyResult;
    function SaveLogList(aTitleID: Integer; aMessage: String; aMColumnID,       /// �إߤ@�� Log �C��, @param aError ��x�����~���O,�s�����\�Υ���
                         aMRowID:Integer; aError:Boolean=False):Boolean;
    function CreateLog(aMTableID: Integer; aLogType: TLogType):Integer;         /// �إ� Log ���D, �^�� Log ID, �s�W�@�Ӥ�x���D  ���\�h�^�Ƿs�W�����D ID
    property EnableLog: Boolean read GetEnableLog write SetEnableLog;
  end;

var
  gTableHandler: TTableHandler;
  gMergeTableHandler: TMergeTableHandler;
  
implementation

uses
  StateCtrl, CommonFunction;

const
  (********************************************************
   * Database �]�w�`��
   ********************************************************)
  cColumnType: array[1..7] of String =('number', 'textfield', 'textarea', 'date', 'checkbox', 'radiobox', 'selectbox');
  cColumnType_Text= 'textarea';
  cColumnType_SBox_Sep       = ',';           /// Separator of Select Box EX: ("A","B")
  cColumnType_SBox_delimiter = '"';           /// delimiter of Select Box Ex: "A"

  // HTML String �榡
  cFRed  = '<font color=#E14400><b>' ;   // ���?
  cFGreen = '<font color=#008800><b>' ;  // �`��?
  cFE    = '</b></font>' ;
  cBold  = '<b>';
  cBoldE = '</b>';
  cTableString_001 = cFRed+'[%s]'+cFE+'�չϭק�M��'+cFGreen+'[%s]'+cFE+
                     '�����'+cFGreen+'[%s]'+cFE+', �i�O���ѤF! ';
  cTableString_002 = cFRed+'[%s]'+'�ק�M��'+cFGreen+'[%s]'+cFE+'�����'+cFGreen+'[%s]'+cFE+
                     ',�N���'+cFGreen+'[%s]'+cFE+'�����e��'+cBold+'[%s]'+cBoldE+'�קאּ'+cBold+'[%s]'+cBoldE+'�C';
  cTableString_003 = '�������~,���p���}�o�H��';
  cTableString_004 = cFRed+'[%s]'+cFE+'�չϷs�W�@����Ʃ�M��'+cFGreen+'[%s]'+cFE+'�����'+cFGreen+'[%s]'+cFE+', �i�O���ѤF! ';
  cTableString_005 = cFRed+'[%s]'+cFE+'�s�W�@����Ʃ�M��'+cFGreen+'[%s]'+cFE+'�����'+cFGreen+'[%s]'+cFE+'�C';
  cTableString_006 = cFRed+'[%s]'+cFE+'�չϷs�W�@����Ʃ�M��'+cFGreen+'[%s]'+cFE+'���`��'+cFGreen+'[%s]'+cFE+', �i�O���ѤF! ';
  cTableString_007 = cFRed+'[%s]'+cFE+'�s�W�@����Ʃ�M��'+cFGreen+'[%s]'+cFE+'���`��'+cFGreen+'[%s]'+cFE+'�C';
  cTableString_008 = '�L�W��';
  cTableString_009 = '�����H';     // �����M��, �������
  cTableString_010 = '���(%s)��(%s).';
  cTableString_011 = cFRed+'[%s]'+cFE+'�չϭק�M��'+cFGreen+'[%s]'+cFE+
                     '���`�X���'+cFGreen+'[%s]'+cFE+'�����'+cFGreen+'[%s]'+cFE+', �i�O���ѤF! ';
  cTableString_012 = cFRed+'[%s]'+cFE+'�ק�M��'+cFGreen+'[%s]'+cFE+
                     '���`�X���'+cFGreen+'[%s]'+cFE+',�N���'+cFGreen+'[%s]'+cFE+
                     '�����e��'+cBold+'[%s]'+cBoldE+'�קאּ'+cBold+'[%s]'+cBoldE+'�C';
  cTableString_013 = cFRed+'[%s]'+cFE+'�s�W�M��'+cFGreen+'[%s]'+cFE+'���`�X���'+cFGreen+'[%s]'+cFE+
                     ',�����'+cFGreen+'[%s]'+cFE+'�����e'+cBold+'[%s]'+cBoldE+'�C';
  cTableString_014 = cFRed+'[%s]'+cFE+'�R���M��'+cFGreen+'[%s]'+cFE+'���`�X���'+cFGreen+'[%s]'+cFE+
                     ',����'+cBold+'[%d]'+cBoldE+'�C�C';
  // Format String �榡
  cTableString_021 = '[%s]��M��[%s]�����[%s]�s�W�F��ơC';
  cTableString_022 = '[%s]��M��[%s]�����[%s]�ק�F��ơC';
  cTableString_023 = '[%s]��M��[%s]�����[%s]�R���F��ơC';

  cValid   = 1;
  cInvalid = 0;

{ TTableHandler }

constructor TTableHandler.Create;
begin
  EnableLog := True;
end;

function TTableHandler.GetEnableLog: Boolean;
begin
  Result := mEnableLog;
end;

procedure TTableHandler.SetEnableLog(const Value: Boolean);
begin
  mEnableLog := Value;
end;

function TTableHandler.ModifyColumn: Integer;
begin
  Result:= -1 ;
end;

function TTableHandler.ModifyColumnvalue(aTableID, aColumnID,
  aColumnRowID: Integer; aValue: String; aCheck: Boolean): TModifyResult;
var
  vRecordSet: TRecordSet;
  vResult: Integer;
  vMessage: String;
  vColName, vColType, vTableName, vProjName: String;
  vPreColValue, vNowColValue, vNickName : String;    (**�쥻����줺�e,���᪺��줺�e*)
begin
  Result:= ModifyError ;
  vRecordSet := nil ;
  vMessage   := '';
  
  vRecordSet:= gDBmanager.GetColumn(aTableID, aColumnID);
  if vRecordSet.RowNums = 0 then
  begin
    Result := NotExist;   // ��줣�s�b
    Exit;
  end;
  vColName:= vRecordSet.Row[0, 'column_name'];
  vColType:= vRecordSet.Row[0, 'column_type'];
  freeAndNil(vRecordSet); // �M��

  vRecordSet := gDBmanager.GetTable(aTableID);
  if vRecordSet.RowNums = 0 then
  begin
    Result := NotExist;   // ��椣�s�b
    Exit;
  end;
  vTableName:= vRecordSet.Row[0, 'table_name'];
  vProjName := vRecordSet.Row[0, 'project_name'];
  freeAndNil(vRecordSet); // �M��

  vRecordSet := gDBmanager.GetColumnvalue(aTableID,aColumnID,aColumnRowID);
  if vRecordSet.RowNums = 0 then
  begin
    Result := NotExist;   // ��줺�e���s�b (�ӦC�|���إ�)
    Exit;
  end;

  vPreColValue := vRecordSet.Row[0, 'value'];
  vNowColValue := aValue;
  freeAndNil(vRecordSet); // �M��

  // TODO: �ˬd�榡 Input check !!!!!!!!!!!!!!
  if aCheck then
  begin
    Result := Success;
    Exit;
  end;

  /// ��s��� scs_columnvalue
  vResult:= gDBManager.SetColumnvalue(aTableID,aColumnID,aColumnRowID,aValue);

  if mEnableLog = True then
    Exit;
    
  /// �إߧ�ʬ����T�� scs_table_log
  if StateManage.NickName = '' then
    vNickName := cTableString_008
  else
    vNickName := StateManage.NickName;
    
  if vResult <= 0 then
    // '[%s]�չϭק�M��[%s]�����[%s], �i�O���ѤF! '
    vMessage := Format(cTableString_001,[vNickName, vProjName, vTableName])
  else
    // '[%s]�ק�M��[%s]�����[%s],�N���[%s]�����e��[%s]�קאּ[%s]�C';
    vMessage := Format(cTableString_002,[vNickName, vProjName, vTableName, vColName, vPreColValue, vNowColValue]);

  SaveLog(aTableID, StateManage.ID, vMessage, cValid );    // �s�W��ʬ��� scs_table_log
end;

function TTableHandler.ModifyTable: Integer;
begin
  Result:= -1 ;
end;

function TTableHandler.NewColumn: Integer;
begin
  Result:= -1 ;
end;

function TTableHandler.NewColumnvalue: Integer;
begin
  Result:= -1 ;
end;

function TTableHandler.NewRow(aTableID, aRowID: Integer): Integer;
var
  vRecordSet: TRecordSet;
  vString: TStringList;
  i: Integer;
begin
  Result:= -1;
  vString:= TStringList.Create;
  
  // ���o����
  vRecordSet:= gDBManager.GetTable_ColumnS(aTableID);
  if vRecordSet.RowNums = 0 then
  begin
{$ifdef Debug}
    ShowMessage( 'Table Has No Columns !!' );
{$endif}      
    Exit;
  end;

  for i:=0 to vRecordSet.RowNums-1 do
    vString.Add('');

  NewRow(aTableID, aRowID, vString);
end;

 
function TTableHandler.NewRow(aTableID, aRowID: Integer; aValueList: TStringList): Integer;
var
  vRecordSet: TRecordSet;
  vProjName, vTableName, vMessage: String;
  vQuery: String;
  i, vColID : Integer;
  vErrorFlag: Boolean;
begin
  Result     := -1;
  vErrorFlag := False;
  vMessage   := '';

  // �ˬd���O�_�s�b
  vRecordSet := gDBManager.GetTable(aTableID);
  if vRecordSet.RowNums = 0 then
    vErrorFlag := True;          // ShowMessage( 'Table Not Exist !!' );
  vTableName:= vRecordSet.Row[0, 'table_name'];
  vProjName := vRecordSet.Row[0, 'project_name'];
  freeAndNil(vRecordSet); // �M��

  // �ˬd�ӦC�O�_�w�g�s�b, (�����`,�s���@�C���|�s�b)
  vRecordSet := gDBManager.GetColumnValueS(aTableID, 0, aRowID, 'total');
  if vRecordSet.RowNums <> 0 then
    vErrorFlag := True;        // ShowMessage( 'Row Already Exist, Error !!' );
  freeAndNil(vRecordSet);      // �M��

  // �ˬd���O�_�s�b
  vRecordSet:= gDBManager.GetTable_ColumnS(aTableID);
  if vRecordSet.RowNums = 0 then
    vErrorFlag := True;        // ShowMessage( 'Table Has No Columns !!' );

  // �ˬd��J��ƪ����ƬO�_���T, �@�ӭ�(value) �����@��(column)
  if aValueList.Count <> vRecordSet.RowNums then
    vErrorFlag := True;
    
  if vErrorFlag = True then
  begin
    // '[%s]�չϷs�W�@����Ʃ�M��[%s]�����[%s], �i�O���ѤF!'
    vMessage := Format(cTableString_004,[StateManage.NickName, vProjName, vTableName]);
    SaveLog( aTableID, StateManage.ID, vMessage, cInvalid );
    Exit;
  end;
  
  /// �}�l��J���
  vQuery:= '';
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    vColID:= StrToIntDef( vRecordSet.Row[i, 'column_id'], -1 );
    gDBManager.AddColumnvalue( aTableID, vColID, aRowID, aValueList[i] );
  end;

  /// �x�s Table Log
  vMessage := Format(cTableString_005,[StateManage.NickName, vProjName, vTableName]);  // '[%s]�s�W�@����Ʃ�M��[%s]�����[%s]�C';
  SaveLog( aTableID, StateManage.ID, vMessage, cValid );    // �s�W��ʬ��� scs_table_log
  
  Result   := 1;
end;

function TTableHandler.NewTable(aTableName, aTableDesc: String; aUserID,
  aOrganizeID, aProjectID: Integer): Integer;
begin
  Result:= -1 ;
end;

function TTableHandler.SelectListToString(aSelectList: TStringList): String;
var
  i: Integer ;
begin
  Result:= '';

  for i:= 0 to aSelectList.Count-1 do
  begin
    Result:= Result + Format( '%s%s%s', [cColumnType_SBox_delimiter,aSelectList[i],cColumnType_SBox_delimiter] );   // Ex: "A"
    if i < aSelectList.Count-1 then
      Result:= Result + cColumnType_SBox_Sep ;  // �D�����h +  ','
  end;
  
end;

function TTableHandler.StringToSelectList(aSelectString: String): TStringList;
var
  i: Integer ;
begin
  Result:= nil;
  if aSelectString = '' then
    Exit;

  Result:= SplitString(aSelectString, cColumnType_SBox_Sep );

  for i:= 0 to Result.Count-1 do
  begin
    Result.Strings[i] := Trim(Result.Strings[i]);
    
    if (Copy( Result.Strings[i], 0, 1 ) = cColumnType_SBox_delimiter ) AND                           // �Ĥ@�Ӧr���� "
       (Copy( Result.Strings[i], Length(Result.Strings[i]) , 1 ) = cColumnType_SBox_delimiter) then  // �̫�@�Ӧr���� "
    begin
      Result.Strings[i] := Copy( Result.Strings[i], 2, Length(Result.Strings[i])-2 );
    end
    else
{$ifdef Debug}
      ShowMessage( aSelectString + ' SelectBox Format error');
{$endif}      
  end;
end;

function TTableHandler.SaveLog(aTableID, aUserID:Integer; vMessage:String; aValid:Byte):Boolean;
var
  EffRow:Integer;
begin
  Result:= False;
  EffRow:= gDBManager.AddTableLog( aTableID, aUserID, vMessage, aValid );

  if EnableLog = False then
    Exit;

  if EffRow > 0 then
    Result := True;
end;

function TTableHandler.DeleteRow(aTableID, aRowID: Integer): Integer;
begin
  Result:= -1;
  if aTableID <= 0 then
    Exit;
  if aRowID <= 0 then
    Exit;

  Result:= gDBmanager.DelColumnvalue(aTableID, 0, aRowID);
end;

{ TMergeTableHandler }

function TMergeTableHandler.GetEnableLog: Boolean;
begin
  Result:= mEnableLog;
end;

procedure TMergeTableHandler.SetEnableLog(const Value: Boolean);
begin
  mEnableLog := Value;
end;

procedure TMergeTableHandler.ValueSOfChildTable( aMTableID:Integer;
  aValList: TStringList; out aArrValList: array of TStringList);
var
  vRSet: TRecordSet;
  i, vIdx, vCurTableID, vMergeColID : Integer;
begin
  if aMTableId <= 0 then
    Exit;

  vRSet := gDBmanager.GetMergeTable_ColumnS(aMTableID, 0, 'detail', 'table');
                      
  vIdx  := 0;
  vCurTableID:= StrToInt(vRSet.Row[0,'table_id']);    // �ثe�x�s��List ���l��� ID
  aArrValList[vIdx]:= TStringList.Create;
  for i:= 0 to vRSet.RowNums -1 do
  begin
    if vCurTableID <> StrToInt(vRSet.Row[i,'table_id']) then   // �ˬd�O�_�x�s�U�@�� �l��� �� LIST
    begin
      vCurTableID := StrToIntDef(vRSet.Row[i,'table_id'],0);
      Inc(vIdx);
      if vIdx >= Length(aArrValList) then    // out of range
        break;
      aArrValList[vIdx]:= TStringList.Create;
    end;
    vMergeColID:= StrToInt( vRSet.Row[i,'mergecolumn_id'] );
    aArrValList[vIdx].Add( aValList[vMergeColID-1] );  // implement, mergecolumn_id start with 1, stringlist start with 0
  end;
end;

function TMergeTableHandler.ModifyColumnvalue(aLogID, aMTableID, aMColumnID,
  aMColumnRowID: Integer; aMValue: String; aCheck: Boolean; aRefreshAllTable:Boolean): TModifyResult;
var
  vRSet, vRSet2: TRecordSet;
  vNickName, vMessage, vColName, vMTableName, vProjName, vOrgName, vPreColValue: String;
  vTableID, vColumnID: Integer;
  vError, i : Integer;
begin
  Result:= ModifyError ;
  vRSet := nil ;
  vError:= -1 ;

  // ���o �`�����(mergecolumn) �M �۹������l���(column), ... mapping data
  vRSet := gDBmanager.GetMergeTable_ColumnS(aMTableID, aMColumnID,'detail');
  if vRSet.RowNums = 0 then
  begin
    Result := NotExist;   // �`����줣�s�b
    Exit;
  end;

  // TODO: �ˬd�榡 Input check !!!!!!!!!!!!!!
  if aCheck then
  begin
    Result := Success;
    Exit;
  end;

  vNickName := StateManage.NickName ;
  if vNickName = '' then
    vNickName := cTableString_008;

  // ���o�`������T
  vColName := '';
  for i:= 0 to vRSet.RowNums-1 do
    vColName:=vColName+Format(cTableString_010, [vRSet.Row[i,'table_name'],vRSet.Row[i,'column_name']]); // '���(%s)��(%s)';

  vTableID    := StrToIntDef(vRSet.Row[0,'table_id'] , -1);  // �H ID �̫e���� ���Ȭ��D
  vColumnID   := StrToIntDef(vRSet.Row[0,'column_id'], -1);
  vRSet2      := gDBmanager.GetColumnvalue( vTableID, vColumnID, aMColumnRowID);
  vPreColValue:= vRSet2.Row[0,'value'];

  // ��s[�`����줺�e] == �]���P�B, �ҥH�|��s�h��[��]��[��줺�e] multi- scs_columnvalue
  for i:= 0 to vRSet.RowNums-1 do
  begin
    vTableID := StrToIntDef(vRSet.Row[i, 'table_id'] , -1);
    vColumnID:= StrToIntDef(vRSet.Row[i, 'column_id'], -1);
    vError   := gDBmanager.SetColumnvalue(vTableID, vColumnID, aMColumnRowID,
                                          aMValue);                             // MergeRowID = RowID
    if vError <= 0 then   // �s�W���� (TODO: �R�����e��J�� or �ϥ� TRANSACTION )
      Break;
  end;
  vTableID   := StrToIntDef(vRSet.Row[0,'table_id'], -1);
  FreeAndNil(vRSet);
  
  vRSet := gDBManager.GetMergeTable_TableS(aMTableID);  // ���X�`�X��橳�U�����
  SaveTableIDs(vRSet);

  (** �ק諸���p --> �]�� ColumnValue �٦s�b, �i�H�u��s ColumnValue ���ɶ�, ����s TableTime **)
  if aRefreshAllTable then
  begin
    for i:= 0 to Length(mTableIDs)-1 do
      gDBManager.SetTable_UpdateTime(mTableIDs[i]);  /// ��s Table �̫�ק�ɶ�
    gDBManager.SetMergeTable_UpdateTime(aMTableID);   /// ��s MergeTable �̫�ק�ɶ�
  end;
  
  FreeAndNil(vRSet);
  ///============= �H�U�u�O���F Log ���o��T =============
  // ���o�`�� �M��, ��´��T
  vRSet      := gDBmanager.GetTable( vTableID );
  vProjName  := vRSet.Row[0, 'project_name'];
  vOrgName   := vRSet.Row[0, 'organize_name'];
  FreeAndNil(vRSet);
  vRSet      := gDBmanager.GetMergeTable( aMTableID );
  vMTableName:= vRSet.Row[0, 'mergetable_name'];
  FreeAndNil(vRSet);

  if vError <= 0 then
  begin
    // '�u%s�v�չϭק�M��[%s]���`�X���[%s]�����[%s], �i�O���ѤF! '
    vMessage := Format(cTableString_011,[vNickName, vProjName, vMTableName, vColName]);
    SavelogList(aLogID, vMessage, aMColumnID, aMColumnRowID,True);// ��function �~�� SavelogTitle
  end
  else
  begin
    // '�u%s�v�ק�M��[%s]���`�X���[%s],�N���[%s]�����e��[%s]�קאּ[%s]�C';
    vMessage := Format(cTableString_012,[vNickName,vProjName,vMTableName,vColName,vPreColValue,aMValue]);
    SavelogList(aLogID, vMessage, aMColumnID, aMColumnRowID);      // ��function �~�� SavelogTitle
  end;

  Result := Success;
end;

constructor TMergeTableHandler.Create;
begin
  mEnableLog:= True;
end;

function TMergeTableHandler.NewRow(aMTableID, aMRowID: Integer): Integer;
const
  cDefaultValue = ' -- ';
var
  vRSet : TRecordSet;
  i: Integer;
  vValueList: TStringList;
begin
  Result:= -1;
  // �ˬd�`��檺���O�_�s�b
  //vRSet:= gDBManager.GetMergeTable_ColumnS(aMTableID, 0, 'mapping');
  vRSet:= gDBManager.GetMergeTable_ColumnS(aMTableID, 0);
  if vRSet.RowNums = 0 then
  begin
{$ifdef Debug}  
    ShowMessage( 'MergeTable Has No Columns !!' );
{$endif}    
    Exit;
  end;

  vValueList:= TStringList.Create;
  for i:=0 to vRSet.RowNums-1 do
    vValueList.Add(cDefaultValue);

  NewRow(aMTableID, aMRowID, vValueList);
end;

function TMergeTableHandler.NewRow(aMTableID, aMRowID: Integer;
  aValueList: TStringList): Integer;
var
  vRSet, vRSet2 : TRecordSet;
  vErrorFlag: Boolean;
  i, vTableID, vLogID, vMColNums : Integer;
  vNickName, vMessage, vProjName, vTableName, vColName: String;
  vArrValueList: array of TStringList;
begin
  Result     := -1;
  vErrorFlag := False; 
  vProjName  := cTableString_009;   // '�����H'
  vTableName := cTableString_009;   // '�����H'

  // �ˬd �`��� �O�_�s�b
  vRSet := gDBManager.GetMergeTable(aMTableID);
  if vRSet.RowNums = 0 then
    vErrorFlag := True ;

  // �ˬd�Ҧ��l���(Table)�b�ӦC�O�_�w�g�s�b, (�����`,�s���@�C���s�b)
  if vErrorFlag = False then
  begin
    vProjName := vRSet.Row[0, 'project_name'];
    vTableName:= vRSet.Row[0, 'mergetable_name'];
    FreeAndNil(vRSet);
    // ���o�Ҧ��l���(Table)
    vRSet:= gDBManager.GetMergeTable_TableS(aMTableID);

    for i:= 0 to vRSet.RowNums -1 do     // �ˬd�l���U����줺�e
    begin
      vTableID := StrToIntDef(vRSet.Row[i, 'table_id'], 0) ;
      vRSet2   := gDBManager.GetColumnValueS(vTableID, 0, aMRowID, 'total');    // MergeRowID = RowID, ���`���p�`���M�l���C�ƬO�@�P��
      if vRSet2.RowNums <> 0 then
      begin
        ShowMessage( 'MergeTable''s Row Already Exist, Error !!' );
        vErrorFlag := True;
        Break;
      end;
      freeAndNil(vRSet2); // �M��
    end;
  end;
  freeAndNil(vRSet2); // �M��

  // �ˬd�`��檺���O�_�s�b
  if vErrorFlag = False then
  begin
    vRSet2:= gDBManager.GetMergeTable_ColumnS(aMTableID, 0);
    if vRSet2.RowNums = 0 then
    begin
      vErrorFlag := True;
{$ifdef Debug}
      ShowMessage( 'MergeTable Has No Columns !!' );
{$endif}      
    end;
  end;

  vNickName := StateManage.NickName;
  if StateManage.NickName = '' then
    vNickName := cTableString_008 ;
{$ifdef Debug}
  vNickName := '�ռݴ��ե�';
{$endif}

  // �ˬd��J��ƪ����ƬO�_���T, �@�ӭ�(value) �����@��(column)
  vMColNums := StrToIntDef(vRSet2.Row[vRSet2.RowNums-1, 'mergecolumn_id'], -1); // ��X�`��@���X��
  if vErrorFlag = False then
  if aValueList.Count <> vMColNums then
    vErrorFlag := True;

  if vErrorFlag = True then
  begin
{$ifdef Debug}
    ShowMessage( 'TMergeTableHandler.NewRow Error !!' );
{$endif}
    vMessage := Format(cTableString_006,[vNickName, vProjName, vTableName]); // '�u%s�v�չϷs�W�@����Ʃ�M��[%s]���`��[%s], �i�O���ѤF! ';
    vLogID := CreateLog( StateManage.ID, ltNew);           // �s Log ���D
    SaveLogList(vLogID, vMessage, 0, aMRowID, True);       // �s Log �C��
    Exit;
  end;

  // �N�@���`�� Value ���Ѧ� N �Ӥl��� Value
  SetLength(vArrValueList, vRSet.RowNums);
  ValueSOfChildTable(aMTableID, aValueList, vArrValueList);

  // �}�l�s�W[�l���](Table)�����
  gTableHandler.EnableLog:= False;
  for i:= 0 to vRSet.RowNums - 1 do
  begin
    vTableID := StrToIntDef(vRSet.Row[i, 'table_id'], 0) ;
    gTableHandler.NewRow(vTableID, aMRowID, vArrValueList[i]);
    gDBManager.SetTable_UpdateTime(vTableID);     /// ��s Table �̫�ק�ɶ�
  end;
  gTableHandler.EnableLog:= True;
  gDBManager.SetMergeTable_UpdateTime(aMTableID);  /// ��s MergeTable �̫�ק�ɶ�

  // �x�s Table Log
  vLogID := CreateLog( aMTableID, ltNew);           // �s Log ���D
  for i:= 0 to aValueList.Count-1 do                     // �s Log �C��
  begin
    vColName := vRSet2.Row[i, 'column_name'];   // ���ƶq�P value �ƶq�w���L
    vMessage := Format(cTableString_013,[vNickName, vProjName, vTableName, vColName, aValueList[i]]); // [%s]�s�W�M��[%s]���`�X���[%s],�����[%s]�����e[%s]
    SaveLogList(vLogID, vMessage, i+1, aMRowID);    // ���`���p mcolumn �� 1�}�l�B�s��
  end;

  freeAndNil(vRSet); // �M��
  freeAndNil(vRSet2); // �M��
  Result   := 1;
end;

function TMergeTableHandler.DeleteRow(aMTableID, aMRowID: Integer): Integer;
var
  vRSet      : TRecordSet;
  i, vTableID, vLogID: Integer;
  vNickName, vProjName, vMTableName, vMessage: String;
begin
  Result:= -1;
  if aMTableID <= 0 then
    Exit;
  if aMRowID <= 0 then
    Exit;

  // �ˬd �`��� �O�_�s�b
  vRSet := gDBManager.GetMergeTable(aMTableID);
  if vRSet.RowNums = 0 then
    Exit ;
  vProjName  := vRSet.Row[0, 'project_name'];
  vMTableName:= vRSet.Row[0, 'mergetable_name'];
  freeAndNil(vRSet);

  if Application.MessageBox('�T�w�R�����C�H', '', MB_YESNO)=IDNO then   // TODO: �����O�B�P�_
    exit;
      
  vRSet := gDBManager.GetMergeTable_TableS(aMTableID); // ���o�`���(MTable)�U���Ҧ��l���(Table)
  gTableHandler.EnableLog:= False;
  for i:= 0 to vRSet.RowNums -1 do     // �ˬd�l���U����줺�e
  begin
    vTableID:= StrToIntDef( vRSet.Row[i,'table_id'], 0);
    gTableHandler.DeleteRow(vTableID, aMRowID);
    gDBManager.SetTable_UpdateTime(vTableID);  /// ��s Table �̫�ק�ɶ�
  end;
  gTableHandler.EnableLog:= True;

  gDBManager.SetMergeTable_UpdateTime(aMTableID);  /// ��s MergeTable �̫�ק�ɶ�

  vNickName := StateManage.NickName ;
  vLogID  := CreateLog(aMTableID, ltDel);         // �s Log ���D
  vMessage:= Format(cTableString_014,[vNickName,vProjName,vMTableName, aMRowID]); //[%s]�R���M��[%s]���`�X���[%s],����[%s]�C�C';
  SaveLogList(vLogID, vMessage, 0, aMRowID);       // �s Log �C��
end;

function TMergeTableHandler.SaveLogList(aTitleID: Integer; aMessage: String;
  aMColumnID, aMRowID: Integer; aError:Boolean): Boolean;
var
  EffRow: Integer;
begin
  Result:= False;
  if EnableLog = False then
    Exit;

  EffRow:= gDBManager.AddTablelogList(aTitleID, aMessage, aMColumnID, aMRowID, aError);

  if EffRow > 0 then
    Result := True;
end;

function TMergeTableHandler.CreateLog(aMTableID: Integer;
  aLogType: TLogType): Integer;
var
  vMessage, vProjName, vTableName : String;
  vRSet: TRecordSet;
  vEffRow: Integer;
begin
  Result:= -1;
  if EnableLog = False then
    Exit;
  if aMTableID <= 0 then
    Exit;
  vRSet    := gDBManager.GetMergeTable(aMTableID);
  if vRSet = nil then
    Exit;

  vProjName := vRSet.Row[0, 'project_name'];
  vTableName:= vRSet.Row[0, 'mergetable_name'];
  case aLogType of
  ltNew:
    // '�u%s�v��M��[%s]�����[%s]�s�W�F��ơC';
    vMessage := Format(cTableString_021,[ StateManage.NickName, vProjName, vTableName]);
  ltMod:
    // '�u%s�v��M��[%s]�����[%s]�ק�F��ơC'
    vMessage := Format(cTableString_022,[ StateManage.NickName, vProjName, vTableName]);
  ltDel:
    // '�u%s�v��M��[%s]�����[%s]�R���F��ơC'
    vMessage := Format(cTableString_023,[ StateManage.NickName, vProjName, vTableName]);
  end;

  vEffRow:= gDBManager.AddTablelogTitle(StateManage.ID, aMTableID, vMessage);
  if vEffRow > 0 then     // ���\, �^�Ƿs�W�� ID
    Result := gDBManager.GetTablelogTitle_ID(StateManage.ID, 'max');
end;

function TMergeTableHandler.CheckMergeTableExist(
  aMTableID: Integer): Boolean;
var
  vRSet: TRecordSet;
begin
  Result:= False;
  vRSet := gDBManager.GetMergeTable(aMTableID);
  if vRSet.RowNums <> 0 then
    Result:= True ;
end;

procedure TMergeTableHandler.SaveTableIDs(aRSet: TRecordSet);
var
  i: Integer;
begin
  SetLength(mTableIDs, 0);
  if aRSet.RowNums = 0 then
    exit;

  SetLength(mTableIDs, 1);
  mTableIDs[0] := StrToIntDef(aRSet.Row[0,'table_id'],0);
  for i:=1 to aRSet.RowNums-1 do
  begin
    if aRSet.Row[i,'table_id'] <> aRSet.Row[i-1,'table_id'] then
    begin
      SetLength(mTableIDs, Length(mTableIDs)+1);
      mTableIDs[ Length(mTableIDs)-1 ] := StrToIntDef(aRSet.Row[i,'table_id'],0);
    end;
  end; 
end;

end.
