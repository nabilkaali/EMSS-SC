<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<title>Current Benefits</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/common.js"></script>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/xhrnet/waitalert.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script src="/lawson/webappjs/javascript/objects/ActivityDialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/OpaqueCover.js"></script>
<script src="/lawson/webappjs/javascript/objects/Dialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/Transaction.js"></script>
<script src="/lawson/webappjs/javascript/objects/ProcessFlow.js"></script>
<script>
var currentBens = new Array();
var dependentsList = new Array();
var benefitsHtml;
var sortProperty;
var fromDBFile = false;
var displayCheckDedAmts = false;
var effectiveDate = "";
var costDivisor = "";
var sortDirection = "<";
var pfObj;
var appObj;

function sortByProperty(obj1, obj2)
{
	var name1 = obj1[sortProperty];
	var name2 = obj2[sortProperty];
	if (sortProperty == "start_date")
	{
		name1 = dateInCompareFormat(name1);
		name2 = dateInCompareFormat(name2);
	}
	if (sortDirection == "<") // ascending sort
	{
		if (name1 < name2)
			return -1;
		else if (name1 > name2)
			return 1;
		else
			return 0;
	}
	else // descending sort
	{
		if (name1 > name2)
			return -1;
		else if (name1 < name2)
			return 1;
		else
			return 0;
	}
}

function OpenCurrentBenefits()
{
	authenticate("frameNm='FRAME1'|funcNm='InitBenefits()'|desiredEdit='EM'");
}

function InitBenefits()
{
	stylePage();
	self.printframe.stylePage();
	setLayerSizes();
	var title = getSeaPhrase("CURBEN_22","BEN");
	setWinTitle(title);
	setTaskHeader("header",title,"Benefits");
	effectiveDate = authUser.date;
	currentBens = new Array();
	showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), GetBenefits);
}

function GetBenefits()
{
	if (fromDBFile)
		GetBenefitsFromDBFile();
	else
		GetBenefitsFromBS10("I");
}

function GetBenefitsFromBS10(fc)
{
 	//first try to get benefits from BS10
	self.lawheader.count = 0; 
	self.lawheader.updatetype = "BS10";
	var agsObj = new AGSObject(authUser.prodline,"BS10.1");
	agsObj.event = "ADD";
	agsObj.debug = false;
	agsObj.rtn = "DATA";
	agsObj.longNames = true;
	agsObj.tds = false;
	agsObj.field = "FC=" + fc
	+ "&BEN-COMPANY=" + escape(parseInt(authUser.company,10))
	+ "&BEN-EMPLOYEE=" + escape(parseInt(authUser.employee,10))
	+ "&BAE-CURRENT-DATE=" + escape(effectiveDate)
	+ "&BAE-NEW-DATE="
	+ "&BAE-COST-DIVISOR="
	+ "&BAE-RULE-TYPE=C"
	+ "&BFS-FAMILY-STATUS="
	if (fc == "%2B") 
	{
		var BS10 = self.lawheader.BS10;
		agsObj.field += "&PT-COMPANY=" + escape(BS10.PT_COMPANY)
		+ "&PT-EMPLOYEE=" + escape(BS10.PT_EMPLOYEE)
		+ "&PT-PROCESS-LEVEL=" + escape(BS10.PT_PROCESS_LEVEL,1).toString().replace("+","%2B")
		+ "&PT-FAMILY-STATUS=" + escape(BS10.PT_FAMILY_STATUS)
		+ "&PT-GROUP-NAME=" + escape(BS10.PT_GROUP_NAME,1).toString().replace("+","%2B")
		+ "&PT-PROCESS-ORDER=" + escape(BS10.PT_PROCESS_ORDER)
		+ "&PT-PLN-PLAN-TYPE=" + escape(BS10.PT_PLAN_TYPE,1).toString().replace("+","%2B")
		+ "&PT-PLN-PLAN-CODE=" + escape(BS10.PT_PLAN_CODE,1).toString().replace("+","%2B")
		+ "&PT-BEN-START-DATE=" + escape(BS10.PT_BEN_START_DATE)
		+ "&PT-FIELDS-SET=Y";
	}
	agsObj.func = "parent.CheckBenefits()";
	self.lawheader.initBS10();
	AGS(agsObj,"FRAME1");
}

function ReloadBenefits()
{
	var mainform = self.MAIN.document.forms["mainform"];
	clearRequiredField(mainform.effectivedate);
	if (NonSpace(mainform.effectivedate.value) == 0)
	{
		setRequiredField(mainform.effectivedate, getSeaPhrase("EFFECTIVE_DATE","ESS"));
	   	return;
	}
 	if (ValidDate(mainform.effectivedate) == false)
	   	return;
 	effectiveDate = formjsDate(formatDME(mainform.effectivedate.value));
 	currentBens = new Array();
 	showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), GetBenefits);
}

