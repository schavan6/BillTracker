import 'package:bill_tracker/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({required this.auth, required this.bill_id});
  final String bill_id;
  final AuthBase auth;

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Comments"),
        ),
        body: ChatScreen(auth: widget.auth, bill_id: widget.bill_id));
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.auth, required this.bill_id});
  final String bill_id;
  final AuthBase auth;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String bill_id = '';
  late List<QueryDocumentSnapshot>? listMessage;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    bill_id = widget.bill_id;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              buildMessages(),
              buildInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInput() {
    return Container(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              // Edit text
              Flexible(
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        autofocus: true,
                        maxLines: 5,
                        controller: textEditingController,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Type your message...',
                        ),
                      )),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(Icons.send, size: 25),
                  onPressed: () => onSendMessage(textEditingController.text),
                ),
              ),
            ],
          ),
        ),
        width: double.infinity,
        height: 100.0);
  }

  Widget buildMessages() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(bill_id)
            .collection(bill_id)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            listMessage = snapshot.data?.docs!;
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) =>
                  buildItem(index, snapshot.data?.docs![index]),
              itemCount: snapshot.data?.docs.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    /*if (!document!['read'] && document['idTo'] == uid) {
      print(document['read']);
      Database.updateMessageRead(document, convoID);
    }*/

    // Right (my message)
    if(document!['fromId'] == widget.auth.currentUser?.uid){
      return Row(
        children: <Widget>[
          // Text
          Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Bubble(
                  color: Colors.blueGrey,
                  elevation: 0,
                  padding: const BubbleEdges.all(10.0),
                  nip: BubbleNip.rightTop,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("You",
                          style: const TextStyle(color: Colors.white)),
                      SizedBox(height: 10,),
                      Text(document!['content'],
                          style: const TextStyle(color: Colors.black))
                    ],
                  )),
              width: 200)
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    else{
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                child: Bubble(
                    color: Colors.grey,
                    elevation: 0,
                    padding: const BubbleEdges.all(10.0),
                    nip: BubbleNip.leftTop,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(document!['from'],
                            style: const TextStyle(color: Colors.white)),
                        SizedBox(height: 10,),
                        Text(document!['content'],
                            style: const TextStyle(color: Colors.black))
                      ],
                    ),
                        ),
                width: 200.0,
                margin: const EdgeInsets.only(left: 10.0),
              )
            ])
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      );
    }

  }

  void onSendMessage(String content) {
    if (content.trim() != '') {
      textEditingController.clear();
      content = content.trim();
      _sendMessage(
          bill_id, content, DateTime.now().millisecondsSinceEpoch.toString());
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _sendMessage(
    String bill_id,
    String content,
    String timestamp,
  ) {
    //final DocumentReference convoDoc = FirebaseFirestore.instance.collection('messages').doc(bill_id);

    final DocumentReference messageDoc = FirebaseFirestore.instance
        .collection('messages')
        .doc(bill_id)
        .collection(bill_id)
        .doc(timestamp);

    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(
        messageDoc,
        <String, dynamic>{
          'from': widget.auth.currentUser?.displayName,
          'fromId': widget.auth.currentUser?.uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': content,
          'read': false
        },
      );
    });
  }
}
