const admin = require('firebase-admin');
const db = admin.firestore();

exports.create = ((snap, context) => {
    console.log('running on create order');
    const orderId = snap.id;
    const order = snap.data();
    return handleOrder(order, orderId, false);
});

exports.update = ((change, context) => {
    console.log('running on update order');
    const orderId = change.after.id;
    const order = change.after.data();
    return handleOrder(order, orderId,true);
});

function handleOrder(order, orderId, update) {
    const username = order.customer.name;
    const customerId = order.customer.id;
    const orderStatus = order.status;
    const products = order.products.map(function (p) {
        return p.product.title;
    }).toString();
    var tokenPromises = [getTokens(true), getTokens(false,update,customerId)]
    return Promise.all(tokenPromises).then((tokensArr) => {
        var allTokens = [].concat.apply([], tokensArr);
        console.log("logging all tokens", allTokens);
        var notifyPromises = []
        allTokens.forEach(user => {
            const promise = notify(user.token, orderId, username, products, orderStatus, user.platform);
            notifyPromises.push(promise);
        })
        return Promise.all(notifyPromises);
    });
}

function getTokens(admin, sendToCustomers,id) {
    var collection = admin == true ? "Admins" : "Drivers";
    if (sendToCustomers == true){
        collection = "Customers";
    } 
    return new Promise(function (resolve, reject) {
        var adminsRef = db.collection(collection);
        if (sendToCustomers == true){
            adminsRef = db.collection(collection).where('id', '==', id)
        } 
        adminsRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    console.log('No matching documents.');
                    reject('No matching documents.')
                    return;
                }
                var tokens = [];
                snapshot.forEach(doc => {
                    let user = doc.data();
                    if (user.token) {
                        tokens.push({ "token": user.token, "platform": user.platform });
                    }
                });
                resolve(tokens)
            })
            .catch(err => {
                console.log('Error getting documents', err);
                reject(err)
            });
    });
}

function notify(token, orderId, username, products, orderStatus, platform) {

    var title = "New Order from " + username;
    if (orderStatus == 1) {
        title = "Order is now INProgress";
    } else if (orderStatus == 2) {
        title = "Order is now Completed";
    }

    if (platform == "Android") {
        const payload = {
            data: {
                title: title,
                body: products,
                orderId: orderId,
                action: "order"
            }
        };
        console.log("payload", payload);
        return admin.messaging().sendToDevice(token, payload)
    } else {
        const payload = {
            notification: {
                title: title,
                body: products
            },
            data: {
                orderId: orderId,
                action: "order"
            }
        };
        console.log("payload", payload);
        return admin.messaging().sendToDevice(token, payload)
    }
}