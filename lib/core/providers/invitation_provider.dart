import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invitation_model.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final myInvitationsProvider = FutureProvider<List<InvitationModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getMyInvitations();
});

final invitationProvider = FutureProvider.family<InvitationModel?, String>((ref, id) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getInvitation(id);
});

final createInvitationProvider = FutureProvider.family<InvitationModel, InvitationModel>(
  (ref, invitation) async {
    final service = ref.watch(supabaseServiceProvider);
    final created = await service.createInvitation(invitation);
    ref.invalidate(myInvitationsProvider);
    return created;
  },
);

final updateInvitationProvider = FutureProvider.family<InvitationModel, InvitationModel>(
  (ref, invitation) async {
    final service = ref.watch(supabaseServiceProvider);
    final updated = await service.updateInvitation(invitation);
    ref.invalidate(myInvitationsProvider);
    ref.invalidate(invitationProvider(invitation.id));
    return updated;
  },
);

final deleteInvitationProvider = FutureProvider.family<void, String>(
  (ref, id) async {
    final service = ref.watch(supabaseServiceProvider);
    await service.deleteInvitation(id);
    ref.invalidate(myInvitationsProvider);
  },
);
