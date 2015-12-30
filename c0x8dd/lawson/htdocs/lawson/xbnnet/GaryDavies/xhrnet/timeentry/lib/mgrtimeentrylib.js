// Version: 8-)@(#)@(201111) 09.00.01.06.09
// $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/timeentry/lib/Attic/mgrtimeentrylib.js,v 1.1.2.6.4.1 2012/03/06 17:13:30 brentd Exp $

/*
 *		Common Objects
 */

function PlanCodeObject(company, employee)
{
	this.Company = company;
	this.Employee = employee;
	this.NumberOfPlans = null;
	this.Detail = new Array(0);
}

function PlanCodeDetailObject(code, description)
{
	this.PlanCode = code;
	this.Description = description;
}

function ReportsObject(company, employee)
{
	this.Company = company
	this.Employee = employee
	this.EmployeeName = null;
	this.PlanCode = null;
	this.PeriodStart = null;
	this.PeriodEnd = null;
	this.View = null;
	this.PlanCodeDescription = null;
	this.Email = null;
	this.LastHsuCode = null;
	this.LastLastName = null;
	this.LastFirstName = null;
	this.LastMiddleInit = null;
	this.LastEmployee = null;
	this.LastStartDate = null;
	this.Detail = new Array(0);
}

function ReportsDetailObject(employee)
{
	this.Employee = employee;
	this.TimecardType = null;
	this.TimecardTypeDesc = null;
	this.PlanCode = null;
	this.CommentsExist = null
	this.FullName = null;
	this.TotalHours = null;
	this.Status = null;
	this.Email = null;
	this.DatesExist = null;
	this.PeriodStartsAt = null;
	this.PeriodStopsAt = null;
	// PT116112
	this.PlanCode = null;
	this.PlanCodeDescription = null;
	this.FullName = null;	
}

/*
 *		Common Functions
 */

var boolSaveChanges = false;	//whether or not changes have been made to the form

function GetTimeCardView(iView)
{
	if (IgnorePeriodOutOfRangeAndLockOut)
	{
		LockedOut = false;
		Reports.View = 4;
		return;
	}

	if (iView == 2)
	{
		LockedOut = true;
	}
	else
	{
		LockedOut = false;
	}
}

