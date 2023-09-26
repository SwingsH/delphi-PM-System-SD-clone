unit TableControlPanel;
(**************************************************************************
 * 動態更動 專案/總合表格/子表格 UI ListBox 列表的 控制器
 * 需要得知 [表格相關列表] 操作狀態與資料, 請由此 pas 存取
 * Ex: 作用中的 Table ID, MergeTable ID, 
 *************************************************************************)
interface

uses
  (** Delphi *)
  StdCtrls,
  (** SkyDragon *)
  CommonSaveRecord, SQLConnecter;
  
type
  (**************************************************************************
   * 一串 Table 清單的紀錄
   *************************************************************************)
  rListTable = record
    mMrgTableID: Integer;       /// 對應的總和表格
    mTableS: array of rTable;   /// 總和表格下的一串 Table 清單
  end;
  
  (**************************************************************************
   * 一串 MergeTable 清單的紀錄
   *************************************************************************)
  rListMrgTable = record
    mProjectID: Integer;                  /// 對應的專案
    mMrgTableS: array of rMergeTable;     /// 專案下的一串 MergeTable 清單
  end;

  (**************************************************************************
   * 一串 Project 清單的紀錄
   *************************************************************************)
  rListProject = record
    mUserID: Integer;                  /// 對應的使用者
    mProjectS: array of rProject;      /// 使用者下的一串 Project 清單
  end;

  (**************************************************************************
   * 動態更動 專案/總合表格/子表格 ListBox 列表的 控制器
   * @Author Swings Huang (2010/02/25 新增)
   * @todo 結構不夠好,可改良
   *************************************************************************)
  TTableControlPanel= class(TObject)
  private
    (** 作用中的資訊 *)
    mProjectID         : Integer;      /// 操作面版作用中(Focus)到的 ProjectID
    mMTableID          : Integer;      /// 操作面版作用中(Focus)到的 MergeTableID
    mTableID           : Integer;      /// 操作面版作用中(Focus)到的 TableID
    mCurrentProjIdx    : Integer;      /// 操作面版作用中(Focus)到的 專案 listbox index
    mCurrentMrgTableIdx: Integer;      /// 操作面版作用中(Focus)到的 總表 listbox index
    mCurrentTableIdx   : Integer;      /// 操作面版作用中(Focus)到的 子表 listbox index
    mListProject       : rListProject; /// 作用中(Focus)專案清單的紀錄
    mListMrgTable      : rListMrgTable;/// 作用中(Focus)總表清單的紀錄
    mListTable         : rListTable;   /// 作用中(Focus)子表清單的紀錄
    (** Dfm 實體參照 *)                               
    mProjListBox       : TListBox;     /// reference to Dfm Instance
    mMrgTableListBox   : TListBox;     /// reference to Dfm Instance
    mTableListBox      : TListBox;     /// reference to Dfm Instance
    (**清單 Cache functions, 儲存向 DB 索取過的清單*)
    mArrListProject : array of rListProject;                        /// for cache , 全部快取的資料  TODO: private
    mArrListMrgTable: array of rListMrgTable;                       /// for cache , 全部快取的資料  TODO: private
    mArrListTable   : array of rListTable;                          /// for cache , 全部快取的資料  TODO: private
    function  CacheUserIdx(aUserID: Integer): Integer;                  /// 判斷 User 下的 Project 清單是否有 cache, 0 為不存在
    procedure SaveCacheProjectList(aUserID:Integer; aRSet:TRecordSet ); /// 儲存 cache
    function  CacheProjectIdx( aProjID: Integer ):Integer;              /// 判斷 Project 下的 MegTable 清單是否有 cache, 0 為不存在
    procedure SaveCacheMTableList(aProjID:Integer; aRSet:TRecordSet );  /// 儲存 cache
    function  CacheMrgTableIdx( aMTableID: Integer ):Integer;           /// 判斷 MegTable 下的 Table 清單是否有 cache, 0 為不存在
    procedure SaveCacheTableList(aMTableID:Integer; aRSet:TRecordSet ); /// 儲存 cache
    function GetCurrentMergeTable: rMergeTable;                         /// 取得目前作用中的 MergeTable Record
    function GetCurrentProject: rProject;                               /// 取得目前作用中的 Project Record
    function GetCurrentTable: rTable;
    function GetMergeTableData(aMTableID:Integer): rMergeTable;
  protected
  public
    constructor Create( aProjListBox, aMrgTableListBox, aTableListBox:TListBox );
    procedure Init;
    procedure ListBoxClear;
    (** 設置清單列表 *)
    procedure SetProjectList( aUserID: Integer);                                /// 依照使用者 ID 設定專案列表
    procedure SetMrgTableList( aProjectID : Integer );                          /// 依照專案 ID 設定總合表格列表
    procedure SetTableList( aMrgTableID: Integer );                             /// 依照總合表格 ID 設定子表格列表
    procedure SetPrivatProList;                                                 /// 顯示使用者未完成項目
    (** Event *)
    procedure OnProjectClick(Sender:TObject);
    procedure OnMrgTableClick(Sender:TObject);
    procedure OnTableClick(Sender:TObject);
    (** 資料存取區 *)
    property ListProject : rListProject read mListProject write mListProject;   /// 列表資料
    property ListMrgTable: rListMrgTable read mListMrgTable write mListMrgTable;/// 列表資料
    property ListTable   : rListTable read mListTable write mListTable;         /// 列表資料
    property Project     : rProject read GetCurrentProject;                     /// 作用中的 DB 資料
    property MergeTable  : rMergeTable read GetCurrentMergeTable;               /// 作用中的 DB 資料
    property Table       : rTable read GetCurrentTable;                         /// 作用中的 DB 資料
    property ProjectID   : Integer read mProjectID;
    property TableID     : Integer read mTableID;
    property MrgTableID  : Integer read mMTableID;
    property MergeTableData[aMTableID:Integer]: rMergeTable read GetMergeTableData;
  end;