function CheckBenefits()
{
	var msg = self.lawheader.gmsg;
	var msgNbr = Number(self.lawheader.gmsgnbr);
	//if rule type "C" does not exist, get employee's benefits from BENEFIT file
	if (msgNbr == 126)
	{
		GetBenefitsFromDBFile();
		return;
	}
	else if (msgNbr == 105)
	{
		//no benefits found, continue
		ProcessBenefits();
		return;
	}
	else if (msgNbr != 0)
	{
		removeWaitAlert();
		seaAlert(msg, null, nulll, "error");	
		return;
	}
	//if more records exist perform a page down
	if (msg.toUpperCase().indexOf("PAGEDOWN")!=-1) 
	{
		GetBenefitsFromBS10("%2B");
		return;
	}
	ProcessBenefits();
}

function GetBenefitsFromDBFile()
{
	fromDBFile = true;
	currentBens = new Array();
	var dmeObj = new DMEObject(authUser.prodline,"BENEFIT");
	dmeObj.out = "JAVASCRIPT";
	dmeObj.index = "BENSET4";
	dmeObj.field = "plan-type,xlt;start-date;plan-code;stop-date;plan-option;"
	+ "cov-option;emp-pre-cont;emp-aft-cont;comp-cont;cover-amt;bond-ded-amt;dep-cover-amt;"
	+ "pct-amt-flag;multiple;cmp-flx-cont;bncovopt.cov-desc;plan.cmp-ded-code-p;"
	+ "plan.waive-flag;plan.desc;plan-type;comp-match;employee.pay-frequency;mtch-up-to;dependents.dependent;"
	+ "employee.label-name-1"
   	dmeObj.max = "600";
   	dmeObj.otmmax = "1";
	dmeObj.key = parseInt(authUser.company,10) + "=" + parseInt(authUser.employee,10);
  	dmeObj.select = "start-date<=" + effectiveDate + "&(stop-date>=" + effectiveDate + "|stop-date=00000000)";
	dmeObj.func	= "GetMoreBenefitsFromDBFile()";
	DME(dmeObj,"FRAME1");
}

function GetMoreBenefitsFromDBFile()
{
	currentBens = currentBens.concat(self.FRAME1.record);
	if (self.FRAME1.Next)
		self.FRAME1.location.replace(self.FRAME1.Next);
	else
		ProcessBenefits();
}

function ProcessBenefits()
{
	costDivisor = self.lawheader.BS10.BAE_COST_DIVISOR;
	if (!costDivisor)
		costDivisor = "P";	
	displayCheckDedAmts = false;
	var depBensExist = false;
	for (var i=0; i<currentBens.length; i++)	
	{
		if (GetNbr(currentBens[i].dependents_dependent) > 0)
			depBensExist = true;
		currentBens[i].check_amt_total = 0;
		if (typeof(currentBens[i].pre_check_amt) != "undefined" && typeof(currentBens[i].aft_check_amt) != "undefined")
		{	
			var preCheckAmt = GetNbr(currentBens[i].pre_check_amt);
			var aftCheckAmt = GetNbr(currentBens[i].aft_check_amt);
			if ((preCheckAmt != 0 && !isNaN(preCheckAmt)) || (aftCheckAmt != 0 && !isNaN(aftCheckAmt)))
			{
				currentBens[i].check_amt_total = preCheckAmt + aftCheckAmt;
				displayCheckDedAmts = true;
			}
		}
	}
	sortProperty = "plan_type_xlt";
	currentBens.sort(sortByProperty);
	if (depBensExist)
		GetDependents();
	else		
		DspCurrentBenefits();
}

function GetDependents()
{
	dependentsList = new Array();
	var dmeObj = new DMEObject(authUser.prodline, "HRDEPBEN");
	dmeObj.out = "JAVASCRIPT";
	dmeObj.field = "dependent;plan-type;plan-code;emp-start;dependent.label-name-1;start-date;stop-date";
	dmeObj.otmmax = "1";
	dmeObj.max = "50";
	dmeObj.key = parseInt(authUser.company,10) + "=" + parseInt(authUser.employee,10);
	dmeObj.func = "GetDependents_Finished()";
	DME(dmeObj,"FRAME1");
}

function GetDependents_Finished()
{
	dependentsList = dependentsList.concat(self.FRAME1.record);
	if (self.FRAME1.Next)
		self.FRAME1.location.replace(self.FRAME1.Next);
	else
		DspCurrentBenefits();	
}

