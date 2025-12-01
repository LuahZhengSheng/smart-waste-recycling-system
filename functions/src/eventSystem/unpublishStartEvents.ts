// src/eventSystem/unpublishStartEvents.ts

import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

/**
 * Cloud Function to automatically unpublish past events
 * Runs every hour at the top of the hour (e.g., 1:00, 2:00, 3:00...)
 * Timezone: Asia/Kuala_Lumpur
 *
 * Logic:
 * - Find all events where:
 *   - status == "active"
 *   - isPublish == true
 *   - startDateTime < now
 * - Set isPublish = false
 */
export const unpublishStartEvents = functions.scheduler.onSchedule(
    {
      schedule: "0 * * * *", // Every hour at minute 0
      timeZone: "Asia/Kuala_Lumpur",
      memory: "256MiB",
      timeoutSeconds: 540, // 9 minutes
    },
    async (event) => {
const db = admin.firestore();
const now = admin.firestore.Timestamp.now();

console.log("Starting event expiration check at:", now.toDate());

try {
// ==================== Query Events ====================
console.log("Querying active & published events...");

const eventsSnapshot = await db
    .collection("events")
    .where("status", "==", "active")
    .where("isPublish", "==", true)
    .where("startDateTime", "<=", now)
    .get();

if (eventsSnapshot.empty) {
console.log("No events to unpublish.");
return;
}

let updatedEventsCount = 0;

// Firestore batch limit = 500
const batchSize = 500;
let currentBatch = db.batch();
let operationsInBatch = 0;

for (const doc of eventsSnapshot.docs) {
currentBatch.update(doc.ref, {
isPublish: false,
});
operationsInBatch++;
updatedEventsCount++;

const data = doc.data();
const startDateTime = data.startDateTime as admin.firestore.Timestamp;

console.log(
`Unpublishing event ${doc.id}: startDateTime=${startDateTime?.toDate()}`
);

// Commit batch if it reaches the limit
if (operationsInBatch >= batchSize) {
await currentBatch.commit();
console.log(`Committed a batch of ${operationsInBatch} event updates.`);
currentBatch = db.batch();
operationsInBatch = 0;
}
}

// Commit remaining operations
if (operationsInBatch > 0) {
await currentBatch.commit();
console.log(`Committed final batch of ${operationsInBatch} event updates.`);
}

console.log("==================== Event Expiration Summary ====================");
console.log(`Total events unpublished (isPublish=false): ${updatedEventsCount}`);
console.log("==================================================================");
} catch (error) {
console.error("❌ Error in unpublishStartEvents:", error);
throw error;
}
}
);
