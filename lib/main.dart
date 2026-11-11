import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

// Thông tin Cloudinary của dự án thực hành.
// Tuyệt đối KHÔNG đưa API Secret vào Flutter Web.
const String cloudinaryCloudName = 'cicjv3yc';
const String cloudinaryUploadPreset = 'flutter_products';

const Color _forest = Color(0xFF155E52);
const Color _ink = Color(0xFF172B28);
const Color _cream = Color(0xFFF6F7F3);
const Color _orange = Color(0xFFF4BA68);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOVA STORE | Quản lý sản phẩm',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _forest,
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDDE5DF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDDE5DF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _forest, width: 1.5),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Lỗi Firebase Auth: ${snapshot.error}')),
            );
          }
          return snapshot.hasData ? const ProductPage() : const LoginPage();
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: ${error.code}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không đăng nhập được: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6F1E8), _cream, Color(0xFFF9E9D2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.08),
                      blurRadius: 34,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _forest,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.local_mall_outlined, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'NOVA STORE',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: _ink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Chào mừng trở lại',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29, color: _ink),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đăng nhập để quản lý cửa hàng và sản phẩm của bạn.',
                      style: TextStyle(color: Color(0xFF64726C)),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email quản trị viên',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      onSubmitted: (_) {
                        if (!_loading) _login();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _login,
                        icon: const Icon(Icons.login),
                        label: Text(_loading ? 'Đang đăng nhập...' : 'Đăng nhập quản trị'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'Bảo vệ bởi Firebase Authentication',
                        style: TextStyle(color: Color(0xFF8B9792), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dữ liệu giả lập phục vụ demo, chỉ có đúng 4 field theo đề.
// URL ảnh minh họa dùng ảnh Unsplash; khi nộp có thể thay bằng ảnh tự upload Cloudinary.
const List<Map<String, dynamic>> _sampleProducts = [
  {
    'name': 'Áo thun cotton trắng', 'price': 179000, 'soluong': 32,
    'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=700&q=85',
  },
  {
    'name': 'Áo phông basic đen', 'price': 199000, 'soluong': 25,
    'image': 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?w=700&q=85',
  },
  {
    'name': 'Áo hoodie thể thao', 'price': 499000, 'soluong': 16,
    'image': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=700&q=85',
  },
  {
    'name': 'Áo sơ mi thanh lịch', 'price': 389000, 'soluong': 17,
    'image': 'https://images.unsplash.com/photo-1598032895397-b9472444bf93?w=700&q=85',
  },
  {
    'name': 'Quần jeans xanh', 'price': 459000, 'soluong': 29,
    'image': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=700&q=85',
  },
  {
    'name': 'Quần kaki tối giản', 'price': 425000, 'soluong': 12,
    'image': 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=700&q=85',
  },
  {
    'name': 'Giày sneaker trắng', 'price': 890000, 'soluong': 14,
    'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=700&q=85',
  },
  {
    'name': 'Giày running đỏ', 'price': 1090000, 'soluong': 9,
    'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700&q=85',
  },
  {
    'name': 'Giày thể thao Classic', 'price': 940000, 'soluong': 20,
    'image': 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=700&q=85',
  },
  {
    'name': 'Túi xách da thời trang', 'price': 659000, 'soluong': 11,
    'image': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=700&q=85',
  },
  {
    'name': 'Balo du lịch năng động', 'price': 549000, 'soluong': 22,
    'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=700&q=85',
  },
  {
    'name': 'Đồng hồ tối giản', 'price': 1250000, 'soluong': 8,
    'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=700&q=85',
  },
  {
    'name': 'Kính mát phong cách', 'price': 299000, 'soluong': 34,
    'image': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=700&q=85',
  },
  {
    'name': 'Áo khoác da cá tính', 'price': 890000, 'soluong': 7,
    'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=700&q=85',
  },
  {
    'name': 'Váy midi mùa hè', 'price': 530000, 'soluong': 13,
    'image': 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=700&q=85',
  },
  {
    'name': 'Giày sneaker trẻ trung', 'price': 799000, 'soluong': 26,
    'image': 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=700&q=85',
  },
];

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final CollectionReference<Map<String, dynamic>> _products =
      FirebaseFirestore.instance.collection('products');
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream;
  final TextEditingController _searchController = TextEditingController();
  String _category = 'Tất cả';
  String _sort = 'Tên A-Z';
  bool _seeding = false;
  bool _onlyLowStock = false;

  static const _categories = ['Tất cả', 'Áo & váy', 'Quần', 'Giày', 'Phụ kiện'];
  static const _sortOptions = ['Tên A-Z', 'Giá tăng dần', 'Giá giảm dần', 'Tồn kho nhiều nhất'];

  @override
  void initState() {
    super.initState();
    _stream = _products.snapshots();
    _searchController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  int _number(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  String _formatPrice(dynamic value) {
    final digits = _number(value).toString();
    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  // Chuyển tiếng Việt về dạng không dấu để tìm kiếm cả 'áo' và 'ao'.
  String _normalize(String value) {
    var text = value.toLowerCase().trim();
    const groups = <String, String>{
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };
    for (final entry in groups.entries) {
      for (final accent in entry.value.split('')) {
        text = text.replaceAll(accent, entry.key);
      }
    }
    return text;
  }

  String _categoryOf(String name) {
    final n = _normalize(name);
    if (n.startsWith('ao') || n.startsWith('vay') || n.startsWith('dam')) {
      return 'Áo & váy';
    }
    if (n.startsWith('quan')) return 'Quần';
    if (n.startsWith('giay') || n.startsWith('dep')) return 'Giày';
    return 'Phụ kiện';
  }

  void _notify(String message, {bool error = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFFB63B38) : _forest,
        content: Row(
          children: [
            Icon(error ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Future<void> _showProductDetail(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final data = document.data();
    final name = (data['name'] ?? '').toString();
    final imageUrl = (data['image'] ?? '').toString();
    final price = _formatPrice(data['price']);
    final quantity = _number(data['soluong']);
    final status = quantity == 0
        ? 'Hết hàng'
        : quantity <= 5
            ? 'Sắp hết hàng'
            : 'Còn hàng';
    final color = quantity == 0
        ? const Color(0xFFB63B38)
        : quantity <= 5
            ? const Color(0xFF9A660D)
            : _forest;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final compact = MediaQuery.sizeOf(dialogContext).width < 710;
        final photo = ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: compact ? 1.7 : 0.9,
            child: Container(
              color: const Color(0xFFF1F2EE),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.image_outlined, size: 64,
                      color: Color(0xFF9AAA9E))
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image_outlined, size: 64),
                    ),
            ),
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('CHI TIẾT SẢN PHẨM',
                style: TextStyle(fontSize: 11, letterSpacing: 1.3,
                    fontWeight: FontWeight.w800, color: _forest)),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: _ink)),
            const SizedBox(height: 12),
            Text('$price đ', style: const TextStyle(
                fontSize: 27, fontWeight: FontWeight.w900, color: _forest)),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 8),
            Text('Số lượng trong kho: $quantity',
                style: const TextStyle(fontSize: 15, color: _ink)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status, style: TextStyle(
                  fontWeight: FontWeight.w800, color: color)),
            ),
            const SizedBox(height: 12),
            const Text('Danh mục hiển thị được suy ra từ tên sản phẩm.',
                style: TextStyle(fontSize: 12, color: Color(0xFF81918B))),
            const SizedBox(height: 18),
            Wrap(spacing: 10, runSpacing: 8, children: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _showProductForm(document: document);
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Chỉnh sửa'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Đóng'),
              ),
            ]),
          ],
        );
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 430 : 810),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: compact
                    ? Column(mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [photo, const SizedBox(height: 18), details])
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: photo),
                          const SizedBox(width: 28),
                          Expanded(child: details),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showProductForm({
    QueryDocumentSnapshot<Map<String, dynamic>>? document,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProductFormDialog(document: document),
    );
    if (!mounted || result != true) return;
    _notify(document == null
        ? 'Đã thêm sản phẩm thành công vào Firebase.'
        : 'Đã cập nhật sản phẩm thành công.');
  }

  Future<void> _deleteProduct(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final name = (doc.data()['name'] ?? 'sản phẩm').toString();
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text('Bạn muốn xóa "$name" khỏi cửa hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB63B38)),
            child: const Text('Xóa sản phẩm'),
          ),
        ],
      ),
    );
    if (answer != true) return;
    try {
      await doc.reference.delete();
      if (!mounted) return;
      _notify('Đã xóa "$name" khỏi Firestore.');
    } catch (error) {
      if (!mounted) return;
      _notify('Không xóa được sản phẩm: $error', error: true);
    }
  }

  // Chỉ chạy khi admin xác nhận. Bỏ qua sản phẩm trùng tên để không tạo bản sao.
  Future<void> _addSampleProducts() async {
    if (_seeding) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm sản phẩm mẫu?'),
        content: const Text(
          'Ứng dụng sẽ thêm tối đa 16 sản phẩm thời trang mẫu vào Firestore. '
          'Những tên đã có sẽ được bỏ qua. Dữ liệu hiện tại không bị xóa hoặc ghi đè. '
          'Ảnh mẫu là đường dẫn Unsplash, bạn có thể thay bằng ảnh Cloudinary sau.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.add),
            label: const Text('Thêm sản phẩm mẫu'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _seeding = true);
    try {
      final existing = await _products.get();
      final names = existing.docs
          .map((doc) => (doc.data()['name'] ?? '').toString().trim().toLowerCase())
          .toSet();
      final toAdd = _sampleProducts.where((item) {
        final name = (item['name'] ?? '').toString().trim().toLowerCase();
        return !names.contains(name);
      }).toList();
      if (toAdd.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final item in toAdd) {
          batch.set(_products.doc(), item);
        }
        await batch.commit();
      }
      if (!mounted) return;
      _notify('Đã thêm ${toAdd.length} sản phẩm mẫu. Tên trùng được bỏ qua.');
    } catch (error) {
      if (!mounted) return;
      _notify('Không thể nhập sản phẩm mẫu: $error', error: true);
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  Widget _topBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _forest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_mall_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOVA STORE',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                Text(
                  'QUẢN TRỊ CỬA HÀNG',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    color: Color(0xFF81918B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: FirebaseAuth.instance.currentUser?.email ?? 'Admin',
            child: const CircleAvatar(
              radius: 19,
              backgroundColor: Color(0xFFE0EDE8),
              child: Icon(Icons.person_outline, color: _forest),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded, color: _ink),
          ),
        ],
      ),
    );
  }

  Widget _hero(double width) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF154E45), Color(0xFF2C8C72)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42, top: -70,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07)),
            ),
          ),
          Positioned(
            right: 100, bottom: -100,
            child: Container(
              width: 230, height: 230,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _orange.withValues(alpha: 0.11)),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width > 620 ? 42 : 24, vertical: width > 620 ? 34 : 28),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text('BỘ SƯU TẬP • 2026',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 18),
                      Text('Bộ sưu tập thời trang\nđầy cảm hứng.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width > 700 ? 32 : 23,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 14),
                      const Text(
                        'Quản lý bộ sưu tập, hình ảnh, giá bán và tồn kho trong một nơi.',
                        style: TextStyle(color: Color(0xFFDCF1E9), fontSize: 13),
                      ),
                      const SizedBox(height: 23),
                      FilledButton.icon(
                        onPressed: () => _showProductForm(),
                        style: FilledButton.styleFrom(
                          foregroundColor: _ink,
                          backgroundColor: _orange,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Thêm sản phẩm'),
                      ),
                    ],
                  ),
                ),
                if (width > 780) ...[
                  const SizedBox(width: 26),
                  Container(
                    width: width > 1100 ? 300 : 235,
                    height: 218,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF286F5F),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800&q=85',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.shopping_bag_rounded,
                              size: 120, color: Color(0xFFFFD9A9)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required Color tint}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBE6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.11), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: tint, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: _ink)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Color(0xFF718078), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterToolbar(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Khám phá sản phẩm',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w900, fontSize: 25)),
        const SizedBox(height: 6),
        const Text('Bộ sưu tập đang có trong cửa hàng',
            style: TextStyle(color: Color(0xFF7D8A83), fontSize: 13)),
        const SizedBox(height: 22),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: width > 620 ? 350 : width,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm theo tên sản phẩm...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDDE5DF))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sort,
                    items: _sortOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                    onChanged: (value) => setState(() => _sort = value ?? 'Tên A-Z'),
                  ),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _seeding ? null : _addSampleProducts,
              icon: _seeding
                  ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.playlist_add_rounded),
              label: const Text('Thêm 16 sản phẩm mẫu'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._categories.map((category) {
                final selected = _category == category;
                return Padding(
                padding: const EdgeInsets.only(right: 9),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: _forest,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : _ink,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (_) => setState(() => _category = category),
                ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: FilterChip(
                  label: const Text('Sắp hết / hết hàng'),
                  avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                  selected: _onlyLowStock,
                  selectedColor: const Color(0xFFFFE7B6),
                  onSelected: (value) =>
                      setState(() => _onlyLowStock = value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Lỗi đọc Firestore: ${snapshot.error}'),
                    ));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docsAll = snapshot.data!.docs;
                  final totalStock = docsAll.fold<int>(
                    0, (total, doc) => total + _number(doc.data()['soluong']),
                  );
                  final totalValue = docsAll.fold<int>(
                    0, (total, doc) => total +
                        _number(doc.data()['price']) *
                        _number(doc.data()['soluong']),
                  );
                  final lowStockCount = docsAll.where((doc) =>
                      _number(doc.data()['soluong']) <= 5).length;
                  final outOfStockCount = docsAll.where((doc) =>
                      _number(doc.data()['soluong']) == 0).length;

                  final search = _normalize(_searchController.text);
                  final filtered = docsAll.where((doc) {
                    final name = (doc.data()['name'] ?? '').toString();
                    return _normalize(name).contains(search) &&
                        (_category == 'Tất cả' || _categoryOf(name) == _category) &&
                        (!_onlyLowStock || _number(doc.data()['soluong']) <= 5);
                  }).toList();
                  filtered.sort((a, b) {
                    final left = a.data();
                    final right = b.data();
                    switch (_sort) {
                      case 'Giá tăng dần':
                        return _number(left['price']).compareTo(_number(right['price']));
                      case 'Giá giảm dần':
                        return _number(right['price']).compareTo(_number(left['price']));
                      case 'Tồn kho nhiều nhất':
                        return _number(right['soluong']).compareTo(_number(left['soluong']));
                      default:
                        return (left['name'] ?? '').toString().toLowerCase()
                            .compareTo((right['name'] ?? '').toString().toLowerCase());
                    }
                  });

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final fullWidth = constraints.maxWidth;
                      final horizontalPad = fullWidth > 650 ? 25.0 : 16.0;
                      final contentWidth = (fullWidth - 2 * horizontalPad).clamp(0.0, 1220.0).toDouble();
                      final statsPerRow = contentWidth > 1020 ? 4 : contentWidth > 560 ? 2 : 1;
                      final statWidth = (contentWidth - (statsPerRow - 1) * 14) / statsPerRow;
                      final columns = contentWidth >= 1040 ? 4 : contentWidth >= 730 ? 3 : contentWidth >= 465 ? 2 : 1;
                      return SingleChildScrollView(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1270),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(horizontalPad, 24, horizontalPad, 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _hero(contentWidth),
                                  const SizedBox(height: 19),
                                  Wrap(
                                    spacing: 14, runSpacing: 14,
                                    children: [
                                      SizedBox(width: statWidth, child: _statCard(
                                        icon: Icons.inventory_2_outlined, label: 'Tổng sản phẩm',
                                        value: '${docsAll.length}', tint: _forest,
                                      )),
                                      SizedBox(width: statWidth, child: _statCard(
                                        icon: Icons.stacked_bar_chart, label: 'Số lượng trong kho',
                                        value: '$totalStock', tint: const Color(0xFFBC7834),
                                      )),
                                      SizedBox(width: statWidth, child: _statCard(
                                        icon: Icons.payments_outlined, label: 'Giá trị hàng tồn',
                                        value: '${_formatPrice(totalValue)} đ', tint: const Color(0xFF5774AE),
                                      )),
                                      SizedBox(width: statWidth, child: _statCard(
                                        icon: Icons.warning_amber_rounded,
                                        label: 'Sắp hết / hết hàng',
                                        value: '$lowStockCount sản phẩm',
                                        tint: const Color(0xFFBC7834),
                                      )),
                                    ],
                                  ),
                                  if (lowStockCount > 0) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF4E4),
                                        border: Border.all(color: const Color(0xFFEBD8AE)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.inventory_2_outlined,
                                              color: Color(0xFF98620B)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              '$lowStockCount sản phẩm còn tối đa 5 món; '
                                              '$outOfStockCount sản phẩm đã hết hàng.',
                                              style: const TextStyle(color: Color(0xFF825408)),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => setState(() => _onlyLowStock = true),
                                            child: const Text('Lọc ngay'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 35),
                                  _filterToolbar(contentWidth),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Text('${filtered.length} sản phẩm',
                                          style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)),
                                      const Spacer(),
                                      const Icon(Icons.grid_view_rounded, color: _forest),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  if (filtered.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 65, horizontal: 18),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                      child: const Column(
                                        children: [
                                          Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF9CA9A1)),
                                          SizedBox(height: 14),
                                          Text('Chưa có sản phẩm phù hợp',
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 8),
                                          Text('Thử đổi từ khóa hoặc thêm sản phẩm mới.'),
                                        ],
                                      ),
                                    )
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filtered.length,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 18,
                                        mainAxisExtent: columns == 1 ? 440 : 392,
                                      ),
                                      itemBuilder: (context, index) {
                                        final doc = filtered[index];
                                        return _StoreProductCard(
                                          document: doc,
                                          price: _formatPrice(doc.data()['price']),
                                          quantity: _number(doc.data()['soluong']),
                                          onView: () => _showProductDetail(doc),
                                          onEdit: () => _showProductForm(document: doc),
                                          onDelete: () => _deleteProduct(doc),
                                        );
                                      },
                                    ),
                                  const SizedBox(height: 30),
                                  const Center(
                                    child: Text('NOVA STORE • Dữ liệu quản lý bởi Firebase Firestore',
                                        style: TextStyle(color: Color(0xFF98A39D), fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  const _StoreProductCard({
    required this.document,
    required this.price,
    required this.quantity,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> document;
  final String price;
  final int quantity;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final data = document.data();
    final imageUrl = (data['image'] ?? '').toString();
    final name = (data['name'] ?? '').toString();
    final stockText = quantity == 0 ? 'Hết hàng' : quantity <= 5 ? 'Sắp hết hàng' : 'Còn hàng';
    final stockColor = quantity == 0
        ? const Color(0xFFB63B38)
        : quantity <= 5 ? const Color(0xFF9A660D) : _forest;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE7ECE6)),
        boxShadow: [
          BoxShadow(color: _ink.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Material(
                  color: const Color(0xFFF1F2EE),
                  child: InkWell(
                    onTap: onView,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.image_outlined, size: 58,
                            color: Color(0xFF9AAA9E))
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image_outlined,
                                    size: 54, color: Color(0xFF9AAA9E)),
                          ),
                  ),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
                    child: Text(stockText,
                        style: TextStyle(color: stockColor, fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: _ink)),
                const SizedBox(height: 5),
                Text('$price đ',
                    style: const TextStyle(color: _forest, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 3),
                Text('Kho: $quantity sản phẩm',
                    style: const TextStyle(color: Color(0xFF86938A), fontSize: 11)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: TextButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 17),
                    label: const Text('Xem chi tiết'),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text('Sửa'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: Color(0xFFD2DED7)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: 'Xóa sản phẩm',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFB63B38)),
                      style: IconButton.styleFrom(side: const BorderSide(color: Color(0xFFE5DDD8))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Form CRUD và tải ảnh lên Cloudinary, giữ từ phiên bản đã chạy được.
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.document});

  final QueryDocumentSnapshot<Map<String, dynamic>>? document;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _imageUrl;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _saving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final product = widget.document?.data();
    _name = TextEditingController(text: product?['name']?.toString() ?? '');
    _price = TextEditingController(text: product?['price']?.toString() ?? '');
    _quantity = TextEditingController(text: product?['soluong']?.toString() ?? '');
    _imageUrl = TextEditingController(text: product?['image']?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _quantity.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return; // Người dùng bấm Hủy.

      final fileName = picked.name.toLowerCase();
      final validFormat = fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg') ||
          fileName.endsWith('.png') ||
          fileName.endsWith('.webp');
      if (!validFormat) {
        throw Exception('Chỉ chọn ảnh JPG, PNG hoặc WebP.');
      }

      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        throw Exception('Ảnh vượt quá 5 MB. Vui lòng chọn ảnh nhỏ hơn.');
      }
      if (bytes.isEmpty) {
        throw Exception('Không đọc được nội dung ảnh.');
      }
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = picked.name;
        _formError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _formError = 'Chọn ảnh thất bại: $error');
    }
  }

  Future<String> _uploadSelectedImage() async {
    final bytes = _selectedImageBytes;
    final fileName = _selectedImageName;
    if (bytes == null || fileName == null) {
      throw StateError('Chưa chọn ảnh.');
    }

    final endpoint = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
      '$cloudinaryCloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', endpoint)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Phản hồi có thể không ở định dạng JSON.
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = response.body;
      final rawError = body?['error'];
      if (rawError is Map && rawError['message'] != null) {
        detail = rawError['message'].toString();
      }
      throw Exception('Cloudinary (${response.statusCode}): $detail');
    }

    final url = body?['secure_url'];
    if (url is! String || !url.startsWith('https://')) {
      throw Exception('Cloudinary không trả về đường dẫn ảnh hợp lệ.');
    }
    return url;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _formError = null;
    });

    try {
      // Kiểm tra tên trùng trước khi tải ảnh, tránh tạo file Cloudinary vô ích.
      final newName = _name.text.trim().toLowerCase();
      final currentId = widget.document?.id;
      final existing = await FirebaseFirestore.instance.collection('products').get();
      final duplicated = existing.docs.any((doc) =>
          doc.id != currentId &&
          (doc.data()['name'] ?? '').toString().trim().toLowerCase() == newName);
      if (duplicated) {
        throw const FormatException('Tên sản phẩm đã tồn tại. Hãy dùng tên khác.');
      }

      // Có ảnh mới thì tải lên trước. Không có thì giữ URL hiện tại.
      var image = _imageUrl.text.trim();
      if (_selectedImageBytes != null) {
        image = await _uploadSelectedImage();
      }

      // Collection products chỉ có đúng bốn field theo đề bài.
      final product = <String, dynamic>{
        'name': _name.text.trim(),
        'price': int.parse(_price.text.trim()),
        'soluong': int.parse(_quantity.text.trim()),
        'image': image,
      };

      if (widget.document == null) {
        await FirebaseFirestore.instance.collection('products').add(product);
      } else {
        await widget.document!.reference.update(product);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _formError = 'Không lưu được: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = _imageUrl.text.trim();
    final showUrlPreview = _selectedImageBytes == null &&
        (existingUrl.startsWith('https://') ||
            existingUrl.startsWith('http://'));

    return AlertDialog(
      title: Text(widget.document == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  validator: (value) {
                    final name = (value ?? '').trim();
                    if (name.isEmpty) return 'Hãy nhập tên sản phẩm';
                    if (name.length < 2) return 'Tên cần tối thiểu 2 ký tự';
                    if (name.length > 100) return 'Tên không vượt quá 100 ký tự';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá (VNĐ)'),
                  validator: (value) {
                    final number = int.tryParse((value ?? '').trim());
                    if (number == null || number <= 0) {
                      return 'Nhập giá nguyên dương, ví dụ 160000';
                    }
                    if (number > 1000000000) {
                      return 'Giá tối đa 1.000.000.000 VNĐ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantity,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  validator: (value) {
                    final number = int.tryParse((value ?? '').trim());
                    if (number == null || number < 0) {
                      return 'Số lượng phải là số nguyên không âm';
                    }
                    if (number > 1000000) {
                      return 'Số lượng tối đa 1.000.000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrl,
                  enabled: !_saving,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'URL ảnh (không bắt buộc)',
                    hintText: 'https://res.cloudinary.com/...',
                  ),
                  validator: (value) {
                    if (_selectedImageBytes != null) return null;
                    final url = (value ?? '').trim();
                    if (url.isEmpty) return null;
                    final uri = Uri.tryParse(url);
                    if (uri == null || uri.host.isEmpty || uri.scheme != 'https') {
                      return 'URL ảnh phải bắt đầu bằng https://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Chọn ảnh từ máy'),
                ),
                if (_selectedImageBytes != null) ...[
                  const SizedBox(height: 8),
                  Text('Ảnh đã chọn: ${_selectedImageName ?? ''}'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: 150,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _selectedImageBytes = null;
                              _selectedImageName = null;
                            }),
                    child: const Text('Bỏ ảnh đã chọn'),
                  ),
                ] else if (showUrlPreview) ...[
                  const SizedBox(height: 8),
                  Image.network(
                    existingUrl,
                    width: 150,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 48),
                  ),
                ],
                if (_saving) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                  const Text('Đang tải ảnh/lưu sản phẩm...'),
                ],
                if (_formError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _formError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Lưu sản phẩm'),
        ),
      ],
    );
  }
}
