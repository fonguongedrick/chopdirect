import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();

export const sendOrderNotification = onDocumentCreated("orders/{orderId}", async (event) => {
  const snapshot = event.data;
  const context = event.params;
  const orderData = snapshot.data();
  const orderId = context.orderId;

  const farmerIds = [...new Set(orderData.items.map(item => item.farmerId))];

  const buyerSnapshot = await getFirestore()
    .collection("users_chopdirect")
    .doc(orderData.userId)
    .get();

  const buyerName = buyerSnapshot.data()?.name || "a customer";

  await Promise.all(
    farmerIds.map(async (farmerId) => {
      const farmerSnapshot = await getFirestore()
        .collection("farmers")
        .doc(farmerId)
        .get();

      const fcmToken = farmerSnapshot.data()?.fcmToken;
      if (!fcmToken) return;

      await getMessaging().send({
        notification: {
          title: "🚜 New Order!",
          body: `${buyerName} placed an order for your products`,
        },
        data: {
          type: "new_order",
          orderId,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: fcmToken,
      });
    })
  );
});
