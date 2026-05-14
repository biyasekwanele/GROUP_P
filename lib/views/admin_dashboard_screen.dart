/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Admin Dashboard Screen
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardViewModel>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<AdminDashboardViewModel>(
              builder: (context, viewModel, child) {
                return DropdownButton<String>(
                  value: viewModel.filterStatus,
                  isExpanded: true,
                  items: ['All', 'Pending', 'Approved', 'Rejected']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setFilter(value);
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<AdminDashboardViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.error != null) {
                  return Center(child: Text('Error: ${viewModel.error}'));
                }

                if (viewModel.applications.isEmpty) {
                  return const Center(child: Text('No applications found'));
                }

                return ListView.builder(
                  itemCount: viewModel.applications.length,
                  itemBuilder: (context, index) {
                    final app = viewModel.applications[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text('Student: ${app.studentId.substring(0, 8)}'),
                        subtitle: Text('Status: ${app.status.toUpperCase()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (app.status == 'pending') ...[
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => viewModel.updateStatus(app.id, 'approved'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => viewModel.updateStatus(app.id, 'rejected'),
                              ),
                            ],
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => _showDeleteConfirmation(context, viewModel, app.id),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Year: ${app.yearOfStudy}'),
                                Text('Module 1: ${app.module1Level} - ${app.module1Name}'),
                                if (app.module2Level != null && app.module2Name != null)
                                  Text('Module 2: ${app.module2Level} - ${app.module2Name}'),
                                Text('Eligibility: ${app.eligibilityConfirmed ? 'Yes' : 'No'}'),
                                if (app.documentUrl != null) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Document:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(app.documentUrl!),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, AdminDashboardViewModel viewModel, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text('Are you sure you want to delete this invalid application?'),
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

    if (confirmed == true) {
      await viewModel.deleteApplication(id);
    }
  }
}
