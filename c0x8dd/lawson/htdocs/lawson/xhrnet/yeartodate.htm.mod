<!DOCTYPE html>
<!--
// JRZ 8/28/08 Adding print button to year to date history
// JRZ 1/7/09 Adding logic to not display YTD info during payroll
-->
<html lang="en">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=IE8">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width" />
<meta http-equiv="Pragma" content="No-Cache">
<title>Year to Date</title>
<link rel="stylesheet" type="text/css" id="default" title="default" href="/lawson/xhrnet/ui/default.css"/>
<script src="/lawson/webappjs/commonHTTP.js"></script>
<script src="/lawson/webappjs/data.js"></script>
<script src="/lawson/xhrnet/waitalert.js"></script>
<script src="/lawson/xhrnet/esscommon80.js"></script>
<script src="/lawson/xhrnet/yeartodate.js"></script>
<script src="/lawson/webappjs/user.js"></script>
<script src="/lawson/xhrnet/xml/xmlcommon.js"></script>
<script src="/lawson/xhrnet/xml/xmldateroutines.js"></script>
<script src="/lawson/xhrnet/ui/ui.js"></script>
<script src="/lawson/webappjs/javascript/objects/StylerBase.js?emss"></script>
<script src="/lawson/webappjs/javascript/objects/emss/StylerEMSS.js"></script>
<script src="/lawson/webappjs/javascript/objects/Sizer.js"></script>
<script src="/lawson/webappjs/javascript/objects/ActivityDialog.js"></script>
<script src="/lawson/webappjs/javascript/objects/OpaqueCover.js"></script>
<script src="/lawson/webappjs/javascript/objects/Dialog.js"></script>
<!-- JRZ 1/7/09 Adding in St. Luke's pay period interface through stlukescycles.js -->
<script src="/lawson/xhrnet/stlukescycles.js"></script>
<script>
var detailHtml;
var selectedYear;
//NOTE: The FUTUREPAYMTS setting has been moved to the xhrnet/xml/config/emss_config.xml file.
var thisYr = ymdtoday.substring(0,4);
var rulesObj;

function StartPayChecksProgram()
{
	authenticate("frameNm='jsreturn'|funcNm='AuthenticationComplete()'|desiredEdit='EM'");
}

function AuthenticationComplete()
{
	if (window.print)
	{
		var printLbl = getSeaPhrase("PRINT","ESS");
		var printBtn = document.getElementById("printbtn");
		printBtn.innerText = printLbl;
		printBtn.setAttribute("title", printLbl);
		printBtn.setAttribute("aria-label", printLbl);
		self.printframe.stylePage();
	}	
    stylePage();
	// Set the task title.
	var title = getSeaPhrase("YEAR_TO_DATE","ESS");
	setWinTitle(title);
	setWinTitle(getSeaPhrase("YTD_DTL","ESS"), self.ytddetail);
	setTaskHeader("header",title,"Pay");
	showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), GetRules);
}

function GetRules()
{	
	var sysComp = authUser.company.toString();
	for (var i=sysComp.length; i<4; i++)
		sysComp = "0" + sysComp;
	var dmeObj = new DMEObject(authUser.prodline,"sysrules");
	dmeObj.out = "JAVASCRIPT";
	dmeObj.index = "syrset1";
	dmeObj.field = "task;system;key1;alphadata1;"
	dmeObj.key = "PAY=PR=" + sysComp;
	dmeObj.max = "1";
	dmeObj.func = "SetRules()";
	dmeObj.debug = false;
	DME(dmeObj,"jsreturn");
}

function SetRules()
{
	if (self.jsreturn.NbrRecs)
	{	
		rulesObj = self.jsreturn.record[0];
		emssObjInstance.emssObj.zeroNetChecks = (Number(rulesObj.alphadata1_1) == 2) ? false : true;	
		emssObjInstance.emssObj.maskBankInfo = (Number(rulesObj.alphadata1_2) == 2) ? true : false;
		emssObjInstance.emssObj.futurePayments = (Number(rulesObj.alphadata1_3) == 2) ? true : false;
		emssObjInstance.emssObj.periodStartDate = (Number(rulesObj.alphadata1_4) == 2) ? true : false;
		emssObjInstance.emssObj.calcHourlyRate = (Number(rulesObj.alphadata1_5) == 2) ? true : false;
		emssObjInstance.emssObj.payStubAddress = (Number(rulesObj.alphadata1_6) == 2) ? "supplemental" : "home";
	}	
	GetQuartwage("PaintPayCheckHistory()");
}

