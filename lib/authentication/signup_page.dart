import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_sellers/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    "Dessert Shop",
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


  Future<bool> formValidation() async {
    if (imageXFile == null) {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please select an image.",
          );
        },
      );
      return false; // Validation failed
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
            },
          );

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference =
          fStorage.FirebaseStorage.instance.ref().child("sellers").child(fileName);
          fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;

            // Save info to firestore
            authenticateSellerAndSignUp();
          });
          return true; // Validation successful
        } else {
          showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Please write the complete required info for Registration.",
              );
            },
          );
          return false; // Validation failed
        }
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Password do not match.",
            );
          },
        );
        return false; // Validation failed
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
      "open": "close",
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
      backgroundColor: AppColors().white,
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
                 SizedBox(height: 20.h),
                  Text("Choose your store Profile",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 10.sp
                  ),),
                  SizedBox(height: 20.h),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            controller: nameController,
                            data: Icons.person,
                            hintText: "Enter your Shop Name",
                            isObsecure: false,
                            keyboardType: TextInputType.text,
                            inputTextStyle: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),

                          child: Theme(
                            data: Theme.of(context).copyWith(
                              // Set the text style for the dropdown menu items
                              textTheme: Theme.of(context).textTheme.copyWith(
                                subtitle1: TextStyle(
                                  fontSize: 12.sp, // Adjust the font size
                                  color: Colors.black, // Adjust the text color
                                ),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              items: categoryOptions.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      // Define your desired text style here
                                      fontSize: 12,
                                      fontFamily: "Poppins",// Adjust the font size
                                      color: Colors.black, // Adjust the text color
                                    ),
                                  ),
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
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),



                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            controller: emailController,
                            data: Icons.email,
                            hintText: "Enter your Email",
                            isObsecure: false,
                            keyboardType: TextInputType.text,
                            inputTextStyle: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12.sp,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            controller: phoneController,
                            hintText: "Enter your Phone Number",
                            hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 10.sp),
                            data: Icons.phone,
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            isObsecure: false,
                            inputTextStyle: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12.sp,
                            ),
                          ),
                        ),





                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            controller: passwordController,
                            data: Icons.password,
                            hintText: "Enter your Password",
                            keyboardType: TextInputType.text,
                            isObsecure: true,
                            inputTextStyle: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            controller: confirmPasswordController,
                            data: Icons.password_rounded,
                            hintText: "Confirm your Password",
                            keyboardType: TextInputType.text,
                            isObsecure: true,
                            inputTextStyle: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomTextField(
                            controller: locationController,
                            data: Icons.location_city,
                            hintText: "Enter your Address",
                            isObsecure: false,
                            enabled: false,
                            inputTextStyle: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12.sp
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h,),

                        Container(
                          width: 400.w,
                          height: 50.h,
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            label: Text(
                              "Get my current location",
                              style: TextStyle(color: AppColors().white,
                              fontSize: 10.sp,
                              fontFamily: "Poppins"),

                            ),

                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            onPressed: () {

                              getCurrentLocation();


                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors().black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: w * 0.08),
                  SizedBox(
                    width: 170.w, // Set the desired width
                    child:ElevatedButton(
                      onPressed: () async {
                        // Perform form validation
                        bool isValid = await formValidation();
                        if (isValid) {
                          // Navigate only if the validation is successful
                          Navigator.push(context, MaterialPageRoute(builder: (c) => DocumentSubmission()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        backgroundColor: AppColors().red,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Proceed",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )

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