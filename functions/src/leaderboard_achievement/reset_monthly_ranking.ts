import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
admin.initializeApp();
}

/**
 * Cloud Function to reset monthly reward points for all users
 * Runs automatically on the 1st day of every month at 00:00 (midnight)
 *
 * Schedule: '0 0 1 * *' means:
 * - minute: 0
 * - hour: 0
 * - day of month: 1
 * - month: * (every month)
 * - day of week: * (every day)
 */
export const resetMonthlyRewardPoints = functions.pubsub
    .schedule('0 0 1 * *')
    .timeZone('Asia/Kuala_Lumpur') // Set to Malaysia timezone
    .onRun(async (context) => {
const db = admin.firestore();

try {
console.log('Starting monthly reward points reset...');

// Get all users with role 'user' and monthlyRewardPoint > 0
const usersSnapshot = await db
    .collection('users')
    .where('role', '==', 'user')
    .where('monthlyRewardPoint', '>', 0)
    .get();

if (usersSnapshot.empty) {
console.log('No users found with monthly reward points to reset.');
return null;
}

console.log(`Found ${usersSnapshot.size} users to reset monthly points.`);

// Batch write for better performance
const batchSize = 500; // Firestore batch limit
let batch = db.batch();
let operationCount = 0;
let totalUsersProcessed = 0;

for (const doc of usersSnapshot.docs) {
const userRef = db.collection('users').doc(doc.id);

batch.update(userRef, {
monthlyRewardPoint: 0,
lastMonthlyReset: admin.firestore.FieldValue.serverTimestamp(),
});

operationCount++;
totalUsersProcessed++;

// Commit batch when reaching limit
if (operationCount === batchSize) {
await batch.commit();
console.log(`Committed batch of ${batchSize} operations.`);
batch = db.batch();
operationCount = 0;
}
}

// Commit remaining operations
if (operationCount > 0) {
await batch.commit();
console.log(`Committed final batch of ${operationCount} operations.`);
}

console.log(`Successfully reset monthly reward points for ${totalUsersProcessed} users.`);

// Log the reset event
await db.collection('system_logs').add({
event: 'monthly_points_reset',
timestamp: admin.firestore.FieldValue.serverTimestamp(),
usersAffected: totalUsersProcessed,
status: 'success',
});

return null;
} catch (error) {
console.error('Error resetting monthly reward points:', error);

// Log the error
await db.collection('system_logs').add({
event: 'monthly_points_reset',
timestamp: admin.firestore.FieldValue.serverTimestamp(),
status: 'error',
error: error instanceof Error ? error.message : String(error),
});

throw error;
}
});

/**
 * Optional: Manual trigger function for testing or manual reset
 * Can be called via HTTP request
 */
export const manualResetMonthlyPoints = functions.https.onCall(async (data, context) => {
// Check if the caller is an admin
if (!context.auth || !context.auth.token.admin) {
throw new functions.https.HttpsError(
'permission-denied',
'Only administrators can manually reset monthly points.'
);
}

const db = admin.firestore();

try {
console.log('Manual monthly reward points reset triggered by admin:', context.auth.uid);

const usersSnapshot = await db
    .collection('users')
    .where('role', '==', 'user')
    .where('monthlyRewardPoint', '>', 0)
    .get();

if (usersSnapshot.empty) {
return {
success: true,
message: 'No users found with monthly reward points to reset.',
usersAffected: 0,
};
}

const batchSize = 500;
let batch = db.batch();
let operationCount = 0;
let totalUsersProcessed = 0;

for (const doc of usersSnapshot.docs) {
const userRef = db.collection('users').doc(doc.id);

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

// Log the manual reset
await db.collection('system_logs').add({
event: 'manual_monthly_points_reset',
timestamp: admin.firestore.FieldValue.serverTimestamp(),
triggeredBy: context.auth.uid,
usersAffected: totalUsersProcessed,
status: 'success',
});

return {
success: true,
message: `Successfully reset monthly reward points for ${totalUsersProcessed} users.`,
usersAffected: totalUsersProcessed,
};
} catch (error) {
console.error('Error in manual reset:', error);

await db.collection('system_logs').add({
event: 'manual_monthly_points_reset',
timestamp: admin.firestore.FieldValue.serverTimestamp(),
triggeredBy: context.auth?.uid,
status: 'error',
error: error instanceof Error ? error.message : String(error),
});

throw new functions.https.HttpsError(
'internal',
'Failed to reset monthly points.',
error instanceof Error ? error.message : String(error)
);
}
});