function PaintHeaders()
{
	try
	{
		self.MAIN.document.getElementById("paneBody1").innerHTML = "";
	}
	catch(e)
	{
		setTimeout(function() { PaintHeaders.apply(this, arguments); }, 5);
		return;
	}
	
	if ((typeof(Reports.PeriodStart) == "undefined" || Reports.PeriodStart == null || Reports.PeriodStart == "")
	&& (Reports.Detail.length > 0))
	{
		Reports.PeriodStart = Reports.Detail[0].PeriodStartsAt;
	}
	
	if ((typeof(Reports.PeriodEnd) == "undefined" || Reports.PeriodEnd == null || Reports.PeriodEnd == "")
	&& (Reports.Detail.length > 0))
	{
		Reports.PeriodEnd = Reports.Detail[0].PeriodStopsAt;
	}	

	var CalendarStartDate = FormatDte4(Reports.PeriodStart);

	var html = '<table cellpadding="0" cellspacing="0" border="0"><tr><td width="50" rowspan="2">'
	html += '</td><td width="50" rowspan="2">'
	html += '</td><td width="50" rowspan="2">'
	html += '&nbsp;'
	html += '</td><td style="width:100%;text-align:center" class="fieldlabelbold">'
	html += getSeaPhrase("PAY_PLAN","TE")+'&nbsp;<span class="fieldlabel">'+Reports.PlanCodeDescription+'</span>'
	html += '</td><td rowspan="2">'
	html += '&nbsp;'
	html += '</td><td>&nbsp;'
	html += '</td><td width="50" rowspan="2">'
	
	if (arguments.length == 0)
	{
		html += '<a href="" onclick="parent.CheckAuthen(\'OpenTimeOff_Period()\');return false">'
		html += getSeaPhrase("OPEN_LEAVE_BALANCE_WIN","TE")
		html += '</a>'
	}
	else
	{
		html += '&nbsp;'
	}
	
	html += '</td><td>&nbsp;'
	html += '</tr><tr><td style="text-align:center">'
	html += '<table style="margin-left:auto;margin-right:auto" width="410" cellspacing="0" cellpadding="0" border="0">'
	html += '<tr><td style="vertical-align:middle;width:14px">&nbsp;</td>'
	html += '<td style="vertical-align:middle;width:25px">'
	html += '<a href="" onclick="parent.CheckAuthen(\'PreviousPeriod_Summary()\');return false;" '
	html += 'onmouseover="parent.MAIN.document.previous.src=\''+PreviousIconOver+'\';return true;" '
	html += 'onmouseout="parent.MAIN.document.previous.src=\''+PreviousIcon+'\';return true;">'
	html += '<img styler="prevcalendararrow" name="previous" src="'+PreviousIcon+'" alt="'+getSeaPhrase("TO_PRE_PERIOD","TE")+'" border="0">'
	html += '</a>'
	html += '</td><td style="text-align:center;vertical-align:middle" class="plaintablecellbold" nowrap>'
	html += dteDay(Reports.PeriodStart)+", "+FormatDte3(Reports.PeriodStart) + ' - ' + dteDay(Reports.PeriodEnd)+", "+ FormatDte3(Reports.PeriodEnd)
	html += '</td><td style="vertical-align:middle;width:25px">'
	html += '<a href="" onclick="parent.CheckAuthen(\'NextPeriod_Summary()\');return false;" '
	html += 'onmouseover="parent.MAIN.document.next.src=\''+NextIconOver+'\';return true;" '
	html += 'onmouseout="parent.MAIN.document.next.src=\''+NextIcon+'\';return true;">'
	html += '<img styler="nextcalendararrow" name="next" src="'+NextIcon+'" alt="'+getSeaPhrase("TO_NEXT_PERIOD","TE")+'" border="0">'
	html += '</a>'
	html += '</td><td style="vertical-align:middle" nowrap>'
	html += '&nbsp;<input onchange="parent.date_fld_name=\'5\';parent.ReturnDate(this.value)" styler="calendar" class="inputbox" onkeydown="this.value=this.getAttribute(\'start_date\')" onkeyup="this.value=this.getAttribute(\'start_date\')" type="text" name="navDate" size="10" maxlength="10" start_date="' + CalendarStartDate + '" value="' + CalendarStartDate + '"/>'	
	html += '<a styler="hidden" href="" onclick="parent.CheckAuthen(\'HeaderCalendar_Summary()\');return false">'
	html += uiCalendarIcon()
	html += '</a>'
	html += '</td><td style="width:14px">&nbsp;'
	html += '</td></tr></table>'
	html += '</td><td>&nbsp;<td>&nbsp;</td></tr>'
	html += '<tr><td>&nbsp</td>'
	html += '<td>&nbsp;<td>&nbsp;</td>'
	html += '<td style="text-align:center" class="plaintablecellbold">'
	
	switch (parseInt(Reports.View,10))
	{
		case 1: html += getSeaPhrase("INVALID_PERIOD","TE"); break;
		case 2: html += getSeaPhrase("TE_LOCKED","TE"); break;
		case 3: html += getSeaPhrase("OLD_PERIOD","TE"); break;
	}
	
	html += '</td><td style="text-align:right">'
	html += '&nbsp;</td></tr>'
	html += '</table>'
	
	//try
	//{
		self.MAIN.document.getElementById("paneBody1").innerHTML = html;
	//}
	//catch(e)
	//{
		//setTimeout(function() { self.MAIN.document.getElementById("paneBody1").innerHTML = html; }, 5);
		//self.MAIN.document.body.innerHTML = html;
	//}
	//self.MAIN.stylePage();
}

/******************************************************************************************
 Verify that authen object still exists; if not, re-generate it.  Portal v3.0 issue.
******************************************************************************************/
function CheckAuthen(Func)
{
	if (typeof(authUser.prodline)!="string") 
	{
		authenticate("frameNm='jsreturn'|funcNm='"+Func+"'|sysenv=true|desiredEdit='EM'");
	}
	else
	{
		eval(Func);
	}
}

