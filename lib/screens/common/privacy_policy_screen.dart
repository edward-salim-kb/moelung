import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final UserModel currentUser;

  const PrivacyPolicyScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: -1, // No bottom nav item
      user: currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Kebijakan Privasi', showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penting: Dokumen ini adalah contoh. Harap konsultasikan dengan ahli hukum untuk membuat Kebijakan Privasi yang sesuai dengan hukum yang berlaku di wilayah Anda dan praktik pengumpulan data Anda.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kebijakan Privasi ini menjelaskan bagaimana Moelung mengumpulkan, menggunakan, dan mengungkapkan informasi pribadi Anda saat Anda menggunakan aplikasi kami.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1. Informasi yang Kami Kumpulkan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami mengumpulkan berbagai jenis informasi untuk berbagai tujuan guna menyediakan dan meningkatkan Layanan kami kepada Anda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'a. Data Pribadi: Saat menggunakan Layanan kami, kami dapat meminta Anda untuk memberikan kami informasi identitas pribadi tertentu yang dapat digunakan untuk menghubungi atau mengidentifikasi Anda ("Data Pribadi"). Informasi identitas pribadi dapat mencakup, namun tidak terbatas pada: alamat email, nama, nomor telepon, alamat, data penggunaan.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'b. Data Penggunaan: Kami juga dapat mengumpulkan informasi tentang bagaimana Layanan diakses dan digunakan ("Data Penggunaan"). Data Penggunaan ini dapat mencakup informasi seperti alamat Protokol Internet komputer Anda (misalnya alamat IP), jenis browser, versi browser, halaman Layanan kami yang Anda kunjungi, waktu dan tanggal kunjungan Anda, waktu yang dihabiskan di halaman tersebut, pengenal perangkat unik, dan data diagnostik lainnya.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '2. Penggunaan Data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Moelung menggunakan data yang dikumpulkan untuk berbagai tujuan:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'a. Untuk menyediakan dan memelihara Layanan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'b. Untuk memberi tahu Anda tentang perubahan pada Layanan kami',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'c. Untuk memungkinkan Anda berpartisipasi dalam fitur interaktif Layanan kami saat Anda memilih untuk melakukannya',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'd. Untuk memberikan dukungan pelanggan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'e. Untuk memantau penggunaan Layanan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'f. Untuk mendeteksi, mencegah, dan mengatasi masalah teknis',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '3. Pengungkapan Data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Moelung dapat mengungkapkan Data Pribadi Anda dengan itikad baik bahwa tindakan tersebut diperlukan untuk:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'a. Untuk mematuhi kewajiban hukum',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'b. Untuk melindungi dan membela hak atau properti Moelung',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'c. Untuk mencegah atau menyelidiki kemungkinan kesalahan terkait Layanan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'd. Untuk melindungi keamanan pribadi pengguna Layanan atau publik',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'e. Untuk melindungi dari tanggung jawab hukum',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '4. Keamanan Data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keamanan data Anda penting bagi kami, tetapi ingat bahwa tidak ada metode transmisi melalui Internet, atau metode penyimpanan elektronik yang 100% aman. Meskipun kami berusaha untuk menggunakan cara yang dapat diterima secara komersial untuk melindungi Data Pribadi Anda, kami tidak dapat menjamin keamanan mutlaknya.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '5. Perubahan pada Kebijakan Privasi Ini',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kami dapat memperbarui Kebijakan Privasi kami dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan apa pun dengan memposting Kebijakan Privasi baru di halaman ini. Anda disarankan untuk meninjau Kebijakan Privasi ini secara berkala untuk setiap perubahan. Perubahan pada Kebijakan Privasi ini efektif ketika diposting di halaman ini.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '6. Kontak Kami',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami.',
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
