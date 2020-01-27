import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_sales/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:local_sales/image/image_picker_handler.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';


bool isSwitched = false;

class EditProfile extends StatefulWidget {
  EditProfile({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with TickerProviderStateMixin, ImagePickerListener {

  AnimationController _controller;
  ImagePickerHandler imagePicker;
  String imageUrl = UserModel().userData["photoUrl"];
  File imageFile;
  File _image;
  bool change = false;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final date = new RegExp(r"\d\d\/\d\d\/\d\d\d\d");

  static TextEditingController _PicPay = new TextEditingController();
  static TextEditingController _phone = new TextEditingController();
  static TextEditingController _birth = new TextEditingController();
  static TextEditingController _name = new TextEditingController();
  static TextEditingController _email = new TextEditingController();

  Map<String, dynamic> new_data = Map();

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Color themeColor= Colors.orange;

  Future cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.grey,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

  }

  @override
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        UserModel().savephotoUrl(imageUrl);
        //onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }


  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    cropImage(imageFile);
    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(isLoading == true) {
      print("\n\n\n\n\n\n\n\n\n\ aaaaaaaaaaaaaaaaaaaaa \n\n\n\n\n");
      change = true;
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
        ),
        color: Colors.white.withOpacity(0.8),
      );
    }
    else
    return Scaffold(
        appBar: AppBar(
          title: Text("Edições do Usuário"),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: new SingleChildScrollView(child:
            ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          model.loadUserData();
          //new_data = model.userData;
          return Form(
            key: _formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          child: Container(
                              width: 190.0,
                              height: 190.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageUrl != model.userData["photoUrl"] && imageUrl != "" && imageUrl != null
                                          ? NetworkImage(imageUrl)
                                          : NetworkImage(model.userData["photoUrl"]),
                                  )
                              )
                          ),
                            onTap: () async {

                              await getImage();
                              print("ola");
                              print(imageUrl);
                              print(imageUrl);
                              print(imageUrl);
                              print(imageUrl);
                              print(imageUrl);


                            },
                        )
                    )
                ),
                new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new Align(
                        alignment: Alignment.center,
                        child: Text(
                          "${model.userData["name"]}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black45),
                        ))),
                new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new TextFormField(
                      initialValue: model.userData["name"],
                      onSaved: model.saveName,
                      // controller: _name,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(labelText: "Nome"),
                      validator: (text) {
                        if (text.isEmpty) return "Nome Inválido!";
                      },
                    )),
                new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new TextFormField(
                      initialValue: model.userData["email"],
                      onSaved: model.saveEmail,
                      //controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          new InputDecoration(labelText: "Endereço de Email"),
                      validator: (text) {
                        if (text.isEmpty || !text.contains("@"))
                          return "E-mail inválido!";
                        return null;
                      },
                    )),
                new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new TextFormField(
                      initialValue: model.userData["birth"],
                      onSaved: model.saveBirth,
                      //controller: _birth,
                      enabled: true,
                      decoration: new InputDecoration(
                        labelText: 'Data de Nascimento',
                      ),
                      validator: (text) {
                        if (text.isEmpty || (!date.hasMatch(text)))
                          return "Data Inválida!";
                      },
                    )),
                new Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    initialValue: model.userData["phone"],
                    onSaved: UserModel().savePhone,
                    //controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: new InputDecoration(labelText: 'Telefone'),
                    validator: (text) {
                      if (text.isEmpty) return "Telefone Inválido!";
                    },
                  ),
                ),
                new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new Row(
                      children: <Widget>[
                        Text("PicPay", textAlign: TextAlign.left),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Switch(
                            value: isSwitched,
                            onChanged: (value) {
                              setState(() {
                                isSwitched = value;
                              });
                            },
                            activeTrackColor: Colors.deepOrangeAccent,
                            activeColor: Colors.deepOrange,
                          ),
                        )
                      ],
                    )),
                new Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    initialValue: model.userData["picpay"],
                    onSaved: model.savePicpay,
                    //controller: _PicPay,
                    enabled: isSwitched,
                    decoration: new InputDecoration(
                        hintText: 'PicPay User', labelText: '@nickname'),
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 60.0),
                  child: RaisedButton(
                    color: Colors.orange,
                    child: Text(
                      "Submeter",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();

                        new_data = model.userData;


                        if(change == true)
                          new_data["photoUrl"] = imageUrl;

                        await Firestore.instance
                            .collection("users")
                            .document(model.firebaseUser.uid)
                            .updateData(new_data);

                        Navigator.pop(context);
                      }
                    },
                  ),
                )
              ],
            ),
          );
        })));
  }
}