function GetButtonFrameInformation(View)
{
	var arg = '<form name="frmButtonFrame">'
	+ '<table border="0" cellpadding="0" cellspacing="0" style="width:100%"><tr>'
	+ '<td style="vertical-align:middle;text-align:center">';
	
	if (View == 4 && DropDownAvailable())
	{
		arg += uiButton(getSeaPhrase("UPDATE_CARD","TE"),"parent.fncSaveChanges='';parent.SummaryUpdate();return false","margin-left:5px;margin-top:10px");
	}
		
	if (AreAnySubmitted() && View == 4)
	{	
		arg += uiButton(getSeaPhrase("APPROVE_ALL_SUBMITTED","TE"),"parent.ApproveAll();return false","margin-left:5px;margin-top:10px");
	}

	arg += uiButton(getSeaPhrase("CLOSE_TE","TE"),"parent.SummaryApprovalDone('"+View+"');return false","margin-left:5px;margin-top:10px");	
	if (parent.program && parent.program == "summary" && (!parent.PlanCodes || parent.PlanCodes.Detail.length <= 1))
	{
		// do not display the "Return to List" button in Summary Approval if there is not more than one pay plan available
	}
	else
	{
		arg += uiButton(getSeaPhrase("RETURN_LIST","TE"),"parent.BackToPayPlanList('"+View+"');return false","margin-left:5px;margin-top:10px");
	}	
	arg += '</td></table></form>';
	
	return arg;
}

function DropDownAvailable()
{
	for (var i=0; i<Reports.Detail.length; i++)
	{
		if (Reports.Detail[i].Status >= 1)
		{
			return true;
		}
	}
	return false;
}

function AreAnySubmitted()
{
	for (var i = 0; i < Reports.Detail.length; i++)
	{
		if (Reports.Detail[i].Status >= 1 && Reports.Detail[i].Status <= 4)
		{
			return true;
		}
	}
	return false;
}

function ApproveAll()
{
	if (seaConfirm(getSeaPhrase("CONTINUE_SUBMITTED_AS_APPROVED","TE"), "", handleApproveAllResponse))
	{
		DoApproveAll();
	}
}

// Firefox will call this function
function handleApproveAllResponse(confirmWin)
{
	if (confirmWin.returnValue == "ok" || confirmWin.returnValue == "continue")
	{
		DoApproveAll();
	}
}

function DoApproveAll()
{
	var statusForm = self.MAIN.document.forms["frmStatus"];
	var statusDropDown;
		
	for (var i=0; i<Reports.Detail.length; i++)
	{
		if (Reports.Detail[i].Status == 1)
		{
			statusDropDown = statusForm.elements["cmbStatus" + i];
			statusDropDown.selectedIndex = 1;
			self.MAIN.styleElement(statusDropDown);
		}
	}
	
	SummaryUpdate();
}

// PT 141449
function FormatHours(Qty,size)
{
	var strQty  = String(Qty);
	var leadingSign='',trailingSign='',returnVal='';

	if( strQty.charAt(0)=='-' || strQty.charAt(0)=='+')
	{
		leadingSign = strQty.substring(0,1);
		strQty = strQty.substring(1,strQty.length);
		// PT 128693
		strQty = leadingSign + strQty;
	}
	else if(strQty.charAt(strQty.length-1)=='-' || strQty.charAt(strQty.length-1)=='+')
	{
		trailingSign = strQty.substring(strQty.length-1,strQty.length);
		strQty = strQty.substring(0,strQty.length-1);
		// PT 128693
		strQty = trailingSign + strQty;
	}

	var Newsize = size / 10;

	if(Newsize < 0)
	{
		if (strQty.indexOf(".") == -1)
			returnVal = roundToDecimal((Number(strQty) / 100), size);
		else
			returnVal = roundToDecimal(Number(strQty), size);
	}
	else
	{
		var size = parseInt((Newsize - Math.floor(size/10)) * 10);
		if (strQty.indexOf(".") == -1)
			strQty = (Number(strQty) / 100);
		else
			strQty = Number(strQty);
		returnVal = roundToDecimal(strQty, size);
	}

	if (returnVal == "" && size > 0)
	{
		returnVal = "0."; 
		for (var i=0; i<size; i++)
			returnVal += "0";
	}
	
	return returnVal;
}
// PT 141449