function DspCurrentBenefits(onsort, property)
{
	var toolTip;
	var effectiveDateHtml = '';	 
// MOD BY BILAL  - Prior Customizations
//ISH 2008 Modification
   //CGL 2010 Text Updates
	effectiveDateHtml = "<table><tr align=CENTER><td>Here is a list of some of your current benefits.  It shows the benefit and the cost, including St. Luke's cost.  In addition to the following benefits, St. Luke's also pays 100% of the following benefits: Paid Time Off, Extended Sick Leave, long term disability, jury duty leave, bereavement leave, professional liability insurance, travel insurance, workers compensation, and unemployment.</td></tr></table>"
   //CGL End
//ISH End	
// END OF MOD
	if (currentBens.length > 0)
	{
		var emailAvailable = false;
		// email is only supported when BS10 is used to pull the benefits (9.0.1 or newer)
		if (!fromDBFile)
		{
			if (emssObjInstance.emssObj.processFlowsEnabled)	
			{
				// Try to trigger the ProcessFlow if the employee opts to email.
				var techVersion = (iosHandler && iosHandler.getIOSVersionNumber() >= "09.00.00") ? ProcessFlowObject.TECHNOLOGY_900 : ProcessFlowObject.TECHNOLOGY_803;
				var httpRequest = (typeof(SSORequest) == "function") ? SSORequest : SEARequest;
				pfObj = new ProcessFlowObject(window, techVersion, httpRequest, "EMSS");
				pfObj.setEncoding(authUser.encoding);
				pfObj.showErrors = false;
				emailAvailable = true;
			}
		}
		effectiveDateHtml += '<div class="buttonBar" style="padding-right:5px">';
		if (window.print)
			effectiveDateHtml += uiButton(getSeaPhrase("PRINT","BEN"),"parent.printForm();return false",false,"printbtn");	
		if (emailAvailable)
			effectiveDateHtml += uiButton(getSeaPhrase("EMAIL","ESS"),"parent.emailForm();return false","margin-left:5px","emailbtn");		
		effectiveDateHtml += '</div>';
	}	
	effectiveDateHtml += '<form name="mainform" onsubmit="return false">'
	effectiveDateHtml += '<table border="0" cellspacing="0" cellpadding="0" style="padding-left:5px;padding-right:5px" role="presentation">';
	effectiveDateHtml += '<tr><td class="fieldlabelboldleft" colspan="4">'+getSeaPhrase("SELECT_EFFECTIVE_DATE","ESS")+' '+getCostDesc(costDivisor)+'</td></tr>'
	toolTip = getSeaPhrase("SELECT_EFFECTIVE_DATE","ESS");
	effectiveDateHtml += '<tr><td class="fieldlabelbold" style="vertical-align:top;padding-top:7px;padding-bottom:5px" nowrap="nowrap"><label id="effectivedateLbl" for="effectivedate">'+getSeaPhrase("HOME_ADDR_1","ESS")+'</label></td>'
	effectiveDateHtml += '<td class="plaintablecell" style="vertical-align:top;padding-top:5px;padding-bottom:5px" nowrap="nowrap"><input class="inputbox" type="text" id="effectivedate" name="effectivedate" size="10" maxlength="10" onfocus="this.select()" onchange="parent.ValidateDate(this);" value="'+FormatDte4(effectiveDate)+'" aria-labelledby="effectivedateLbl effectivedateFmt">'
	effectiveDateHtml += '<a href="javascript:parent.DateSelect(\'effectivedate\');" title="'+toolTip+'" aria-label="'+toolTip+'">'+uiCalendarIcon()+'</a><br/>'+uiDateFormatSpan("effectivedateFmt")+'</td>'
	effectiveDateHtml += '<td class="plaintablecellright" style="vertical-align:top;padding-top:5px;padding-bottom:5px" nowrap="nowrap">';
	effectiveDateHtml += uiButton(getSeaPhrase("CONTINUE","BEN"), "parent.ReloadBenefits();return false", "margin-left:5px")
	effectiveDateHtml += '</td></tr></table></form>';
	var toolTip = getSeaPhrase("CURBEN_23","BEN")+' - '+getSeaPhrase("SORT_BY_X","SEA");
	benefitsHtml = '<table id="currbenTbl" class="plaintableborder" border="0" cellspacing="0" cellpadding="0" style="width:100%" styler="list" summary="'+getSeaPhrase("TSUM_24","BEN",[FormatDte4(effectiveDate)])+'">'
	+ '<caption class="offscreen">'+getSeaPhrase("TCAP_21","BEN",[FormatDte4(effectiveDate)])+'</caption>'
	+ '<tr><th scope="col" class="plaintableheaderborder" style="text-align:center" styler_click="StylerEMSS.onClickColumn" styler_init="StylerEMSS.initListColumn">'
	+ '<a class="columnsort" href="javascript:;" onclick="parent.SortBenefits(\'plan_type_xlt\');return false" title="'+toolTip+'">'+getSeaPhrase("CURBEN_23","BEN")+'<span class="offscreen"> - '+getSeaPhrase("SORT_BY_X","SEA")+'</span></a></th>'
	toolTip = getSeaPhrase("PLAN","BEN")+' - '+getSeaPhrase("SORT_BY_X","SEA");
	benefitsHtml += '<th scope="col" class="plaintableheaderborder" style="text-align:center" styler_click="StylerEMSS.onClickColumn" styler_init="StylerEMSS.initListColumn">'
	+ '<a class="columnsort" href="javascript:;" onclick="parent.SortBenefits(\'plan_desc\');return false" title="'+toolTip+'">'+getSeaPhrase("PLAN","BEN")+'<span class="offscreen"> - '+getSeaPhrase("SORT_BY_X","SEA")+'</span></a></th>'
	toolTip = getSeaPhrase("START_DATE","BEN")+' - '+getSeaPhrase("SORT_BY_X","SEA");
	benefitsHtml += '<th scope="col" class="plaintableheaderborder" style="text-align:center" styler_click="StylerEMSS.onClickColumn" styler_init="StylerEMSS.initListColumn">'
	+ '<a class="columnsort" href="javascript:;" onclick="parent.SortBenefits(\'start_date\');return false" title="'+toolTip+'">'+getSeaPhrase("START_DATE","BEN")+'<span class="offscreen"> - '+getSeaPhrase("SORT_BY_X","SEA")+'</span></a></th>'	
	benefitsHtml += '<th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("COVERAGE","BEN")+'</th>'
	if (displayCheckDedAmts)
		benefitsHtml += '<th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("CURBEN_36","BEN")+'</th>'
	benefitsHtml += '<th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("CURBEN_24","BEN")+'</th>'
	+ '<th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("CURBEN_25","BEN")+'</th>'
	+ '<th scope="col" class="plaintableheaderborder" style="text-align:center">'+getSeaPhrase("CO_COST","BEN")+'</th></tr>';
	var strBuffer = new Array();
	for (var i=0; i<currentBens.length; i++)
	{
		// Plan Type column data:
		strBuffer[i] = '<tr><td class="plaintablecellborder" nowrap>';
		strBuffer[i] += ((currentBens[i].plan_type_xlt)?currentBens[i].plan_type_xlt:'&nbsp;');
		strBuffer[i] += '</td>';
		// Plan Description column data:
		strBuffer[i] += '<td class="plaintablecellborder" nowrap>';
		strBuffer[i] += ((currentBens[i].plan_desc)?currentBens[i].plan_desc:'&nbsp;');
		strBuffer[i] += '</td>';
		// Start Date column data:
		strBuffer[i] += '<td class="plaintablecellborder" style="text-align:center" nowrap>';
		strBuffer[i] += ((currentBens[i].start_date)?FormatDte4(dateInCompareFormat(currentBens[i].start_date)):'&nbsp;');
		strBuffer[i] += '</td>';
		// Coverage column data:
		strBuffer[i] += '<td class="plaintablecellborderright" nowrap>'+getCoverage(currentBens[i])+'</td>';
		// Pay Check Deduction column data:
		if (displayCheckDedAmts)
		{
			strBuffer[i] += '<td class="plaintablecellborderright" nowrap>';
			strBuffer[i] += ((currentBens[i].check_amt_total)?formatComma(roundToDecimal(currentBens[i].check_amt_total,2)):'&nbsp;');
			strBuffer[i] += '</td>';
		}
		// My Pre-Tax column data:
		strBuffer[i] += '<td class="plaintablecellborderright" nowrap>'+getPreTaxCost(currentBens[i], costDivisor)+'</td>';
		// My After-Tax Cost column data:
		strBuffer[i] += '<td class="plaintablecellborderright" nowrap>'+getAfterTaxCost(currentBens[i])+'</td>';
		// Company Cost column data:
		strBuffer[i] += '<td class="plaintablecellborderright">'+getCompanyCost(currentBens[i])+'</td></tr>';
		if (GetNbr(currentBens[i].dependents_dependent) > 0)
		{
			var lineBreak = false;
			var depsHtml = '';
			for (var x=0; x<dependentsList.length; x++)
			{
				if (currentBens[i].plan_type == dependentsList[x].plan_type && currentBens[i].plan_code == dependentsList[x].plan_code && dependentsList[x].dependent_label_name_1 
				&& dateInCompareFormat(currentBens[i].start_date) == dateInCompareFormat(dependentsList[x].emp_start) 
				&& dateInCompareFormat(effectiveDate) >= dateInCompareFormat(dependentsList[x].start_date) 
				&& (dependentsList[x].stop_date == '' || dateInCompareFormat(effectiveDate) <= dateInCompareFormat(dependentsList[x].stop_date)))
				{
					if (lineBreak)
						depsHtml += '<br/>';
					depsHtml += ' &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+dependentsList[x].dependent_label_name_1;
					lineBreak = true;
				}
			}
			if (depsHtml != '')
				strBuffer[i] += '<tr>\n<td class="plaintablecellborder" colspan="7" nowrap>\n'+depsHtml+'</td></tr>\n';
		}
	}
	benefitsHtml += strBuffer.join("");
	benefitsHtml += '</table>';
	try
	{
		self.MAIN.document.getElementById("paneHeader").innerHTML = getSeaPhrase("PLANS_AND_COVERAGE","BEN");
		if (currentBens.length == 0)
			self.MAIN.document.getElementById("paneBody").innerHTML = effectiveDateHtml+'<div class="fieldlabelboldleft">'+getSeaPhrase("CURBEN_28","BEN")+'</div>';
		else
			self.MAIN.document.getElementById("paneBody").innerHTML = effectiveDateHtml+benefitsHtml;
		self.MAIN.document.forms["mainform"].elements["effectivedate"].setAttribute("styler_dir", self.MAIN.CalendarObject.OPEN_LEFT_DOWN);
	}
	catch(e) {}
	self.MAIN.stylePage();
	if (!onsort)
	{
		self.MAIN.setLayerSizes();
		document.getElementById("MAIN").style.visibility = "visible";
	}
	else
		self.MAIN.styleSortArrow("currbenTbl", property, (sortDirection == "<") ? "ascending" : "descending");
	removeWaitAlert(getSeaPhrase("CNT_UPD_FRM","SEA",[self.MAIN.getWinTitle()]));
	fitToScreen();
}

