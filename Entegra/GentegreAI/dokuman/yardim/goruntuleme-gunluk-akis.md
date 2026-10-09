---
id: goruntuleme-gunluk-akis
baslik: Görüntüleme merkezinde bir günün akışı (rol rol)
modul: radyoloji
ekran:
rota:
surec: goruntuleme
roller: banko_gorevlisi, banko_sorumlusu, doktor_sekreteri, rad_teknisyen, radyolog
dil: tr
surum: 1
urun_modu: 2
yetki:
erisim: kullanici
ozet: Görüntüleme merkezinde randevudan sonuç teslimine kadar günlük iş akışı; banko, radyoloji teknisyeni ve radyoloğun hangi ekranda ne yaptığı ve ayrıntılı yardım belgelerine bağlantılar.
guncelleme: 2026-10-10
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Bu belge görüntüleme merkezinde (röntgen, USG, BT, MR, mamografi) programı yeni öğrenen personel için **haritadır**: bir hastanın kapıdan girdiği andan raporunu teslim alana kadar hangi adımın hangi rolde ve hangi ekranda yapıldığını gösterir. Her adımın ayrıntısı ayrı bir yardım belgesindedir (aşağıda kimlikleriyle verildi; asistana belge adını sorabilirsiniz).

## Akışın özeti
**Randevu → Kabul (başvuru + istem + tahsilat) → Çekim → Rapor → Onay → Teslim / e-Nabız**

Her istemin kartında üstte bir **akış şeridi** vardır: **İstem → Randevu → Çekim → Raporlanıyor → Onay → Teslim**. Tamamlanan adım zamanıyla birlikte işaretlenir; işin nerede kaldığını buradan görürsünüz.

## Banko / sekreter (sabah)
1. **Vardiyayı açın:** Sol menü **Kayıt Kabul › Banko Oturumları › ＋ Yeni Oturum Aç**; bankonuzu seçin, kasadaki parayı sayıp yazın. Açık oturum olmadan tahsilat alınamaz (kurum ayarı açıksa). Ayrıntı: `banko-oturum-gun-sonu`.
2. **Günün randevularına bakın:** **Randevu › Randevular › 📅 Takvim**, cihaz sütunlu görünüm. Ayrıntı: `randevu-olusturma-degistirme-iptal`.

## Banko / sekreter (gün içi)
1. **Telefonla randevu:** takvimde cihaz sütununda boş saate tıklayın, hastayı ve tetkiki seçin. Radyolojide randevu hekime değil **cihaza** verilir.
2. **Hasta geldiğinde (kabul):** Randevu listesinde satırı seçip **✔ Geldi** (ya da **➜ Başvuruya Dönüştür**). Cihazlı randevuda bu düğme **Radyoloji İstemi (kabul) penceresini** açar: başvuru (protokol), tetkik başına istem (Accession No) ve tahsilat tek işlemde oluşur. Ayrıntı: `radyoloji-hasta-kabul`.
3. **Yeni hasta:** önce hasta kartı açılır. Ayrıntı: `hasta-arama-kayit`.
4. **Polikliniğe bağlı merkezde hekim istemi:** hekim muayenede görüntüleme isterse istem başvuruda **bekler**; başvuru kartında **🩺 Doktor İstemi** ile ücretlendirip **💾 Kaydet** deyince çalışma listesine düşer. Ayrıntı: `basvuru-acma`.
5. **Tahsilat:** kabul penceresinde **💵 Tahsilat Al** ya da başvuru kartının Tahsilat sekmesinde **💵 Nakit** / **💳 POS**.
6. **Sonuç teslimi:** onaylı raporu hastaya verirken **Radyoloji › Sonuç Teslim › 📦 Teslim Et**. Ayrıntı: `radyoloji-sonuc-teslim`.

## Radyoloji teknisyeni
1. **Radyoloji › Çalışma Listesi**, çip **Bekleyen Çekim**: sıradaki hastalar.
2. İstemi açıp (**✎ Aç / Düzenle**) **Kontrol Listesi**'ni (gebelik, metal, kreatinin vb.) doldurun.
3. Çekimden sonra **✔ Çekildi İşaretle**; açılan **Sarf Onayı** penceresinde kontrast / malzemeyi onaylayın.
Ayrıntı: `radyoloji-calisma-listesi`.

## Radyolog
1. **Radyoloji › Çalışma Listesi**, çip **Raporlanacak** (ya da **Onay Bekleyen**).
2. **✎ Rapor Yaz** → şablon kendiliğinden gelir, makrolarla yazın, **💾 Taslak Kaydet**.
3. **✍ Onayla ve İmzala**; asistan / genç hekim ise **➜ Uzmana Gönder**.
4. Kritik bulgu varsa **⚠ Kritik Bulgu Bildir** (bildirim kaydı olmadan rapor onaylanmaz).
Ayrıntı: `radyoloji-rapor-yazma-onay`.

## Banko (akşam)
1. Açık borçları kontrol edin: oturum kartında **Açık Borçlar** sekmesi.
2. POS cihazının gün sonu fişindeki toplamı **POS Gün Sonu** sekmesine girin.
3. **🔒 Gün Sonu**: nakdi sayın, yarına bırakılacak tutarı yazın, **🔒 Oturumu Kapat** (ya da **📨 Teslime Gönder**).
Ayrıntı: `banko-oturum-gun-sonu`.

## Yönetici / sorumlu
- **Radyoloji › Pano**: bugünkü randevu, çekim bekleyen, açık kritik bulgu, bugün onaylanan; cihaz doluluğu ve radyolog yükü.
- **Kayıt Kabul › Banko Onayları**: açılış / gün sonu onayı bekleyen oturumlar.
- **e-Nabız › Gönderim Kuyruğu**: onaylı raporların 409 paketleri. Ayrıntı: `enabiz-gonderim`.

## Sık karşılaşılan sorunlar
- **"Tahsilat için açık banko oturumu gerekiyor."** → önce vardiyanızı açın (`banko-oturum-gun-sonu`).
- **Hasta çalışma listesinde yok** → kabul yapılmamış ya da hekim istemi başvuruda ücretlendirilip kaydedilmemiş. Randevu tek başına çalışma listesine iş düşürmez; istem hasta **gelince** doğar.
- **Bir menü görünmüyor** → rolünüzde o ekranın yetkisi yok; bkz. `yetki-ve-erisim`.
- **Ekranın üstünde "DEMO ORTAMI" / "EĞİTİM ORTAMI" yazıyor** → gerçek kurulumda değilsiniz; bkz. `demo-egitim-ortami`.

## Örnek sorular
- Görüntüleme merkezinde günlük iş akışı nasıl?
- Banko sabah ilk ne yapmalı?
- Hasta geldiğinde kabul nasıl yapılır?
- Teknisyen hangi ekranda çalışır?
- Radyolog raporu nereden yazar?
- Rapor hastaya nasıl teslim edilir?
- Hasta neden çalışma listesine düşmedi?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Radyoloji.ts, web/src/sayfalar/listeTanimlari.Ticari.ts (banko)
- web/src/sayfalar/liste/randevuAksiyonlari.ts (cihazlı randevuda Geldi = kabul)
- web/src/bilesenler/radyoloji/IstemAkisi.tsx (akış şeridi)
- dokuman/00_TARIHCE.md (310-320 radyoloji kabul, 912-919 başvuru → istem banko kapısı, 987 banko vardiyası)

## Doğrulama durumu
Kod incelemesiyle yazıldı; adımların sırası görüntüleme merkezi personeliyle ekran üzerinde doğrulanmadı. İnsan doğrulaması bekliyor.
