---
id: lab-sonuc-onay
baslik: Laboratuvar sonuç onayı (teknik / uzman), panik değer ve düzeltme
modul: lab
ekran: lab-sonuc
rota: /lab-sonuc
surec: lab
roller: lab_teknisyen, lab_uzman, hekim
dil: tr
surum: 1
urun_modu: 2
yetki: lab.sonuc
erisim: kullanici
ozet: Laboratuvar › Sonuçlar (Sonuç Onay Kuyruğu) ekranında teknik ve uzman onayı, oto-onay kuralı, panik değer bildirimi, delta uyarısı ve onaylı sonucu düzeltme.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Sonuç Onay Kuyruğu, cihazdan ya da elle girilmiş sonuçların yayınlanmadan önce göründüğü yerdir. Panik ve delta uyarıları önce görünsün diye ayrı çiplerdedir; temiz sonuçlar oto-onayla kuyrukta hiç beklemez. Onaylı sonuç hekime ve rapora yalnız uzman onayından sonra çıkar.

## Ekrana giriş yolları
- Sol menü: **Laboratuvar › Sonuçlar** (ekran başlığı "Sonuç Onay Kuyruğu").
- Komut paleti (Ctrl+K) › "Sonuç".
- Sonuç girişi İstemler ekranındaki **🧪 Sonuç Gir** penceresinden; cihaz mesajları **Laboratuvar › Biyokimya › Cihaz Mesajları**'ndan gelir.

## Ön koşullar
- Teknik onay ve panik bildirimi için **lab.sonuc** (Değiştir); uzman onayı ve düzeltme için **lab.onay** aksiyon yetkisi.
- Referans aralığı ve panik sınırı tetkik kataloğunda tanımlı olmalı; yoksa bayrak boş kalır ("Referans tanımlı değil").
- Kalite kontrolde reddi kapatılmamış test oto-onaya girmez.

## Alanlar
Kart yoktur; satır = tek tetkik sonucu. Düzeltmede "Doğru sonuç değeri" ve **Düzeltme nedeni (zorunlu)**; panik bildiriminde "Bildirim yapılan kişi (ad soyad)" ve "Açıklama (okundu-tekrar edildi vb.)" sorulur.

## Liste kolonları ve çipler
Kolonlar: Barkod · Hasta · Kod · Tetkik · Sonuç · Birim · Değerlendirme (bayrak L / H / LL / HH) · Referans · Panik · Önceki (onaylı önceki değer) · Delta · Ölçüm · Kaynak (cihaz / elle) · Durum · Numune Kalitesi Uyarısı. İstem No, Oto, Onay, Yorum kolon seçicisinden açılır.
Çipler: **Onay Bekleyen · Panik · Delta Uyarı · Numune Uygunsuz · Teknik Onay · Onaylı · Tümü**; tarih süzgeci ölçüm zamanına göre.

## İşlemler (düğmeler)
- `lab.teknik-onay` **✔ Teknik Onay**: birinci aşama.
- `lab.onayla` **✅ Uzman Onayı (yayınla)**: sonucu yayınlar; panik değerde ek onay sorusu.
- `lab.duzelt` **✎ Sonucu Düzelt** (sağ tuş): eski satırı iptal eder, yeni satır açar; neden zorunlu, rapor "düzeltilmiş" damgası taşır.
- `lab.panik-bildir` **☎ Panik Bildirimi**: kime, hangi kanalla bildirildiği kayda geçer.
- `genel.yazdir` **🖨️ Yazdır**.

## Adım adım
1. **Laboratuvar › Sonuçlar** ekranını açın; önce **Panik** ve **Delta Uyarı** çiplerine bakın.
2. Panik satırında **☎ Panik Bildirimi** → bildirilen kişiyi ve "okundu-tekrar edildi" notunu yazın.
3. Satırı seçip **✔ Teknik Onay** verin.
4. Uzman olarak **✅ Uzman Onayı (yayınla)** verin; panikte onay sorusunu okuyup kabul edin.
5. Yanlış girilmiş onaylı sonuçta sağ tuş **✎ Sonucu Düzelt** → doğru değer + neden; sistem yeni değerlendirmeyi (bayrağı) gösterir.
6. Hastaya belge için İstemler ekranından **🖨 Sonuç Raporu**; hekim sonucu muayene kartında görür ve "Gördüm" işaretler.

