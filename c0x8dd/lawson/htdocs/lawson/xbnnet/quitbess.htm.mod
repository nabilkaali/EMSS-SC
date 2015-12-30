<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<title>Quit Enrollment</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script>
function initProgram()
{
	setWinTitle(getSeaPhrase("QUIT_ENROLLMENT","BEN"));
	parent.startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), startProgram);
}
function startProgram()
{
	var par = (parent.main) ? parent : parent.parent;
	if (par.quitting && par.emailSummary)
		par.emailScr(par.main,false);	
	if (par.quitting && par.printSummary)
		setTimeout(function() { par.printScr(par.main.printScreen); }, 500);	
	if (par.quitting)
		par.quitting = false;
	var html = '<div class="plaintablecell" style="padding:0px">'
 	html += '<br/><table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" style="width:100%;margin-left:auto;margin-right:auto" role="presentation">'
	html += '<tr><td class="plaintableheaderborder">'+getSeaPhrase("EXIT","BEN")+'</td></tr>'
	html += '<tr><td class="plaintablecellborder" style="border-bottom:0px"><p>'+getSeaPhrase("QUIT_6","BEN")+'</p></td></tr>'
	html += '<tr><td class="plaintablecellborder"><p>'+getSeaPhrase("QUIT_3","BEN")+'</p></td></tr></table>'
	html += '<p class="textAlignRight">'
	// MOD BY BILAL 
	//Changing the Button styling per St. Lukes requirement.
	if (parent.main)
	{
	//	html += uiButton(getSeaPhrase("QUIT_4","BEN"), "parent.EndEnroll('YES');return false","margin-right:5px;margin-top:10px")
	//	html += uiButton(getSeaPhrase("QUIT_5","BEN"), "parent.EndEnroll('NO');return false","margin-right:5px;margin-top:10px")
		html += uiButton(getSeaPhrase("QUIT_4","BEN"), "parent.EndEnroll('YES');return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
		html += "&nbsp;&nbsp;&nbsp;"
		html += uiButton(getSeaPhrase("QUIT_5","BEN"), "parent.EndEnroll('NO');return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")

	}
	else
	{
	//	html += uiButton(getSeaPhrase("QUIT_4","BEN"), "parent.parent.EndEnroll('YES');return false","margin-right:5px;margin-top:10px")
	//	html += uiButton(getSeaPhrase("QUIT_5","BEN"), "parent.parent.EndEnroll('NO');return false","margin-right:5px;margin-top:10px")
		html += uiButton(getSeaPhrase("QUIT_4","BEN"), "parent.parent.EndEnroll('YES');return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
		html += "&nbsp;&nbsp;&nbsp;"
		html += uiButton(getSeaPhrase("QUIT_5","BEN"), "parent.parent.EndEnroll('NO');return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")

	}
// END OF MOD
	html += '</p></div>'
	document.getElementById("paneBody").innerHTML = html;
	document.getElementById("paneHeader").innerHTML = getSeaPhrase("ENROLLMENT_ELECTIONS","BEN");
	stylePage();
	document.body.style.visibility = "visible";
	parent.stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[getWinTitle()]));
	parent.fitToScreen();
}
</script>
</head>
<body onload="setLayerSizes();initProgram()" style="visibility:hidden">
<div id="paneBorder" class="paneborder">
	<table id="paneTable" border="0" height="100%" width="100%" cellpadding="0" cellspacing="0" role="presentation">
	<tr><td style="height:16px">
		<div id="paneHeader" class="paneheader" role="heading" aria-level="2">&nbsp;</div>
	</td></tr>
	<tr><td>
		<div id="paneBodyBorder" class="panebodyborder" styler="groupbox"><div id="paneBody" class="panebody" tabindex="0"></div></div>
	</td></tr>
	</table>
</div>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/quitbess.htm,v 1.20.2.32 2014/02/25 22:49:14 brentd Exp $ -->
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
