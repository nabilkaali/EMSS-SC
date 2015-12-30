<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Pragma" content="No-Cache">
<title>Veteran Status</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/common.js"></script>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/xhrnet/waitalert.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script src="/lawson/webappjs/javascript/objects/ActivityDialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/OpaqueCover.js"></script>
<script src="/lawson/webappjs/javascript/objects/Dialog.js"></script>
<script>
var updatetype = "";
var EmpInfo = new Object();
var VeteranStatuses;
var appObj;

function OpenVeteran()
{
	authenticate("frameNm='jsreturn'|funcNm='InitVeteran()'|desiredEdit='EM'");
}

function InitVeteran()
{
	stylePage();
	var title = getSeaPhrase("VETERAN_STATUS","ESS");
	setWinTitle(title);
	setTaskHeader("header",title,"Personal");
	StoreDateRoutines();
	showWaitAlert(getSeaPhrase("WAIT","ESS"), GetLawsonApplicationVersion);
}

function GetLawsonApplicationVersion()
{
	if (!appObj)
		appObj = new AppVersionObject(authUser.prodline, "HR");
	// if you call getAppVersion() right away and the IOS object isn't set up yet,
	// then the code will be trying to load the sso.js file, and your call for
	// the appversion will complete before the ios version is set
	if (iosHandler.getIOS() == null || iosHandler.getIOSVersionNumber() == null)
	{
       	setTimeout("GetLawsonApplicationVersion()", 10);
       	return;
	}
	GetEmployee();
}

function GetEmployee()
{
	var dmeObj = new DMEObject(authUser.prodline, "paemployee");
	dmeObj.out = "JAVASCRIPT";
	dmeObj.field = "employee.work-country;veteran";
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
		dmeObj.field += ";veteran.description";
	else
		dmeObj.field += ";veteran,xlt";
	dmeObj.key = parseInt(authUser.company,10) + "=" + parseInt(authUser.employee,10);
	dmeObj.func = "GetVeteranStatuses()";
	dmeObj.otmmax = "1";
	dmeObj.max = "1";
  	DME(dmeObj,"jsreturn");
}

function GetVeteranStatuses()
{
	EmpInfo = self.jsreturn.record[0];
	VeteranStatuses = new Array();

	// if we are running on 8.1.1 applications or newer, perform a DME to get the veteran status select;
	// otherwise use a hard-coded value list.
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
	{
		if (!emssObjInstance.emssObj.filterSelect)
		{
			var dmeObj = new DMEObject(authUser.prodline,"HRCTRYCODE");
			dmeObj.out = "JAVASCRIPT";
			dmeObj.index = "ctcset1";
			dmeObj.field = "hrctry-code;description";
			dmeObj.key = "VS";
			if (EmpInfo.employee_work_country)
				dmeObj.key += "=" + EmpInfo.employee_work_country;
			dmeObj.cond = "active";
			dmeObj.max = "600";
			dmeObj.func = "StoreVeteranStatuses()";
			DME(dmeObj,"jsreturn");
		}
		else
			DrawVeteranScreen();
	}
	else
	{
		VeteranStatuses[0] = new Object();
		VeteranStatuses[0].hrctry_code = "N";
		VeteranStatuses[0].description = getSeaPhrase("NO","ESS");
		VeteranStatuses[1] = new Object();
		VeteranStatuses[1].hrctry_code = "Y";
		VeteranStatuses[1].description = getSeaPhrase("YES","ESS");
		VeteranStatuses[2] = new Object();
		VeteranStatuses[2].hrctry_code = "1";
		VeteranStatuses[2].description = getSeaPhrase("VETERAN","ESS");
		VeteranStatuses[3] = new Object();
		VeteranStatuses[3].hrctry_code = "2";
		VeteranStatuses[3].description = getSeaPhrase("DISABLED_VET","ESS");
		VeteranStatuses[4] = new Object();
		VeteranStatuses[4].hrctry_code = "3";
		VeteranStatuses[4].description = getSeaPhrase("VIETNAM_VET","ESS");
		VeteranStatuses[5] = new Object();
		VeteranStatuses[5].hrctry_code = "4";
		VeteranStatuses[5].description = getSeaPhrase("DISABLED_VIETNAM_VET","ESS");
		VeteranStatuses[6] = new Object();
		VeteranStatuses[6].hrctry_code = "5";
		VeteranStatuses[6].description = getSeaPhrase("GULF_WAR_VET","ESS");
		VeteranStatuses[7] = new Object();
		VeteranStatuses[7].hrctry_code = "6";
		VeteranStatuses[7].description = getSeaPhrase("SPECIAL_DISABLED_VET","ESS");
		VeteranStatuses[8] = new Object();
		VeteranStatuses[8].hrctry_code = "7";
		VeteranStatuses[8].description = getSeaPhrase("OTHER_VET","ESS");
		DrawVeteranScreen();
	}
}

