<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Pragma" content="No-Cache">
<meta http-equiv="Expires" content="Mon, 01 Jan 1990 00:00:01 GMT">
<title>Dependents</title>
<script src="/lawson/webappjs/common.js"></script>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/xhrnet/statesuscan.js"></script>
<script src="/lawson/xhrnet/empinfo.js"></script>
<script src="/lawson/xhrnet/depinfo.js"></script>
<script src="/lawson/xhrnet/fica.js"></script>
<script src="/lawson/xhrnet/instctrycdselect.js"></script>
<script src="/lawson/xhrnet/hrctrycodeselect.js"></script>
<script src="/lawson/xhrnet/pcodesselect.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/xhrnet/waitalert.js"></script>
<script>
var fromTask = (window.location.search)?unescape(window.location.search):"";
var emdseqnbr = 0;
var CurrentDep = new Object();
var prm = 3;
var taskNm = " ";
var geffectd = "";
var userAction = "";
var freeES10DepNbr = 1;
var currentDepIndex = -1;
var depTabs;
var familyStatusExists = false;
var onLoad = true;
var relationData = new Array();
var physicianData = new Array();
var _action;
var appObj;
var isStudent = false;
seaAlert = parent.seaAlert;
if (fromTask)
{
	geffectd = getVarFromString("date",fromTask);
	switch (getVarFromString("from",fromTask))
	{
		case "adoption": prm = 1; taskNm = "ADOPTION"; break;
		case "birth": prm = 2; taskNm = "BIRTH"; break;
		case "divorce":	prm = 3; taskNm = "DIVORCE"; break;
		case "legalsep": prm = 3; taskNm = "LEGAL SEP"; break;
		case "marriage": prm = 3; taskNm = "MARRIAGE"; break;
		case "benenroll": prm = 4; taskNm = "BENENROLL"; break;
	}
	fromTask = (taskNm != "") ? fromTask : "";
}

function InitDependents()
{
	// Check if a parent or opener document has already done an authenticate, otherwise go get the webuser info.
	authUser = null;
	try
	{
		if (parent && typeof(parent.authUser) != "undefined" && parent.authUser != null)
		{
			authUser = parent.authUser;
			if (typeof(parent.EmpInfo) != "undefined" && parent.EmpInfo != null)
			{
				EmpInfo = parent.EmpInfo;
				CalledEmpInfo = parent.CalledEmpInfo;
			}
			if (typeof(parent.DepInfo) != "undefined" && parent.DepInfo != null)
			{
				DepInfo = parent.DepInfo;
				CalledDepInfo = parent.CalledDepInfo;
			}
		}
		else if (opener && typeof(opener.authUser) != "undefined" && opener.authUser != null)
		{
			authUser = opener.authUser;
			if (typeof(opener.EmpInfo) != "undefined" && opener.EmpInfo != null)
			{
				EmpInfo = opener.EmpInfo;
				CalledEmpInfo = opener.CalledEmpInfo;
			}
			if (typeof(opener.DepInfo) != "undefined" && opener.DepInfo != null)
			{
				DepInfo = opener.DepInfo;
				CalledDepInfo = opener.CalledDepInfo;
			}
		}
	}
	catch(e) 
	{
		authUser = null;
		EmpInfo = new Array();
		DepInfo = new Array();
		CalledEmpInfo = false;
		CalledDepInfo = false;
	}
	if (!authUser)
	{
		authenticate("frameNm='jsreturn'|funcNm='LoadDependents()'|desiredEdit='EM'");
		return;
	}
	LoadDependents();
}

function LoadDependents()
{
	stylePage();
	setWinTitle(getSeaPhrase("LIFE_EVENTS_4","ESS"));
	if (fromTask)
		try { parent.document.getElementById(window.name).style.visibility = "visible"; } catch(e) {}
	startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), GetEmdepend);
}

function GetEmdepend()
{
	GetDepInfo(authUser.prodline,authUser.company,authUser.employee,"","CheckForEmpInfo()","");
}

function CheckForEmpInfo()
{
	if (DepInfo.length > 0)
		EmpInfo.employee_work_country = DepInfo[0].employee_work_country;
	else if (typeof(EmpInfo.employee_work_country) == "undefined" || !CalledEmpInfo)
	{
		GetEmpInfo(authUser.prodline,authUser.company,authUser.employee,"paemployee","employee.work-country;","GetCountryCodeInfo()");
		return;
	}
	GetCountryCodeInfo();
}

function GetCountryCodeInfo()
{
	GetInstCtryCdSelect(authUser.prodline,"GetStateProvinceInfo()");
}

function GetStateProvinceInfo()
{
	if (onLoad && (prm == 1 || prm == 2))
	{
		for (var i=0; i<DepInfo.length; i++)
		{
			if (parseInt(DepInfo[i].seq_nbr,10) > emdseqnbr)
				emdseqnbr = parseInt(DepInfo[i].seq_nbr,10);
		}
		GrabStates("AddDependent()");
	}
	else
		GrabStates("DrawDepListScreen()");
}

function MaskSocialNbr(socialNbr)
{
	return socialNbr.substring(socialNbr.length-4,socialNbr.length);
}
// MOD BY BILAL - Prior customizations.
//ISH 2008 Add Important Window
function OpenWinDesc()
{
	window.open("/lawson/xhrnet/importantdependent.htm","IMPORTANT","width=500,height=500,resizable=yes,toolbar=no,scrollbars=yes");
}
// END OF MOD
function DrawDepListScreen()
{
	var rowNbr = -1;
	var rowClass = "";
	var thisDep = new Object();
   	emdseqnbr = 0;
   	onLoad = false;
   	var toolTip = getSeaPhrase("DEP_32","ESS");
// MOD BY BILAL - Prior Customizations
	//ISH 2008 Disclaimer
    var customMsg =  '<TABLE width="100%"><TR><td align="middle"><a href="javascript:parent.OpenWinDesc()"><font color=red><h3>Important!<br>Click and read</h3></font></a></TD></TR></TABLE>'
// END OF MOD
// MOD BY BILAL
// 	var DepListContent = '<table id="depTbl" class="plaintableborder" border="0" cellspacing="0" cellpadding="0" style="width:100%" styler="list" styler_tooltip="'+toolTip+'" summary="'+getSeaPhrase("TSUM_37","SEA")+'">'
   	var DepListContent = customMsg + '<table id="depTbl" class="plaintableborder" border="0" cellspacing="0" cellpadding="0" style="width:100%" styler="list" styler_tooltip="'+toolTip+'" summary="'+getSeaPhrase("TSUM_37","SEA")+'">'
   	+ '<caption class="offscreen">'+getSeaPhrase("CURRENT_DEPENDENTS","ESS")+'</caption>'
// END OF MOD
   	+ '<tr><th scope="col" class="plaintableheaderborder" style="width:58%;text-align:center">'+getSeaPhrase("NAME","ESS")+'</th>'
	+ '<th scope="col" class="plaintableheaderborder" style="width:42%;text-align:center">'+getSeaPhrase("HOME_ADDR_16","ESS")+'</th></tr>'
  	for (var i=0; i<DepInfo.length; i++)
   	{
      	thisDep = DepInfo[i];
	  	if (parseInt(thisDep.seq_nbr,10) > emdseqnbr)
	     	emdseqnbr = parseInt(thisDep.seq_nbr,10);
		if (thisDep.active_flag != "A") continue;
		rowNbr++;
		var tip = thisDep.label_name_1+' - '+getSeaPhrase("EDIT_DTL_FOR","SEA");
      	DepListContent += '<tr><td class="plaintablecellborder" style="width:58%">'
      	+ '<a href="javascript:parent.ChangeDependent('+i+','+rowNbr+');" title="'+tip+'" nowrap>'+thisDep.label_name_1+'<span class="offscreen"> - '+getSeaPhrase("EDIT_DTL_FOR","SEA")+'</span></a></td>'
		+ '<td class="plaintablecellborderright" style="width:42%" nowrap>'+((thisDep.fica_nbr)?MaskSocialNbr(thisDep.fica_nbr):'&nbsp;')+'</td></tr>'
	}
	DepListContent += '</table>'
	AddBtnContent = '<table cellspacing="0" cellpadding="0" width="100%" role="presentation">'
	+ '<tr><td class="plaintablecellright" style="padding-top:5px;padding-right:5px" nowrap="">'
	+ uiButton(getSeaPhrase("ADD","ESS"),"parent.AddDependent();return false","margin-left:5px","addbtn");
	if (fromTask && getVarFromString("from",fromTask).toLowerCase() != "main")
	{
		if (getVarFromString("from",fromTask).toLowerCase() == "benenroll")
		{
			AddBtnContent += uiButton(getSeaPhrase("CONTINUE","BEN"),"parent.CloseDependents();return false","margin-left:5px","closebtn");
			AddBtnContent += uiButton(getSeaPhrase("PREVIOUS","BEN"), "parent.parent.document.getElementById('main').src='"+parent.LastDoc[parent.currentdoc]+"';parent.parent.currentdoc--;return false", "margin-left:5px");
			AddBtnContent += uiButton(getSeaPhrase("EXIT","BEN"), "parent.parent.quitEnroll(self.location.href);return false", "margin-left:5px");
		}
		else
			AddBtnContent += uiButton(getSeaPhrase("CLOSE","ESS"),"parent.CloseDependents();return false","margin-left:5px","closebtn");
	}
	AddBtnContent += '</td></tr></table>'
	DepListContent += AddBtnContent;
	self.left.document.getElementById("paneHeader").innerHTML = getSeaPhrase("CURRENT_DEPENDENTS","ESS");
	if (DepInfo.length == 0)
	{  
//		self.left.document.getElementById("paneBody").innerHTML = '<div id="instructionsDiv" class="fieldlabelboldleft" style="padding-left:5px;padding-top:5px">'
//		+ getSeaPhrase("DEP_LIST_ADD_INSTRUCTIONS","ESS")+'</div><div style="overflow:hidden">'+AddBtnContent+'</div>'

		self.left.document.getElementById("paneBody").innerHTML = '<div id="instructionsDiv" class="fieldlabelboldleft" style="padding-left:5px;padding-top:5px">'
		+ getSeaPhrase("DEP_LIST_ADD_INSTRUCTIONS","ESS")
		// MOD BY CLYNCH - Add text
		+ '<p><font color="red"><u>Please be aware:</u></font> Adding or changing dependents on this screen does NOT affect your elected benefit plans.  If you would like to add/drop dependents to your plan, you must complete a <a href="../../xbnnet/plandescriptions/MidYearChangePacket.pdf" target="_new">Mid Year Change Packet</a> and deliver to Benefits Services.<p>'
		// END OF MOD
		+ '</div><div style="overflow:hidden">'+AddBtnContent+'</div>'

	}
	else
	{
		if (document.all) 
		{
//			self.left.document.getElementById("paneBody").innerHTML = '<div id="instructionsDiv" class="fieldlabelboldleft" style="padding-left:5px;padding-top:5px">'
//			+ getSeaPhrase("DEP_LIST_ADD_INSTRUCTIONS","ESS")+'<p/>'+getSeaPhrase("DEP_LIST_CHG_INSTRUCTIONS","ESS")+'</div><p/><div id="dataDiv">'+DepListContent+'</div>'
			self.left.document.getElementById("paneBody").innerHTML = '<div id="instructionsDiv" class="fieldlabelboldleft" style="padding-left:5px;padding-top:5px">'
			+ getSeaPhrase("DEP_LIST_ADD_INSTRUCTIONS","ESS")+'<p/>'+getSeaPhrase("DEP_LIST_CHG_INSTRUCTIONS","ESS")
			// MOD BY CLYNCH - Add text
			+ '<p><font color="red"><u>Please be aware:</u></font> Adding or changing dependents on this screen does NOT affect your elected benefit plans.  If you would like to add/drop dependents to your plan, you must complete a <a href="../../xbnnet/plandescriptions/MidYearChangePacket.pdf" target="_new">Mid Year Change Packet</a> and deliver to Benefits Services.<p>'
			// END OF MOD			
		    + '</div><p/><div id="dataDiv">'+DepListContent+'</div>'
		}
		else 
		{
			self.left.document.getElementById("paneBody").innerHTML = '<div id="instructionsDiv" class="fieldlabelboldleft" style="padding-left:5px;padding-top:5px;padding-bottom:20px">'
			+ getSeaPhrase("DEP_LIST_ADD_INSTRUCTIONS","ESS")+'<p/>'+getSeaPhrase("DEP_LIST_CHG_INSTRUCTIONS","ESS")	 
			// MOD BY CLYNCH - Add text
			+ '<p><font color="red"><u>Please be aware:</u></font> Adding or changing dependents on this screen does NOT affect your elected benefit plans.  If you would like to add/drop dependents to your plan, you must complete a <a href="../../xbnnet/plandescriptions/MidYearChangePacket.pdf" target="_new">Mid Year Change Packet</a> and deliver to Benefits Services.<p>'
			// END OF MOD			
			+ '</div><p/><div id="dataDiv">'+DepListContent+'</div>'
		}
	}
	self.left.stylePage();
	self.left.setLayerSizes();
	document.getElementById("left").style.visibility = "visible";
	stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[self.left.getWinTitle()]));
	fitToScreen();
}

