import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movdiary/providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  String selectedLanguage = 'Türkçe';

  Future<void> _showEditUsernameDialog(AppProvider provider) async {
    final controller = TextEditingController(text: provider.username);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kullanıcı Adını Düzenle'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Yeni Kullanıcı Adı',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kullanıcı adı boş olamaz')),
                );
                return;
              }
              
              await provider.updateUsername(controller.text.trim());
              Navigator.pop(context);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kullanıcı adı güncellendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Hesap Bilgileri
          Card(
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.purple),
              title: Text('Hesap'),
              subtitle: Text('Profil ve hesap ayarları'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Hesap Bilgileri'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('Kullanıcı: ${provider.username}')),
                            IconButton(
                              icon: Icon(Icons.edit, size: 20, color: Colors.purple),
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditUsernameDialog(provider);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Email: ${provider.currentUser?.email ?? "Bilinmiyor"}'),
                        SizedBox(height: 8),
                        Text('Üyelik: ${provider.isAuthenticated ? "Aktif" : "Misafir"}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Kapat'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 8),
          
          // Karanlık Tema
          Card(
            child: SwitchListTile(
              secondary: Icon(Icons.palette, color: Colors.purple),
              title: Text('Karanlık Tema'),
              subtitle: Text(provider.isDarkMode ? 'Karanlık mod aktif' : 'Aydınlık mod aktif'),
              value: provider.isDarkMode,
              onChanged: (value) {
                provider.toggleTheme(value);
              },
            ),
          ),
          
          SizedBox(height: 8),
          
          // Bildirimler
          Card(
            child: SwitchListTile(
              secondary: Icon(Icons.notifications, color: Colors.purple),
              title: Text('Bildirimler'),
              subtitle: Text('Yeni paylaşımlar ve güncellemeler'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() => notificationsEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? 'Bildirimler açıldı' : 'Bildirimler kapatıldı'),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 8),
          
          // Dil
          Card(
            child: ListTile(
              leading: Icon(Icons.language, color: Colors.purple),
              title: Text('Dil'),
              subtitle: Text(selectedLanguage),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Dil Seçin'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: Text('Türkçe'),
                          value: 'Türkçe',
                          groupValue: selectedLanguage,
                          onChanged: (value) {
                            setState(() => selectedLanguage = value!);
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('English'),
                          value: 'English',
                          groupValue: selectedLanguage,
                          onChanged: (value) {
                            setState(() => selectedLanguage = value!);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 8),
          
          // Gizlilik
          Card(
            child: ListTile(
              leading: Icon(Icons.lock, color: Colors.purple),
              title: Text('Gizlilik'),
              subtitle: Text('Gizlilik ve güvenlik ayarları'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Gizlilik Ayarları'),
                    content: Text('Gizlilik politikası ve veri güvenliği ayarları burada görüntülenecek.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Kapat'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 8),
          
          // Hakkımızda
          Card(
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.purple),
              title: Text('Hakkımızda'),
              subtitle: Text('Versiyon 1.0.0'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Movie Diary'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Versiyon: 1.0.0'),
                        SizedBox(height: 8),
                        Text('Film severlerin buluşma noktası'),
                        SizedBox(height: 8),
                        Text('© 2024 Movie Diary'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Kapat'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 16),
          
          // Çıkış Yap
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Çıkış Yap'),
                    content: Text('Çıkış yapmak istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await provider.signOut();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}