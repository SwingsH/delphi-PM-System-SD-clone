{$I define.h}
unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FMTBcd, DBXpress, WinSkinStore, WinSkinData, DB, SqlExpr,
  ExtCtrls, ComCtrls, Grids, StdCtrls, Htmlview, Menus, IniFiles, TableModel;

const
  cFilePath = 'Data\';          //設定檔路徑
  cFileName = 'LoginInfo.dat';  //設定檔檔名
  cDef_W = 800;
  cDef_H = 600;
  cVersion = '06.18';
  cCaption = '  天空龍 Online(Ver.%s)';
  {$ifdef Debug}
  cUpdateTime = 2 * 1000;  //更新時間
  {$else}
  cUpdateTime = 2 * 1000;  //更新時間
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
    mSkinEnable: Boolean;    /// 因應 skin path 改名, 要判斷無skn資料夾的情況
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

  //form設定
  Caption := format(cCaption, [cVersion]);

  //置中
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;
  if Left < 0 then
    Left := 0;
  if Top < 0 then
    Top := 0;

  //連線啟動
  gDBManager := TDBManager.Create;
  gQGenerator := TQueryGenerator.Create;
  // 一般表格處理器啟動
  gTableHandler := TTableHandler.Create;
  // 合併行總表格處理器啟動
  gMergeTableHandler := TMergeTableHandler.Create;
  // 表單助手
  GridManage := TGridManage.Create(Grid);
  // 登入助手
  StateManage := TStateManage.Create;
  // 即時訊息助手
  gNoticeHandler  := TNoticeHandler.Create(NoticeListBox, mNoticeHTMLViewer);
  // 公告助手
  gBulletinHandler:= TBulletinHandler.Create(mBulletinHTMLViewer);
  // 表格控制面板助手
  gTableControlPanel:= TTableControlPanel.Create(mListBox_ProjList,mListBox_MrgTableList,mListBox_TableList); // 動態更動 專案/總合表格/子表格 列表的 控制器
  // 表格編輯器(新增修改編輯器)
  gTableEditor:= TTableEditor.Create;
  // Excel助手
  XlsManage := TXlsManage.Create;
  // 版本訊息助手
  gVersionMemoHandler:= TVersionMemoHandler.Create(mAboutHTMLViewer);
  
  // Skin設定
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

  //表格元件StringGrid設定
  Grid.Options := [ goFixedVertLine,
                    goFixedHorzLine,
                    goVertLine,
                    goHorzLine,
                    //goRangeSelect,
                    goDrawFocusSelected,
                    goRowSizing,         //滑鼠可改變行寬
                    goColSizing,         //滑鼠可改變列高
                    goRowMoving,
                    goColMoving,
                    //goEditing,         //直接編輯
                    goTabs,
                    //goRowSelect,       //選取整列, 反藍Focus 置前
                    goThumbTracking ];    //捲軸動時跟著動

  //即時訊息搜索物件設定
  mNoticePicker_EndTime.DateTime:= Now;
  mNoticePicker_StartTime.ShowCheckbox:= True;
  mNoticePicker_EndTime.ShowCheckbox:= True;
  mNoticePicker_StartTime.Checked:= False;     // 因為有Date初始值, 需連設兩次 False (TimePicker的缺陷)
  mNoticePicker_StartTime.Checked:= False;
  mNoticePicker_EndTime.Checked:= False;       // 因為有Date初始值, 需連設兩次 False (TimePicker的缺陷)
  mNoticePicker_EndTime.Checked:= False;
  mNoticeHTMLViewer.ScrollBars:= ssVertical;

  //縮放屬性設置
  //PageControl.Align        := alCustom;                           // 全頁面
  PageControl.Anchors      := [akLeft, akTop, akRight, akBottom];
  //PrivateTableList.Align   := alCustom;
