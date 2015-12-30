<!--
// CLYNCH 09/01/2011 Customizations for display of employee information on manager employee profile view.  Removed the following
//                   fields from display: work schedule, union flag, work phone extension, work phone country code, home phone 
//                   country code, next review date, next review type, pay rate, shift.  Added display of total FTE. 
-->
<html>
<head>
<title>Job Profile</title>
<meta name="viewport" content="width=device-width" />
<META HTTP-EQUIV="Pragma" CONTENT="No-Cache">
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script>
var fromTask = (window.location.search)?unescape(window.location.search):"";
var recs = new Array();
var empnbr = "";
var empname = "";
var pgmname = "";

if (fromTask) {
	pgmname = getVarFromString("from",fromTask);
	empname = getVarFromString("name",fromTask);
	empnbr = getVarFromString("number",fromTask);
	fromTask = (pgmname != "") ? fromTask : "";
}

function GetWebuser()
{
	authenticate("frameNm='FRAME1'|funcNm='GetEmployee()'|desiredEdit='EM'");
}

function GetEmployee()
{
	// Adjust the frame height for Netscape
	setLayerSizes();
	if (fromTask) {
		parent.document.getElementById(window.name).style.visibility = "visible";
		parent.showWaitAlert(getSeaPhrase("WAIT","ESS"));
	}
	document.title = getSeaPhrase("JOB_PROFILE_1","ESS");

	emp = authUser.employee;
	sub_emp_name = "";

	if (empnbr != "" && typeof(empnbr) != "undefined" && empnbr != null)
	{
		emp = empnbr;
		sub_emp_name = unescape(empname);
	}

	var dmeObj = new DMEObject(authUser.prodline, "employee");
	dmeObj.out = "JAVASCRIPT";
	dmeObj.prod = authUser.prodline;
	dmeObj.field = "process-level.name;hm-acct-unit;department.name;"
		+"location.description;supervisor.description;employee;"
		+"job-code.description;paemployee.wk-phone-ext;paemployee.wk-phone-nbr;"
		+"email-address;date-hired;pay-rate;paemployee.hm-phone-nbr;"
		+"paemployee.next-review;paemployee.next-rev-code;adj-hire-date;"
		+"position;position.effect-date;position.description;union.description;schedule;pay-step;pay-grade;"
		+"paemployee.wk-phone-cntry;paemployee.hm-phone-cntry;"
		// CLYNCH 09/01/2011 - Adding fte_total to query
		+"fte-total"
		//~CLYNCH

	if (pgmname == "directreports")
 	{
		dmeObj.field += ";emp-status.description;annivers-date;paemployee.senior-date;shift,xlt;work-sched.description";
	}

	// Filter the related position records so that we get the description for the employee's current
	// position based on the system date.  The 9.0 Data servlet can do this for us.
	if (iosHandler && iosHandler.getIOSVersionNumber() >= "8.1")
	{
		dmeObj.select = "position.effect-date<=" + authUser.date;
	}

	dmeObj.max = "1";
	dmeObj.otmmax = "1";
	dmeObj.exclude = "drill;keys;sorts";
	dmeObj.key = parseInt(authUser.company,10) +"="+ parseInt(emp,10);
	dmeObj.func	= "CheckPayRate()";
	DME(dmeObj,"FRAME1");
}

function CheckPayRate()
{
	if (self.FRAME1.NbrRecs)
	{
		recs = self.FRAME1.record;
		if ((NonSpace(recs[0].pay_rate) == 0 || recs[0].pay_rate==0) && NonSpace(recs[0].pay_step) != 0)
		{
				var dmeObj 		= new DMEObject(authUser.prodline, "prsagdtl");
				dmeObj.out 		= "JAVASCRIPT";
				dmeObj.index	= "sgdset3";
				dmeObj.prod 	= authUser.prodline;
				dmeObj.field 	= "pay-rate";
				dmeObj.select 	= "effect-date<=" + authUser.date
				dmeObj.key 		= parseInt(authUser.company,10) +"="+ escape(recs[0].schedule,1)
								+ "=" + escape(recs[0].pay_grade,1) +"="+ escape(recs[0].pay_step,1);
				dmeObj.max      = "1";
				dmeObj.func		= "DspPrsagdtl()";
				DME(dmeObj,"FRAME1");
				return;
		}
	}
	CheckPosition();
}

