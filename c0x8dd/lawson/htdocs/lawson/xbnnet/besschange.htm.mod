<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<title>Change Your Benefit Elections</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script>
var flag=0
var match=false
function initProgram()
{
	setWinTitle(getSeaPhrase("CHANGE_ELECTIONS","BEN"));
	parent.startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), startProgram);
}
function startProgram()
{
	var html = '<div class="plaintablecell" style="padding:0px">' 
	// MOD BY BILAL
	html += '<center>'
	// END OF MOD
	html += '<br/><table cellspacing="0" cellpadding="0" border="0" style="width:100%;margin-left:auto;margin-right:auto" role="presentation">'
	html += '<tr><td class="plaintablecell">'+getSeaPhrase("CHGBEN_6","BEN")+' '+getSeaPhrase("CHGBEN_7","BEN")+'</td>'
	html += '</tr></table><br/>'
	html += '</center><center>'
// END OF MOD
	html += '<form name="listform">'
	html += '<table class="plaintableborder" border="0" cellspacing="0" cellpadding="0" style="width:100%;margin-left:auto;margin-right:auto" styler="list" summary="'+getSeaPhrase("TSUM_6","BEN")+'">'
	html += '<caption class="offscreen">'+getSeaPhrase("TCAP_5","BEN")+'</caption>'
	html += '<tr><th scope="col" class="plaintableheaderborder" style="width:50px;text-align:center">'+getSeaPhrase("SELECT","BEN")+'</th>'
	html += '<th scope="col" class="plaintableheaderborder" style="width:100%;text-align:center">'+getSeaPhrase("PLAN_TYPE","BEN")+'</th></tr>'
	var match = false;
	for (var i=1; i<parent.EligPlanGroups.length; i++) 
	{
		match = false;
		for (var x=0; x<parent.errorPlans.length; x++)	
		{
			if (parent.EligPlanGroups[i][0] == parent.errorPlans[x]) 
			{
				match = true;
				break;
			}
		}
		if (!match && parent.errorGroups.length>0 && parent.verifyPlanGrps)	
		{
			for (var y=0; y<parent.errorGroups.length; y++) 
			{
				if (parent.EligPlanGroups[i][0] == parent.errorGroups[y]) 
				{
					match = true;
					break;
				}
			}
		}
		if (match) 
		{
			html += '<tr><td class="plaintablecellborder" style="text-align:center" nowrap><input class="inputbox" type="checkbox" id="C'+i+'" name="C'+i+'" checked onclick="this.checked=true;styleElement(this);"></td>'
			html += '<td class="plaintablecellborder" nowrap><label id="C'+i+'Lbl" for="C'+i+'"><span class="offscreen">'+getSeaPhrase("PLAN_TYPE","BEN")+'</span>&nbsp;'+parent.EligPlanGroups[i][0]+'</label></td></tr>'
		} 
		else 
		{
// MOD BY LARRY TAYLOR
			//html += '<tr><td class="plaintablecellborder" style="text-align:center" nowrap><input class="inputbox" type="checkbox" id="C'+i+'" name="C'+i+'" onclick="styleElement(this);"></td>'
			html += '<tr><td class="plaintablecellborder" style="text-align:center" nowrap><input class="inputbox" type="checkbox" id="C'+i+'" name="C'+i+'" onclick="fPlanGroupClicked('+i+');styleElement(this);"></td>'
// END OF MOD
			html += '<td class="plaintablecellborder" nowrap><label id="C'+i+'Lbl" for="C'+i+'"><span class="offscreen">'+getSeaPhrase("PLAN_TYPE","BEN")+'</span>&nbsp;'+parent.EligPlanGroups[i][0]+'</label></td></tr>'
		}
	}
	html += '</table><p class="textAlignRight">'  
// MOD BY BILAL
	//html += uiButton(getSeaPhrase("CONTINUE","BEN"),"checkarray();return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
	//html += uiButton(getSeaPhrase("PREVIOUS","BEN"),"no();return false","margin-right:5px;margin-top:10px")
	html += uiButton(getSeaPhrase("CONTINUE","BEN"),"checkarray();return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px;margin-right:0px;margin-left:0px")
	html += "&nbsp;&nbsp;"
	html += uiButton(getSeaPhrase("PREVIOUS","BEN"),"no();return false","margin-right:5px;margin-top:10px")
// END OF MOD
	html += '</p></form></div>'

	document.getElementById("paneBody").innerHTML = html;
	document.getElementById("paneHeader").innerHTML = getSeaPhrase("ENROLLMENT_CHANGE","BEN");
	stylePage();
	document.body.style.visibility = "visible";
	parent.stopProcessing(getSeaPhrase("CNT_UPD_FRM","SEA",[getWinTitle()]));
	parent.fitToScreen();
	var msg = "";
	if (parent.errorPlans.length>0 && (parent.errorGroups.length==0 || !parent.verifyPlanGrps)) 
	{
		msg = getSeaPhrase("CHGBEN_8","BEN");
		parent.seaAlert(msg, null, null, "alert");
	} 
	else if (parent.errorGroups.length>0 && parent.verifyPlanGrps && parent.errorPlans.length==0) 
	{
		msg = getSeaPhrase("CHGBEN_9","BEN");
		parent.seaAlert(msg, null, null, "alert");
	} 
	else if (parent.errorPlans.length>0 || (parent.errorGroups.length>0 && parent.verifyPlanGrps)) 
	{
		msg = getSeaPhrase("CHGBEN_10","BEN");
		parent.seaAlert(msg, null, null, "alert");
	}
}
// MOD BY LARRY TAYLOR
//------------------------------------------------------------------
// The following plan groups function as one unit.
// If one is checked then all are checked.
// If one is unchecked then all are unchecked.
//	MEDICAL
//	HEALTH SAVINGS ACCT
//	FLEX SPEND MEDICAL
//	FLEX SPEND LIMITED
//------------------------------------------------------------------

