import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

interface ReminderData {
  status: string;
  remindAt: admin.firestore.Timestamp;
  userId: string;
  eventId?: string;
  eventTitle?: string;
  eventLocation?: string;
  registrationId?: string;
  isSent?: boolean;
  processedAt?: admin.firestore.Timestamp;
  statusMessage?: string;
}

interface UserData {
  fcmTokens?: string[];
}

interface SendResult {
  success: boolean;
  token: string;
  error?: string;
}

/**
 * Scheduled function to check and send event reminders
 * Runs every 15 minutes to check for pending reminders
 */
export const sendEventReminders = functions.pubsub
  .schedule('every 15 minutes')
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async (context) => {
    try {
      console.log('Starting event reminder check...');

      const now = admin.firestore.Timestamp.now();

      // Query for reminders that are due and not yet sent
      const remindersSnapshot = await db
        .collection('scheduledReminders')
        .where('status', '==', 'pending')
        .where('remindAt', '<=', now)
        .limit(100) // Process 100 reminders at a time
        .get();

      if (remindersSnapshot.empty) {
        console.log('No pending reminders found');
        return null;
      }

      console.log(`Found ${remindersSnapshot.size} reminders to process`);

      // Process each reminder
      const promises = remindersSnapshot.docs.map(async (doc) => {
        const reminder = doc.data() as ReminderData;
        const reminderId = doc.id;

        try {
          // Get user's FCM tokens
          const userDoc = await db.collection('users').doc(reminder.userId).get();

          if (!userDoc.exists) {
            console.log(`User ${reminder.userId} not found`);
            await updateReminderStatus(reminderId, 'failed', 'User not found');
            return;
          }

          const userData = userDoc.data() as UserData;
          const fcmTokens = userData.fcmTokens || [];

          if (fcmTokens.length === 0) {
            console.log(`No FCM tokens for user ${reminder.userId}`);
            await updateReminderStatus(reminderId, 'failed', 'No FCM tokens');
            return;
          }

          // Prepare notification message
          const message: admin.messaging.MessagingPayload = {
            notification: {
              title: reminder.eventTitle ? `Event Reminder: ${reminder.eventTitle}` : 'Event Reminder',
              body: `Your event starts tomorrow at ${reminder.eventLocation || 'the venue'}. Don't forget to attend!`,
            },
            data: {
              type: 'event_reminder',
              eventId: reminder.eventId || '',
              reminderId: reminderId,
              registrationId: reminder.registrationId || '',
              userId: reminder.userId,
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
              priority: 'high',
              notification: {
                channelId: 'event_reminders',
                sound: 'default',
                priority: 'high',
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          };

          // Send to all user's devices
          const sendPromises = fcmTokens.map(async (token: string) => {
            try {
              await messaging.send({
                ...message,
                token: token,
              } as admin.messaging.Message);
              console.log(`Sent reminder to token: ${token.substring(0, 20)}...`);
              return { success: true, token } as SendResult;
            } catch (error: any) {
              console.error(`Failed to send to token ${token.substring(0, 20)}:`, error.code);

              // Remove invalid tokens
              if (error.code === 'messaging/invalid-registration-token' ||
                  error.code === 'messaging/registration-token-not-registered') {
                await removeInvalidToken(reminder.userId, token);
              }

              return { success: false, token, error: error.code } as SendResult;
            }
          });

          const results = await Promise.all(sendPromises);
          const successCount = results.filter(r => r.success).length;

          if (successCount > 0) {
            // Update reminder status to sent
            await updateReminderStatus(reminderId, 'sent', `Sent to ${successCount} device(s)`);

            // Update the reminder document in the reminders collection
            await db.collection('reminders').doc(reminderId).update({
              isSent: true,
              sentAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            console.log(`Successfully sent reminder ${reminderId} to ${successCount} device(s)`);
          } else {
            await updateReminderStatus(reminderId, 'failed', 'Failed to send to any device');
          }

        } catch (error: any) {
          console.error(`Error processing reminder ${reminderId}:`, error);
          await updateReminderStatus(reminderId, 'failed', error.message);
        }
      });

      await Promise.all(promises);
      console.log('Event reminder check completed');
      return null;

    } catch (error: any) {
      console.error('Error in sendEventReminders:', error);
      return null;
    }
  });

/**
 * Update reminder status in scheduledReminders collection
 */
async function updateReminderStatus(reminderId: string, status: string, message: string = ''): Promise<void> {
  try {
    await db.collection('scheduledReminders').doc(reminderId).update({
      status: status,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      statusMessage: message,
    });
  } catch (error: any) {
    console.error(`Error updating reminder status for ${reminderId}:`, error);
  }
}

/**
 * Remove invalid FCM token from user document
 */
async function removeInvalidToken(userId: string, token: string): Promise<void> {
  try {
    await db.collection('users').doc(userId).update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
    });
    console.log(`Removed invalid token for user ${userId}`);
  } catch (error: any) {
    console.error(`Error removing invalid token:`, error);
  }
}

/**
 * Clean up old processed reminders (runs daily)
 * Removes reminders older than 7 days
 */
export const cleanupOldReminders = functions.pubsub
  .schedule('every 24 hours')
  .timeZone('Asia/Kuala_Lumpur')
  .onRun(async (context) => {
    try {
      console.log('Starting cleanup of old reminders...');

      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      const cutoffTimestamp = admin.firestore.Timestamp.fromDate(sevenDaysAgo);

      // Delete old reminders
      const oldRemindersSnapshot = await db
        .collection('scheduledReminders')
        .where('status', 'in', ['sent', 'failed'])
        .where('processedAt', '<=', cutoffTimestamp)
        .limit(500)
        .get();

      if (oldRemindersSnapshot.empty) {
        console.log('No old reminders to clean up');
        return null;
      }

      const batch = db.batch();
      oldRemindersSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`Cleaned up ${oldRemindersSnapshot.size} old reminders`);

      return null;
    } catch (error: any) {
      console.error('Error in cleanupOldReminders:', error);
      return null;
    }
  });