var
  gTableControlPanel: TTableControlPanel;

implementation

uses
  (** Delphi *)
  SysUtilS, Dialogs,
  (** SkyDragon *)
  GridCtrl, DBManager, Main, StateCtrl;

{ TTableControlPanel }

function TTableControlPanel.CacheProjectIdx(aProjID: Integer): Integer;
var
  i: Integer;
  vLength: Integer;
begin
  result:= -1;
  vLength:= Length( mArrListMrgTable );
  if vLength = 0 then
    Exit;
  for i:=0 to vLength-1 do
  begin
    if aProjID = mArrListMrgTable[i].mProjectID then   // 找到 ID, 有 cache 存在
    begin
      result:= i;
      exit;
    end;
  end;
end;

constructor TTableControlPanel.Create(aProjListBox,aMrgTableListBox,aTableListBox: TListBox);
begin
  mProjListBox    := aProjListBox;
  mMrgTableListBox:= aMrgTableListBox;
  mTableListBox   := aTableListBox;
  mCurrentProjIdx    := 0;
  mCurrentMrgTableIdx:= 0;
  mCurrentTableIdx   := 0;
  mProjectID         := 0;
  mMTableID          := 0;
  mTableID           := 0;
  Init;
end;

procedure TTableControlPanel.Init;
begin
  mProjListBox.OnClick:= OnProjectClick;
  mMrgTableListBox.OnClick:= OnMrgTableClick;
  mTableListBox.OnClick:= OnTableClick;
end;

