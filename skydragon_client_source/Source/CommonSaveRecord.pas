unit CommonSaveRecord;
(********************************************************
 * 系統共用的 Record 型態
 * @Author Swings Huang (2010/02/25 新增)
 * @Todo
 ********************************************************)
interface

uses
  SQLConnecter;

type
  (********************************************************
   * 用來存放 ComboBox 的資訊
   ********************************************************)
  rComboSave = record
    ID  : Integer;      /// reference ID, 對應 database 的 id
    Name: String;       /// combo 顯示文字
  end;

  (********************************************************
   * 對應 SQL DB 的儲存紀錄 - 專案
   ********************************************************)
  rProject = record
    ID  : Integer;
    Name: String;
    LeaderUserID: Integer;
    Description: String;
  end;

  (********************************************************
   * 對應 SQL DB 的儲存紀錄 - 總合表格
   ********************************************************)
  rMergeTable = record
    ID  : Integer;
    TemplateID: Integer;       // 總表版型 ID 1.四合一總表
    Name: String;
    Description: String;       // 合併表格說明
    CreateUserID: Integer;     // 建立合併表格的使用者ID
    CreateOrganizeID: Integer; // 合併表格所屬的組織(防止人事調動,所屬以組織為主)
    CreateProjectID:Integer;   // 合併表格所對應的專案
    CreateTime: String;        // 合併表格建立時間
    Expire_time:String;        // 合併表格過期時間
  end;

  (********************************************************
   * 對應 SQL DB 的儲存紀錄 - 子表格
   ********************************************************)
  rTable = record
    ID               : Integer;
    TemplateID       : Integer;       // 表格版型 ID 1.企劃進度表
    Name             : String;
    Description      : String;        // 表格說明
    CreateUserID     : Integer;       // 建立表格的使用者ID
    CreateOrganizeID : Integer;       // 表格所屬的組織(防止人事調動,所屬以組織為主)
    CreateProjectID  : Integer;       // 表格所對應的專案
    CreateTime       : String;        // 表格建立時間
    Expire_time      : String;        // 表格過期時間
  end;

  (********************************************************
   * 對應 SQL DB 的儲存紀錄 - 總合表格欄位
   ********************************************************)
   rMergeColumn = record
     MrgTableID  : Integer; // 總表的母表格 ID PK
     MrgColumnID : Integer; // 總表的母欄位 ID PK
     TableID     : Integer; // 來源的子表格 ID PK
     ColumnID    : Integer; // 來源的子欄位 ID
     CreateUserID: Integer; // 合併表格建立者ID
     CreateTime  : String;  // 合併表格建立時間
     PositionID  : Integer; // 可存取的職務身份 ID - mergecolumn_id 同, 職務 ID 亦同..違反 2NF..
     Priority    : Integer; // 存取最低權限-需查詢使用者在專案的權利等級
     ColumnType  : String;
     TypeSet     : String;
     Name        : String;  // extra
   end;

  (********************************************************
   * 對應 SQL DB 的儲存紀錄 - 表格欄位 extra = column + mergecolumn 通用型態
   ********************************************************)
   rColumnEx = record
     TableID     : Integer; // 總表的母表格 ID PK
     ColumnID    : Integer; // 總表的母欄位 ID PK
     ColumnName  : String;  // 來源的子表格 ID PK
     ColumnDesc  : String;  // 來源的子欄位 ID
     CreateUserID: Integer; // 合併表格建立者ID
     CreateTime  : String;  // 合併表格建立時間
     Priority    : Integer; // 存取最低權限-需查詢使用者在專案的權利等級
     ColumnType  : String;
     TypeSet     : String;
     Width       : Integer;
     Height      : Integer;
     (** Extra *)
     MTableID    : Integer;
     MColumnID   : Integer;
     PositionID  : Integer; // mergecolumn_position_id
   end;
   
  (********************************************************
   * [參照] SQL DB 的儲存紀錄 - 表格的欄位值 & 合併表格的欄位值
   *        2010.03.12 DB 上實際沒有 MergeColumnValue 這個 TB Schema
   ********************************************************)
   rMergeColumnValue = record
     TableID     : Integer; // 總表 ID PK
     ColumnID    : Integer; // 總表欄位 ID
     RowID       : Integer; // 總表列數 ID
     Value       : String;
     DateTime    : String;
   end;

  (********************************************************
   * 對應 SQL DB 的儲存紀錄 - 總表間, 單向自動回填規則
   ********************************************************)
   rMergeColumnAutofill = record
     ID                  : Integer;
     MergeColumnIDSet    : String;
     TriggerString       : String;
     TriggerMergeTableID : Integer;
     TriggerMergeColumnID: Integer;
     TriggerColumnType   : String;
     DestMergeTableID    : Integer;
     DestMergeColumnID   : Integer;
   end;

implementation

end.
