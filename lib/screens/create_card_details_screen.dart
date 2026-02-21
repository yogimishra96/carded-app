import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
import '../services/cards_service.dart';
import '../widgets/app_widgets.dart';

class CreateCardDetailsScreen extends StatefulWidget {
  const CreateCardDetailsScreen({super.key});
  @override
  State<CreateCardDetailsScreen> createState() => _CreateCardDetailsScreenState();
}

class _CreateCardDetailsScreenState extends State<CreateCardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  int _templateIndex = 0;
  VisitingCard? _editingCard;
  bool _initialized = false;

  // Photo
  File? _pickedPhoto;
  String? _existingPhotoUrl;
  bool _uploadingPhoto = false;

  final _nameCtrl        = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _companyCtrl     = TextEditingController();
  final _email1Ctrl      = TextEditingController();
  final _email2Ctrl      = TextEditingController();
  final _phone1Ctrl      = TextEditingController();
  final _phone2Ctrl      = TextEditingController();
  final _websiteCtrl     = TextEditingController();
  final _addressCtrl     = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is VisitingCard) {
      _editingCard         = args;
      _templateIndex       = args.templateIndex;
      _nameCtrl.text       = args.name;
      _designationCtrl.text = args.designation;
      _companyCtrl.text    = args.company;
      _email1Ctrl.text     = args.email1;
      _email2Ctrl.text     = args.email2;
      _phone1Ctrl.text     = args.phone1;
      _phone2Ctrl.text     = args.phone2;
      _websiteCtrl.text    = args.website;
      _addressCtrl.text    = args.address;
      _existingPhotoUrl    = args.photoUrl;
    } else if (args is int) {
      _templateIndex = args;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _designationCtrl.dispose(); _companyCtrl.dispose();
    _email1Ctrl.dispose(); _email2Ctrl.dispose(); _phone1Ctrl.dispose();
    _phone2Ctrl.dispose(); _websiteCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }

  // ── Photo picker ────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        ListTile(leading: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
          title: const Text('Take Photo'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library_outlined, color: AppColors.accent),
          title: const Text('Choose from Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        if (_pickedPhoto != null || _existingPhotoUrl != null)
          ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
            onTap: () { setState(() { _pickedPhoto = null; _existingPhotoUrl = null; }); Navigator.pop(ctx); }),
        const SizedBox(height: 8),
      ])),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final xFile  = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (xFile != null) setState(() => _pickedPhoto = File(xFile.path));
  }

  // ── Build card from form ─────────────────────────────────────
  VisitingCard _buildCard() {
    final id = _editingCard?.id ?? const Uuid().v4();
    return VisitingCard(
      id:            id,
      nickname:      _editingCard?.nickname ?? _nameCtrl.text.trim(),
      name:          _nameCtrl.text.trim(),
      designation:   _designationCtrl.text.trim(),
      company:       _companyCtrl.text.trim(),
      email1:        _email1Ctrl.text.trim(),
      email2:        _email2Ctrl.text.trim(),
      phone1:        _phone1Ctrl.text.trim(),
      phone2:        _phone2Ctrl.text.trim(),
      website:       _websiteCtrl.text.trim(),
      address:       _addressCtrl.text.trim(),
      templateIndex: _templateIndex,
      photoUrl:      _existingPhotoUrl,
      photoPath:     _pickedPhoto?.path,
      createdAt:     _editingCard?.createdAt ?? DateTime.now(),
    );
  }

  Future<void> _preview() async {
    if (!_formKey.currentState!.validate()) return;
    var card = _buildCard();

    // Upload photo first if a new one is picked
    if (_pickedPhoto != null) {
      setState(() => _uploadingPhoto = true);
      final url = await CardsService.instance.uploadPhoto(card.id, _pickedPhoto!);
      setState(() => _uploadingPhoto = false);
      if (url != null) {
        _existingPhotoUrl = url;
        card = card.copyWith(photoUrl: url);
      }
    }

    if (!mounted) return;
    Navigator.pushNamed(context, '/card-preview', arguments: {'card': card, 'isView': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
        title: Text(_editingCard != null ? 'Edit Card' : 'Card Details'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Photo upload section ──────────────────────────
            const Text('PROFILE PHOTO', style: AppTextStyles.label),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)]),
                child: Row(children: [
                  // Preview circle
                  Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentLight, border: Border.all(color: AppColors.border, width: 1.5)),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedPhoto != null
                        ? Image.file(_pickedPhoto!, fit: BoxFit.cover)
                        : _existingPhotoUrl != null
                            ? Image.network(_existingPhotoUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.person_outline, size: 28, color: AppColors.textHint))
                            : const Icon(Icons.person_outline, size: 28, color: AppColors.textHint)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_pickedPhoto != null || _existingPhotoUrl != null ? 'Photo Selected' : 'Add Profile Photo',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(_pickedPhoto != null || _existingPhotoUrl != null ? 'Tap to change or remove' : 'Camera or Gallery • Optional',
                      style: AppTextStyles.bodySecondary),
                  ])),
                  if (_uploadingPhoto)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                  else
                    const Icon(Icons.camera_alt_outlined, color: AppColors.accent, size: 20),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // ── Personal Info ─────────────────────────────────
            const SectionHeader(title: 'Personal Info'),
            const SizedBox(height: 16),
            AppTextField(label: 'Full Name *', hint: 'e.g. Yogesh Sharma', controller: _nameCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            AppTextField(label: 'Designation *', hint: 'e.g. Senior Product Designer', controller: _designationCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            AppTextField(label: 'Company *', hint: 'e.g. Creative Labs Jaipur', controller: _companyCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),

            const SizedBox(height: 24),

            // ── Contact Info ──────────────────────────────────
            const SectionHeader(title: 'Contact Info'),
            const SizedBox(height: 16),
            AppTextField(label: 'Primary Email *', hint: 'you@company.com', controller: _email1Ctrl,
              keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            AppTextField(label: 'Secondary Email', hint: 'Optional', controller: _email2Ctrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            AppTextField(label: 'Primary Phone *', hint: '+91 98765 43210', controller: _phone1Ctrl,
              keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            AppTextField(label: 'Secondary Phone', hint: 'Optional', controller: _phone2Ctrl, keyboardType: TextInputType.phone),

            const SizedBox(height: 24),

            // ── Online Presence ───────────────────────────────
            const SectionHeader(title: 'Online Presence'),
            const SizedBox(height: 16),
            AppTextField(label: 'Website', hint: 'https://yourwebsite.com', controller: _websiteCtrl, keyboardType: TextInputType.url),
            const SizedBox(height: 14),
            AppTextField(label: 'Address', hint: 'City, State', controller: _addressCtrl),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _uploadingPhoto ? null : _preview,
              child: _uploadingPhoto
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Preview Card →'),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}