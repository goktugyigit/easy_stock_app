// lib/screens/add_edit_warehouse_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';
import '../models/warehouse_item.dart';
import '../widgets/corporate_header.dart';
// import '../widgets/map_picker_page.dart'; // Harita için ileride eklenecek

class AddEditWarehousePage extends StatefulWidget {
  final String? existingItemId;

  const AddEditWarehousePage({super.key, this.existingItemId});

  @override
  State<AddEditWarehousePage> createState() => _AddEditWarehousePageState();
}

class _AddEditWarehousePageState extends State<AddEditWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  var _editedWarehouseItem =
      WarehouseItem(id: '', name: ''); // Varsayılan değerler
  var _isInit = true;
  var _isLoading = false;
  XFile? _pickedImageFile;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  // Latitude ve Longitude için controller'lar veya direkt değişkenler tutulabilir
  // Şimdilik _editedWarehouseItem üzerinden yönetilecekler.

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.existingItemId != null) {
        final existingItem =
            Provider.of<WarehouseProvider>(context, listen: false)
                .findById(widget.existingItemId!);
        if (existingItem != null) {
          _editedWarehouseItem = existingItem;
          _nameController.text = _editedWarehouseItem.name;
          _addressController.text = _editedWarehouseItem.address ?? '';
          if (_editedWarehouseItem.localImagePath != null &&
              _editedWarehouseItem.localImagePath!.isNotEmpty) {
            _pickedImageFile = XFile(_editedWarehouseItem.localImagePath!);
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
    _formKey.currentState!
        .save(); // onSaved'ları tetikler (şu an kullanmıyoruz ama iyi pratik)
    setState(() {
      _isLoading = true;
    });

    final warehouseProvider =
        Provider.of<WarehouseProvider>(context, listen: false);

    final name = _nameController.text;
    final address =
        _addressController.text.isEmpty ? null : _addressController.text;
    final String? imagePath = _pickedImageFile?.path;
    // Latitude ve longitude, haritadan seçme sonrası _editedWarehouseItem'a atanmış olacak
    // veya başlangıçta null olacaklar.

    try {
      if (widget.existingItemId != null && _editedWarehouseItem.id.isNotEmpty) {
        warehouseProvider.updateItem(
          id: _editedWarehouseItem.id,
          name: name,
          address: address,
          localImagePath: imagePath,
          latitude: _editedWarehouseItem.latitude, // Haritadan geldiyse
          longitude: _editedWarehouseItem.longitude, // Haritadan geldiyse
        );
      } else {
        warehouseProvider.addItem(
          name: name,
          address: address,
          localImagePath: imagePath,
          latitude: _editedWarehouseItem.latitude,
          longitude: _editedWarehouseItem.longitude,
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Depo kaydetme hatası: $error');
      }
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hata Oluştu!'),
            content: Text(
                'Depo kaydedilirken bir sorun oluştu: ${error.toString()}'),
            actions: [
              TextButton(
                  child: const Text('Tamam'),
                  onPressed: () => Navigator.of(ctx).pop())
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(); // Sayfayı kapat
      }
    }
  }

  void _openMapPicker() async {
    // TODO: Harita seçici sayfasını aç ve sonucu al.
    // final result = await Navigator.of(context).push<MapPickerResult>(
    //   MaterialPageRoute(builder: (ctx) => const MapPickerPage()),
    // );
    // if (result != null && mounted) {
    //   setState(() {
    //     _addressController.text = result.address ?? _addressController.text;
    //     _editedWarehouseItem.latitude = result.latitude;
    //     _editedWarehouseItem.longitude = result.longitude;
    //   });
    // }
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
          Text('Depo Resmi Seç',
              style: TextStyle(color: Colors.grey[800], fontSize: 13)),
        ],
      );
    }
    if (kIsWeb) {
      return Image.network(_pickedImageFile!.path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey)));
    } else {
      return Image.file(File(_pickedImageFile!.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CorporateHeader(
        title:
            widget.existingItemId == null ? 'Yeni Depo Ekle' : 'Depoyu Düzenle',
        showBackButton: true,
        showSaveButton: true,
        centerTitle: true,
        onSavePressed: _isLoading ? null : _saveForm,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                16.0 +
                    MediaQuery.of(context).padding.bottom +
                    MediaQuery.of(context).viewInsets.bottom,
              ),
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
                          margin:
                              const EdgeInsets.only(bottom: 20.0, top: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 1.5),
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
                      decoration: const InputDecoration(
                          labelText: 'Depo Adı (*)',
                          border: OutlineInputBorder()),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Depo adı zorunludur.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Depo Adresi',
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
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
    );
  }
}
