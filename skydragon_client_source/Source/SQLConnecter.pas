{$I define.h}
unit SQLConnecter ;
(**************************************************************************
 * SQL 資料庫相關元件 
 *************************************************************************)
interface

uses
  SysUtils, Classes, ComCtrls,
  Dialogs, SqlExpr;

const
  cDefaultCode         = 'BIG5';                /// Default char code

  cMYSQL_DriverName    = 'dbxmysql';
  cMYSQL_GetDriverFunc = 'getSQLDriverMYSQL50';
  cMYSQL_LibraryName   = 'dbxopenmysql50.dll';
  cMYSQL_VendorLib     = 'libmysql.dll';

  cMSSQL_DriverName    = '';
  cMSSQL_GetDriverFunc = '';
  cMSSQL_LibraryName   = '';
  cMSSQL_VendorLib     = '';

  cQuerySaveNums       = 10;  /// 儲存備用的Query指令,會影響效能,謹慎開數量。
type
  (********************************************
   * RowSet Set of DB Source
   ********************************************)
  TRowSet       = class;    (** RowSet Set of DB Source **)

  (******************************************
  * Record Set of DB Source 資料庫回傳的資料集.
  *
  * @Version 2010/01/15 v1.0 初版
  * @Version 2010/02/02 v1.1 可以刪除一列資料 (RowSet)
  * @Version 2010/03/23 v1.2 增加檢查欄位 (ColumnExist) 和剔除空值(DiscardNull) 功能
  ******************************************)
  TRecordSet    = class;

  (********************************************
   * SQL DB Connect Handler 資料庫連線管理器,
   * 需搭配 DbExpress drivers for MySQL V5.0 (dbxopenmysql50.dll)
   * http://www.justsoftwaresolutions.co.uk/delphi/dbexpress_and_mysql_5.html
   *
   * @Author  Swings Huang
   * @Version 2010/01/15 v1.0 初版
   * @Version 2010/01/27 v1.1 增加 Pause 功能
   *
   * @Todo    1. 無法連線時的處理
   *          2. DBX SQL error 的錯誤處理
   *          3. DBX Join 難使, 需強化 RecordSet 增加欄位的方法 , 以取代合併功能
   *             EX: RecordSet.Row[ 1, 'new'] = 'newvalue'
   ********************************************)
  TSQLConnecter = class;
  
  (********************************************
   * Definition of DB Source 資料庫來源類息定義
   ********************************************)
  TDatabaseKind = (MySQL, MSSQL, MSAccess, Paradox);

  TRowSet = class
  private
    mValues   : array of String ;       /// ColumnValue  欄位內容
    mCount    : Integer;                /// Column Number
    function  GetValue(aCount: Integer): String;
    procedure SetValue(aCount: Integer; const aValue: String);
  public
    destructor Destroy; override;
    property Value[Count: Integer]: String read GetValue write SetValue;
    property Count:Integer read mCount;
  end;

  TRecordSet = class(TObject)
  private
    mColumnName  : TStringList;                                                 /// Column Info 欄位資訊 : ColumnName   欄位名稱
    mColumnType  : TStringList ;                                                /// Column Info 欄位資訊 : ColumnType   欄位類型
    mRows        : array of TRowSet ;                                           /// Row Info    資料列資訊 :RowSet Records
    mRowNums     : Integer;                                                     /// Row Info    資料列資訊
    mColNums     : Integer;
    // mRowCount    : Integer ;                                                 /// Row count ( resource id )  TODO:再考慮是否要用next指針
    function GetRow(aCount: Integer; aColumName: String): String;               /// Get RowValue by ColumName
    function GetRowSet(aCount: Integer): TRowSet;                               /// Get RowSet
    function GetColumnID(aColumName: String) : Integer;                         /// Get ColumnID By Name
  protected
  public
    // property Count: Integer read mRowCount write mRowCount;
    constructor Create;
    destructor Destroy; override;
    function ColumnExist(aColName: String):Boolean;                             /// Check If column exist
    function AddRowSet(aRowSet: TRowSet): Boolean;                              /// Add one rowset
    function DeleteRowSet(aCount: Integer): Boolean;                            /// Delete one rowset
    procedure DiscardNull;overload;                                             /// Discard NULL value, DBX1.0 有時有怪異的Null值必須清除
    procedure DiscardNull(aColName:String); overload;
    property RowNums: Integer read mRowNums write mRowNums;
    property ColNums: Integer read mColNums write mColNums;
    property ColumnName: TStringList read mColumnName write mColumnName;
    property Row[Count: Integer; ColumName: String] : String read GetRow;
    property RowSet[Count: Integer]: TRowSet read GetRowSet;                    /// 使用範例: RecordSet.Rows[ 1 , 'example_id' ];
  end;

  TSQLConnecter = class(TObject)
  private
    (** DB Connect Information **)
    mDBName       : String;
    mUserName     : String;
    mUserPassword : String;
    mHostName     : String;
    mDBKind       : TDatabaseKind;
    mConnection   : TSQLConnection;  /// MySQL connect component
    mQuery        : TSQLQuery;       /// MySQL Query languange component
    mDebugMode    : Boolean;         /// Switch to debug mode
    mDebugEdit    : TRichEdit ;      /// SQL debug memo, will Save all executed Query.
    mDefaultCode  : String;          /// for MySQL 'SET NAMES', default code page
    mQueryString  : String;          /// previous Saved query
    mQueryList    : TStringList;     /// 
    mPause        : Boolean;         /// Pause mode, will not do Query, but store QueryString
    (** MySQL specific functions *)
    procedure MySQL_SetComponent(aConnection: TSQLConnection; aQuery: TSQLQuery);
    function  MySQL_Query(aQueryString: String): TRecordSet;                      /// start query, return RS result
    procedure MySQL_FetchRows(var aQuery: TSQLQuery; out aRecordSet: TRecordSet );/// fetch result data to TRecordSet
    function  MySQL_ExecuteQuery(aQueryString: String):Integer;                   /// execute query, return EffectRows
    function  MySQL_SetNames:Integer;                                             /// Set Encode Decode set
    (** MSSQL specific functions *)
    procedure MSSQL_SetComponent(aConnection: TSQLConnection; aQuery: TSQLQuery); /// (TODO:)
    function  MSSQL_Query(aQueryString: String): TRecordSet;                      /// (TODO:)start query, return RS result
    procedure MSSQL_FetchRows(var aQuery: TSQLQuery; out aRecordSet: TRecordSet );/// (TODO:)fetch result data to TRecordSet
    function  MSSQL_ExecuteQuery(aQueryString: String):Integer;                   /// (TODO:)execute query, return EffectRows
    (** Debug functions *)
    procedure DEBUG_SetComponent(aREdit:TRichEdit);
    procedure DEBUG_DumpQuery(aQuery: String);
    procedure DEBUG_DumpResult(aRecordSet: TRecordSet);overload;
    procedure DEBUG_DumpResult(aEffectRows: Integer);overload;
    function  DEBUG_QueryInList(aQuery: String):Boolean;                          /// check if already in query save list
    function  DEBUG_QuerySave(aQuery: String):Boolean;
    (** Others *)
    function  GetQueryString: String;                                             /// get query string
  protected
    //function CheckCaller;                                                       /// 檢查呼叫元件的 class
  public
    constructor Create(aDBKind: TDatabaseKind);
    destructor Destroy;override;
    procedure Init;
    function  Query(aQueryString: String): TRecordSet;                            /// start query, return RS result
    function  ExecuteQuery(aQueryString: String): Integer;                        /// execute query, return EffectRows
    procedure SetComponent(aConnection: TSQLConnection; aQuery: TSQLQuery);overload; /// before do stuff, Set component
    procedure SetParams(aDBName, aUserName, aUserPassword,
                        aHostName: String);  overload;                            /// Append DB Params
    procedure SetParams(const aParams: array of String); overload;                /// Append DB Params
    procedure SetCode;
    function  QueryError: Boolean;overload;                                       /// TODO: Check result error
    procedure Connect;overload;                                                   /// connect to SQL Database
    procedure Connect(aDBName, aUserName, aUserPassword, aHostName: String;
                      aDBKind: TDatabaseKind); overload;                          /// use param connect to SQL Database
    procedure Disconnect;                                                         /// disconnect to SQL Database
    procedure AddDebugLog(aStr: String);                                          /// For n SQL debug 
    (** PropertyS *)
    property  QueryString: String read GetQueryString ;
    property  Pause: Boolean read mPause write mPause ;
    property  DebugMode: Boolean read mDebugMode write mDebugMode; 
  end;

