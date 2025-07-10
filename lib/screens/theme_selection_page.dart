import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  State<ThemeSelectionPage> createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  Future<void> _updateTheme(String newTheme) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.setTheme(newTheme);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Tema ayarı kaydedildi: ${_getThemeDisplayName(newTheme)}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getThemeDisplayName(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Açık Tema';
      case 'dark':
        return 'Koyu Tema';
      case 'system':
        return 'Sistem Teması';
      default:
        return 'Sistem Teması';
    }
  }

  Widget _buildThemeOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 8.0 : 2.0,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.grey[300]!,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _updateTheme(value),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? color
                            : Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentTheme = themeProvider.currentThemeString;

        return Scaffold(
          appBar: AppBar(
            title: Text('Tema Seçimi'),
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Uygulamanın görünümünü kişiselleştirin',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),
                _buildThemeOption(
                  value: 'light',
                  title: 'Açık Tema',
                  subtitle: 'Beyaz arka plan ve koyu metin kullanır',
                  icon: Icons.light_mode,
                  color: Colors.orange,
                  isSelected: currentTheme == 'light',
                ),
                _buildThemeOption(
                  value: 'dark',
                  title: 'Koyu Tema',
                  subtitle: 'Siyah arka plan ve açık metin kullanır',
                  icon: Icons.dark_mode,
                  color: Colors.indigo,
                  isSelected: currentTheme == 'dark',
                ),
                _buildThemeOption(
                  value: 'system',
                  title: 'Sistem Teması',
                  subtitle: 'Cihazınızın ayarlarını otomatik takip eder',
                  icon: Icons.brightness_auto,
                  color: Colors.teal,
                  isSelected: currentTheme == 'system',
                ),
                SizedBox(height: 40),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tema değişiklikleri anında uygulanır. Sistem teması cihazınızın gece modu ayarını takip eder.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
