const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const {getMessaging} = require("firebase-admin/messaging");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Firestore settings for optimized performance
const firestore = admin.firestore();
firestore.settings({ignoreUndefinedProperties: true});

exports.sendOrderNotification = functions.firestore.onDocumentCreated(
    {document: "orders/{orderId}"},
    async (event) => {
      try {
      // Validate data availability
        if (!event.data) {
          console.error("No data found for the order event.");
          return;
        }

        const orderData = event.data.data();

        // Ensure order structure integrity (removed optional chaining)
        if (!orderData || !orderData.items || !Array.isArray(orderData.items)) {
          console.error("Malformed order data.");
          return;
        }

        // Construct notification payload
        const payload = {
          notification: {
            title: "Order Successful!",
            body: `Your order for ${orderData.items.length} items has been` +
            "placed.",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          data: {
            screen: "order_details",
            orderId: event.params.orderId,
            timestamp: new Date().toISOString(),
          },
          android: {priority: "high"},
          apns: {headers: {"apns-priority": "10"}},
        };

        // Send notification via Firebase Cloud Messaging
        const response = await getMessaging().sendToTopic(
            "order_updates",
            payload,
        );
        console.log("Notification sent:", response);

        // Firestore batch update for efficiency
        const batch = firestore.batch();
        batch.update(event.data.ref, {
          notificationSent: true,
          notificationTime: admin.firestore.FieldValue.serverTimestamp(),
        });
        await batch.commit();

        return;
      } catch (error) {
        console.error("Error in sendOrderNotification:", error);

        // Log detailed error stack trace
        if (error instanceof Error) {
          console.error("Error stack:", error.stack);
        }

        // Structured error response
        throw new functions.https.HttpsError(
            "internal",
            "Notification dispatch failed",
            error.message,
        );
      }
    },
);