//  PrivateTableList.Anchors := [akLeft, akTop, akBottom];
  //UserInfo.Align           := alCustom;
  UserInfo.Anchors         := [akLeft, akTop];
  //Grid.Align               := alCustom;                           // 各式表單
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
  //BulletinClearBtn.Align   := alCustom;                           // 公告
  BulletinClearBtn.Anchors := [akRight, akBottom];
  //BulletinSendBtn.Align    := alCustom;
  BulletinSendBtn.Anchors  := [akRight, akBottom];
  //Bulletin_Edit.Align      := alCustom;
  Bulletin_Edit.Anchors    := [akLeft, akRight, akBottom];
  //mLabelNoticeTitle.Align  := alCustom;                           // 即時訊息
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
    ShowMessage('公告權限不足');
    Exit;
  end;

  if Trim(Bulletin_Edit.Text) = '' then
  begin
    ShowMessage('請輸入公告');
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

  if GetTickCount < (StateManage.LoginTime + cUpdateTime) then  //小於更新時間
    exit;

  StateManage.LoginTime := GetTickCount;

  StateManage.Update;

  GridManage.Update;  //debug期間不自動更新好方便做測試
end;

procedure TMainForm.GridBtn4Click(Sender: TObject);
begin
  //XlsManage.NewExcel;  //創建一個新的excel
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
  if StateManage.ID = 0 then              // 未登入
  begin
    StateManage.NickName := '開發人員';
    StateManage.ID := 1;
  end;  
{$endif}

  gDBManager.Init; //TODO: 會執行多次
  gDBManager.TestRun;

  //登入讀取設定檔
  if not StateManage.Logined then
  begin
    StateManage.Load((AppPath + cFilePath), cFileName);
    StateManage.AutoLogin;  //檢查自動登入
  end;

  // if GridManage.Table = nil then
  if GridManage.TableManager.CurrentTableID <> 0 then //表示有開啟表單, S.H Mod:
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

  Grid.MouseToCell(X, Y, vCol, vRow);  //取得滑鼠所在欄列
  if (vCol<>-1)and(vRow<>-1)then
  begin
    mGridCol := vCol;
    mGridRow := vRow;
  end;    

  if Button = mbLeft then  //左鍵
  begin
    //左鍵目前為編輯功能, 接在GridSelectCell裡面
    GridManage.LockCols := mGridCol;  //設定被鎖定的欄位數目為mGridCol(在SetmLockCols內判斷)
  end
  else
  if Button = mbRight then  //右鍵
  begin
  end;

  // 設置 falg 讓 Grid上的Search用 combo 重新設定 size
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
    vStr := '第[%s]欄,第[%s]列,欄位內容:[%s]';

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
    vStr := '第[%s]欄,第[%s]列,欄位內容:[%s]';

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
  if GridManage.TableManager.CurrentMrgTableID = 0 then   // 沒有作用任何表格
    exit;

  gTableEditor.TriggerShow(GridManage.TableManager.CurrentMrgTable.Column);  // 新增欄位一率使用總表 MrgTable 資料, 一次填入多個
  ///gTableEditor.TriggerShow(GridManage.TableManager.CurrentTable.Column); // 子表資料的 編輯視窗
end;

procedure TMainForm.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  vRect:TRect;
  vComboBox: TComboBox;
  i:Integer;
  vList:TStringList;
begin
  if (ACol >= 1) and (ARow >= 1) then  //將鎖定的格子顏色設定為跟其他未鎖定的顏色相同
  begin
    if gdFixed in State then
    begin
      Grid.Canvas.Brush.Color := Grid.Color;
      Grid.Canvas.FillRect(Rect);
      Grid.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, Grid.Cells[ACol, ARow]);
    end;
  end;

  ///== 以下為搜索用 下拉式選單
  if GridManage.TableManager.CurrentTableID=0 then
    exit;

  if (aRow=(cFirstRowCount-1)) and  // 選項專用列
     (GridManage.TableManager.CurrentTable.Column.Data[aCol-1].ColumnType='selectbox') then  // 欄位型態為下拉式
  begin
    if GridManage.GridComboManage.Exist(aCol, aRow)=false then   // 是否已建立　？應映tick作判斷
    begin
      vComboBox:= GridManage.GridComboManage.RegisterItem(aCol, aRow);
      vList:= gTableHandler.StringToSelectList(GridManage.TableManager.CurrentTable.Column.Data[aCol-1].TypeSet);
      for i:=0 to vList.Count-1 do
        vComboBox.Items.Add(vList[i]);

      //改變 X,Y,W,H  
      vRect := TStringGrid(Sender).CellRect(ACOL,AROW);
      vComboBox.Width := vRect.Right-vRect.Left;
      vComboBox.Height:= vRect.Bottom + vComboBox.Items.Count*15;
      vComboBox.Left  := vRect.Left;
      vComboBox.Top   := vRect.Top;
    end
    else
    begin
      vComboBox:= GridManage.GridComboManage.ItemS[aCol, aRow];

      if GridManage.GridComboManage.ItemChanged[aCol, aRow] then    // 判斷是否要改變 X,Y,W,H
      begin
        vRect := TStringGrid(Sender).CellRect(ACOL,AROW);
        vComboBox.Width := vRect.Right-vRect.Left;
        vComboBox.Height:= vRect.Bottom + vComboBox.Items.Count*15;
        vComboBox.Left  := vRect.Left;
        vComboBox.Top   := vRect.Top;

        //if GridManage.GridComboManage.IsLastItem(aCol, aRow) then  //判斷註冊的最後一個 combobox = 全部更新完畢, 改變 flag
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
  XlsManage.NewExcel;  //創建一個新的excel
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
  vTempW:= abs(vTempW - PageControl.Left); // 舊 X - 新 X = 移動距離
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
  vTempW:= abs(PageControl.Left - vTempW); // 舊 X - 新 X = 移動距離
  PageControl.Width:= PageControl.Width - vTempW;
  //MainForm.Width:=MainForm.Width+(Panel_UserInfo.Width-15);
