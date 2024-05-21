/// Items definition
Class SampleApps.Synch.Data.Item Extends (%Persistent, %Populate)
{

///This allows the class to be stored with the GUIDs
///Also is a class referenced in Order class which is to be synchronized, 
///so this class objects need a GUID to be able to synchronize their references
Parameter GUIDENABLED = 1;

Property code as %Integer [Identity];
Property description as %String (MAXLEN=100,POPSPEC="Product()");
Property minStock as %Decimal (POPSPEC="Float()");

/// IDKEY
Index idxCode On code [IdKey ];


Storage Default
{
<Data name="ItemDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>code</Value>
</Value>
<Value name="3">
<Value>description</Value>
</Value>
<Value name="4">
<Value>minStock</Value>
</Value>
</Data>
<DataLocation>^SampleApps.Synch.Data.ItemD</DataLocation>
<DefaultData>ItemDefaultData</DefaultData>
<IdLocation>^SampleApps.Synch.Data.ItemD</IdLocation>
<IndexLocation>^SampleApps.Synch.Data.ItemI</IndexLocation>
<StreamLocation>^SampleApps.Synch.Data.ItemS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}