function ReturnDate(date)
{
	try 
	{
   		depTabs.frame.document.maindepform.elements[date_fld_name].value = date;
		if (depTabs.getActiveTab() != 0)
			depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
	}
	catch(e)
	{
		try 
		{
			depTabs.frame.document.addrdepform.elements[date_fld_name].value = date;
			if (depTabs.getActiveTab() != 1)
				depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_1"));
		}
		catch(e) {}
	}
}

function toggleFrame(frmId, show)
{
	var frm = document.getElementById(frmId);
	if (frm)
	{	
		frm.style.visibility = (show) ? "visible" : "hidden";
		frm.style.display = (show) ? "" : "none";	
	}
}

function CloseDependents()
{
	if (prm == 1 || prm == 2)
	{
		switch (prm)
		{
			case 1: toggleFrame("left", true);
					self.left.location.replace("/lawson/xhrnet/adopt1.htm?date="+escape(geffectd,1));
					break;
			case 2: toggleFrame("left", true);
					self.left.location.replace("/lawson/xhrnet/birth1.htm?date="+escape(geffectd,1));
					break;
			default: break;
		}
	}
	else if (prm == 4)
	{		
		if (parent.LastDoc[parent.LastDoc.length-1] != "/lawson/xhrnet/dependents.htm?from=benenroll")
			parent.LastDoc[parent.LastDoc.length]="/lawson/xhrnet/dependents.htm?from=benenroll";
		parent.currentdoc=parent.LastDoc.length-1;
		parent.continueEnrollment("dependents");
	}
	else
	{
		// refresh the dependent array in the parent
		try { parent.DepInfo = DepInfo; } catch(e) {}
		try 
		{	
	   		parent.toggleFrame("right", false);   		
	   		parent.toggleFrame("relatedtask", false);
	   		parent.toggleFrame("fullrelatedtask", false);
	   		parent.toggleFrame("left", true);
		}
		catch(e) {}
		// display the checkmark indicating that this task has been accessed.
		try { parent.left.setImageVisibility("dependentaddress_checkmark","visible"); } catch(e) {}
	}
}

function HideListButtons()
{
	try 
	{
		self.left.document.getElementById("addbtn").style.visibility = "hidden";
		if (fromTask)
			self.left.document.getElementById("closebtn").style.visibility = "hidden";
	}
	catch(e) {}
}

function ShowListButtons()
{
	try 
	{
		self.left.document.getElementById("addbtn").style.visibility = "visible";
		if (fromTask)
			self.left.document.getElementById("closebtn").style.visibility = "visible";
	}
	catch(e) {}
}

function ChangeDependent(i,rowNbr)
{
	var nextFunc = function()
	{
		activateTableRow("depTbl",rowNbr,self.left);
		userAction = "Change";
		currentDepIndex = i;
		HideListButtons();
		var getPcodes = !emssObjInstance.emssObj.filterSelect && !CalledPcodesInfo;
		var getRelcodes = !CalledHrCtryCodeInfo;	
		if (getPcodes || getRelcodes)
		{
			var keyStr = "DP";
			if (getPcodes)
				keyStr += ";PC";		
			GetPcodesSelect(authUser.prodline,keyStr,"SortPcodes()","Active");
		}
		else
		{
			CurrentDep = DepInfo[i];
			document.getElementById("right").style.visibility = "hidden";
			DrawDependentTabs("Change",i,"self.right");
		}
	};
	startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), nextFunc);
}

function AddDependent()
{
	var nextFunc = function()
	{
		userAction = "Add";
		currentDepIndex = -1;
		HideListButtons();	
		var getPcodes = !emssObjInstance.emssObj.filterSelect && !CalledPcodesInfo;
		var getRelcodes = !CalledHrCtryCodeInfo;
		if (getPcodes || getRelcodes)
		{
			var keyStr = "DP";
			if (getPcodes)
				keyStr += ";PC";		
			GetPcodesSelect(authUser.prodline,keyStr,"SortPcodes()","Active");
		}
		else
		{
	   		CurrentDep = new Object();
	   		if (onLoad && (prm == 1 || prm == 2))
	   			DrawDependentTabs("Add",-1,"self.leftform");
	   		else
	   			DrawDependentTabs("Add",-1,"self.right");
		}
	};
	startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), nextFunc);
}

function SortPcodes()
{
	var relTypeExists = (appObj && appObj.getLongAppVersion() != null && appObj.getLongAppVersion().toString() >= "10.00.00.03") ? true : false;
	for (var i=0; i<PcodesInfo.length; i++)
	{
		if (PcodesInfo[i].type == "DP")
		{	
			if (relTypeExists)
			{
				if (Number(PcodesInfo[i].dp_rel_type) != 2)
					relationData[relationData.length] = PcodesInfo[i];
			}	
			else	
				relationData[relationData.length] = PcodesInfo[i];
		}	
		else if (PcodesInfo[i].type == "PC")
			physicianData[physicianData.length] = PcodesInfo[i];
	}
	GetNameSuffixInfo();
}

function GetNameSuffixInfo()
{
	if (userAction == "Change")
		GetHrCtryCodeSelect(authUser.prodline,"SU","ChangeDependent("+currentDepIndex+")");
	else
		GetHrCtryCodeSelect(authUser.prodline,"SU","AddDependent()");
}