function CommentIconMouseOver(flag, i)
{
	var frName;

	if(i == '')
		frName = "COMMENTS"
	else
		frName = "MAIN"

	if(flag)
	{
		if(eval('self.'+frName+'.document.comment'+i).src.indexOf(ExistingCommentsIcon)>=0)
			eval('self.'+frName+'.document.comment'+i).src	=	ExistingCommentsOverIcon
		else
			eval('self.'+frName+'.document.comment'+i).src	=	NoCommentsOverIcon
	}
	else
	{
		if(eval('self.'+frName+'.document.comment'+i).src.indexOf(ExistingCommentsOverIcon)>=0)
			eval('self.'+frName+'.document.comment'+i).src = ExistingCommentsIcon
		else
			eval('self.'+frName+'.document.comment'+i).src = NoCommentsIcon
	}
}

/******************************************************************************************
 Open Tips Window
******************************************************************************************/
function NewToolTips()
{
	TipsWin = window.open("/lawson/xhrnet/timeentry/tips/tips.htm", "TIPS", "toolbar=no;status=no,width=300,height=400")
}

function DoesObjectExist(pObj)
{
	if(typeof(pObj) == "undefined" || typeof(pObj) == "unknown" || pObj == null || typeof(pObj) == "null")
		return false;
	else
		return true;
}

/*
 *		Comments Functions
 */

var Comments		//Instance of the Comments object.
var ToggleSwitch = false
var DeleteFlag = false;
var CommentsUpdateFlag = false;
var CommentsCloseFlag = false;

/**********************************************************************************************
 Comment object which handles all of the functionality of this window.
**********************************************************************************************/
function CommentsObject()
{
	this.Date = null
	this.Employee = null
	this.Text = null
	this.SequenceNumber = null
	this.UserId = null
	this.ProxyId = null
	this.Event = "ADD"
	this.commentsWindow = null;
}

/**********************************************************************************************
 Locate the center of the parent window.
**********************************************************************************************/
function FindCenterforCommentsWindow()
{
	var retval = new Object()
	retval.X = (screen.width/2) - 275;
	retval.Y = (screen.height/2) - 175;
	return retval
}

/**********************************************************************************************
 Will open the comments window and assign the handle to the Comments Object.
**********************************************************************************************/
function OpenComments(Date, Employee)
{
	// var SSLLoc = (document.getElementById && !document.all) ? "javascript:''" : "/lawson/xhrnet/dot.htm";
	var SSLLoc = "/lawson/xhrnet/ui/windowplain.htm?func=opener.CommentsLoaded()";
	
	if (typeof(authUser.prodline) == "unknown")
	{
		authenticate("frameNm='jsreturn'|funcNm='OpenComments(\""+Date+"\",\""+Employee+"\")'|sysenv=true|desiredEdit='EM'");
		return;
	}

	WIND = FindCenterforCommentsWindow();

	if (typeof(Comments)=='undefined' || typeof((Comments.commentsWindow)=='undefined' || !Comments.commentsWindow) || Comments.commentsWindow.closed)
	{
		Comments = new CommentsObject();
		Comments.commentsWindow = window.open(SSLLoc,"Comments","left="+WIND.X+",top="+WIND.Y+",toolbar=no,resizable=yes,status=no,height=350,width=550");
	}
	else
	{
		Comments.commentsWindow.focus();
	}
	
	Comments.Date = Date;
	Comments.Employee = Employee;
	GetEmpComment();
}

/**********************************************************************************************
 DME call to grab all the comments related to the date in question. This DME will only return
 the comments that are assigned to the date given in Comments.Date.
**********************************************************************************************/
function GetEmpComment()
{
	var object 			= new DMEObject(authUser.prodline,"EMPCOMMENT")
		object.out 		= "JAVASCRIPT"
		object.index 		= "ecmset1"
		object.field 		= "employee;ln-nbr;seq-nbr;cmt-text;date;user-id;proxy-id"
		object.key 		= parseFloat(authUser.company)+"="+parseFloat(Comments.Employee)+"=TR="+Comments.Date
		object.max 		= "600";
		object.debug 		= false;
		object.sortasc 		= "ln-nbr"
		object.func 		= "DspEmpComments()";
	DME(object,"jsreturn")
}

