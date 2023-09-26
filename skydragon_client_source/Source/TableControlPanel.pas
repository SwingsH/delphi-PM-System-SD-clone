unit TableControlPanel;
(**************************************************************************
 * �ʺA��� �M��/�`�X���/�l��� UI ListBox �C�� ���
 * �ݭn�o�� [�������C��] �ާ@���A�P���, �ХѦ� pas �s��
 * Ex: �@�Τ��� Table ID, MergeTable ID, 
 *************************************************************************)
interface

uses
  (** Delphi *)
  StdCtrls,
  (** SkyDragon *)
  CommonSaveRecord, SQLConnecter;
  
type
  (**************************************************************************
   * �@�� Table �M�檺����
   *************************************************************************)
  rListTable = record
    mMrgTableID: Integer;       /// �������`�M���
    mTableS: array of rTable;   /// �`�M���U���@�� Table �M��
  end;
  
  (**************************************************************************
   * �@�� MergeTable �M�檺����
   *************************************************************************)
  rListMrgTable = record
    mProjectID: Integer;                  /// �������M��
    mMrgTableS: array of rMergeTable;     /// �M�פU���@�� MergeTable �M��
  end;

  (**************************************************************************
   * �@�� Project �M�檺����
   *************************************************************************)
  rListProject = record
    mUserID: Integer;                  /// �������ϥΪ�
    mProjectS: array of rProject;      /// �ϥΪ̤U���@�� Project �M��
  end;

  (**************************************************************************
   * �ʺA��� �M��/�`�X���/�l��� ListBox �C�� ���
   * @Author Swings Huang (2010/02/25 �s�W)
   * @todo ���c�����n,�i��}
   *************************************************************************)
  TTableControlPanel= class(TObject)
  private
    (** �@�Τ�����T *)
    mProjectID         : Integer;      /// �ާ@�����@�Τ�(Focus)�쪺 ProjectID
    mMTableID          : Integer;      /// �ާ@�����@�Τ�(Focus)�쪺 MergeTableID
    mTableID           : Integer;      /// �ާ@�����@�Τ�(Focus)�쪺 TableID
    mCurrentProjIdx    : Integer;      /// �ާ@�����@�Τ�(Focus)�쪺 �M�� listbox index
    mCurrentMrgTableIdx: Integer;      /// �ާ@�����@�Τ�(Focus)�쪺 �`�� listbox index
    mCurrentTableIdx   : Integer;      /// �ާ@�����@�Τ�(Focus)�쪺 �l�� listbox index
    mListProject       : rListProject; /// �@�Τ�(Focus)�M�ײM�檺����
    mListMrgTable      : rListMrgTable;/// �@�Τ�(Focus)�`��M�檺����
    mListTable         : rListTable;   /// �@�Τ�(Focus)�l��M�檺����
    (** Dfm ����ѷ� *)                               
    mProjListBox       : TListBox;     /// reference to Dfm Instance
    mMrgTableListBox   : TListBox;     /// reference to Dfm Instance
    mTableListBox      : TListBox;     /// reference to Dfm Instance
    (**�M�� Cache functions, �x�s�V DB �����L���M��*)
    mArrListProject : array of rListProject;                        /// for cache , �����֨������  TODO: private
    mArrListMrgTable: array of rListMrgTable;                       /// for cache , �����֨������  TODO: private
    mArrListTable   : array of rListTable;                          /// for cache , �����֨������  TODO: private
    function  CacheUserIdx(aUserID: Integer): Integer;                  /// �P�_ User �U�� Project �M��O�_�� cache, 0 �����s�b
    procedure SaveCacheProjectList(aUserID:Integer; aRSet:TRecordSet ); /// �x�s cache
    function  CacheProjectIdx( aProjID: Integer ):Integer;              /// �P�_ Project �U�� MegTable �M��O�_�� cache, 0 �����s�b
    procedure SaveCacheMTableList(aProjID:Integer; aRSet:TRecordSet );  /// �x�s cache
    function  CacheMrgTableIdx( aMTableID: Integer ):Integer;           /// �P�_ MegTable �U�� Table �M��O�_�� cache, 0 �����s�b
    procedure SaveCacheTableList(aMTableID:Integer; aRSet:TRecordSet ); /// �x�s cache
    function GetCurrentMergeTable: rMergeTable;                         /// ���o�ثe�@�Τ��� MergeTable Record
    function GetCurrentProject: rProject;                               /// ���o�ثe�@�Τ��� Project Record
    function GetCurrentTable: rTable;
    function GetMergeTableData(aMTableID:Integer): rMergeTable;
  protected
  public
    constructor Create( aProjListBox, aMrgTableListBox, aTableListBox:TListBox );
    procedure Init;
    procedure ListBoxClear;
    (** �]�m�M��C�� *)
    procedure SetProjectList( aUserID: Integer);                                /// �̷ӨϥΪ� ID �]�w�M�צC��
    procedure SetMrgTableList( aProjectID : Integer );                          /// �̷ӱM�� ID �]�w�`�X���C��
    procedure SetTableList( aMrgTableID: Integer );                             /// �̷��`�X��� ID �]�w�l���C��
    procedure SetPrivatProList;                                                 /// ��ܨϥΪ̥���������
    (** Event *)
    procedure OnProjectClick(Sender:TObject);
    procedure OnMrgTableClick(Sender:TObject);
    procedure OnTableClick(Sender:TObject);
    (** ��Ʀs���� *)
    property ListProject : rListProject read mListProject write mListProject;   /// �C����
    property ListMrgTable: rListMrgTable read mListMrgTable write mListMrgTable;/// �C����
    property ListTable   : rListTable read mListTable write mListTable;         /// �C����
    property Project     : rProject read GetCurrentProject;                     /// �@�Τ��� DB ���
    property MergeTable  : rMergeTable read GetCurrentMergeTable;               /// �@�Τ��� DB ���
    property Table       : rTable read GetCurrentTable;                         /// �@�Τ��� DB ���
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
    if aProjID = mArrListMrgTable[i].mProjectID then   // ��� ID, �� cache �s�b
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
  /// �C������\��
  if mProjListBox.ItemIndex = -1 then
    Exit;

  mProjectID := mListProject.mProjectS[mProjListBox.ItemIndex].ID ;
  if mProjectID <= 0 then
    Exit;

  SetMrgTableList(mProjectID);

  MainForm.AddNewBtn.Enabled := false;

  /// �����ܬ����\��
  GridManage.TableManager.CurrentTableID := 0;
  GridManage.GridComboManage.Clear;
  GridManage.ClearGrid;
end;

procedure TTableControlPanel.OnTableClick(Sender: TObject);
begin
  /// �C������\��
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

  /// �����ܬ����\��
  GridManage.SetTableTitle(mTableListBox.Items[mTableListBox.ItemIndex]);
  GridManage.TableManager.CurrentTableID := mTableID;
  GridManage.SetTable(mTableID);
  GridManage.GridLocking(GridManage.LockCols);
  GridManage.GridComboManage.Clear;
  GridManage.TriggerGridCancelSearch; // �I��or�������, �۰����ϥΪ̨����j�����A
end;

procedure TTableControlPanel.OnMrgTableClick(Sender: TObject);
begin
  /// �C������\��
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

  /// �����ܬ����\��
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

  if vIdx = -1 then   // cache �L���
  begin
    vRSet := gDBManager.GetUser_Project( aUserID );  // ���X�ϥΪ̩��U���M��
    SaveCacheProjectList( aUserID, vRSet);
    mListProject := mArrListProject[ Length(mArrListProject)-1 ];   // Last Insert Item
  end
  else
    mListProject := mArrListProject[vIdx];

  // �M�� & �C�X List
  ListBoxClear;
  for i:= 0 to Length(mListProject.mProjectS)-1 do
  begin
    SetMrgTableList(mListProject.mProjectS[i].ID);   // todo ���F���� cache ���ǿ��~, ����s�@��
    mProjListBox.Items.Add(mListProject.mProjectS[i].Name);
  end;

  // �վ�w�]�ﶵ�� �S��
  mProjListBox.ItemIndex:= -1;
  mProjectID:=0;

  // �� MrgTable + Table �����M��, �w�]���L
  mMrgTableListBox.Clear;
  mTableListBox.Clear;
end;

procedure TTableControlPanel.SaveCacheMTableList(aProjID: Integer; aRSet: TRecordSet);
var
  i, vIdx: Integer;
begin
  vIdx:= Length(mArrListMrgTable);
  SetLength(mArrListMrgTable, vIdx+1);

  for i:= 0 to aRSet.RowNums-1 do  //�N�M�ץ[�Jgrid��combo
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

  if vIdx = -1 then   // cache �L���
  begin
    vRSet := gDBManager.GetProject_MergeTableS( aProjectID );  // ���X�M�ש��U���`�X���
    SaveCacheMTableList( aProjectID, vRSet);
    mListMrgTable:= mArrListMrgTable[ Length(mArrListMrgTable)-1 ];   // Last Insert Item
  end
  else
    mListMrgTable := mArrListMrgTable[vIdx];

  // �M�� & �C�X List
  mMrgTableListBox.Clear;
  mTableListBox.Clear;
  for i:= 0 to Length(mListMrgTable.mMrgTableS)-1 do
  begin
    SetTableList(mListMrgTable.mMrgTableS[i].ID);   // todo ���F���� cache ���ǿ��~, ����s�@��
    mMrgTableListBox.Items.Add(mListMrgTable.mMrgTableS[i].Name);
    mMrgTableListBox.ItemIndex:=i;
  end;

  // �վ�w�]�ﶵ�� �S��
  mMrgTableListBox.ItemIndex:= -1;
  mMTableID:= 0;

  // �� Table �����M��, �w�]���L
  mTableListBox.Clear;
end;

procedure TTableControlPanel.SetTableList(aMrgTableID: Integer);
var
  vRSet: TRecordSet;
  i, vIdx: Integer;
begin
  vIdx := CacheMrgTableIdx( aMrgTableID );

  if vIdx = -1 then   // �L cache ���
  begin
    vRSet := gDBManager.GetMergeTable_TableS( aMrgTableID, 'detail' );  // ���X�M�ש��U���`�X���
    SaveCacheTableList( aMrgTableID, vRSet);
    mListTable:= mArrListTable[ Length(mArrListTable)-1 ];   // Last Insert Item
  end
  else
    mListTable := mArrListTable[vIdx];

  // �M�� & �C�X List
  mTableListBox.Clear;
  for i:= 0 to Length(mListTable.mTableS)-1 do
  begin
    mTableListBox.Items.Add(mListTable.mTableS[i].Name);
  end;

  // �վ�w�]�ﶵ�� �S��
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
    if aMTableID = mArrListTable[i].mMrgTableID then  // ��� ID, �� cache �s�b
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

  for i:= 0 to aRSet.RowNums-1 do  //�N�M�ץ[�Jgrid��combo
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
    if aUserID = mArrListProject[i].mUserID then   // ��� ID, �� cache �s�b
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

  for i:= 0 to aRSet.RowNums-1 do  //�N�M�ץ[�Jgrid��combo
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

  MainForm.PrivateTableList.Items.Add('-----����������-----');
  
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
  // ��l���A�ݭn�� MrgTable + Table �M��
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
