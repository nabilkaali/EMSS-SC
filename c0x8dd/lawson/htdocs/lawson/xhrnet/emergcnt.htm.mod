<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Pragma" content="No-Cache">
<meta http-equiv="Expires" content="Mon, 01 Jan 1990 00:00:01 GMT">
<title>Emergency Contacts</title>
<script src="/lawson/webappjs/common.js"></script>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/xhrnet/statesuscan.js"></script>
<script src="/lawson/xhrnet/instctrycdselect.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script>
var parentTask = "";
var fromTask = (window.location.search)?unescape(window.location.search):"";
var EmergencyContacts = new Array();
var EmergencyContent;
var emergcntWind;
var empNbr;
var empName;
var appObj;

if (fromTask) 
{
	parentTask = getVarFromString("from",fromTask);
	if (parentTask == "directreports") 
	{
		empNbr = getVarFromString("number",fromTask);
		empName = getVarFromString("name",fromTask);
	}
	fromTask = (parentTask != "") ? fromTask : "";
}

function OpenEmergency()
{
	authenticate("frameNm='jsreturn'|funcNm='GetCountryCodes()'|desiredEdit='EM'");
}

function GetCountryCodes()
{
	stylePage();
	if (!fromTask || parentTask != "directreports")
		empNbr = authUser.employee;
	setWinTitle(getSeaPhrase("EMERGENCY_CONTACTS","ESS"));
	var nextFunc = function()
	{
		GetInstCtryCdSelect(authUser.prodline,"GetStateCodes()");
	};
	if (fromTask) 
	{
		parent.document.getElementById(window.name).style.visibility = "visible";
		parent.showWaitAlert(getSeaPhrase("WAIT","ESS"), nextFunc);
	}
	else
		nextFunc();
}

function GetStateCodes()
{
	GrabStates("GetAppVersion()");
}

function GetAppVersion()
{
	appObj = new AppVersionObject(authUser.prodline, "HR");
	GetPaemergcnt();
}

function GetPaemergcnt()
{
	// if you call getAppVersion() right away and the IOS object isn't set up yet,
	// then the code will be trying to load the sso.js file, and your call for
	// the appversion will complete before the ios version is set
	if (iosHandler.getIOS() == null || iosHandler.getIOSVersionNumber() == null)
	{
       	setTimeout(function(){ GetPaemergcnt(); }, 10);
       	return;
	}
	EmergencyContacts = new Array();
	if (typeof(emergcntWind) != "undefined" && emergcntWind != null && !emergcntWind.closed)
		emergcntWind.close();
	var dmeObj = new DMEObject(authUser.prodline, "paemergcnt");
	dmeObj.out = "JAVASCRIPT";
	dmeObj.index = "paeset1";
	dmeObj.field = "label-name;first-name;last-name;relationship;"
	+ "addr1;addr2;addr3;addr4;city;state;zip;hm-phone-cntry;"
	+ "hm-phone-nbr;wk-phone-cntry;wk-phone-nbr;wk-phone-ext;"
	+ "country.country-desc;country.country-code;seq-nbr";
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
		dmeObj.field += ";cl-phone-nbr;cl-phone-cntry";
	dmeObj.key = parseInt(authUser.company,10) + "=" + parseInt(empNbr,10);
	DME(dmeObj, "jsreturn");
}

