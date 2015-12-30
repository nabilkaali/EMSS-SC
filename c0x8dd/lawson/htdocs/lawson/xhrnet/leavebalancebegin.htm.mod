<!DOCTYPE html>
<head>
<head>
<title>Leave Balances</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Pragma" content="No-Cache">
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/xhrnet/waitalert.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script src="/lawson/webappjs/javascript/objects/ActivityDialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/OpaqueCover.js"></script>
<script src="/lawson/webappjs/javascript/objects/Dialog.js"></script>
<script>
var loadTimer;
var authUser;

function CallBack()
{
	authenticate("frameNm='jsreturn'|funcNm='user=authUser;InitLeaveBalance()'|desiredEdit='EM'");
}

function InitLeaveBalance()
{
    stylePage();
    setWinTitle(getSeaPhrase("LEAVE_BALANCES","ESS"));
	showWaitAlert(getSeaPhrase("WAIT","ESS"), GetGlcodes);
}

function GetGlcodes() 
{
  	//check if LP is being used
  	var obj = new DMEObject(authUser.prodline, "glcodes");
	obj.out = "JAVASCRIPT";
	obj.index = "gcdset4";
	obj.field = "system";
	obj.key = authUser.company+"=LP";
	obj.debug = false;
	obj.max	= "1";
	obj.func = "checkForLP()";
  	DME(obj,"jsreturn");
}

function checkForLP() {
	if (self.jsreturn.record.length > 0) {
// CGL - Redirecting delivered LP balance display screen to custom page
// ianm - restored original page
		self.location = "/lawson/xhrnet/leavebalance.htm" + window.location.search;
		//self.location = "/lawson/xhrnet/emtamastrlp.htm" + window.location.search;
//~CGL
	}
	else {
		self.location = "/lawson/xhrnet/emtamastr.htm" + window.location.search;
        }
}

loadTimer = setTimeout("CallBack()",3000);
</script>
</head>
<body onload="clearTimeout(loadTimer);CallBack()">
	<iframe id="header" name="header" title="Header" tabindex="0" style="visibility:hidden;position:absolute;height:32px;width:803px;left:10px;top:0px" src="/lawson/xhrnet/ui/header.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="jsreturn" name="jsreturn" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/dot.htm" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/Attic/leavebalancebegin.htm,v 1.1.2.25 2014/01/22 22:58:02 brentd Exp $ -->
<!--************************************************************
 *                                                             *
 *                           NOTICE                            *
 *                                                             *
 *   THIS SOFTWARE IS THE PROPERTY OF AND CONTAINS             *
 *   CONFIDENTIAL INFORMATION OF INFOR AND/OR ITS              *
 *   AFFILIATES OR SUBSIDIARIES AND SHALL NOT BE DISCLOSED     *
 *   WITHOUT PRIOR WRITTEN PERMISSION. LICENSED CUSTOMERS MAY  *
 *   COPY AND ADAPT THIS SOFTWARE FOR THEIR OWN USE IN         *
 *   ACCORDANCE WITH THE TERMS OF THEIR SOFTWARE LICENSE       *
 *   AGREEMENT. ALL OTHER RIGHTS RESERVED.                     *
 *                                                             *
 *   (c) COPYRIGHT 2014 INFOR.  ALL RIGHTS RESERVED.           *
 *   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
 *   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
 *   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL               *
 *   RIGHTS RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE  *
 *   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
 *                                                             *
 ************************************************************-->