function StoreVeteranStatuses()
{
	VeteranStatuses = VeteranStatuses.concat(self.jsreturn.record);
	if (self.jsreturn.Next)
	{
		self.jsreturn.location.replace(self.jsreturn.Next);
		return;
	}
	VeteranStatuses = VeteranStatuses.sort(sortByDescription);
	DrawVeteranScreen();
}

function DrawVeteranSelect(selectedvalue)
{
	var codeselect = new Array();
	codeselect[0] = "<option value=' '>";
	for (var i=0; i<VeteranStatuses.length; i++)
	{
		codeselect[i+1] = "";
		codeselect[i+1] += "<option value='" + VeteranStatuses[i].hrctry_code + "'";
		if (VeteranStatuses[i].hrctry_code == selectedvalue)
		    codeselect[i+1] += " selected";
		codeselect[i+1] += ">" + VeteranStatuses[i].description;
	}
	return codeselect.join("");
}

function DrawVeteranScreen()
{
	var toolTip;
	var veteranStatus = EmpInfo.veteran;
	var sb = new Array();
	sb[sb.length] = '<form name="veteranform">'
	+ '<table border="0" cellspacing="0" cellpadding="0" style="width:100%" role="presentation">'
	+ '<tr><td class="plaintablerowheaderborderbottom" style="padding-top:5px"><label for="veteran">'+getSeaPhrase("VETERAN_STATUS","ESS")+'</label></td>'
	+ '<td class="plaintablecell" style="padding-top:5px" nowrap>';
	if (emssObjInstance.emssObj.filterSelect && appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
	{
		toolTip = dmeFieldToolTip("veteran");
		sb[sb.length] = '<input type="text" id="veteran" name="veteran" fieldnm="veteran" class="inputbox" size="4" maxlength="4" '
		+ 'value="'+veteranStatus+'" onkeyup="parent.dmeFieldOnKeyUpHandler(event,\'veteran\');"/>'
		+ '<a href="javascript:;" onclick="parent.openDmeFieldFilter(\'veteran\');return false" title="'+toolTip+'" aria-label="'+toolTip+'"><img src="/lawson/xhrnet/ui/images/ico_form_dropmenu.gif" border="0" style="margin-bottom:-3px" alt="'+toolTip+'" title="'+toolTip+'">'
		+ '</a><span class="plaintablecelldisplay" style="width:200px" id="xlt_veteran">' 
		if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
			sb[sb.length-1] += EmpInfo.veteran_description;
		else
			sb[sb.length-1] += EmpInfo.veteran_xlt;
		sb[sb.length-1] += '</span>';
	}
	else
		sb[sb.length] = '<select id="veteran" name="veteran">'+DrawVeteranSelect(veteranStatus)+'</select>';
	sb[sb.length] = '</td></tr><tr><td>&nbsp;</td><td class="plaintablecell">'
	+ uiButton(getSeaPhrase("UPDATE","ESS"),"parent.ProcessVeteran();return false","margin-top:10px")
	+ uiButton(getSeaPhrase("CANCEL","ESS"),"parent.CancelVeteran();return false","margin-top:10px;margin-left:5px")
	+ '</td></tr></table>'
	+ '<br>'
	+ '<table border="1" cellspacing="0" cellpadding="0" style="width:100%">'
	+ '<tr><td class="plaintablecell" style="text-align:left:padding-top:5px" colspan="2"><b>Veteran Status Codes:</b></td></tr>'
	+ '<tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>1 - Disabled Veteran</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran of the U.S. military entitled to compensation under laws administered by the Secretary of Veteran Affairs, or a person discharged or released from active duty because of a service connected disability.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>2 - Act Dty Wartime/Campaign Badge</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who served on active duty in the U.S. military during a war or campaign or expedition for which a campaign badge was awarded.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>3 - Armed Forces Service Medal Vet</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who, while serving on active duty in the Armed Forces, participated in a United States military operation for which an Armed Forces service medal was awarded pursuant to Executive Order 12985.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>4 - Recently Separated Veteran</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Recently separated veteran (veterans within 36 months from discharge or release from active duty).</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>5 - Disabled/Other Protected</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Disabled Veteran and Other Protected Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>6 - Disabled/Arm Forces Svc Medal</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Disabled Veteran and Armed Forces Service Medal Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>7 - Disabled/Recently Separated</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Disabled Veteran and Recently Separated Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>8 - Disabled/Other/AFS Medal</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Disabled Veteran, Other Protected Veteran, and Armed Forces Service Medal Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>9 - Disabled/Other/Recently Sep</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Disabled Veteran, Other Protected Veteran, and Recently Separated Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>10 - Disabled/AFS Medal/Recently Sep</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Disabled Veteran, Armed Forces Service Medal Veteran, and Recently Separated Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>11 - Disable/Other/Medal/Recent Sep</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Disabled Veteran, Other Protected Veteran, Armed Forces Service Medal Veteran, and Recently Separated Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>12 - Other/Arm Forces Service Medal</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Other Protected Veteran and Armed Forces Service Medal Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>13 - Other/Recently Separated</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Other Protected Veteran and Recently Separated Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>14 - Other/AFS Medal/Recently Sep</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Other Protected Veteran, Armed Forces Service Medal Veteran, and Recently Separated Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>15 - Arm Fcs Svc Medal/Recently Sep</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Veteran who meets the qualifications of Armed Forces Service Medal Veteran and Recently Separated Veteran.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>98 - Veteran - None of the Above</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">A veteran of the U.S. military that does not fit into one of the above protected classes as defined by the U.S. Department of Labor.</td>'
	+ '</tr><tr>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px" nowrap><b>99 - Not Disclosed</b></td>'
	+ '<td class="plaintablecell" style="text-align:left:padding-top:5px">Not Disclosed.</td>'
	+ '</tr>'
	+ '</table>'
    + '</form>';
	try
	{
		self.MAIN.document.getElementById("paneHeader").innerHTML = getSeaPhrase("DETAILS","ESS");
		self.MAIN.document.getElementById("paneBody").innerHTML = sb.join("");
		self.MAIN.stylePage();
		self.MAIN.setLayerSizes();
		document.getElementById("MAIN").style.visibility = "visible";
	}
	catch(e) {}
	removeWaitAlert(getSeaPhrase("CNT_UPD_FRM","SEA",[self.MAIN.getWinTitle()]));	
	fitToScreen();
}

function CancelVeteran()
{
	self.MAIN.location = "/lawson/xhrnet/ui/logo.htm";
}

function ProcessVeteran()
{
	var nextFunc = function()
	{
		var formObj = self.MAIN.document.forms["veteranform"];
		for (var i=0; i<formObj.elements.length; i++)
		{
			if (NonSpace(formObj.elements[i].value) == 0)
				formObj.elements[i].value = " ";	
		}
		var agsObj = new AGSObject(authUser.prodline, "HR11.1");
		agsObj.event = "CHANGE";
		agsObj.rtn = "MESSAGE";
		agsObj.longNames = "ALL";
		agsObj.tds = false;
		agsObj.field = "FC=C"
		+ "&EFFECT-DATE=" + ymdtoday
		+ "&EMP-COMPANY=" + parseInt(authUser.company,10)
		+ "&EMP-EMPLOYEE=" + parseInt(authUser.employee,10)
		+ "&PEM-VETERAN=" + escape(formObj.elements["veteran"].value,1)
		+ "&XMIT-HREMP-BLOCK=1000000000"
		+ "&XMIT-REQDED=1"
		+ "&PT-BYPASS-PERS-ACT=1";
		agsObj.func = "parent.DisplayMessage()";
		agsObj.debug = false;
		updatetype = "VET";
		for (var i=0; i<formObj.elements.length; i++)
		{
			if (NonSpace(formObj.elements[i].value) == 0)
				formObj.elements[i].value = "";	
		}
		AGS(agsObj,"jsreturn");
	};
	showWaitAlert(getSeaPhrase("HOME_ADDR_42","ESS"), nextFunc);
}

function DisplayMessage()
{
	removeWaitAlert();
	var msg = self.lawheader.gmsg;
	var msgnbr = parseInt(self.lawheader.gmsgnbr,10);
	if (msgnbr != 0)
	{
		if (msgnbr == 50 || msgnbr == 141)
			msg = getSeaPhrase("REQUIRE_ADDITIONAL_INFO_CONTACT_HR","ESS");
		seaAlert(msg, null, null, "error");
	}
	else
	{
		msg = getSeaPhrase("CHANGE_COMPLETE_NO_CONTINUE","ESS");
		var alertResponse = seaPageMessage(msg, null, null, "info", GetEmployee, true, getSeaPhrase("APPLICATION_ALERT","SEA"), true);
		if (typeof(alertResponse) == "undefined" || alertResponse == null)
		{	
			if (seaPageMessage == window.alert)
				GetEmployee();
			return;
		}
	}
}

function OpenHelpDialog()
{
	openHelpDialogWindow("/lawson/xhrnet/veterantips.htm");
}

function sortByDescription(obj1, obj2)
{
	if (obj1.description < obj2.description)
		return -1;
	else if (obj1.description > obj2.description)
		return 1;
	else
		return 0;
}

/* Filter Select logic - start */
function performDmeFieldFilterOnLoad(dmeFilter)
{
	switch (dmeFilter.getFieldNm().toLowerCase())
	{
		case "veteran": // veteran status
			var keyStr = "VS";
			if (EmpInfo && EmpInfo.employee_work_country)
				keyStr += "=" + EmpInfo.employee_work_country;
			dmeFilter.addFilterField("hrctry-code", 4, getSeaPhrase("VETERAN_STATUS","ESS"), true);
			dmeFilter.addFilterField("description", 30, getSeaPhrase("JOB_OPENINGS_2","ESS"), false);
			filterDmeCall(dmeFilter,
				"jsreturn",
				"hrctrycode",
				"ctcset1",
				"hrctry-code;description",
				keyStr,
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
		case "veteran": // veteran status
		var keyStr = "VS";
		if (EmpInfo && EmpInfo.employee_work_country)
			keyStr += "=" + EmpInfo.employee_work_country;
		filterDmeCall(dmeFilter,
			"jsreturn",
			"hrctrycode",
			"ctcset1",
			"hrctry-code;description",
			keyStr,
			"active",
			dmeFilter.getSelectStr(),
			dmeFilter.getNbrRecords(),
			null);
		break;
		default: break;
	}
}

function dmeFieldRecordSelected(recIndex, fieldNm)
{
	var selRec = self.jsreturn.record[recIndex];
	var formElm = self.MAIN.document.getElementById(fieldNm.toLowerCase());
	var formDescElm;
	switch (fieldNm.toLowerCase())
	{
		case "veteran": // veteran status
			formElm.value = selRec.hrctry_code;
			try { self.MAIN.document.getElementById("xlt_"+fieldNm.toLowerCase()).innerHTML = selRec.description; } catch(e) {}
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
		var formElm = self.MAIN.document.getElementById(fieldNm.toLowerCase());
		fld = [self.MAIN, formElm, null];
		switch (fieldNm.toLowerCase())
		{
			case "veteran": fld[2] = getSeaPhrase("VETERAN_STATUS","ESS"); break;
			default: break;
		}	
	}
	catch(e) {}
	return fld;
}

function dmeFieldKeyUpHandler(fieldNm)
{
	var formElm = self.MAIN.document.getElementById(fieldNm.toLowerCase());
	switch (fieldNm.toLowerCase())
	{
		case "veteran": // veteran status
			try { self.MAIN.document.getElementById("xlt_"+fieldNm.toLowerCase()).innerHTML = ""; } catch(e) {}
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
		case "veteran": // veteran status
			var tmpObj;
			selectHtml[0] = '<table class="filterTable" border="0" cellspacing="0" cellpadding="0" width="100%;padding-left:5px;padding-right:5px" styler="list" summary="'+getSeaPhrase("TSUM_11","SEA",[fldDesc])+'">'
			selectHtml[0] += '<caption class="offscreen">'+getSeaPhrase("TCAP_8","SEA",[fldDesc])+'</caption>'
			selectHtml[0] += '<tr><th scope="col" style="width:50%">'+getSeaPhrase("VETERAN_STATUS","ESS")+'</th>'
			selectHtml[0] += '<th scope="col" style="width:50%">'+getSeaPhrase("JOB_OPENINGS_2","ESS")+'</th></tr>'
			for (var i=0; i<nbrDmeRecs; i++)
			{
				tmpObj = dmeRecs[i];
				selectHtml[i+1] = '<tr onclick="dmeFieldRecordSelected(event,'+i+',\''+fieldNm+'\');return false" class="filterTableRow">'
				selectHtml[i+1] += '<td style="padding-left:5px" nowrap><a href="javascript:;" onclick="dmeFieldRecordSelected(event,'+i+',\''+fieldNm+'\');return false">'
				selectHtml[i+1] += (tmpObj.hrctry_code) ? tmpObj.hrctry_code : '&nbsp;'
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
	var mainFrame = document.getElementById("MAIN");
	var winObj = getWinSize();
	var winWidth = winObj[0];	
	var winHeight = winObj[1];
	var contentHeightBorder;
	var contentHeight;	
	var contentWidthBorder;
	var contentWidth;
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
		contentHeight = winHeight - 60;
		contentHeightBorder = contentHeight + 24;		
	}
	mainFrame.style.width = winWidth + "px";
	mainFrame.style.height = winHeight + "px";
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
</head>
<body style="overflow:hidden" onload="OpenVeteran()" onresize="fitToScreen()">
	<iframe id="header" name="header" title="Header" level="1" tabindex="0" style="visibility:hidden;position:absolute;height:32px;width:803px;left:0px;top:0px" src="/lawson/xhrnet/ui/header.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="MAIN" name="MAIN" title="Main Content" level="2" tabindex="0" style="visibility:hidden;position:absolute;left:0%;height:300px;width:500px;top:32px" src="/lawson/xhrnet/ui/headerpanehelp.htm" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	<iframe id="jsreturn" name="jsreturn" title="Empty" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;height:0px;width:0px;" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="lawheader" name="lawheader" title="Empty" src="/lawson/xhrnet/errmsg.htm" style="visibility:hidden;height:0px;width:0px;" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/Attic/veteran.htm,v 1.1.2.51 2014/02/25 22:49:13 brentd Exp $ -->
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