procedure TTableControlPanel.OnProjectClick(Sender: TObject);
begin
  /// 列表相關功能
  if mProjListBox.ItemIndex = -1 then
    Exit;

  mProjectID := mListProject.mProjectS[mProjListBox.ItemIndex].ID ;
  if mProjectID <= 0 then
    Exit;

  SetMrgTableList(mProjectID);

  MainForm.AddNewBtn.Enabled := false;

  /// 表格顯示相關功能
  GridManage.TableManager.CurrentTableID := 0;
  GridManage.GridComboManage.Clear;
  GridManage.ClearGrid;
end;

procedure TTableControlPanel.OnTableClick(Sender: TObject);
begin
  /// 列表相關功能
  if mMrgTableListBox.ItemIndex = -1 then
    Exit;
  if mTableListBox.ItemIndex = -1 then
    Exit;

  mTableID := mListTable.mTableS[mTableListBox.ItemIndex].ID ;

  if mTableID <= 0 then
    Exit;

  if MainForm.BlockColMenu.Enabled = false then
    MainForm.BlockColMenu.Enabled := true;

  MainForm.AddNewBtn.Enabled := true;

  /// 表格顯示相關功能
  GridManage.SetTableTitle(mTableListBox.Items[mTableListBox.ItemIndex]);
  GridManage.TableManager.CurrentTableID := mTableID;
  GridManage.SetTable(mTableID);
  GridManage.GridLocking(GridManage.LockCols);
  GridManage.GridComboManage.Clear;
  GridManage.TriggerGridCancelSearch; // 點擊or切換表格, 自動幫使用者取消搜索狀態
end;

procedure TTableControlPanel.OnMrgTableClick(Sender: TObject);
begin
  /// 列表相關功能
  if mProjListBox.ItemIndex = -1 then
    Exit;
  if mMrgTableListBox.ItemIndex = -1 then
    Exit;

  mMTableID := mListMrgTable.mMrgTableS[mMrgTableListBox.ItemIndex].ID ;
  if mMTableID <= 0 then
    Exit;

  SetTableList(mMTableID);

  if MainForm.BlockColMenu.Enabled = false then
    MainForm.BlockColMenu.Enabled := true;

  MainForm.AddNewBtn.Enabled := false;

  /// 表格顯示相關功能
  GridManage.SetTableTitle('');
  GridManage.TableManager.CurrentMrgTableID := mMTableID;
  GridManage.TableManager.CurrentTableID := 0;
  GridManage.ClearGrid;
  GridManage.GridComboManage.Clear;
  MainForm.BlockColMenu.Checked := false;
  GridManage.IsLock := false;
  GridManage.GridLocking(1);
end;

procedure TTableControlPanel.SetProjectList(aUserID: Integer);
var
  vRSet: TRecordSet;
  i, vIdx: Integer;
begin
  vIdx := CacheUserIdx( aUserID );

  if vIdx = -1 then   // cache 無資料
  begin
    vRSet := gDBManager.GetUser_Project( aUserID );  // 取出使用者底下的專案
    SaveCacheProjectList( aUserID, vRSet);
    mListProject := mArrListProject[ Length(mArrListProject)-1 ];   // Last Insert Item
  end
  else
    mListProject := mArrListProject[vIdx];

  // 清空 & 列出 List
  ListBoxClear;
  for i:= 0 to Length(mListProject.mProjectS)-1 do
  begin
    SetMrgTableList(mListProject.mProjectS[i].ID);   // todo 為了防止 cache 順序錯誤, 先刷新一次
    mProjListBox.Items.Add(mListProject.mProjectS[i].Name);
  end;

  // 調整預設選項為 沒有
  mProjListBox.ItemIndex:= -1;
  mProjectID:=0;

  // 把 MrgTable + Table 的選單清空, 預設為無
  mMrgTableListBox.Clear;
  mTableListBox.Clear;
end;

procedure TTableControlPanel.SaveCacheMTableList(aProjID: Integer; aRSet: TRecordSet);
var
  i, vIdx: Integer;
