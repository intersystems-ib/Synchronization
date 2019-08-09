
# Syncrhonization
## Object Synchronization project

sample text **sample bold** :

1. list number...
2. list number....


> **WARNING**: warning test ;-)

### Section AAAA

This is a sample of 4 classes (1) : `OPNLib.Serialize.Adaptor`, `OPNLib.Serialize.Util`, `OPNLib.Serialize.TemplateOPNLib.Serialize.Template` and `OPNLib.Serialize.TemplateOPNLib.Serialize.TemplateCSV` 

(1) footnote `OPNLib.Serialize.Adaptor` 

### Section BBBB

Textadadadsasdafsd
asdfñasdkfjañdsjfñalkjsdfñalksjfñalskjdf.

---

_**Example:**_ 
_(Example assumes that your classname is `SampleApps.Serialize.MapTesting`, that is a persistent class and that you already extended it to inherit from `OPNLib.Serialize.Adaptor`)_

Here it goes some code.... :

```javascript
     Set obj = ##class(SampleApps.Serialize.MapTesting).%OpenId(1)
     Set objJSON = obj.Export()
     Do objJSON.%ToJSON()

     Set newObj = ##class(SampleApps.Serialize.MapTesting).%New()
     Do newObj.Import(objJSON)
     set tSC = newObj.%Save()
     write newOBJ.%Id()
 ```
more text _`SampleApps.Serialize.MapTesting`_ text following.

---
 
 
### Section CCC

Some text....


Here it goes a table :

Code | Category | Description
---- | ------------- | -----------
1 | Basic type | It'll include %String, %Integer, %Date, %Datetime,%Timestamp,%Decimal,%Float,… and most of the basic types defined in the %Library package 
2 | List collection | It'll include collections of datatypes of type %Collection.ListOfDT
3 | Array collection | It'll include collections of datatypes of type %Collection.ArrayOfDT
4 | Object Reference | A property that reference a custom object not in %* libraries 
5 | Array of objects and Relationship objects | A property of type %Collection.ArrayOfObject or a property of type %RelationshipObject with cardinality many or children
6 | List of Objects | A property of type %Collection.ListOfObject
7 | Stream | Properties of type %Stream.*, %CSP.*stream*,…

Another way of formatting follows....

---
**MAPS / MAPSREV globals' structure**

^MAP("*classname*","*mapname*",_GroupType[1..6]_,"_Source Property Name_") = *List Element*

 *List Element*:
 
  [1] *Target Property Name*
  
  [2] *Convert Method*
  
  [3] *Drill down*
  
  [4] *Class of referenced object(s)*
  
  [5] *Template Class that implement export/import logic*
  
  [6] *Method Class to dispatch for export/import*

---

Formatting code...:
```
...
...
^MAPS("SampleApps.Serialize.MapTesting","MAP0",4,"reference")=$lb("referencia","","1","SampleApps.Serialize.MapTesting","","")
^MAPS("SampleApps.Serialize.MapTesting","MAP0",5,"arrayOfObjects")=$lb("arrayDeObjectos","","1","SampleApps.Serialize.MapTesting","","")
...
...
^MAPSREV("SampleApps.Serialize.MapTesting","MAP0",4,"referencia")=$lb("reference","","1","SampleApps.Serialize.MapTesting","","")
^MAPSREV("SampleApps.Serialize.MapTesting","MAP0",5,"arrayDeObjetos")=$lb("arrayOfObjects","","1","SampleApps.Serialize.MapTesting","","")
...
...
```


---
**Example:**

