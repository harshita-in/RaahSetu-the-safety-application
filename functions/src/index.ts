import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendEmergencyNotification = functions.database
  .ref("/emergencies/{emergencyId}")
  .onCreate(async (snapshot, context) => {
    const emergencyData = snapshot.val();
    const userId = emergencyData.userId;
    const lat = emergencyData.lat;
    const lng = emergencyData.lng;

    // Get all users with tokens
    const usersSnap = await admin.database().ref("users").once("value");
    const tokens: string[] = [];

    usersSnap.forEach((child) => {
      const token = child.val().fcmToken;
      if (token && child.key !== userId) {
        tokens.push(token);
      }
    });

    if (tokens.length === 0) {
      console.log("No tokens found, skipping notification.");
      return null;
    }

    const payload = {
      notification: {
        title: "🚨 Emergency Alert!",
        body: "Someone nearby needs help. Open RaahSetu to assist.",
      },
      data: {
        emergencyId: context.params.emergencyId,
        lat: String(lat),
        lng: String(lng),
      },
    };

    await admin.messaging().sendToDevice(tokens, payload);
    console.log(`✅ Emergency notification sent to ${tokens.length} users`);
    return null;
  });
