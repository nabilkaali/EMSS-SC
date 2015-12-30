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
	// This is where you can define your own instructions. Do not change anything outside the **** lines
	// You should replace the translation calls with straight text if you are not using your own phrase file
	// *****************************************************************************************************
// MOD BY BILAL
//	html += getSeaPhrase("BULLETIN_4","BEN")
//	html += '<p>' + getSeaPhrase("BULLETIN_5","BEN") + '</p>'
//	html += '<p>' + getSeaPhrase("NHBULLETIN_17","BEN") + '</p>'
// MOD BY CLYNCH - Moved empname value set, added display of name to text, removed name display in paneHeader.
	var empname = parent.nickname + " " + parent.lastname
	html += '<p>'
	html += '<font size="-1"><b>Welcome ' + empname
	html += '</b></font><p>'
	html += '<font size="-1">The benefits enrollment period is from <b>7:30am MST February 4, 2013 through 5:00pm MST February 22, 2013</b>.  You must elect your benefits during this time frame. Failure to do so may affect your ability to have benefits for the new plan year. The new plan year is <b>April 1, 2013 through March 31, 2014</b></font>'
	html += '<p>'
	html += '<font size="-1">Under the myHR Benefits section of this website, you will have links to plan descriptions for the different benefit plans and a provider directory to help answer any questions.  The plan descriptions provide additional information about the benefit plans.  In the event of any conflict between these enrollment materials, the plan descriptions and the official plan documents will rule.</font>'
	html += '<p><font size="-1"><b>Authorization for Salary Reduction:  </b> I have read and understand the benefit choices available to me.  I further understand that coverage will become effective only after coverage has been approved and on the date specified.  I agree to all payroll deductions for all benefits that I select (including default benefits that I receive because I do not make a contrary election).</font></p> '
	html += '<p><font size="-1"><b>Certification:  </b> I certify that the information I will provide on this form is true and accurate to the best of my knowledge.  Any misrepresentation or deliberate omission of fact may invalidate coverage for me and/or my dependents and may result in termination of my employment.</font></p>'
// END OF MOD
	// *****************************************************************************************************
	html += '<p style="text-align:center">'
// MOD BY CLYNCH - Added font size/weight/color and button width/backgroundcolor attributes to style parameter.
//	html += uiButton(getSeaPhrase("CONTINUE","BEN"), "parent.CheckBenis();return false", "margin-top:10px")
	html += uiButton(getSeaPhrase("CONTINUE","BEN"), "parent.CheckBenis();return false", "font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
	html += '&nbsp;&nbsp;'
	if (parent.opener)
		html += uiButton(getSeaPhrase("EXIT","BEN"), "parent.parent.EndEnroll('YES');return false", "font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
//		html += uiButton(getSeaPhrase("EXIT","BEN"), "parent.parent.EndEnroll('YES');return false", "margin-top:10px")
// END OF MOD
	html += '</p>'
	html += '</div>'
	document.getElementById("paneBody").innerHTML = html;
	document.getElementById("paneHeader").innerHTML = getSeaPhrase("WELCOME","BEN");
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
<!-- MOD BY BILAL - Prior customizations -->
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-395426-5");
pageTracker._trackPageview();
} catch(err) {}</script>
<!-- END OF MOD  -->
</body>
</html>
<!-- Version: 8-)@(#)@(201111) 09.00.01.06.00 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/benbulletin.htm,v 1.22.2.4 2009/03/04 17:39:46 brentd Exp $ -->
