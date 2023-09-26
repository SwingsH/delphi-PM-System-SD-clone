{$I define.h}
unit NoticeManager;
(**************************************************************************
 * �Y�ɰT��(Notice) �P ���i(Bulletin)�޲z�u��
 *************************************************************************)
interface

uses
  (** SkyDragon *)
  DBManager, SQLConnecter, Notice, CommonSaveRecord,
  (** Delphi *)
  Main, Classes, StdCtrls, ExtCtrlS, ComCtrlS, GraphicS, Htmlview, Types;

type

  PrMessage = ^rMessage;
  rMessage = record
    Value      : String;       /// Message ���e
    Time       : Integer;      /// Message �ɶ��W�O
    TimeStr    : String;       /// Message �ɶ��r��
    Visible    : Boolean;      /// Message �O�_���
    ReferenceID: Integer;      /// Message �ѷӥΪ� ID, ���� database �� id
  end;

  TMessageListBase = class(TObject)
  private
    mCheckTimeStr  : String;
    mCheckTime     : Integer;
    mCount         : Integer;
    mMessageList   : TList;
    mUpdateCount   : Integer;   /// ��s�p�ƾ�
    mUpdateInterval: Integer;   /// �C����s�����j Tick
    mEnableUpdate  : Boolean;
  protected
    function AddMessage(aMessage :rMessage):Integer;
    function DeleteMessage(aMessage: rMessage):Boolean;
    function MessageExist(aMessage: rMessage):Boolean;                          /// �ˬd�� Notice �O�_�w�g�s�b
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update;
    procedure DoUpdate;virtual; abstract;
    procedure Clear;
  end;

  (*****************************
   * �����ܰʼҦ�: �j���Ҧ�, �@��Ҧ�
   *****************************)
  TNoticeResize    = (Search, Default);
  (********************************************************
   * �Y�ɰT��(Notice)�޲z�u��
   * @Author Swings Huang
   * @Version 2010/02/11 v1.0
   * @Todo 
   ********************************************************)
  TNoticeHandler = class(TMessageListBase)
  private
    mListBox : TListBox;
    mIDList  : TStringList;
    mViewer  : THTMLViewer;
    mPanel   : TPanel;
    mResizeMode   : TNoticeResize;
    mProjSave     : array of rComboSave;
    mMrgTableSave : array of rComboSave;
    mMrgColumnSave: array of rComboSave;
    mMrgRowSave   : array of rComboSave;
    mUserNameSave : array of rComboSave;
    mResizePadding_Default: TRect;
    procedure SetComboBox( aCombo: TComboBox; aSave: array of rComboSave );     // �Q�� rComboSave �]�w ComboBox
  protected
    procedure ResetComboBox;                                                    // �M�� ComboBox�����w�]��
    procedure ShowNoticeList(aRSet: TRecordSet; aTitle, aTime: String);         // �N�J TRecordSet ��� Title ����
    procedure ResizePanel( aMode : TNoticeResize); overload;                    // ���s�վ㪩���j�p
    procedure ResizePanel; overload;
  public                                                                        // �]�w�M��ܲӶ��� HTML Template
    constructor Create(aListBox: TListBox; aViewer: THTMLViewer);
    destructor Destroy; override;
    procedure Init;
    procedure SetActive;                                                        // User Focus �즹���ɭn������
    procedure DoUpdate; override;
    procedure OnItemClick(Sender: TObject);
    (** Notice Form **)
    procedure ShowNotice_ByTitle(aTitleID: Integer);overload;                   // �̷� Title ID ��ܲӶ�
    procedure ShowNotice_BySearch(aProjID,aMTableID,aMColID,aMRowID,            // �̷� �j������ ��ܲӶ�
                                  aUserID: Integer; aStartTime,aEndTime:String);overload;
    (** ComboBox ���ʺA�]�w **)
    procedure SetCombo_Project( aUserID: Integer);
    procedure SetCombo_UserName( aUserID: Integer);
    procedure SetCombo_MrgTable( aProjID: Integer);
    procedure SetCombo_MrgColumn( aMTableID: Integer);
    procedure SetCombo_MrgRow( aMTableID: Integer);
    (** Ĳ�o�ƥ�]�w **)
    procedure OnProjectSelect(Sender:TObject);
    procedure OnMrgTableSelect(Sender:TObject);
    procedure OnMrgColumnSelect(Sender:TObject);
    procedure OnMrgRowSelect(Sender:TObject);
    procedure OnUserNameSelect(Sender:TObject);
    procedure OnSearchClick(Sender:TObject);
    procedure OnDefaultClick(Sender:TObject);
  end;

  (********************************************************
   * ���i(Bulletin)�޲z�u��
   * @Author Swings Huang
   * @Version 2010/02/22 v1.0
   * @Todo 
   ********************************************************)
  TBulletinHandler = class(TMessageListBase)
  private
    mViewer: THTMLViewer;
    mIsFirst: Boolean;
    mHTMLSave: String;
  protected
  public
    constructor Create(aViewer: THTMLViewer);
    procedure DoUpdate; override;
  end;

  (********************************************************
   * ������T�B�z
   * @Author Swings Huang
   * @Version 2010/03/09 v1.0
   * @Todo 
   ********************************************************)
  TVersionMemoHandler = class(TMessageListBase)
  private
    mViewer: THTMLViewer;
    mHTMLSave: String;
    mVersionString: String;
  protected
  public
    constructor Create(aViewer: THTMLViewer);
    procedure DoUpdate; override;
  end;
  
