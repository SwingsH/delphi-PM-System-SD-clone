{$I define.h}
unit StateCtrl;

interface

type
  //�n�J���A
  TLoginResult = (Success, InvalidAccount, InvalidPassword, AlreadyOnline, LoginError);

  (**************************************************************************
   * �ϥΪ̸�T
   *************************************************************************)
  rUserInfo = packed record
    Account: String;       //�b��
    Password: String;      //�K�X
    LoginTime: Cardinal;   //�̷s�ɶ�
    IP: String;            //
    ID: Integer;           //
    NickName: String;      //�O��
    Tel: Integer;          //����
    Level: Integer;        //�v��
  end;

  //�s�ɵ��c
  rSaveInfo = packed record
    Auto: Boolean;         //�۰ʵn�J
    Account: String;       //�b��
    Password: String;      //�K�X
  end;

  //�n�J�U��
  TStateManage = class
  private
    mUserInfo: rUserInfo;
    mLogined: Boolean;
    mSaveInfo: rSaveInfo;
    mIsLoad: Boolean;
    // TableAccessAuthenticator // ���s���v���޲z��
  public
    mProjIdx: array of integer;  //gride comb��tabld�����޳s��

    constructor Create;
    destructor Destroy; override;
    procedure Update;

    function CheckLogin(aAccount, aPassword: String; out aID: Integer):  //�ˬd�n�J��T
                        TLoginResult;
    procedure SetLoginState(aID: Integer; aLogined: Boolean);            //�x�s�n�J���A
    function GetClientIP: String;                                        //���oip
    procedure SetUserInfo(aID: Integer);  //�N��T�ন�ۭq���c
    procedure SetShowUserInfo;            //�N�ϥΪ̸�T��ܦb�����n�J����       
    procedure SetUserProj;                //�N�ϥΪ̱M�׳]�w��combo

    function CheckState: Boolean;         //�ˬd���A
    procedure AutoLogin;                  //�۰ʵn�J

    procedure SetIsAuto(aAuto: Boolean);  //�]�w�U���O�_�۰ʵn�J 
    function Save(const aDir, aName: String): Boolean;  //�s��
    function Load(const aDir, aName: String): Boolean;  //Ū��

    //�ϥΪ̸�T
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

  //�@�����ư���
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
  
  vRSet := gDBManager.GetUser('user_account', 0, aAccount);  //���o�b����

  if vRSet.RowNums = 0 then
  begin
    result := InvalidAccount;  //�L�ıb��
    exit; 
  end
  else
  if Trim(aPassword) <> vRSet.Row[0, 'user_password'] then
  begin
    result := InvalidPassword;  //�L�ıK�X
    exit;
  end
  else
  begin
    aID := StrToIntDef(vRSet.Row[0, 'user_id'], -1);

    if aID = -1 then
      exit;

    vRSet2 := gDBManager.GetUserStatus(aID);

    if vRSet2.RowNums = 0 then  //�����n�J
    begin
      result := Success;
      exit;
    end
    else
//    if StrToIntDef(vRSet.Row[0, 'user_logined'], -1) = 0 then  //�w�g�n�J��
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
    //�u�b�@��Ҧ��ˬd
  {$else}

  if not StateManage.Logined then
  begin
    ShowMessage('�Х��n�J');
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
  StateManage.Save((AppPath + cFilePath), cFileName);  //�x�s�]�w
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

  if vRSet2.RowNums = 0 then  //�L���ϥΪ�
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

  SetUserInfo(aID);  //�N��T�ন�ۭq���c
end;

procedure TStateManage.SetShowUserInfo;
begin
  MainForm.UserInfo.Lines.Add(format('IP��m:%s', [mUserInfo.IP]));
  MainForm.UserInfo.Lines.Add(format('�Τ�ʺ�:%s', [mUserInfo.NickName]));
  MainForm.UserInfo.Lines.Add(format('�Τ����:%d', [mUserInfo.Tel]));
  gTableControlPanel.SetPrivatProList;
end;

procedure TStateManage.SetUserInfo(aID: Integer);
var
  vRSet: TRecordSet;
begin
  //�@���
  mUserInfo.Account := LoginForm.ACEdit.Text;
  mUserInfo.Password := LoginForm.PWEdit.Text;
  mUserInfo.LoginTime := GetTickCount;
  mUserInfo.IP := GetClientIP;
  mUserInfo.ID := aID;

  vRSet := gDBManager.GetUser('user_account', 0, mUserInfo.Account);
  mUserInfo.NickName := vRSet.Row[0, 'user_nickname'];
  mUserInfo.Tel := StrToIntDef(vRSet.Row[0, 'user_exnumber'], 0);

  //�ϥΪ��v��
  {$ifdef Debug}
    mUserInfo.Level := 1;
  {$else}
  {$endif}

  //�s�ɥ�
  mSaveInfo.Account := mUserInfo.Account;
  mSaveInfo.Password := mUserInfo.Password;
  LoginForm.MyIniFile.DeleteKey('public','ID');
  LoginForm.MyIniFile.WriteString('public','ID',mUserInfo.Account);

  gNoticeHandler.SetActive ;                   // �n�J��, �̷ӨϥΪ�, �]�w�Y�ɰT������
  gTableControlPanel.SetProjectList(aID);      // �]�w�U��M�צC��
  SetShowUserInfo;                             // �N�ϥΪ̸�T��ܦb����
end;

procedure TStateManage.SetUserProj;
var
  vRSet: TRecordSet;
  vStr: String;
  vID: Integer;
  i: Integer;
begin
  vRSet := gDBManager.GetUser_Project(mUserInfo.ID);  //���X�ϥΪ̩��U���M��

  SetLength(mProjIdx, vRSet.RowNums);

  for i := 0 to (vRSet.RowNums - 1) do  //�N�M�ץ[�Jgrid��combo
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
