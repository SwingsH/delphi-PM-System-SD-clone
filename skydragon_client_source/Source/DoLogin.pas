{$I define.h}
unit DoLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,IniFiles, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdAntiFreezeBase, IdAntiFreeze;

const
  cHost = 'http://192.168.38.119/fsy/';
  cPort = 80;

type
  TLoginForm = class(TForm)
    ACEdit: TLabeledEdit;
    PWEdit: TLabeledEdit;
    OKBtn: TButton;
    SDHTTP: TIdHTTP;
    IdAntiFreeze1: TIdAntiFreeze;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure PWEditKeyPress(Sender: TObject; var Key: Char);
    procedure ACEditKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    mMyIniFile: TIniFile;

    procedure InitialLabelWidth;
    procedure InitialSDHTTP;
    procedure CheckSkyDragonUpdate;
    procedure UpdateSkyDragron;
  public
    { Public declarations }
    procedure CheckAcPw;  //檢查使用者帳號跟密碼並做登入
    property MyIniFile: TIniFile read mMyIniFile;
  end;

var
  LoginForm: TLoginForm;
  AppPath: String;
  gDBIP   : String;

implementation

{$R *.dfm}

uses
  StateCtrl, Main, PubFun, ShellAPI,
  DBManager, SQLConnecter;

const
  cDef_W = 200;
  cDef_H = 300;
  cCap = '  登入介面';
{$ifdef Debug}
  cDefaultDBIP = '127.0.0.1';
{$else}
  cDefaultDBIP = '127.0.0.1';
{$endif}

procedure TLoginForm.CheckAcPw;
var
  vState: TLoginResult;
  vID : Integer;
begin
  vState := StateManage.CheckLogin(ACEdit.Text, PWEdit.Text, vID);  //檢查帳號跟密碼

  case vState of
    Success:
      begin
        StateManage.SetLoginState(vID, True);  //設定狀態
        CheckSkyDragonUpdate;
        MainForm.GridBtn5.Enabled := false;
        MainForm.Visible := true;
        Hide;
      end;
    InvalidAccount:
      ShowMessage('無效的帳號');
    InvalidPassword:
      ShowMessage('無效的密碼');
    AlreadyOnline:
      ShowMessage('此帳號已在線上');
    LoginError:
      ShowMessage('登入錯誤');
  else
    exit;
  end;
end;

procedure TLoginForm.FormCreate(Sender: TObject);
begin
  AppPath:=ExtractFilePath(Application.ExeName);       //取得執行檔路徑
  mMyIniFile := TIniFile.Create(AppPath + 'ID.ini');
  if not FileExists(AppPath + 'ID.ini') then
  begin
    mMyinifile.WriteString('public','ID','');
    mMyinifile.WriteString('public','DB','');
  end;
  ACEdit.Text:=mMyIniFile.ReadString('public','ID','');
  gDBIP:= mMyIniFile.ReadString('public','DB','');
  if gDBIP = '' then
    gDBIP := cDefaultDBIP; // 預設的 DBIP
  //form設定
  Caption := cCap;

  ClientWidth := cDef_W;
  ClientHeight := cDef_H;

  //置中
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;

  if Left < 0 then
    Left := 0;
  if Top < 0 then
    Top := 0;

  BorderStyle := bsSingle;

  InitialLabelWidth;
  InitialSDHTTP;
end;

procedure TLoginForm.FormDestroy(Sender: TObject);
begin
  //
  //MainForm.SkinData.EnableSkin(false);
  MainForm.SkinData.Active := false;
end;

procedure TLoginForm.InitialLabelWidth;
begin
  PWEdit.EditLabel.Width := Length(PWEdit.EditLabel.Caption) * PWEdit.EditLabel.Font.Size;
  ACEdit.EditLabel.Width := Length(ACEdit.EditLabel.Caption) * ACEdit.EditLabel.Font.Size;
end;

procedure TLoginForm.OKBtnClick(Sender: TObject);
begin
  CheckAcPw;  //檢查使用者帳號跟密碼並做登入
end;

procedure TLoginForm.PWEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
    CheckAcPw;

  if Ord(Key) = VK_ESCAPE then
  begin
    if MessageDlg('是否確定要登出？', mtConfirmation, mbOKCancel, 0) = mrOk then
      Application.Terminate;
  end;
end;

procedure TLoginForm.ACEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_ESCAPE then
  begin
    if MessageDlg('是否確定要登出？', mtConfirmation, mbOKCancel, 0) = mrOk then
      Application.Terminate;
  end;
end;

procedure TLoginForm.InitialSDHTTP;
begin
  SDHTTP.Host := cHost;
  SDHTTP.Port := cPort;

  SDHTTP.Request.ContentRangeStart := 0;
  SDHTTP.Request.ContentRangeEnd := 0;
end;

procedure TLoginForm.UpdateSkyDragron;
var
  vSkyDragon: TMemoryStream;
  vVerSet: TRecordSet;
begin
  MainForm.DisableSkin;

  vSkyDragon := TMemoryStream.Create;
  vVerSet := gDBManager.GetVersion('');

  SDHTTP.Get(cHost + 'ExeChanger.exe', vSkyDragon);

  if vSkyDragon.Size = 374784 then
  begin
    WriteShareFile(AppPath + 'ExeChanger.exe', vSkyDragon.Memory^, vSkyDragon.Size);
    FreeAndNil(vSkyDragon);
  end;

  vSkyDragon := TMemoryStream.Create;
  SDHTTP.Get(cHost + 'Path.ini', vSkyDragon);

  if vSkyDragon.Size = 92 then
  begin
    WriteShareFile(AppPath + 'Path.ini', vSkyDragon.Memory^, vSkyDragon.Size);
    FreeAndNil(vSkyDragon);
  end;

  vSkyDragon := TMemoryStream.Create;
  SDHTTP.Get(cHost + 'Login.exe', vSkyDragon);

  if vSkyDragon.Size = StrToInt(vVerSet.Row[0, 'version_size']) then
  begin
    WriteShareFile(AppPath + 'Login.exe', vSkyDragon.Memory^, vSkyDragon.Size);
    FreeAndNil(vSkyDragon);
    ShellExecute(Handle, 'open', 'ExeChanger.exe', nil, nil, SW_SHOWNORMAL);
    Halt;
  end;
end;

procedure TLoginForm.CheckSkyDragonUpdate;
var
  vRSet: TRecordSet;
begin
  exit;
  vRSet := gDBManager.GetVersion('');

  if vRSet.Row[0, 'version_current'] <> cVersion then
  begin
    LoginForm.Caption := '天空龍檢查更新中...';
    UpdateSkyDragron;
  end;
end;

procedure TLoginForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //MainForm.SkinData.EnableSkin(false);
  MainForm.SkinData.Active := false;
end;

end.
