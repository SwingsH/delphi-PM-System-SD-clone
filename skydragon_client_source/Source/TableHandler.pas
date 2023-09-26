{$I define.h}
unit TableHandler;
(**************************************************************************
 * 系統中的 表格(Excel)/欄位/欄位內容 處理器, Control Layer
 *************************************************************************)
interface

uses
  (** Delphi *)
  Dialogs, SqlExpr, SysUtils, Classes, DBManager, SQLConnecter,Forms,Windows;

type
  (********************************************************
   * 更改資料結果: 成功, 欄位不存在, 輸入錯誤, 不明錯誤
   ********************************************************)
  TModifyResult = (Success, NotExist, InputError, ModifyError);
  TLogType      = (ltNew, ltMod, ltDel);

  /// TODO: 轉換操作 一般表格 TTableHandler 和總表 TMergeTableHandler 用
  ITableHandle = interface
  ['{0F4B6790-F2D7-4925-AB07-480DD21C426B}']
    function NewRow(aMTableID, aMRowID: Integer): Integer;
    function  GetEnableLog: Boolean;
    procedure SetEnableLog(const Value:Boolean );
    property EnableLog: Boolean read GetEnableLog write SetEnableLog;
  end;

  (********************************************************
   * 系統中的 表格(Excel)/欄位/欄位內容 處理器
   * 取名為 Handler 非 Manager 是因為其為 MVC 中的 Control,
   * 負責處理流程, 而不留存 Data
   *
   * 1. 記錄 表格(Excel)/欄位/欄位內容 操作歷史紀錄 scs_table_log
   * 2. 尋找 合併表格 scs_mergetable / 表格 scs_table 的對應
   * @Author  Swings Huang
   * @Version 2010/01/28
   ********************************************************)
  TTableHandler = class(TInterfacedObject,ITableHandle)
  private
    mEnableLog: Boolean;
    function GetEnableLog: Boolean;
    procedure SetEnableLog(const Value: Boolean);
    function SaveLog(aTableID, aUserID:Integer; vMessage:String; aValid:Byte):Boolean;  /// (TODO:作廢..但是 目前本來就只用 MergeTableHandler)
  protected
  public
    constructor Create;
    function NewTable(aTableName, aTableDesc: String;                           /// (TODO:)建立新表格: 回傳 -1 in false or ID in Success
                      aUserID, aOrganizeID, aProjectID: Integer): Integer; virtual;
    function NewColumn: Integer; virtual;                                       /// (TODO:)新增欄位
    function NewColumnvalue: Integer; virtual;                                  /// (TODO:)新增欄位內容
    function NewRow(aTableID, aRowID: Integer): Integer; overload; virtual;     /// 新增一列 = 新增多個 RowID 一樣的 Columnvalue, 全都填預設值   (TODO:後續有時間盡量內部實作函式化)
    function NewRow(aTableID, aRowID:Integer;                                   /// 新增一列 = 新增多個 RowID 一樣的 Columnvalue, 集體填值!!     (TODO:後續有時間盡量內部實作函式化)
                    aValueList:TStringList):Integer;overload;
    function DeleteRow(aTableID, aRowID: Integer): Integer;                     /// 刪除一列 = 新增多個 RowID 一樣的 Columnvalue
    function ModifyTable: Integer; virtual;                                     /// (TODO:)
    function ModifyColumn: Integer;  virtual;                                   /// (TODO:)
    function ModifyColumnvalue(aTableID, aColumnID, aColumnRowID: Integer;      /// 更改欄位內容: 回傳 TModifyResult (TODO:後續有時間盡量內部實作函式化)
                               aValue: String; aCheck:Boolean= False): TModifyResult; virtual;
    function SelectListToString( aSelectList: TStringList ):String;             /// scs_column.type_set, 下拉式選單 StringList 轉換成 String
    function StringToSelectList( aSelectString: String):TStringList;            /// scs_column.type_set, 下拉式選單 String 轉換成 StringList
    property EnableLog: Boolean read GetEnableLog write SetEnableLog;
  end;
  
  (********************************************************
   * 總表 (合併表格/MergeTable) 的處理器
   * 負責同步總表(MergeTable)資料到對應的子表格(Table)
   * 重點開發
   * @Author  Swings Huang
   * @Version 2010/02/02
   * @Todo    1. 對應表完整檢查, 檢查總表下的子表格, 是不是都能在總表找的到對應,
   *             沒有缺漏的欄位。
   *          2. 同步檢查, 檢查總表下的子表格的所有 [欄位內容] & [列數] 是否一致。
   *          3. 新增前也要同步檢查。
   ********************************************************)
  TMergeTableHandler = class(TInterfacedObject,ITableHandle)
  private
    mEnableLog: Boolean;  /// 是否要開啟儲存 Log 的功能。 scs_table_log
    mTableIDs: array of Integer;
    function  GetEnableLog: Boolean;
    procedure SetEnableLog(const Value: Boolean);
    procedure ValueSOfChildTable(aMTableID:Integer;aValList:TStringList;        /// 把總表資料 轉成成多個子表格資料
                                 out aArrValList: array of TStringList);
    procedure SaveTableIDs(aRSet: TRecordSet);                                  /// TODO: 使用 RSet 儲存一個總表下有幾個子表
  public
    constructor Create;
    function CheckMergeTableExist(aMTableID: Integer):Boolean ;
    function NewRow(aMTableID, aMRowID: Integer): Integer;overload;             /// 新增一列 = 新增多個 RowID 一樣的 Columnvalue, 全都填預設值 (TODO:後續有時間盡量內部實作函式化)
    function NewRow(aMTableID, aMRowID:Integer;                                 /// 新增一列 = 新增多個 RowID 一樣的 Columnvalue, 集體填值!!  (TODO:後續有時間盡量內部實作函式化)
                    aValueList:TStringList):Integer;overload;
    function DeleteRow(aMTableID, aMRowID: Integer): Integer;                   /// 刪除一列 = 新增多個 RowID 一樣的 Columnvalue
    function ModifyColumnvalue(aLogID,aMTableID, aMColumnID, aMColumnRowID: Integer;   /// 更改欄位內容: 回傳 TModifyResult, 需要傳入 LogID, 否則無法儲存一個動作修改多個欄位的 LOG (TODO:後續有時間盡量內部實作函式化)
                               aMValue: String; aCheck:Boolean= false; aRefreshAllTable:Boolean= false): TModifyResult;
    function SaveLogList(aTitleID: Integer; aMessage: String; aMColumnID,       /// 建立一個 Log 列表, @param aError 日誌的錯誤類別,存取成功或失敗
                         aMRowID:Integer; aError:Boolean=False):Boolean;
    function CreateLog(aMTableID: Integer; aLogType: TLogType):Integer;         /// 建立 Log 標題, 回傳 Log ID, 新增一個日誌標題  成功則回傳新增的標題 ID
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
   * Database 設定常數
   ********************************************************)
  cColumnType: array[1..7] of String =('number', 'textfield', 'textarea', 'date', 'checkbox', 'radiobox', 'selectbox');
  cColumnType_Text= 'textarea';
  cColumnType_SBox_Sep       = ',';           /// Separator of Select Box EX: ("A","B")
  cColumnType_SBox_delimiter = '"';           /// delimiter of Select Box Ex: "A"

  // HTML String 格式
  cFRed  = '<font color=#E14400><b>' ;   // 橘紅?
  cFGreen = '<font color=#008800><b>' ;  // 深綠?
  cFE    = '</b></font>' ;
  cBold  = '<b>';
  cBoldE = '</b>';
  cTableString_001 = cFRed+'[%s]'+cFE+'試圖修改專案'+cFGreen+'[%s]'+cFE+
                     '的表格'+cFGreen+'[%s]'+cFE+', 可是失敗了! ';
  cTableString_002 = cFRed+'[%s]'+'修改專案'+cFGreen+'[%s]'+cFE+'的表格'+cFGreen+'[%s]'+cFE+
                     ',將欄位'+cFGreen+'[%s]'+cFE+'的內容由'+cBold+'[%s]'+cBoldE+'修改為'+cBold+'[%s]'+cBoldE+'。';
  cTableString_003 = '不明錯誤,請聯絡開發人員';
  cTableString_004 = cFRed+'[%s]'+cFE+'試圖新增一筆資料於專案'+cFGreen+'[%s]'+cFE+'的表格'+cFGreen+'[%s]'+cFE+', 可是失敗了! ';
  cTableString_005 = cFRed+'[%s]'+cFE+'新增一筆資料於專案'+cFGreen+'[%s]'+cFE+'的表格'+cFGreen+'[%s]'+cFE+'。';
  cTableString_006 = cFRed+'[%s]'+cFE+'試圖新增一筆資料於專案'+cFGreen+'[%s]'+cFE+'的總表'+cFGreen+'[%s]'+cFE+', 可是失敗了! ';
  cTableString_007 = cFRed+'[%s]'+cFE+'新增一筆資料於專案'+cFGreen+'[%s]'+cFE+'的總表'+cFGreen+'[%s]'+cFE+'。';
  cTableString_008 = '無名氏';
  cTableString_009 = '不明？';     // 不明專案, 不明表格
  cTableString_010 = '表格(%s)的(%s).';
  cTableString_011 = cFRed+'[%s]'+cFE+'試圖修改專案'+cFGreen+'[%s]'+cFE+
                     '的總合表格'+cFGreen+'[%s]'+cFE+'的欄位'+cFGreen+'[%s]'+cFE+', 可是失敗了! ';
  cTableString_012 = cFRed+'[%s]'+cFE+'修改專案'+cFGreen+'[%s]'+cFE+
                     '的總合表格'+cFGreen+'[%s]'+cFE+',將欄位'+cFGreen+'[%s]'+cFE+
                     '的內容由'+cBold+'[%s]'+cBoldE+'修改為'+cBold+'[%s]'+cBoldE+'。';
  cTableString_013 = cFRed+'[%s]'+cFE+'新增專案'+cFGreen+'[%s]'+cFE+'的總合表格'+cFGreen+'[%s]'+cFE+
                     ',的欄位'+cFGreen+'[%s]'+cFE+'的內容'+cBold+'[%s]'+cBoldE+'。';
  cTableString_014 = cFRed+'[%s]'+cFE+'刪除專案'+cFGreen+'[%s]'+cFE+'的總合表格'+cFGreen+'[%s]'+cFE+
                     ',的第'+cBold+'[%d]'+cBoldE+'列。';
  // Format String 格式
  cTableString_021 = '[%s]於專案[%s]的表格[%s]新增了資料。';
  cTableString_022 = '[%s]於專案[%s]的表格[%s]修改了資料。';
  cTableString_023 = '[%s]於專案[%s]的表格[%s]刪除了資料。';

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
  vPreColValue, vNowColValue, vNickName : String;    (**原本的欄位內容,更改後的欄位內容*)
