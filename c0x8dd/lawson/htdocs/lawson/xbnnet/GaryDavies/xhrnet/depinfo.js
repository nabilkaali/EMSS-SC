// Version: 8-)@(#)@(201111) 09.00.01.06.00
// $Header: /cvs/cvs_archive/applications/webtier/shr/src/xhrnet/depinfo.js,v 1.3.2.2 2005/02/18 20:24:59 brentd Exp $
var DepInfo = new Array()
var CalledDepInfo = false

function GetDepInfo(prodline, company, employee, fields, functocall, cond, framename)
{
	framename = (framename)?framename:"jsreturn"
	if (!fields || typeof(fields) == "undefined" || fields == null || fields == "")
	{
		fields = "label-name-1;last-name-pre;name-suffix;middle-init;last-name;first-name;"
		+ "rel-code.description;hm-phone-nbr;hm-phone-cntry;wk-phone-nbr;wk-phone-cntry;"
		+ "wk-phone-ext;rel-code;addr1;addr2;addr3;addr4;city;state;zip;birthdate;placement-date;"
		+ "adoption-date;seq-nbr;emp-address;dep-type;sex;student;disabled;smoker;fica-nbr;country-code;"
		+ "employee.addr1;employee.addr2;employee.addr3;employee.addr4;employee.city;employee.state;"
		+ "employee.zip;employee.country-code;employee.work-country;pa-employee.hm-phone-nbr;"
		+ "pa-employee.hm-phone-cntry;country.country-desc;active-flag;benefits.plan-type;" // PT 139145 - add HRDEPBEN field
		+ "primary-care"
	}
	DepInfo = new Array()
	CalledDepInfo = false
	
	var pObj 			= new DMEObject(prodline, "EMDEPEND")
		pObj.out 		= "JAVASCRIPT"
		pObj.index		= "emdset1"
		pObj.field 		= fields
		pObj.key 		= parseInt(company,10) + "=" + parseInt(employee,10)
		pObj.max 		= "600"	
	if (cond) pObj.cond	= cond.toString()	
		pObj.func 		= "GetDepInfoDone('"+escape(framename,1)+"','"+escape(functocall,1)+"')"
		pObj.debug 		= false
	DME(pObj, framename)
}

function GetDepInfoDone(framename, functocall)
{
	framename = unescape(framename)
	functocall = unescape(functocall)
	var dmeFrame = eval("self."+framename)
	
	DepInfo = DepInfo.concat(dmeFrame.record)
	
	if (dmeFrame.Next != "")
	{
		dmeFrame.location.replace(dmeFrame.Next)
		return
	}
	
	CalledDepInfo = true
	eval(functocall)
}