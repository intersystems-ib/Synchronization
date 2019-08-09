/// Helping methods and tools
Class SampleApps.Synch.Util Extends %RegisteredObject
{
/// Use with care. This method eliminates everything related to Object synchronization, from journalled transactions to historical previous synchronizations
ClassMethod Reset(pMasterNS as %String="MASTER") as %Status
{
	kill ^XXTRACE("SYNCH")
	set ^XXTRACE("SYNCH","NS") = pMasterNS  //During synchronization conflicts, this let the logic know which is the MasterNS (it should include the system GUID to really be uniquely identified)
	
	do ##class(SampleApps.Synch.Data.Order).%KillExtent()
	do ##class(SampleApps.Synch.Data.Customer).%KillExtent()
	do ##class(SampleAppps.Synch.Data.Employee).%KillExtent()
	do ##class(SampleApps.Synch.Data.Item).%KillExtent()
	
	do ##class(%ExtentMgr.GUID).%KillExtent()
	do ##class(%SYNC.SyncTime).%KillExtent()
	
	//Get data DB directory for current namespace
	do ##class(%SYS.Namespace).GetAllNSInfo($namespace,.tInfo)
	set tDBdir = $get(tInfo("GlobalDB","Directory"),"")
	
	//Delete from current DB whatever global related with Object synchronization
	set tSt = ##class(%SQL.Statement).%New()
	set tSC = tSt.%PrepareClassQuery("%SYS.GlobalQuery","DirectoryList")
	
	if tSC 
	{
		set tRS = tSt.%Execute(tDBdir,,"OBJ.*",1,,1)
		while tRS.%Next()
		{
			set tGblName = "^"_tRS.%Get("Name")
			kill @tGblName
		}
	
	}
	
	quit tSC
}

/// Reset Syncrhonization info in current Namespace and populates the sample tables
ClassMethod Restart(pItems as %SmallInt=50,pCustomers as %SmallInt=50,pEmployees as %SmallInt=100,pOrders as %SmallInt=1000) as %Status
{
	do ..Reset()
	
	do ..Populate(pItems,pCustomers,pEmployees,pOrders)
	
	quit $$$OK
}

/// Insert data in sample tables. By default just in Order, as, in the sample, Orders are the only objects that are synchronized
/// WARNING:
///		If we just synchronize Orders means that we just accept that variation between DBs copies will just come from that type of objects, 
///     That means that no other changes will be synchronized. Following the sample, new Items or Employees or Customers will not be synchronized between DBs.
ClassMethod Populate(pItems as %SmallInt=0,pCustomers as %SmallInt=0,pEmployees as %SmallInt=0,pOrders as %SmallInt=1000,pVerbose as %Boolean=0) as %Status
{	
	do ##class(SampleApps.Synch.Data.Item).Populate(pItems,pVerbose)
	do ##class(SampleApps.Synch.Data.Customer).Populate(pCustomers,pVerbose)
	do ##class(SampleApps.Synch.Data.Employee).Populate(pEmployees,pVerbose)
	do ##class(SampleApps.Synch.Data.Order).Populate(pOrders,pVerbose)
	
	quit $$$OK
}

///It gathers all the changed data to synchronize as stored in OBJ.JournalT and stores it in a file to be sent to target system for synchronizing
/// pGUIDRemote + pExcludeNS have to be indicated to identify and not include transactions in local system that came from target system (by default pGUIDRemote is current system GUID, but pExcludeNS is mandatory
ClassMethod PrepareSync(pSyncID as %Integer, pUpdateSyncTime as %Boolean=1, pDir as %String=".",pFile as %String="",pFTrans as %Integer="",pLTrans as %Integer="", pGUIDremote as %GUID="", pExcludeNS as %String="",Output pResult as %DynamicObject,pVerbose as %Boolean=0) as %Status
{	
    #dim e As %Exception.AbstractException
	#dim tSC as %Status=$$$OK
	#dim SrcSyncSet as %SYNC.SyncSet
	#dim tVerbFlag as %String="-d"
	
	set pResult = {"status":0}
	quit:(pSyncID'>0) 0	
       
    Try 
    {    	
		//If GUIDremote input, we assume that is local system... in a real app we shouldn't
		if pGUIDremote="" set pGUIDremote = ##class(%SYS.System).InstanceGUID()
		if pVerbose set tVerbFlag = "d"
		
		//We will assume a convention for the filename if no other name is indicated
		if pFile = ""
		{
			set pFile = "syncFrom"_$namespace_"-"_pSyncID_".gbl"
		}
		
		set tFile = pDir_"/"_pFile
		
		set SrcSyncSet = ##class(%SYNC.SyncSet).%New(pSyncID)
			
		// We should exclude local NameSpaces that don't want to synchronize 
		//(For example, because they take part in other apps or synchronization processes... also we don't want to take changes that already came from the NS with which we want to re-synchronize)
		set tExcluded = $ListBuild(pGUIDremote,pExcludeNS) 
		set tSC = SrcSyncSet.AddTransactions(pFTrans,pLTrans,tExcluded)
		set tSC = SrcSyncSet.ExportFile(tFile,tVerbFlag,pUpdateSyncTime)
		
		set pResult.status = tSC
		set pResult.gblSyncSet = SrcSyncSet.GlobalName()
		set pResult.file = tFile
		set pResult.firstTransac = SrcSyncSet.GetFirstTransaction()
		set pResult.lastTransac = SrcSyncSet.GetLastTransaction()
		set pResult.errors = SrcSyncSet.ErrCount()
		
		if pVerbose
		{
			write !,"Global used for the SyncSet: "_SrcSyncSet.GlobalName()
			write !,"First Transaction: "_SrcSyncSet.GetFirstTransaction()
			write !,"Last transaction: "_SrcSyncSet.GetLastTransaction()
			write !,"Results saved in : "_tFile
			write !,"Errors: "_SrcSyncSet.ErrCount()
		}
	}
	catch (e)
	{
		set tSC = e.AsStatus()
		set pResult.status = tSC
	}
	quit tSC
}

/// Initialize SYNC tables when we get a full copy of current DB to put it in the remote system
/// It has to set the current last transaction in %SYNC.SyncTime to avoid synchronize transactions that are already in the remote system.
ClassMethod InitiateFresh(pExludeLocalNS as %String="",pGUIDRemote as %GUID) as %Status
{
	// NOT IMPLEMENTED
	
	quit 0
	
}

/// If we already have loaded a SyncSet with ID = pSyncID, this method displays all the info for transaction pPtr included in that Object SyncSet
ClassMethod ObjectSyncSet(pSyncID as %Integer, pPtr as %Integer) as %Status
{
	#dim tRS as %ResultSet
	#dim tSC as %Status = $$$OK
	
	
	set tRS = ##class(%ResultSet).%New("%SYNC.SyncSet:PropertyValues")
	
	do tRS.%Execute(pSyncID,pPtr)
	
	while tRS.%Next(.tSC)
	{
		set tColumns = tRS.GetColumnCount()
		
		for i = 1:1:tColumns
		{
			write !,tRS.GetColumnName(i)," : ",tRS.GetData(i)
		}
	}
	
	quit tSC
	
}
/// It takes a file with data to synchronize previously generated in origin NS (pSrcNS). 
/// pSyncID has to be the same ID used when the file was generated in source system. 
/// pSrcNS is only included to create a filename based on the convention: syncFrom<pSrcNS>-<pSyncID>.gbl. If a pFile is indicated, pSrsNS is not used.
ClassMethod Synchronize(pSyncID as %Integer,pSrcNS as %String="", pDir as %String=".",pFile as %String="", Output pResult as %DynamicObject, pVerbose as %Boolean=0) as %Status
{
    #dim e As %Exception.AbstractException
	#dim tSC as %Status = $$$OK
	#dim TargetSyncSet as %SYNC.SyncSet
	#dim pResult as %DynamicObject={"status":0}
	
	quit:(pSyncID'>0)||(pDir="")||((pFile="")&&(pSrcNS=""))
       
    Try 
    {    		
		if pFile = ""
		{
			set pFile = "syncFrom"_pSrcNS_"-"_pSyncID_".gbl"
		}
		
		set tFile = pDir_"\"_pFile
		
		write:pVerbose !,"Synchronizing data from :"_tFile
		
		set TargetSyncSet = ##class(%SYNC.SyncSet).%New(pSyncID)
		
		// Import(file As %String = "", lastSync As %Integer = 0, maxTS As %Integer, qspec As %String = "", ByRef errorlog As %String, diag As %Integer = 0, trace As %Integer = 0) As %Status		
		Set tSC = TargetSyncSet.Import(tFile,,,,.tErrorLog,pVerbose)
		if pVerbose
		{
			write !,"ERRORS: ",!
			zw tErrorLog
		}
		
		set pResult = {"status":(tSC),"importFile":(tFile)}
	}
	catch (e)
	{
		set tSC = e.AsStatus()
	}
	
	quit tSC
}
}