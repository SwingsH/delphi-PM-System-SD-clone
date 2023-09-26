{$I define.h}
unit StateCtrl;

interface

type
  //登入狀態
  TLoginResult = (Success, InvalidAccount, InvalidPassword, AlreadyOnline, LoginError);

  (**************************************************************************
   * 使用者資訊
   *************************************************************************)
  rUserInfo = packed record
    Account: String;       //帳號
    Password: String;      //密碼
    LoginTime: Cardinal;   //最新時間
    IP: String;            //
    ID: Integer;           //
    NickName: String;      //別稱
    Tel: Integer;          //分機
    Level: Integer;        //權限
  end;

  //存檔結構
  rSaveInfo = packed record
    Auto: Boolean;         //自動登入
    Account: String;       //帳號
    Password: String;      //密碼
  end;

  //登入助手
  TStateManage = class
  private
    mUserInfo: rUserInfo;
    mLogined: Boolean;
    mSaveInfo: rSaveInfo;
    mIsLoad: Boolean;
    // TableAccessAuthenticator // 表格存取權限管理器
  public
    mProjIdx: array of integer;  //gride comb跟tabld的索引連結

    constructor Create;
    destructor Destroy; override;
    procedure Update;

    function CheckLogin(aAccount, aPassword: String; out aID: Integer):  //檢查登入資訊
                        TLoginResult;
    procedure SetLoginState(aID: Integer; aLogined: Boolean);            //儲存登入狀態
    function GetClientIP: String;                                        //取得ip
    procedure SetUserInfo(aID: Integer);  //將資訊轉成自訂結構
    procedure SetShowUserInfo;            //將使用者資訊顯示在左側登入介面       
    procedure SetUserProj;                //將使用者專案設定到combo

    function CheckState: Boolean;         //檢查狀態
    procedure AutoLogin;                  //自動登入

    procedure SetIsAuto(aAuto: Boolean);  //設定下次是否自動登入 
    function Save(const aDir, aName: String): Boolean;  //存檔
    function Load(const aDir, aName: String): Boolean;  //讀檔

    //使用者資訊
    property Account: String read mUserInfo.Account;
    property Password: String read mUserInfo.Password;
    property LoginTime: Cardinal read mUserInfo.LoginTime write mUserInfo.LoginTime;
    property IP: String read mUserInfo.IP write mUserInfo.IP;
    property ID: Integer read mUserInfo.ID write mUserInfo.ID;
    property NickName: String read mUserInfo.NickName write mUserInfo.NickName;
    property TelNum: Integer read mUserInfo.Tel write mUserInfo.Tel;
    property Level: Integer read mUserInfo.Level write mUserInfo.Level; 

    property Logined: Boolean read mLogined write mLogined;

    property SaveAuto: Boolean read mSaveInfo.Auto write mSaveInfo.Auto;
  end;

var
  StateManage: TStateManage;

implementation

uses
  SQLConnecter, SysUtils, DBManager, WinSock, DoLogin, Windows, Main, Classes,
  NoticeManager, GridCtrl, Dialogs, Inifiles, TableControlPanel;

{ TStateManage }

procedure TStateManage.AutoLogin;
begin
  if not mSaveInfo.Auto then
    exit;

  //作假把資料偷塞
  try
    LoginForm.ACEdit.Text := mSaveInfo.Account;
    LoginForm.PWEdit.Text := mSaveInfo.Password;
  except
    exit;
  end;

  LoginForm.CheckAcPw;
end;

function TStateManage.CheckLogin(aAccount,
  aPassword: String; out aID:Integer): TLoginResult;
var
  vRSet, vRSet2: TRecordSet;
begin
  result := LoginError;
  aAccount := Trim(aAccount);
  aID := 0 ;
  
  vRSet := gDBManager.GetUser('user_account', 0, aAccount);  //取得帳戶資料

  if vRSet.RowNums = 0 then
  begin
    result := InvalidAccount;  //無效帳號
    exit; 
  end
  else
  if Trim(aPassword) <> vRSet.Row[0, 'user_password'] then
  begin
    result := InvalidPassword;  //無效密碼
    exit;
  end
  else
  begin
    aID := StrToIntDef(vRSet.Row[0, 'user_id'], -1);

    if aID = -1 then
      exit;

    vRSet2 := gDBManager.GetUserStatus(aID);

    if vRSet2.RowNums = 0 then  //首次登入
    begin
      result := Success;
      exit;
    end
    else
//    if StrToIntDef(vRSet.Row[0, 'user_logined'], -1) = 0 then  //已經登入中
//    begin
//      result := AlreadyOnline;
//      exit;
//    end;

    result := Success;
  end;
end;

function TStateManage.CheckState: Boolean;
begin
  result := False;

  {$ifdef Debug}
    //只在一般模式檢查
  {$else}

  if not StateManage.Logined then
  begin
    ShowMessage('請先登入');
    exit;
  end;
  {$endif}

  result := True;
end;


constructor TStateManage.Create;
begin
  mIsLoad := False;
end;

destructor TStateManage.Destroy;
begin

  inherited;
end;