## Durumlar
- **Onay Bekleyen (1)** → **Teknik Onay (2)** → **Onaylı (3)**; düzeltilen eski satır **iptal (4)**, yenisi tekrar numarasıyla açılır.
- **Oto-onay**: bayrak normal, panik yok, delta uyarısı yok ve tetkikte oto-onay açıksa sonuç doğrudan onaylanır. Düzeltmede oto-onay kapalıdır.
- **Delta**: önceki onaylı sonuçla fark eşiği aşılmışsa uyarı; **Numune Uygunsuz**: hemoliz / lipemi / ikter eşiği aşılmış, uzman bakmadan yayınlanmaz.

## Yetki
- **lab.sonuc**: sonuç girişi, teknik onay, panik bildirimi. **lab.onay**: uzman onayı ve düzeltme. **lab.kk**: kalite kontrol ekranları.
- Dış lab sonucu oto-onaya girmez; uzman onayı bekler.

## Sık görülen hata ve uyarılar
- **Panik değerde uzman onayı sorusu** → sonuç panik sınırının dışında; onaylamadan önce bildirim yaptığınızdan emin olun.
- **"Düzeltme nedeni zorunlu."** → neden yazmadan düzeltme kaydedilmez.
- **Onaylı sonuç değiştirilemiyor** → onaylı satır güncellenmez; **✎ Sonucu Düzelt** kullanın.
- **Bayrak boş** → tetkikte referans / panik sınırı tanımlı değil; Tetkik Kataloğu'ndan tamamlayın.
- **Sonuç kuyrukta görünmüyor** → oto-onayla yayınlanmış olabilir ("Onaylı" çipine bakın) ya da cihaz mesajı çözümlenememiştir (Cihaz Mesajları › Hata).
- **YASAK (403)** uzman onayında → lab.onay yetkiniz yok.

## Diğer modüllere etkisi
- Onaylı sonuç muayene kartının İstem & Sonuçlar sekmesine düşer, "sonuç bekliyor" rozeti kapanır ve e-Nabız "Laboratuvar Sonuç" paketi üretilir.
- Sonuç raporu yalnız onaylı satırları basar; açık kültür / genetik vakası varsa TASLAK damgası vurur.
- Kalite kontrol reddi olan testte oto-onay durur; Westgard kuralları bu ekranı etkiler.

## Yapılmaması gerekenler
- Panik değeri bildirmeden yayınlamayın; bildirim kaydı hasta güvenliği izidir.
- Onaylı sonucu "düzenle" ile değiştirmeye çalışmayın; düzeltme ayrı adımdır.
- Referansı sonradan değiştirip eski sonucu yeniden yorumlamayı beklemeyin; bayrak sonuçla birlikte saklanır.

## Örnek sorular
- Laboratuvar sonucunu nasıl onaylarım?
- Teknik onay ile uzman onayı farkı ne?
- Panik değer bildirimi nasıl yapılır?
- Onaylanmış sonucu nasıl düzeltirim?
- Delta uyarısı ne demek?
- Sonuç neden oto-onaylandı?
- Sonuç hekime ne zaman görünür?
- Sonuç raporunu nasıl basarım?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Laboratuvar.ts (lab-sonuc)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (lab-sonuc-liste)
- api/src/Gentegre.Cekirdek/Katalog/KaynakKatalogu.Lab.cs (lab-sonuc)
- web/src/sayfalar/liste/labAksiyonlari.ts
- dokuman/01_API_SOZLESMELERI.md §9.3, §9.6, §9.7, §9.10
- db/447_ai_rehber.sql (lab-sonuc-bak konusu)

## Doğrulama durumu
Kod incelemesiyle yazıldı.

## Kod-belge çelişkileri
- Görev tanımı "e-imza" adımından söz eder; laboratuvar onay uçlarında ve aksiyon kataloğunda e-imza (akıllı kart) adımı yoktur. Uzman onayı kullanıcı hesabıyla kaydedilir; e-imza yalnız onay akışları ve Medula reçetesinde bir bayrak olarak vardır. Rapor çıktısında "e-imzalı" ibaresi beklenmemeli (doğrulanacak).
