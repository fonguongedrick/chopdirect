import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../buyer_services/buyer_storage.dart';

 class BuyerEditProfile extends StatefulWidget {
   const BuyerEditProfile({super.key});

   @override
   State<BuyerEditProfile> createState() => _BuyerEditProfileState();
 }

 class _BuyerEditProfileState extends State<BuyerEditProfile> {
   final User? currentUser = FirebaseAuth.instance.currentUser;
   bool isEditable = false;
   bool isEditable2 = false;
   bool isEditable3 = false;
   final TextEditingController _nameController = TextEditingController();
   final TextEditingController emailController = TextEditingController();
   final TextEditingController phoneNumberController = TextEditingController();

   Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
     if (currentUser == null) {
       return Future.error("User not logged in");
     }
     String? userId = currentUser?.uid;
     if(userId == null){
       return Future.error("User not logged in");
     }
     QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
         .collection("users_chopdirect")
         .where("userId", isEqualTo: userId)
         .limit(1)
         .get();

     if (querySnapshot.docs.isEmpty) {
       return Future.error("No user data found!");
     }

     return querySnapshot.docs.first;
   }

   //To update UserName
   Future<void> updateUser(String newName) async{
     if(currentUser == null) return;
     String? userId = currentUser?.uid;
     QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
         .collection("users_chopdirect")
         .where("userId", isEqualTo: userId)
         .limit(1)
         .get();

     if (querySnapshot.docs.isNotEmpty) {
       DocumentReference userRef = querySnapshot.docs.first.reference;
       await userRef.update({"name": newName});
     }
   }
  //to update userName

   //to update UserEmail
   Future<void> updateUserEmail(String newEmail) async {
     if (currentUser == null) return;
     String? userId = currentUser?.uid;

     QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
         .collection("users_chopdirect")
         .where("userId", isEqualTo: userId)
         .limit(1)
         .get();

     if (querySnapshot.docs.isNotEmpty) {
       DocumentReference userRef = querySnapshot.docs.first.reference;
       await userRef.update({"email": newEmail}); // ✅ Update email field
     }
   }
   //to update UserEmail


   //to update User PhoneNumber
   Future<void> updatePhoneNumber(String newPhonenumber) async {
     if (currentUser == null) return;
     String? userId = currentUser?.uid;

     QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
         .collection("users_chopdirect")
         .where("userId", isEqualTo: userId)
         .limit(1)
         .get();

     if (querySnapshot.docs.isNotEmpty) {
       DocumentReference userRef = querySnapshot.docs.first.reference;
       await userRef.update({"phoneNumber": newPhonenumber}); // ✅ Update email field
     }
   }
   //to update User PhoneNumber

   //to saveUpdated info
   Future<void> saveUserDetails() async {
     if (currentUser == null) return;
     String? userId = currentUser?.uid;

     QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
         .collection("users_chopdirect")
         .where("userId", isEqualTo: userId)
         .limit(1)
         .get();

     if (querySnapshot.docs.isNotEmpty) {
       DocumentReference userRef = querySnapshot.docs.first.reference;
       await userRef.update({
         "name": _nameController.text.trim(),
         "email": emailController.text.trim(),
         "phoneNumber": phoneNumberController.text.trim(),
       });

       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Profile updated successfully!")),
       );
       Navigator.pop(context,true);
     }
   }
   //to saveUpdated info

   //to fetch buyers storage
   Future<void> fetchImages() async {
     await Provider.of<StorageServices>(context, listen: false).fetchImages();
   }
   //to fetch buyers storage
   @override
  void initState() {
    super.initState();
  }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getUserDetails(),
            builder: (context, snapshot){
              if(snapshot.hasError){
                return Center(child: Text("ERROR: ${snapshot.error}"));
              }else if(!snapshot.hasData || !snapshot.data!.exists){
                return Center(child: Text(""));
              }
              Map<String, dynamic>? user = snapshot.data?.data();
              if(user == null){
                return Center(child: Text("User data is missing."));
              }

              if (_nameController.text.isEmpty) {
                _nameController.text = user["name"] ?? "";
              }
              if (emailController.text.isEmpty) {
                emailController.text = user["email"] ?? "";
              }
              if (phoneNumberController.text.isEmpty) {
                phoneNumberController.text = user["phoneNumber"] ?? "";
              }
               return Consumer<StorageServices>(
                 builder: (context, storageServices, child){
                   final List<String> imageUrl = storageServices.imageUrl;
                   return Stack(
                     children: [
                       Positioned(
                         top: 50,
                         left: 25,
                         child: IconButton(
                             onPressed: ()=>Navigator.pop(context),
                             icon: Icon(Icons.arrow_back,size: 40,)
                         ),
                       ),
                       Positioned(
                         top: 60,
                         left: 170,
                         child: Text("Edit Profile",
                           style: TextStyle(
                               fontSize: 22,
                               fontWeight: FontWeight.bold
                           ),
                         ),
                       ),
                       Positioned(
                         top: 130,
                         left: 140,
                         child: CircleAvatar(
                           radius: 90,
                           backgroundColor: Colors.grey,
                           backgroundImage: imageUrl.isNotEmpty
                               ? NetworkImage(imageUrl.last)
                               : AssetImage("assets/Ellipse 7.png"),
                         ),
                       ),
                       Positioned(
                           top: 250,
                           left: 280,
                           child: GestureDetector(
                             onTap: () async {
                             fetchImages();
                              await storageServices.uploadImage();
                              setState(() {});
                             },
                             child: Container(
                               height: 40,
                               width: 40,
                               decoration: BoxDecoration(
                                   color: Colors.green,
                                   shape: BoxShape.circle
                               ),
                               child: Icon(Icons.camera_alt,color: Colors.white,),
                             ),
                           )
                       ),


                       //user name update
                       Positioned(
                         top: 370,
                         left: 20,
                         right: 20,
                         child: Container(
                           height: 110,
                           width: double.infinity,
                           decoration: BoxDecoration(
                               color: Colors.grey.shade300,
                               borderRadius: BorderRadius.circular(30)
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Padding(
                                 padding: const EdgeInsets.only(left: 15,top: 15),
                                 child: Text('Username',
                                   style: TextStyle(
                                     fontSize: 18,
                                   ),
                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 8),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     isEditable
                                         ? Expanded(
                                       child: TextField(
                                         autofocus: isEditable,
                                         controller: _nameController,
                                         decoration: const InputDecoration(
                                           border: InputBorder.none,
                                           fillColor: Colors.transparent,
                                           filled: true,
                                         ),
                                       ),
                                     )
                                         :Text(
                                       user["name"] ?? "No User",
                                       style: TextStyle(
                                           fontSize: 22,
                                           fontWeight: FontWeight.bold
                                       ),
                                     ),
                                     GestureDetector(
                                       onTap: () async{
                                         if (isEditable) {
                                           String newName = _nameController.text.trim();

                                           if (newName.isNotEmpty) {
                                             await updateUser(newName);
                                             setState(() {
                                               user["name"] = newName;
                                             });
                                           }
                                         }
                                         setState(() {
                                           isEditable = !isEditable;
                                         });
                                       },
                                       child: Container(
                                         height: 40,
                                         width: 40,
                                         decoration: BoxDecoration(
                                             color: Colors.white,
                                             shape: BoxShape.circle
                                         ),
                                         child: Icon(
                                           isEditable
                                               ?Icons.check
                                               :Icons.edit,
                                           color: Colors.green,
                                         ),
                                       ),
                                     )
                                   ],
                                 ),
                               )
                             ],
                           ),
                         ),
                       ),
                       //user name update

                       //User email Update
                       Positioned(
                           top: 500,
                           left: 15,
                           right: 15,
                           child: Container(
                             height: 110,
                             width: double.infinity,
                             decoration: BoxDecoration(
                               color: Colors.grey.shade300,
                               borderRadius: BorderRadius.circular(30),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Padding(
                                     padding: const EdgeInsets.only(left: 15,top: 15),
                                     child: Text('Email',
                                         style: TextStyle(
                                           fontSize: 18,
                                         )
                                     )
                                 ),
                                 Padding(
                                     padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 8),
                                     child: Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           isEditable2
                                               ?Expanded(
                                             child: TextField(
                                               autofocus: isEditable2,
                                               controller: emailController,
                                               decoration: const InputDecoration(
                                                 border: InputBorder.none,
                                                 fillColor: Colors.transparent,
                                                 filled: true,
                                               ),
                                             ),
                                           )
                                               :Text(user["email"] ?? "No Email",
                                             style: TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 22
                                             ),
                                           ),
                                           GestureDetector(
                                             onTap: () async{
                                               if (isEditable2) {
                                                 String newEmail = emailController.text;

                                                 if (newEmail.isNotEmpty) {
                                                   await updateUserEmail(newEmail);
                                                   setState(() {
                                                     user["name"] = newEmail;
                                                   });
                                                 }
                                               }
                                               setState(() {
                                                 isEditable2 = !isEditable2;
                                               });
                                             },
                                             child: Container(
                                               height: 40,
                                               width: 40,
                                               decoration: BoxDecoration(
                                                   color: Colors.white,
                                                   shape: BoxShape.circle
                                               ),
                                               child: Icon(
                                                 isEditable2
                                                     ?Icons.check
                                                     :Icons.edit,
                                                 color: Colors.green,
                                               ),
                                             ),
                                           )
                                         ]
                                     )
                                 )
                               ],
                             ),
                           )
                       ),
                       //user email update

                       //user phoneNumberUpdate
                       Positioned(
                           top: 635,
                           left: 15,
                           right: 15,
                           child: Container(
                             height: 110,
                             width: double.infinity,
                             decoration: BoxDecoration(
                               color: Colors.grey.shade300,
                               borderRadius: BorderRadius.circular(30),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Padding(
                                     padding: const EdgeInsets.only(left: 15,top: 15),
                                     child: Text('PhoneNumber',
                                         style: TextStyle(
                                           fontSize: 18,
                                         )
                                     )
                                 ),
                                 Padding(
                                     padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 8),
                                     child: Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           isEditable3
                                               ?Expanded(
                                             child: TextField(
                                               autofocus: isEditable3,
                                               controller: phoneNumberController,
                                               decoration: const InputDecoration(
                                                 border: InputBorder.none,
                                                 fillColor: Colors.transparent,
                                                 filled: true,
                                               ),
                                             ),
                                           )
                                               :Text(user["phoneNumber"] ?? "",
                                             style: TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 22
                                             ),
                                           ),
                                           GestureDetector(
                                             onTap: () async{
                                               if (isEditable3) {
                                                 String newPhoneNumber = phoneNumberController.text;

                                                 if (newPhoneNumber.isNotEmpty) {
                                                   await updateUser(newPhoneNumber);
                                                   setState(() {
                                                     user["name"] = newPhoneNumber;
                                                   });
                                                 }
                                               }
                                               setState(() {
                                                 isEditable3 = !isEditable3;
                                               });
                                             },
                                             child: Container(
                                               height: 40,
                                               width: 40,
                                               decoration: BoxDecoration(
                                                   color: Colors.white,
                                                   shape: BoxShape.circle
                                               ),
                                               child: Icon(
                                                 isEditable3
                                                     ?Icons.check
                                                     :Icons.edit,
                                                 color: Colors.green,
                                               ),
                                             ),
                                           )
                                         ]
                                     )
                                 )
                               ],
                             ),
                           )
                       ),
                       //user phoneNumberUpdate

                       //save updatedInfo button
                       Positioned(
                         top: 780,
                         left: 155,
                         child: ElevatedButton(
                             onPressed: saveUserDetails,
                             child: Text("Save Changes")
                         ),
                       )
                       //save updatedInfo button
                     ],
                   );
                 },
               );
            }
        )
     );
   }
 }
