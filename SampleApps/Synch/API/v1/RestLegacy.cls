Class SampleApps.Synch.API.v1.RestLegacy Extends %CSP.REST
{
Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/orders" Method="GET" Call="ListOrders"/>
<Route Url="/orders/:topMax" Method="GET" Call="ListOrders"/>
<Route Url="/items" Method="GET" Call="ListItems"/>
<Route Url="/items/:topMax" Method="GET" Call="ListItems"/>
<Route Url="/customers/:topMax" Method="GET" Call="ListCustomers"/>
<Route Url="/customers" Method="GET" Call="ListCustomers"/>
<Route Url="/employees" Method="GET" Call="ListEmployees"/>
<Route Url="/employees/:topMax" Method="GET" Call="ListEmployees"/>
<Route Url="/order/:orderID" Method="GET" Call="GetOrder"/>
<Route Url="/order" Method="POST" Call="NewOrder"/>
<Route Url="/order" Method="PUT" Call="UpdateOrder"/>
<Route Url="/order/:orderID" Method="DELETE" Call="DeleteOrder"/>
<Route Url="/randomorder" Method="POST" Call="CreateRandomOrder"/>
<!-- Admin services to prepare SynchSet, Synchronize and query conflicts -->
<Route Url="/admin/prepsynch" Method="POST" Call="PrepSynch"/>
<Route Url="/admin/synchronize" Method="POST" Call="Synchronize"/>
<Route Url="/admin/conflicts/:topMax" Method="GET" Call="ListSynchConflicts"/>
<Route Url="/admin/conflicts" Method="GET" Call="ListSynchConflicts"/>
<!-- Echo services for test -->
<Route Url="/echo" Method="POST" Call="EchoPost"/>
<Route Url="/echo" Method="GET" Call="EchoGet"/>
<Route Url="/echo" Method="PUT" Call="EchoPut"/>
<Route Url="/echo" Method="DELETE" Call="EchoDelete"/>
<Route Url="/admin/echo" Method="POST" Call="EchoPost"/>
</Routes>
}

ClassMethod CreateRandomOrder() as %Status
{
	#dim tSC as %Status=$$$OK
	#dim tNewID as %String=""
	#dim tResult as %DynamicObject={}
	
	do ##class(SampleApps.Synch.Util).Populate(0,0,0,1,0)
	&SQL(select top 1 ID into :tNewID from SampleApps_Synch_Data.Order order by ID desc)
	
	set tResult.id = tNewID
	do tResult.%ToJSON()
	quit tSC
}

/// It prepares a synch file with all the changes to syncrhonize with another namespace in current or different instance
/// It expects a JSON object with the following format:
///  {
///			"syncID":			<integer - unique ID to identify this syncrhonization>,
///			"updateSyncTime":	<boolean - update or not automatically SyncTime table>,
///			"dir":				<directory path - directory where the file should be stored>,
///			"file":				<filename>,
///			"firstTrans":		<integer - transaction number from which we should start to gather DB changes to syncrhonize (by default it takes the value in SyncTime>,
///			"lastTrans":		<integer - transction number up to which we should gather DB changes to syncrhonize (by default, it will gather up to the last transaction registered>,
///			"GUID":				<target system GUID - the GUID of the target instance>,
///			"excludeNS":		<remote namespace - transactions associated to GUID+excludeNS will not be included in the file>
///	 }
///	Sample for tests - To generate synch file from our MASTER namespace to synchronize afterwards in  CLIENT
///		{"syncID":1000,"dir":"c:/Temp","excludeNS":"CLIENT"}
ClassMethod PrepSynch() as %Status
{
	#dim tSC as %Status=$$$OK
	#dim e as %Exception.AbstractException
	#dim tJSON as %DynamicObject={}
	#dim tResult as %DynamicObject={}
	
	try
	{
		set tJSON = tJSON.%FromJSON(%request.Content)
		do tJSON.%ToJSON()
		set tSC = ##class(SampleApps.Synch.Util).PrepareSync(tJSON.%Get("syncID",0),tJSON.%Get("updateSyncTime",1),tJSON.%Get("dir","."),tJSON.%Get("file",""),tJSON.%Get("firstTrans",0),tJSON.%Get("lastTrans",""),tJSON.%Get("GUID",""),tJSON.%Get("excludeNS",""),.tResult)
		
		do tResult.%ToJSON()
	}
	catch e
	{
		set tSC = e.AsStatus()
	}
	
	quit tSC
}

