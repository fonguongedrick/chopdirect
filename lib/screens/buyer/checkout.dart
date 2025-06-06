// import 'package:chopdirect/screens/buyer/cards/paymentmethod_card.dart';
// import 'package:chopdirect/screens/buyer/order_confirmation.dart';
// import 'package:chopdirect/screens/buyer/order_summary_item.dart';
// import 'package:flutter/material.dart';
// import 'package:mesomb/mesomb.dart';
// import 'dart:math';
//
// class CheckoutScreen extends StatefulWidget {
//   final double? subtotal; // Receive subtotal dynamically from the CartScreen
//
//   const CheckoutScreen({super.key, this.subtotal});
//
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late PaymentOperation payment;
//   final _phoneController = TextEditingController();
//   final double deliveryFee = 500; // Static delivery fee
//
//   @override
//   void initState() {
//     super.initState();
//     payment = PaymentOperation('795ee41f78b16c24023a17ed94a90bf577b569c4',
//         '98af2657-3378-40e1-adfb-5b1017ffb25d',
//         'bb817a20-d65a-4566-9d75-46381ff8c19f'
//     );
//   }
//
//   Future<void> processPayment() async {
//     String nonce = Random().nextInt(1000000).toString();
//     String phone = _phoneController.text.trim();
//     double totalAmount =(widget.subtotal ?? 0) + deliveryFee;
//
//     if (phone.isEmpty || totalAmount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Please enter a valid phone number'),
//       ));
//       return;
//     }
//      final response = await payment.makeCollect(
//          amount: 1,
//          service: "MTN",
//          payer: phone,
//         nonce: nonce
//      );
//
//     if (response.isTransactionSuccess()) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const OrderConfirmationScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Payment failed, please try again'),
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double totalAmount = (widget.subtotal ?? 0) + deliveryFee;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Checkout')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 8),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Home'),
//                     const Text('Mile 2, Bamenda'),
//                     const SizedBox(height: 8),
//                     OutlinedButton(
//                       onPressed: () {},
//                       child: const Text('Change Address'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 8),
//             const PaymentMethodCard(icon: Icons.phone_android, title: 'Mobile Money', subtitle: 'MTN MoMo, Orange Money', isSelected: true),
//             const PaymentMethodCard(icon: Icons.credit_card, title: 'Card Payment', subtitle: 'Visa, Mastercard', isSelected: false),
//             const SizedBox(height: 16),
//             const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 8),
//             OrderSummaryItem(label: 'Subtotal', value: 'XAF ${(widget.subtotal ?? 0).toStringAsFixed(2)}'),
//             OrderSummaryItem(label: 'Delivery', value: 'XAF ${deliveryFee.toStringAsFixed(2)}'),
//             const Divider(),
//             OrderSummaryItem(label: 'Total', value: 'XAF ${totalAmount.toStringAsFixed(2)}', isTotal: true),
//             const SizedBox(height: 24),
//             TextField(
//               controller: _phoneController,
//               decoration: InputDecoration(labelText: 'Enter Phone Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: processPayment,
//                 child: const Text('Place Order & Pay'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
