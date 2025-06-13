const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendOrderNotificationForFarmers = functions.firestore
    .onDocumentCreated("orders/{orderId}", (event) => {
      const orderData = event.data.data();
      const orderId = event.params.orderId;

      const buyerText = `Buyer: ${orderData.buyerName}`;
      const phoneText = `Phone: ${orderData.buyerPhone}`;
      const locationText = `Location: ${orderData.buyerLocation}`;
      const orderIdText = `Order ID: ${orderId}`;
      const amountText = `Amount Paid: $${orderData.amountPaid}`;

      const messageBody = buyerText + " | " +
                        phoneText + " | " +
                        locationText + " | " +
                        orderIdText + " | " +
                        amountText;

      const payload = {
        notification: {
          title: "New Order Received!",
          body: messageBody,
          sound: "default",
        },
        data: {
          buyerName: orderData.buyerName,
          buyerPhone: orderData.buyerPhone,
          buyerLocation: orderData.buyerLocation,
          orderId: orderId,
          amountPaid: orderData.amountPaid.toString(),
        },
      };

      return admin.messaging().sendToTopic("farmers", payload)
          .then(() => {
            console.log("Order notification sent successfully");
          })
          .catch((error) => {
            console.error("Error sending order notification:", error);
          });
    });
