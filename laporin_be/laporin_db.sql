-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 23, 2025 at 04:16 PM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 7.4.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `laporin_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `refresh_token` text DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `username`, `password`, `name`, `email`, `refresh_token`, `createdAt`, `updatedAt`) VALUES
(1, 'admin1', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Administrator Utama', 'admin1@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(2, 'raharja', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Raharja Wijaya', 'raharja@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(3, 'setyawan', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Setyawan Prasetya', 'setyawan@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(4, 'anindita', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Anindita Kusuma', 'anindita@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(5, 'pratiwi', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Pratiwi Sari', 'pratiwi@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(6, 'budi_santoso', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Budi Santoso', 'budi@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(7, 'dewi_kartika', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Dewi Kartika', 'dewi@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(8, 'eko_nugroho', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Eko Nugroho', 'eko@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(9, 'maharani', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Maharani Wijaya', 'maharani@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25'),
(10, 'surya_adi', '$2a$10$XFxG8nKb0VN1T.NZIB37.etSgNJUUQ2DMTy5SU.e3YLedJUDO8xcy', 'Surya Adi Wicaksono', 'surya@laporin.diy.go.id', NULL, '2025-05-23 21:07:25', '2025-05-23 21:07:25');

-- --------------------------------------------------------

--
-- Table structure for table `government_agencies`
--

CREATE TABLE `government_agencies` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `division` varchar(255) DEFAULT NULL,
  `contact` varchar(255) DEFAULT NULL,
  `service_area` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `government_agencies`
--

INSERT INTO `government_agencies` (`id`, `name`, `division`, `contact`, `service_area`, `is_active`, `createdAt`, `updatedAt`) VALUES
(1, 'Dinas Pekerjaan Umum DIY', 'Infrastruktur Jalan', '(0274) 563228', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(2, 'Dinas Lingkungan Hidup DIY', 'Pengelolaan Sampah', '(0274) 587865', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(3, 'BPBD DIY', 'Penanggulangan Bencana', '(0274) 555836', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(4, 'Dinas Perhubungan DIY', 'Lalu Lintas', '(0274) 589074', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(5, 'Dinas Sosial DIY', 'Kesejahteraan Sosial', '(0274) 512939', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(6, 'PDAM Tirta Marta Yogyakarta', 'Distribusi Air', '(0274) 512574', 'Kota Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(7, 'Dinas Kesehatan DIY', 'Pelayanan Kesehatan', '(0274) 563469', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(8, 'PLN UP3 Yogyakarta', 'Distribusi Listrik', '(0274) 553221', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(9, 'Satpol PP DIY', 'Ketertiban Umum', '(0274) 555241', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(10, 'Dinas Pendidikan DIY', 'Fasilitas Pendidikan', '(0274) 512956', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(11, 'Dinas Pariwisata DIY', 'Pengembangan Wisata', '(0274) 587486', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(12, 'BAPPEDA DIY', 'Perencanaan Wilayah', '(0274) 562811', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(13, 'Dinas Pertanian DIY', 'Ketahanan Pangan', '(0274) 563065', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(14, 'BPN Kanwil DIY', 'Pertanahan', '(0274) 589219', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56'),
(15, 'Dinas Kebudayaan DIY', 'Pelestarian Budaya', '(0274) 561914', 'Daerah Istimewa Yogyakarta', 1, '2025-05-23 21:07:56', '2025-05-23 21:07:56');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `category_id` int(11) NOT NULL,
  `reporter_name` varchar(255) NOT NULL,
  `reporter_contact` varchar(255) NOT NULL,
  `status` enum('pending','verified','in_progress','resolved','rejected') NOT NULL DEFAULT 'pending',
  `location` varchar(255) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `lampiran_url` varchar(255) DEFAULT NULL,
  `agency_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`id`, `title`, `description`, `category_id`, `reporter_name`, `reporter_contact`, `status`, `location`, `image_url`, `lampiran_url`, `agency_id`, `admin_id`, `createdAt`, `updatedAt`) VALUES