function fPlanGroupClicked(i)
{
	var vChecked = document.getElementsByName("C"+i)[0].checked;
	var vPlanGroup = parent.EligPlanGroups[i][0];
	if (vPlanGroup != parent.gMedicalPlanGroup
	&& vPlanGroup != parent.gMedSpendingPlanGroup
	&& vPlanGroup != parent.gFlexMedPlanGroup
	&& vPlanGroup != parent.gFlexLtdPlanGroup)
	{
		return true;
	}
	for (var j=1;j<parent.EligPlanGroups.length;j++)
	{
		vPlanGroup = parent.EligPlanGroups[j][0];
		if (vPlanGroup == parent.gMedicalPlanGroup
		|| vPlanGroup == parent.gMedSpendingPlanGroup
		|| vPlanGroup == parent.gFlexMedPlanGroup
		|| vPlanGroup == parent.gFlexLtdPlanGroup)
		{
//alert('besschange\nvPlanGroup='+vPlanGroup+'\nj='+j+'\nvChecked='+vChecked)
			document.getElementsByName("C"+j)[0].checked = vChecked;
		}
	}
}
// END OF MOD

function no()
{
	parent.document.getElementById("main").src = parent.baseurl+'bensummary.htm';
}
function checkarray()
{
	for (var i=1;i<parent.CurrentBens.length;i++) 
	{
		if (parent.CurrentBens[i])
			parent.CurrentBens[i][45] = false;
	}
	var temp = new Array();
	var tempdepbens = new Array();
	parent.status = "C";
	parent.changes = new Array();
	var pltype1;
	var plcode1;
	var pltype2;
	var plcode2;
	for (var x=0; x<parent.ElectedPlans.length; x++) 
	{
		if (parent.ElectedPlans[x][6])
			parent.ElectedPlans[x][6] = false;
		if (parseFloat(parent.ElectedPlans[x][0])>=2 && parseFloat(parent.ElectedPlans[x][0])<=5) 
		{
			pltype1 = parent.removespace(parent.ElectedPlans[x][2][37]);
			plcode1 = parent.removespace(parent.ElectedPlans[x][2][38]);
			for (var k=1; k<parent.EligPlans.length; k++) 
			{
				if (pltype1 == parent.removespace(parent.EligPlans[k][1]) && plcode1 == parent.removespace(parent.EligPlans[k][2])) 
				{
					parent.ElectedPlans[x][2][43]=parent.EligPlans[k][20];
					parent.ElectedPlans[x][2][44]=parent.EligPlans[k][21];
					parent.ElectedPlans[x][2][54]=parent.EligPlans[k][8];
				}
			}
		}
	}
// MOD BY BILAL - Prior Customization
	// JRZ Set up custom plangroup relationships for groups that should be changed together
	// relatePlans array key will be the plan, the value is an array that holds the plans you want to relate it with
	var relatePlans = new Array();
	// CGL 1/12/2011 - Removing tobacco declaration and tobacco plans
	//relatePlans["TOBACCO DECLARATION"] = new Array("MEDICAL");
	// ~CGL
	relatePlans["PAY IN LIEU OF BENEF"] = new Array("MEDICAL","DENTAL","VISION","EMPLOYEE SUPP LIFE","CHILD SUPP LIFE","SPOUSE SUPP LIFE","PTO SELLBACK OCTOBER","PTO SELLBACK APRIL");

// MOD BY LARRY TAYLOR
// If they come back in and change PILB then we route them thru HSA and the FLEX plans
	relatePlans["PAY IN LIEU OF BENEF"][relatePlans["PAY IN LIEU OF BENEF"].length] = parent.gMedSpendingPlanGroup;
	relatePlans["PAY IN LIEU OF BENEF"][relatePlans["PAY IN LIEU OF BENEF"].length] = parent.gFlexMedPlanGroup;
	relatePlans["PAY IN LIEU OF BENEF"][relatePlans["PAY IN LIEU OF BENEF"].length] = parent.gFlexLtdPlanGroup;
// END OF MOD

	// first check if the desired plan was checked
	var plansToFill = new Array();
	for(var r in relatePlans) {
		for(var i=1;i<parent.EligPlanGroups.length;i++) {
			if(r == parent.EligPlanGroups[i][0]) {
				// check the box for that plan group, the name of the input is "C" + i
				var desiredInputName = "C" + i;
				// inspect all of the checkboxes in the list
				for(var j=0;j<self.document.listform.length;j++) {
					// whichever one matches our plan name
				  if(self.document.listform.elements[j].name == desiredInputName) {
						// if the user has decided to make changes to that plan
						if(self.document.listform.elements[j].checked==true) {
							// store a list of plans to group with it using the relatePlans structure
							for(var rP=0;rP<relatePlans[r].length;rP++) {
								plansToFill[plansToFill.length] = relatePlans[r][rP];
							}
						}
					}
				}
			}
		}
	}

	// now select those related plans
	for(var p=0;p<plansToFill.length;p++) {
		for (var i=1;i<parent.EligPlanGroups.length;i++) {
			if(plansToFill[p] == parent.EligPlanGroups[i][0]) {
				// check the box for that plan group, the name of the input is "C" + i
				var desiredInputName = "C" + i;
				for(var j=0;j<self.document.listform.length;j++) {
				  if(self.document.listform.elements[j].name == desiredInputName) {
						self.document.listform.elements[j].checked=true;
					}
				}
			}
		}
	}
	//~JRZ
// END OF MOD
	for (var i=0; i<self.document.listform.length; i++)
	{
		if (self.document.listform.elements[i].checked == true)
		{
			for (var x=0; x<parent.ElectedPlans.length; x++)
			{
				//if this plan is in the group that is going to be changed
				if ((parseInt(parent.ElectedPlans[x][0],10)>=2 && parseInt(parent.ElectedPlans[x][0],10)<=5) &&parent.ElectedPlans[x][2][54]==parent.EligPlanGroups[i+1][0])
				{
					//find all other plans that are based on the plan that is going to be changed
					for (var k=0; k<parent.ElectedPlans.length; k++)
					{
						if (parent.ElectedPlans[k][2][43]==parent.ElectedPlans[x][2][37] && parent.ElectedPlans[k][2][44]==parent.ElectedPlans[x][2][38])
						{
							//automatically select the plan group with the plan that is based on the other plan that the employee is going to change
							// PT 149282. Do not count the two navigation buttons as checkbox form elements.
							for (var j=0; j<self.document.listform.length-2; j++)
							{
								var obj = eval('self.document.listform.elements[j]');
								if (obj.checked != true && parent.ElectedPlans[k][2][54] == parent.EligPlanGroups[j+1][0])
								{
									self.document.listform.elements[j].checked=true
									styleElement(self.document.listform.elements[j]);
									var msg = getSeaPhrase("CHGBEN_1","BEN")+" "+parent.ElectedPlans[x][2][54]+".  "
									+ getSeaPhrase("CHGBEN_2","BEN")+" "+parent.ElectedPlans[k][2][54]+" "+getSeaPhrase("CHGBEN_3","BEN")+" "+parent.ElectedPlans[x][2][54]+". "
									+ getSeaPhrase("CHGBEN_4","BEN")+" "+parent.ElectedPlans[k][2][54]+" "+getSeaPhrase("ERROR_CHOOSE_PLAN_5","BEN");
									parent.seaAlert(msg, null, null, "alert");
									// set i to 0 to start at the begining of the list in case the plan group selected comes before the current value of i and there are other plans
									// based on plans in the group just marked to be changed
									i = 0;
								}
							}
						}
					}
				}
			}
		}
	}
	// Go through all eligible plan groups and remove those the user has checked to change from the current ElectedPlans array.
	for (var i=0; i<self.document.listform.length; i++)
	{
		if (self.document.listform.elements[i].checked == true)
		{
			flag = 1;
			parent.changes[parent.changes.length]=self.document.listform.elements[i].name.substring(1,self.document.listform.elements[i].name.length);
		}
		else
		{
			try 
			{
				for (var j=0; j<parent.ElectedPlans.length; j++)
				{
					if (parent.removespace(parent.ElectedPlans[j][3]) == parent.removespace(parent.EligPlanGroups[i+1][0]))
					{
						temp[temp.length] = new Array();
						temp[temp.length-1] = parent.ElectedPlans[j];
						tempdepbens[tempdepbens.length] = new Array();
						tempdepbens[tempdepbens.length-1] = parent.DependentBens[j];
					}
				}
			}
			catch(e) {}
		}
	}
	parent.ElectedPlans = new Array();
	parent.ElectedPlans = temp;
	parent.DependentBens = new Array();
	parent.DependentBens = tempdepbens;
	parent.currentChange = 0;
	parent.CurrentPlanGroup = parent.changes[parent.currentChange];
	if (flag != 0)
	{
		for (var i=1; i<parent.EligPlans.length; i++)
			parent.selectedPlanInGrp[i] = false;
		parent.errorPlans = new Array();
		parent.errorGroups = new Array();
		for (var i=1; i<parent.CurrentBens.length; i++)
		{
			if (parent.CurrentBens[i] != null)
			{
				if (parent.CurrentBens[i][32] == parent.EligPlanGroups[parent.CurrentPlanGroup][0])
				{
					parent.planname = i;
					break;
				}
			}
		}
		if (parent.CurrentBens[parent.planname] != null)
		{
			if (parent.CurrentBens[parent.planname][32] == parent.EligPlanGroups[parent.CurrentPlanGroup][0])
				parent.document.getElementById("main").src = parent.baseurl+"disp_benefits.htm";
			else
				parent.document.getElementById("main").src = parent.baseurl+"availplans.htm";
		}
		else
			parent.document.getElementById("main").src = parent.baseurl+"availplans.htm";
	}
	else
		parent.seaAlert(getSeaPhrase("CHGBEN_5","BEN"), null, null, "error");
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
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/besschange.htm,v 1.17.2.36 2014/02/25 22:49:14 brentd Exp $ -->
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