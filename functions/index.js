const functions = require("firebase-functions");
const midtransClient = require("midtrans-client");

// Initialize Midtrans Snap API
const snap = new midtransClient.Snap({
  isProduction: false, // Set true for production
  serverKey: "SB-Mid-server-igKVco7vKi-jEDckU28dIbmP", // Replace with your Server Key
  clientKey: "SB-Mid-client-ajRWEHYAlEwvWpHl", // Replace with your Client Key
});

exports.createTransaction = functions.https.onCall(async (data, context) => {
  try {
    const transactionParams = {
      transaction_details: {
        order_id: data.orderId,
        gross_amount: data.amount, // Total harga
      },
      credit_card: {
        secure: true,
      },
      customer_details: {
        first_name: data.firstName,
        last_name: data.lastName,
        email: data.email,
        phone: data.phone,
      },
    };

    const transaction = await snap.createTransaction(transactionParams);
    return { redirect_url: transaction.redirect_url }; // Kirim URL pembayaran
  } catch (error) {
    throw new functions.https.HttpsError("unknown", error.message);
  }
});