/// It will take that data to synchronize from a pFile stored in pDir. The info required will come from a JSON object with the format:
/// {
///		"syncID":		<integer - number that univocally identifies this synchronization>
///		"srcNS":		<string - name of namespace of origin - just used to create a file name if pFile is not include. Generated filename convention: sync<srcNS>-<syncID>.gbl >
///		"dir":			<string - dir path where the file is stored ("." by default)
///		"file":			<filename - file that stores the data to be synchronized>
/// }
/// Sample for tests - Synchronizing in CLIENT namespace with a file coming from MASTER namespace
///		{"syncID":1000,"dir":"c:/Temp","srcNS":"MASTER"}
ClassMethod Synchronize() as %Status
{
	#dim tSC as %Status=$$$OK
	#dim e as %Exception.AbstractException
	#dim tJSON as %DynamicObject={}
	#dim tResult as %DynamicObject={}
	
	try
	{
		set tJSON = tJSON.%FromJSON(%request.Content)
		//do tJSON.%ToJSON()
		set tSC = ##class(SampleApps.Synch.Util).Synchronize(tJSON.%Get("syncID",0),tJSON.%Get("srcNS",""),tJSON.%Get("dir","."),tJSON.%Get("file",""),.tResult)
		
		do tResult.%ToJSON()
	}
	catch e
	{
		set tSC = e.AsStatus()
	}
	
	quit tSC
}

/// Will receive data in body of request, in JSON format:
/// Example:  {"orderNum":1004,"employee":1,"customer":5,"dateOrder":"2000-07-11 06:14:11","item":23,"quantity":401,"price":446}
ClassMethod UpdateOrder() as %Status
{
	#dim tSC as %Status=$$$OK
	#dim e as %Exception.AbstractException
	#dim tJSON as %DynamicObject={}
	#dim tResult as %DynamicObject={}
	
	try
	{
		set tJSON = tJSON.%FromJSON(%request.Content)
		
		// In case of no info for some properties that would mean that those properties shouldn't be modified... to state that we assign a non-valid value with passed to changeOrder method.
		// There we will deal with that.
		set tResult = ##class(SampleApps.Synch.API.common).changeOrder(tJSON.%Get("orderNum",0),tJSON.%Get("item",-1),tJSON.%Get("employee",-1),tJSON.%Get("customer",-1),tJSON.%Get("dateOrder",""),tJSON.%Get("price",-1),tJSON.%Get("quantity",-1))

    	Set %response.ContentType="application/json"
    	do tResult.%ToJSON()
	}
	catch e
	{
		set tSC = e.AsStatus()
	}
	quit tSC
}

ClassMethod GetOrder(pID as %Integer) as %Status
{
	#dim tSC as %Status=$$$OK
	#dim e as %Exception.AbstractException
	
	try
	{
	
		set tObj = ##class(SampleApps.Synch.Data.Order).%OpenId(pID,,.tSC)
		if $IsObject(tObj) 
		{
			Set %response.ContentType="application/json"
			do tObj.%JSONExport()
		}
	}
	catch e
	{
		set tSC = e.AsStatus()
	}
	
	quit tSC
}

/// Register a new Order in the database. It's a demo. BE AWARE: It doesn't validate if referenced object exist
ClassMethod NewOrder() as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    #dim %request as %CSP.Request
    #dim tJSON as %DynamicObject={}
    #dim tResult as %DynamicObject={}
    
    Try 
    {    
    	// we should receive a JSON in the request body
    	set tJSON = tJSON.%FromJSON(%request.Content)
    	
    	set tResult = ##class(SampleApps.Synch.API.common).newOrder(tJSON.item,tJSON.employee,tJSON.customer,tJSON.dateOrder,tJSON.price,tJSON.quantity)
    	
    	Set %response.ContentType="application/json"
    	do tResult.%ToJSON()
    }
    catch (e)
    {
    	set tSC = e.AsStatus()
    }
    
    quit tSC
}

/// Deleter order with ID = pOrdeId
ClassMethod DeleteOrder(pOrderId as %Integer) as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    #dim tResult as %DynamicObject={}
    
    Try 
    {    
    	set tResult = ##class(SampleApps.Synch.API.common).deleteOrder(pOrderId)
     	
     	Set %response.ContentType="application/json"
    	do tResult.%ToJSON()
    }
    catch (e)
    {
    	set tSC = e.AsStatus()
    }
    
    quit tSC
 	
}

ClassMethod ListSynchConflicts(pTop as %SmallInt=10) as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    #dim tSQL As %SQL.Statement
    #dim tRS as %SQL.StatementResult
    #dim tList as %DynamicArray=[]
    #dim tJSONstr as %String=""
    #dim tResult as %DynamicObject={"conflicts":""}
    #dim tJSON as %DynamicObject={}
    
    if pTop'>0 set pTop = 1
    
    Try 
    {    	
    	set tRS = ##class(%SQL.Statement).%ExecDirect(.tSQL,"select top "_pTop_" ID from SampleApps_Synch_Data.SynchConflict")
    
    	//$$$THROWONERROR() ... here we should control SQL errors
    
    	while tRS.%Next(.tSC)
    	{
    		set tJSONstr=""
    		do ##class(SampleApps.Synch.Data.SynchConflict).%OpenId(tRS.%GetData(1)).%JSONExportToString(.tJSONstr)
    		
    		set tJSON = tJSON.%FromJSON(tJSONstr)
    		do tList.%Push(tJSON)
   		}
   		
   		set tResult = {"conflicts":(tList)}
   		//break
   		Set %response.ContentType="application/json"
   		do tResult.%ToJSON()
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}

