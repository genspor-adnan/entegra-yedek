---
id: icmal-kasa-gun-sonu
baslik: Kasa / Gün Sonu Mutabakatı
modul: finans
ekran: kasa-gun-sonu
rota: /kasa-gun-sonu
surec: icmal
roller: muhasebe, finans, vezne, yonetim
dil: tr
surum: 1
urun_modu: 2
yetki: kasa.gun_sonu
erisim: kullanici
ozet: Şubenin bir gününde bütün kasa, POS ve banka hesaplarının beklenen / sayılan / farkını gösterir; sayım, POS gün sonu ve banka ekstresi girilir, farklar açıklanır ve gün kapatılır.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Dün kasalar tuttu mu, POS gün sonu ve banka ekstresi sistemle uyuşuyor mu, gün kapatılabilir mi?" sorusunu cevaplar. Kasaların devir, giriş, çıkış ve transferinden beklenen bakiyeyi hesaplar, sayılanla karşılaştırır; farklar açıklandıktan sonra **Günü Kapat** ile gün kilitlenir ve o güne kasa işlemi yazılamaz. Muhasebe, finans ve vezne sorumlusu kullanır. Vezne İcmali bunun bir alt düzeyidir (banko oturumları).

## Bu ekranda neler yapabilirsiniz
- **Günü değiştirmek** — "📅 Tarih" kutusu ve ‹ / › okları (varsayılan dün).
- **Sekmeler arasında geçmek** — Kasalar, POS Mutabakatı, Banka Hareketleri, Hareketler, Farklar / Açıklamalar.
- **Kasa sayımı girmek** — Kasalar sekmesinde Sayılan hücresine tutarı yazıp Kaydet (ya da Enter); gün açık ve Değiştir yetkisi varsa.
- **POS gün sonu (batch) toplamı girmek** — POS Mutabakatı sekmesinde ilgili satıra tutarı girip Kaydet.
- **Banka ekstre rakamı girmek** — Banka Hareketleri sekmesinde yatış ve havale ekstre tutarlarını girin.
- **Farkı açıklamak** — Farklar / Açıklamalar sekmesinde Neden seçip açıklama yazın ve Kaydet.
- **Kasa seçmek / ayrıntı açmak** — kasa satırına tıklayın (Ctrl / Shift ile çoklu); seçim Hareketler sekmesini ve A4'ü süzer. ▸ işareti kasanın alt satırlarını açar.
- **Günü kapatmak** — "🔒 Günü Kapat"; engel varsa liste gösterilir, yoksa onaydan sonra gün kilitlenir.
- **Kapalı günü açmak** — "🔓 Günü Aç" (Sil yetkisi gerekir); gerekçe istenir ve kayıtta kalır.
- **Çıktı almak** — "🖨️ Gün Sonu Raporu ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML. "🏦 Vezne İcmali" aynı günün vezne icmaline geçer.

## Ekrana giriş
- Sol menü **Finans › Kasa / Gün Sonu** (`/kasa-gun-sonu`), yalnız HBYS modunda.
- Hesap ekstresi (kasa) ekranındaki "🧮 Gün Sonu" ve kasa panellerindeki "🧮 Sayım" düğmeleri.
- `kasa.gun_sonu` Gör ile izlenir; sayım / fark girme ve günü kapatma Değiştir, günü açma Sil yetkisi ister.

## Süzgeçler
- Yalnız **Tarih** vardır; aktif şubenin günü gösterilir. Şeritte gün durumu (Gün kapalı / Gün açık · kapatılabilir / kapatılamaz), kapanmamış banko oturumu, POS farkı ve önceki günün kapanış durumu yazar.

## Özet ve sekmeler
Özet kutuları: **Devir (Açılış)** · **Nakit Giriş** · **Nakit Çıkış** · **Kasa Bakiyesi** (beklenen; sayılan ve fark) · **POS / Kredi Kartı** (çekim, batch, fark, bekleyen) · **Havale / EFT** (ekstre farkı) · **Bankaya Yatırılan** · **Ertesi Gün Devri** (sayılmayan kasa varsa "kesin değil").

Sekmeler:
- **Kasalar** — Kasa, Açılış, Giriş, Çıkış, Transfer, Beklenen, Sayılan, Fark, Sorumlu, Oturum / Sayım.
- **POS Mutabakatı** — POS Hesabı, Terminal / Banko, Sistem Adet, Sistem Tutar, Gün Sonu (Batch), Kaynak, Fark, Durum.
- **Banka Hareketleri** — Yatış (beklenen / ekstre), Havale (adet, sistem, ekstre), Fark, Durum.
- **Hareketler** — günün kasa hareketleri: Saat, Kasa / Hesap, Tür, Yön, Protokol No / Açıklama, Tutar, Kullanıcı.
- **Farklar / Açıklamalar** — Kalem, Fark, Sorumlu, Neden, Açıklama, Durum (sekme sayısı açıklanmamış engel farkı sayısıdır).

## Rakamlar nereden gelir
- Uç: `GET /api/kasa-gun-sonu`; girişler `/sayim`, `/pos`, `/banka`, `/fark`, `/kapat`, `/ac` (`KasaGunSonuUclari.cs`).
- Kaynak hesap ekstresiyle aynıdır (gerçekleşmiş hareketler); gün Türkiye saatiyle.
- **Beklenen** = devir (günden önceki bakiye) + giriş − çıkış + transfer (virman).
- **Sayılan**: banko kasasında gün içinde kapanan son oturumun "kasada bırakılan"ı; öteki kasalarda bu ekranda girilen sayım.
- **POS gün sonu**: elle girilen tutar, yoksa banko oturum kapanışında girilen cihaz toplamı. **Banka ekstresi** elle girilir (içe aktarma bu sürümde yok).

## Çıktı
"🖨️ Gün Sonu Raporu ▾" menüsü "GÜN SONU KASA RAPORU" başlıklı A4 üretir (gün kapanmadıysa başlıkta "(TASLAK)"); kasa ve POS tabloları içerir, kasa seçilmişse seçime göre süzülür. Dosya adı "Gün Sonu Kasa Raporu <tarih>".

## Dikkat edilecekler
- **Günü Kapat engelleri**: açık banko oturumu, sayımı girilmemiş hareketli kasa, gün sonu toplamı girilmemiş POS, açıklamasız kasa / POS farkı. Banka farkı engel değildir, yalnız bilgidir.
- Engeller kapatma anında sunucuda yeniden hesaplanır.
- Kapalı güne kasa işlemi yazılamaz, değiştirilemez (veritabanı kilidi); açmak yalnız yetkili kişiyle ve gerekçeyle olur.

## Örnek sorular
- Dünkü günü neden kapatamıyorum?
- Kasa sayım farkına açıklama nasıl girerim?
- POS gün sonu toplamını nereye yazarım?
- Kapattığım günü yeniden nasıl açarım?
- Ertesi güne ne kadar nakit devrediyor?