implementation

uses
  Debug, Math, Graphics, DBManager;

{ TSQLConnecter }

constructor TSQLConnecter.Create(aDBKind: TDatabaseKind);
begin
  mDBKind:= aDBKind;
  mDebugMode:= False;
  mDefaultCode:= cDefaultCode;
  mQueryList:= TStringList.Create;
{$ifdef Debug}
  mDebugMode:= True;
{$endif}
end;

destructor TSQLConnecter.Destroy;
begin
  mConnection := nil ;
  mQuery      := nil ;

  inherited;
end;

procedure TSQLConnecter.Init;
begin
  DEBUG_SetComponent(DebugForm.DebugREdit);
end;

procedure TSQLConnecter.Connect;
begin
  if (mConnection = nil) OR (mQuery = nil) then
  begin
{$ifdef Debug}
    ShowMessage('SQLConnecter.Connect Error !');
{$endif}    
    Exit ;
  end;


  try
    mConnection.Open;     /// Open Connect
  except
    on E : Exception do
      ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;

  SetCode;              /// Set CharSet
end;

procedure TSQLConnecter.Connect(aDBName, aUserName, aUserPassword,
  aHostName: String; aDBKind: TDatabaseKind);
begin
  if (mConnection = nil) OR (mQuery = nil) then
  begin
{$ifdef Debug}  
    ShowMessage('SQLConnecter.Connect Error !');
{$endif}    
    Exit ;
  end;

  try
    mConnection.Params.Append('Database='  + aDBName       );
    mConnection.Params.Append('User_Name=' + aUserName     );
    mConnection.Params.Append('Password='  + aUserPassword );
    mConnection.Params.Append('HostName='  + aHostName     );
  except
{$ifdef Debug}
    ShowMessage('SQLConnecter.Connect Error !');
{$endif}    
  end;

  mConnection.Open;     /// Open Connect
  SetCode;              /// 連線時設定編碼
