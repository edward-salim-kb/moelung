import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/utils/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final UserModel currentUser;

  const TermsOfServiceScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: -1, // No bottom nav item
      user: currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Ketentuan Layanan', showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penting: Dokumen ini adalah contoh. Harap konsultasikan dengan ahli hukum untuk membuat Ketentuan Layanan yang sesuai dengan hukum yang berlaku di wilayah Anda.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selamat datang di Moelung! Dengan menggunakan aplikasi kami, Anda menyetujui untuk terikat oleh Ketentuan Layanan berikut. Harap baca dengan seksama.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1. Penerimaan Ketentuan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dengan mengakses atau menggunakan Layanan, Anda menyetujui untuk terikat oleh Ketentuan ini dan semua syarat dan ketentuan yang tergabung di dalamnya melalui referensi. Jika Anda tidak setuju dengan semua Ketentuan ini, jangan gunakan Layanan.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '2. Perubahan Ketentuan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami berhak, atas kebijakan kami sendiri, untuk mengubah atau memodifikasi bagian mana pun dari Ketentuan ini kapan saja. Jika kami melakukannya, kami akan memposting perubahan pada halaman ini dan menunjukkan tanggal revisi terakhir di bagian atas Ketentuan ini. Penggunaan Layanan Anda yang berkelanjutan setelah tanggal tersebut merupakan penerimaan Anda terhadap Ketentuan yang direvisi.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '3. Privasi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan merujuk ke Kebijakan Privasi kami untuk informasi tentang bagaimana kami mengumpulkan, menggunakan, dan mengungkapkan informasi pribadi Anda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '4. Perilaku Pengguna',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Anda setuju untuk tidak menggunakan Layanan untuk tujuan ilegal atau tidak sah. Anda bertanggung jawab penuh atas semua aktivitas yang terjadi di bawah akun Anda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '5. Penghentian',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami dapat menghentikan atau menangguhkan akses Anda ke Layanan kami segera, tanpa pemberitahuan sebelumnya atau kewajiban, untuk alasan apa pun, termasuk tanpa batasan jika Anda melanggar Ketentuan.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '6. Penafian Jaminan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Layanan disediakan atas dasar "sebagaimana adanya" dan "sebagaimana tersedia" tanpa jaminan apa pun, baik tersurat maupun tersirat.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '7. Batasan Tanggung Jawab',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dalam keadaan apa pun Moelung, direktur, karyawan, mitra, agen, pemasok, atau afiliasinya tidak akan bertanggung jawab atas kerugian tidak langsung, insidental, khusus, konsekuensial, atau hukuman, termasuk tanpa batasan, kehilangan keuntungan, data, penggunaan, niat baik, atau kerugian tidak berwujud lainnya, yang dihasilkan dari (i) akses Anda ke atau penggunaan atau ketidakmampuan untuk mengakses atau menggunakan Layanan; (ii) perilaku atau konten pihak ketiga mana pun di Layanan; (iii) konten yang diperoleh dari Layanan; dan (iv) akses, penggunaan, atau perubahan transmisi atau konten Anda yang tidak sah, baik berdasarkan garansi, kontrak, tort (termasuk kelalaian), atau teori hukum lainnya, apakah kami telah diberitahu tentang kemungkinan kerusakan tersebut, dan bahkan jika obat yang ditetapkan di sini ditemukan telah gagal dari tujuan esensialnya.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '8. Hukum yang Mengatur',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketentuan ini akan diatur dan ditafsirkan sesuai dengan hukum Indonesia, tanpa memperhatikan pertentangan ketentuan hukumnya.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '9. Kontak Kami',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jika Anda memiliki pertanyaan tentang Ketentuan ini, silakan hubungi kami.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
