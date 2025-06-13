const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
admin.initializeApp();

// Firestore settings for optimized performance
const firestore = admin.firestore();
firestore.settings({ ignoreUndefinedProperties: true });

exports.sendOrderNotification = functions.firestore.onDocumentCreated(
  { document: "orders/{orderId}" },
  async (event) => {
    try {
      if (!event.data) {
        console.error("No data found for the order event.");
        return;
      }

      const orderData = event.data.data();

      if (!orderData || !orderData.items || !Array.isArray(orderData.items)) {
        console.error("Malformed order data.");
        return;
      }

      // Build the FCM message with Android-specific settings
      const message = {
        topic: "order_updates", // Send to subscribers of "order_updates"
        notification: {
          title: "Order Successful!",
          body: `Your order for ${orderData.items.length} items has been placed.`,
        },
        android: {
          notification: {
            sound: "default", // For Android, the sound key inside android.notification specifies the sound.
          },
        },
        data: {
          screen: "order_details",
          orderId: event.params.orderId,
          timestamp: new Date().toISOString(),
        },
      };

      // Send the notification using the new message format
      const response = await admin.messaging().send(message);
      console.log("Notification sent:", response);

      // Batch update order document to mark notification as sent
      const batch = firestore.batch();
      batch.update(event.data.ref, {
        notificationSent: true,
        notificationTime: admin.firestore.FieldValue.serverTimestamp(),
      });
      await batch.commit();

      return;
    } catch (error) {
      console.error("Error in sendOrderNotification:", error);
      if (error instanceof Error) {
        console.error("Error stack:", error.stack);
      }
      throw new functions.https.HttpsError(
        "internal",
        "Notification dispatch failed",
        error.message,
      );
    }
  }
);