(1, 'Jalan Berlubang di Akses Utama', 'Jalan rusak di depan balai desa sangat membahayakan pengendara motor.', 1, 'Ahmad Fauzi', '081234567890', 'pending', 'Jl. Raya Ngaliyan', 'uploads/jalan1.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(2, 'Penumpukan Sampah di Sungai', 'Sampah rumah tangga menggunung di aliran sungai kecil.', 2, 'Rina Andayani', '082198765432', 'verified', 'Sungai Dusun Bono', 'uploads/sampah1.jpg', 'uploads/laporan_sampah1.pdf', 3, 1, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(3, 'Lampu Jalan Mati Total', 'Sudah lebih dari seminggu lampu jalan padam total di 3 titik.', 3, 'Bayu Hartono', '081223344556', 'in_progress', 'Jl. Dukuh Ngaliyan', 'uploads/lampu.jpg', NULL, 2, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(4, 'Pohon Tumbang di Jalan', 'Pohon besar tumbang menutup akses jalan kampung.', 4, 'Dewi Lestari', '082334455667', 'resolved', 'Depan SD Negeri Ngaliyan', 'uploads/pohon.jpg', NULL, 1, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(5, 'Jembatan Retak', 'Retakan panjang terlihat di sisi timur jembatan gantung.', 5, 'Imam Subekti', '083344556677', 'pending', 'Jembatan Bono Barat', 'uploads/jembatan.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(6, 'Kebocoran Pipa Air Bersih', 'Pipa PDAM bocor dan air mengalir ke jalan.', 6, 'Sri Wahyuni', '082167890123', 'verified', 'Jl. PDAM Sumber', 'uploads/pipa.jpg', 'uploads/bukti_kebocoran.pdf', 4, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(7, 'Kabel Listrik Menjuntai', 'Kabel PLN sangat rendah, membahayakan anak-anak.', 7, 'Yusuf Maulana', '082345678901', 'rejected', 'Gang Belakang Masjid', 'uploads/kabel.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(8, 'Graffiti di Tembok Kantor Desa', 'Dinding luar kantor desa dicoret vandalisme.', 8, 'Laila Kurnia', '081298765432', 'resolved', 'Kantor Desa Ngaliyan', 'uploads/vandalisme.jpg', NULL, 3, 1, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(9, 'Kebocoran Saluran Irigasi', 'Air merembes dari saluran sekunder irigasi sawah.', 9, 'Rahmat Hidayat', '081234567891', 'pending', 'Sawah Blok B', 'uploads/irigasi.jpg', NULL, 4, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(10, 'Penyakit Ternak', 'Beberapa ternak warga mendadak sakit dan mati.', 10, 'Dina Oktaviani', '085612345678', 'verified', 'Kandang Dusun Timur', 'uploads/ternak.jpg', 'uploads/bukti_penyakit.pdf', 5, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(11, 'Bangunan Liar di Lahan Umum', 'Terjadi pembangunan ilegal di atas lahan desa.', 11, 'Andi Pratama', '085811122233', 'in_progress', 'Dekat Lapangan Bola', 'uploads/bangunan.jpg', NULL, NULL, 3, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(12, 'Genangan Air di Jalan', 'Drainase buruk menyebabkan genangan air saat hujan.', 12, 'Nina Ramadhani', '087788899900', 'pending', 'Jl. Puskesmas', 'uploads/genangan.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(13, 'WC Umum Rusak', 'Kunci rusak dan air tidak mengalir di toilet umum pasar.', 13, 'Tomy Ardian', '081234560987', 'resolved', 'Pasar Desa Ngaliyan', 'uploads/wc.jpg', NULL, 3, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(14, 'Plafon Balai RT Runtuh', 'Atap plafon rapat warga runtuh dan menimpa kursi.', 14, 'Fitri Ayu', '085766554433', 'verified', 'Balai RT 04', 'uploads/plafon.jpg', NULL, 2, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(15, 'Penerangan Jalan Redup', 'Lampu jalan masih menyala, tapi sangat redup.', 15, 'Wawan Gunawan', '082112223334', 'in_progress', 'Jl. Pondok Pesantren', 'uploads/redup.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(16, 'Penipuan Berkedok Sumbangan', 'Warga didatangi oleh oknum yang meminta sumbangan palsu.', 16, 'Siti Maesaroh', '081223300112', 'verified', 'RT 03 RW 01', 'uploads/penipuan.jpg', 'uploads/fotocopy_ktp.jpg', 5, 4, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(17, 'Banjir Ringan Pasca Hujan', 'Beberapa rumah kemasukan air setinggi mata kaki.', 17, 'Hendra Kurniawan', '085622334455', 'resolved', 'Dusun Selatan', 'uploads/banjir.jpg', NULL, 2, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(18, 'Tumpahan Limbah Industri', 'Air sungai menghitam dan berbau setelah hujan deras.', 18, 'Yuliana', '082333444555', 'rejected', 'Sungai Cokro', 'uploads/limbah.jpg', 'uploads/laporan_lab.pdf', 4, 1, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(19, 'Sengketa Lahan Warga', 'Dua keluarga berseteru soal batas tanah warisan.', 19, 'Bambang Subroto', '081900112233', 'pending', 'Dusun Tengah', 'uploads/lahan.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(20, 'Jalan Akses Tertutup Tanah Longsor', 'Tanah longsor menutup total jalan penghubung antar dusun.', 1, 'Rofiq Nurhidayat', '081278945612', 'in_progress', 'Jl. Dusun Barat', 'uploads/longsor.jpg', NULL, 1, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(21, 'Tumpukan Sampah Pasar', 'Sampah menumpuk di belakang pasar tanpa penanganan.', 2, 'Mega Wulandari', '082167894320', 'pending', 'Pasar Pagi', 'uploads/sampah_pasar.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(22, 'Tiang Listrik Miring', 'Tiang listrik condong ke rumah warga setelah hujan angin.', 3, 'Arif Sutrisno', '083456788901', 'verified', 'Depan TPA', 'uploads/tiang_miring.jpg', NULL, 2, 1, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(23, 'Tebing Retak Dekat Sekolah', 'Tebing dekat SDN 3 mengalami retakan, khawatir longsor.', 4, 'Suci Lestari', '085612347890', 'pending', 'Belakang SDN 3', 'uploads/tebing.jpg', 'uploads/retakan_tebing.pdf', NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(24, 'Kolong Jembatan Kotor', 'Warga membuang limbah rumah tangga ke kolong jembatan.', 5, 'Yayan Hidayat', '082134556677', 'rejected', 'Jembatan Kaliwedi', 'uploads/kolong.jpg', NULL, 3, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(25, 'Kebocoran Tangki Air Penampungan', 'Tangki penampungan air bocor sejak kemarin malam.', 6, 'Erna Puspitasari', '081244556677', 'resolved', 'Belakang Kantor Lurah', 'uploads/tangki.jpg', 'uploads/nota_perbaikan.pdf', 4, 3, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(26, 'Pipa Gas Bocor', 'Bau gas menyengat di sekitar dapur umum warga.', 7, 'Fajar Andika', '081900234567', 'in_progress', 'Dapur Umum RT 07', 'uploads/gas.jpg', NULL, 2, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(27, 'Plang Nama Rusak', 'Plang nama desa roboh karena angin.', 8, 'Tari Nirmala', '087812345678', 'pending', 'Gerbang Utama', 'uploads/plang.jpg', NULL, NULL, NULL, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(28, 'Embung Tidak Terawat', 'Tanaman liar tumbuh di dasar embung, mengganggu aliran air.', 9, 'Samsul Arifin', '085711223344', 'verified', 'Embung Blok Selatan', 'uploads/embung.jpg', NULL, 4, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(29, 'Ayunan di Taman Rusak', 'Tali ayunan di taman bermain putus dan membahayakan anak.', 10, 'Alifah Nurani', '083344556678', 'resolved', 'Taman Ceria', 'uploads/ayunan.jpg', 'uploads/surat_kerusakan.pdf', 3, 1, '2025-05-23 21:16:10', '2025-05-23 21:16:10'),
(30, 'Bayi Gizi Buruk', 'Ditemukan bayi dengan berat badan jauh di bawah normal.', 20, 'Rizka Nuraini', '082300456789', 'verified', 'Posyandu Melati', 'uploads/bayi.jpg', 'uploads/kartu_gizi.jpg', 5, 2, '2025-05-23 21:16:10', '2025-05-23 21:16:10');

-- --------------------------------------------------------

--
-- Table structure for table `report_categories`
--

CREATE TABLE `report_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `report_categories`
--

INSERT INTO `report_categories` (`id`, `name`, `createdAt`, `updatedAt`) VALUES
(1, 'Jalan Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(2, 'Jembatan Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(3, 'Lampu Jalan Mati', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(4, 'Saluran Air Tersumbat', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(5, 'Banjir', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(6, 'Drainase Buruk', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(7, 'Trotoar Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(8, 'Jalan Berlubang', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(9, 'Sampah Menumpuk', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(10, 'Longsor', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(11, 'Pemasangan Kabel Tidak Aman', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(12, 'Fasilitas Publik Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(13, 'Rambu Lalu Lintas Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(14, 'Median Jalan Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(15, 'Gorong-gorong Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(16, 'Tiang Listrik Miring/Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(17, 'Jalan Ambles', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(18, 'Genangan Air', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(19, 'Zebra Cross Pudar', '2025-05-21 11:11:44', '2025-05-21 11:11:44'),
(20, 'Polisi Tidur Rusak', '2025-05-21 11:11:44', '2025-05-21 11:11:44');

-- --------------------------------------------------------

--
-- Table structure for table `report_histories`
--

CREATE TABLE `report_histories` (
  `id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `status` enum('pending','verified','in_progress','resolved','rejected') NOT NULL,
  `note` text DEFAULT NULL,
  `agency_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `government_agencies`
--
ALTER TABLE `government_agencies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `agency_id` (`agency_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `report_categories`
--
ALTER TABLE `report_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `report_histories`
--
ALTER TABLE `report_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `report_id` (`report_id`),
  ADD KEY `agency_id` (`agency_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `government_agencies`
--
ALTER TABLE `government_agencies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `report_categories`
--
ALTER TABLE `report_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `report_histories`
--
ALTER TABLE `report_histories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `report_categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`agency_id`) REFERENCES `government_agencies` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `reports_ibfk_3` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `report_histories`
--
ALTER TABLE `report_histories`
  ADD CONSTRAINT `report_histories_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `report_histories_ibfk_2` FOREIGN KEY (`agency_id`) REFERENCES `government_agencies` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `report_histories_ibfk_3` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