function DspPrsagdtl()
{
	if (self.FRAME1.NbrRecs && recs.length > 0)
	{
		recs[0].pay_rate = self.FRAME1.record[0].pay_rate;
	}
	CheckPosition();
}

function CheckPosition()
{
	if (recs.length > 0)
	{
		// If the position record we found has a future effective date, filter the position records for the employee's current position code
		// so that we get the description for the employee's current position based on the system date.  This is a work-around for a 8.0.3
		// DME limitation where not every of the one-to-many related PAPOSITION records is searched in the above DME to the EMPLOYEE file.
		if (NonSpace(recs[0].position_effect_date) > 0 && formjsDate(recs[0].position_effect_date) > authUser.date)
		{
				var dmeObj 		= new DMEObject(authUser.prodline, "paposition")
				dmeObj.out 		= "JAVASCRIPT"
				dmeObj.index	= "posset2"
				dmeObj.prod 	= authUser.prodline
				dmeObj.field 	= "description"
				dmeObj.key 		= parseInt(authUser.company,10) +"="+ escape(recs[0].position,1)
				dmeObj.select	= "effect-date<=" + authUser.date
				dmeObj.max      = "1";
				dmeObj.func		= "DspPaposition()";
				DME(dmeObj,"FRAME1")
				return;
		}
	}
	CheckAcctUnit();
}

function DspPaposition()
{
	if(self.FRAME1.NbrRecs)
	{
		recs[0].position_description = self.FRAME1.record[0].description;
	}
	CheckAcctUnit();
}

function CheckAcctUnit()
{
	if (recs.length > 0)
	{
		if (NonSpace(recs[0].hm_acct_unit) > 0)
		{
				var dmeObj 		= new DMEObject(authUser.prodline, "glnames");
				dmeObj.out 		= "JAVASCRIPT";
				dmeObj.index	= "glnset1";
				dmeObj.prod 	= authUser.prodline;
				dmeObj.field 	= "description";
				dmeObj.key 		= parseInt(authUser.company,10) +"="+ escape(recs[0].hm_acct_unit,1);
				dmeObj.max      = "1";
				dmeObj.func		= "DspGlnames()";
				DME(dmeObj,"FRAME1");
				return;
		}
	}
	DspEmployee();
}

function DspGlnames()
{
	if(self.FRAME1.NbrRecs && recs.length > 0)
	{
		recs[0].hm_acct_unit = self.FRAME1.record[0].description;
	}
	DspEmployee();
}