function SortBenefits(property)
{
	var nextFunc = function()
	{
		if (sortProperty != property)
			sortDirection = "<";
		else
			sortDirection = (sortDirection == "<") ? ">" : "<";
		sortProperty = property;	
		currentBens.sort(sortByProperty);
		DspCurrentBenefits(true, property);
	};
	showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), nextFunc);
}

function GetNbr(str)
{
	if (typeof(str) == "number")
		return str;
	else if (str.length == 0)
		return 0;
	len = str.length-1;
	if (str.charAt(len) == "-")
	{
		n = Number(str.substring(0,len));
		n = 0-n;
		return n;
	}
	else
		return Number(str);
}

function payFreq(paycode)
{
	switch (paycode)
	{
		case "1": return 52;
		case "2": return 26;
		case "3": return 24;
		case "4": return 12;
		default: return 1;
	}
}

function getCoverage(bnPlan)
{
	var covStr = '&nbsp;';
	if ((bnPlan.plan_type == "HL" || bnPlan.plan_type == "DN") && (bnPlan.plan_waive_flag == "Y"))
		covStr = (getSeaPhrase("CURBEN_26","BEN")) ? getSeaPhrase("CURBEN_26","BEN") : '&nbsp;';
	else
	{
		if (fromDBFile)
		{
			if ((bnPlan.plan_type == "DI" || bnPlan.plan_type == "DL" || bnPlan.plan_type == "EL") && (GetNbr(bnPlan.cover_amt) != 0))
				covStr = (bnPlan.cover_amt) ? formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2)) : '&nbsp;';
			else if ((bnPlan.plan_type == "DN" || bnPlan.plan_type == "HL") && (GetNbr(bnPlan.cov_option) != 0))
				covStr = (bnPlan.bncovopt_cov_desc) ? bnPlan.bncovopt_cov_desc : '&nbsp;';
			else if (bnPlan.plan_type == "VA")
				covStr = (bnPlan.multiple) ? formatComma(roundToDecimal(GetNbr(bnPlan.multiple),2)) : '&nbsp;';
		}	
		else
		{
			var recType = Number(bnPlan.record_type);
			switch (recType)
			{
				case 1:
					covStr = '&nbsp;' + bnPlan.bncovopt_cov_desc;
					break;
				case 2:
					var covType = bnPlan.life_add_flg;
					if (covType == "E")
						covStr = getSeaPhrase("EMPLOYEE","BEN") + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					else if (covType == "S")
						covStr = getSeaPhrase("SPOUSE","BEN") + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					else if (covType == "D")
						covStr = getSeaPhrase("DEPENDENT","BEN") + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					else if (covType == "B" || covType == "C" || covType == "A")
					{
						var covLbl = "&nbsp;";
						if (covType == "B")
							covType = getSeaPhrase("SPOUSE","BEN");
						else if (covType == "C")
							covLbl = getSeaPhrase("DOM_PARTNER","BEN");
						else if (covType == "A")
							covLbl = getSeaPhrase("SPOUSE_OR_PARTNER","BEN");						
						covStr = '<div class="plaintablecell" style="padding-right:0px">' + covLbl + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2)) + '</div>';
						covStr += '<div class="plaintablecell" style="padding-right:0px">' + getSeaPhrase("DEPENDENT","BEN") + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.dep_cover_amt),2)) + '</div>';
					}
					else if (covType == "P")
						covStr = getSeaPhrase("DOM_PARTNER","BEN") + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					else if (covType == "O")
						covStr = getSeaPhrase("SPOUSE_OR_PARTNER","BEN") + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					else if (covType == "R")
						covStr = getSeaPhrase("PARTNER_DEPS","BEN") + '&nbsp;&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					else if (covType == "")
						covStr = '&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					break;
				case 3:
				case 4:
				case 13:
					covStr = '&nbsp;' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					break;
				case 5:
					covStr = getSeaPhrase("%_OF_SAL","BEN",[''+Number(bnPlan.salary_pct)]);
					if (GetNbr(bnPlan.cover_amt) != 0)
						covStr += '<br/>' + formatComma(roundToDecimal(GetNbr(bnPlan.cover_amt),2));
					break;
				case 6:
				case 8:
				case 9:			
					if (bnPlan.pct_amt_flag == "P")
					{
						if (GetNbr(bnPlan.annual_amt) != 0)
							covStr += '&nbsp;' + formatComma(roundToDecimal(bnPlan.annual_amt,2)) + ' ' + getSeaPhrase("PERCENT_OF_TOTAL","BEN");
					}
					else
					{
						if (GetNbr(bnPlan.annual_amt) != 0)
							covStr += '&nbsp;' + formatComma(roundToDecimal(bnPlan.annual_amt,2)) + ' ' + getSeaPhrase("PER_YEAR","BEN");					
					}
					break;		
				case 7:
					if (GetNbr(bnPlan.nbr_hours) != 0)
						covStr += formatComma(roundToDecimal(bnPlan.nbr_hours,2)) + ' ' + getSeaPhrase("HOURS","BEN");
					break;
				case 10:
				case 11:
				case 12:
					covStr = '&nbsp;';
					break;
			}			
		}
	}
	return covStr;
}