/**
 * HTTP function to manually trigger a test notification (for debugging)
 */
export const sendTestNotification = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to send test notifications'
    );
  }

  const userId = context.auth.uid;

  try {
    // Get user's FCM tokens
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data() as UserData;
    const fcmTokens = userData.fcmTokens || [];

    if (fcmTokens.length === 0) {
      throw new functions.https.HttpsError('failed-precondition', 'No FCM tokens found');
    }

    const message: admin.messaging.MessagingPayload = {
      notification: {
        title: 'Test Notification',
        body: 'This is a test event reminder notification.',
      },
      data: {
        type: 'test_notification',
        userId: userId,
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'event_reminders',
          sound: 'default',
        },
      },
    };

    // Send to first token
    await messaging.send({
      ...message,
      token: fcmTokens[0],
    } as admin.messaging.Message);

    return { success: true, message: 'Test notification sent successfully' };

  } catch (error: any) {
    console.error('Error sending test notification:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Trigger when a new reminder is created
 * Validates reminder data
 */
export const onReminderCreated = functions.firestore
  .document('reminders/{reminderId}')
  .onCreate(async (snapshot, context) => {
    const reminder = snapshot.data() as ReminderData;
    const reminderId = context.params.reminderId;

    try {
      console.log(`New reminder created: ${reminderId}`);

      // Validate reminder data
      if (!reminder.remindAt || !reminder.userId) {
        console.error('Invalid reminder data:', reminder);
        return null;
      }

      // Check if remindAt is in the future
      const now = admin.firestore.Timestamp.now();
      if (reminder.remindAt <= now) {
        console.log('Reminder time is in the past, marking as expired');
        await snapshot.ref.update({
          status: 'expired',
          isSent: false,
        });
      }

      return null;
    } catch (error: any) {
      console.error('Error in onReminderCreated:', error);
      return null;
    }
  });