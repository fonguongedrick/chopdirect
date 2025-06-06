import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

 class ProductOverview extends StatefulWidget {
   final String name;
   final String image;
   final double rating;
   final String price;
   final String farmer;
   final int? stock;
   final VoidCallback updateCartBadge;
   const ProductOverview({super.key,
    required this.name,
    required this.image,
    required this.rating,
    required this.price,
    required this.farmer,
    required this.stock,
     required this.updateCartBadge
   });

  @override
  State<ProductOverview> createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
   void addToCart() async {
     User? currentUser = FirebaseAuth.instance.currentUser;
     if (currentUser == null) {
       print("User not logged in!");
       return;
     }

     // Query all cart items for the current user.
     QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
         .collection("cart")
         .where("userId", isEqualTo: currentUser.email)
         .get();

     // If there are items in the cart, check the farmer field.
     if (cartSnapshot.docs.isNotEmpty) {
       // Get the farmer of the first product in the cart.
       String existingFarmer = cartSnapshot.docs.first['farmer'];
       if (existingFarmer != widget.farmer) {
         // If the current product's farmer is different, show a dialog.
         showDialog(
           context: context,
           builder: (context) {
             return AlertDialog(
               title: const Text('Sorry'),
               content: const Text(
                   'You cannot add products from a different farmer to your cart.'),
               actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.of(context).pop(); // Close the dialog.
                   },
                   child: const Text('OK'),
                 ),
               ],
             );
           },
         );
         return;
       }
     }

     // Either the cart is empty or the farmer matches; proceed to add/update the product.
     DocumentReference cartRef = FirebaseFirestore.instance
         .collection("cart")
         .doc("${currentUser.email}_${widget.name}");

     DocumentSnapshot cartItem = await cartRef.get();

     if (cartItem.exists) {
       int currentQuantity = cartItem["quantity"] ?? 1;
       await cartRef.update({
         "quantity": currentQuantity + 1,
       });
     } else {
       await cartRef.set({
         "userId": currentUser.email,
         "name": widget.name,
         "price": widget.price,
         "imageUrl": widget.image,
         "quantity": 1, // Default quantity
         "farmer": widget.farmer, // Store the product's farmer
       });
     }

     widget.updateCartBadge();
     print("${widget.name} added to cart!");
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Container(
             height: 280,
               width: double.infinity,
               child: Stack(
                 children: [
                   Image.network(widget.image,fit: BoxFit.cover,width: double.infinity,),
                   Positioned(
                     top:40,
                     left: 20,
                     child: GestureDetector(
                       onTap: ()=>Navigator.pop(context),
                       child: Container(
                         height: 50,
                         width: 50,
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.8),
                           shape: BoxShape.circle,
                         ),
                         child: Icon(Icons.keyboard_arrow_left_rounded,size: 40,),
                       ),
                     ),
                   ),
                 ],
               )
           ),
           SizedBox(height: 15,),
           Padding(
             padding: const EdgeInsets.only(left: 20.0,right: 20),
             child: Row(
               children: [
                 Text(widget.name,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  ),
                 ),
                 Spacer(),
                 Text("From: ${widget.farmer}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                 )
               ],
             ),
           ),
           SizedBox(height: 10,),
           Padding(
             padding: const EdgeInsets.only(left: 20.0),
             child: Text(widget.price,
               style: TextStyle(
                  fontWeight: FontWeight.w600,
                 fontSize: 25
               ),
             ),
           ),
           SizedBox(height: 10,),
           Padding(
             padding: const EdgeInsets.only(left: 20.0,right: 20),
             child: Row(
               children: [
                 Icon(Icons.star,color: Colors.yellow,size: 30,),
                 SizedBox(width: 10,),
                 Text(widget.rating.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                 ),
                 Spacer(),
                 Text("See all reviews",
                   style: TextStyle(
                     fontWeight: FontWeight.w800,
                     fontSize: 16,
                     decoration: TextDecoration.underline
                   ),
                 )
               ]
             )
           ),
           Spacer(),
           GestureDetector(
             onTap: addToCart,
             child: Container(
               margin: EdgeInsets.symmetric(horizontal: 20),
               height: 53,
               width: double.infinity,
               decoration: BoxDecoration(
                 color: Colors.green,
                 borderRadius: BorderRadius.circular(22),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.5),
                     offset: Offset(0, 3),
                     spreadRadius: 2,
                     blurRadius: 5,
                   )
                 ]
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Image.asset("assets/cart.png",color: Colors.white,),
                   SizedBox(width: 20,),
                   Text("Add to cart",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white
                    ),
                   )
                 ],
               ),
             ),
           ),
           SizedBox(height: 30,),
         ],
       ),
     );
   }
}
