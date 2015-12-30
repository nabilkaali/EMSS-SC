<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
<head>
<title>Time Entry</title>
<meta name="viewport" content="width=device-width" />
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<link rel="alternate stylesheet" type="text/css" id="ui" title="classic" href="/lawson/xhrnet/ui/ui.css"/>
<link rel="alternate stylesheet" type="text/css" id="uiLDS" title="lds" href="/lawson/webappjs/lds/css/ldsEMSS.css"/>
<script src="/lawson/webappjs/common.js"></script>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/webappjs/transaction.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/email.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/xhrnet/waitalert.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/xhrnet/timeentry/lib/timeentrylib.js"></script>
<script src="/lawson/xhrnet/timeentry/Skins/Ocean/Template.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Calendar.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script src="/lawson/webappjs/javascript/objects/ActivityDialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/OpaqueCover.js"></script>
<script src="/lawson/webappjs/javascript/objects/Dialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/StringBuffer.js"></script>
<script src="/lawson/webappjs/javascript/objects/Data.js"></script>
<script src="/lawson/webappjs/javascript/objects/ProcessFlow.js"></script>
<script language="JavaScript">

var prm = "";
var EmpIndex = 0;
var Reports, ReportsSaved;
var NoSummaryFlag 	= false;
var QuickPaint 		= false;
var ExceptionFlag 	= false;
var pfServiceObj;

if (window.location.search)
{
	prm = getVarFromString("type", window.location.search).toLowerCase();
	EmpIndex = parseInt(getVarFromString("index", window.location.search).toLowerCase(), 10);
	var SummaryParam = getVarFromString("summary", window.location.search).toLowerCase();
	NoSummaryFlag = (SummaryParam == "no") ? true : false;
}

if (!prm)
{
	prm = "period";
}

if (isNaN(EmpIndex))
{
	EmpIndex = 0;
}

function OpenProgram()
{
	// Exit if lawheader is not defined
	if (typeof(self.lawheader.gmsgnbr) == "undefined")
	{
		return;
	}

	authenticate("frameNm='jsreturn'|funcNm='StartTimeEntry()'|sysenv=true|desiredEdit='EM'");
}

///////////////////////////////////////////////////////////////////////////////////////////////
//
// This function will get called once when the program starts. hs36 is initialized and executed
//

var ReportsDetail;

function StartTimeEntry()
{
	stylePage();
	showWaitAlert(getSeaPhrase("LOADING_TE","TE"));
	document.title = getSeaPhrase("TIME_ENTRY","TE");
	setTaskHeader("header", getSeaPhrase("TIME_ENTRY","TE"), "TimeEntry");

	document.getElementById("paneHelpIcon").alt = getSeaPhrase("HELP","ESS").toString();
    document.getElementById("paneBorder").style.visibility = "visible";

	if ((opener && opener.Reports) || (parent && parent.Reports))
	{
		var ReportsObj = (opener && opener.Reports) ? opener.Reports : parent.Reports;

		ReportsDetail = new Array();

		for (var i=0; i<ReportsObj.Detail.length; i++)
		{
			ReportsDetail[i] = new ReportsDetailObject(ReportsObj.Detail[i].Employee)
			ReportsDetail[i].Employee = ReportsObj.Detail[i].Employee
			ReportsDetail[i].TimecardType = ReportsObj.Detail[i].TimecardType
			ReportsDetail[i].TimecardTypeDesc = ReportsObj.Detail[i].TimecardTypeDesc;
			ReportsDetail[i].PlanCode = ReportsObj.Detail[i].PlanCode
			ReportsDetail[i].CommentsExist = ReportsObj.Detail[i].CommentsExist
			ReportsDetail[i].FullName = ReportsObj.Detail[i].FullName
			ReportsDetail[i].TotalHours = ReportsObj.Detail[i].TotalHours
			ReportsDetail[i].Status = ReportsObj.Detail[i].Status
			ReportsDetail[i].Email = ReportsObj.Detail[i].Email
			ReportsDetail[i].DatesExist = ReportsObj.Detail[i].DatesExist
			ReportsDetail[i].PeriodStartsAt = ReportsObj.Detail[i].PeriodStartsAt;
			ReportsDetail[i].PeriodStopsAt = ReportsObj.Detail[i].PeriodStopsAt;
		}

		if (ReportsObj.PeriodEnd)
		{
			hs36 = new HS36Object(ReportsObj.PeriodStart, ReportsObj.PeriodEnd, ReportsObj.Detail[EmpIndex].Employee, true)
		}
		else
		{
			if (prm == "period")
			{
				hs36 = new HS36Object(ReportsObj.PeriodStart, "", ReportsObj.Detail[EmpIndex].Employee, true)
			}
			else
			{
				hs36 = new HS36Object(ReportsObj.PeriodStart, ReportsObj.PeriodStart, ReportsObj.Detail[EmpIndex].Employee, true)
			}
		}
	}
	else if(prm == "daily")
	{
		hs36 = new HS36Object(authUser.date, authUser.date, authUser.employee, false)
	}
	else
	{
		hs36 = new HS36Object("", "", authUser.employee, false)
	}

	hs36.normal();
}

