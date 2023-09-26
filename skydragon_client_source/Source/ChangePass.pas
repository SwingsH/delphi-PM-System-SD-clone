unit ChangePass;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask;

type
  TChangePassForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    OldPass: TEdit;
    NewPass: TEdit;
    CheckNewPass: TEdit;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChangePassForm: TChangePassForm;

implementation

uses
  SQLConnecter,DBManager, DoLogin;

{$R *.dfm}

procedure TChangePassForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TChangePassForm.Button1Click(Sender: TObject);
var
  vRSet: TRecordSet;
begin
  vRSet := gDBManager.GetUser('user_account', 0, Trim(LoginForm.MyIniFile.ReadString('public','ID','')));  //取得帳戶資料
  if Trim(OldPass.Text) = vRSet.Row[0, 'user_password'] then
  begin
    if NewPass.Text<>CheckNewPass.Text then
      ShowMessage('新密碼確認錯誤')
    else
    begin
      if gDBManager.SetPass(StrToIntDef(vRSet.Row[0, 'user_id'], -1),NewPass.Text)=-1 then
        ShowMessage('修改密碼失敗！')
      else
      begin
        ShowMessage('密碼修改成功！');
        Close;
      end;
    end;
  end
  else
    ShowMessage('舊密碼錯誤');
end;

procedure TChangePassForm.FormShow(Sender: TObject);
begin
  OldPass.SetFocus;
end;

end.
