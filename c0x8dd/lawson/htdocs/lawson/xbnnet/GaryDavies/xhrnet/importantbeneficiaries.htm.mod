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
    var headertext = '<table border="0" width="100%"><tr><td width="60%"><font style="font-size:smaller" color="#FFFFFF"><b>Important Information about Beneficiaries</b></font></td><td width="20%" align="right" valign="middle"><a href=javascript:self.close()><font color="#FFFFFF"><b>Close</b></font></a>&nbsp;</td><td width="20%" align="right" valign="middle"><a href=javascript:self.print()><font color="#FFFFFF"><b>Print</b></font></a>&nbsp;</td></tr></table>'
	html += '<p>'
	html += '<b><font size="4">&nbsp;Important: </font>&nbsp;403(b) Tax Deferred Annuity Plan and Life Insurance Plan (s)</b>&nbsp; If you are married, the federal and state law requires you to have your 100% primary beneficiary under the Plan as your spouse, unless your spouse signs a written consent to your designation of a non-spouse beneficiary. If Spousal Consent is required, it must be witnessed by a Plan Representative or a Notary Public. This form is available at Inside St. Luke�s. By selecting a beneficiary, you are certifying that you agree to notify the Benefits Department immediately in the event of any marital status changes.</p>'
	html += '<p>If you do not name a beneficiary or your beneficiary does not survive you, your primary beneficiary under the Plan(s) will be your spouse, or, if you do not have a surviving spouse, your revocable trust or Estate.</p>'
	html += '<p>As a covered employee, you have the right to designate a beneficiary in accordance with the provisions of your plan. You may also have the right to change the designated beneficiary. If more than one primary beneficiary is designated, payment of the death benefit will be made in equal shares to each of the designated beneficiaries which survive you, unless some other allocation is specified by you in accordance with the provisions of the policy. If none of the primary beneficiaries survive you, the contingent beneficiaries will be used. If no designated beneficiary survives you, settlement will be made in accordance with the terms of the plan.</p>'
	html += '<p><b>TRUST</b> - A life insurance trust is an irrevocable, non-amendable trust which is both the owner and beneficiary of one or more life insurance policies.  Upon the death of the insured, the Trustee invests the insurance proceeds and administers the trust for one or more beneficiaries.  The trustees are the legal owners of the trust property (or trust corpus), but they are obliged to hold the property for the benefit of one or more individuals or organizations (the beneficiary), usually specified by the settlor.  The trustees owe a fiduciary duty to the beneficiaries, who are the "beneficial" owners of the trust property.</p>'
	html += '<p><b>CONTINGENT</b> - A contingent (secondary) beneficiary is the person designated to receive life insurance policy proceeds if the primary beneficiary should die before the insured dies.</p>'
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
