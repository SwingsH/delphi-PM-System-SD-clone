{$I define.h}
unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FMTBcd, DBXpress, WinSkinStore, WinSkinData, DB, SqlExpr,
  ExtCtrls, ComCtrls, Grids, StdCtrls, Htmlview, Menus, IniFiles, TableModel;

const
  cFilePath = 'Data\';          //�]�w�ɸ��|
  cFileName = 'LoginInfo.dat';  //�]�w���ɦW
  cDef_W = 800;
  cDef_H = 600;
  cVersion = '06.18';
  cCaption = '  �Ѫ��s Online(Ver.%s)';
  {$ifdef Debug}
  cUpdateTime = 2 * 1000;  //��s�ɶ�
  {$else}
  cUpdateTime = 2 * 1000;  //��s�ɶ�
  {$endif}

type
  TMainForm = class(TForm)
    Timer: TTimer;
    gSQLQuery: TSQLQuery;
    gSQLConnection: TSQLConnection;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    Grid: TStringGrid;
    GroupBox_TBBtn: TGroupBox;
    GroupBox_SysBTN: TGroupBox;
    GridBtn5: TButton;
    Bulletin_Edit: TEdit;
    BulletinSendBtn: TButton;
    BulletinClearBtn: TButton;
    DebugBtn: TButton;
    TestBtn: TButton;
    NoticeListBox: TListBox;
    mNoticeComboBox_Project: TComboBox;
    mNoticeComboBox_MrgTable: TComboBox;
    mNoticeComboBox_MrgColumn: TComboBox;
    mNoticeComboBox_MrgRow: TComboBox;
    mNoticePicker_StartTime: TDateTimePicker;
    mNoticePicker_EndTime: TDateTimePicker;
    mNoticeComboBox_UserName: TComboBox;
    mNoticeBTN_Search: TButton;
    mNoticeBTN_ReSet: TButton;
    mLabelNoticeTitle: TLabel;
    mPanelNotice: TPanel;
    mNoticeHTMLViewer: THTMLViewer;
    mBulletinHTMLViewer: THTMLViewer;
    mPanelBulletin: TPanel;
    AddNewBtn: TButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    MenuItem_Theme: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    MenuItem_SQLDebugForm: TMenuItem;
    N10: TMenuItem;
    BlockColMenu: TMenuItem;
    GroupBox_Project: TGroupBox;
    mListBox_ProjList: TListBox;
    GroupBox_MrgTable: TGroupBox;
    mListBox_MrgTableList: TListBox;
    GroupBox_Table: TGroupBox;
    mListBox_TableList: TListBox;
    Panel_UserInfo: TPanel;
    PanelHide: TButton;
    PanelShow: TButton;
    PTableListShow: TButton;
    PTableListHide: TButton;
    SysMessage: TLabel;
    mPanelAbout: TPanel;
    mAboutHTMLViewer: THTMLViewer;
    PrivateTableList: TListBox;
    UserInfo: TRichEdit;
    MenuItem_Close: TMenuItem;
    PopupMenu1: TPopupMenu;
    mPOPMenu_Search: TMenuItem;
    mPOPMenu_SEARCHCancel: TMenuItem;
    mPOPMenu_DEL: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    mPOPMenu_ADD: TMenuItem;
    SkinData: TSkinData;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridBtn4Click(Sender: TObject);
    procedure GridBtn5Click(Sender: TObject);
    procedure BulletinClearBtnClick(Sender: TObject);
    procedure BulletinSendBtnClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DebugBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NoticeListBoxClick(Sender: TObject);
    procedure TestBtnClick(Sender: TObject);
    procedure AddNewBtnClick(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure MenuItem_ThemeClick(Sender: TObject);
    procedure PanelHideClick(Sender: TObject);
    procedure PanelShowClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure MenuItem_SQLDebugFormClick(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure BlockColMenuClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure PTableListHideClick(Sender: TObject);
    procedure PTableListShowClick(Sender: TObject);
    procedure PrivateTableListDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure GridEnter(Sender: TObject);
    procedure GridExit(Sender: TObject);
    procedure GridTopLeftChanged(Sender: TObject);
    procedure MenuItem_CloseClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mPOPMenu_SearchClick(Sender: TObject);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mPOPMenu_SEARCHCancelClick(Sender: TObject);
    procedure mPOPMenu_DELClick(Sender: TObject);
    procedure mListBox_MrgTableListEnter(Sender: TObject);
    procedure mPOPMenu_ADDClick(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure Bulletin_EditKeyPress(Sender: TObject; var Key: Char);
  private
    mMyIniFile: TIniFile;
    mSkinEnable: Boolean;    /// �]�� skin path ��W, �n�P�_�Lskn��Ƨ������p
  public
    mGridCol,mGridRow:integer;
    procedure AddSysMessage(aStr:string);
    property MyIniFile: TIniFile read mMyIniFile;
    procedure DisableSkin;
    procedure EnableSkin;
  end;

var
  MainForm: TMainForm;
  AppPath, SkinPath: String;

implementation

{$R *.dfm}

uses
  GridCtrl, DoLogin, StateCtrl, DBManager, NoticeManager, TableHandler,
  XlsCtrl, Debug, SQLConnecter, Notice, TableControlPanel, ChangePass,
  ChangeSkin, TableEditor, CommonFunction, HTMLHint, Const_Template;

procedure TMainForm.FormCreate(Sender: TObject);
var
  vSkin: string;
begin
  mSkinEnable:= true;
  AppPath := ExtractFilePath(Application.ExeName);
  SkinPath := AppPath + 'skin\';
  if DirectoryExists(SkinPath)=false then
    mSkinEnable:= false ;

  //form�]�w
  Caption := format(cCaption, [cVersion]);

  //�m��
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;
  if Left < 0 then
    Left := 0;
  if Top < 0 then
    Top := 0;

  //�s�u�Ұ�
  gDBManager := TDBManager.Create;
  gQGenerator := TQueryGenerator.Create;
  // �@����B�z���Ұ�
  gTableHandler := TTableHandler.Create;
  // �X�֦��`���B�z���Ұ�
  gMergeTableHandler := TMergeTableHandler.Create;
  // ���U��
  GridManage := TGridManage.Create(Grid);
  // �n�J�U��
  StateManage := TStateManage.Create;
  // �Y�ɰT���U��
  gNoticeHandler  := TNoticeHandler.Create(NoticeListBox, mNoticeHTMLViewer);
  // ���i�U��
  gBulletinHandler:= TBulletinHandler.Create(mBulletinHTMLViewer);
  // ��汱��O�U��
  gTableControlPanel:= TTableControlPanel.Create(mListBox_ProjList,mListBox_MrgTableList,mListBox_TableList); // �ʺA��� �M��/�`�X���/�l��� �C�� ���
  // ���s�边(�s�W�ק�s�边)
  gTableEditor:= TTableEditor.Create;
  // Excel�U��
  XlsManage := TXlsManage.Create;
  // �����T���U��
  gVersionMemoHandler:= TVersionMemoHandler.Create(mAboutHTMLViewer);
  
  // Skin�]�w
  if mSkinEnable then
  begin
    mMyIniFile := TIniFile.Create(SkinPath + 'Skin.ini');
    if not FileExists(SkinPath + 'Skin.ini') then
      mMyinifile.WriteString('public', 'SkinData', '');
    vSkin := mMyIniFile.ReadString('public', 'SkinData', '');
    if vSkin <> '' then
    begin
      vSkin:=StringReplace(vSkin,'..',ExcludeTrailingPathDelimiter(AppPath),[rfIgnoreCase]);
      SkinData.LoadFromFile(vSkin);
      SkinData.Active := True;
      //SkinData.MenuUpdate:=false;
      //SkinData.MenuMerge :=false;
    end
    else
      SkinData.Active := false;
    MenuItem_Theme.Visible:= true;
  end
  else
  begin
    DisableSkin;
    MenuItem_Theme.Visible:= false;
  end;

  //��椸��StringGrid�]�w
  Grid.Options := [ goFixedVertLine,
                    goFixedHorzLine,
                    goVertLine,
                    goHorzLine,
                    //goRangeSelect,
                    goDrawFocusSelected,
                    goRowSizing,         //�ƹ��i���ܦ�e
                    goColSizing,         //�ƹ��i���ܦC��
                    goRowMoving,
                    goColMoving,
                    //goEditing,         //�����s��
                    goTabs,
                    //goRowSelect,       //�����C, ����Focus �m�e
                    goThumbTracking ];    //���b�ʮɸ�۰�

  //�Y�ɰT���j������]�w
  mNoticePicker_EndTime.DateTime:= Now;
  mNoticePicker_StartTime.ShowCheckbox:= True;
  mNoticePicker_EndTime.ShowCheckbox:= True;
  mNoticePicker_StartTime.Checked:= False;     // �]����Date��l��, �ݳs�]�⦸ False (TimePicker���ʳ�)
  mNoticePicker_StartTime.Checked:= False;
  mNoticePicker_EndTime.Checked:= False;       // �]����Date��l��, �ݳs�]�⦸ False (TimePicker���ʳ�)
  mNoticePicker_EndTime.Checked:= False;
  mNoticeHTMLViewer.ScrollBars:= ssVertical;

  //�Y���ݩʳ]�m
  //PageControl.Align        := alCustom;                           // ������
  PageControl.Anchors      := [akLeft, akTop, akRight, akBottom];
  //PrivateTableList.Align   := alCustom;
//  PrivateTableList.Anchors := [akLeft, akTop, akBottom];
  //UserInfo.Align           := alCustom;
  UserInfo.Anchors         := [akLeft, akTop];
  //Grid.Align               := alCustom;                           // �U�����
  Grid.Anchors             := [akLeft, akTop, akRight, akBottom];
  //mPanelBulletin.Align     := alCustom;
  mPanelBulletin.Anchors   := [akLeft, akTop, akRight, akBottom];
  //GroupBox_Project.Align   := alCustom;
  GroupBox_Project.Anchors := [akLeft, akBottom];
  //GroupBox_MrgTable.Align  := alCustom;
  GroupBox_MrgTable.Anchors:= [akLeft, akBottom];
  //GroupBox_Table.Align     := alCustom;
  GroupBox_Table.Anchors   := [akLeft, akBottom];
  //GroupBox_TBBtn.Align     := alCustom;
  GroupBox_TBBtn.Anchors   := [akRight, akBottom];
  //GroupBox_SysBtn.Align    := alCustom;
  GroupBox_SysBtn.Anchors  := [akRight, akBottom];
  //BulletinClearBtn.Align   := alCustom;                           // ���i
  BulletinClearBtn.Anchors := [akRight, akBottom];
  //BulletinSendBtn.Align    := alCustom;
  BulletinSendBtn.Anchors  := [akRight, akBottom];
  //Bulletin_Edit.Align      := alCustom;
  Bulletin_Edit.Anchors    := [akLeft, akRight, akBottom];
  //mLabelNoticeTitle.Align  := alCustom;                           // �Y�ɰT��
  mLabelNoticeTitle.Anchors:= [akLeft, akRight, akBottom];
  //NoticeListBox.Align      := alCustom;
  NoticeListBox.Anchors    := [akLeft, akTop, akRight, akBottom];
  //mPanelNotice.Align       := alCustom;
  mPanelNotice.Anchors     := [akLeft, akRight, akBottom];
  //mPanelAbout.Align        := alCustom;
  mPanelAbout.Anchors      := [akLeft, akTop, akRight, akBottom];
  //SysMessage.Align         := alCustom;
  SysMessage.Anchors       := [akLeft, akBottom];
  
  {$ifdef Debug}
    DebugBtn.Show;
    TestBtn.Show;
    MenuItem_SQLDebugForm.Visible:= true;
  {$else}
    DebugBtn.Hide;
    TestBtn.Hide;
    MenuItem_SQLDebugForm.Visible:= false;
  {$endif}
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SkinData.Active := false;
  LoginForm.FormDestroy(Sender);     // TODO:
  FreeAndNil(XlsManage);
  FreeAndNil(GridManage);
  FreeAndNil(StateManage);
  FreeAndNil(gMergeTableHandler);
  FreeAndNil(gTableHandler);
  FreeAndNil(gQGenerator);
  FreeAndNil(gDBManager);
  FreeAndNil(gNoticeHandler);
  FreeAndNil(gBulletinHandler);
  FreeAndNil(gVersionMemoHandler);
end;

procedure TMainForm.BulletinClearBtnClick(Sender: TObject);
begin
  Bulletin_Edit.Clear;
end;

procedure TMainForm.BulletinSendBtnClick(Sender: TObject);
begin
  if not StateManage.CheckState then
    exit;

  if StateManage.Level < 0 then
  begin
    ShowMessage('���i�v������');
    Exit;
  end;

  if Trim(Bulletin_Edit.Text) = '' then
  begin
    ShowMessage('�п�J���i');
    Exit;
  end;

  gDBManager.AddBulletin(StateManage.ID, 2, Trim(Bulletin_Edit.Text),2,1); /// TODO:......
  Bulletin_Edit.Clear;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  if not StateManage.Logined then
    exit;

  gNoticeHandler.Update;
  gBulletinHandler.Update;
  gVersionMemoHandler.Update;

  if GetTickCount < (StateManage.LoginTime + cUpdateTime) then  //�p���s�ɶ�
    exit;

  StateManage.LoginTime := GetTickCount;

  StateManage.Update;

  GridManage.Update;  //debug�������۰ʧ�s�n��K������
end;

procedure TMainForm.GridBtn4Click(Sender: TObject);
begin
  //XlsManage.NewExcel;  //�Ыؤ@�ӷs��excel
end;

procedure TMainForm.GridBtn5Click(Sender: TObject);
begin
  LoginForm.Show;
end;

procedure TMainForm.DebugBtnClick(Sender: TObject);
begin
  DebugForm.InitShow;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
{$ifdef Debug}
  if StateManage.ID = 0 then              // ���n�J
  begin
    StateManage.NickName := '�}�o�H��';
    StateManage.ID := 1;
  end;  
{$endif}

  gDBManager.Init; //TODO: �|����h��
  gDBManager.TestRun;

  //�n�JŪ���]�w��
  if not StateManage.Logined then
  begin
    StateManage.Load((AppPath + cFilePath), cFileName);
    StateManage.AutoLogin;  //�ˬd�۰ʵn�J
  end;

  // if GridManage.Table = nil then
  if GridManage.TableManager.CurrentTableID <> 0 then //��ܦ��}�Ҫ��, S.H Mod:
    BlockColMenu.Enabled := false
  else
    BlockColMenu.Enabled := true;
end;

procedure TMainForm.GridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  vCol, vRow: Integer;
begin
  if not StateManage.CheckState then
    exit;

  Grid.MouseToCell(X, Y, vCol, vRow);  //���o�ƹ��Ҧb��C
  if (vCol<>-1)and(vRow<>-1)then
  begin
    mGridCol := vCol;
    mGridRow := vRow;
  end;    

  if Button = mbLeft then  //����
  begin
    //����ثe���s��\��, ���bGridSelectCell�̭�
    GridManage.LockCols := mGridCol;  //�]�w�Q��w�����ƥج�mGridCol(�bSetmLockCols���P�_)
  end
  else
  if Button = mbRight then  //�k��
  begin
  end;

  // �]�m falg �� Grid�W��Search�� combo ���s�]�w size
  GridManage.GridComboManage.Changed:= True;
end;

procedure TMainForm.NoticeListBoxClick(Sender: TObject);
begin
  gNoticeHandler.OnItemClick(Sender);
end;

procedure TMainForm.TestBtnClick(Sender: TObject);
(*var
  i: Integer;
  vRSet: TRecordSet;
  vStr: String;
  v1, v2, v3: String;*)
begin
  {$ifdef Debug}
{
    vRSet := gDBManager.GetMergeTable_ColumnvalueS(1);
    vStr := '��[%s]��,��[%s]�C,��줺�e:[%s]';

    for i := 0 to (vRSet.RowNums - 1) do
    begin
      v1 := vRSet.Row[i,'mergecolumn_id'];
      v2 := vRSet.Row[i,'column_row_id'];
      v3 := vRSet.Row[i,'value'];

      ShowMessage(format(vStr, [v1, v2, v3]));
    end;
}
{
    vRSet := gDBManager.GetTable_ColumnvalueS(1);
    vStr := '��[%s]��,��[%s]�C,��줺�e:[%s]';

    for i := 0 to (vRSet.RowNums - 1) do
    begin
      v1 := vRSet.Row[i,'column_id'];
      v2 := vRSet.Row[i,'column_row_id'];
      v3 := vRSet.Row[i,'value'];

      ShowMessage(format(vStr, [v1, v2, v3]));
    end;
}
  {$endif}
end;


procedure TMainForm.AddNewBtnClick(Sender: TObject);
begin
  if GridManage.TableManager.CurrentMrgTableID = 0 then   // �S���@�Υ�����
    exit;

  gTableEditor.TriggerShow(GridManage.TableManager.CurrentMrgTable.Column);  // �s�W���@�v�ϥ��`�� MrgTable ���, �@����J�h��
  ///gTableEditor.TriggerShow(GridManage.TableManager.CurrentTable.Column); // �l���ƪ� �s�����
end;

procedure TMainForm.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  vRect:TRect;
  vComboBox: TComboBox;
  i:Integer;
  vList:TStringList;
begin
  if (ACol >= 1) and (ARow >= 1) then  //�N��w����l�C��]�w�����L����w���C��ۦP
  begin
    if gdFixed in State then
    begin
      Grid.Canvas.Brush.Color := Grid.Color;
      Grid.Canvas.FillRect(Rect);
      Grid.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, Grid.Cells[ACol, ARow]);
    end;
  end;

  ///== �H�U���j���� �U�Ԧ����
  if GridManage.TableManager.CurrentTableID=0 then
    exit;

  if (aRow=(cFirstRowCount-1)) and  // �ﶵ�M�ΦC
     (GridManage.TableManager.CurrentTable.Column.Data[aCol-1].ColumnType='selectbox') then  // ��쫬�A���U�Ԧ�
  begin
    if GridManage.GridComboManage.Exist(aCol, aRow)=false then   // �O�_�w�إߡ@�H���Mtick�@�P�_
    begin
      vComboBox:= GridManage.GridComboManage.RegisterItem(aCol, aRow);
      vList:= gTableHandler.StringToSelectList(GridManage.TableManager.CurrentTable.Column.Data[aCol-1].TypeSet);
      for i:=0 to vList.Count-1 do
        vComboBox.Items.Add(vList[i]);

      //���� X,Y,W,H  
      vRect := TStringGrid(Sender).CellRect(ACOL,AROW);
      vComboBox.Width := vRect.Right-vRect.Left;
      vComboBox.Height:= vRect.Bottom + vComboBox.Items.Count*15;
      vComboBox.Left  := vRect.Left;
      vComboBox.Top   := vRect.Top;
    end
    else
    begin
      vComboBox:= GridManage.GridComboManage.ItemS[aCol, aRow];

      if GridManage.GridComboManage.ItemChanged[aCol, aRow] then    // �P�_�O�_�n���� X,Y,W,H
      begin
        vRect := TStringGrid(Sender).CellRect(ACOL,AROW);
        vComboBox.Width := vRect.Right-vRect.Left;
        vComboBox.Height:= vRect.Bottom + vComboBox.Items.Count*15;
        vComboBox.Left  := vRect.Left;
        vComboBox.Top   := vRect.Top;

        //if GridManage.GridComboManage.IsLastItem(aCol, aRow) then  //�P�_���U���̫�@�� combobox = ������s����, ���� flag
        GridManage.GridComboManage.ItemChanged[aCol, aRow]:= false;
      end;
    end;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //SkinData.EnableSkin(false);
  SkinData.Active := false;
  Application.Terminate;
  if DebugForm<>nil then
    DebugForm.Close;
end;

procedure TMainForm.MenuItem_SQLDebugFormClick(Sender: TObject);
begin
  MenuItem_SQLDebugForm.Checked:=not MenuItem_SQLDebugForm.Checked;
  if MenuItem_SQLDebugForm.Checked then
    DebugForm.Show
  else
    DebugForm.Close;
end;

procedure TMainForm.N10Click(Sender: TObject);
begin
  XlsManage.NewExcel;  //�Ыؤ@�ӷs��excel
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
  if mListBox_ProjList.ItemIndex < 0 then
    N10.Enabled := false
  else
    N10.Enabled := true;
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
  ChangePassForm.Show;
end;

procedure TMainForm.BlockColMenuClick(Sender: TObject);
begin
  if GridManage.LockCols <> 0 then
  begin
    BlockColMenu.Checked := not BlockColMenu.Checked;
    GridManage.IsLock := BlockColMenu.Checked;

    case BlockColMenu.Checked of
      True:
        GridManage.GridLocking(GridManage.LockCols);
      else
        GridManage.GridLocking(1);
    end;
  end;
end;

procedure TMainForm.MenuItem_ThemeClick(Sender: TObject);
begin
  ChangeSkinForm.Show;
end;

procedure TMainForm.PanelHideClick(Sender: TObject);
var
  vTempW: Integer;
begin
  Panel_UserInfo.Hide;
  PanelHide.Hide;
  PanelShow.Visible:=true;
  vTempW:= PageControl.Left;
  PageControl.Left:=PanelShow.Left+PanelShow.Width;
  vTempW:= abs(vTempW - PageControl.Left); // �� X - �s X = ���ʶZ��
  PageControl.Width:= PageControl.Width + vTempW;
  //MainForm.Width:=MainForm.Width-(Panel_UserInfo.Width-15);
end;

procedure TMainForm.PanelShowClick(Sender: TObject);
var
  vTempW: Integer;
begin
  Panel_UserInfo.Show;
  PanelHide.Show;
  PanelShow.Hide;
  vTempW:= PageControl.Left;
  PageControl.Left:=PanelHide.Left+PanelHide.Width;
  vTempW:= abs(PageControl.Left - vTempW); // �� X - �s X = ���ʶZ��
  PageControl.Width:= PageControl.Width - vTempW;
  //MainForm.Width:=MainForm.Width+(Panel_UserInfo.Width-15);
end;

// ��s�O��
procedure TMainForm.N6Click(Sender: TObject);
begin
  PageControl.ActivePage:=TabSheet5;
end;

procedure TMainForm.GridDblClick(Sender: TObject);
var
  vLabel: TLabel;
  vLen, i: Integer;
begin
  if mGridRow < 0 then    // �I����t���Ǧ���� or �S�I��������
    exit;
  if mGridCol <= 0 then
    exit;
  if gTableControlPanel.TableID = 0 then  //�u���l��榳�@��,  �{�b�S���@�Τ�[�l���], �Y���I�����]�L��
    exit;

  if mGridRow = 0 then  //�����ƹ��|�۰ʱN���e�׳]��̾A�j�p
  begin
    vLabel := TLabel.Create(nil);
    vLabel.Caption := MainForm.Grid.Cells[mGridCol, mGridRow] + '  ';
    vLen := vLabel.Width;

    for i := 1 to GridManage.TableManager.CurrentTable.RowNums - 1 do
    begin
      //vLabel.Caption := GridManage.TableManager.CurrentTable.Cells[mGridCol, i].Value + '  ';
      vLabel.Caption := GridManage.DataCellS[mGridCol, i].Value + '  ';

      if vLen < vLabel.Width then
        vLen := vLabel.Width;
    end;

    MainForm.Grid.ColWidths[mGridCol] := vLen;
    FreeAndNil(vLabel);
    exit;
  end;

  GridManage.TriggerGridEdit(mGridCol,mGridRow);
end;

procedure TMainForm.PTableListHideClick(Sender: TObject);
begin
  PTableListShow.Visible:=true;
  Panel_UserInfo.Height:=PTableListHide.Top+PTableListHide.Height;
  PTableListHide.Hide;
  Panel_UserInfo.Anchors:=[akLeft,akTop];
end;

procedure TMainForm.PTableListShowClick(Sender: TObject);
begin
  PTableListHide.Show;
  Panel_UserInfo.Height:=PageControl.Height;
  PTableListShow.Hide;
  Panel_UserInfo.Anchors:=[akLeft,akTop,akBottom];
  PrivateTableList.Anchors := [akLeft, akTop,akBottom];
end;

procedure TMainForm.PrivateTableListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  cTitleIndex = 0;  
var
  vNum:integer;
begin
  vNum:=StrToIntDef(Copy(PrivateTableList.Items.Strings[Index],length(PrivateTableList.Items.Strings[Index])-1,1), 0);
  if (vNum>0) or (Index=cTitleIndex) then
    PrivateTableList.Canvas.Font.Style:=[fsBold]
  else
    PrivateTableList.Canvas.Font.Style:=[];
  PrivateTableList.Canvas.TextOut(Rect.Left, Rect.Top,PrivateTableList.Items.Strings[Index]);
end;

procedure TMainForm.AddSysMessage(aStr: string);
begin
  SysMessage.Caption:=aStr;
end;

procedure TMainForm.GridEnter(Sender: TObject);
begin
  AddSysMessage('�������� or Enter=�s��, Shift+��������=�j��, Esc=�����j��, Delete=�R��');
  if GridManage.IsMrg then
    AddNewBtn.Enabled:=true;
end;

procedure TMainForm.GridExit(Sender: TObject);
begin
  AddSysMessage('');
end;

procedure TMainForm.GridTopLeftChanged(Sender: TObject);
begin
  GridManage.GridComboManage.Clear;
  sleep(0);
end;

procedure TMainForm.MenuItem_CloseClick(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if gTableControlPanel.TableID = 0 then  // �u���l��榳�@��, �{�b�S���@�Τ�[�l���], �Y���I�����]�L��
    exit;

  case Key of
    VK_RETURN:GridManage.TriggerGridEdit(mGridCol, mGridRow); //Enter
    VK_ESCAPE:GridManage.TriggerGridCancelSearch;             //Esc
    VK_Delete:GridManage.TriggerGridDelete(mGridCol,mGridRow);//Delete
  end;
end;

procedure TMainForm.mPOPMenu_SearchClick(Sender: TObject);
begin
  GridManage.SelectNeed(mGridCol, mGridRow);  //�̱���z��
end;

procedure TMainForm.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  vGRect:TGridRect;
  vCol, vRow: Integer;
begin
  if gTableControlPanel.TableID = 0 then  // �u���l��榳�@��, �{�b�S���@�Τ�[�l���], �Y���I�����]�L��
    exit;

  Grid.MouseToCell(X, Y, vCol, vRow);  //���o�ƹ��Ҧb��C
  if (vCol<>-1)and(vRow<>-1)then
  begin
    mGridCol := vCol;
    mGridRow := vRow;
  end;
  
  if Button = mbLeft then  //����
  begin
    if ssShift in Shift then
      GridManage.SelectNeed(mGridCol, mGridRow);  //�̱���z��
  end
  else
  if Button = mbRight then  //�k��
  begin
    vGRect.Left:=mGridCol;
    vGRect.Top:=mGridRow;
    vGRect.Right:=mGridCol;
    vGRect.Bottom:=mGridRow;
    Grid.Selection:=vGRect;   // �`�N!�]�w Grid ����d��, TODO: �����O�B�Τ@�]�m
    if GridManage.IsSelect then
      mPOPMenu_SEARCHCancel.Visible:=true
    else
      mPOPMenu_SEARCHCancel.Visible:=false;
    mPOPMenu_DEL.Visible:=true;
    mPOPMenu_ADD.Visible:=true;
    PopupMenu1.Popup(MainForm.Left+Panel_UserInfo.Width+20+X,MainForm.top+90+Y);
  end;
end;

procedure TMainForm.mPOPMenu_SEARCHCancelClick(Sender: TObject);
begin
  GridManage.TriggerGridCancelSearch;
end;

procedure TMainForm.mPOPMenu_DELClick(Sender: TObject);
begin
  GridManage.TriggerGridDelete(mGridCol,mGridRow);
end;

procedure TMainForm.mListBox_MrgTableListEnter(Sender: TObject);
begin
  AddNewBtn.Enabled:=true;
end;

procedure TMainForm.mPOPMenu_ADDClick(Sender: TObject);
begin
  if GridManage.TableManager.CurrentMrgTableID = 0 then
    exit;

  gTableEditor.TriggerShow(GridManage.TableManager.CurrentMrgTable.Column);  // �s�W���@�v�ϥ��`�� MrgTable ���, �@����J�h��
  /// gTableEditor.TriggerShow(GridManage.TableManager.CurrentTable.Column); // �l���ƪ� �s�����
  (** �ª��s�����
  if GridManage.Project <> nil then
  begin
    if GridManage.IsMrg then
    begin
      GridManage.IsFixMode := false;
      GEditForm.Show;
    end;
  end;
  *)
end;

procedure TMainForm.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  mGridCol:=ACol;
  mGridRow:=ARow;
end;

procedure TMainForm.Bulletin_EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
    BulletinSendBtn.Click;
end;

procedure TMainForm.DisableSkin;
begin
  SkinData.Active := false;
end;

procedure TMainForm.EnableSkin;
begin
  SkinData.Active := true;
end;

end.