//////////////////////////////////////////////////////////////////////////////////////////
// Paint front page containing the years user can drill down
//
function PaintPayCheckHistory()
{
	var strHtml = "";	
// MOD BY BILAL
	setTaskHeader("header",getSeaPhrase("YEAR_TO_DATE","ESS") + " for " + PayChecks.EmployeeName ,"Pay");
// END OF MOD
	if (PayChecks.Year.length == 0)
		strHtml += '<div class="fieldlabelboldleft" style="padding-top:5px;padding-left:5px">'+getSeaPhrase("NO_YTD_INFO","ESS")+'</div>';
	else 
	{
		strHtml += '<div style="padding-top:3px">';
    	strHtml += '<table border="0" cellspacing="0" cellpadding="0" width="100%" role="presentation">';
		strHtml += '<tr><td class="fieldlabelbold" style="width:50%"><label for="year">'+getSeaPhrase("SELECT_A_YEAR","ESS")+'</label></td>';
		strHtml += '<td class="plaintablecell" style="width:50%" nowrap><select class="inputbox" id="year" name="year" ';
		strHtml += 'title="'+getSeaPhrase("VIEW_PAYMENTS","ESS")+'" onchange="GetYTDForYear(this)">';
		strHtml += '<option value="">';
		for (var i=0; i<PayChecks.Year.length; i++)
		{
			// if future payments should not display, do not allow a future year to be selected.
			if (emssObjInstance.emssObj.futurePayments || (Number(PayChecks.Year[i].Year) <= Number(thisYr)))
				strHtml += '<option value="'+PayChecks.Year[i].Year+'">'+FormatDte8(PayChecks.Year[i].Year);
		}
		strHtml += '</select></td></table></div>';
	}
	try 
	{
		document.getElementById("paneHeader").innerHTML = getSeaPhrase("YEARS","ESS");
		document.getElementById("paneBody").innerHTML = strHtml;
		styleElement(document.getElementById("year"));
	}
	catch(e) {}
	document.getElementById("yearselect").style.visibility = "visible";
	removeWaitAlert();
	fitToScreen();
}

function GetYTDForYear(selObj)
{
	var nextFunc = function()
	{
		selectedYear = "";
		selectedYear = selObj.options[selObj.selectedIndex].value;
		if (selectedYear != "") 
		{
			if (PayChecks.YearDetail[selectedYear])
				PaintPaymentDetail(Number(selectedYear));
			else 
			{
				// if future payments should be displayed or we are viewing payments for a prior year, pull the records from the QUART files;
				// otherwise pull them from PAYMASTER and PAYDEDUCTN
				var thisYear = authUser.date.substring(0,4);
				if (emssObjInstance.emssObj.futurePayments || Number(selectedYear) < Number(thisYear))
					GetQuartDed(Number(selectedYear),"PaintPaymentDetail("+Number(selectedYear)+")");
				else
					GetYTDPaymentsForYear(Number(selectedYear),"PaintPaymentDetail("+Number(selectedYear)+")");
			}
		}
		else
			ClearYTDHistory();
	}
	showWaitAlert(getSeaPhrase("PROCESSING_WAIT","ESS"), nextFunc);
}

function ClearYTDHistory()
{
	HidePaymentLink();
	HidePrintButton();
	document.getElementById("ytddetail").style.visibility = "hidden";
	document.getElementById("paycheck").style.visibility = "hidden";
	self.paycheck.location.replace("/lawson/xhrnet/dot.htm");
	removeWaitAlert();
}

