{$I define.h}
unit DBManager;
(**************************************************************************
 * �t�αM�� DB ��@�P�޲z�u��
 *
 * @Author Swings Huang
 * @Version 2010/01/15 v1.0
 * @Todo ��}�o
 *************************************************************************)
interface

uses
  (** Delphi *)
  Dialogs, SqlExpr, SysUtils, Classes,
  (** Sky Dragon *)
  SQLConnecter ;

const
  cUpdateSecond = 30; /// ��Ʈw Update �����j���

type
  (********************************************************
   * SQL DB ��ƺ޲z��, �t�Τ��� SQL �y����@��
   * �`�N: �бN�t�Τ����Ҧ� SQL �y����m�� pas !! ��K�Τ@�޲z�P�ק� !!
   * �`�N: ���O�S�������޿��ˬd ! �u�t�d����C
   *
   * �禡�����R�W�򥻳W�h
   * Add_ (SQL: INSERT �������O)  Set_ (SQL: UPDATE �������O)
   * Get_ (SQL: SELECT �������O)  Del_ (SQL: DELETE �������O)
   *
   * @Author Swings Huang
   * @Version 2010/01/15 v1.0
   * @Todo 
   ********************************************************)
  TDBManager      = class;
  
  (********************************************************
   * SQL �y�k���b���;�, ���� SQL ���O���a��, �קK�H�� KeyIn ���O�X�{���~
   *
   * @Author Swings Huang
   * @Version 2010/01/22
   * @Todo 1.Implode() �B�@���ӭn�n���� TRecordSet
   ********************************************************)
  TQueryGenerator = class;

  TDBManager = class( TObject )
  private
    mSQL         : TSQLConnecter;     /// DB �s�u�u��,
    mQueryString : String;            /// �d�ߦr��, ��K������, �q�`�P mSQL.QueryString �O�ۦP��
    function GetQueryString: String;
  protected
  public
    constructor Create ;
    destructor  Destroy; override;
    (** Table: scs_users **)
    function GetUser(aUserID: Integer): TRecordSet;overload;
    function GetUser(aFilter: String=''; aArg: Integer=0; aArg2: String='';     /// �̱�����o�h��[�ϥΪ�]
                     aRequest: String=''): TRecordSet;overload;
    function AddUser(aAccount, aPassword, aNickname:String; aExNumber, aEmployeeNum,
                     aPosID, aDepID, aTeamOrgID, aOrgID, aLevelID: Integer): Integer;
    function SetPass(aID:integer;aValue: String=''):integer;                    /// �ק�K�X
    function GetUser_Project(aUserID: Integer): TRecordSet;                     /// ���o[�ϥΪ�]���U���Ҧ��M��
    function GetUsers: TRecordSet;overload;
    function GetUsers(aDepID, aOrgID, aGradeLvID: Integer;
                      aRequest: String=''): TRecordSet;overload;
    (** Table: scs_user_status **)
    function GetUserStatus(aUserID: Integer):TRecordSet;                        /// ���o�ϥΪ̪��A (TODO: �Ӫ�u�O�Ȯɨ��N Server)
    function SetUserStatus(aUserID: Integer):Integer; overload;                 /// TODO:
    function SetUserStatus(aQueryStr: String):Integer; overload;                /// TODO:
    (** Table: scs_table, scs_column, scs_columnvalue **)
    function AddTable(out aTableID: Integer; aTableName: String;                /// �s�W�@�� Table, -1���s�W����, 1���s�W���\
                      aTableDesc: String; aUserID:Integer;aOrganizeID: Integer;
                      aProjectID: Integer=0): Integer;
    function AddColumn(aTableID: Integer; aColumnID: Integer;aColumnName:String;/// �s�W�@�� ��� (Column) , -1���s�W����, 1���s�W���\ , �榡�ˬd�зR�� TableHandler
                       aColumnDesc: String;aUserID: Integer; aPriority: Integer; aType: String;
                       aTypeSet: String='';aWidth: Integer= 40; aHeight: Integer = 20 ): Integer;
    function AddColumnvalue(aTableID: Integer; aColumnID: Integer;              /// �s�W�@�� ��줺�e (Columnvalue) , -1���s�W����, 1���s�W���\, �榡�ˬd�зR�� TableHandler
                            aColumnRowID: Integer=-1; aValue: String=''): Integer;
    function SetColumnvalue(aTableID: Integer; aColumnID: Integer;              /// �ק�@�� ��줺�e (Columnvalue) , -1���s�W����, 1���s�W���\, �榡�ˬd�зR�� TableHandler
                            aColumnRowID: Integer; aValue: String; aTime:String=''): Integer;
    function SetTable_UpdateTime(aTableID: Integer):Integer;                    /// ���s�]�m Table ���̫��s�ɶ�
    function DelColumnvalue(aTableID, aColumnID, aRowID: Integer): Integer;     /// �̱���R���@�өΦh����줺�e (Columnvalue), -1���R������, 1�H�W���R���ƶq
    function GetTable(aTableID: Integer):TRecordSet;
    function GetTableS(aProjectID:Integer= 0; aOrganizeID:Integer= 0;           /// �̱�����o TableS
                       aUserID:Integer= 0; StartTime:String='';EndTime:String=''; aRequest:String=''): TRecordSet;
    function GetPrivateTableNum(aTableID: Integer; aName:string):Integer;       /// TODO: �d�߯S�w�W�٪�����, [��s�T�{][�|������(????????)]���ƶq�C�g�����\��C SQL �ԭz���u��
    // function GetColumn;
    function GetTable_ColumnNum(aTableID: Integer): Integer;                    /// ���o���w Table ��Column�`��
    function GetTable_ColumnS(aTableID: Integer;aRequest:String=''): TRecordSet;/// ���o���w Table ���Ҧ� Column
    function GetTable_ColumnvalueS(aTableID: Integer;aOrder:String='')          /// ���o���w Table ���Ҧ� Column���e
                                   : TRecordSet;
    function GetColumn(aTableID, aColumnID:Integer):TRecordSet;                 /// �̱�����o Column ��@���
    function GetColumnS(aTableID: Integer= 0; aColumnID: Integer= 0):TRecordSet;/// ?? �̱�����o ColumnS
    function GetColumnvalue(aTableID,aColumnID, aRowID: Integer): TRecordSet;   /// ���o���w Table ���w Column�� �Y�@����줺�e
    function GetColumnvalueS(aTableID:Integer; aColumnID:Integer=0;             /// ���o���w Table ���w Column�� ������줺�e
                             aRowID:Integer=0;aRequest:String=''): TRecordSet;
    function GetColumn_ID( aTableID: Integer=0; aRequest: String='' ):Integer;  /// �̱�����o Column_ID
    function GetColumnvalue_ID( aTableID: Integer=0; aColumnID: Integer= 0;     /// �̱�����o Columnvalue_ID
                                aRequest: String='' ):Integer;
    (** Table: scs_mergecolumn **)
    function GetInfoByTableID(const aTableID: Integer): TRecordSet;             /// �H�l���ID���o�Ҧ�mergecolumn�����
    (** Table: scs_mergetable [�X�֫��A�����] **)
    function AddMergeTable(out aMTableID: Integer; aMTableName: String;         /// �s�W�@�� MergeTable, -1���s�W����, 1���s�W���\
                      aMTableDesc: String; aMUserID:Integer;aMOrgID: Integer;
                      aMProjID: Integer=0): Integer;
    function AddMergeColumn(aMTableID: Integer; aMColumnID: Integer;            /// �s�W�@�� �X�֪�檺 MergeColumn , -1���s�W����, 1���s�W���\ , �榡�ˬd�зR�� TableHandler
                            aTableID: Integer; aColumnID: Integer;
                            aUserID: Integer; aPriority: Integer; aMType:String=''; aMTypeSet:String=''): Integer;
    function GetMergeTable(aMTableID: Integer):TRecordSet;                      /// ���o���w MergeTable
    function GetMergeTable_TableS(aMTableID: Integer;aRequest:String='')        /// ���o���w MergeTable (�`���) ���Ҧ� Table (�l���), �Q�n���D�@���`��Ψ�X�Ӥl���ɥi�Φ� method
                                  : TRecordSet;
    function GetMergeTable_ColumnS(aMTableID:Integer;aMColumnID:Integer=0;      /// ���o���w MergeTable ���Ҧ� Column
                                   aRequest:String=''; aOrder:String=''; aGroupName:String=''):TRecordSet;
    function GetMergeTable_ColumnvalueS(aMTableID: Integer;aOrder:String='';    /// ���o���w MergeTable ���Ҧ� Column���e // �H mergecolumn_id ��GROUP�s��, �u���X���X table_id �̫e���� columnvalue (���`���p�䥦���������Y�� table �� columnvalue �O�@�˪�, �]�����@�N�i)
                                        aMColumnID:Integer=0;aMRowID:Integer=0): TRecordSet;
    function GetMergeColumn(aMTableID,aMColumnID,aTableID,aColumnID: Integer;   /// ���o�@�� �X�֪�檺 MergeColumn
                            aRequest:String=''):TRecordSet;
    function GetMergeColumnvalue_ID( aMTableID: Integer=0;                      /// �̱�����o �X�֫���檺 ColumnValue ID
                                     aRequest: String='' ):Integer;
    function SetMergeTable_UpdateTime(aMTableID: Integer):Integer;
    (** Table: scs_mergecolumn_autofill **)
    function GetMergeColumnAutofill(aMTableID:Integer=0;                        /// ���o�`��۰ʦ^�񪺸��
                                    aMColumnID:Integer=0):TRecordSet;
    (** Table: scs_table_log [����ܰʤ�x] (TODO:20100208�@�o)**)
    function AddTableLog(aTableID,aUserID:Integer;aMessage:String;              /// �s�W�@�Ӫ���ܰʤ�x
                         aValid:Byte=1):Integer;
    function GetTableLogS(aTableID:Integer=0; aUserID:Integer=0;                /// ���o�h�Ӫ���ܰʤ�x
                          aValid:Byte=1; aStartTime:String='';aEndTime:String=''):TRecordSet;
    (** Table: scs_tablelog_title **)
    function AddTablelogTitle(aUserID, aMTable: Integer; aWord: String):Integer;/// �s�W�@��mergetable��x���D
    function GetTablelogTitle_ID(aUserID:Integer=0; aRequest:String=''):Integer;/// �̱�����omergetable��x���D ID
    function GetTablelogTitleS(aTableID:Integer=0; aUserID:Integer=0;           /// ���o�h��mergetable��x���D
                               aStartTime:String='';aEndTime:String=''; aOrder:String=''):TRecordSet;
    (** Table: scs_tablelog_list **)
    function AddTablelogList(aTitleID: Integer; aMessage: String;aMColumnID,    /// �s�W�@��mergetable��x�C��
                             aMRowID:Integer; aError:Boolean=False):Integer;
    function GetTablelogListS(aTitleID: Integer; aRequest:String='';            /// ���o�h��mergetable��x�C��
                              aProjID:Integer=0; aMTableID:Integer=0; aMColID:Integer=0; aMRowID:Integer=0;
                              aUserID: Integer=0; aStartTime:String='';aEndTime:String=''):TRecordSet;
    (** Table: scs_bulletin **)
    function AddBulletin(aUserID:Integer; aType:Integer; aText:String;          /// �s�W�@�Ӥ��i
                         aOrgID:Integer=0; aProjID:Integer=0): Integer;
    function GetBulletin(aBulletinID: Integer): TRecordSet;                     /// ���o���w ID �����i
    function GetBulletinS(aUserID:Integer=0; aOrgID:Integer=0;                  /// �̷ӱ�����o�h�Ӥ��i
                          aProjID:Integer=0; aRequest:String=''; aStartTime:String='';
                          aEndTime:String=''; aOrder:String=''):TRecordSet;
    (** Table: scs_project, scs_project_memeber **)
    function GetProject(aProjectID: Integer):TRecordSet;                        /// ���o��@ Project �����
    function GetProject_MergeTableS(aProjectID: Integer):TRecordSet;            /// ���o��@ Project ���U���h���`��
    function GetProject_Members(aProjectID: Integer):TRecordSet;                /// ���o���w Project ������
    (** Table: scs_version **)
    function GetVersion(aDateTime: String=''): TRecordSet;                      /// ���o�t�Ϊ�����T
    (** Funcitons: **)
    procedure Init;
    function  ConvertBig5Datetime(aDatetime: String): String;                   /// �ഫ Big5 ���ɶ��r�ꬰ�зǮ榡
    (** SQLConnecter: *)
    procedure Pause;                                                            /// SQL ����Ȱ�����, �i�ΨӲ��� Query String
    procedure Play;                                                             /// SQL �����_����
    (** Funcitons: for Test **)
    procedure TestRun;  /// ���������O��@���եΪ�
    procedure DBTest;
    procedure DBTest_UserData;
    procedure DBTest_Table;       // SY, �]�w���~�t���o
    procedure DBTest_MergeTable;  // SY, �]�w���~�t���o
    procedure DBTest_Table_2;     // SY Tw
    procedure DBTest_MergeTable_2;// SY Tw
    procedure DBTest_Table_TZ;      // TianZi ���l���
    procedure DBTest_MergeTable_TZ; // TianZi ���`���
    procedure DBTest_Table_TZ_China;      // TianZi ���l��� china
    procedure DBTest_MergeTable_TZ_China; // TianZi ���`��� china
    procedure DBTest_Table_SY_China;     // SY China
    procedure DBTest_MergeTable_SY_China;// SY China
    procedure DBTest_ColumnValue;
    procedure DBTest_Bulletin;
    procedure DBTest_ConvertMColumnType;
    procedure DBTest_Table_WeekReport;       // �P����
    procedure DBTest_MergeTable_WeekReport;  // �P����
    procedure DBTest_Table_SDBug;            // �Ѫ��s Bug ��
    procedure DBTest_MergeTable_SDBug;       // �Ѫ��s Bug ��
    procedure DBTest_Table_SYSchedule;       // SiYo�i�פ��t��
    procedure DBTest_MergeTable_SYSchedule;  // SiYo�i�פ��t��
    procedure DBTest_Table_WuLin;            // WULIN���l���
    procedure DBTest_MergeTable_WuLin;       // WULIN���`���
    procedure DBTest_AddProjMemberS;         // �M�צ������
    procedure DBTest_AddMergeColumn_Autofill;// �۰ʦ^���`�� - �T�X�@ --> BUG��
    function DBTest_ForUpdateUse: TRecordSet;        //��s��ƥ�
    function DBTest_GetTableUpdateTime(const aTableID: Integer; const aTime: string): TRecordSet;  //���o������̫�ק�ɶ�
    (** Property **)
    property QueryString: String read GetQueryString;
    property SQLConnecter: TSQLConnecter read mSQL;
  end;

  TQueryGenerator = class(TObject)
  private
  public
    function Insert( aTableName:String; aColumnS:array of String;               /// �ѼƲ��� INSERT ���O
                     aValueS:array of String; aIsString: array of Byte ):String;
    function Update( aTableName:String; aColumnS:array of String;               /// �ѼƲ��� UPDATE ���O
                     aValueS:array of String; aIsString: array of Byte; aWhere:String=''):String;
    function Delete( aTableName:String; aWhere: String ):String;                /// �ѼƲ��� DELETE ���O
    function Select:String;                                                     /// �ѼƲ��� SELECT ���O TODO:
    function Implode( aRecordSet: TRecordSet; aColumnName: String ;
                        IsString: Boolean = False):String;                      /// (TODO:�B�@���ӭn�n���� TRecordSet) �ѼƲ��� IN ���O
  end;

var
  gDBManager : TDBManager;
  gQGenerator: TQueryGenerator;

implementation

uses
  WinSock, DoLogin,
  Main, TableHandler, GridCtrl, TableModel;

const
  (** �]���S�ҥ\��g�������`�� *)
  cColumnID_PMName = 1 ;      /// �`��(�������i�ת�) - �����t�d�H�����s�� , �g���C
  cColumnID_ItemConfirm = 11; /// �`��(�������i�ת�) - ��s�T�{�����s�� , �g���C

{ TDBManager }

function TDBManager.GetQueryString: String;
begin
  Result:= mSQL.QueryString ;
end;

constructor TDBManager.Create;
begin
  mSQL := TSQLConnecter.Create( MySQL ) ;
  mSQL.SetComponent( MainForm.gSQLConnection, MainForm.gSQLQuery);
  mSQL.SetParams('scontrol', 'sd', '123123', gDBIP);
  mSQL.Connect;
end;

destructor TDBManager.Destroy;
begin
  mSQL.Disconnect;
  FreeAndNil( mSQL );
  inherited;
end;

(**************************************************************************
 *                        Table: Table, Column, ColumnValue
 *************************************************************************)
function TDBManager.AddTable(out aTableID: Integer; aTableName,
  aTableDesc: String; aUserID, aOrganizeID, aProjectID: Integer): Integer;
var
  vRecordSet: TRecordSet;
begin
  Result:= -1;
  aTableID:= 0;
  mQueryString:= Format( 'INSERT INTO %s(%s, %s, %s, %s, %s, %s, %s) VALUES(''%s'',''%s'', %d, %d, %d, %s, ''%s'')',
                         [ 'scs_table', 'table_name', 'table_description', 'table_create_user_id',
                           'table_create_organize_id', 'table_create_project_id','table_create_time', 'table_expire_time',
                           aTableName, aTableDesc, aUserID, aOrganizeID, aProjectID,
                           'CURRENT_TIMESTAMP()', '0000-00-00 00:00:00']);
  Result:= mSQL.ExecuteQuery( mQueryString );
  if Result= -1 then  // �s�W��ƥ���
    Exit;

  mQueryString:= 'SELECT MAX( table_id ) AS last_id FROM scs_table ';
  vRecordSet  := mSQL.Query( mQueryString );

  if vRecordSet <> nil then
    aTableID:= StrToIntDef( vRecordSet.Row[ 0, 'last_id' ],0 );
end;

function TDBManager.AddColumn(aTableID, aColumnID: Integer; aColumnName,
  aColumnDesc: String; aUserID, aPriority: Integer; aType,
  aTypeSet: String; aWidth, aHeight: Integer): Integer;
begin
  Result:= -1;
  if aTableID <= 0 then    // �����w TableID, ���ηd�F�a..
    Exit;

  if aColumnID <= 0 then   // �����w ColumnID, ���o��ƪ�ثe�� Max Column ID
    aColumnID:= GetColumn_ID(aTableID, 'max');

  Inc( aColumnID );
  mQueryString:= Format('INSERT INTO %s VALUES( %d, %d, ''%s'', ''%s'', %d, %s, %d, ''%s'', ''%s'', %d, %d)',
                        ['scs_column', aTableID, aColumnID, aColumnName, aColumnDesc, aUserID, 'CURRENT_TIMESTAMP()',
                         aPriority, aType, aTypeSet, aWidth, aHeight]);
  Result:= mSQL.ExecuteQuery( mQueryString );
end;

function TDBManager.AddColumnvalue(aTableID, aColumnID: Integer; aColumnRowID: Integer;
                                   aValue: String): Integer;
var
  vIsString: Byte;                                   
begin
  Result:= -1 ;
  if aTableID <= 0 then
    Exit;
  if aColumnID <= 0 then
    Exit;

  if aColumnRowID <= 0 then   // �����w aColumnvalueID, ���o��ƪ�ثe�� Max Column ID
  begin
    aColumnRowID:= GetColumnvalue_ID(aTableID, aColumnID, 'max');
    Inc( aColumnRowID );
  end;

  if aValue='CURRENT_TIMESTAMP()'then
    vIsString:=0
  else
    vIsString:=1;
  mQueryString:= gQGenerator.Insert('scs_columnvalue',
                   ['table_id','column_id','column_row_id','value'],
                   [IntToStr(aTableID),IntToStr(aColumnID),IntToStr(aColumnRowID),aValue],
                   [0, 0, 0, vIsString]);
  Result:= mSQL.ExecuteQuery(mQueryString);
  if Result= -1 then          // �s�W����
    Exit;
end;

function TDBManager.SetColumnvalue(aTableID, aColumnID,
  aColumnRowID: Integer; aValue, aTime: String): Integer;
var
  vIsString: Byte;  
begin
  Result:= -1 ;
  if aTableID <= 0 then
    Exit;
  if aColumnID <= 0 then
    Exit;

  if aValue='CURRENT_TIMESTAMP()' then
    vIsString:=0
  else
    vIsString:=1;
    
  if aTime = '' then
    mQueryString:= gQGenerator.Update('scs_columnvalue',['value', 'datetime'],
                     [aValue,'CURRENT_TIMESTAMP()'],[vIsString, 0],
                     Format( ' table_id=%d AND column_id=%d AND column_row_id=%d ',[aTableID,aColumnID,aColumnRowID]))
  else
    mQueryString:= gQGenerator.Update('scs_columnvalue',['value', 'datetime'],
                     [aValue,aTime],[vIsString, 1],
                     Format( ' table_id=%d AND column_id=%d AND column_row_id=%d ',[aTableID,aColumnID,aColumnRowID]));

  Result:= mSQL.ExecuteQuery(mQueryString);
  if Result= -1 then          // ��s����
    Exit;
end;

function TDBManager.DelColumnvalue(aTableID, aColumnID, aRowID: Integer): Integer;
var
  vWhere: String;
begin
  Result:= -1 ;
  vWhere:= '';

  if aTableID > 0 then
    if vWhere = '' then
      vWhere:= Format(' WHERE table_id = %d ', [aTableID])
    else
      vWhere:= vWhere + Format(' AND (table_id = %d) ', [aTableID]);
  if aColumnID > 0 then
    if vWhere = '' then
      vWhere:= Format(' WHERE column_id = %d ', [aColumnID])
    else
      vWhere:= vWhere + Format(' AND (column_id = %d) ', [aColumnID]);
  if aRowID > 0 then
    if vWhere = '' then
      vWhere:= Format(' WHERE column_row_id = %d ', [aRowID])
    else
      vWhere:= vWhere + Format(' AND (column_row_id = %d) ', [aRowID]);

  mQueryString:= ' DELETE FROM scs_columnvalue ' + vWhere ;
  Result:= mSQL.ExecuteQuery(mQueryString);
end;

function TDBManager.AddMergeTable(out aMTableID: Integer; aMTableName,
  aMTableDesc: String; aMUserID, aMOrgID, aMProjID: Integer): Integer;
var
  vRecordSet: TRecordSet;
begin
  Result:= -1;
  aMTableID:= 0;

  mQueryString:= gQGenerator.Insert('scs_mergetable',
                   ['mergetable_name','mergetable_description','mergetable_create_user_id','mergetable_create_organize_id',
                    'mergetable_create_project_id','mergetable_create_time','mergetable_expire_time'],
                   [aMTableName,aMTableDesc,IntToStr(aMUserID),IntToStr(aMOrgID),
                    IntToStr(aMProjID),'CURRENT_TIMESTAMP()','0000-00-00 00:00:00'],
                   [1, 1, 0, 0, 0, 0, 1]);

  Result:= mSQL.ExecuteQuery(mQueryString);

  mQueryString:= 'SELECT MAX(mergetable_id) AS last_id FROM scs_mergetable ';
  vRecordSet  := mSQL.Query(mQueryString );

  if vRecordSet <> nil then
    aMTableID:= StrToIntDef(vRecordSet.Row[ 0, 'last_id' ], 1);
end;


function TDBManager.GetMergeTable(aMTableID: Integer): TRecordSet;
begin
  Result:= nil;
  if aMTableID <= 0 then
    Exit;

  mQueryString:= ' SELECT smt.*, sp.project_name, so.organize_name ' +
                 ' FROM (scs_mergetable AS smt JOIN scs_organize AS so ON smt.mergetable_create_organize_id=so.organize_id)' +
                 '       JOIN scs_project AS sp ON smt.mergetable_create_project_id = sp.project_id' +
                 ' WHERE mergetable_id = ' + IntToStr(aMTableID);

  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetMergeTable_TableS(aMTableID: Integer;aRequest:String): TRecordSet;
var
  i: Integer;
begin
  Result:= nil;
  if aMTableID <= 0 then
    Exit;

  if aRequest = '' then
    mQueryString:= ' SELECT table_id FROM scs_mergecolumn AS smt ' +
                   ' WHERE mergetable_id = ' + IntToStr(aMTableID) +
                   ' GROUP BY table_id '
  else if aRequest = 'detail' then
    mQueryString:= ' SELECT DISTINCT(table_id),st.* '+
                   ' FROM scs_mergecolumn AS smt NATURAL JOIN scs_table AS st ' +
                   ' WHERE mergetable_id = ' + IntToStr(aMTableID);


  Result := mSQL.Query( mQueryString );

  for i:= Result.RowNums - 1 downto 0 do
  begin
    if Result.Row[i, 'table_id'] = '' then  // TODO: GROUP BY ���ǲ��� null �ȥ����M��
      Result.DeleteRowSet(i)
    else if i >= 1 then                     // �M���ۦP table id �����ƭ�
      if Result.Row[i, 'table_id'] = Result.Row[i-1, 'table_id'] then
        Result.DeleteRowSet(i);
  end;
end;


function TDBManager.GetMergetable_ColumnS(aMTableID: Integer; aMColumnID:Integer;
  aRequest: String; aOrder:String; aGroupName:String): TRecordSet;
var
  i: Integer;  
begin
  Result:= nil;
  if aMTableID <= 0 then
    Exit;
  if aRequest = 'mapping' then        // ���X������
    mQueryString:= Format('SELECT * FROM scs_mergecolumn WHERE mergetable_id=%d ', [aMTableID])
  else if aRequest = 'detail' then    // ���X������ + �Բ�����T
    mQueryString:= ' SELECT smc.*, st.table_name, sc.column_name ' +
                   ' FROM (scs_mergecolumn AS smc NATURAL JOIN scs_table AS st)' +
                   '       NATURAL JOIN scs_column AS sc' +
                   ' WHERE mergetable_id = ' + IntToStr(aMTableID)
  else if aRequest = '' then
    mQueryString:= ' SELECT smc.*, st.table_name,' +
                   ' sc.column_name,sc.column_description,sc.column_create_user_id,' +
                   ' sc.column_create_time,sc.column_priority,sc.column_type,sc.column_typeset,' +
                   ' sc.column_width,sc.column_height '+
                   ' FROM (scs_mergecolumn AS smc NATURAL JOIN scs_table AS st)' +
                   '       NATURAL JOIN scs_column AS sc' +
                   ' WHERE mergetable_id = ' + IntToStr(aMTableID);
  
  // �p�G�����w�� mergecolumn_id �h�[�W
  if aMColumnID > 0 then
    mQueryString := Format('%s AND mergecolumn_id = %d ', [mQueryString, aMColumnID])  ;

  if aGroupName <> '' then // default no Group
    mQueryString := Format('%s GROUP BY %s', [mQueryString, aGroupName]);

  if aOrder = '' then      // default order
    mQueryString := Format('%s ORDER BY mergecolumn_id, table_id, column_id ', [mQueryString])
  else if aOrder = 'table' then      // default order
    mQueryString := Format('%s ORDER BY table_id, column_id ', [mQueryString]);

  Result:= mSQL.Query( mQueryString );

  if Result.RowNums <> 0 then
  if aRequest = '' then   // �D������, �u���o�����ƪ����.. �]�O�]�� DBX ���䴩 Null Join �� Group
  begin
    for i:=Result.RowNums-1 downto 1 do
      if Result.Row[i, 'mergecolumn_id'] = Result.Row[i-1, 'mergecolumn_id'] then
        Result.DeleteRowSet(i);
  end;
end;

function TDBManager.GetMergeTable_ColumnvalueS(aMTableID: Integer;
  aOrder: String; aMColumnID, aMRowID:Integer): TRecordSet;
var
  vRSet: TRecordSet;
  i: Integer;
  vWhere: String;
begin
  Result:= nil;
  if aMTableID <= 0 then
    Exit;

  vWhere:= '';
  if aMRowID <> 0 then
    vWhere:= vWhere + Format(' AND column_row_id = %d ',[aMRowID]);
  
  // �]�� DBX ���䴩, �W����, �u�n�ϥγ·Ъ���k�s��
  vRSet:= gDBManager.GetMergeTable_TableS(aMTableID);
  mQueryString:= Format(' SELECT scv.*, mergetable_id, mergecolumn_id, smc.column_id, mergecolumn_create_user_id ' +
                        ' FROM scs_columnvalue AS scv NATURAL JOIN scs_mergecolumn AS smc '+
                        ' WHERE table_id in(%s) '+ vWhere + 
                        ' ORDER BY column_row_id, mergecolumn_id ASC ',
                        [gQGenerator.Implode(vRSet,'table_id')]);
  Result:= mSQL.Query( mQueryString );
  // TODO: GROUP BY ���ǲ��� null �ȥ����M��
  for i:= Result.RowNums - 1 downto 0 do
  begin
    if Result.Row[i, 'table_id'] = '' then
      Result.DeleteRowSet(i);
  end;
  // TODO: DBX ���䴩, �ϥηj���覡��  �P�B&�ۦP���l������&�P�C�����e����
  for i:= Result.RowNums - 1 downto 1 do
  begin
    if (i <> 0) AND (Result.Row[i,'mergecolumn_id'] = Result.Row[i-1,'mergecolumn_id'])
    AND (Result.Row[i,'column_row_id'] = Result.Row[i-1,'column_row_id'])then
      Result.DeleteRowSet(i);
  end;

  if aMColumnID <> 0 then
  begin
    for i:= Result.RowNums - 1 downto 0 do
    begin
      if IntToStr(aMColumnID) <> Result.Row[i,'mergecolumn_id'] then
        Result.DeleteRowSet(i);
    end;
  end;
end;

function TDBManager.GetMergeColumn(aMTableID, aMColumnID, aTableID,
  aColumnID: Integer; aRequest: String): TRecordSet;
begin
  Result:= nil;
  if aMTableID <= 0 then
    Exit;
  if aMColumnID <= 0 then
    Exit;
  if aTableID <= 0 then
    Exit;
  if aColumnID <= 0 then
    Exit;

  if aRequest = '' then
    mQueryString := Format('SELECT * FROM scs_mergecolumn WHERE mergetable_id= %d AND mergecolumn_id = %d AND table_id= %d AND column_id = %d',
                           [aMTableID, aMColumnID, aTableID, aColumnID])
  else  (** TODO: *)
    mQueryString := Format('SELECT * FROM scs_mergecolumn WHERE mergetable_id= %d AND mergecolumn_id = %d AND table_id= %d AND column_id = %d',
                           [aMTableID, aMColumnID, aTableID, aColumnID]);

  Result := mSQL.Query( mQueryString );

end;

function TDBManager.AddMergeColumn(aMTableID, aMColumnID, aTableID,
  aColumnID, aUserID, aPriority: Integer; aMType:String; aMTypeSet:String): Integer;

begin
  Result:= -1;
  if aMTableID <= 0 then   // �����w PK���@�� MTableID, ���ηd�F�a..
    Exit;
  if aMColumnID <= 0 then  // �����w PK���@�� MTableID, ���ηd�F�a..
    Exit;
  if aTableID <= 0 then    // �����w PK���@�� TableID, ���ηd�F�a..
    Exit;
  if aColumnID <= 0 then   // �����w PK���@�� ColumnID, ���ηd�F�a..
    Exit;

  mQueryString:= gQGenerator.Insert('scs_mergecolumn', ['mergetable_id', 'mergecolumn_id','table_id',
                                    'column_id', 'mergecolumn_create_user_id', 'mergecolumn_create_time',
                                    'mergecolumn_priority','mergecolumn_type','mergecolumn_typeset'],
                                    [IntToStr(aMTableID),IntToStr(aMColumnID),IntToStr(aTableID),IntToStr(aColumnID),
                                     IntToStr(aUserID),'CURRENT_TIMESTAMP()',IntToStr(aPriority),aMType,aMTypeSet],
                                    [0,0,0,0,0,0,0,1,1]);

  Result:= mSQL.ExecuteQuery( mQueryString );
end;


function TDBManager.GetMergeColumnvalue_ID(aMTableID: Integer;
  aRequest: String): Integer;
var
  vRSet: TRecordSet;
begin
  Result:= -1;    // error
  aRequest:= LowerCase(aRequest);

  // �]�� DBX ���䴩�������b where �X�{.., �]���γ·Ъ��@�k
  vRSet := GetMergeTable_TableS(aMTableID);
  if aRequest = 'max' then
  begin
    mQueryString:= Format(' SELECT MAX( column_row_id ) AS ans '+
                          ' FROM scs_columnvalue ' +
                          ' WHERE table_id IN(%s) ', [gQGenerator.Implode(vRSet,'table_id')] )
  end
  else if aRequest = 'total' then
  begin
    mQueryString:= Format(' SELECT COUNT( DISTINCT(column_row_id) ) AS ans'+
                          ' FROM scs_columnvalue '+
                          ' WHERE table_id IN(%s) ', [gQGenerator.Implode(vRSet,'table_id')] )
  end
  else   {TODO:...}
    mQueryString:= Format(' SELECT MAX( column_row_id ) AS ans '+
                          ' FROM scs_columnvalue AS scv NATURAL JOIN scs_mergecolumn AS smc '+
                          ' WHERE mergetable_id=%d ', [aMTableID] ) ;
  FreeAndNil(vRSet);
  vRSet := mSQL.Query( mQueryString );

  if vRSet.RowNums = 0 then
    Result:= 0                  // have no row
  else
    Result:= StrToIntDef( vRSet.Row[ 0, 'ans' ], -1 ) ;
end;


(**************************************************************************
 *                        Table: Log
 *************************************************************************)

function TDBManager.AddTableLog(aTableID, aUserID: Integer;
  aMessage: String; aValid:Byte): Integer;
begin
  Result:= -1 ;
  if aTableID <= 0 then
    Exit;
  if aUserID < 0 then
    Exit;
  if aMessage = '' then
    Exit;

  mQueryString:= gQGenerator.Insert('scs_table_log',
                   ['table_id','user_id','tablelog_message','tablelog_datetime','tablelog_valid'],
                   [IntToStr(aTableID),IntToStr(aUserID),aMessage,'CURRENT_TIMESTAMP()',IntToStr(aValid)],
                   [0, 0, 1, 0, 0]);
  Result:= mSQL.ExecuteQuery( mQueryString );
  if Result= -1 then  // �s�W����
    Exit;
end;

function TDBManager.GetTableLogS(aTableID: Integer; aUserID: Integer;
  aValid: Byte; aStartTime, aEndTime: String): TRecordSet;
var
  vRSet: TRecordSet;
begin
  Result:= nil;

  if (aTableID = 0) AND (aUserID > 0) then /// �w�� User: ���X user �U���M�ת��
  begin
    vRSet:= GetUser_Project(aUserID);

    mQueryString:= Format(' SELECT table_id, table_create_project_id FROM scs_table AS st ' +
                          ' WHERE table_create_project_id IN (%s) ',
                          [gQGenerator.Implode(vRSet,'project_id')] );
    FreeAndNil(vRSet);                      
    vRSet:= mSQL.Query( mQueryString );

    mQueryString:= Format(' SELECT * FROM scs_table_log WHERE table_id IN (%s) ',
                          [gQGenerator.Implode(vRSet,'table_id')] );
    FreeAndNil(vRSet);                      
  end;

  if aValid = 1 then
    mQueryString := mQueryString + ' AND tablelog_valid = 1 ';

  // �ɶ�����  
  if (aStartTime <> '') AND (aEndTime <> '') then
    mQueryString := mQueryString + Format(' AND(tablelog_datetime BETWEEN ''%s'' AND ''%s'' )', [aStartTime,aEndTime])
  else if aStartTime <> '' then
    mQueryString := mQueryString + Format(' AND tablelog_datetime >= ''%s'' ', [aStartTime])
  else if aEndTime <> '' then
    mQueryString := mQueryString + Format(' AND tablelog_datetime <= ''%s'' ', [aEndTime]); 
  
  mQueryString := mQueryString + ' ORDER BY tablelog_datetime ASC ' ;

  Result:= mSQL.Query( mQueryString );
end;


function TDBManager.AddTablelogTitle(aUserID, aMTable: Integer;
  aWord: String): Integer;
begin
  Result:= -1 ;
  if aUserID <= 0 then
    Exit;
  if aWord = '' then
    Exit;

  mQueryString:= gQGenerator.Insert('scs_tablelog_title',
                   ['user_id','mergetable_id','tablelog_title_word','tablelog_create_time'],
                   [IntToStr(aUserID),IntToStr(aMTable),aWord,'CURRENT_TIMESTAMP()'],
                   [0, 0, 1, 0]);
  Result:= mSQL.ExecuteQuery( mQueryString );
  if Result= -1 then  // �s�W����
    Exit;
end;

function TDBManager.GetTablelogTitle_ID(aUserID: Integer;
  aRequest: String): Integer;
var
  vRecordSet : TRecordSet;
begin
  Result:= -1;    // error
  aRequest:= LowerCase(aRequest);

  if aRequest = 'max' then
  begin
    mQueryString:= 'SELECT MAX(tablelog_title_id) AS max_id FROM scs_tablelog_title ' ;
  end
  else if aRequest = '' then     // TODO:
    Exit;

  if aUserID > 0 then // ����P�B���D, ��L user �b�P�ɶ��]�i�঳ LOG, �� same user �P�ɶ��u��s�W�@�� LOG
    mQueryString := mQueryString + Format(' WHERE user_id= %d', [aUserID]);

  vRecordSet := mSQL.Query( mQueryString );

  if vRecordSet.RowNums = 0 then
    Result:= 0                  // have no row
  else
    Result:= StrToIntDef( vRecordSet.Row[ 0, 'max_id' ], -1 ) ;
end;

function TDBManager.GetTablelogTitleS(aTableID, aUserID: Integer;
  aStartTime, aEndTime: String; aOrder:String): TRecordSet;
var
  vRSet: TRecordSet;
begin
  Result:= nil;
  mQueryString:= '';
  
  if (aTableID = 0) AND (aUserID > 0) then /// �w�� User, �S���w Table : ���X user �U���M�� merge ���
  begin
    vRSet:= GetUser_Project(aUserID);

    mQueryString:= Format(' SELECT mergetable_id, mergetable_create_project_id FROM scs_mergetable AS smt ' +
                          ' WHERE mergetable_create_project_id IN (%s) ',
                          [gQGenerator.Implode(vRSet,'project_id')] );
    FreeAndNil(vRSet);                      
    vRSet:= mSQL.Query( mQueryString );

    mQueryString:= Format(' SELECT * FROM scs_tablelog_title WHERE mergetable_id IN (%s) ',
                          [gQGenerator.Implode(vRSet,'mergetable_id')] );
    FreeAndNil(vRSet);                      
  end;

  // �ɶ�����  
  if (aStartTime <> '') AND (aEndTime <> '') then
    mQueryString := mQueryString + Format(' AND(tablelog_create_time BETWEEN ''%s'' AND ''%s'' )', [aStartTime,aEndTime])
  else if aStartTime <> '' then
    mQueryString := mQueryString + Format(' AND tablelog_create_time > ''%s'' ', [aStartTime])
  else if aEndTime <> '' then
    mQueryString := mQueryString + Format(' AND tablelog_create_time < ''%s'' ', [aEndTime]); 

  if aOrder='' then
    mQueryString := mQueryString + ' ORDER BY tablelog_create_time ASC '
  else if aOrder='desc' then
    mQueryString := mQueryString + ' ORDER BY tablelog_create_time DESC ' ;

  Result:= mSQL.Query( mQueryString );
end;

function TDBManager.AddTablelogList(aTitleID: Integer; aMessage: String;
  aMColumnID, aMRowID: Integer; aError: Boolean): Integer;
begin
  Result:= -1 ;
  if aTitleID <= 0 then     // require
    Exit;
  if aMColumnID < 0 then    // optional
    Exit;
  if aMRowID < 0 then       // optional
    Exit;
  if aMessage = '' then
    Exit;

  mQueryString:= gQGenerator.Insert('scs_tablelog_list',
                   ['tablelog_title_id','tablelog_list_message','tablelog_list_error',
                    'mergecolumn_id','mergecolumn_row_id'],
                   [IntToStr(aTitleID),aMessage,IntToStr(Ord(aError)),
                    IntToStr(aMColumnID), IntToStr(aMRowID)],
                   [0, 1, 0, 0, 0, 0]);
  Result:= mSQL.ExecuteQuery( mQueryString );
  if Result= -1 then  // �s�W����
    Exit;
end;

function TDBManager.GetTablelogListS(aTitleID: Integer; aRequest: String;
  aProjID, aMTableID, aMColID, aMRowID, aUserID: Integer; aStartTime,
  aEndTime: String): TRecordSet;
var
  vQuery, vWhere, vTitleFilter: String;
  vRSet: TRecordSet;  
begin
  Result:= nil;

  if aTitleID > 0 then          // �@�����, ������l����, �D�j������
  begin
    if aRequest = 'detail' then
      mQueryString := Format('SELECT * FROM scs_tablelog_list NATURAL JOIN scs_tablelog_title WHERE tablelog_title_id = %d ',[aTitleID])
    else
      mQueryString := Format('SELECT * FROM scs_tablelog_list WHERE tablelog_title_id = %d ',[aTitleID]);
  end
  else
  begin                        // �D�@�����, �j�������l����
    //============== �]�� DBX ���䴩..����q.. (1) �z�� log title ==============
    if aRequest = 'detail' then
      vQuery := ' SELECT stt.* FROM scs_tablelog_title AS stt '
    else
      vQuery := ' SELECT * FROM scs_tablelog_title ' ;

    vWhere := '';
    vTitleFilter:= ''; 
    // aMTableID and aProjID is confict �ܤ@�Y�i, aMTable ����n�B�z, �ӥB���ӴN�� project ���
    if aMTableID > 0 then
    begin
      if vWhere = '' then
        vWhere:= Format(' WHERE mergetable_id = %d ', [aMTableID] )
      else
        vWhere:= Format(' %s AND mergetable_id = %d ',[vWhere, aMTableID] );
    end
    else if aProjID > 0 then
    begin
      vRSet:= GetProject_MergeTableS(aProjID);
      if vWhere = '' then
        vWhere:= Format(' WHERE mergetable_id IN(%s) ', [gQGenerator.Implode(vRSet,'mergetable_id')] )
      else
        vWhere:= Format(' %s AND mergetable_id IN(%s) ',[vWhere, gQGenerator.Implode(vRSet,'mergetable_id')] );
      FreeAndNil(vRSet);
    end;

    if aUserID > 0 then
    begin
      if vWhere = '' then
        vWhere:= Format(' WHERE user_id= %d ', [aUserID] )
      else
        vWhere:= Format(' %s AND user_id= %d ',[vWhere, aUserID] );
    end;

    // �ɶ�����
    if (aStartTime<>'') AND (aEndTime<>'')then
    begin
      if vWhere = '' then
        vWhere:= Format(' WHERE (tablelog_create_time BETWEEN ''%s'' AND ''%s'')', [aStartTime,aEndTime] )
      else
        vWhere:= Format(' %s AND (tablelog_create_time BETWEEN ''%s'' AND ''%s'') ',[vWhere, aStartTime,aEndTime] );
    end
    else if aStartTime <> '' then
    begin
      if vWhere = '' then
        vWhere:= Format(' WHERE tablelog_create_time >= ''%s'' ', [aStartTime] )
      else
        vWhere:= Format(' %s AND tablelog_create_time >= ''%s'' ',[vWhere, aStartTime] );
    end
    else if aEndTime <> '' then
    begin
      if vWhere = '' then
        vWhere:= Format(' WHERE tablelog_create_time <= ''%s'' ', [aEndTime] )
      else
        vWhere:= Format(' %s AND tablelog_create_time <= ''%s'' ',[vWhere, aEndTime] );
    end;

    if (aMTableID>0) OR (aProjID>0) OR (aUserID>0) OR  // ����@�Ӧ��� = �n�j�� log title
       (aStartTime<>'') OR (aEndTime<>'') then
    begin
      vQuery := vQuery + vWhere;
      vRSet:= mSQL.Query( vQuery );
      if vRSet.RowNums = 0 then     // �S������, ��������
      begin
        Result:= TRecordSet.Create;
        Exit;
      end;
      vTitleFilter:= Format(' tablelog_title_id IN (%s)',[gQGenerator.Implode(vRSet,'tablelog_title_id')]);
      FreeAndNil(vRSet);
    end;

    //============== �]�� DBX ���䴩..����q.. (2) �z�� log list ==============
    if aRequest = 'detail' then
      vQuery := ' SELECT * FROM scs_tablelog_list NATURAL JOIN scs_tablelog_title '
    else
      vQuery := ' SELECT * FROM scs_tablelog_title ' ;
    vWhere := '';     // init

    if aMColID > 0 then
    begin
      if vWhere = '' then
        vWhere:= Format(' WHERE mergecolumn_id= %d ', [aMColID] )
      else
        vWhere:= Format(' %s AND mergecolumn_id= %d ',[vWhere, aMColID] );
    end;
    if aMRowID > 0 then
    begin
      if vWhere = '' then
        vWhere:= Format(' WHERE mergecolumn_row_id= %d ', [aMRowID] )
      else
        vWhere:= Format(' %s AND mergecolumn_row_id= %d ',[vWhere, aMRowID] );
    end;

    if vTitleFilter <> '' then
      if vWhere = '' then
        vWhere:= Format(' WHERE %s ', [vTitleFilter] )
      else
        vWhere:= Format(' %s AND %s ',[vWhere, vTitleFilter] );

    mQueryString := vQuery + vWhere ;
  end;

  Result:= mSQL.Query( mQueryString );
  //Result:= mSQL.Query( Format(' SELECT mergetable_id FROM(%s) AS new1 WHERE mergetable_id = 1',[vQuery]) );
end;

(**************************************************************************
 *                        Table: Log End
 *************************************************************************)
 
function TDBManager.GetColumn_ID(aTableID: Integer;
  aRequest: String): Integer;
var
  vRecordSet: TRecordSet;
begin
  Result:= -1;    // error
  aRequest:= LowerCase(aRequest);

  if aRequest = 'max' then
  begin
    mQueryString:= Format(' SELECT MAX( column_id ) AS max_id FROM scs_column WHERE table_id=%d', [aTableID] );
  end
  else if aRequest = '' then // TODO:
  begin
    mQueryString:= Format(' SELECT * FROM scs_column WHERE table_id=%d ', [aTableID]);
  end;

  vRecordSet := mSQL.Query( mQueryString );

  if vRecordSet.RowNums = 0 then
    Result:= 0                  // have no row
  else
    Result:= StrToIntDef( vRecordSet.Row[ 0, 'max_id' ],0) ;
end;

function TDBManager.GetColumnvalue_ID(aTableID, aColumnID: Integer;
  aRequest: String): Integer;
var
  vRecordSet: TRecordSet;
begin
  Result:= -1;    // error
  aRequest:= LowerCase(aRequest);

  if aRequest = 'max' then
  begin
    mQueryString:= Format('SELECT MAX( column_row_id ) AS max_id FROM scs_columnvalue WHERE table_id=%d ', [aTableID] ) ;
  end
  else if aRequest = '' then     // TODO:
  begin
    mQueryString:= Format('SELECT * AS max_id FROM scs_columnvalue WHERE table_id=%d AND column_id=%d ', [aTableID,aColumnID] );
  end;

  vRecordSet := mSQL.Query( mQueryString );

  if vRecordSet.RowNums = 0 then
    Result:= 0                  // have no row
  else
    Result:= StrToIntDef( vRecordSet.Row[ 0, 'max_id' ], -1 ) ;

end;

function TDBManager.GetTable_ColumnNum(aTableID: Integer): Integer;
var
  vRS : TRecordSet ;
begin
  Result:= -1;
  if aTableID <= 0 then
    Exit;

  mQueryString:= Format('SELECT COUNT(*) AS total FROM scs_column WHERE table_id=%d ', [aTableID]);
  vRS:= mSQL.Query( mQueryString );

  Result:= StrToIntDef( vRS.Row[0, 'total'], 0);
end;

function TDBManager.GetTable_ColumnS(aTableID: Integer;aRequest:String): TRecordSet;
begin
  Result:= nil;
  if aTableID <= 0 then
    Exit;
  if aRequest = '' then
    mQueryString:= Format('SELECT * FROM scs_column WHERE table_id=%d ', [aTableID])
  else if aRequest = 'detail' then
  begin
    mQueryString:= ' SELECT st.*, sp.project_name ' +
                   ' FROM (scs_table AS st NATURAL JOIN scs_organize AS sc )' +
                   '       NATURAL JOIN scs_project AS sp ' +
                   ' WHERE table_id = ' + IntToStr(aTableID);
  end;

  Result:= mSQL.Query( mQueryString );
end;

function TDBManager.GetTable_ColumnvalueS(aTableID: Integer;aOrder:String=''): TRecordSet;
begin
  Result:= nil;
  if aTableID <= 0 then
    Exit;
    
  if aOrder = '' then       // �w�] order by row
    mQueryString:= Format('SELECT * FROM scs_columnvalue AS scv WHERE table_id=%d ORDER BY column_row_id ASC', [aTableID]) 
  else if aOrder = 'by_column' then
  begin
    mQueryString:= Format('SELECT * FROM scs_columnvalue WHERE table_id=%d ORDER BY column_id ASC', [aTableID]);
  end;

  Result:= mSQL.Query( mQueryString );
end;

function TDBManager.GetUser(aUserID: Integer): TRecordSet;
begin
  Result:= nil;
  if aUserID <= 0 then
    Exit;
    
  mQueryString := Format('SELECT * FROM scs_user WHERE user_id = %d',[aUserID]);
  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetUser(aFilter: String; aArg: Integer; aArg2: String;
         aRequest: String): TRecordSet;
begin
  Result:= nil;
  mQueryString:= '';

  if aRequest = '' then            // �ϥΪ̪����
  begin
    if aFilter = 'employee_number' then
      mQueryString:= Format( 'SELECT * FROM scs_user WHERE scs_employee_number = %s', [aArg] )
    else if aFilter = 'user_id' then
      mQueryString:= Format( 'SELECT * FROM scs_user WHERE scs_user_id = %s', [aArg] )
    else if aFilter = 'user_account' then
      mQueryString:= Format( 'SELECT * FROM scs_user WHERE user_account = ''%s''', [aArg2] );
  end
  else if aRequest = 'detail' then // �ϥΪ̸ԲӸ��,
  begin
    if aFilter = 'employee_number' then
      mQueryString:= Format( ' SELECT su.*, sgl.*, so.organize_id, so.organize_name ' +
                             ' FROM (scs_user AS su NATURAL JOIN scs_organize AS so) NATURAL JOIN scs_grade_level AS sgl' +
                             ' WHERE employee_number = ''%s''', [aArg2] )
    else if aFilter = 'user_id' then
      mQueryString:= Format( ' SELECT su.*, sgl.*, so.organize_id, so.organize_name ' +
                             ' FROM (scs_user AS su NATURAL JOIN scs_organize AS so) NATURAL JOIN scs_grade_level AS sgl' +
                             ' WHERE user_id = ''%s''', [aArg2] )
    else if aFilter = 'user_account' then
      mQueryString:= Format( ' SELECT su.*, sgl.*, so.organize_id, so.organize_name ' +
                             ' FROM (scs_user AS su NATURAL JOIN scs_organize AS so) NATURAL JOIN scs_grade_level AS sgl' +
                             ' WHERE user_account = ''%s''', [aArg2] );
  end;

  Result := mSQL.Query( mQueryString );
end;

function TDBManager.AddUser(aAccount, aPassword, aNickname: String;
  aExNumber, aEmployeeNum, aPosID, aDepID, aTeamOrgID, aOrgID,
  aLevelID: Integer): Integer;
begin
  Result:= -1;
  if aAccount = '' then
    Exit;
  if aPassword = '' then
    Exit;
  mQueryString:= gQGenerator.Insert('scs_user',
                   ['employee_number','position_id','department_id','team_organize_id','organize_id',
                    'gradelevel_id','user_account','user_password','user_nickname','user_exnumber'],
                   [IntToStr(aEmployeeNum),IntToStr(aPosID),IntToStr(aDepID),IntToStr(aTeamOrgID),IntToStr(aOrgID),
                    IntToStr(aLevelID),aAccount,aPassword,aNickname,IntToStr(aExNumber)],
                   [0, 0, 0, 0, 0, 0, 1, 1, 1, 0]);
  Result:= mSQL.ExecuteQuery(mQueryString);
  if Result= -1 then          // �s�W����
    Exit;
end;

function TDBManager.GetUser_Project(aUserID: Integer): TRecordSet;
begin
  Result:= nil;
  if aUserID <= 0 then
    Exit;

  mQueryString:= Format(' SELECT spm.*, sp.* ' +
                        ' FROM scs_project_member AS spm NATURAL JOIN scs_project AS sp ' +
                        ' WHERE user_id=%d ', [aUserID]);
  Result:= mSQL.Query( mQueryString );
end;

function TDBManager.GetUsers: TRecordSet;
begin
  mQueryString := ' SELECT scs_user.scs_user_id, scs_user.scs_employee_number, scs_user.scs_user_nickname ' +
                  ' FROM scs_user ' ;
  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetUsers(aDepID, aOrgID, aGradeLvID: Integer; aRequest: String): TRecordSet;
var
  vQueryWhere, vQueryLimit: String;
begin
  Result:= nil;
  mQueryString:= '';
  vQueryLimit := '';
  vQueryWhere := '';

  mQueryString := ' SELECT * FROM scs_user ';

  if aDepID > 0 then          // aDepartmentID : ���X�S�w�������ϥΪ�
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE department_id = %d', [aDepID] )
    else
      vQueryWhere:= Format(' %s AND department_id = %d', [vQueryWhere, aDepID] );
  end
  else if aOrgID > 0 then     // aOrganizeID : ���X�S�w��´���ϥΪ�
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE organize_id = %d', [aOrgID] )
    else
      vQueryWhere:= Format(' %s AND organize_id = %d', [vQueryWhere, aOrgID] );
  end
  else if aGradeLvID > 0 then // aGradeLvID : ���X�S�w¾�����ϥΪ�
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE gradelevel_id = %d', [aGradeLvID] )
    else
      vQueryWhere:= Format(' %s AND gradelevel_id = %d', [vQueryWhere, aGradeLvID] );
  end;

  if aRequest = 'online' then       // �O�_���w ���b�u�W���ϥΪ�
  begin
    if vQueryWhere = '' then            
      vQueryWhere:= Format(' WHERE user_logincheck_datetime > NOW() - %d', [cUpdateSecond] )
    else
      vQueryWhere:= Format(' %s AND user_logincheck_datetime > NOW() - %d', [vQueryWhere, cUpdateSecond] );
  end;

  // MainForm.gDebugMemo.Text:= vQuerySelect + vQueryFrom + vQueryWhere;
  mQueryString := mQueryString + vQueryWhere ;
  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetUserStatus(aUserID: Integer): TRecordSet;
begin
  mQueryString:= Format( 'SELECT * FROM scs_user_status WHERE user_id= %d', [aUserID] );
  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetTable(aTableID: Integer): TRecordSet;
begin
  Result:= nil;
  if aTableID <= 0 then
    Exit;

  mQueryString:= ' SELECT st.*, sp.project_name, so.organize_name ' +
                 ' FROM (scs_table AS st JOIN scs_organize AS so ON st.table_create_organize_id=so.organize_id)' +
                 '       JOIN scs_project AS sp ON st.table_create_project_id = sp.project_id' +
                 ' WHERE table_id = ' + IntToStr(aTableID);

  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetTableS(aProjectID, aOrganizeID, aUserID: Integer;
  StartTime, EndTime: String; aRequest:String): TRecordSet;
var
  vQuerySelect, vQueryFrom, vQueryWhere, vQueryLimit: String;
begin
  /// TODO: DBX error ���䴩!!
  Result:= nil;
  vQuerySelect:= '';
  vQueryFrom  := '';
  vQueryLimit := '';
  vQueryWhere := '';
  if aRequest = 'columns' then             // ���X��� + ���榡
  begin
    vQuerySelect:= ' SELECT st.*, sc.* ';
    vQueryFrom  := ' FROM scs_column AS sc NATURAL JOIN scs_table AS st ';
  end
  else if aRequest = 'columnvalues' then   // ���X��� + ���榡 + ��줺�e
  begin
    vQuerySelect:= ' SELECT st.*, sc.*, scv.* '; // TODO:
    vQueryFrom  := ' FROM scs_table AS st RIGHT JOIN scs_column sc ON st.table_id = sc.table_id ,' +
                   '       sc LEFT OUTER JOIN scs_columnvalues AS scv ON sc.column_id = scv.column_id ' ;
  end
  else                                     // ���X���
  begin
    vQuerySelect:= ' SELECT st.* ';
    vQueryFrom  := ' FROM scs_table AS st ';
  end;

  if aProjectID > 0 then        // aProjectID : ���X�S�w�M�ת����
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE table_create_project_id = %d', [aProjectID] )
    else
      vQueryWhere:= Format(' %s AND table_create_project_id = %d',[vQueryWhere, aProjectID] );
  end
  else if aOrganizeID > 0 then  // aOrganizeID : ���X�S�w��´�ҫإߪ����
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE table_create_organize_id = %d',[aOrganizeID] )
    else
      vQueryWhere:= Format(' %s AND table_create_organize_id = %d', [vQueryWhere, aProjectID] );
  end
  else if aUserID > 0 then
  begin
    if vQueryWhere = '' then    // aUserID : ���X�S�w�ϥΪ̩ҫإߪ����
      vQueryWhere:= Format(' WHERE table_create_user_id = %d', [aProjectID] )
    else
      vQueryWhere:= Format(' %s AND table_create_user_id = %d', [vQueryWhere, aProjectID] );
  end;
  mQueryString := vQuerySelect + vQueryFrom + vQueryWhere;
  // MainForm.gDebugMemo.Text:= mQueryString;
  Result := mSQL.Query( mQueryString );
end;


function TDBManager.GetColumn(aTableID, aColumnID: Integer): TRecordSet;
begin
  Result:= nil;
  if aTableID <= 0 then
    Exit;
  if aColumnID <= 0 then
    Exit;

  mQueryString := Format('SELECT * FROM scs_column WHERE table_id= %d AND column_id = %d',[aTableID, aColumnID]);
  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetColumnS(aTableID, aColumnID: Integer): TRecordSet;
begin
  Result:= nil;
end;

function TDBManager.GetColumnvalue(aTableID,aColumnID, aRowID: Integer): TRecordSet;
begin
  Result:= nil;
  if aTableID <= 0 then
    Exit;
  if aColumnID <= 0 then
    Exit;

  mQueryString:= Format(' SELECT * FROM scs_columnvalue WHERE table_id = %d AND column_id = %d AND column_row_id = %d ',
                        [aTableID, aColumnID, aRowID]);
  Result:= mSQL.Query(mQueryString);
end;

function TDBManager.GetColumnvalueS(aTableID,aColumnID, aRowID: Integer; aRequest:String): TRecordSet;
begin
  Result:= nil;
  if aTableID <= 0 then
    Exit;

  if aRequest = '' then
    mQueryString:= Format(' SELECT * FROM scs_columnvalue WHERE table_id = %d ',[aTableID])
  else if aRequest = 'total' then   // ����`�ٮį�
    mQueryString:= Format(' SELECT COUNT(*) AS total FROM scs_columnvalue WHERE table_id = %d ',[aTableID]);

  if aColumnID > 0 then
    mQueryString:= Format(' %s AND column_id = %d ', [mQueryString, aColumnID] )
  else if aRowID > 0 then
    mQueryString:= Format(' %s AND column_row_id = %d ', [mQueryString, aRowID] );

  Result:= mSQL.Query(mQueryString);
end;

(**************************************************************************
 *                        System Functions 
 *************************************************************************)

function TDBManager.SetUserStatus(aUserID: Integer): Integer;
begin
  Result:= -1
end;

function TDBManager.SetUserStatus(aQueryStr: String): Integer;
begin
  Result:= -1 ;
  mQueryString:= aQueryStr;
  
  Result:= mSQL.ExecuteQuery( mQueryString );
  if Result= -1 then  // ��s��ƥ���
    Exit;
    
end;

(**************************************************************************
 *                        Table: Bulletin
 *************************************************************************)
function TDBManager.AddBulletin(aUserID, aType: Integer; aText: String;
  aOrgID, aProjID: Integer): Integer;
begin
  Result:= -1 ;
  if aUserID <= 0 then
    Exit;
  if aType <= 0 then
    Exit;
  if aText = '' then
    Exit;

  mQueryString:= gQGenerator.Insert('scs_bulletin',
                   ['user_id','organize_id','project_id','bulletin_type','bulletin_text','create_datetime'],
                   [IntToStr(aUserID),IntToStr(aOrgID),IntToStr(aProjID),IntToStr(aType),aText,'CURRENT_TIMESTAMP()'],
                   [0, 0, 0, 0, 1, 0]);
  Result:= mSQL.ExecuteQuery( mQueryString );
  if Result= -1 then  // �s�W����
    Exit;
end;

function TDBManager.GetBulletin(aBulletinID: Integer): TRecordSet;
begin
  Result:= nil;
  if aBulletinID <= 0 then
    Exit;
    
  mQueryString := Format('SELECT * FROM scs_bulletin WHERE bulletin_id = %d',[aBulletinID]);
  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetBulletinS(aUserID, aOrgID, aProjID: Integer;
  aRequest: String; aStartTime, aEndTime:String; aOrder:String): TRecordSet;
var
  vSelect, vFrom, vWhere : String;
  i: Integer;
begin
  Result:= nil;
  if aUserID < 0 then
    Exit;
  if aOrgID < 0 then
    Exit;
  if aProjID < 0 then
    Exit;

  vSelect:= '';
  vFrom:= '';
  vWhere:='';
  if aRequest = 'detail' then
  begin
    vSelect := ' SELECT sb.*, so.organize_name, sp.project_name, su.user_nickname ';
    vFrom   := ' FROM ((scs_bulletin AS sb NATURAL JOIN scs_organize AS so) ' +
               ' NATURAL JOIN scs_project AS sp )JOIN scs_user AS su ON su.user_id = sb.user_id' ;
  end
  else if aRequest = '' then
  begin
    vSelect := ' SELECT sb.* ';
    vFrom   := ' FROM scs_bulletin AS sb' ;
  end;

  if aUserID > 0 then          // aUserID : ���X�S�w�ϥΪ� Post �����i
  begin
    if vWhere = '' then
      vWhere:= Format(' WHERE user_id = %d', [aUserID] )
    else
      vWhere:= Format(' %s AND user_id = %d', [vWhere, aUserID] );
  end
  else if aOrgID > 0 then     // aOrganizeID : ���X�S�w��´�����i
  begin
    if vWhere = '' then
      vWhere:= Format(' WHERE organize_id = %d', [aOrgID] )
    else
      vWhere:= Format(' %s AND organize_id = %d', [vWhere, aOrgID] );
  end
  else if aProjID > 0 then    // aProjectID : ���X�S�w�M�ת����i
  begin
    if vWhere = '' then
      vWhere:= Format(' WHERE project_id = %d', [aProjID] )
    else
      vWhere:= Format(' %s AND project_id = %d', [vWhere, aProjID] );
  end;

  // �ɶ�����  
  if (aStartTime <> '') AND (aEndTime <> '') then
    if vWhere = '' then
      vWhere:= Format(' WHERE (create_datetime BETWEEN ''%s'' AND ''%s'' )', [aStartTime,aEndTime])
    else
      vWhere:= vWhere + Format(' AND(create_datetime BETWEEN ''%s'' AND ''%s'' )', [aStartTime,aEndTime])
  else if aStartTime <> '' then
    if vWhere = '' then
      vWhere:= Format(' WHERE create_datetime > ''%s'' ', [aStartTime])
    else
      vWhere:= vWhere + Format(' AND create_datetime > ''%s'' ', [aStartTime])
  else if aEndTime <> '' then
    if vWhere = '' then
      vWhere:= Format(' WHERE create_datetime > ''%s'' ', [aStartTime])
    else
      vWhere:= vWhere + Format(' AND create_datetime < ''%s'' ', [aStartTime]);

  // �ƧǱ���
  if aOrder= 'desc' then
    vWhere:= vWhere + ' Order By create_datetime DESC '
  else if aOrder= '' then
    vWhere:= vWhere + ' Order By create_datetime ASC ';

  mQueryString := vSelect + vFrom + vWhere ;
  Result := mSQL.Query( mQueryString );

  for i:=0 to Result.RowNums-1 do
  begin
    if Result.Row[i, 'bulletin_id'] = '' then  // TODO: DBX1.0 ���ɦ��ǲ��� null �ȥ����M��
      Result.DeleteRowSet(i)
  end;    
end;

(**************************************************************************
 *                        Table: Project, ProJect Member
 *************************************************************************)
function TDBManager.GetProject(aProjectID: Integer): TRecordSet;
begin
  Result:= nil;
end;

function TDBManager.GetProject_MergeTableS(aProjectID: Integer): TRecordSet;
begin
  Result:= nil;

  /// 2010.04.16, �W�[ mergetable_order �ƧǱM�����C ����N���ϥΪ̦۰���ܶ���
  mQueryString:= ' SELECT smt.*, sp.project_id, sp.project_name' +
                 ' FROM scs_mergetable AS smt JOIN scs_project AS sp ON smt.mergetable_create_project_id = sp.project_id' +
                 ' WHERE mergetable_create_project_id = ' + IntToStr(aProjectID) +
                 ' ORDER BY mergetable_order, mergetable_create_time ASC';
  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetProject_Members(aProjectID: Integer): TRecordSet;
begin
  Result:= nil;
end;

(**************************************************************************
 *                        Version
 *************************************************************************)
function TDBManager.GetVersion(aDateTime: String): TRecordSet;
begin
  Result:= nil;
  mQueryString:= ' SELECT * FROM scs_version ';

  if aDateTime <> '' then
    mQueryString:= Format('%s WHERE version_datetime > ''%s''', [mQueryString, aDateTime]);
    
  Result := mSQL.Query( mQueryString );
end;

(**************************************************************************
 *                        FunctionS
 *************************************************************************)
procedure TDBManager.Pause;
begin
  mSQL.Pause := True ;
end;

procedure TDBManager.Play;
begin
  mSQL.Pause := False ;
end;

procedure TDBManager.Init;
begin
  mSQL.Init;
end;

(**************************************************************************
 *                        Test Functions - ���ե�
 *************************************************************************)
procedure TDBManager.DBTest;
begin
  //DBTest_MergeColumnValue;
  //DBTest_MergeTable;
  //DBTest_Table;
  //DBTest_Bulletin;
  //DBTest_ColumnValue;
  //DBTest_ConvertMColumnType;
  //DBTest_Table_2;
  //DBTest_MergeTable_2;
  //DBTest_UserData;
  //DBTest_Table_WeekReport;
  //DBTest_MergeTable_WeekReport;
  //DBTest_Table_SY_China;
  //DBTest_MergeTable_SY_China;
  //DBTest_Table_TZ;      //TianZi �l��
  //DBTest_MergeTable_TZ; //TianZi �`��
  //DBTest_Table_TZ_China;  //TianZi �l��, ����
  //DBTest_MergeTable_TZ_China;  //TianZi �l��, ����
  //DBTest_AddProjMemberS;
  //DBTest_Table_SDBug;
  //DBTest_MergeTable_SDBug;
  //DBTest_Table_SYSchedule; // SiYo�i�פ��t��
  //DBTest_MergeTable_SYSchedule; // SiYo�i�פ��t��
  //DBTest_Table_WuLin;           // WULIN���l���
  //DBTest_MergeTable_WuLin       // WULIN�`��
  //DBTest_AddMergeColumn_Autofill; // BUG ��۰ʦ^��t��
end;

procedure TDBManager.DBTest_UserData;
begin
  AddUser('3263','3263','ZuanKai',3263, 75, 2, 2, 1, 1, 6);
  AddUser('3696','3696','YENYEN',3696,  0, 2, 2, 1, 1, 1);
  AddUser('3225','3225','HOHOOHOH',3225,  0, 2, 2, 1, 1, 1);
  AddUser('3220','3220','KUOOOOO',3220,  0, 2, 2, 1, 1, 1);
  AddUser('3290','3290','WANG',3290,  0, 2, 2, 1, 1, 1);
  AddUser('3219','3219','ACEE',3219,  0, 2, 2, 1, 1, 1);
  AddUser('3604','3604','WizardWu',3604,  0, 2, 2, 1, 1, 1);
  AddUser('3639','3639','ShienYY',3639,  0, 2, 2, 1, 1, 1);
  AddUser('3339','3339','CHH',3339,  0, 2, 2, 1, 1, 1);
  AddUser('3794','3794','MING',3794,  0, 2, 2, 1, 1, 1);
  AddUser('3726','3726','CZR',3726,  0, 2, 2, 1, 1, 1);
  AddUser('3659','3659','HUANGPURE',3659,  0, 2, 2, 1, 1, 1);
  AddUser('3322','3322','AMYLLLLLIU',3322,  0, 2, 2, 1, 1, 1);
  AddUser('3891','3891','HAVEFACE',3891,  0, 2, 2, 1, 1, 1);
  AddUser('3235','3235','KUOZENG',3235,  0, 2, 2, 1, 1, 1);
  AddUser('3656','3656','SHENG',3656,  0, 2, 2, 1, 1, 1);
  AddUser('3346','3346','ChenZU',3346,  0, 2, 2, 1, 1, 1);
  AddUser('3841','3841','EVERTEN',3841,  0, 2, 2, 1, 1, 1);
  AddUser('3846','3846','CLL',3846,  0, 2, 2, 1, 1, 1);
  AddUser('3758','3758','TongZenZen',3758,  0, 2, 2, 1, 1, 1);
  AddUser('3790','3790','ADDMON',3790,  0, 2, 2, 1, 1, 1);
  AddUser('3770','3770','TING',3770,  0, 2, 2, 1, 1, 1);
  AddUser('3549','3549','VICKYPPPAANNN',3549,  0, 2, 2, 1, 1, 1);
  AddUser('3203','3203','ONESHOT',3203,  0, 2, 2, 1, 1, 1);
  AddUser('3254','3254','REEEEDED',3254,  0, 2, 2, 1, 1, 1);
  AddUser('3657','3657','C3',3657,  0, 2, 2, 1, 1, 1);
  AddUser('3213','3213','LHHZ',3213,0, 2, 2, 1, 1, 1);
  AddUser('3752','3752','HSY',3752,  0, 2, 2, 1, 1, 1);
  AddUser('3575','3575','TingY',3575,  0, 2, 2, 1, 1, 1);
  AddUser('3755','3755','FUCKKUO',3755,  0, 2, 2, 1, 1, 1);
  AddUser('3422','3422','GDTK',3422,  0, 2, 2, 1, 1, 1);
  AddUser('3732','3732','TENKEN',3732,  0, 2, 2, 1, 1, 1);
  AddUser('3511','3511','ANNIECHANG',3511,  0, 2, 2, 1, 1, 1);
  AddUser('3371','3371','HOMEB',3371,  0, 2, 2, 1, 1, 1);
  AddUser('3395','3395','LIANGKB',3395,  0, 2, 2, 1, 1, 1);
  AddUser('3828','3828','JU',3828,  0, 2, 2, 1, 1, 1);
  AddUser('3823','3823','CHENSHSH',3823,  0, 2, 2, 1, 1, 1);
  AddUser('3732','3732','YOYEN',3732,  0, 2, 2, 1, 1, 1);
  AddUser('3668','3668','TON',3668,  0, 2, 2, 1, 1, 1);
end;

procedure TDBManager.DBTest_Bulletin;
begin
 // ShowMessage( WideStringToString( StringToWideString('���եΤ��i',950),950) );
 // Exit;
  //gDBManager.SQLConnecter.ExecuteQuery( 'SET NAMES UTF8' );
  gDBManager.SQLConnecter.ExecuteQuery( 'SET NAMES BIG5' );
  gDBManager.AddBulletin( 1, 2,'���եΤ��i' , 2, 1 );
end;

procedure TDBManager.DBTest_Table;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�����i�ת�', '�����i�ת�(�Ѧҥ�)���u�O���եΪ�',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H', '�o�����u�������H��',1,6,'selectbox','"WANG", "TrueIn", "Pure"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '����', '����..�N�O������..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '����', '����..............',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '..............',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�P�{��������', '�P�{��������..�u��3�ص���',1,4,'selectbox','"��", "��", "�C"' );
  gDBManager.AddColumn(vTableID, -1, '����������', '���e������..�u���Ʀr',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '�����w���������', '���....',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�{���H��', '�u���H�W',1,4,'selectbox','"BS","SH", "CB", "ZF"' );
  gDBManager.AddColumn(vTableID, -1, '�{���w���������', '���....',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�', '...............',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���g��s�T�{', 'OOXX....',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '����ɶ�/�ƥ�', '..........',1,4,'textfield','' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '��s���ت�', '��s���ت�(�Ѧҥ�)',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��', '�o�����u�������H��',1,6,'selectbox','"WANG", "TrueIn", "Pure"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '����', '����..�N�O������..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '���ػ���..�N�O....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�w�p��s���e���I����', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '���ɦW��', '....�o���٨S�]�w.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����ɶ�/�����~����/�Y�����ᦳ�ק�]�n����', '���C�⪺���...�B����]�٨S�B�z.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�̫�ק鷺�e', '�ק鷺�e..................',1,4,'selectbox','"BS","SH", "CB", "ZF"' );
  gDBManager.AddColumn(vTableID, -1, '�˴��^��', '......',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����^��', '......',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��էO', '......',1,4,'selectbox','"A��", "B��", "C��"' );
  gDBManager.AddColumn(vTableID, -1, '�˴��H��', '......',1,4,'selectbox','"���", "�ͳ�", "�ӳ�"' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�˴���', '�ѣ�..���n�X�h���]�w, �٨S�B�z, �Ҽ{�˭Ӫ�檩���a..�]�w���..�P��ܪ������}',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�M�צW��', '.......',1,6,'selectbox','"SiYo", "WULIN", "�i��"' );
  gDBManager.AddColumn(vTableID, -1, '�������', '...........',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�w�w���է����ɶ�', '...',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�����H(���������D��)', '.....',1,4,'selectbox','"ZuanKai"' );
  gDBManager.AddColumn(vTableID, -1, '����H', '...................',1,4,'selectbox','"Shen"' );
  gDBManager.AddColumn(vTableID, -1, '�s��', '.....................',1,4,'number','autoincrement' );
  gDBManager.AddColumn(vTableID, -1, '���n�ʵ���', '...............',1,4,'selectbox','"1.�D�`���n","2.�ܭ��n","3.���q���n"' );
  gDBManager.AddColumn(vTableID, -1, '���ն���', '.................',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '���ն��ػ���', '.............',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '����', '.....................',1,4,'selectbox','"A��", "B��", "C��"' );
  gDBManager.AddColumn(vTableID, -1, '���խ��I', '.................',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��','.................',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H��', '.............',1,6,'selectbox','"WANG", "TrueIn", "Pure"' );   ///
  gDBManager.AddColumn(vTableID, -1, '�{���t�d�H��', '.............',1,4,'selectbox','"BS","SH", "CB", "ZF"' );  ///
  gDBManager.AddColumn(vTableID, -1, '�˴��t�d�H��', '.............',1,4,'selectbox','"��","��", "��"' );  ///
end;

procedure TDBManager.DBTest_Table_2;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�����i�ת�', '�����i�ת�(�Ѧҥ�)���u�O���եΪ�',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H', '�����i�ת�-�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '�����i�ת�-���ػ���',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�P�{��������', '�P�{��������..�u��3�ص���',1,4,'selectbox','"��", "��", "�C"' );
  gDBManager.AddColumn(vTableID, -1, '����������', '���e������..�u���Ʀr',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '�����w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�{���H��', '�u���H�W',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );
  gDBManager.AddColumn(vTableID, -1, '�{���w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�', '�����i�ת�-�Ƶ�',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���g��s�T�{', '�����i�ת�-���g��s�T�{',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '����ɶ�/�ƥ�', '�����i�ת�-����ɶ�',1,4,'textfield','' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '��s���ت�', '��s���ت�(�Ѧҥ�)',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��', '�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '����', '����..�N�O������..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '���ػ���..�N�O....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�w�p��s���e���I����', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '���ɦW��', '....�o���٨S�]�w.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����ɶ�/�����~����/�Y�����ᦳ�ק�]�n����', '���C�⪺���,�B����]�٨S�B�z.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�̫�ק鷺�e', '��s���ت�-�̫�ק鷺�e',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��^��', '��s���ت�-�˴��^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����^��', '��s���ت�-�����^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��էO', '��s���ت�-�˴���',1,4,'selectbox','"�TD", "�GD"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�˴���', '���n�X�h���]�w,�٨S�B�z,TODO�˭Ӫ�檩���a..�]�w���..�P��ܪ������}',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '���n�ʵ���','�˴���-���n�ʵ���',1,4,'selectbox','"1.�D�`���n","2.�ܭ��n","3.���q���n"' );
  gDBManager.AddColumn(vTableID, -1, '���ն���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '���ն��ػ���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '����', '�˴���-����',1,4,'selectbox','"A��", "B��", "C��"' );
  gDBManager.AddColumn(vTableID, -1, '���խ��I', '�˴���-���խ��I',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '�w�w���է����ɶ�', '�˴���-�w�w����',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '��������]','���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H��', '�˴���-�����t�d�H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, '�{���t�d�H��', '�˴���-�{���t�d�H��',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, 'BUG��', '�L�~��s�W',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��','BUG��-�����H��auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '����','BUG��-����auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG���e����','BUG��-BUG���e����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�^�����','BUG��-�^�����auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '�B�z���p','BUG��-�B�z���p',1,4,'selectbox','"1.�B�z��","2.�w�ץ�","3.���ץ�"' );
  gDBManager.AddColumn(vTableID, -1, '���p����','BUG��-���p����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��T�{','BUG��-�˴��H��',1,4,'selectbox','"1.�T�{�w�ץ�","2.�|���ץ�"' );
end;

procedure TDBManager.DBTest_MergeTable;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, 'SiYo�T�X�@���', '��X�T�Ӫ��', 1, 2, 1);

  /// �s�W�X�����
  // ��� 1 �]�w  �����t�d�H / �H��  / �����t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 1, 1, 1, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 1, 2, 1, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 1, 3,14, vUserID, vPriority);
  // ��� 2 �]�w  ���� / ���� / ����
  gDBManager.AddMergeColumn(vMTableID, 2, 1, 2, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 2, 2, 2, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 2, 3,10, vUserID, vPriority);
  // ��� 3 �]�w  ����/ ���ػ��� /���ն���
  gDBManager.AddMergeColumn(vMTableID, 3, 1, 3, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 3, 2, 3, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 3, 3, 8, vUserID, vPriority);
  // ��� 4 �]�w  ���ػ���/ �w�p��s���e���I����/ ���ն��ػ���
  gDBManager.AddMergeColumn(vMTableID, 4, 1, 4, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 4, 2, 4, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 4, 3, 9, vUserID, vPriority);
  // ��� 5 �]�w  �P�{��������/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1, 5, vUserID, vPriority);
  // ��� 6 �]�w  ����������/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1, 6, vUserID, vPriority);
  // ��� 7 �]�w  �����w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1, 7, vUserID, vPriority);
  // ��� 8 �]�w  �{���H��/ / �{���t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 8, 1, 8, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 8, 3,15, vUserID, vPriority);
  // ��� 9 �]�w  �{���w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1, 9, vUserID, vPriority);
  // ��� 10 �]�w  �Ƶ�/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1,10, vUserID, vPriority);
  // ��� 11 �]�w  ���g��s�T�{/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1,11, vUserID, vPriority);
  // ��� 12 �]�w  ����ɶ�/�ƥ� / /
  gDBManager.AddMergeColumn(vMTableID,12, 1,12, vUserID, vPriority);
  // ��� 13 �]�w   /���ɦW�� /    ***��s���ت� start
  gDBManager.AddMergeColumn(vMTableID,13, 2, 5, vUserID, vPriority);
  // ��� 14 �]�w   /�����ɶ� /
  gDBManager.AddMergeColumn(vMTableID,14, 2, 6, vUserID, vPriority);
  // ��� 15 �]�w   /�̫�ק鷺�e /
  gDBManager.AddMergeColumn(vMTableID,15, 2, 7, vUserID, vPriority);
  // ��� 16 �]�w   /�˴��^�� /
  gDBManager.AddMergeColumn(vMTableID,16, 2, 8, vUserID, vPriority);
  // ��� 17 �]�w   /�����^�� /
  gDBManager.AddMergeColumn(vMTableID,17, 2, 9, vUserID, vPriority);
  // ��� 18 �]�w   /�˴��էO /
  gDBManager.AddMergeColumn(vMTableID,18, 2,10, vUserID, vPriority);
  // ��� 19 �]�w   /�˴��H�� / �˴��t�d�H��
  gDBManager.AddMergeColumn(vMTableID,19, 2,11, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID,19, 3,16, vUserID, vPriority);
  // ��� 20 �]�w   / / �M�צW��   *** �˴��� start
  gDBManager.AddMergeColumn(vMTableID,20, 3, 1, vUserID, vPriority);
  // ��� 21 �]�w   / / �������
  gDBManager.AddMergeColumn(vMTableID,21, 3, 2, vUserID, vPriority);
  // ��� 22 �]�w   / / �w�w���է������
  gDBManager.AddMergeColumn(vMTableID,22, 3, 3, vUserID, vPriority);
  // ��� 23 �]�w   / / �����H(���������D��)
  gDBManager.AddMergeColumn(vMTableID,23, 3, 4, vUserID, vPriority);
  // ��� 24 �]�w   / / ����H
  gDBManager.AddMergeColumn(vMTableID,24, 3, 5, vUserID, vPriority);
  // ��� 25 �]�w   / / �s��
  gDBManager.AddMergeColumn(vMTableID,25, 3, 6, vUserID, vPriority);
  // ��� 26 �]�w   / / ���n�ʵ���
  gDBManager.AddMergeColumn(vMTableID,26, 3, 7, vUserID, vPriority);
  // ��� 27 �]�w   / / ���խ��I
  gDBManager.AddMergeColumn(vMTableID,27, 3,11, vUserID, vPriority);
  // ��� 28 �]�w   / / ���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��
  gDBManager.AddMergeColumn(vMTableID,28, 3,12, vUserID, vPriority);
end;

procedure TDBManager.DBTest_MergeTable_2;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, 'SiYo�|�X�@���', '��X�|�Ӫ��', 1, 2, 1);

  /// �s�W�X�����
  // ��� 1 �]�w  �����t�d�H / �H��  / �����t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 1, 1, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2, 1, vUserID, vPriority, 'selectbox', '"Yen","HO","KUO","WANG","ACE","WUUUU","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HO","KUO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // ��� 2 �]�w  ���� / ���� / ����
  gDBManager.AddMergeColumn(vMTableID, 2, 1, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3, 4, vUserID, vPriority, 'textfield');
  // ��� 3 �]�w  ����/ ���ػ��� /���ն���
  gDBManager.AddMergeColumn(vMTableID, 3, 1, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 2, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 3, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 4, 2, vUserID, vPriority, 'textfield');
  // ��� 4 �]�w  ���ػ���/ �w�p��s���e���I����/ ���ն��ػ���
  gDBManager.AddMergeColumn(vMTableID, 4, 1, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 2, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 3, 3, vUserID, vPriority, 'textfield');
  // ��� 5 �]�w  �P�{��������/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1, 5, vUserID, vPriority, 'selectbox', '"��", "��", "�C"');
  // ��� 6 �]�w  ����������/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1, 6, vUserID, vPriority, 'number');
  // ��� 7 �]�w  �����w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1, 7, vUserID, vPriority, 'date');
  // ��� 8 �]�w  �{���H��/ / �{���t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 8, 1, 8, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3, 9, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  // ��� 9 �]�w  �{���w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1, 9, vUserID, vPriority, 'date');
  // ��� 10 �]�w  �Ƶ�/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1,10, vUserID, vPriority, 'textfield');
  // ��� 11 �]�w  ���g��s�T�{/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1,11, vUserID, vPriority, 'checkbox');
  // ��� 12 �]�w  ����ɶ�/�ƥ� / /
  gDBManager.AddMergeColumn(vMTableID,12, 1,12, vUserID, vPriority, 'textfield');
  // ��� 13 �]�w   /���ɦW�� /    ***��s���ت� start
  gDBManager.AddMergeColumn(vMTableID,13, 2, 5, vUserID, vPriority, 'textfield');
  // ��� 14 �]�w   /�����ɶ� /
  gDBManager.AddMergeColumn(vMTableID,14, 2, 6, vUserID, vPriority, 'date');
  // ��� 15 �]�w   /�̫�ק鷺�e /
  gDBManager.AddMergeColumn(vMTableID,15, 2, 7, vUserID, vPriority, 'textfield');
  // ��� 16 �]�w   /�˴��^�� /
  gDBManager.AddMergeColumn(vMTableID,16, 2, 8, vUserID, vPriority, 'textfield');
  // ��� 17 �]�w   /�����^�� /
  gDBManager.AddMergeColumn(vMTableID,17, 2, 9, vUserID, vPriority, 'textfield');
  // ��� 18 �]�w   /�˴��էO /
  gDBManager.AddMergeColumn(vMTableID,18, 2,10, vUserID, vPriority, 'selectbox', '"�TD", "�GD"');
  // ��� 19 �]�w   /�˴��H�� / �˴��t�d�H�� / �˴��H��
  gDBManager.AddMergeColumn(vMTableID,19, 2,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // ��� 20 �]�w   / / ���n�ʵ���   *** �˴��� start
  gDBManager.AddMergeColumn(vMTableID,20, 3, 1, vUserID, vPriority, 'selectbox', '"1.�D�`���n","2.�ܭ��n","3.���q���n"');
  // ��� 21 �]�w   / / ���խ��I
  gDBManager.AddMergeColumn(vMTableID,21, 3, 5, vUserID, vPriority, 'textfield');
  // ��� 22 �]�w   / / �w�w���է����ɶ�
  gDBManager.AddMergeColumn(vMTableID,22, 3, 6, vUserID, vPriority, 'date');
  // ��� 23 �]�w   / / ��������]
  gDBManager.AddMergeColumn(vMTableID,23, 3, 7, vUserID, vPriority, 'textfield');
  // ��� 24 �]�w   / / / BUG���e����   *** BUG�� start
  gDBManager.AddMergeColumn(vMTableID,24, 4, 3, vUserID, vPriority, 'textfield');
  // ��� 25 �]�w   / / / �^�����
  gDBManager.AddMergeColumn(vMTableID,25, 4, 4, vUserID, vPriority, 'date');
  // ��� 26 �]�w   / / / �B�z���p
  gDBManager.AddMergeColumn(vMTableID,26, 4, 6, vUserID, vPriority, 'selectbox', '"1.�B�z��","2.�w�ץ�","3.���ץ�"');
  // ��� 27 �]�w   / / / ���p����
  gDBManager.AddMergeColumn(vMTableID,27, 4, 7, vUserID, vPriority, 'textfield');
  // ��� 28 �]�w   / / / �˴��T�{
  gDBManager.AddMergeColumn(vMTableID,28, 4, 8, vUserID, vPriority, 'selectbox', '"1.�T�{�w�ץ�","2.�|���ץ�"');
end;

procedure TDBManager.DBTest_ColumnValue;
var
  vRS : TRecordSet;
  vRowID, i : Integer;
begin
  vRS    := gDBManager.GetTable_ColumnS(1);
  vRowID := gDBManager.GetColumnvalue_ID(1,0,'max');
  Inc( vRowID );
  for i:= 0 to vRS.RowNums - 1 do
    gDBManager.AddColumnvalue(1, i, vRowID,
               Format( '���s��%d����%d�檺��%d�C',[1,i,vRowID]));
  FreeAndNil(vRS);

  vRS    := gDBManager.GetTable_ColumnS(2);
  vRowID := gDBManager.GetColumnvalue_ID(2,0,'max');
  Inc( vRowID );
  for i:= 0 to vRS.RowNums - 1 do
    gDBManager.AddColumnvalue(2, i, vRowID,
               Format( '���s��%d����%d�檺��%d�C',[2,i,vRowID]));
  FreeAndNil(vRS);

  vRS    := gDBManager.GetTable_ColumnS(3);
  vRowID := gDBManager.GetColumnvalue_ID(3,0,'max');
  Inc( vRowID );
  for i:= 0 to vRS.RowNums - 1 do
    gDBManager.AddColumnvalue(3, i, vRowID,
               Format( '���s��%d����%d�檺��%d�C',[3,i,vRowID]));
  FreeAndNil(vRS);
end;


procedure TDBManager.TestRun;
var
  vRecordSet, vRecordSet2 : TRecordSet;
  vTableID: Integer;
  i,j : Integer;
  vMSG: String;
  vRowID, vLogID : Integer;
  vValueList: TStringList;
begin
  DBTest;
  
  Exit;

  vRecordSet:= GetMergeTable_TableS(1, 'detail');

  gMergeTableHandler.DeleteRow(1,7);

  ShowMessage( ConvertBig5Datetime('2010/2/11 �U�� 03:28:55') );
  // �Y�ɰT���j������
  vRecordSet:= GetTablelogListS(0, 'detail', 1, 1, 1);
  ShowMessage(IntToStr(vRecordSet.RowNums));

  DBTest;

  // ���o�`���C�̤j��
  vRowID:= GetMergeColumnvalue_ID(1,'max') + 1 ;
  vRecordSet:= gDBManager.GetMergeTable_ColumnS(1);
  for i:= 0 to vRecordSet.RowNums-1 do
  begin
    ShowMessage(vRecordSet.Row[i, 'column_name']);
  end;
  

  // �s�W�`���@�C
  vValueList:= TStringList.Create;
  vValueList.Add('WANG');
  vValueList.Add('�@���s');
  vValueList.Add('�����k���\��');
  vValueList.Add('�}�񤸯��k�����\��: 1.������˳ƪk���C 2.�k���|�l��');
  vValueList.Add('��');
  vValueList.Add('10%');
  vValueList.Add('2010/02/15');
  vValueList.Add('SH');
  vValueList.Add('2010/02/17');
  vValueList.Add('�S���Ƶ�');
  vValueList.Add('X'); // ���g��s�T�{
  vValueList.Add('�����ٻݭn����z��');       // ��� 12 �]�w  ����ɶ�/�ƥ� / /
  vValueList.Add('�S��������ɦW��');         // ��� 13 �]�w   /���ɦW�� /    ***��s���ت� start
  vValueList.Add('2010/02/29');               // ��� 14 �]�w   /�����ɶ� /
  vValueList.Add('�����̫�ק鷺�e���N��');   // ��� 15 �]�w   /�̫�ק鷺�e /
  vValueList.Add('��BUG');                    // ��� 16 �]�w   /�˴��^�� /
  vValueList.Add('�i����');                   // ��� 17 �]�w   /�����^�� /
  vValueList.Add('A��');                      // ��� 18 �]�w   /�˴��էO /
  vValueList.Add('��');                     // ��� 19 �]�w   /�˴��H�� / �˴��t�d�H��
  vValueList.Add('�_��SiYo');                 // ��� 20 �]�w   / / �M�צW��   *** �˴��� start
  vValueList.Add('2010/03/02');               // ��� 21 �]�w   / / �������
  vValueList.Add('2010/03/05');               // ��� 22 �]�w   / / �w�w���է������
  vValueList.Add('ZuanKai');                   // ��� 23 �]�w   / / �����H(���������D��)
  vValueList.Add('Shen');                   // ��� 24 �]�w   / / ����H
  vValueList.Add('1');                        // ��� 25 �]�w   / / �s��
  vValueList.Add('1.�D�`���n');               // ��� 26 �]�w   / / ���n�ʵ���
  vValueList.Add('���խ��I�N�O�ݦ��S�� BUG'); // ��� 27 �]�w   / / ���խ��I
  vValueList.Add('V');                        // ��� 28 �]�w   / / ���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��

  gMergeTableHandler.NewRow(1, vRowID, vValueList);
  

  // ���X�@���`��(1)�U���Ҧ���줺�e
  vRecordSet:= gDBManager.GetMergeTable_ColumnvalueS(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( Format('��[%s]��,��[%s]�C,��줺�e: [%s] ',
                        [vRecordSet.Row[i,'mergecolumn_id'],
                         vRecordSet.Row[i,'column_row_id'],
                         vRecordSet.Row[i,'value']]));
  end;
  FreeAndNil(vRecordSet);

  // ����`���@����� + Log
  vLogID:= gMergeTableHandler.CreateLog(1, ltMod);
  gMergeTableHandler.ModifyColumnvalue(vLogID,1,1,1,'�o�O�t�d�H?');

  // ���o ��� 1 , �����w��쪺, �̤j�C��
  vRowID:= gDBManager.GetColumnvalue_ID(1, 0, 'max');
  Inc(vRowID);

  // �s�W�@�C
  gTableHandler.NewRow(1,vRowID);

  // ���X�@���`��橳�U�ʥΨ�X�Ӥl���
  vRecordSet := GetMergeTable_TableS(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( '�l���:' + vRecordSet.Row[i, 'table_id']);
  end;
  FreeAndNil(vRecordSet);

  // ���X�@�Ӫ��(1)�U���Ҧ���줺�e
  vRecordSet:= gDBManager.GetTable_ColumnvalueS(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( Format('��[%s]��,��[%s]�C,��줺�e: [%s] ',
                        [vRecordSet.Row[i,'column_id'], vRecordSet.Row[i,'column_row_id'], vRecordSet.Row[i,'value']]));
  end;
  FreeAndNil(vRecordSet);

  // ���X�@�ӨϥΪ̤U���Ҧ��M��
  vRecordSet:= gDBManager.GetUser_Project(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage('�M�צW��: ' + vRecordSet.Row[i,'project_name']);
  end;
  FreeAndNil(vRecordSet);

  // ���XSiYo�M�ת���
  vRecordSet:= gDBManager.GetTableS(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    vMSG:= '';
    vTableID  := StrToIntDef( vRecordSet.Row[i, 'table_id'], 0 );
    vRecordSet2 := gDBManager.GetTable_ColumnS(vTableID);
    vMSG := vMSG + '[' + vRecordSet.Row[ i, 'table_name'] + ']';
    for j:= 0 to vRecordSet2.RowNums -1 do
    begin
      vMSG := vMSG + Format(':%s:%s---', [vRecordSet2.Row[ j, 'column_name'],
                                          vRecordSet2.Row[ j, 'column_description']] );
                                          
      if vRecordSet2.Row[ j, 'column_type'] = 'selectbox' then
      begin
        //ShowMessage(TableHandler.StringToSelectList( vRecordSet2.Row[ j, 'column_typeset'] ));
      end;
    end;
  end;
  FreeAndNil(vRecordSet);

  // ���X user_id = 1 �i�K�����i
  vRecordSet:= gDBManager.GetBulletinS(1,0,0,'detail');
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( Format( '[%s] �M��:%s - �i�K�H:%s - %s - �i�K�ɶ� : %s' ,
                 [vRecordSet.Row[i,'organize_name'], vRecordSet.Row[i,'project_name'],vRecordSet.Row[i,'user_nickname'],vRecordSet.Row[i,'bulletin_text'],vRecordSet.Row[i,'create_datetime']]));
  end;
  FreeAndNil(vRecordSet);
  
  // ���@�����
  gTableHandler.ModifyColumnvalue(1,2,1,'�ڧ��F!!SH . in 2010.01.27', False);

end;

procedure TDBManager.DBTest_ConvertMColumnType;
var
  vRSet, vRSet2: TRecordSet;
  i, vMTableID, vMColumnID, vTableID, vColumnID : Integer;
begin
  vRSet:= gDBManager.GetMergeTable_ColumnS(1);
  for i:=0 to vRSet.RowNums-1 do
  begin
    vTableID  := StrToIntDef(vRSet.Row[i, 'table_id'],0);
    vColumnID := StrToIntDef(vRSet.Row[i, 'column_id'],0);
    vMTableID := StrToIntDef(vRSet.Row[i, 'mergetable_id'],0);
    vMColumnID:= StrToIntDef(vRSet.Row[i, 'mergecolumn_id'],0);
    vRSet2    := gDBManager.GetColumn(vTableID, vColumnID);
    mQueryString:= Format('UPDATE scs_mergecolumn SET mergecolumn_type = ''%s'', mergecolumn_typeset=''%s'' WHERE mergetable_id = %d AND mergecolumn_id = %d AND table_id = %d AND column_id = %d ',
                          [vRSet2.Row[0,'column_type'],vRSet2.Row[0,'column_typeset'],vMTableID,vMColumnID,vTableID,vColumnID]);
    gDBManager.SQLConnecter.ExecuteQuery( mQueryString );
  end;
end;

procedure TDBManager.DBTest_MergeTable_WeekReport;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;

  (***
  // �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, '�M�ץ����i�פu�@��', '�@�g��@��, �ܶ}��', 1, 2, 3);
  // ��� 1 �]�w   ���H��
  gDBManager.AddMergeColumn(vMTableID, 1, 5, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON","�cPY","�EBS","�LZF","ANSN","�ECRZ","�LCB","��SH","CHIU","PONPON"');
  // ��� 2 �]�w   �u�@����
  gDBManager.AddMergeColumn(vMTableID, 2, 5, 2, vUserID, vPriority, 'textarea');
  // ��� 3 �]�w   �����H��
  gDBManager.AddMergeColumn(vMTableID, 3, 5, 3, vUserID, vPriority,'multiselectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON","�cPY","�EBS","�LZF","ANSN","�ECRZ","�LCB","��SH","CHIU","PONPON"');
  // ��� 4 �]�w   �����ɶ�
  gDBManager.AddMergeColumn(vMTableID, 4, 5, 4, vUserID, vPriority,'date');
  // ��� 5 �]�w   �W�g�w����
  gDBManager.AddMergeColumn(vMTableID, 5, 5, 5, vUserID, vPriority,'selectbox', '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  // ��� 6 �]�w   ��g�w�p����
  gDBManager.AddMergeColumn(vMTableID, 6, 5, 6, vUserID, vPriority, 'selectbox','"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  // ��� 7 �]�w   ��g�w�w�����i�׻���
  gDBManager.AddMergeColumn(vMTableID, 7, 5, 7, vUserID, vPriority, 'textfield');
  ***)

  // �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, '�P����', '�@�P�u�ݭn��@�������ݭn���`��ܡH',vUserID, 1, 4);
  // ��� 1 �]�w   �W��
  gDBManager.AddMergeColumn(vMTableID, 1, 6+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON",'+'"�cPY","�EBS","�LZF","ANSN","�ECRZ","�LCB","��SH","CHIU","PONPON"');
  // ��� 2 �]�w   �D�n����
  gDBManager.AddMergeColumn(vMTableID, 2, 6+24, 2, vUserID, vPriority, 'selectbox','"���g�u�@"');
  // ��� 3 �]�w   �ثe�u�@���e
  gDBManager.AddMergeColumn(vMTableID, 3, 6+24, 3, vUserID, vPriority, 'textarea');
  // ��� 4 �]�w   �t�X����
  gDBManager.AddMergeColumn(vMTableID, 4, 6+24, 4, vUserID, vPriority, 'multiselectbox','"����","�{��","���N","�˴�","��B"');
  // ��� 5 �]�w   �t�X�H���W��
  gDBManager.AddMergeColumn(vMTableID, 5, 6+24, 5, vUserID, vPriority,'textarea');
  // ��� 6 �]�w   ����}�l�ɶ�
  gDBManager.AddMergeColumn(vMTableID, 6, 6+24, 6, vUserID, vPriority, 'date');
  // ��� 7 �]�w   ���浲���ɶ�
  gDBManager.AddMergeColumn(vMTableID, 7, 6+24, 7, vUserID, vPriority, 'date');
  // ��� 8 �]�w   �Ƶ�
  gDBManager.AddMergeColumn(vMTableID, 8, 6+24, 8, vUserID, vPriority, 'textarea');
  // ��� 9 �]�w   ��ڶi��
  gDBManager.AddMergeColumn(vMTableID, 9, 6+24, 9, vUserID, vPriority, 'selectbox','"�W�e","�p��","����"');
  // ��� 10 �]�w  �~��F������
  gDBManager.AddMergeColumn(vMTableID,10, 6+24,10, vUserID, vPriority, 'selectbox','"�u","�i","�t"');
end;

procedure TDBManager.DBTest_AddProjMemberS;
var
  i: Integer;
begin
  for i:=1 to 9 do
  begin
    mQueryString:= gQGenerator.Insert('scs_project_member',
                   ['project_id','user_id','projectmemeber_priority','projectunit_id','projectunit_jointime'],
                   [IntToStr(6),IntToStr(i),IntToStr(1),IntToStr(1),'CURRENT_TIMESTAMP()'],
                   [0, 0, 0, 0, 0]);
    gDBManager.SQLConnecter.ExecuteQuery( mQueryString );
  end;
end;


procedure TDBManager.DBTest_AddMergeColumn_Autofill;
var
  vIDSet:String;
begin
  vIDSet:= Format('%d=>%d,%d=>%d,%d=>%d', [1,1, 3,2, 19,5]);        /// �T�X�@ => BUG��
  mQueryString:= gQGenerator.Insert('scs_mergecolumn_autofill',
                   ['autofill_mergecolumn_id_set','autofill_trigger_string',
                    'autofill_trigger_mergetable_id','autofill_trigger_mergecolumn_id','autofill_trigger_columntype',
                    'autofill_dest_mergetable_id','autofill_dest_mergecolumn_id'],
                   [ vIDSet, 'BUG��', IntToStr(10),IntToStr(16)(*fixed*),'textarea',
                     IntToStr(21), IntToStr(3) (*fixed*)],
                   [1, 1, 0, 0, 1, 0, 0]);
  gDBManager.SQLConnecter.ExecuteQuery( mQueryString );                 
end;

procedure TDBManager.DBTest_Table_WeekReport;
var
  vTableID: Integer;
begin
  (***
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�M�ץ����i�פu�@��', '�@�P�u�ݭn��@�������ݭn���`��ܡH',1, 1, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '���H��',  '�i�פu�@��-���H��',1,6,'selectbox','selfname');
  gDBManager.AddColumn(vTableID, -1, '�u�@����',  '�i�פu�@��-�u�@����',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '�����H��',  '�i�פu�@��-�����H��',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '�����ɶ�',  '�i�פu�@��-�����ɶ�',1,6,'date');
  gDBManager.AddColumn(vTableID, -1, '�W�g�w����','�i�פu�@��-�W�g�w����',1,6,'selectbox',     '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  gDBManager.AddColumn(vTableID, -1, '��g�w�p����', '�i�פu�@��-��g�w�p����',1,6,'selectbox','"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  gDBManager.AddColumn(vTableID, -1, '��g�w�w�����i�׻���', '�i�פu�@��-�w�w�����i�׻���',1,6,'textfield');
  **)
  
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�P����', '�@�P�u�ݭn��@�������ݭn���`��ܡH',1, 1, 4);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�W��',    '�����P����-�W��',1,6,'function','selfname');
  gDBManager.AddColumn(vTableID, -1, '�D�n����','�����P����-�D�n����',1,6,'selectbox','"���g�u�@"');
  gDBManager.AddColumn(vTableID, -1, '�ثe�u�@���e','�����P����-�ثe�u�@���e',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '�t�X����', '�����P����-�W��',1,6,'checkbox','"����","�{��","���N","�˴�","��B"');
  gDBManager.AddColumn(vTableID, -1, '�t�X�H���W��', '�����P����-�W��',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '����}�l�ɶ�', '����ɶ�',1,6,'date');
  gDBManager.AddColumn(vTableID, -1, '���浲���ɶ�', '����ɶ�',1,6,'date');
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�', '�Ƶ�',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '��ڶi��', '��ڶi��-���W�h�C',1,6,'selectbox','"�W�e","�p��","����"');
  gDBManager.AddColumn(vTableID, -1, '�~��F������', '�~��F������-���W�h',1,6,'selectbox','"�u","�i","�t"');
end;

(**************************************************************************
 *                        Test Functions End - ���ե� End
 *************************************************************************)

function TDBManager.ConvertBig5Datetime(aDatetime: String): String;
var
  vPos1, vPos2: Integer;
  vHour: String;
begin
  try
    Result:= aDatetime;
    vPos1 := Pos('�W�� ', aDatetime);
    vPos2 := Pos('�U�� ', aDatetime);

    // �� �W��  �U�� �� Big5 SQL DB ��12�p�ɨ��ഫ��24�p�ɨ� (TODO: ���n���@�k...)
    if vPos1 > 0 then
      Result:= StringReplace(Result, '�W�� ', '',[rfReplaceAll, rfIgnoreCase])
    else if vPos2 > 0 then
    begin
      Result:= StringReplace(Result, '�U�� ', '',[rfReplaceAll, rfIgnoreCase]);
      vPos2 := Pos(':', Result);
      vHour := Copy(Result, vPos2-Length('12'), Length('12'));
      if vHour <> '12' then  // (12:30 �k���� �U�� 12:30 �ӫD �W�� 12:30 )
        vHour := IntToStr( StrToIntDef(vHour, 0) + 12);
      Result:= Copy(Result,0, vPos2-Length('12')-1) + vHour + Copy(Result,vPos2, Length(Result)-vPos2+1);
    end;

    Result:= StringReplace(Result, '/', '-',[rfReplaceAll, rfIgnoreCase]);  //  2010/02  to  2010-02

  except                                    
    on E : Exception do
      ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;  
end;

function TDBManager.SetPass(aID:integer;aValue: String): integer;
begin
  Result:= -1 ;

  mQueryString:= gQGenerator.Update('scs_user',['user_password'],[aValue],[1],
                 Format( ' user_id=%d ',[aID]));
  Result:= mSQL.ExecuteQuery(mQueryString);
  if Result= -1 then          // ��s����
    Exit;
end;

procedure TDBManager.DBTest_MergeTable_TZ;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, 'TianZi �|�X�@���', '��X�|�Ӫ��', 1, 2, 1);

  /// �s�W�X�����
  // ��� 1 �]�w  �����t�d�H / �H��  / �����t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 1, 1+6, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+6, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+6, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+6, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // ��� 2 �]�w  ���� / ���� / ����
  gDBManager.AddMergeColumn(vMTableID, 2, 1+6, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+6, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+6, 4, vUserID, vPriority, 'textfield');
  // ��� 3 �]�w  ����/ ���ػ��� /���ն���
  gDBManager.AddMergeColumn(vMTableID, 3, 1+6, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+6, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+6, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+6, 2, vUserID, vPriority, 'textfield');
  // ��� 4 �]�w  ���ػ���/ �w�p��s���e���I����/ ���ն��ػ���
  gDBManager.AddMergeColumn(vMTableID, 4, 1+6, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+6, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+6, 3, vUserID, vPriority, 'textfield');
  // ��� 5 �]�w  �P�{��������/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+6, 5, vUserID, vPriority, 'selectbox', '"��", "��", "�C"');
  // ��� 6 �]�w  ����������/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+6, 6, vUserID, vPriority, 'number');
  // ��� 7 �]�w  �����w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+6, 7, vUserID, vPriority, 'date');
  // ��� 8 �]�w  �{���H��/ / �{���t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 8, 1+6, 8, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+6, 9, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  // ��� 9 �]�w  �{���w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+6, 9, vUserID, vPriority, 'date');
  // ��� 10 �]�w  �Ƶ�/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+6,10, vUserID, vPriority, 'textfield');
  // ��� 11 �]�w  ���g��s�T�{/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+6,11, vUserID, vPriority, 'checkbox');
  // ��� 12 �]�w  ����ɶ�/�ƥ� / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+6,12, vUserID, vPriority, 'textfield');
  // ��� 13 �]�w   /���ɦW�� /    ***��s���ت� start
  gDBManager.AddMergeColumn(vMTableID,13, 2+6, 5, vUserID, vPriority, 'textfield');
  // ��� 14 �]�w   /�����ɶ� /
  gDBManager.AddMergeColumn(vMTableID,14, 2+6, 6, vUserID, vPriority, 'date');
  // ��� 15 �]�w   /�̫�ק鷺�e /
  gDBManager.AddMergeColumn(vMTableID,15, 2+6, 7, vUserID, vPriority, 'textfield');
  // ��� 16 �]�w   /�˴��^�� /
  gDBManager.AddMergeColumn(vMTableID,16, 2+6, 8, vUserID, vPriority, 'textfield');
  // ��� 17 �]�w   /�����^�� /
  gDBManager.AddMergeColumn(vMTableID,17, 2+6, 9, vUserID, vPriority, 'textfield');
  // ��� 18 �]�w   /�˴��էO /
  gDBManager.AddMergeColumn(vMTableID,18, 2+6,10, vUserID, vPriority, 'selectbox', '"�TD", "�GD"');
  // ��� 19 �]�w   /�˴��H�� / �˴��t�d�H�� / �˴��H��
  gDBManager.AddMergeColumn(vMTableID,19, 2+6,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+6,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+6, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // ��� 20 �]�w   / / ���n�ʵ���   *** �˴��� start
  gDBManager.AddMergeColumn(vMTableID,20, 3+6, 1, vUserID, vPriority, 'selectbox', '"1.�D�`���n","2.�ܭ��n","3.���q���n"');
  // ��� 21 �]�w   / / ���խ��I
  gDBManager.AddMergeColumn(vMTableID,21, 3+6, 5, vUserID, vPriority, 'textfield');
  // ��� 22 �]�w   / / �w�w���է����ɶ�
  gDBManager.AddMergeColumn(vMTableID,22, 3+6, 6, vUserID, vPriority, 'date');
  // ��� 23 �]�w   / / ��������]
  gDBManager.AddMergeColumn(vMTableID,23, 3+6, 7, vUserID, vPriority, 'textfield');
  // ��� 24 �]�w   / / / BUG���e����   *** BUG�� start
  gDBManager.AddMergeColumn(vMTableID,24, 4+6, 3, vUserID, vPriority, 'textfield');
  // ��� 25 �]�w   / / / �^�����
  gDBManager.AddMergeColumn(vMTableID,25, 4+6, 4, vUserID, vPriority, 'date');
  // ��� 26 �]�w   / / / �B�z���p
  gDBManager.AddMergeColumn(vMTableID,26, 4+6, 6, vUserID, vPriority, 'selectbox', '"1.�B�z��","2.�w�ץ�","3.���ץ�"');
  // ��� 27 �]�w   / / / ���p����
  gDBManager.AddMergeColumn(vMTableID,27, 4+6, 7, vUserID, vPriority, 'textfield');
  // ��� 28 �]�w   / / / �˴��T�{
  gDBManager.AddMergeColumn(vMTableID,28, 4+6, 8, vUserID, vPriority, 'selectbox', '"1.�T�{�w�ץ�","2.�|���ץ�"');

end;

procedure TDBManager.DBTest_Table_TZ;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�����i�ת�', '�����i�ת�(�Ѧҥ�)���u�O���եΪ�',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H', '�����i�ת�-�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '�����i�ת�-���ػ���',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�P�{��������', '�P�{��������..�u��3�ص���',1,4,'selectbox','"��", "��", "�C"' );
  gDBManager.AddColumn(vTableID, -1, '����������', '���e������..�u���Ʀr',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '�����w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�{���H��', '�u���H�W',1,4,'selectbox','"���H��","������","�L�P��","���F��","���[�|","�����M","���x�M","����X","�״I�s","�ΰ���","���s�w","���f��","���ѻ�","���E��","�Q�移","�ˤj�_","�L�Υ�","�f�M��","�L�۱j","�P�F��","�Y�R�a","�i�Y��","�����w"' );
  gDBManager.AddColumn(vTableID, -1, '�{���w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�', '�����i�ת�-�Ƶ�',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���g��s�T�{', '�����i�ת�-���g��s�T�{',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '����ɶ�/�ƥ�', '�����i�ת�-����ɶ�',1,4,'textfield','' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '��s���ت�', '��s���ت�(�Ѧҥ�)',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��', '�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '����', '����..�N�O������..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '���ػ���..�N�O....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�w�p��s���e���I����', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '���ɦW��', '....�o���٨S�]�w.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����ɶ�/�����~����/�Y�����ᦳ�ק�]�n����', '���C�⪺���,�B����]�٨S�B�z.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�̫�ק鷺�e', '��s���ت�-�̫�ק鷺�e',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��^��', '��s���ت�-�˴��^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����^��', '��s���ت�-�����^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��էO', '��s���ت�-�˴���',1,4,'selectbox','"�TD", "�GD"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�˴���', '���n�X�h���]�w,�٨S�B�z,TODO�˭Ӫ�檩���a..�]�w���..�P��ܪ������}',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '���n�ʵ���','�˴���-���n�ʵ���',1,4,'selectbox','"1.�D�`���n","2.�ܭ��n","3.���q���n"' );
  gDBManager.AddColumn(vTableID, -1, '���ն���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '���ն��ػ���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '����', '�˴���-����',1,4,'selectbox','"A��", "B��", "C��"' );
  gDBManager.AddColumn(vTableID, -1, '���խ��I', '�˴���-���խ��I',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '�w�w���է����ɶ�', '�˴���-�w�w����',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '��������]','���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H��', '�˴���-�����t�d�H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, 'cheng shi fu ze ren yuan ', 'jian ce dan -cheng shi fu ze ren yuan ',1,4,'selectbox','"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, 'BUG��', '�L�~��s�W',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��','BUG��-�����H��auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '����','BUG��-����auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG���e����','BUG��-BUG���e����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�^�����','BUG��-�^�����auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '�B�z���p','BUG��-�B�z���p',1,4,'selectbox','"1.�B�z��","2.�w�ץ�","3.���ץ�"' );
  gDBManager.AddColumn(vTableID, -1, '���p����','BUG��-���p����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��T�{','BUG��-�˴��H��',1,4,'selectbox','"1.�T�{�w�ץ�","2.�|���ץ�"' );
end;


procedure TDBManager.DBTest_MergeTable_TZ_China;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, '[����]TianZi �|�X�@���', '��X�|�Ӫ��', 1, 1, 4);

  /// �s�W�X�����
  // ��� 1 �]�w  �����t�d�H / �H��  / �����t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 1, 1+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+24, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // ��� 2 �]�w  ���� / ���� / ����
  gDBManager.AddMergeColumn(vMTableID, 2, 1+24, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+24, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+24, 4, vUserID, vPriority, 'textfield');
  // ��� 3 �]�w  ����/ ���ػ��� /���ն���
  gDBManager.AddMergeColumn(vMTableID, 3, 1+24, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+24, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+24, 2, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+24, 2, vUserID, vPriority, 'textarea');
  // ��� 4 �]�w  ���ػ���/ �w�p��s���e���I����/ ���ն��ػ���
  gDBManager.AddMergeColumn(vMTableID, 4, 1+24, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+24, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+24, 3, vUserID, vPriority, 'textarea');
  // ��� 5 �]�w  �P�{��������/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+24, 5, vUserID, vPriority, 'selectbox', '"��", "��", "�C"');
  // ��� 6 �]�w  ����������/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+24, 6, vUserID, vPriority, 'selectbox', '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"');
  // ��� 7 �]�w  �����w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+24, 7, vUserID, vPriority, 'date');
  // ��� 8 �]�w  �{���H��/ / �{���t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 8, 1+24, 8, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+24, 9, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  // ��� 9 �]�w  �{���w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+24, 9, vUserID, vPriority, 'date');
  // ��� 10 �]�w  �Ƶ�/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+24,10, vUserID, vPriority, 'textarea');
  // ��� 11 �]�w  ���g��s�T�{/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+24,11, vUserID, vPriority, 'selectbox','"�T�{��s","����"');
  // ��� 12 �]�w  ����ɶ�/�ƥ� / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+24,12, vUserID, vPriority, 'textarea');
  // ��� 13 �]�w   /���ɦW�� /    ***��s���ت� start
  gDBManager.AddMergeColumn(vMTableID,13, 2+24, 5, vUserID, vPriority, 'textfield');
  // ��� 14 �]�w   /�����ɶ� /
  gDBManager.AddMergeColumn(vMTableID,14, 2+24, 6, vUserID, vPriority, 'date');
  // ��� 15 �]�w   /�̫�ק鷺�e /
  gDBManager.AddMergeColumn(vMTableID,15, 2+24, 7, vUserID, vPriority, 'textarea');
  // ��� 16 �]�w   /�˴��^�� /
  gDBManager.AddMergeColumn(vMTableID,16, 2+24, 8, vUserID, vPriority, 'textarea');
  // ��� 17 �]�w   /�����^�� /
  gDBManager.AddMergeColumn(vMTableID,17, 2+24, 9, vUserID, vPriority, 'textarea');
  // ��� 18 �]�w   /�˴��էO /
  gDBManager.AddMergeColumn(vMTableID,18, 2+24,10, vUserID, vPriority, 'selectbox', '"�TD", "�GD"');
  // ��� 19 �]�w   /�˴��H�� / �˴��t�d�H�� / �˴��H��
  gDBManager.AddMergeColumn(vMTableID,19, 2+24,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+24,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+24, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // ��� 20 �]�w   / / ���n�ʵ���   *** �˴��� start
  gDBManager.AddMergeColumn(vMTableID,20, 3+24, 1, vUserID, vPriority, 'selectbox', '"1.�D�`���n","2.�ܭ��n","3.���q���n"');
  // ��� 21 �]�w   / / ���խ��I
  gDBManager.AddMergeColumn(vMTableID,21, 3+24, 5, vUserID, vPriority, 'textarea');
  // ��� 22 �]�w   / / �w�w���է����ɶ�
  gDBManager.AddMergeColumn(vMTableID,22, 3+24, 6, vUserID, vPriority, 'date');
  // ��� 23 �]�w   / / ��������]
  gDBManager.AddMergeColumn(vMTableID,23, 3+24, 7, vUserID, vPriority, 'textarea');
  // ��� 24 �]�w   / / / BUG���e����   *** BUG�� start
  gDBManager.AddMergeColumn(vMTableID,24, 4+24, 3, vUserID, vPriority, 'textarea');
  // ��� 25 �]�w   / / / �^�����
  gDBManager.AddMergeColumn(vMTableID,25, 4+24, 4, vUserID, vPriority, 'date');
  // ��� 26 �]�w   / / / �B�z���p
  gDBManager.AddMergeColumn(vMTableID,26, 4+24, 6, vUserID, vPriority, 'selectbox', '"1.�B�z��","2.�w�ץ�","3.���ץ�"');
  // ��� 27 �]�w   / / / ���p����
  gDBManager.AddMergeColumn(vMTableID,27, 4+24, 7, vUserID, vPriority, 'textarea');
  // ��� 28 �]�w   / / / �˴��T�{
  gDBManager.AddMergeColumn(vMTableID,28, 4+24, 8, vUserID, vPriority, 'selectbox', '"1.�T�{�w�ץ�","2.�|���ץ�"');
end;

procedure TDBManager.DBTest_Table_TZ_China;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�����i�ת�', '�����i�ת�(�Ѧҥ�)���u�O���եΪ�',1, 1, 4);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H', '�����i�ת�-�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '�����i�ת�-���ػ���',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�P�{��������', '�P�{��������..�u��3�ص���',1,4,'selectbox','"��", "��", "�C"' );
  gDBManager.AddColumn(vTableID, -1, '����������', '���e������..�u���Ʀr',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '�����w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, 'cheng shi ren yuan ', 'zhi neng tian ren ming ',1,4,'selectbox','"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"' );
  gDBManager.AddColumn(vTableID, -1, '�{���w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�', '�����i�ת�-�Ƶ�',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���g��s�T�{', '�����i�ת�-���g��s�T�{',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '����ɶ�/�ƥ�', '�����i�ת�-����ɶ�',1,4,'textfield','' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '��s���ت�', '��s���ت�(�Ѧҥ�)',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��', '�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '����', '����..�N�O������..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '���ػ���..�N�O....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�w�p��s���e���I����', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '���ɦW��', '....�o���٨S�]�w.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����ɶ�/�����~����/�Y�����ᦳ�ק�]�n����', '���C�⪺���,�B����]�٨S�B�z.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�̫�ק鷺�e', '��s���ت�-�̫�ק鷺�e',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��^��', '��s���ت�-�˴��^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����^��', '��s���ت�-�����^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��էO', '��s���ت�-�˴���',1,4,'selectbox','"�TD", "�GD"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�˴���', '���n�X�h���]�w,�٨S�B�z,TODO�˭Ӫ�檩���a..�]�w���..�P��ܪ������}',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '���n�ʵ���','�˴���-���n�ʵ���',1,4,'selectbox','"1.�D�`���n","2.�ܭ��n","3.���q���n"' );
  gDBManager.AddColumn(vTableID, -1, '���ն���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '���ն��ػ���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '����', '�˴���-����',1,4,'selectbox','"A��", "B��", "C��"' );
  gDBManager.AddColumn(vTableID, -1, '���խ��I', '�˴���-���խ��I',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '�w�w���է����ɶ�', '�˴���-�w�w����',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '��������]','���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H��', '�˴���-�����t�d�H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, 'cheng shi fu ze ren yuan ', 'jian ce dan -cheng shi fu ze ren yuan ',1,4,'selectbox','"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///


  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, 'BUG��', '�L�~��s�W',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��','BUG��-�����H��auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '����','BUG��-����auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG���e����','BUG��-BUG���e����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�^�����','BUG��-�^�����auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '�B�z���p','BUG��-�B�z���p',1,4,'selectbox','"1.�B�z��","2.�w�ץ�","3.���ץ�"' );
  gDBManager.AddColumn(vTableID, -1, '���p����','BUG��-���p����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��T�{','BUG��-�˴��H��',1,4,'selectbox','"1.�T�{�w�ץ�","2.�|���ץ�"' );
end;


procedure TDBManager.DBTest_MergeTable_SY_China;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, '[����]SiYo�|�X�@���', '��X�|�Ӫ��', 1, 2, 1);

  /// �s�W�X�����
  // ��� 1 �]�w  �����t�d�H / �H��  / �����t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 1, 1+10, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+10, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+10, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+10, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // ��� 2 �]�w  ���� / ���� / ����
  gDBManager.AddMergeColumn(vMTableID, 2, 1+10, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+10, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+10, 4, vUserID, vPriority, 'textfield');
  // ��� 3 �]�w  ����/ ���ػ��� /���ն���
  gDBManager.AddMergeColumn(vMTableID, 3, 1+10, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+10, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+10, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+10, 2, vUserID, vPriority, 'textfield');
  // ��� 4 �]�w  ���ػ���/ �w�p��s���e���I����/ ���ն��ػ���
  gDBManager.AddMergeColumn(vMTableID, 4, 1+10, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+10, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+10, 3, vUserID, vPriority, 'textfield');
  // ��� 5 �]�w  �P�{��������/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+10, 5, vUserID, vPriority, 'selectbox', '"��", "��", "�C"');
  // ��� 6 �]�w  ����������/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+10, 6, vUserID, vPriority, 'number');
  // ��� 7 �]�w  �����w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+10, 7, vUserID, vPriority, 'date');
  // ��� 8 �]�w  �{���H��/ / �{���t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 8, 1+10, 8, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+10, 9, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  // ��� 9 �]�w  �{���w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+10, 9, vUserID, vPriority, 'date');
  // ��� 10 �]�w  �Ƶ�/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+10,10, vUserID, vPriority, 'textfield');
  // ��� 11 �]�w  ���g��s�T�{/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+10,11, vUserID, vPriority, 'checkbox');
  // ��� 12 �]�w  ����ɶ�/�ƥ� / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+10,12, vUserID, vPriority, 'textfield');
  // ��� 13 �]�w   /���ɦW�� /    ***��s���ت� start
  gDBManager.AddMergeColumn(vMTableID,13, 2+10, 5, vUserID, vPriority, 'textfield');
  // ��� 14 �]�w   /�����ɶ� /
  gDBManager.AddMergeColumn(vMTableID,14, 2+10, 6, vUserID, vPriority, 'date');
  // ��� 15 �]�w   /�̫�ק鷺�e /
  gDBManager.AddMergeColumn(vMTableID,15, 2+10, 7, vUserID, vPriority, 'textfield');
  // ��� 16 �]�w   /�˴��^�� /
  gDBManager.AddMergeColumn(vMTableID,16, 2+10, 8, vUserID, vPriority, 'textfield');
  // ��� 17 �]�w   /�����^�� /
  gDBManager.AddMergeColumn(vMTableID,17, 2+10, 9, vUserID, vPriority, 'textfield');
  // ��� 18 �]�w   /�˴��էO /
  gDBManager.AddMergeColumn(vMTableID,18, 2+10,10, vUserID, vPriority, 'selectbox', '"�TD", "�GD"');
  // ��� 19 �]�w   /�˴��H�� / �˴��t�d�H�� / �˴��H��
  gDBManager.AddMergeColumn(vMTableID,19, 2+10,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+10,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+10, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');

  // ��� 20 �]�w   / / ���n�ʵ���   *** �˴��� start
  gDBManager.AddMergeColumn(vMTableID,20, 3+10, 1, vUserID, vPriority, 'selectbox', '"1.�D�`���n","2.�ܭ��n","3.���q���n"');
  // ��� 21 �]�w   / / ���խ��I
  gDBManager.AddMergeColumn(vMTableID,21, 3+10, 5, vUserID, vPriority, 'textfield');
  // ��� 22 �]�w   / / �w�w���է����ɶ�
  gDBManager.AddMergeColumn(vMTableID,22, 3+10, 6, vUserID, vPriority, 'date');
  // ��� 23 �]�w   / / ��������]
  gDBManager.AddMergeColumn(vMTableID,23, 3+10, 7, vUserID, vPriority, 'textfield');
  // ��� 24 �]�w   / / / BUG���e����   *** BUG�� start
  gDBManager.AddMergeColumn(vMTableID,24, 4+10, 3, vUserID, vPriority, 'textfield');
  // ��� 25 �]�w   / / / �^�����
  gDBManager.AddMergeColumn(vMTableID,25, 4+10, 4, vUserID, vPriority, 'date');
  // ��� 26 �]�w   / / / �B�z���p
  gDBManager.AddMergeColumn(vMTableID,26, 4+10, 6, vUserID, vPriority, 'selectbox', '"1.�B�z��","2.�w�ץ�","3.���ץ�"');
  // ��� 27 �]�w   / / / ���p����
  gDBManager.AddMergeColumn(vMTableID,27, 4+10, 7, vUserID, vPriority, 'textfield');
  // ��� 28 �]�w   / / / �˴��T�{
  gDBManager.AddMergeColumn(vMTableID,28, 4+10, 8, vUserID, vPriority, 'selectbox', '"1.�T�{�w�ץ�","2.�|���ץ�"');
end;

procedure TDBManager.DBTest_Table_SY_China;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�����i�ת�', '�����i�ת�(�Ѧҥ�)���u�O���եΪ�',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H', '�����i�ת�-�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '�����i�ת�-���ػ���',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�P�{��������', '�P�{��������..�u��3�ص���',1,4,'selectbox','"��", "��", "�C"' );
  gDBManager.AddColumn(vTableID, -1, '����������', '���e������..�u���Ʀr',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '�����w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�{���H��', '�u���H�W',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );
  gDBManager.AddColumn(vTableID, -1, '�{���w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�', '�����i�ת�-�Ƶ�',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���g��s�T�{', '�����i�ת�-���g��s�T�{',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '����ɶ�/�ƥ�', '�����i�ת�-����ɶ�',1,4,'textfield','' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '��s���ت�', '��s���ت�(�Ѧҥ�)',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��', '�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '����', '����..�N�O������..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '���ػ���..�N�O....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�w�p��s���e���I����', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '���ɦW��', '....�o���٨S�]�w.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����ɶ�/�����~����/�Y�����ᦳ�ק�]�n����', '���C�⪺���,�B����]�٨S�B�z.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�̫�ק鷺�e', '��s���ت�-�̫�ק鷺�e',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��^��', '��s���ت�-�˴��^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����^��', '��s���ت�-�����^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��էO', '��s���ت�-�˴���',1,4,'selectbox','"�TD", "�GD"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�˴���', '���n�X�h���]�w,�٨S�B�z,TODO�˭Ӫ�檩���a..�]�w���..�P��ܪ������}',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '���n�ʵ���','�˴���-���n�ʵ���',1,4,'selectbox','"1.�D�`���n","2.�ܭ��n","3.���q���n"' );
  gDBManager.AddColumn(vTableID, -1, '���ն���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '���ն��ػ���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '����', '�˴���-����',1,4,'selectbox','"A��", "B��", "C��"' );
  gDBManager.AddColumn(vTableID, -1, '���խ��I', '�˴���-���խ��I',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '�w�w���է����ɶ�', '�˴���-�w�w����',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '��������]','���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, 'qi hua fu ze ren yuan ', 'jian ce dan -qi hua fu ze ren yuan ',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, 'cheng shi fu ze ren yuan ', 'jian ce dan -cheng shi fu ze ren yuan ',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///


  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, 'BUG��', '�L�~��s�W',1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��','BUG��-�����H��auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '����','BUG��-����auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG���e����','BUG��-BUG���e����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�^�����','BUG��-�^�����auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '�B�z���p','BUG��-�B�z���p',1,4,'selectbox','"1.�B�z��","2.�w�ץ�","3.���ץ�"' );
  gDBManager.AddColumn(vTableID, -1, '���p����','BUG��-���p����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��T�{','BUG��-�˴��H��',1,4,'selectbox','"1.�T�{�w�ץ�","2.�|���ץ�"' );

end;

procedure TDBManager.DBTest_MergeTable_SDBug;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;

  // �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, '�ݨD�M��', '�Ѫ��s���ݨD�\���+BUG�M��', 1, 2, 2);
  // ��� 1 �]�w   �C�X���
  gDBManager.AddMergeColumn(vMTableID, 1, 15, 1, vUserID, vPriority, 'date');
  // ��� 2 �]�w   ����
  gDBManager.AddMergeColumn(vMTableID, 2, 15, 2, vUserID, vPriority, 'selectbox','"�\��","�ާ@","���","BUG"');
  // ��� 3 �]�w   �\�୶��
  gDBManager.AddMergeColumn(vMTableID, 3, 15, 3, vUserID, vPriority, 'selectbox','"�U�����","�������i","�t��","�Y�ɰT��"');
  // ��� 4 �]�w   ����
  gDBManager.AddMergeColumn(vMTableID, 4, 15, 4, vUserID, vPriority, 'textfield');
  // ��� 5 �]�w   ���n�{��
  gDBManager.AddMergeColumn(vMTableID, 5, 15, 5, vUserID, vPriority, 'selectbox','"��","�C","��","����"');
  // ��� 6 �]�w   ���浲�G
  gDBManager.AddMergeColumn(vMTableID, 6, 15, 6, vUserID, vPriority, 'selectbox','"O","X"');
  // ��� 6 �]�w   �Ƶ�
  gDBManager.AddMergeColumn(vMTableID, 7, 15, 7, vUserID, vPriority, 'textfield');
end;

procedure TDBManager.DBTest_Table_SDBug;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�ݨD�M��', 'SkyDragon���ݨD�\���+BUG�M��',1, 2, 2);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�C�X���','�C�X���auto',1,4,'date' );
  gDBManager.AddColumn(vTableID, -1, '����','����~',1,4,'selectbox','"�\��","�ާ@","���","BUG"' );
  gDBManager.AddColumn(vTableID, -1, '�\�୶��','�\�୶��~',1,4,'selectbox','"�U�����","�������i","�t��","�Y�ɰT��"' );
  gDBManager.AddColumn(vTableID, -1, '����','����~',1,4,'textfield');
  gDBManager.AddColumn(vTableID, -1, '���n�{��','���n�{��~',1,4,'selectbox','"��","�C","��","����"' );
  gDBManager.AddColumn(vTableID, -1, '���浲�G','���浲�G~',1,4,'selectbox','"O","X"' );
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�','�Ƶ�~',1,4,'textfield');
end;

procedure TDBManager.DBTest_MergeTable_SYSchedule;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 1 ;

  // �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, '�i�פ��t��', 'SiYo���i�פ��t��', 1, 2, 1);
  // ��� 1 �]�w   �������A
  gDBManager.AddMergeColumn(vMTableID, 1, 16, 1, vUserID, vPriority, 'selectbox', '"�cPY","�EBS","�LZF","ANSN","�ECRZ","�LCB","��SH","CHIU","PONPON"');
  // ��� 2 �]�w   �ץ�
  gDBManager.AddMergeColumn(vMTableID, 2, 16, 2, vUserID, vPriority, 'selectbox','"SiYo�x��","SiYo����","SuSan","Delphi","�u��","TianZi ","����","SkyDragon"');
  // ��� 3 �]�w   ����
  gDBManager.AddMergeColumn(vMTableID, 3, 16, 3, vUserID, vPriority, 'textfield');
  // ��� 4 �]�w   ����/�t�d�H
  gDBManager.AddMergeColumn(vMTableID, 4, 16, 4, vUserID, vPriority, 'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // ��� 5 �]�w   ���|�ɶ�
  gDBManager.AddMergeColumn(vMTableID, 5, 16, 5, vUserID, vPriority, 'date');
  // ��� 6 �]�w   �����צ���ɶ�
  gDBManager.AddMergeColumn(vMTableID, 6, 16, 6, vUserID, vPriority, 'date');
  // ��� 7 �]�w   �}�l�ɶ�
  gDBManager.AddMergeColumn(vMTableID, 7, 16, 7, vUserID, vPriority, 'date');
  // ��� 8 �]�w   �w�w����
  gDBManager.AddMergeColumn(vMTableID, 8, 16, 8, vUserID, vPriority, 'date');
  // ��� 9 �]�w   �w���һݮɶ�
  gDBManager.AddMergeColumn(vMTableID, 9, 16, 9, vUserID, vPriority, 'textfield');
  // ��� 10 �]�w  ������
  gDBManager.AddMergeColumn(vMTableID,10, 16, 10, vUserID, vPriority, 'selectbox','"OK","����","!�ݴ�","����","  "');
  // ��� 11 �]�w  �I���
  gDBManager.AddMergeColumn(vMTableID,11, 16, 11, vUserID, vPriority, 'date');
  // ��� 12 �]�w  ��s��
  gDBManager.AddMergeColumn(vMTableID,12, 16, 12, vUserID, vPriority, 'date');
  // ��� 13 �]�w  �Ƶ�
  gDBManager.AddMergeColumn(vMTableID,13, 16, 13, vUserID, vPriority, 'textfield');
end;

procedure TDBManager.DBTest_Table_SYSchedule;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '�i�פ��t��', 'SiYo���i�פ��t��', 1, 2, 1);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�������A','�i�פ��t��-�������A',1,4, 'selectbox', '"PY","JST","JF","ANASN","CRZ","CB","SH"');
  gDBManager.AddColumn(vTableID, -1, '�ץ�','�i�פ��t��-�ץ�',1,4,'selectbox','"SY�x��","SY����","SuSan","Delphi","�u��","TianZi ","ZhongHua ","SkyDragon"' );
  gDBManager.AddColumn(vTableID, -1, '����','�i�פ��t��-����',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '����/�t�d�H','�i�פ��t��-����/�t�d�H',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddColumn(vTableID, -1, '���|�ɶ�','�i�פ��t��-���|�ɶ�',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '�����צ���ɶ�','�i�פ��t��-�����צ���ɶ�',1,4,'date' );
  gDBManager.AddColumn(vTableID, -1, '�}�l�ɶ�','�i�פ��t��-�}�l�ɶ�',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '�w�w����','�i�פ��t��-�w�w����',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '�w���һݮɶ�','�i�פ��t��-�w���һݮɶ�',1,4,'textfield');
  gDBManager.AddColumn(vTableID, -1, '������','SiYoSuSan���ؤ�,����(�{������),�ݴ�(������), OK(����),��L���� ���ɧY����,�ȶ� OK',1,4,'selectbox','"OK","����","!�ݴ�","����","  "');
  gDBManager.AddColumn(vTableID, -1, '�I���','�i�פ��t��-�I���',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '��s��','�i�פ��t��-��s��',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�','�i�פ��t��-�Ƶ�',1,4,'textfield');
end;

function TDBManager.DBTest_ForUpdateUse: TRecordSet;
begin
  result := nil;

  mQueryString := Format('SELECT * FROM scs_columnvalue WHERE table_id = %d and datetime > ''%s''',
                         [GridManage.TableManager.CurrentTableID,
                          GridManage.TableManager.CurrentTable.LatestTime]);

  Result := mSQL.Query( mQueryString );
end;

function TDBManager.GetPrivateTableNum(aTableID:integer;aName:string): integer;
var
  vRSet: TRecordSet;
begin
  Result:= 0;    // error
  mQueryString:= Format(' SELECT table_id, column_row_id FROM scs_columnvalue '+
                        ' WHERE  column_id = %d AND value="%s" AND table_id=%d ',
                        [cColumnID_PMName, aName, aTableID]);
  vRSet := mSQL.Query( mQueryString );
  if vRSet.RowNums<>0 then
  begin
    mQueryString:=format('SELECT * FROM scs_columnvalue WHERE column_id = %d AND column_row_id in (%s) AND table_id = %d ',
                         [cColumnID_ItemConfirm, gQGenerator.Implode(vRSet,'column_row_id'),aTableID]);
    vRSet := mSQL.Query( mQueryString );
    Result:=vRSet.RowNums;
  end;
end;

procedure TDBManager.DBTest_MergeTable_WuLin;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// �s�W�@�ӦX�֪��
  gDBManager.AddMergeTable(vMTableID, '[����]WULIN�|�X�@���', '��X�|�Ӫ��', 1, 2, 5);

  /// �s�W�X�����
  // ��� 1 �]�w  �����t�d�H / �H��  / �����t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 1, 1+20, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+20, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+20, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+20, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // ��� 2 �]�w  ���� / ���� / ����
  gDBManager.AddMergeColumn(vMTableID, 2, 1+20, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+20, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+20, 4, vUserID, vPriority, 'textfield');
  // ��� 3 �]�w  ����/ ���ػ��� /���ն���
  gDBManager.AddMergeColumn(vMTableID, 3, 1+20, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+20, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+20, 2, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+20, 2, vUserID, vPriority, 'textarea');
  // ��� 4 �]�w  ���ػ���/ �w�p��s���e���I����/ ���ն��ػ���
  gDBManager.AddMergeColumn(vMTableID, 4, 1+20, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+20, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+20, 3, vUserID, vPriority, 'textarea');
  // ��� 5 �]�w  �P�{��������/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+20, 5, vUserID, vPriority, 'selectbox', '"��", "��", "�C"');
  // ��� 6 �]�w  ����������/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+20, 6, vUserID, vPriority, 'selectbox', '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"');
  // ��� 7 �]�w  �����w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+20, 7, vUserID, vPriority, 'date');
  // ��� 8 �]�w  �{���H��/ / �{���t�d�H��
  gDBManager.AddMergeColumn(vMTableID, 8, 1+20, 8, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye ","wang ","you  ","weng wei ","REAL","ruan yuan ","guo bin ","huang ","wei hong ","mi ","lin ","lu ","lin","zhou rong ","ya ","zhang ","li "');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+20, 9, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye ","wang ","you  ","weng wei ","REAL","ruan yuan ","guo bin ","huang ","wei hong ","mi ","lin ","lu ","lin","zhou rong ","ya ","zhang ","li "');
  // ��� 9 �]�w  �{���w���������/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+20, 9, vUserID, vPriority, 'date');
  // ��� 10 �]�w  �Ƶ�/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+20,10, vUserID, vPriority, 'textarea');
  // ��� 11 �]�w  ���g��s�T�{/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+20,11, vUserID, vPriority, 'selectbox','"�T�{��s","����"');
  // ��� 12 �]�w  ����ɶ�/�ƥ� / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+20,12, vUserID, vPriority, 'textarea');
  // ��� 13 �]�w   /���ɦW�� /    ***��s���ت� start
  gDBManager.AddMergeColumn(vMTableID,13, 2+20, 5, vUserID, vPriority, 'textfield');
  // ��� 14 �]�w   /�����ɶ� /
  gDBManager.AddMergeColumn(vMTableID,14, 2+20, 6, vUserID, vPriority, 'date');
  // ��� 15 �]�w   /�̫�ק鷺�e /
  gDBManager.AddMergeColumn(vMTableID,15, 2+20, 7, vUserID, vPriority, 'textarea');
  // ��� 16 �]�w   /�˴��^�� /
  gDBManager.AddMergeColumn(vMTableID,16, 2+20, 8, vUserID, vPriority, 'textarea');
  // ��� 17 �]�w   /�����^�� /
  gDBManager.AddMergeColumn(vMTableID,17, 2+20, 9, vUserID, vPriority, 'textarea');
  // ��� 18 �]�w   /�˴��էO /
  gDBManager.AddMergeColumn(vMTableID,18, 2+20,10, vUserID, vPriority, 'selectbox', '"�TD", "�GD"');
  // ��� 19 �]�w   /�˴��H�� / �˴��t�d�H�� / �˴��H��
  gDBManager.AddMergeColumn(vMTableID,19, 2+20,11, vUserID, vPriority, 'selectbox', '"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+20,10, vUserID, vPriority, 'selectbox', '"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+20, 5, vUserID, vPriority, 'selectbox', '"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // ��� 20 �]�w   / / ���n�ʵ���   *** �˴��� start
  gDBManager.AddMergeColumn(vMTableID,20, 3+20, 1, vUserID, vPriority, 'selectbox', '"1.�D�`���n","2.�ܭ��n","3.���q���n"');
  // ��� 21 �]�w   / / ���խ��I
  gDBManager.AddMergeColumn(vMTableID,21, 3+20, 5, vUserID, vPriority, 'textarea');
  // ��� 22 �]�w   / / �w�w���է����ɶ�
  gDBManager.AddMergeColumn(vMTableID,22, 3+20, 6, vUserID, vPriority, 'date');
  // ��� 23 �]�w   / / ��������]
  gDBManager.AddMergeColumn(vMTableID,23, 3+20, 7, vUserID, vPriority, 'textarea');
  // ��� 24 �]�w   / / / BUG���e����   *** BUG�� start
  gDBManager.AddMergeColumn(vMTableID,24, 4+20, 3, vUserID, vPriority, 'textarea');
  // ��� 25 �]�w   / / / �^�����
  gDBManager.AddMergeColumn(vMTableID,25, 4+20, 4, vUserID, vPriority, 'date');
  // ��� 26 �]�w   / / / �B�z���p
  gDBManager.AddMergeColumn(vMTableID,26, 4+20, 6, vUserID, vPriority, 'selectbox', '"1.�B�z��","2.�w�ץ�","3.���ץ�"');
  // ��� 27 �]�w   / / / ���p����
  gDBManager.AddMergeColumn(vMTableID,27, 4+20, 7, vUserID, vPriority, 'textarea');
  // ��� 28 �]�w   / / / �˴��T�{
  gDBManager.AddMergeColumn(vMTableID,28, 4+20, 8, vUserID, vPriority, 'selectbox', '"1.�T�{�w�ץ�","2.�|���ץ�"');
end;

procedure TDBManager.DBTest_Table_WuLin;
var
  vTableID: Integer;
begin
  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '[��][WULIN]�����i�ת�', '�����i�ת�(�Ѧҥ�)���u�O���եΪ�',1, 2, 5);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H', '�����i�ת�-�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '����', '�����i�ת�-����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '�����i�ת�-���ػ���',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�P�{��������', '�P�{��������..�u��3�ص���',1,4,'selectbox','"��", "��", "�C"' );
  gDBManager.AddColumn(vTableID, -1, '����������', '���e������..�u���Ʀr',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '�����w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�{���H��', '�u���H�W',1,4,'selectbox','"PY","BS","ZF","ANS","CRZ","CB","SH"' );
  gDBManager.AddColumn(vTableID, -1, '�{���w���������', '�����i�ת�-���',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�Ƶ�', '�����i�ת�-�Ƶ�',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���g��s�T�{', '�����i�ת�-���g��s�T�{',1,4,'selectbox','"�T�{��s","����"' );
  gDBManager.AddColumn(vTableID, -1, '����ɶ�/�ƥ�', '�����i�ת�-����ɶ�',1,4,'textfield','' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '[��][WULIN]��s���ت�', '��s���ت�(�Ѧҥ�)',1, 2, 5);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��', '�o�����u�������H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '����', '����..�N�O������..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '���ػ���', '���ػ���..�N�O....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�w�p��s���e���I����', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '���ɦW��', '....�o���٨S�]�w.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����ɶ�/�����~����/�Y�����ᦳ�ק�]�n����', '���C�⪺���,�B����]�٨S�B�z.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '�̫�ק鷺�e', '��s���ت�-�̫�ק鷺�e',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��^��', '��s���ت�-�˴��^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�����^��', '��s���ت�-�����^��',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��էO', '��s���ت�-�˴���',1,4,'selectbox','"�TD", "�GD"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '[��][WULIN]�˴���', '���n�X�h���]�w,�٨S�B�z,TODO�˭Ӫ�檩���a..�]�w���..�P��ܪ������}',1, 2, 5);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '���n�ʵ���','�˴���-���n�ʵ���',1,4,'selectbox','"1.�D�`���n","2.�ܭ��n","3.���q���n"' );
  gDBManager.AddColumn(vTableID, -1, '���ն���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '���ն��ػ���','�˴���-���ն���',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '����', '�˴���-����',1,4,'selectbox','"A��", "B��", "C��"' );
  gDBManager.AddColumn(vTableID, -1, '���խ��I', '�˴���-���խ��I',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '�w�w���է����ɶ�', '�˴���-�w�w����',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '��������]','���յ��G(V)����/�������̽л�����]�æ^�������t�d�H��',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '�����t�d�H��', '�˴���-�����t�d�H��',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, '�{���t�d�H��', '�˴���-�{���t�d�H��',1,4,'selectbox','"PY","BS","ZF","ANS","CRZ","CB","SH"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///

  // �s�W�@�Ӫ��
  gDBManager.AddTable(vTableID, '[��][WULIN]BUG��', '�L�~��s�W',1, 2, 5);
  // �s�W���
  gDBManager.AddColumn(vTableID, -1, '�����H��','BUG��-�����H��auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '����','BUG��-����auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG���e����','BUG��-BUG���e����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�^�����','BUG��-�^�����auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '�B�z���p','BUG��-�B�z���p',1,4,'selectbox','"1.�B�z��","2.�w�ץ�","3.���ץ�"' );
  gDBManager.AddColumn(vTableID, -1, '���p����','BUG��-���p����',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '�˴��T�{','BUG��-�˴��H��',1,4,'selectbox','"1.�T�{�w�ץ�","2.�|���ץ�"' );
end;

function TDBManager.DBTest_GetTableUpdateTime(const aTableID: Integer; const aTime: string): TRecordSet;
begin
  result := nil;

  mQueryString := Format('SELECT table_update_time FROM scs_table WHERE table_id = %d and table_update_time > ''%s''',
                         [aTableID, aTime]);

  Result := mSQL.Query( mQueryString );
end;


function TDBManager.SetTable_UpdateTime(aTableID: Integer): Integer;
begin
  result:= 0; // effect row, 0
  if aTableID <= 0 then
    exit;

  mQueryString:= gQGenerator.Update('scs_table',['table_update_time'],
                     ['CURRENT_TIMESTAMP()'],[0],
                      Format( ' table_id=%d ',[aTableID]) );
  result:= mSQL.ExecuteQuery(mQueryString);
end;

function TDBManager.SetMergeTable_UpdateTime(aMTableID: Integer): Integer;
begin
  result:= 0; // effect row, 0
  if aMTableID <= 0 then
    exit;

  mQueryString:= gQGenerator.Update('scs_mergetable',['mergetable_update_time'],
                     ['CURRENT_TIMESTAMP()'],[0],
                      Format( ' mergetable_id=%d ',[aMTableID]) );
  result:= mSQL.ExecuteQuery(mQueryString);
end;

function TDBManager.GetInfoByTableID(
  const aTableID: Integer): TRecordSet;
begin
  result := nil;

  if aTableID <= 0 then  //�d�L���s����Table
    exit;

  mQueryString := Format('SELECT sc.column_name,sc.column_description,sc.column_create_user_id,'
                         + ' sc.column_create_time,sc.column_priority,sc.column_type,sc.column_typeset,'
                         + ' sc.column_width,sc.column_height, smc.* '
                         + ' FROM scs_column AS sc NATURAL JOIN scs_mergecolumn AS smc'
                         + ' WHERE table_id = %d '
                         + ' ORDER BY column_id ASC ', [aTableID]);

  result := mSQL.Query( mQueryString );
end;

function TDBManager.GetMergeColumnAutofill(aMTableID,aMColumnID: Integer): TRecordSet;
var
  vWhere: String;
begin
  if aMTableID > 0 then
    if vWhere = '' then
      vWhere:= Format(' WHERE autofill_trigger_mergetable_id = %d ', [aMTableID])
    else
      vWhere:= vWhere + Format(' AND (autofill_trigger_mergetable_id = %d) ', [aMTableID]);
  if aMColumnID > 0 then
    if vWhere = '' then
      vWhere:= Format(' WHERE autofill_trigger_mergecolumn_id = %d ', [aMColumnID])
    else
      vWhere:= vWhere + Format(' AND (autofill_trigger_mergecolumn_id = %d) ', [aMColumnID]);

  mQueryString:= ' SELECT * FROM scs_mergecolumn_autofill ' + vWhere;

  result := mSQL.Query( mQueryString );
end;

{ TQueryGenerator }

function TQueryGenerator.Delete(aTableName, aWhere: String): String;
begin
  result:='';
end;

function TQueryGenerator.Implode(aRecordSet: TRecordSet;
  aColumnName: String; IsString: Boolean = False): String;
var
  i : Integer;
  vQuery: String;
begin
  if aRecordSet = nil then
    Exit;

  aRecordSet.DiscardNull(aColumnName);  // �w�� aColumnName ��즳 NULL �ȵo��
  
  vQuery := '';

  for i:= 0 to aRecordSet.RowNums - 1 do
  begin
    if IsString then
      vQuery := vQuery + Format( '''%s''', [aRecordSet.Row[i, aColumnName]])
    else
      vQuery := vQuery + aRecordSet.Row[i, aColumnName];

    if i <> (aRecordSet.RowNums - 1) then
      vQuery := vQuery + ',' ;
  end;

  Result:= vQuery;
end;

function TQueryGenerator.Insert(aTableName: String; aColumnS,
  aValueS: array of String; aIsString: array of Byte): String;
var
  i: Integer;
  vStrVal, vStrCol: String ;
begin
  Result   := '' ;
  vStrVal  := '';
  vStrCol  := '';
  if aTableName = '' then
    Exit;
  if ( Length(aColumnS) <> Length(aValueS) ) or
     ( Length(aColumnS) <> Length(aValueS) ) then
  begin
    ShowMessage('TQueryGenerator.Insert error! ');
    Exit;
  end;

  for i:= Low(aColumnS) to High(aColumnS) do
  begin
    vStrCol:= vStrCol + aColumnS[i];

    if aIsString[i] = 1 then
      vStrVal:= vStrVal + Format( '''%s''', [ aValueS[i] ] )
    else
      vStrVal:= vStrVal + Format( '%s', [ aValueS[i] ] );
      
    if i <> High(aColumnS) then        // not last index
    begin
      vStrCol:= vStrCol + ',' ;
      vStrVal:= vStrVal + ',';
    end;
  end;

  Result:= Format( 'INSERT INTO %s(%s) VALUES(%s)',[aTableName, vStrCol, vStrVal] );
end;

function TQueryGenerator.Select: String;
begin
  result:='';
end;

function TQueryGenerator.Update(aTableName: String; aColumnS,
  aValueS: array of String; aIsString: array of Byte; aWhere:String=''): String;
var
  i: Integer;
  vStr: String ;
begin
  Result   := '' ;
  vStr     := '' ;
  
  if aTableName = '' then
    Exit;
  if ( Length(aColumnS) <> Length(aValueS) ) or
     ( Length(aColumnS) <> Length(aValueS) ) then
    Exit;

  for i:= Low(aColumnS) to High(aColumnS) do
  begin
    if aIsString[i] = 1 then
      vStr:= vStr + Format( ' %s = ''%s'' ', [ aColumnS[i], aValueS[i] ] )
    else
      vStr:= vStr + Format( ' %s = %s '    , [ aColumnS[i], aValueS[i] ] );
      
    if i <> High(aColumnS) then        // not last index
    begin
      vStr := vStr + ',';
    end;
  end;

  Result:= Format( 'UPDATE %s SET %s WHERE %s ',[aTableName, vStr, aWhere] );
end;

end.
