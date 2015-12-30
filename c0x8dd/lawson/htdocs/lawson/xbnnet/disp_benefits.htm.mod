<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<title>Benefit Plan Details</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script>
parent.SelectedPlan = new Array();
parent.CurrentBens[parent.planname][45] = true;
var button1 = 0;
var button2 = 0;
var button3 = 0;
var button4 = 1;
var button5 = 0;
var _Processed = true;
parent.cantEnroll = new Array();
parent.notAvailable = new Array();
parent.EMP_CONT_TYPE = '';
// PT 150929. If the record type cannot be determined from the eligble plan record, use the record type from the
// current benefit (should not really occur)
var REC_TYPE = parent.CurrentBens[parent.planname][22];
parent.CurrentEligPlan = "";
for (var i=1; i<parent.EligPlans.length; i++)
{
	if (parent.CurrentBens[parent.planname][2] == parent.EligPlans[i][2] && parent.CurrentBens[parent.planname][1] == parent.EligPlans[i][1])
	{
		parent.CurrentEligPlan = i;
		// PT 150929. Get the record type from the eligible plan record, because the record type could have changed.
		REC_TYPE = parent.EligPlans[i][6];
		var grpHasElection = false;
		// If this plan group requires at least one plan and the employee has not yet elected one and this is the last unelected plan in a plan group,
		// remove the "stop this type of benefit" option for this plan, which will require the user to choose a plan for the plan group.
		// Is the current plan group required and is this the last unelected plan in this group?
		if (parent.EligPlans[i][19] == "Y" && parent.lastPlanInGrp())
		{
			// Check all newly-elected plans to see if there is one elected for the same plan group.
			for (var j=0; j<parent.ElectedPlans.length; j++)
			{
				// Make sure this plan election has been confirmed by the user
				if (!parent.ElectedPlans[j][4]) continue;
				// Is there a plan within the same plan group that has been newly-elected by the user?
				if (parent.ElectedPlans[j][3] == parent.EligPlans[i][8])
				{
					grpHasElection = true;
					break;
				}
			}
			// If there is not a newly-elected plan within the same plan group, remove the "stop this type of benefit" option.
			if (!grpHasElection)
				button4 = 0;
		}
		break;
	}
}
var GrpPlans = new Array();
var plangroup = 0;
var footerMsg = "";
var newPlan = 0;
var mult = 0;
var temp = 0;
var multsal = 0;
var empcst1 = 0;
var empcst2 = 0;
var flxcost = 0;
var compcost = 0;
if (parent.CurrentBens[parent.planname][18]!="")
	empcst1 = parseFloat(parent.CurrentBens[parent.planname][18]);
if (parent.CurrentBens[parent.planname][19]!="")
	empcst2 = parseFloat(parent.CurrentBens[parent.planname][19]);
if (parent.CurrentBens[parent.planname][21]!="")
	flxcost = parseFloat(parent.CurrentBens[parent.planname][21]);
if (parent.CurrentBens[parent.planname][21]!="")
	flxcost = parseFloat(parent.CurrentBens[parent.planname][21]);
var empcost = empcst1 + empcst2;
if (parent.CurrentBens[parent.planname][12]!="")
	compcost = parseFloat(parent.CurrentBens[parent.planname][12]);
var taxable = parent.CurrentBens[parent.planname][13];
if (parent.CurrentBens[parent.planname][13] == "A")
	taxable = "After-Tax";
else if (parent.CurrentBens[parent.planname][13] == "P")
	taxable = "Pre-Tax";
else if (parent.CurrentBens[parent.planname][13] == "B")
	taxable = "Both";