ClassMethod ListOrders(pTop as %SmallInt=10) as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    #dim tSQL As %SQL.Statement
    #dim tRS as %SQL.StatementResult
    #dim tList as %DynamicArray=[]
    #dim tResult as %DynamicObject={"orders":""}
    #dim tJSON as %DynamicObject={}
    
    if pTop'>0 set pTop = 1
    
    Try 
    {    	
    	set tRS = ##class(%SQL.Statement).%ExecDirect(.tSQL,"select top "_pTop_" JSON_OBJECT('id':%ID,'orderNum':orderNum,'employee':employee,'dateOrder':dateOrder,'customer':customer,'item':item,'price':price,'quantity':quantity) from SampleApps_Synch_Data.Order")
    
    	//$$$THROWONERROR() ... here we should control SQL errors
    
    	while tRS.%Next(.tSC)
    	{
    		set tJSON={}
    		set tJSON = tJSON.%FromJSON(tRS.%GetData(1))
    		do tList.%Push(tJSON)
   		}
   		
   		set tResult = {"orders":(tList)}
   		
   		Set %response.ContentType="application/json"
   		do tResult.%ToJSON()
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}

ClassMethod ListItems(pTop as %SmallInt=10) as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    #dim tSQL As %SQL.Statement
    #dim tRS as %SQL.StatementResult
    #dim tList as %DynamicArray=[]
    #dim tResult as %DynamicObject={"items":""}
    #dim tJSON as %DynamicObject={}
    
    if pTop'>0 set pTop = 1
    
    Try 
    {    	
    	set tRS = ##class(%SQL.Statement).%ExecDirect(.tSQL,"select top "_pTop_" JSON_OBJECT('id':%ID,'code':code,'description':description,'minStock':minStock) from SampleApps_Synch_Data.Item")
    
    	//$$$THROWONERROR() ... here we should control SQL errors
    
    	while tRS.%Next(.tSC)
    	{
    		set tJSON={}
    		set tJSON = tJSON.%FromJSON(tRS.%GetData(1))
    		do tList.%Push(tJSON)
   		}
   		
   		set tResult = {"items":(tList)}
   		
   		Set %response.ContentType="application/json"
   		do tResult.%ToJSON()
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}

ClassMethod ListEmployees(pTop as %SmallInt=10) as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    #dim tSQL As %SQL.Statement
    #dim tRS as %SQL.StatementResult
    #dim tList as %DynamicArray=[]
    #dim tResult as %DynamicObject={"employees":""}
    #dim tJSON as %DynamicObject={}
    
    if pTop'>0 set pTop = 1
    
    Try 
    {    	
    	set tRS = ##class(%SQL.Statement).%ExecDirect(.tSQL,"select top "_pTop_" JSON_OBJECT('id':%ID,'empCode':empCode,'name':name) from SampleApps_Synch_Data.Employee")
    
    	//$$$THROWONERROR() ... here we should control SQL errors
    
    	while tRS.%Next(.tSC)
    	{
    		set tJSON={}
    		set tJSON = tJSON.%FromJSON(tRS.%GetData(1))
    		do tList.%Push(tJSON)
   		}
   		
   		set tResult = {"employees":(tList)}
   		
   		Set %response.ContentType="application/json"
   		do tResult.%ToJSON()
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}

ClassMethod ListCustomers(pTop as %SmallInt=10) as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    #dim tSQL As %SQL.Statement
    #dim tRS as %SQL.StatementResult
    #dim tList as %DynamicArray=[]
    #dim tResult as %DynamicObject={"customers":""}
    #dim tJSON as %DynamicObject={}
    
    if pTop'>0 set pTop = 1
    
    Try 
    {    	
    	set tRS = ##class(%SQL.Statement).%ExecDirect(.tSQL,"select top "_pTop_" JSON_OBJECT('id':%ID,'code':code,'custName':custName,'HQAddress':HQAddress) from SampleApps_Synch_Data.Customer")
    
    	//$$$THROWONERROR() ... here we should control SQL errors
    
    	while tRS.%Next(.tSC)
    	{
    		set tJSON={}
    		set tJSON = tJSON.%FromJSON(tRS.%GetData(1))
    		do tList.%Push(tJSON)
   		}
   		
   		set tResult = {"customers":(tList)}
   		
   		Set %response.ContentType="application/json"
   		do tResult.%ToJSON()
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}

ClassMethod EchoGet() as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    #dim tEcho As %DynamicObject={}
    
    Try 
    {
    	set tEcho = {"test":"test value"}

    	Set %response.ContentType="application/json"
    	do tEcho.%ToJSON()
    	
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}

ClassMethod EchoPost() as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    Try 
    {
  
		Set %response.ContentType=%request.ContentType
	    
	    do %request.Content.OutputToDevice()
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}

ClassMethod EchoPut() as %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    
    Try 
    {
  
		Set %response.ContentType=%request.ContentType
	    
	    do %request.Content.OutputToDevice()
    }
    catch (e) 
    {
        Set tSC=e.AsStatus()
    }
    
    Quit tSC
}
}