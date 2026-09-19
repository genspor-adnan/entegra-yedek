---
id: dis-seans
baslik: Diş seansı açma, işlem ekleme ve seansı bitirme
modul: dis
ekran: dis-seans
rota: /dis-seans
surec: dis
roller: dis_hekimi, dis_asistan, banko
dil: tr
surum: 1
urun_modu: 2
yetki: dis.seans
erisim: kullanici
ozet: Diş › Seanslar ekranında seans açma, tedavi planı satırlarından işlem ekleme, sarf ve steril paket okutma, "Bu seansta tamamlandı" işareti ve seansı bitirme (ücretlendirme, odontogram).
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Diş kliniğinde iş birimi tedavi planıdır: bulgular odontograma işlenir, plan satırları fiyatlanıp seanslara bölünür, her seansta yapılan işlem ücretlenir. Seans kartı hekimin koltuk başındaki kaydıdır; **✔ Seansı Bitir** ile tamamlanan işlemler başvuruya ücret satırı olarak düşer ve odontogram güncellenir.

## Ekrana giriş yolları
- Sol menü **Diş › Seanslar** (`/dis-seans`); günün çizelgesi **Diş › Günlük Akış** (ünit × saat); hasta ve plan kartları **Diş › Hastalar (Odontogram)** ve **Diş › Tedavi Planları**.
- Seans kartı özel penceredir: `/dis-seans/[kayıt no]`; **🪑 Seans Aç** düğmesiyle açılır.
- Komut paleti (Ctrl+K) › "Seans".

## Ön koşullar
- **dis.seans** yetkisi; bitirme için `dis.seans.bitir` aksiyon yetkisi; hasta kartı için **dis.hasta**.
- Hasta ya da randevu seçili olmalı ("Hasta ya da randevu gerekli").
- Plan satırından işlem eklemek için onaylı / süren tedavi planı; plan dışı işlem için hizmet kartı.
- Ücret satırı başvuruya düşer: seansın bağlı olduğu başvuru (protokol) açık olmalı.

## Alanlar
Seans: **Hasta (zorunlu)**, Hekim, Asistan, Ünit, Tedavi Planı, Randevu, Başvuru, Başlangıç / Bitiş, Süre (dk), Durum, Sterilizasyon Paketi.
Uygulama: Uygulama Notu, Komplikasyon (seans), Hastaya Talimat, Sonraki Seans Planı. Anestezi: Anestezi Türü, İlaç, Doz.
"Yapılan İşlemler" detayı: **İşlem (zorunlu)**, Plan Satırı, Diş, Yüzey, Seans No, **Bu seansta tamamlandı**, Not. "Malzeme & Sarf": Malzeme, Miktar, Birim, Kaynak, Maliyet; aynı sekmede "Sterilizasyon · kullanılan paketler" kutusu (paket barkodu ya da set barkodu okut).
Kart düğmeleri: **🪑 Seans Aç**, **💾 İşlemi kaydet**, **Okut**, "Bu seansın ücreti (bitince)", "Bakiye (yapılan − tahsil)".

## Liste kolonları ve çipler
Kolonlar: Başlangıç · Hasta · Hekim · Ünit · Plan · İşlemler · Süre (dk). Çipler: **Açık · Bitti · Tümü**; tarih süzgeci başlangıca göre.

## İşlemler (düğmeler)
- `dis-seans.yeni` **＋ Seans Aç** (Ctrl+N), `dis-seans.duzenle` **✎ Düzenle**, `dis-seans.sil` **🗑 Sil** (bitmiş seans silinmez).
- `dis.seans-bitir` **✔ Seansı Bitir** (yeşil): onay sorusu; tamamlanan işlemler ücretlenir, odontogram güncellenir, "… işlem tamamlandı, … seans ilerledi" özeti döner.
- `dis.hasta-karti` **🦷 Diş Hasta Kartı**: odontogram + plan.
- `genel.yazdir` **🖨️ Yazdır**.

