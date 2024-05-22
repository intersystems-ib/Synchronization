/// Common operations
/// Really very basic. No error handling, nothing... just built to play with some sample data
Class SampleApps.Synch.API.common Extends %RegisteredObject
{
ClassMethod newOrder(pItem as %Integer, pEmployee as %Integer, pCustomer as %Integer, pDateOrder as %TimeStamp, pPrice as %Decimal, pQuantity as %Decimal) as %DynamicObject
{
	#dim tOrd as SampleApps.Synch.Data.Order
	#dim tResp as %DynamicObject={"status":($$$OK),"id":""}
	
	set tOrd = ##class(SampleApps.Synch.Data.Order).%New()
	
	do tOrd.itemSetObjectId(pItem)
	do tOrd.employeeSetObjectId(pEmployee)
	do tOrd.customerSetObjectId(pCustomer)
	set tOrd.dateOrder = pDateOrder
	set tOrd.price = pPrice
	set tOrd.quantity = pQuantity
	
	set tSC = tOrd.%Save()
	
	set tResp.status = tSC
	set:tSC=1 tResp.id = tOrd.%Id()
	quit tResp
}

/// Modifies and order. References to other objects will come with their IDs. We're assuming that data is valid, that means, those referenced objects exist.
ClassMethod changeOrder(pOrderId as %Integer, pItem as %Integer, pEmployee as %Integer, pCustomer as %Integer, pDateOrder as %TimeStamp, pPrice as %Decimal, pQuantity as %Decimal) as %DynamicObject
{
	#dim tSC as %Status=0
	#dim tResp as %DynamicObject={"status":($$$OK),"id":""}
	
	set tOrd = ##class(SampleApps.Synch.Data.Order).%OpenId(pOrderId)
	
	if $IsObject(tOrd)
	{
		do:pItem>0 tOrd.itemSetObjectId(pItem)
		do:pEmployee>0 tOrd.employeeSetObjectId(pEmployee)
		do:pCustomer>0 tOrd.customerSetObjectId(pCustomer)
		set:pDateOrder'="" tOrd.dateOrder = pDateOrder
		set:pPrice'<0 tOrd.price = pPrice
		set:pQuantity'<0 tOrd.quantity = pQuantity
		
		set tSC = tOrd.%Save()		
		
		set tResp.status = tSC
		set tResp.id = pOrderId
	}
	
	quit tResp
}

ClassMethod deleteOrder(pOrderId as %Integer) as %DynamicObject
{
	#dim tResp as %DynamicObject={"status":($$$OK),"id":(pOrderId)}

	&sql(delete from SampleApps_Synch_Data.Order where ID = :pOrderId)
	
	if SQLCODE <0 
	{
		set tResp.status = SQLCODE
	}	
	
	quit tResp
}
}