end;

procedure TSQLConnecter.Disconnect;
begin
  mConnection.Close;    /// Close Connect
end;

procedure TSQLConnecter.SetParams(const aParams: array of String);
var
  i : Integer ;
begin
  if mConnection = nil then
    Exit ;

  for i:= Low(aParams) to High(aParams) do
  begin
     mConnection.Params.Append(aParams[i]);
  end;

end;

procedure TSQLConnecter.SetParams(aDBName, aUserName, aUserPassword,
  aHostName: String);
begin
  try
    mDBName       := aDBName ;
    mUserName     := aUserName ;
    mUserPassword := aUserPassword ;
    mHostName     := aHostName ;
    mConnection.Params.Append('Database='  + mDBName       );
    mConnection.Params.Append('User_Name=' + mUserName     );
    mConnection.Params.Append('Password='  + mUserPassword );
    mConnection.Params.Append('HostName='  + mHostName     );
  except
{$ifdef Debug} 
    ShowMessage('Database SetParams Error !')
{$endif}     
  end;
end;

(**************************************************************************
 *                         MySQL functions
 *************************************************************************)
function TSQLConnecter.MySQL_ExecuteQuery(aQueryString: String):Integer;
begin
  Result:= 0 ;
  if aQueryString = '' then
    Exit;
    
  mQuery.SQL.Text:= aQueryString ;
  try
    Result:= mQuery.ExecSQL()     /// execute query, return EffectRows
  except
{$ifdef Debug}   
    ShowMessage('MySQL ExecuteQuery Error !');
{$endif}     
  end;

end;

function TSQLConnecter.MySQL_Query(aQueryString: String): TRecordSet;
var
  vRecordSet: TRecordSet;
begin
  Result:= nil ;
  if aQueryString = '' then
    Exit;

  mQuery.Close;
  mQuery.SQL.Text:= aQueryString;

  try
    mQuery.Prepared:= True;
    mQuery.Open;
  except
{$ifdef Debug}   
    ShowMessage('MySQL Query Error !');
{$endif}     
  end;
  // mQuery.FetchAll;  /// avoid dead lock 釋放資源,避免死鎖佔用資料表。(for 共同查詢) 
  if QueryError then
    Exit;
  
  MySQL_FetchRows(mQuery, vRecordSet);
  Result:= vRecordSet;
