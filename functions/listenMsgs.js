const admin = require('firebase-admin');
const db = admin.firestore();

exports.notify = ((snap, context) => {
    const msg = snap.data();
    const senderType = msg.senderType;
    if (senderType == "CUSTOMER" || senderType == "DRIVER") { return null }

    const channelId = msg.channelId;
    return db.collection('Channels').doc(channelId).get()
        .then(channelSnap => {
            const channel = channelSnap.data();
            const receiverId = channel.member.id
            const collection = channel.member.type == "CUSTOMER" ? "Customers" : "Drivers"
            return db.collection(collection).doc(receiverId).get();
        })
        .then(snap => {
            const receiver = snap.data();
            if (receiver && receiver.token) {
                console.log('sending notification to ', receiver.name);
                return sendNotification(receiver.token, msg.message, receiver.platform, msg.channelId);
            } else {
                console.log('either notification receiver not found or fcmtoken is null')
                return null;
            }
        }).catch(err => {
            return err;
        });
});

function sendNotification(token, msg, platform, channelId) {
    if (platform == "Android") {
        const payload = {
            data: {
                title: "New Message",
                body: msg,
                action: "chat",
                channelId: channelId
            }
        };
        return admin.messaging().sendToDevice(token, payload)
    } else {
        const payload = {
            notification: {
                title: "New Message",
                body: msg
            },
            data: {
                channelId: channelId,
                action: "chat"
            },
        };
        console.log("payload", payload);
        return admin.messaging().sendToDevice(token, payload)
    }
}