begin
  vIdx:= Length(mArrListMrgTable);
  SetLength(mArrListMrgTable, vIdx+1);

  for i:= 0 to aRSet.RowNums-1 do  //將專案加入grid的combo
  begin
    SetLength( mArrListMrgTable[vIdx].mMrgTableS, i+1 );
    mArrListMrgTable[vIdx].mMrgTableS[i].ID := StrToIntDef(aRSet.Row[i, 'mergetable_id'], 0);
    mArrListMrgTable[vIdx].mMrgTableS[i].TemplateID:=StrToIntDef(aRSet.Row[i, 'mergetable_template_id'], 0);
    mArrListMrgTable[vIdx].mMrgTableS[i].Name := aRSet.Row[i, 'mergetable_name'];
    mArrListMrgTable[vIdx].mMrgTableS[i].Description  := aRSet.Row[i, 'mergetable_description'];
    mArrListMrgTable[vIdx].mMrgTableS[i].CreateUserID := StrToIntDef(aRSet.Row[i, 'mergetable_create_user_id'],0);
    mArrListMrgTable[vIdx].mMrgTableS[i].CreateOrganizeID:= StrToIntDef(aRSet.Row[i, 'mergetable_create_organize_id'],0);
    mArrListMrgTable[vIdx].mMrgTableS[i].CreateProjectID := StrToIntDef(aRSet.Row[i, 'mergetable_create_project_id'],0);
    mArrListMrgTable[vIdx].mMrgTableS[i].CreateTime   := aRSet.Row[i, 'mergetable_create_time'];
    mArrListMrgTable[vIdx].mMrgTableS[i].Expire_time  := aRSet.Row[i, 'mergetable_expire_time'];
  end;
  mArrListMrgTable[vIdx].mProjectID:= aProjID;
end;

procedure TTableControlPanel.SetMrgTableList(aProjectID: Integer);
var
  vRSet: TRecordSet;
  i, vIdx: Integer;
begin
  vIdx := CacheProjectIdx( aProjectID );

  if vIdx = -1 then   // cache 無資料
  begin
    vRSet := gDBManager.GetProject_MergeTableS( aProjectID );  // 取出專案底下的總合表格
    SaveCacheMTableList( aProjectID, vRSet);
    mListMrgTable:= mArrListMrgTable[ Length(mArrListMrgTable)-1 ];   // Last Insert Item
  end
  else
    mListMrgTable := mArrListMrgTable[vIdx];

  // 清空 & 列出 List
  mMrgTableListBox.Clear;
  mTableListBox.Clear;
  for i:= 0 to Length(mListMrgTable.mMrgTableS)-1 do
  begin
    SetTableList(mListMrgTable.mMrgTableS[i].ID);   // todo 為了防止 cache 順序錯誤, 先刷新一次
    mMrgTableListBox.Items.Add(mListMrgTable.mMrgTableS[i].Name);
    mMrgTableListBox.ItemIndex:=i;
  end;

  // 調整預設選項為 沒有
  mMrgTableListBox.ItemIndex:= -1;
  mMTableID:= 0;

  // 把 Table 的選單清空, 預設為無
  mTableListBox.Clear;
end;

procedure TTableControlPanel.SetTableList(aMrgTableID: Integer);
var
  vRSet: TRecordSet;
  i, vIdx: Integer;
begin
  vIdx := CacheMrgTableIdx( aMrgTableID );

  if vIdx = -1 then   // 無 cache 資料
  begin
    vRSet := gDBManager.GetMergeTable_TableS( aMrgTableID, 'detail' );  // 取出專案底下的總合表格
    SaveCacheTableList( aMrgTableID, vRSet);
    mListTable:= mArrListTable[ Length(mArrListTable)-1 ];   // Last Insert Item
  end
  else
    mListTable := mArrListTable[vIdx];

  // 清空 & 列出 List
  mTableListBox.Clear;
  for i:= 0 to Length(mListTable.mTableS)-1 do
  begin
    mTableListBox.Items.Add(mListTable.mTableS[i].Name);
  end;

  // 調整預設選項為 沒有
  mTableListBox.ItemIndex:= -1;
  mTableID:= 0;
