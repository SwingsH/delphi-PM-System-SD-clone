{$I define.h}
unit DBManager;
(**************************************************************************
 * 系統專用 DB 實作與管理工具
 *
 * @Author Swings Huang
 * @Version 2010/01/15 v1.0
 * @Todo 剛開發
 *************************************************************************)
interface

uses
  (** Delphi *)
  Dialogs, SqlExpr, SysUtils, Classes,
  (** Sky Dragon *)
  SQLConnecter ;

const
  cUpdateSecond = 30; /// 資料庫 Update 的間隔秒數

type
  (********************************************************
   * SQL DB 資料管理器, 系統中的 SQL 語言實作區
   * 注意: 請將系統中的所有 SQL 語言放置於此 pas !! 方便統一管理與修改 !!
   * 注意: 類別沒有欄位或邏輯檢查 ! 只負責執行。
   *
   * 函式成員命名基本規則
   * Add_ (SQL: INSERT 類型指令)  Set_ (SQL: UPDATE 類型指令)
   * Get_ (SQL: SELECT 類型指令)  Del_ (SQL: DELETE 類型指令)
   *
   * @Author Swings Huang
   * @Version 2010/01/15 v1.0
   * @Todo 
   ********************************************************)
  TDBManager      = class;
  
  (********************************************************
   * SQL 語法防呆產生器, 產生 SQL 指令的地方, 避免人為 KeyIn 指令出現錯誤
   *
   * @Author Swings Huang
   * @Version 2010/01/22
   * @Todo 1.Implode() 運作應該要要抽離 TRecordSet
   ********************************************************)
  TQueryGenerator = class;

  TDBManager = class( TObject )
  private
    mSQL         : TSQLConnecter;     /// DB 連線工具,
    mQueryString : String;            /// 查詢字串, 方便除錯用, 通常與 mSQL.QueryString 是相同的
    function GetQueryString: String;
  protected
  public
    constructor Create ;
    destructor  Destroy; override;
    (** Table: scs_users **)
    function GetUser(aUserID: Integer): TRecordSet;overload;
    function GetUser(aFilter: String=''; aArg: Integer=0; aArg2: String='';     /// 依條件取得多個[使用者]
                     aRequest: String=''): TRecordSet;overload;
    function AddUser(aAccount, aPassword, aNickname:String; aExNumber, aEmployeeNum,
                     aPosID, aDepID, aTeamOrgID, aOrgID, aLevelID: Integer): Integer;
    function SetPass(aID:integer;aValue: String=''):integer;                    /// 修改密碼
    function GetUser_Project(aUserID: Integer): TRecordSet;                     /// 取得[使用者]底下的所有專案
    function GetUsers: TRecordSet;overload;
    function GetUsers(aDepID, aOrgID, aGradeLvID: Integer;
                      aRequest: String=''): TRecordSet;overload;
    (** Table: scs_user_status **)
    function GetUserStatus(aUserID: Integer):TRecordSet;                        /// 取得使用者狀態 (TODO: 該表只是暫時取代 Server)
    function SetUserStatus(aUserID: Integer):Integer; overload;                 /// TODO:
    function SetUserStatus(aQueryStr: String):Integer; overload;                /// TODO:
    (** Table: scs_table, scs_column, scs_columnvalue **)
    function AddTable(out aTableID: Integer; aTableName: String;                /// 新增一個 Table, -1為新增失敗, 1為新增成功
                      aTableDesc: String; aUserID:Integer;aOrganizeID: Integer;
                      aProjectID: Integer=0): Integer;
    function AddColumn(aTableID: Integer; aColumnID: Integer;aColumnName:String;/// 新增一個 欄位 (Column) , -1為新增失敗, 1為新增成功 , 格式檢查請愛用 TableHandler
                       aColumnDesc: String;aUserID: Integer; aPriority: Integer; aType: String;
                       aTypeSet: String='';aWidth: Integer= 40; aHeight: Integer = 20 ): Integer;
    function AddColumnvalue(aTableID: Integer; aColumnID: Integer;              /// 新增一個 欄位內容 (Columnvalue) , -1為新增失敗, 1為新增成功, 格式檢查請愛用 TableHandler
                            aColumnRowID: Integer=-1; aValue: String=''): Integer;
    function SetColumnvalue(aTableID: Integer; aColumnID: Integer;              /// 修改一個 欄位內容 (Columnvalue) , -1為新增失敗, 1為新增成功, 格式檢查請愛用 TableHandler
                            aColumnRowID: Integer; aValue: String; aTime:String=''): Integer;
    function SetTable_UpdateTime(aTableID: Integer):Integer;                    /// 重新設置 Table 的最後更新時間
    function DelColumnvalue(aTableID, aColumnID, aRowID: Integer): Integer;     /// 依條件刪除一個或多個欄位內容 (Columnvalue), -1為刪除失敗, 1以上為刪除數量
    function GetTable(aTableID: Integer):TRecordSet;
    function GetTableS(aProjectID:Integer= 0; aOrganizeID:Integer= 0;           /// 依條件取得 TableS
                       aUserID:Integer= 0; StartTime:String='';EndTime:String=''; aRequest:String=''): TRecordSet;
    function GetPrivateTableNum(aTableID: Integer; aName:string):Integer;       /// TODO: 查詢特定名稱的企劃, [更新確認][尚未完成(????????)]的數量。寫死的功能。 SQL 敘述需優化
    // function GetColumn;
    function GetTable_ColumnNum(aTableID: Integer): Integer;                    /// 取得指定 Table 的Column總數
    function GetTable_ColumnS(aTableID: Integer;aRequest:String=''): TRecordSet;/// 取得指定 Table 的所有 Column
    function GetTable_ColumnvalueS(aTableID: Integer;aOrder:String='')          /// 取得指定 Table 的所有 Column內容
                                   : TRecordSet;
    function GetColumn(aTableID, aColumnID:Integer):TRecordSet;                 /// 依條件取得 Column 單一欄位
    function GetColumnS(aTableID: Integer= 0; aColumnID: Integer= 0):TRecordSet;/// ?? 依條件取得 ColumnS
    function GetColumnvalue(aTableID,aColumnID, aRowID: Integer): TRecordSet;   /// 取得指定 Table 指定 Column的 某一個欄位內容
    function GetColumnvalueS(aTableID:Integer; aColumnID:Integer=0;             /// 取得指定 Table 指定 Column的 全部欄位內容
                             aRowID:Integer=0;aRequest:String=''): TRecordSet;
    function GetColumn_ID( aTableID: Integer=0; aRequest: String='' ):Integer;  /// 依條件取得 Column_ID
    function GetColumnvalue_ID( aTableID: Integer=0; aColumnID: Integer= 0;     /// 依條件取得 Columnvalue_ID
                                aRequest: String='' ):Integer;
    (** Table: scs_mergecolumn **)
    function GetInfoByTableID(const aTableID: Integer): TRecordSet;             /// 以子表格ID取得所有mergecolumn的資料
    (** Table: scs_mergetable [合併型態的表格] **)
    function AddMergeTable(out aMTableID: Integer; aMTableName: String;         /// 新增一個 MergeTable, -1為新增失敗, 1為新增成功
                      aMTableDesc: String; aMUserID:Integer;aMOrgID: Integer;
                      aMProjID: Integer=0): Integer;
    function AddMergeColumn(aMTableID: Integer; aMColumnID: Integer;            /// 新增一個 合併表格的 MergeColumn , -1為新增失敗, 1為新增成功 , 格式檢查請愛用 TableHandler
                            aTableID: Integer; aColumnID: Integer;
                            aUserID: Integer; aPriority: Integer; aMType:String=''; aMTypeSet:String=''): Integer;
    function GetMergeTable(aMTableID: Integer):TRecordSet;                      /// 取得指定 MergeTable
    function GetMergeTable_TableS(aMTableID: Integer;aRequest:String='')        /// 取得指定 MergeTable (總表格) 的所有 Table (子表格), 想要知道一個總表用到幾個子表格時可用此 method
                                  : TRecordSet;
    function GetMergeTable_ColumnS(aMTableID:Integer;aMColumnID:Integer=0;      /// 取得指定 MergeTable 的所有 Column
                                   aRequest:String=''; aOrder:String=''; aGroupName:String=''):TRecordSet;
    function GetMergeTable_ColumnvalueS(aMTableID: Integer;aOrder:String='';    /// 取得指定 MergeTable 的所有 Column內容 // 以 mergecolumn_id 為GROUP群組, 只取出取出 table_id 最前面的 columnvalue (正常情況其它有對應關係的 table 的 columnvalue 是一樣的, 因此取一就可)
                                        aMColumnID:Integer=0;aMRowID:Integer=0): TRecordSet;
    function GetMergeColumn(aMTableID,aMColumnID,aTableID,aColumnID: Integer;   /// 取得一個 合併表格的 MergeColumn
                            aRequest:String=''):TRecordSet;
    function GetMergeColumnvalue_ID( aMTableID: Integer=0;                      /// 依條件取得 合併型表格的 ColumnValue ID
                                     aRequest: String='' ):Integer;
    function SetMergeTable_UpdateTime(aMTableID: Integer):Integer;
    (** Table: scs_mergecolumn_autofill **)
    function GetMergeColumnAutofill(aMTableID:Integer=0;                        /// 取得總表自動回填的資料
                                    aMColumnID:Integer=0):TRecordSet;
    (** Table: scs_table_log [表格變動日誌] (TODO:20100208作廢)**)
    function AddTableLog(aTableID,aUserID:Integer;aMessage:String;              /// 新增一個表格變動日誌
                         aValid:Byte=1):Integer;
    function GetTableLogS(aTableID:Integer=0; aUserID:Integer=0;                /// 取得多個表格變動日誌
                          aValid:Byte=1; aStartTime:String='';aEndTime:String=''):TRecordSet;
    (** Table: scs_tablelog_title **)
    function AddTablelogTitle(aUserID, aMTable: Integer; aWord: String):Integer;/// 新增一個mergetable日誌標題
    function GetTablelogTitle_ID(aUserID:Integer=0; aRequest:String=''):Integer;/// 依條件取得mergetable日誌標題 ID
    function GetTablelogTitleS(aTableID:Integer=0; aUserID:Integer=0;           /// 取得多個mergetable日誌標題
                               aStartTime:String='';aEndTime:String=''; aOrder:String=''):TRecordSet;
    (** Table: scs_tablelog_list **)
    function AddTablelogList(aTitleID: Integer; aMessage: String;aMColumnID,    /// 新增一個mergetable日誌列表
                             aMRowID:Integer; aError:Boolean=False):Integer;
    function GetTablelogListS(aTitleID: Integer; aRequest:String='';            /// 取得多個mergetable日誌列表
                              aProjID:Integer=0; aMTableID:Integer=0; aMColID:Integer=0; aMRowID:Integer=0;
                              aUserID: Integer=0; aStartTime:String='';aEndTime:String=''):TRecordSet;
    (** Table: scs_bulletin **)
    function AddBulletin(aUserID:Integer; aType:Integer; aText:String;          /// 新增一個公告
                         aOrgID:Integer=0; aProjID:Integer=0): Integer;
    function GetBulletin(aBulletinID: Integer): TRecordSet;                     /// 取得指定 ID 的公告
    function GetBulletinS(aUserID:Integer=0; aOrgID:Integer=0;                  /// 依照條件取得多個公告
                          aProjID:Integer=0; aRequest:String=''; aStartTime:String='';
                          aEndTime:String=''; aOrder:String=''):TRecordSet;
    (** Table: scs_project, scs_project_memeber **)
    function GetProject(aProjectID: Integer):TRecordSet;                        /// 取得單一 Project 的資料
    function GetProject_MergeTableS(aProjectID: Integer):TRecordSet;            /// 取得單一 Project 底下的多個總表
    function GetProject_Members(aProjectID: Integer):TRecordSet;                /// 取得指定 Project 的成員
    (** Table: scs_version **)
    function GetVersion(aDateTime: String=''): TRecordSet;                      /// 取得系統版本資訊
    (** Funcitons: **)
    procedure Init;
    function  ConvertBig5Datetime(aDatetime: String): String;                   /// 轉換 Big5 的時間字串為標準格式
    (** SQLConnecter: *)
    procedure Pause;                                                            /// SQL 元件暫停執行, 可用來產生 Query String
    procedure Play;                                                             /// SQL 元件恢復執行
    (** Funcitons: for Test **)
    procedure TestRun;  /// 完完全全是實作測試用的
    procedure DBTest;
    procedure DBTest_UserData;
    procedure DBTest_Table;       // SY, 設定有誤差做廢
    procedure DBTest_MergeTable;  // SY, 設定有誤差做廢
    procedure DBTest_Table_2;     // SY Tw
    procedure DBTest_MergeTable_2;// SY Tw
    procedure DBTest_Table_TZ;      // TianZi 的子表格
    procedure DBTest_MergeTable_TZ; // TianZi 的總表格
    procedure DBTest_Table_TZ_China;      // TianZi 的子表格 china
    procedure DBTest_MergeTable_TZ_China; // TianZi 的總表格 china
    procedure DBTest_Table_SY_China;     // SY China
    procedure DBTest_MergeTable_SY_China;// SY China
    procedure DBTest_ColumnValue;
    procedure DBTest_Bulletin;
    procedure DBTest_ConvertMColumnType;
    procedure DBTest_Table_WeekReport;       // 周報表
    procedure DBTest_MergeTable_WeekReport;  // 周報表
    procedure DBTest_Table_SDBug;            // 天空龍 Bug 表
    procedure DBTest_MergeTable_SDBug;       // 天空龍 Bug 表
    procedure DBTest_Table_SYSchedule;       // SiYo進度分配表
    procedure DBTest_MergeTable_SYSchedule;  // SiYo進度分配表
    procedure DBTest_Table_WuLin;            // WULIN的子表格
    procedure DBTest_MergeTable_WuLin;       // WULIN的總表格
    procedure DBTest_AddProjMemberS;         // 專案成員資料
    procedure DBTest_AddMergeColumn_Autofill;// 自動回填總表 - 三合一 --> BUG表
    function DBTest_ForUpdateUse: TRecordSet;        //刷新資料用
    function DBTest_GetTableUpdateTime(const aTableID: Integer; const aTime: string): TRecordSet;  //取得表格欄位最後修改時間
    (** Property **)
    property QueryString: String read GetQueryString;
    property SQLConnecter: TSQLConnecter read mSQL;
  end;

  TQueryGenerator = class(TObject)
  private
  public
    function Insert( aTableName:String; aColumnS:array of String;               /// 參數產生 INSERT 指令
                     aValueS:array of String; aIsString: array of Byte ):String;
    function Update( aTableName:String; aColumnS:array of String;               /// 參數產生 UPDATE 指令
                     aValueS:array of String; aIsString: array of Byte; aWhere:String=''):String;
    function Delete( aTableName:String; aWhere: String ):String;                /// 參數產生 DELETE 指令
    function Select:String;                                                     /// 參數產生 SELECT 指令 TODO:
    function Implode( aRecordSet: TRecordSet; aColumnName: String ;
                        IsString: Boolean = False):String;                      /// (TODO:運作應該要要抽離 TRecordSet) 參數產生 IN 指令
  end;

