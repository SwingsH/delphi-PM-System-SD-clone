unit Const_Template;
(**************************************************************************
 * HTML �ҪO���;�, �t�Τ��� HTML �y�k�M�ҪO�Ҧb�o�̲���
 * @Author Swings Huang
 * @Version 2010/02/24 v1.0
 *************************************************************************)
interface

const
  cHTML_Body =
  '<html>'+
  '<head>'+
  '<meta http-equiv="Content-Type" content="text/html; charset=big5">'+
  '<style>'+
  'html, body { margin: 10; padding: 10; font-family: Tahoma; font-size: 12px; background-color:#FFFFFF;}'+
  '.noticelist img{ float:left;}' +
  '.noticelist span{ text-align: left; padding: 10px 3px 10px 3px; float:Left;}' +
  '.noticelist .timetag{ color:#362E2B; font-size:11px;}' +
  '.noticelist{padding-top:4px; padding-bottom:4px; border-bottom:#D1C0A5 1px solid}' +
  '.bulletinlist{padding-top:4px; padding-bottom:4px; border-bottom:#D1C0A5 1px solid}' +
  '</style>'+
  '</head>'+
  '<body>%s</body>'+
  '</html>';

  cHTML_NoticeTitle =
  '<center><b><font size="2" color="#333333">%s</font></b>�@<font color="#666666">%s</font></center> '+
  '<hr color="#C0C0C0" size="1" width="90%%" align="center"><class >';

  cHTML_NoticeList =
  '<div class="noticelist"><img src="template/image/icon_access_allow.gif" width="16" height="16"/>'+
  '<span> %s</span><span class="timetag">%s</span></div>' ;

  cHTML_NoticeList_Error =
  '<div class="noticelist"><img src="template/image/icon_access_disallow.gif" width="16" height="16"/>'+
  '<span> %s</span><span class="timetag">%s</span></div>' ;

  cHTML_NoticeList_Empty =
  '<div class="noticelist"><span><center> �S���ԲӸ��</center></span></div>' ;

  cHTML_BuleltinList =
  '<div class="bulletinlist"><img src="template/image/msnchat.gif" width="16" height="16"/>'+
  '<b>[%s] ��</b><font size="1" color="#333333">(%s)</font>�G %s</div>' ;

  cHTML_GridHint =
  '<html>'+
  '<head>'+
  '<meta http-equiv="Content-Type" content="text/html; charset=big5">'+
  '<style>'+
  'html{border:#000000 1px solid;}'+
  'body { border:#000000 1px solid; margin: 2; padding: 4; font-family: Tahoma; font-size: 11px; color:666666;background-color:#ffffff;}'+
  'span{ text-align: left; padding: 2px 2px 2px 2px; float:Left;} '+
  '.access_pass{ font-weight:bold;color:#00C400;}  '+
  '.access_deny{font-weight:bold;color:#FF0000;}  '+
  '</style>  '+
  '</head> '+
  '<body>   '+
  '<div><span>�̫�s��G%s</span></div> '+
  '<div><span>��쫬�A�G%s</span></div>   '+
  ' %s <!--�s���v��--> '+
  '</body> '+
  '</html>';

  cHTML_GridHint_AccessPass=
  '<div><span class="access_pass">�֦��s���v��</span></div> ';

  cHTML_GridHint_AccessDeny=
  '<div><span class="access_deny">�S���s���v��</span></div> ';
  
function Template_NoticeTitle( aHTMLString1, aHTMLString2: String): String;
function Template_NoticeList( aHTMLString, aTimeString: String; aError: Boolean): String;
function Template_NoticeListEmpty: String;
function Template_HTMLBody( aHTMLString: String): String;
function Template_BulletinList( aHTMLString1, aHTMLString2, aHTMLString3: String ): String;
function Template_GridHint(aUpdateTime:String;aGridType:String;aAccess:Boolean):String;

implementation
uses
  SysUtilS;

function Template_HTMLBody( aHTMLString: String): String;
begin
  Result:= Format(cHTML_Body, [aHTMLString] );
end;

function Template_NoticeTitle( aHTMLString1, aHTMLString2: String): String;
begin
  Result:= Format(cHTML_NoticeTitle, [aHTMLString1,aHTMLString2] );
end;

function Template_NoticeList( aHTMLString, aTimeString: String; aError: Boolean ): String;
begin
  if aError = False then
    Result:= Format(cHTML_NoticeList, [aHTMLString,aTimeString] )
  else
    Result:= Format(cHTML_NoticeList_Error, [aHTMLString,aTimeString] );
end;

function Template_NoticeListEmpty: String;
begin
  Result:= cHTML_NoticeList_Empty;
end;

function Template_BulletinList( aHTMLString1, aHTMLString2, aHTMLString3: String ): String;
begin
  Result:= Format(cHTML_BuleltinList, [aHTMLString1,aHTMLString2, aHTMLString3] );
end;

function Template_GridHint(aUpdateTime:String;aGridType:String;aAccess:Boolean):String;
begin
  if aAccess then
    result:= Format(cHTML_GridHint,[aUpdateTime,aGridType,cHTML_GridHint_AccessPass])
  else
    result:= Format(cHTML_GridHint,[aUpdateTime,aGridType,cHTML_GridHint_AccessDeny]);
end;

end.
