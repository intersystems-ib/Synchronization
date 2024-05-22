Class SampleApps.Synch.Data.Address Extends (%SerialObject, %Populate)
{

Parameter OBJJOURNAL = 1;
Parameter GUIDENABLED = 1;


Property street as %String (POPSPEC="Street()");
Property number as %SmallInt (MINVAL=1,MAXVAL=90);
Property city as %String (POPSPEC="City()");
Property ZIP as %String (POPSPEC="USZip()");
Property country as %String (VALUELIST=",USA,Spain,France,Portugal,Brazil,Chile,Panama,Argentina,Venezuela,Italy,United Kingdom,Germany,Belgium,Russia,Morocco,Israel,South Africa,Guinea,India,China,Australia,Netherlands,Poland,Austria,Greece,Turkey");
Storage Default
{
<Data name="AddressState">
<Value name="1">
<Value>street</Value>
</Value>
<Value name="2">
<Value>number</Value>
</Value>
<Value name="3">
<Value>city</Value>
</Value>
<Value name="4">
<Value>ZIP</Value>
</Value>
<Value name="5">
<Value>country</Value>
</Value>
</Data>
<State>AddressState</State>
<StreamLocation>^SampleApps.Synch.Data.AddressS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}