function DspPaemergcnt()
{
	EmergencyContacts = EmergencyContacts.concat(self.jsreturn.record);
	if (self.jsreturn.Next != "")
	{
		self.jsreturn.location.replace(self.jsreturn.Next);
		return;
	}
	document.getElementById("RIGHT").style.visibility = "hidden";
	document.getElementById("LEFT").style.visibility = "visible";
	var bodyHtml = ''
	if (EmergencyContacts.length)
	{
		var detailFunc = "UpdateContact";
		if (fromTask && parentTask == "directreports")
			detailFunc = "ViewContact";
		bodyHtml += '<table id="emergencyTbl" class="plaintableborder" border="0" cellspacing="0" cellpadding="0" width="100%" summary="'+getSeaPhrase("TSUM_38","SEA")+'">'
		bodyHtml += '<caption class="offscreen">'+getSeaPhrase("EMERGENCY_CONTACTS","ESS")+'</caption>'
		bodyHtml += '<tr><th scope="col" colspan="2"></th></tr>'
		for (var i=0; i<EmergencyContacts.length; i++)
		{
		   	var contact = EmergencyContacts[i];
		   	var tip = contact.label_name+' - '+getSeaPhrase("EDIT_DTL_FOR","SEA");
			bodyHtml += '<tr><th scope="row" class="plaintablerowheaderborder"style="width:50%;border-bottom:0px;padding-top:5px">'+getSeaPhrase("NAME","ESS")+'</th>'
			+ '<td class="plaintablecellborderdisplay" style="border-bottom:0px;padding-top:10px;padding-top:5px"><a href="javascript:;" onclick="parent.'+detailFunc+'('+i+','+((i*5)-1)+');return false" title="'+tip+'" nowrap>'+contact.label_name+'<span class="offscreen"> - '+getSeaPhrase("EDIT_DTL_FOR","SEA")+'</span></a></td></tr>'
			+ '<tr><th scope="row" class="plaintablerowheaderborder" style="width:50%;border-bottom:0px">'+getSeaPhrase("DEP_23","ESS")+'</th>'
			+ '<td class="plaintablecellborderdisplay" style="border-bottom:0px" nowrap>'+((contact.relationship)?contact.relationship:'&nbsp;')+'</td></tr>'
			if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
			{
				bodyHtml += '<tr><th scope="row" class="plaintablerowheaderborder" style="width:50%;border-bottom:0px">'+getSeaPhrase("CELL_TELEPHONE","ESS")+'</th>'
				+ '<td class="plaintablecellborderdisplay" style="border-bottom:0px" nowrap>'+((contact.cl_phone_cntry)?contact.cl_phone_cntry+'&nbsp;':'')+((contact.cl_phone_nbr)?contact.cl_phone_nbr:'&nbsp;')+'</td></tr>'
			}
			bodyHtml += '<tr><th scope="row" class="plaintablerowheaderborder" style="width:50%;border-bottom:0px">'+getSeaPhrase("HOME_TELEPHONE","ESS")+'</th>'
			+ '<td class="plaintablecellborderdisplay" style="border-bottom:0px" nowrap>'+((contact.hm_phone_cntry)?contact.hm_phone_cntry+'&nbsp;':'')+((contact.hm_phone_nbr)?contact.hm_phone_nbr:'&nbsp;')+'</td></tr>'
			+ '<tr><th scope="row" class="plaintablerowheaderborder" style="width:50%;padding-bottom:5px">'+getSeaPhrase("WORK_TELEPHONE","ESS")+'</th>'
			+ '<td class="plaintablecellborderdisplay" style="padding-bottom:5px" nowrap>'+((contact.wk_phone_cntry)?contact.wk_phone_cntry+'&nbsp;':'')+((contact.wk_phone_nbr)?contact.wk_phone_nbr:'&nbsp;')+'</td></tr>'
		}
	    bodyHtml += '</table>'
	}
	bodyHtml += '<div class="fieldlabel textAlignRight">'
	if (fromTask && parentTask != "main")
	{
		if (parentTask == "directreports")
			bodyHtml += uiButton(getSeaPhrase("BACK","ESS"),"parent.parent.backToMain('emergencycontacts');return false");
		else 
		{
			bodyHtml += uiButton(getSeaPhrase("ADD","ESS"),"parent.AddContact();return false",false,"addbtn");
			bodyHtml += uiButton(getSeaPhrase("CLOSE","ESS"),"parent.CloseEmergency();return false","margin-left:5px","closebtn");
		}
	}
	else
		bodyHtml += uiButton(getSeaPhrase("ADD","ESS"),"parent.AddContact();return false",false,"addbtn");
	bodyHtml += '</div>'
	if (fromTask && parentTask == "directreports" && empName)
		self.LEFT.document.getElementById("paneHeader").innerHTML = getSeaPhrase("CONTACTS","ESS")+' - '+empName;
	else
		self.LEFT.document.getElementById("paneHeader").innerHTML = getSeaPhrase("CONTACTS","ESS");
	var strHtml = '<div class="fieldlabelboldleft" style="padding-left:20px;padding-right:20px;padding-top:10px">'
	if (fromTask && parentTask == "directreports") 
	{
		if (EmergencyContacts.length > 0)
			strHtml += getSeaPhrase("VIEW_EMERGENCY_CONTACT","ESS");
		else
			strHtml += getSeaPhrase("NO_EMP_CONTACTS","ESS");
		strHtml += '</div><p/><div style="overflow:hidden">'+bodyHtml+'</div>';
	} 
	else 
	{
		strHtml += getSeaPhrase("ADD_EMERG_CONTACT","ESS")+'<p/>'
		+((EmergencyContacts.length)?getSeaPhrase("CHG_EMERG_CONTACT","ESS"):'')
		+'</div><p/><div style="overflow:hidden">'+bodyHtml+'</div>';
	}
	self.LEFT.document.getElementById("paneBody").innerHTML = strHtml;
	self.LEFT.stylePage();
	self.LEFT.setLayerSizes();
	if (fromTask)
		parent.removeWaitAlert(getSeaPhrase("CNT_UPD_FRM","SEA",[self.LEFT.getWinTitle()]));
	fitToScreen();	
}

