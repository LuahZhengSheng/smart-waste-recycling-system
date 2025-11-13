import { scheduler, https } from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

// 延迟初始化函数
function getDb() {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  return admin.firestore();
}

/**
 * Cloud Function to reset monthly reward points for all users
 */
export const resetMonthlyRanking = scheduler
  .onSchedule({
    schedule: "0 0 1 * *",
    timeZone: "Asia/Kuala_Lumpur",
  }, async () => {
    const db = getDb();

    try {
      console.log("Starting monthly reward points reset...");

      // Get all users with role 'user' and monthlyRewardPoint > 0
      const usersSnapshot = await db
        .collection("users")
        .where("role", "==", "user")
        .where("monthlyRewardPoint", ">", 0)
        .get();

      if (usersSnapshot.empty) {
        console.log("No users found with monthly reward points to reset.");
        return;
      }

      console.log(`Found ${usersSnapshot.size} users to reset monthly points.`);

      // Batch write for better performance
      const batchSize = 500;
      let batch = db.batch();
      let operationCount = 0;
      let totalUsersProcessed = 0;

      for (const doc of usersSnapshot.docs) {
        const userRef = db.collection("users").doc(doc.id);

        batch.update(userRef, {
          monthlyRewardPoint: 0,
          lastMonthlyReset: admin.firestore.FieldValue.serverTimestamp(),
        });

        operationCount++;
        totalUsersProcessed++;

        if (operationCount === batchSize) {
          await batch.commit();
          console.log(`Committed batch of ${batchSize} operations.`);
          batch = db.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
        console.log(`Committed final batch of ${operationCount} operations.`);
      }

      console.log(`Successfully reset monthly reward points for ${totalUsersProcessed} users.`);

      await db.collection("system_logs").add({
        event: "monthly_points_reset",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        usersAffected: totalUsersProcessed,
        status: "success",
      });
    } catch (error) {
      console.error("Error resetting monthly reward points:", error);

      await db.collection("system_logs").add({
        event: "monthly_points_reset",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: "error",
        error: error instanceof Error ? error.message : String(error),
      });

      throw error;
    }
  });

/**
 * Manual trigger function for testing or manual reset
 */
export const manualResetMonthlyPoints = https.onCall(
  async (request) => {
    // 直接使用 request，不声明未使用的 data 变量
    const context = request;

    const db = admin.firestore();

    if (!context.auth) {
      throw new https.HttpsError(
        "unauthenticated",
        "User must be authenticated to perform this action."
      );
    }

    // 管理员验证逻辑
    const userDoc = await db.collection("users").doc(context.auth.uid).get();
    const userData = userDoc.data();
    const isAdmin = userData?.role === "admin" || userData?.isAdmin === true;

    if (!isAdmin) {
      throw new https.HttpsError(
        "permission-denied",
        "Only administrators can manually reset monthly points."
      );
    }

    try {
      console.log("Manual monthly reward points reset triggered by admin:", context.auth.uid);

      const usersSnapshot = await db
        .collection("users")
        .where("role", "==", "user")
        .where("monthlyRewardPoint", ">", 0)
        .get();

      if (usersSnapshot.empty) {
        return {
          success: true,
          message: "No users found with monthly reward points to reset.",
          usersAffected: 0,
        };
      }

      const batchSize = 500;
      let batch = db.batch();
      let operationCount = 0;
      let totalUsersProcessed = 0;

      for (const doc of usersSnapshot.docs) {
        const userRef = db.collection("users").doc(doc.id);

        batch.update(userRef, {
          monthlyRewardPoint: 0,
          lastMonthlyReset: admin.firestore.FieldValue.serverTimestamp(),
        });

        operationCount++;
        totalUsersProcessed++;

        if (operationCount === batchSize) {
          await batch.commit();
          batch = db.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      await db.collection("system_logs").add({
        event: "manual_monthly_points_reset",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        triggeredBy: context.auth.uid,
        usersAffected: totalUsersProcessed,
        status: "success",
      });

      return {
        success: true,
        message: `Successfully reset monthly reward points for ${totalUsersProcessed} users.`,
        usersAffected: totalUsersProcessed,
      };
    } catch (error) {
      console.error("Error in manual reset:", error);

      await db.collection("system_logs").add({
        event: "manual_monthly_points_reset",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        triggeredBy: context.auth.uid,
        status: "error",
        error: error instanceof Error ? error.message : String(error),
      });

      throw new https.HttpsError(
        "internal",
        "Failed to reset monthly points.",
        error instanceof Error ? error.message : String(error)
      );
    }
  });