for (var i=1; i<parent.EligPlans.length; i++)
{
	if (parent.CurrentBens[parent.planname][32] == parent.EligPlans[i][8])
	{
		// PT 147390.
		// Allow employee to select a different plan in the same plan group if the benefit plan you are working on has stop-allowed=Y and:
		// 	a) at least one other plan in the same group is a current benefit and add-allowed=Y or chg-allowed=Y for that plan, or
		//	b) at least one other plan in the same group is a new benefit and add-allowed=Y for that plan
		if (isCurrentBenefit(parent.EligPlans[i]))
		{
			if (parent.EligPlans[i][10] == "Y" || parent.EligPlans[i][12] == "Y")
			{
				plangroup++;
				GrpPlans[GrpPlans.length] = parent.EligPlans[i];
				//plans in the same group
			}
		}
		else
		{
			if (parent.EligPlans[i][10] == "Y")
			{
				plangroup++;
				GrpPlans[GrpPlans.length] = parent.EligPlans[i];
				//plans in the same group
			}
		}
	}
}
// PT 147390. Determine if a benefit plan is already a current benefit.
function isCurrentBenefit(plan)
{
	for (var j=1; j<parent.CurrentBens.length; j++)
	{
		if (parent.CurrentBens[j][1] == plan[1] && parent.CurrentBens[j][2] == plan[2])
			return true;
	}
	return false;
}
function DepOptionAlert()
{
	var stop = true;
	var msg = "";
	if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "B" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& (parent.spouseExists == false && parent.depsExist == false))
		msg = getSeaPhrase("ERROR_101","BEN");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "S" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& parent.spouseExists == false)
		msg = getSeaPhrase("ERROR_102","BEN");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "D" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& parent.depsExist == false)
		msg = getSeaPhrase("ERROR_103","BEN");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "P" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& parent.domParterExists == false)
		msg = getSeaPhrase("ERROR_126","BEN");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "O" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& (parent.spouseExists == false && parent.domParterExists == false))
		msg = getSeaPhrase("ERROR_127","BEN");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "R" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& parent.depsExist == false)
		msg = getSeaPhrase("ERROR_128","BEN");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "C" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& (parent.depsExist == false && parent.domParterExists == false))		
		msg = getSeaPhrase("ERROR_129","BEN");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "A" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& parent.dependents.length == 0)		
		msg = getSeaPhrase("ERROR_130","BEN");
	else if (REC_TYPE == "01" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& !isNaN(parseFloat(parent.SelectedPlan[parent.choice][19])) && parseFloat(parent.SelectedPlan[parent.choice][19]) > 0 
	&& parent.dependents.length < parseFloat(parent.SelectedPlan[parent.choice][19]))
	{
		var msg;
		if (parseFloat(parent.SelectedPlan[parent.choice][19]) == 1)
			msg = getSeaPhrase("ERROR_144","BEN");
		else
			msg = getSeaPhrase("ERROR_137","BEN",[parseFloat(parent.SelectedPlan[parent.choice][19])]);
		parent.seaAlert(msg, null, null, "error");
	}		
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "S" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.spouseExists == false)
		msg = getSeaPhrase("ERROR_104","BEN");
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05"|| REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "D" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.depsExist == false)
		msg = getSeaPhrase("ERROR_105","BEN");
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05"|| REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "B" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && (parent.depsExist == false && parent.spouseExists == false))
		msg = getSeaPhrase("ERROR_106","BEN");
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "P" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.domParterExists == false)
		msg = getSeaPhrase("ERROR_131","BEN");
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "O" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && (parent.spouseExists == false && parent.domParterExists == false))
		msg = getSeaPhrase("ERROR_132","BEN");
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "R" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.depsExist == false)
		msg = getSeaPhrase("ERROR_133","BEN");
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "C" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && (parent.depsExist == false && parent.domParterExists == false))
		msg = getSeaPhrase("ERROR_134","BEN");
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "A" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.dependents.length == 0)
		msg = getSeaPhrase("ERROR_135","BEN");
	else
		stop = false;
	if (stop)
		parent.seaAlert(msg, null, null, "error");
	return stop;
}
function IneligibleCoveredDepAgeExists()
{
	// student and dependent coverage ages
	var studentAge = 0;
	var depAge = 0;
	if (parent.updatetype == "CRT" || (typeof(REC_TYPE) != "undefined" && parseInt(REC_TYPE,10) == 1))
	{
		studentAge = parseFloat(parent.SelectedPlan[parent.choice][13]);
		depAge = parseFloat(parent.SelectedPlan[parent.choice][14]);
	}
	else if (parent.updatetype == "CRT2" || (typeof(REC_TYPE) != "undefined" && ((1 < parseInt(REC_TYPE,10) && parseInt(REC_TYPE,10) < 6) || parseInt(REC_TYPE,10) == 13)))
	{
		studentAge = parseFloat(parent.SelectedPlan[45]);
		depAge = parseFloat(parent.SelectedPlan[46]);
	}
	if (isNaN(studentAge))
		studentAge = 0;
	if (isNaN(depAge))
		depAge = 0;
	// start date of employee benefit
	var BnStartDate = "";
	if (parent.event == "annual")
	{
		if (parent.actiontaken == 3)
			BnStartDate = parent.setStopDate(parent.BenefitRules[2]);
		else
			BnStartDate = parent.BenefitRules[2];
	}
	else if (parent.rule_type == "N")
		BnStartDate = parent.EligPlans[parent.CurrentEligPlan][5];
	else
	{
		if (parent.actiontaken == 2 || parent.actiontaken == 5)
			BnStartDate = parent.BenefitRules[2];
		else if (parent.actiontaken == 1)
			BnStartDate = parent.EligPlans[parent.CurrentEligPlan][11];
		else if (parent.actiontaken == 3)
			BnStartDate = parent.setStopDate(parent.EligPlans[parent.CurrentEligPlan][15]);
		else if (parent.actiontaken == 4)
			BnStartDate = parent.EligPlans[parent.CurrentEligPlan][13];
	}
	var returnVal = false;
	for (var x=0; x<parent.coveredDeps.length; x++)
	{
		for (var y=0; y<parent.dependents.length; y++)
		{
			if (parent.dependents[y].seq_nbr == parent.coveredDeps[x].dependent)
			{
				if (parent.dependents[y].dep_type == "D")
				{
                    var birthDate = parent.formjsDate(parent.formatDME(parent.dependents[y].birthdate));
                    if (birthDate > BnStartDate)
                          returnVal = true;
                    if (parent.dependents[y].disabled == "N")
                    {
                          if (parent.dependents[y].student == "Y" && !parent.isDepAgeEligible(parent.termopt, birthDate, studentAge, BnStartDate))
                                returnVal = true;
                          if (parent.dependents[y].student == "N" && !parent.isDepAgeEligible(parent.termopt, birthDate, depAge, BnStartDate))
                                returnVal = true;
                    }
				}
				break;
			}
		}
		if (returnVal)
			break;
	}
	return returnVal;
}
function header(addlStr)
{
	var titleLbl = parent.CurrentBens[parent.planname][5]+' - '+getSeaPhrase("VIEW_PLAN_DESC","BEN")+' '+getSeaPhrase("OPENS_WIN","SEA");
	var html = '<br/><table border="0" cellpadding="0" cellspacing="0" style="width:100%;margin-left:auto;margin-right:auto" role="presentation">'
	html += '<tr><td class="plaintablecell">'+getSeaPhrase("DISPBEN_1","BEN")+' '
	html += '<a href="javascript:;" onclick="parent.parent.openWinDesc2(\''+parent.CurrentBens[parent.planname][1]+'\',\''+parent.CurrentBens[parent.planname][2]+'\');return false" title="'+titleLbl+'" aria-haspopup="true">'
	html += parent.CurrentBens[parent.planname][5]+'<span class="offscreen"> - '+titleLbl+'</span></a>.'
// MOD BY BILAL - Prior Customization
    // JRZ 1/27/09 making currently enrolled plan stand out
	html += 'You are currently enrolled in <span style="font-size:1.1em;font-weight:bold;color:#ff0000">'+parent.CurrentBens[parent.planname][5]+'</span>'
    //~JRZ
// END OF MOD
// MOD BY BILAL - Prior Customization
    // JRZ 1/27/09 The openWinDesc2 function doesn't work for our needs, replacing with old one
		var nme = parent.removespace(parent.CurrentBens[parent.planname][1]+parent.CurrentBens[parent.planname][2])
	html +=' <a href=Javascript:parent.parent.openWinDesc("'+nme+'.htm") onMouseOver="window.status=\'Display plan description\';return true"> View Description </a>'
    //~JRZ
// END OF MOD
	html += ((addlStr)?' '+addlStr:'')
	html += '</td>'
	// **********************************************************************************************************
	// Example Enwisen Integration.
	//
	// If Enwisen is enabled in the config file for the employee's company and the "Medical Cost Estimator"
	// and "Learn About: Medical Programs" pages have been defined for this plan group in the
	// config file, show the links.
	//
	// **********************************************************************************************************
	if (isEnwisenEnabled())
	{
		html += '<td><ul>';
		var planGroup = parent.CurrentBens[parent.planname][32];
		// <page> nodes are defined with id="PlanGroup=ID"
		if (getEnwisenLink("id=" + planGroup + "=MEDICAL_COST_ESTIMATOR") != null)
			html += '<li style="padding:2px">' + getEnwisenLink("id=" + planGroup + "=MEDICAL_COST_ESTIMATOR","Medical Cost Estimator");
		if (getEnwisenLink("id=" + planGroup + "=YOUR_NEEDS_MEDICAL") != null)
			html += '<li style="padding:2px">' + getEnwisenLink("id=" + planGroup + "=YOUR_NEEDS_MEDICAL","Learn About: Medical Programs");
		html += '</ul></td>';
	}	
	html += '</tr></table><br/>'
	return html;
}
function initDispScreen()
{
	stylePage();
	setWinTitle(getSeaPhrase("PLAN_DETAILS","BEN"));
	parent.startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), setdata);	
}
function setdata()
{
	if (REC_TYPE=="01")
	{
		parent.lawheader.count = 0;
		updatetype = "CRT";
		parent.updatetype = "CRT";
		var object1 = new AGSObject(parent.prodline, "BS13.1");
		object1.event = "ADD";
		object1.rtn = "DATA";
		object1.longNames = true;
		object1.tds = false;
		object1.field = "FC=I"
		+ "&COP-COMPANY=" + escape(parent.company)
		+ "&EMP-EMPLOYEE=" + escape(parent.employee)
		+ "&COP-PLAN-TYPE=" + escape(parent.CurrentBens[parent.planname][1],1).toString().replace("+","%2B")
		+ "&COP-PLAN-CODE=" + escape(parent.CurrentBens[parent.planname][2],1).toString().replace("+","%2B")
		+ "&BAE-NEW-DATE=" + escape(parent.BenefitRules[2])
		+ "&BAE-COST-DIVISOR=" + escape(parent.BenefitRules[6])
		+ "&BAE-RULE-TYPE=" + parent.rule_type
		+ "&BFS-FAMILY-STATUS=" + escape(parent.eventname.toUpperCase());
		object1.func = "parent.getdep()";
		AGS(object1,"js1");
	}
	else if (REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13")
	{
		parent.lawheader.count = 0;
		updatetype = "CRT2";
		parent.updatetype = "CRT2";
		var object1 = new AGSObject(parent.prodline, "BS14.1");
		object1.event = "ADD";
		object1.rtn = "DATA";
		object1.longNames = true;
		object1.tds = false;
		object1.field = "FC=I"
		+ "&CVR-COMPANY=" + escape(parent.company)
		+ "&EMP-EMPLOYEE=" + escape(parent.employee)
		+ "&CVR-PLAN-TYPE=" + escape(parent.CurrentBens[parent.planname][1],1).toString().replace("+","%2B")
		+ "&CVR-PLAN-CODE=" + escape(parent.CurrentBens[parent.planname][2],1).toString().replace("+","%2B")
		+ "&BAE-NEW-DATE="  + escape(parent.BenefitRules[2])
		+ "&BAE-COST-DIVISOR=" + escape(parent.BenefitRules[6])
		+ "&BAE-RULE-TYPE=" + parent.rule_type
		+ "&BFS-FAMILY-STATUS=" + escape(parent.eventname.toUpperCase());
		object1.func = "parent.getdep()";
		AGS(object1,"js1");
	}
	else if (REC_TYPE == "06" || REC_TYPE == "07" || REC_TYPE == "08" || REC_TYPE == "09" || REC_TYPE == "10")
	{
		parent.lawheader.count = 0;
		updatetype = "CRT3";
		parent.updatetype = "CRT3";
		var object1 = new AGSObject(parent.prodline, "BS15.1");
		object1.event = "ADD";
		object1.rtn = "DATA";
		object1.longNames = true;
		object1.tds = false;
		object1.field = "FC=I"
		+ "&PRE-COMPANY=" + escape(parent.company)
		+ "&EMP-EMPLOYEE=" + escape(parent.employee)
		+ "&PRE-PLAN-TYPE=" + escape(parent.CurrentBens[parent.planname][1],1).toString().replace("+","%2B")
		+ "&PRE-PLAN-CODE=" + escape(parent.CurrentBens[parent.planname][2],1).toString().replace("+","%2B")
		+ "&BAE-NEW-DATE=" + escape(parent.BenefitRules[2])
		+ "&BAE-COST-DIVISOR=" + escape(parent.BenefitRules[6])
		+ "&BAE-RULE-TYPE=" + parent.rule_type
		+ "&BFS-FAMILY-STATUS=" + escape(parent.eventname.toUpperCase());
		object1.func = "parent.goform()";
		AGS(object1,"js1");
	}
	else if (REC_TYPE == "12")
	{
		parent.updatetype = "CRT3";
		parent.msgNbr = 99;
		parent.SelectedPlan = new Array();
		parent.SelectedPlan[0] = 12;
		if (parent.CurrentEligPlan != "")
		{
			parent.SelectedPlan[1] = parent.EligPlans[parent.CurrentEligPlan][1];
			parent.SelectedPlan[2] = parent.EligPlans[parent.CurrentEligPlan][2];
		}
		parent.SelectedPlan[65] = parent.CurrentBens[parent.planname][48];
		goform();
	}
	else
		parent.stopProcessing();
}
function getdep()
{
	if (parent.updatetype == "CRT2")
	{
		if (parent.SelectedPlan[55] == "Y")
			button5 = 1;
	}
	var obj = new parent.DMEObject(parent.prodline,"hrdepben");
	obj.out = "JAVASCRIPT";
	obj.index = "hdbset3";
	obj.field = "dependent;start-date;stop-date";
	obj.key = parent.company +"="+ parent.employee +"="+escape(parent.CurrentBens[parent.planname][1],1).toString().replace("+","%2B")
	+"="+escape(parent.CurrentBens[parent.planname][2],1).toString().replace("+","%2B")
	+"="+escape(parent.CurrentBens[parent.planname][3]);
	obj.max = "600";
	parent.DME(obj,"main.js1");
}
function DspHrdepben()
{
	temp = new Array();
	for (var i=0; i<self.js1.record.length; i++)
	{
		if (parseFloat(parent.formjsDate(parent.formatDME(self.js1.record[i].start_date))) <= parseFloat(parent.eventdte) 
		&& (self.js1.record[i].stop_date == '' || parseFloat(parent.formjsDate(parent.formatDME(self.js1.record[i].stop_date))) >= parseFloat(parent.eventdte)))
			temp[temp.length] = self.js1.record[i];
	}
	parent.coveredDeps = temp;
	for (var x=0; x<parent.coveredDeps.length; x++)
	{
		for (var y=0; y<parent.dependents.length; y++)
		{
			if (parent.dependents[y].seq_nbr == parent.coveredDeps[x].dependent)
			{
				parent.coveredDeps[x].first_name = parent.dependents[y].first_name;
				parent.coveredDeps[x].last_name = parent.dependents[y].last_name;
				break;
			}
		}
	}
	parent.oldDepBens[parent.ElectedPlans.length] = parent.coveredDeps;
	goform();
}
function goform()
{
	if (_Processed)
	{
		_Processed = false;
		if (REC_TYPE == "01")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_01.htm";
		else if (REC_TYPE == "02")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_02.htm";
		else if (REC_TYPE == "03" || REC_TYPE == "13")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_03.htm";
		else if (REC_TYPE == "04")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_04.htm";
		else if (REC_TYPE == "05")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_05.htm";
		else if (REC_TYPE == "06")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_06.htm";
		else if (REC_TYPE == "07")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_07.htm";
		else if (REC_TYPE == "08")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_06.htm";
		else if (REC_TYPE == "09")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_06.htm";
		else if (REC_TYPE == "10")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_10.htm";
		else if (REC_TYPE == "12")
			self.document.getElementById("disp").src = "/lawson/xbnnet/disp_ben_12.htm";
		else
			parent.stopProcessing();
		fitToScreen();	
	}
	else
		parent.stopProcessing();
}
function setTaxType(msgNbr)
{
    var recType = parseInt(REC_TYPE,10);
	if (parent.CurrentBens[parent.planname][13] !="")
	{
		if (recType == 1)
	   	{
	   		if (parent.SelectedPlan[parent.choice][3] == "B")
	   			parent.setpreaft_flag(parent.CurrentBens[parent.planname][13]);
			// PT 150062. Do not populate the preaft flag from the current benefit if there is no employee contribution for the new benefit.	   			
	   		else if (parent.SelectedPlan[parent.choice][3] != "N" && parent.SelectedPlan[parent.choice][4])	
	   			parent.setpreaft_flag(parent.SelectedPlan[parent.choice][4]);
	    }
	    else if (((2 <= recType && recType <= 5) || recType == 13)) 
	    {
	    	if (parent.SelectedPlan[15] == "B")	
	    		parent.setpreaft_flag(parent.CurrentBens[parent.planname][13]);
	    	else if (parent.SelectedPlan[16] != "")
	        	parent.setpreaft_flag(parent.SelectedPlan[16]);
	    }
	    else if (6 <= recType && recType <= 10) 
	    {
	    	if (parent.SelectedPlan[26] == "B")	
	    		parent.setpreaft_flag(parent.CurrentBens[parent.planname][13]);
	    	else if (parent.SelectedPlan[28] != "")
	        	parent.setpreaft_flag(parent.SelectedPlan[28]);
	    }
    }
    parent.selOption(msgNbr);
}
function parseChoice(thisForm)
{
	var choices = thisForm.option;
	var choiceSelected = false;
	// PT 147390.  Handle only one radio button option.
    if (!choices.length)
    {
        choiceSelected = thisForm.option.checked;
        choices = new Array();
        choices[0] = thisForm.option;
    }
	for (var i=0; i<choices.length; i++) 
	{
		if (choices[i].checked) 
		{
			choiceSelected = true;
			switch (parseInt(choices[i].value,10)) 
			{
				case 0: // PT 152554.
						var recType = parseInt(REC_TYPE,10);
						if ((recType >= 2 && recType <= 5) || recType == 13)
							coverLimCheck(2);
						else
							setTaxType(2);
						break;
				case 1: parent.selOption(4); break;			
				case 2: 						
						var recType = parseInt(REC_TYPE,10);
						if ((recType >= 2 && recType <= 5) || recType == 13)
							coverLimCheck(5);
						else
							setTaxType(5);
						break;
				case 3: parent.selOption(1); break;
				case 4: parent.selOption(3); break;
				default: break;
			}
		}
	}
	if (!choiceSelected)
		parent.seaAlert(getSeaPhrase("SELECT_AN_OPTION","BEN"), null, null, "error");
}
function coverLimCheck(msgNbr)
{
	var percentage = 0;
	var firstBenCov = null;
	var secondBenCov = null;
	var newBenCov = null;
	var len = parent.ElectedPlans.length;
	for (var i=len-1; i>=0; i--)
	{
		var planType = getPlanType(parent.ElectedPlans[i]);
		var planCode = getPlanCode(parent.ElectedPlans[i]);
		if ((planType != null) && (planCode != null) && (planType == parent.SelectedPlan[6]) && (planCode == parent.SelectedPlan[8]))
		{
			firstBenCov = getPlanCov(parent.ElectedPlans[i]); 	// Coverage of the first plan
			secondBenCov = getSelectedPlanCov(parent.SelectedPlan, REC_TYPE); // Coverage of the second plan
			newBenCov = parent.determineCoverage(parseInt(REC_TYPE,10)); // Coverage limit based on first plan
		}
		if ((firstBenCov != null) && (secondBenCov != null) && (newBenCov != true) && (Number(secondBenCov) > Number(newBenCov)))
		{
			parent.seaAlert(getSeaPhrase("MAX_COVERAGE_ALLOWED","BEN")+" "+parent.formatCont(newBenCov)+". "+getSeaPhrase("MUST_CHANGE_COVERAGE","BEN"), null, null, "error");
			parent.selOption(4);
			return;
		}
	}
	setTaxType(msgNbr);
}
function getPlanType(electedPlan)
{
	var planType = "";
	switch (parseInt(electedPlan[0],10))
	{
		case 1: planType = electedPlan[2][11]; break;
		case 2:
		case 3:
		case 4:
		case 5: planType = electedPlan[2][37]; break;
		case 6:
		case 7:
		case 8:
		case 9:
		case 10: planType = electedPlan[2][38]; break;
		case 12: planType = electedPlan[2][1]; break;
		default: break;
	}
	return planType;
}
function getPlanCode(electedPlan)
{
	var planCode = "";
	switch (parseInt(electedPlan[0],10))
	{
		case 1: planCode = electedPlan[2][12]; break;
		case 2:
		case 3:
		case 4:
		case 5: planCode = electedPlan[2][38]; break;
		case 6:
		case 7:
		case 8:
		case 9:
		case 10: planCode = electedPlan[2][39]; break;
		case 12: planCode = electedPlan[2][2]; break;
		default: break;
	}
	return planCode;
}
function getPlanCov(electedPlan)
{
	var planCov = null;
	switch (parseInt(electedPlan[0],10))
	{
		case 1: break;
		case 2: planCov = electedPlan[2][5]; break;
		case 3: planCov = electedPlan[2][14]; break;
		case 4: planCov = electedPlan[2][17]; break;
		case 5: planCov = electedPlan[2][14]; break;
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
		case 12: break;
		default:
			break;
	}
	return planCov;
}
function getSelectedPlanCov(selectedPlan, recType)
{
	var planCov = null;
	switch (parseInt(recType,10))
	{
		case 1: break;
		case 2: planCov = selectedPlan[5]; break;
		case 3:
		case 13: planCov = selectedPlan[14]; break;
		case 4: planCov = selectedPlan[17]; break;
		case 5: planCov = selectedPlan[14]; break;
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
		case 12: break;
		default:
			break;
	}
	return planCov;
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
	var dispFrame = document.getElementById("disp");
	var winObj = getWinSize();
	var winWidth = winObj[0];	
	var winHeight = winObj[1];
	var contentWidth;
	var contentWidthBorder;
	var contentHeightBorder;
	var contentHeight;
	if (window.styler && window.styler.showInfor)
	{			
		contentWidth = winWidth - 10;
		contentWidthBorder = (navigator.appName.indexOf("Microsoft") >= 0) ? contentWidth + 5 : contentWidth + 2;
		contentHeight = winHeight - 65;
		contentHeightBorder = contentHeight + 30;
	}
	else if (window.styler && (window.styler.showLDS || window.styler.showInfor3))
	{
		contentWidth = winWidth - 20;
		contentWidthBorder = (window.styler.showInfor3) ? contentWidth + 7 : contentWidth + 17;
		contentHeight = winHeight - 75;	
		contentHeightBorder = winHeight - 35;
	}
	else
	{
		contentWidth = winWidth - 10;
		contentWidthBorder = contentWidth;
		contentHeight = winHeight - 60;
		contentHeightBorder = contentHeight + 24;	
	}
	dispFrame.style.width = winWidth + "px";
	dispFrame.style.height = winHeight + "px";
	try
	{
		if (self.disp.onresize && self.disp.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.disp.onresize = null;		
	}
	catch(e) {}
	try
	{
		self.disp.document.getElementById("paneBorder").style.width = contentWidthBorder + "px";
		self.disp.document.getElementById("paneBodyBorder").style.width = contentWidth + "px";
		self.disp.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.disp.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.disp.document.getElementById("paneBody").style.width = contentWidth + "px";
		self.disp.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
}
</script>
</head>
<body style="overflow:hidden" onload="initDispScreen();fitToScreen()" onresize="fitToScreen()">
	<iframe id="disp" name="disp" title="Main Content" level="2" tabindex="0" src="/lawson/xhrnet/ui/headerpane.htm" style="visibility:visible;position:absolute;top:0px;left:0px;width:721px;height:464px" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	<iframe name="js1" title="Empty" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;height:0px;width:0px;"></iframe>
	<iframe name="lawheader" title="Empty" src="/lawson/xbnnet/besslawheader.htm" style="visibility:hidden;height:0px;width:0px;"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/disp_benefits.htm,v 1.21.2.73 2014/02/24 22:02:28 brentd Exp $ -->
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
