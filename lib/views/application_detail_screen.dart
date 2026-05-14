/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Application Detail Screen
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/application_detail_viewmodel.dart';

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({super.key});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final applicationId = ModalRoute.of(context)?.settings.arguments as String?;
    if (applicationId != null) {
      context.read<ApplicationDetailViewModel>().loadApplication(applicationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          Consumer<ApplicationDetailViewModel>(
            builder: (context, viewModel, child) {
              if (!viewModel.canEdit) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  if (viewModel.application != null) {
                    Navigator.pushNamed(
                      context,
                      '/application_form',
                      arguments: viewModel.application,
                    ).then((_) => viewModel.loadApplication(viewModel.application!.id));
                  }
                },
              );
            },
          ),
          Consumer<ApplicationDetailViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, viewModel),
              );
            },
          ),
        ],
      ),
      body: Consumer<ApplicationDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          final app = viewModel.application;
          if (app == null) {
            return const Center(child: Text('Application not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Application ID', app.id),
                _buildDetailRow('Year of Study', app.yearOfStudy.toString()),
                _buildDetailRow('Module 1', '${app.module1Level} - ${app.module1Name}'),
                if (app.module2Level != null && app.module2Name != null)
                  _buildDetailRow('Module 2', '${app.module2Level} - ${app.module2Name}'),
                _buildDetailRow('Eligibility Confirmed', app.eligibilityConfirmed ? 'Yes' : 'No'),
                _buildDetailRow('Status', app.status.toUpperCase()),
                if (app.documentUrl != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Supporting Document:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(app.documentUrl!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ApplicationDetailViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text('Are you sure you want to delete this application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && viewModel.application != null) {
      final success = await viewModel.deleteApplication(viewModel.application!.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }
}