function DrawDependentTabs(action, depIndex, frameStr)
{
// MOD BY BILAL - Hiding Address Tab
	if (typeof(depTabs) == "undefined")
		depTabs = new uiTabSet("depTabs",new Array(getSeaPhrase("MAIN","ESS")));
//		depTabs = new uiTabSet("depTabs",new Array(getSeaPhrase("MAIN","ESS"),getSeaPhrase("HOME_ADDR_2","ESS")));

//END OF MOD
	var toolTip;
	var classStr = (onLoad && (prm == 1 || prm == 2))?"fieldlabelbold":"fieldlabelboldlite";
	var tab0Html = "";
	var tab1Html = "";
	// Main tab form
	var tab0Html = '<form name="maindepform">'
	if (action == "Add")
		tab0Html += '<input class="inputbox" type="hidden" name="seqnbr" value="'+(parseInt(emdseqnbr,10)+1)+'">'
	else
		tab0Html += '<input class="inputbox" type="hidden" name="seqnbr" value="'+DepInfo[depIndex].seq_nbr+'">'
	tab0Html += '<table border="0" cellspacing="0" cellpadding="0" width="100%" role="presentation">'
	+ '<tr style="padding-top:5px"><td class="'+classStr+'" style="width:35%">'+uiRequiredFooter()+'</td><td>&nbsp;</td></tr>'
	+ '<tr style="padding-top:5px"><td class="'+classStr+'" style="width:35%"><label for="firstname">'+getSeaPhrase("DEP_34","ESS")+'</label></td>'
// MOD BY BILAL - Changing to UPPER CASE
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="firstname" name="firstname" size="15" maxlength="15" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"'		// MOD BY BILAL - Changing to UPPER CASE
// END OF MOD
	if (action == "Change")
		tab0Html += ' value="'+DepInfo[depIndex].first_name+'"'
	tab0Html += '>'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="middleinit">'+getSeaPhrase("DEP_35","ESS")+'</label></td>'
// MOD BY BILAL - Changing to UPPER CASE 
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="middleinit" name="middleinit" size="1" maxlength="1" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"'
// END OF MOD
	if (action == "Change")
		tab0Html += ' value="'+DepInfo[depIndex].middle_init+'"'
	tab0Html += '></td></tr>'
	if (EmpInfo.employee_work_country == "DE" || EmpInfo.employee_work_country == "NL")
	{
// MOD BY BILAL - Chaging to UPPER CASE
		tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label for="lastnameprefix">'+getSeaPhrase("DEP_37","ESS")+'</label></td>'
		+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="lastnameprefix" name="lastnameprefix" size="30" maxlength="30" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"'
// END OF MOD
		if (action == "Change")
			tab0Html += ' value="'+DepInfo[depIndex].last_name_pre+'"'
		tab0Html += '></td></tr>'
	}
//MOD BY BILAL - Changing to UPPERCASE
	tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label for="lastname">'+getSeaPhrase("DEP_38","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="lastname" name="lastname" size="30" maxlength="30" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"'
// END OF MOD
	if (action == "Change")
		tab0Html += ' value="'+DepInfo[depIndex].last_name+'"'
	tab0Html += '>'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="namesuffix">'+getSeaPhrase("DEP_39","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><select class="inputbox" id="namesuffix" name="namesuffix">'
	if (action == "Change")
		tab0Html += DrawHrCtryCodeSelect("SU",DepInfo[depIndex].name_suffix)
	else
		tab0Html += DrawHrCtryCodeSelect("SU","")
	tab0Html += '</select></td></tr>'
	toolTip = uiDateToolTip(getSeaPhrase("DEP_40","ESS"));
	tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label id="birthdateLbl" for="birthdate">'+getSeaPhrase("DEP_40","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="birthdate" name="birthdate" size="10" maxlength="10" onfocus="this.select()" onchange="parent.ValidateDate(this);"'
	if (action == "Change")
		tab0Html += ' value="'+DepInfo[depIndex].birthdate+'"'
	tab0Html += ' aria-labelledby="birthdateLbl birthdateFmt"><a href="javascript:parent.DateSelect(\'birthdate\');"'
	+ ' title="'+toolTip+'" aria-label="'+toolTip+'">'+uiCalendarIcon()+'</a>'+uiDateFormatSpan("birthdateFmt")+uiRequiredIcon()+'</td></tr>'
	toolTip = uiDateToolTip(getSeaPhrase("DEP_41","ESS"));
	tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label id="adoptdateLbl" for="adoptdate">'+getSeaPhrase("DEP_41","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="adoptdate" name="adoptdate" size="10" maxlength="10" onfocus="this.select()" onchange="parent.ValidateDate(this);"'
	if (action == "Change")
		tab0Html += ' value="'+DepInfo[depIndex].adoption_date+'"'
	var htmlCode = (prm == 1) ? uiRequiredIcon() : ''
	tab0Html += ' aria-labelledby="adoptdateLbl adoptdateFmt"><a href="javascript:parent.DateSelect(\'adoptdate\');"'
	+ ' title="'+toolTip+'" aria-label="'+toolTip+'">'+uiCalendarIcon()+'</a>'+uiDateFormatSpan("adoptdateFmt")+'</td></tr>'
	toolTip = uiDateToolTip(getSeaPhrase("DEP_22","ESS"));
	tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label id="placedateLbl" for="placedate">'+getSeaPhrase("DEP_22","ESS")+'</label></td>'
    + '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="placedate" name="placedate" size="10" maxlength="10" onfocus="this.select()" onchange="parent.ValidateDate(this);"'
	if (action == "Change")
		tab0Html += ' value="'+DepInfo[depIndex].placement_date+'"'
	tab0Html += ' aria-labelledby="placedateLbl placedateFmt"><a href="javascript:parent.DateSelect(\'placedate\');"'
	+ ' title="'+toolTip+'" aria-label="'+toolTip+'">'+uiCalendarIcon()+'</a>'+uiDateFormatSpan("placedateFmt")+htmlCode+'</td></tr>'
   	+ '<tr><td class="'+classStr+'" style="width:35%"><label id="ficanbrLbl" for="ficanbr">'+getSeaPhrase("HOME_ADDR_16","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><span id="ficaspan"><input class="inputbox" type="text" id="ficanbr" name="ficanbr" size="11" maxlength="11" onfocus="this.select()"'
	if (action == "Change")
		tab0Html += ' value="'+DepInfo[depIndex].fica_nbr+'"'
	tab0Html += '></span>'
	if (parent.emssObjInstance.emssObj.requireDepSSN)
	{
		tab0Html += uiRequiredIcon("","ficarequiredicon")+'&nbsp;&nbsp;&nbsp;'
		if (prm == 1 || prm == 2)
		{	
			tab0Html += '<span style="position:relative;top:2px"><input class="inputbox" type="checkbox" id="ficaissued" name="ficaissued" onclick="parent.RefreshSSN(this)">'
			tab0Html += '<label class="fieldlabelbold" for="ficaissued"><span class="offscreen">'+getSeaPhrase("HOME_ADDR_16","ESS")+'&nbsp;</span>'+getSeaPhrase("NOT_ISSUED","ESS")+'</label></span>'
		}	
	}
	tab0Html += '</td></tr>'
	tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label for="deptype">'+getSeaPhrase("TYPE","ESS")+'</label></td>'
    + '<td class="plaintablecell" nowrap><select class="inputbox" id="deptype" name="deptype">'
    + '<option value="">'
	if (action == "Change") 
	{
 		tab0Html += '<option value="S"'
 		if (DepInfo[depIndex].dep_type == "S")
 			tab0Html += ' selected'
 		tab0Html += '>'+getSeaPhrase("DEP_43","ESS")
 		+ '<option value="D"'
 		if (DepInfo[depIndex].dep_type == "D")
 			tab0Html += ' selected'
 		tab0Html += '>'+getSeaPhrase("DEP_33","ESS")
 		if (appObj && appObj.getLongAppVersion() != null && appObj.getLongAppVersion().toString() >= "10.00.00.01")
 		{	
 			tab0Html += '<option value="P"'
	 		if (DepInfo[depIndex].dep_type == "P")
	 			tab0Html += ' selected'
	 		tab0Html += '>'+getSeaPhrase("DOM_PARTNER","ESS")
 		}
	}
  	else 
  	{
 		tab0Html += '<option value="S">'+getSeaPhrase("DEP_43","ESS")
 		+ '<option value="D">'+getSeaPhrase("DEP_33","ESS")
  		if (appObj && appObj.getLongAppVersion() != null && appObj.getLongAppVersion().toString() >= "10.00.00.01")		
  			tab0Html += '<option value="P">'+getSeaPhrase("DOM_PARTNER","ESS")
	}
	tab0Html += '</select>'+uiRequiredIcon()+'</td></tr>'
	if (action == "Change")
	{
// MOD BY BILAL  - hiding the field  "display:none"
//		tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label for="status">'+getSeaPhrase("STATUS","ESS")+'</label></td>'
		tab0Html += '<tr style="display:none"><td class="'+classStr+'" style="width:35%"><label for="status">'+getSeaPhrase("STATUS","ESS")+'</label></td>'
// END OF MOD
	    + '<td class="plaintablecell" nowrap><select class="inputbox" id="status" name="status">'
 		+ '<option value="A"'
 		if (DepInfo[depIndex].active_flag == "A")
 			tab0Html += ' selected'
 		tab0Html += '>'+getSeaPhrase("ACTIVE","ESS")
 		+ '<option value="I"'
 		if (DepInfo[depIndex].active_flag == "I")
 			tab0Html += ' selected'
 		tab0Html += '>'+getSeaPhrase("INACTIVE","ESS")
		tab0Html += '</select></td></tr>'
	}
	tab0Html += '<tr><td class="'+classStr+'" style="width:35%"><label for="relcode">'+getSeaPhrase("DEP_23","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><select class="inputbox" id="relcode" name="relcode">'
	if (action == "Change")
		tab0Html += DrawPcodesSelect("DP",DepInfo[depIndex].rel_code,relationData)
	else
		tab0Html += DrawPcodesSelect("DP","",relationData)
	tab0Html += '</select>'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="empaddress">'+getSeaPhrase("HOME_ADDR_2","ESS")+'</label></td>'
    + '<td class="plaintablecell" nowrap><select class="inputbox" id="empaddress" name="empaddress">'
// MOD BY BILAL - Removing the Blank option
//    + '<option value="">'
// END OF MOD
    if (action == "Change") 
    {
 		tab0Html += '<option value="H"'
 		if (DepInfo[depIndex].emp_address == "H")
 			tab0Html += ' selected'
 		tab0Html += '>'+getSeaPhrase("HOME","ESS")	  
// MOD BY BILAL - Removing option
//		+ '<option value="N"'
//		if (DepInfo[depIndex].emp_address == "N")
//			tab0Html += ' selected'
//		tab0Html += '>'+getSeaPhrase("DEP_30","ESS")   
// END OF MOD
    }
    else
// MOD BY BILAL  -  Forcing the HOME to be the only selected option
		tab0Html += '<option value="H" selected>'+getSeaPhrase("HOME","ESS")
//		tab0Html += '<option value="H">'+getSeaPhrase("HOME","ESS")+'<option value="N">'+getSeaPhrase("DEP_30","ESS")

	tab0Html += '</select>'+uiRequiredIcon()+'</td></tr>'
//	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="pcpcode">'+getSeaPhrase("PRIMARY_CARE_PHYSICIAN","ESS")+'</label></td>'
//	+ '<td class="plaintablecell" nowrap>' 
// MOD BY BILAL - No need for this field
/*	if (emssObjInstance.emssObj.filterSelect)
	{
		toolTip = dmeFieldToolTip("pcpcode");
		tab0Html += '<input type="text" id="pcpcode" name="pcpcode" fieldnm="pcpcode" class="inputbox" size="10" maxlength="10" value="'
		if (action == "Change")
			tab0Html += DepInfo[depIndex].primary_care		
		tab0Html += '" onkeyup="parent.dmeFieldOnKeyUpHandler(event,\'pcpcode\');"/>'
		+ '<a href="javascript:;" onclick="parent.openDmeFieldFilter(\'pcpcode\');return false" title="'+toolTip+'" aria-label="'+toolTip+'">'
		+ '<img src="/lawson/xhrnet/ui/images/ico_form_dropmenu.gif" border="0" style="margin-bottom:-3px" alt="'+toolTip+'" title="'+toolTip+'">'
		+ '</a><span class="plaintablecelldisplay" style="width:200px" id="xlt_pcpcode">'
		if (action == "Change")
			tab0Html += DepInfo[depIndex].primary_care_description
		tab0Html += '</span>'
	}
	else
	{
		tab0Html += '<select class="inputbox" id="pcpcode" name="pcpcode">'
		if (action == "Change")
			tab0Html += DrawPcodesSelect("PC",DepInfo[depIndex].primary_care,physicianData)
		else
			tab0Html += DrawPcodesSelect("PC","",physicianData)		
		tab0Html += '</select>';
	}  */
// END OF MOD
	tab0Html += '</td></tr>'
    + '<tr><td class="'+classStr+'" style="width:35%"><label for="gender">'+getSeaPhrase("DEP_27","ESS")+'</label></td>'
    + '<td class="plaintablecell" nowrap><select class="inputbox" id="gender" name="gender">'
	+ '<option value="">'
	if (action == "Change") 
	{
    	tab0Html += '<option value="M"'
    	if (DepInfo[depIndex].sex == "M")
    		tab0Html += ' selected'
    	tab0Html += '>'+getSeaPhrase("DEP_25","ESS")
    	+ '<option value="F"'
    	if (DepInfo[depIndex].sex == "F")
    		tab0Html += 'selected'
    	tab0Html += '>'+getSeaPhrase("DEP_26","ESS")
	}
	else
    	tab0Html += '<option value="M">'+getSeaPhrase("DEP_25","ESS")+'<option value="F">'+getSeaPhrase("DEP_26","ESS")
    tab0Html += '</select>'+uiRequiredIcon()+'</td></tr>'
	//GDD  09/26/14  remove student
	//tab0Html += '<tr><td class="'+classStr+'" style="width:35%">'
	// PT 139145. Add tool tip text for student status dropdown if HRDEPBEN benefit exists
	//if (action == "Change" && DepInfo[depIndex].benefits_plan_type != "")
	//	tab0Html += '<label id="studentstatus" for="student" title="'+getSeaPhrase("STUDENT_STATUS_HELP_TEXT","ESS")+'">'+getSeaPhrase("DEP_24","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("STUDENT_STATUS_HELP_TEXT","ESS")+'</span></label>'
	//else
	//	tab0Html += '<label for="student">'+getSeaPhrase("DEP_24","ESS")+'</label>'
	//tab0Html += '</td><td class="plaintablecell" nowrap><select class="inputbox" id="student" name="student"'
	//isStudent = false;
	//if (action == "Change") 
	//{
		// PT 139145. Disable student status dropdown if HRDEPBEN benefit exists
	//	if (DepInfo[depIndex].benefits_plan_type != "")
	//		tab0Html += ' disabled="true"'
	//	tab0Html += '><option value="N"'
	//	if (DepInfo[depIndex].student == "N")
	//		tab0Html += ' selected'
	//	tab0Html += '>'+getSeaPhrase("NO","ESS")
	//	+ '<option value="Y"'
	//	if (DepInfo[depIndex].student == "Y" || DepInfo[depIndex].student == "F" || DepInfo[depIndex].student == "P") 
	//	{
	//		tab0Html += ' selected'
	//		isStudent = true;
	//	}
	//	tab0Html += '>'+getSeaPhrase("YES","ESS")
	//}
	//else
	//	tab0Html += '><option value="N" selected>'+getSeaPhrase("NO","ESS")+'<option value="Y">'+getSeaPhrase("YES","ESS")
	//tab0Html += '</select></td></tr>'
	//GDD end of change
        //GDD  09/16/14  Remove disabled
	/* + '<tr><td class="'+classStr+'" style="width:35%"><label for="disabled">'+getSeaPhrase("DEP_28","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><select class="inputbox" id="disabled" name="disabled">'
	if (action == "Change") 
	{
		tab0Html += '<option value="N"'
		if (DepInfo[depIndex].disabled == "N")
			tab0Html += ' selected'
		tab0Html += '>'+getSeaPhrase("NO","ESS")
		+ '<option value="Y"'
		if (DepInfo[depIndex].disabled == "Y")
			tab0Html += ' selected'
		tab0Html += '>'+getSeaPhrase("YES","ESS")
	}
	else 
	{
		tab0Html += '<option value="N" selected>'+getSeaPhrase("NO","ESS")
		+ '<option value="Y">'+getSeaPhrase("YES","ESS")
	}
	tab0Html += '</select></td></tr>' */
	//GDD end of change 
// MOD BY BILAL 	- Removing the Field from screen
/*	+ '<tr><td class="'+classStr;
	if (classStr == "fieldlabelboldlite")
		tab0Html += 'underline';
	tab0Html += '" style="width:35%"><label for="smoker">'+getSeaPhrase("SMOKER","ESS")+'</label></td>'
	tab0Html += '<td class="plaintablecell" nowrap><select class="inputbox" id="smoker" name="smoker">'
	if (action == "Change") 
	{
		tab0Html += '<option value="N"'
		if (DepInfo[depIndex].smoker == "N")
			tab0Html += ' selected'
		tab0Html += '>'+getSeaPhrase("NO","ESS")
		+ '<option value="Y"'
		if (DepInfo[depIndex].smoker == "Y")
			tab0Html += ' selected'
		tab0Html += '>'+getSeaPhrase("YES","ESS")
	}
	else
		tab0Html += '<option value="N" selected>'+getSeaPhrase("NO","ESS")+'<option value="Y">'+getSeaPhrase("YES","ESS")
	tab0Html += '</select></td></tr>'  */
// END OF MOD 
	+ '<tr><td class="plaintablecell" style="width:35%">&nbsp;</td><td nowrap="">'
	+ uiButton(getSeaPhrase("UPDATE","ESS"),"parent.UpdateDependent('"+action+"');return false","margin-left:5px;margin-top:10px")
	if (!onLoad || (prm != 1 && prm != 2))
		tab0Html += uiButton(getSeaPhrase("CANCEL","ESS"),"parent.CancelDependentAction()","margin-left:5px;margin-top:10px")
	tab0Html += '</td></tr></table></form>'

	// Other Address form
	tab1Html = '<form name="addrdepform">'
	+ '<table border="0" cellspacing="0" cellpadding="0" width="100%" role="presentation">'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="addr1">'+getSeaPhrase("ADDR_1","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr1" name="addr1" size="30" maxlength="30" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].addr1+'"'
	tab1Html += '></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="addr2">'+getSeaPhrase("ADDR_2","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr2" name="addr2" size="30" maxlength="30" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].addr2+'"'
	tab1Html += '></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="addr3">'+getSeaPhrase("ADDR_3","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr3" name="addr3" size="30" maxlength="30" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].addr3+'"'
	tab1Html += '></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="addr4">'+getSeaPhrase("ADDR_4","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr4" name="addr4" size="30" maxlength="30" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].addr4+'"'
	tab1Html += '></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="city">'+getSeaPhrase("CITY_OR_ADDR_5","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="city" name="city" size="18" maxlength="18" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].city+'"'
	tab1Html += '></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="state">'+getSeaPhrase("HOME_ADDR_6","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><select class="inputbox" id="state" name="state">'
	if (action == "Change")
		tab1Html += BuildStateSelect(DepInfo[depIndex].state)
	else
		tab1Html += BuildStateSelect("")
	tab1Html += '</select></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="zip">'+getSeaPhrase("HOME_ADDR_7","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="zip" name="zip" size="10" maxlength="10" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].zip+'"'
	tab1Html += '><tr><td class="'+classStr+'" style="width:35%"><label for="country">'+getSeaPhrase("COUNTRY_ONLY","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><select class="inputbox" id="country" name="country">'
	if (action == "Change")
		tab1Html += DrawInstCtryCdSelect(DepInfo[depIndex].country_code)
	else
		tab1Html += DrawInstCtryCdSelect("")
	tab1Html += '</select></td></tr>'
	+ '<tr style="height:30px"><td class="'+classStr+'" style="width:35%">&nbsp;</td><td>&nbsp;</td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="hmphonenbr">'+getSeaPhrase("JOB_PROFILE_13","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="hmphonenbr" name="hmphonenbr" size="15" maxlength="15" onfocus="this.select()"'
	if (action == "Change") 
	{
		if (DepInfo[depIndex].emp_address == "H" && DepInfo[depIndex].hm_phone_nbr == "")
			tab1Html += ' value="'+DepInfo[depIndex].pa_employee_hm_phone_nbr+'"';
		else
			tab1Html += ' value="'+DepInfo[depIndex].hm_phone_nbr+'"'
	}
	tab1Html += '></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%">'
	+ '<label id="hmctrycd" for="hmphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("HOME_PHONE_CNTRY_CODE_ONLY","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'</span></label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="hmphonecntry" name="hmphonecntry" size="3" maxlength="3" onfocus="this.select()"'
	if (action == "Change") 
	{
		if (DepInfo[depIndex].emp_address == "H" && DepInfo[depIndex].hm_phone_nbr == "")
			tab1Html += ' value="'+DepInfo[depIndex].pa_employee_hm_phone_cntry+'"'
		else
			tab1Html += ' value="'+DepInfo[depIndex].hm_phone_cntry+'"'
	}
	tab1Html += '></td></tr>'
	+ '<tr style="height:30px"><td class="'+classStr+'" style="width:35%">&nbsp;</td><td>&nbsp;</td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="wkphonenbr">'+getSeaPhrase("JOB_PROFILE_11","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphonenbr" name="wkphonenbr" size="15" maxlength="15" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].wk_phone_nbr+'"'
	tab1Html += '></td></tr>'
	+ '<tr><td class="'+classStr+'" style="width:35%"><label for="wkphoneext">'+getSeaPhrase("JOB_OPENINGS_14","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphoneext" name="wkphoneext" size="5" maxlength="5" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].wk_phone_ext+'"'
	tab1Html += '></td></tr>'
	var thisClassStr = (classStr == "fieldlabelboldlite") ? classStr + "underline" : classStr;
	tab1Html += '<tr><td class="'+thisClassStr+'" style="width:35%">'	
	+ '<label id="wkctrycd" for="wkphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("WORK_PHONE_CNTRY_CODE_ONLY","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'</span></label></td>'
	tab1Html += '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphonecntry" name="wkphonecntry" size="3" maxlength="3" onfocus="this.select()"'
	if (action == "Change")
		tab1Html += ' value="'+DepInfo[depIndex].wk_phone_cntry+'"'
	tab1Html += '></td></tr>'
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "10.00.00")
	{
		tab1Html += '<tr><td class="'+classStr+'" style="width:35%"><label for="personalemail">'+getSeaPhrase("PERSONAL_EMAIL","SEA")+'</label></td>'
		+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="personalemail" name="personalemail" size="30" maxlength="60" onfocus="this.select()"'
		if (action == "Change")
			tab1Html += ' value="'+DepInfo[depIndex].email_personal+'"'
		tab1Html += '></td></tr>'
	}
	tab1Html += '<tr><td class="plaintablecell" style="width:35%">&nbsp;</td><td nowrap="">'
	+ uiButton(getSeaPhrase("UPDATE","ESS"),"parent.UpdateDependent('"+action+"');return false","margin-left:5px;margin-top:10px")
	if (!onLoad || (prm != 1 && prm != 2))
		tab1Html += uiButton(getSeaPhrase("CANCEL","ESS"),"parent.CancelDependentAction()","margin-left:5px;margin-top:10px")
	tab1Html += '</td></tr></table></form>'
	depTabs.draw = true;
	depTabs.frame = eval(frameStr);
	var tmpObj = String(frameStr).split(".");
	var tmpId = tmpObj[tmpObj.length-1];
	if (onLoad && (prm == 1 || prm == 2))
   		depTabs.frame.document.getElementById("paneHeader").innerHTML = getSeaPhrase("DEP_33","ESS");
	else
   		depTabs.frame.document.getElementById("paneHeader").innerHTML = getSeaPhrase("DETAIL","ESS");	
	depTabs.tabHtml = new Array();
	depTabs.tabHtml[0] = tab0Html;
// MOD BY BILAL 	-	Removing Address Tab
//	depTabs.tabHtml[1] = tab1Html;
// END OF MOD
	if (onLoad && (prm == 1 || prm == 2))
		depTabs.isDetail = false;
	else
		depTabs.isDetail = true;
	depTabs.create();
	document.getElementById(tmpId).style.visibility = "visible";
	onLoad = false;
	stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[depTabs.frame.getWinTitle()]));
	fitToScreen();
}

function RefreshSSN(cBox)
{
	var ssnElm = depTabs.frame.document.maindepform.ficanbr;
	if (cBox.checked)
	{
		clearRequiredField(ssnElm);
		ssnElm.value = "";
		depTabs.frame.document.getElementById("ficaspan").style.display = "none";
		depTabs.frame.document.getElementById("ficarequiredicon").style.display = "none";
	}	
	else
	{
		depTabs.frame.document.getElementById("ficaspan").style.display = "";
		depTabs.frame.document.getElementById("ficarequiredicon").style.display = "";	
	}	
}

var eventDate = "";

function UpdateDependent(action)
{
	var mainform = depTabs.frame.document.maindepform;
// MOD BY BILAL 	- Address Tab is deleted
//	var addrform = depTabs.frame.document.addrdepform;
// END OF MOD
	clearRequiredField(mainform.firstname);
	clearRequiredField(mainform.lastname);
	clearRequiredField(mainform.birthdate);
	clearRequiredField(mainform.adoptdate);
	clearRequiredField(mainform.placedate);
	clearRequiredField(mainform.ficanbr);
	clearRequiredField(depTabs.frame.document.getElementById("deptype"));
	clearRequiredField(depTabs.frame.document.getElementById("relcode"));
	clearRequiredField(depTabs.frame.document.getElementById("empaddress"));
	clearRequiredField(depTabs.frame.document.getElementById("gender"));
//	clearRequiredField(addrform.addr1);
//	clearRequiredField(addrform.hmphonenbr);
//	clearRequiredField(addrform.hmphonecntry);
//	clearRequiredField(addrform.wkphonenbr);
//	clearRequiredField(addrform.wkphonecntry);
//	if ((action == "Add" || DepInfo[currentDepIndex].emp_address =="H" ) && mainform.empaddress.selectedIndex == 1 && (NonSpace(addrform.addr1.value) != 0 || NonSpace(addrform.addr2.value) != 0 || NonSpace(addrform.addr3.value) != 0 || NonSpace(addrform.addr4.value) != 0 || NonSpace(addrform.city.value) != 0 || addrform.state.selectedIndex != 0 || NonSpace(addrform.zip.value) != 0 || addrform.country.selectedIndex != 0 ))
//	{
//		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
//		setRequiredField(depTabs.frame.document.getElementById("empaddress"), getSeaPhrase("WRONG_ADDRESS_FIELD","ESS"), mainform.empaddress);
//		return;
//	}
	if (NonSpace(mainform.firstname.value) == 0)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		setRequiredField(mainform.firstname, getSeaPhrase("FIRST_NAME","ESS"));
	   	return;
	}
	if (NonSpace(mainform.lastname.value) == 0)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		setRequiredField(mainform.lastname, getSeaPhrase("LAST_NAME","ESS"));
	   	return;
	}
	if (NonSpace(mainform.birthdate.value) == 0)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		setRequiredField(mainform.birthdate, getSeaPhrase("BIRTHDATE","ESS"));
	   	return;
	}
 	if (ValidDate(mainform.birthdate) == false)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
	   	return;
	}
	if (NonSpace(mainform.adoptdate.value) && ValidDate(mainform.adoptdate) == false)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		return;
	}
	if (prm == 1 && action == "Add") // adoption life event
	{
		if (NonSpace(mainform.placedate.value) == 0)
	   	{
	   		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
	   		setRequiredField(mainform.placedate, getSeaPhrase("PLACEMENT_DATE","ESS"));
	      	return;
	   	}
		if (ValidDate(mainform.placedate) == false)
	   	{
	   		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
	      	return;
	   	}
	}
	else if (NonSpace(mainform.placedate.value) && ValidDate(mainform.placedate) == false)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		return;
	}
	if (parent.emssObjInstance.emssObj.requireDepSSN)
	{
		var ssnNotIssued = ((prm == 1 || prm == 2) && mainform.ficaissued && mainform.ficaissued.checked);
		if (!ssnNotIssued && NonSpace(mainform.ficanbr.value) == 0)
		{
			depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
			setRequiredField(mainform.ficanbr, getSeaPhrase("SSN_REQUIRED","ESS"));
			return;	
		}
	}
	if (parent.emssObjInstance.emssObj.validateSSNFormat && NonSpace(mainform.ficanbr.value) > 0 && ValidSSN(mainform.ficanbr, EmpInfo.employee_work_country) == false)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		setRequiredField(mainform.ficanbr, getSeaPhrase("INVALID_SSN","SEA"));
		return;			
	}
	if (mainform.deptype.selectedIndex == 0)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		setRequiredField(depTabs.frame.document.getElementById("deptype"), getSeaPhrase("DEP_45","ESS"), mainform.deptype);
	   	return;
   	}
    if (mainform.relcode.selectedIndex == 0)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		setRequiredField(depTabs.frame.document.getElementById("relcode"), getSeaPhrase("RELATIONSHIP","ESS"), mainform.relcode);
	   	return;
	}
