const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendOrderNotification = functions.firestore
    .document("orders/{orderId}")
    .onCreate(async (snap, context) => {
      const orderData = snap.data();
      const payload = {
        notification: {
          title: "Order Successful!",
          body:
        `Your order for ${orderData.items.length} items has been ` +
        "placed.",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          screen: "order_details",
          orderId: context.params.orderId,
        },
      };

      try {
        const response = await admin.messaging()
            .sendToTopic("order_updates", payload);
        console.log("Notification sent:", response);
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    });