//////////////////////////////////////////////////////////////////////////////////////////
// Paint drill information
//
function PaintPaymentDetail(year)
{
	detailHtml = "";
	PayChecks.TotalWagesEarned(year);
	PayChecks.TotalDeductionsEarned(year);
	var pYearObj = PayChecks.FindYear(year);
	var tblHtml = "";
	var printButtonHtml = "";
// MOD BY BILAL
  // JRZ 1/7/09 Adding logic to lock out viewing of YTD if during payroll and display a helpful message
  var stlukescycles = new StLukesCycles();
  if(year >= thisYr && stlukescycles.isPayrollRunningToday()) {
      alert('Year to Date pay information cannot be viewed while payroll is running (Tuesday through Thursday).  Please check back on Friday.  Thank you for your patience.')
      return;
    }
  //~JRZ   
// END OF MOD


//////////////
//	WAGES	//
//////////////
	for (var i=0; i<pYearObj.Country.length; i++)
	{
		for(var j=0; j<pYearObj.Country[i].Currency.length; j++)
		{
			// Tables by country and currency: pYearObj.Country[i].Code+' - '+pYearObj.Country[i].Currency[j].Description
			tblHtml = '<table class="plaintableborder" border="0" cellspacing="0" cellpadding="0" width="100%" styler="list" summary="'+getSeaPhrase("TSUM_83","SEA",[''+year])+'">'
			+ '<caption class="offscreen">'+getSeaPhrase("TCAP_63","SEA",[''+year])+'</caption>'
			+ '<tr><th scope="col" class="plaintableheaderborder" style="text-align:center;width:47%">'+getSeaPhrase("PAY_TYPE","ESS")+'</th>'
			+ '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:26%">'+getSeaPhrase("HOURS","ESS")+'</th>'
			+ '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:27%">'+getSeaPhrase("WAGES","ESS")+'</th></tr>'
			var pWageObj = pYearObj.Country[i].Currency[j].Wages;
			for (var k=0; k<pWageObj.PaySumGrp.length; k++)
			{
 				if (pWageObj.PaySumGrp[k].TotalHours || pWageObj.PaySumGrp[k].TotalWages)
				{
					tblHtml += '<tr><td class="plaintablecellborderright" style="width:47%" nowrap>'
					+ ((pWageObj.PaySumGrp[k].Description)?pWageObj.PaySumGrp[k].Description:'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'
					+ ((roundToPennies(pWageObj.PaySumGrp[k].TotalHours))?roundToPennies(pWageObj.PaySumGrp[k].TotalHours):'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:27%" nowrap>'
					+ ((roundToPennies(pWageObj.PaySumGrp[k].TotalWages))?roundToPennies(pWageObj.PaySumGrp[k].TotalWages):'&nbsp;')+'</td></tr>'
				}
			}
			tblHtml += '<tr><td class="plaintablecellboldborderright" style="width:47%" nowrap>'
			+ getSeaPhrase("TOTAL","ESS")+'</td>'
			+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'+((roundToPennies(pWageObj.TotalHours))?roundToPennies(pWageObj.TotalHours):'&nbsp;')+'</td>'
			+ '<td class="plaintablecellborderright" style="width:27%" nowrap>'+((roundToPennies(pWageObj.TotalWages))?roundToPennies(pWageObj.TotalWages):'&nbsp;')+'</td>'
			+ '</tr></table>'
			var titleStr = getSeaPhrase("WAGES","ESS")+' - '+pYearObj.Country[i].Currency[j].Description+', '+pYearObj.Country[i].Code;
			detailHtml += uiTable(self.ytddetail,titleStr,tblHtml);
			if (pYearObj.Country[i].Code == "CA")
				detailHtml += CAPayCheckFormat(pYearObj, i, j);
			else
				detailHtml += USPayCheckFormat(pYearObj, i, j);
		}
	}
	// hide the paycheck listing, if it is visible
	document.getElementById("paycheck").style.visibility = "hidden";
	self.paycheck.location.replace("/lawson/xhrnet/dot.htm");
	document.getElementById("ytddetail").style.visibility = "visible";
	var detailExists = true;
	if (detailHtml == "") 
	{
		detailExists = false;
		detailHtml = '<div class="fieldlabelboldleft" style="padding-top:5px;padding-left:5px">'+getSeaPhrase("NO_PAYMENT_INFO","ESS")+' '+year+'.</div>'
	}
	try 
	{
		self.ytddetail.document.getElementById("paneBody").innerHTML = detailHtml;
	}
	catch(e) {}
	self.ytddetail.stylePage();
	self.ytddetail.setLayerSizes();
	if (detailExists)
	{	
		var toolTip = year+' - '+getSeaPhrase("PAY_DTL_FOR_YEAR","ESS");
		document.getElementById("paymentlink").innerHTML = '<a id="getPaymentsLink" styler="hyperlink" href="javascript:;" onclick="GetPaymentsForYear();return false" title="'+toolTip+'">'+getSeaPhrase("PAYMENT_DETAILS","ESS")+'<span class="offscreen"> - '+toolTip+'</span></a>';
		styleElement(document.getElementById("getPaymentsLink"));
		ShowPaymentLink();
		ShowPrintButton();
	}
	else
	{
    	HidePaymentLink();
    	HidePrintButton();
	}
    removeWaitAlert(getSeaPhrase("CNT_UPD_FRM","SEA",[self.ytddetail.getWinTitle()]));
    fitToScreen();
}

function GetPaymentsForYear()
{
	var nextFunc = function()
	{
		var selObj = document.getElementById("year");
		var selectedYear = Number(selObj.options[selObj.selectedIndex].value);	
		self.paycheck.location.replace("/lawson/xhrnet/paytyear.htm?year="+escape(selectedYear,1)+"&from=yeartodate");
		document.getElementById("yearselect").style.zIndex = "2";
		document.getElementById("ytddetail").style.zIndex = "2";
		document.getElementById("paycheck").style.zIndex = "1";
		HidePaymentLink();
		//document.getElementById("paycheck").style.visibility = "visible";
	};
	showWaitAlert(getSeaPhrase("RETRIEVE_PAYMENT_INFO","ESS"), nextFunc);
}

function HideYTDDetail()
{
	document.getElementById("ytddetail").style.visibility = "hidden";
	HidePrintButton();
	var toolTip = getSeaPhrase("BACK_TO_YTD","ESS");
	document.getElementById("paymentlink").innerHTML = '<a id="backToYtdLink" styler="hyperlink" href="javascript:;" onclick="BackToYearToDate();return false" title="'+toolTip+'">'+toolTip+'</a>';
	styleElement(document.getElementById("backToYtdLink"));
}

function ShowPrintButton()
{
	if (window.print)
		document.getElementById("printbtn").style.visibility = "visible";
}

function HidePrintButton()
{
	if (window.print)
		document.getElementById("printbtn").style.visibility = "hidden";
}

function ShowPaymentLink()
{
	document.getElementById("paymentlayer").style.visibility = "visible";	
}

function HidePaymentLink()
{
	document.getElementById("paymentlayer").style.visibility = "hidden";	
}

function BackToYearToDate()
{
	var selObj = document.getElementById("year");
	GetYTDForYear(selObj);
}

//////////////////////////////////////////////////////////////////////////////////////////
// United states and default view
//
function USPayCheckFormat(pYearObj, i, j)
{
	var Index = 1;
	var tblStr = "";
	var rtnStr = "";
//////////////////////////////////////
//	TAXES & DEDUCTIONS - US FORMAT	//
/////////////////////////////////////
	while (Index < 7)
	{
		if (DoesSectionContainValues(Index, pYearObj.Country[i].Currency[j].Ded.DeductionGroups))
		{
			var titleStr = null;
			var sumStr = "";
			var capStr = "";
			switch (Index)
			{
				case 1:	titleStr = getSeaPhrase("TAXES","ESS"); sumStr = getSeaPhrase("TSUM_84","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_63","SEA",[''+pYearObj.Year]); break;
				case 2:	titleStr = getSeaPhrase("PRE_TAX_DEDUCTIONS","ESS"); sumStr = getSeaPhrase("TSUM_86","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_65","SEA",[''+pYearObj.Year]); break;
				case 3:	titleStr = getSeaPhrase("AFTER_TAX_DEDUCTIONS","ESS"); sumStr = getSeaPhrase("TSUM_87","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_66","SEA",[''+pYearObj.Year]); break;
				case 4:	titleStr = getSeaPhrase("ADD_TO_NET_PAY","ESS"); sumStr = getSeaPhrase("TSUM_88","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_67","SEA",[''+pYearObj.Year]); break;
				case 5:	titleStr = getSeaPhrase("COMPANY_TAXES","ESS"); sumStr = getSeaPhrase("TSUM_85","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_64","SEA",[''+pYearObj.Year]); break;
				case 6:	titleStr = getSeaPhrase("COMPANY_DEDUCTIONS","ESS"); sumStr = getSeaPhrase("TSUM_89","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_68","SEA",[''+pYearObj.Year]); break;
				default: break;
			}			
			tblStr = '<table class="plaintableborder" border="0" cellspacing="0" cellpadding="0" width="100%" styler="list" summary="'+sumStr+'">'
			+ '<caption class="offscreen">'+capStr+'</caption>'
			+ '<tr><th scope="col" class="plaintableheaderborder" style="text-align:center;width:47%">'+getSeaPhrase("DEDUCTION","ESS")+'</th>'
			+ '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:26%">'+getSeaPhrase("AMOUNT","ESS")+'</th>'
			if (Index == 1 || Index == 5)
				tblStr += '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:27%">'+getSeaPhrase("TAXABLE_WAGES","ESS")+'</th>';
			else
				tblStr += '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:27%">&nbsp;</th>';
			tblStr += '</tr>';
			var TotalAmount = 0;
			var pDedObj = pYearObj.Country[i].Currency[j].Ded;
			for (var k=0; k<pDedObj.DeductionGroups.length; k++)
			{
				if ((pDedObj.DeductionGroups[k].Section == 1 || pDedObj.DeductionGroups[k].Section == 5) && (pDedObj.DeductionGroups[k].Section == Index))
				{
					tblStr += '<tr><td class="plaintablecellborderright" style="width:47%" nowrap>'
					+ ((pDedObj.DeductionGroups[k].Description)?pDedObj.DeductionGroups[k].Description:'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'
					+ ((roundToPennies(pDedObj.DeductionGroups[k].TotalAmount))?roundToPennies(pDedObj.DeductionGroups[k].TotalAmount):'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:27%" nowrap>'
					+ ((roundToPennies(pDedObj.DeductionGroups[k].TotalWages))?roundToPennies(pDedObj.DeductionGroups[k].TotalWages):'&nbsp;')+'</td></tr>';
					TotalAmount += (roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount)))?Number(roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount))):Number(0);
				}
				else if ((pDedObj.DeductionGroups[k].Section == 2 || pDedObj.DeductionGroups[k].Section == 3 || pDedObj.DeductionGroups[k].Section == 4 || pDedObj.DeductionGroups[k].Section == 6)
				&& (pDedObj.DeductionGroups[k].Section == Index))
				{
					tblStr += '<tr><td class="plaintablecellborderright" style="width:47%" nowrap>'
					+ ((pDedObj.DeductionGroups[k].Description)?pDedObj.DeductionGroups[k].Description:'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'
					+ ((roundToPennies(pDedObj.DeductionGroups[k].TotalAmount))?roundToPennies(pDedObj.DeductionGroups[k].TotalAmount):'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:27%" nowrap>&nbsp;</td></tr>';
					TotalAmount += (roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount)))?Number(roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount))):Number(0);
				}
			}
			// Totals table row
			tblStr += '<tr><td class="plaintablecellboldborderright" style="width:47%" nowrap>'+getSeaPhrase("TOTAL","ESS")+'</td>'
			+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'+((roundToPennies(TotalAmount))?roundToPennies(TotalAmount):'&nbsp;')+'</td>'
			+ '<td class="plaintablecellborderright" style="width:27%" nowrap>&nbsp;</td></tr></table>';
			if (titleStr != null)
				rtnStr += uiTable(self.ytddetail,titleStr,tblStr);
		}
		Index++;
	}
	return rtnStr;
}

