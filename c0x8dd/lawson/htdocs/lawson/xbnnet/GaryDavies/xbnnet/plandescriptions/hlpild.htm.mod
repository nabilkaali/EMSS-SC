<html>
<head>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<link rel="alternate stylesheet" type="text/css" id="ui" title="classic" href="/lawson/xhrnet/ui/ui.css"/>
<link rel="alternate stylesheet" type="text/css" id="uiLDS" title="lds" href="/lawson/webappjs/lds/css/ldsEMSS.css"/>
<script type="text/javascript" src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script>
function startProgram()
{
	var html = '<div class="plaintablecell" style="padding:10px">';
    var headertext = '<table border="0" width="100%"><tr><td width="60%"><font style="font-size:smaller" color="#0066cc"><b>Pay In Lieu of Benefits Coverage</b></font></td><td width="20%" align="right" valign="middle"><a href=javascript:self.close()><font color="#0066cc"><b>Close</b></font></a>&nbsp;</td><td width="20%" align="right" valign="middle"><a href=javascript:self.print()><font color="#0066cc"><b>Print</b></font></a>&nbsp;</td></tr></table>'
	html += '<p>'
	html += 'St. Luke\'s offers Pay In Lieu of Benefits Plan. The pay in lieu of benefits plan (PILB) is an <b><u>OPTIONAL</u></b> benefit election and is designed to allow benefits eligible employees who have health insurance coverage under a <b><u>non-St. Luke\'s health plan</u></b> to elect a higher rate of pay in lieu of certain benefits.  With PILB being an optional election, if you do not elect PILB, you will remain eligible for all applicable benefits based on your employment status. For example, if you do not want to enroll in St. Luke\�s Group Health Plan, you are not required to elect PILB.<p>'
	html += '<p>'
	html += 'If you choose the <B>Decline PILB</B> option, you may proceed to elect your benefits.<p>'
	html += '</div>'
	document.getElementById("paneBody").innerHTML = html;
	document.getElementById("paneHeader").innerHTML = headertext
	stylePage();
	document.body.style.visibility = "visible";
}
</script>
</head>
<body onload="setLayerSizes();startProgram()" style="visibility:hidden">
<div id="paneBorder" class="paneborder">
	<table id="paneTable" border="0" height="100%" width="100%" cellpadding="0" cellspacing="0">
	<tr><td style="height:16px">
		<div id="paneHeader" class="paneheader">&nbsp;
		</div>
	</td></tr>
	<tr><td>
		<div id="paneBodyBorder" class="panebodyborder" styler="groupbox"><div id="paneBody" class="panebody"></div>
		</div>
	</td></tr>
	</table>
</div>
</body>
</html>
<!-- Version: 8-)@(#)@(201005) 09.00.01.03.00 Mon Apr 19 10:15:09 CDT 2010 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/benbulletin.htm,v 1.22.2.4 2009/03/04 17:39:46 brentd Exp $ -->
