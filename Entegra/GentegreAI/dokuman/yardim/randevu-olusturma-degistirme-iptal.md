---
id: randevu-olusturma-degistirme-iptal
baslik: Randevu oluşturma, değiştirme ve iptal
modul: randevu
ekran: randevu
rota: /randevu
surec: randevu
roller: kayit_kabul, banko, cagri_operator, hekim
dil: tr
surum: 1
urun_modu: 2
yetki: randevu
erisim: kullanici
ozet: Randevu › Randevular ekranında takvimden ya da listeden randevu verme, Geldi / Gelmedi / İptal işaretleme, başvuruya dönüştürme ve çalışma planı bağı.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Randevu, hastanın bir hekime (poliklinik) ya da bir cihaza (radyoloji) ayrılan saatidir. Hasta geldiğinde randevu başvuruya dönüştürülür; randevunun hizmeti başvurunun ilk kalemi olur. Hangi hekimin hangi gün / saat çalıştığı Çalışma Planları'ndan gelir.

## Ekrana giriş yolları
- Sol menü: **Randevu › Randevular**; aynı grupta **Çalışma Planları**, **Çalışma Şablonları**, **İzin & İstisnalar**, **Randevu Ayarları**.
- Radyoloji Çalışma Listesi'nde **📅 Randevu Ver** (cihaz randevusu).
- Çağrı merkezi operatör panosunda **Randevu Ver** / **Randevu Değiştir**.
- Komut paleti (Ctrl+K) › "Randevu".

## Ön koşullar
- **randevu** yetkisi (Gör / Ekle / Değiştir); plan ekranları için **randevu.plan**.
- Hekimin aktif bir çalışma şablonu olmalı; yoksa hekim listesinde çıkmaz. Acil / laboratuvar gibi "randevusuz kabul" bölümleri plan gerektirmez.
- Hasta kayıtlı olmalı (arama penceresi yalnız hastaları listeler).

## Alanlar
Üst şerit (Kimlik): **Hasta (zorunlu)**, **Tarih / Saat (zorunlu)**, Durum.
Randevu kutusu: Bölüm / Poliklinik (yalnız randevu verilebilen bölümler), Hekim (yalnız planlı hekimler), Cihaz (radyoloji), Hizmet / İşlem, **Süre (dk) (zorunlu, varsayılan 15)**, Randevu Tipi (Muayene / Kontrol / Tetkik / Girişim-İşlem / Aşı / Rapor), Kaynak (Telefon / Yerinde / Web / Çağrı Merkezi / Hekim Yönlendirmesi / MHRS), Açıklama.
Bitiş saati alan değildir; süreden hesaplanır.

## Liste kolonları ve çipler
Kolonlar: Bölüm · Hekim · Cihaz · Hasta · Tarih · Saat · Bitiş · Süre (dk) · Durum · Hizmet · Açıklama (Tip, Kaynak, Başvuru kolon seçicisinden açılır).
Çipler: **Planlandı · Geldi · Gelmedi · İptal · Tümü**; tarih süzgeci randevu tarihine göre.
Görünüm düğmesi **📅 Takvim**: hekim ya da cihaz sütunlu takvim; bölüm ve hekim süzgeci; radyoloji cihazı tanımlıysa yanda "randevu bekleyen istemler" paneli.

## İşlemler (düğmeler)
- `randevu.yeni` **＋ Yeni** (Ctrl+N): boş randevu kartı (takvimde boş saate tıklamak da kartı o saatle açar).
- `randevu.duzenle` **✎ Düzenle** (Enter): saat / hekim / süre değiştirme.
- `randevu.geldi` **✔ Geldi**: durumu Geldi yapar.
- `randevu.gelmedi` **✖ Gelmedi**: durumu Gelmedi yapar.
- `randevu.basvuru` **➜ Başvuruya Dönüştür**: hastaya başvuru açar, randevunun hizmetini kalem yapar, fiyatı fiyat listesi / kampanyadan alır.
- `randevu.iptal` **⊘ İptal** (sağ tuş): durumu İptal yapar; kayıt silinmez.
- `randevu.sil` **🗑 Sil** (sağ tuş, Del): kaydı siler.
- `genel.yazdir` **🖨️ Yazdır**.

