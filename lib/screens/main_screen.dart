import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hose_jockey/time_format.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'engagement_screen.dart';
import '../models/estimate.dart';
import '../models/engagement.dart';
import 'package:hose_jockey/database_helper.dart';


class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);
  static const routeName = '/';

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {

  final engagementCtrl = new TextEditingController();
  final acreageCtrl = TextEditingController();
  final GlobalKey<MainScreenState> _key = GlobalKey();
  List<Engagement> engagements = [];
  
  var newName;

  void initState(){
    super.initState();
    loadEngagements();
  }

  var dto;

  void loadEngagements() async{
    final Database database = await DatabaseHelper.getDBConnector();
    List<Map> engagementRecords = await database.rawQuery('SELECT * FROM engagements');
    if (engagementRecords != null) {
      final engagementEntries = engagementRecords.map((record) {
        print("active: ${record['active']}");
        return Engagement(
          record['name'],
          record['timeStamp'],
          record['acres'],
          loadOrders(record['orders']),
          record['active'],
          record['id'],
        );
      }).toList();
      setState(() {
        engagements = engagementEntries.reversed.toList();
      });
    } else{
      engagements = new List<Engagement>();
    }
  }

  List<Estimate> loadOrders(string) {
    Iterable i = json.decode(string);
    List<Estimate> orderEntries = List<Estimate>.from(i.map((model) => Estimate.fromJson(model)));
    return orderEntries;
  }

  void deleteDB() async{
    print("DB Deleted");
    await deleteDatabase('engagements.db'); //delete this
    loadEngagements();
  }

  void setEngagement() {
    if (engagementCtrl.text.isNotEmpty) {
      setState(() {
            dto = Engagement( newName, timeFormat(), 250, [], 1);
      });
      engagementCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Ops Normal';
    if (engagements.isEmpty){
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("No Engagements Created Yet"),
              ],
            ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: floatAccButton(),
        bottomNavigationBar: bottomNavBar()
      );

      } else
          return Scaffold(
            resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(title),
                centerTitle: true,
              ),

              body: Column(
                key: _key,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: engagements.length,
                      itemBuilder: (context, index){
                        return Dismissible(
                          key: Key(engagements[index].primaryKey.toString()),
                          background: Stack(children: [
                            Container(color: Colors.red),
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.delete_forever, size: 34,),
                              ),
                            )
                          ],
                          ),
                          dismissThresholds: {
                            DismissDirection.startToEnd: 1.0,
                            DismissDirection.endToStart: 0.25
                          },
                          confirmDismiss: (DismissDirection direction) async{
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: const Text("Delete Engagement?"),
                                  content: const Text("This cannot be undone"),
                                  actions: [
                                    FlatButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text("Delete"),
                                    ),
                                    FlatButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    )
                                  ],
                                );
                              }
                            );
                          },
                          onDismissed: (direction){
                              DatabaseHelper.deleteEngagement(engagements[index].primaryKey);
                              loadEngagements();
                          },

                          child: ListTile(
                            title: Text('${engagements[index].name}', style: TextStyle(fontSize: 22),),
                            subtitle: Text('Created: ${engagements[index].fireTimeStamp}'),
                            onTap: () {
                              Navigator.pushNamed(context, SelectedEngagement.routeName, arguments: engagements[index]);
                            },
                          )
                        );
                      }

                    ),
                  ),
                ]
              ),

              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: floatAccButton(),
              bottomNavigationBar: bottomNavBar()
            );
  }

  _createEngagement(context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Engagement'),
          content: TextField(
            autofocus: true,
            controller: engagementCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Engagement Name:',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            OutlineButton(
              child: Text('cancel'),
              onPressed:() {
                Navigator.of(context).pop();
              },
            ),
            OutlineButton(
              child: Text('Create'),
              onPressed: () async {
                newName = engagementCtrl.text;
                setEngagement();
                DatabaseHelper.insertEngagement(dto);
                loadEngagements();
                Navigator.of(context).pop();
              },
            )
          ]
        );
      }
    );
  }

  Widget bottomNavBar(){
    return BottomAppBar(
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(icon: Icon(Icons.arrow_upward), 
          onPressed: (){
            setState(() {
                engagements.sort((a,b) => a.name.compareTo(b.name));
              });
            },
          ),
          IconButton(icon: Icon(Icons.arrow_downward), 
          onPressed: (){
            setState(() {
                engagements.sort((a,b) => b.name.compareTo(a.name));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget floatAccButton(){
    return FloatingActionButton(
      onPressed: () => _createEngagement(context),
      tooltip: 'New estimate',
      child: Icon(Icons.add),
    );
  }
}
