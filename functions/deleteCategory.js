const admin = require('firebase-admin');
const db = admin.firestore();

exports.deleteOrderHandler = ((req, res) => {
    var id = req.body.id;
    let categoryRef = db.collection('Categories').doc(id);
    
    db.collection('Products').where('catId', '==', id).get()
    .then(snapshot => {
      if (snapshot.empty) {
        console.log('No Products found for this category');
        return categoryRef.delete();
      }  
      let batch = db.batch();
      batch.delete(categoryRef);

      snapshot.forEach(product => {
        let productRef = db.collection('Products').doc(product.id);
        batch.delete(productRef);
      });
      return batch.commit();
    })
    .then(data => {
        res.status(200).send({success: true, messageEng: "Category removed", message: "类别已删除", data : data});
    })
    .catch(err => {
      console.log('Error getting documents', err);
      res.status(404).send({ success: false, messageEng: "Error while removing Category", message:"删除类别时出错", error : err });
    });
});
