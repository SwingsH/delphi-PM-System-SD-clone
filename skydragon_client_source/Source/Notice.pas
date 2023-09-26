unit Notice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Htmlview;

type
  TNoticeForm = class(TForm)
    mHTMLViewer: THTMLViewer;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NoticeForm: TNoticeForm;

implementation

const
  cCaption = '即時訊息細項';

{$R *.dfm}
  
procedure TNoticeForm.FormCreate(Sender: TObject);
begin
  Self.Caption := cCaption;
end;

end.