// MOD BY BILAL	-Commenting out the logic
//    if (mainform.empaddress.selectedIndex == 0)
//	{
//		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
//		setRequiredField(depTabs.frame.document.getElementById("empaddress"), getSeaPhrase("HOME_OR_DIFFERENT_ADDRESS","ESS"), mainform.empaddress);
//	   	return;
//	}
// END OF MOD
	if (mainform.gender.selectedIndex == 0)
	{
		depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_0"));
		setRequiredField(depTabs.frame.document.getElementById("gender"), getSeaPhrase("DEP_46","ESS"), mainform.gender);
	   	return;
	}
	// set focus on address tab if address field is set to "other"	
// MOD BY BILAL	-Commenting out the logic
/*	if (mainform.empaddress.selectedIndex == 2)
	{
		if (NonSpace(addrform.addr1.value) == 0)
		{
			depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_1"));
			setRequiredField(addrform.addr1, getSeaPhrase("HOME_ADDR_10","ESS"));
			return;
		}
		if (NonSpace(addrform.hmphonenbr.value) > 0 && !ValidPhoneEntry(addrform.hmphonenbr))
		{
			depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_1"));
			setRequiredField(addrform.hmphonenbr, getSeaPhrase("PHONE_NBR_ERROR","ESS"));
			return;
		}
		if (NonSpace(addrform.hmphonecntry.value) > 0 && !ValidPhoneEntry(addrform.hmphonecntry))
		{
			depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_1"));
			setRequiredField(addrform.hmphonecntry, getSeaPhrase("PHONE_COUNTRY_CODE_ERROR","ESS"));
			return;
		}
		if (NonSpace(addrform.wkphonenbr.value) > 0 && !ValidPhoneEntry(addrform.wkphonenbr))
		{
			depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_1"));
			setRequiredField(addrform.wkphonenbr, getSeaPhrase("PHONE_NBR_ERROR","ESS"));
			return;
		}
		if (NonSpace(addrform.wkphonecntry.value) > 0 && !ValidPhoneEntry(addrform.wkphonecntry))
		{
			depTabs.frame.tabOnClick(depTabs.frame.document.getElementById("depTabs_TabBody_1"));
			setRequiredField(addrform.wkphonecntry, getSeaPhrase("PHONE_COUNTRY_CODE_ERROR","ESS"));
			return;
		}	   
	}	*/
