<!DOCTYPE html>
<html lang="en">
<head>
<title>Beneficiaries</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Pragma" content="No-Cache">
<meta http-equiv="Expires" content="Mon, 01 Jan 1990 00:00:01 GMT">
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/common.js"></script>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/xhrnet/fica.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/xhrnet/statesuscan.js"></script>
<script src="/lawson/xhrnet/instctrycdselect.js"></script>
<script src="/lawson/xhrnet/pcodesselect.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/Dialog.js"></script>
<script>
///////////////////////////////////////////////////////////////////////////////////////////
//
// Global Variables.
//
var fromTask = (window.location.search)?unescape(window.location.search):"";
var parentTask = getVarFromString("from",fromTask);
var Benefits = new Array();
var Beneficiaries = new Array();
var NamePrefix = new Array();
var NameSuffix = new Array();
var Relationship = new Array();
var SysRulesRecords = new Array();
var UpdateAllViews = false;
var BenefitsRec = null;
var UpdateInProgress = false;
var BenefitKeys = "";
var appObj;

///////////////////////////////////////////////////////////////////////////////////////////
//
// Initialize function.
//
function Initialize()
{
	authenticate("frameNm='jsreturn'|funcNm='AuthenticateFinished()'|desiredEdit='EM'");
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Initialization Complete function.
//
function AuthenticateFinished()
{
    stylePage();
    self.printframe.stylePage();
    setWinTitle(getSeaPhrase("BENEFICIARIES","BEN"));
	if (parentTask != "adoption" && parentTask != "birth") 
	{
		if (fromTask)
			try { parent.document.getElementById(window.name).style.visibility = "visible"; } catch(e) {}
	}
	var nextFunc = function()
	{
		StoreDateRoutines();
		GetSysRules();
		fitToScreen();		
	};
	startProcessing(getSeaPhrase("PROCESSING","BEN"), nextFunc);
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Defined Objects.
//
function BeneficiaryObj(plantype, plancode, plandesc, seqnbr, lastname, lastpre, lastsuf, firstname, middleinit,
	pctamtflag, pmtamt, primcntgnt, currencyformsexp, labelname1, beneftype, relcode, ficanbr, empaddress,
	addr1, addr2, addr3, addr4, city, state, zip, countrycode, cmttext, trust, namesuffix, benefname1)
{
	this.plan_type = plantype;
	this.plan_code = plancode;
	this.plan_desc = plandesc; // this supplies the name
	this.seq_nbr = seqnbr;
	this.last_name = lastname;
	this.last_pre = lastpre;
	this.last_suf = lastsuf;
	this.first_name = firstname;
	this.middle_init = middleinit;
	this.pct_amt_flag = pctamtflag;
	this.pmt_amt = pmtamt;
	this.prim_cntgnt = primcntgnt;
	this.currency_forms_exp = (currencyformsexp) ? currencyformsexp : "";
	this.label_name_1 = labelname1;
	this.benef_type = beneftype;
	this.rel_code = relcode;
	this.fica_nbr = ficanbr;
	this.emp_address = empaddress;
	this.addr1 = addr1;
	this.addr2 = addr2;
	this.addr3 = addr3;
	this.addr4 = addr4;
	this.city = city;
	this.state = state;
	this.zip = zip;
	this.country_code = countrycode;
	this.cmt_text = cmttext;
	this.trust = trust;
	this.name_suffix = namesuffix;
	this.benef_name_1 = benefname1;
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// DME requests.
//
function GetSysRules() 
{
	var rulesCompany = authUser.company.toString();
	for (var i=rulesCompany.length; i<4; i++)
		rulesCompany = "0" + rulesCompany;
	var pDMEObj = new DMEObject(authUser.prodline, "SYSRULES");
	pDMEObj.out = "JAVASCRIPT";
	pDMEObj.index = "syrset1";
	pDMEObj.field = "alphadata1";
	pDMEObj.key = "BENEFICIARY=BN=BS07="+rulesCompany;
	pDMEObj.debug = false;
	pDMEObj.func = "ProccessSysRules()";
	pDMEObj.max	= "1";
	DME(pDMEObj,"jsreturn");
}

function ProccessSysRules()
{
	SysRulesRecords = self.jsreturn.record;
	BenefitKeys = "";
	if (SysRulesRecords.length > 0)
	{
		if (Number(SysRulesRecords[0].alphadata1_1) == 1)
			BenefitKeys += "DB;";
		if (Number(SysRulesRecords[0].alphadata1_2) == 1)
			BenefitKeys += "DC;";			
		if (Number(SysRulesRecords[0].alphadata1_3) == 1)
			BenefitKeys += "DI;";
		if (Number(SysRulesRecords[0].alphadata1_4) == 1)
			BenefitKeys += "DL;";
		if (Number(SysRulesRecords[0].alphadata1_5) == 1)
			BenefitKeys += "EL;";
		if (Number(SysRulesRecords[0].alphadata1_6) == 1)
			BenefitKeys += "RS;";			
		if (Number(SysRulesRecords[0].alphadata1_7) == 1)
			BenefitKeys += "SB;";
		if (Number(SysRulesRecords[0].alphadata1_8) == 1)
			BenefitKeys += "SP;";
		if (BenefitKeys != "" && BenefitKeys.charAt(BenefitKeys.length-1) == ';')
			BenefitKeys = BenefitKeys.slice(0,BenefitKeys.length-1);
	}
	else
		BenefitKeys = "DB;DC;DI;EL";
	DMEToBenefitPlans();
}

function DMEToBenefitPlans()
{
	Benefits = new Array();
	Beneficiaries = new Array();
	BenefitsRec = null;
	var pDMEObj = new DMEObject(authUser.prodline,"BENEFIT");
	pDMEObj.out = "JAVASCRIPT";
	pDMEObj.field = "plan-type;plan-code;plan.desc;start-date;stop-date;employee.label-name-1;employee.fica-nbr;employee.work-country;currency.forms-exp";
	pDMEObj.cond = "non-waive";
//	pDMEObj.key = parseInt(authUser.company,10)+"="+BenefitKeys+"="+parseInt(authUser.employee,10);
	pDMEObj.func = "ProcessBenefits()";
	pDMEObj.max = "600"; 
// MOD BY BILAL  - Prior Customization
		//ISH 2008 Only Show 401k and Life Insurance
		//CGL 01/28/2010 Add Annual Contribution (ANNU) plan to beneficiary display
		//CGL 02/13/2012 Add employee supp life (ELSP) plan to beneficiary display
		//GDD  09/27/14  Changed plan codes queried
		pDMEObj.index	= "BENSET2"
		pDMEObj.key   	= parseInt(authUser.company,10)+"=DC;EL=RET1;RET2;RET3;ELF1;RET5;RET6;RET7;ELF2="+parseInt(authUser.employee,10)
// END OF MOD
	pDMEObj.otmmax = "1";
	pDMEObj.debug = false;
	DME(pDMEObj, "jsreturn");
}

function ProcessBenefits()
{
	//PT118698: display benefits with future start dates; do not display if they have been stopped prior to the system date
	var tmpRec;
	for (var i=0; i<self.jsreturn.NbrRecs; i++) 
	{
		tmpRec = self.jsreturn.record[i];
		if (NonSpace(tmpRec.stop_date) == 0 || getDteDifference(ymdtoday,formjsDate(formatDME(tmpRec.stop_date))) > 0)
			Benefits[Benefits.length] = self.jsreturn.record[i];
	}
	if (self.jsreturn.Next != "")
		self.jsreturn.location.replace(self.jsreturn.Next);
	else 
	{
		Benefits.sort(sortByName);
		GetBeneficiary(0);
	}
}

function sortByName(obj1,obj2)
{
	var name1 = obj1.plan_desc;
	var name2 = obj2.plan_desc;
	if (name1 < name2)
		return -1;
	else if (name1 > name2)
		return 1;
	else
		return 0;
}

function GetBeneficiary(Index)
{
	if (Index >= Benefits.length)
	{
		if (!UpdateAllViews)
			GetSuffixes();
		else
			Draw();
	}
	else
	{
		var thisPlan = Benefits[Index];
		var PlanType = Benefits[Index].plan_type;
		var PlanCode = Benefits[Index].plan_code;
		if (typeof(Beneficiaries[PlanType+PlanCode]) == "undefined" || Beneficiaries[PlanType+PlanCode] == null)
		{
			Beneficiaries[PlanType+PlanCode] = new Array();
			GetBeneficiaryInfo(PlanType,PlanCode,"ProcessBeneficiaries("+Index+",'"+PlanType+"','"+PlanCode+"')");
		}
		else
			GetBeneficiary(++Index);
	}
}

function GetBeneficiaryInfo(plantype, plancode, func)
{
	var pObj = new DMEObject(authUser.prodline,"BENEFICRY");
	pObj.out = "JAVASCRIPT";
	pObj.field 	= "plan-type;plan.desc;plan-code;seq-nbr;last-name;first-name;middle-init;name-suffix;"
	+ "pct-amt-flag;pmt-amt;prim-cntgnt;first-mi-exp;benef-type;rel-code;fica-nbr;emp-address;"
	+ "addr1;addr2;addr3;addr4;city;state;zip;country-code;cmt-text;last-suf;trust;benef-name-1";
	pObj.key = parseInt(authUser.company,10)+"="+parseInt(authUser.employee,10)+"="+escape(plantype,1)+"="+escape(plancode,1);
	pObj.func = escape(func.toString(),1);
	pObj.sortasc = "last-name";
	pObj.max = "600";
	pObj.debug = false;
	DME(pObj,"jsreturn");
}

function ProcessBeneficiaries(Index, PlanType, PlanCode)
{
	// PT 118581: if the record is a trust, use BENEF-NAME-1; otherwise, construct the full name on the record.
	for (var i=0; i<self.jsreturn.NbrRecs; i++)
	{
		var thisBn = self.jsreturn.record[i];
		var Index1 = PlanType+PlanCode;
		var Index2 = Beneficiaries[PlanType+PlanCode].length;
		Beneficiaries[Index1][Index2] = new BeneficiaryObj(thisBn.plan_type,thisBn.plan_code,thisBn.plan_desc,thisBn.seq_nbr,thisBn.last_name,"",thisBn.last_suf,
			thisBn.first_name,thisBn.middle_init,thisBn.pct_amt_flag,thisBn.pmt_amt,thisBn.prim_cntgnt,Benefits[Index].currency_forms_exp,((thisBn.benef_type==1)?thisBn.benef_name_1:thisBn.first_mi_exp+' '+thisBn.last_suf),
			thisBn.benef_type,thisBn.rel_code,thisBn.fica_nbr,thisBn.emp_address,thisBn.addr1,thisBn.addr2,thisBn.addr3,thisBn.addr4,thisBn.city,thisBn.state,thisBn.zip,
			thisBn.country_code,thisBn.cmt_text,thisBn.trust,thisBn.name_suffix,thisBn.benef_name_1);
	}
	if (self.jsreturn.Next != "")
		self.jsreturn.location.replace(self.jsreturn.Next);
	else
	{
		var Index1 = PlanType+PlanCode;
		if (Beneficiaries[Index1].length == 0)
		{
			Beneficiaries[Index1][0] = new BeneficiaryObj(PlanType,PlanCode,Benefits[Index].plan_desc,"","","","","","","",0,"",Benefits[Index].currency_forms_exp,
				"","","","","","","","","","","","","","","","","");
		}
		GetBeneficiary(Index+1);
	}
}

function GetSuffixes()
{
	if (!appObj)
		appObj = new AppVersionObject(authUser.prodline, "HR");
	// if you call getAppVersion() right away and the IOS object isn't set up yet,
	// then the code will be trying to load the sso.js file, and your call for
	// the appversion will complete before the ios version is set
	if (iosHandler.getIOS() == null || iosHandler.getIOSVersionNumber() == null)
	{
       	setTimeout("GetSuffixes()", 10);
       	return;
	}
	NamePrefix = new Array();
	NameSuffix = new Array();
	var pObj = new DMEObject(authUser.prodline,"HRCTRYCODE");
	pObj.out = "JAVASCRIPT";
	pObj.field = "type;hrctry-code;description";
	pObj.index = "ctcset1";
	pObj.key = "PR;SU";
	pObj.func = "DspSuffixes()";
	pObj.max = "600";
	pObj.debug = false;
	DME(pObj,"jsreturn");
}

function DspSuffixes()
{
	for (var i=0; i<self.jsreturn.NbrRecs; i++)
	{
		if (self.jsreturn.record[i].type == "PR")
			NamePrefix[NamePrefix.length] = self.jsreturn.record[i];
		else if (self.jsreturn.record[i].type == "SU")
			NameSuffix[NameSuffix.length] = self.jsreturn.record[i];
	}
	if (self.jsreturn.Next != "")
		self.jsreturn.location.replace(self.jsreturn.Next)
	else
	{
		var condStr = "Active";
		if (appObj && appObj.getLongAppVersion() != null && appObj.getLongAppVersion().toString() >= "10.00.00.03")
			condStr = "Beneficiary";
		GetPcodesSelect(authUser.prodline,"DP","StoreRelationships()",condStr,null);
	}
}

function StoreRelationships()
{
	Relationship = PcodesInfo;
	GetCountryCodes();
}

function GetCountryCodes()
{
	GetInstCtryCdSelect(authUser.prodline,"GrabStates(\"Draw()\")");
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Draw the window. (used if you want to draw a window using javascript.
function Draw()
{
	DrawLeftFrame();
	document.getElementById("RIGHT").style.visibility = "hidden";
	if (UpdateAllViews)
		seaPageMessage(self.lawheader.gmsg, null, null, "info", null, true, getSeaPhrase("APPLICATION_ALERT","SEA"), true);
	UpdateAllViews = false;
}

// MOD BY BILAL
//ISH 2008 Open Important Notice
function OpenWinDesc()
{
	window.open("/lawson/xhrnet/importantbeneficiaries.htm","IMPORTANT","width=500,height=500,resizable=yes,toolbar=no,scrollbars=yes");
}
// END OF MOD
function DrawLeftFrame()
{
	var BeneficiaryExists = false;
	var BeneficiaryRecs;
	var strHtml = "";
	var cnt = 0;
	for (var TypeCode in Beneficiaries)
	{
		BeneficiaryRecs = Beneficiaries[TypeCode];
		var marginStr = (BeneficiaryExists) ? "margin-top:10px" : "";
		strHtml += '<table id="'+TypeCode+'Tbl" class="tableborderbox" style="'+marginStr+'" border="0" cellspacing="0" cellpadding="0" width="100%" summary="'+getSeaPhrase("TSUM_23","BEN",[BeneficiaryRecs[0].plan_desc])+'">';
		strHtml += '<caption class="offscreen">'+getSeaPhrase("TCAP_20","SEA",[BeneficiaryRecs[0].plan_desc])+'</caption>'
		strHtml += '<tr><th scope="col" colspan="2"></th></tr>'
		strHtml += '<tr><th scope="row" class="plaintablerowheader" style="width:25%">'+getSeaPhrase("PLAN_TYPE","BEN")+'</th>';
		strHtml += '<td class="plaintablecelldisplay" style="width:75%">'+PlanTypeTitle(BeneficiaryRecs[0].plan_type)+'</td></tr>';
		strHtml += '<tr><th scope="row" class="plaintablerowheaderborderbottom" style="width:25%">'+getSeaPhrase("PLAN_NAME","BEN")+'</th>';
		strHtml += '<td class="plaintablecelldisplay" style="width:75%">'+BeneficiaryRecs[0].plan_desc+'</td></tr>';
		BeneficiaryExists = true;
		if (BeneficiaryRecs[0].seq_nbr)
		{
			var len = BeneficiaryRecs.length;
			for (var i=0; i<len; i++)
			{
				if (BeneficiaryRecs[i].seq_nbr) 
				{
					cnt++;
					strHtml += DrawBeneficiary(BeneficiaryRecs[i],i,TypeCode,(cnt*3)-2);
				}
			}
		}
		strHtml += '<tr><td>&nbsp;</td><td>';
		strHtml += uiButton(getSeaPhrase("ADD_INDIVIDUAL","BEN"),"parent.AddBenefitsDetail(\'"+TypeCode+"\',0);return false",false,TypeCode+"_addindividualbtn");
		strHtml += uiButton(getSeaPhrase("ADD_TRUST","BEN"),"parent.AddBenefitsDetail(\'"+TypeCode+"\',1);return false","margin-left:5px",TypeCode+"_addtrustbtn");
		strHtml += '</td></tr></table>';
	}
	if ((window.print && BeneficiaryExists) || (fromTask && parentTask != "main"))
	{
		strHtml += '<table border="0" cellspacing="0" cellpadding="0" width="100%" role="presentation">';
		strHtml += '<tr><td class="plaintablecellright">';
		if (window.print && BeneficiaryExists)
			strHtml += uiButton(getSeaPhrase("PRINT","BEN"),"parent.printForm();return false","margin-right:5px","printbtn");
		if (fromTask && parentTask != "main")
			strHtml += uiButton(getSeaPhrase("CLOSE","BEN"),"parent.doneForm();return false",false,"closebtn");
		strHtml += '</td></tr></table>';
	}
	if (BeneficiaryExists) 
	{
		var hdrHtml = '<div class="fieldlabelboldleft" style="padding-bottom:10px;padding-left:10px">';
		hdrHtml += getSeaPhrase("ADD_BENEFICIARY","BEN");
		hdrHtml += '</div>';
		if (cnt != 0)
			hdrHtml += '<div class="fieldlabelboldleft" style="padding-bottom:10px;padding-left:10px">'+getSeaPhrase("CHANGE_BENEFICIARY","BEN")+'</div>';
		hdrHtml += '</div>';
		strHtml = hdrHtml+strHtml;
	}
	else 
	{
		var hdrHtml = '<div class="fieldlabelboldleft" style="padding-bottom:10px;padding-left:10px;padding-top:10px">'+getSeaPhrase("NO_PLANS_FOR_BEN","BEN")+'</div>';
		strHtml = hdrHtml + strHtml;
	}

	try {
// MOD BY BILAL prior Customization.
		self.LEFT.document.getElementById("paneHeader").innerHTML = getSeaPhrase("CURRENT_BENEFICIARIES","BEN");
//		self.LEFT.document.getElementById("paneBody").innerHTML = strHtml;
		self.LEFT.document.getElementById("paneBody").innerHTML = '<div align=center><a href=javascript:parent.OpenWinDesc() style="width:100%" ><font color="red"><h4>Important<br>Click and Read</h4></font></a></div>' + strHtml;
// END OF MOD
	}
	catch(e) {}
	self.LEFT.setLayerSizes();
	self.LEFT.stylePage();
	document.getElementById("LEFT").style.visibility = "visible";
	stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[self.LEFT.getWinTitle()]));
	fitToScreen();	
}

function hideButtons()
{
	var btnTags = self.LEFT.document.getElementsByTagName("BUTTON");
	for (var i=0; i<btnTags.length; i++) 
	{
		if (btnTags[i].id.indexOf("addindividualbtn") >= 0 || btnTags[i].id.indexOf("addtrustbtn") >= 0)
			btnTags[i].style.visibility = "hidden";
	}
}

function showButtons()
{
	var btnTags = self.LEFT.document.getElementsByTagName("BUTTON");
	for (var i=0; i<btnTags.length; i++) 
	{
		if (btnTags[i].id.indexOf("addindividualbtn") >= 0 || btnTags[i].id.indexOf("addtrustbtn") >= 0)
			btnTags[i].style.visibility = "visible";
	}
}

function doneForm()
{
	try 
	{
   		parent.toggleFrame("right", false);   		
   		parent.toggleFrame("relatedtask", false);
   		parent.toggleFrame("fullrelatedtask", false);		
   		parent.toggleFrame("left", true);
	}
	catch(e) {}
	// display the checkmark indicating that this task has been accessed.
	try 
	{
		parent.left.setImageVisibility("beneficiaries_checkmark","visible");
	}
	catch(e) {}
}

function DrawRightFrame(Index, Key, View)
{
	if (Index >= 0)
		BenefitsRec = Beneficiaries[Key][Index];
	else
	{
		BenefitsRec = new BeneficiaryObj(Beneficiaries[Key][0].plan_type, Beneficiaries[Key][0].plan_code, Beneficiaries[Key][0].plan_desc,0,"","","","","","","","", Beneficiaries[Key][0].currency_forms_exp,Beneficiaries[Key][0].plan_desc,
			View,"","","","","","","","","","","","","","","");
	}
	var classStr = "fieldlabelboldlite";
	hideButtons();
	var strHtml = '<form name="beneficiaryform">';
	strHtml += '<table border="0" cellspacing="0" cellpadding="0" width="100%" role="presentation">';
	strHtml += '<tr><td class="'+classStr+'" style="width:40%">'+uiRequiredFooter()+'</td><td>&nbsp;</td></tr>';
	if (View == 1)
	{
		// Trust detail fields
		// Trust
		strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="trust">'+getSeaPhrase("TRUST","BEN")+'</label></td>';
		strHtml += '<td class="plaintablecell" nowrap><textarea class="inputbox" style="text-transform:uppercase" id="trust" name="trust" cols="30" rows="2" maxlength="60" onkeyup="this.value=this.value.toUpperCase();parent.LimitTextLength(this,60)" onkeydown="parent.LimitTextLength(this,60)">'+BenefitsRec.trust+'</textarea>'+uiRequiredIcon()+'</td></tr>';
		// Blank Row
		strHtml += BlankRow(classStr);
		// Distribution Type Fields
		strHtml += DistTypeFields(BenefitsRec,classStr);
		// Blank Row
		strHtml += BlankRow(classStr);
		// Beneficiary Type
		strHtml += BeneficiaryType(BenefitsRec,classStr);
		// Blank Row
		strHtml += BlankRow(classStr);
	}
	else
	{
		// Individual detail fields
		// First Name
		strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="firstname">'+getSeaPhrase("FIRST_NAME","BEN")+'</label></td>';
		strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="firstname" name="firstname" size="15" maxlength="15" onfocus="this.select()" value="'+BenefitsRec.first_name+'">'+uiRequiredIcon()+'</td></tr>';
		// Middle Initial
		strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="middlename">'+getSeaPhrase("MID_INIT","BEN")+'</label></td>';
		strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="middlename" name="middlename" size="1" maxlength="1" onfocus="this.select()" value="'+BenefitsRec.middle_init+'"></td></tr>';
		// PT 118581: remove last name prefix
		// Last Name Prefix
		//strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="prefixes">'+getSeaPhrase("LAST_NAME_PRE","BEN")+'</label></td>';
		//strHtml += '<td class="plaintablecell" nowrap><select class="inputbox" id="prefixes" name="prefixes">';
		//strHtml += BuildPrefixes(BenefitsRec.last_pre.split('\ ')[0]);
		//strHtml += '</select></td></tr>';
		// Last Name
		strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="lastname">'+getSeaPhrase("LAST_NAME","BEN")+'</label></td>';
		strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="lastname" name="lastname" size="30" maxlength="30" onfocus="this.select()" value="'+BenefitsRec.last_name+'">'+uiRequiredIcon()+'</td></tr>';
		// Last Name Suffix
		strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="suffixes">'+getSeaPhrase("LAST_NAME_SUF","BEN")+'</label></td>';
		strHtml += '<td class="plaintablecell" nowrap><select class="inputbox" id="suffixes" name="suffixes">';
		strHtml += BuildSuffixes(BenefitsRec.name_suffix);
		strHtml += '</select></td></tr>';
		// Distribution Type Fields
		strHtml += DistTypeFields(BenefitsRec,classStr);
		// Blank Row
		strHtml += BlankRow(classStr);
		// Beneficiary Type
		strHtml += BeneficiaryType(BenefitsRec,classStr);
		// Relationship
		strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="relationship">'+getSeaPhrase("RELATIONSHIP","BEN")+'</label></td>';
		strHtml += '<td class="plaintablecell" nowrap><select class="inputbox" id="relationship" name="relationship">';
		strHtml += BuildRelationships(BenefitsRec.rel_code);
		strHtml += '</select></td></tr>';
// MOD BY BILAL - Prior customization
	//ISH 2006 starts Add Relationship to leave blank
		strHtml += '<TR><td class="'+classStr+'" style="width:40%">&nbsp;</td><td class="plaintablecell"><i><font size="-4"><small><center>For Retirement, if relationship is "Spouse" percent election should be 100%. A consent form should be filled out if designation is less than 100% for a relationship "Spouse"</center></small></i></font></td></TR>';
	//ISH end
// END OF MOD
		// Social Number
		strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="fica">'+getSeaPhrase("SOCIAL_NUMBER","BEN")+'</label></td>';
// MOD BY BILAL - Prior customization
		//strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="fica" name="fica" size="20" maxlength="20" onfocus="this.select()" value="'+BenefitsRec.fica_nbr+'"></td></tr>';
		strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="fica" name="fica" size="20" maxlength="20" onfocus="this.select()" value="'+BenefitsRec.fica_nbr+'"> (format:121-78-9073)</td></tr>';
// END OF MOD
		// Blank Row
		strHtml += BlankRow(classStr);
	}
	// Address Fields
	strHtml += AddressFields(BenefitsRec,classStr);
	// Blank Row
	strHtml += BlankRow(classStr);
	// Comments
	strHtml += CommentField(BenefitsRec,classStr+"underline");
	// Form Buttons
	strHtml += '<tr><td>&nbsp;</td><td class="plaintablecell">';
	strHtml += uiButton(getSeaPhrase("UPDATE","BEN"),"parent.updateDetail();return false","margin-top:10px");
	strHtml += uiButton(getSeaPhrase("CANCEL","BEN"),"parent.closeDetail();return false","margin-top:10px;margin-left:5px");
	if (Index >= 0)
		strHtml += uiButton(getSeaPhrase("DELETE","BEN"),"parent.deleteDetail();return false","margin-top:10px;margin-left:15px");
	strHtml += '</td></tr></table></form>';
	try 
	{
		self.RIGHT.document.getElementById("paneHeader").innerHTML = getSeaPhrase("DETAIL","BEN");
		self.RIGHT.document.getElementById("paneBody").innerHTML = strHtml;
	}
	catch(e) {}
	self.RIGHT.stylePage();
	self.RIGHT.setLayerSizes();
	document.getElementById("RIGHT").style.visibility = "visible";
	stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[self.RIGHT.getWinTitle()]));
	fitToScreen();	
}

function BlankRow(classStr)
{
	// Blank Row
	var strHtml = '<tr><td class="'+classStr+'" style="text-align:center;height:15px">&nbsp;</td><td class="plaintablecell" nowrap>&nbsp;</td></tr>';
	return strHtml;
}

function BeneficiaryType(BenefitsRec,classStr)
{
	// Beneficiary Type
	var strHtml = '<tr><td class="'+classStr+'" style="width:40%"><label for="bntype">'+getSeaPhrase("BENEFICIARY_TYPE","BEN")+'</label></td>';
	strHtml += '<td id="type" class="plaintablecell" nowrap><select class="inputbox" id="bntype" name="type">';
	strHtml += BuildBeneficiaryType(BenefitsRec.prim_cntgnt);
	strHtml += '</select>'+uiRequiredIcon()+'</td></tr>';
	return strHtml;
}

function CommentField(BenefitsRec,classStr)
{
	// Comments
	var strHtml = '<tr><td class="'+classStr+'" style="width:40%"><label for="comments">'+getSeaPhrase("COMMENTS","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><textarea class="inputbox" id="comments" name="comments" cols="30" rows="2" maxlength="60" onkeyup="parent.LimitTextLength(this,60)" onkeydown="parent.LimitTextLength(this,60)">';	
	strHtml += BenefitsRec.cmt_text;
	strHtml += '</textarea></td></tr>';
	return strHtml;
}

function AddressFields(BenefitsRec,classStr)
{
	// Employee Address
	var strHtml = '<tr><td class="'+classStr+'" style="width:40%"><label for="address">'+getSeaPhrase("EE_ADDRESS","BEN")+'</label></td>';
	strHtml += '<td id="empaddress" class="plaintablecell" nowrap><select class="inputbox" id="address" name="empaddress">';
	strHtml += BuildEmployeeAddress(BenefitsRec.emp_address);
	strHtml += '</select></td>';
	// or
	strHtml += '<tr><td class="'+classStr+' textAlignRight" style="width:40%;height:15px">'+getSeaPhrase("OR","BEN")+'</td>';
	strHtml += '<td class="plaintablecell" nowrap>&nbsp;</td></tr>';
	// Address 1
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="addr1">'+getSeaPhrase("ADDRESS1","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr1" name="addr1" size="30" maxlength="30" onfocus="this.select()" value="'+BenefitsRec.addr1+'"></td></tr>';
	// Address 2
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="addr2">'+getSeaPhrase("ADDRESS2","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr2" name="addr2" size="30" maxlength="30" onfocus="this.select()" value="'+BenefitsRec.addr2+'"></td></tr>';
	// Address 3
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="addr3">'+getSeaPhrase("ADDRESS3","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr3" name="addr3" size="30" maxlength="30" onfocus="this.select()" value="'+BenefitsRec.addr3+'"></td></tr>';
	// Address 4
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="addr4">'+getSeaPhrase("ADDRESS4","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr4" name="addr4" size="30" maxlength="30" onfocus="this.select()" value="'+BenefitsRec.addr4+'"></td></tr>';
	// City or Address 5
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="addr5">'+getSeaPhrase("ADDRESS5","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr5" name="addr5" size="18" maxlength="18" onfocus="this.select()" value="'+BenefitsRec.city+'"></td></tr>';
	// State or Province
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="states">'+getSeaPhrase("STATE_PROVINCE","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><select class="inputbox" id="states" name="states">';
	strHtml += BuildStateSelect(BenefitsRec.state,false);
	strHtml += '</select></td></tr>';
	// Postal Code
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="zip">'+getSeaPhrase("ZIP","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="zip" name="zip" size="10" maxlength="10" onfocus="this.select()" value="'+BenefitsRec.zip+'"></td></tr>';
	// Country
	strHtml += '<tr><td class="'+classStr+'" style="width:40%"><label for="country">'+getSeaPhrase("COUNTRY","BEN")+'</label></td>';
	strHtml += '<td class="plaintablecell" nowrap><select class="inputbox" id="country" name="country">';
	strHtml += DrawInstCtryCdSelect(BenefitsRec.country_code);
	strHtml += '</select></td></tr>';
	return strHtml;
}

function DistTypeFields(BenefitsRec,classStr)
{
// MOD BY BILAL - Prior customization
	var strHtml =''
	// Distribution Type
	//var strHtml = '<tr><td class="'+classStr+'"><label for="disttype">'+getSeaPhrase("DISTRIBUTION_TYPE","BEN")+'</label></td>';
	//strHtml += '<td id="amount" class="plaintablecell" nowrap><select class="inputbox" id="disttype" name="amount">';
	//strHtml += BuildDistType(BenefitsRec.pct_amt_flag);
	//strHtml += '</select>'+uiRequiredIcon()+'</td></tr>';
// END OF MOD

// MOD BY BILAL - Prior customization
	// Amount
//	strHtml += '<tr><td class="'+classStr+'"><label for="pctamt">'+getSeaPhrase("AMOUNT","BEN")+'</label></td>';
// END OF MOD 
	strHtml += '<tr><td class="'+classStr+'">Percent</td>';
	strHtml += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" name="pmtamt" size="12" maxlength="12" onfocus="this.select()" value="'+((BenefitsRec.pmt_amt)?parseFloat(BenefitsRec.pmt_amt):'')+'">'+uiRequiredIcon()+'</td></tr>';

	return strHtml;
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Helper functions: Drawing methods.
function closeDetail()
{
	for (var TypeCode in Beneficiaries)
		deactivateTableRows(TypeCode+"Tbl",self.LEFT,false,false);
	showButtons();
	document.getElementById("RIGHT").style.visibility = "hidden";
	try { self.RIGHT.document.beneficiaryform.reset(); } catch(e) {}
}

function updateOngoing()
{
	return UpdateInProgress;
}

function GetBenefitsDetail(Index, Key, RowCnt)
{
	// Disable the detail hyperlink if an update is still ongoing.
	if (updateOngoing())
		return false;
	var nextFunc = function()
	{
		for (var TypeCode in Beneficiaries)
		{
			if (TypeCode != Key)
				deactivateTableRows(TypeCode+"Tbl",self.LEFT,false,false);
		}
		activateTableRow(Key+"Tbl",RowCnt,self.LEFT);
		DrawRightFrame(Index, Key, Beneficiaries[Key][((Index < 0) ? 0 : Index)].benef_type);
	};
	startProcessing(getSeaPhrase("PROCESSING","BEN"), nextFunc);
}

function AddBenefitsDetail(Key, Type)
{
	var nextFunc = function()
	{
		for (var TypeCode in Beneficiaries)
			deactivateTableRows(TypeCode+"Tbl",self.LEFT,false,false);
		DrawRightFrame(-1, Key, Type);
	};
	startProcessing(getSeaPhrase("PROCESSING","BEN"), nextFunc);
}

function PlanTypeTitle(plantype)
{
	switch (plantype)
	{
		case "DB": return getSeaPhrase("PLAN_1","BEN"); break;
		case "DC": return getSeaPhrase("PLAN_2","BEN"); break;
		case "DI": return getSeaPhrase("PLAN_3","BEN"); break;
		case "DL": return getSeaPhrase("PLAN_6","BEN"); break;
		case "EL": return getSeaPhrase("PLAN_4","BEN"); break;
		case "RS": return getSeaPhrase("PLAN_7","BEN"); break;
		case "SB": return getSeaPhrase("PLAN_8","BEN"); break;
		case "SP": return getSeaPhrase("PLAN_9","BEN"); break;		
		default: return getSeaPhrase("PLAN_5","BEN"); break;
	}
}

function DrawBeneficiary(BenRec, Index, Key, RowCnt)
{
	var toolTip = BenRec.label_name_1+' - '+getSeaPhrase("EDIT_DTL_FOR","SEA");
	var BeneficiaryRecs = Beneficiaries[Key];
	var strHtml = '<tr><th scope="row" class="plaintablerowheader" style="width:25%">'+getSeaPhrase("NAME","BEN")+'</th>';
	strHtml += '<td class="plaintablecell" style="width:75%" nowrap>';
	strHtml += '<a href="javascript:;" onclick="parent.GetBenefitsDetail('+Index+',\''+Key+'\','+RowCnt+');return false" title="'+toolTip+'">'+BenRec.label_name_1+'<span class="offscreen"> - '+getSeaPhrase("EDIT_DTL_FOR","SEA")+'</span></a></td></tr>';
	strHtml += '<tr><th scope="row" class="plaintablerowheader" style="width:25%">'+getSeaPhrase("TYPE","BEN")+'</th>';
	strHtml += '<td class="plaintablecelldisplay" style="width:75%" nowrap>';
	strHtml += ((BenRec.prim_cntgnt == 1)?getSeaPhrase("PRIMARY","BEN"):getSeaPhrase("CONTINGENT","BEN"));
	strHtml += '</td></tr><tr>';
	if (Index+1 >= BeneficiaryRecs.length)
	{	
		strHtml += '<th scope="row" class="plaintablerowheaderborderbottom" style="width:25%">'+getSeaPhrase("AMOUNT","BEN")+'</th>';
		strHtml += '<td class="plaintablecelldisplay" style="width:75%" nowrap>';
	}	
	else
	{	
		strHtml += '<th scope="row" class="plaintablerowheader" style="padding-bottom:10px;width:25%">'+getSeaPhrase("AMOUNT","BEN")+'</th>';
		strHtml += '<td class="plaintablecelldisplay" style="padding-bottom:10px;width:75%" nowrap>';
	}
	strHtml += BenRec.pmt_amt+((BenRec.pct_amt_flag == "P")?getSeaPhrase("PER","BEN"):'&nbsp;'+BenRec.currency_forms_exp);
	strHtml += '</td></tr>';
	return strHtml;
}

function BuildPrefixes(prefix)
{
	var Str = '<option value=" "> </option>';
	for (var i=0; i<NamePrefix.length; i++)
	{
        Str += '<option value="' + NamePrefix[i].hrctry_code + '"';
		Str += (prefix == NamePrefix[i].hrctry_code) ? ' selected>' : '>';
		Str += NamePrefix[i].description+'</option>';
	}
	return Str;
}

function BuildSuffixes(suffix)
{
	var Str = '<option value=" "> </option>';
	for (var i=0; i<NameSuffix.length; i++)
	{
        Str += '<option value="' + NameSuffix[i].hrctry_code + '"';
		Str += (suffix == NameSuffix[i].hrctry_code) ? ' selected>' : '>';
		Str += NameSuffix[i].description+'</option>';
	}
	return Str;
}

function BuildRelationships(relation)
{
	var Str = '<option value=" "> </option>';
	for (var i=0; i<Relationship.length; i++)
	{
        Str += '<option value="' + Relationship[i].code + '"';
		Str += (relation == Relationship[i].code) ? ' selected>' : '>';
		Str += Relationship[i].description+'</option>';
	}
	return Str;
}

function BuildDistType(type)
{
	var Str = '<option value=" "> </option>';
    Str += '<option value="A"';
	Str += (type == "A")?' selected>':'>';
	Str += getSeaPhrase("AMOUNT","BEN")+'</option>';
    Str += '<option value="P"';
	Str += (type == "P")?' selected>':'>';
	Str += getSeaPhrase("PERCENT","BEN")+'</option>';
	return Str;
}

function BuildBeneficiaryType(type)
{
	var Str = '<option value=" "> </option>';
    Str += '<option value="1"';
	Str += (type == 1)?' selected>':'>';
	Str += getSeaPhrase("PRIMARY","BEN")+'</option>';
    Str += '<option value="2"';
	Str += (type == 2)?' selected>':'>';
	Str += getSeaPhrase("CONTINGENT","BEN")+'</option>';
	return Str;
}

function BuildEmployeeAddress(addr)
{
	var Str = '<option value=" "> </option>';
    Str += '<option value="H"';
	Str += (addr == "H")?' selected>':'>';
	Str += getSeaPhrase("HOME_ADDR","BEN")+'</option>';
    Str += '<option value="S"';
	Str += (addr == "S")?' selected>':'>';
	Str += getSeaPhrase("SUP_ADDR","BEN")+'</option>';
	return Str;
}

function LimitTextLength(txtElm, maxChars)
{
	if (!txtElm || isNaN(Number(maxChars)))
		return;
	if (txtElm.value.length > Number(maxChars))
		txtElm.value = txtElm.value.substring(0, Number(maxChars));
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Updating Methods.
function deleteDetail()
{
	var BenRec = BenefitsRec;
	var pAGSObj = new AGSObject(authUser.prodline, "BN47.1");
	pAGSObj.event = "CHG";
	pAGSObj.rtn = "DATA";
	pAGSObj.longNames = true;
	pAGSObj.tds = false;
	pAGSObj.func = "parent.formDeleted()";
	pAGSObj.field = "FC=C"
	+ "&BEN-COMPANY=" + authUser.company
	+ "&BEN-EMPLOYEE=" + authUser.employee
	+ "&BEN-PLAN-TYPE=" + escape(BenRec.plan_type,1)
	+ "&BEN-PLAN-CODE=" + escape(BenRec.plan_code,1)
	+ "&LINE-FC1=D"
	+ "&BNF-LAST-NAME1=" + ParseAGSValue(BenRec.last_name,1)
	+ "&BNF-FIRST-NAME1=" + ParseAGSValue(BenRec.first_name,1)
	+ "&BNF-MIDDLE-INIT1=" + ParseAGSValue(BenRec.middle_init,1)
	+ "&BNF-NAME-SUFFIX1=" + ParseAGSValue(BenRec.name_suffix,1)
	+ "&BNF-PCT-AMT-FLAG1=" + ParseAGSValue(BenRec.pct_amt_flag,1)
	+ "&BNF-PMT-AMT1=" + ParseAGSValue(BenRec.pmt_amt,1)
	+ "&BNF-PRIM-CNTGNT1=" + ((BenRec.prim_cntgnt == 1) ? "P" : "C")
	+ "&BNF-SEQ-NBR1=" + escape(BenRec.seq_nbr,1);
	pAGSObj.out = "JAVASCRIPT";
	pAGSObj.debug = false;
	UpdateInProgress = true;
	startProcessing(getSeaPhrase("PROCESSING","BEN"), function(){AGS(pAGSObj, "jsreturn");});
}

function formDeleted()
{
	UpdateInProgress = false;
	if (self.lawheader.gmsgnbr == "000")
	{
		UpdateAllViews = true;
		closeDetail();
		DMEToBenefitPlans();
	}
	else
	{
		stopProcessing();
		seaAlert(self.lawheader.gmsg, null, null, "error");
	}
}

function updateDetail()
{
//MOD BY BILAL - Prior Customization
	//ISH 2007 Fields values change to upper case as .toUpperCase()
	var BenRec = BenefitsRec;
	var BenDoc = self.RIGHT.document;
	var BenForm = self.RIGHT.document.beneficiaryform;
	var	str = escape(BenForm.comments.value)
	str = str.split("%0D%0A").join("\ ");
	str = str.split("%0D").join("\ ");
	str = str.split("%0A").join("\ ");
	var pAgsObj = new AGSObject(authUser.prodline, "BN47.1")
	pAgsObj.rtn = "DATA"
	pAgsObj.longNames = "ALL"
	pAgsObj.tds = false
	pAgsObj.event = (BenRec.seq_nbr > 0) ? "CHANGE" : "ADD"
	pAgsObj.field = ((BenRec.seq_nbr > 0) ? "FC=C": "FC=A")
	+ "&BEN-COMPANY=" + escape(parseInt(authUser.company,10))
	+ "&BEN-EMPLOYEE=" + escape(parseInt(authUser.employee,10))
	+ "&BEN-PLAN-TYPE=" + ParseAGSValue(BenRec.plan_type,1)
	+ "&BEN-PLAN-CODE=" + ParseAGSValue(BenRec.plan_code,1)
	+ "&LINE-FC1=" + ((BenRec.seq_nbr > 0) ? "C" : "A")
	+ "&BNF-TYPE1=" + BenRec.benef_type
	+ "&BNF-CMT-TEXT1=" + ParseAGSValue(unescape(str),1)
	+ "&USER-ID1=" + "W" + String(authUser.employee);
	clearRequiredField(BenDoc.getElementById("empaddress"));
	if (BenForm.empaddress.selectedIndex > 0)
	{
		if (NonSpace(BenForm.addr1.value) || NonSpace(BenForm.addr2.value) || NonSpace(BenForm.addr3.value) || NonSpace(BenForm.addr4.value)
		|| NonSpace(BenForm.addr5.value) || BenForm.states.selectedIndex > 0 || NonSpace(BenForm.zip.value) || BenForm.country.selectedIndex > 0)
		{
			// Home Address edit
			if (BenForm.empaddress.selectedIndex == 1)
			{
				setRequiredField(BenDoc.getElementById("empaddress"), getSeaPhrase("HOME_ADDR_SELECTED","BEN"), BenForm.empaddress);
				return;
			}
			// Supplemental Address edit
			if (BenForm.empaddress.selectedIndex == 2)
			{
				setRequiredField(BenDoc.getElementById("empaddress"), getSeaPhrase("SUP_ADDR_SELECTED","BEN"), BenForm.empaddress);
				return;
			}
		}
		//PT 158906 added addition field as spaces
// MOD BY BILAL - Converting into UPPERCASE
		pAgsObj.field += "&EMP-ADDRESS1=" + ParseAGSValue(BenForm.empaddress.options[BenForm.empaddress.selectedIndex].value.toUpperCase(), 1)
		+ "&BNF-ADDR11=" + escape(' ')
		+ "&BNF-ADDR21=" + escape(' ')
		+ "&BNF-ADDR31=" + escape(' ')
		+ "&BNF-ADDR41=" + escape(' ')
		+ "&BNF-CITY1=" + escape(' ')
		+ "&BNF-STATE1=" + escape(' ')
		+ "&BNF-ZIP1=" + escape(' ')
		+ "&BNF-COUNTRY-CODE1=" + escape(' ');
	}
	else
	{
		pAgsObj.field	+= "&BNF-ADDR11=" + ParseAGSValue(BenForm.addr1.value.toUpperCase(), 1)
			+ "&BNF-ADDR21="        + ParseAGSValue(BenForm.addr2.value.toUpperCase(), 1)
			+ "&BNF-ADDR31="        + ParseAGSValue(BenForm.addr3.value.toUpperCase(), 1)
			+ "&BNF-ADDR41="        + ParseAGSValue(BenForm.addr4.value.toUpperCase(), 1)
			+ "&BNF-CITY1="         + ParseAGSValue(BenForm.addr5.value.toUpperCase(), 1)
			+ "&BNF-STATE1="        + ParseAGSValue(BenForm.states.options[BenForm.states.selectedIndex].value.toUpperCase(), 1)
			+ "&BNF-ZIP1="          + ParseAGSValue(BenForm.zip.value.toUpperCase(), 1)
			+ "&BNF-COUNTRY-CODE1=" + ParseAGSValue(BenForm.country.options[BenForm.country.selectedIndex].value.toUpperCase(), 1)
		+ "&EMP-ADDRESS1=" + escape(' ');
	}
	clearRequiredField(BenDoc.getElementById("type"));
	clearRequiredField(BenForm.pmtamt);
// MOD BY BIAL - Prior customization
//	clearRequiredField(BenDoc.getElementById("amount"));
	try { clearRequiredField(BenForm.fica) } 
	    catch(e) {};
// END OF MOD

	if (BenRec.benef_type == 0)
	{
		clearRequiredField(BenForm.firstname);
		clearRequiredField(BenForm.lastname);
		clearRequiredField(BenForm.fica);
		// First Name edit
		if (!NonSpace(BenForm.firstname.value))
		{
			setRequiredField(BenForm.firstname, getSeaPhrase("BEN_NAME_REQUIRED","BEN"));
			return;
		}
		// Last Name edit
		if (!NonSpace(BenForm.lastname.value))
		{
			setRequiredField(BenForm.lastname, getSeaPhrase("BEN_NAME_REQUIRED","BEN"));
			return;
		}  
// MOD BY BILAL - Prior Customization
		// Distribution Type edit
		//if (BenForm.amount.selectedIndex == 0)
		//{
		//	setRequiredField(BenDoc.getElementById("amount"), getSeaPhrase("DISTRIBUTION_TYPE_REQUIRED","BEN"));
		//	return;
		//}
// END OF MOD
		// Amount edit
		if (!NonSpace(BenForm.pmtamt.value))
		{
			setRequiredField(BenForm.pmtamt, getSeaPhrase("ENTER","BEN"), BenForm.pmtamt);
			return;
		}
		// Amount edit
		if (isNaN(parseFloat(BenForm.pmtamt.value)) || !ValidNumber(BenForm.pmtamt,12,2))
		{
			setRequiredField(BenForm.pmtamt, getSeaPhrase("INVALID_NUMBER","BEN"));
			return;
		}
		// Only allow up to 100% distribution.
// MOD BY BILAL - Prior customization
    //ISH 2008 Modify Amount to be P
//		if (BenForm.amount.selectedIndex == 2 && parseInt(BenForm.pmtamt.value,10) > 100)
		if(parseInt(BenForm.pmtamt.value, 10) > 100)
		{
			setRequiredField(BenForm.pmtamt, getSeaPhrase("SUM_OVERFLOW","BEN"));
			return;
		}

// CUSTOM EDIT ADDED.
		if(ParseAGSValue(BenForm.relationship.options[BenForm.relationship.selectedIndex].value,1)=="SPOUSE")
		{
			if (BenForm.pmtamt.value != 100)
			{
				setRequiredField(BenForm.pmtamt);
				seaAlert("If relationship is \"Spouse\", percent election should be 100%. \nA consent form should be filled out if designation is less than \n 100% for a relationship \"Spouse\"");
				BenForm.pmtamt.focus();
			    return;
			}
		}

// END OF MOD
		// Beneficiary Type edit
		if (BenForm.type.selectedIndex == 0)
		{
			setRequiredField(BenDoc.getElementById("type"), getSeaPhrase("BENEFICIARY_TYPE_REQUIRED","BEN"), BenForm.type);
			return;
		}
		// Social Number edit
		if (emssObjInstance.emssObj.validateSSNFormat && NonSpace(BenForm.fica.value) > 0 && ValidSSN(BenForm.fica, Benefits[0].employee_work_country) == false)
		{
			setRequiredField(BenForm.fica, getSeaPhrase("INVALID_SSN","SEA"));
			return;			
		}		
		pAgsObj.field += "&BNF-LAST-NAME1="	+ ParseAGSValue(BenForm.lastname.value.toUpperCase(),1)
		+ "&BNF-FIRST-NAME1=" 			+ ParseAGSValue(BenForm.firstname.value.toUpperCase(),1)
		+ "&BNF-MIDDLE-INIT1=" 			+ ParseAGSValue(BenForm.middlename.value.toUpperCase(),1)

		//+ "&BNF-LAST-NAME-PRE1=" + ParseAGSValue(BenForm.prefixes.options[BenForm.prefixes.selectedIndex].value,1)
		+ "&BNF-NAME-SUFFIX1=" 			+ ParseAGSValue(BenForm.suffixes.options[BenForm.suffixes.selectedIndex].value.toUpperCase(),1)
		+ "&BNF-REL-CODE1=" + ParseAGSValue(BenForm.relationship.options[BenForm.relationship.selectedIndex].value,1)
		+ "&BNF-FICA-NBR1=" + ParseAGSValue(BenForm.fica.value,1)
		+ "&BNF-TRUST1=" + escape(" ");
// END OF MOD
	}
	else
	{
		clearRequiredField(BenForm.trust);
		if (!NonSpace(BenForm.trust.value))
		{
			setRequiredField(BenForm.trust, getSeaPhrase("TRUST_NAME_REQUIRED","BEN"));
			return;
		} 
// MOD BY BILAL
		// Distribution Type edit
		//if (BenForm.amount.selectedIndex == 0)
		//{
		//	setRequiredField(BenDoc.getElementById("amount"), getSeaPhrase("DISTRIBUTION_TYPE_REQUIRED","BEN"), BenForm.type);
		//	return;
		//}
// END OF MOD
		// Amount edit
		if (!NonSpace(BenForm.pmtamt.value))
		{
			setRequiredField(BenForm.pmtamt, getSeaPhrase("ENTER","BEN"));
			return;
		}
		// Amount edit
		if (isNaN(parseFloat(BenForm.pmtamt.value)) || !ValidNumber(BenForm.pmtamt,12,2))
		{
			setRequiredField(BenForm.pmtamt, getSeaPhrase("INVALID_NUMBER","BEN"));
			return;
		}
		// Only allow up to 100% distribution.
// MOD BY BILAL - Prior Customization
		// ISH 2008 
		//if (BenForm.amount.selectedIndex == 2 && parseInt(BenForm.pmtamt.value,10) > 100)
		if(parseInt(BenForm.pmtamt.value,10) > 100)
		{
			setRequiredField(BenForm.pmtamt, getSeaPhrase("SUM_OVERFLOW","BEN"));
			return;
		}
// END OF MOD
		// Beneficiary Type edit
		if (BenForm.type.selectedIndex == 0)
		{
			setRequiredField(BenDoc.getElementById("type"), getSeaPhrase("BENEFICIARY_TYPE_REQUIRED","BEN"), BenForm.type);
			return;
		}
		str = escape(BenForm.trust.value);
		str = str.split("%0D%0A").join("\ ");
		str = str.split("%0D").join("\ ");
		str = str.split("%0A").join("\ ");
		pAgsObj.field += "&BNF-TRUST1=" + ParseAGSValue(unescape(str),1);
		pAgsObj.field += "&BNF-LAST-NAME1=" + escape(' ');
		pAgsObj.field +="&BNF-FIRST-NAME1=" + escape(' ');
		pAgsObj.field +="&BNF-MIDDLE-INIT1=" + escape(' ');
		pAgsObj.field +="&BNF-LAST-NAME-PRE1=" + escape(' ');
		pAgsObj.field +="&BNF-NAME-SUFFIX1=" + escape(' ');
		pAgsObj.field +="&BNF-REL-CODE1=" + escape(' ');
		pAgsObj.field +="&BNF-FICA-NBR1=" + escape(' ');
	}
	pAgsObj.field += "&BNF-PRIM-CNTGNT1=" + ((BenForm.type.selectedIndex == 2) ? "2" : "1")
	+ "&BNF-PMT-AMT1=" + ParseAGSValue(parseFloat(BenForm.pmtamt.value),1)
// MOD BY BILAL - Prior customization
      // JRZ 12/11/08 Only pulling Pre-tax
//	+ "&BNF-PCT-AMT-FLAG1=" + ((BenForm.amount.selectedIndex == 2) ? "P" : "A")
	+ "&BNF-PCT-AMT-FLAG1=P"
      //~JRZ
// END OF MOD

	if (BenRec.seq_nbr > 0) {
		pAgsObj.field += "&BNF-SEQ-NBR1=" + ParseAGSValue(parseInt(BenRec.seq_nbr,10),1)
		pAgsObj.field +="&WEB-SEQ-NBR=" + ParseAGSValue(parseInt(BenRec.seq_nbr,10),1)
		pAgsObj.field += "&WEB-UPDATE-FL=Y";
	}
	pAgsObj.dtlField = "LINE-FC;BNF-TYPE;BNF-CMT-TEXT;USER-ID;EMP-ADDRESS;BNF-ADDR1;BNF-ADDR2;BNF-ADDR3;BNF-ADDR4;"
	+ "BNF-CITY;BNF-STATE;BNF-ZIP;BNF-COUNTRY-CODE;BNF-LAST-NAME;BNF-FIRST-NAME;BNF-MIDDLE-INIT;BNF-LAST-NAME-PRE;"
	+ "BNF-NAME-SUFFIX;BNF-REL-CODE;BNF-FICA-NBR;BNF-TRUST;BNF-PRIM-CNTGNT;BNF-PMT-AMT;BNF-PCT-AMT-FLAG;BNF-SEQ-NBR";
	pAgsObj.func = "parent.updateFinished()";
	pAgsObj.debug = false;
	self.lawheader.gmsgnbr = -1;
	UpdateInProgress = true;
	startProcessing(getSeaPhrase("PROCESSING","BEN"), function(){AGS(pAgsObj,"jsreturn");});
}

function updateFinished()
{
	UpdateInProgress = false;
	var BenDoc = self.RIGHT.document;
	if (self.lawheader.gmsgnbr == "000")
	{
		UpdateAllViews 	= true;
		closeDetail();
		DMEToBenefitPlans();
	}
	else
	{
		stopProcessing();
	    if (self.lawheader.gmsgnbr == "109")
			setRequiredField(BenDoc.getElementById("amount"), getSeaPhrase("DISTRIBUTION_MUST_BE_AMOUNT","BEN"), BenDoc.beneficiaryform.type);
		else if (self.lawheader.gmsgnbr == "110")
			setRequiredField(BenDoc.getElementById("amount"), getSeaPhrase("DISTRIBUTION_MUST_BE_PERCENT","BEN"), BenDoc.beneficiaryform.type);
		else if (self.lawheader.gmsgnbr == "125")
			setRequiredField(BenDoc.getElementById("amount"), getSeaPhrase("DELETE_AND_READD","BEN"), BenDoc.beneficiaryform.type);
		else
			seaAlert(self.lawheader.gmsg, null, null, "error");
	}
}

function maskSocialNbr(socialNbr)
{
	return socialNbr.substring(socialNbr.length-4,socialNbr.length);
}

function printForm()
{
	var nextFunc = function()
	{
		var tmpBnRecs;
		var BeneficiaryExists = false;
		var strHtml = '<div class="plaintableheader" style="text-align:center" role="heading" aria-level="1">'+getSeaPhrase("BENEFICIARY_DESIGNATION","BEN")+'<div>';
		strHtml += '<table border="0" cellspacing="0" cellpadding="0" summary="'+getSeaPhrase("TSUM_12","SEA")+'">';
		strHtml += '<caption class="offscreen">'+getSeaPhrase("TCAP_9","SEA")+'</caption>'
		strHtml += '<tr><th scope="col" colspan="2"></th></tr>';
		strHtml += '<tr><th scope="row" class="plaintableheader">'+getSeaPhrase("EMPNAME","BEN")+'</th>';
		strHtml += '<td class="plaintablecellright" nowrap>'+((Benefits.length)?Benefits[0].employee_label_name_1:authUser.name)+'</td></tr>';	
		strHtml += '<tr><th scope="row" class="plaintableheader">'+getSeaPhrase("EMPNUM","BEN")+'</th>';
		strHtml += '<td class="plaintablecellright" nowrap>'+authUser.employee+'</td></tr>';
// MOD BY BILAL - Prior Customization
		//ISH 2007 Remove SSN
//		strHtml += '<tr><th scope="row" class="plaintableheader">'+getSeaPhrase("SSN","BEN")+'</th>';
//		strHtml += '<td class="plaintablecellright" nowrap>'+((Benefits.length)?maskSocialNbr(Benefits[0].employee_fica_nbr):'')+'</td></tr>';
		strHtml += '</table><p/>';
		for (var TypeCode in Beneficiaries)
		{
			tmpBnRecs = Beneficiaries[TypeCode];
			var marginStr = (BeneficiaryExists) ? "margin-top:10px" : "";
			strHtml += '<table class="tableborderbox" style="'+marginStr+'" border="0" cellspacing="0" cellpadding="0" width="100%" summary="'+getSeaPhrase("TSUM_23","BEN",[tmpBnRecs[0].plan_desc])+'">';
			strHtml += '<caption class="offscreen">'+getSeaPhrase("TCAP_20","SEA",[tmpBnRecs[0].plan_desc])+'</caption>'
			strHtml += '<tr><th scope="col" colspan="2"></th></tr>'
			strHtml += '<tr class="tablerowhighlight" style="border-bottom:#dddddd 1px solid">';
			strHtml += '<th scope="row" class="plaintablerowheader" style="width:25%">'+getSeaPhrase("PLAN_TYPE","BEN")+'</th>';
			strHtml += '<td class="plaintableheader" style="width:75%">'+PlanTypeTitle(tmpBnRecs[0].plan_type)+'</td></tr>';
			strHtml += '<tr class="tablerowhighlight"><th scope="row" class="plaintablerowheader" style="width:25%">'+getSeaPhrase("PLAN_NAME","BEN")+'</th>';
			strHtml += '<td class="plaintableheader" style="width:75%">'+tmpBnRecs[0].plan_desc+'</td></tr>';
			BeneficiaryExists = true;
			if (tmpBnRecs[0].seq_nbr)
			{
				for (var i=0; i<tmpBnRecs.length; i++)
				{
					if (tmpBnRecs[i].seq_nbr)
						strHtml += DrawBeneficiary(tmpBnRecs[i],i,TypeCode);
				}
			}
			else 
			{
				strHtml += '<tr><th scope="row" class="plaintableheader" style="width:25%">&nbsp;</th>';
				strHtml += '<td class="plaintableheader" style="width:75%">'+getSeaPhrase("NO_BEN_SPECIFIED","BEN")+'</td></tr>';
			}
			strHtml += '</table>';
		}
		strHtml += '<p/><p/><p/>';	
// MOD BY BILAL - Prior customization
		//ISH 2007 Remove Signature Line
//		strHtml += '<table border="0" cellspacing="0" cellpadding="0" width="100%" role="presentation">';
//		strHtml += '<tr><td class="plaintableheader">_______________________________</td>';
//		strHtml += '<td class="plaintableheader">___________________________</td>';
//		strHtml += '<td class="plaintableheader">_____________</td></tr>';
//		strHtml += '<tr><td class="plaintableheader">'+getSeaPhrase("PRINT_EE_NAME","BEN")+'</td>';
//		strHtml += '<td class="plaintableheader">'+getSeaPhrase("SIGNATURE","BEN")+'</td>';
//		strHtml += '<td class="plaintableheader">'+getSeaPhrase("DATE","BEN")+'</td></tr>';
//		strHtml += '</table>';
// END OF MOD
	    self.printframe.document.title = getSeaPhrase("BENEFICIARIES","BEN");
	    self.printframe.document.body.innerHTML = strHtml;
		self.printframe.stylePage();
		self.printframe.document.body.style.overflow = "visible";
		stopProcessing();
		sendToPrinter();
	};
	startProcessing(getSeaPhrase("PROCESSING","BEN"), nextFunc);
}

function OpenHelpDialog()
{
	openHelpDialogWindow("/lawson/xhrnet/Beneficiaries/SHR002_help.htm");
}

function sendToPrinter()
{
	self.printframe.focus();
	self.printframe.print();
}

function ParseAGSValue(value, flag)
{
	return (value == "") ? escape(" ") : escape(value,1);
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
	var leftFrame = document.getElementById("LEFT");
	var rightFrame = document.getElementById("RIGHT");
	var winObj = getWinSize();
	var winWidth = winObj[0];	
	var winHeight = winObj[1];
	var contentHeightBorder;
	var contentHeight;	
	var contentLeftWidthBorder;
	var contentLeftWidth;	
	var contentRightWidthBorder;
	var contentRightWidth;
	if (window.styler && window.styler.showInfor)
	{	
		contentLeftWidth = parseInt(winWidth*.50) - 10;
		contentLeftWidthBorder = (navigator.appName.indexOf("Microsoft") >= 0) ? contentLeftWidth + 5 : contentLeftWidth + 2;
		contentRightWidth = parseInt(winWidth*.50) - 10;
		contentRightWidthBorder = (navigator.appName.indexOf("Microsoft") >= 0) ? contentRightWidth + 5 : contentRightWidth + 2;						
		contentHeight = winHeight - 65;
		contentHeightBorder = contentHeight + 30;	
	}
	else if (window.styler && (window.styler.showLDS || window.styler.showInfor3))
	{
		contentLeftWidth = parseInt(winWidth*.50) - 20;
		contentLeftWidthBorder = (window.styler.showInfor3) ? contentLeftWidth + 7 : contentLeftWidth + 17;
		contentRightWidth = parseInt(winWidth*.50) - 20;
		contentRightWidthBorder = (window.styler.showInfor3) ? contentRightWidth + 7 : contentRightWidth + 17;				
		contentHeight = winHeight - 75;	
		contentHeightBorder = contentHeight + 30;		
	}
	else
	{
		contentLeftWidth = parseInt(winWidth*.50) - 10;
		contentLeftWidthBorder = contentLeftWidth;	
		contentRightWidth = parseInt(winWidth*.50) - 10;
		contentRightWidthBorder = contentRightWidth;			
		contentHeight = winHeight - 60;
		contentHeightBorder = contentHeight + 24;		
	}
	leftFrame.style.width = parseInt(winWidth*.50) + "px";
	leftFrame.style.height = winHeight + "px";
	try
	{
		if (self.LEFT.onresize && self.LEFT.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.LEFT.onresize = null;		
	}
	catch(e) {}
	try
	{
		self.LEFT.document.getElementById("paneBorder").style.width = contentLeftWidthBorder + "px";
		self.LEFT.document.getElementById("paneBodyBorder").style.width = contentLeftWidth + "px";
		self.LEFT.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.LEFT.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.LEFT.document.getElementById("paneBody").style.width = contentLeftWidth + "px";
		self.LEFT.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
	rightFrame.style.width = parseInt(winWidth*.50) + "px";
	rightFrame.style.height = winHeight + "px";
	try
	{
		if (self.RIGHT.onresize && self.RIGHT.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.RIGHT.onresize = null;		
	}
	catch(e) {}
	try
	{
		self.RIGHT.document.getElementById("paneBorder").style.width = contentRightWidthBorder + "px";
		self.RIGHT.document.getElementById("paneBodyBorder").style.width = contentRightWidth + "px";
		self.RIGHT.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.RIGHT.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.RIGHT.document.getElementById("paneBody").style.width = contentRightWidth + "px";
		self.RIGHT.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
	if (window.styler && window.styler.textDir == "rtl")
	{
		leftFrame.style.left = "";
		leftFrame.style.right = "0px";	
		rightFrame.style.left = "0px";
	}
	else
		rightFrame.style.left = parseInt(winWidth*.50,10) + "px";
}
</script>
<!-- MOD BY BILAL  prior customizations -->
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
<body style="overflow:hidden" onload="Initialize()" onresize="fitToScreen()">
	<iframe id="LEFT" name="LEFT" title="Content" level="2" tabindex="0" style="position:absolute;top:0px;left:0px;width:49%;height:464px;visibility:hidden" src="/lawson/xhrnet/ui/headerpane.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="RIGHT" name="RIGHT" title="Secondary Content" level="3" tabindex="0" style="position:absolute;top:0px;left:49%;width:51%;height:464px;visibility:hidden" src="/lawson/xhrnet/ui/headerpanehelplite.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="printframe" name="printframe" title="Empty" src="/lawson/xhrnet/ui/pane.htm" style="visibility:hidden;height:0px;width:0px;" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="jsreturn" name="jsreturn" title="Empty" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;height:0px;width:0px;" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="lawheader" name="lawheader" title="Empty" src="/lawson/xhrnet/Beneficiaries/SHR002_law.htm" style="visibility:hidden;height:0px;width:0px;" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/Beneficiaries/SHR002.htm,v 1.24.2.69 2014/02/24 22:02:32 brentd Exp $ -->
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