//////////////////////////////////////////////////////////////////////////////////////////
// Canadian view
//
function CAPayCheckFormat(pYearObj, i, j)
{
	var Index = 1;
	var tblStr = "";
	var rtnStr = "";
//////////////////////////////////////
//	TAXES & DEDUCTIONS - CA FORMAT	//
/////////////////////////////////////
	while (Index < 7)
	{
		if (DoesSectionContainValues(Index, pYearObj.Country[i].Currency[j].Ded.DeductionGroups))
		{
			var titleStr = null;
			var sumStr = "";
			var capStr = "";
			switch (Index)
			{
				case 1:	titleStr = getSeaPhrase("DEDUCTIONS","ESS"); sumStr = getSeaPhrase("TSUM_90","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_69","SEA",[''+pYearObj.Year]); break;
				case 2:	titleStr = getSeaPhrase("TAXABLE_BENEFITS","ESS"); sumStr = getSeaPhrase("TSUM_91","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_70","SEA",[''+pYearObj.Year]); break;
				case 3:	titleStr = getSeaPhrase("ADD_TO_NET_PAY","ESS"); sumStr = getSeaPhrase("TSUM_88","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_67","SEA",[''+pYearObj.Year]); break;
				case 4:	titleStr = getSeaPhrase("COMPANY_TAXES","ESS"); sumStr = getSeaPhrase("TSUM_85","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_64","SEA",[''+pYearObj.Year]); break;
				case 5:	titleStr = getSeaPhrase("COMPANY_DEDUCTIONS","ESS"); sumStr = getSeaPhrase("TSUM_89","SEA",[''+pYearObj.Year]); capStr = getSeaPhrase("TCAP_68","SEA",[''+pYearObj.Year]); break;
				default: break;
			}			
			tblStr = '<table class="plaintableborder" border="0" cellspacing="0" cellpadding="0" width="100%" styler="list" summary="'+sumStr+'">'
			+ '<caption class="offscreen">'+capStr+'</caption>'
			+ '<tr><th scope="col" class="plaintableheaderborder" style="text-align:center;width:47%">'+getSeaPhrase("DEDUCTION","ESS")+'</th>'
			+ '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:26%">'+getSeaPhrase("AMOUNT","ESS")+'</th>'
			if (Index == 1 || Index == 4)
				tblStr += '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:27%">'+getSeaPhrase("TAXABLE_WAGES","ESS")+'</th>';
			else
				tblStr += '<th scope="col" class="plaintableheaderborder" style="text-align:center;width:27%">&nbsp;</th>';
			tblStr += '</tr>';
			var TotalAmount = 0;
			var pDedObj = pYearObj.Country[i].Currency[j].Ded;
			for (var k=0; k<pDedObj.DeductionGroups.length; k++)
			{
				if ((pDedObj.DeductionGroups[k].Section == 1 || pDedObj.DeductionGroups[k].Section == 4) && (pDedObj.DeductionGroups[k].Section == Index))
				{
					tblStr += '<tr><td class="plaintablecellborderright" style="width:47%" nowrap>'
					+ ((pDedObj.DeductionGroups[k].Description)?pDedObj.DeductionGroups[k].Description:'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'
					+ ((roundToPennies(pDedObj.DeductionGroups[k].TotalAmount))?roundToPennies(pDedObj.DeductionGroups[k].TotalAmount):'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:27%" nowrap>'
					+ ((roundToPennies(pDedObj.DeductionGroups[k].TotalWages))?roundToPennies(pDedObj.DeductionGroups[k].TotalWages):'&nbsp;')+'</td></tr>';
					TotalAmount += (roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount)))?Number(roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount))):Number(0);
				}
				else if((pDedObj.DeductionGroups[k].Section == 2 || pDedObj.DeductionGroups[k].Section == 3) && (pDedObj.DeductionGroups[k].Section == Index))
				{
					tblStr += '<tr><td class="plaintablecellborderright" style="width:47%" nowrap>'
					+ ((pDedObj.DeductionGroups[k].Description)?pDedObj.DeductionGroups[k].Description:'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'
					+ ((roundToPennies(pDedObj.DeductionGroups[k].TotalAmount))?roundToPennies(pDedObj.DeductionGroups[k].TotalAmount):'&nbsp;')+'</td>'
					+ '<td class="plaintablecellborderright" style="width:27%" nowrap>&nbsp;</td></tr>';
					TotalAmount += (roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount)))?Number(roundToPennies(Number(pDedObj.DeductionGroups[k].TotalAmount))):Number(0);
				}
			}
			// Totals table row
			tblStr += '<tr><td class="plaintablecellboldborderright" style="width:47%" nowrap>'+getSeaPhrase("TOTAL","ESS")+'</td>'
			+ '<td class="plaintablecellborderright" style="width:26%" nowrap>'+((roundToPennies(TotalAmount))?roundToPennies(TotalAmount):'&nbsp;')+'</td>'
			+ '<td class="plaintablecellborderright" style="width:27%" nowrap>&nbsp;</td></tr></table>';
			if (titleStr != null)
				rtnStr += uiTable(self.ytddetail,titleStr,tblStr);
		}
		Index++;
	}
	return rtnStr;
}