## Adım adım
1. **Diş › Günlük Akış**'ta randevudan ya da **Diş › Seanslar › ＋ Seans Aç** ile hasta / randevu seçip seansı açın; hekim, asistan, ünit dolar.
2. "Yapılan İşlemler"e plan satırından ekleyin (açık plan satırları listelenir) ya da "Plan dışı işlem" için hizmet seçin; diş no ve yüzeyi yazın.
3. Tek seanslık iş plandan eklenince "tamamlandı" işaretli gelir; çok seanslı işte son seans değilse işaretsiz bırakın (plan satırı bir seans ilerler).
4. Kullanılan malzemeyi "Malzeme & sarf"a, steril paketi barkod okutarak ekleyin; karantina paketinde onay sorulur.
5. Anestezi ve uygulama notunu, hastaya talimatı ve sonraki seans planını yazın; **💾 İşlemi kaydet**.
6. **✔ Seansı Bitir**: "tamamlandı" işaretli işlemler başvuruya ücret satırı olur; tahsilat ve fiş kasa modülüyle alınır.

## Durumlar
- **Açık (1)**: işlem eklenir / değişir. **Bitti (2)**: kapanmış; işlem eklenmez, değiştirilmez, ücretlenmiş satır silinmez.
- Plan satırı: yapılmış / iptal satır seansa alınmaz; tamamlanan satır odontograma işlenir.

## Yetki
- Seans listesi ve kartı **dis.seans**; bitirme `dis.seans.bitir`; hasta kartı **dis.hasta**; plan **dis.plan**; ödeme planı **dis.odeme**; lab iş emri **dis.lab**.
- Sterilizasyon kutusu **steril** modülü ve **steril.kullanim** yetkisi yoksa boş kalır; seans akışı etkilenmez.

## Sık görülen hata ve uyarılar
- **"Hasta ya da randevu gerekli."** (DOGRULAMA) → seans açarken biri seçilmeli.
- **"Seansta yapılan işlem yok; önce işlem satırı ekleyin."** (IS_KURALI) → boş seans bitirilmez.
- **"Seans zaten kapanmış." / "Kapanmış seans değiştirilmez." / "Kapanmış seansa işlem eklenmez."** → bitmiş seans; yeni seans açın.
- **"Bu plan satırı seansta zaten var." / "Plan satırı başka hastanın." / "Yapılmış / iptal plan satırı seansa alınmaz."**
- **"Ücretlenmiş ya da kapanmış seansın işlemi silinmez."**
- **"Bitmiş seans silinmez"** (Sil ipucu).
- **KARANTINA** (paket okutma) → biyolojik sonuç bekleniyor; onayla kullanılır, kayda geçer.
- Seans bitirirken "paket okutulmadı" → kurum kuralına göre onay sorusu (uyarı) ya da engel.

## Diğer modüllere etkisi
- Ücret satırı başvuruya (protokol) düşer; tahsilat kasa, fatura belge modülünde.
- Odontogram ve tedavi planı satır durumu güncellenir; lab iş emri (protez) plan satırından açılır.
- Kullanılan steril paket kapanır, set kirli havuzuna düşer.
- Hekim primi / hakediş seans işlemlerinden hesaplanır.

## Yapılmaması gerekenler
- Boş seansı bitirmeye çalışmayın; önce işlem ekleyin.
- Çok seanslı işte ara seansta "tamamlandı" işaretlemeyin; ücret erken düşer.
- Bitmiş seansı düzeltmek için silmeyin; yeni seans açın.

## Örnek sorular
- Diş seansı nasıl açılır?
- Seansa plan satırından işlem nasıl eklenir?
- "Bu seansta tamamlandı" ne işe yarar?
- Seansı bitirince ne olur?
- Seans neden bitirilemiyor?
- Steril paketi seansa nasıl okuturum?
- Bitmiş seans neden silinmiyor?
- Seans ücreti nereye yazılır?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Dis.ts; web/src/sayfalar/dis/DisSeansKarti.tsx; web/src/sayfalar/liste/disAksiyonlari.ts
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (dis-seans-liste), KartKatalogu.Dis.cs, KaynakKatalogu.Dis.cs
- api/src/Gentegre.Api/Uclar/DisUclari.Seans.cs, DisUclari.SeansKart.cs
- dokuman/00_TARIHCE.md (706-710 diş, "Diş seans kartına kullanılan paketler kutusu")

## Doğrulama durumu
Kod incelemesiyle yazıldı.
