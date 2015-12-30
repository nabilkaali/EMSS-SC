<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<title>Enroll in Benefit Plan</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script>
var head=""
var bod=""
var flexflag=0
var empflag=0
var compflag=0
var start=parseFloat(parent.parent.SelectedPlan[29])
var stop=parseFloat(parent.parent.SelectedPlan[31])
var mult=""
var temp=""
var flexrate=doParseFloat(parent.parent.SelectedPlan[20])
var emprate=doParseFloat(parent.parent.SelectedPlan[18])
var comprate=doParseFloat(parent.parent.SelectedPlan[24])
var flex=doParseFloat(parent.parent.SelectedPlan[20])
var emp=doParseFloat(parent.parent.SelectedPlan[18])
var comp=doParseFloat(parent.parent.SelectedPlan[24])
var CVR_BEF_AFT_FLAG=(parent.parent.SelectedPlan[39])
var CVR_ROUND_METH=(parent.parent.SelectedPlan[40])
var CVR_ROUND_TO=(parent.parent.SelectedPlan[41])
var	PRE_CONTRIB_BASIS=(parent.parent.SelectedPlan[42])
var BN_PLAN_TYPE=(parent.parent.SelectedPlan[43])
var BN_PLAN_CODE=(parent.parent.SelectedPlan[44])
var CAL_SALARY_START=doParseFloat(parent.parent.SelectedPlan[11])
var CAL_SALARY=doParseFloat(parent.parent.SelectedPlan[11])
var CVR_MULT_SALARY=doParseFloat(parent.parent.SelectedPlan[17])
var CVR_MIN_COVER=doParseFloat(parent.parent.SelectedPlan[26])
var CVR_MAX_COVER=doParseFloat(parent.parent.SelectedPlan[27])
var tmp=parent.parent.determineCoverage(4)
var max=doParseFloat(parent.parent.SelectedPlan[34])
var min=doParseFloat(parent.parent.SelectedPlan[33])
var CVR_INCREMENT=doParseFloat(parent.parent.SelectedPlan[35])
var i=1
function startProgram()
{
	setWinTitle(getSeaPhrase("ENROLL_PLAN","BEN"));
	REC_TYPE=parent.parent.EligPlans[parent.parent.CurrentEligPlan][6]
	if (tmp)
	{
		if (tmp!=true)
		{
			var tmpmax=0
			tmpmax=parseInt(tmp/doParseFloat(parent.parent.SelectedPlan[35]),10)
			tmpmax=tmpmax*doParseFloat(parent.parent.SelectedPlan[35])
			if (tmpmax<max)
				max=tmpmax
		}
		precont = parent.parent.SelectedPlan[15];
		defaul = parent.parent.SelectedPlan[16];
		var costsStr = '';
		if (precont=="P"||precont=="N"||precont=="A")
		{
			if (precont=="P")
				costsStr += getSeaPhrase("ELECTBEN_3","BEN")
			else if (precont=="A")
				costsStr += getSeaPhrase("ELECTBEN_4","BEN")
			else if (precont=="N")
				costsStr += getSeaPhrase("ELECTBEN_7","BEN")
		}
		var html = '<div class="plaintablecell" style="padding:0px">'
		html += parent.header(costsStr)
		head += '<table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" style="width:100%;margin-left:auto;margin-right:auto" styler="list" summary="'+getSeaPhrase("TSUM_15","BEN",[parent.parent.EligPlans[parent.parent.CurrentEligPlan][4]])+'">'
		head += '<caption class="offscreen">'+getSeaPhrase("TCAP_11","BEN",[parent.parent.EligPlans[parent.parent.CurrentEligPlan][4]])+'</caption>'
		head += '<tr><th scope="col" class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("ELECTBEN_33","BEN")+'</th>'
		bod += '<tr><td class="plaintablecellborder" style="text-align:center">'+parent.parent.formatCont(parent.parent.SelectedPlan[35])+'</td>'
		if (parent.parent.SelectedPlan[20]!="")
		{
			head += '<th scope="col" class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("FLEX_CR","BEN")+'</th>'
			bod += '<td class="plaintablecellborder" style="text-align:center" nowrap>'+parent.parent.formatCont(parent.parent.SelectedPlan[20])
			if (parent.parent.EMP_CONT_TYPE=="P")
				bod += getSeaPhrase("PER","BEN")
			bod += '</td>'
		}
		if (parent.parent.SelectedPlan[18]!="")
		{
			head += '<th scope="col" class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("EMPLOYEE_COST","BEN")+'</th>'
			bod += '<td class="plaintablecellborder" style="text-align:center" nowrap>'+parent.parent.formatCont(parent.parent.SelectedPlan[18])
			if (parent.parent.EMP_CONT_TYPE=="P")
				bod += getSeaPhrase("PER","BEN")
			bod += '</td>'
		}
		if (parent.parent.SelectedPlan[24]!="")
		{
			head += '<th scope="col" class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("CO_COST","BEN")+'</th>'
			bod += '<td class="plaintablecellborder" style="text-align:center" nowrap>'+parent.parent.formatCont(parent.parent.SelectedPlan[24])
			if (parent.parent.EMP_CONT_TYPE=="P")
				bod += getSeaPhrase("PER","BEN")
			bod += '</td>'
		}
		html += head+'</tr>'
		html += bod+'</tr>'
		html += '</table>'
		html += '<br/><table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" style="width:100%;margin-left:auto;margin-right:auto" styler="list" summary="'+getSeaPhrase("TSUM_17","BEN",[parent.parent.EligPlans[parent.parent.CurrentEligPlan][4]])+'">'
		head += '<caption class="offscreen">'+getSeaPhrase("TCAP_14","BEN",[parent.parent.EligPlans[parent.parent.CurrentEligPlan][4]])+'</caption>'
		html += '<tr><th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("MIN","BEN")+'</th>'
		if (parent.parent.formatCont2(max) != 0)
			html += '<th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("MAX","BEN")+'</th>'
		html += '</tr><tr><td class="plaintablecellborder" style="text-align:center">'+parent.parent.formatCont2(min)+'</td>'
		if (parent.parent.formatCont2(max) != 0)
			html += '<td class="plaintablecellborder" style="text-align:center">'+parent.parent.formatCont2(max)+'</td>'
		html += '</tr></table><br/>'
		html += '<form name="CovAmt" onsubmit="return false">'
		html += '<table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" style="width:auto" role="presentation">'
		html += '<tr><td class="plaintablecell"><label for="cov">'+getSeaPhrase("ELECTBEN_11","BEN")+'</label></td><td class="plaintablecell">'
		html += '<input class="inputbox" type="text" id="cov" name="cov" size="10">'
		html += '</td></tr></table>'
		html += footer(parent.parent.SelectedPlan[15],parent.parent.SelectedPlan[16])
		html += '</form></div>'
		document.getElementById("paneBody").innerHTML = html;
		document.getElementById("paneHeader").innerHTML = getSeaPhrase("BEN_ELECT","BEN")+' - '+parent.parent.EligPlans[parent.parent.CurrentEligPlan][8];
	}
	stylePage();
	document.body.style.visibility = "visible";
	parent.parent.stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[getWinTitle()]));
	parent.fitToScreen();
}