var
  gNoticeHandler     : TNoticeHandler;
  gBulletinHandler   : TBulletinHandler;
  gVersionMemoHandler: TVersionMemoHandler;
implementation

uses
  CommonFunction, Const_Template, StateCtrl, Windows,
  SysUtils, Dialogs, Math, Controls;

const
  cNoticeString_001 = '�i%s�j  %s';
  cNoticeString_002 = '%s �� %s';
  cNoticeString_003 = '�j�����G�@%d��';
  
  cFontName = '�s�ө���' ;
  cFontSize = 10;
  cFontColor= clBlack;

  cComboDef_Proj    = '-�����M��-';
  cComboDef_Table   = '-�����`��-';
  cComboDef_Column  = '-�������-';
  cComboDef_Row     = '-�����C-';
  cComboDef_UserNmae= '-�Ҧ��ϥΪ�-';

  //cPanel_Margin:TRect = (Left: 5; Top: 35; Width: )
{ TMessageListBase }

function TMessageListBase.AddMessage(aMessage: rMessage): Integer;
var
  pMSG : PrMessage;
begin
  //Result:= -1;
  new(pMSG);
  pMSG^.Value      := aMessage.Value;
  pMSG^.Time       := aMessage.Time;
  pMSG^.TimeStr    := aMessage.TimeStr;
  pMSG^.Visible    := aMessage.Visible;
  pMSG^.ReferenceID:= aMessage.ReferenceID;

  Result:= mMessageList.Add(pMSG);
end;

procedure TMessageListBase.Clear;
begin

end;

constructor TMessageListBase.Create;
begin
  mMessageList := TList.Create;
  mCheckTimeStr:= '';
  mCheckTime   := 0 ;
  mCount       := 0 ;
  mUpdateInterval:= 5;
end;

function TMessageListBase.DeleteMessage(aMessage: rMessage): Boolean;
begin
  Result:= False;
end;

destructor TMessageListBase.Destroy;
begin
  inherited;
  FreeAndNil(mMessageList);
end;

function TMessageListBase.MessageExist(aMessage: rMessage): Boolean;
var
  i: Integer;
  pMSG: PrMessage;
begin
  Result:= False;

  for i:= 0 to mMessageList.Count-1 do
  begin
    pMSG := mMessageList.Items[i] ;
    if (aMessage.Value     = pMSG.Value) And
       (aMessage.Time      = pMSG.Time) And
       (aMessage.TimeStr   = pMSG.TimeStr) And
       (aMessage.Visible   = pMSG.Visible) And
       (aMessage.ReferenceID = pMSG.ReferenceID) then
    begin
      Result:= True;
      Exit;
    end;
  end;
end;

procedure TMessageListBase.Update;
begin
  mUpdateCount := (mUpdateCount + 1) mod mUpdateInterval;

  if mEnableUpdate = True then
  if mUpdateCount = 0 then
    DoUpdate;
end;

{ TNoticeHandler }