function CloseEmergency()
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
	try { parent.left.setImageVisibility("emergencycontacts_checkmark","visible"); } catch(e) {}
}

function UpdateContact(i, rowNbr)
{
	if (fromTask)
		parent.showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), function(){UpdateContactForm(i,rowNbr);});
	else
		UpdateContactForm(i, rowNbr);
}

function UpdateContactForm(i, rowNbr)
{
	activateTableRow("emergencyTbl",rowNbr,self.LEFT);
	obj = EmergencyContacts[i];	   
// MOD BY BILAL
//ISH 2007 Change to Upper case when save as obj.value.toUpperCase()
	EmergencyContent = '<form name="contactform"><table border="0" cellspacing="0" cellpadding="0" style="width:100%" role="presentation">'
	+ '<tr style="padding-top:5px"><td class="fieldlabelboldlite">'+uiRequiredFooter()+'</td><td>&nbsp;</td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="firstname">'+getSeaPhrase("DEP_34","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="firstname" name="firstname" value="'+obj.first_name+'" size="14" maxlength="14" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()">'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="lastname">'+getSeaPhrase("DEP_38","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="lastname" name="lastname" value="'+obj.last_name+'" size="30" maxlength="30" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()">'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="relationship">'+getSeaPhrase("DEP_23","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="relationship" name="relationship" value="'+obj.relationship+'" size="30" maxlength="30" onfocus="this.select()"></td></tr>' 
// END OF MOD
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
	{
		EmergencyContent += '<tr><td class="fieldlabelboldlite"><label for="clphonenbr">'+getSeaPhrase("CELL_PHONE","ESS")+'</label></td>'
		+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="clphonenbr" name="clphonenbr" value="'+obj.cl_phone_nbr+'" size="15" maxlength="15" onfocus="this.select()"></td></tr>'
// MOD BY BILAL
// JRZ removing Cell phone country - hiding the row.
		+ '<tr id="clctrycd" style="display:none"><td class="fieldlabelboldlite">'
		+ '<label id="clctrycd" for="clphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("CELL_PHONE_CNTRY_CODE","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'</span></label></td>'
		+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="clphonecntry" name="clphonecntry" value="'+obj.cl_phone_cntry+'" size="3" maxlength="3" onfocus="this.select()"></td></tr>'
// END OF MOD
	}
	EmergencyContent += '<tr><td class="fieldlabelboldlite"><label for="hmphonenbr">'+getSeaPhrase("HOME_PHONE_ONLY","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="hmphonenbr" name="hmphonenbr" value="'+obj.hm_phone_nbr+'" size="15" maxlength="15" onfocus="this.select()"></td></tr>'   
// MOD BY BILAL
// JRZ removing home phone country - hiding the row.
	+ '<tr id="hmctrycd" style="display:none"><td class="fieldlabelboldlite"><label id="hmctrycd" for="hmphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("HOME_PHONE_CNTRY_CODE_ONLY","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'</span></label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="hmphonecntry" name="hmphonecntry" value="'+obj.hm_phone_cntry+'" size="3" maxlength="3" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="wkphonenbr">'+getSeaPhrase("WORK_PHONE_ONLY","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphonenbr" name="wkphonenbr" value="'+obj.wk_phone_nbr+'" size="15" maxlength="15" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="wkphoneext">'+getSeaPhrase("JOB_OPENINGS_14","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphoneext" name="wkphoneext" value="'+obj.wk_phone_ext+'" size="5" maxlength="5" onfocus="this.select()"></td></tr>' 
// JRZ removing work phone country  - hiding the row 
	+ '<tr id="wkctrycd" style="display:none"><td class="fieldlabelboldlite"><label id="wkctrycd" for="wkphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("WORK_PHONE_CNTRY_CODE_ONLY","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'</span></label></td>'  
//ISH 2007 Change to Upper case when save as obj.value.toUpperCase()
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphonecntry" name="wkphonecntry" value="'+obj.wk_phone_cntry+'" size="3" maxlength="3" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr1">'+getSeaPhrase("ADDR_1","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr1" name="addr1" value="'+obj.addr1+'" size="30" maxlength="30" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr2">'+getSeaPhrase("ADDR_2","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr2" name="addr2" value="'+obj.addr2+'" size="30" maxlength="30" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr3">'+getSeaPhrase("ADDR_3","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr3" name="addr3" value="'+obj.addr3+'" size="30" maxlength="30" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr4">'+getSeaPhrase("ADDR_4","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr4" name="addr4" value="'+obj.addr4+'" size="30" maxlength="30" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="city">'+getSeaPhrase("CITY_OR_ADDR_5","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="city" name="city" value="'+obj.city+'" size="18" maxlength="18" onfocus="this.select()" onblur="this.value=this.value.toUpperCase()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="state">'+getSeaPhrase("HOME_ADDR_6","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><select class="inputbox" id="state" name="state">'+BuildStateSelect(obj.state)+'</select></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="zip">'+getSeaPhrase("HOME_ADDR_7","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="zip" name="zip" value="'+obj.zip+'" size="10" maxlength="10" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldliteunderline"><label for="country">'+getSeaPhrase("COUNTRY_ONLY","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><span id="countryCell"><select class="inputbox" id="country" name="country">'+DrawInstCtryCdSelect(obj.country_country_code)+'</select></span></td></tr>'
	+ '<tr><td>&nbsp;</td><td class="plaintablecell">'
// END OF MOD
	+ uiButton(getSeaPhrase("UPDATE","ESS"),"parent.ProcessContact();return false","margin-top:10px")
	+ uiButton(getSeaPhrase("CANCEL","ESS"),"parent.CloseEmergencyDetail();return false","margin-top:10px;margin-left:5px;margin-right:15px")
	+ uiButton(getSeaPhrase("DELETE","ESS"),"parent.DeleteContact("+i+");return false","margin-top:10px")
	+ '</td></tr></table>'
	+ '<input class="inputbox" type="hidden" name="seqnbr" value="'+obj.seq_nbr+'">'
	+ '<input class="inputbox" type="hidden" name="fc" value="C"></form>'
	try 
	{
		self.RIGHT.document.getElementById("paneHeader").innerHTML = getSeaPhrase("DETAIL","ESS");
		self.RIGHT.document.getElementById("paneBody").innerHTML = EmergencyContent;
		self.RIGHT.stylePage();
    	self.RIGHT.setLayerSizes();
	}
	catch(e) {}
	SetBtnVisibility("hidden");
	document.getElementById("RIGHT").style.visibility = "visible";
	if (fromTask)
		parent.removeWaitAlert(getSeaPhrase("CNT_UPD_FRM","SEA",[self.RIGHT.getWinTitle()]));
	fitToScreen();
}

function ViewContact(i, rowNbr)
{
	if (fromTask)
		parent.showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), function(){ViewContactForm(i,rowNbr);});
	else
		ViewContactForm(i, rowNbr);
}

function ViewContactForm(i, rowNbr)
{
	activateTableRow("emergencyTbl",rowNbr,self.LEFT);
	obj = EmergencyContacts[i];
	EmergencyContent = '<table class="plaintableborder" border="0" cellspacing="0" cellpadding="0" style="width:100%" summary="'+getSeaPhrase("TSUM_39","SEA",[obj.label_name])+'">'
	+ '<caption class="offscreen">'+getSeaPhrase("TCAP_23","SEA",[obj.label_name])+'</caption>'
	+ '<tr style="padding-top:5px"><th scope="col" colspan="2"></th></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("DEP_34","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.first_name+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("DEP_38","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.last_name+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderborderlite" style="width:50%">'+getSeaPhrase("DEP_23","ESS")+'</th>'
	+ '<td class="plaintablecellborderdisplay" nowrap>'+((obj.relationship)?obj.relationship:'&nbsp;')+'</td></tr>'
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
	{
		EmergencyContent += '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("CELL_PHONE","ESS")+'</th>'
		+ '<td class="plaintablecelldisplay" nowrap>'+obj.cl_phone_nbr+'</td></tr>'
		+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("CELL_PHONE_CNTRY_CODE","ESS")+'</th>'
		+ '<td class="plaintablecelldisplay" nowrap>'+obj.cl_phone_cntry+'</td></tr>'
	}
	EmergencyContent += '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("HOME_PHONE_ONLY","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.hm_phone_nbr+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("HOME_PHONE_CNTRY_CODE_ONLY","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.hm_phone_cntry+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("WORK_PHONE_ONLY","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.wk_phone_nbr+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("JOB_OPENINGS_14","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.wk_phone_ext+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderborderlite" style="width:50%">'+getSeaPhrase("WORK_PHONE_CNTRY_CODE_ONLY","ESS")+'</th>'
	+ '<td class="plaintablecellborderdisplay" nowrap>'+((obj.wk_phone_cntry)?obj.wk_phone_cntry:'&nbsp;')+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("ADDR_1","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.addr1+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("ADDR_2","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.addr2+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("ADDR_3","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.addr3+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("ADDR_4","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.addr4+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("CITY_OR_ADDR_5","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.city+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("HOME_ADDR_6","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+ReturnStateDescription(obj.state)+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("HOME_ADDR_7","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+obj.zip+'</td></tr>'
	+ '<tr><th scope="row" class="plaintablerowheaderlite" style="width:50%">'+getSeaPhrase("COUNTRY_ONLY","ESS")+'</th>'
	+ '<td class="plaintablecelldisplay" nowrap>'+ReturnCountryDescription(obj.country_country_code)+'</td></tr>'
	+ '</table>'
	try 
	{
		self.RIGHT.document.getElementById("paneHeader").innerHTML = getSeaPhrase("DETAIL","ESS");
		self.RIGHT.document.getElementById("paneBody").innerHTML = EmergencyContent;
		self.RIGHT.stylePage();
    	self.RIGHT.setLayerSizes();
	}
	catch(e) {}
	SetBtnVisibility("hidden");
	document.getElementById("RIGHT").style.visibility = "visible";
	if (fromTask)
		parent.removeWaitAlert(getSeaPhrase("CNT_UPD_FRM","SEA",[self.RIGHT.getWinTitle()]));
	fitToScreen();
}

function DeleteContact(i)
{
	obj = EmergencyContacts[i];
	var agsObj = new AGSObject(authUser.prodline, "PA12.1");
	agsObj.event = "CHANGE";
	agsObj.rtn = "MESSAGE";
	agsObj.longNames = "ALL";
	agsObj.tds = false;
	agsObj.field = "FC=D"
	+ "&PAE-COMPANY="+escape(parseInt(authUser.company,10),1)
	+ "&PAE-EMPLOYEE="+escape(parseInt(empNbr,10),1)
	+ "&PAE-SEQ-NBR="+escape(parseInt(obj.seq_nbr,10),1)
	+ "&USER-ID=W"+escape(parseInt(empNbr,10),1);
	agsObj.func = "parent.handlePA12Response()";
	updatetype = "PAE";
	if (fromTask)
		parent.showWaitAlert(getSeaPhrase("HOME_ADDR_42","ESS"),function(){AGS(agsObj,"jsreturn");});
	else
		AGS(agsObj,"jsreturn");
}

function AddContact()
{
	if (fromTask)
		parent.showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), NewContactForm);
	else
		NewContactForm();
}

function NewContactForm()
{ 
// MOD BY BILAL
// Change to Upper case when save as obj.value.toUpperCase()
	EmergencyContent = '<form name="contactform"><table border="0" cellspacing="0" cellpadding="0" style="width:100%;margin-left:auto;margin-right:auto" role="presentation">'
	+ '<tr style="padding-top:5px"><td class="fieldlabelboldlite">'+uiRequiredFooter()+'</td><td>&nbsp;</td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="firstname">'+getSeaPhrase("DEP_34","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="firstname" name="firstname" size="15" maxlength="14" onfocus="this.select() onblur="this.value=this.value.toUpperCase()"">'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="lastname">'+getSeaPhrase("DEP_38","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="lastname" name="lastname" size="30" maxlength="30" onfocus="this.select() onblur="this.value=this.value.toUpperCase()"">'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="relationship">'+getSeaPhrase("DEP_23","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="relationship" name="relationship" size="30" maxlength="30" onfocus="this.select()"></td></tr>'
	if (appObj && appObj.getAppVersion() != null && appObj.getAppVersion().toString() >= "08.01.01")
	{
		EmergencyContent += '<tr><td class="fieldlabelboldlite"><label for="clphonenbr">'+getSeaPhrase("CELL_PHONE","ESS")+'</label></td>'
		+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="clphonenbr" name="clphonenbr" size="15" maxlength="15" onfocus="this.select()"></td></tr>'	
// MOD BY BILAL
// JRZ removing Cell phone country - hiding the row.
		+ '<tr id="clctrycd" style="display:none"><td class="fieldlabelboldlite"><label id="clctrycd" for="clphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("CELL_PHONE_CNTRY_CODE","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'</span></label></td>'
		+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="clphonecntry" name="clphonecntry" size="3" maxlength="3" onfocus="this.select()"></td></tr>'
	}
	EmergencyContent += '<tr><td class="fieldlabelboldlite"><label for="hmphonenbr">'+getSeaPhrase("HOME_PHONE_ONLY","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="hmphonenbr" name="hmphonenbr" size="15" maxlength="15" onfocus="this.select()"></td></tr>'	
// MOD BY BILAL
// JRZ removing home phone country - hiding the row.
	+ '<tr id="hmctrycd" style="display:none"><td class="fieldlabelboldlite"><label id="hmctrycd" for="hmphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("HOME_PHONE_CNTRY_CODE_ONLY","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'<span></label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="hmphonecntry" name="hmphonecntry" size="3" maxlength="3" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="wkphonenbr">'+getSeaPhrase("WORK_PHONE_ONLY","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphonenbr" name="wkphonenbr" size="15" maxlength="15" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="wkphoneext">'+getSeaPhrase("JOB_OPENINGS_14","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphoneext" name="wkphoneext" size="5" maxlength="5" onfocus="this.select()"></td></tr>'  
// MOD BY BILAL
// JRZ removing work phone country - hiding the row.
	+ '<tr id="wkctrycd" style="display:none"><td class="fieldlabelboldlite"><label id="wkctrycd" for="wkphonecntry" title="'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'">'+getSeaPhrase("WORK_PHONE_CNTRY_CODE_ONLY","ESS")+'<span class="offscreen">&nbsp;'+getSeaPhrase("COUNTRY_CODE_HELP_TEXT","ESS")+'<span></label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="wkphonecntry" name="wkphonecntry" size="3" maxlength="3" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr1">'+getSeaPhrase("ADDR_1","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr1" name="addr1" size="30" maxlength="30" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr2">'+getSeaPhrase("ADDR_2","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr2" name="addr2" size="30" maxlength="30" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr3">'+getSeaPhrase("ADDR_3","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr3" name="addr3" size="30" maxlength="30" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="addr4">'+getSeaPhrase("ADDR_4","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="addr4" name="addr4" size="30" maxlength="30" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="city">'+getSeaPhrase("CITY_OR_ADDR_5","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="city" name="city" size="18" maxlength="18" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="state">'+getSeaPhrase("HOME_ADDR_6","ESS")+'</label></td>'
// MOD BY BILAL  - Added Required icon in front of state.
	+ '<td class="plaintablecell" nowrap><select class="inputbox" id="state" name="state">'+BuildStateSelect("")+'</select>'+uiRequiredIcon()+'</td></tr>'
	+ '<tr><td class="fieldlabelboldlite"><label for="zip">'+getSeaPhrase("HOME_ADDR_7","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><input class="inputbox" type="text" id="zip" name="zip" size="10" maxlength="10" onfocus="this.select()"></td></tr>'
	+ '<tr><td class="fieldlabelboldliteunderline"><label for="country">'+getSeaPhrase("COUNTRY_ONLY","ESS")+'</label></td>'
	+ '<td class="plaintablecell" nowrap><span id="countryCell"><select class="inputbox" id="country" name="country">'+DrawInstCtryCdSelect("")+'</select></span></td></tr>'
	+ '<tr><td>&nbsp;</td><td class="plaintablecell">'
	+ uiButton(getSeaPhrase("UPDATE","ESS"),"parent.ProcessContact();return false","margin-top:10px")
	+ uiButton(getSeaPhrase("CANCEL","ESS"),"parent.CloseEmergencyDetail();return false","margin-top:10px;margin-left:5px")
	+ '</td></tr></table>'
	+ '<input class="inputbox" type="hidden" name="seqnbr" value="0">'
	+ '<input class="inputbox" type="hidden" name="fc" value="A">'
	+ '</form>'
	try 
	{
		self.RIGHT.document.getElementById("paneHeader").innerHTML = getSeaPhrase("DETAIL","ESS");
		self.RIGHT.document.getElementById("paneBody").innerHTML = EmergencyContent;
		self.RIGHT.stylePage();
    	self.RIGHT.setLayerSizes();
	}
	catch(e) {}
	SetBtnVisibility("hidden");
	document.getElementById("RIGHT").style.visibility = "visible";
	if (fromTask)
		parent.removeWaitAlert(getSeaPhrase("CNT_UPD_FRM","SEA",[self.RIGHT.getWinTitle()]));
	fitToScreen();
}

function SetBtnVisibility(val)
{
	try 
	{
		self.LEFT.document.getElementById("addbtn").style.visibility = val;
		self.LEFT.document.getElementById("closebtn").style.visibility = val;
	}
	catch(e) {}
}

function CloseEmergencyDetail()
{
	deactivateTableRows("emergencyTbl",self.LEFT);
	SetBtnVisibility("visible");
	document.getElementById("RIGHT").style.visibility = "hidden";
	document.getElementById("LEFT").style.visibility = "visible";
}

function ProcessContact()
{
	var obj = self.RIGHT.document.contactform;
	for (var i=0; i<obj.elements.length; i++)
	{
		if (obj.elements[i].value == "")
			obj.elements[i].value = " ";
	}
	clearRequiredField(obj.firstname);
	clearRequiredField(obj.lastname);
	clearRequiredField(obj.hmphonenbr);
	clearRequiredField(obj.hmphonecntry);
	clearRequiredField(obj.wkphonenbr);
	clearRequiredField(obj.wkphonecntry);
	if (obj.clphonenbr)
		clearRequiredField(obj.clphonenbr);
	if (obj.clphonecntry)
		clearRequiredField(obj.clphonecntry);
	clearRequiredField(self.RIGHT.document.getElementById("countryCell"));
	if (NonSpace(obj.firstname.value) == 0)
	{
		setRequiredField(obj.firstname, getSeaPhrase("FIRST_NAME","ESS"));
		return;
	}
	if (NonSpace(obj.lastname.value) == 0)
	{
		setRequiredField(obj.lastname, getSeaPhrase("LAST_NAME","ESS"));
		return;
	}
	if (obj.clphonenbr)
	{
		if (NonSpace(obj.clphonenbr.value) == 0 && NonSpace(obj.hmphonenbr.value) == 0 && NonSpace(obj.wkphonenbr.value) == 0)
		{
			var msg = getSeaPhrase("HOME_CELL_WORK_NBR_REQUIRED","ESS");
			setRequiredField(obj.hmphonenbr, msg, obj.clphonenbr);
			setRequiredField(obj.wkphonenbr, msg, obj.clphonenbr, false);
		 	setRequiredField(obj.clphonenbr, msg, obj.clphonenbr, false);
			return;
		}
	}
	else
	{
		if (NonSpace(obj.hmphonenbr.value) == 0 && NonSpace(obj.wkphonenbr.value) == 0)
		{
			var msg = getSeaPhrase("PHONE_NBR_REQUIRED","ESS");
			setRequiredField(obj.hmphonenbr, msg, obj.hmphonenbr);
			setRequiredField(obj.wkphonenbr, msg, obj.hmphonenbr, false);
			return;
		}
	}
	if (NonSpace(obj.hmphonenbr.value) > 0 && !ValidPhoneEntry(obj.hmphonenbr))
	{
		setRequiredField(obj.hmphonenbr, getSeaPhrase("PHONE_NBR_ERROR","ESS"));
		return;
	}
	if (NonSpace(obj.wkphonenbr.value) > 0 && !ValidPhoneEntry(obj.wkphonenbr))
	{
		setRequiredField(obj.wkphonenbr, getSeaPhrase("PHONE_NBR_ERROR","ESS"));
		return;
	}
    if (obj.clphonenbr && NonSpace(obj.clphonenbr.value) > 0 && !ValidPhoneEntry(obj.clphonenbr))
	{
		setRequiredField(obj.clphonenbr, getSeaPhrase("PHONE_NBR_ERROR","ESS"));
		return;
	}
	if (NonSpace(obj.hmphonecntry.value) > 0 && !ValidPhoneEntry(obj.hmphonecntry))
	{
		setRequiredField(obj.hmphonecntry, getSeaPhrase("PHONE_COUNTRY_CODE_ERROR","ESS"));
		return;
	}
	if (NonSpace(obj.wkphonecntry.value) > 0 && !ValidPhoneEntry(obj.wkphonecntry))
	{
		setRequiredField(obj.wkphonecntry, getSeaPhrase("PHONE_COUNTRY_CODE_ERROR","ESS"));
		return;
	}
	if (obj.clphonecntry && NonSpace(obj.clphonecntry.value) > 0 && !ValidPhoneEntry(obj.clphonecntry))
	{
		setRequiredField(obj.clphonecntry, getSeaPhrase("PHONE_COUNTRY_CODE_ERROR","ESS"));
		return;
	}
// MOD BY BILAL - uncommenting the code
///* Do not require state or province, as it is not required on PA12.
	if ((obj.state.selectedIndex>=0 && NonSpace(obj.state.options[obj.state.selectedIndex].value) == 0) 
	&& (obj.country.selectedIndex >=0 && NonSpace(obj.country.options[obj.country.selectedIndex].value) == 0))
	{
		setRequiredField(obj.state, getSeaPhrase("STATE_PROVINCE","ESS"));
		return;
	}

// END OF MOD
	var object = new AGSObject(authUser.prodline, "PA12.1");
	object.rtn = "MESSAGE";
	object.longNames = "ALL";
	object.tds = false;
	if (obj.fc.value == "C")
	{
		object.event = "CHANGE";
		object.field = "FC=C";
	}
 	else
	{
		object.event = "ADD";
		object.field = "FC=A";
	}
// MOD BY BILAL
//ISH 2007 Change to Upper case when save as obj.value.toUpperCase()
    object.field += "&PAE-COMPANY=" + escape(parseInt(authUser.company,10),1)
	+ "&PAE-EMPLOYEE=" + escape(parseInt(empNbr,10),1)
	+ "&PAE-SEQ-NBR=" + escape(parseInt(obj.seqnbr.value,10),1)
	+ "&PAE-FIRST-NAME=" + escape(obj.firstname.value.toUpperCase(),1)
	+ "&PAE-LAST-NAME=" + escape(obj.lastname.value.toUpperCase(),1)
	+ "&PAE-RELATIONSHIP=" + escape(obj.relationship.value.toUpperCase(),1)
	+ "&PAE-ADDR1=" + escape(obj.addr1.value.toUpperCase(),1)
	+ "&PAE-ADDR2=" + escape(obj.addr2.value.toUpperCase(),1)
	+ "&PAE-ADDR3=" + escape(obj.addr3.value.toUpperCase(),1)
	+ "&PAE-ADDR4=" + escape(obj.addr4.value.toUpperCase(),1)
	+ "&PAE-CITY=" + escape(obj.city.value.toUpperCase(),1);
	if (obj.state.selectedIndex >= 0)
		object.field += "&PAE-STATE=" + escape(obj.state.options[obj.state.selectedIndex].value,1);
	else
		object.field += "&PAE-STATE=" + escape("");
	object.field += "&PAE-ZIP=" + escape(obj.zip.value,1);
	if (obj.country.selectedIndex >= 0)
		object.field += "&PAE-COUNTRY-CODE=" + escape(obj.country.options[obj.country.selectedIndex].value,1);
	else
		object.field += "&PAE-COUNTRY-CODE=" + escape("");
	if (obj.clphonecntry && obj.clphonenbr)
	{
		object.field += "&PAE-CL-PHONE-CNTRY=" + escape(obj.clphonecntry.value,1);
	    object.field += "&PAE-CL-PHONE-NBR=" + escape(obj.clphonenbr.value,1);
	}
	object.field += "&PAE-HM-PHONE-CNTRY=" + escape(obj.hmphonecntry.value,1)
	+ "&PAE-HM-PHONE-NBR=" + escape(obj.hmphonenbr.value,1)
	+ "&PAE-WK-PHONE-NBR=" + escape(obj.wkphonenbr.value,1)
	+ "&PAE-WK-PHONE-CNTRY=" + escape(obj.wkphonecntry.value,1)
	+ "&PAE-WK-PHONE-EXT=" + escape(obj.wkphoneext.value,1)
	+ "&USER-ID=W" + escape(parseInt(empNbr,10),1);
	object.func = "parent.handlePA12Response()";
	updatetype = "PAE";
	if (fromTask)
		parent.showWaitAlert(getSeaPhrase("HOME_ADDR_42","ESS"), function(){AGS(object,"jsreturn");});
	else
		AGS(object,"jsreturn");
}

function handlePA12Response()
{
	if (self.lawheader.gmsgnbr != "000")
	{
	 	if (fromTask)
			parent.removeWaitAlert();
	 	parent.seaAlert(self.lawheader.gmsg, null, null, "error");
		if (self.lawheader.gmsgnbr == "107")
		{
			var formObj = self.RIGHT.document.contactform;
			setRequiredField(self.RIGHT.document.getElementById("countryCell"), self.lawheader.gmsg, formObj.country);
		}
	}
	else
	{
		if (fromTask)
			parent.removeWaitAlert();
		var refreshData = function()
		{
			if (fromTask)
				parent.showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), GetPaemergcnt);
			else
				GetPaemergcnt();
		}
		var alertResponse = parent.seaPageMessage(getSeaPhrase("UPDATE_COMPLETE","ESS"), "", "info", null, refreshData, true, getSeaPhrase("APPLICATION_ALERT","SEA"), true);
		if (typeof(alertResponse) == "undefined" || alertResponse == null)
		{	
			if (parent.seaPageMessage == parent.alert)
				refreshData();
		}		
	}	
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
	{	
		leftFrame.style.left =  "0px";
		rightFrame.style.left = parseInt(winWidth*.50,10) + "px";
	}	
}
</script>
<!-- MOD BY BILAL - Prior customizations  -->
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
<body style="width:100%;height:100%;overflow:hidden" onload="OpenEmergency()" onresize="fitToScreen()">
	<iframe id="LEFT" name="LEFT" title="Main Content" level="2" tabindex="0" style="position:absolute;top:0px;left:0px;width:49%;height:464px" src="/lawson/xhrnet/ui/headerpane.htm" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	<iframe id="RIGHT" name="RIGHT" title="Secondary Content" level="3" tabindex="0" style="visibility:hidden;position:absolute;top:0px;left:49%;width:51%;height:464px" src="/lawson/xhrnet/ui/headerpanelite.htm" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	<iframe id="jsreturn" name="jsreturn" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/dot.htm" marginwidth="0" marginheight="0" scrolling="no" frameborder="no"></iframe>
	<iframe id="lawheader" name="lawheader" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/esslawheader.htm" marginwidth="0" marginheight="0" scrolling="no" frameborder="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/emergcnt.htm,v 1.22.2.75 2014/02/17 21:29:54 brentd Exp $ -->
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