function getPreTaxCost(bnPlan, costDivisor)
{
	var pfreq = (fromDBFile) ? payFreq(bnPlan.employee_pay_frequency) : 1;
	var pretotal = roundToDecimal(GetNbr(bnPlan.cmp_flx_cont) + GetNbr(bnPlan.emp_pre_cont),2);
	var ptStr = '&nbsp;';
	if (GetNbr(bnPlan.cmp_flx_cont) < 0)
	{
		if (bnPlan.pct_amt_flag == "P")
			ptStr = formatComma(roundToDecimal(GetNbr(bnPlan.cmp_flx_cont),2)) + getSeaPhrase("PER","BEN");
		else
			ptStr = formatComma(roundToDecimal(GetNbr(bnPlan.cmp_flx_cont)/pfreq,2));
	}
	else if (GetNbr(pretotal) != 0)
	{
		if (bnPlan.pct_amt_flag == "P")
			ptStr = formatComma(pretotal) + getSeaPhrase("PER","BEN");
		else
		{
			if ((bnPlan.plan_type == "RS" || bnPlan.plan_type == "SP") && (fromDBFile || costDivisor == "P") && GetNbr(bnPlan.bond_ded_amt) != 0)
				ptStr = formatComma(roundToDecimal(GetNbr(bnPlan.bond_ded_amt),2));
			else
				ptStr = formatComma(roundToDecimal(pretotal/pfreq,2));
		}
	}
	return ptStr;
}