/**********************************************************************************************
 Parse through any information returned from the DME. Recall the DME function if more than
 300 records are returned. If not paint the window with the information provided in the
 Comments object.
**********************************************************************************************/
function DspEmpComments()
{
	Comments.Text = ""
	var obj;

	for (var i=0; i<self.jsreturn.NbrRecs; i++)
	{
		obj = self.jsreturn.record[i];

		// PT 127924 extra space added in comments maked comments hard to read
		// Comments.Text 		+= obj.cmt_text + " ";
		Comments.Text 			+= obj.cmt_text;
		Comments.SequenceNumber	= parseFloat(obj.ln_nbr);
		Comments.UserId			= obj.user_id;
		Comments.ProxyId		= obj.proxy_id;
	}

	if (self.jsreturn.NbrRecs > 0)
	{
		Comments.Event 			= "CHANGE";
	}
	
	if (self.jsreturn.Next != '')
	{
		window.open(self.jsreturn.Next,"jsreturn");
	}
	else
	{
		WriteComments();
	}
}

/**********************************************************************************************
 Handles the date returned from the calendar, assigns this date to the object and recalls the
 DME function.
**********************************************************************************************/
function ReturnCommentsDate(Date)
{
	if(getDteDifference(Date,Comments.Date) == 0)
	{
		seaAlert(getSeaPhrase("COMMENTS_LOADED_FOR_DAY","TE"), "Comments.commentsWindow")
		return;
	}
	showWaitAlert(getSeaPhrase("MOVING_TO_NEW_DATE","TE"))

	Comments.Date 	= Date
	GetEmpComment(true)
}

/**********************************************************************************************
 Will open the calendar window for the user to select a new date.
**********************************************************************************************/
function MoveToNewDateForComments()
{
	DateSelect("2")
}

/**********************************************************************************************
 Paints the comments window. Quickpaint will only repaint the header as the date is a label
 field and cannot be changed by itself. The form elements will be changed by their object
 values and do not have to be repainted.
**********************************************************************************************/
function WriteComments()
{
	if (!Comments || !Comments.commentsWindow || !Comments.commentsWindow.document || !Comments.commentsWindow.document.body
	|| !Comments.commentsWindow.document.getElementById("paneBody1"))
	{
		setTimeout('WriteComments()',5);
		return;
	}	

	date_fld_name = "2";
	Comments.commentsWindow.document.getElementById("paneBody1").style.visibility = "hidden";
	
	var html = '<div style="padding:5px;width:100%;height:100%;text-align:center"><div styler="groupbox">'+
		'<table border="0" cellspacing="0" cellpadding="0"><tr><td styler="hidden" style="text-align:center" class="plaintablecellbold">'+
		getSeaPhrase("COMMENTS","TE")+'</td>'+
		'<td style="text-align:center" class="plaintablecellbold"><input onchange="parent.opener.ReturnDate(this.value)" styler="calendar" class="inputbox" onkeydown="this.value=this.getAttribute(\'start_date\')" onkeyup="this.value=this.getAttribute(\'start_date\')" type="text" name="navDate" size="10" maxlength="10" start_date="' + FormatDte4(Comments.Date) + '" value="' + FormatDte4(Comments.Date) + '"/>'+
		'<a styler="hidden" href="" onclick="parent.opener.MoveToNewDateForComments();return false;">'+
		uiCalendarIcon()+'</a></td></tr>';
		
	html += '<tr><td class="plaintablecellbold" colspan="2"><div style="text-align:center"><form name="myComments">'+
		'<textarea class="plaintablecell" cols="60" rows="11" name="comments" wrap="virtual">'+Comments.Text+
		'</textarea></form></div></td></tr></table>';

	html += '<div style="text-align:center"><table border="0" cellspacing="0" cellpadding="0"><tr><td>'+
		uiButton(getSeaPhrase("UPDATE","TE"), "parent.opener.UpdateComments();return false");
		
	if (Comments.Text != "")
	{
		html += uiButton(getSeaPhrase("DELETE","TE"), "parent.opener.DeleteComment();return false","margin-left:5px");
	}
	else
	{
		html += uiButton(getSeaPhrase("CLEAR","TE"), "parent.document.myComments.comments.value='';return false","margin-left:5px");
	}
	
	html += uiButton(getSeaPhrase("DONE","TE"), "parent.opener.CloseCommentsWindow();return false","margin-left:5px")+
		'</td></tr></table></div></div></div>';

	Comments.commentsWindow.document.getElementById("paneBody1").innerHTML = html;	
	Comments.commentsWindow.stylePage(true, getSeaPhrase("COMMENTS","TE"));
	Comments.commentsWindow.document.getElementById("paneBody1").style.visibility = "visible";
	
	setTimeout("CommentsLoaded()",1000);
	removeWaitAlert();
	
	if (ToggleSwitch)
	{
		ToggleSwitch = false;
		if (DeleteFlag)
		{
			ToggleCommentSwitch("Deleting", Comments.Date);
		}
		else
		{
			ToggleCommentSwitch("Adding", Comments.Date);
		}
	}
}

