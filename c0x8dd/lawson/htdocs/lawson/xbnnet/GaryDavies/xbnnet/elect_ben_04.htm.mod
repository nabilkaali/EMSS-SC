<html>
<head>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<link rel="alternate stylesheet" type="text/css" id="ui" title="classic" href="/lawson/xhrnet/ui/ui.css"/>
<link rel="alternate stylesheet" type="text/css" id="uiLDS" title="lds" href="/lawson/webappjs/lds/css/ldsEMSS.css"/>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script type="text/javascript" src="/lawson/xhrnet/ui/ui.js"></script>
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
	REC_TYPE=parent.parent.EligPlans[parent.parent.CurrentEligPlan][6]
	if(tmp)
	{
		if(tmp!=true)
		{
			var tmpmax=0
			tmpmax=parseInt(tmp/doParseFloat(parent.parent.SelectedPlan[35]),10)
			tmpmax=tmpmax*doParseFloat(parent.parent.SelectedPlan[35])
			if(tmpmax<max)
				max=tmpmax
		}

		precont = parent.parent.SelectedPlan[15];
		defaul = parent.parent.SelectedPlan[16];

		var costsStr = '';
		if(precont=="P"||precont=="N"||precont=="A")
		{
			if(precont=="P")
			{
				costsStr += getSeaPhrase("ELECTBEN_3","BEN")
			}
			if(precont=="A")
			{
				costsStr += getSeaPhrase("ELECTBEN_4","BEN")
			}
			if(precont=="N")
			{
				costsStr += getSeaPhrase("ELECTBEN_7","BEN")
			}
		}

		var html = '';
		html += '<div class="plaintablecell" style="padding:10px">'
		// MOD BY BILAL
		html += '<center>'
		// END OF MOD
		html += parent.header('<br>'+costsStr)

		head += '<table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" styler="list">'
		head += '<TR><TH class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("ELECTBEN_33","BEN")+'</TH>'
		bod+='<TR><TD class="plaintablecellborder" style="text-align:center">'+parent.parent.formatCont(parent.parent.SelectedPlan[35])
		if(parent.parent.SelectedPlan[20]!="")
		{
			head+='<TH class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("FLEX_CR","BEN")+'</TH>'
			bod+='<TD class="plaintablecellborder" style="text-align:center" nowrap>'+parent.parent.formatCont(parent.parent.SelectedPlan[20])
			if(parent.parent.EMP_CONT_TYPE=="P")
				bod+=getSeaPhrase("PER","BEN")
			bod+='</TD>'
		}

		if(parent.parent.SelectedPlan[18]!="")
		{
			head+='<TH class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("EMPLOYEE_COST","BEN")+'</TH>'
			bod+='<TD class="plaintablecellborder" style="text-align:center" nowrap>'+parent.parent.formatCont(parent.parent.SelectedPlan[18])
			if(parent.parent.EMP_CONT_TYPE=="P")
				bod+=getSeaPhrase("PER","BEN")
			bod+='</TD>'
		}

		if(parent.parent.SelectedPlan[24]!="")
		{
			head+='<TH class="plaintableheaderborder" style="text-align:center" nowrap>'+getSeaPhrase("CO_COST","BEN")+'</TH>'
			bod+='<TD class="plaintablecellborder" style="text-align:center" nowrap>'+parent.parent.formatCont(parent.parent.SelectedPlan[24])
			if(parent.parent.EMP_CONT_TYPE=="P")
				bod+=getSeaPhrase("PER","BEN")
			bod+='</TD>'
		}

		html += head + '</TR>'
		html += bod + '</TR>'
		html += '</table><br>'

		html += '<table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" styler="list">'
		html += '<TR><TH class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("MIN","BEN")+'</TH>'
		if (parent.parent.formatCont2(max) != 0)
			html += '<TH class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("MAX","BEN")+'</TH>'
		html += '<TR><TD class="plaintablecellborder" style="text-align:center">'+parent.parent.formatCont2(min)+'</TD>'
		if (parent.parent.formatCont2(max) != 0)
			html += '<TD class="plaintablecellborder" style="text-align:center">'+parent.parent.formatCont2(max)+'</TD>'
		html += '</table><br>'

		html += '<form name=CovAmt onsubmit="return false">'
		html += '<span class="plaintablecell">'+getSeaPhrase("ELECTBEN_11","BEN")+'</span>'
		html += '<input class="inputbox" type=Text name=cov size=10>'

		html += footer(parent.parent.SelectedPlan[15],parent.parent.SelectedPlan[16])
		// MOD BY BILAL
		html += '</center>'
		// END OF MOD
		html += '</div>'

		parent.parent.removeWaitAlert();
		if (typeof(parent.parent.parent.removeWaitAlert) != "undefined") {
			parent.parent.parent.removeWaitAlert();
		}
		document.getElementById("paneBody").innerHTML = html
		document.getElementById("paneHeader").innerHTML = '<span>'+getSeaPhrase("BEN_ELECT","BEN")+' - '+parent.parent.EligPlans[parent.parent.CurrentEligPlan][8]+'</span>';
	}
	stylePage();
	document.body.style.visibility = "visible";
}

