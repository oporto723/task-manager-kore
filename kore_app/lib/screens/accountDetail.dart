import 'package:flutter/material.dart';
import 'package:kore_app/models/user.dart';
import 'package:kore_app/auth/user_repository.dart';
import 'package:kore_app/utils/theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:kore_app/models/account.dart';
import 'package:kore_app/models/task.dart';
import 'package:kore_app/data/api.dart';
import 'package:kore_app/screens/taskDetail.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/task.dart';

class AccountDetailState extends State<AccountDetail> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _tasks = <Task>[];
  Future<User> _user;
  Future<List<Task>> _tasksAPI;
  Future<String> _username;
  Future<String> _token;
  Api _api;

  int _count = 0;
  var text;
  var color;
  var icon;
  var completeIcon;

  //test
  // Api _api = Api();

  //one of the state lifecycle function, only load once
  //good place for dummydata loading
  @override
  initState() {
    super.initState();
    _token = widget.userRepository.hasToken();
    _username = widget.userRepository.getUsername();
    _api = Api();
    _tasksAPI = _api.getTasks(_token);
    _user = _api.getUserByUsername(_token, _username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.account.accountName),
        // actions: <Widget>[      // Add 3 lines from here...
        //     IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        //   ],
      ),
        body: FutureBuilder<List<Task>>(
          future: _tasksAPI,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new Column(
                  children: <Widget>[_buildHeader(), _buildList(snapshot.data)]);
            } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return CircularProgressIndicator();
          },
        ));
  }

  Widget _buildHeader() {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 0.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.only(bottomLeft: const Radius.circular(30.0)),
        
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //Using expanded to ensure the image is always sized with contraint
          Expanded(
            child: new Container(
              height: 150.0,
              child: Column(
                children: <Widget>[
                  _buildPercentIndicator(),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildPercentIndicator() {
    return new Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: new CircularPercentIndicator(
          radius: 95.0,
          lineWidth: 13.0,
          animation: true,
          percent: widget.account.percentage * 0.01,
          center: new Text(
            widget.account.percentage.toString() + "%",
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
          ),
          footer: new Text(
            "Progress",
            style: new TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold, 
              fontSize: 17.0),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.grey,
          progressColor: Colors.indigo,
        ),
    );
  }

  // Widget _buildList(List<Task> _tasks) {
  //   return Flexible(child: ListView.builder(
  //       // padding: const EdgeInsets.symmetric(vertical: 25.0),
  //       itemBuilder: (context, i) {
  //     // if (i.isOdd) return Divider();
  //     // final index = i ~/ 2;
  //     if (_tasks.length > i) {
  //       return _buildRow(_tasks[i], i);
  //     }
  //     return null;
  //   }));
  // }

    Widget _buildList(List<Task> _tasks) {
    return Flexible(
        child: ListView.builder(
            padding: const EdgeInsets.all(25.0),
            itemBuilder: (context, i) {
              if (i.isOdd) return Divider();

              final index = i ~/ 2;
              if (_tasks.length > index) {
                return _buildRow(_tasks[index], i);
              }
              return null;
            }));
  }

  Widget _buildRow(Task task, int i) {
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: new ListTile(
          leading: new CircleAvatar(
            backgroundColor: KorePrimaryColor,
            child: new Text((i + 1).toString()),
            foregroundColor: Colors.white,
          ),
          trailing: Icon(completeIcon),
          title: new Text(task.description),
          subtitle: new Text((task.dueDate).toString()),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetail(task: task),
                ));
          },
        ),
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: 'Upload',
          color: Colors.blueAccent,
          icon: Icons.file_upload,
        ),
        new IconSlideAction(
          caption: task.label,
          color: task.color,
          icon: task.icon,
          onTap: () {
            task.isCompleted ? markNotCompleted(task) : markCompleted(task);
          },
        ),
      ],
    );
  }

  void markCompleted(Task task) {
    task.isCompleted = true;

    setState(() {
      task.setStatus();
    });

    print(task.isCompleted);
  }

  void markNotCompleted(Task task) {
    task.isCompleted = false;

    setState(() {
      task.setStatus();
    });

    print(task.isCompleted);
  }
}

class AccountDetail extends StatefulWidget {
  final Account account;
  final UserRepository userRepository;
  const AccountDetail({Key key, @required this.account, @required this.userRepository}) : super(key: key);

  @override
  AccountDetailState createState() => new AccountDetailState();
}
