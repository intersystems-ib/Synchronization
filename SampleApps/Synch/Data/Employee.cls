/// Registered employees
Class SampleApps.Synch.Data.Employee Extends (%Persistent,%Populate)
{

///This allows the class to be stored with the GUIDs
///Also is a class referenced in Order class which is to be synchronized, 
///so this class objects need a GUID to be able to synchronize their references
Parameter GUIDENABLED = 1;

Property empCode as %Integer [Identity ];
Property name as %String;
Storage Default
{
<Data name="EmployeeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
</Data>
<DataLocation>^SampleApps.SynchB289.EmployeeD</DataLocation>
<DefaultData>EmployeeDefaultData</DefaultData>
<IdLocation>^SampleApps.SynchB289.EmployeeD</IdLocation>
<IndexLocation>^SampleApps.SynchB289.EmployeeI</IndexLocation>
<StreamLocation>^SampleApps.SynchB289.EmployeeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}