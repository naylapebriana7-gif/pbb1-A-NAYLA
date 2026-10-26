import 'data.dart';
import 'input.dart';

// ============================================================
// Fungsi bantu
// ============================================================

/// Mencari barang berdasarkan kode. Mengembalikan null jika tidak ada.
Map<String, dynamic>? cariByKode(String kode) {
  for (final barang in daftarBarang) {
    if (barang['kode'] == kode) return barang;
  }
  return null;
}

/// Menghitung total harga semua barang di keranjang (sebelum diskon).
int hitungTotal() {
  var total = 0;
  keranjang.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    total += (barang['harga'] as int) * jumlah;
  });
  return total;
}

/// Mencetak isi keranjang beserta subtotal setiap barang.
void cetakIsiKeranjang(Map<String, int> isi) {
  isi.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    final harga = barang['harga'] as int;
    print(
      '$kode | ${barang['nama']} | $jumlah x Rp$harga = Rp${harga * jumlah}',
    );
  });
}

// ============================================================
// Fitur yang sudah jadi
// ============================================================

/// Menu 1: menampilkan semua barang.
void tampilkanBarang() {
  print('\n=== Daftar Barang ===');
  for (final barang in daftarBarang) {
    print(
      '${barang['kode']} | ${barang['nama']} | '
      'Rp${barang['harga']} | stok ${barang['stok']}',
    );
  }
}

/// Menu 2: memasukkan barang ke keranjang.
void tambahKeKeranjang() {
  print('\n=== Tambah ke Keranjang ===');
  final kode = bacaTeks('Kode barang').toUpperCase();
  final barang = cariByKode(kode);
  if (barang == null) {
    print('Barang dengan kode $kode tidak ditemukan.');
    return;
  }
  final jumlah = bacaInt('Jumlah', min: 1, max: 1000);
  final sudahDiKeranjang = keranjang[kode] ?? 0;
  final stok = barang['stok'] as int;
  if (sudahDiKeranjang + jumlah > stok) {
    print(
      'Stok tidak cukup. Stok ${barang['nama']}: $stok, '
      'di keranjang: $sudahDiKeranjang.',
    );
    return;
  }
  keranjang[kode] = sudahDiKeranjang + jumlah;
  print('$jumlah ${barang['nama']} masuk ke keranjang.');
}

/// Menu 3: menampilkan isi keranjang, diskon, dan total bayar.
void tampilkanKeranjang() {
  print('\n=== Keranjang ===');
  if (keranjang.isEmpty) {
    print('Keranjang kosong.');
    return;
  }
  cetakIsiKeranjang(keranjang);
  final total = hitungTotal();
  final diskon = hitungDiskon(total);
  print('Total      : Rp$total');
  print('Diskon     : Rp$diskon');
  print('Total bayar: Rp${total - diskon}');
}

// ============================================================
// Fitur pilihan (pilih minimal 3, lihat README.md)
// ============================================================

/// Menu 4 [Mudah]: menambah barang baru ke daftar barang.
void tambahBarangBaru() {
  print('\n=== Tambah barang ===');
  final kode = bacaTeks('Masukan kode barang: ');
  if (cariByKode(kode) != null) {
    print('Gagal: Barang dengan kode tersebut sudah ada!');
    return;
  }
  final String nama = bacaTeks('Masukan nama barang: ');
  final harga = bacaInt('Masukan harga barang: ', min: 0);
  final stok = bacaInt('Masukan stok awal: ', min: 0);

  daftarBarang.add({
    'kode': kode,
    'nama': nama,
    'harga': harga,
    'stok': stok,
  });

  print('Sukses: Barang baru berhasil ditambahkan!');
}

/// Menu 5 [Mudah]: menghapus satu barang dari keranjang.
void hapusDariKeranjang() {
  print('\n=== Hapus barang di keranjang ===');
  final kode = bacaTeks('Masukan kode barang yang ingin dihapus: ');
  if (keranjang.containsKey(kode)) {
    keranjang.remove(kode);
    print('Sukses: Barang berhasil dihapus dari keranjang!');
  } else {
    // Tampilkan pesan jika barang tidak ada di keranjang.
    print('Gagal: Barang dengan kode tersebut tidak ada di keranjang.');
  }
}

/// [Sedang] Menghitung potongan diskon dari [total] belanja.
///
/// Fungsi ini sudah dipakai di menu 3. Selama belum dibuat, diskon selalu 0.
int hitungDiskon(int total) {
    if (total >= 100000) {
      return (total * 0.10).toInt(); // Diskon 10%
    } else if (total >= 50000) {
      return (total * 0.05).toInt(); // Diskon 5%
    } else {
      return 0;
    }
}

/// Menu 6 [Sedang]: membayar belanjaan di keranjang.
void bayar() {
  print('\n=== Bayar Belanjaan ===');

  // cek apakah keranjang kosong
  if (keranjang.isEmpty) {
    print('Keranjang kosong.');
    return;
  }
  // 1. Tampilkan total bayar (total - diskon), lalu minta uang yang diterima.
  final total = hitungTotal();
  final diskon = hitungDiskon(total);
  final totalBayar = total - diskon;

  print('Total Bayar: Rp$totalBayar');

  final inputUang = bacaTeks('Masukkan jumlah uang: ');
  final uang = int.tryParse(inputUang) ?? 0;

  // 2. Buat fungsi hitungKembalian(totalBayar, uang) yang melempar Exception
  // jika uang kurang. Tangkap dengan try-catch dan tampilkan pesannya.
  int hitungKembalian(int totalBayar, int uangDiterima) {
  if (uangDiterima < totalBayar) {
    throw Exception('Uang tidak cukup!');
  }
  return uangDiterima - totalBayar;
}
  try {
    final kembalian = hitungKembalian(totalBayar, uang); 
    
    // 3. Jika berhasil: tampilkan kembalian, panggil kurangiStok() dan
    print('Kembalian: Rp$kembalian');

    kurangiStok();
    simpanRiwayat(totalBayar, diskon, uang, kembalian);
    keranjang.clear();

    print('Pembayaran berhasil!');
  } catch (e) {
    print('Gagal: ${e.toString().replaceAll('Exception: ', '')}');
  }
}
  //    simpanRiwayat(...), lalu kosongkan keranjang.
  ///
/// Dipanggil dari bayar(), jadi fitur ini membutuhkan menu 6.
void simpanRiwayat(int total, int diskon, int uang, int kembalian) {
  riwayatTransaksi.add({
    'nomor': riwayatTransaksi.length + 1,
    'detail': Map<String, int>.from(keranjang),
    'total': total,
    'diskon': diskon,
    'uang': uang,
    'kembalian': kembalian,
  });
}
/// [Sulit] Mengurangi stok barang sesuai isi keranjang.
///
/// Dipanggil dari bayar(), jadi fitur ini membutuhkan menu 6.
void kurangiStok() {
  keranjang.forEach((kode, jumlah) {
    final barang = cariByKode(kode);
    if (barang != null) {
      barang['stok'] = (barang['stok'] as int) - jumlah;
    }
  });
}

/// Menu 7 [Sulit]: menampilkan struk semua transaksi.
void tampilkanRiwayat() {
  // TODO: tampilkan setiap transaksi di riwayatTransaksi seperti struk:
  // isi belanja, total, diskon, total bayar, uang, dan kembalian.
  print('Fitur belum tersedia.');
}