function getAfterTaxCost(bnPlan)
{
	var pfreq = (fromDBFile) ? payFreq(bnPlan.employee_pay_frequency) : 1;
	var afttotal = roundToDecimal(GetNbr(bnPlan.emp_aft_cont),2);
	var atStr = '&nbsp;';
	if (GetNbr(afttotal) != 0)
	{
		if (bnPlan.pct_amt_flag == "P")
			atStr = formatComma(afttotal) + getSeaPhrase("PER","BEN");
		else
		{
			if ((bnPlan.plan_type == "RS" || bnPlan.plan_type == "SP") && (fromDBFile || costDivisor == "P") && GetNbr(bnPlan.bond_ded_amt) != 0)
				atStr = formatComma(roundToDecimal(GetNbr(bnPlan.bond_ded_amt),2));
			else
		 		atStr = formatComma(roundToDecimal(afttotal/pfreq,2));
		}
	}
	return atStr;
}

function getCompanyCost(bnPlan)
{
	var pfreq = (fromDBFile) ? payFreq(bnPlan.employee_pay_frequency) : 1;
	var cStr = '&nbsp;';
	if ((GetNbr(bnPlan.comp_cont) != 0) && (GetNbr(bnPlan.comp_match) != 0))
	{
		cStr = formatComma(roundToDecimal(bnPlan.comp_match,2)) + getSeaPhrase("PER","BEN");		
		if (GetNbr(bnPlan.mtch_up_to) != 0)
		{
			cStr += ' ' + getSeaPhrase("CURBEN_33","BEN") + ' ' 
			+ formatComma(roundToDecimal(bnPlan.mtch_up_to,2)) 
			+ getSeaPhrase("CURBEN_34","BEN");
		}
		cStr += '<br/>'+ getSeaPhrase("CURBEN_27","BEN")
		+ ' ' + formatComma(roundToDecimal(bnPlan.comp_cont,2)) + ' ' + getSeaPhrase("PER_YEAR","BEN");
	}
	else if (GetNbr(bnPlan.comp_match) != 0)
		cStr = formatComma(roundToDecimal(bnPlan.comp_match,2)) + getSeaPhrase("PER","BEN");
	else if (GetNbr(bnPlan.comp_cont) != 0)
	{
		if (bnPlan.pct_amt_flag == "P" || bnPlan.plan_cmp_ded_code_p != "")
			cStr = formatComma(roundToDecimal(bnPlan.comp_cont,2)) + getSeaPhrase("PER","BEN");
		else
			cStr = formatComma(roundToDecimal(bnPlan.comp_cont/pfreq,2));
	}
	return cStr;
}