end;

function TTableControlPanel.CacheMrgTableIdx(aMTableID: Integer): Integer;
var
  i: Integer;
  vLength: Integer;
begin
  result:= -1;
  vLength:= Length( mArrListTable );
  if vLength = 0 then
    Exit;
  for i:=0 to vLength-1 do
  begin
    if aMTableID = mArrListTable[i].mMrgTableID then  // 找到 ID, 有 cache 存在
    begin
      result:= i;
      exit;
    end;
  end;
end;

procedure TTableControlPanel.SaveCacheTableList(aMTableID: Integer;
  aRSet: TRecordSet);
var
  i, vIdx: Integer;  
begin
  vIdx:= Length(mArrListTable);
  SetLength(mArrListTable, vIdx+1);

  for i:= 0 to aRSet.RowNums-1 do  //將專案加入grid的combo
  begin
    SetLength( mArrListTable[vIdx].mTableS, i+1 );
    mArrListTable[vIdx].mTableS[i].ID := StrToIntDef(aRSet.Row[i, 'table_id'], 0);
    mArrListTable[vIdx].mTableS[i].TemplateID   := StrToIntDef(aRSet.Row[i, 'table_template_id'], 0);
    mArrListTable[vIdx].mTableS[i].Name := aRSet.Row[i, 'table_name'];
    mArrListTable[vIdx].mTableS[i].Description  := aRSet.Row[i, 'table_description'];
    mArrListTable[vIdx].mTableS[i].CreateUserID := StrToIntDef(aRSet.Row[i, 'table_create_user_id'],0);
    mArrListTable[vIdx].mTableS[i].CreateOrganizeID:= StrToIntDef(aRSet.Row[i, 'table_create_organize_id'],0);
    mArrListTable[vIdx].mTableS[i].CreateProjectID := StrToIntDef(aRSet.Row[i, 'table_create_project_id'],0);
    mArrListTable[vIdx].mTableS[i].CreateTime   := aRSet.Row[i, 'table_create_time'];
    mArrListTable[vIdx].mTableS[i].Expire_time  := aRSet.Row[i, 'table_expire_time'];
  end;
  mArrListTable[vIdx].mMrgTableID:= aMTableID;
end;

function TTableControlPanel.CacheUserIdx(aUserID: Integer): Integer;
var
  i: Integer;
  vLength: Integer;
begin
  result:= -1;
  vLength:= Length( mArrListProject );
  if vLength = 0 then
    Exit;
  for i:=0 to vLength-1 do
  begin
    if aUserID = mArrListProject[i].mUserID then   // 找到 ID, 有 cache 存在
    begin
      result:= i;
      exit;
    end;
  end;
end;

procedure TTableControlPanel.SaveCacheProjectList(aUserID: Integer;
  aRSet: TRecordSet);
var
  i, vIdx: Integer;
begin
  vIdx:= Length(mArrListProject);
  SetLength(mArrListProject, vIdx+1);

  for i:= 0 to aRSet.RowNums-1 do  //將專案加入grid的combo
  begin
    SetLength( mArrListProject[vIdx].mProjectS, i+1 );
    mArrListProject[vIdx].mProjectS[i].ID := StrToIntDef(aRSet.Row[i, 'project_id'], 0);
    mArrListProject[vIdx].mProjectS[i].Name := aRSet.Row[i, 'project_name'];
    mArrListProject[vIdx].mProjectS[i].LeaderUserID := StrToIntDef(aRSet.Row[i, 'project_leader_user_id'],0);
    mArrListProject[vIdx].mProjectS[i].Description  := aRSet.Row[i, 'project_description'];
  end;
  mArrListProject[vIdx].mUserID:= aUserID;
end;

