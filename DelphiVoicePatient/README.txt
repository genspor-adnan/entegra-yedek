DelphiVoicePatient – Sesle Hasta Kaydı (TSV Çıktı)
==================================================

Bu proje, Windows SAPI (Speech API 5.x) ile Türkçe konuşma komutlarını dinler
ve `hastalar.tsv` dosyasına kayıt eder.

Komutlar:
- "yeni hasta"  → yeni satıra başlar
- "adı ..."     → ad sütununu doldurur
- "soyadı ..."  → soyad sütununu doldurur
- "telefonu ..."→ telefon sütununu doldurur (yalnızca rakamlar kaydedilir)
- "bitti"       → mevcut satırı dosyaya yazar ve uygulamayı kapatır

Gereksinimler
-------------
1) Windows 10/11
2) Türkçe konuşma tanıma paketi (Ayarlar → Zaman ve Dil → Konuşma → Türkçe)
3) Delphi (VCL) – XE7+ önerilir.
4) Microsoft Speech Object Library (SAPI 5.x) Type Library

İlk Kurulum (1 dakika)
----------------------
1) Projeyi Delphi'de açın: `DelphiVoicePatient.dproj`
2) Type Library ekleyin (bir kez yapılır):
   - Menü: **Project → Import Type Library…**
   - Listeden **Microsoft Speech Object Library (v5.x)** seçin.
   - "Create Unit" / "Install" adımlarında **SpeechLib_TLB.pas** dosyası
     projeye eklenecek. (Varsayılan isim yeterli.)
3) Çalıştırın (F9). Formda **Başla** tuşuna basın ve komutları söyleyin.

Çıktı
-----
- Uygulama klasörüne `hastalar.tsv` oluşturur. Excel'de açılabilir.

Notlar
-----
- Mikrofon seviyeniz ve ortam gürültüsü tanıma kalitesini etkiler.
- Komut kelimesini net söyleyin: ör. "Adı Ahmet", "Soyadı Demir", "Telefonu 5 3 2 ...".
- İsterseniz CSV'ye yazma, ek alanlar ("TC", "adres", "not") gibi genişletmeler yapılabilir.