var
  gDBManager : TDBManager;
  gQGenerator: TQueryGenerator;

implementation

uses
  WinSock, DoLogin,
  Main, TableHandler, GridCtrl, TableModel;

const
  (** 因應特例功能寫死的欄位常數 *)
  cColumnID_PMName = 1 ;      /// 總表(之企劃進度表) - 企劃負責人的欄位編號 , 寫死。
  cColumnID_ItemConfirm = 11; /// 總表(之企劃進度表) - 更新確認的欄位編號 , 寫死。

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
  if Result= -1 then  // 新增資料失敗
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
  if aTableID <= 0 then    // 未指定 TableID, 不用搞了吧..
    Exit;

  if aColumnID <= 0 then   // 未指定 ColumnID, 取得資料表目前的 Max Column ID
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

  if aColumnRowID <= 0 then   // 未指定 aColumnvalueID, 取得資料表目前的 Max Column ID
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
  if Result= -1 then          // 新增失敗
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
  if Result= -1 then          // 更新失敗
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
    if Result.Row[i, 'table_id'] = '' then  // TODO: GROUP BY 有怪異的 null 值必須清除
      Result.DeleteRowSet(i)
    else if i >= 1 then                     // 清除相同 table id 的重複值
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
  if aRequest = 'mapping' then        // 取出對應表
    mQueryString:= Format('SELECT * FROM scs_mergecolumn WHERE mergetable_id=%d ', [aMTableID])
  else if aRequest = 'detail' then    // 取出對應表 + 詳細欄位資訊
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
  
  // 如果有指定的 mergecolumn_id 則加上
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
  if aRequest = '' then   // 非對應表, 只取得不重複的欄位.. 也是因為 DBX 不支援 Null Join 的 Group
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
  
  // 因為 DBX 不支援, 超難用, 只好使用麻煩的方法存取
  vRSet:= gDBManager.GetMergeTable_TableS(aMTableID);
  mQueryString:= Format(' SELECT scv.*, mergetable_id, mergecolumn_id, smc.column_id, mergecolumn_create_user_id ' +
                        ' FROM scs_columnvalue AS scv NATURAL JOIN scs_mergecolumn AS smc '+
                        ' WHERE table_id in(%s) '+ vWhere + 
                        ' ORDER BY column_row_id, mergecolumn_id ASC ',
                        [gQGenerator.Implode(vRSet,'table_id')]);
  Result:= mSQL.Query( mQueryString );
  // TODO: GROUP BY 有怪異的 null 值必須清除
  for i:= Result.RowNums - 1 downto 0 do
  begin
    if Result.Row[i, 'table_id'] = '' then
      Result.DeleteRowSet(i);
  end;
  // TODO: DBX 不支援, 使用搜索方式把  同步&相同的子表格欄位&同列的內容消除
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
  if aMTableID <= 0 then   // 未指定 PK之一的 MTableID, 不用搞了吧..
    Exit;
  if aMColumnID <= 0 then  // 未指定 PK之一的 MTableID, 不用搞了吧..
    Exit;
  if aTableID <= 0 then    // 未指定 PK之一的 TableID, 不用搞了吧..
    Exit;
  if aColumnID <= 0 then   // 未指定 PK之一的 ColumnID, 不用搞了吧..
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

  // 因為 DBX 不支援異表欄位在 where 出現.., 因此用麻煩的作法
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
  if Result= -1 then  // 新增失敗
    Exit;
end;

function TDBManager.GetTableLogS(aTableID: Integer; aUserID: Integer;
  aValid: Byte; aStartTime, aEndTime: String): TRecordSet;
var
  vRSet: TRecordSet;
begin
  Result:= nil;

  if (aTableID = 0) AND (aUserID > 0) then /// 針對 User: 取出 user 下的專案表格
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

  // 時間條件  
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
  if Result= -1 then  // 新增失敗
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

  if aUserID > 0 then // 防止同步問題, 其他 user 在同時間也可能有 LOG, 但 same user 同時間只能新增一筆 LOG
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
  
  if (aTableID = 0) AND (aUserID > 0) then /// 針對 User, 沒指定 Table : 取出 user 下的專案 merge 表格
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

  // 時間條件  
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
  if Result= -1 then  // 新增失敗
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

  if aTitleID > 0 then          // 一般顯示, 直接找子項目, 非搜索條件
  begin
    if aRequest = 'detail' then
      mQueryString := Format('SELECT * FROM scs_tablelog_list NATURAL JOIN scs_tablelog_title WHERE tablelog_title_id = %d ',[aTitleID])
    else
      mQueryString := Format('SELECT * FROM scs_tablelog_list WHERE tablelog_title_id = %d ',[aTitleID]);
  end
  else
  begin                        // 非一般顯示, 搜索條件找子項目
    //============== 因為 DBX 不支援..分兩段.. (1) 篩選 log title ==============
    if aRequest = 'detail' then
      vQuery := ' SELECT stt.* FROM scs_tablelog_title AS stt '
    else
      vQuery := ' SELECT * FROM scs_tablelog_title ' ;

    vWhere := '';
    vTitleFilter:= ''; 
    // aMTableID and aProjID is confict 擇一即可, aMTable 比較好處理, 而且本來就有 project 資料
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

    // 時間條件
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

    if (aMTableID>0) OR (aProjID>0) OR (aUserID>0) OR  // 任何一個成立 = 要搜索 log title
       (aStartTime<>'') OR (aEndTime<>'') then
    begin
      vQuery := vQuery + vWhere;
      vRSet:= mSQL.Query( vQuery );
      if vRSet.RowNums = 0 then     // 沒任何資料, 提早結束
      begin
        Result:= TRecordSet.Create;
        Exit;
      end;
      vTitleFilter:= Format(' tablelog_title_id IN (%s)',[gQGenerator.Implode(vRSet,'tablelog_title_id')]);
      FreeAndNil(vRSet);
    end;

    //============== 因為 DBX 不支援..分兩段.. (2) 篩選 log list ==============
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
    
  if aOrder = '' then       // 預設 order by row
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

  if aRequest = '' then            // 使用者表的資料
  begin
    if aFilter = 'employee_number' then
      mQueryString:= Format( 'SELECT * FROM scs_user WHERE scs_employee_number = %s', [aArg] )
    else if aFilter = 'user_id' then
      mQueryString:= Format( 'SELECT * FROM scs_user WHERE scs_user_id = %s', [aArg] )
    else if aFilter = 'user_account' then
      mQueryString:= Format( 'SELECT * FROM scs_user WHERE user_account = ''%s''', [aArg2] );
  end
  else if aRequest = 'detail' then // 使用者詳細資料,
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
  if Result= -1 then          // 新增失敗
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

  if aDepID > 0 then          // aDepartmentID : 取出特定部門的使用者
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE department_id = %d', [aDepID] )
    else
      vQueryWhere:= Format(' %s AND department_id = %d', [vQueryWhere, aDepID] );
  end
  else if aOrgID > 0 then     // aOrganizeID : 取出特定組織的使用者
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE organize_id = %d', [aOrgID] )
    else
      vQueryWhere:= Format(' %s AND organize_id = %d', [vQueryWhere, aOrgID] );
  end
  else if aGradeLvID > 0 then // aGradeLvID : 取出特定職等的使用者
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE gradelevel_id = %d', [aGradeLvID] )
    else
      vQueryWhere:= Format(' %s AND gradelevel_id = %d', [vQueryWhere, aGradeLvID] );
  end;

  if aRequest = 'online' then       // 是否限定 正在線上的使用者
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
  /// TODO: DBX error 不支援!!
  Result:= nil;
  vQuerySelect:= '';
  vQueryFrom  := '';
  vQueryLimit := '';
  vQueryWhere := '';
  if aRequest = 'columns' then             // 取出表格 + 欄位格式
  begin
    vQuerySelect:= ' SELECT st.*, sc.* ';
    vQueryFrom  := ' FROM scs_column AS sc NATURAL JOIN scs_table AS st ';
  end
  else if aRequest = 'columnvalues' then   // 取出表格 + 欄位格式 + 欄位內容
  begin
    vQuerySelect:= ' SELECT st.*, sc.*, scv.* '; // TODO:
    vQueryFrom  := ' FROM scs_table AS st RIGHT JOIN scs_column sc ON st.table_id = sc.table_id ,' +
                   '       sc LEFT OUTER JOIN scs_columnvalues AS scv ON sc.column_id = scv.column_id ' ;
  end
  else                                     // 取出表格
  begin
    vQuerySelect:= ' SELECT st.* ';
    vQueryFrom  := ' FROM scs_table AS st ';
  end;

  if aProjectID > 0 then        // aProjectID : 取出特定專案的表格
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE table_create_project_id = %d', [aProjectID] )
    else
      vQueryWhere:= Format(' %s AND table_create_project_id = %d',[vQueryWhere, aProjectID] );
  end
  else if aOrganizeID > 0 then  // aOrganizeID : 取出特定組織所建立的表格
  begin
    if vQueryWhere = '' then
      vQueryWhere:= Format(' WHERE table_create_organize_id = %d',[aOrganizeID] )
    else
      vQueryWhere:= Format(' %s AND table_create_organize_id = %d', [vQueryWhere, aProjectID] );
  end
  else if aUserID > 0 then
  begin
    if vQueryWhere = '' then    // aUserID : 取出特定使用者所建立的表格
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
  else if aRequest = 'total' then   // 比較節省效能
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
  if Result= -1 then  // 更新資料失敗
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
  if Result= -1 then  // 新增失敗
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

  if aUserID > 0 then          // aUserID : 取出特定使用者 Post 的公告
  begin
    if vWhere = '' then
      vWhere:= Format(' WHERE user_id = %d', [aUserID] )
    else
      vWhere:= Format(' %s AND user_id = %d', [vWhere, aUserID] );
  end
  else if aOrgID > 0 then     // aOrganizeID : 取出特定組織的公告
  begin
    if vWhere = '' then
      vWhere:= Format(' WHERE organize_id = %d', [aOrgID] )
    else
      vWhere:= Format(' %s AND organize_id = %d', [vWhere, aOrgID] );
  end
  else if aProjID > 0 then    // aProjectID : 取出特定專案的公告
  begin
    if vWhere = '' then
      vWhere:= Format(' WHERE project_id = %d', [aProjID] )
    else
      vWhere:= Format(' %s AND project_id = %d', [vWhere, aProjID] );
  end;

  // 時間條件  
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

  // 排序條件
  if aOrder= 'desc' then
    vWhere:= vWhere + ' Order By create_datetime DESC '
  else if aOrder= '' then
    vWhere:= vWhere + ' Order By create_datetime ASC ';

  mQueryString := vSelect + vFrom + vWhere ;
  Result := mSQL.Query( mQueryString );

  for i:=0 to Result.RowNums-1 do
  begin
    if Result.Row[i, 'bulletin_id'] = '' then  // TODO: DBX1.0 有時有怪異的 null 值必須清除
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

  /// 2010.04.16, 增加 mergetable_order 排序專用欄位。 後續將給使用者自動顯示順序
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
 *                        Test Functions - 測試用
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
  //DBTest_Table_TZ;      //TianZi 子表
  //DBTest_MergeTable_TZ; //TianZi 總表
  //DBTest_Table_TZ_China;  //TianZi 子表, 陸版
  //DBTest_MergeTable_TZ_China;  //TianZi 子表, 陸版
  //DBTest_AddProjMemberS;
  //DBTest_Table_SDBug;
  //DBTest_MergeTable_SDBug;
  //DBTest_Table_SYSchedule; // SiYo進度分配表
  //DBTest_MergeTable_SYSchedule; // SiYo進度分配表
  //DBTest_Table_WuLin;           // WULIN的子表格
  //DBTest_MergeTable_WuLin       // WULIN總表
  //DBTest_AddMergeColumn_Autofill; // BUG 表自動回填系統
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
 // ShowMessage( WideStringToString( StringToWideString('測試用公告',950),950) );
 // Exit;
  //gDBManager.SQLConnecter.ExecuteQuery( 'SET NAMES UTF8' );
  gDBManager.SQLConnecter.ExecuteQuery( 'SET NAMES BIG5' );
  gDBManager.AddBulletin( 1, 2,'測試用公告' , 2, 1 );
