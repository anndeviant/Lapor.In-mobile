import express from "express";

const router = express.Router();

// API Documentation Route
router.get("/", (req, res) => {
  const htmlContent = `
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Laporin API Documentation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .endpoint-card {
            border-left: 4px solid #007bff;
            margin-bottom: 1rem;
        }
        .method-get { border-left-color: #28a745; }
        .method-post { border-left-color: #007bff; }
        .method-put { border-left-color: #ffc107; }
        .method-patch { border-left-color: #fd7e14; }
        .method-delete { border-left-color: #dc3545; }
        .method-badge {
            font-size: 0.75rem;
            font-weight: bold;
            min-width: 60px;
            text-align: center;
        }
        .code-block {
            background-color: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 0.375rem;
            padding: 1rem;
            font-family: 'Courier New', monospace;
            font-size: 0.875rem;
        }
        .sidebar {
            position: sticky;
            top: 20px;
            height: calc(100vh - 40px);
            overflow-y: auto;
        }
        .nav-link {
            color: #6c757d;
            padding: 0.25rem 0.5rem;
        }
        .nav-link:hover {
            color: #007bff;
            background-color: #f8f9fa;
        }
        .section-title {
            color: #007bff;
            border-bottom: 2px solid #007bff;
            padding-bottom: 0.5rem;
            margin-bottom: 1.5rem;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 bg-light sidebar">
                <div class="p-3">
                    <h5 class="text-primary">
                        <i class="fas fa-book"></i> API Documentation
                    </h5>
                    <nav class="nav flex-column">
                        <a class="nav-link" href="#overview">Overview</a>
                        <a class="nav-link" href="#authentication">Authentication</a>
                        <a class="nav-link" href="#public-endpoints">Public Endpoints</a>
                        <a class="nav-link ms-3" href="#public-reports">Reports</a>
                        <a class="nav-link ms-3" href="#public-categories">Categories</a>
                        <a class="nav-link ms-3" href="#public-agencies">Agencies</a>
                        <a class="nav-link" href="#user-endpoints">User Endpoints</a>
                        <a class="nav-link ms-3" href="#user-auth">Authentication</a>
                        <a class="nav-link" href="#admin-endpoints">Admin Endpoints</a>
                        <a class="nav-link ms-3" href="#admin-auth">Authentication</a>
                        <a class="nav-link ms-3" href="#admin-profile">Profile Management</a>
                        <a class="nav-link ms-3" href="#admin-reports">Report Management</a>
                        <a class="nav-link ms-3" href="#admin-categories">Category Management</a>
                        <a class="nav-link ms-3" href="#admin-agencies">Agency Management</a>
                        <a class="nav-link ms-3" href="#admin-users">Admin Management</a>
                        <a class="nav-link" href="#models">Data Models</a>
                        <a class="nav-link" href="#status-codes">Status Codes</a>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-9">
                <div class="p-4">
                    <!-- Header -->
                    <div class="text-center mb-5">
                        <h1 class="display-4 text-primary fw-bold">
                            <i class="fas fa-exclamation-triangle"></i> Laporin API
                        </h1>
                        <p class="lead fw-bold">REST API untuk Aplikasi Pelaporan Kerusakan Infrastruktur</p>
                        <p class="text-muted">
                        Base URL:
                        <a href="https://laporin-be-298647753913.us-central1.run.app" target="_blank" rel="noopener noreferrer" class="bg-secondary-subtle text-dark px-1 rounded small text-decoration-none">
                            https://laporin-be-298647753913.us-central1.run.app
                        </a>
                        </p>
                    </div>

                    <!-- Overview -->
                    <section id="overview" class="mb-5">
                        <h2 class="section-title">
                            <i class="fas fa-info-circle"></i> Overview
                        </h2>
                        <p>Laporin API menyediakan endpoints untuk mengelola laporan kerusakan infrastruktur. API ini mendukung operasi untuk masyarakat umum (pelapor) dan admin (pengelola).</p>
                        
                        <h4>Fitur Utama:</h4>
                        <ul>
                            <li>Pelaporan kerusakan infrastruktur oleh masyarakat</li>
                            <li>Verifikasi dan pengelolaan laporan oleh admin</li>
                            <li>Pelacakan status laporan</li>
                            <li>Manajemen kategori dan instansi</li>
                        </ul>
                    </section>

                    <!-- Authentication -->
                    <section id="authentication" class="mb-5">
                        <h2 class="section-title">
                            <i class="fas fa-lock"></i> Authentication
                        </h2>
                        <p>API menggunakan JWT (JSON Web Token) untuk autentikasi admin. Token harus disertakan dalam header Authorization.</p>
                        
                        <div class="code-block">
Authorization: Bearer &lt;access_token&gt;
                        </div>
                        
                        <div class="alert alert-info mt-3">
                            <strong>Info:</strong> Endpoint public tidak memerlukan autentikasi, sedangkan endpoint admin memerlukan token yang valid.
                        </div>
                    </section>

                    <!-- Public Endpoints -->
                    <section id="public-endpoints" class="mb-5">
                        <h2 class="section-title">
                            <i class="fas fa-globe"></i> Public Endpoints
                        </h2>
                        
                        <!-- Public Reports -->
                        <div id="public-reports">
                            <h4 class="text-secondary mb-3">Reports</h4>
                            
                            <!-- Get Reports -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/public/reports</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan daftar laporan dengan filter dasar</p>
                                    <div class="code-block">
Response: [
  {
    "id": 1,
    "title": "Jalan Rusak di Jl. Sudirman",
    "description": "...",
    "status": "pending",
    "location": "Jl. Sudirman No. 123",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "ReportCategory": { "name": "Jalan" },
    "GovernmentAgency": { "name": "Dinas PU" }
  }
]
                                    </div>
                                </div>
                            </div>

                            <!-- Create Report -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/public/reports</code>
                                    </div>
                                    <p class="mb-2">Membuat laporan baru (dengan upload file)</p>
                                    <strong>Body (multipart/form-data):</strong>
                                    <div class="code-block">
{
  "title": "string (required)",
  "description": "string (required)",
  "category_id": "integer (required)",
  "reporter_name": "string (required)",
  "reporter_contact": "string (required)",
  "location": "string (required)",
  "agency_id": "integer (optional)",
  "image": "file (required)",
  "lampiran": "file (optional)"
}
                                    </div>
                                </div>
                            </div>

                            <!-- Track Report -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/public/reports/track/:trackingId</code>
                                    </div>
                                    <p class="mb-2">Melacak status laporan dengan ID pelacakan</p>
                                </div>
                            </div>
                        </div>

                        <!-- Public Categories -->
                        <div id="public-categories" class="mt-4">
                            <h4 class="text-secondary mb-3">Categories</h4>
                            
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/public/categories</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan semua kategori laporan</p>
                                </div>
                            </div>
                        </div>

                        <!-- Public Agencies -->
                        <div id="public-agencies" class="mt-4">
                            <h4 class="text-secondary mb-3">Agencies</h4>
                            
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/public/agencies</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan daftar instansi pemerintah</p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- User Endpoints -->
                    <section id="user-endpoints" class="mb-5">
                        <h2 class="section-title">
                            <i class="fas fa-mobile-alt"></i> User Endpoints (Mobile App)
                        </h2>
                        <div class="alert alert-info">
                            <strong>Info:</strong> Endpoints ini khusus untuk aplikasi mobile dengan autentikasi berbasis device info.
                        </div>

                        <!-- User Authentication -->
                        <div id="user-auth">
                            <h4 class="text-secondary mb-3">Authentication</h4>
                            
                            <!-- Register User -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/users/register</code>
                                    </div>
                                    <p class="mb-2">Mendaftarkan user baru</p>
                                    <div class="code-block">
{
  "fullname": "string (required)",
  "phone_number": "string (required)",
  "password": "string (required)"
}
                                    </div>
                                </div>
                            </div>

                            <!-- Login User -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/users/login</code>
                                    </div>
                                    <p class="mb-2">Login user dengan device info</p>
                                    <div class="code-block">
{
  "phone_number": "string (required)",
  "password": "string (required)",
  "device_info": "string (required)"
}
                                    </div>
                                </div>
                            </div>

                            <!-- Check Session -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/users/check-session</code>
                                    </div>
                                    <p class="mb-2">Mengecek apakah user masih login</p>
                                    <div class="code-block">
{
  "phone_number": "string (required)"
}
                                    </div>
                                </div>
                            </div>

                            <!-- Logout User -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/users/logout</code>
                                    </div>
                                    <p class="mb-2">Logout user (clear device info)</p>
                                    <div class="code-block">
{
  "phone_number": "string (required)"
}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Admin Endpoints -->
                    <section id="admin-endpoints" class="mb-5">
                        <h2 class="section-title">
                            <i class="fas fa-user-shield"></i> Admin Endpoints
                        </h2>
                        <div class="alert alert-warning">
                            <strong>Perhatian:</strong> Semua endpoint admin memerlukan token autentikasi yang valid.
                        </div>

                        <!-- Admin Authentication -->
                        <div id="admin-auth">
                            <h4 class="text-secondary mb-3">Authentication</h4>
                            
                            <!-- Register -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/admin/register</code>
                                    </div>
                                    <p class="mb-2">Mendaftarkan admin baru</p>
                                    <div class="code-block">
{
  "username": "string",
  "password": "string",
  "name": "string",
  "email": "string"
}
                                    </div>
                                </div>
                            </div>

                            <!-- Login -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/admin/login</code>
                                    </div>
                                    <p class="mb-2">Login admin</p>
                                    <div class="code-block">
{
  "username": "string",
  "password": "string"
}
                                    </div>
                                </div>
                            </div>

                            <!-- Logout -->
                            <div class="card endpoint-card method-delete">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-danger method-badge me-2">DELETE</span>
                                        <code>/admin/logout</code>
                                    </div>
                                    <p class="mb-2">Logout admin</p>
                                </div>
                            </div>

                            <!-- Refresh Token -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/admin/token</code>
                                    </div>
                                    <p class="mb-2">Refresh access token</p>
                                </div>
                            </div>
                        </div>

                        <!-- Admin Profile -->
                        <div id="admin-profile" class="mt-4">
                            <h4 class="text-secondary mb-3">Profile Management</h4>
                            
                            <!-- Get Profile -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/admin/profile</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan profil admin</p>
                                </div>
                            </div>

                            <!-- Update Profile -->
                            <div class="card endpoint-card method-patch">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-warning method-badge me-2">PATCH</span>
                                        <code>/admin/profile</code>
                                    </div>
                                    <p class="mb-2">Mengupdate profil admin</p>
                                </div>
                            </div>
                        </div>

                        <!-- Admin User Management -->
                        <div id="admin-users" class="mt-4">
                            <h4 class="text-secondary mb-3">Admin Management</h4>
                            
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/admin/users/:id</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan detail admin berdasarkan ID</p>
                                </div>
                            </div>

                            <div class="card endpoint-card method-delete">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-danger method-badge me-2">DELETE</span>
                                        <code>/admin/users/:id</code>
                                    </div>
                                    <p class="mb-2">Menghapus admin</p>
                                </div>
                            </div>
                        </div>

                        <!-- Admin Reports -->
                        <div id="admin-reports" class="mt-4">
                            <h4 class="text-secondary mb-3">Report Management</h4>
                            
                            <!-- Get Reports -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/admin/reports</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan semua laporan</p>
                                </div>
                            </div>

                            <!-- Get Report by ID -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/admin/reports/:id</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan detail laporan spesifik</p>
                                </div>
                            </div>

                            <!-- Update Report -->
                            <div class="card endpoint-card method-patch">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-warning method-badge me-2">PATCH</span>
                                        <code>/admin/reports/:id</code>
                                    </div>
                                    <p class="mb-2">Memperbarui laporan</p>
                                </div>
                            </div>

                            <!-- Delete Report -->
                            <div class="card endpoint-card method-delete">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-danger method-badge me-2">DELETE</span>
                                        <code>/admin/reports/:id</code>
                                    </div>
                                    <p class="mb-2">Menghapus laporan</p>
                                </div>
                            </div>
                        </div>

                        <!-- Admin Categories -->
                        <div id="admin-categories" class="mt-4">
                            <h4 class="text-secondary mb-3">Category Management</h4>
                            
                            <!-- Get Categories -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/admin/categories</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan semua kategori</p>
                                </div>
                            </div>

                            <!-- Create Category -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/admin/categories</code>
                                    </div>
                                    <p class="mb-2">Membuat kategori baru</p>
                                </div>
                            </div>

                            <!-- Update Category -->
                            <div class="card endpoint-card method-patch">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-warning method-badge me-2">PATCH</span>
                                        <code>/admin/categories/:id</code>
                                    </div>
                                    <p class="mb-2">Memperbarui kategori</p>
                                </div>
                            </div>

                            <!-- Delete Category -->
                            <div class="card endpoint-card method-delete">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-danger method-badge me-2">DELETE</span>
                                        <code>/admin/categories/:id</code>
                                    </div>
                                    <p class="mb-2">Menghapus kategori</p>
                                </div>
                            </div>
                        </div>

                        <!-- Admin Agencies -->
                        <div id="admin-agencies" class="mt-4">
                            <h4 class="text-secondary mb-3">Agency Management</h4>
                            
                            <!-- Get Agencies -->
                            <div class="card endpoint-card method-get">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-success method-badge me-2">GET</span>
                                        <code>/admin/agencies</code>
                                    </div>
                                    <p class="mb-2">Mendapatkan semua instansi</p>
                                </div>
                            </div>

                            <!-- Create Agency -->
                            <div class="card endpoint-card method-post">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-primary method-badge me-2">POST</span>
                                        <code>/admin/agencies</code>
                                    </div>
                                    <p class="mb-2">Membuat instansi baru</p>
                                </div>
                            </div>

                            <!-- Update Agency -->
                            <div class="card endpoint-card method-patch">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-warning method-badge me-2">PATCH</span>
                                        <code>/admin/agencies/:id</code>
                                    </div>
                                    <p class="mb-2">Memperbarui instansi</p>
                                </div>
                            </div>

                            <!-- Delete Agency -->
                            <div class="card endpoint-card method-delete">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <span class="badge bg-danger method-badge me-2">DELETE</span>
                                        <code>/admin/agencies/:id</code>
                                    </div>
                                    <p class="mb-2">Menghapus instansi</p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- Data Models -->
                    <section id="models" class="mb-5">
                        <h2 class="section-title">
                            <i class="fas fa-database"></i> Data Models
                        </h2>
                        
                        <h4>Report Status Values:</h4>
                        <ul>
                            <li><code>pending</code> - Laporan baru, menunggu verifikasi</li>
                            <li><code>verified</code> - Laporan telah diverifikasi admin</li>
                            <li><code>in_progress</code> - Laporan sedang ditangani instansi</li>
                            <li><code>resolved</code> - Laporan telah diselesaikan</li>
                            <li><code>rejected</code> - Laporan ditolak</li>
                        </ul>

                        <h4 class="mt-4">File Upload:</h4>
                        <ul>
                            <li>Format yang didukung: JPG, JPEG, PNG (untuk gambar), PDF, DOC, DOCX (untuk lampiran)</li>
                            <li>Ukuran maksimal: 5MB per file</li>
                            <li>Gambar bukti wajib disertakan</li>
                            <li>Lampiran tambahan bersifat opsional</li>
                        </ul>
                    </section>

                    <!-- Status Codes -->
                    <section id="status-codes" class="mb-5">
                        <h2 class="section-title">
                            <i class="fas fa-list-ol"></i> HTTP Status Codes
                        </h2>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <h5>Success Codes</h5>
                                <ul>
                                    <li><code>200 OK</code> - Request berhasil</li>
                                    <li><code>201 Created</code> - Resource berhasil dibuat</li>
                                    <li><code>204 No Content</code> - Request berhasil, tanpa content</li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h5>Error Codes</h5>
                                <ul>
                                    <li><code>400 Bad Request</code> - Request tidak valid</li>
                                    <li><code>401 Unauthorized</code> - Tidak terautentikasi</li>
                                    <li><code>403 Forbidden</code> - Tidak memiliki akses</li>
                                    <li><code>404 Not Found</code> - Resource tidak ditemukan</li>
                                    <li><code>500 Internal Server Error</code> - Error server</li>
                                </ul>
                            </div>
                        </div>
                    </section>

                    <!-- Footer -->
                    <footer class="text-center mt-5 pt-4 border-top">
                        <p class="text-muted">
                            <i class="fas fa-code"></i> Laporin API Documentation - 
                            <small>Last updated: ${new Date().toLocaleDateString(
                              "id-ID"
                            )}</small>
                        </p>
                    </footer>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Highlight active section in navigation
        window.addEventListener('scroll', function() {
            const sections = document.querySelectorAll('section[id]');
            const navLinks = document.querySelectorAll('.nav-link[href^="#"]');
            
            let currentSection = '';
            sections.forEach(section => {
                const sectionTop = section.offsetTop - 100;
                if (window.scrollY >= sectionTop) {
                    currentSection = section.getAttribute('id');
                }
            });

            navLinks.forEach(link => {
                link.classList.remove('active', 'text-primary');
                link.classList.add('text-muted');
                if (link.getAttribute('href') === '#' + currentSection) {
                    link.classList.remove('text-muted');
                    link.classList.add('active', 'text-primary');
                }
            });
        });
    </script>
</body>
</html>
  `;

  res.send(htmlContent);
});

export default router;