end;

// 更新記錄
procedure TMainForm.N6Click(Sender: TObject);
begin
  PageControl.ActivePage:=TabSheet5;
end;

procedure TMainForm.GridDblClick(Sender: TObject);
var
  vLabel: TLabel;
  vLen, i: Integer;
begin
  if mGridRow < 0 then    // 點到邊緣的灰色欄位 or 沒點到任何欄位
    exit;
  if mGridCol <= 0 then
    exit;
  if gTableControlPanel.TableID = 0 then  //只有子表格有作用,  現在沒有作用中[子表格], 即使點到欄位也無效
    exit;

  if mGridRow = 0 then  //雙擊滑鼠會自動將欄位寬度設到最適大小
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
  AddSysMessage('雙擊左鍵 or Enter=編輯, Shift+單擊左鍵=搜索, Esc=取消搜索, Delete=刪除');
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
  if gTableControlPanel.TableID = 0 then  // 只有子表格有作用, 現在沒有作用中[子表格], 即使點到欄位也無效
    exit;

  case Key of
    VK_RETURN:GridManage.TriggerGridEdit(mGridCol, mGridRow); //Enter
    VK_ESCAPE:GridManage.TriggerGridCancelSearch;             //Esc
    VK_Delete:GridManage.TriggerGridDelete(mGridCol,mGridRow);//Delete
  end;
end;

procedure TMainForm.mPOPMenu_SearchClick(Sender: TObject);
begin
  GridManage.SelectNeed(mGridCol, mGridRow);  //依條件篩選
end;

procedure TMainForm.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  vGRect:TGridRect;
  vCol, vRow: Integer;
begin
  if gTableControlPanel.TableID = 0 then  // 只有子表格有作用, 現在沒有作用中[子表格], 即使點到欄位也無效
    exit;

  Grid.MouseToCell(X, Y, vCol, vRow);  //取得滑鼠所在欄列
  if (vCol<>-1)and(vRow<>-1)then
  begin
    mGridCol := vCol;
    mGridRow := vRow;
  end;
  
  if Button = mbLeft then  //左鍵
  begin
    if ssShift in Shift then
      GridManage.SelectNeed(mGridCol, mGridRow);  //依條件篩選
  end
  else
  if Button = mbRight then  //右鍵
  begin
    vGRect.Left:=mGridCol;
    vGRect.Top:=mGridRow;
    vGRect.Right:=mGridCol;
    vGRect.Bottom:=mGridRow;
    Grid.Selection:=vGRect;   // 注意!設定 Grid 選取範圍, TODO: 移往別處統一設置
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

  gTableEditor.TriggerShow(GridManage.TableManager.CurrentMrgTable.Column);  // 新增欄位一率使用總表 MrgTable 資料, 一次填入多個
  /// gTableEditor.TriggerShow(GridManage.TableManager.CurrentTable.Column); // 子表資料的 編輯視窗
  (** 舊版編輯視窗
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