constructor TNoticeHandler.Create(aListBox: TListBox; aViewer: THTMLViewer);
begin
  inherited Create;
  mListBox := aListBox;
  mUpdateInterval:= 1;
  mIDList:= TStringList.Create;
  mEnableUpdate:= True;
  mViewer:= aViewer;
  mResizeMode:= Default;
  Init;
end;

destructor TNoticeHandler.Destroy;
begin

  inherited;
end;
                                                                                                    
procedure TNoticeHandler.DoUpdate;
var
  vRSet : TRecordSet;
  i, vIdx : Integer;
  vWord, vTimeStr, vTimeFilter: String;
begin
  vTimeFilter:= gDBManager.ConvertBig5Datetime(mCheckTimeStr) ;
  vRSet := gDBManager.GetTablelogTitleS(0, StateManage.ID, vTimeFilter);

  if vRSet.RowNums = 0 then
    Exit;

  for i:= 0 to vRSet.RowNums-1 do
  begin
     vWord   := vRSet.Row[i, 'tablelog_title_word'];
     vTimeStr:= vRSet.Row[i, 'tablelog_create_time'];
     mCheckTimeStr:= vTimeStr;
     vTimeStr:= gDBManager.ConvertBig5Datetime(vTimeStr);
     if vWord = '' then
       continue;
     //mListBox.Items.Add(Format(cNoticeString_001, [vTimeStr, vWord]));
     mListBox.Items.Insert(0, Format(cNoticeString_001, [vTimeStr, vWord]));
     mIDList.Insert(0, vRSet.Row[i, 'tablelog_title_id'] );
  end;

  // Focus ��̫�̷s���@�� = �Ĥ@��
  mListBox.ItemIndex:= 0;
  // ��̫ܳ�̷s���@�� LOG ���Ӷ�
  vIdx := StrToIntDef(mIDList[0], 1);
  ShowNotice_ByTitle(vIdx);
end;

procedure TNoticeHandler.Init;
begin
  mListBox.Font.Name := cFontName;
  mListBox.Font.Size := cFontSize;
  mListBox.Font.Color:= cFontColor;

  // �]�w buttonx ���ƥ�
  MainForm.mNoticeBTN_Search.OnClick := OnSearchClick;
  MainForm.mNoticeBTN_ReSet.OnClick  := OnDefaultClick;
  
  // �]�w combobox ���ƥ�
  MainForm.mNoticeComboBox_Project.OnSelect := OnProjectSelect;
  MainForm.mNoticeComboBox_MrgTable.OnSelect := OnMrgTableSelect;
  MainForm.mNoticeComboBox_MrgColumn.OnSelect := OnMrgColumnSelect;
  MainForm.mNoticeComboBox_MrgRow.OnSelect := OnMrgRowSelect;
  MainForm.mNoticeComboBox_UserName.OnSelect := OnUserNameSelect;

  // �]�w panel ���ѷ�
  mPanel:= MainForm.mPanelNotice ;
  
  ResetComboBox;  //...TODO: �i�H�@�o?
  // �]�w combobox ���ƥ�
  SetCombo_Project(0);
  SetCombo_MrgTable(0);
  SetCombo_MrgColumn(0);
  SetCombo_MrgRow(0);
  SetCombo_UserName(0);

  // �]�w Resize ��l��
  mResizePadding_Default:= Rect(mPanel.Left ,mPanel.Top,
                                  mPanel.Width,mPanel.Height);
end;

procedure TNoticeHandler.SetActive;
begin
  SetCombo_Project( StateManage.ID );
  SetCombo_UserName( StateManage.ID );
end;

procedure TNoticeHandler.OnItemClick(Sender: TObject);
var
  vIdx: Integer ;
  vWord:String;
begin
  if mListBox.ItemIndex = -1 then
    Exit;
  vIdx := StrToIntDef(mIDList[ mListBox.ItemIndex ], -1) ;
  vWord:= mListBox.Items[ mListBox.ItemIndex ];
  ShowNotice_ByTitle(vIdx);
end;

