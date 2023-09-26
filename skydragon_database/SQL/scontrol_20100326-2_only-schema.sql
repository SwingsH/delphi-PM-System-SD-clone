-- phpMyAdmin SQL Dump
-- version 2.10.3
-- http://www.phpmyadmin.net
-- 
-- 主機: localhost
-- 建立日期: Mar 26, 2010, 01:45 PM
-- 伺服器版本: 5.0.51
-- PHP 版本: 5.2.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

-- 
-- 資料庫: `scontrol`
-- 

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_bulletin`
-- 

CREATE TABLE `scs_bulletin` (
  `bulletin_id` int(11) NOT NULL auto_increment COMMENT '公告ID',
  `user_id` int(6) NOT NULL COMMENT '使用者ID',
  `organize_id` int(11) NOT NULL COMMENT '組織ID',
  `project_id` int(11) NOT NULL COMMENT '專案ID',
  `bulletin_type` tinyint(2) NOT NULL COMMENT '公告種類',
  `bulletin_text` mediumtext NOT NULL COMMENT '公告內容',
  `create_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT '建立時間',
  PRIMARY KEY  (`bulletin_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 ROW_FORMAT=COMPRESSED COMMENT='各類公告' AUTO_INCREMENT=21 ;

-- 
-- 資料表格式： `scs_column`
-- 

CREATE TABLE `scs_column` (
  `table_id` int(11) unsigned NOT NULL COMMENT '表格編號',
  `column_id` int(11) unsigned NOT NULL COMMENT '欄位編號',
  `column_name` varchar(128) NOT NULL COMMENT '欄位名稱',
  `column_description` text NOT NULL COMMENT '欄位描述 (非必要)',
  `column_create_user_id` int(6) unsigned NOT NULL COMMENT '表格建立者ID',
  `column_create_time` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT '表格建立時間',
  `column_priority` int(4) unsigned NOT NULL COMMENT '存取最低權限-需查詢使用者在專案的權利等級TODO\0olumn''\r\n\0mn''\r\n\0_co\0',
  `column_type` enum('number','textfield','textarea','date','checkbox','radiobox','selectbox','function') NOT NULL default 'number' COMMENT '數字.文字欄位.文字區.日期.checkbox.radiobox.selectbox',
  `column_typeset` text COMMENT 'column_type 的詳細設定值,selectbox, radio_box 等才用的到',
  `column_width` int(11) unsigned NOT NULL COMMENT '資料欄位的寬',
  `column_height` int(11) unsigned NOT NULL COMMENT '資料欄位的高',
  PRIMARY KEY  (`table_id`,`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=big5 ROW_FORMAT=COMPACT COMMENT='表格的欄位設定';

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_columnvalue`
-- 

CREATE TABLE `scs_columnvalue` (
  `table_id` int(11) unsigned NOT NULL COMMENT '表格ID',
  `column_id` int(11) unsigned NOT NULL COMMENT '欄位ID',
  `column_row_id` int(11) unsigned NOT NULL COMMENT '欄位列ID-表示為第幾列資料',
  `value` varchar(512) NOT NULL COMMENT '欄位內容-非Text專用。可null節省空間',
  `datetime` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`table_id`,`column_id`,`column_row_id`)
) ENGINE=InnoDB DEFAULT CHARSET=big5 ROW_FORMAT=COMPACT COMMENT='表格的欄位值 & 合併表格的欄位值';

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_department`
-- 

CREATE TABLE `scs_department` (
  `department_id` int(4) unsigned NOT NULL auto_increment COMMENT '部門ID',
  `department_name` varchar(64) NOT NULL COMMENT '部門名稱',
  `department_description` text NOT NULL COMMENT '部門描述',
  PRIMARY KEY  (`department_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 COMMENT='部門' AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_grade_level`
-- 

CREATE TABLE `scs_grade_level` (
  `gradelevel_id` int(4) unsigned NOT NULL auto_increment COMMENT '職等ID',
  `gradelevel_name` varchar(64) NOT NULL COMMENT '職等名稱',
  `gradelevel_priority` int(4) unsigned NOT NULL COMMENT '職等的優先權限',
  `gradelevel_description` text NOT NULL COMMENT '職等描述',
  PRIMARY KEY  (`gradelevel_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 COMMENT='職等' AUTO_INCREMENT=7 ;

-- 
-- 列出以下資料庫的數據： `scs_grade_level`
-- 

INSERT INTO `scs_grade_level` VALUES (1, '組員', 6, '最低階的賤民');
INSERT INTO `scs_grade_level` VALUES (2, '副組長', 5, '很厲害');
INSERT INTO `scs_grade_level` VALUES (3, '組長', 4, '很大..');
INSERT INTO `scs_grade_level` VALUES (4, '副課長', 3, '副課長了耶!!');
INSERT INTO `scs_grade_level` VALUES (5, '課長', 2, '');
INSERT INTO `scs_grade_level` VALUES (6, '副理', 1, '');

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_mergecolumn`
-- 

CREATE TABLE `scs_mergecolumn` (
  `mergetable_id` int(11) unsigned NOT NULL COMMENT '合併的母表格ID PK',
  `mergecolumn_id` int(11) unsigned NOT NULL COMMENT '合併的母欄位ID PK',
  `table_id` int(11) unsigned NOT NULL COMMENT '來源的子表格ID PK',
  `column_id` int(11) unsigned NOT NULL COMMENT '來源的子欄位ID',
  `mergecolumn_create_user_id` int(6) unsigned NOT NULL COMMENT '合併表格建立者ID',
  `mergecolumn_create_time` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT '合併表格建立時間',
  `mergecolumn_position_id` int(4) unsigned NOT NULL COMMENT '可存取的職務身份 ID - mergecolumn_id 同, 職務 ID 亦同..違反 2NF..',
  `mergecolumn_priority` int(4) unsigned NOT NULL COMMENT '存取最低權限-需查詢使用者在專案的權利等級TODO',
  `mergecolumn_type` enum('number','textfield','textarea','date','checkbox','radiobox','selectbox','function') NOT NULL,
  `mergecolumn_typeset` text NOT NULL,
  PRIMARY KEY  (`mergetable_id`,`mergecolumn_id`,`table_id`,`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=big5 ROW_FORMAT=COMPACT COMMENT='合併表格的欄位設定, 許多資料省略, 是因為可從第一個找到的子表格中取得';

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_mergetable`
-- 

CREATE TABLE `scs_mergetable` (
  `mergetable_id` int(11) NOT NULL auto_increment COMMENT '-合併表格ID',
  `mergetable_template_id` int(6) unsigned NOT NULL,
  `mergetable_name` varchar(256) NOT NULL COMMENT '-合併表格名稱',
  `mergetable_description` text NOT NULL COMMENT '-合併表格說明',
  `mergetable_create_user_id` int(6) NOT NULL COMMENT '-建立合併表格的使用者ID',
  `mergetable_create_organize_id` int(11) NOT NULL COMMENT '-合併表格所屬的組織(防止人事調動,所屬以組織為主)',
  `mergetable_create_project_id` int(11) NOT NULL COMMENT '-合併表格所對應的專案',
  `mergetable_create_time` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '-合併表格建立時間',
  `mergetable_expire_time` timestamp NOT NULL default '0000-00-00 00:00:00' COMMENT '-合併表格過期時間',
  `mergetable_update_time` timestamp NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`mergetable_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 ROW_FORMAT=COMPACT COMMENT='合併多個一般表格的總和表' AUTO_INCREMENT=11 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_organize`
-- 

CREATE TABLE `scs_organize` (
  `organize_id` int(11) unsigned NOT NULL auto_increment COMMENT '組織編號',
  `organize_name` varchar(128) NOT NULL COMMENT '組織名稱',
  `organize_description` text NOT NULL COMMENT '組織介紹',
  `organize_leader_user_id` int(6) unsigned NOT NULL COMMENT '單位主管ID',
  `organize_parent_id` int(11) unsigned NOT NULL COMMENT '所屬組織編號[體制]',
  `organize_nodecache` text NOT NULL COMMENT '附屬組織編號群-快取',
  PRIMARY KEY  (`organize_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 COMMENT='公司組織' AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_position`
-- 

CREATE TABLE `scs_position` (
  `position_id` int(4) unsigned NOT NULL auto_increment COMMENT '職務 ID',
  `position_name` varchar(20) NOT NULL COMMENT '職務名稱',
  PRIMARY KEY  (`position_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 COMMENT='職務 - 工作內容' AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_project`
-- 

CREATE TABLE `scs_project` (
  `project_id` int(4) unsigned NOT NULL auto_increment COMMENT '專案 ID',
  `project_leader_user_id` int(6) unsigned NOT NULL COMMENT '專案負責人使用者 ID',
  `project_name` varchar(64) NOT NULL COMMENT '專案名稱',
  `project_description` text NOT NULL COMMENT '專案描述',
  PRIMARY KEY  (`project_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 COMMENT='遊戲專案' AUTO_INCREMENT=7 ;


-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_project_member`
-- 

CREATE TABLE `scs_project_member` (
  `project_id` int(4) unsigned NOT NULL COMMENT '專案 ID PK',
  `user_id` int(6) unsigned NOT NULL COMMENT '使用者 ID PK',
  `projectmemeber_priority` int(4) unsigned NOT NULL COMMENT '專案使用者的優先權限',
  `projectunit_id` int(4) unsigned NOT NULL COMMENT '專案內的組別單位 ID FK',
  `projectunit_jointime` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT '專案使用者的加入日期',
  PRIMARY KEY  (`project_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=big5 COMMENT='專案成員';

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_project_unit`
-- 

CREATE TABLE `scs_project_unit` (
  `projectunit_id` int(4) unsigned NOT NULL auto_increment COMMENT '專案分組單位 ID PK',
  `projectunit_name` varchar(128) NOT NULL COMMENT '專案分組單位名稱',
  PRIMARY KEY  (`projectunit_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 COMMENT='專案分組單位' AUTO_INCREMENT=4 ;

-- 
-- 列出以下資料庫的數據： `scs_project_unit`
-- 

INSERT INTO `scs_project_unit` VALUES (1, '應用開發組');
INSERT INTO `scs_project_unit` VALUES (2, '引擎研發組');
INSERT INTO `scs_project_unit` VALUES (3, '活動社群組');

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_table`
-- 

CREATE TABLE `scs_table` (
  `table_id` int(11) unsigned NOT NULL auto_increment COMMENT '表格ID',
  `table_template_id` int(6) unsigned NOT NULL,
  `table_name` varchar(256) character set big5 NOT NULL COMMENT '表格名稱',
  `table_description` text character set big5 NOT NULL COMMENT '表格說明',
  `table_create_user_id` int(6) unsigned NOT NULL COMMENT '建立表格的使用者ID',
  `table_create_organize_id` int(11) unsigned NOT NULL COMMENT '表格所屬的組織(防止人事調動,所屬以組織為主)',
  `table_create_project_id` int(11) unsigned NOT NULL COMMENT '表格所對應的專案',
  `table_create_time` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '表格建立時間',
  `table_expire_time` timestamp NOT NULL default '0000-00-00 00:00:00' COMMENT '表格過期時間',
  `table_update_time` timestamp NOT NULL default '0000-00-00 00:00:00' COMMENT '表格最後更新時間.',
  PRIMARY KEY  (`table_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=COMPACT COMMENT='資料表Excel原型' AUTO_INCREMENT=25 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_tablelog_list`
-- 

CREATE TABLE `scs_tablelog_list` (
  `tablelog_list_id` int(11) NOT NULL auto_increment COMMENT '日誌列表 ID PK',
  `tablelog_title_id` int(11) unsigned NOT NULL COMMENT '表格日誌 - 標題ID FK',
  `tablelog_list_message` text NOT NULL COMMENT '表格日誌 - 列表 - 訊息',
  `tablelog_list_error` tinyint(1) NOT NULL default '0',
  `mergecolumn_id` int(11) NOT NULL COMMENT '合併欄位 ID FK',
  `mergecolumn_row_id` int(11) NOT NULL COMMENT '合併列 ID FK',
  PRIMARY KEY  (`tablelog_list_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 ROW_FORMAT=COMPRESSED COMMENT='表格變動日誌 - 列表 - 為了配合 scv 不做 NF3 正規化 -  merge 用' AUTO_INCREMENT=2760 ;


-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_tablelog_title`
-- 

CREATE TABLE `scs_tablelog_title` (
  `tablelog_title_id` int(11) NOT NULL auto_increment COMMENT '表格日誌 - 標題ID',
  `user_id` int(6) unsigned NOT NULL COMMENT '使用者ID',
  `mergetable_id` int(11) unsigned NOT NULL COMMENT '合併表 ID FK',
  `tablelog_title_word` varchar(256) NOT NULL COMMENT '表格日誌 - 標題文字',
  `tablelog_create_time` timestamp NOT NULL default '0000-00-00 00:00:00' COMMENT '表格日誌 - 建立時間',
  PRIMARY KEY  (`tablelog_title_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 ROW_FORMAT=COMPRESSED COMMENT='資料表變動日誌 - 標題 - 為了配合 scv 不做 NF3 正規化 - merge 用' AUTO_INCREMENT=391 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_table_log`
-- 

CREATE TABLE `scs_table_log` (
  `tablelog_id` bigint(20) unsigned NOT NULL auto_increment COMMENT '表格日誌ID',
  `table_id` int(11) unsigned NOT NULL COMMENT '表格ID,一次可能變動多個欄位所以不記column_id, 可是會造成搜索困難',
  `user_id` int(6) unsigned NOT NULL COMMENT '變動表格者ID',
  `tablelog_message` varchar(256) NOT NULL COMMENT '表格日誌的訊息',
  `tablelog_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP COMMENT '表格日誌發生時間',
  `tablelog_valid` tinyint(1) unsigned NOT NULL COMMENT '表格歷史紀錄是否顯示給一般使用者?',
  PRIMARY KEY  (`tablelog_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 ROW_FORMAT=COMPACT COMMENT='資料表變動日誌' AUTO_INCREMENT=505 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_user`
-- 

CREATE TABLE `scs_user` (
  `user_id` int(6) unsigned NOT NULL auto_increment COMMENT '系統使用者ID',
  `employee_number` int(6) unsigned NOT NULL COMMENT '員工編號 FK',
  `position_id` int(4) unsigned NOT NULL COMMENT '職務 ID FK - 對應表格權限, 與部門高度相關',
  `department_id` int(4) unsigned NOT NULL COMMENT '員工部門ID FK - 代表職務類型',
  `team_organize_id` int(11) unsigned NOT NULL COMMENT '所屬團隊的組織ID FK',
  `organize_id` int(11) unsigned NOT NULL COMMENT '組織ID FK',
  `gradelevel_id` int(4) unsigned NOT NULL COMMENT '員工職等ID FK',
  `user_account` varchar(64) NOT NULL COMMENT '系統使用者帳號',
  `user_password` varchar(64) NOT NULL COMMENT '系統使用者密碼',
  `user_nickname` varchar(128) NOT NULL COMMENT '使用者暱稱',
  `user_exnumber` int(6) unsigned NOT NULL COMMENT '使用者分機號碼',
  PRIMARY KEY  (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 COMMENT='使用者' AUTO_INCREMENT=49 ;

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_user_status`
-- 

CREATE TABLE `scs_user_status` (
  `user_id` int(6) unsigned NOT NULL COMMENT '使用者ID',
  `user_logined` tinyint(1) NOT NULL COMMENT '使用者目前是否登入',
  `user_logined_ip` varchar(15) NOT NULL default '0.0.0.0' COMMENT '使用者目前登入IP',
  `user_logincheck_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP COMMENT '前次使用者狀態檢查時間-更新By Tick',
  PRIMARY KEY  (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=big5 ROW_FORMAT=COMPACT COMMENT='系統使用者狀態,本可與scs_user合併,但是此表格內容只是暫時取代Server協定用。';

-- 
-- 列出以下資料庫的數據： `scs_user_status`
-- 

INSERT INTO `scs_user_status` VALUES (1, -1, '192.168.33.35', '2010-03-26 21:42:41');
INSERT INTO `scs_user_status` VALUES (2, -1, '192.168.33.133', '2010-03-26 18:23:05');
INSERT INTO `scs_user_status` VALUES (3, -1, '192.168.33.131', '2010-03-26 16:32:55');
INSERT INTO `scs_user_status` VALUES (4, -1, '192.168.33.132', '2010-03-24 12:03:34');
INSERT INTO `scs_user_status` VALUES (5, -1, '192.168.33.98', '2010-03-26 17:22:49');
INSERT INTO `scs_user_status` VALUES (7, 0, '192.168.38.41', '2010-02-01 14:34:14');
INSERT INTO `scs_user_status` VALUES (8, -1, '192.168.33.64', '2010-03-26 13:52:54');
INSERT INTO `scs_user_status` VALUES (9, -1, '192.168.33.3', '2010-03-26 19:14:45');
INSERT INTO `scs_user_status` VALUES (10, -1, '192.168.38.76', '2010-03-19 18:50:21');
INSERT INTO `scs_user_status` VALUES (11, -1, '192.168.37.74', '2010-03-24 14:58:45');
INSERT INTO `scs_user_status` VALUES (14, -1, '192.168.37.75', '2010-03-23 18:07:21');
INSERT INTO `scs_user_status` VALUES (16, -1, '192.168.39.1', '2010-03-23 18:24:36');
INSERT INTO `scs_user_status` VALUES (17, -1, '192.168.37.70', '2010-03-19 17:17:07');
INSERT INTO `scs_user_status` VALUES (18, -1, '192.168.37.89', '2010-03-19 17:18:19');
INSERT INTO `scs_user_status` VALUES (20, -1, '192.168.38.95', '2010-03-19 17:32:13');
INSERT INTO `scs_user_status` VALUES (21, -1, '192.168.38.104', '2010-03-24 10:05:09');
INSERT INTO `scs_user_status` VALUES (23, -1, '192.168.38.5', '2010-03-19 17:53:58');
INSERT INTO `scs_user_status` VALUES (32, -1, '192.168.38.18', '2010-03-19 18:53:51');
INSERT INTO `scs_user_status` VALUES (34, -1, '192.168.38.75', '2010-03-18 10:06:03');
INSERT INTO `scs_user_status` VALUES (42, -1, '192.168.38.45', '2010-03-19 18:42:42');
INSERT INTO `scs_user_status` VALUES (43, -1, '192.168.37.42', '2010-03-18 10:05:57');

-- --------------------------------------------------------

-- 
-- 資料表格式： `scs_version`
-- 

CREATE TABLE `scs_version` (
  `version_id` int(10) NOT NULL auto_increment,
  `version_current` varchar(10) NOT NULL COMMENT '現在版本',
  `version_size` int(10) unsigned NOT NULL default '0' COMMENT '執行檔大小',
  `version_desc` text NOT NULL COMMENT '更新列表',
  `version_datetime` datetime NOT NULL COMMENT '最後更新時間',
  PRIMARY KEY  (`version_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=big5 AUTO_INCREMENT=2 ;

-- 
-- 列出以下資料庫的數據： `scs_version`
-- 

INSERT INTO `scs_version` VALUES (1, '06.08', 1890304, '\r\n<html>\r\n<head>\r\n  <style>\r\n  	html, body { margin: 10; padding: 10; font-family: Tahoma;	font-size: 12px; color: #505050;}\r\n    .updatelist { margin-left: 4px;}\r\n    .updatetitle{ font-size: 14; font-weight: bold; margin-bottom:4px;}\r\n    .filepath{margin-left: 4px;font-size: 12; font-weight: bold; margin-bottom:4px; color:#D9524F;}\r\n  </style>\r\n</head>\r\n<body>\r\n\r\n<div class="filepath">* 最新版路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍最新版本</div>\r\n<div class="filepath">                               請注意天空龍已有 FTP 更新，確認您的版本沒有自動更新時，才需要手動更新。</div>\r\n\r\n<hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.08  (2010.03.26)</div>\r\n<div class="updatelist"><b>* 系統測試資料刪除。</b></div>\r\n<div class="updatelist">* 修正使用右鍵新增資料，有時候會出現"Grid index out of raneg"的BUG</div>\r\n<div class="updatelist">* 修正使用右鍵取消後，使用滾輪會出現"Grid index out of raneg"的BUG</div>\r\n<div class="updatelist">* 修正表格會一直閃爍的BUG。</div>\r\n<div class="updatelist">* 修正表格完全沒有資料卻可以編輯的BUG。</div>\r\n<div class="updatelist">* 修正移動執行檔後，佈景主題功能不會運作的BUG。</div>\r\n<div class="updatelist">* 修正即時訊息有新資料時，部分機率會出現Access violation 的BUG。</div>\r\n<div class="updatelist">* 修正開啟新增編輯視窗，Bar條會置頂。</div>\r\n<div class="updatelist">* 修改下拉式選單，不能任意輸入字。</div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.08</div>-->\r\n\r\n<hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.07  (2010.03.26)</div>\r\n<div class="updatelist">* 修正下方選單交替點擊會 Error的 BUG</div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.07</div>-->\r\n\r\n<hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.06  (2010.03.25)</div>\r\n<div class="updatelist">* 新增發送訊息時，增加Enter發送功能</div>\r\n<div class="updatelist">* 新增表格編輯介面，可以使用滑鼠滾輪的功能。</div>\r\n<div class="updatelist">* 修正刪除列數時，即時訊息的[專案]顯示不正確的BUG</div>\r\n<div class="updatelist">* 修正單一欄位編輯時，原始資料不會回填的BUG</div>\r\n<div class="updatelist">* 修正單一欄位編輯視窗有時候會error的Bug</div>\r\n<div class="updatelist">* 修正沒有細項的[即時訊息]，沒有任何提示的BUG。</div>\r\n<div class="updatelist">* 修正點選後面的欄位時，焦點會跑到最前端的BUG。</div>\r\n<div class="updatelist">* 修正取消搜索有時候會error的BUG。</div>\r\n<div class="updatelist">* 修改刪除列數時，即時訊息不只會記錄[刪除的列數]，也會記錄部分原始內容。</div>\r\n<div class="updatelist">* 修改下方[專案]與[表格]選單區，預設為全部不選。</div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.06</div>-->\r\n\r\n<hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.05  (2010.03.19)</div>\r\n<div class="updatelist">* 修正總表顯示列數不正確的BUG</div>\r\n<div class="updatelist">* 修正新增資料時，點選到子表會跳出 Error的 BUG</div>\r\n<div class="updatelist">* 修正右鍵選單，取消後，又點選總表，會跳Error的 BUG</div>\r\n<div class="updatelist"><b>* 修改表格只針對單一欄位編輯</b></div\r\n<div class="updatelist">* 修改欄位可以使用大範圍的編輯框</div>\r\n<div class="updatelist">* 修改天空龍 FTP 線上更新的流程。</div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.05</div>-->\r\n\r\n<hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.04  (2010.03.18)</div>\r\n<div class="updatelist">* 新增天空龍 FTP 線上更新機制。</div>\r\n<div class="updatelist">* 新增刪除一列的功能。</div>\r\n<div class="updatelist">* 修改新版編輯視窗修改視窗</div>\r\n<div class="updatelist">* 修改時間輸入方式為統一格式</div>\r\n<div class="updatelist">* 修正個人資訊列隱藏與顯示時，頁面分頁不會縮放的問題。</div>\r\n<div class="updatelist">* 修正表格雙擊灰色地帶會error的Bug。</div>\r\n<div class="updatelist">* 修正總表欄位顯示不正確的問題。</div>\r\n<div class="updatelist">* 修正個人未完成項目計算錯誤。</div>\r\n<div class="updatelist"><b>* 修正發送公告時會連續跳訊息的BUG。</b></div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.04</div>-->\r\n\r\n <hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.03  (2010.03.10)</div>\r\n<div class="updatelist">* 修正編輯表格內容後，下一次點選的編輯視窗，資訊會錯誤的Bug。</div>\r\n<div class="updatelist">* 修正右鍵搜索有時候會出現Error的Bug。</div>\r\n<div class="updatelist">* 修正取消搜索後列數顯示不正常的Bug。</div>\r\n<div class="updatelist">* 修改未登入點擊表格，不會再跳警告。</div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.03</div>-->\r\n   	\r\n<hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.02  (2010.03.09)</div>\r\n<div class="updatelist">* 新增天空龍喃喃自語，左下方會出現提示訊息的功能。</div>\r\n<div class="updatelist">* 新增版本檢查與通知機制。</div>\r\n<div class="updatelist">* 新增天空龍巨龍模式，透過視窗拖拉的關鍵動作，能夠讓天空龍放大縮小。</div>\r\n<div class="updatelist">* 新增個人資訊列出企畫進度表，讓天空龍來告訴你未完成的項目總數。</div>\r\n<div class="updatelist">* 修改為了讓天空龍載重率提高，變更表格資料更新方式，天空龍將能載更多人。</div>\r\n<div class="updatelist">* 欄位寬度變得更精準，幾乎已經是完全貼合欄位內資料的狀況。</div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.02</div>-->\r\n 	\r\n<hr color="#C0C0C0" size="1" width="100%" align="center">\r\n<div class="updatetitle">Ver 6.01  (2010.03.04)</div>\r\n<div class="updatelist">* 修正[本週更新]的欄位設定,限制為 確認更新 or 延後。</div>\r\n<div class="updatelist">* 修正[凍結視窗]的功能的操作方式。</div>\r\n<div class="updatelist">* 修正表單上使用滾輪滑鼠時, 會一直彈跳出編輯視窗的問題。</div>\r\n<div class="updatelist">* 修正移動 [新增修改介面] 上面填寫的資料都會不見的問題。</div>\r\n<div class="updatelist">* 新增系統功能列, 更改密碼功能。</div>\r\n<div class="updatelist">* 新增系統功能列, 更換佈景主題功能。</div>\r\n<div class="updatelist">* 新增 XLS 轉存時, 部分表格(企劃進度表/更新項目表)可以套用版型的功能。</div>\r\n<!--<div class="filepath">* 手動更新路徑：　\\\\share\\專案共用區\\奇幻西遊\\奇幻西遊-程式組\\給又玄\\盈毅給\\天空龍ver06.01</div>-->\r\n  	\r\n</body>\r\n</html>\r\n  \r\n', '2010-03-26 21:13:08');
