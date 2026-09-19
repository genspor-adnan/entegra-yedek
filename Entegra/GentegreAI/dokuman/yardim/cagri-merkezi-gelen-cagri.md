---
id: cagri-merkezi-gelen-cagri
baslik: Çağrı merkezi: gelen çağrı, arayan tanıma ve çağrı kaydı
modul: cagri
ekran: cagri
rota: /cagri
surec: cagri
roller: cagri_operator, cagri_supervizor, banko
dil: tr
surum: 1
urun_modu: 2
yetki: cagri.kayit
erisim: kullanici
ozet: Operatör Panosu'nda gelen çağrıyı karşılama, arayanı tanıma, hızlı işlem (randevu, geri arama), çağrıyı kapatma ve Çağrı Kayıtları listesinde takip.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Çağrı merkezi modülü santral / WhatsApp / SMS / web formu / e-posta kanallarından gelen çağrıyı kayda alır: arayan numaradan hasta / cari tanınır, konu ağacından konu ve sonuç seçilir, çağrı içinden randevu, ödeme linki, şikâyet görevi ya da geri arama açılır. Kapatılmayan çağrı "Kayıt bekliyor", cevapsız çağrı "Kaçan" olarak geri arama listesine düşer.

## Ekrana giriş yolları
- Sol menü **Çağrı Merkezi › Operatör Panosu** (`/cagri-pano`): gelen çağrı, kuyruk, arayan kartı, hızlı işlemler.
- **Çağrı Merkezi › Çağrı Kayıtları** (`/cagri`): geçmiş çağrılar; çift tık çağrı kartını (`/cagri/[kayıt no]`) açar; alan düzenleme gizli "Çağrı (kart)" (`/cagri-kart`).
- **Giden Arama · Kampanya**, **Süpervizör Panosu**, **Kalite Değerlendirmeleri**; Ayarlar: Konu ağacı & SLA, Kuyruklar & SLA, Agentlar, Santral · IVR · Kanallar.

## Ön koşullar
- **cagri.kayit** (kayıt / kart), **cagri.pano** (operatör panosu), **cagri.giden** (geri arama, kampanya, tıkla-ara), **cagri.ayar** (tanımlar), **cagri.supervizor**, **cagri.kalite**.
- Agent olarak tanımlı olmak (Ayarlar › Agentlar) ve panoda **✔ Hazır** durumuna geçmek; mola sebep ister.
- Santral olayları webhook ile gelir; santral sürücüsü yoktur, tıkla-ara çağrıyı kayıt olarak açar.

## Alanlar
Çağrı: **Kanal (zorunlu)**, **Yön (zorunlu)**, Arayan numara, Kişi (hasta / cari), Kuyruk, Agent, Durum, Öncelik. Kayıt: Konu, Alt konu (konuya bağlı), Sonuç, Not, Memnuniyet (1-5), Ses kaydı bağlantısı. Süre (salt okunur): Bekleme (sn), Konuşma (sn), Başlama, Bitiş.
Detaylar: "Bu çağrıda açılanlar" (Kaynak, Kayıt no, Açıklama), "Zaman çizelgesi" (salt okunur).
Operatör panosu arayan kartı: kişi özeti (son ziyaret, yaklaşan randevu, bekleyen / hazır sonuç, bakiye, açık görev), "Kimlik doğrulama (randevu / sonuç için)", "Arayan tanınmadı; 'Yeni hasta' ya da 'Başka kişi' ile bağlayın."

## Liste kolonları ve çipler
Kolonlar: Zaman · Kanal · Yön · Numara · Kişi · Kuyruk · Agent · Konu · Alt konu · Sonuç · Bekleme (sn) · Süre (sn) · SLA · Durum.
Çipler: **Kayıt bekleyen · Kaçan · Geri aranacak · Gelen · Giden · Tümü**.

## İşlemler (düğmeler)
Operatör panosu: **✔ Hazır**, **☕ Mola**, **📞 Ara**, **Randevu Ver**, **Randevu Değiştir**, **Geri Arama Planla** (geri arama zamanı), **↩ Geri arama**, **💾 Kaydet & Kapat**, **📤 Geri arama · Kampanya**.
Çağrı Kayıtları: `cagri.kart` **📞 Çağrı kartı** (Enter), `cagri.yeni-kayit` **＋ Elle çağrı kaydı** (numara + yön sorar, panoya götürür), `cagri.duzenle` **✎ Düzenle**, `cagri.geri-arama-tamam` **✔ Geri arama yapıldı** (sağ tuş; bağlı hatırlatma görevi kapanır), `cagri.kisi-ac` **👤 Kişi kartı**, `cagri.sil` **🗑 Sil**, **🖨️ Yazdır**.
Çağrı kartı sekmeleri: ilgili kayıtlar, zaman çizelgesi, ses kaydı & özet (kural tabanlı özet), kalite ölçütleri, kişi geçmişi.