procedure TNoticeHandler.ResetComboBox;
begin
  MainForm.mNoticeComboBox_Project.Clear;
  MainForm.mNoticeComboBox_MrgTable.Clear;
  MainForm.mNoticeComboBox_MrgColumn.Clear;
  MainForm.mNoticeComboBox_MrgRow.Clear;
  MainForm.mNoticeComboBox_UserName.Clear;

  MainForm.mNoticeComboBox_Project.Items.Add('--�M��--');
  MainForm.mNoticeComboBox_MrgTable.Items.Add('--�`��--');
  MainForm.mNoticeComboBox_MrgColumn.Items.Add('--�`�����--');
  MainForm.mNoticeComboBox_MrgRow.Items.Add('-�C-');
  MainForm.mNoticeComboBox_UserName.Items.Add('--�ϥΪ�--');

  MainForm.mNoticeComboBox_Project.ItemIndex:=0 ;
  MainForm.mNoticeComboBox_MrgTable.ItemIndex:=0 ;
  MainForm.mNoticeComboBox_MrgColumn.ItemIndex:=0 ;
  MainForm.mNoticeComboBox_MrgRow.ItemIndex:=0 ;
  MainForm.mNoticeComboBox_UserName.ItemIndex:=0 ;
end;

procedure TNoticeHandler.SetComboBox(aCombo: TComboBox;
  aSave: array of rComboSave);
var
  i: Integer;  
begin
  aCombo.Clear;

  for i:= Low(aSave) to High(aSave) do
  begin
    aCombo.Items.Add(aSave[i].Name);
  end;
end;

procedure TNoticeHandler.SetCombo_MrgColumn(aMTableID: Integer);
var
  vRSet: TRecordSet;
  i: Integer;
begin
  fillChar(mMrgColumnSave, SizeOf(mMrgColumnSave), 0);
  SetLength(mMrgColumnSave, 0);
  
  // �]�m�̤W���w�]��
  SetLength(mMrgColumnSave, 1);
  mMrgColumnSave[0].ID   := 0 ;
  mMrgColumnSave[0].Name := cComboDef_Column ;  // '-�������-'

  if aMTableID <> 0 then
  begin
    vRSet:= gDBManager.GetMergeTable_ColumnS(aMTableID);
    // �]�m�M��
    for i:= 0 to vRSet.RowNums-1 do
    begin
      SetLength(mMrgColumnSave, Length(mMrgColumnSave)+1);
      mMrgColumnSave[i+1].ID   := StrToIntDef( vRSet.Row[i,'mergecolumn_id'] ,-1);
      mMrgColumnSave[i+1].Name := vRSet.Row[i,'column_name'];
    end;
  end;  

  SetComboBox( MainForm.mNoticeComboBox_MrgColumn, mMrgColumnSave);
  MainForm.mNoticeComboBox_MrgColumn.ItemIndex:= 0;
end;

procedure TNoticeHandler.SetCombo_MrgRow(aMTableID: Integer);
var
  i: Integer;
  vMaxRowID: Integer;
begin
  fillChar(mMrgRowSave, SizeOf(mMrgRowSave), 0);
  SetLength(mMrgRowSave, 0);
  
  // �]�m�̤W���w�]��
  SetLength(mMrgRowSave, 1);
  mMrgRowSave[0].ID   := 0 ;
  mMrgRowSave[0].Name := cComboDef_Row ;  // '-�����C-'

  if aMTableID <> 0 then
  begin
    vMaxRowID:= gDBManager.GetMergeColumnvalue_ID(aMTableID, 'max');
    // �]�m�M��
    for i:= 1 to vMaxRowID do
    begin
      SetLength(mMrgRowSave, Length(mMrgRowSave)+1);
      mMrgRowSave[i].ID   := i;
      mMrgRowSave[i].Name := Format('��%d�C',[i]);
    end;
  end;  

  SetComboBox( MainForm.mNoticeComboBox_MrgRow, mMrgRowSave);
  MainForm.mNoticeComboBox_MrgRow.ItemIndex:= 0;
end;

procedure TNoticeHandler.SetCombo_MrgTable(aProjID: Integer);
var
  vRSet: TRecordSet;
  i: Integer;
