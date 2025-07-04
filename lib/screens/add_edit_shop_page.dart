// lib/screens/add_edit_shop_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../models/shop_item.dart';

class AddEditShopPage extends StatefulWidget {
  final String? existingItemId;

  const AddEditShopPage({super.key, this.existingItemId});

  @override
  State<AddEditShopPage> createState() => _AddEditShopPageState();
}

class _AddEditShopPageState extends State<AddEditShopPage> {
  final _formKey = GlobalKey<FormState>();
  var _editedShopItem = ShopItem(id: '', name: '');
  var _isInit = true;
  var _isLoading = false;
  XFile? _pickedImageFile;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.existingItemId != null) {
        final existingItem = Provider.of<ShopProvider>(context, listen: false)
            .findById(widget.existingItemId!);
        if (existingItem != null) {
          _editedShopItem = existingItem;
          _nameController.text = _editedShopItem.name;
          _addressController.text = _editedShopItem.address ?? '';
          if (_editedShopItem.localImagePath != null &&
              _editedShopItem.localImagePath!.isNotEmpty) {
            _pickedImageFile = XFile(_editedShopItem.localImagePath!);
          }
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImageFile = pickedFile;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Resim seçme hatası: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim seçilemedi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() { _isLoading = true; });

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    final name = _nameController.text;
    final address = _addressController.text.isEmpty ? null : _addressController.text;
    final String? imagePath = _pickedImageFile?.path;

    try {
      if (widget.existingItemId != null && _editedShopItem.id.isNotEmpty) {
        shopProvider.updateItem(
          id: _editedShopItem.id,
          name: name,
          address: address,
          localImagePath: imagePath,
          latitude: _editedShopItem.latitude,
          longitude: _editedShopItem.longitude,
        );
      } else {
        shopProvider.addItem(
          name: name,
          address: address,
          localImagePath: imagePath,
          latitude: _editedShopItem.latitude,
          longitude: _editedShopItem.longitude,
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Dükkan kaydetme hatası: $error');
      }
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hata Oluştu!'),
            content: Text('Dükkan kaydedilirken bir sorun oluştu: ${error.toString()}'),
            actions: [TextButton(child: const Text('Tamam'), onPressed: () => Navigator.of(ctx).pop())],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
        Navigator.of(context).pop();
      }
    }
  }

  void _openMapPicker() async {
    // TODO: Harita seçici
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Haritadan konum seçme özelliği yakında!')),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImageFile == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 45, color: Colors.grey[700]),
          const SizedBox(height: 8),
          Text('Dükkan Resmi Seç', style: TextStyle(color: Colors.grey[800], fontSize: 13)),
        ],
      );
    }
    if (kIsWeb) {
      return Image.network(_pickedImageFile!.path, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))
      );
    } else {
      return Image.file(File(_pickedImageFile!.path), fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingItemId == null ? 'Yeni Dükkan Ekle' : 'Dükkanı Düzenle'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: _isLoading ? null : _saveForm,
            tooltip: 'Kaydet',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 130,
                          height: 130,
                          margin: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.5),
                            child: _buildImagePreview(),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Dükkan Adı (*)', border: OutlineInputBorder()),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.isEmpty) ? 'Dükkan adı zorunludur.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Dükkan Adresi',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map_outlined),
                          tooltip: 'Haritadan Seç',
                          onPressed: _openMapPicker,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                      minLines: 1,
                    ),
                    // Dükkana özel ek alanlar (telefon, çalışma saatleri vb.) buraya eklenebilir
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Dükkanı Kaydet'),
                      onPressed: _isLoading ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}