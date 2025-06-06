// Impor kelas Storage dari paket '@google-cloud/storage'
import { Storage } from "@google-cloud/storage";

// Impor paket 'dotenv' untuk memuat variabel lingkungan dari file .env
import dotenv from "dotenv";
dotenv.config();

// Mendapatkan variabel lingkungan 'PROJECT_ID' dan 'KEYFILENAME' dari file .env
const projectId = process.env.PROJECT_ID;
const keyFilename = process.env.KEY_FILE_NAME;

// Membuat objek Storage baru dengan project ID dan file kunci yang ditentukan
const storage = new Storage({ projectId, keyFilename });

// Mendefinisikan fungsi asinkron untuk mengunggah file ke Google Cloud Storage
async function uploadFile(bucketName, file, fileOutputName) {
  try {
    // Mendapatkan referensi ke bucket yang ditentukan
    const bucket = storage.bucket(bucketName);

    // Mengunggah file yang ditentukan ke bucket dengan nama tujuan yang diberikan
    const uploadResult = await bucket.upload(file, {
      destination: fileOutputName,
    });

    // Mengembalikan hasil operasi unggahan
    return uploadResult;
  } catch (error) {
    // Menangani error yang terjadi selama proses unggahan
    console.error("Error:", error);
  }
}

// Menggunakan Immediately-Invoked Function Expression (IIFE) untuk memanggil fungsi uploadFile
(async () => {
  // Memanggil fungsi uploadFile dengan parameter yang ditentukan
  const uploadResult = await uploadFile(
    process.env.BUCKET_NAME,
    "laporin_db.sql"
  );

  // Mencatat hasil operasi unggahan ke konsol
  console.log(uploadResult);
})();
