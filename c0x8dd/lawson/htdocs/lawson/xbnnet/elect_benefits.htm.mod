<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<title>Benefit Plan Details</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script>
var _Processed = true;
var flexflag = 0;
var empflag = 0;
var compflag = 0;
var REC_TYPE = parent.EligPlans[parent.CurrentEligPlan][6];
parent.choice = 0;
parent.SelectedPlan = new Array();
parent.EMP_CONT_TYPE = '';
function initElectScreen()
{
	stylePage();
	setWinTitle(getSeaPhrase("PLAN_DETAILS","BEN"));
	parent.startProcessing(getSeaPhrase("PROCESSING_WAIT","ESS"), setdata);	
}
function setdata()
{
	if (REC_TYPE+"".length < 2)
		REC_TYPE = "0"+REC_TYPE;
	if (REC_TYPE == "01")
	{
		parent.lawheader.count = 0;
		updatetype = "CRT";
		parent.updatetype = "CRT";
		var object1 = new AGSObject(parent.prodline, "BS13.1");
		object1.event = "ADD";
		object1.rtn = "DATA";
		object1.debug = false;
		object1.longNames = true;
		object1.tds = false;
		object1.field = "FC=I"
		+ "&COP-COMPANY=" + escape(parent.company)
		+ "&EMP-EMPLOYEE=" + escape(parent.employee)
		+ "&COP-PLAN-TYPE=" + escape(parent.EligPlans[parent.CurrentEligPlan][1],1).toString().replace("+","%2B")
		+ "&COP-PLAN-CODE=" + escape(parent.EligPlans[parent.CurrentEligPlan][2],1).toString().replace("+","%2B");
		if (parent.rule_type == "N")
			object1.field += "&BAE-NEW-DATE=" + escape(parent.EligPlans[parent.CurrentEligPlan][5]);
		else
		 	object1.field += "&BAE-NEW-DATE=" + escape(parent.BenefitRules[2]);
		object1.field += "&BAE-COST-DIVISOR=" + escape(parent.BenefitRules[6])
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
		object1.debug = false;
		object1.field = "FC=I"
		+ "&CVR-COMPANY=" + escape(parent.company)
		+ "&EMP-EMPLOYEE=" + escape(parent.employee)
		+ "&CVR-PLAN-TYPE=" + escape(parent.EligPlans[parent.CurrentEligPlan][1],1).toString().replace("+","%2B")
		+ "&CVR-PLAN-CODE=" + escape(parent.EligPlans[parent.CurrentEligPlan][2],1).toString().replace("+","%2B");
		if (parent.rule_type == "N")
		  	object1.field += "&BAE-NEW-DATE=" + escape((parent.EligPlans[parent.CurrentEligPlan][5]));
		else
		  	object1.field += "&BAE-NEW-DATE=" + escape(parent.BenefitRules[2]);
		object1.field += "&BAE-COST-DIVISOR=" + escape(parent.BenefitRules[6])
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
		object1.debug = false;
		object1.tds = false;
		object1.field = "FC=I"
		+ "&PRE-COMPANY=" + escape(parent.company)
		+ "&EMP-EMPLOYEE=" + escape(parent.employee)
		+ "&PRE-PLAN-TYPE=" + escape(parent.EligPlans[parent.CurrentEligPlan][1],1).toString().replace("+","%2B")
		+ "&PRE-PLAN-CODE=" + escape(parent.EligPlans[parent.CurrentEligPlan][2],1).toString().replace("+","%2B");
		if (parent.rule_type == "N")
		  	object1.field += "&BAE-NEW-DATE=" + escape((parent.EligPlans[parent.CurrentEligPlan][5]));
		else if (parent.rule_type == "F")
		{
			if (parent.actiontaken == 1)
				object1.field += "&BAE-NEW-DATE=" + escape(parent.EligPlans[parent.CurrentEligPlan][11]);
			else if (parent.actiontaken == 2 || parent.actiontaken == 4 || parent.actiontaken == 5)
				object1.field += "&BAE-NEW-DATE=" + escape(parent.EligPlans[parent.CurrentEligPlan][13]);
			else if (parent.actiontaken == 3)
				object1.field += "&BAE-NEW-DATE=" + escape(parent.EligPlans[parent.CurrentEligPlan][15]);
			else	
				object1.field += "&BAE-NEW-DATE=" + escape(parent.BenefitRules[2]);
		}
		else
		  	object1.field += "&BAE-NEW-DATE=" + escape(parent.BenefitRules[2]);
		object1.field += "&BAE-COST-DIVISOR=" + escape(parent.BenefitRules[6])
		+ "&BAE-RULE-TYPE=" + parent.rule_type
		+ "&BFS-FAMILY-STATUS=" + escape(parent.eventname.toUpperCase());
		object1.func = "parent.getdep()";
		AGS(object1,"js1");
	}
	else if (REC_TYPE=="12") 
	{
		parent.coveredDeps = new Array();
		parent.updatetype = "CRT3";
		parent.msgNbr = 99;
		parent.SelectedPlan = new Array();
		parent.SelectedPlan[0] = 12;
		parent.SelectedPlan[1] = parent.EligPlans[parent.CurrentEligPlan][1];
		parent.SelectedPlan[2] = parent.EligPlans[parent.CurrentEligPlan][2];
		parent.SelectedPlan[65] = parent.EligPlans[parent.CurrentEligPlan][28];
		parent.document.getElementById("main").src = parent.baseurl+"bensconfirm.htm";
	}
	else
		parent.stopProcessing();
}
function getdep()
{
	parent.coveredDeps = new Array();
	goform();
}
function goform()
{
	if (_Processed) 
	{
		_Processed = false;
		if (REC_TYPE == "01")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_01.htm";
		else if (REC_TYPE == "02")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_02.htm";
		else if (REC_TYPE == "03" || REC_TYPE == "13")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_03.htm";
		else if (REC_TYPE == "04")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_04.htm";
		else if (REC_TYPE == "05")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_05.htm";
		else if (REC_TYPE == "06")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_06.htm";
		else if (REC_TYPE == "07")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_07.htm";
		else if (REC_TYPE == "08")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_08.htm";
		else if (REC_TYPE == "09")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_09.htm";
		else if (REC_TYPE == "10")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_10.htm";
		else if (REC_TYPE == "12")
			self.document.getElementById("elect").src = "/lawson/xbnnet/elect_ben_12.htm";
		else
			parent.stopProcessing();
		fitToScreen();	
	}
	else
		parent.stopProcessing();
}
function header(addlStr)
{
	var titleLbl = parent.EligPlans[parent.CurrentEligPlan][4]+' - '+getSeaPhrase("VIEW_PLAN_DESC","BEN")+' '+getSeaPhrase("OPENS_WIN","SEA");
	var nme = parent.removespace(parent.EligPlans[parent.CurrentEligPlan][1]+parent.EligPlans[parent.CurrentEligPlan][2])
	var html = '<br/><table border="0" cellpadding="0" cellspacing="0" style="width:100%;margin-left:auto;margin-right:auto" role="presentation">'
	html += '<tr><td class="plaintablecell" style="padding-top:5px">'+getSeaPhrase("CONBEN_2","BEN")+' '
	html += '<a href="javascript:;" onclick="javascript:var winRef=(typeof(parent.parent.openWinDesc2)==\'function\')?parent.parent:parent.parent.parent;winRef.openWinDesc2(\''+parent.EligPlans[parent.CurrentEligPlan][1]+'\',\''+parent.EligPlans[parent.CurrentEligPlan][2]+'\');return false" title="'+titleLbl+'" aria-haspopup="true">'
// MOD BY BILAL 
//	html += parent.EligPlans[parent.CurrentEligPlan][4]+'<span class="offscreen"> - '+titleLbl+'</span>View Description</a>.'
	html += '<font color=red><b>' + parent.EligPlans[parent.CurrentEligPlan][4] + '</b></font> <span class="offscreen"> - '+titleLbl+'</span></a>.'
// END OF MOD	
	html += ((addlStr)?' '+addlStr:'')
	html += '</td></tr></table><br/>'
	return html;
}
function planMessages(precont,defaul)
{
	var msgStr = "";
	if ((parent.updatetype == "CRT2" && !isNaN(parseFloat(parent.SelectedPlan[18])) && parseFloat(parent.SelectedPlan[18]) > 0)
	|| (parent.updatetype == "CRT3" && !isNaN(parseFloat(parent.SelectedPlan[16])) && parseFloat(parent.SelectedPlan[16]) > 0)
	|| (parent.updatetype == "CRT")) 
	{
		if (precont=="P" || precont=="N" || precont=="A") 
		{
			if ((parent.updatetype == "CRT" && (flexflag != 0 || empflag != 0 || compflag != 0)) || parent.updatetype != "CRT") 
			{
				if (precont == "P")
					msgStr += getSeaPhrase("ELECTBEN_3","BEN")+' ';
				else if (precont == "A")
					msgStr += getSeaPhrase("ELECTBEN_4","BEN")+' ';
			}
			if (precont == "N")
				msgStr += getSeaPhrase("ELECTBEN_7","BEN")+' ';
		}
	} 
	else
		msgStr += getSeaPhrase("ELECTBEN_7","BEN")+' ';
	if (REC_TYPE != "08" && REC_TYPE != "09" && REC_TYPE != "06") 
	{
		if (flexflag != 0 || empflag != 0 || compflag != 0)
			msgStr += parent.costdivisor;
	}
	return msgStr;
}
function footer(precont, defaul)
{
	var html = '<div>'
	if ((parent.updatetype == "CRT2" && !isNaN(parseFloat(parent.SelectedPlan[18])) && parseFloat(parent.SelectedPlan[18]) > 0)
	|| (parent.updatetype == "CRT3" && !isNaN(parseFloat(parent.SelectedPlan[16])) && parseFloat(parent.SelectedPlan[16]) > 0)
	|| (parent.updatetype == "CRT")) 
	{
// JRZ 1/27/09 Adding note that new coverage options for 2009 always cover self
// CLYNCH 2/14/2012 - Modify to not display coverage options text for Child Supp Life
		if (parent.EligPlans[parent.CurrentEligPlan][8]!="CHILD SUPP LIFE") {
			html+='<p style="color:#ff0000;font-weight:bold">Please note: All coverage options provide Self coverage, too</p>'
		}
// ~CLYNCH
//~JRZ
		//GDD  01/22/15    Add text for PILB election
		if (parent.EligPlans[parent.CurrentEligPlan][2] == parent.gPilbPlan) {
			html += '<div id="pilbwording" style="text-align:left"><br><br><P>Pay in Lieu of Benefits plan (PILB) is an OPTIONAL benefit election and is designed to allow benefits eligible employees who have health insurance coverage under a non-St. Luke\'s health plan to elect a higher rate of pay in lieu of certain benefits.</P>';
			html += '<p>To see which benefits you will be forfeiting, click the plan name above.</p>';
			html += '<p> If you elect PILB in any pay period following your date of hire, your benefit will be effective in the pay period in which you make your election.</p></div>';
		}
		//GDD  end of change
		if (precont == "P" || precont == "N" || precont == "A") 
		{
			if ((parent.updatetype == "CRT" && (flexflag != 0 || empflag != 0 || compflag != 0)) || parent.updatetype != "CRT") 
			{
				if (precont == "P")
					parent.setpreaft_flag("P");
				else if (precont == "A")
					parent.setpreaft_flag("A");
			}
			if (precont == "N")
				parent.setpreaft_flag("");
		} 
		else if (precont != null && precont != '' && typeof(precont) != 'undefined') 
		{
			html += '<form name="preaft"><div role="radiogroup" aria-labelledby="howLbl">'
			if (defaul == "P")	
			{
				parent.setpreaft_flag("P");
				html += '<span id="howLbl">'+getSeaPhrase("ELECTBEN_6","BEN")+'</span> '
				html += '<input class="inputbox" type="radio" id="pretax" name="preaft" value="pre" onclick="parent.parent.setpreaft_flag(\'P\');styleElement(this);" checked><label for="pretax" class="plaintablecell">'+getSeaPhrase("PRE_TAX","BEN")+'</label>'
				html += '<input class="inputbox" type="radio" id="afttax" name="preaft" value="aft" onclick="parent.parent.setpreaft_flag(\'A\');styleElement(this);"><label for="afttax" class="plaintablecell">'+getSeaPhrase("AFTER_TAX","BEN")+'</label>'
			} 
			else if (defaul=="A") 
			{
				parent.setpreaft_flag("A");
				html += '<span id="howLbl">'+getSeaPhrase("ELECTBEN_6","BEN")+'</span> '
				html += '<input class="inputbox" type="radio" id="pretax" name="preaft" value="pre" onclick="parent.parent.setpreaft_flag(\'P\');styleElement(this);"><label for="pretax" class="plaintablecell">'+getSeaPhrase("PRE_TAX","BEN")+'</label>'
				html += '<input class="inputbox" type="radio" id="afttax" name="preaft" value="aft" onclick="parent.parent.setpreaft_flag(\'A\');styleElement(this);" checked><label for="afttax" class="plaintablecell">'+getSeaPhrase("AFTER_TAX","BEN")+'</label>'
			} 
			else 
			{
				parent.setpreaft_flag("");
				html += '<span id="howLbl">'+getSeaPhrase("ELECTBEN_6","BEN")+'</span> '
				html += '<input class="inputbox" type="radio" id="pretax" name="preaft" value="pre" onclick="parent.parent.setpreaft_flag(\'P\');styleElement(this);"><label for="pretax" class="plaintablecell">'+getSeaPhrase("PRE_TAX","BEN")+'</label>'
				html += '<input class="inputbox" type="radio" id="afttax" name="preaft" value="aft" onclick="parent.parent.setpreaft_flag(\'A\');styleElement(this);"><label for="afttax" class="plaintablecell">'+getSeaPhrase("AFTER_TAX","BEN")+'</label>'
			}
			html += '</div></form>'
		}
	} 
	else
		parent.setpreaft_flag("");	
// MOD BY BILAL  - Prior Customizations
// JRZ Modify Cost for Air St. Lukes to say per year
        var currentCode = escape(parent.EligPlans[parent.CurrentEligPlan][2],1);
        if(REC_TYPE!="08" && REC_TYPE!="09" && REC_TYPE!="06")
        {
            if(flexflag!=0 || empflag!=0 || compflag!=0) 
            {
	                if(parent.SLRMC.isASL(parent.company,currentCode)) 
	                {
			               html+='<BR><BR>Costs are per year, taken as a one time paycheck deduction.';
					}
//					else 
//					{
//					       html+='<BR><BR>'+parent.costdivisor
//			        }
            }
        }
//~JRZ
// END OF MOD
	html += '<br>'
// MOD BY BILAL - Styling the Buttons as per St. Luke's
	html += '<p class="textAlignRight">'
//	html += uiButton(getSeaPhrase("CONTINUE","BEN"), "parent.setBenefit('"+precont+"');return false","margin-right:5px;margin-top:10px")
	html += uiButton(getSeaPhrase("CONTINUE","BEN"), "parent.setBenefit('"+precont+"');return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")

	if (parent.LastDoc[parent.currentdoc]!=null)
		html += "&nbsp;&nbsp;" + uiButton(getSeaPhrase("PREVIOUS","BEN"), "parent.previousTask();return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px")
		//html += uiButton(getSeaPhrase("PREVIOUS","BEN"), "parent.previousTask();return false","margin-right:5px;margin-top:10px")
// 	html += uiButton(getSeaPhrase("EXIT","BEN"), "parent.parent.quitEnroll(parent.location);return false","margin-right:5px;margin-top:10px",null,'aria-haspopup="true"')
	html += "&nbsp;&nbsp;" + uiButton(getSeaPhrase("EXIT","BEN"), "parent.parent.quitEnroll(parent.location);return false","font-size:14px;font-weight:bold;color:#FFFFFF;width:100;background-color:#6699cc;margin-top:10px",null,'aria-haspopup="true"')
// JRZ Elect Benefits wording, appears after selecting a plan code and clicking continue
    if(REC_TYPE=="01" || REC_TYPE=="03") 
    {
        // elements will be searched for at the beginning of the plan code
    	var matchDependent = parent.SLRMC.isDependentElectPlan(parent.company,currentCode);
        // JRZ Adding EPO requirements reminder for EPO plan
	      if(parent.SLRMC.isEPOPlan(parent.company,currentCode))
	           html+= parent.SLRMC.EPOReminder(parent.parent.rule_type);

        // JRZ Adding dependent reminder
	//  GDD  01/12/15  Add plan type to function
	      if(matchDependent)
			    html+=parent.SLRMC.DependentReminder(parent.parent.rule_type,parent.EligPlans[parent.CurrentEligPlan][1])

        // JRZ Adding in Dual discount information
            if(parent.SLRMC.isDualDiscountPlan(parent.company,currentCode))
		        html+=parent.SLRMC.DualDiscountReminder();

        // JRZ Adding in ASL reminder
             if(parent.SLRMC.isASL(parent.company,currentCode))
		         html+=parent.SLRMC.ASLReminder(parent.parent.rule_type);

    }

       if(parent.SLRMC.isMonthlyDeductionPlan(parent.company,currentCode))
//	             html+='<p>Deductions are taken once per month rather than every pay period.  However, the above deduction is a per pay period amount.<br>Your monthly deduction for child supp life coverage will be:<br>&nbsp;&nbsp;&nbsp;$0.30 per month for $5,000 of coverage<br>&nbsp;&nbsp;&nbsp;$0.61 per month for $10,000 of coverage</p>'
	             html+='<p></p>'
        //~JRZ
	html+='</center>'
// END OF MOD
	html += '</p></div>'
	return html;
}
function setBenefit(precont,continueFlag)
{
	parent.cantEnroll = new Array();
	parent.notAvailable = new Array();
	if (REC_TYPE != "01" && typeof(self.elect.document.forms['preaft']) != 'undefined' && self.elect.document.forms["preaft"].preaft[0].checked == false 
	&& self.elect.document.forms["preaft"].preaft[1].checked == false)
		parent.seaAlert(getSeaPhrase("ERROR_91","BEN"), null, null, "error");
	else if ((REC_TYPE == "01" || REC_TYPE == "03" || REC_TYPE == "13") && parent.choice == 0 && (continueFlag || (!precont || (precont && precont != "N"))))
		parent.seaAlert(getSeaPhrase("ERROR_92","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "B" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& (parent.spouseExists == false && parent.depsExist == false))
		parent.seaAlert(getSeaPhrase("ERROR_101","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "S" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.spouseExists == false)
		parent.seaAlert(getSeaPhrase("ERROR_102","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "D" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.depsExist == false)
		parent.seaAlert(getSeaPhrase("ERROR_103","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "P" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.domParterExists == false)
		parent.seaAlert(getSeaPhrase("ERROR_126","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "O" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& (parent.spouseExists == false && parent.domParterExists == false))
		parent.seaAlert(getSeaPhrase("ERROR_127","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "R" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.depsExist == false)
		parent.seaAlert(getSeaPhrase("ERROR_128","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "C" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" 
	&& (parent.depsExist == false && parent.domParterExists == false))		
		parent.seaAlert(getSeaPhrase("ERROR_129","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' == "A" &&
	parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.dependents.length == 0)		
		parent.seaAlert(getSeaPhrase("ERROR_130","BEN"), null, null, "error");
	else if (REC_TYPE == "01" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && !isNaN(parseFloat(parent.SelectedPlan[parent.choice][19])) 
	&& parseFloat(parent.SelectedPlan[parent.choice][19]) > 0 && parent.dependents.length < parseFloat(parent.SelectedPlan[parent.choice][19]))
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
		parent.seaAlert(getSeaPhrase("ERROR_104","BEN"), null, null, "error")
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "D" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.depsExist == false)
		parent.seaAlert(getSeaPhrase("ERROR_105","BEN"), null, null, "error")
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "B" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && (parent.depsExist == false && parent.spouseExists == false))
		parent.seaAlert(getSeaPhrase("ERROR_106","BEN"), null, null, "error")
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") && parent.SelectedPlan[4]+'' == "P" 
	&& parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.domParterExists == false)
		parent.seaAlert(getSeaPhrase("ERROR_131","BEN"), null, null, "error")
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") && parent.SelectedPlan[4]+'' == "O" 
	&& parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && (parent.spouseExists == false && parent.domParterExists == false))
		parent.seaAlert(getSeaPhrase("ERROR_132","BEN"), null, null, "error")
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") && parent.SelectedPlan[4]+'' == "R" 
	&& parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.depsExist == false)
		parent.seaAlert(getSeaPhrase("ERROR_133","BEN"), null, null, "error")
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") && parent.SelectedPlan[4]+'' == "C" 
	&& parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && (parent.depsExist == false && parent.domParterExists == false))
		parent.seaAlert(getSeaPhrase("ERROR_134","BEN"), null, null, "error")
	else if ((REC_TYPE == "02" || REC_TYPE == "03" || REC_TYPE == "04" || REC_TYPE == "05" || REC_TYPE == "13") 
	&& parent.SelectedPlan[4]+'' == "A" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.dependents.length == 0)
		parent.seaAlert(getSeaPhrase("ERROR_135","BEN"), null, null, "error")		
	else 
	{
		if (REC_TYPE == "01" || REC_TYPE == "03" || REC_TYPE == "13") 
		{
			if (REC_TYPE == "01") 
			{
				if (!isNaN(parseFloat(parent.SelectedPlan[parent.choice][5]))) 
				{
					if (typeof(self.elect.document.forms['preaft']) != 'undefined' && self.elect.document.forms["preaft"].preaft[0].checked == false && self.elect.document.forms["preaft"].preaft[1].checked == false) 
					{
						parent.seaAlert(getSeaPhrase("ERROR_91","BEN"), null, null, "error");
						return;
					}
				} 
				else
					parent.setpreaft_flag("");
			}
			parent.msgNbr = 1;
			parent.currentdoc++;
			if (parent.currentdoc < parent.LastDoc.length) 
			{
				var ArrayTemp = parent.LastDoc;
				parent.LastDoc = new Array(0);
				for (var i=0; i<=parent.currentdoc+1; i++)
					parent.LastDoc[i] = ArrayTemp[i];
			}
			parent.LastDoc[parent.currentdoc] = parent.baseurl+"elect_benefits.htm";
			if (REC_TYPE == "01" && parent.SelectedPlan[parent.choice][16]+'' != "N" && parent.SelectedPlan[parent.choice][16]+'' != "E" && parent.EligPlans[parent.CurrentEligPlan][18] == "Y" && parent.dependents.length > 0)
				parent.document.getElementById("main").src = parent.baseurl+"depscr.htm";
			else if (REC_TYPE != "01" && parent.SelectedPlan[55]+'' == "Y" && parent.dependents.length > 0)
				parent.document.getElementById("main").src = parent.baseurl+"depscr.htm";
			else
				parent.document.getElementById("main").src = parent.baseurl+"bensconfirm.htm";
		} 
		else 
		{
			parent.msgNbr = 1;
			parent.currentdoc++;
			if (parent.currentdoc < parent.LastDoc.length) 
			{
				var ArrayTemp = parent.LastDoc;
				parent.LastDoc = new Array(0);
				for(var i=0; i<=parent.currentdoc+1;i++)
					parent.LastDoc[i] = ArrayTemp[i];
			}
			parent.LastDoc[parent.currentdoc] = parent.baseurl+"elect_benefits.htm";
			if (parent.SelectedPlan[55]+'' == "Y" && (parseFloat(REC_TYPE) < 6 || parseFloat(REC_TYPE) == 13) && parent.dependents.length > 0)
				parent.document.getElementById("main").src = parent.baseurl+"depscr.htm";
			else
 				parent.document.getElementById("main").src = parent.baseurl+"bensconfirm.htm";
		}
	}
}
function previousTask()
{
	parent.document.getElementById("main").src = parent.LastDoc[parent.currentdoc];
	parent.currentdoc--;
}
function Choice(num, doc, max)
{
 	parent.choice = num;
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
	var electFrame = document.getElementById("elect");
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
		contentHeight = winHeight - 60;
		contentHeightBorder = contentHeight + 24;	
	}
	electFrame.style.width = winWidth + "px";
	electFrame.style.height = winHeight + "px";
	try
	{
		if (self.elect.onresize && self.elect.onresize.toString().indexOf("setLayerSizes") >= 0)
			self.elect.onresize = null;		
	}
	catch(e) {}
	try
	{
		self.elect.document.getElementById("paneBorder").style.width = contentWidthBorder + "px";
		self.elect.document.getElementById("paneBodyBorder").style.width = contentWidth + "px";
		self.elect.document.getElementById("paneBorder").style.height = contentHeightBorder + "px";
		self.elect.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.elect.document.getElementById("paneBody").style.width = contentWidth + "px";
		self.elect.document.getElementById("paneBody").style.height = contentHeight + "px";
	}
	catch(e) {}
}
</script>
</head>
<body style="overflow:hidden" onload="initElectScreen();fitToScreen()" onresize="fitToScreen()">
	<iframe id="elect" name="elect" title="Main Content" level="2" tabindex="0" src="/lawson/xhrnet/ui/headerpane.htm" style="visibility:visible;position:absolute;top:0px;left:0px;width:721px;height:464px" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	<iframe name="js1" title="Empty" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;height:0px;width:0px;"></iframe>
	<iframe name="lawheader" title="Empty" src="/lawson/xbnnet/besslawheader.htm" style="visibility:hidden;height:0px;width:0px;"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/elect_benefits.htm,v 1.26.2.71.2.1 2014/03/07 21:02:36 brentd Exp $ -->
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