function printForm()
{
	var empName = (PayChecks && PayChecks.EmployeeName) ? PayChecks.EmployeeName : authUser.name; 
	var headerHtml = '<table summary="'+getSeaPhrase("TSUM_12","SEA")+'">'
	+ '<caption class="offscreen">'+getSeaPhrase("TCAP_9","SEA")+'</caption>'
	+ '<tr><th scope="col" colspan="2"></th></tr>'
	+ '<tr><th scope="row" class="plaintablecell"><span class="dialoglabel" style="padding:0px;margin:0px">'+getSeaPhrase("EMPLOYEE_NAME","ESS")+':</span></th>'
	+ '<td class="plaintablecell">'+empName+'</td></tr>'	
	+ '<tr><th scope="row" class="plaintablecell"><span class="dialoglabel" style="padding:0px;margin:0px">'+getSeaPhrase("EMPLOYEE_NUMBER","ESS")+':</span></th>'
	+ '<td class="plaintablecell">'+authUser.employee+'</td></tr>'					
	+ '</table><div style="height:20px">&nbsp;</div>';
    self.printframe.document.title = getSeaPhrase("YEAR_TO_DATE","ESS")+" - "+selectedYear;
	self.printframe.document.body.innerHTML = headerHtml+detailHtml;
	self.printframe.stylePage();
	self.printframe.document.body.style.overflow = "visible";
	self.printframe.focus();
	self.printframe.print();
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
	var winObj = getWinSize();
	var winWidth = winObj[0];	
	var winHeight = winObj[1];
	var contentLeftWidth;
	var contentLeftBorderWidth;
	var contentRightWidth;
	var contentRightBorderWidth;
	var contentTopHeight;
	var contentTopBorderHeight;	
	var contentHeight;
	var contentBorderHeight;
	if (window.styler && window.styler.showInfor)
	{
		contentLeftWidth = parseInt(winWidth*.40,10) - 10;
		var elmPad = 2;
		if ((navigator.appName.indexOf("Microsoft") >= 0) && (!document.documentMode || document.documentMode < 8))
			elmPad = 7;		
		contentLeftBorderWidth = contentLeftWidth + elmPad;
		contentRightWidth = parseInt(winWidth*.60,10) - 10;
		contentRightBorderWidth = contentRightWidth + elmPad;
		contentTopHeight = parseInt(winHeight*.20,10) - 30;
		contentTopBorderHeight = contentTopHeight + 30;		
		contentHeight = winHeight - 50;
		contentBorderHeight = contentHeight + 30;	
	}
	else if (window.styler && (window.styler.showLDS || window.styler.showInfor3))
	{
		contentLeftWidth = parseInt(winWidth*.40,10) - 20;
		contentLeftBorderWidth = (window.styler.showInfor3) ? contentLeftWidth + 7 : contentLeftWidth + 17;
		contentRightWidth = parseInt(winWidth*.60,10) - 18;
		contentRightBorderWidth = (window.styler.showInfor3) ? contentRightWidth + 7 : contentRightWidth + 17;
		contentTopHeight = parseInt(winHeight*.20,10) - 30;
		contentTopBorderHeight = contentTopHeight + 30;	
		contentHeight = winHeight - 75;
		contentBorderHeight = contentHeight + 30;				
	}
	else
	{
		contentLeftWidth = parseInt(winWidth*.40,10) - 10;
		contentLeftBorderWidth = contentLeftWidth;
		contentRightWidth = parseInt(winWidth*.60,10) - 10;
		contentRightBorderWidth = contentRightWidth;
		contentTopHeight = parseInt(winHeight*.20,10) - 30;
		contentTopBorderHeight = contentTopHeight + 24;	
		contentHeight = winHeight - 50;
		contentBorderHeight = contentHeight + 24;				
	}	
	try
	{
		document.getElementById("yearselect").style.width = parseInt(winWidth*.40,10) + "px";
		document.getElementById("yearselect").style.height = parseInt(winHeight*.20,10) + "px";
		document.getElementById("paneBorder").style.width = contentLeftBorderWidth + "px";
		document.getElementById("paneBorder").style.height = contentTopBorderHeight + "px";		
		document.getElementById("paneBodyBorder").style.width = contentLeftWidth + "px";
		document.getElementById("paneBodyBorder").style.height = contentTopHeight + "px";
		document.getElementById("paneBody").style.width = contentLeftWidth + "px";
		document.getElementById("paneBody").style.height = contentTopHeight + "px";
		document.getElementById("paneBody").style.overflow = "auto";		
	}
	catch(e) {}		
	if (self.ytddetail.onresize && self.ytddetail.onresize.toString().indexOf("setLayerSizes") >= 0)
		self.ytddetail.onresize = null;	
	try
	{
		document.getElementById("ytddetail").style.left = parseInt(winWidth*.40,10) + "px";
		document.getElementById("ytddetail").style.height = winHeight + "px";
		self.ytddetail.document.getElementById("paneBorder").style.width = contentRightBorderWidth + "px";
		self.ytddetail.document.getElementById("paneBorder").style.height = contentBorderHeight + "px";		
		self.ytddetail.document.getElementById("paneBodyBorder").style.width = contentRightWidth + "px";
		self.ytddetail.document.getElementById("paneBodyBorder").style.height = contentHeight + "px";
		self.ytddetail.document.getElementById("paneBody").style.width = contentRightWidth + "px";
		self.ytddetail.document.getElementById("paneBody").style.height = contentHeight + "px";
		self.ytddetail.document.getElementById("paneBody").style.overflow = "auto";		
	}
	catch(e) {}
	document.getElementById("paycheck").style.width = winWidth + "px";
	document.getElementById("paycheck").style.height = winHeight + "px";
	if (window.styler && window.styler.textDir == "rtl")
	{
		document.getElementById("yearselect").style.left = "";
		document.getElementById("yearselect").style.right = "0px";
		document.getElementById("paycheck").style.left = "";
		document.getElementById("paycheck").style.right = "0px";
		document.getElementById("ytddetail").style.left = "0px";
		document.getElementById("paymentlayer").style.left = "0px";
	}
	else
	{
		document.getElementById("ytddetail").style.left = parseInt(winWidth*.40,10) + "px";
		document.getElementById("paymentlayer").style.left = parseInt(winWidth*.40,10) + "px";
	}		
}
</script>
<!-- MOD BY BILAL -->
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
<body style="width:100%;height:100%;overflow:hidden" onload="StartPayChecksProgram()" onresize="fitToScreen()">
	<div id="yearselect" title="Navigation" style="visibility:hidden;position:absolute;left:0px;width:40%;top:32px;height:125px">
		<div id="paneBorder" class="paneborder">
			<table id="paneTable" border="0" height="100%" width="100%" cellpadding="0" cellspacing="0" role="presentation">
			<tr><td style="height:16px;vertical-align:top">
				<div id="paneHeader" class="paneheader" role="heading" aria-level="2">&nbsp;</div>
			</td></tr>
			<tr><td style="vertical-align:top">
				<div id="paneBodyBorder" class="panebodyborder" styler="groupbox">
					<div id="paneBody" class="panebody" tabindex="0"></div>
				</div>
			</td></tr>
			</table>
		</div>
	</div>
	<div id="paymentlayer" title="Navigation" class="plaintableheadertallwhite" style="visibility:hidden;position:absolute;height:24px;left:40%;width:60%;top:26px;z-index:999">
		<table border="0" cellspacing="0" cellpadding="0" width="100%" role="presentation"><tr>
			<td id="paymentlink" class="plaintableheadertallwhite" style="padding-left:0px;vertical-align:middle">&nbsp;</td>
			<td class="plaintableheadertallwhite" style="padding-left:0px;padding-top:0px;vertical-align:top">
				<div id="btnlayer" class="buttonBar"><button onclick="printForm();return false;" id="printbtn" class="button" type="button" role="button" title="Print" aria-label="Print" style="visibility:hidden" styler="pushbutton">Print</button></div>
			</td></tr>
		</table>
	</div>
	<iframe id="header" name="header" title="Header" level="1" tabindex="0" style="visibility:hidden;position:absolute;height:32px;width:803px;left:0px;top:0px" src="/lawson/xhrnet/ui/header.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="ytddetail" name="ytddetail" title="Secondary Content" level="4" tabindex="0" src="/lawson/xhrnet/ui/pane.htm" style="visibility:hidden;position:absolute;left:40%;width:60%;top:48px;height:464px" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="paycheck" name="paycheck" title="Main Content" level="3" tabindex="0" src="/lawson/xhrnet/dot.htm" style="visibility:hidden;position:absolute;left:0px;width:803px;top:32px;height:464px" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="printframe" name="printframe" title="Empty" src="/lawson/xhrnet/ui/pane.htm" style="visibility:hidden;height:0px;width:0px;" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
	<iframe id="jsreturn" name="jsreturn" title="Empty" style="visibility:hidden;height:0px;width:0px;" src="/lawson/xhrnet/dot.htm" frameborder="no" marginwidth="0" marginheight="0" scrolling="no"></iframe>
</body>
</html>
<!-- Version: 8-)@(#)@10.00.05.00.12 -->
<!-- $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/yeartodate.htm,v 1.4.2.73.2.1 2014/03/21 19:25:55 brentd Exp $ -->
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
