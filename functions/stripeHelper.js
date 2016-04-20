
// 'sk_test_51H4n5DHyiKZJiqafPsMlfbQWMHMn5vfnJzqTHIysJAu6eARGaSKpxC2a7ylB6Urd6QcUbZrRxUy1JgaDYVLm69p900DNN9MX0P'
//'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'
function createChargeWith(token,amount,id) {
    return new Promise( function (resolve,reject) {
        const stripe = require('stripe')('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');
        console.log('creating charge');
        stripe.charges.create({
          amount: amount,
          currency: 'hkd',
          description: 'Charge for order id : '+id,
          source: token,
        }).then( charge => {
            console.log('charge is ',charge);
            resolve(charge);
        }).catch( err => {
            console.log('error while creating charge',err);
            reject(err);
        });
    })
}
module.exports.createChargeWith = createChargeWith;