end;

procedure TDBManager.DBTest_Table;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '企劃進度表', '企劃進度表(參考用)其實只是測試用的',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃負責人', '這個欄位只能填企劃人員',1,6,'selectbox','"WANG", "TrueIn", "Pure"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '分類', '分類..就是分類阿..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目', '項目..............',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '..............',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '與程式相關度', '與程式相關度..只有3種等級',1,4,'selectbox','"高", "中", "低"' );
  gDBManager.AddColumn(vTableID, -1, '企劃完成度', '企畫完成度..只能填數字',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '企劃預估完成日期', '日期....',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '程式人員', '只能填人名',1,4,'selectbox','"BS","SH", "CB", "ZF"' );
  gDBManager.AddColumn(vTableID, -1, '程式預估完成日期', '日期....',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '備註', '...............',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '本週更新確認', 'OOXX....',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '延後時間/事由', '..........',1,4,'textfield','' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '更新項目表', '更新項目表(參考用)',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員', '這個欄位只能填企劃人員',1,6,'selectbox','"WANG", "TrueIn", "Pure"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '分類', '分類..就是分類阿..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '項目說明..就是....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '預計更新內容重點說明', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '附檔名稱', '....這個還沒設定.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '完成時間/完成才填日期/若完成後有修改也要填日期', '有顏色的欄位...且換行也還沒處理.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '最後修改內容', '修改內容..................',1,4,'selectbox','"BS","SH", "CB", "ZF"' );
  gDBManager.AddColumn(vTableID, -1, '檢測回報', '......',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '企劃回報', '......',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測組別', '......',1,4,'selectbox','"A組", "B組", "C組"' );
  gDBManager.AddColumn(vTableID, -1, '檢測人員', '......',1,4,'selectbox','"毛毛", "凱凱", "勝勝"' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '檢測單', '天ㄚ..欄位好幾層的設定, 還沒處理, 考慮弄個表格版型吧..設定資料..與顯示版型分開',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '專案名稱', '.......',1,6,'selectbox','"SiYo", "WULIN", "勇者"' );
  gDBManager.AddColumn(vTableID, -1, '提報日期', '...........',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '預定測試完成時間', '...',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '提報人(限企劃部主管)', '.....',1,4,'selectbox','"ZuanKai"' );
  gDBManager.AddColumn(vTableID, -1, '收件人', '...................',1,4,'selectbox','"Shen"' );
  gDBManager.AddColumn(vTableID, -1, '編號', '.....................',1,4,'number','autoincrement' );
  gDBManager.AddColumn(vTableID, -1, '重要性評比', '...............',1,4,'selectbox','"1.非常重要","2.很重要","3.普通重要"' );
  gDBManager.AddColumn(vTableID, -1, '測試項目', '.................',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '測試項目說明', '.............',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '分類', '.....................',1,4,'selectbox','"A類", "B類", "C類"' );
  gDBManager.AddColumn(vTableID, -1, '測試重點', '.................',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '測試結果(V)完成/未完成者請說明原因並回報相關負責人員','.................',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '企劃負責人員', '.............',1,6,'selectbox','"WANG", "TrueIn", "Pure"' );   ///
  gDBManager.AddColumn(vTableID, -1, '程式負責人員', '.............',1,4,'selectbox','"BS","SH", "CB", "ZF"' );  ///
  gDBManager.AddColumn(vTableID, -1, '檢測負責人員', '.............',1,4,'selectbox','"毛","凱", "勝"' );  ///
end;

procedure TDBManager.DBTest_Table_2;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '企劃進度表', '企劃進度表(參考用)其實只是測試用的',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃負責人', '企劃進度表-這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '分類', '企劃進度表-分類',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目', '企劃進度表-項目',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '企劃進度表-項目說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '與程式相關度', '與程式相關度..只有3種等級',1,4,'selectbox','"高", "中", "低"' );
  gDBManager.AddColumn(vTableID, -1, '企劃完成度', '企畫完成度..只能填數字',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '企劃預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '程式人員', '只能填人名',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );
  gDBManager.AddColumn(vTableID, -1, '程式預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '備註', '企劃進度表-備註',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '本週更新確認', '企劃進度表-本週更新確認',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '延後時間/事由', '企劃進度表-延後時間',1,4,'textfield','' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '更新項目表', '更新項目表(參考用)',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員', '這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '分類', '分類..就是分類阿..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '項目說明..就是....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '預計更新內容重點說明', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '附檔名稱', '....這個還沒設定.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '完成時間/完成才填日期/若完成後有修改也要填日期', '有顏色的欄位,且換行也還沒處理.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '最後修改內容', '更新項目表-最後修改內容',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測回報', '更新項目表-檢測回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '企劃回報', '更新項目表-企劃回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測組別', '更新項目表-檢測組',1,4,'selectbox','"三D", "二D"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '檢測單', '欄位好幾層的設定,還沒處理,TODO弄個表格版型吧..設定資料..與顯示版型分開',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '重要性評比','檢測單-重要性評比',1,4,'selectbox','"1.非常重要","2.很重要","3.普通重要"' );
  gDBManager.AddColumn(vTableID, -1, '測試項目','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '測試項目說明','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '分類', '檢測單-分類',1,4,'selectbox','"A類", "B類", "C類"' );
  gDBManager.AddColumn(vTableID, -1, '測試重點', '檢測單-測試重點',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '預定測試完成時間', '檢測單-預定測試',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '未完成原因','測試結果(V)完成/未完成者請說明原因並回報相關負責人員',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '企劃負責人員', '檢測單-企劃負責人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, '程式負責人員', '檢測單-程式負責人員',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///

  // 新增一個表格
  gDBManager.AddTable(vTableID, 'BUG表', '過年後新增',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員','BUG表-企劃人員auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '項目','BUG表-項目auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG內容說明','BUG表-BUG內容說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '回報日期','BUG表-回報日期auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '處理狀況','BUG表-處理狀況',1,4,'selectbox','"1.處理中","2.已修正","3.不修正"' );
  gDBManager.AddColumn(vTableID, -1, '狀況說明','BUG表-狀況說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測確認','BUG表-檢測人員',1,4,'selectbox','"1.確認已修正","2.尚未修正"' );
end;

procedure TDBManager.DBTest_MergeTable;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, 'SiYo三合一表格', '整合三個表格', 1, 2, 1);

  /// 新增合併欄位
  // 欄位 1 設定  企劃負責人 / 人員  / 企劃負責人員
  gDBManager.AddMergeColumn(vMTableID, 1, 1, 1, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 1, 2, 1, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 1, 3,14, vUserID, vPriority);
  // 欄位 2 設定  分類 / 分類 / 分類
  gDBManager.AddMergeColumn(vMTableID, 2, 1, 2, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 2, 2, 2, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 2, 3,10, vUserID, vPriority);
  // 欄位 3 設定  項目/ 項目說明 /測試項目
  gDBManager.AddMergeColumn(vMTableID, 3, 1, 3, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 3, 2, 3, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 3, 3, 8, vUserID, vPriority);
  // 欄位 4 設定  項目說明/ 預計更新內容重點說明/ 測試項目說明
  gDBManager.AddMergeColumn(vMTableID, 4, 1, 4, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 4, 2, 4, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 4, 3, 9, vUserID, vPriority);
  // 欄位 5 設定  與程式相關度/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1, 5, vUserID, vPriority);
  // 欄位 6 設定  企劃完成度/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1, 6, vUserID, vPriority);
  // 欄位 7 設定  企劃預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1, 7, vUserID, vPriority);
  // 欄位 8 設定  程式人員/ / 程式負責人員
  gDBManager.AddMergeColumn(vMTableID, 8, 1, 8, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID, 8, 3,15, vUserID, vPriority);
  // 欄位 9 設定  程式預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1, 9, vUserID, vPriority);
  // 欄位 10 設定  備註/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1,10, vUserID, vPriority);
  // 欄位 11 設定  本週更新確認/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1,11, vUserID, vPriority);
  // 欄位 12 設定  延後時間/事由 / /
  gDBManager.AddMergeColumn(vMTableID,12, 1,12, vUserID, vPriority);
  // 欄位 13 設定   /附檔名稱 /    ***更新項目表 start
  gDBManager.AddMergeColumn(vMTableID,13, 2, 5, vUserID, vPriority);
  // 欄位 14 設定   /完成時間 /
  gDBManager.AddMergeColumn(vMTableID,14, 2, 6, vUserID, vPriority);
  // 欄位 15 設定   /最後修改內容 /
  gDBManager.AddMergeColumn(vMTableID,15, 2, 7, vUserID, vPriority);
  // 欄位 16 設定   /檢測回報 /
  gDBManager.AddMergeColumn(vMTableID,16, 2, 8, vUserID, vPriority);
  // 欄位 17 設定   /企劃回報 /
  gDBManager.AddMergeColumn(vMTableID,17, 2, 9, vUserID, vPriority);
  // 欄位 18 設定   /檢測組別 /
  gDBManager.AddMergeColumn(vMTableID,18, 2,10, vUserID, vPriority);
  // 欄位 19 設定   /檢測人員 / 檢測負責人員
  gDBManager.AddMergeColumn(vMTableID,19, 2,11, vUserID, vPriority);
  gDBManager.AddMergeColumn(vMTableID,19, 3,16, vUserID, vPriority);
  // 欄位 20 設定   / / 專案名稱   *** 檢測單 start
  gDBManager.AddMergeColumn(vMTableID,20, 3, 1, vUserID, vPriority);
  // 欄位 21 設定   / / 提報日期
  gDBManager.AddMergeColumn(vMTableID,21, 3, 2, vUserID, vPriority);
  // 欄位 22 設定   / / 預定測試完成日期
  gDBManager.AddMergeColumn(vMTableID,22, 3, 3, vUserID, vPriority);
  // 欄位 23 設定   / / 提報人(限企劃部主管)
  gDBManager.AddMergeColumn(vMTableID,23, 3, 4, vUserID, vPriority);
  // 欄位 24 設定   / / 收件人
  gDBManager.AddMergeColumn(vMTableID,24, 3, 5, vUserID, vPriority);
  // 欄位 25 設定   / / 編號
  gDBManager.AddMergeColumn(vMTableID,25, 3, 6, vUserID, vPriority);
  // 欄位 26 設定   / / 重要性評比
  gDBManager.AddMergeColumn(vMTableID,26, 3, 7, vUserID, vPriority);
  // 欄位 27 設定   / / 測試重點
  gDBManager.AddMergeColumn(vMTableID,27, 3,11, vUserID, vPriority);
  // 欄位 28 設定   / / 測試結果(V)完成/未完成者請說明原因並回報相關負責人員
  gDBManager.AddMergeColumn(vMTableID,28, 3,12, vUserID, vPriority);
end;

procedure TDBManager.DBTest_MergeTable_2;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, 'SiYo四合一表格', '整合四個表格', 1, 2, 1);

  /// 新增合併欄位
  // 欄位 1 設定  企劃負責人 / 人員  / 企劃負責人員
  gDBManager.AddMergeColumn(vMTableID, 1, 1, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2, 1, vUserID, vPriority, 'selectbox', '"Yen","HO","KUO","WANG","ACE","WUUUU","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HO","KUO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // 欄位 2 設定  分類 / 分類 / 分類
  gDBManager.AddMergeColumn(vMTableID, 2, 1, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3, 4, vUserID, vPriority, 'textfield');
  // 欄位 3 設定  項目/ 項目說明 /測試項目
  gDBManager.AddMergeColumn(vMTableID, 3, 1, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 2, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 3, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 4, 2, vUserID, vPriority, 'textfield');
  // 欄位 4 設定  項目說明/ 預計更新內容重點說明/ 測試項目說明
  gDBManager.AddMergeColumn(vMTableID, 4, 1, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 2, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 3, 3, vUserID, vPriority, 'textfield');
  // 欄位 5 設定  與程式相關度/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1, 5, vUserID, vPriority, 'selectbox', '"高", "中", "低"');
  // 欄位 6 設定  企劃完成度/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1, 6, vUserID, vPriority, 'number');
  // 欄位 7 設定  企劃預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1, 7, vUserID, vPriority, 'date');
  // 欄位 8 設定  程式人員/ / 程式負責人員
  gDBManager.AddMergeColumn(vMTableID, 8, 1, 8, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3, 9, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  // 欄位 9 設定  程式預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1, 9, vUserID, vPriority, 'date');
  // 欄位 10 設定  備註/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1,10, vUserID, vPriority, 'textfield');
  // 欄位 11 設定  本週更新確認/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1,11, vUserID, vPriority, 'checkbox');
  // 欄位 12 設定  延後時間/事由 / /
  gDBManager.AddMergeColumn(vMTableID,12, 1,12, vUserID, vPriority, 'textfield');
  // 欄位 13 設定   /附檔名稱 /    ***更新項目表 start
  gDBManager.AddMergeColumn(vMTableID,13, 2, 5, vUserID, vPriority, 'textfield');
  // 欄位 14 設定   /完成時間 /
  gDBManager.AddMergeColumn(vMTableID,14, 2, 6, vUserID, vPriority, 'date');
  // 欄位 15 設定   /最後修改內容 /
  gDBManager.AddMergeColumn(vMTableID,15, 2, 7, vUserID, vPriority, 'textfield');
  // 欄位 16 設定   /檢測回報 /
  gDBManager.AddMergeColumn(vMTableID,16, 2, 8, vUserID, vPriority, 'textfield');
  // 欄位 17 設定   /企劃回報 /
  gDBManager.AddMergeColumn(vMTableID,17, 2, 9, vUserID, vPriority, 'textfield');
  // 欄位 18 設定   /檢測組別 /
  gDBManager.AddMergeColumn(vMTableID,18, 2,10, vUserID, vPriority, 'selectbox', '"三D", "二D"');
  // 欄位 19 設定   /檢測人員 / 檢測負責人員 / 檢測人員
  gDBManager.AddMergeColumn(vMTableID,19, 2,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // 欄位 20 設定   / / 重要性評比   *** 檢測單 start
  gDBManager.AddMergeColumn(vMTableID,20, 3, 1, vUserID, vPriority, 'selectbox', '"1.非常重要","2.很重要","3.普通重要"');
  // 欄位 21 設定   / / 測試重點
  gDBManager.AddMergeColumn(vMTableID,21, 3, 5, vUserID, vPriority, 'textfield');
  // 欄位 22 設定   / / 預定測試完成時間
  gDBManager.AddMergeColumn(vMTableID,22, 3, 6, vUserID, vPriority, 'date');
  // 欄位 23 設定   / / 未完成原因
  gDBManager.AddMergeColumn(vMTableID,23, 3, 7, vUserID, vPriority, 'textfield');
  // 欄位 24 設定   / / / BUG內容說明   *** BUG表 start
  gDBManager.AddMergeColumn(vMTableID,24, 4, 3, vUserID, vPriority, 'textfield');
  // 欄位 25 設定   / / / 回報日期
  gDBManager.AddMergeColumn(vMTableID,25, 4, 4, vUserID, vPriority, 'date');
  // 欄位 26 設定   / / / 處理狀況
  gDBManager.AddMergeColumn(vMTableID,26, 4, 6, vUserID, vPriority, 'selectbox', '"1.處理中","2.已修正","3.不修正"');
  // 欄位 27 設定   / / / 狀況說明
  gDBManager.AddMergeColumn(vMTableID,27, 4, 7, vUserID, vPriority, 'textfield');
  // 欄位 28 設定   / / / 檢測確認
  gDBManager.AddMergeColumn(vMTableID,28, 4, 8, vUserID, vPriority, 'selectbox', '"1.確認已修正","2.尚未修正"');
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
               Format( '表格編號%d的第%d欄的第%d列',[1,i,vRowID]));
  FreeAndNil(vRS);

  vRS    := gDBManager.GetTable_ColumnS(2);
  vRowID := gDBManager.GetColumnvalue_ID(2,0,'max');
  Inc( vRowID );
  for i:= 0 to vRS.RowNums - 1 do
    gDBManager.AddColumnvalue(2, i, vRowID,
               Format( '表格編號%d的第%d欄的第%d列',[2,i,vRowID]));
  FreeAndNil(vRS);

  vRS    := gDBManager.GetTable_ColumnS(3);
  vRowID := gDBManager.GetColumnvalue_ID(3,0,'max');
  Inc( vRowID );
  for i:= 0 to vRS.RowNums - 1 do
    gDBManager.AddColumnvalue(3, i, vRowID,
               Format( '表格編號%d的第%d欄的第%d列',[3,i,vRowID]));
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

  ShowMessage( ConvertBig5Datetime('2010/2/11 下午 03:28:55') );
  // 即時訊息搜索條件
  vRecordSet:= GetTablelogListS(0, 'detail', 1, 1, 1);
  ShowMessage(IntToStr(vRecordSet.RowNums));

  DBTest;

  // 取得總表的列最大值
  vRowID:= GetMergeColumnvalue_ID(1,'max') + 1 ;
  vRecordSet:= gDBManager.GetMergeTable_ColumnS(1);
  for i:= 0 to vRecordSet.RowNums-1 do
  begin
    ShowMessage(vRecordSet.Row[i, 'column_name']);
  end;
  

  // 新增總表的一列
  vValueList:= TStringList.Create;
  vValueList.Add('WANG');
  vValueList.Add('一般更新');
  vValueList.Add('元神法器功能');
  vValueList.Add('開放元神法器的功能: 1.元神能裝備法器。 2.法器會損毀');
  vValueList.Add('高');
  vValueList.Add('10%');
  vValueList.Add('2010/02/15');
  vValueList.Add('SH');
  vValueList.Add('2010/02/17');
  vValueList.Add('沒有備註');
  vValueList.Add('X'); // 本週更新確認
  vValueList.Add('延後還需要什麼理由');       // 欄位 12 設定  延後時間/事由 / /
  vValueList.Add('沒有什麼附檔名稱');         // 欄位 13 設定   /附檔名稱 /    ***更新項目表 start
  vValueList.Add('2010/02/29');               // 欄位 14 設定   /完成時間 /
  vValueList.Add('不懂最後修改內容的意思');   // 欄位 15 設定   /最後修改內容 /
  vValueList.Add('有BUG');                    // 欄位 16 設定   /檢測回報 /
  vValueList.Add('可測試');                   // 欄位 17 設定   /企劃回報 /
  vValueList.Add('A組');                      // 欄位 18 設定   /檢測組別 /
  vValueList.Add('毛');                     // 欄位 19 設定   /檢測人員 / 檢測負責人員
  vValueList.Add('奇幻SiYo');                 // 欄位 20 設定   / / 專案名稱   *** 檢測單 start
  vValueList.Add('2010/03/02');               // 欄位 21 設定   / / 提報日期
  vValueList.Add('2010/03/05');               // 欄位 22 設定   / / 預定測試完成日期
  vValueList.Add('ZuanKai');                   // 欄位 23 設定   / / 提報人(限企劃部主管)
  vValueList.Add('Shen');                   // 欄位 24 設定   / / 收件人
  vValueList.Add('1');                        // 欄位 25 設定   / / 編號
  vValueList.Add('1.非常重要');               // 欄位 26 設定   / / 重要性評比
  vValueList.Add('測試重點就是看有沒有 BUG'); // 欄位 27 設定   / / 測試重點
  vValueList.Add('V');                        // 欄位 28 設定   / / 測試結果(V)完成/未完成者請說明原因並回報相關負責人員

  gMergeTableHandler.NewRow(1, vRowID, vValueList);
  

  // 取出一個總表(1)下的所有欄位內容
  vRecordSet:= gDBManager.GetMergeTable_ColumnvalueS(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( Format('第[%s]欄,第[%s]列,欄位內容: [%s] ',
                        [vRecordSet.Row[i,'mergecolumn_id'],
                         vRecordSet.Row[i,'column_row_id'],
                         vRecordSet.Row[i,'value']]));
  end;
  FreeAndNil(vRecordSet);

  // 更改總表的一個欄位 + Log
  vLogID:= gMergeTableHandler.CreateLog(1, ltMod);
  gMergeTableHandler.ModifyColumnvalue(vLogID,1,1,1,'這是負責人?');

  // 取得 表格 1 , 不限定欄位的, 最大列數
  vRowID:= gDBManager.GetColumnvalue_ID(1, 0, 'max');
  Inc(vRowID);

  // 新增一列
  gTableHandler.NewRow(1,vRowID);

  // 取出一個總表格底下動用到幾個子表格
  vRecordSet := GetMergeTable_TableS(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( '子表格:' + vRecordSet.Row[i, 'table_id']);
  end;
  FreeAndNil(vRecordSet);

  // 取出一個表格(1)下的所有欄位內容
  vRecordSet:= gDBManager.GetTable_ColumnvalueS(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( Format('第[%s]欄,第[%s]列,欄位內容: [%s] ',
                        [vRecordSet.Row[i,'column_id'], vRecordSet.Row[i,'column_row_id'], vRecordSet.Row[i,'value']]));
  end;
  FreeAndNil(vRecordSet);

  // 取出一個使用者下的所有專案
  vRecordSet:= gDBManager.GetUser_Project(1);
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage('專案名稱: ' + vRecordSet.Row[i,'project_name']);
  end;
  FreeAndNil(vRecordSet);

  // 取出SiYo專案的表
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

  // 取出 user_id = 1 張貼的公告
  vRecordSet:= gDBManager.GetBulletinS(1,0,0,'detail');
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    ShowMessage( Format( '[%s] 專案:%s - 張貼人:%s - %s - 張貼時間 : %s' ,
                 [vRecordSet.Row[i,'organize_name'], vRecordSet.Row[i,'project_name'],vRecordSet.Row[i,'user_nickname'],vRecordSet.Row[i,'bulletin_text'],vRecordSet.Row[i,'create_datetime']]));
  end;
  FreeAndNil(vRecordSet);
  
  // 更改一個欄位
  gTableHandler.ModifyColumnvalue(1,2,1,'我更改了!!SH . in 2010.01.27', False);

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
  // 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, '專案企劃進度工作表', '一週填一次, 很開心', 1, 2, 3);
  // 欄位 1 設定   填表人員
  gDBManager.AddMergeColumn(vMTableID, 1, 5, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON","盧PY","余BS","林ZF","ANSN","余CRZ","林CB","黃SH","CHIU","PONPON"');
  // 欄位 2 設定   工作項目
  gDBManager.AddMergeColumn(vMTableID, 2, 5, 2, vUserID, vPriority, 'textarea');
  // 欄位 3 設定   相關人員
  gDBManager.AddMergeColumn(vMTableID, 3, 5, 3, vUserID, vPriority,'multiselectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON","盧PY","余BS","林ZF","ANSN","余CRZ","林CB","黃SH","CHIU","PONPON"');
  // 欄位 4 設定   完成時間
  gDBManager.AddMergeColumn(vMTableID, 4, 5, 4, vUserID, vPriority,'date');
  // 欄位 5 設定   上週已完成
  gDBManager.AddMergeColumn(vMTableID, 5, 5, 5, vUserID, vPriority,'selectbox', '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  // 欄位 6 設定   當週預計完成
  gDBManager.AddMergeColumn(vMTableID, 6, 5, 6, vUserID, vPriority, 'selectbox','"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  // 欄位 7 設定   當週預定完成進度說明
  gDBManager.AddMergeColumn(vMTableID, 7, 5, 7, vUserID, vPriority, 'textfield');
  ***)

  // 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, '周報表', '一周只需要填一次的有需要用總表嗎？',vUserID, 1, 4);
  // 欄位 1 設定   名稱
  gDBManager.AddMergeColumn(vMTableID, 1, 6+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON",'+'"盧PY","余BS","林ZF","ANSN","余CRZ","林CB","黃SH","CHIU","PONPON"');
  // 欄位 2 設定   主要項目
  gDBManager.AddMergeColumn(vMTableID, 2, 6+24, 2, vUserID, vPriority, 'selectbox','"本週工作"');
  // 欄位 3 設定   目前工作內容
  gDBManager.AddMergeColumn(vMTableID, 3, 6+24, 3, vUserID, vPriority, 'textarea');
  // 欄位 4 設定   配合部門
  gDBManager.AddMergeColumn(vMTableID, 4, 6+24, 4, vUserID, vPriority, 'multiselectbox','"企劃","程式","美術","檢測","營運"');
  // 欄位 5 設定   配合人員名稱
  gDBManager.AddMergeColumn(vMTableID, 5, 6+24, 5, vUserID, vPriority,'textarea');
  // 欄位 6 設定   執行開始時間
  gDBManager.AddMergeColumn(vMTableID, 6, 6+24, 6, vUserID, vPriority, 'date');
  // 欄位 7 設定   執行結束時間
  gDBManager.AddMergeColumn(vMTableID, 7, 6+24, 7, vUserID, vPriority, 'date');
  // 欄位 8 設定   備註
  gDBManager.AddMergeColumn(vMTableID, 8, 6+24, 8, vUserID, vPriority, 'textarea');
  // 欄位 9 設定   實際進度
  gDBManager.AddMergeColumn(vMTableID, 9, 6+24, 9, vUserID, vPriority, 'selectbox','"超前","如期","延後"');
  // 欄位 10 設定  品質達成評價
  gDBManager.AddMergeColumn(vMTableID,10, 6+24,10, vUserID, vPriority, 'selectbox','"優","可","差"');
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
  vIDSet:= Format('%d=>%d,%d=>%d,%d=>%d', [1,1, 3,2, 19,5]);        /// 三合一 => BUG表
  mQueryString:= gQGenerator.Insert('scs_mergecolumn_autofill',
                   ['autofill_mergecolumn_id_set','autofill_trigger_string',
                    'autofill_trigger_mergetable_id','autofill_trigger_mergecolumn_id','autofill_trigger_columntype',
                    'autofill_dest_mergetable_id','autofill_dest_mergecolumn_id'],
                   [ vIDSet, 'BUG表', IntToStr(10),IntToStr(16)(*fixed*),'textarea',
                     IntToStr(21), IntToStr(3) (*fixed*)],
                   [1, 1, 0, 0, 1, 0, 0]);
  gDBManager.SQLConnecter.ExecuteQuery( mQueryString );                 
end;

procedure TDBManager.DBTest_Table_WeekReport;
var
  vTableID: Integer;
begin
  (***
  // 新增一個表格
  gDBManager.AddTable(vTableID, '專案企劃進度工作表', '一周只需要填一次的有需要用總表嗎？',1, 1, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '填表人員',  '進度工作表-填表人員',1,6,'selectbox','selfname');
  gDBManager.AddColumn(vTableID, -1, '工作項目',  '進度工作表-工作項目',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '相關人員',  '進度工作表-相關人員',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '完成時間',  '進度工作表-完成時間',1,6,'date');
  gDBManager.AddColumn(vTableID, -1, '上週已完成','進度工作表-上週已完成',1,6,'selectbox',     '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  gDBManager.AddColumn(vTableID, -1, '當週預計完成', '進度工作表-當週預計完成',1,6,'selectbox','"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"' );
  gDBManager.AddColumn(vTableID, -1, '當週預定完成進度說明', '進度工作表-預定完成進度說明',1,6,'textfield');
  **)
  
  // 新增一個表格
  gDBManager.AddTable(vTableID, '周報表', '一周只需要填一次的有需要用總表嗎？',1, 1, 4);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '名稱',    '企劃周報表-名稱',1,6,'function','selfname');
  gDBManager.AddColumn(vTableID, -1, '主要項目','企劃周報表-主要項目',1,6,'selectbox','"本週工作"');
  gDBManager.AddColumn(vTableID, -1, '目前工作內容','企劃周報表-目前工作內容',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '配合部門', '企劃周報表-名稱',1,6,'checkbox','"企劃","程式","美術","檢測","營運"');
  gDBManager.AddColumn(vTableID, -1, '配合人員名稱', '企劃周報表-名稱',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '執行開始時間', '執行時間',1,6,'date');
  gDBManager.AddColumn(vTableID, -1, '執行結束時間', '執行時間',1,6,'date');
  gDBManager.AddColumn(vTableID, -1, '備註', '備註',1,6,'textfield');
  gDBManager.AddColumn(vTableID, -1, '實際進度', '實際進度-不規則。',1,6,'selectbox','"超前","如期","延後"');
  gDBManager.AddColumn(vTableID, -1, '品質達成評價', '品質達成評價-不規則',1,6,'selectbox','"優","可","差"');
end;

(**************************************************************************
 *                        Test Functions End - 測試用 End
 *************************************************************************)

function TDBManager.ConvertBig5Datetime(aDatetime: String): String;
var
  vPos1, vPos2: Integer;
  vHour: String;
begin
  try
    Result:= aDatetime;
    vPos1 := Pos('上午 ', aDatetime);
    vPos2 := Pos('下午 ', aDatetime);

    // 用 上午  下午 把 Big5 SQL DB 的12小時制轉換成24小時制 (TODO: 不好的作法...)
    if vPos1 > 0 then
      Result:= StringReplace(Result, '上午 ', '',[rfReplaceAll, rfIgnoreCase])
    else if vPos2 > 0 then
    begin
      Result:= StringReplace(Result, '下午 ', '',[rfReplaceAll, rfIgnoreCase]);
      vPos2 := Pos(':', Result);
      vHour := Copy(Result, vPos2-Length('12'), Length('12'));
      if vHour <> '12' then  // (12:30 歸類為 下午 12:30 而非 上午 12:30 )
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
  if Result= -1 then          // 更新失敗
    Exit;
end;

procedure TDBManager.DBTest_MergeTable_TZ;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, 'TianZi 四合一表格', '整合四個表格', 1, 2, 1);

  /// 新增合併欄位
  // 欄位 1 設定  企劃負責人 / 人員  / 企劃負責人員
  gDBManager.AddMergeColumn(vMTableID, 1, 1+6, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+6, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+6, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+6, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // 欄位 2 設定  分類 / 分類 / 分類
  gDBManager.AddMergeColumn(vMTableID, 2, 1+6, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+6, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+6, 4, vUserID, vPriority, 'textfield');
  // 欄位 3 設定  項目/ 項目說明 /測試項目
  gDBManager.AddMergeColumn(vMTableID, 3, 1+6, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+6, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+6, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+6, 2, vUserID, vPriority, 'textfield');
  // 欄位 4 設定  項目說明/ 預計更新內容重點說明/ 測試項目說明
  gDBManager.AddMergeColumn(vMTableID, 4, 1+6, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+6, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+6, 3, vUserID, vPriority, 'textfield');
  // 欄位 5 設定  與程式相關度/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+6, 5, vUserID, vPriority, 'selectbox', '"高", "中", "低"');
  // 欄位 6 設定  企劃完成度/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+6, 6, vUserID, vPriority, 'number');
  // 欄位 7 設定  企劃預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+6, 7, vUserID, vPriority, 'date');
  // 欄位 8 設定  程式人員/ / 程式負責人員
  gDBManager.AddMergeColumn(vMTableID, 8, 1+6, 8, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+6, 9, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  // 欄位 9 設定  程式預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+6, 9, vUserID, vPriority, 'date');
  // 欄位 10 設定  備註/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+6,10, vUserID, vPriority, 'textfield');
  // 欄位 11 設定  本週更新確認/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+6,11, vUserID, vPriority, 'checkbox');
  // 欄位 12 設定  延後時間/事由 / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+6,12, vUserID, vPriority, 'textfield');
  // 欄位 13 設定   /附檔名稱 /    ***更新項目表 start
  gDBManager.AddMergeColumn(vMTableID,13, 2+6, 5, vUserID, vPriority, 'textfield');
  // 欄位 14 設定   /完成時間 /
  gDBManager.AddMergeColumn(vMTableID,14, 2+6, 6, vUserID, vPriority, 'date');
  // 欄位 15 設定   /最後修改內容 /
  gDBManager.AddMergeColumn(vMTableID,15, 2+6, 7, vUserID, vPriority, 'textfield');
  // 欄位 16 設定   /檢測回報 /
  gDBManager.AddMergeColumn(vMTableID,16, 2+6, 8, vUserID, vPriority, 'textfield');
  // 欄位 17 設定   /企劃回報 /
  gDBManager.AddMergeColumn(vMTableID,17, 2+6, 9, vUserID, vPriority, 'textfield');
  // 欄位 18 設定   /檢測組別 /
  gDBManager.AddMergeColumn(vMTableID,18, 2+6,10, vUserID, vPriority, 'selectbox', '"三D", "二D"');
  // 欄位 19 設定   /檢測人員 / 檢測負責人員 / 檢測人員
  gDBManager.AddMergeColumn(vMTableID,19, 2+6,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+6,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+6, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // 欄位 20 設定   / / 重要性評比   *** 檢測單 start
  gDBManager.AddMergeColumn(vMTableID,20, 3+6, 1, vUserID, vPriority, 'selectbox', '"1.非常重要","2.很重要","3.普通重要"');
  // 欄位 21 設定   / / 測試重點
  gDBManager.AddMergeColumn(vMTableID,21, 3+6, 5, vUserID, vPriority, 'textfield');
  // 欄位 22 設定   / / 預定測試完成時間
  gDBManager.AddMergeColumn(vMTableID,22, 3+6, 6, vUserID, vPriority, 'date');
  // 欄位 23 設定   / / 未完成原因
  gDBManager.AddMergeColumn(vMTableID,23, 3+6, 7, vUserID, vPriority, 'textfield');
  // 欄位 24 設定   / / / BUG內容說明   *** BUG表 start
  gDBManager.AddMergeColumn(vMTableID,24, 4+6, 3, vUserID, vPriority, 'textfield');
  // 欄位 25 設定   / / / 回報日期
  gDBManager.AddMergeColumn(vMTableID,25, 4+6, 4, vUserID, vPriority, 'date');
  // 欄位 26 設定   / / / 處理狀況
  gDBManager.AddMergeColumn(vMTableID,26, 4+6, 6, vUserID, vPriority, 'selectbox', '"1.處理中","2.已修正","3.不修正"');
  // 欄位 27 設定   / / / 狀況說明
  gDBManager.AddMergeColumn(vMTableID,27, 4+6, 7, vUserID, vPriority, 'textfield');
  // 欄位 28 設定   / / / 檢測確認
  gDBManager.AddMergeColumn(vMTableID,28, 4+6, 8, vUserID, vPriority, 'selectbox', '"1.確認已修正","2.尚未修正"');

end;

procedure TDBManager.DBTest_Table_TZ;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '企劃進度表', '企劃進度表(參考用)其實只是測試用的',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃負責人', '企劃進度表-這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '分類', '企劃進度表-分類',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目', '企劃進度表-項目',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '企劃進度表-項目說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '與程式相關度', '與程式相關度..只有3種等級',1,4,'selectbox','"高", "中", "低"' );
  gDBManager.AddColumn(vTableID, -1, '企劃完成度', '企畫完成度..只能填數字',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '企劃預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '程式人員', '只能填人名',1,4,'selectbox','"李信言","戴光賢","林燕昌","蔡政廷","李坤育","楊景霖","葉庭霖","王瑞琪","尤富新","翁偉翔","李貞德","阮柏源","郭書賓","黃鴻傑","魏瑞宏","羋大榕","林佳弘","呂貽舜","林自強","周政融","嚴崇榮","張欣哲","李忠琅"' );
  gDBManager.AddColumn(vTableID, -1, '程式預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '備註', '企劃進度表-備註',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '本週更新確認', '企劃進度表-本週更新確認',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '延後時間/事由', '企劃進度表-延後時間',1,4,'textfield','' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '更新項目表', '更新項目表(參考用)',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員', '這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '分類', '分類..就是分類阿..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '項目說明..就是....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '預計更新內容重點說明', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '附檔名稱', '....這個還沒設定.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '完成時間/完成才填日期/若完成後有修改也要填日期', '有顏色的欄位,且換行也還沒處理.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '最後修改內容', '更新項目表-最後修改內容',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測回報', '更新項目表-檢測回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '企劃回報', '更新項目表-企劃回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測組別', '更新項目表-檢測組',1,4,'selectbox','"三D", "二D"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '檢測單', '欄位好幾層的設定,還沒處理,TODO弄個表格版型吧..設定資料..與顯示版型分開',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '重要性評比','檢測單-重要性評比',1,4,'selectbox','"1.非常重要","2.很重要","3.普通重要"' );
  gDBManager.AddColumn(vTableID, -1, '測試項目','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '測試項目說明','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '分類', '檢測單-分類',1,4,'selectbox','"A類", "B類", "C類"' );
  gDBManager.AddColumn(vTableID, -1, '測試重點', '檢測單-測試重點',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '預定測試完成時間', '檢測單-預定測試',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '未完成原因','測試結果(V)完成/未完成者請說明原因並回報相關負責人員',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '企劃負責人員', '檢測單-企劃負責人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, 'cheng shi fu ze ren yuan ', 'jian ce dan -cheng shi fu ze ren yuan ',1,4,'selectbox','"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///

  // 新增一個表格
  gDBManager.AddTable(vTableID, 'BUG表', '過年後新增',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員','BUG表-企劃人員auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '項目','BUG表-項目auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG內容說明','BUG表-BUG內容說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '回報日期','BUG表-回報日期auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '處理狀況','BUG表-處理狀況',1,4,'selectbox','"1.處理中","2.已修正","3.不修正"' );
  gDBManager.AddColumn(vTableID, -1, '狀況說明','BUG表-狀況說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測確認','BUG表-檢測人員',1,4,'selectbox','"1.確認已修正","2.尚未修正"' );
end;


procedure TDBManager.DBTest_MergeTable_TZ_China;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, '[陸版]TianZi 四合一表格', '整合四個表格', 1, 1, 4);

  /// 新增合併欄位
  // 欄位 1 設定  企劃負責人 / 人員  / 企劃負責人員
  gDBManager.AddMergeColumn(vMTableID, 1, 1+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+24, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+24, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // 欄位 2 設定  分類 / 分類 / 分類
  gDBManager.AddMergeColumn(vMTableID, 2, 1+24, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+24, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+24, 4, vUserID, vPriority, 'textfield');
  // 欄位 3 設定  項目/ 項目說明 /測試項目
  gDBManager.AddMergeColumn(vMTableID, 3, 1+24, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+24, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+24, 2, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+24, 2, vUserID, vPriority, 'textarea');
  // 欄位 4 設定  項目說明/ 預計更新內容重點說明/ 測試項目說明
  gDBManager.AddMergeColumn(vMTableID, 4, 1+24, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+24, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+24, 3, vUserID, vPriority, 'textarea');
  // 欄位 5 設定  與程式相關度/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+24, 5, vUserID, vPriority, 'selectbox', '"高", "中", "低"');
  // 欄位 6 設定  企劃完成度/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+24, 6, vUserID, vPriority, 'selectbox', '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"');
  // 欄位 7 設定  企劃預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+24, 7, vUserID, vPriority, 'date');
  // 欄位 8 設定  程式人員/ / 程式負責人員
  gDBManager.AddMergeColumn(vMTableID, 8, 1+24, 8, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+24, 9, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"');
  // 欄位 9 設定  程式預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+24, 9, vUserID, vPriority, 'date');
  // 欄位 10 設定  備註/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+24,10, vUserID, vPriority, 'textarea');
  // 欄位 11 設定  本週更新確認/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+24,11, vUserID, vPriority, 'selectbox','"確認更新","延後"');
  // 欄位 12 設定  延後時間/事由 / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+24,12, vUserID, vPriority, 'textarea');
  // 欄位 13 設定   /附檔名稱 /    ***更新項目表 start
  gDBManager.AddMergeColumn(vMTableID,13, 2+24, 5, vUserID, vPriority, 'textfield');
  // 欄位 14 設定   /完成時間 /
  gDBManager.AddMergeColumn(vMTableID,14, 2+24, 6, vUserID, vPriority, 'date');
  // 欄位 15 設定   /最後修改內容 /
  gDBManager.AddMergeColumn(vMTableID,15, 2+24, 7, vUserID, vPriority, 'textarea');
  // 欄位 16 設定   /檢測回報 /
  gDBManager.AddMergeColumn(vMTableID,16, 2+24, 8, vUserID, vPriority, 'textarea');
  // 欄位 17 設定   /企劃回報 /
  gDBManager.AddMergeColumn(vMTableID,17, 2+24, 9, vUserID, vPriority, 'textarea');
  // 欄位 18 設定   /檢測組別 /
  gDBManager.AddMergeColumn(vMTableID,18, 2+24,10, vUserID, vPriority, 'selectbox', '"三D", "二D"');
  // 欄位 19 設定   /檢測人員 / 檢測負責人員 / 檢測人員
  gDBManager.AddMergeColumn(vMTableID,19, 2+24,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+24,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+24, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // 欄位 20 設定   / / 重要性評比   *** 檢測單 start
  gDBManager.AddMergeColumn(vMTableID,20, 3+24, 1, vUserID, vPriority, 'selectbox', '"1.非常重要","2.很重要","3.普通重要"');
  // 欄位 21 設定   / / 測試重點
  gDBManager.AddMergeColumn(vMTableID,21, 3+24, 5, vUserID, vPriority, 'textarea');
  // 欄位 22 設定   / / 預定測試完成時間
  gDBManager.AddMergeColumn(vMTableID,22, 3+24, 6, vUserID, vPriority, 'date');
  // 欄位 23 設定   / / 未完成原因
  gDBManager.AddMergeColumn(vMTableID,23, 3+24, 7, vUserID, vPriority, 'textarea');
  // 欄位 24 設定   / / / BUG內容說明   *** BUG表 start
  gDBManager.AddMergeColumn(vMTableID,24, 4+24, 3, vUserID, vPriority, 'textarea');
  // 欄位 25 設定   / / / 回報日期
  gDBManager.AddMergeColumn(vMTableID,25, 4+24, 4, vUserID, vPriority, 'date');
  // 欄位 26 設定   / / / 處理狀況
  gDBManager.AddMergeColumn(vMTableID,26, 4+24, 6, vUserID, vPriority, 'selectbox', '"1.處理中","2.已修正","3.不修正"');
  // 欄位 27 設定   / / / 狀況說明
  gDBManager.AddMergeColumn(vMTableID,27, 4+24, 7, vUserID, vPriority, 'textarea');
  // 欄位 28 設定   / / / 檢測確認
  gDBManager.AddMergeColumn(vMTableID,28, 4+24, 8, vUserID, vPriority, 'selectbox', '"1.確認已修正","2.尚未修正"');
end;

procedure TDBManager.DBTest_Table_TZ_China;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '企劃進度表', '企劃進度表(參考用)其實只是測試用的',1, 1, 4);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃負責人', '企劃進度表-這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '分類', '企劃進度表-分類',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目', '企劃進度表-項目',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '企劃進度表-項目說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '與程式相關度', '與程式相關度..只有3種等級',1,4,'selectbox','"高", "中", "低"' );
  gDBManager.AddColumn(vTableID, -1, '企劃完成度', '企畫完成度..只能填數字',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '企劃預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, 'cheng shi ren yuan ', 'zhi neng tian ren ming ',1,4,'selectbox','"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"' );
  gDBManager.AddColumn(vTableID, -1, '程式預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '備註', '企劃進度表-備註',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '本週更新確認', '企劃進度表-本週更新確認',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '延後時間/事由', '企劃進度表-延後時間',1,4,'textfield','' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '更新項目表', '更新項目表(參考用)',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員', '這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '分類', '分類..就是分類阿..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '項目說明..就是....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '預計更新內容重點說明', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '附檔名稱', '....這個還沒設定.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '完成時間/完成才填日期/若完成後有修改也要填日期', '有顏色的欄位,且換行也還沒處理.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '最後修改內容', '更新項目表-最後修改內容',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測回報', '更新項目表-檢測回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '企劃回報', '更新項目表-企劃回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測組別', '更新項目表-檢測組',1,4,'selectbox','"三D", "二D"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '檢測單', '欄位好幾層的設定,還沒處理,TODO弄個表格版型吧..設定資料..與顯示版型分開',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '重要性評比','檢測單-重要性評比',1,4,'selectbox','"1.非常重要","2.很重要","3.普通重要"' );
  gDBManager.AddColumn(vTableID, -1, '測試項目','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '測試項目說明','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '分類', '檢測單-分類',1,4,'selectbox','"A類", "B類", "C類"' );
  gDBManager.AddColumn(vTableID, -1, '測試重點', '檢測單-測試重點',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '預定測試完成時間', '檢測單-預定測試',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '未完成原因','測試結果(V)完成/未完成者請說明原因並回報相關負責人員',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '企劃負責人員', '檢測單-企劃負責人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, 'cheng shi fu ze ren yuan ', 'jian ce dan -cheng shi fu ze ren yuan ',1,4,'selectbox','"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye","wang rui qi ","you","weng","li zhen de ","ruan","guo","huang","wei","mi","lin","lu","lin","zhou","yan","zhang","li"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///


  // 新增一個表格
  gDBManager.AddTable(vTableID, 'BUG表', '過年後新增',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員','BUG表-企劃人員auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '項目','BUG表-項目auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG內容說明','BUG表-BUG內容說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '回報日期','BUG表-回報日期auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '處理狀況','BUG表-處理狀況',1,4,'selectbox','"1.處理中","2.已修正","3.不修正"' );
  gDBManager.AddColumn(vTableID, -1, '狀況說明','BUG表-狀況說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測確認','BUG表-檢測人員',1,4,'selectbox','"1.確認已修正","2.尚未修正"' );
end;


procedure TDBManager.DBTest_MergeTable_SY_China;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;
  /// 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, '[陸版]SiYo四合一表格', '整合四個表格', 1, 2, 1);

  /// 新增合併欄位
  // 欄位 1 設定  企劃負責人 / 人員  / 企劃負責人員
  gDBManager.AddMergeColumn(vMTableID, 1, 1+10, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+10, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+10, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+10, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // 欄位 2 設定  分類 / 分類 / 分類
  gDBManager.AddMergeColumn(vMTableID, 2, 1+10, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+10, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+10, 4, vUserID, vPriority, 'textfield');
  // 欄位 3 設定  項目/ 項目說明 /測試項目
  gDBManager.AddMergeColumn(vMTableID, 3, 1+10, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+10, 3, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+10, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+10, 2, vUserID, vPriority, 'textfield');
  // 欄位 4 設定  項目說明/ 預計更新內容重點說明/ 測試項目說明
  gDBManager.AddMergeColumn(vMTableID, 4, 1+10, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+10, 4, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+10, 3, vUserID, vPriority, 'textfield');
  // 欄位 5 設定  與程式相關度/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+10, 5, vUserID, vPriority, 'selectbox', '"高", "中", "低"');
  // 欄位 6 設定  企劃完成度/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+10, 6, vUserID, vPriority, 'number');
  // 欄位 7 設定  企劃預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+10, 7, vUserID, vPriority, 'date');
  // 欄位 8 設定  程式人員/ / 程式負責人員
  gDBManager.AddMergeColumn(vMTableID, 8, 1+10, 8, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+10, 9, vUserID, vPriority, 'selectbox', '"PY","BS","ZF","ANASN","CRZ","CB","SH"');
  // 欄位 9 設定  程式預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+10, 9, vUserID, vPriority, 'date');
  // 欄位 10 設定  備註/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+10,10, vUserID, vPriority, 'textfield');
  // 欄位 11 設定  本週更新確認/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+10,11, vUserID, vPriority, 'checkbox');
  // 欄位 12 設定  延後時間/事由 / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+10,12, vUserID, vPriority, 'textfield');
  // 欄位 13 設定   /附檔名稱 /    ***更新項目表 start
  gDBManager.AddMergeColumn(vMTableID,13, 2+10, 5, vUserID, vPriority, 'textfield');
  // 欄位 14 設定   /完成時間 /
  gDBManager.AddMergeColumn(vMTableID,14, 2+10, 6, vUserID, vPriority, 'date');
  // 欄位 15 設定   /最後修改內容 /
  gDBManager.AddMergeColumn(vMTableID,15, 2+10, 7, vUserID, vPriority, 'textfield');
  // 欄位 16 設定   /檢測回報 /
  gDBManager.AddMergeColumn(vMTableID,16, 2+10, 8, vUserID, vPriority, 'textfield');
  // 欄位 17 設定   /企劃回報 /
  gDBManager.AddMergeColumn(vMTableID,17, 2+10, 9, vUserID, vPriority, 'textfield');
  // 欄位 18 設定   /檢測組別 /
  gDBManager.AddMergeColumn(vMTableID,18, 2+10,10, vUserID, vPriority, 'selectbox', '"三D", "二D"');
  // 欄位 19 設定   /檢測人員 / 檢測負責人員 / 檢測人員
  gDBManager.AddMergeColumn(vMTableID,19, 2+10,11, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+10,10, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+10, 5, vUserID, vPriority, 'selectbox', '"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');

  // 欄位 20 設定   / / 重要性評比   *** 檢測單 start
  gDBManager.AddMergeColumn(vMTableID,20, 3+10, 1, vUserID, vPriority, 'selectbox', '"1.非常重要","2.很重要","3.普通重要"');
  // 欄位 21 設定   / / 測試重點
  gDBManager.AddMergeColumn(vMTableID,21, 3+10, 5, vUserID, vPriority, 'textfield');
  // 欄位 22 設定   / / 預定測試完成時間
  gDBManager.AddMergeColumn(vMTableID,22, 3+10, 6, vUserID, vPriority, 'date');
  // 欄位 23 設定   / / 未完成原因
  gDBManager.AddMergeColumn(vMTableID,23, 3+10, 7, vUserID, vPriority, 'textfield');
  // 欄位 24 設定   / / / BUG內容說明   *** BUG表 start
  gDBManager.AddMergeColumn(vMTableID,24, 4+10, 3, vUserID, vPriority, 'textfield');
  // 欄位 25 設定   / / / 回報日期
  gDBManager.AddMergeColumn(vMTableID,25, 4+10, 4, vUserID, vPriority, 'date');
  // 欄位 26 設定   / / / 處理狀況
  gDBManager.AddMergeColumn(vMTableID,26, 4+10, 6, vUserID, vPriority, 'selectbox', '"1.處理中","2.已修正","3.不修正"');
  // 欄位 27 設定   / / / 狀況說明
  gDBManager.AddMergeColumn(vMTableID,27, 4+10, 7, vUserID, vPriority, 'textfield');
  // 欄位 28 設定   / / / 檢測確認
  gDBManager.AddMergeColumn(vMTableID,28, 4+10, 8, vUserID, vPriority, 'selectbox', '"1.確認已修正","2.尚未修正"');
end;

procedure TDBManager.DBTest_Table_SY_China;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '企劃進度表', '企劃進度表(參考用)其實只是測試用的',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃負責人', '企劃進度表-這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '分類', '企劃進度表-分類',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目', '企劃進度表-項目',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '企劃進度表-項目說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '與程式相關度', '與程式相關度..只有3種等級',1,4,'selectbox','"高", "中", "低"' );
  gDBManager.AddColumn(vTableID, -1, '企劃完成度', '企畫完成度..只能填數字',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '企劃預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '程式人員', '只能填人名',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );
  gDBManager.AddColumn(vTableID, -1, '程式預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '備註', '企劃進度表-備註',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '本週更新確認', '企劃進度表-本週更新確認',1,4,'checkbox','' );
  gDBManager.AddColumn(vTableID, -1, '延後時間/事由', '企劃進度表-延後時間',1,4,'textfield','' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '更新項目表', '更新項目表(參考用)',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員', '這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '分類', '分類..就是分類阿..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '項目說明..就是....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '預計更新內容重點說明', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '附檔名稱', '....這個還沒設定.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '完成時間/完成才填日期/若完成後有修改也要填日期', '有顏色的欄位,且換行也還沒處理.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '最後修改內容', '更新項目表-最後修改內容',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測回報', '更新項目表-檢測回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '企劃回報', '更新項目表-企劃回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測組別', '更新項目表-檢測組',1,4,'selectbox','"三D", "二D"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '檢測單', '欄位好幾層的設定,還沒處理,TODO弄個表格版型吧..設定資料..與顯示版型分開',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '重要性評比','檢測單-重要性評比',1,4,'selectbox','"1.非常重要","2.很重要","3.普通重要"' );
  gDBManager.AddColumn(vTableID, -1, '測試項目','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '測試項目說明','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '分類', '檢測單-分類',1,4,'selectbox','"A類", "B類", "C類"' );
  gDBManager.AddColumn(vTableID, -1, '測試重點', '檢測單-測試重點',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '預定測試完成時間', '檢測單-預定測試',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '未完成原因','測試結果(V)完成/未完成者請說明原因並回報相關負責人員',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, 'qi hua fu ze ren yuan ', 'jian ce dan -qi hua fu ze ren yuan ',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, 'cheng shi fu ze ren yuan ', 'jian ce dan -cheng shi fu ze ren yuan ',1,4,'selectbox','"PY","BS","ZF","ANASN","CRZ","CB","SH"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///


  // 新增一個表格
  gDBManager.AddTable(vTableID, 'BUG表', '過年後新增',1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員','BUG表-企劃人員auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '項目','BUG表-項目auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG內容說明','BUG表-BUG內容說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '回報日期','BUG表-回報日期auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"Shen","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '處理狀況','BUG表-處理狀況',1,4,'selectbox','"1.處理中","2.已修正","3.不修正"' );
  gDBManager.AddColumn(vTableID, -1, '狀況說明','BUG表-狀況說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測確認','BUG表-檢測人員',1,4,'selectbox','"1.確認已修正","2.尚未修正"' );

end;

procedure TDBManager.DBTest_MergeTable_SDBug;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 3 ;

  // 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, '需求清單', '天空龍的需求功能表+BUG清單', 1, 2, 2);
  // 欄位 1 設定   列出日期
  gDBManager.AddMergeColumn(vMTableID, 1, 15, 1, vUserID, vPriority, 'date');
  // 欄位 2 設定   類型
  gDBManager.AddMergeColumn(vMTableID, 2, 15, 2, vUserID, vPriority, 'selectbox','"功能","操作","資料","BUG"');
  // 欄位 3 設定   功能頁面
  gDBManager.AddMergeColumn(vMTableID, 3, 15, 3, vUserID, vPriority, 'selectbox','"各式表單","內部公告","系統","即時訊息"');
  // 欄位 4 設定   說明
  gDBManager.AddMergeColumn(vMTableID, 4, 15, 4, vUserID, vPriority, 'textfield');
  // 欄位 5 設定   重要程度
  gDBManager.AddMergeColumn(vMTableID, 5, 15, 5, vUserID, vPriority, 'selectbox','"中","低","高","極高"');
  // 欄位 6 設定   執行結果
  gDBManager.AddMergeColumn(vMTableID, 6, 15, 6, vUserID, vPriority, 'selectbox','"O","X"');
  // 欄位 6 設定   備註
  gDBManager.AddMergeColumn(vMTableID, 7, 15, 7, vUserID, vPriority, 'textfield');
end;

procedure TDBManager.DBTest_Table_SDBug;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '需求清單', 'SkyDragon的需求功能表+BUG清單',1, 2, 2);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '列出日期','列出日期auto',1,4,'date' );
  gDBManager.AddColumn(vTableID, -1, '類型','類型~',1,4,'selectbox','"功能","操作","資料","BUG"' );
  gDBManager.AddColumn(vTableID, -1, '功能頁面','功能頁面~',1,4,'selectbox','"各式表單","內部公告","系統","即時訊息"' );
  gDBManager.AddColumn(vTableID, -1, '說明','說明~',1,4,'textfield');
  gDBManager.AddColumn(vTableID, -1, '重要程度','重要程度~',1,4,'selectbox','"中","低","高","極高"' );
  gDBManager.AddColumn(vTableID, -1, '執行結果','執行結果~',1,4,'selectbox','"O","X"' );
  gDBManager.AddColumn(vTableID, -1, '備註','備註~',1,4,'textfield');
end;

procedure TDBManager.DBTest_MergeTable_SYSchedule;
var
  vMTableID: Integer;
  vUserID, vPriority: Integer;
begin
  vUserID := 1 ;
  vPriority:= 1 ;

  // 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, '進度分配表', 'SiYo的進度分配表', 1, 2, 1);
  // 欄位 1 設定   接受狀態
  gDBManager.AddMergeColumn(vMTableID, 1, 16, 1, vUserID, vPriority, 'selectbox', '"盧PY","余BS","林ZF","ANSN","余CRZ","林CB","黃SH","CHIU","PONPON"');
  // 欄位 2 設定   案件
  gDBManager.AddMergeColumn(vMTableID, 2, 16, 2, vUserID, vPriority, 'selectbox','"SiYo台版","SiYo陸版","SuSan","Delphi","工具","TianZi ","中華","SkyDragon"');
  // 欄位 3 設定   項目
  gDBManager.AddMergeColumn(vMTableID, 3, 16, 3, vUserID, vPriority, 'textfield');
  // 欄位 4 設定   企劃/負責人
  gDBManager.AddMergeColumn(vMTableID, 4, 16, 4, vUserID, vPriority, 'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // 欄位 5 設定   知會時間
  gDBManager.AddMergeColumn(vMTableID, 5, 16, 5, vUserID, vPriority, 'date');
  // 欄位 6 設定   企劃案收件時間
  gDBManager.AddMergeColumn(vMTableID, 6, 16, 6, vUserID, vPriority, 'date');
  // 欄位 7 設定   開始時間
  gDBManager.AddMergeColumn(vMTableID, 7, 16, 7, vUserID, vPriority, 'date');
  // 欄位 8 設定   預定完成
  gDBManager.AddMergeColumn(vMTableID, 8, 16, 8, vUserID, vPriority, 'date');
  // 欄位 9 設定   預估所需時間
  gDBManager.AddMergeColumn(vMTableID, 9, 16, 9, vUserID, vPriority, 'textfield');
  // 欄位 10 設定  完成度
  gDBManager.AddMergeColumn(vMTableID,10, 16, 10, vUserID, vPriority, 'selectbox','"OK","延後","!待測","完成","  "');
  // 欄位 11 設定  截止日
  gDBManager.AddMergeColumn(vMTableID,11, 16, 11, vUserID, vPriority, 'date');
  // 欄位 12 設定  更新日
  gDBManager.AddMergeColumn(vMTableID,12, 16, 12, vUserID, vPriority, 'date');
  // 欄位 13 設定  備註
  gDBManager.AddMergeColumn(vMTableID,13, 16, 13, vUserID, vPriority, 'textfield');
end;

procedure TDBManager.DBTest_Table_SYSchedule;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '進度分配表', 'SiYo的進度分配表', 1, 2, 1);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '接受狀態','進度分配表-接受狀態',1,4, 'selectbox', '"PY","JST","JF","ANASN","CRZ","CB","SH"');
  gDBManager.AddColumn(vTableID, -1, '案件','進度分配表-案件',1,4,'selectbox','"SY台版","SY陸版","SuSan","Delphi","工具","TianZi ","ZhongHua ","SkyDragon"' );
  gDBManager.AddColumn(vTableID, -1, '項目','進度分配表-項目',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '企劃/負責人','進度分配表-企劃/負責人',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddColumn(vTableID, -1, '知會時間','進度分配表-知會時間',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '企劃案收件時間','進度分配表-企劃案收件時間',1,4,'date' );
  gDBManager.AddColumn(vTableID, -1, '開始時間','進度分配表-開始時間',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '預定完成','進度分配表-預定完成',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '預估所需時間','進度分配表-預估所需時間',1,4,'textfield');
  gDBManager.AddColumn(vTableID, -1, '完成度','SiYoSuSan項目分,完成(程式完成),待測(給企劃), OK(結束),其他項目 丟檔即結束,僅填 OK',1,4,'selectbox','"OK","延後","!待測","完成","  "');
  gDBManager.AddColumn(vTableID, -1, '截止日','進度分配表-截止日',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '更新日','進度分配表-更新日',1,4,'date');
  gDBManager.AddColumn(vTableID, -1, '備註','進度分配表-備註',1,4,'textfield');
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
  /// 新增一個合併表格
  gDBManager.AddMergeTable(vMTableID, '[陸版]WULIN四合一表格', '整合四個表格', 1, 2, 5);

  /// 新增合併欄位
  // 欄位 1 設定  企劃負責人 / 人員  / 企劃負責人員
  gDBManager.AddMergeColumn(vMTableID, 1, 1+20, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 2+20, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 3+20, 8, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  gDBManager.AddMergeColumn(vMTableID, 1, 4+20, 1, vUserID, vPriority, 'selectbox', '"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"');
  // 欄位 2 設定  分類 / 分類 / 分類
  gDBManager.AddMergeColumn(vMTableID, 2, 1+20, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 2+20, 2, vUserID, vPriority, 'textfield');
  gDBManager.AddMergeColumn(vMTableID, 2, 3+20, 4, vUserID, vPriority, 'textfield');
  // 欄位 3 設定  項目/ 項目說明 /測試項目
  gDBManager.AddMergeColumn(vMTableID, 3, 1+20, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 2+20, 3, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 3+20, 2, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 3, 4+20, 2, vUserID, vPriority, 'textarea');
  // 欄位 4 設定  項目說明/ 預計更新內容重點說明/ 測試項目說明
  gDBManager.AddMergeColumn(vMTableID, 4, 1+20, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 2+20, 4, vUserID, vPriority, 'textarea');
  gDBManager.AddMergeColumn(vMTableID, 4, 3+20, 3, vUserID, vPriority, 'textarea');
  // 欄位 5 設定  與程式相關度/ /
  gDBManager.AddMergeColumn(vMTableID, 5, 1+20, 5, vUserID, vPriority, 'selectbox', '"高", "中", "低"');
  // 欄位 6 設定  企劃完成度/ /
  gDBManager.AddMergeColumn(vMTableID, 6, 1+20, 6, vUserID, vPriority, 'selectbox', '"0%","10%","20%","30%","40%","50%","60%","70%","80%","90%","100%"');
  // 欄位 7 設定  企劃預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 7, 1+20, 7, vUserID, vPriority, 'date');
  // 欄位 8 設定  程式人員/ / 程式負責人員
  gDBManager.AddMergeColumn(vMTableID, 8, 1+20, 8, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye ","wang ","you  ","weng wei ","REAL","ruan yuan ","guo bin ","huang ","wei hong ","mi ","lin ","lu ","lin","zhou rong ","ya ","zhang ","li "');
  gDBManager.AddMergeColumn(vMTableID, 8, 3+20, 9, vUserID, vPriority, 'selectbox', '"li xin yan ","dai guang xian ","yan ","cai","li kun yu ","yang","ye ","wang ","you  ","weng wei ","REAL","ruan yuan ","guo bin ","huang ","wei hong ","mi ","lin ","lu ","lin","zhou rong ","ya ","zhang ","li "');
  // 欄位 9 設定  程式預估完成日期/ /
  gDBManager.AddMergeColumn(vMTableID, 9, 1+20, 9, vUserID, vPriority, 'date');
  // 欄位 10 設定  備註/ /
  gDBManager.AddMergeColumn(vMTableID,10, 1+20,10, vUserID, vPriority, 'textarea');
  // 欄位 11 設定  本週更新確認/ /
  gDBManager.AddMergeColumn(vMTableID,11, 1+20,11, vUserID, vPriority, 'selectbox','"確認更新","延後"');
  // 欄位 12 設定  延後時間/事由 / /
  gDBManager.AddMergeColumn(vMTableID,12, 1+20,12, vUserID, vPriority, 'textarea');
  // 欄位 13 設定   /附檔名稱 /    ***更新項目表 start
  gDBManager.AddMergeColumn(vMTableID,13, 2+20, 5, vUserID, vPriority, 'textfield');
  // 欄位 14 設定   /完成時間 /
  gDBManager.AddMergeColumn(vMTableID,14, 2+20, 6, vUserID, vPriority, 'date');
  // 欄位 15 設定   /最後修改內容 /
  gDBManager.AddMergeColumn(vMTableID,15, 2+20, 7, vUserID, vPriority, 'textarea');
  // 欄位 16 設定   /檢測回報 /
  gDBManager.AddMergeColumn(vMTableID,16, 2+20, 8, vUserID, vPriority, 'textarea');
  // 欄位 17 設定   /企劃回報 /
  gDBManager.AddMergeColumn(vMTableID,17, 2+20, 9, vUserID, vPriority, 'textarea');
  // 欄位 18 設定   /檢測組別 /
  gDBManager.AddMergeColumn(vMTableID,18, 2+20,10, vUserID, vPriority, 'selectbox', '"三D", "二D"');
  // 欄位 19 設定   /檢測人員 / 檢測負責人員 / 檢測人員
  gDBManager.AddMergeColumn(vMTableID,19, 2+20,11, vUserID, vPriority, 'selectbox', '"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 3+20,10, vUserID, vPriority, 'selectbox', '"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  gDBManager.AddMergeColumn(vMTableID,19, 4+20, 5, vUserID, vPriority, 'selectbox', '"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "');
  // 欄位 20 設定   / / 重要性評比   *** 檢測單 start
  gDBManager.AddMergeColumn(vMTableID,20, 3+20, 1, vUserID, vPriority, 'selectbox', '"1.非常重要","2.很重要","3.普通重要"');
  // 欄位 21 設定   / / 測試重點
  gDBManager.AddMergeColumn(vMTableID,21, 3+20, 5, vUserID, vPriority, 'textarea');
  // 欄位 22 設定   / / 預定測試完成時間
  gDBManager.AddMergeColumn(vMTableID,22, 3+20, 6, vUserID, vPriority, 'date');
  // 欄位 23 設定   / / 未完成原因
  gDBManager.AddMergeColumn(vMTableID,23, 3+20, 7, vUserID, vPriority, 'textarea');
  // 欄位 24 設定   / / / BUG內容說明   *** BUG表 start
  gDBManager.AddMergeColumn(vMTableID,24, 4+20, 3, vUserID, vPriority, 'textarea');
  // 欄位 25 設定   / / / 回報日期
  gDBManager.AddMergeColumn(vMTableID,25, 4+20, 4, vUserID, vPriority, 'date');
  // 欄位 26 設定   / / / 處理狀況
  gDBManager.AddMergeColumn(vMTableID,26, 4+20, 6, vUserID, vPriority, 'selectbox', '"1.處理中","2.已修正","3.不修正"');
  // 欄位 27 設定   / / / 狀況說明
  gDBManager.AddMergeColumn(vMTableID,27, 4+20, 7, vUserID, vPriority, 'textarea');
  // 欄位 28 設定   / / / 檢測確認
  gDBManager.AddMergeColumn(vMTableID,28, 4+20, 8, vUserID, vPriority, 'selectbox', '"1.確認已修正","2.尚未修正"');
end;

procedure TDBManager.DBTest_Table_WuLin;
var
  vTableID: Integer;
begin
  // 新增一個表格
  gDBManager.AddTable(vTableID, '[陸][WULIN]企劃進度表', '企劃進度表(參考用)其實只是測試用的',1, 2, 5);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃負責人', '企劃進度表-這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///.........
  gDBManager.AddColumn(vTableID, -1, '分類', '企劃進度表-分類',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目', '企劃進度表-項目',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '企劃進度表-項目說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '與程式相關度', '與程式相關度..只有3種等級',1,4,'selectbox','"高", "中", "低"' );
  gDBManager.AddColumn(vTableID, -1, '企劃完成度', '企畫完成度..只能填數字',1,4,'number','' );
  gDBManager.AddColumn(vTableID, -1, '企劃預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '程式人員', '只能填人名',1,4,'selectbox','"PY","BS","ZF","ANS","CRZ","CB","SH"' );
  gDBManager.AddColumn(vTableID, -1, '程式預估完成日期', '企劃進度表-日期',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '備註', '企劃進度表-備註',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '本週更新確認', '企劃進度表-本週更新確認',1,4,'selectbox','"確認更新","延後"' );
  gDBManager.AddColumn(vTableID, -1, '延後時間/事由', '企劃進度表-延後時間',1,4,'textfield','' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '[陸][WULIN]更新項目表', '更新項目表(參考用)',1, 2, 5);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員', '這個欄位只能填企劃人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );    ///.......
  gDBManager.AddColumn(vTableID, -1, '分類', '分類..就是分類阿..',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '項目說明', '項目說明..就是....',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '預計更新內容重點說明', '.....',1,4,'textfield' );
  gDBManager.AddColumn(vTableID, -1, '附檔名稱', '....這個還沒設定.',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '完成時間/完成才填日期/若完成後有修改也要填日期', '有顏色的欄位,且換行也還沒處理.',1,4,'date','' );
  gDBManager.AddColumn(vTableID, -1, '最後修改內容', '更新項目表-最後修改內容',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測回報', '更新項目表-檢測回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '企劃回報', '更新項目表-企劃回報',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測組別', '更新項目表-檢測組',1,4,'selectbox','"三D", "二D"' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ', 'mu qian xie si hou xu yong huo de ',1,4,'selectbox','"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );

  // 新增一個表格
  gDBManager.AddTable(vTableID, '[陸][WULIN]檢測單', '欄位好幾層的設定,還沒處理,TODO弄個表格版型吧..設定資料..與顯示版型分開',1, 2, 5);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '重要性評比','檢測單-重要性評比',1,4,'selectbox','"1.非常重要","2.很重要","3.普通重要"' );
  gDBManager.AddColumn(vTableID, -1, '測試項目','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '測試項目說明','檢測單-測試項目',1,4,'textfield','' );    ///////////
  gDBManager.AddColumn(vTableID, -1, '分類', '檢測單-分類',1,4,'selectbox','"A類", "B類", "C類"' );
  gDBManager.AddColumn(vTableID, -1, '測試重點', '檢測單-測試重點',1,4,'textfield' );            ////
  gDBManager.AddColumn(vTableID, -1, '預定測試完成時間', '檢測單-預定測試',1,4,'date' );            ////
  gDBManager.AddColumn(vTableID, -1, '未完成原因','測試結果(V)完成/未完成者請說明原因並回報相關負責人員',1,4,'textfield' );            ////          ////
  gDBManager.AddColumn(vTableID, -1, '企劃負責人員', '檢測單-企劃負責人員',1,6,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );   ///
  gDBManager.AddColumn(vTableID, -1, '程式負責人員', '檢測單-程式負責人員',1,4,'selectbox','"PY","BS","ZF","ANS","CRZ","CB","SH"' );  ///
  gDBManager.AddColumn(vTableID, -1, 'jian ce fu ze ren yuan ', 'jian ce dan -jian ce fu ze ren yuan ',1,4,'selectbox','"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );  ///

  // 新增一個表格
  gDBManager.AddTable(vTableID, '[陸][WULIN]BUG表', '過年後新增',1, 2, 5);
  // 新增欄位
  gDBManager.AddColumn(vTableID, -1, '企劃人員','BUG表-企劃人員auto',1,4,'selectbox','"YENYEN","HOHOOHOH","KUOOOOO","WANG","ACEE","WizardWu","ShienYY",'+'"CHH","MING","CZR","HUANGPURE","AMYLLLLLIU"'+',"HAVEFACE","KUOZENG","SHENG","ChenZU","EVERTEN","CLL","TongZenZen","ADDMON","TING","VICKYPPPAANNN","ONESHOT","REEEEDED","C3","LHHZ","HSY","TingY","FUCKKUO","GDTK","TENKEN","ANNIECHANG","HOMEB","LIANGKB","JU","CHENSHSH","YOYEN","TON"' );
  gDBManager.AddColumn(vTableID, -1, '項目','BUG表-項目auto',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, 'BUG內容說明','BUG表-BUG內容說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '回報日期','BUG表-回報日期auto',1,4,'date','now()' );
  gDBManager.AddColumn(vTableID, -1, 'jian ce ren yuan ','BUGbiao -jian ce ren yuan auto',1,4,'selectbox','"lin sheng kai ","zhou shi hao ","lin tian yi ","lin li xuan ","LINSSS"'+',"xu chun yang ","CLONGBB","su xing xuan ","lai hong lin ","wang xin yi ","deng xiao qi "'+',"CHANGHHH","wu yu xin ","LUNGSS","jian yong xiong ","lin ya shu ",'+'"cai cheng en ","jiang zheng dian ","chen jun hong ","ZonShow","lin wen zhong ",'+'"LUHH","cao ze min ","liu shi pei ","wu xin da ","shi ya ling ","liu yu kai ","lin qi hong ","pan xin song ","huai zi jie ","lan yu bin ","jiang he yuan ","LeafLin","chen qiao wei ","yang yi quan ",'+'"li yan ?","ZAWZH","ZiHuan","xu xian hui ","lin yi xuan ","lin yuan yi ","shen bai guang ","guo pei ru ","CHENYUUU","CANDYZZZ","HKS","CHENZR","HHB","HCN","wang juan ru ","chen pin han ","lin zheng qian ","lin yu ting ","qiu zhao xuan "' );
  gDBManager.AddColumn(vTableID, -1, '處理狀況','BUG表-處理狀況',1,4,'selectbox','"1.處理中","2.已修正","3.不修正"' );
  gDBManager.AddColumn(vTableID, -1, '狀況說明','BUG表-狀況說明',1,4,'textfield','' );
  gDBManager.AddColumn(vTableID, -1, '檢測確認','BUG表-檢測人員',1,4,'selectbox','"1.確認已修正","2.尚未修正"' );
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

  if aTableID <= 0 then  //查無此編號的Table
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

  aRecordSet.DiscardNull(aColumnName);  // 預防 aColumnName 欄位有 NULL 值發生
  
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
