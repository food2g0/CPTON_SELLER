import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/error_dialog.dart';
import '../Widgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/document_submission.dart';
import '../mainScreen/home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String selectedCategory = "Buffet"; // Default category
  TextEditingController categoryController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";

  List<String> categoryOptions = [
    "Buffet",
    "Cake Shop",
    "Milk Tea Shop",
    "Coffee Shop",
    "Fast Food",
    "Burger Shop",
    // Add more categories as needed
  ];
  // Default category

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    // Check if the subLocality is equal to "Pinamalayan"
    if (pMark.locality != "Pinamalayan") {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please select a valid address in Pinamalayan.",
          );
        },
      );
      return; // Exit the function early
    }

    completeAddress =
    '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }


  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please select an image.",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          // Start uploading image
          showDialog(
              context: context,
              builder: (c) {
                return LoadingDialog(
                  message: "Registering Account",
                );
              });

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference =
          fStorage.FirebaseStorage.instance.ref().child("sellers").child(fileName);
          fStorage.UploadTask uploadTask =
          reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;

            // Save info to firestore
            authenticateSellerAndSignUp();
          });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return ErrorDialog(
                  message: "Please write the complete required info for Registration.",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Password do not match.",
              );
            });
      }
    }
  }



  void authenticateSellerAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      await saveDataToFirestore(currentUser!);

      // Check the status before redirecting
      if (currentUser != null && currentUser!.uid.isNotEmpty) {
        FirebaseFirestore.instance
            .collection("sellers")
            .doc(currentUser?.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            String status = documentSnapshot.get("status");
          } else {
            // Handle the case where the document does not exist
          }
        });
      }
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    CollectionReference salesCollection = FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).collection("sales");

    // Create documents for January, February, and March
    await salesCollection.doc("01_January").set({
      // Add fields specific to January sales if needed
      "saleVal": 0.0,
      "colorVal": "0xFFe63946",
      "saleYear": "Jan"
    });
    await salesCollection.doc("02_February").set({
      // Add fields specific to February sales if needed
      "saleVal": 0.0,
      "color": "0xFFe63946",
      "saleYear": "Feb"
    });
    await salesCollection.doc("03_March").set({
      // Add fields specific to March sales if needed
      "saleVal": 0.0,
      "colorVal": "0xFFe63946",
      "saleYear": "Mar"
    });
    await salesCollection.doc("04_April").set({
      // Add fields specific to March sales if needed
      "saleVal": 0.0,
      "colorVal": "0xFFe63946",
      "saleYear": "Apr"
    });
    await salesCollection.doc("05_May").set({
      // Add fields specific to March sales if needed
      "saleVal": 0.0,
      "colorVal": "0xFFe63946",
      "saleYear": "May"
    });

    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellersUID": currentUser.uid,
      "sellersEmail": currentUser.email,
      "sellersName": nameController.text.trim(),
      "sellersImageUrl": sellerImageUrl,
      "sellersphone": phoneController.text.trim(),
      "sellersAddress": completeAddress,
      "sellersCategory": categoryController.text, // Use categoryController.text
      "status": "disapproved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    // Save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("sellersUID", currentUser.uid);
    await sharedPreferences!.setString("sellersEmail", currentUser.email.toString());
    await sharedPreferences!.setString("sellersName", nameController.text.trim());
    await sharedPreferences!.setString("sellersImageUrl", sellerImageUrl);
  }


  @override
  Widget build(BuildContext context) {



    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/log.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      _getImage();
                    },
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.10,
                      backgroundColor: Colors.black87,
                      backgroundImage: imageXFile == null
                          ? null
                          : FileImage(File(imageXFile!.path)),
                      child: imageXFile == null
                          ? Icon(
                        Icons.add_photo_alternate,
                        size: MediaQuery.of(context).size.width * 0.10,
                        color: Colors.grey,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: nameController,
                          data: Icons.person,
                          hintText: "Enter your Shop Name",
                          isObsecure: false,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            items: categoryOptions.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? selectedCategory) {
                              setState(() {
                                this.selectedCategory = selectedCategory ?? "Desert";
                                categoryController.text = this.selectedCategory;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.category_outlined),
                              hintText: "Select Shop Category",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: emailController,
                          data: Icons.email,
                          hintText: "Enter your Email",
                          isObsecure: false,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: phoneController,
                          data: Icons.phone_android,
                          hintText: "Enter your Phone Number",
                          isObsecure: false,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: passwordController,
                          data: Icons.password,
                          hintText: "Enter your Password",
                          isObsecure: true,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: confirmPasswordController,
                          data: Icons.password_rounded,
                          hintText: "Confirm your Password",
                          isObsecure: true,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: locationController,
                          data: Icons.location_city,
                          hintText: "Enter your Address",
                          isObsecure: false,
                          enabled: false,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 400,
                          height: 40,
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            label: const Text(
                              "Get my current location",
                              style: TextStyle(color: Colors.white),
                            ),
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            onPressed: () {

                              getCurrentLocation();


                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black45,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: w * 0.08),
                  SizedBox(
                    width: 150, // Set the desired width
                    child: ElevatedButton(
                      onPressed: () {

                        formValidation();
                          Navigator.push(context, MaterialPageRoute(builder: (c) => DocumentSubmission()));


                      },


                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black45,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: w * 0.08),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}