end;

procedure TSQLConnecter.MySQL_FetchRows(var aQuery: TSQLQuery;
  out aRecordSet: TRecordSet);
var
  i, j : Integer;
  vRow: TRowSet;
begin
  aRecordSet:= nil ;
  vRow:= nil;
  if aQuery = nil then
    Exit;

  aRecordSet := TRecordSet.Create;
  aRecordSet.mRowNums := mQuery.RecordCount;
  aRecordSet.mColNums := mQuery.Fields.Count;

  for i:= 0 to aQuery.Fields.Count -1 do    /// Fetch Filed Name
  begin
    aRecordSet.ColumnName.Add(aQuery.Fields[i].FieldName);
  end;

  for j:= 0 to aQuery.RecordCount -1 do     /// Fetch Filed Value
  begin
    if vRow <> nil then
      FreeAndNil(vRow);
    vRow:= TRowSet.Create ;
    
    for i:= 0 to aQuery.Fields.Count -1 do
      vRow.Value[i]:= aQuery.Fields[i].AsString;
    aRecordSet.AddRowSet(vRow);
    aQuery.Next;
  end;
end;

procedure TSQLConnecter.MySQL_SetComponent(aConnection: TSQLConnection;
  aQuery: TSQLQuery);
begin
  if (aConnection = nil) OR (aQuery = nil) then
  begin
{$ifdef Debug}   
    ShowMessage('SQLConnecter.Create Error !');
{$endif}     
    Exit ;
  end;
  mConnection := aConnection ;
  mQuery := aQuery ;
  mQuery.SQLConnection := mConnection ;   /// Combine
end;

function TSQLConnecter.MySQL_SetNames: Integer;
begin
  Result := -1 ;
  if (mConnection = nil) OR (mQuery = nil) then
  begin
{$ifdef Debug}   
    ShowMessage('SQLConnecter.Create Error !');
{$endif}     
    Exit ;
  end;

  MySQL_ExecuteQuery( Format( 'SET NAMES %s', [mDefaultCode] ) );
end;

(**************************************************************************
 *                         MySQL functions End
 *************************************************************************)

function TSQLConnecter.Query(aQueryString: String): TRecordSet;
begin
  result:= nil;
{$ifdef Debug}
  if DEBUG_QueryInList(aQueryString) = false then    // avoid Save same memo
    DEBUG_DumpQuery(aQueryString);
{$endif}
  if mPause = True then    // pause mode, only save QueryString
    Exit;
    
  case mDBKind of
    MySQL:
      result:= MySQL_Query(aQueryString);
    MSSQL:
      result:= MSSQL_Query(aQueryString); /// (* TODO: *)
  end;
  
{$ifdef Debug}
  if DEBUG_QueryInList(aQueryString) = false then    // avoid Save same memo
  begin
    DEBUG_DumpResult(result);
    DEBUG_QuerySave(aQueryString);
  end;
{$endif}

  mQueryString := aQueryString;
end;

function TSQLConnecter.ExecuteQuery(aQueryString: String): Integer;
begin
  result:= 0;

  mQueryString:= aQueryString;
{$ifdef Debug}
  if DEBUG_QueryInList(aQueryString) = false then    // avoid Save same memo
    DEBUG_DumpQuery(aQueryString);
{$endif}
  if mPause = True then    // pause mode, only save QueryString
    Exit;

  case mDBKind of
    MySQL:
      result:= MySQL_ExecuteQuery(aQueryString);
    MSSQL:
      result:= MSSQL_ExecuteQuery(aQueryString); /// (* TODO: *)
  end;

{$ifdef Debug}
  if DEBUG_QueryInList(aQueryString) = false then    // avoid Save same memo
  begin
    DEBUG_DumpResult(result);
    DEBUG_QuerySave(aQueryString);
  end;
{$endif}

  mQueryString := aQueryString;
end;

procedure TSQLConnecter.SetComponent(aConnection: TSQLConnection;
  aQuery: TSQLQuery);
begin
  case mDBKind of
    MySQL:
    begin
      MySQL_SetComponent(aConnection, aQuery);
      mConnection.DriverName    := cMYSQL_DriverName;
      mConnection.GetDriverFunc := cMYSQL_GetDriverFunc;
      mConnection.LibraryName   := cMYSQL_LibraryName;
      mConnection.VendorLib     := cMYSQL_VendorLib;
    end;
    MSSQL:
      /// (* TODO: *)  
  end;
