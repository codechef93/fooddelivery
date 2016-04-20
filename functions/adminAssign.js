const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

exports.assignAdminHandler = ((snap, context) => {
        const channelId = snap.id;
        const channel = snap.data()
        const username = channel.member.name;

        let adminsRef = db.collection('Admins');
       return adminsRef.where('online', '==', true).get()
            .then(snapshot => {
                if (snapshot.empty) {
                    console.log('No matching documents.');
                    return null;
                }
                var earliest;
                var adminToAssign;
                var shouldBreak = false
                snapshot.forEach(doc => {
                    let admin = doc.data();
                    console.log('admin', admin);
                    if (shouldBreak == true){
                        return;    
                    }
                    if (!earliest) {
                        if (!admin.assignedTime){
                            adminToAssign = admin;
                            shouldBreak = true;     
                        }else{
                            earliest = admin.assignedTime.seconds;
                            adminToAssign = admin; 
                        }
                    } else {
                        if (earliest > admin.assignedTime.seconds) {
                            earliest = admin.assignedTime.seconds;
                            adminToAssign = admin;
                        }
                    }
                });

                if (adminToAssign) {
                    console.log("Assigning admin ", adminToAssign.name);
                    let channelRef = db.collection('Channels').doc(channelId);
                    let messagesRef = db.collection('Messages').doc();
                    
                    const timeStamp = admin.firestore.FieldValue.serverTimestamp()
                    const assignTimePromise = adminsRef.doc(adminToAssign.id).update({ assignedTime: timeStamp })
                    const message = {
                        "id": messagesRef.id,
                        "date": timeStamp,
                        "message": adminToAssign.name + " is assigned to you",
                        "channelId": channelId,
                        "senderId": adminToAssign.id,
                        "senderName": adminToAssign.name,
                        "msgType": "10",
                        "senderType" : "ADMIN"
                    };

                    let update = {
                        admin: {
                            "name": adminToAssign.name,
                            "id": adminToAssign.id,
                            "type": "ADMIN"
                        },
                        message : message
                    }
                    const msgAddPromise = messagesRef.set(message); 
                    const channelUpdatePromise = channelRef.update(update);

                    var promises = [assignTimePromise, channelUpdatePromise, msgAddPromise];
                    if (adminToAssign.token) {
                        console.log('sending notification to admin');
                        const notifyPromise = notifyAdmin(adminToAssign.token, channelId, username, admin.platform);
                        promises.push(notifyPromise)
                    } else {
                        console.log('admin does not have fcm token');
                    }
                    return Promise.all(promises)

                } else {
                    console.log("admin to assign not found");
                    return null;
                }
            })
            .catch(err => {
                console.log('Error getting documents', err);
                return err;
            });
    });

function notifyAdmin(token, channelId, username, platform) {
    if (platform == "Android") {
        const payload = {
            data: {
                channelId: channelId,
                title: "Message from " + username,
                body: "i need your help",
                action: "chat"
            }
        };
        return admin.messaging().sendToDevice(token, payload)
    } else {
        const payload = {
            notification: {
                title: "Message from " + username,
                body: "i need your help"
            },
            data: {
                channelId: channelId,
                action: "chat"
            }
        };
        return admin.messaging().sendToDevice(token, payload)
    }
}
