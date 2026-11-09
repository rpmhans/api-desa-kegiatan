require('dotenv').config();
const express = require('express');
const pool = require('./src/db');

const app = express();
app.use(express.json());

const SELECT_KEGIATAN = `
  SELECT k.id, k.judul, k.deskripsi, k.tanggal_kegiatan, k.jam_mulai, k.jam_selesai,
         k.status, k.kategori_id, kk.nama_kategori, k.lokasi_id, l.nama_lokasi, k.created_at
  FROM kegiatan k
  JOIN kategori_kegiatan kk ON kk.id = k.kategori_id
  JOIN lokasi l ON l.id = k.lokasi_id
`;

const isValidId = (v) => /^\d+$/.test(v) && Number(v) > 0;

// Penanganan error database yang umum
function handleDbError(err, res) {
  if (err.code === '23503') {
    return res.status(400).json({ message: 'kategori_id atau lokasi_id tidak ditemukan' });
  }
  if (err.code === '23514' || err.code === '22007' || err.code === '22008') {
    return res.status(400).json({ message: 'Data tidak valid (cek status, tanggal, atau jam)' });
  }
  console.error(err);
  return res.status(500).json({ message: 'Terjadi kesalahan pada server' });
}

app.get('/', (req, res) => {
  res.json({ message: 'API Sistem Informasi Kegiatan Desa Sukamaju' });
});

// GET semua kegiatan
app.get('/kegiatan', async (req, res) => {
  try {
    const { rows } = await pool.query(`${SELECT_KEGIATAN} ORDER BY k.tanggal_kegiatan, k.jam_mulai`);
    res.json({ message: 'Berhasil mengambil semua data kegiatan', total: rows.length, data: rows });
  } catch (err) {
    handleDbError(err, res);
  }
});

// GET kegiatan berdasarkan ID
app.get('/kegiatan/:id', async (req, res) => {
  const { id } = req.params;
  if (!isValidId(id)) return res.status(400).json({ message: 'ID tidak valid' });
  try {
    const { rows } = await pool.query(`${SELECT_KEGIATAN} WHERE k.id = $1`, [id]);
    if (!rows.length) return res.status(404).json({ message: 'Kegiatan tidak ditemukan' });
    res.json({ message: 'Berhasil mengambil data kegiatan', data: rows[0] });
  } catch (err) {
    handleDbError(err, res);
  }
});

// POST kegiatan baru
app.post('/kegiatan', async (req, res) => {
  const { judul, deskripsi, tanggal_kegiatan, jam_mulai, jam_selesai, status, kategori_id, lokasi_id } = req.body;
  if (!judul || !tanggal_kegiatan || !jam_mulai || !kategori_id || !lokasi_id) {
    return res.status(400).json({
      message: 'judul, tanggal_kegiatan, jam_mulai, kategori_id, dan lokasi_id wajib diisi',
    });
  }
  try {
    const { rows } = await pool.query(
      `INSERT INTO kegiatan (judul, deskripsi, tanggal_kegiatan, jam_mulai, jam_selesai, status, kategori_id, lokasi_id)
       VALUES ($1, $2, $3, $4, $5, COALESCE($6, 'terjadwal'), $7, $8)
       RETURNING *`,
      [judul, deskripsi || null, tanggal_kegiatan, jam_mulai, jam_selesai || null, status || null, kategori_id, lokasi_id]
    );
    res.status(201).json({ message: 'Kegiatan berhasil dibuat', data: rows[0] });
  } catch (err) {
    handleDbError(err, res);
  }
});

// PUT update kegiatan
app.put('/kegiatan/:id', async (req, res) => {
  const { id } = req.params;
  if (!isValidId(id)) return res.status(400).json({ message: 'ID tidak valid' });
  const { judul, deskripsi, tanggal_kegiatan, jam_mulai, jam_selesai, status, kategori_id, lokasi_id } = req.body;
  if (!judul || !tanggal_kegiatan || !jam_mulai || !kategori_id || !lokasi_id) {
    return res.status(400).json({
      message: 'judul, tanggal_kegiatan, jam_mulai, kategori_id, dan lokasi_id wajib diisi',
    });
  }
  try {
    const { rows } = await pool.query(
      `UPDATE kegiatan
       SET judul = $1, deskripsi = $2, tanggal_kegiatan = $3, jam_mulai = $4, jam_selesai = $5,
           status = COALESCE($6, status), kategori_id = $7, lokasi_id = $8
       WHERE id = $9
       RETURNING *`,
      [judul, deskripsi || null, tanggal_kegiatan, jam_mulai, jam_selesai || null, status || null, kategori_id, lokasi_id, id]
    );
    if (!rows.length) return res.status(404).json({ message: 'Kegiatan tidak ditemukan' });
    res.json({ message: 'Kegiatan berhasil diperbarui', data: rows[0] });
  } catch (err) {
    handleDbError(err, res);
  }
});

// DELETE kegiatan
app.delete('/kegiatan/:id', async (req, res) => {
  const { id } = req.params;
  if (!isValidId(id)) return res.status(400).json({ message: 'ID tidak valid' });
  try {
    const { rows } = await pool.query('DELETE FROM kegiatan WHERE id = $1 RETURNING *', [id]);
    if (!rows.length) return res.status(404).json({ message: 'Kegiatan tidak ditemukan' });
    res.json({ message: 'Kegiatan berhasil dihapus', data: rows[0] });
  } catch (err) {
    handleDbError(err, res);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server berjalan di http://localhost:${PORT}`));