function footer(precont,defaul)
{
	var footHtml = ""
	footHtml += '<span class="plaintablecell">'
	if(precont=="P"||precont=="N"||precont=="A")
	{
		if(precont=="P")
		{
			parent.parent.setpreaft_flag("P")
			//footHtml += '<BR>'+getSeaPhrase("ELECTBEN_3","BEN")
		}
		if(precont=="A")
		{
			parent.parent.setpreaft_flag("A")
			//footHtml += '<BR>'+getSeaPhrase("ELECTBEN_4","BEN")
		}
		if(precont=="N")
		{
			parent.parent.setpreaft_flag("")
			//footHtml += '<BR>'+getSeaPhrase("ELECTBEN_7","BEN")
		}
	}
	else
	{
		if(defaul=="P")
		{
			parent.parent.setpreaft_flag("P")
			footHtml += getSeaPhrase("ELECTBEN_6","BEN")+' '
			footHtml += '<INPUT class="inputbox" TYPE=radio name=preaft value=pre onClick=parent.parent.setpreaft_flag("P") CHECKED>'+getSeaPhrase("PRE_TAX","BEN")
			footHtml += '<INPUT class="inputbox" TYPE=radio name=preaft value=aft onClick=parent.parent.setpreaft_flag("A")>'+getSeaPhrase("AFTER_TAX","BEN")
		}
		else
		{
			if(defaul=="A")
			{
				parent.parent.setpreaft_flag("A")
				footHtml += getSeaPhrase("ELECTBEN_6","BEN")+' '
				footHtml += '<INPUT class="inputbox" TYPE=radio name=preaft value=pre onClick=parent.parent.setpreaft_flag("P")>'+getSeaPhrase("PRE_TAX","BEN")
				footHtml += '<INPUT class="inputbox" TYPE=radio name=preaft value=aft onClick=parent.parent.setpreaft_flag("A") CHECKED>'+getSeaPhrase("AFTER_TAX","BEN")
			}
			else
			{
				parent.parent.setpreaft_flag("")
				footHtml += getSeaPhrase("ELECTBEN_6","BEN")+' '
				footHtml += '<INPUT class="inputbox" TYPE=radio name=preaft value=pre onClick=parent.parent.setpreaft_flag("P")>'+getSeaPhrase("PRE_TAX","BEN")
				footHtml += '<INPUT class="inputbox" TYPE=radio name=preaft value=aft onClick=parent.parent.setpreaft_flag("A")>'+getSeaPhrase("AFTER_TAX","BEN")
			}
		}
	}
// MOD BY BILAL
//	footHtml += '<br><table border="0" cellspacing="0" cellpadding="0">'
//	footHtml += '<tr><td class="plaintablecell">'
	footHtml += '<br><center><table border="0" cellspacing="0" cellpadding="0">'
	footHtml += '<tr><td class="plaintablecell" align="center">'
//	footHtml += uiButton(getSeaPhrase("CONTINUE","BEN"),"checkLimits(this.form);return false","margin-top:10px")
	footHtml += uiButton(getSeaPhrase("CONTINUE","BEN"),"checkLimits(this.form);return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
	if(parent.parent.LastDoc[parent.parent.currentdoc]!=null)
	{
//		footHtml += uiButton(getSeaPhrase("PREVIOUS","BEN"),"parent.parent.document.getElementById('main').src='"+parent.parent.LastDoc[parent.parent.currentdoc]+"';parent.parent.currentdoc--;return false","margin-top:10px")
		footHtml += uiButton(getSeaPhrase("PREVIOUS","BEN"),"parent.parent.document.getElementById('main').src='"+parent.parent.LastDoc[parent.parent.currentdoc]+"';parent.parent.currentdoc--;return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px;margin-left:10px")
	}
//	footHtml += uiButton(getSeaPhrase("EXIT","BEN"),"parent.parent.quitEnroll(parent.location);return false","margin-top:10px")
	footHtml += uiButton(getSeaPhrase("EXIT","BEN"),"parent.parent.quitEnroll(parent.location);return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px;margin-left:10px")
// END OF MOD
// MOD BY BILAL - Prior Customization
		// JRZ custom wording for insurance plans with record type 04
		var currentCode = escape(parent.parent.EligPlans[parent.parent.CurrentEligPlan][2],1);
		if( (parent.parent.company == 1 && (currentCode == "ELSP" || currentCode == "DLSS" || currentCode == "DLSC")) ) {
			footHtml +='<p>Deductions are taken once per month rather than every pay period.  However, the above deduction is a per pay period amount.</p>';
		}
		//~JRZ		
// END OF MOD
	footHtml += '</tr>'
	footHtml += '</table>'
// MOD BY BILAL
	footHtml += '</center>'
// END OF MOD
	footHtml += '</form>'
	footHtml += '</span>'

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
	if (prevalue.search(regExp) == -1) {
		// value string doesn't match regular expression, not a number
		msg=getSeaPhrase("ELECTBEN_8","BEN");
	} else {
		var value=parseFloat(prevalue.split(",").join(""));
		if(isNaN(value))
			msg=getSeaPhrase("ELECTBEN_8","BEN")
		else if((max != 0 && value > max) || value < min)
			msg=(getSeaPhrase("ELECTBEN_9","BEN")+" "+parent.parent.formatCont(min)+" - "+parent.parent.formatCont(max))
		else if(!parent.parent.DividesEvenly(value,CVR_INCREMENT))
		 	msg=(getSeaPhrase("ELECTBEN_10","BEN")+" "+parent.parent.roundToPennies(CVR_INCREMENT))
	}
	
	if(msg!="")
		parent.parent.seaAlert(msg)
	else
	{
		calccost(value,CVR_INCREMENT)
		parent.parent.SelectedPlan[17]=value
		parent.parent.SelectedPlan[18]=emp
		parent.parent.SelectedPlan[20]=flex
		parent.parent.SelectedPlan[24]=comp
		parent.setBenefit(parent.parent.SelectedPlan[15])
	}
}

function doParseFloat(str)
{
	if (str)
		return parseFloat(str)
	else
		return 0
}

function calccost(cover,increment)
{
	if(PRE_CONTRIB_BASIS=="C")
	{
		var rate=(cover/increment)
		flex=flex*rate
		emp=emp*rate
		comp=comp*rate
		if(flex!=0)
			flex=parent.parent.roundToPennies(flex)
		if(emp!=0)
			emp=parent.parent.roundToPennies(emp)
		if(comp!=0)
			comp=parent.parent.roundToPennies(comp)
	}
	return
}
</script>
</head>
<body onload="setLayerSizes();startProgram()" style="visibility:hidden">
<div id="paneBorder" class="paneborder">
	<table id="paneTable" border="0" height="100%" width="100%" cellpadding="0" cellspacing="0">
	<tr><td style="height:16px">
		<div id="paneHeader" class="paneheader">&nbsp;</div>
	</td></tr>
	<tr><td>
		<div id="paneBodyBorder" class="panebodyborder" styler="groupbox"><div id="paneBody" class="panebody"></div>
		</div>
	</td></tr>
	</table>
</div>
</body>
</html>
<!-- Version: 8-)@(#)@(201111) 09.00.01.06.09 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/elect_ben_04.htm,v 1.12.2.12.6.1 2012/03/12 06:12:46 juanms Exp $ -->