function TStateManage.GetClientIP: String;
type
  TaPInAddr = array [0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array [0..63] of char;
  i: Integer;
  GInitData: TWSADATA;
begin
  Result := '';
  WSAStartup($101, GInitData);

  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(buffer);

  if phe = nil then
    exit;

  pptr := PaPInAddr(Phe^.h_addr_list);

  i := 0;

  while pptr^[i] <> nil do
  begin
    result := StrPas(inet_ntoa(pptr^[i]^));
    inc(i);
  end;

  WSACleanup;
end;

function TStateManage.Load(const aDir, aName: String): Boolean;
var
  vTmpFile: TIniFile;
begin
  result := False;

  if mIsLoad then
    exit;
  if not DirectoryExists(aDir) then
    exit;
  if not FileExists(aDir + aName) then
    exit;

  try
    vTmpFile := TIniFile.Create(aDir + aName);
    mSaveInfo.Auto := vTmpFile.ReadBool('AutoLogin', 'Auto', false);
    mSaveInfo.Account := vTmpFile.ReadString('AutoLogin', 'Account', '');
    mSaveInfo.Password := vTmpFile.ReadString('AutoLogin', 'Password', '');
  finally
    FreeAndNil(vTmpFile);
  end;

  result := True;
end;

function TStateManage.Save(const aDir, aName: String): Boolean;
var
  vTmpFile: TIniFile;
begin
  result := False;

  if not DirectoryExists(aDir) then
    mkdir(aDir);
//    exit;

  try
    vTmpFile := TIniFile.Create(aDir + aName);
    vTmpFile.WriteBool('AutoLogin', 'Auto', mSaveInfo.Auto);
    vTmpFile.WriteString('AutoLogin', 'Account', mSaveInfo.Account);
    vTmpFile.WriteString('AutoLogin', 'Password', mSaveInfo.Password);
  finally
    FreeAndNil(vTmpFile);
  end;

  result := True;
end;

procedure TStateManage.SetIsAuto(aAuto: Boolean);
begin
  StateManage.SaveAuto := aAuto;
  StateManage.Save((AppPath + cFilePath), cFileName);  //儲存設定
end;

procedure TStateManage.SetLoginState(aID: Integer; aLogined: Boolean);
var
  vRSet, vRSet2: TRecordSet;
  vQuery: String;
begin
  if aID <= 0 then
    exit;

  vRSet := gDBManager.GetUserStatus(aID);
  vRSet2 := gDBManager.GetUser(aID);

  if vRSet2.RowNums = 0 then  //無此使用者
    exit;

  mLogined := aLogined;

  if vRSet.RowNums = 0 then
  begin
    vQuery := gQGenerator.Insert('scs_user_status',
                                 ['user_id', 'user_logined', 'user_logined_ip'],
                                 [IntToStr(aID), BoolToStr(aLogined), GetClientIP],
                                 [0, 0, 1]);
  end
  else
  begin
    vQuery := gQGenerator.Update('scs_user_status',
                                 ['user_logined', 'user_logined_ip', 'user_logincheck_datetime'],
                                 [BoolToStr(aLogined), GetClientIP, 'CURRENT_TIMESTAMP()'],
                                 [0, 1, 0],
                                 format('user_id = %d', [aID]));
  end;

  gDBManager.SetUserStatus(vQuery);

  SetUserInfo(aID);  //將資訊轉成自訂結構
end;

procedure TStateManage.SetShowUserInfo;
begin
  MainForm.UserInfo.Lines.Add(format('IP位置:%s', [mUserInfo.IP]));
  MainForm.UserInfo.Lines.Add(format('用戶暱稱:%s', [mUserInfo.NickName]));
  MainForm.UserInfo.Lines.Add(format('用戶分機:%d', [mUserInfo.Tel]));
  gTableControlPanel.SetPrivatProList;
end;

procedure TStateManage.SetUserInfo(aID: Integer);
var
  vRSet: TRecordSet;
begin
  //一般用
  mUserInfo.Account := LoginForm.ACEdit.Text;
  mUserInfo.Password := LoginForm.PWEdit.Text;
  mUserInfo.LoginTime := GetTickCount;
  mUserInfo.IP := GetClientIP;
  mUserInfo.ID := aID;

  vRSet := gDBManager.GetUser('user_account', 0, mUserInfo.Account);
  mUserInfo.NickName := vRSet.Row[0, 'user_nickname'];
  mUserInfo.Tel := StrToIntDef(vRSet.Row[0, 'user_exnumber'], 0);

  //使用者權限
  {$ifdef Debug}
    mUserInfo.Level := 1;
  {$else}
  {$endif}

  //存檔用
  mSaveInfo.Account := mUserInfo.Account;
  mSaveInfo.Password := mUserInfo.Password;
  LoginForm.MyIniFile.DeleteKey('public','ID');
  LoginForm.MyIniFile.WriteString('public','ID',mUserInfo.Account);

  gNoticeHandler.SetActive ;                   // 登入後, 依照使用者, 設定即時訊息頁面
  gTableControlPanel.SetProjectList(aID);      // 設定下方專案列表
  SetShowUserInfo;                             // 將使用者資訊顯示在介面
end;

procedure TStateManage.SetUserProj;
var
  vRSet: TRecordSet;
  vStr: String;
  vID: Integer;
  i: Integer;
begin
  vRSet := gDBManager.GetUser_Project(mUserInfo.ID);  //取出使用者底下的專案

  SetLength(mProjIdx, vRSet.RowNums);

  for i := 0 to (vRSet.RowNums - 1) do  //將專案加入grid的combo
  begin
    vStr := vRSet.Row[i, 'project_name'];
    vID := StrToIntDef(vRSet.Row[i, 'project_id'], 0);
    mProjIdx[i] := vID;
    //MainForm.GridCombo.Items.Add(vStr);
  end;
end;

procedure TStateManage.Update;
begin

end;

end.