/**********************************************************************************************
 Event function to be called when the comments content has fulled loaded into the window.
**********************************************************************************************/
function CommentsLoaded()
{
	//Comments.commentsWindow.document.myComments.comments.focus();
	// if the user clicked the "Done" button prior to the update completing, close the 
	// comments window.
	if (CommentsUpdateFlag)
	{
		CommentsUpdateFlag = false; // make sure the update flag is turned off
		if (CommentsCloseFlag)
		{
			CloseCommentsWindow();
		}
	}
}

/**********************************************************************************************
 If the user has clicked the DONE button then this function is called. Close the comments
 window and call the CommentsWindow_Closed() function which is defined elsewhere in the program
 for performing any logical check after this window has closed.
**********************************************************************************************/
function CloseCommentsWindow()
{
	// if the user clicks on the "Done" button while a comments update is still occurring,
	// do not close the window until the update has fully completed.
	if (CommentsUpdateFlag)
	{
		CommentsCloseFlag = true;
	}
	else
	{
		CommentsWindow_Closed();
		Comments.commentsWindow.close();
	}
}

/**********************************************************************************************
 Will prompt you first to make sure you want to delete this comment. If so then it will call the
 delete function.
**********************************************************************************************/
function DeleteComment()
{
	if (seaConfirm(getSeaPhrase("DELETE_COMMENTS?","TE"), "", FireFoxDeleteComment))
	{
		Delete_Comments("true");
	}
}

function FireFoxDeleteComment(confirmWin)
{
	if (confirmWin.returnValue == "ok" || confirmWin.returnValue == "continue")
	{
		Delete_Comments("true");
	}
	try
	{
		Comments.commentsWindow.focus();
	}
	catch(e) {}	
}

/**********************************************************************************************
 Will clear out the textarea.
**********************************************************************************************/
function ClearComment()
{
	Comments.commentsWindow.document.myComments.comments.value='';
}

/**********************************************************************************************
 Update the comments by deleting the comments first then readding the new comments stored in
 the textarea.
**********************************************************************************************/
function UpdateComments()
{	//PT 163413
	if(NonSpace(Comments.commentsWindow.document.myComments.comments.value) == 0)
	{
		Comments.commentsWindow.seaAlert(getSeaPhrase("UPDATE_COMMENTS","TE"))	
		Comments.commentsWindow.document.myComments.comments.focus();
		return;
  	}
	CommentsUpdateFlag = true;
	if(Comments.Text != "")
	{
		if(Comments.commentsWindow.document.myComments.comments.value == "")
			Delete_Comments("true")
		else
			Delete_Comments("false")
	}
	else
		Add_Comments()
}

/**********************************************************************************************
 AGS call to delete the comments. ES01 works where all the information it needs are the key
 fields plus the date to delete. It will delete all records related to this date.
**********************************************************************************************/
function Delete_Comments(flag)
{
	var object = new AGSObject(authUser.prodline,"ES01.1")
		object.event 	= "CHANGE";
		object.rtn 	= "MESSAGE";
		object.longNames = true;
		object.lfn	= "ALL";
		object.tds 	= false;
		object.field 	= "FC=D"
				+ "&ECM-COMPANY="+parseFloat(authUser.company)
				+ "&ECM-EMPLOYEE="+parseFloat(Comments.Employee)
				+ "&ECM-CMT-TYPE=TR"
				+ "&ECM-DATE="+Comments.Date
		object.func = "parent.RecordsDeleted_Comments('"+flag+"')"
		object.debug = false;
	AGS(object,"jsreturn")
}