```javascript
 set tClassName = "SampleApps.Serialize.MapTesting"
 ;Assuming the class has only 1 map: MAP0, used in ^MAPS and ^MAPSREV
 set json = ##class(OPNLib.Serialize.Util).ExportMapsToJSON(tClassName)
 
 ;change name of map from MAP0 to MAP1 
 set json.maps.%Get(0).map = "MAP1"  //change mapname entry in corresponding to ^MAPS
 set json.maps.%Get(1).map = "MAP1" //change mapname entry corresponding to ^MAPSREV

 ;Overwrite map (2) of SampleApps.Serialize.MapTesting with map in object:json
 set tSC = ##class(OPNLib.Serialize.Util).ImportMapsFromJSON(json,2,tClassName) 

 ;Get settings of one of the properties. They are returned in a json object
 set propExprt = ##class(SampleApps.Serialize.MapTesting).GetMappedPropSettings("code","MAP1",tClassName,1)

 ;We change the targetPropertyName setting
 set $ListUpdate(propExprt.settings,1) = "codeAccepted"
 do ##class(SampleApps.Serialize.MapTesting).SetMappedPropSettings("code",propExprt,"MAP1",tClassName,1)

 ;Now we open and object and export it using new mapping
 set obj = ##class(SampleApps.Serialize.MapTesting).%OpenId(1)
 set objJSON = obj.Export(,,,,"MAP1")
 do objJSON.%ToJSON()

```
---

Another list.... :
* Change the name of default map. 
  * Use parameter `EXPTDEFAULTMAP` to indicate a name for default map before compiling the class 
* Excluding  properties 
  * if we don't want to export some   properties, we should include them (comma separated list) in the parameter : `EXPTEXCLUDEPROP` before compiling the class
* Include  object references
  * Even when we decide not to drill down through referenced objects, we still have the chance to export the object reference itself if we set the parameter `EXPTINCLUDEOREF` to 1.
* Drill down levels
  * Use `EXPTDRILLDOWN`To indicate up to what number of levels that the export/import logic should follow through object references. 0 means no drill down. A positive number(n) means to drill down n times through the chain of references.



## Sample Application
Explaining the sample... `SampleApps.Synch`

## REST Services
Just a bunch of REST services to make use and test this functionality. You can find them in `SampleApps.Synch.API.v1.RestLegacy`class:

Service | Path | HTTP Method 
------- | ---- | -----------
Get an object up to a drilldown level in JSON format following a particular map especification | /object/json/:class/:id/:ddlevel/:map | GET
Get an object up to a drilldown level in JSON format following the default map | /object/json/:class/:id/:ddlevel | GET
Get an object in JSON format following the default map and default drilldown especs | /object/json/:class/:id" | GET
Load an object from JSON using a particular map and drilldown especifications | /object/json/:class/:ddlevel/:map | POST
Load an object from JSON using its default map and a particular drilldown especifications | /object/json/:class/:ddlevel | POST
Load an object from JSON using its default map | /object/json/:class | POST
Load an object from JSON using its default map and which class is included in _classname_ property of the JSON document | /object/json | POST
Get a serialized object in format especified by serialization method and with a especified drilldown level | /object/serial/:templateclass/:serializationmethod/:class/:id/:ddlevel | GET
Get a serialized object in format especified by serialization method | /object/serial/:templateclass/:serializationmethod/:class/:id |GET
Load object from a particular class, and with an especified drilldown level, from a serialized stream | /object/serial/:templateclass/:serializationmethod/:class/:ddlevel | POST 
Load object from a particular class from a serialized stream | /object/serial/:templateclass/:serializationmethod/:class | POST
Update an object from JSON input | /object/json/:class/:id | PUT
Delete an object with certain ID | NOT YET IMPLEMENTED | DELETE
Update an object from serialized input | (NOT YET IMPLEMENTED) /object/serial/:templateclass/:serializationmethod/:class/:id | PUT
Get a JSON document that contains certain type of MAPS (export or import) for a particular class | /map/:class/:map/:type | GET
Get a JSON document that contains export and import definition of a MAP name associated with a particular class | /map/:class/:map | GET
Get a JSON document that contains all the maps' definitions for a class | /map/:class | GET
Set export/import MAPS (all or those comma-separated especified in Filter) from a JSON document | /map/:override/:filter | POST
Set export/import MAPS from a JSON document (overriding the existing ones if any) | /map" | POST
Set the export/import MAPS from a JSON document to a different target class (all or those especificied in filter) | /map/chgclass/:targetclass/:override/:filter | POST
Set the export/import MAPS from a JSON document to a different target class | /map/chgclass/:targetclass | POST


## End

I hope this code can help you in any way.

Enjoy!
_Jose-Tomas Salvador_