## Adım adım
1. **Randevu › Randevular** ekranını açın; **📅 Takvim** görünümüne geçin.
2. Bölüm ve hekim (ya da cihaz) süzgecini seçin.
3. Boş bir saate tıklayın; kart o saatle açılır. Hastayı arama penceresinden seçin.
4. Hizmet / işlem, süre, randevu tipi ve kaynağı girip **Kaydet**'e basın.
5. Değiştirmek için listede satırı seçip **✎ Düzenle**; yeni saat çakışıyorsa sistem kaydetmez.
6. Hasta gelince **✔ Geldi**, ardından **➜ Başvuruya Dönüştür**; gelmezse **✖ Gelmedi**.
7. Vazgeçildiyse sağ tuş **⊘ İptal** (silmek yerine).

## Durumlar
- **Planlandı (1)**: verildi. **Geldi (2)**: hasta geldi. **Gelmedi (3)**: gelmedi. **İptal (4)**: iptal edildi.
- Başvuruya dönüştürülen randevuya başvuru numarası bağlanır ("Başvuru" kolonu).

## Yetki
- Kart ve liste **randevu**; başvuruya dönüştürme ayrıca **belge** Ekle ister.
- Plan / şablon / istisna ekranları **randevu.plan**.
- Portal hastası yalnız kendi randevusunu görür; dış doktor randevu takvimini görmez.

## Sık görülen hata ve uyarılar
- **"Randevu için hekim ya da cihaz seçilmeli."** (IS_KURALI) → biri zorunlu; poliklinikte hekim, radyolojide cihaz.
- **"Poliklinik randevusunda bölüm seçilmeli."** → bölüm boş.
- **"Hekimin bu saatte başka randevusu var."** → saati ya da hekimi değiştirin.
- **"Cihaz bu saatte dolu (aynı anda en fazla … hasta)." / "Cihaz bu aralıkta randevuya kapalı: …"** → cihaz kapasitesi / bakım-kapatma takvimi; başka saat seçin.
- **"Tetkik ile cihazın modalitesi uyuşmuyor"** → radyoloji tetkiki için doğru cihazı seçin.
- **"Randevuda hasta yok." / "Randevuda hizmet seçili değil — başvuru kalemi oluşturulamıyor."** → başvuruya dönüştürmeden önce kartta hasta ve hizmeti doldurun.
- Hekim listede yok → hekimin aktif çalışma şablonu yok; **Randevu › Çalışma Şablonları**'ndan tanımlayın.

## Diğer modüllere etkisi
- Başvuruya dönüştürme kayıt kabulde protokol açar ve Hekim Çalışma Listesi'ne düşürür.
- Radyoloji randevusu cihaz çalışma listesine (MWL) gider; diş kliniğinde Günlük Akış randevunun diş görünümüdür.
- Randevu hatırlatma SMS'i bildirim kuyruğundan gider; çağrı merkezi kampanyaları yarınki randevuları kaynak alır.
- Muayene kartı randevu numarasını taşır.

## Yapılmaması gerekenler
- Gelmeyen hastanın randevusunu silmeyin; **✖ Gelmedi** ya da **⊘ İptal** kullanın (istatistik ve hatırlatma buna bakar).
- Muhasebe gibi randevu alınmayan bölüme randevu vermeye çalışmayın; listede çıkmaz.
- Çakışan saati zorlamayın; sistem kaydetmez.

## Örnek sorular
- Randevu nasıl oluşturulur?
- Randevu saatini nasıl değiştiririm?
- Randevuyu nasıl iptal ederim, silmeli miyim?
- Hekim randevu listesinde neden görünmüyor?
- "Hekimin bu saatte başka randevusu var" ne demek?
- Randevuyu başvuruya nasıl dönüştürürüm?
- Takvim görünümüne nereden geçilir?
- Radyoloji cihazına randevu nasıl verilir?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Klinik.ts (randevu, calisma-plani, calisma-sablon, calisma-istisna)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (randevu-liste)
- api/src/Gentegre.Cekirdek/Katalog/KartKatalogu.Randevu.cs, KaynakKatalogu.Randevu.cs
- web/src/sayfalar/liste/randevuAksiyonlari.ts, web/src/sayfalar/Liste.tsx (Takvim görünümü)
- db/316_randevu_cihaz_kaynagi.sql, db/317_randevu_tetkik_uyum.sql, db/243_randevu.sql, db/261_randevu_tip_kaynak.sql
- dokuman/00_TARIHCE.md (718 hekim çalışma planı)

## Doğrulama durumu
Kod incelemesiyle yazıldı.

## Kod-belge çelişkileri
- Rehber kataloğu (447) "Hekimin çalışma saatleri Randevu Ayarları'ndan gelir" der; 718 sonrası hekim / bölüm uygunluğu **Çalışma Planları** (şablon + istisna) ile belirlenir. Takvim slot düzeni ise hâlâ Randevu Ayarları'ndan gelir (plan bloklarına bağlanması açık iş).