// END OF MOD
	if (prm == 1)
	 	geffectd = formjsDate(formatDME(mainform.placedate.value));
	if (prm == 2)
	   geffectd = formjsDate(formatDME(mainform.birthdate.value));
	eventDate = formjsDate(formatDME(mainform.birthdate.value));
// MOD BY BILAL 	- Address Form removed by Bilal
	// Make sure we pass a space for any blank address fields, or they won't be cleared on the HR13 form.
//	if (addrform.addr1.value == "") addrform.addr1.value = " ";
//	if (addrform.addr2.value == "") addrform.addr2.value = " ";
//	if (addrform.addr3.value == "") addrform.addr3.value = " ";
//	if (addrform.addr4.value == "") addrform.addr4.value = " ";
//	if (addrform.city.value == "") addrform.city.value = " ";
//	if (addrform.state.options[addrform.state.selectedIndex].value == "")
//		addrform.state.options[addrform.state.selectedIndex].value = " ";
//	if (addrform.zip.value == "") addrform.zip.value = " ";
//	if (addrform.country.options[addrform.country.selectedIndex].value == "")
//		addrform.country.options[addrform.country.selectedIndex].value = " ";
//	if (addrform.hmphonenbr.value == "") addrform.hmphonenbr.value = " ";
//	if (addrform.hmphonecntry.value == "") addrform.hmphonecntry.value = " ";
//	if (addrform.wkphonenbr.value == "") addrform.wkphonenbr.value = " ";
//	if (addrform.wkphoneext.value == "") addrform.wkphoneext.value = " ";
//	if (addrform.wkphonecntry.value == "") addrform.wkphonecntry.value = " ";
// END OF MOD
   	if (prm > 0 && action == "Add" && geffectd)
   	{
   		var nextFunc = function()
   		{
	   		var object = new DMEObject(authUser.prodline, "FAMSTSHIST");
	      	object.out = "JAVASCRIPT";
		   	object.index = "FSHSET1";
		   	object.field = "dep-1;dep-2;dep-3;dep-4;dep-5;dep-6;dep-7;dep-8;dep-9"
		   	object.key = parseInt(authUser.company,10)+"="+parseInt(authUser.employee,10)+"="+escape(taskNm,1) + "=" + escape(geffectd,1)
		   	object.func = "CheckFamstshist('"+action+"')";
	   		DME(object, "jsreturn");
   		};
		startProcessing(getSeaPhrase("HOME_ADDR_42","ESS"), nextFunc); 		
  	}
   	else
   	{

// MOD BY BILAL	- Removing Status related Condidtion
//		if (action == "Change" && mainform.status.value == "I")
//		{
			_action = action;
//			if (!parent.seaConfirm(getSeaPhrase("UPDATE_WARNING_1","ESS")+" "+getSeaPhrase("INACTIVATE_DEP_WARNING","ESS"), "", confirmInactivate))
//		   		return;
//		}   	
// END OF MOD

		ProcessHR13(action);
	}
}

