import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Trigger: Runs when a new emergency is created in Realtime DB.
 * Path: /emergencies/{emergencyId}
 */
export const sendEmergencyNotification = functions.database.onValueCreated(
  "/emergencies/{emergencyId}",
  async (event) => {
    try {
      const emergencyData = event.data.val();
      const emergencyId = event.params.emergencyId;

      if (!emergencyData) {
        console.log("⚠️ No emergency data found.");
        return;
      }

      const userId: string = emergencyData.userId;
      const lat: number = emergencyData.lat;
      const lng: number = emergencyData.lng;

      // Fetch all users from DB
      const usersSnap = await admin.database().ref("users").once("value");
      const tokens: string[] = [];

      usersSnap.forEach((child) => {
        const token = child.val().fcmToken;
        if (token && child.key !== userId) {
          tokens.push(token);
        }
      });

      if (tokens.length === 0) {
        console.log("⚠️ No tokens found, skipping notification.");
        return;
      }

      const payload = {
        notification: {
          title: "🚨 Emergency Alert!",
          body: "Someone nearby needs help. Open RaahSetu to assist.",
        },
        data: {
          emergencyId: emergencyId,
          lat: String(lat),
          lng: String(lng),
        },
      };

      // Send notifications
      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log(`✅ Sent emergency alert to ${tokens.length} users`, response);
    } catch (error) {
      console.error("❌ Error in sendEmergencyNotification:", error);
    }
  }
);