//////////////////////////////////////////////////////////////////////////////////////////
//
// This function will only get called if an email needs to be sent as a result of information
// changed on the current time card. The reject and managerchanged emails are only sent if
// this program is being run in Manager Mode.
//

function SendEmail(type)
{
	var mailText = "";
	var SendingTo = "";
	var Sender = "";
	var alertMsg = getSeaPhrase("SENDING_EMAIL","TE");

	//PT 156127 removed extra code for period start and stop dates used in email text.
	var TimeCardStart = TimeCard.StartDate;
	var TimeCardStop = TimeCard.EndDate;
	var action = "";

	switch (type)
	{
		case "reject":
			action 			= "reject";
			alertMsg		= getSeaPhrase("SENDING_EMPLOYEE_NOTICE","TE");
			mailText 		= Reports.EmployeeName+getSeaPhrase("TIME_CARD_RETURNED_PERIOD","TE")+FormatDte3(TimeCardStart)+getSeaPhrase("TO","TE")+FormatDte3(TimeCardStop)+getSeaPhrase("DOT","TE");
			var SendingTo 	= Employee.Email;
			var Sender 		= Employee.SupervisorEmail;
			break;
		case "approve":
			action 			= "approve";
			alertMsg		= getSeaPhrase("SENDING_EMPLOYEE_NOTICE","TE");
			mailText 		= Reports.EmployeeName+getSeaPhrase("TIME_CARD_APPROVED_PERIOD","TE")+FormatDte3(TimeCardStart)+getSeaPhrase("TO","TE")+FormatDte3(TimeCardStop)+getSeaPhrase("DOT","TE");
			var SendingTo 	= Employee.Email;
			var Sender 		= Employee.SupervisorEmail;
			break;
		case "managerchanged":
			action 			= "change";
			alertMsg		= getSeaPhrase("SENDING_EMPLOYEE_NOTICE","TE");
			mailText 		= Reports.EmployeeName+getSeaPhrase("TIME_CARD_CHANGED_PERIOD","TE")+FormatDte3(TimeCardStart)+getSeaPhrase("TO","TE")+FormatDte3(TimeCardStop)+getSeaPhrase("DOT","TE");
			var SendingTo 	= Employee.Email;
			var Sender 		= Employee.SupervisorEmail;
			break;
		case "employeesubmitted":
			action 			= "submit";
			alertMsg		= getSeaPhrase("SENDING_SUPERVISOR_APPROVAL","TE");
			// PT 127426
			// mailText 	= Reports.EmployeeName+getSeaPhrase("TIME_CARD_SUBMITTED_PERIOD","TE")+FormatDte3(TimeCardStart)+getSeaPhrase("TO","TE")+FormatDte3(TimeCardStop)+getSeaPhrase("DOT","TE");
			mailText 		= Employee.EmployeeName+getSeaPhrase("TIME_CARD_SUBMITTED_PERIOD","TE")+FormatDte3(TimeCardStart)+getSeaPhrase("TO","TE")+FormatDte3(TimeCardStop)+getSeaPhrase("DOT","TE");
			var SendingTo 	= Employee.SupervisorEmail;
			var Sender 		= Employee.Email;
			break;
	}

	var Subject 	= getSeaPhrase("TIME_ENTRY","TE");

	// PT 127426
	if (type == "employeesubmitted")
	{
		if (typeof(Sender) == "undefined" || Sender == null || !Sender)
		{
			if (typeof(Employee.EmployeeName) == "undefined" || Employee.EmployeeName == null || !Employee.EmployeeName)
				Sender = SendingTo
			else
				Sender = Employee.EmployeeName
		}
	}
	else
	{
		if (typeof(Sender) == "undefined" || Sender == null || !Sender)
		{
			if (typeof(Reports.EmployeeName) == "undefined" || Reports.EmployeeName == null || !Reports.EmployeeName)
				Sender = SendingTo
			else
				Sender = Reports.EmployeeName
		}
	}

	if (SendingTo)
	{
		showWaitAlert(alertMsg);

		// If the ProcessFlow service was found, trigger the flow.  Otherwise use the email CGI program.
		var techVersion = (iosHandler && iosHandler.getIOSVersionNumber() >= "9.0") ? ProcessFlowObject.TECHNOLOGY_900 : ProcessFlowObject.TECHNOLOGY_803;
		var httpRequest = (typeof(SSORequest) == "function") ? SSORequest : SEARequest;
		var pfObj = new ProcessFlowObject(window, techVersion, httpRequest, "EMSS");
		pfObj.showErrors = false;

		if (typeof(pfServiceObj) == "undefined")
		{
			pfServiceObj = pfObj.lookUpService("EMSSTimeEntChg");
		}
// MOD BY BILAL
	pfServiceObj = null;
// END OF MOD

		if (pfServiceObj != null)
		{
			var flowObj = pfObj.setFlow("EMSSTimeEntChg", Workflow.SERVICE_EVENT_TYPE, Workflow.ERP_SYSTEM,
						authUser.prodline, authUser.webuser, null, "");
			flowObj.addVariable("company", String(authUser.company));
			flowObj.addVariable("employee", String(Employee.EmployeeNbr));
			flowObj.addVariable("role", (type == "employeesubmitted") ? "employee" : "manager");
			flowObj.addVariable("action", action);
			flowObj.addVariable("fromDate", String(TimeCard.StartDate));
			flowObj.addVariable("toDate", String(TimeCard.EndDate));
			flowObj.addVariable("dailyFlag", (TimeCard.DailyFlag && TimeCard.DailyFlag != "N") ? "Y" : "N");
			flowObj.addVariable("printFlag", (TimeCard.PrintFlag && TimeCard.PrintFlag != "N") ? "Y" : "N");
			flowObj.addVariable("exceptionFlag", (TimeCard.ExceptionFlag && TimeCard.ExceptionFlag != "N") ? "Y" : "N");
			pfObj.triggerFlow();
			EmailTimer = setTimeout("cgiEmailDone()", 5);
			return;
		}

		var obj 		= new EMAILObject(SendingTo,Sender);
			obj.subject = Subject;
			obj.message = mailText;
		EMAIL(obj,"jsreturn");
		EmailTimer = setTimeout("cgiEmailDone()", 10000);
	}
	else
	{
		seaAlert(getSeaPhrase("EMPLOYEE_EMAIL_NOT_AVAILABLE","TE"));

		if (boolSaveChanges || bSelectChanged)
		{
			if (!SaveChangesDone())
			{
				QuickPaint = true;  		// we still need to reset our objects. Since we are outside the main
				hs36.normal();				// procedure we will do that here.
			}
			else
			{
				removeWaitAlert();
			}
		}
		else
		{
			QuickPaint = true; 				// we still need to reset our objects. Since we are outside the main
			hs36.normal();					// procedure we will do that here.
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Function that is called when the email has successfully been delivered.
//

function cgiEmailDone()
{
	clearTimeout(EmailTimer);
	//PT 113608: do not attempt to diagnose an email problem; NT users incorrectly get this message.
	//if(arguments.length>0)
	//{
	//	seaAlert("There is an internal problem with email. Please contact your Human Resources Department.")
	//}
	//else
	//{
		window.status = getSeaPhrase("EMAIL_SENT","TE")
	//}

	if (boolSaveChanges || bSelectChanged)
	{
		removeWaitAlert();
		if (!SaveChangesDone())
		{
			QuickPaint = true;  		// we still need to reset our objects. Since we are outside the main
			hs36.normal();				// procedure we will do that here.
		}
	}
	else
	{
		QuickPaint = true;  			// we still need to reset our objects. Since we are outside the main
		hs36.normal();					// procedure we will do that here.
	}
}

function Unload()
{
	CloseChildPopupWindows();
}

function checkResolution()
{
	if (screen.width <= "800" && screen.height <= "600")
	{
		if (document.body.clientHeight)
		{
			document.getElementById("paneBorder").style.height = (document.body.clientHeight - 55) + "px";
		}
		document.getElementById("TABLE").style.height = "475px";
		window.moveTo(0,0);
		window.resizeTo(screen.width,screen.height);
	}
}

function fitToScreen()
{
	setLayerSizes();

	var winHeight = 520;
	var winWidth = 800;
	var headerHeight = 40;
	var outerPane = self.TABLE.document.getElementById("outerPane");
	var paneBody1 = self.TABLE.document.getElementById("paneBody1");
	var paneBody2 = self.TABLE.document.getElementById("paneBody2");

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

	var tblFrame = document.getElementById("TABLE");
	tblFrame.style.height = (winHeight - headerHeight) + "px";
	tblFrame.style.width = (winWidth - 20) + "px";

	var paneBorder = document.getElementById("paneBorder");
	paneBorder.style.height = (winHeight - headerHeight) + "px";

	if (outerPane)
	{
		outerPane.setAttribute("styler", "groupbox");
		outerPane.style.width = "100%";
	}

	if (paneBody1 && paneBody2)
	{
		paneBody2.style.overflow = "auto";
		paneBody2.style.width = "100%";

		if (winHeight > (paneBody1.offsetHeight + headerHeight + 32))
		{
			paneBody2.style.height = (winHeight - paneBody1.offsetHeight - headerHeight - 75) + "px";
			paneBody2.style.height = (winHeight - paneBody1.offsetHeight - headerHeight - 32) + "px";
		}
	}
}

</script>
</head>

<body style="overflow:hidden" onload="checkResolution();fitToScreen();OpenProgram()" onresize="fitToScreen()" onunload="Unload()">

<iframe id="header" name="header" src="/lawson/xhrnet/ui/header.htm" style="visibility:visible;position:absolute;height:34px;width:803px;left:0px;top:0px" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>

<div id="paneBorder" class="panebordertimeentry" style="position:absolute;top:34px;left:0px;visibility:hidden;height:560px;overflow:hidden">
	<table id="paneTable" border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr style="height:16px" styler="hidden">
	<td>
		<table border="0" cellspacing="0" cellpadding="0" width="100%" height="100%">
		<tr>
		<td>
			<img id="paneHelpIcon" border="0" class="helpicon" onclick="OpenHelpDialog()" src="/lawson/xhrnet/ui/images/ico_help_6699cc.gif" onmouseover=this.src="/lawson/xhrnet/ui/images/ico_help_6699cc-over.gif" onmousedown=this.src="/lawson/xhrnet/ui/images/ico_help_6699cc-down.gif" onmouseout=this.src="/lawson/xhrnet/ui/images/ico_help_6699cc.gif">
			<div id="paneHeader" class="paneheadertimeentry" width="100%" height="100%">&nbsp;</div>
		</td>
		</tr>
		</table>
	</td>
	</tr>
	<tr><td style="padding-left:5px">
		<table border="0" width="100%" cellpadding="0" cellspacing="0">
		<tr><td>
			<iframe name="TABLE" id="TABLE" src="/lawson/xhrnet/ui/plain.htm" style="visibility:visible;width:100%;height:520px" allowtransparency="yes" marginwidth="0" marginheight="0" frameborder="0" scrolling="no"></iframe>
		</td></tr>
		</table>
	</td></tr>
	<tr><td>
		<iframe name="jsreturn" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;width:0px;height:0px" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
		<iframe name="lawheader" src="/lawson/xhrnet/timeentry/employee/timeentrylaw.htm" style="visibility:hidden;width:0px;height:0px" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
		<iframe name="printFm" src="/lawson/xhrnet/ui/plain.htm" style="visibility:visible;position:relative;top:0px;left:0px;width:100%;height:1px" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
		<iframe name="PGCONTROL" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;width:0px;height:0px" marginwidth="0" marginheight="0" frameborder="no" scrolling="no"></iframe>
	</td></tr>
	</table>
</div>

</body>
</html>

<!-- Version: 8-)@(#)@(201111) 09.00.01.06.00 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/timeentry/employee/timeentry.htm,v 1.16.2.35 2011/05/04 21:10:17 brentd Exp $ -->