procedure TTableControlPanel.SetPrivatProList;
var
  i,j,k,vIdx1,vIdx2:integer;
  vPrivateTableListShow:boolean;
begin
  vPrivateTableListShow:=false;

  MainForm.PrivateTableList.Items.Add('-----未完成項目-----');
  
  for i:=0 to length(mArrListProject[0].mProjectS)-1 do
  begin
    vIdx1 := CacheProjectIdx(mArrListProject[0].mProjectS[i].ID );

    for j:=0 to length(mArrListMrgTable[vIdx1].mMrgTableS)-1 do
    begin
      if mArrListMrgTable[vIdx1].mMrgTableS[j].TemplateID=1 then
      begin
        vIdx2 := CacheMrgTableIdx( mArrListMrgTable[vIdx1].mMrgTableS[j].ID );

        for k:=0 to length(mArrListTable[vIdx2].mTableS)-1 do
        begin
          if mArrListTable[vIdx2].mTableS[k].TemplateID=1 then
          begin
            MainForm.PrivateTableList.Items.Add(mArrListMrgTable[vIdx1].mMrgTableS[j].Name+
                                                format('(%d)',[gDBManager.GetPrivateTableNum(mArrListTable[vIdx2].mTableS[k].ID,
                                                               StateManage.NickName)]));
            if gDBManager.GetPrivateTableNum(mArrListTable[vIdx2].mTableS[k].ID,StateManage.NickName)>0 then
              vPrivateTableListShow:=true;
          end;
        end;
      end;
    end;
  end;
  if vPrivateTableListShow then
  begin
    MainForm.PTableListHide.Show;
    MainForm.Panel_UserInfo.Height:=MainForm.PageControl.Height;
    MainForm.PTableListShow.Hide;
    MainForm.PrivateTableList.ScrollWidth:=200;
  end
  else
  begin
    MainForm.PTableListShow.Visible:=true;
    MainForm.Panel_UserInfo.Height:=MainForm.PTableListHide.Top+MainForm.PTableListHide.Height;
    MainForm.PTableListHide.Hide;
  end;
end;

function TTableControlPanel.GetCurrentMergeTable: rMergeTable;
var
  i, vLength: Integer;
begin
  fillchar( result, Sizeof(result), 0 );
  if mMTableID <= 0 then
    exit;

  vLength:=  Length( mListMrgTable.mMrgTableS ); 
  for i:=0 to vLength-1 do
  begin
    if mListMrgTable.mMrgTableS[i].ID = mMTableID then
      result:= mListMrgTable.mMrgTableS[i];
  end;  
end;

function TTableControlPanel.GetCurrentProject: rProject;
begin
  fillchar( result, Sizeof(result), 0 );
  if mProjectID <= 0 then
    exit;

  result:= mListProject.mProjectS[mProjectID];
end;

function TTableControlPanel.GetCurrentTable: rTable;
var
  i, vLength: Integer;
begin
  fillchar( result, Sizeof(result), 0 );
  if mTableID <= 0 then
    exit;

  vLength:=  Length( mListTable.mTableS ); 
  for i:=0 to vLength-1 do
  begin
    if mListTable.mTableS[i].ID = mTableID then
      result:= mListTable.mTableS[i];
  end;
end;

procedure TTableControlPanel.ListBoxClear;
begin
  // 初始狀態需要把 MrgTable + Table 清空
  mProjListBox.Clear;
  mMrgTableListBox.Clear;
  mTableListBox.Clear;
end;

function TTableControlPanel.GetMergeTableData(aMTableID: Integer): rMergeTable;
var
  i, vLength: Integer;
begin
  fillchar( result, Sizeof(result), 0 );

  vLength:=  Length( mListMrgTable.mMrgTableS ); 
  for i:=0 to vLength-1 do
  begin
    if mListMrgTable.mMrgTableS[i].ID = aMTableID then
      result:= mListMrgTable.mMrgTableS[i];
  end;
end;

end.
