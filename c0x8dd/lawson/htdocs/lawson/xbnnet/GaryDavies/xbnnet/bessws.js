// Version: 8-)@(#)@(201111) 09.00.01.06.00
// $Header: /cvs/cvs_archive/applications/webtier/shr/src/xbnnet/bessws.js,v 1.10.2.5 2011/06/21 16:10:37 brentd Exp $
var MailTo = ""
var ColorArray = new Array()
ColorArray[0]='"D8F2FF"'
ColorArray[1]='"FFFFD8"'
ColorArray[2]='"FFE0F4"'
ColorArray[3]='"E0FFF4"'
ColorArray[4]='"FFE0E0"'
ColorArray[5]='"EAE0FF"'
ColorArray[6]='"E0FFF4"'
ColorArray[7]='"FFE0F4"'
ColorArray[8]='"D8F2FF"'
ColorArray[9]='"EAE0FF"'
var baseurl='/lawson/xbnnet/'
var actiontaken=0
var oldelected=new Array()
var OldElectedPlans=new Array()
var clearGroup=false
var changedPlan=false
var quitting=false
var _BaseDate 
var _DateRange 
var _BaseDateWord 
var flexFlag=false
var cantEnroll=new Array()
var notAvailable=new Array()
var enrollError=new Array()
var oldElectionsIn=""
var alreadyElect="N"
var empname=""
var lastname
var firstname
var fullname
var nickname
var emailaddress
var selectedPlan=-1
var selectedPlanInGrp = new Array()
// Benefit table spacing parameters
var TableWidth="600"
var SummaryWidth="450"
var TableSpacer="3"
var CellPadding="2"
var CellSpacing="1"
var currentdate
var newdate
var currentmult=1
var status=""
var errorPlans=new Array()
var errorGroups=new Array()
var flexcredits=""  //   Y/N
var dependents = new Array()
var BenefitRules=new Array()
var EligPlanGroups=new Array()
var CurrentPlanGroup=""				 //placeholder for the first record in the EligPlans array for the current plan group
var foundEligPlan=new Array()
var EligFlexExist=false
var CurrentFlexExist=false
var CurrentBens=new Array()			 //array to hold all current Benefits if there are any
var planname=""						 //placeholder for the current selected plan
var EligPlans=new Array()			 //array to hold all eligible plans for employee
var CurrentEligPlan=""
var SelectedPlan=new Array()		 //specific information gathered about current plan
var ElectedPlans=new Array()		 //array to hold plans for new year
var DependentBens=new Array()		 //array to hold dependent benefits for updating to server
var oldDepBens=new Array()
var CurrentDeps=new Array()
CurrentDeps[0]=""
var FlexPlan=new Array()
var updatetype=''
var gotError=false
var msgNbr=0
var LoadError=false
var choices= new Array()
var currentChoice=0
var changes= new Array()
var currentChange=0
var choice=0
var REC_TYPE=0
var HasCurrentBens=0
var LastDoc=new Array()
var maxdocnum=0
var currentdoc=0
var GotNewFlex=false
var fromupdatetype=""
var pathnm=self.location.pathname
var indx=pathnm.lastIndexOf('/')
pathnm=pathnm.substring(0,indx+1)
var EMP_CONT_TYPE=""
var company = 0
var employee = 0
var emppayfreq = 0
var prodline = ""
var dateofbirth = ""
var empsalary = ""
var salaryclass = ""
var ficanbr = ""
var preaft_flag
var costdivisor=""
var contdivisor=""
var CurrentBenDate = ""
var selectedCoverage=""
var NbrHours=""
var NbrRecs = 0
var keepflag="Y"
var TC_val = ""
var HK_val = ""
var termopt = "" 
//BS10 PageDown "Position-To" Fields
var PT_Company = ""
var PT_Employee = ""
var PT_Process_Level = ""
var PT_Family_Status = ""
var PT_Group_Name = ""
var PT_Process_Order = ""
var PT_Plan_Type = ""
var PT_Plan_Code = ""
var PT_Ben_Start_Date = ""
//Final summary and "Show Elections" totals
var EmpFlexTotal = 0			// From BS11
var EmpNegPreTaxTotal = 0		// Total of all negative employee pre-tax amount contributions
var BenCreditTotal = 0			// Total of all employee flex credits + all negative pre-tax amount contributions
var FlexCreditTotal = 0			// EmpFlexTotal + BenCreditTotal
var EmpPreTaxTotal = 0			// Total of all employee pre-tax amount contributions
var CreditsLessPreTax = 0		// FlexCreditTotal - EmpPreTaxTotal
var AddToGrossPercent = 0		// From BS11
var AddedToPay = 0				// CreditsLessPreTax * AddToGrossPercent
var ForfeitedDifference = 0		// CreditsLessPreTax - AddedToPay
var EmpAfterTaxTotal = 0		// Total of all employee after-tax amount contributions
var EmpPreTaxPercentTotal = 0	// Total of all employee pre-tax percent contributions
var EmpAfterTaxPercentTotal = 0 // Total of all employee after-tax percent contributions
var TaxPercentTotal = 0			// Pre-tax % + after-tax %
var CompanyTotal = 0			// Total of all company amount contributions
var FamilySts=''
var FamilyStsEffectDate=''
var pfServiceObj;
var printSummary = false;
var emailSummary = false;