function footer(precont,defaul)
{
	var footHtml = '<div>'
	if (precont=="P"||precont=="N"||precont=="A")
	{
		if (precont=="P")
		{
			parent.parent.setpreaft_flag("P");
			//footHtml += ' '+getSeaPhrase("ELECTBEN_3","BEN")
		}
		else if (precont=="A")
		{
			parent.parent.setpreaft_flag("A");
			//footHtml += ' '+getSeaPhrase("ELECTBEN_4","BEN")
		}
		else if (precont=="N")
		{
			parent.parent.setpreaft_flag("");
			//footHtml += ' '+getSeaPhrase("ELECTBEN_7","BEN")
		}
	}
	else
	{
		footHtml += '<div role="radiogroup" aria-labelledby="howLbl">'
		if (defaul=="P")
		{
			parent.parent.setpreaft_flag("P")
			footHtml += '<span id="howLbl">'+getSeaPhrase("ELECTBEN_6","BEN")+'</span> '
			footHtml += '<input class="inputbox" type="radio" id="pretax" name="preaft" value="pre" onclick="parent.parent.setpreaft_flag(\'P\');styleElement(this);" checked><label for="pretax">'+getSeaPhrase("PRE_TAX","BEN")+'</label>'
			footHtml += '<input class="inputbox" type="radio" id="afttax" name="preaft" value="aft" onclick="parent.parent.setpreaft_flag(\'A\');styleElement(this);"><label for="afttax">'+getSeaPhrase("AFTER_TAX","BEN")+'</label>'
		}
		else
		{
			if (defaul=="A")
			{
				parent.parent.setpreaft_flag("A")
				footHtml += '<span id="howLbl">'+getSeaPhrase("ELECTBEN_6","BEN")+'</span> '
				footHtml += '<input class="inputbox" type="radio" id="pretax" name="preaft" value="pre" onclick="parent.parent.setpreaft_flag(\'P\');styleElement(this);"><label for="pretax">'+getSeaPhrase("PRE_TAX","BEN")+'</label>'
				footHtml += '<input class="inputbox" type="radio" id="afttax" name="preaft" value="aft" onclick="parent.parent.setpreaft_flag(\'A\');styleElement(this);" checked><label for="afttax">'+getSeaPhrase("AFTER_TAX","BEN")+'</label>'
			}
			else
			{
				parent.parent.setpreaft_flag("")
				footHtml += '<span id="howLbl">'+getSeaPhrase("ELECTBEN_6","BEN")+'</span> '
				footHtml += '<input class="inputbox" type="radio" id="pretax" name="preaft" value="pre" onclick="parent.parent.setpreaft_flag(\'P\');styleElement(this);"><label for="pretax">'+getSeaPhrase("PRE_TAX","BEN")+'</label>'
				footHtml += '<input class="inputbox" type="radio" id="afttax" name="preaft" value="aft" onclick="parent.parent.setpreaft_flag(\'A\');styleElement(this);"><label for="afttax">'+getSeaPhrase("AFTER_TAX","BEN")+'</label>'
			}
		}
		footHtml += '</div>'
	}
	footHtml += '<table border="0" cellspacing="0" cellpadding="0" style="width:100%;margin-left:auto;margin-right:auto" role="presentation">'
	footHtml += '<tr><td class="plaintablecellright">' 
// MOD BY BILAL
//	footHtml += uiButton(getSeaPhrase("CONTINUE","BEN"),"checkLimits(this.form);return false","margin-top:10px")
	footHtml += uiButton(getSeaPhrase("CONTINUE","BEN"),"checkLimits(this.form);return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")

	if (parent.parent.LastDoc[parent.parent.currentdoc]!=null)
		footHtml += uiButton(getSeaPhrase("PREVIOUS","BEN"),"parent.parent.document.getElementById('main').src='"+parent.parent.LastDoc[parent.parent.currentdoc]+"';parent.parent.currentdoc--;return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px;margin-left:10px")
//		footHtml += uiButton(getSeaPhrase("PREVIOUS","BEN"),"parent.parent.document.getElementById('main').src='"+parent.parent.LastDoc[parent.parent.currentdoc]+"';parent.parent.currentdoc--;return false","margin-top:10px;margin-left:5px")
	footHtml += uiButton(getSeaPhrase("EXIT","BEN"),"parent.parent.quitEnroll(parent.location);return false","margin-top:10px;margin-left:5px",null,'aria-haspopup="true"')
	footHtml += '</tr></table></div>'
	return footHtml;
}