begin
  fillChar(mMrgTableSave, SizeOf(mMrgTableSave), 0);
  SetLength(mMrgTableSave, 0);

  // �]�m�̤W���w�]��
  SetLength(mMrgTableSave, 1);
  mMrgTableSave[0].ID   := 0 ;
  mMrgTableSave[0].Name := cComboDef_Table ;  // '�����`��'

  if aProjID <> 0 then
  begin
    vRSet:= gDBManager.GetProject_MergeTableS(aProjID);
    // �]�m�M��
    for i:= 0 to vRSet.RowNums-1 do
    begin
      SetLength(mMrgTableSave, Length(mMrgTableSave)+1);
      mMrgTableSave[i+1].ID   := StrToIntDef( vRSet.Row[i,'mergetable_id'] ,-1);
      mMrgTableSave[i+1].Name := vRSet.Row[i,'mergetable_name'];
    end;
  end;  

  SetComboBox( MainForm.mNoticeComboBox_MrgTable, mMrgTableSave);
  MainForm.mNoticeComboBox_MrgTable.ItemIndex:= 0;
end;

procedure TNoticeHandler.SetCombo_Project(aUserID: Integer);
var
  vRSet: TRecordSet;
  i: Integer;
begin
  fillChar(mProjSave, SizeOf(mProjSave), 0);
  SetLength(mProjSave, 0);
  
  // �]�m�̤W���w�]��
  SetLength(mProjSave, 1);
  mProjSave[0].ID   := 0 ;
  mProjSave[0].Name := cComboDef_Proj ;  // '�����M��'

  if aUserID <> 0 then
  begin
    vRSet:= gDBManager.GetUser_Project(aUserID);
    // �]�m�M��
    for i:= 0 to vRSet.RowNums-1 do
    begin
      SetLength(mProjSave, Length(mProjSave)+1);
      mProjSave[i+1].ID   := StrToIntDef( vRSet.Row[i,'project_id'] ,-1);
      mProjSave[i+1].Name := vRSet.Row[i,'project_name'];
    end;
  end;  

  SetComboBox( MainForm.mNoticeComboBox_Project, mProjSave);
  MainForm.mNoticeComboBox_Project.ItemIndex:= 0;
end;

procedure TNoticeHandler.SetCombo_UserName(aUserID: Integer);
begin
  (** TODO: **)
  fillChar(mUserNameSave, SizeOf(mUserNameSave), 0);
  SetLength(mUserNameSave, 0);

  // �]�m�̤W���w�]��
  SetLength(mUserNameSave, 1);
  mUserNameSave[0].ID   := 0 ;
  mUserNameSave[0].Name := cComboDef_UserNmae ;  // '-�Ҧ��ϥΪ�-'

  SetComboBox( MainForm.mNoticeComboBox_UserName, mUserNameSave);
  MainForm.mNoticeComboBox_UserName.ItemIndex:= 0;
end;

procedure TNoticeHandler.ShowNotice_ByTitle(aTitleID: Integer);
var
  vRSet : TRecordSet;
  vTitle, vTime: String;
  vText: String;
begin
  vRSet := gDBManager.GetTablelogListS(aTitleID, 'detail');
  if vRSet.RowNums = 0 then
  begin
    vText:= Template_HTMLBody(Template_NoticeListEmpty);
    mViewer.LoadFromBuffer(Pchar(vText),Length(vText),'');
    exit;
  end;
  
  vTitle:= vRSet.Row[0, 'tablelog_title_word'];
  vTime := vRSet.Row[0, 'tablelog_create_time'];
  vTime := gDBManager.ConvertBig5Datetime(vTime);
  
  ShowNoticeList(vRSet, vTitle, vTime);
end;

procedure TNoticeHandler.ShowNotice_BySearch(aProjID, aMTableID, aMColID,
  aMRowID, aUserID: Integer; aStartTime, aEndTime: String);
var
  vRSet : TRecordSet;
  vTitle, vTime: String;
begin
  vRSet := gDBManager.GetTablelogListS(0, 'detail',aProjID,aMTableID,aMColID,
                                       aMRowID,aUserID,aStartTime,aEndTime);
  // �]�w�ɶ��r��
  vTime := '';
  if (aStartTime<>'') OR (aEndTime<>'') then
    vTime := Format(cNoticeString_002,[aStartTime, aEndTime]); // '%s �� %s'
  vTitle:= Format(cNoticeString_003,[vRSet.RowNums]);          // '�j�����G�@%s��';
  ShowNoticeList(vRSet, vTitle, vTime);
end;

procedure TNoticeHandler.ShowNoticeList(aRSet: TRecordSet; aTitle, aTime: String);
var
  i     : Integer;
  vError: Boolean;
  vText : String;