// Firefox will call this function
function confirmInactivate(confirmWin)
{
    if (confirmWin.returnValue == "ok" || confirmWin.returnValue == "continue")
    	ProcessHR13(action);
}

function CheckFamstshist(action)
{
	// We found a family status history record for this life event.
	if (self.jsreturn.NbrRecs != 0)
   	{
     	familyStatusExists = true;
	  	var deps = new Array();
	   	deps[1] = self.jsreturn.record[0].dep_1;
	   	deps[2] = self.jsreturn.record[0].dep_2;
	  	deps[3] = self.jsreturn.record[0].dep_3;
		deps[4] = self.jsreturn.record[0].dep_4;
		deps[5] = self.jsreturn.record[0].dep_5;
		deps[6] = self.jsreturn.record[0].dep_6;
		deps[7] = self.jsreturn.record[0].dep_7;
		deps[8] = self.jsreturn.record[0].dep_8;
		deps[9] = self.jsreturn.record[0].dep_9;
		deps[10] = 0;
		freeES10DepNbr = 0;
      	for (var i=1; i<11; i++)
      	{
		    if (deps[i] == 0 && freeES10DepNbr != 10)
		   	{
		      	freeES10DepNbr = i;
		      	break;
		   	}
		}
		if (freeES10DepNbr == 10)
		{
			stopProcessing();
			parent.seaAlert(getSeaPhrase("DEP_47","ESS"), null, null, "alert");
			return;
		}
   	}
   	else
   		freeES10DepNbr = 1;
   	CallHR13(action);
}

function ProcessHR13(action, nowarning)
{
	startProcessing(getSeaPhrase("HOME_ADDR_42","ESS"), function(){CallHR13(action, nowarning);});
}

function CallHR13(action, nowarning)
{
	if (!appObj)
		appObj = new AppVersionObject(authUser.prodline, "HR");
	// if you call getAppVersion() right away and the IOS object isn't set up yet,
	// then the code will be trying to load the sso.js file, and your call for
	// the appversion will complete before the ios version is set
	if (iosHandler.getIOS() == null || iosHandler.getIOSVersionNumber() == null)
	{
       	setTimeout(function(){ProcessHR13(action,nowarning)}, 10);
       	return;
	}
	var mainform = depTabs.frame.document.maindepform;
// MOD BY BILAL 	- 	Address form is removed
//	var addrform = depTabs.frame.document.addrdepform;
// END OF MOD
	var pObj = new AGSObject(authUser.prodline, "HR13.1");
	pObj.rtn = "MESSAGE";
	pObj.longNames = "ALL";
	pObj.tds = false;
	pObj.debug = false;
   	if (action == "Add")
   	{
	  	pObj.event = "ADD";
	  	pObj.field = "FC=A";
   	}
   	else
   	{
	  	pObj.event = "CHANGE";
	  	pObj.field = "FC=C";
   	}
   	pObj.field += "&EMD-COMPANY=" + escape(parseInt(authUser.company,10),1)
	+ "&EMD-EMPLOYEE=" + escape(parseInt(authUser.employee,10),1)
	+ "&EMD-SEQ-NBR=" + escape(parseInt(mainform.seqnbr.value,10),1)
	+ "&EMD-FIRST-NAME=" + escape(mainform.firstname.value,1)
	+ "&EMD-MIDDLE-INIT=" + escape(mainform.middleinit.value,1)
	if (typeof(mainform.lastnameprefix) != "undefined")
		pObj.field += "&EMD-LAST-NAME-PRE=" + escape(mainform.lastnameprefix.value,1)
	pObj.field += "&EMD-LAST-NAME=" + escape(mainform.lastname.value,1)
	if (typeof(mainform.namesuffix) != "undefined")
	{
		pObj.field += "&EMD-NAME-SUFFIX="
		+ escape(mainform.namesuffix.options[mainform.namesuffix.selectedIndex].value,1)
	}
	var depAddr = mainform.empaddress.options[mainform.empaddress.selectedIndex].value;
	// PT 149243. Force a 00000000 date value into blank date fields.
	pObj.field += "&EMD-BIRTHDATE=" + ((NonSpace(mainform.birthdate.value) == 0) ? "00000000" : escape(formjsDate(formatDME(mainform.birthdate.value)),1))
	pObj.field += "&EMD-PLACEMENT-DATE=" + ((NonSpace(mainform.placedate.value) == 0) ? "00000000" : escape(formjsDate(formatDME(mainform.placedate.value)),1))
	pObj.field += "&EMD-ADOPTION-DATE=" + ((NonSpace(mainform.adoptdate.value) == 0) ? "00000000" : escape(formjsDate(formatDME(mainform.adoptdate.value)),1))
	pObj.field += "&EMD-FICA-NBR=" + escape(mainform.ficanbr.value,1)
	+ "&EMD-DEP-TYPE=" + escape(mainform.deptype.options[mainform.deptype.selectedIndex].value,1)
	+ "&EMD-REL-CODE=" + escape(mainform.relcode.options[mainform.relcode.selectedIndex].value,1)
	+ "&EMD-EMP-ADDRESS=" + escape(depAddr,1)
	+ "&EMD-SEX=" + escape(mainform.gender.options[mainform.gender.selectedIndex].value,1)
//GDD  09/16/14  Remove disabled
//	+ "&EMD-DISABLED=" + escape(mainform.disabled.options[mainform.disabled.selectedIndex].value,1)
//GDD  end of change
// MOD BY BILAL
//	+ "&EMD-SMOKER=" + escape(mainform.smoker.options[mainform.smoker.selectedIndex].value,1)
//	+ "&EMD-PRIMARY-CARE=" + escape(mainform.pcpcode.value,1)  
// END OF MOD
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "10.00.00")
		pObj.field += "&EMD-EMAIL-PERSONAL=" + escape(addrform.personalemail.value,1)
