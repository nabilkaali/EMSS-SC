<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Pragma" content="No-Cache">
<meta http-equiv="Expires" content="Mon, 01 Jan 1990 00:00:01 GMT">
<title>Home Address</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/xhrnet/waitalert.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script src="/lawson/webappjs/javascript/objects/ActivityDialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/OpaqueCover.js"></script>
<script src="/lawson/webappjs/javascript/objects/Dialog.js"></script>
<script>
var fromTask = (window.location.search)?unescape(window.location.search):"";
var EmpInfo = new Object();
EmpInfo.employee_work_country = "";

function LoadHomeAddress()
{
	// Force the program to recall authen only if we haven't called authen before or if
	// we don't have the bookmarks.
	try
	{
	    if (top && top.authUser && !top.authUser.OfficeObject)
			top.authUser = null;
		if (opener && opener.top && opener.top.authUser && !opener.top.authUser.OfficeObject)
			opener.top.authUser = null;
	}
	catch(e) {}
	authenticate("frameNm='jsreturn'|funcNm='HomeAddressContent()'|officeObjects=true|sysenv=true|desiredEdit='EM'");
}
function HomeAddressContent()
{
	stylePage();
	var title;
	// Set the task title.
	if (fromTask && getVarFromString("from",fromTask) == "lifeevents")
	{
		title = getSeaPhrase("HOME_ADDR_49","ESS");
		setTaskHeader("header",title,"LifeEvents");
	}	
	else
	{	
		title = getSeaPhrase("HOME_ADDR_0","ESS");
		setTaskHeader("header",title,"Personal");
	}	
	setWinTitle(title);
	// Load the application.
	self.left.location.replace("/lawson/xhrnet/empaddress.htm?from=main");
	document.getElementById("left").style.visibility = "visible";
}
function OpenHelpDialog()
{
    try
    {
    	self.left.OpenHelpDialog.apply(this, arguments);;
    }
    catch(e) {}
}
function toggleFrame(frmId, show)
{
	var frm = document.getElementById(frmId);
	if (frm)
	{	
		frm.style.visibility = (show) ? "visible" : "hidden";
		frm.style.display = (show) ? "" : "none";	
	}
}
function fitToScreen()
{
	if (typeof(window["styler"]) == "undefined" || window.styler == null)
		window.stylerWnd = findStyler(true);
	if (!window.stylerWnd)
		return;
	if (typeof(window.stylerWnd["StylerEMSS"]) == "function")
		window.styler = new window.stylerWnd.StylerEMSS();
	else
		window.styler = window.stylerWnd.styler;
	var leftFrame = document.getElementById("left");
	var rightFrame = document.getElementById("right");
	var relatedTaskFrame = document.getElementById("relatedtask");
	var fullRelatedTaskFrame = document.getElementById("fullrelatedtask");
	var winObj = getWinSize();
	var winWidth = winObj[0];	
	var winHeight = winObj[1];
	var contentHeightBorder;
	var contentHeight;
	var contentWidthBorder;
	var contentWidth;	
	var contentLeftWidthBorder;
	var contentLeftWidth;	
	var contentRightWidthBorder;
	var contentRightWidth;
	if (window.styler && window.styler.showInfor)
	{	
		contentWidth = winWidth - 10;
		contentWidthBorder = (navigator.appName.indexOf("Microsoft") >= 0) ? contentWidth + 5 : contentWidth + 2;	
		contentLeftWidth = parseInt(winWidth*.50) - 10;
		contentLeftWidthBorder = (navigator.appName.indexOf("Microsoft") >= 0) ? contentLeftWidth + 5 : contentLeftWidth + 2;
		contentRightWidth = parseInt(winWidth*.50) - 10;
		contentRightWidthBorder = (navigator.appName.indexOf("Microsoft") >= 0) ? contentRightWidth + 5 : contentRightWidth + 2;						
		contentHeight = winHeight - 65;
		contentHeightBorder = contentHeight + 30;
	}
	else if (window.styler && (window.styler.showLDS || window.styler.showInfor3))
	{
		contentWidth = winWidth - 20;
		contentWidthBorder = (window.styler.showInfor3) ? contentWidth + 7 : contentWidth + 17;	
		contentLeftWidth = parseInt(winWidth*.50) - 20;
		contentLeftWidthBorder = (window.styler.showInfor3) ? contentLeftWidth + 7 : contentLeftWidth + 17;
		contentRightWidth = parseInt(winWidth*.50) - 20;
		contentRightWidthBorder = (window.styler.showInfor3) ? contentRightWidth + 7 : contentRightWidth + 17;				
		contentHeight = winHeight - 75;	
		contentHeightBorder = contentHeight + 30;
	}
	else
	{
		contentWidth = winWidth - 10;
		contentWidthBorder = contentWidth;	
		contentLeftWidth = parseInt(winWidth*.50) - 10;
		contentLeftWidthBorder = contentLeftWidth;	
		contentRightWidth = parseInt(winWidth*.50) - 10;
		contentRightWidthBorder = contentRightWidth;			
		contentHeight = winHeight - 60;
		contentHeightBorder = contentHeight + 24;
	}
	setLayerSizes = function() {};
	leftFrame.style.width = parseInt(winWidth*.50) + "px";
	leftFrame.style.height = winHeight + "px";
	try
	{
		if (self.left.onresize && self.left.onresize.toString().indexOf("setLayerSizes") >= 0)
		{
			self.left.setLayerSizes = function() {};
			self.left.onresize = null;
		}			
	}
	catch(e) {}
	try
	{
		self.left.document.getElementById("paneBorder").style.width = contentLeftWidthBorder + "px";
		self.left.document.getElementById("paneBodyBorder").style.width = contentLeftWidth + "px";
		self.left.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.left.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.left.document.getElementById("paneBody").style.width = contentLeftWidth + "px";
		self.left.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
	rightFrame.style.width = parseInt(winWidth*.50) + "px";
	rightFrame.style.height = winHeight + "px";
	try
	{
		if (self.right.onresize && self.right.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.right.onresize = null;		
	}
	catch(e) {}
	try
	{
		self.right.document.getElementById("paneBorder").style.width = contentRightWidthBorder + "px";
		self.right.document.getElementById("paneBodyBorder").style.width = contentRightWidth + "px";
		self.right.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.right.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.right.document.getElementById("paneBody").style.width = contentRightWidth + "px";
		self.right.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}	
	relatedTaskFrame.style.width = parseInt(winWidth*.50) + "px";
	relatedTaskFrame.style.height = winHeight + "px";
	try
	{
		if (self.relatedtask.onresize && self.relatedtask.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.relatedtask.onresize = null;		
	}
	catch(e) {}
	try
	{
		self.relatedtask.document.getElementById("paneBorder").style.width = contentLeftWidthBorder + "px";
		self.relatedtask.document.getElementById("paneBodyBorder").style.width = contentLeftWidth + "px";
		self.relatedtask.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.relatedtask.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.relatedtask.document.getElementById("paneBody").style.width = contentLeftWidth + "px";
		self.relatedtask.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}	
	fullRelatedTaskFrame.style.width = winWidth + "px";
	fullRelatedTaskFrame.style.height = winHeight + "px";
	try
	{
		if (self.fullrelatedtask.onresize && self.fullrelatedtask.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.fullrelatedtask.onresize = null;		
	}
	catch(e) {}
	try
	{
		self.fullrelatedtask.document.getElementById("paneBorder").style.width = contentWidthBorder + "px";
		self.fullrelatedtask.document.getElementById("paneBodyBorder").style.width = contentWidth + "px";
		self.fullrelatedtask.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.fullrelatedtask.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.fullrelatedtask.document.getElementById("paneBody").style.width = contentWidth + "px";
		self.fullrelatedtask.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}	
	if (window.styler && window.styler.textDir == "rtl")
	{
		leftFrame.style.left = "";
		leftFrame.style.right = "0px";
		relatedTaskFrame.style.left = "";
		relatedTaskFrame.style.right = "0px";
		rightFrame.style.left = "0px";
	}
	else
		rightFrame.style.left = parseInt(winWidth*.50) + "px";
}
</script>
</head>
<body style="overflow:hidden" onload="fitToScreen();LoadHomeAddress()" onresize="fitToScreen()">
	<iframe id="header" name="header" title="Header" level="1" tabindex="0" style="visibility:hidden;position:absolute;height:32px;width:803px;left:0px;top:0px" src="/lawson/xhrnet/ui/header.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="left" name="left" title="Main Content" level="2" tabindex="0" class="contentframe" src="/lawson/xhrnet/dot.htm" style="position:absolute;top:32px;height:555px;left:0%;width:49%" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="right" name="right" title="Secondary Content" level="3" tabindex="0" class="contentframe" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;position:absolute;top:32px;height:555px;left:49%;width:51%" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="relatedtask" name="relatedtask" title="Secondary Content" level="2" tabindex="0" class="contentframe" style="position:absolute;top:32px;height:555px;left:0%;width:49%;visibility:hidden" src="/lawson/xhrnet/dot.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="fullrelatedtask" name="fullrelatedtask" title="Secondary Content" level="2" tabindex="0" class="contentframe" style="position:absolute;top:32px;height:555px;width=803px;left:0%;visibility:hidden" src="/lawson/xhrnet/dot.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="jsreturn" name="jsreturn" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/dot.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/homeaddress.htm,v 1.9.2.46 2014/01/22 22:58:04 brentd Exp $ -->
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