begin
  vText     := Template_NoticeTitle(aTitle, aTime);
  for i:= 0 to aRSet.RowNums-1 do
  begin
    if StrToIntDef(aRSet.Row[i,'tablelog_list_error'],0) = 1 then
      vError := True
    else
      vError := False;
    vText:= vText + Template_NoticeList(aRSet.Row[i,'tablelog_list_message'],
                                        aRSet.Row[i,'tablelog_create_time'], vError );
  end;

  vText:= Template_HTMLBody(vText);
  mViewer.LoadFromBuffer(Pchar(vText),Length(vText),'');
end;

procedure TNoticeHandler.OnMrgColumnSelect(Sender: TObject);
begin
  // = 0 --> ������� : do no thing~  ��� ���v�T�|��L����
end;

procedure TNoticeHandler.OnMrgRowSelect(Sender: TObject);
begin
  // = 0 --> �����C�� : do no thing~  �C�� ���v�T�|��L����
end;

procedure TNoticeHandler.OnMrgTableSelect(Sender: TObject);
var
  vIdx, vID: Integer;
begin
  vIdx:= MainForm.mNoticeComboBox_MrgTable.ItemIndex ;
  vID := mMrgTableSave[vIdx].ID;

  if vID <> 0 then
  begin
    SetCombo_MrgColumn(vID);
    SetCombo_MrgRow(vID);
  end  
  else                      // = 0 --> �����`�� : ���� ComboBox �M��
  begin
    SetCombo_MrgColumn(0);
    SetCombo_MrgRow(0);
  end;
end;

procedure TNoticeHandler.OnProjectSelect(Sender: TObject);
var
  vIdx, vID: Integer;
begin
  vIdx:= MainForm.mNoticeComboBox_Project.ItemIndex ;
  vID:= mProjSave[vIdx].ID;

  if vID <> 0 then
    SetCombo_MrgTable(vID)
  else                      // = 0 --> �����M�� : ���� ComboBox �M��
  begin
    SetCombo_MrgTable(0);
    SetCombo_MrgColumn(0);
    SetCombo_MrgRow(0);
  end;
end;

procedure TNoticeHandler.OnUserNameSelect(Sender: TObject);
begin
  // TODO: �ݰt�X��´ schema
end;

procedure TNoticeHandler.OnSearchClick(Sender: TObject);
var
  vProjID, vMTableID, vMColumnID, vMRowID, vUserID: Integer;
  vStart, vEnd: String;
begin
  // avoid range check error
  vProjID   := mProjSave[ MainForm.mNoticeComboBox_Project.ItemIndex ].ID;
  vMTableID := mMrgTableSave[ MainForm.mNoticeComboBox_MrgTable.ItemIndex ].ID;
  vMColumnID:= mMrgColumnSave[ MainForm.mNoticeComboBox_MrgColumn.ItemIndex ].ID;
  vMRowID   := mMrgRowSave[ MainForm.mNoticeComboBox_MrgRow.ItemIndex ].ID;
  vUserID   := mUserNameSave[ MainForm.mNoticeComboBox_UserName.ItemIndex ].ID;

  if MainForm.mNoticePicker_StartTime.Checked = True then
  begin
    vStart  := DateTimeToStr( MainForm.mNoticePicker_StartTime.Time );
    vStart  := gDBManager.ConvertBig5Datetime( vStart );
  end
  else
    vStart  := '';

  if MainForm.mNoticePicker_EndTime.Checked = True then
  begin
    vEnd  := DateTimeToStr( MainForm.mNoticePicker_EndTime.Time );
    vEnd  := gDBManager.ConvertBig5Datetime( vEnd );
  end
  else
    vEnd  := '';

  if (vProjID=0) AND (vMTableID=0) then
  begin
    ShowMessage('�j���d��L�j');
    Exit;
  end;

  ShowNotice_BySearch(vProjID, vMTableID, vMColumnID, vMRowID, vUserID, vStart, vEnd);
  ResizePanel(Search);
end;

procedure TNoticeHandler.OnDefaultClick(Sender: TObject);
var
  vIdx : Integer;
