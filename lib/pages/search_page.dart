import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
TextEditingController searchController= TextEditingController();
bool isLoading=false;
bool hasUserSearched= false;
String userName=" ";
QuerySnapshot? searchSnapshot;
bool isJoined= false;
User? user;

@override
  void initState() {
    super.initState();
    getUserIdAndName();
  }
getUserIdAndName() async {
  user=FirebaseAuth.instance.currentUser!;
  await HelperFunction.getUserName().then((val){
    setState((){
      userName=val!;

    });
  });
}


  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
             color: Theme.of(context).primaryColor,
               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
               child:Row(
                children: [
                  Expanded(child: TextField( 
                    controller: searchController,
                     style: const TextStyle(color: Colors.white),
                       decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups....",
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
 )),
GestureDetector(
  onTap: (){
    initiateSearchMethod();
  
  },
  child: Container(
     width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40)),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
  ),
)
                ],
               )

          ),
          isLoading?Center(child: CircularProgressIndicator(color:Theme.of(context).primaryColor),):groupList(),
        ],
      ),

    );
  }
  initiateSearchMethod() async{
if(searchController.text.isNotEmpty){
setState(() {
  isLoading=true;

});
await DatabaseService().searchByName(searchController.text).then((snapshot){
setState(() {
  searchSnapshot=snapshot;
   isLoading = false;
          hasUserSearched = true;
});
});
}


  }
  groupList(){
    return hasUserSearched? ListView.builder(
      itemCount: searchSnapshot!.docs.length,
      shrinkWrap: true,
      itemBuilder: (context,index){
        return groupTile(userName,
        searchSnapshot!.docs[index]['groupId'],
        searchSnapshot!.docs[index]['groupName'],
        searchSnapshot!.docs[index]['admin'],
        );
      }
    ):Container();

  }

  joinedOrNot(String userName, String groupId, String groupName, String admin) async{
  await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }
  Widget groupTile(String username, String groupId, String groupName,String admin){
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async{

        },
         child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join Now",
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}