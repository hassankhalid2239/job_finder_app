// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import '../Widgets/snackbar.dart';
import 'gender_screen.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _editDataFormKey = GlobalKey<FormState>();
  final TextEditingController _emailTextControler =
      TextEditingController(text: '');
  final TextEditingController _phoneTextControler =
      TextEditingController(text: '');
  final TextEditingController _locationTextControler =
      TextEditingController(text: '');
  final Snack snack = Snack();
  bool _isLoading = false;
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? imageUrl;
  String? _imgUrl;
  String? _gndr;

  @override
  void initState() {
    super.initState();
    _getEditProfileData();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _getGender();
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      cropImage(image.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          snack.errorSnackBar('On Error!', 'Failed to pick image'));
      // return 'Failed to pick image';
    }
  }

  Future pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      cropImage(image.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          snack.errorSnackBar('On Error!', 'Failed to pick image'));
      // return 'Failed to pick image';
    }
  }

  Future cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage == null) {
      setState(() {
        imageFile = null;
      });
    }
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  Future uploadProfileData() async {
    final isValid = _editDataFormKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        final User? user = _auth.currentUser;
        final uid = user!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child('userProfileImages')
            .child('$uid.jpg');
        if (imageFile != null) {
          await ref.putFile(imageFile!);
          imageUrl = await ref.getDownloadURL();
          FirebaseFirestore.instance.collection('Users').doc(uid).update({
            'User Image': imageUrl,
            'Phone Number': _phoneTextControler.text,
            'Location': _locationTextControler.text,
          });
          Future.delayed(const Duration(seconds: 1)).then((value) => {
                setState(() {
                  _isLoading = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                      snack.successSnackBar(
                          'Congrats!', 'Changes saved successfully'));
                })
              });
        } else {
          FirebaseFirestore.instance.collection('Users').doc(uid).update({
            'Phone Number': _phoneTextControler.text,
            'Location': _locationTextControler.text,
          });
          Future.delayed(const Duration(seconds: 1)).then((value) => {
                setState(() {
                  _isLoading = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                      snack.successSnackBar(
                          'Congrats!', 'Changes saved successfully'));
                })
              });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (e.message ==
            'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
          ScaffoldMessenger.of(context).showSnackBar(
              snack.errorSnackBar('On Error!', 'No Internet Connection'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              snack.errorSnackBar('On Error!', e.message.toString()));
        }
      }
    }
  }

  void deletePF() {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'User Image': '',
    });
  }

  Future _getEditProfileData() async {
    DocumentSnapshot ref =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    setState(() {
      _emailTextControler.text = ref.get('Email');
      _phoneTextControler.text = ref.get('Phone Number');
      _locationTextControler.text = ref.get('Location');
      _imgUrl = ref.get('User Image');
      _gndr = ref.get('Gender');
    });
  }

  Future _getGender() async {
    DocumentSnapshot ref =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    setState(() {
      _gndr = ref.get('Gender');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.onSurface,
            statusBarIconBrightness: Theme.of(context).brightness),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 0,
        centerTitle: true,
        title: Text('Edit Profile',
            style: Theme.of(context).textTheme.labelMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            pickImageCamera();
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.background),
                            padding:
                                const MaterialStatePropertyAll(EdgeInsets.zero),
                            shape: const MaterialStatePropertyAll(
                                BeveledRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            // splashFactory: InkSplash.splashFactory,
                            splashFactory: InkSparkle.splashFactory,
                            overlayColor: const MaterialStatePropertyAll(
                                Color(0x4d5800ff)),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.camera_alt,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            title: Text(
                              'Take profile picture',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            pickImage();
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Theme.of(context).colorScheme.background),
                            padding:
                                const MaterialStatePropertyAll(EdgeInsets.zero),
                            shape: const MaterialStatePropertyAll(
                                BeveledRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            // splashFactory: InkSplash.splashFactory,
                            splashFactory: InkSparkle.splashFactory,
                            overlayColor: const MaterialStatePropertyAll(
                                Color(0x4d5800ff)),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.photo_library,
                                color: Theme.of(context).colorScheme.outline),
                            title: Text(
                              'Select profile picture',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                        ),
                        _imgUrl == ''
                            ? imageFile == null
                                ? const SizedBox()
                                : ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        imageFile = null;
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Theme.of(context)
                                              .colorScheme
                                              .background),
                                      padding: const MaterialStatePropertyAll(
                                          EdgeInsets.zero),
                                      shape: const MaterialStatePropertyAll(
                                          BeveledRectangleBorder(
                                              borderRadius: BorderRadius.zero)),
                                      // splashFactory: InkSplash.splashFactory,
                                      splashFactory: InkSparkle.splashFactory,
                                      overlayColor:
                                          const MaterialStatePropertyAll(
                                              Color(0x4d5800ff)),
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.delete_forever,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                      title: Text(
                                        'Delete profile image',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge,
                                      ),
                                    ),
                                  )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    deletePF();
                                    _imgUrl = null;
                                    imageFile = null;
                                    imageUrl = null;
                                    Navigator.pop(context);
                                  });
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfilePage()));
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Theme.of(context).colorScheme.background),
                                  padding: const MaterialStatePropertyAll(
                                      EdgeInsets.zero),
                                  shape: const MaterialStatePropertyAll(
                                      BeveledRectangleBorder(
                                          borderRadius: BorderRadius.zero)),
                                  // splashFactory: InkSplash.splashFactory,
                                  splashFactory: InkSparkle.splashFactory,
                                  overlayColor: const MaterialStatePropertyAll(
                                      Color(0x4d5800ff)),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.delete_forever,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                  title: Text(
                                    'Delete profile image',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                ),
                              )
                      ],
                    );
                  });
            },
            child: DottedBorder(
              padding: const EdgeInsets.all(6),
              color: const Color(0xff5800FF),
              borderType: BorderType.Circle,
              dashPattern: const [5, 5],
              strokeCap: StrokeCap.round,
              strokeWidth: 2,
              child: Center(
                  child: _imgUrl == ''
                      ? CircleAvatar(
                          // backgroundColor: Theme.of(context).colorScheme.background,
                          radius: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: imageFile == null
                                ? const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                : Image.file(imageFile!, fit: BoxFit.cover),
                          ))
                      : CircleAvatar(
                          radius: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: imageFile == null
                                ? Image.network(_imgUrl.toString(),
                                    fit: BoxFit.cover)
                                : Image.file(imageFile!, fit: BoxFit.cover),
                          ))),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Form(
            key: _editDataFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
                Text('Your Email Account',
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  enabled: false,
                  textInputAction: TextInputAction.next,
                  // onEditingComplete: () =>
                  //     FocusScope.of(context).requestFocus(_passFocusNode),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailTextControler,
                  style: Theme.of(context).textTheme.titleSmall,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.all(15),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                    hintText: 'Usermail@gmail.com',
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                    prefixIcon: const Icon(
                      Icons.mail_outline_sharp,
                      size: 20,
                      color: Colors.grey,
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color(0xff5800FF),
                    )),
                    enabledBorder:
                        const UnderlineInputBorder(borderSide: BorderSide.none),
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.redAccent,
                    )),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.red,
                    )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Phone
                Text('Phone', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  // focusNode: _passFocusNode,
                  keyboardType: TextInputType.phone,
                  controller: _phoneTextControler,
                  //Change it dynamically
                  validator: (value) {
                    if (value == null) {
                      return;
                    }
                    return;
                  },
                  style: Theme.of(context).textTheme.titleSmall,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.all(15),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                    hintText: '+62821 - 3948 - 9384',
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                    prefixIcon: const Icon(
                      Icons.phone_android_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    enabledBorder:
                        const UnderlineInputBorder(borderSide: BorderSide.none),
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.redAccent,
                    )),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color(0xff5800FF),
                    )),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.redAccent,
                    )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Location
                Text('Location', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  // focusNode: _passFocusNode,
                  keyboardType: TextInputType.text,
                  controller: _locationTextControler,
                  //Change it dynamically
                  validator: (value) {
                    if (value == null) {
                      return;
                    }
                    return;
                  },
                  style: Theme.of(context).textTheme.titleSmall,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.all(15),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                    hintText: 'ex: Islamabad, Pakistan',
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    enabledBorder:
                        const UnderlineInputBorder(borderSide: BorderSide.none),
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.redAccent,
                    )),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color(0xff5800FF),
                    )),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.redAccent,
                    )),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Gender
                Text('Gender', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: const GenderScreen(),
                            type: PageTransitionType.rightToLeft));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          borderRadius: BorderRadius.circular(4)),
                      child: ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                        ),
                        title: Text(
                          '$_gndr',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 150),
          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    splashFactory: InkRipple.splashFactory,
                    backgroundColor: const Color(0xff5800FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  uploadProfileData();
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        'Save Change',
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
          ),
        ],
      ),
    );
  }
}
