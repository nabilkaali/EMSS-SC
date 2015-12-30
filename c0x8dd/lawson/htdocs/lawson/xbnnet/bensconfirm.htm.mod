<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<title>Confirm Your Benefit Plan Choices</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script>
var REC_TYPE = parent.EligPlans[parent.CurrentEligPlan][6];
var intMessage = parent.msgNbr;
var changedte = "";
var coverage;
var planDesc = "";
var head = "";
var bod = "";
var bod2 = "";
parent.flg = 0;
parent.Ycost = 0;
parent.Fcost = 0;
parent.Ccost = 0;
parent.Pcost = 0;
parent.flexflag = 0;
parent.empflag = 0;
parent.compflag = 0;
parent.empcost = 0;
parent.empprecost = 0;
parent.empaftcost = 0;
parent.compcost = 0;
parent.flexcost = 0;
parent.taxable = "";
function initProgram()
{
	setWinTitle(getSeaPhrase("CONFIRM_CHOICES","BEN"));
	parent.startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), startProgram);
}
function startProgram()
{
	if (parent.event == "annual") 
	{
		if (parent.actiontaken == 3)
			changedte = parent.FormatDte4(parent.setStopDate(parent.BenefitRules[2]));
		else
			changedte = parent.FormatDte4(parent.BenefitRules[2]);
	} 
	else if (parent.rule_type == "N")
		changedte = parent.FormatDte4(parent.EligPlans[parent.CurrentEligPlan][5]);
	else 
	{
		if (parent.actiontaken == 1)
			changedte = parent.FormatDte4(parent.EligPlans[parent.CurrentEligPlan][11]);
		else if (parent.actiontaken == 2 || parent.actiontaken == 4 || parent.actiontaken == 5)
			changedte = parent.FormatDte4(parent.EligPlans[parent.CurrentEligPlan][13]);
		else if (parent.actiontaken==3)
			changedte = parent.FormatDte4(parent.setStopDate(parent.EligPlans[parent.CurrentEligPlan][15]));
		else
			changedte = parent.FormatDte4(parent.BenefitRules[2]);
	}
	bod += '';
	if (parent.updatetype == "CRT" || parseInt(REC_TYPE,10) == 1) 
	{
		parent.updatetype = "CRT";
		parent.SelectedPlan[parent.choice][3] = parent.preaft_flag;
		getPlanDetails(parent.SelectedPlan[parent.choice]);
	}
	else if (parent.updatetype == "CRT2" || (1 < parseInt(REC_TYPE,10) && parseInt(REC_TYPE,10) < 6) || parseInt(REC_TYPE,10) == 13)
	{
		parent.updatetype = "CRT2";
		parent.SelectedPlan[15] = parent.preaft_flag;
		getPlanDetails(parent.SelectedPlan);
	}
	else if (parent.updatetype == "CRT3" || (5 < parseInt(REC_TYPE,10) && parseInt(REC_TYPE,10) < 11)) 
	{
		parent.updatetype = "CRT3";
		parent.SelectedPlan[26] = parent.preaft_flag;
		getPlanDetails(parent.SelectedPlan);
	}
	head += '<br/><table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" style="width:100%;margin-left:auto;margin-right:auto" styler="list" summary="'+getSeaPhrase("TSUM_3","BEN",[planDesc])+'">'
	head += '<caption class="offscreen">'+getSeaPhrase("TCAP_2","BEN",[planDesc])+'</caption>' 
	head += '<tr><th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("PLAN","BEN")+'</th>'
	var covLbl = getSeaPhrase("COVERAGE","BEN");
	if (parent.updatetype == "CRT3")
	{
		if (parseFloat(parent.SelectedPlan[0]) == 8 || parseFloat(parent.SelectedPlan[0]) == 9)
			covLbl = getSeaPhrase("CONTRIBUTION","BEN");
		else if (parseFloat(parent.SelectedPlan[0]) == 10)
			covLbl = '&nbsp;';
		else if (parseFloat(parent.SelectedPlan[0]) == 12)
		{
			//HL and DN plans display coverage of "Waive"; others do not display a coverage column
			if ((parent.SelectedPlan[1] == "HL" || parent.SelectedPlan[1] == "DN") && parent.SelectedPlan[65] == "Y")
				covLbl = getSeaPhrase("COVERAGE","BEN");
			else
				covLbl = '&nbsp;';
		}	
	}
	head += '<th class="plaintableheaderborder" style="text-align:center">'+covLbl+'</th>'
	head += '<th class="plaintableheaderborder" style="text-align:center">'
	if (parent.flexflag!=0)
		head += getSeaPhrase("FLEX_CR","BEN")
	else
		head += '&nbsp;'
	head += '</th>'
	// Add a spacer column for display
	head += '<th class="plaintableheaderborder">&nbsp;</th>'	
	head += '<th class="plaintableheaderborder" style="text-align:center" colspan="2">'
	if (parent.empflag != 0)
		head += getSeaPhrase("COST","BEN");
	else
		head += '&nbsp;';
// MOD BY BILAL - reducing width
//	head += '</th><th class="plaintableheaderborder" style="text-align:center">'
	head += '</th><th class="plaintableheaderborder" style="text-align:center" width="5%" nowrap>'
// END OF MOD
	if (parent.compflag!=0)
		head += getSeaPhrase("CO_COST","BEN");
	else
		head += '&nbsp;';
	head += '</th></tr>'
	bod2 += '</table>'
	var cov1 = parent.EligPlanGroups[parent.CurrentPlanGroup][0];
	var cov;
	if (parent.msgNbr == 2 || parent.msgNbr == 3 || parent.msgNbr == 5)
		cov = parent.CurrentBens[parent.planname][5];
	if (parent.msgNbr == 1 || parent.msgNbr == 99)
		cov = parent.EligPlans[parent.CurrentEligPlan][4];
	var nme = parent.removespace(parent.EligPlans[parent.CurrentEligPlan][1]+parent.EligPlans[parent.CurrentEligPlan][2]);
	var strMessage = "";
	// MOD BY BILAL
	var strMessageCust=""
	if (intMessage == 2 || intMessage == 5)
		strMessageCust = getSeaPhrase("CONBEN_1","BEN")+' ';	 // Variable Changed by Bilal
	else if (intMessage == 1 || intMessage == 99)
		strMessageCust = getSeaPhrase("CONBEN_2","BEN")+' ';	 // Variable Changed by Bilal
	else if (intMessage == 3)
		strMessageCust = getSeaPhrase("CONBEN_3","BEN")+' ';	 // Variable Changed by Bilal
	// END OF MOD
// MOD BY BILAL
	var titleLbl = cov+' - '+getSeaPhrase("VIEW_PLAN_DESC","BEN")+' '+getSeaPhrase("OPENS_WIN","SEA");
//	strMessage += '<a href="javascript:;" onclick="parent.openWinDesc2(\''+parent.EligPlans[parent.CurrentEligPlan][1]+'\',\''+parent.EligPlans[parent.CurrentEligPlan][2]+'\');return false" title="'+titleLbl+'" aria-haspopup="true">'+cov+'<span class="offscreen"> - '+titleLbl+'</span></a>.'
	strMessageCust += '<font color=red><b>'+ cov + '</b></font>' + ' '
	strMessageCust += '<a href="" onclick="parent.openWinDesc2(\''+parent.EligPlans[parent.CurrentEligPlan][1]+'\',\''+parent.EligPlans[parent.CurrentEligPlan][2]+'\');return false">View Description</a>.<br>'
// END OF MOD
	if(intMessage!=3) {
// MOD BY BILAL - Prior customization

			// JRZ adding annual cost change for Air St. Luke's
		if(!parent.noCosts) {
			if(REC_TYPE=="08" || REC_TYPE=="09")
				strMessage += ' '+parent.costdivisor+'<br>'
// MOD BY BILAL
			else if(currentPlanCode == "AIR")
				strMessage += '<BR>Costs are per year, taken as a one time paycheck deduction.'
//			else
//				strMessage += ' '+parent.costdivisor+'<br>'
// END OF MOD
		}
			//~JRZ
	}
	if(parent.actiontaken==3)
		strMessage += ' '+getSeaPhrase("CONBEN_4","BEN")+' '+changedte+'.'
	else if(parent.rule_type=="N")
		strMessage += ' '+getSeaPhrase("CONBEN_5","BEN")+' '+changedte+'.'
	else
		strMessage += ' '+getSeaPhrase("CONBEN_6","BEN")+' '+changedte+'.'
	var html = '<div style="padding:10px"><center>'
// MOD BY BILAL
//	html += '<table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" width="80%">'
	html += strMessageCust
	html += '<br><br><center><table class="plaintableborder" border="0" cellpadding="0" cellspacing="0" width="60%">'
// END OF MOD 
// MOD BY BILAL	-	Hiding the Blank Header Line.
//	html += '<tr><td class="plaintableheaderborder">&nbsp;</td></tr>'
// END OF MOD
	html += '<tr><td class="plaintablecellborder">'+strMessage+'</td></tr>'
	html += '</table><br>'
// MOD BY BILAL - Prior Customization
	var currentPlanCode = escape(parent.EligPlans[parent.CurrentEligPlan][2],1);
	if (intMessage != 3) 
	{
		// JRZ adding annual cost change for Air St. Luke's
		if (!parent.noCosts) 
		{
			if (REC_TYPE == "08" || REC_TYPE == "09")  
			{
				costStr = parent.costdivisor.split("Costs")
				strMessage +='<BR>Contributions'+costStr[1]
			}
			else if(currentPlanCode == "AIR") {
				strMessage +='<BR>Costs are per year, taken as a one time paycheck deduction.';
			}
			else
				strMessage += ' '+parent.costdivisor+' ';
		}
		//~JRZ
	}  
// END OF MOD
// CGL 10/20/2014 - REMOVE DUPLICATE SET OF STRMESSAGE, CAUSING DOUBLE TEXT ON PAGE
//	if (parent.actiontaken == 3)
//		strMessage += ' '+getSeaPhrase("CONBEN_4","BEN")+' '+changedte+'.';
//	else if (parent.rule_type == "N")
//		strMessage += ' '+getSeaPhrase("CONBEN_5","BEN")+' '+changedte+'.';
//	else
//		strMessage += ' '+getSeaPhrase("CONBEN_6","BEN")+' '+changedte+'.';
// CGL 10/20/2014 - END OF MOD
	var html = '<div style="padding:0px">'
	html += '<br/><table border="0" cellpadding="0" cellspacing="0" style="width:100%;margin-left:auto;margin-right:auto" role="presentation">'
	html += '<tr><td class="plaintablecell">'+strMessage+'</td></tr></table>'	
	if (intMessage != 3)
		html += head + bod + bod2;
	html += parent.writeDepPortion(changedte, planDesc);
	//html += '<p class="plaintablecell">'+getSeaPhrase("CORRECT?","BEN")+'</p>'
	html += '<p class="textAlignRight">'
// MOD BY BILAL  - Adding Style to the button as per St. Luke.
	//html += uiButton(getSeaPhrase("CONTINUE","BEN"), "setben();return false", "margin-right:5px;margin-top:10px")
	html += uiButton(getSeaPhrase("CONTINUE","BEN"), "setben();return false", "font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
	if (parent.LastDoc[parent.currentdoc] != null)
		html += '&nbsp;&nbsp;' + uiButton(getSeaPhrase("PREVIOUS","BEN"), "back();return false", "font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
		//html += uiButton(getSeaPhrase("PREVIOUS","BEN"), "back();return false", "margin-right:5px;margin-top:10px")
	html += "&nbsp;&nbsp;"
	//html += uiButton(getSeaPhrase("ELECTIONS","BEN"), "parent.printScr('newwindow');return false", "margin-right:5px;margin-top:10px", null, 'aria-haspopup="true"', getSeaPhrase("VIEW_ELECTIONS","BEN")+' '+getSeaPhrase("OPENS_WIN","SEA"))
	html += uiButton(getSeaPhrase("ELECTIONS","BEN"), "parent.printScr('newwindow');return false", "font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px", null, 'aria-haspopup="true"', getSeaPhrase("VIEW_ELECTIONS","BEN")+' '+getSeaPhrase("OPENS_WIN","SEA"))
// END OF MOD
	html += '</p></div>' 
// MOD BY BILAL - Prior customization
		// JRZ display different disclaimers based on plan
    if(parent.SLRMC.isEPOPlan(parent.company,currentPlanCode)) {
      html += parent.SLRMC.EPOReminder(parent.rule_type)
    }
		//~JRZ
// END OF MOD
	document.getElementById("paneBody").innerHTML = html;
	document.getElementById("paneHeader").innerHTML = getSeaPhrase("BEN_ELECT","BEN")+' - '+cov1;
	stylePage();
	document.body.style.visibility = "visible";
	parent.stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[getWinTitle()]));
	parent.fitToScreen();
}
function getPlanDetails(arr)
{
	if (parseFloat(parent.msgNbr) == 2 || parseFloat(parent.msgNbr) == 5)
		planDesc = parent.CurrentBens[parent.planname][5];
	else if (parseFloat(parent.msgNbr) == 1 || parseFloat(parent.msgNbr) == 99)
		planDesc = parent.EligPlans[parent.CurrentEligPlan][4];
	if (parent.updatetype == "CRT")
		arr[0] = "01";
	bod += parent.getCoverage(arr,arr[0],planDesc);
}
function back()
{
 	parent.document.getElementById("main").src = parent.LastDoc[parent.currentdoc];
 	parent.currentdoc--;
}
function setben()
{
	if (parent.msgNbr != 3) 
	{
		parent.selectedPlanInGrp[parent.CurrentEligPlan] = true;
		parent.ElectedPlans[parent.ElectedPlans.length] = new Array();
		if (parent.msgNbr == 2 || parent.msgNbr == 5) 
		{
			parent.ElectedPlans[parent.ElectedPlans.length-1][0] = parent.CurrentBens[parent.planname][22];
			parent.ElectedPlans[parent.ElectedPlans.length-1][1] = parent.CurrentBens[parent.planname][5];
			parent.ElectedPlans[parent.ElectedPlans.length-1][3] = parent.CurrentBens[parent.planname][32];
			parent.ElectedPlans[parent.ElectedPlans.length-1][4] = parent.formjsDate(changedte);
			parent.ElectedPlans[parent.ElectedPlans.length-1][5] = parent.formjsDate(changedte);
			if (!parent.CurrentBens[parent.planname][0] && parent.CurrentBens[parent.planname][1] == parent.EligPlans[parent.CurrentEligPlan][1] 
			&& parent.CurrentBens[parent.planname][2] == parent.EligPlans[parent.CurrentEligPlan][2]) 
			{
				parent.CurrentBens[parent.planname][0] = new Array();
				parent.CurrentBens[parent.planname][0][0] = parent.msgNbr;
				parent.CurrentBens[parent.planname][0][1] = parent.EligPlans[parent.CurrentEligPlan][11];
				parent.CurrentBens[parent.planname][0][2] = parent.EligPlans[parent.CurrentEligPlan][13];
				parent.CurrentBens[parent.planname][0][3] = parent.EligPlans[parent.CurrentEligPlan][15];
				parent.CurrentBens[parent.planname][0][4] = parent.formjsDate(changedte);
			}
		}
		else if (parent.msgNbr == 1 || parent.msgNbr == 99) 
		{
			parent.ElectedPlans[parent.ElectedPlans.length-1][0] = parent.EligPlans[parent.CurrentEligPlan][6];
			parent.ElectedPlans[parent.ElectedPlans.length-1][1] = parent.EligPlans[parent.CurrentEligPlan][4];
			parent.ElectedPlans[parent.ElectedPlans.length-1][3] = parent.EligPlans[parent.CurrentEligPlan][8];
			if (parent.rule_type == "N")
				parent.ElectedPlans[parent.ElectedPlans.length-1][5] = parent.EligPlans[parent.CurrentEligPlan][5];
			else
				parent.ElectedPlans[parent.ElectedPlans.length-1][5] = parent.formjsDate(changedte);
		}
		if (parent.updatetype == "CRT") 
		{
			parent.ElectedPlans[parent.ElectedPlans.length-1][2] = parent.SelectedPlan[parent.choice];
			setdepBens();
		}
		else if (parent.updatetype == "CRT2")
		{
			parent.ElectedPlans[parent.ElectedPlans.length-1][2] = parent.SelectedPlan;
			setdepBens();
		}
		else if (parent.updatetype == "CRT3")
			parent.ElectedPlans[parent.ElectedPlans.length-1][2] = parent.SelectedPlan;
		parent.ElectedPlans[parent.ElectedPlans.length-1][4] = new Array();
		parent.ElectedPlans[parent.ElectedPlans.length-1][4][0] = parent.actiontaken;
		parent.ElectedPlans[parent.ElectedPlans.length-1][4][1] = parent.EligPlans[parent.CurrentEligPlan][11];
		parent.ElectedPlans[parent.ElectedPlans.length-1][4][2] = parent.EligPlans[parent.CurrentEligPlan][13];
		parent.ElectedPlans[parent.ElectedPlans.length-1][4][3] = parent.EligPlans[parent.CurrentEligPlan][15];
		if (parent.status == "C")	
		{
			parent.changedPlan = true;
			parent.ElectedPlans[parent.ElectedPlans.length-1][6] = true;
		} 
		else
			parent.ElectedPlans[parent.ElectedPlans.length-1][6] = false;
		parent.ElectedPlans[parent.ElectedPlans.length-1][7] = parent.EligPlans[parent.CurrentEligPlan][24];
		parent.ElectedPlans[parent.ElectedPlans.length-1][8] = parent.EligPlans[parent.CurrentEligPlan][25];
		parent.ElectedPlans[parent.ElectedPlans.length-1][9] = parent.EligPlans[parent.CurrentEligPlan][26];
	} 
	else 
	{
		//alert("// elected to stop plan")
		if (parent.status == "C")
			parent.changedPlan = true;
		if (!parent.CurrentBens[parent.planname][0] && parent.CurrentBens[parent.planname][1] == parent.EligPlans[parent.CurrentEligPlan][1] 
		&& parent.CurrentBens[parent.planname][2] == parent.EligPlans[parent.CurrentEligPlan][2]) 
		{
			parent.CurrentBens[parent.planname][0] = new Array();
			parent.CurrentBens[parent.planname][0][0] = parent.actiontaken;
			parent.CurrentBens[parent.planname][0][1] = parent.EligPlans[parent.CurrentEligPlan][11];
			parent.CurrentBens[parent.planname][0][2] = parent.EligPlans[parent.CurrentEligPlan][13];
			parent.CurrentBens[parent.planname][0][3] = parent.EligPlans[parent.CurrentEligPlan][15];
		}
	}
	if (parent.actiontaken == 1 && parent.msgNbr == 1 && parent.InDocPath(parent.baseurl+"disp_benefits.htm")) 
	{
		//alert("//elected to choose a plan other than the current one")
		if (!parent.CurrentBens[parent.planname][0])
		{
			parent.CurrentBens[parent.planname][0] = new Array();
			parent.CurrentBens[parent.planname][0][0] = parent.msgNbr;
			if (parent.CurrentBens[parent.planname][1] == parent.EligPlans[parent.CurrentEligPlan][1] && parent.CurrentBens[parent.planname][2] == parent.EligPlans[parent.CurrentEligPlan][2])
			{
				parent.CurrentBens[parent.planname][0][1] = parent.EligPlans[parent.CurrentEligPlan][11];
				parent.CurrentBens[parent.planname][0][2] = parent.EligPlans[parent.CurrentEligPlan][13];
				parent.CurrentBens[parent.planname][0][3] = parent.EligPlans[parent.CurrentEligPlan][15];				
			}
			//current plan is no longer available
			else
			{
				parent.CurrentBens[parent.planname][0][1] = "";
				parent.CurrentBens[parent.planname][0][2] = "";
				//if the plan doesn't have a stop date, stop the plan one day prior to the start date of the new plan (we don't have a stop date from BS03.2)
				if (parent.CurrentBens[parent.planname][15])
					parent.CurrentBens[parent.planname][0][3] = parent.CurrentBens[parent.planname][15];
				else
					parent.CurrentBens[parent.planname][0][3] = parent.formjsDate(changedte);
			}	
		}
	}
	// msgNbr==1 here means user went through elect_benefits.htm
	else if (parent.actiontaken == 4 && parent.msgNbr == 1 && parent.InDocPath(parent.baseurl+"disp_benefits.htm"))
	{
		//alert("elected to change coverage")
		if (!parent.CurrentBens[parent.planname][0] && parent.CurrentBens[parent.planname][1] == parent.EligPlans[parent.CurrentEligPlan][1] 
		&& parent.CurrentBens[parent.planname][2] == parent.EligPlans[parent.CurrentEligPlan][2]) 
		{
			parent.CurrentBens[parent.planname][0] = new Array();
			parent.CurrentBens[parent.planname][0][0] = parent.actiontaken;
			parent.CurrentBens[parent.planname][0][1] = parent.EligPlans[parent.CurrentEligPlan][11];
			parent.CurrentBens[parent.planname][0][2] = parent.EligPlans[parent.CurrentEligPlan][13];
			parent.CurrentBens[parent.planname][0][3] = parent.EligPlans[parent.CurrentEligPlan][15];
		}
	}
	parent.LastDoc = new Array();
	parent.currentdoc = 0;
	parent.navigate1();
}
function setdepBens()
{
	parent.DependentBens[parent.ElectedPlans.length-1] = new Array();
	parent.DependentBens[parent.ElectedPlans.length-1][0] = parent.actiontaken;
	parent.DependentBens[parent.ElectedPlans.length-1][1] = parent.coveredDeps;
	parent.DependentBens[parent.ElectedPlans.length-1][2] = parent.planname;
	parent.coveredDeps = new Array();
	parent.newDeps = new Array();
	return;
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
<!-- Version: 8-)@(#)@10.00.05.00.27 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/bensconfirm.htm,v 1.22.2.44.2.2 2014/06/26 15:38:07 brentd Exp $ -->
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