function DspEmployee()
{
	var profileHtml = "";
	var profileHeading = "";

	if (NonSpace(sub_emp_name) != 0) {
		profileHeading = getSeaPhrase("JOB_PROFILE_FOR","ESS") + " " + sub_emp_name;
	}
	else {
		profileHeading = getSeaPhrase("PROFILE","ESS");
	}

  	if (recs.length == 0)
   	{
   	  	profileHtml = '<table class="plaintable" cellspacing="0" cellpadding="0" width="100%" '
   	  	+ 'summary="'+getSeaPhrase("JOB_PROFILE_SUMMARY","ESS")+'">'
       	+ '<tr align=left><td class="plaintableheader">'
       	+ getSeaPhrase("JOB_PROFILE_0","ESS")+'</td></tr></table>'

		self.MAIN.document.getElementById("paneHeader").innerHTML = profileHeading;
		self.MAIN.document.getElementById("paneBody").innerHTML = profileHtml;
		self.MAIN.stylePage();
   	}
	else
   	{
   		obj = recs[0];
   		var nextclass = "";
   		var profileHtml = '<table class="plaintableborder" cellspacing="0" cellpadding="0" width="100%" '
   		+ 'summary="'+getSeaPhrase("JOB_PROFILE_SUMMARY","ESS")+'">'

		//if (NonSpace(obj.employee) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_2","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.employee)>0)?obj.employee:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.process_level_name) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_3","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.process_level_name)>0)?obj.process_level_name:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.department_name) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_4","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.department_name)>0)?obj.department_name:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.hm_acct_unit) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_5","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.hm_acct_unit)>0)?obj.hm_acct_unit:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.location_description) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_6","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.location_description)>0)?obj.location_description:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.supervisor_description) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_7","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.supervisor_description)>0)?obj.supervisor_description:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.position_description) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_8","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.position_description)>0)?obj.position_description:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.job_code_description) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_9","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.job_code_description)>0)?obj.job_code_description:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		if (pgmname == "directreports")
		{
		//CLYNCH 09/01/2011 - Remove Work Schedule display from employee detail
		//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("WORK_SCHEDULE","ESS")
		//	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
		//	+ ((NonSpace(obj.work_sched_description)>0)?obj.work_sched_description:'&nbsp;')
		//	+ '</td></tr>'
		}	
		//if (NonSpace(obj.union_description) != 0)
		//{
		//CLYNCH 09/01/2011 - Remove Union display from employee detail
		//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_10","ESS")
		//	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
		//	+ ((NonSpace(obj.union_description)>0)?obj.union_description:'&nbsp;')
		//	+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.paemployee_wk_phone_nbr) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_11","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.paemployee_wk_phone_nbr)>0)?obj.paemployee_wk_phone_nbr:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.paemployee_wk_phone_ext) != 0)
		//{
		//CLYNCH 09/01/2011 - Remove Work Phone Extension display from employee detail
		//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("WORK_PHONE_EXTENSION","ESS")
		//	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
		//	+ ((NonSpace(obj.paemployee_wk_phone_ext)>0)?obj.paemployee_wk_phone_ext:'&nbsp;')
		//	+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.paemployee_wk_phone_cntry) != 0)
		//{
		//CLYNCH 09/01/2011 - Remove Work Phone Country Code display from employee detail
		//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("WORK_PHONE_CNTRY_CODE_ONLY","ESS")
		//	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
		//	+ ((NonSpace(obj.paemployee_wk_phone_cntry)>0)?obj.paemployee_wk_phone_cntry:'&nbsp;')
		//	+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.email_address) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_12","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.email_address)>0)?obj.email_address:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.paemployee_hm_phone_nbr) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_13","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.paemployee_hm_phone_nbr)>0)?obj.paemployee_hm_phone_nbr:'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.paemployee_hm_phone_cntry) != 0)
		//{
		//CLYNCH 09/01/2011 - Remove Home Phone Country Code display from employee detail
		//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("HOME_PHONE_CNTRY_CODE_ONLY","ESS")
		//	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
		//	+ ((NonSpace(obj.paemployee_hm_phone_cntry)>0)?obj.paemployee_hm_phone_cntry:'&nbsp;')
		//	+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.date_hired) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_14","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.date_hired)>0)?formatDME(obj.date_hired):'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.adj_hire_date) != 0)
		//{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_15","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.adj_hire_date)>0)?formatDME(obj.adj_hire_date):'&nbsp;')
			+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}

      	if (pgmname == "directreports")
      	{
			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("STATUS","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.emp_status_description)>0)?obj.emp_status_description:'&nbsp;')
			+ '</td></tr>'			
			// CLYNCH 09/01/2011 - Adding total FTE to employee profile display
			+ '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("FULL_TIME_EMPLOYEE","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.fte_total)>0)?obj.fte_total:'&nbsp;')
			+ '</td></tr>'
			//~CLYNCH			
			+ '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("ANNIVERSARY_DATE","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.annivers_date)>0)?obj.annivers_date:'&nbsp;')
			+ '</td></tr>'
			+ '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("SENIORITY_DATE","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			+ ((NonSpace(obj.paemployee_senior_date)>0)?obj.paemployee_senior_date:'&nbsp;')
			+ '</td></tr>'
			//PT164832
			if (formjsDate(obj.adj_hire_date) > ymdtoday)
			{
				years_served	=	"";
				months_served	=	"";
			}
			else
			{
				var date_diff = Math.abs(getDteDifference(ymdtoday,formjsDate(obj.adj_hire_date)))/365.2421896698;
	   			var date      = date_diff.toString().split(".");
	   			var years_served  = parseInt(date[0],10);
	   			var months_served = parseInt(parseFloat("."+date[1])*12,10);
			}
			//PT164832
	   		if (isNaN(years_served)) years_served = 0;
	   		if (isNaN(months_served)) months_served = 0;

			profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("LENGTH_OF_SERVICE","ESS")
			+ '<br/>'+getSeaPhrase("YEARS","ESS")+'<br/>'+getSeaPhrase("MONTHS","ESS")
			+ '</td><td class="plaintablecellborderdisplay" style="width:50%;vertical-align:bottom" nowrap>'

			if ((years_served > 0) || (months_served > 0))
			{
				if (years_served > 0)
					profileHtml += years_served;
				if (months_served > 0)
				{
					if (years_served > 0)
						profileHtml += '<br/>';
					profileHtml += months_served;
				}//PT 158339 changes added else
				else
					{
				profileHtml += '<br/>'+'&nbsp;'
				}
			}
			else
				profileHtml += '&nbsp;'
			profileHtml += '</td></tr>'
		}

		//if (NonSpace(obj.paemployee_next_review) != 0)
		//{
		//CLYNCH 09/01/2011 - Remove Next Review Date display from employee detail
		//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_16","ESS")
		//	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
		//	+ ((NonSpace(obj.paemployee_next_review)>0)?formatDME(obj.paemployee_next_review):'&nbsp;')
		//	+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		//if (NonSpace(obj.paemployee_next_rev_code) != 0)
		//{
		//CLYNCH 09/01/2011 - Remove Next Review Type display from employee detail
		//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("JOB_PROFILE_17","ESS")
		//	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
		//	+ ((NonSpace(obj.paemployee_next_rev_code)>0)?obj.paemployee_next_rev_code:'&nbsp;')
		//	+ '</td></tr>'
			//nextclass = toggleClass(nextclass);
		//}
		if (pgmname == "requisition")
		{
			profileHtml += '</table><table cellspacing="0" cellpadding="0" width="100%">'
			+ '<tr><td><form>'
			+ uiButton(getSeaPhrase("BACK","ESS"),"parent.window.close();return false")
			+ '</form></td></tr>'
		}
		else
		{	if (NonSpace(recs[0].pay_rate) != 0 && recs[0].pay_rate != 0)
			{
			//CLYNCH 09/01/2011 - Remove Pay Rate display from employee detail
			//	profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("PAY_RATE","ESS")
			//  	+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			//  	+ ((NonSpace(obj.pay_rate)>0)?obj.pay_rate:'&nbsp;')
			//	+ '</td></tr>'
			}
    	}

      	if (pgmname == "directreports")
      	{
			//CLYNCH 09/01/2011 - Remove Shift display from employee detail
			//profileHtml += '<tr'+nextclass+'><td class="plaintablerowheaderborder" style="text-align:right;width:50%">'+getSeaPhrase("SHIFT","ESS")
			//+ '</td><td class="plaintablecellborderdisplay" style="width:50%" nowrap>'
			//+ ((NonSpace(obj.shift_xlt)>0)?obj.shift_xlt:'&nbsp;')
			//+ '</td></tr>'
      	}

		profileHtml += '</table>'

		// 9790
		if (pgmname == "directreports") {
			profileHtml += '<p align="center">'
			profileHtml += uiButton(getSeaPhrase("BACK","ESS"),"parent.parent.backToMain('profile');return false")
			profileHtml += '</p>'
		}

		try {
			self.MAIN.document.getElementById("paneHeader").innerHTML = profileHeading;
			self.MAIN.document.getElementById("paneBody").innerHTML = profileHtml;
		}
		catch(e) {}

		self.MAIN.stylePage();
		self.MAIN.setLayerSizes(true);
		document.getElementById("MAIN").style.visibility = "visible";
  	}
	// if this task has been launched as a related link, remove any processing message
	if (fromTask && typeof(parent.removeWaitAlert) == "function")
		parent.removeWaitAlert();

	fitToScreen();
}
function fitToScreen()
{
	if (typeof(window["styler"]) == "undefined" || window.styler == null)
	{
		window.stylerWnd = findStyler(true);
	}

	if (!window.stylerWnd)
	{
		return;
	}

	if (typeof(window.stylerWnd["StylerEMSS"]) == "function")
	{
		window.styler = new window.stylerWnd.StylerEMSS();
	}
	else
	{
		window.styler = window.stylerWnd.styler;
	}

	var mainFrame = document.getElementById("MAIN");
	var winHeight = 571;
	var winWidth = 400;

	// resize the table frame to the screen dimensions
	if (document.body.clientHeight)
	{
		winHeight = document.body.clientHeight;
		winWidth = document.body.clientWidth;
	}
	else if (window.innerHeight)
	{
		winHeight = window.innerHeight;
		winWidth = window.innerWidth;
	}

	var fullContentWidth = (window.styler && window.styler.showLDS) ? (winWidth - 17) : ((navigator.appName.indexOf("Microsoft") >= 0) ? (winWidth - 12) : (winWidth - 7));

	try
	{
		mainFrame.style.height = winHeight + "px";
		
		if (winHeight < 571)
		{
			self.MAIN.document.getElementById("paneBorder").style.height = (winHeight - 35) + "px";
			self.MAIN.document.getElementById("paneBodyBorder").style.height = (winHeight - 62) + "px";
			self.MAIN.document.getElementById("paneBody").style.height = (winHeight - 70) + "px";
		}
		else
		{
			self.MAIN.document.getElementById("paneBorder").style.height = "566px";
			self.MAIN.document.getElementById("paneBodyBorder").style.height = "549px";
			self.MAIN.document.getElementById("paneBody").style.height = "541px";
		}

		if (fullContentWidth < 400)
		{
			self.MAIN.document.getElementById("paneBorder").style.width = fullContentWidth + "px";
			self.MAIN.document.getElementById("paneBodyBorder").style.width = (fullContentWidth - ((window.styler && window.styler.showLDS) ? 15 : 3)) + "px";				
			self.MAIN.document.getElementById("paneBody").style.width = (fullContentWidth - ((window.styler && window.styler.showLDS) ? 15 : 3)) + "px";
		}
		else
		{		
			self.MAIN.document.getElementById("paneBorder").style.width = "400px";	
			self.MAIN.document.getElementById("paneBodyBorder").style.width = (window.styler && window.styler.showLDS) ? "385px" : "393px";
			self.MAIN.document.getElementById("paneBody").style.width = (window.styler && window.styler.showLDS) ? "385px" : "393px";
		}
	}
	catch(e)
	{}
}
</script>
</head>
<body onload="GetWebuser()" onresize="fitToScreen()">
	<iframe id="MAIN" name="MAIN" style="visibility:hidden;position:absolute;height:571px;width:400px;left:0px;top:0px" src="/lawson/xhrnet/ui/headerpane.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="FRAME1" name="FRAME1" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/dot.htm" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@(201111) 09.00.01.06.00 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/empprofile.htm,v 1.17.2.26 2011/08/10 05:21:01 juanms Exp $ -->
