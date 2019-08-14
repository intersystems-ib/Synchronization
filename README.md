
# Synchronization
## Object Synchronization project

This is just a simple project to play a bit with IRIS Object Synchronization feature (also available in last versions in Caché and Ensemble). On the journey you can also see a sample of an Installer class that would allow you, from scratch, to define and create Namespaces + Databases, REST services, import a class model and populate it with sample data.

> **WARNING**: As usual... be aware this is playing code, not robust enough for any production use.

### Data Model

The data itself is very simple, just 8 classes:

Class |  Type  | Description
----- | ------ | -----------
`SampleApps.Synch.Data.Address`| Data | Serial class
`SampleApps.Synch.Data.Customer`| Data | Customer's master table
`SampleApps.Synch.Data.Employee`| Data | Employee's master table
`SampleApps.Synch.Data.Item`| Data | Item's master table
`SampleApps.Synch.Data.Order`| Data | Orders registered
`SampleApps.Synch.Data.SynchConflict`| Data | Stores conflicts during synchronizations
`SampleApps.Synch.API.common`| Logic | Basic functions to register, update, delete and query info
`SampleApps.Synch.API.v1.RestLegacy`| Logic | REST API based on %CSP.REST
`SampleApps.Synch.Config.Installer`| Demo Admin | Installer class to prepare demo environment
`SampleApps.Synch.Util`| Demo Admin | Utilities to Restart the demo, prepare SynchSets, launch synchronizations

### Prepare de Demo environment

Once we've downloaded the source code, we choose a folder in our server to put it, let's say: c:/Temp/SampleApps.

Then, we open an IRIS session in a terminal, for example in MYOWNNAMESPACE, an run this code:

```javascript
 do $system.OBJ.Load("c:/Temp/SampleApps/Synch/Config/Installer.cls","ck")
 set args("InstallingFromNS")="MYOWNNAMESPACE"
 set args("NamespaceMaster")="MYMASTERNODE"
 set args("NamespaceClient")="MYCLIENTNODE"
 do ##class(SampleApps.Synch.Config.Installer).setup(.args)
```

After execution, the demo environment will have been created for you and there will be(1):
 * 2 new Namesapces: `MYMASTERNODE` and `MYCLIENTNODE` 
 * based also in 2 new databases: `MYMASTERNODEDB`and `MYCLIENTNODEDB`
  * Both DB will be identical with already populated sample data
 * 1 REST service for both new namespaces to have access to the APIs

An your environment will be ready for you to test.

(1) For the rest of the document, we will assume that the namespaces are MASTER and CLIENT.

### REST Services
Just a bunch of REST services to make use and test this functionality. You can find them in `SampleApps.Synch.API.v1.RestLegacy`class:

Service | Path | HTTP Method | Body sample
------- | ---- | ----------- | -----------
Inserts a new randomly generated order | /randomorder | POST
Get the order with ID = orderID | /order/:orderID | GET
Update the order with ID = orderID and the info attached in body as JSON  object | /order/:orderID | PUT
Delete the order with ID = orderID | /order/:orderID | DELETE
List top 10 orders | /orders | GET
List orders up to: topMax | /orders/:topMax | GET
List top 10 items | /items | GET
List items up to: topMax | /items/:topMax | GET
List top 10 customers | /customers | GET
List customers up to: topMax | /customers/:topMax | GET
List top 10 employees | /employees | GET
List employees up to :TopMax | /employees/:topMax | GET
Prepare a Synchronization Set | /admin/prepsynch | POST | {"syncID":1000,"dir":"c:/Temp","excludeNS":"CLIENT"}
Synchronize data from a Synchronization Set referenced in JSON format in body message | /admin/synchronize | POST | {"syncID":1000,"dir":"c:/Temp","srcNS":"MASTER"}
List top 10 synchronization conflicts | /admin/conflicts | GET
List up to: opMax syncrhonization conflicts | /admin/conflicts/:topMax | GET

### How synchronization feature works

You have a full explanation about this feature in [InterSystems online documentation](https://docs.intersystems.com/iris20192/csp/docbook/DocBook.UI.Page.cls?KEY=GOBJ_objsync).

Some tips:
 * if we want a solution to make use of this feature we have to analize and decide and design time, as classes which objects we want to synchronize will have to be defined accordingly.
 * take into account that synchronization is asynchronous and bidirectional, that means, we decide when we do it, and it will require to build a SynchSet to bring data changes from MASTER to CLIENT and to build another SynchSet to bring data changes from CLIENT to MASTER. 
 * Metadata associated with synchronizations is stored in `%SYNC.SyncTime`. 
 * Data related to transactions of objects that we have decided to syncrhonize is stored internally in `^OBJ.JournalT`
 * When we create a synchronization set (see `%SYNC.SyncSet`), all the synchset objects data is stored internally in `^OBJ.SYNC.<ssid>`, where ssid is a unique identifier we have chosen.

### How to test

From the beginning MASTER and CLIENT already have data and are identical. One easy and quick way to do test will be adding some data to MASTER, prepare a synch set in MASTER to synchronize with CLIENT, and, finally, synchronize in CLIENT. Here it goes an example:

_**Example:**_ 
_You can use whatever REST client, or directly from a terminal. In any case, I'll put the curl commands here (if you want to make use of REST services from command line)_

```
curl -X POST -H 'Authorization: Basic c3VwZXJ1c2VyOnN5cw==' -i http://localhost:52773/synchmaster/rest/v1/randomorder -
curl -X POST -H 'Authorization: Basic c3VwZXJ1c2VyOnN5cw==' -i http://localhost:52774/synchmaster/rest/v1/admin/prepsynch --data '{"syncID":3000,"dir":"c:/Temp","excludeNS":"CLIENT"}'
curl -X POST -H 'Authorization: Basic c3VwZXJ1c2VyOnN5cw==' -i http://localhost:52773/synchclient/rest/v1/admin/synchronize --data '{"syncID":3000,"dir":"c:/Temp","srcNS":"MASTER"}'
 ```
---
 
And there you go... you just have synchronized data between 2 servers (well, 2 namespaces in this case). If you want to generate some conflicts, just modify the same object in both databases before synchronization. When trying to synchronize, it will detect that there was a modification in both sites over the same object and it will arise an event... who will win?? I'll let you find out by yourself (Tip: look at Order class.. ;-) )

## End

I hope this code can help you in any way.

Enjoy!
_Jose-Tomas Salvador_
