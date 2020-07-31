import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import "package:path/path.dart";
import "package:dropdown_formfield/dropdown_formfield.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BasicSql(),
    );
  }
}

class BasicSql extends StatefulWidget {
  @override
  _BasicSqlState createState() => _BasicSqlState();
}

class _BasicSqlState extends State<BasicSql> {

  String _myActivity;
  String _myActivityResult;

  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _country = TextEditingController();

  GlobalKey<FormState> _form = GlobalKey<FormState>();

  BuildContext _buildcontext;
  List<ContactData> contactList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myActivity = '';
    _myActivityResult = '';

    initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    _buildcontext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts details"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(

                    controller: _name,
                    validator: (String v) {
                      if (v.length < 5) {
                        return "Please give a proper name";
                      }
                      else if(v.length<0)
                        {
                          return "name is required";
                        }
                      else
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Fullname',
                      enabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height:2.0),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.number,
                    validator: (String v) {
                      if (v.length < 10) {
                        return "Please give more than 10 numbers";
                      }
                      else if(v.length<0)
                      {
                        return "mobile number is required";
                      }
                      else
                      return null;
                    },
                    decoration: InputDecoration(

                      labelText: 'Phone',
                      enabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height:2.0),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: DropDownFormField(
                    titleText: 'Residence',
                    hintText: 'Please choose one',
                    value: _myActivity,
                    onSaved: (value) {
                      setState(() {
                        _myActivity = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _myActivity = value;
                      });
                    },
                    dataSource: [
                      {
                        "display": "Office",
                        "value": "Office",
                      },
                      {
                        "display": "Home",
                        "value": "Home",
                      },


                    ],
                    textField: 'display',
                    valueField: 'value',
                  ),
                ),
                SizedBox(height:2.0),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _country,
                    validator: (String v) {
                      if (v.length > 47 || v.length == 0) {
                        return "Please give a  valid country name";
                      }
                      return null;
                    },
                    decoration: InputDecoration(

                      labelText: 'Country',
                      enabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(),
                    ),
                  ),

                ),

                RaisedButton(
                  onPressed: () {
                    if (_form.currentState.validate()) {
                      print("success");
                      insertData(_name.text, _phone.text, _country.text);
                      _showAlert();
                      _name.clear();
                      _phone.clear();
                      _country.clear();


                    } else {
                      print("error");
                    }
                  },
                  child: new Text("SAVE"),
                  textColor: Colors.white,
                  color: Colors.lightBlueAccent,
                ),
                FlatButton(
                  color: Colors.blueAccent[200],
                  onPressed: (){
                    _showAlert();
                  },
                  child: Text('Saved details'),

                ),
              ],
            ),
          )),
    );
  }

  Database _db;

  Future<void> initDatabase() async {
    String path = join(await getDatabasesPath(), "contacts_database2.db");
    print("path name: " + path);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          '''
          CREATE TABLE contacts(
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT,
            country TEXT NOT NULL
            )
          ''',
        );
      },
    );



    getDataFromDb();
  }

  void getDataFromDb() async {
    List<Map> x = await _db.rawQuery("SELECT * FROM contacts");

    contactList = [];

    setState(() {
      x.forEach((element) {
        ContactData contactData =
        ContactData(element["id"], element["name"], element["phone"],element["country"]);
        contactList.add(contactData);
      });
    });
  }

  void insertData(String name, String phoneNumber,String country) async {
    print(
        "INSERT INTO contacts (name,phone,country) values ('${name.toUpperCase()}','$phoneNumber','$country')");

    int n = await _db.rawInsert(
        "INSERT INTO contacts (name,phone,country) values ('$name','$phoneNumber','$country')");
    print(n);

//    List<Map> x = await _db.rawQuery("SELECT * FROM contacts");

    getDataFromDb();
  }

  void _showAlert() {
    Navigator.push(_buildcontext, MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("contact Saved"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Form(
          child:SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ...List.generate(
                  contactList.length,
                      (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "${contactList[index].name} - ${contactList[index].phoneNumber}- ${contactList[index].country}"),
                  ),),
              ],

            ),
          ),
        ),





      );
    }));
  }
}

class ContactData {
  int id;
  String name;
  String phoneNumber;
  String country;

  ContactData(this.id, this.name, this.phoneNumber,this.country);
}