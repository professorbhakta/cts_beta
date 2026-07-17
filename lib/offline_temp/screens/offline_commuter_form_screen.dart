import 'package:cts/appManager/colors.dart';
import 'package:cts/offline_temp/models/offline_commuter.dart';
import 'package:cts/offline_temp/models/offline_pop.dart';
import 'package:cts/offline_temp/providers/offline_temp_provider.dart';
import 'package:cts/offline_temp/utils/offline_validators.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OfflineCommuterFormScreen extends StatefulWidget {
  const OfflineCommuterFormScreen({
    required this.batchId,
    required this.batchName,
    this.commuter,
    super.key,
  });

  final int batchId;
  final String batchName;
  final OfflineCommuter? commuter;

  bool get isEditing => commuter != null;

  @override
  State<OfflineCommuterFormScreen> createState() =>
      _OfflineCommuterFormScreenState();
}

class _OfflineCommuterFormScreenState extends State<OfflineCommuterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cabController;
  late final TextEditingController _mobileController;
  late bool _isComing;
  int? _selectedRouteId;
  int? _selectedPopId;

  @override
  void initState() {
    super.initState();
    final c = widget.commuter;
    _nameController = TextEditingController(text: c?.name ?? '');
    _cabController = TextEditingController(text: c?.cab ?? '');
    _mobileController = TextEditingController(text: c?.mobile ?? '');
    _isComing = c?.isComing ?? true;
    _selectedPopId = c?.popId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncRouteFromPop();
    });
  }

  void _syncRouteFromPop() {
    final popId = _selectedPopId;
    if (popId == null) return;
    final provider = context.read<OfflineTempProvider>();
    for (final pop in provider.pops) {
      if (pop.id == popId) {
        setState(() => _selectedRouteId = pop.routeId);
        return;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cabController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Consumer<OfflineTempProvider>(
      builder: (context, provider, _) {
        final routePops = _selectedRouteId == null
            ? <OfflinePop>[]
            : provider.popsForRoute(_selectedRouteId!);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.acBlack,
            title: Text(widget.isEditing ? 'Edit Commuter' : 'Add Commuter'),
            actions: [
              if (widget.isEditing)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: _delete,
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Batch: ${widget.batchName}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Local ID: #${widget.commuter!.displayId}',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (provider.routes.isEmpty)
                  Card(
                    color: AppColors.acOrangeSoft,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Add at least one Route and POP (Routes tab) before assigning location.',
                      ),
                    ),
                  ),
                if (provider.routes.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    key: ValueKey('route_$_selectedRouteId'),
                    initialValue: _selectedRouteId,
                    decoration: const InputDecoration(
                      labelText: 'Route',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.routes
                        .where((r) => r.id != null)
                        .map(
                          (route) => DropdownMenuItem(
                            value: route.id,
                            child: Text(route.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRouteId = value;
                        _selectedPopId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: ValueKey('pop_${_selectedRouteId}_$_selectedPopId'),
                    initialValue: _selectedPopId,
                    decoration: InputDecoration(
                      labelText: 'POP (Pick-up Point)',
                      border: const OutlineInputBorder(),
                      helperText: _selectedRouteId == null
                          ? 'Select a route first'
                          : null,
                    ),
                    items: routePops
                        .where((p) => p.id != null)
                        .map(
                          (pop) => DropdownMenuItem(
                            value: pop.id,
                            child: Text(pop.name),
                          ),
                        )
                        .toList(),
                    onChanged: _selectedRouteId == null
                        ? null
                        : (value) => setState(() => _selectedPopId = value),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: OfflineValidators.commuterName,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cabController,
                  decoration: const InputDecoration(
                    labelText: 'Cab number',
                    border: OutlineInputBorder(),
                    helperText: 'Optional — numbers only',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: OfflineValidators.optionalCab,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    border: OutlineInputBorder(),
                    helperText: 'Optional — 10 digits',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: OfflineValidators.optionalMobile,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Is coming'),
                  subtitle: const Text('Attendance / pickup status'),
                  value: _isComing,
                  onChanged: (value) => setState(() => _isComing = value),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(widget.isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final commuter = OfflineCommuter(
      id: widget.commuter?.id,
      batchId: widget.batchId,
      popId: _selectedPopId,
      name: _nameController.text.trim(),
      cab: _cabController.text.trim(),
      mobile: _mobileController.text.trim(),
      isComing: _isComing,
      createdAt: widget.commuter?.createdAt ?? DateTime.now(),
    );

    final error = await context.read<OfflineTempProvider>().saveCommuter(commuter);
    if (!mounted) return;

    if (error == null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _delete() async {
    final id = widget.commuter?.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Delete commuter?',
        message: 'Remove ${widget.commuter!.name} (#$id)?',
        confirmLabel: 'Delete',
        confirmColor: AppColors.acRed,
        icon: Icons.delete_outline,
        iconColor: AppColors.acRed,
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<OfflineTempProvider>().deleteCommuter(id);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
