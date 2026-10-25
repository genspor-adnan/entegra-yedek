---
id: icmal-alacak-yaslandirma
baslik: Alacak Yaşlandırma
modul: finans
ekran: alacak-yaslandirma
rota: /alacak-yaslandirma
surec: icmal
roller: muhasebe, finans, vezne, yonetim
dil: tr
surum: 1
urun_modu: 2
yetki: finans.alacak_yaslandirma
erisim: kullanici
ozet: Hastalardan ve ödeyen kurumlardan (SGK, ÖSS, kurumu öder) alınacak açık bakiyeleri referans tarihine göre 0–30 / 31–60 / 61–90 / 90+ gün dilimlerinde gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hasta ve kurum alacaklarımızın ne kadarı ne zamandır bekliyor?" sorusunu cevaplar. Her açık belge kendi yaşına göre bir gün dilimine düşer; kurum tarafında faturalanmamış kurum payı da ayrıca görünür. Hastane muhasebesi, finans ve yönetim tahsilat önceliğini belirlemek için kullanır. Yalnız HBYS kurulumunda vardır.

## Bu ekranda neler yapabilirsiniz
- **Tarafı seçmek** — "👥 Taraf" listesinden Tümü (hasta + kurum), Kurum ya da Hasta.
- **Referans tarihini değiştirmek** — "📅 Referans tarihi"; gün = referans tarihi − belge tarihi.
- **Kurum türü süzmek** — "🏢 Kurum türü": Tümü / SGK / ÖSS / Kurumu öder (Hasta seçiliyken gizlenir).
- **Sekmeler arasında geçmek** — Kurumlar, Hastalar, Dilim Grafiği.
- **Satır seçmek** — satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); A4 çıktı yalnız seçilenleri basar.
- **Kurum ya da hasta icmalini açmak** — kurum adına tıklayınca Kurum İcmali, hasta adına tıklayınca Hasta İcmali açılır; geri dönüş bu ekrana gelir.
- **Çıktı almak** — "🖨️ Alacak Yaşlandırma ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Diğer ekranlara geçmek** — 📞 Hasta Borç Takibi ve 🏢 Kurum İcmali düğmeleri.

## Ekrana giriş
- Sol menü **Finans › Alacak Yaşlandırma** (`/alacak-yaslandirma`), yalnız HBYS modunda.
- Hasta Borç Takibi ekranındaki "⏳ Alacak Yaşlandırma" düğmesi (Hasta tarafı seçili açılır).
- `finans.alacak_yaslandirma` görme yetkisi gerekir.

## Süzgeçler
- **Taraf** (varsayılan Tümü), **Referans tarihi** (varsayılan bugün), **Kurum türü** (SGK / ÖSS / Kurumu öder).
- Süzgeçler adres çubuğuna yazılır; değişince seçim temizlenir. 90+ gün alacak varsa şeritte kırmızı uyarı çıkar.

## Özet ve sekmeler
Özet kutuları: **Toplam Alacak** (kurum / hasta ayrımı) · **0 – 30 Gün** · **31 – 60 Gün** · **61 – 90 Gün** · **90+ Gün** (toplama göre pay) · **En Eski Alacak** (gün) · **Ortalama Gün** (tutar ağırlıklı) · **Taraf** (kurum ve hasta sayısı).

Sekmeler:
- **Kurumlar** — Kurum, Tür, Açık Belge, 0–30, 31–60, 61–90, 90+, Toplam, Faturasız (henüz faturalanmamış kurum payı), En Eski, Son Tahsilat, Durum; altta toplam.
- **Hastalar** — Hasta, Dosya No, Açık Protokol, dilimler, Toplam, En Eski, Son Tahsilat, Durum.
- **Dilim Grafiği** — dilim başına kurum, hasta, toplam ve pay çubukları.

Durum rozeti: **90+ gün var**, **61–90 gün**, **31–60 gün** ya da **Güncel**.

## Rakamlar nereden gelir
- Uç: `GET /api/alacak-yaslandirma` (`AlacakYaslandirmaUclari.cs`); yalnız okur.
- **Kurum alacağı** = kesilmiş ama ödenmemiş kurum faturası / tahakkuku (kurum carisi, `v_cari_ekstre`; tahsilat önce en eski borcu kapatır) + henüz faturalanmamış kurum payı (kapanmamış SGK + ÖSS payı, başvuru tarihinden). İkisi çakışmaz.
- **Hasta alacağı** = başvuru başına hasta payı − net tahsilat (Hasta İcmali ile aynı kural); avans mahsup edilmedikçe düşülmez.
- **Gün** = referans tarihi − açık belgenin tarihi; her açık belge kendi dilimine düşer.

## Çıktı
"🖨️ Alacak Yaşlandırma ▾" menüsü "ALACAK YAŞLANDIRMA RAPORU" başlıklı A4 üretir: Taraf, Tür, 0–30, 31–60, 61–90, 90+, Toplam sütunları. Satır seçilmişse yalnız seçili kurum ve hastalar basılır. Dosya adı "Alacak Yaşlandırma <tarih>".

## Dikkat edilecekler
- Hasta TC kimlik numarası gösterilmez; hasta ad ve dosya no ile tanınır.
- Avans, mahsup edilmedikçe hasta borcundan düşülmez.
- Faturasız kurum payı faturalandığında kurum carisine geçer; iki kez sayılmaz.

## Örnek sorular
- SGK'dan 90 günü geçmiş ne kadar alacağımız var?
- En eski açık alacak hangi kurumda?
- Henüz faturalanmamış kurum payı ne kadar?
- Sadece seçtiğim kurumların yaşlandırmasını nasıl yazdırırım?
- Hasta borçlarının dilimlere dağılımı nasıl?