begin
  ResizePanel(Default);

  // ��̫ܳ�̷s���@�� LOG ���Ӷ�
  vIdx := StrToIntDef(mIDList[ mListBox.Count-1 ], -1);
  ShowNotice_ByTitle(vIdx);
end;

procedure TNoticeHandler.ResizePanel(aMode: TNoticeResize);
begin
  mResizeMode:= aMode;
  ResizePanel;
end;


procedure TNoticeHandler.ResizePanel;
begin
  case mResizeMode of
    Search:
    begin
      mListBox.Visible:= False;
      mPanel.Top:= 40;
      mPanel.Left:= 0;
      mPanel.Width:= mPanel.Parent.Width;
      mPanel.Height:= mPanel.Parent.Height - mPanel.Top;
      mPanel.Anchors     := [akLeft, akRight, akBottom, akTop];
    end;  
    Default:
    begin
      mListBox.Visible:= True;
      mPanel.Top   := mResizePadding_Default.Top;
      mPanel.Left  := mResizePadding_Default.Left;
      mPanel.Width := mResizePadding_Default.Right;
      mPanel.Height:= mResizePadding_Default.Bottom;
      mPanel.Anchors:= [akLeft, akRight, akBottom];
    end;
  end;
end;

{ TBulletinHandler }

constructor TBulletinHandler.Create(aViewer: THTMLViewer);
begin
  mUpdateInterval:= 1;
  mEnableUpdate:= True;
  mViewer:= aViewer;
  mIsFirst:= True;
end;

procedure TBulletinHandler.DoUpdate;
var
  vRSet : TRecordSet;
  vTimeFilter, vTime, vText, vNickName, vAllHTML: String;
  i: Integer;
begin
  inherited;

  vTimeFilter:= gDBManager.ConvertBig5Datetime(mCheckTimeStr) ;
  vRSet:= gDBManager.GetBulletinS(0, 0, 0, 'detail', vTimeFilter);
  if vRSet.RowNums = 0 then
    Exit;

  for i:= 0 to vRSet.RowNums-1 do
  begin
    vNickName    := vRSet.Row[i,'user_nickname'];
    vText        := vRSet.Row[i,'bulletin_text'];
    vTime        := vRSet.Row[i,'create_datetime'];
    mCheckTimeStr:= vTime;
    mHTMLSave    := Template_BulletinList(vNickName, vTime, vText) + mHTMLSave;
    vAllHTML     := Template_HTMLBody( mHTMLSave );

    mViewer.LoadFromBuffer(Pchar(vAllHTML),Length(vAllHTML),'');

    if mIsFirst <> True then
    if i = vRSet.RowNums-1 then
    if StateManage.ID <> StrToIntDef(vRSet.Row[i, 'user_id'], 0) then
      ShowMessage( Format('[%s] ��: %s', [vNickName, vText]) );
  end;
  mIsFirst := False ;
end;

{ TVersionMemoHandler }

constructor TVersionMemoHandler.Create(aViewer: THTMLViewer);
begin
  mUpdateInterval:= 3;
  mEnableUpdate:= True;
  mViewer:= aViewer;
  mVersionString:= '';
end;

procedure TVersionMemoHandler.DoUpdate;
var
  vRSet: TRecordSet;
begin
  inherited;
  vRSet:= gDBManager.GetVersion(mCheckTimeStr);
  if vRSet.RowNums = 0 then
    Exit;

  mVersionString:= vRSet.Row[0, 'version_current'];
  mHTMLSave     := vRSet.Row[0, 'version_desc'];
  mCheckTimeStr := vRSet.Row[0, 'version_datetime'];
  mCheckTimeStr := gDBManager.ConvertBig5Datetime(mCheckTimeStr);
  mViewer.LoadFromBuffer(Pchar(mHTMLSave),Length(mHTMLSave),'');
    
  // �ˬd�����P�iĵ
{$ifndef Debug}
  if Trim(cVersion) <> Trim(mVersionString) then
  begin
    ShowMessage( Format('�z������ [SkyDragon %s], ���O�̷s����(%s), �Ш���s�T����ʧ�s',[cVersion,mVersionString]));
    (**
    if MessageDlg('SkyDragon�����w�g��s, �T�{��Y�N�����C', mtInformation,[mbYes],0)= mrYes then
    begin
      MainForm.Close;
    end;
    **)
  end;
{$endif}
  
end;

end.
