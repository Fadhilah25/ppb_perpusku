import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/member.dart';
import '../../providers/member_provider.dart';

class AddEditMemberScreen extends StatefulWidget {
  final Member? member;

  const AddEditMemberScreen({super.key, this.member});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _memberIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _photoPath;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.member!.name;
      _memberIdController.text = widget.member!.memberId;
      _phoneController.text = widget.member!.phone ?? '';
      _emailController.text = widget.member!.email ?? '';
      _photoPath = widget.member!.photo;
    } else {
      // Generate new member ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<MemberProvider>();
        _memberIdController.text = provider.generateMemberId();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memberIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final member = Member(
      id: widget.member?.id,
      name: _nameController.text.trim(),
      memberId: _memberIdController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      photo: _photoPath,
      createdAt: widget.member?.createdAt,
    );

    try {
      if (isEditing) {
        await context.read<MemberProvider>().updateMember(member);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anggota berhasil diperbarui')),
          );
        }
      } else {
        await context.read<MemberProvider>().addMember(member);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anggota berhasil ditambahkan')),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Anggota' : 'Tambah Anggota'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveMember),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _memberIdController,
              decoration: const InputDecoration(
                labelText: 'ID Anggota *',
                prefixIcon: Icon(Icons.badge),
              ),
              enabled: !isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ID Anggota harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveMember,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Perbarui Anggota' : 'Simpan Anggota'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        const Text(
          'Foto Anggota',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: _showImageSourceDialog,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[300],
              child: _photoPath != null
                  ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                  : Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
            ),
          ),
        ),
        if (_photoPath != null)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _photoPath = null;
              });
            },
            icon: const Icon(Icons.delete),
            label: const Text('Hapus Foto'),
          ),
      ],
    );
  }
}
