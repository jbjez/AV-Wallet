class SupabaseEnv {
  // Clés Supabase configurées
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sjwaoemczpzwlijljozk.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqd2FvZW1jenB6d2xpamxqb3prIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5MjYxMjksImV4cCI6MjA3MjUwMjEyOX0.xWAwKbAcsKQviBz31HmcCRY5XhT1WPy9tIAliyqqMlg',
  );
  
  // Méthode pour vérifier si les clés sont configurées
  static bool get isConfigured => 
      supabaseUrl.contains('sjwaoemczpzwlijljozk') && 
      supabaseAnonKey.contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
}