## Adım adım
1. **Operatör Panosu**'nu açın, **✔ Hazır**'a basın.
2. Çağrı çalınca arayan kartı açılır; numara eşleşmediyse "Yeni hasta" ya da "Başka kişi" ile bağlayın. Randevu / sonuç bilgisi verecekseniz kimlik doğrulamayı yapın.
3. Konu ve alt konuyu seçin; konunun betiği (operatör betiği) varsa ekranda görünür.
4. Hızlı işlem: **Randevu Ver** / **Randevu Değiştir**, ödeme linki / yol tarifi / anket mesajı, şikâyet için görev, ya da **Geri Arama Planla** (tarih / saat zorunlu).
5. Sonucu (Çözüldü, Geri aranacak, Görev açıldı, Ulaşılamadı, Yönlendirildi, Bilgi verildi, Randevu verildi, Vazgeçti) ve notu girip **💾 Kaydet & Kapat**.
6. Santralsiz ortamda **＋ Elle çağrı kaydı** ile numara ve yönü girip aynı akışı panoda tamamlayın.
7. Geri aranacaklar **Giden Arama · Kampanya** listesinde; arayınca **✔ Geri arama yapıldı** ile kapatın.

## Durumlar
- Çağrı: Çalıyor (1) → Görüşmede (2) → Beklemede (3) → **Kayıt bekliyor (4)** → **Tamamlandı (5)**; **Kaçan (6)**, Sesli mesaj (7), Ulaşılamadı (8).
- Agent: Hazır / Mola / Çıkış; işlem sonrası süresi dolan agent kendiliğinden hazır olur.
- SLA: kuyruğun cevap süresi eşiğine göre "İçinde / Aşıldı".

## Yetki
- Kayıt ve kart **cagri.kayit**; pano **cagri.pano**; geri arama / kampanya / tıkla-ara **cagri.giden**; kalite **cagri.kalite**; süpervizör **cagri.supervizor**; tanımlar **cagri.ayar**.
- Kişi kartı düğmesi hastaysa hasta kartını (**hasta** yetkisi), değilse cari kartını açar.

## Sık görülen hata ve uyarılar
- **"Açık çağrınız var (#…); önce onu kapatın."** (IS_KURALI) → aynı anda ikinci çağrı başlatılmaz.
- **"Konu seçilmeden çağrı kapatılamaz."** / **"\"Geri aranacak\" için tarih/saat zorunlu."**
- **"Durum yalnız Hazır / Mola / Çıkış seçilebilir." / "Mola sebebi zorunlu."**
- **"Telefon numarası yok."** (mesaj gönderimi) / **"Bilinmeyen mesaj şablonu."**
- **"Çağrı beklemede değil."** → beklemeden alma işlemi için çağrı beklemede olmalı.
- **"Bu çağrı bir kişiye bağlı değil."** → Kişi kartı için önce arayanı bağlayın.
- **"Puan 0-100 arası olmalı."** (kalite değerlendirmesi).

## Diğer modüllere etkisi
- Randevu Ver / Değiştir randevu modülüne yazar; şikâyet ve geri arama görev modülünde görev açar.
- Mesajlar (ödeme linki, yol tarifi, anket, geri arama, randevu hatırlatma) bildirim kuyruğundan gider; kampanya kaynakları yarınki randevu, 7 günlük lab sonucu, bakiye eşiği ve İSG periyodik muayeneleridir.
- Arayan tanıma hasta / cari telefonlarına (son 10 hane) bakar; hasta kartındaki telefon güncel olmalı.

## Yapılmaması gerekenler
- Konu seçmeden çağrıyı kapatmaya çalışmayın.
- Kimlik doğrulamadan randevu / sonuç bilgisi vermeyin; pano bunu ayrıca sorar.
- Test ortamında gerçek hasta numarasına mesaj göndermeyin; bildirim işçisi canlı sağlayıcıya bağlı olabilir.

## Örnek sorular
- Gelen çağrıyı nasıl kaydederim?
- Arayan tanınmadı, ne yapmalıyım?
- Çağrı neden kapanmıyor?
- Çağrıdan randevu nasıl verilir?
- Geri arama nasıl planlanır ve kapatılır?
- Kaçan çağrıları nerede görürüm?
- Elle çağrı kaydı nasıl açılır?
- Mola'ya nasıl geçerim?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Cagri.ts; web/src/sayfalar/cagri/CagriOperator.tsx, CagriKarti.tsx; web/src/sayfalar/liste/cagriAksiyonlari.ts
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (cagri-liste, cagri-kampanya-*), KartKatalogu.Cagri.cs, KaynakKatalogu.Cagri.cs
- api/src/Gentegre.Api/Uclar/CagriUclari.Akis.cs; db/839_cagri_merkezi.sql (kod listeleri)
- dokuman/00_TARIHCE.md ("Çağrı Merkezi modülü (839)")

## Doğrulama durumu
Kod incelemesiyle yazıldı.
