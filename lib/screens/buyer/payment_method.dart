import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mesomb/mesomb.dart';

import 'order_confirmation.dart';

class PaymentMethod extends StatefulWidget {
  final double? subtotal;
  const PaymentMethod({super.key,this.subtotal});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  late PaymentOperation payment;
  final TextEditingController _phoneController = TextEditingController();
  final double deliveryFee = 500; // Static delivery fee

  @override
  void initState() {
    super.initState();
    payment = PaymentOperation(
        '795ee41f78b16c24023a17ed94a90bf577b569c4',
        '98af2657-3378-40e1-adfb-5b1017ffb25d',
        'bb817a20-d65a-4566-9d75-46381ff8c19f'
    );
    _phoneController.text = "+237";
  }


  //MTN Payment
  Future<void> processPaymentMTNPayment() async {
    double subtotal = widget.subtotal ?? 0;
    double totalAmount = subtotal + deliveryFee;
    String nonce = Random().nextInt(1000000).toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter Payment Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 26),
              TextField(
                controller: TextEditingController(text: "${subtotal.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Subtotal"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${deliveryFee.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Delivery Fee"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${totalAmount.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "TotalPayment"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  if (!value.startsWith("+237")) {
                    _phoneController.text = "+237";
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _phoneController.text.length),
                    );
                  }
                },
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  String phone = _phoneController.text.trim();
                  // Navigator.pop(context);
                  // Payment Logic with MeSomB API
                  if (phone.isEmpty || !phone.startsWith("+237") || phone.length <= 12) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please enter a valid phone number'),
                    ));
                    return;
                  }

                  final response = await payment.makeCollect(
                      amount: 1,
                      service: "MTN",
                      payer: phone,
                      nonce: nonce
                  );

                  if (response.isTransactionSuccess()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderConfirmationScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Payment failed, please try again'),
                    ));
                  }

                },
                //Payment Logic with MeSomB API
                child: Text("Make Payment"),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
  //MTN Payment

  //Orange Payment
  Future<void> processOrangePayment() async {
    double subtotal = widget.subtotal ?? 0;
    double totalAmount = subtotal + deliveryFee;
    String nonce = Random().nextInt(1000000).toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter Payment Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 26),
              TextField(
                controller: TextEditingController(text: "${subtotal.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Subtotal"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${deliveryFee.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Delivery Fee"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${totalAmount.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "TotalPayment"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  if (!value.startsWith("+237")) {
                    _phoneController.text = "+237";
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _phoneController.text.length),
                    );
                  }
                },
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  String phone = _phoneController.text.trim();
                  // Navigator.pop(context);
                  // Payment Logic with MeSomB API
                  if (phone.isEmpty || !phone.startsWith("+237") || phone.length <= 12) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please enter a valid phone number'),
                    ));
                    return;
                  }

                  final response = await payment.makeCollect(
                      amount: 1,
                      service: "Orange",
                      payer: phone,
                      nonce: nonce
                  );

                  if (response.isTransactionSuccess()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderConfirmationScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Payment failed, please try again'),
                    ));
                  }

                },
                //Payment Logic with MeSomB API
                child: Text("Make Payment"),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
  //Orange Payment

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: SafeArea(
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Center(child: Padding(
             padding: const EdgeInsets.only(top: 20.0),
             child: Text("Complete Payment Via...",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),
             ),
           )),
           SizedBox(height: 40,),

           SizedBox(height: 100,),
           GestureDetector(
             onTap: processPaymentMTNPayment,
             child: Container(
               margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 83,
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(22),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withAlpha(20),
                       spreadRadius: 2,
                       blurRadius: 2,
                       offset: Offset(0, 2)
                     )
                   ]
                 ),
                 child: Row(
                   children: [
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                       child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                           child: Image.asset("assets/mtnmomo.png",scale: 2,)),
                     ),
                     SizedBox(width: 20,),
                     Text("MTN Mobile Money",
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 20
                       ),
                     ),
                     Spacer(),
                     Icon(Icons.keyboard_arrow_right,size: 40,),
                   ],
                 )
             ),
           ),

           SizedBox(height: 30,),
           GestureDetector(
             onTap: processOrangePayment,
             child: Container(
                 margin: EdgeInsets.symmetric(horizontal: 20),
                 height: 83,
                 width: double.infinity,
                 decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(22),
                     boxShadow: [
                       BoxShadow(
                           color: Colors.black.withAlpha(20),
                           spreadRadius: 2,
                           blurRadius: 2,
                           offset: Offset(0, 2)
                       )
                     ]
                 ),
                 child: Row(
                   children: [
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                       child: ClipRRect(
                           borderRadius: BorderRadius.circular(10),
                           child: Image.asset("assets/orangemoney.jpeg",scale: 2,)),
                     ),
                     SizedBox(width: 20,),
                     Text("Orange Money",
                       style: TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 20
                       ),
                     ),
                     Spacer(),
                     Icon(Icons.keyboard_arrow_right,size: 40,),
                   ],
                 ),
             ),
           ),
           SizedBox(height: 70,),
            Center(child: Row(
              children: [
                Expanded(child: Divider()),
                Text("Other Payments",
                 style: TextStyle(
                   fontSize: 16,
                 ),
                ),
                Expanded(child: Divider())
              ],
            ))
         ],
       ),
     ),
    );
  }
}
