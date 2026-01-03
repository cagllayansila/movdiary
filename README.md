# 🎬 Movie Diary

Film severlerin buluşma noktası! Movie Diary, izlediğiniz filmleri kaydetmenizi, puanlamanızı ve diğer film tutkunlarıyla deneyimlerinizi paylaşmanızı sağlayan bir mobil uygulamadır.

## ✨ Özellikler

- **🔐 Kullanıcı Kimlik Doğrulama**: Firebase Authentication ile güvenli giriş ve kayıt
- **🎥 Film Arama**: TMDB API entegrasyonu ile geniş film veritabanı
- **⭐ Puanlama Sistemi**: Filmlere 1-5 yıldız arası puan verin
- **📝 Yorum Paylaşımı**: Film hakkındaki düşüncelerinizi paylaşın
- **📷 Fotoğraf Ekleme**: Gönderilerinize fotoğraf ekleyin
- **❤️ Favori Filmler**: Beğendiğiniz filmleri favorilere ekleyin
- **🔍 Keşfet**: Diğer kullanıcıların film yorumlarını keşfedin
- **🌓 Karanlık Mod**: Gözlerinizi yormuyor, karanlık mod desteği
- **📱 Responsive Tasarım**: Mobil, tablet ve desktop uyumlu
- **👤 Profil Yönetimi**: Kullanıcı adı ve hesap bilgilerinizi düzenleyin

## 🛠️ Kullanılan Teknolojiler

- **Flutter**: Cross-platform mobil uygulama geliştirme
- **Firebase**:
  - Authentication (Kullanıcı kimlik doğrulama)
  - Firestore (Veritabanı)
  - Storage (Fotoğraf depolama)
- **Provider**: State management
- **TMDB API**: Film bilgileri ve poster görselleri
- **Image Picker**: Galeri erişimi ve fotoğraf seçimi

## 📋 Gereksinimler

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase projesi
- TMDB API anahtarı
- Android Studio / VS Code
- Android SDK / iOS SDK

## 🚀 Kurulum

1. **Repoyu klonlayın**
```bash
git clone https://github.com/kullaniciadi/movie-diary.git
cd movie-diary
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Firebase yapılandırması**
   - Firebase Console'da yeni bir proje oluşturun
   - Android ve iOS uygulamalarını Firebase projenize ekleyin
   - `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
   - FlutterFire CLI kullanarak yapılandırmayı tamamlayın:
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

4. **TMDB API anahtarı**
   - [TMDB](https://www.themoviedb.org/settings/api) sitesinden API anahtarı alın
   - `lib/screen/home_screen.dart` ve `lib/screen/add_screen.dart` dosyalarındaki `apiKey` değişkenini güncelleyin

5. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 📱 Ekran Görüntüleri

### Ana Sayfa
<img width="497" height="891" alt="anasayfa" src="https://github.com/user-attachments/assets/1f04e6cc-6a84-4234-939d-c9193c82b1d0" />


### Keşfet
<img width="506" height="896" alt="kesfet" src="https://github.com/user-attachments/assets/7f1d28ec-9355-4eae-89cc-ecc4957bcea6" />

Diğer kullanıcıların film yorumlarını görün.

### Paylaş
<img width="505" height="883" alt="ekle" src="https://github.com/user-attachments/assets/e3801d90-b0f1-4e96-bb41-60dec3acd4c7" />

Yeni film yorumu ekleyin, puan verin ve fotoğraf paylaşın.

### Kaydedilenler
<img width="511" height="891" alt="kaydedilenler" src="https://github.com/user-attachments/assets/80dfd0ba-704f-4130-a423-c59c58a0108e" />

Kaydettiğiniz filmleri görüntüleyin.

### Ayarlar
<img width="505" height="879" alt="ayarlar" src="https://github.com/user-attachments/assets/a32d90aa-84ff-41ca-a584-9b8effc98c9e" /><img width="503" height="887" alt="ayarlar2" src="https://github.com/user-attachments/assets/8c7f73d2-78c5-4f9a-80b7-f7bfcc8eb751" />

### Login 
<img width="498" height="888" alt="login" src="https://github.com/user-attachments/assets/ccf058bf-f86c-4bc0-b450-8a46342b12f5" />




Profil bilgilerinizi düzenleyin, karanlık modu aktif edin.

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                 # Ana uygulama dosyası
├── firebase_options.dart     # Firebase yapılandırması
├── models/                   # Veri modelleri
│   ├── movie.dart
│   ├── post_model.dart
│   └── notification_model.dart
├── providers/                # State management
│   └── app_provider.dart
├── screen/                   # Ekranlar
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home_screen.dart
│   ├── posts_screen.dart
│   ├── add_screen.dart
│   ├── liked_screen.dart
│   ├── settings_screen.dart
│   ├── notifications_screen.dart
│   └── main_screen.dart
└── utils/                    # Yardımcı sınıflar
    └── responsive.dart
```

## 🔧 Yapılandırma

### Firebase Güvenlik Kuralları

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      
      match /savedMovies/{movieId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## 📦 Bağımlılıklar

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  provider: ^6.1.1
  http: ^1.1.2
  image_picker: ^1.0.7
  permission_handler: ^11.2.0
```

## 🤝 Katkıda Bulunma

1. Bu projeyi fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/yeniOzellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik eklendi'`)
4. Branch'inizi push edin (`git push origin feature/yeniOzellik`)
5. Pull Request oluşturun

.

## 👨‍💻 Geliştirici

Sıla Çağlayan
- GitHub: [Cagllayansila](https://github.com/cagllayansila)
- LinkedIn: [Cagllayansila](https://www.linkedin.com/feed/)

## 🙏 Teşekkürler

- [TMDB](https://www.themoviedb.org/) - Film veritabanı API'si
- [Firebase](https://firebase.google.com/) - Backend servisleri
- [Flutter](https://flutter.dev/) - Framework

## 📧 İletişim

Sorularınız veya önerileriniz için:
- Email: silacaglayan93@gmail.com

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
