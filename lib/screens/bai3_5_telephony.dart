import 'dart:io';
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmsReaderScreen()),
              );
            },
            child: const Text('Đọc tin nhắn SMS (Bài 3)'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactsListScreen()),
              );
            },
            child: const Text('Danh bạ điện thoại (Bài 3 & 5)'),
          ),
        ],
      ),
    );
  }
}

class SmsReaderScreen extends StatefulWidget {
  const SmsReaderScreen({super.key});
  @override
  State<SmsReaderScreen> createState() => _SmsReaderScreenState();
}

class _SmsReaderScreenState extends State<SmsReaderScreen> {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.sms, Permission.phone].request();
    if (statuses[Permission.sms]!.isGranted) {
      _loadMessages();
    } else {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng cấp quyền đọc tin nhắn SMS!')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE, SmsColumn.TYPE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );
    if(mounted) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Reader')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? const Center(child: Text('Không có tin nhắn nào.'))
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    SmsMessage message = _messages[index];
                    return ListTile(
                      title: Text(message.body ?? 'Không có nội dung'),
                      subtitle: Text('Từ: ${message.address ?? 'Không rõ'}'),
                    );
                  },
                ),
    );
  }
}

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});
  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  List<ContactInfo> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.contacts].request();
    if (statuses[Permission.contacts]!.isGranted) {
      _loadContacts();
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng cấp quyền để đọc danh bạ!')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddContactScreen()),
              );
              _initializePermissions(); // Refresh
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
                      leading: contact.avatar != null
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contact.avatar!),
                            )
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(contact.displayName ?? 'Không có tên'),
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

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});
  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _avatar;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveContact() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên và số điện thoại không được để trống!')),
      );
      return;
    }

    final contact = ContactInfo(
      displayName: _nameController.text,
      phones: [ValueItem(label: 'mobile', value: _phoneController.text)],
      emails: [ValueItem(label: 'email', value: _emailController.text)],
      avatar: _avatar != null ? await _avatar!.readAsBytes() : null,
    );

    try {
      await FlutterContactsService.addContact(contact);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Danh bạ đã được lưu thành công!')));
        Navigator.pop(context);
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
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                  child: _avatar == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
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
