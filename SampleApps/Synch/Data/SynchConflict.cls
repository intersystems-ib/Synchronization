Class SampleApps.Synch.Data.SynchConflict Extends (%Persistent,%JSON.Adaptor)
{
	Property syncSRC as %String;
	Property syncID as %Integer (MINVAL=0);
	//Property srcObject as %DynamicObject; // There is a known limitation as of 2019.2 in %JSON.Adaptor dealing with properties of type %DynamicObject
	/// To store srsObject serialized in string format
	Property srcObjectSTR as %String (MAXLEN="");
	//Property tgtObject as %DynamicObject; // There is a known limitation as of 2019.2 in %JSON.Adaptor dealing with properties of type %DynamicObject
	/// To store tgtObject serialized in string format
	Property tgtObjectSTR as %String (MAXLEN="");
	Property chosen as %String (VALUELIST=",remote,local");
Storage Default
{
<Data name="SynchConflictDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>syncSRC</Value>
</Value>
<Value name="3">
<Value>syncID</Value>
</Value>
<Value name="4">
<Value>chosen</Value>
</Value>
<Value name="5">
<Value>srcObjectSTR</Value>
</Value>
<Value name="6">
<Value>tgtObjectSTR</Value>
</Value>
</Data>
<Data name="srcObject">
<Attribute>srcObject</Attribute>
<Structure>node</Structure>
<Subscript>"srcObject"</Subscript>
</Data>
<Data name="tgtObject">
<Attribute>tgtObject</Attribute>
<Structure>node</Structure>
<Subscript>"tgtObject"</Subscript>
</Data>
<DataLocation>^SampleApps.SB289.SynchConflictD</DataLocation>
<DefaultData>SynchConflictDefaultData</DefaultData>
<IdLocation>^SampleApps.SB289.SynchConflictD</IdLocation>
<IndexLocation>^SampleApps.SB289.SynchConflictI</IndexLocation>
<StreamLocation>^SampleApps.SB289.SynchConflictS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}