function printForm()
{
	var empName = (currentBens.length) ? currentBens[0].employee_label_name_1 : authUser.name;
	var headerHtml = '<table summary="'+getSeaPhrase("TSUM_12","SEA")+'"><tr><th scope="col" colspan="2"></th></tr>'
	+ '<caption class="offscreen">'+getSeaPhrase("TCAP_9","SEA")+'</caption>'
	+ '<tr><th scope="row" class="plaintablecell"><span class="dialoglabel" style="padding:0px;margin:0px">'+getSeaPhrase("EMPLOYEE_NAME","ESS")+':</span></th>'
	+ '<td class="plaintablecell">'+empName+'</td></tr>'	
	+ '<tr><th scope="row" class="plaintablecell"><span class="dialoglabel" style="padding:0px;margin:0px">'+getSeaPhrase("EMPLOYEE_NUMBER","ESS")+':</span></th>'
	+ '<td class="plaintablecell">'+authUser.employee+'</td></tr>'	
	+ '<tr><th scope="row" class="plaintablecell"><span class="dialoglabel" style="padding:0px;margin:0px">'+getSeaPhrase("HOME_ADDR_1","ESS")+':</span></th>'
	+ '<td class="plaintablecell">'+FormatDte4(effectiveDate)+'</td></tr>'							
	+ '</table><div style="height:20px">&nbsp;</div>';
    self.printframe.document.title = getSeaPhrase("PLANS_AND_COVERAGE","BEN")+' - '+FormatDte4(effectiveDate);
	self.printframe.document.body.innerHTML = headerHtml + benefitsHtml;
	self.printframe.stylePage();
	self.printframe.document.body.style.overflow = "visible";
	try { self.printframe.document.getElementById("currbenTbl").style.width = "650px"; } catch(e) {}
	self.printframe.focus();
	self.printframe.print();
}

function normalizeField(fldVal, fldLen)
{
	if (typeof(fldVal) != "undefined")
	{
		fldVal = fldVal.toString();
		for (var i=fldVal.length; i<fldLen; i++)
			fldVal += " ";
	}
	return fldVal;
}

