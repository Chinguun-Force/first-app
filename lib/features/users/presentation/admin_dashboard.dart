import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // We actually need uuid package for generating IDs if not using Auth
import '../../users/data/user_repository.dart';
import '../../auth/domain/app_user.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search users...',
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(context),
        child: const Icon(Icons.add),
      ),
      body: usersAsync.when(
        data: (users) {
          final filtered = users.where((u) {
            final q = _searchQuery.toLowerCase();
            return u.email.toLowerCase().contains(q) ||
                u.displayName.toLowerCase().contains(q);
          }).toList();

          if (filtered.isEmpty)
            return const Center(child: Text('No users found.'));

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final user = filtered[index];
              return ListTile(
                title: Text(
                  user.displayName,
                  style: TextStyle(
                    decoration: user.isActive
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                ),
                subtitle: Text('${user.email} • ${user.role}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showUserDialog(context, user: user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, user),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to soft-delete ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(userRepositoryProvider).softDeleteUser(user.uid);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, {AppUser? user}) {
    showDialog(
      context: context,
      builder: (context) => UserDialog(user: user),
    );
  }
}

class UserDialog extends ConsumerStatefulWidget {
  final AppUser? user;
  const UserDialog({super.key, this.user});

  @override
  ConsumerState<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends ConsumerState<UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailCtrl;
  late TextEditingController _nameCtrl;
  String _role = 'user';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _nameCtrl = TextEditingController(text: widget.user?.displayName ?? '');
    _role = widget.user?.role ?? 'user';
    _isActive = widget.user?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit User' : 'Add User Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing)
                const Text(
                  'Note: This only creates a Firestore profile. The user must register with this email to sign in.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                enabled:
                    !isEditing, // Email usually immutable as it's the ID link
              ),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v!),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              CheckboxListTile(
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final repo = ref.read(userRepositoryProvider);
              final uid =
                  widget.user?.uid ??
                  const Uuid().v4(); // Generate mock UID for new profile

              final newUser = AppUser(
                uid: uid,
                email: _emailCtrl.text.trim(),
                displayName: _nameCtrl.text.trim(),
                role: _role,
                isActive: _isActive,
                createdAt: widget.user?.createdAt ?? DateTime.now(),
              );

              if (isEditing) {
                await repo.updateUser(newUser);
              } else {
                await repo.createUserProfile(newUser);
              }
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
