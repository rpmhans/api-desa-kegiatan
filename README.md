# API Sistem Informasi Kegiatan Desa Sukamaju

REST API dengan Express.js dan PostgreSQL untuk mengelola jadwal kegiatan desa (siskamling, gotong royong, rapat warga).

## Cara menjalankan
1. Buat database: `CREATE DATABASE desa_db;`
2. Jalankan `database.sql` (lewat psql atau pgAdmin) untuk membuat tabel dan data contoh:
   `psql -U postgres -d desa_db -f database.sql`
3. Salin `.env.example` menjadi `.env`, lalu isi password PostgreSQL kamu.
4. `npm install`
5. `npm start` (server berjalan di http://localhost:3000)

## Endpoint
| Method | URL | Keterangan |
|---|---|---|
| GET | /kegiatan | Semua kegiatan |
| GET | /kegiatan/:id | Kegiatan berdasarkan ID |
| POST | /kegiatan | Tambah kegiatan |
| PUT | /kegiatan/:id | Ubah kegiatan |
| DELETE | /kegiatan/:id | Hapus kegiatan |

Contoh body POST/PUT:
```json
{
  "judul": "Kerja Bakti Bersih Masjid",
  "deskripsi": "Membersihkan area masjid desa",
  "tanggal_kegiatan": "2026-11-22",
  "jam_mulai": "07:00",
  "jam_selesai": "10:00",
  "status": "terjadwal",
  "kategori_id": 2,
  "lokasi_id": 3
}
```
