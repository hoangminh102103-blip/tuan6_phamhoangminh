import 'dart:io';
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

// MÀN HÌNH MENU CHÍNH (Chọn Đi đến Đọc SMS hoặc Quản lý Danh Bạ)
class Bai35Telephony extends StatelessWidget {
  const Bai35Telephony({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Telephony & Contacts (Bài 3 & 5)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Nhảy sang màn hình Đọc tin nhắn
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SmsReaderScreen()));
            },
            child: const Text('Đọc tin nhắn SMS (Bài 3)'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Nhảy sang màn hình Quản lý danh bạ
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsListScreen()));
            },
            child: const Text('Danh bạ điện thoại (Bài 3 & 5)'),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// MÀN HÌNH ĐỌC TIN NHẮN (BÀI 3)
// ========================================================
class SmsReaderScreen extends StatefulWidget {
  const SmsReaderScreen({super.key});
  @override
  State<SmsReaderScreen> createState() => _SmsReaderScreenState();
}

class _SmsReaderScreenState extends State<SmsReaderScreen> {
  // Khởi tạo bộ công cụ đọc tin nhắn (Telephony)
  final Telephony telephony = Telephony.instance;
  
  // Danh sách để chứa tin nhắn sau khi đọc được
  List<SmsMessage> _messages = [];
  bool _isLoading = true; // Trạng thái đang xoay xoay tải dữ liệu

  @override
  void initState() {
    super.initState();
    _initializePermissions(); // Vừa vào màn hình là xin quyền ngay
  }

  // Hàm xin quyền đọc SMS
  Future<void> _initializePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.sms, Permission.phone].request();
    
    // Nếu được cấp quyền SMS thì gọi hàm đọc tin nhắn
    if (statuses[Permission.sms]!.isGranted) {
      _loadMessages();
    } else {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng cấp quyền đọc tin nhắn SMS!')));
      }
      setState(() => _isLoading = false); // Dừng xoay vòng tải
    }
  }

  // Hàm lấy tin nhắn từ hộp thư trong điện thoại
  Future<void> _loadMessages() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE, SmsColumn.TYPE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)], // Sắp xếp tin nhắn mới nhất lên đầu
    );
    if(mounted) {
      setState(() {
        _messages = messages; // Gán dữ liệu lấy được vào biến
        _isLoading = false;   // Tắt vòng xoay tải
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Reader')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Nếu đang tải -> xoay vòng
          : _messages.isEmpty
              ? const Center(child: Text('Không có tin nhắn nào.'))
              : ListView.builder( // Vòng lặp in ra danh sách tin nhắn
                  itemCount: _messages.length, // Số lượng tin nhắn
                  itemBuilder: (context, index) {
                    SmsMessage message = _messages[index]; // Lấy tin nhắn thứ i
                    return ListTile(
                      title: Text(message.body ?? 'Không có nội dung'), // Nội dung tin nhắn
                      subtitle: Text('Từ: ${message.address ?? 'Không rõ'}'), // Số điện thoại gửi
                    );
                  },
                ),
    );
  }
}

// ========================================================
// MÀN HÌNH DANH SÁCH DANH BẠ (BÀI 3 & 5)
// ========================================================
class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});
  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  // Danh sách lưu dữ liệu những người trong danh bạ
  List<ContactInfo> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  // Hàm xin quyền đọc danh bạ
  Future<void> _initializePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [Permission.contacts].request();
    if (statuses[Permission.contacts]!.isGranted) {
      _loadContacts(); // Nếu có quyền -> Gọi hàm tải danh bạ
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng cấp quyền để đọc danh bạ!')));
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm móc dữ liệu danh bạ từ điện thoại ra
  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    // Dùng thư viện FlutterContactsService để lấy hết liên hệ
    List<ContactInfo> contacts = await FlutterContactsService.getContacts();
    if(mounted) {
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ'),
        actions: [
          // Nút dấu + trên thanh tiêu đề để thêm người mới
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Mở màn hình Thêm danh bạ. Dùng await để đợi khi nào màn hình kia đóng lại...
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddContactScreen()),
              );
              // ...thì lập tức load lại danh bạ để cập nhật số mới thêm
              _initializePermissions(); 
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? const Center(child: Text('Không có danh bạ nào.'))
              : ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    ContactInfo contact = _contacts[index];
                    return ListTile(
                      // Hiển thị ảnh đại diện (avatar), nếu null thì hiện icon hình người
                      leading: contact.avatar != null
                          ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar!))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(contact.displayName ?? 'Không có tên'),
                      // Lấy số điện thoại đầu tiên trong danh sách các số của người này
                      subtitle: Text(
                        (contact.phones != null && contact.phones!.isNotEmpty)
                            ? contact.phones!.first.value ?? 'Không có số'
                            : 'Không có số',
                      ),
                    );
                  },
                ),
    );
  }
}

// ========================================================
// MÀN HÌNH THÊM MỚI DANH BẠ
// ========================================================
class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});
  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  // Các bộ điều khiển để lấy chữ từ ô nhập liệu (TextField)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Lưu ảnh đại diện nếu có chọn
  File? _avatar;

  // Hàm chọn ảnh để làm avatar
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  // Hàm lưu thông tin vào danh bạ máy
  Future<void> _saveContact() async {
    // Ràng buộc: Không được để trống Tên và SĐT
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên và số điện thoại không được để trống!')),
      );
      return;
    }

    // Đóng gói thông tin thành 1 đối tượng ContactInfo theo chuẩn của thư viện
    final contact = ContactInfo(
      displayName: _nameController.text,
      phones: [ValueItem(label: 'mobile', value: _phoneController.text)],
      emails: [ValueItem(label: 'email', value: _emailController.text)],
      // Chuyển file ảnh thành dạng bytes (mã hóa) để lưu vào danh bạ
      avatar: _avatar != null ? await _avatar!.readAsBytes() : null,
    );

    try {
      // Thực hiện lưu vào danh bạ
      await FlutterContactsService.addContact(contact);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Danh bạ đã được lưu thành công!')));
        Navigator.pop(context); // Trở về màn hình trước
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi lưu danh bạ: \$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm danh bạ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery), // Bấm vào để chọn ảnh
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                  child: _avatar == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // Ô nhập tên
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              // Ô nhập số điện thoại
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone, // Mở bàn phím số
              ),
              // Ô nhập Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress, // Mở bàn phím có nút @
              ),
              const SizedBox(height: 16),
              // Nút Lưu
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