/**********************************************************************************************
 Check for any error messages from AGS. If we are adding comments then call the add comments
 function. If not, toggle the comments icon pointing to this date to clear and recall the
 DME function to reset the window.
**********************************************************************************************/
function RecordsDeleted_Comments(flag)
{
	DeleteFlag = false;
	if(self.lawheader.gmsgnbr == "000")
	{
		if(eval(flag))
		{
			Comments.commentsWindow.seaAlert(self.lawheader.gmsg)
			ToggleSwitch = true;
			DeleteFlag = true;
			GetEmpComment(true);
		}
		else
			Add_Comments()
	}
	else
		Comments.commentsWindow.seaAlert(self.lawheader.gmsg)
}

/**********************************************************************************************
 Separate the textarea into 60 character lines. Call AGS with the key elements and then
 loop through the array of lines, adding them to the call with a SEQ number that relates to
 the line.
**********************************************************************************************/
function Add_Comments()
{
	DeleteFlag = false;
	var lines = SeparateTextArea(Comments.commentsWindow.document.myComments.comments.value,60)

	var object = new AGSObject(authUser.prodline,"ES01.1")
		object.event 	= "ADD";
		object.rtn 	= "MESSAGE";
		object.longNames = true;
		object.lfn	= "ALL";
		object.tds 	= false;
		object.field 	= "FC=A"
				+ "&ECM-COMPANY="+parseFloat(authUser.company)
				+ "&ECM-EMPLOYEE="+parseFloat(Comments.Employee)
				+ "&ECM-CMT-TYPE=TR"
				+ "&ECM-DATE="+Comments.Date

	for(var i=0,j=1;i<lines.length;i++,j++)
	{
		if(i<lines.length)
			lines[i] = unescape(DeleteIllegalCharacters(escape(lines[i])))
//PT 160079
		object.field += "&LINE-FC"+j+"=A"
			// PT 127924
			// + "&ECM-SEQ-NBR"+j+"="	+ j
			+ "&ECM-CMT-TEXT"+j+"="	+ escape(lines[i])
	}
	
	object.dtlField = "LINE-FC;ECM-CMT-TEXT";
	object.debug = false;
	object.func = "parent.RecordsAdded_Comments()"
	AGS(object,"jsreturn")
}

/**********************************************************************************************
 Check for any error messages. If there are none then recall DME so the window gets reset and
 toggle the comments icon on the parent window.
**********************************************************************************************/
function RecordsAdded_Comments()
{
	Comments.commentsWindow.seaAlert(self.lawheader.gmsg);

	if(self.lawheader.gmsgnbr == "000")
	{
		ToggleSwitch = true;
		GetEmpComment(true);
	}
}

/**********************************************************************************************
 Delete any illegal characters that will not make it through AGS.
**********************************************************************************************/
function DeleteIllegalCharacters(myAry)
{
	var retval = '';
	for(var k=0;k<myAry.length;k++)
	{
		if(myAry.charAt(k)=="%" && myAry.charAt(k+1)=="0" &&
		  (myAry.charAt(k+2)=="A" || myAry.charAt(k+2)=="D"))
		{
			k = k+2;
			// PT 127924 cariage return should be replaced by a space
			// also, ES01.1 should not remove trailing spaces of each line
			// retval += '';
			retval += ' ';
		}
		else
			retval += myAry.charAt(k);
	}
	return retval;
}

/**********************************************************************************************
 Split the textarea value into 60 character lines and store them into an array.
**********************************************************************************************/
function SeparateTextArea(text,val)
{
	var ary = new Array(0);
	for(var i=0;text.length>0;i++)
	{
		if(text.length<val)
		{
			ary[i] = text.substring(0,text.length)
			break;
		}
		ary[i] = text.substring(0,val);
		text = text.substring(val,text.length)
	}
	return ary;
}

/*
 *		Save Changes Functionality
 */
 
