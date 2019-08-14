/// Store all order transactions
Class SampleApps.Synch.Data.Order Extends (%Persistent,%Populate,%JSON.Adaptor)
{
// We don't want to force other classes reference to use %JSON.Adaptor. Then we decide export the GUID of referenced objects (by default it will include the JSON of object referenced)
// ID doesn't uniquely identify an object when there are 2 DBs involved. GUID does.
Parameter %JSONREFERENCE As STRING [ Constraint = "OBJECT,ID,OID,GUID", Flags = ENUM ] = "GUID";

///We'll keep track of this class for synchronization (assuming that in off-line mode is not allowed by the app to modify master classes
Parameter OBJJOURNAL = 1;
///This allows the class to be stored with the GUIDs
Parameter GUIDENABLED = 1;

Property orderNum as %Integer [Identity];
Property employee as SampleApps.Synch.Data.Employee;
Property customer as SampleApps.Synch.Data.Customer;
Property dateOrder as %TimeStamp (POPSPEC="TimeStamp($zdt(""$h-60,0"",3),$zdt($h,3))");
Property item as SampleApps.Synch.Data.Item;
Property quantity as %Decimal (MINVAL=0,MAXVAL=1000);
Property price as %Decimal (MINVAL=1,MAXVAL=9999);

/// IDKEY
Index idxOrder On orderNum [IdKey ];
Index idxEmployee on employee;

// This method should be implemented by the user. This method is invoked by %SYNC.SyncSet.Import when the object being imported
/// has been modified on the local system since the last time it was synchronized with the system which produced the SyncSet.
/// Passed to this method are the oid of the conflicting object, and oref to the SyncSet containing the version to sync to, and the pointer
/// to this object in the SyncSet. It is the responsibility of this method to either resolve the conflict and process the resolved object or
/// to return a failure status to the caller. The resolved object can be processed by saving, invoking the %SyncObjectIn method or by whatever
/// means the class author deems appropriate. If a failure status is returned to %SYNC.SyncSet.Import then the object will be requeued in the SyncSet.
/// That might result in another call at a later time to this method.
/// 
ClassMethod %ResolveConcurrencyConflict(oid As %ObjectIdentity, objSS As %SYNC.SyncSet, iPtr As %Integer, ByRef bAcceptYours As %Boolean = 0) As %Status [ ServerOnly = 1 ]
{
	#dim tRS as %ResultSet
	#dim tObjectData as %DynamicObject={}
	#dim tObjTgtJSON as %String=""
	#dim tConflict as SampleApps.Synch.Data.SynchConflict
	#dim e as %Exception.AbstractException
	
	try
	{
	 	set ^XXTRACE("SYNCH","conflicts")=0
	 	set tTimeStamp = $zdt($h,3)
	 	set ^XXTRACE("SYNCH",objSS.sId)=tTimeStamp
	 	set tCounter = $I(^XXTRACE("SYNCH",objSS.sId,"conflicts"))
		set ^XXTRACE("SYNCH",objSS.sId,"Object conflict",tCounter,oid)=""
		
		// Gets the name of NS we consider MASTER repository  (this should be in some kind of configuration area... also it would be better SystemGUID+NS)
		set tMASTERns = $get(^XXTRACE("SYNCH","NS"),"MASTER")
		
		//Getting the property(ies) that changed
		set tRS = ##class(%ResultSet).%New("%SYNC.SyncSet:PropertyValues")
		set tSC = tRS.%Execute(objSS.sId,iPtr)
		while tRS.%Next(.tSC)
		{
			do tObjectData.%Set(tRS.GetData(1),tRS.GetData(2))
			//set ^XXTRACE(tTimeStamp,"Object conflict",tCounter,"getting data")=""
		} 
		
		set ^XXTRACE(tTimeStamp,"Object conflict",tCounter,"src data")=tObjectData.%ToJSON()	
		
		// We can preserve the src and target data in a SynchConflict class.
		set tConflict = ##class(SampleApps.Synch.Data.SynchConflict).%New()
		set tConflict.chosen = "local"  // By default let's assume we'll keep the local object version
		set tConflict.syncID = objSS.sId
		set tConflict.syncSRC = objSS.SyncSystem
		//set tConflict.srcObject = tObjectData
		set tConflict.srcObjectSTR = tObjectData.%ToJSON() // as of Aug-19, there is a known limitation in 2019.2 with JSON projections of properties of type %DynamicObject - meanwhile we store the object in string format
		do ..%Open(oid).%JSONExportToString(.tObjTgtJSON)
		//do tConflict.tgtObject.%FromJSON(tObjTgtJSON)
		set tConflict.tgtObjectSTR = tObjTgtJSON  // as of Aug-19, there is a known limitation in 2019.2 with JSON projections of properties of type %DynamicObject - meanwhile we store the object in string format
		
		// MAKE DECISIONS... 
		//Example - Orders will mainly be modified off-line, so if the data is coming from other DB that what we consider MASTER DB
		// we accept the data coming. Otherwise, we keep it. We could better use System GUID to identify the master system.
		if tMASTERns '= tObjectData.%Get("%%ONSID")   // %ONSID stores the src namespace
		{
			set bAcceptYours = 1
			set tConflict.chosen = "remote"	// we will store the remote object version
		}
		
		set tSC = tConflict.%Save()
	}
	catch e
	{
		set tSC = e.AsStatus()
		set ^XXTRACE("SYNCH",objSS.sId,"error")=tSC
	}
	
	quit tSC
	
}

Storage Default
{
<Data name="OrderDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>employee</Value>
</Value>
<Value name="3">
<Value>dateOrder</Value>
</Value>
<Value name="4">
<Value>item</Value>
</Value>
<Value name="5">
<Value>quantity</Value>
</Value>
<Value name="6">
<Value>price</Value>
</Value>
<Value name="7">
<Value>customer</Value>
</Value>
</Data>
<DataLocation>^SampleApps.Synch.Data.OrderD</DataLocation>
<DefaultData>OrderDefaultData</DefaultData>
<IdLocation>^SampleApps.Synch.Data.OrderD</IdLocation>
<IndexLocation>^SampleApps.Synch.Data.OrderI</IndexLocation>
<StreamLocation>^SampleApps.Synch.Data.OrderS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}