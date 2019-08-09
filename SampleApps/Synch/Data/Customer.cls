/// Customers' master table
Class SampleApps.Synch.Data.Customer Extends (%Persistent, %Populate)
{

///This allows the class to be stored with the GUIDs
///Also is a class referenced in Order class which is to be synchronized, 
///so this class objects need a GUID to be able to synchronize their references
Parameter GUIDENABLED = 1;

Property code as %String (MAXLEN=20,POPSPEC="Random(9999)_""CST"" ");
Property custName as %String (POPSPEC="Company()");
Property HQAddress as SampleApps.Synch.Data.Address;

Storage Default
{
<Data name="CustomerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>code</Value>
</Value>
<Value name="3">
<Value>custName</Value>
</Value>
<Value name="4">
<Value>HQAddress</Value>
</Value>
</Data>
<DataLocation>^SampleApps.SynchB289.CustomerD</DataLocation>
<DefaultData>CustomerDefaultData</DefaultData>
<IdLocation>^SampleApps.SynchB289.CustomerD</IdLocation>
<IndexLocation>^SampleApps.SynchB289.CustomerI</IndexLocation>
<StreamLocation>^SampleApps.SynchB289.CustomerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}