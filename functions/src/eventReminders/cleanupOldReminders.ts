// src/eventReminders/cleanupOldReminders.ts
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions/v2';

export const cleanupOldReminders = functions.scheduler.onSchedule('every 24 hours', async (event) => {
  try {
    const db = admin.firestore();
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 7);

    console.log('Cleaning up old reminders...');

    const oldReminders = await db.collection('reminders')
      .where('isSent', '==', true)
      .where('remindAt', '<=', cutoffDate)
      .get();

    const batch = db.batch();
    oldReminders.docs.forEach((doc: admin.firestore.QueryDocumentSnapshot) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Cleaned up ${oldReminders.size} old reminders`);

  } catch (error: any) {
    console.error('Error in cleanupOldReminders:', error);
  }
});