//GDD 09/26/14  Remove student
//	if (!isStudent || escape(mainform.student.options[mainform.student.selectedIndex].value,1) == "N")
//		pObj.field += "&EMD-STUDENT=" + escape(mainform.student.options[mainform.student.selectedIndex].value,1)
//GDD end of change
	if (depAddr == "H")
	{
		pObj.field += "&EMD-ADDR1=" + escape(" ",1)  // the dependent address fields are
		+ "&EMD-ADDR2=" + escape(" ",1)  // blank because the address is the
		+ "&EMD-ADDR3=" + escape(" ",1)  // employee's home address
		+ "&EMD-ADDR4=" + escape(" ",1)
		+ "&EMD-CITY=" + escape(" ",1)
		+ "&EMD-STATE=" + escape(" ",1)
		+ "&EMD-ZIP=" + escape(" ",1)
		+ "&EMD-COUNTRY-CODE=" + escape(" ",1) 
// MOD BY BILAL  - Adress tab is removed
//		+ "&EMD-WK-PHONE-NBR=" + escape(addrform.wkphonenbr.value,1)
//		+ "&EMD-WK-PHONE-EXT=" + escape(addrform.wkphoneext.value,1)
//		+ "&EMD-WK-PHONE-CNTRY=" + escape(addrform.wkphonecntry.value,1)
//		if (addrform.hmphonenbr.value == "")
//		{
//			pObj.field += "&EMD-HM-PHONE-CNTRY=" + escape(DepInfo[depIndex].pa_employee_hm_phone_cntry,1)
//			+ "&EMD-HM-PHONE-NBR=" + escape(DepInfo[depIndex].pa_employee_hm_phone_nbr,1)
//		}
//		else
//		{
//			pObj.field += "&EMD-HM-PHONE-CNTRY=" + escape(addrform.hmphonecntry.value,1)
//			+ "&EMD-HM-PHONE-NBR=" + escape(addrform.hmphonenbr.value,1)
//		}
//	}
//	else
//	{
//		pObj.field += "&EMD-ADDR1=" + escape(addrform.addr1.value,1)
//		+ "&EMD-ADDR2=" + escape(addrform.addr2.value,1)
//		+ "&EMD-ADDR3=" + escape(addrform.addr3.value,1)
//		+ "&EMD-ADDR4=" + escape(addrform.addr4.value,1)
//		+ "&EMD-CITY=" + escape(addrform.city.value,1)
//		+ "&EMD-STATE=" + escape(addrform.state.value,1)
//		+ "&EMD-ZIP=" + escape(addrform.zip.value,1)
//		+ "&EMD-COUNTRY-CODE=" + escape(addrform.country.options[addrform.country.selectedIndex].value,1)
//		+ "&EMD-HM-PHONE-CNTRY=" + escape(addrform.hmphonecntry.value,1)
//		+ "&EMD-HM-PHONE-NBR=" + escape(addrform.hmphonenbr.value,1)
//		+ "&EMD-WK-PHONE-NBR=" + escape(addrform.wkphonenbr.value,1)
//		+ "&EMD-WK-PHONE-EXT=" + escape(addrform.wkphoneext.value,1)
//		+ "&EMD-WK-PHONE-CNTRY=" + escape(addrform.wkphonecntry.value,1)
	}
	if (action == "Change" && mainform.status.value == "I")
		pObj.field += "&EMD-ACTIVE-FLAG=I"
	else
		pObj.field += "&EMD-ACTIVE-FLAG=A"
	if (nowarning) 
		pObj.field += "&PT-XMIT-NBR1=1"
 	if (appObj && (appObj.getAppVersion() != null) && (appObj.getAppVersion().toString() >= "09.00.01"))	
  		pObj.field += "&EMD-USER-ID=W"+escape(parseInt(authUser.employee,10),1)
   	pObj.func = "parent.DisplayHR13Message('"+action+"')";
	self.lawheader.formCheck = "HR13";
   	AGS(pObj,"jsreturn");
}

function DisplayHR13Message(action)
{
	var msgnbr = parseInt(self.lawheader.gmsgnbr,10);
   	if (msgnbr == 0)
   	{
      	if (prm > 0 && action == "Add" && geffectd)
         	ProcessES10();
	  	else
			DependentUpdateComplete();
   	}
   	else if (msgnbr == 130)
   	{
		self.lawheader.msgnbr = "000";
		self.lawheader.gmsg = " ";
	   	DependentUpdateComplete(getSeaPhrase("DEP_48","ESS"));
	}
	else if (msgnbr == 134)
	{
		stopProcessing();
		var errmsg = "";
		if (typeof(EmpInfo) != "undefined" && typeof(EmpInfo.employee_work_country) != "undefined")
			errmsg += GetFicaErrMsg(EmpInfo.employee_work_country);
  		else if (typeof(CurrentDep) != "undefined" && typeof(CurrentDep.employee_work_country) != "undefined")
     	 	errmsg += GetFicaErrMsg(CurrentDep.employee_work_country);
		else
			errmsg += getSeaPhrase("DEP_19","ESS");
		_action = action;
		var confirmResponse = parent.seaConfirm(errmsg, "", handleConfirmResponse);
		if (confirmResponse)
			ProcessHR13(action, true);		
	}
	else
	{
		stopProcessing();
		parent.seaAlert(self.lawheader.gmsg, null, null, "error");
	}
}

// Firefox will call this function
function handleConfirmResponse(confirmWin)
{
	if (confirmWin.returnValue == "ok" || confirmWin.returnValue == "continue")
		ProcessHR13(_action,true);	
}

function ProcessES10()
{
	var mainform = depTabs.frame.document.maindepform;
	var pObj = new AGSObject(authUser.prodline, "ES10.1");
    pObj.rtn = "MESSAGE";
   	pObj.longNames = "ALL";
   	pObj.tds = false;
	pObj.debug = false;
   	if (familyStatusExists)
   	{
      	pObj.event = "CHANGE";
   	  	pObj.field = "FC=C";
   	}
   	else
   	{
      	pObj.event = "ADD";
   	  	pObj.field = "FC=A";
   	}
	pObj.field += "&FSH-COMPANY=" + escape(parseInt(authUser.company,10),1)
    + "&FSH-EMPLOYEE=" + escape(parseInt(authUser.employee,10),1)
   	+ "&FSH-FAMILY-STATUS=" + escape(taskNm,1)
   	+ "&FSH-EFFECT-DATE=" + escape(geffectd,1)
	+ "&FSH-DEP-" + freeES10DepNbr + "=" + escape(parseInt(mainform.seqnbr.value,10),1)
   	pObj.func = "parent.DisplayES10Message()";
	self.lawheader.formCheck = "ES10";
	AGS(pObj,"jsreturn");
}

function DisplayES10Message()
{
   	if (parseInt(self.lawheader.gmsgnbr,10) == 0)
   		DependentUpdateComplete();
   	else
   	{
   		stopProcessing();   		
   		parent.seaAlert(self.lawheader.gmsg, null, null, "error");
   	}	
}

function DependentUpdateComplete(msg)
{
	ShowListButtons();
	document.getElementById("right").style.visibility = "hidden";
	document.getElementById("leftform").style.visibility = "hidden";
	depTabs.frame.document.maindepform.reset();
// MOD BY BILAL	-	ADDRESS form is removed
//	depTabs.frame.document.addrdepform.reset();
// END OF MOD

	switch (prm)
	{
		case 1: document.getElementById("leftform").style.visibility = "hidden"; break;
		case 2: document.getElementById("leftform").style.visibility = "hidden"; break;
		default: break;
	}
	stopProcessing();
	var alertMsg = getSeaPhrase("DEP_0","ESS");
	if (msg)
		alertMsg += ' '+msg;
	var refreshData = function()
	{
		startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), GetEmdepend);
	};
	var alertResponse = parent.seaPageMessage(alertMsg, "", "info", null, refreshData, true, getSeaPhrase("APPLICATION_ALERT","SEA"), true);
	if (typeof(alertResponse) == "undefined" || alertResponse == null)
	{	
		if (parent.seaPageMessage == parent.alert)
			refreshData();
	}
}

function CancelDependentAction()
{
	deactivateTableRows("depTbl",self.left);
	try 
	{
		self.document.getElementById("right").style.visibility = "hidden";
		ShowListButtons();
	}
	catch(e) {}
}

function OpenHelpDialog()
{
	if (isEnwisenEnabled() && (taskNm == "ADOPTION" || taskNm == "BIRTH"))
		openEnwisenWindow("id=" + taskNm);
	else
		openHelpDialogWindow("/lawson/xhrnet/dependenthelp.htm");
}

/* Filter Select logic - start */
function performDmeFieldFilterOnLoad(dmeFilter)
{
	switch (dmeFilter.getFieldNm().toLowerCase())
	{
		case "pcpcode":
			dmeFilter.addFilterField("code", 15, getSeaPhrase("PRIMARY_CARE_PHYSICIAN","ESS"), true);
			dmeFilter.addFilterField("description", 30, getSeaPhrase("JOB_OPENINGS_2","ESS"), false);
			filterDmeCall(dmeFilter,
				"jsreturn",
				"pcodes",
				"pcoset1",
				"type;code;description",
				"PC",
				"active",
				null,
				dmeFilter.getNbrRecords(),
				null);
		break;
		default: break;
	}
}

function performDmeFieldFilter(dmeFilter)
{
	switch (dmeFilter.getFieldNm().toLowerCase())
	{
		case "pcpcode":
		filterDmeCall(dmeFilter,
			"jsreturn",
			"pcodes",
			"pcoset1",
			"type;code;description",
			"PC",
			"active",
			dmeFilter.getSelectStr(),
			dmeFilter.getNbrRecords(),
			null);
		break;
		default: break;
	}
}

function drawDmeFieldFilterContent(dmeFilter)
{
	var selectHtml = new Array();
	var dmeRecs = self.jsreturn.record;
	var nbrDmeRecs = dmeRecs.length;
	var fieldNm = dmeFilter.getFieldNm().toLowerCase();
	var fldObj = getDmeFieldElement(fieldNm);
	var fldDesc = fldObj[2];	
	switch (fieldNm)
	{
		case "pcpcode": 
			var tmpObj;
			selectHtml[0] = '<table class="filterTable" border="0" cellspacing="0" cellpadding="0" width="100%;padding-left:5px;padding-right:5px" styler="list" summary="'+getSeaPhrase("TSUM_11","SEA",[fldDesc])+'">'
			selectHtml[0] += '<caption class="offscreen">'+getSeaPhrase("TCAP_8","SEA",[fldDesc])+'</caption>'
			selectHtml[0] += '<tr><th scope="col" style="width:50%">'+getSeaPhrase("PRIMARY_CARE_PHYSICIAN","ESS")+'</th>'
			selectHtml[0] += '<th scope="col" style="width:50%">'+getSeaPhrase("JOB_OPENINGS_2","ESS")+'</th></tr>'
			for (var i=0; i<nbrDmeRecs; i++)
			{
				tmpObj = dmeRecs[i];
				selectHtml[i+1] = '<tr onclick="dmeFieldRecordSelected(event,'+i+',\''+fieldNm+'\');return false" class="filterTableRow">'
				selectHtml[i+1] += '<td style="padding-left:5px" nowrap><a href="javascript:;" onclick="dmeFieldRecordSelected(event,'+i+',\''+fieldNm+'\');return false">'
				selectHtml[i+1] += (tmpObj.code) ? tmpObj.code : '&nbsp;'
				selectHtml[i+1] += '</a></td><td style="padding-left:5px" nowrap><a href="javascript:;" onclick="dmeFieldRecordSelected(event,'+i+',\''+fieldNm+'\');return false">'
				selectHtml[i+1] += (tmpObj.description) ? tmpObj.description : '&nbsp;'
				selectHtml[i+1] += '</a></td></tr>'
			}
			if (nbrDmeRecs == 0)
			{
				selectHtml[1] = '<tr class="filterTableRow">'
				selectHtml[1] += '<td style="padding-left:5px" colspan="2" nowrap>'+getSeaPhrase("NORECS","ESS")+'</td></tr>'
			}
			selectHtml[selectHtml.length] = '</table>'
			break;
		default: break;
	}
	dmeFilter.getRecordElement().innerHTML = selectHtml.join("");
}

