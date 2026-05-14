/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Application Form Screen
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/application_form_viewmodel.dart';
import '../models/application.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  String? _module1Level;
  String? _module1Name;
  String? _module2Level;
  String? _module2Name;
  bool _eligibilityConfirmed = false;
  ApplicationModel? _existingApplication;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ApplicationModel) {
      _existingApplication = args;
      _yearController.text = args.yearOfStudy.toString();
      _module1Level = args.module1Level;
      _module1Name = args.module1Name;
      _module2Level = args.module2Level;
      _module2Name = args.module2Name;
      _eligibilityConfirmed = args.eligibilityConfirmed;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ApplicationFormViewModel>().checkExistingApplication();
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplicationFormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingApplication != null ? 'Edit Application' : 'New Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Year of Study',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter current year (1-3)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final year = int.tryParse(value);
                  if (year == null || year < 1 || year > 3) {
                    return 'Enter valid year (1-3)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Module 1',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _module1Level,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Academic Level',
                ),
                items: viewModel.academicLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _module1Level = value;
                  });
                },
                validator: (value) => value == null ? 'Select level' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _module1Name,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Module',
                ),
                items: viewModel.modules
                    .map((module) => DropdownMenuItem(
                          value: module,
                          child: Text(module),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _module1Name = value;
                  });
                },
                validator: (value) => value == null ? 'Select module' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Module 2 (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _module2Level,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Academic Level',
                ),
                items: viewModel.academicLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _module2Level = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _module2Name,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Module',
                ),
                items: viewModel.modules
                    .map((module) => DropdownMenuItem(
                          value: module,
                          child: Text(module),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _module2Name = value;
                  });
                },
              ),
              if (_module2Level != null && _module2Name == null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Module name is required when level is selected',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text('I confirm that I meet the minimum requirements'),
                value: _eligibilityConfirmed,
                onChanged: (value) {
                  setState(() {
                    _eligibilityConfirmed = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: viewModel.pickDocument,
                icon: const Icon(Icons.upload_file),
                label: Text(viewModel.selectedFile != null
                    ? 'Document: ${viewModel.selectedFile!.name}'
                    : 'Upload Supporting Document'),
              ),
              const SizedBox(height: 24),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_existingApplication == null && viewModel.hasExistingApplication)
                        ? null
                        : _submit,
                    child: Text(_existingApplication != null ? 'Update' : 'Submit'),
                  ),
                ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_module2Level != null && _module2Name == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Module 2 name')),
      );
      return;
    }

    final viewModel = context.read<ApplicationFormViewModel>();
    final success = await viewModel.submitApplication(
      yearOfStudy: int.parse(_yearController.text),
      module1Level: _module1Level!,
      module1Name: _module1Name!,
      module2Level: _module2Level,
      module2Name: _module2Name,
      eligibilityConfirmed: _eligibilityConfirmed,
      existingId: _existingApplication?.id,
      existingDocumentUrl: _existingApplication?.documentUrl,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