function checkLimits(frm)
{
	var msg=""
	// PT 103857
	// regular expression of floating point number, for better understanding
	// /^
	// [+-]?
	// (
	// ( (\d|(\d\d)|(\d\d\d)) (((\d\d\d)*)|((,\d\d\d)*)) )
	// | (\.\d+) |
	// ( (\d|(\d\d)|(\d\d\d)) (((\d\d\d)*)|((,\d\d\d)*)) (\.\d+) )
	// )
	// ([eE][+-]?\d+)?
	// $/
	regExp = /^[+-]?(((\d|(\d\d)|(\d\d\d))(((\d\d\d)*)|((,\d\d\d)*)))|(\.\d+)|((\d|(\d\d)|(\d\d\d))(((\d\d\d)*)|((,\d\d\d)*))(\.\d+)))([eE][+-]?\d+)?$/
	var prevalue = frm.cov.value;
	if (prevalue.search(regExp) == -1) 
	{
		// value string doesn't match regular expression, not a number
		msg = getSeaPhrase("ELECTBEN_8","BEN");
	} 
	else 
	{
		var value = parseFloat(prevalue.split(",").join(""));
		if (isNaN(value))
			msg = getSeaPhrase("ELECTBEN_8","BEN");
		else if ((max != 0 && value > max) || value < min)
			msg = (getSeaPhrase("ELECTBEN_9","BEN")+" "+parent.parent.formatCont(min)+" - "+parent.parent.formatCont(max));
		else if (!parent.parent.DividesEvenly(value,CVR_INCREMENT))
		 	msg = (getSeaPhrase("ELECTBEN_10","BEN")+" "+parent.parent.roundToPennies(CVR_INCREMENT));
	}
	if (msg != "")
		parent.parent.seaAlert(msg, null, null, "error");
	else
	{
		calccost(value,CVR_INCREMENT);
		parent.parent.SelectedPlan[17] = value;
		parent.parent.SelectedPlan[18] = emp;
		parent.parent.SelectedPlan[20] = flex;
		parent.parent.SelectedPlan[24] = comp;
		parent.setBenefit(parent.parent.SelectedPlan[15]);
	}
}

function doParseFloat(str)
{
	if (str)
		return parseFloat(str);
	else
		return 0;
}

function calccost(cover, increment)
{
	if (PRE_CONTRIB_BASIS=="C")
	{
		var rate = (cover/increment);
		flex = flex * rate;
		emp = emp * rate;
		comp = comp*rate;
		if (flex != 0)
			flex = parent.parent.roundToPennies(flex);
		if (emp != 0)
			emp = parent.parent.roundToPennies(emp);
		if (comp != 0)
			comp = parent.parent.roundToPennies(comp);
	}
	return;
}
</script>
</head>
<body onload="setLayerSizes();startProgram()" style="visibility:hidden">
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
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/elect_ben_04.htm,v 1.12.2.42 2014/02/25 22:49:14 brentd Exp $ -->
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