end;

function TSQLConnecter.MSSQL_ExecuteQuery(aQueryString: String): Integer;
begin
  Result:= 0;
end;

procedure TSQLConnecter.DEBUG_SetComponent(aREdit: TRichEdit);
begin
  if aREdit = nil then
    Exit;
    
  mDebugEdit:= aREdit;
end;

procedure TSQLConnecter.DEBUG_DumpQuery(aQuery: String);
begin
  if mDebugMode = False then
    Exit;
  if aQuery = '' then
    Exit;
  if mDebugEdit = nil then
    Exit;
    
  mDebugEdit.Lines.Add(StringOfChar('=',80));
  mDebugEdit.Lines.Add(aQuery);
end;

procedure TSQLConnecter.DEBUG_DumpResult(aRecordSet: TRecordSet);
var
  i, j: Integer;
  vLen: Byte;
  vName, vVal, vLog, vStr: String;
begin
  if mDebugMode = False then
    Exit;
  if aRecordSet = nil then
    Exit;
  if mDebugEdit = nil then
    Exit;  

  mDebugEdit.Lines.Add(StringOfChar('-',30) + '擷取一筆結果' +StringOfChar('-',30));
  vLog:= '';
  vLen:= Min(aRecordSet.RowNums, 1);    // show max to 2 rows for example
  for i:=0 to vLen - 1 do
  begin
    for j:=0 to aRecordSet.ColumnName.Count -1 do
    begin
      // Set String
      vName:= aRecordSet.ColumnName[j];
      vVal := aRecordSet.Row[i,vName];
      vStr := Format('%s(%s)  ',[vName,vVal]);
      vLog := vLog + vStr;
    end;
    mDebugEdit.Lines.Add(vLog);
  end;
end;

procedure TSQLConnecter.DEBUG_DumpResult(aEffectRows: Integer);
begin
  if mDebugMode = False then
    Exit;
  if mDebugEdit = nil then
    Exit;
    
  mDebugEdit.Lines.Add(StringOfChar('-',30) + '列出影響的資料筆數' +StringOfChar('-',30));
  mDebugEdit.Lines.Add('Effect Rows: # ' + IntToStr(aEffectRows) );
end;

function TSQLConnecter.DEBUG_QueryInList(aQuery: String): Boolean;
begin
  result:= false;
  if mQueryList.IndexOf(aQuery) <> -1 then
    result:= true
end;

function TSQLConnecter.DEBUG_QuerySave(aQuery: String): Boolean;
begin
  result:= false;
  if aQuery = '' then
    Exit;
  if mQueryList.Count >= cQuerySaveNums then
    mQueryList.Delete(0);

  mQueryList.Add(aQuery);
end;

procedure TSQLConnecter.MSSQL_FetchRows(var aQuery: TSQLQuery;
  out aRecordSet: TRecordSet);
begin
 aRecordSet:= nil ;
end;

function TSQLConnecter.MSSQL_Query(aQueryString: String): TRecordSet;
begin
  Result:= nil;
end;

procedure TSQLConnecter.MSSQL_SetComponent(aConnection: TSQLConnection;
  aQuery: TSQLQuery);
begin

end;

function TSQLConnecter.QueryError: Boolean;
begin
  Result:= False;
end;


procedure TSQLConnecter.SetCode;
begin
  case mDBKind of
    MySQL:
    begin
      MySQL_SetNames;
    end;
    MSSQL:
      /// (* TODO: *)  
  end;
end;

function TSQLConnecter.GetQueryString: String;
begin
  Result:= mQueryString;
end;

procedure TSQLConnecter.AddDebugLog(aStr: String);
begin
  mDebugEdit.Lines.Add(StringOfChar('=',80));
  mDebugEdit.Lines.Add(Format(' NOT SQL : %s', [aStr]));
end;

{ TRowSet }

destructor TRowSet.Destroy;
begin
  FillChar(mValues, sizeof(mValues), 0);
  mValues:= nil;
  inherited;
end;

function TRowSet.GetValue( aCount: Integer): String;
begin
  Result := '' ;
  if aCount > High( mValues ) then
    Exit;

  Result := mValues[ aCount ];