begin
  Result:= ModifyError ;
  vRecordSet := nil ;
  vMessage   := '';
  
  vRecordSet:= gDBmanager.GetColumn(aTableID, aColumnID);
  if vRecordSet.RowNums = 0 then
  begin
    Result := NotExist;   // 欄位不存在
    Exit;
  end;
  vColName:= vRecordSet.Row[0, 'column_name'];
  vColType:= vRecordSet.Row[0, 'column_type'];
  freeAndNil(vRecordSet); // 清空

  vRecordSet := gDBmanager.GetTable(aTableID);
  if vRecordSet.RowNums = 0 then
  begin
    Result := NotExist;   // 表格不存在
    Exit;
  end;
  vTableName:= vRecordSet.Row[0, 'table_name'];
  vProjName := vRecordSet.Row[0, 'project_name'];
  freeAndNil(vRecordSet); // 清空

  vRecordSet := gDBmanager.GetColumnvalue(aTableID,aColumnID,aColumnRowID);
  if vRecordSet.RowNums = 0 then
  begin
    Result := NotExist;   // 欄位內容不存在 (該列尚未建立)
    Exit;
  end;

  vPreColValue := vRecordSet.Row[0, 'value'];
  vNowColValue := aValue;
  freeAndNil(vRecordSet); // 清空

  // TODO: 檢查格式 Input check !!!!!!!!!!!!!!
  if aCheck then
  begin
    Result := Success;
    Exit;
  end;

  /// 更新資料 scs_columnvalue
  vResult:= gDBManager.SetColumnvalue(aTableID,aColumnID,aColumnRowID,aValue);

  if mEnableLog = True then
    Exit;
    
  /// 建立更動紀錄訊息 scs_table_log
  if StateManage.NickName = '' then
    vNickName := cTableString_008
  else
    vNickName := StateManage.NickName;
    
  if vResult <= 0 then
    // '[%s]試圖修改專案[%s]的表格[%s], 可是失敗了! '
    vMessage := Format(cTableString_001,[vNickName, vProjName, vTableName])
  else
    // '[%s]修改專案[%s]的表格[%s],將欄位[%s]的內容由[%s]修改為[%s]。';
    vMessage := Format(cTableString_002,[vNickName, vProjName, vTableName, vColName, vPreColValue, vNowColValue]);

  SaveLog(aTableID, StateManage.ID, vMessage, cValid );    // 新增更動紀錄 scs_table_log
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
  
  // 取得欄位數
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

  // 檢查表格是否存在
  vRecordSet := gDBManager.GetTable(aTableID);
  if vRecordSet.RowNums = 0 then
    vErrorFlag := True;          // ShowMessage( 'Table Not Exist !!' );
  vTableName:= vRecordSet.Row[0, 'table_name'];
  vProjName := vRecordSet.Row[0, 'project_name'];
  freeAndNil(vRecordSet); // 清空

  // 檢查該列是否已經存在, (不正常,新的一列怎麼會存在)
  vRecordSet := gDBManager.GetColumnValueS(aTableID, 0, aRowID, 'total');
  if vRecordSet.RowNums <> 0 then
    vErrorFlag := True;        // ShowMessage( 'Row Already Exist, Error !!' );
  freeAndNil(vRecordSet);      // 清空

  // 檢查欄位是否存在
  vRecordSet:= gDBManager.GetTable_ColumnS(aTableID);
  if vRecordSet.RowNums = 0 then
    vErrorFlag := True;        // ShowMessage( 'Table Has No Columns !!' );

  // 檢查輸入資料的筆數是否正確, 一個值(value) 對應一欄(column)
  if aValueList.Count <> vRecordSet.RowNums then
    vErrorFlag := True;
    
  if vErrorFlag = True then
  begin
    // '[%s]試圖新增一筆資料於專案[%s]的表格[%s], 可是失敗了!'
    vMessage := Format(cTableString_004,[StateManage.NickName, vProjName, vTableName]);
    SaveLog( aTableID, StateManage.ID, vMessage, cInvalid );
    Exit;
  end;
  
  /// 開始輸入資料
  vQuery:= '';
  for i:= 0 to vRecordSet.RowNums - 1 do
  begin
    vColID:= StrToIntDef( vRecordSet.Row[i, 'column_id'], -1 );
    gDBManager.AddColumnvalue( aTableID, vColID, aRowID, aValueList[i] );
  end;

  /// 儲存 Table Log
  vMessage := Format(cTableString_005,[StateManage.NickName, vProjName, vTableName]);  // '[%s]新增一筆資料於專案[%s]的表格[%s]。';
  SaveLog( aTableID, StateManage.ID, vMessage, cValid );    // 新增更動紀錄 scs_table_log
  
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
      Result:= Result + cColumnType_SBox_Sep ;  // 非結尾則 +  ','
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
    
    if (Copy( Result.Strings[i], 0, 1 ) = cColumnType_SBox_delimiter ) AND                           // 第一個字元為 "
       (Copy( Result.Strings[i], Length(Result.Strings[i]) , 1 ) = cColumnType_SBox_delimiter) then  // 最後一個字元為 "
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
  vCurTableID:= StrToInt(vRSet.Row[0,'table_id']);    // 目前儲存的List 的子表格 ID
  aArrValList[vIdx]:= TStringList.Create;
  for i:= 0 to vRSet.RowNums -1 do
  begin
    if vCurTableID <> StrToInt(vRSet.Row[i,'table_id']) then   // 檢查是否儲存下一個 子表格 的 LIST
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

  // 取得 總表欄位(mergecolumn) 和 相對應的子欄位(column), ... mapping data
  vRSet := gDBmanager.GetMergeTable_ColumnS(aMTableID, aMColumnID,'detail');
  if vRSet.RowNums = 0 then
  begin
    Result := NotExist;   // 總表欄位不存在
    Exit;
  end;

  // TODO: 檢查格式 Input check !!!!!!!!!!!!!!
  if aCheck then
  begin
    Result := Success;
    Exit;
  end;

  vNickName := StateManage.NickName ;
  if vNickName = '' then
    vNickName := cTableString_008;

  // 取得總表欄位資訊
  vColName := '';
  for i:= 0 to vRSet.RowNums-1 do
    vColName:=vColName+Format(cTableString_010, [vRSet.Row[i,'table_name'],vRSet.Row[i,'column_name']]); // '表格(%s)的(%s)';

  vTableID    := StrToIntDef(vRSet.Row[0,'table_id'] , -1);  // 以 ID 最前面的 欄位值為主
  vColumnID   := StrToIntDef(vRSet.Row[0,'column_id'], -1);
  vRSet2      := gDBmanager.GetColumnvalue( vTableID, vColumnID, aMColumnRowID);
  vPreColValue:= vRSet2.Row[0,'value'];

  // 更新[總表欄位內容] == 因為同步, 所以會更新多個[表]的[欄位內容] multi- scs_columnvalue
  for i:= 0 to vRSet.RowNums-1 do
  begin
    vTableID := StrToIntDef(vRSet.Row[i, 'table_id'] , -1);
    vColumnID:= StrToIntDef(vRSet.Row[i, 'column_id'], -1);
    vError   := gDBmanager.SetColumnvalue(vTableID, vColumnID, aMColumnRowID,
                                          aMValue);                             // MergeRowID = RowID
    if vError <= 0 then   // 新增失敗 (TODO: 刪除之前輸入的 or 使用 TRANSACTION )
      Break;
  end;
  vTableID   := StrToIntDef(vRSet.Row[0,'table_id'], -1);
  FreeAndNil(vRSet);
  
  vRSet := gDBManager.GetMergeTable_TableS(aMTableID);  // 取出總合表格底下的表格
  SaveTableIDs(vRSet);

  (** 修改的情況 --> 因為 ColumnValue 還存在, 可以只更新 ColumnValue 的時間, 不更新 TableTime **)
  if aRefreshAllTable then
  begin
    for i:= 0 to Length(mTableIDs)-1 do
      gDBManager.SetTable_UpdateTime(mTableIDs[i]);  /// 更新 Table 最後修改時間
    gDBManager.SetMergeTable_UpdateTime(aMTableID);   /// 更新 MergeTable 最後修改時間
  end;
  
  FreeAndNil(vRSet);
  ///============= 以下只是為了 Log 取得資訊 =============
  // 取得總表 專案, 組織資訊
  vRSet      := gDBmanager.GetTable( vTableID );
  vProjName  := vRSet.Row[0, 'project_name'];
  vOrgName   := vRSet.Row[0, 'organize_name'];
  FreeAndNil(vRSet);
  vRSet      := gDBmanager.GetMergeTable( aMTableID );
  vMTableName:= vRSet.Row[0, 'mergetable_name'];
  FreeAndNil(vRSet);

  if vError <= 0 then
  begin
    // '「%s」試圖修改專案[%s]的總合表格[%s]的欄位[%s], 可是失敗了! '
    vMessage := Format(cTableString_011,[vNickName, vProjName, vMTableName, vColName]);
    SavelogList(aLogID, vMessage, aMColumnID, aMColumnRowID,True);// 於function 外部 SavelogTitle
  end
  else
  begin
    // '「%s」修改專案[%s]的總合表格[%s],將欄位[%s]的內容由[%s]修改為[%s]。';
    vMessage := Format(cTableString_012,[vNickName,vProjName,vMTableName,vColName,vPreColValue,aMValue]);
    SavelogList(aLogID, vMessage, aMColumnID, aMColumnRowID);      // 於function 外部 SavelogTitle
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
  // 檢查總表格的欄位是否存在
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
  vProjName  := cTableString_009;   // '不明？'
  vTableName := cTableString_009;   // '不明？'

  // 檢查 總表格 是否存在
  vRSet := gDBManager.GetMergeTable(aMTableID);
  if vRSet.RowNums = 0 then
    vErrorFlag := True ;

  // 檢查所有子表格(Table)在該列是否已經存在, (不正常,新的一列怎麼存在)
  if vErrorFlag = False then
  begin
    vProjName := vRSet.Row[0, 'project_name'];
    vTableName:= vRSet.Row[0, 'mergetable_name'];
    FreeAndNil(vRSet);
    // 取得所有子表格(Table)
    vRSet:= gDBManager.GetMergeTable_TableS(aMTableID);

    for i:= 0 to vRSet.RowNums -1 do     // 檢查子表格下的欄位內容
    begin
      vTableID := StrToIntDef(vRSet.Row[i, 'table_id'], 0) ;
      vRSet2   := gDBManager.GetColumnValueS(vTableID, 0, aMRowID, 'total');    // MergeRowID = RowID, 正常情況總表格和子表格列數是一致的
      if vRSet2.RowNums <> 0 then
      begin
        ShowMessage( 'MergeTable''s Row Already Exist, Error !!' );
        vErrorFlag := True;
        Break;
      end;
      freeAndNil(vRSet2); // 清空
    end;
  end;
  freeAndNil(vRSet2); // 清空

  // 檢查總表格的欄位是否存在
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
  vNickName := '盈毅測試用';
{$endif}

  // 檢查輸入資料的筆數是否正確, 一個值(value) 對應一欄(column)
  vMColNums := StrToIntDef(vRSet2.Row[vRSet2.RowNums-1, 'mergecolumn_id'], -1); // 算出總表共有幾欄
  if vErrorFlag = False then
  if aValueList.Count <> vMColNums then
    vErrorFlag := True;

  if vErrorFlag = True then
  begin
{$ifdef Debug}
    ShowMessage( 'TMergeTableHandler.NewRow Error !!' );
{$endif}
    vMessage := Format(cTableString_006,[vNickName, vProjName, vTableName]); // '「%s」試圖新增一筆資料於專案[%s]的總表[%s], 可是失敗了! ';
    vLogID := CreateLog( StateManage.ID, ltNew);           // 存 Log 標題
    SaveLogList(vLogID, vMessage, 0, aMRowID, True);       // 存 Log 列表
    Exit;
  end;

  // 將一份總表 Value 分解成 N 個子表格 Value
  SetLength(vArrValueList, vRSet.RowNums);
  ValueSOfChildTable(aMTableID, aValueList, vArrValueList);

  // 開始新增[子表格](Table)的資料
  gTableHandler.EnableLog:= False;
  for i:= 0 to vRSet.RowNums - 1 do
  begin
    vTableID := StrToIntDef(vRSet.Row[i, 'table_id'], 0) ;
    gTableHandler.NewRow(vTableID, aMRowID, vArrValueList[i]);
    gDBManager.SetTable_UpdateTime(vTableID);     /// 更新 Table 最後修改時間
  end;
  gTableHandler.EnableLog:= True;
  gDBManager.SetMergeTable_UpdateTime(aMTableID);  /// 更新 MergeTable 最後修改時間

  // 儲存 Table Log
  vLogID := CreateLog( aMTableID, ltNew);           // 存 Log 標題
  for i:= 0 to aValueList.Count-1 do                     // 存 Log 列表
  begin
    vColName := vRSet2.Row[i, 'column_name'];   // 欄位數量與 value 數量已比對過
    vMessage := Format(cTableString_013,[vNickName, vProjName, vTableName, vColName, aValueList[i]]); // [%s]新增專案[%s]的總合表格[%s],的欄位[%s]的內容[%s]
    SaveLogList(vLogID, vMessage, i+1, aMRowID);    // 正常情況 mcolumn 由 1開始且連號
  end;

  freeAndNil(vRSet); // 清空
  freeAndNil(vRSet2); // 清空
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

  // 檢查 總表格 是否存在
  vRSet := gDBManager.GetMergeTable(aMTableID);
  if vRSet.RowNums = 0 then
    Exit ;
  vProjName  := vRSet.Row[0, 'project_name'];
  vMTableName:= vRSet.Row[0, 'mergetable_name'];
  freeAndNil(vRSet);

  if Application.MessageBox('確定刪除此列？', '', MB_YESNO)=IDNO then   // TODO: 移往別處判斷
    exit;
      
  vRSet := gDBManager.GetMergeTable_TableS(aMTableID); // 取得總表格(MTable)下的所有子表格(Table)
  gTableHandler.EnableLog:= False;
  for i:= 0 to vRSet.RowNums -1 do     // 檢查子表格下的欄位內容
  begin
    vTableID:= StrToIntDef( vRSet.Row[i,'table_id'], 0);
    gTableHandler.DeleteRow(vTableID, aMRowID);
    gDBManager.SetTable_UpdateTime(vTableID);  /// 更新 Table 最後修改時間
  end;
  gTableHandler.EnableLog:= True;

  gDBManager.SetMergeTable_UpdateTime(aMTableID);  /// 更新 MergeTable 最後修改時間

  vNickName := StateManage.NickName ;
  vLogID  := CreateLog(aMTableID, ltDel);         // 存 Log 標題
  vMessage:= Format(cTableString_014,[vNickName,vProjName,vMTableName, aMRowID]); //[%s]刪除專案[%s]的總合表格[%s],的第[%s]列。';
  SaveLogList(vLogID, vMessage, 0, aMRowID);       // 存 Log 列表
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
    // '「%s」於專案[%s]的表格[%s]新增了資料。';
    vMessage := Format(cTableString_021,[ StateManage.NickName, vProjName, vTableName]);
  ltMod:
    // '「%s」於專案[%s]的表格[%s]修改了資料。'
    vMessage := Format(cTableString_022,[ StateManage.NickName, vProjName, vTableName]);
  ltDel:
    // '「%s」於專案[%s]的表格[%s]刪除了資料。'
    vMessage := Format(cTableString_023,[ StateManage.NickName, vProjName, vTableName]);
  end;

  vEffRow:= gDBManager.AddTablelogTitle(StateManage.ID, aMTableID, vMessage);
  if vEffRow > 0 then     // 成功, 回傳新增的 ID
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