var fncSaveChanges = "";
var hSaveChanges;
var lpcsView;

function SaveChanges(CallBack, View)
{
	fncSaveChanges = CallBack
	lpcsView = View;
	
	if (styler && styler.showLDS && typeof(window["DialogObject"]) == "function")
	{
	    window.DialogObject.prototype.getPhrase = function(phrase)
		{
			if (!userWnd && typeof(window["findAuthWnd"]) == "function")
			{
			    userWnd = findAuthWnd(true);	
			}
		        
			if (userWnd && userWnd.getSeaPhrase)
			{
				var retStr = userWnd.getSeaPhrase(phrase.toUpperCase(), "ESS");
				return (retStr != "") ? retStr : phrase;
			}
			else
			{
			    return phrase;
			}    
		}        
        
		var messageDialog = new window.DialogObject("/lawson/webappjs/", null, styler);
		messageDialog.pinned = true;
		messageDialog.getPhrase = function(phrase)
		{
			if (!userWnd && typeof(window["findAuthWnd"]) == "function")
			{
			    userWnd = findAuthWnd(true);	
			}
		        
			if (userWnd && userWnd.getSeaPhrase)
			{
			    var retStr = userWnd.getSeaPhrase(phrase.toUpperCase(), "TE");
			    return (retStr != "") ? retStr : phrase;
			}
			else
			{
			    return phrase;
			}            
		}
                
		var msgReturn = messageDialog.messageBox(getSeaPhrase("SAVE_CHANGES","TE"), "yesnocancel", "question", window, false, "", FireFoxSaveChangesDone);
		if (typeof(msgReturn) == "undefined")
		{
			return;
		}
		SaveChangesUserAction(msgReturn);
	}
	else
	{
		hSaveChanges = window.open("/lawson/xhrnet/ui/windowplain.htm?func=opener.writeSaveChangesWindow('"+View+"')", "SAVECHANGES", "resizable=no,toolbar=no,status=no,height=140,width=350")
	}
}

function FireFoxSaveChangesDone(msgWin)
{
    SaveChangesUserAction(msgWin.returnValue);
}

function SaveChangesUserAction(action)
{
    if (action == "yes")
    {
        if (lpcsView == "Summary")
        {
            SaveChanges_Clicked(lpcsView);
        }
        else
        {
            SaveChanges_Clicked();
        }
    }
    else if (action == "no")
    {
        DoNotSaveChanges_Clicked();    
    }
}
	
function writeSaveChangesWindow(View)
{
	var html = '<div style="padding:10px;padding-top:25px">'
	html += '<table border=0 cellpadding=0 cellspacing=0 style="width:100%">'
	html += '<tr><td class="plaintablecell">'+getSeaPhrase("SAVE_CHANGES","TE")
	html += '</td></tr>'
	html += '<tr><td class="plaintablecell">'
	if(View == "Summary")
		html += uiButton(getSeaPhrase("SAVE","TE"),"parent.opener.SaveChanges_Clicked('Summary');return false;")
	else
		html += uiButton(getSeaPhrase("SAVE","TE"),"parent.opener.SaveChanges_Clicked();return false;")
	html += uiButton(getSeaPhrase("NO","TE"),"parent.opener.DoNotSaveChanges_Clicked();return false;")
	html += uiButton(getSeaPhrase("CANCEL","TE"),"parent.opener.hSaveChanges.close();return false;")
	html += '</td></tr>'
	html += '</table>'
	html += '</div>'
	hSaveChanges.document.body.innerHTML = html
}

function SaveChangesDone()
{
	if(DoesObjectExist(fncSaveChanges) && fncSaveChanges != "")
	{
		eval(fncSaveChanges)
		return true;
	}
	else
		return false;
}

function SaveChanges_Clicked()
{
	if(arguments.length>0)
		SummaryUpdate();
	else
		UpdateTimeCard(lpcsView, "SavingChanges")

	if(typeof(hSaveChanges) != "undefined" && !hSaveChanges.closed)
		hSaveChanges.close()
}

function DoNotSaveChanges_Clicked()
{
	eval(fncSaveChanges)
	if(typeof(hSaveChanges) != "undefined" && !hSaveChanges.closed)
		hSaveChanges.close()
}
 