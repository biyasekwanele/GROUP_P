/**
 * Student Numbers: 221049921, 221050534, 222010648, 221014841
 * Student Names  : Kwanele Biyase, Motheo Sekgweleo, Thapelo Sikithi, Paki Gabriel Sekotlo
 * Question: Student Home Screen
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_home_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentHomeViewModel>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentHomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
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
      body: RefreshIndicator(
        onRefresh: () => viewModel.loadApplications(),
        child: _buildBody(viewModel),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.applications.isNotEmpty
            ? null
            : () async {
                await Navigator.pushNamed(context, '/application_form');
                if (mounted) {
                  viewModel.loadApplications();
                }
              },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(StudentHomeViewModel viewModel) {
    if (viewModel.isLoading && viewModel.applications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${viewModel.error}'),
            ),
          ),
        ],
      );
    }

    if (viewModel.applications.isEmpty) {
      return ListView(
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No applications submitted. Tap + to apply.'),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: viewModel.applications.length,
      itemBuilder: (context, index) {
        final app = viewModel.applications[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Application #${app.id.substring(0, 8)}'),
            subtitle: Text('Status: ${app.status.toUpperCase()}'),
            trailing: _getStatusIcon(app.status),
            onTap: () async {
              await Navigator.pushNamed(
                context,
                '/application_detail',
                arguments: app.id,
              );
              if (mounted) {
                viewModel.loadApplications();
              }
            },
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'pending':
      default:
        return const Icon(Icons.pending, color: Colors.orange);
    }
  }
}

