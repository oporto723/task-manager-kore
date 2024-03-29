import 'package:flutter/material.dart';
import 'package:kore_app/auth/user_repository.dart';
import 'package:kore_app/models/account.dart';
import 'package:kore_app/models/user.dart';
import 'package:kore_app/screens/account_detail.dart';
import 'package:kore_app/screens/account_list.dart';
import 'package:kore_app/utils/theme.dart';
import 'package:kore_app/widgets/loading_indicator.dart';

class BasicListState extends State<BasicList> {
  final _biggerFont = THEME_TEXTSTYLE.copyWith(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w400);
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
          future: widget.list,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildList(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return LoadingIndicator();
          },
        );
  }

  Widget _buildList(List<dynamic> list) {
    return Flexible(
        child: ListView.builder(
            padding: const EdgeInsets.all(25.0),
            itemBuilder: (context, i) {
              if (i.isOdd) return Divider();

              final index = i ~/ 2;
              if (list.length > index) {
                return _buildRow(list[index]);
              }
              return null;
            }));
  }

  Widget _buildRow(dynamic item) {
    return ListTile(
      title: Text(
        item.name,
        style: _biggerFont,
      ),
      // trailing: Icon(
      //   // Add the lines from here...
      //   account.percentage >= 100 ? Icons.done : null,
      // ),
      onTap: () {
        if(item is Account){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountDetail(account: item, userRepository: widget.userRepository, role: widget.role),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountList(organization: item, userRepository: widget.userRepository, role: widget.role),
            ));
      }
      },
    );
  }
}

class BasicList extends StatefulWidget {
  
  final Future<User> user;
  final Future<List<dynamic>> list;
  final UserRepository userRepository;
  final String role;

  BasicList({Key key, @required this.user, @required this.list, @required this.userRepository, @required this.role}) : super(key: key);

  @override
  BasicListState createState() => new BasicListState();
}