function dmeFieldRecordSelected(recIndex, fieldNm)
{
	var selRec = self.jsreturn.record[recIndex];
	var formElm = depTabs.frame.document.getElementById(fieldNm.toLowerCase());
	switch (fieldNm.toLowerCase())
	{
		case "pcpcode":
			formElm.value = selRec.code;
			try { depTabs.frame.document.getElementById("xlt_"+fieldNm.toLowerCase()).innerHTML = selRec.description;} catch(e) {}
			break;
		default: break;
	}
	try { filterWin.close(); } catch(e) {}
	try { formElm.focus(); } catch(e) {}
}

function getDmeFieldElement(fieldNm)
{
	var fld = [null, null, null];
	try
	{
		var formElm = depTabs.frame.document.getElementById(fieldNm.toLowerCase());
		fld = [depTabs.frame, formElm, null];
		switch (fieldNm.toLowerCase())
		{
			case "pcpcode": fld[2] = getSeaPhrase("PRIMARY_CARE_PHYSICIAN","ESS"); break;
			default: break;
		}
	}
	catch(e) {}
	return fld;
}

function dmeFieldKeyUpHandler(fieldNm)
{
	var formElm = depTabs.frame.document.getElementById(fieldNm.toLowerCase());
	switch (fieldNm.toLowerCase())
	{
		case "pcpcode": 
			formElm.value = "";
			try { depTabs.frame.document.getElementById("xlt_"+fieldNm.toLowerCase()).innerHTML = "";} catch(e) {}
			break;
		default: break;
	}	
}
/* Filter Select logic - end */

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
	var leftFrame = document.getElementById("left");
	var rightFrame = document.getElementById("right");
	var leftFormFrame = document.getElementById("leftform");
	var fullRelatedTaskFrame = document.getElementById("fullrelatedtask");
	var winObj = getWinSize();
	var winWidth = winObj[0];	
	var winHeight = winObj[1];
	var contentLeftWidth;
	var contentLeftBorderWidth;
	var contentRightWidth;
	var contentRightBorderWidth;	
	var contentHeight;
	var contentBorderHeight;	
	var contentWidth;
	var contentBorderWidth;
	var tabHeight;
	var tabWidth;
	if (window.styler && window.styler.showInfor)
	{
		contentLeftWidth = parseInt(winWidth*.50,10) - 10;
		var elmPad = 2;
		if ((navigator.appName.indexOf("Microsoft") >= 0) && (!document.documentMode || document.documentMode < 8))
			elmPad = 7;		
		contentLeftBorderWidth = contentLeftWidth + elmPad;
		contentRightWidth = parseInt(winWidth*.50,10) - 10;
		contentRightBorderWidth = contentRightWidth + elmPad;
		contentHeight = winHeight - 65;
		contentBorderHeight = contentHeight + 30;
		tabHeight = contentHeight + 25;
		try { tabWidth = (typeof(depTabs) != "undefined" && depTabs.frame && depTabs.frame.frameElement.id == "right") ? contentRightWidth : contentLeftWidth; } catch(e) { tabWidth = contentLeftWidth; }
	}
	else if (window.styler && (window.styler.showLDS || window.styler.showInfor3))
	{
		contentLeftWidth = parseInt(winWidth*.50,10) - 20;
		contentLeftBorderWidth = (window.styler.showInfor3) ? contentLeftWidth + 7 : contentLeftWidth + 17;
		contentRightWidth = parseInt(winWidth*.50,10) - 20;
		contentRightBorderWidth = (window.styler.showInfor3) ? contentRightWidth + 7 : contentRightWidth + 17;
		contentHeight = winHeight - 75;
		contentBorderHeight = contentHeight + 30;				
		tabHeight = contentHeight + 25;
		try { tabWidth = (typeof(depTabs) != "undefined" && depTabs.frame && depTabs.frame.frameElement.id == "right") ? contentRightWidth : contentLeftWidth; } catch(e) { tabWidth = contentLeftWidth; }
	}
	else
	{
		contentLeftWidth = parseInt(winWidth*.50,10) - 10;
		contentLeftBorderWidth = contentLeftWidth;
		contentRightWidth = parseInt(winWidth*.50,10) - 10;
		contentRightBorderWidth = contentRightWidth;
		contentHeight = winHeight - 60;
		contentBorderHeight = contentHeight + 24;				
		tabHeight = contentHeight + 30;
		try { tabWidth = (typeof(depTabs) != "undefined" && depTabs.frame && depTabs.frame.frameElement.id == "right") ? contentRightWidth : contentLeftWidth; } catch(e) { tabWidth = contentLeftWidth; }
	}
	leftFrame.style.width = parseInt(winWidth*.50,10) + "px";
	leftFrame.style.height = winHeight + "px";
	// disable the onresize window event if it exists - we don't want the elements in the frame to resize themselves
	if (self.left.onresize && self.left.onresize.toString().indexOf("setLayerSizes") >= 0)
		self.left.onresize = null;
	try
	{
		self.left.document.getElementById("paneBorder").style.width = contentLeftBorderWidth + "px";
		self.left.document.getElementById("paneBorder").style.height = contentBorderHeight + "px";
		self.left.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.left.document.getElementById("paneBodyBorder").style.width = contentLeftWidth + "px";
		self.left.document.getElementById("paneBody").style.width = contentLeftWidth + "px";
		self.left.document.getElementById("paneBody").style.height = contentHeight + "px";
		self.left.document.getElementById("depTbl").style.width = "100%";
	}
	catch(e) {}
	rightFrame.style.width = parseInt(winWidth*.50,10) + "px";
	rightFrame.style.height = winHeight + "px";
	// disable the onresize window event if it exists - we don't want the elements in the frame to resize themselves
	if (self.right.onresize && self.right.onresize.toString().indexOf("setLayerSizes") >= 0)
		self.right.onresize = null;
	try
	{
		self.right.document.getElementById("paneBorder").style.width = contentRightBorderWidth + "px";
		self.right.document.getElementById("paneBorder").style.height = contentBorderHeight + "px";
		self.right.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.right.document.getElementById("paneBodyBorder").style.width = contentRightWidth + "px";
		self.right.document.getElementById("paneBody").style.width = contentRightWidth + "px";
		self.right.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
	leftFormFrame.style.width = parseInt(winWidth*.50,10) + "px";
	leftFormFrame.style.height = winHeight + "px";
	// disable the onresize window event if it exists - we don't want the elements in the frame to resize themselves
	if (self.leftform.onresize && self.leftform.onresize.toString().indexOf("setLayerSizes") >= 0)
		self.leftform.onresize = null;
	try
	{
		self.leftform.document.getElementById("paneBorder").style.width = contentLeftBorderWidth + "px";
		self.leftform.document.getElementById("paneBorder").style.height = contentBorderHeight + "px";
		self.leftform.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.leftform.document.getElementById("paneBodyBorder").style.width = contentLeftWidth + "px";
		self.leftform.document.getElementById("paneBody").style.width = contentLeftWidth + "px";
		self.leftform.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
	fullRelatedTaskFrame.style.width = winWidth + "px";
	fullRelatedTaskFrame.style.height = winHeight + "px";
	try
	{
		if (window.styler && window.styler.showInfor && (navigator.appName.indexOf("Microsoft") >= 0) && (!document.documentMode || (document.documentMode < 8)))
			tabWidth += 20;
		if (typeof(depTabs) != "undefined")
		{	
			// the theme 10.3 HTML5 control may take time to render tab contents, so wait before sizing
			var delayInMS = (window.styler && window.styler.showInfor3) ? 200 : 1;
			setTimeout(function(){setTabContentSizes("depTabs", depTabs.frame, tabWidth, tabHeight);}, delayInMS);
		}
	}
	catch(e) {}	
	if (window.styler && window.styler.textDir == "rtl")
	{
		leftFrame.style.left = "";
		leftFrame.style.right = "0px";
		leftFormFrame.style.left = "";
		leftFormFrame.style.right = "0px";			
		rightFrame.style.left = "0px";
	}
	else
		rightFrame.style.left = parseInt(winWidth*.50,10) + "px";
}
</script>
<!-- MOD BY BILAL - Prior Customizations-->
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
</head>
<body style="width:100%;height:100%;overflow:hidden" onload="fitToScreen();InitDependents()" onresize="fitToScreen()">
	<iframe id="left" name="left" title="Main Content" level="2" tabindex="0" src="/lawson/xhrnet/ui/headerpane.htm" style="visibility:hidden;position:absolute;left:0px;width:50%;top:0px;height:555px" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="right" name="right" title="Secondary Content" level="3" tabindex="0" src="/lawson/xhrnet/ui/innertabpanehelplite.htm" style="visibility:hidden;position:absolute;left:50%;width:50%;top:0px;height:555px" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="leftform" name="leftform" title="Content" level="2" tabindex="0" src="/lawson/xhrnet/ui/innertabpanehelp.htm" style="visibility:hidden;position:absolute;left:0px;width:50%;top:0px;height:555px" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="fullrelatedtask" name="fullrelatedtask" level="2" tabindex="0" title="Content" style="left:0px;top:0px;position:absolute;width:803px;height:464px;visibility:hidden" src="/lawson/xhrnet/dot.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="jsreturn" name="jsreturn" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/dot.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="lawheader" name="lawheader" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/nerrmsg.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/dependents.htm,v 1.16.2.127.2.3 2014/03/19 19:03:19 brentd Exp $ -->
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
