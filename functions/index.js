const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "EMAIL_KAMU@gmail.com",
    pass: "PASSWORD_APLIKASI",
  },
});

exports.sendOtp = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const otp = data.otp;

  const mailOptions = {
    from: "Inventaris_manggala@gmail.com",
    to: email,
    subject: "Kode OTP Verifikasi",
    text: `Kode OTP kamu adalah: ${otp}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError("unknown", "Gagal mengirim email", error);
  }
});
