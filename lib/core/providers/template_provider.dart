import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template_model.dart';
import '../services/supabase_service.dart';
import 'invitation_provider.dart';

final templatesProvider = FutureProvider<List<TemplateModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getTemplates();
});

final templateProvider = Provider.family<TemplateModel?, String>((ref, id) {
  final templates = ref.watch(templatesProvider).valueOrNull ?? [];
  try {
    return templates.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
});
