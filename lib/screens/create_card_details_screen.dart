import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/visiting_card.dart';
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

  final _nameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _email1Ctrl = TextEditingController();
  final _email2Ctrl = TextEditingController();
  final _phone1Ctrl = TextEditingController();
  final _phone2Ctrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is VisitingCard) {
      _editingCard = args;
      _templateIndex = args.templateIndex;
      _nameCtrl.text = args.name;
      _designationCtrl.text = args.designation;
      _companyCtrl.text = args.company;
      _email1Ctrl.text = args.email1;
      _email2Ctrl.text = args.email2;
      _phone1Ctrl.text = args.phone1;
      _phone2Ctrl.text = args.phone2;
      _websiteCtrl.text = args.website;
      _addressCtrl.text = args.address;
    } else if (args is int) {
      _templateIndex = args;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    _companyCtrl.dispose();
    _email1Ctrl.dispose();
    _email2Ctrl.dispose();
    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    _websiteCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _previewCard() {
    if (!_formKey.currentState!.validate()) return;
    final card = (_editingCard ?? VisitingCard(
      id: const Uuid().v4(),
      nickname: '',
      name: '',
      designation: '',
      company: '',
      email1: '',
      phone1: '',
      createdAt: DateTime.now(),
    )).copyWith(
      name: _nameCtrl.text.trim(),
      designation: _designationCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      email1: _email1Ctrl.text.trim(),
      email2: _email2Ctrl.text.trim(),
      phone1: _phone1Ctrl.text.trim(),
      phone2: _phone2Ctrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      templateIndex: _templateIndex,
    );

    final finalCard = _editingCard != null
        ? card
        : VisitingCard(
            id: const Uuid().v4(),
            nickname: '',
            name: card.name,
            designation: card.designation,
            company: card.company,
            email1: card.email1,
            email2: card.email2,
            phone1: card.phone1,
            phone2: card.phone2,
            website: card.website,
            address: card.address,
            templateIndex: _templateIndex,
            createdAt: DateTime.now(),
          );

    Navigator.pushNamed(context, '/card-preview', arguments: {'card': finalCard, 'isView': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_editingCard != null ? 'Edit Card' : 'Card Details'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personal Info', style: AppTextStyles.label),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Full Name *',
                hint: 'e.g. John Doe',
                controller: _nameCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Designation *',
                hint: 'e.g. Senior Product Manager',
                controller: _designationCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Designation is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Company Name *',
                hint: 'e.g. Acme Corp',
                controller: _companyCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Company is required' : null,
              ),
              const SizedBox(height: 24),
              const Text('Contact Info', style: AppTextStyles.label),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email 1 *',
                hint: 'work@company.com',
                controller: _email1Ctrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email 2',
                hint: 'personal@email.com (optional)',
                controller: _email2Ctrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Phone 1 *',
                hint: '+91 98765 43210',
                controller: _phone1Ctrl,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Phone is required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Phone 2',
                hint: '+91 98765 43211 (optional)',
                controller: _phone2Ctrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text('Online Presence', style: AppTextStyles.label),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Website',
                hint: 'https://yoursite.com',
                controller: _websiteCtrl,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Address',
                hint: '123 Business Park, City, State',
                controller: _addressCtrl,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _previewCard,
                child: const Text('Preview Card'),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