end;

procedure TRowSet.SetValue( aCount: Integer; const aValue: String);
begin
  if aCount >= Length( mValues ) then
    SetLength( mValues, aCount + 1 );

  mCount:= Length(mValues);
  mValues[aCount] := aValue ;
end;

{ TRecordSet }

function TRecordSet.AddRowSet(aRowSet: TRowSet): Boolean;
var
  vLength: Integer;
  i : Integer ;
begin
  Result:= False ;
  if aRowSet = nil then
    Exit;

  vLength:= Length(mRows);
  SetLength(mRows, vLength+1);

  mRows[ vLength ]:= TRowSet.Create;
  for i:= 0 to aRowSet.Count - 1 do
  begin
    mRows[ vLength ].SetValue( i, aRowSet.Value[i] ); // Copy to member
  end;
end;

function TRecordSet.DeleteRowSet(aCount: Integer): Boolean;
var
  vLength: Integer;
  i : Integer ;
begin
  Result:= False ;
  if aCount < 0 then
    Exit;

  vLength:= Length(mRows);
  if aCount >= vLength then
    Exit;

  FreeAndNil(mRows[aCount]);
  
  for i:= aCount+1 to vLength - 1 do
    mRows[i-1]:= mRows[i];
    
  SetLength(mRows, vLength-1);
  Dec(mRowNums);  
end;

constructor TRecordSet.Create;
begin
  mColumnName:= TStringList.Create;
  mColumnType:= TStringList.Create;
  mRowNums   := 0;
  mColNums   := 0;
end;

destructor TRecordSet.Destroy;
begin
  mColumnName.Clear;
  FreeAndNil( mColumnName );
  mColumnType.Clear;
  FreeAndNil( mColumnType );

  fillChar(mRows, SizeOf(mRows), 0);
  mRowNums := 0 ;
  inherited;
end;

function TRecordSet.GetColumnID(aColumName: String): Integer;
begin
  Result:= mColumnName.IndexOf(aColumName);
  if Result = -1 then
{$ifdef Debug}   
    ShowMessage( Format('Column Name [%s] not found !', [aColumName])) ;
{$endif}     
end;

function TRecordSet.GetRow(aCount: Integer; aColumName: String): String;
var
  vColumnID : Integer ;
begin
  Result := '' ;
  if aCount < 0 then
    Exit ;

  if Length(mRows) = 0 then
  begin
{$ifdef Debug}  
    ShowMessage(Format('Can''t Access [%s], Rows is Empty!', [aColumName]));
{$endif}
    Exit ;    
  end;

  if aCount >= Length(mRows) then   /// Rows Count out of range !
  begin
{$ifdef Debug}
    ShowMessage('Rows Count out of range !');
{$endif}
    Exit ;
  end;

  vColumnID := GetColumnID( aColumName ) ; 
  if vColumnID < 0 then
    Exit;

  Result := mRows[ aCount ].Value[ vColumnID ] ;
end;

function TRecordSet.GetRowSet(aCount: Integer): TRowSet;
begin
  Result := nil ;

  if aCount <= 0 then
    Exit ;

  if aCount >= Length( mRows ) then   /// Rows Count out of range !
  begin
{$ifdef Debug}   
    ShowMessage('Rows Count out of range !');
{$endif}     
    Exit ;
  end;
  Result := mRows[aCount];
end;

procedure TRecordSet.DiscardNull;
var
  i, j: Integer;
  vAllNULL: Boolean;
begin
  try
    for i:=0 to mRowNums-1 do
    begin
      vAllNULL:= True;
      for j:= 0 to mColNums-1 do
      begin
        if mRows[i].Value[j] <> '' then
        begin
          vAllNULL:= False;
          break;
        end;
      end;

      if vAllNull then
        DeleteRowSet(i);
    end;
  except
    on E : Exception do
      ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;
end;

procedure TRecordSet.DiscardNull(aColName: String);
var
  i: Integer;
begin
  try
    for i:=0 to mRowNums-1 do
    begin
      if Row[i, aColName] = '' then
        DeleteRowSet(i);
    end;
  except
    on E : Exception do
      ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;
end;

function TRecordSet.ColumnExist(aColName: String): Boolean;
begin
  result:= false;
  if GetColumnID(aColName) <> -1 then
    result:= true;
end;

end.