function sendEmail()
{
	setTimeout(function(){showWaitAlert(getSeaPhrase("SENDING_EMAIL","ESS"))}, 50);
	if (emssObjInstance.emssObj.emailAddressType.toString().toLowerCase() == "personal")
	{	
		if (!appObj)
			appObj = new AppVersionObject(authUser.prodline, "HR");
		// if you call getAppVersion() right away and the IOS object isn't set up yet,
		// then the code will be trying to load the sso.js file, and your call for
		// the appversion will complete before the ios version is set
		if (iosHandler.getIOS() == null || iosHandler.getIOSVersionNumber() == null)
		{
	       	setTimeout("sendEmail()", 10);
	       	return;
		}
		if (!appObj || appObj.getAppVersion() == null || appObj.getAppVersion().toString() < "10.00.00")
			emssObjInstance.emssObj.emailAddressType = "work";
	}
	var flowObj = pfObj.setFlow("EMSSCurBenChg", Workflow.SERVICE_EVENT_TYPE, Workflow.ERP_SYSTEM,
		authUser.prodline, authUser.webuser, null, "");
	flowObj.addVariable("company", String(authUser.company));
	flowObj.addVariable("employee", String(authUser.employee));
	flowObj.addVariable("dateFmt", normalizeField(String(authUser.datefmt.toUpperCase()),8)+String(authUser.date_separator));
	flowObj.addVariable("effectDate", String(effectiveDate));
	flowObj.addVariable("costDivisor", String(costDivisor));			
	flowObj.addVariable("emailFormat", String(emssObjInstance.emssObj.emailFormat)+","+String(emssObjInstance.emssObj.emailAddressType));
	flowObj.addVariable("sortField", String(sortProperty));
	pfObj.triggerFlow();
	setTimeout(function(){removeWaitAlert()}, 2000);
}

function confirmEmailResponse(confirmWin)
{
	if (confirmWin.returnValue == "ok" || confirmWin.returnValue == "continue")
		sendEmail();
}

function emailForm()
{
	if (seaConfirm(getSeaPhrase("CURBEN_35","BEN"), "", confirmEmailResponse))
		sendEmail();
}

function dateInCompareFormat(fldval)
{
	if (fldval == "" || typeof(fldval) == "number" || fldval.indexOf(authUser.date_separator) == -1)
		return fldval;	
	try 
	{
		return formjsDate(formatDME(fldval));
	}
	catch(e) 
	{
		return fldval;
	}
}

function getCostDesc(costDivisor)
{
	if (costDivisor == "P")
 		return getSeaPhrase("COST_PP","BEN")
 	else if (costDivisor == "M")
 		return getSeaPhrase("COST_PM","BEN")
 	else if (costDivisor == "A")
 		return getSeaPhrase("COST_AN","BEN")
	else if (costDivisor == "S")
		return getSeaPhrase("COST_SM","BEN")
	else
		return "";
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
	var mainFrame = document.getElementById("MAIN");
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
		contentHeightBorder = contentHeight + 30;
	}
	else
	{
		contentWidth = winWidth - 10;
		contentWidthBorder = contentWidth;
		contentHeight = winHeight - 65;
		contentHeightBorder = contentHeight + 24;	
	}
	mainFrame.style.width = winWidth + "px";
	mainFrame.style.height = (winHeight - 35) + "px";
	try
	{
		if (self.MAIN.onresize && self.MAIN.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.MAIN.onresize = null;
	}
	catch(e) {}
	try
	{
		self.MAIN.document.getElementById("paneBorder").style.width = contentWidthBorder + "px";
		self.MAIN.document.getElementById("paneBodyBorder").style.width = contentWidth + "px";
		self.MAIN.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.MAIN.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.MAIN.document.getElementById("paneBody").style.width = contentWidth + "px";
		self.MAIN.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
}
</script>
<!-- MOD BY BILAL  - Prior Customizations  -->
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("UA-395426-5");
pageTracker._trackPageview();
} catch(err) {}</script>
<!-- END OF MOD -->
</head>
<body style="overflow:hidden" onload="OpenCurrentBenefits()" onresize="fitToScreen()">
	<iframe id="header" name="header" title="Header" level="1" tabindex="0" style="visibility:hidden;position:absolute;height:32px;width:803px;left:0px;top:0px" src="/lawson/xhrnet/ui/header.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="MAIN" name="MAIN" title="Main Content" level="2" tabindex="0" style="visibility:hidden;position:absolute;left:0%;height:464px;width:768px;top:32px" src="/lawson/xhrnet/ui/headerpane.htm" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	<iframe id="printframe" name="printframe" title="Empty" src="/lawson/xhrnet/ui/pane.htm" style="visibility:hidden;position:absolute;top:-1px;left:0px;height:0px;width:0px;" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="FRAME1" name="FRAME1" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/dot.htm" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	<iframe id="lawheader" name="lawheader" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/benefitslawheader.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/currentbenefits.htm,v 1.9.2.90 2014/02/17 21:29:54 brentd Exp $ -->
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
