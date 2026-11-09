DROP TABLE IF EXISTS peserta_kegiatan CASCADE;
DROP TABLE IF EXISTS kegiatan CASCADE;
DROP TABLE IF EXISTS lokasi CASCADE;
DROP TABLE IF EXISTS kategori_kegiatan CASCADE;
DROP TABLE IF EXISTS profil_warga CASCADE;
DROP TABLE IF EXISTS warga CASCADE;
DROP TABLE IF EXISTS dusun CASCADE;

-- 1. Dusun (parent dari warga -> one to many)
CREATE TABLE dusun (
  id            SERIAL PRIMARY KEY,
  nama_dusun    VARCHAR(100) NOT NULL UNIQUE,
  kepala_dusun  VARCHAR(100)
);

-- 2. Warga (many warga -> 1 dusun)
CREATE TABLE warga (
  id             SERIAL PRIMARY KEY,
  nik            CHAR(16) NOT NULL UNIQUE,
  nama_lengkap   VARCHAR(150) NOT NULL,
  jenis_kelamin  CHAR(1) NOT NULL CHECK (jenis_kelamin IN ('L', 'P')),
  tanggal_lahir  DATE,
  dusun_id       INT NOT NULL REFERENCES dusun(id) ON DELETE RESTRICT,
  created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 3. Profil warga (ONE TO ONE dengan warga, warga_id UNIQUE)
CREATE TABLE profil_warga (
  id         SERIAL PRIMARY KEY,
  warga_id   INT NOT NULL UNIQUE REFERENCES warga(id) ON DELETE CASCADE,
  no_hp      VARCHAR(20),
  alamat     TEXT,
  pekerjaan  VARCHAR(100)
);

-- 4. Kategori kegiatan (parent dari kegiatan -> one to many)
CREATE TABLE kategori_kegiatan (
  id             SERIAL PRIMARY KEY,
  nama_kategori  VARCHAR(100) NOT NULL UNIQUE,
  deskripsi      TEXT
);

-- 5. Lokasi (parent dari kegiatan -> one to many)
CREATE TABLE lokasi (
  id           SERIAL PRIMARY KEY,
  nama_lokasi  VARCHAR(150) NOT NULL,
  alamat       TEXT,
  kapasitas    INT CHECK (kapasitas IS NULL OR kapasitas > 0)
);

-- 6. Kegiatan (many kegiatan -> 1 kategori dan 1 lokasi)
CREATE TABLE kegiatan (
  id               SERIAL PRIMARY KEY,
  judul            VARCHAR(200) NOT NULL,
  deskripsi        TEXT,
  tanggal_kegiatan DATE NOT NULL,
  jam_mulai        TIME NOT NULL,
  jam_selesai      TIME,
  status           VARCHAR(20) NOT NULL DEFAULT 'terjadwal'
                   CHECK (status IN ('terjadwal', 'berlangsung', 'selesai', 'dibatalkan')),
  kategori_id      INT NOT NULL REFERENCES kategori_kegiatan(id) ON DELETE RESTRICT,
  lokasi_id        INT NOT NULL REFERENCES lokasi(id) ON DELETE RESTRICT,
  created_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 7. Peserta kegiatan (MANY TO MANY antara warga dan kegiatan)
CREATE TABLE peserta_kegiatan (
  warga_id          INT NOT NULL REFERENCES warga(id) ON DELETE CASCADE,
  kegiatan_id       INT NOT NULL REFERENCES kegiatan(id) ON DELETE CASCADE,
  status_kehadiran  VARCHAR(20) NOT NULL DEFAULT 'belum_konfirmasi'
                    CHECK (status_kehadiran IN ('hadir', 'tidak_hadir', 'belum_konfirmasi')),
  created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (warga_id, kegiatan_id)
);

-- =====================================================
-- DATA CONTOH
-- =====================================================
INSERT INTO dusun (nama_dusun, kepala_dusun) VALUES
  ('Dusun Krajan', 'Bapak Sutrisno'),
  ('Dusun Sidomulyo', 'Bapak Hartono'),
  ('Dusun Karangrejo', 'Ibu Siti Aminah');

INSERT INTO warga (nik, nama_lengkap, jenis_kelamin, tanggal_lahir, dusun_id) VALUES
  ('3578010101900001', 'Budi Santoso', 'L', '1990-01-01', 1),
  ('3578010202850002', 'Siti Rahayu',  'P', '1985-02-02', 1),
  ('3578010303950003', 'Agus Prasetyo','L', '1995-03-03', 2),
  ('3578010404880004', 'Dewi Lestari', 'P', '1988-04-04', 3);

INSERT INTO profil_warga (warga_id, no_hp, alamat, pekerjaan) VALUES
  (1, '081234567801', 'RT 01 RW 01 Dusun Krajan', 'Petani'),
  (2, '081234567802', 'RT 02 RW 01 Dusun Krajan', 'Guru'),
  (3, '081234567803', 'RT 01 RW 02 Dusun Sidomulyo', 'Wiraswasta'),
  (4, '081234567804', 'RT 03 RW 03 Dusun Karangrejo', 'Bidan Desa');

INSERT INTO kategori_kegiatan (nama_kategori, deskripsi) VALUES
  ('Siskamling', 'Sistem keamanan lingkungan oleh warga'),
  ('Gotong Royong', 'Kerja bakti kebersihan dan perbaikan fasilitas umum'),
  ('Rapat Warga', 'Musyawarah dan pertemuan warga desa');

INSERT INTO lokasi (nama_lokasi, alamat, kapasitas) VALUES
  ('Balai Desa Sukamaju', 'Jl. Raya Sukamaju No. 1', 150),
  ('Pos Kamling RT 01', 'RT 01 RW 01 Dusun Krajan', 20),
  ('Lapangan Desa', 'Jl. Lapangan, Dusun Sidomulyo', 300);

INSERT INTO kegiatan (judul, deskripsi, tanggal_kegiatan, jam_mulai, jam_selesai, status, kategori_id, lokasi_id) VALUES
  ('Ronda Malam Dusun Krajan', 'Jadwal ronda malam pekan ke-2', '2026-11-14', '22:00', '04:00', 'terjadwal', 1, 2),
  ('Kerja Bakti Bersih Selokan', 'Membersihkan selokan utama desa', '2026-11-15', '07:00', '11:00', 'terjadwal', 2, 3),
  ('Rapat Musyawarah Desa', 'Pembahasan anggaran desa tahun 2027', '2026-11-20', '19:30', '22:00', 'terjadwal', 3, 1);

INSERT INTO peserta_kegiatan (warga_id, kegiatan_id, status_kehadiran) VALUES
  (1, 1, 'hadir'),
  (2, 1, 'belum_konfirmasi'),
  (1, 2, 'hadir'),
  (3, 2, 'hadir'),
  (4, 2, 'tidak_hadir'),
  (1, 3, 'belum_konfirmasi'),
  (4, 3, 'hadir');
