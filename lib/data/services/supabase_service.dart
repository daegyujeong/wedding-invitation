import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  static Future<SupabaseService> initialize() async {
    await Supabase.initialize(
      url: 'https://wunptgchvfnnglswmjmj.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind1bnB0Z2NodmZubmdsc3dtam1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNTkyMjIsImV4cCI6MjA2MDYzNTIyMn0.7xrvx35HL50xvtVExZq9QYiQOVquv1oWtkL2aLp-XvY',
    );

    return SupabaseService(Supabase.instance.client);
  }
}
