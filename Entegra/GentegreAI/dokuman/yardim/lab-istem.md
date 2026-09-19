---
id: lab-istem
baslik: Laboratuvar istemi açma
modul: lab
ekran: lab-istem
rota: /lab-istem
surec: lab
roller: hekim, lab_teknisyen, banko
dil: tr
surum: 1
urun_modu: 2
yetki: lab
erisim: kullanici
ozet: Laboratuvar › İstemler ekranında tetkik / panel isteme, tüp planı ve barkod üretimi, etiket basma, istem düzeyinde kabul / ret ve dış istem girişi.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Laboratuvar istemi, bir başvuruya bağlı tetkik listesidir. İstem kaydedilince tüp planı ve barkodlar sistem tarafından üretilir; numune alınır, kabul edilir, cihazda çalışılır ve sonuç onaylanınca hekime döner. Satır = istem; tetkikler ve sonuçları kartın "Tetkikler" detayındadır.

## Ekrana giriş yolları
- Sol menü: **Laboratuvar › İstemler** (ekran başlığı "Laboratuvar İstemleri").
- Muayene kartı › **İstem & Sonuçlar** sekmesi › **🔬 İstem Aç** (istem başvuruya bağlanır).
- Komut paleti (Ctrl+K) › "İstem". Kart adresi `/lab-istem/[kayıt no]`.
- **📷 Barkod Okut** ile tüp barkodu okutulunca ilgili istem kendiliğinden bulunur.

## Ön koşullar
- **lab** yetkisi (Gör / Ekle); barkod / etiket / kabul için **lab.numune**, sonuç girişi için **lab.sonuc**.
- Hasta ve (kurum içi istemde) açık başvuru; dış kurum isteminde gönderen kurum ve dış doktor seçilir.
- Tetkikler **Laboratuvar › Tetkik Kataloğu**'nda, paneller **Paneller**'de tanımlı olmalı; referans aralığı olmayan tetkik bayrak üretemez.

## Alanlar
Kimlik şeridi: **Hasta (zorunlu)**, Kaynak (kurum içi / dış kurum; varsayılan "Dış kurum"), Öncelik (rutin / öncelikli / acil), Bölüm, İstem Tarihi, Durum.
"İstem" sekmesi: Dış Kurum, Kurum, İsteyen Hekim, İstem No (otomatik), Başvuru (Protokol Id), Klinik Bilgi, Tanı (ICD-10).
"Süreç" sekmesi: Numune Alma, Sonuç, Hedef Bitiş (TAT), Açıklama.
"Tetkikler" detayı: Sıra, Tetkik (arama), Panel, Kod, Test Adı, Durum, Sonuç, Birim, Referans Aralığı, Değerlendirme, Cihaz, Giriş, Numune / Barkod, Sonuç Zamanı, Açıklama.
"Numuneler" detayı: Barkod, Numune, Tüp, Durum, Alan, Alım Yeri, Alım, Kabul, Kalite, Hemoliz / Lipemi / İkter indeksleri, Saklama Yeri, °C, Ret, Ret Nedeni, Ret Açıklaması.

## Liste kolonları ve çipler
Kolonlar: İstem No · Hasta · Protokol · Dosya No · İstem (tarih) · Öncelik · Sonuç (tarih) ve kaynak / durum kolonları.
Çipler: **Numune Bekliyor · Kabul Edildi · Ret · Acil · Dış İstem · Tümü**. Tarih seçimi hazır aralık kutusundan, açılışta **Bugün**.
Satır seçilince altta o istemin tetkikleri, referans aralığı ve bayrağı bölüm bölüm görünür.

## İşlemler (düğmeler)
- `lab-istem.yeni` **＋ Yeni** (Ctrl+N), `lab-istem.duzenle` **✎ Düzenle**, `lab-istem.sil` **🗑 Sil** (sağ tuş).
- `lab.sonuc-gir` **🧪 Sonuç Gir**: istemin bütün tetkiklerini tek pencerede elle girme.
- `lab.barkod-okut` **📷 Barkod Okut**: tüpü okutarak istemi bul (satır seçmek gerekmez).
- `lab.etiket` **🏷 Etiket Bas**: istemin tüm tüp etiketleri tek sayfada.
- `lab.istem-kabul` **✔ Kabul** (yeşil) / `lab.istem-ret` **✖ Ret** (kırmızı): istemin tüm tüpleri birlikte.
- `lab.rapor` **🖨 Sonuç Raporu**: hastaya verilen belge (yalnız onaylı sonuçlar; açık kültür / genetik varsa TASLAK damgası).
- `lab.numune-plani` **🏷 Barkod Üret**, `lab.ekim` **🧫 Ekim Yap (kültür)**, `lab.genetik-vaka` **🧬 Genetik Vaka Aç** (sağ tuş).
- `lab.dis-gonder` **🏍️ Dış Lab'a Gönder**, `lab.saklama` **🧊 Saklama Yeri** (ikinci sıra).
- **🖨️ Yazdır**.

## Adım adım
1. Hekimseniz muayene kartında **İstem & Sonuçlar › 🔬 İstem Aç**; "Laboratuvar"ı seçip tetkik ya da paneli işaretleyin.
2. Bankodan açıyorsanız **Laboratuvar › İstemler › ＋ Yeni**; hastayı seçin, kaynak / öncelik / klinik bilgiyi girin.
3. "Tetkikler" detayına tetkik ya da panel satırları ekleyin; **Kaydet**. Tüp planı ve barkodlar sunucuda üretilir (aynı tüp tipindeki tetkikler tek barkoda bağlanır).
4. **🏷 Etiket Bas** ile tüp etiketlerini basın; kan alma bankosu tüpleri hazırlar.
5. Tüpler geldiğinde **📷 Barkod Okut** → istem açılır; uygunsa **✔ Kabul** (numune kalitesi seçilir, süre başlar), değilse **✖ Ret**.
6. Sonuçlar cihazdan ya da **🧪 Sonuç Gir** ile girilir; onay Sonuç Onay Kuyruğu'nda yapılır.
7. Hastaya belge için **🖨 Sonuç Raporu**.

## Durumlar
- İstem: **Numune Bekliyor (1)** → **Kabul Edildi (2+)**; ret sayısı > 0 ise "Ret" çipinde görünür.
- Numune: etiketlendi → alındı → kabul → cihazda → saklamada; ret numuneyi kapatır, tetkikler "tekrar numune bekliyor"a döner.
- Tetkik sonucu: onay bekliyor → teknik onay → onaylı (yayınlandı); düzeltilen eski satır iptal.

## Yetki
- **lab**: istem ve rapor. **lab.numune**: barkod, etiket, kabul / ret, saklama. **lab.sonuc**: sonuç girişi. **lab.kultur**: ekim. **lab.genetik**: vaka. **lab.dislab**: dış lab sevki. **lab.tetkik**: katalog / panel.
- Dış kurum portal kullanıcısı yalnız kendi gönderdiği istemleri görür.

## Sık görülen hata ve uyarılar
- **"Süre (TAT) şimdi başladı."** → bilgi: TAT kabulde başlar, istemde değil.
- **"İstemin TÜM tüpleri REDDEDİLECEK …"** → onay sorusu; ret geri alınmaz, hastadan yeniden numune alınır.
- **"Saklama yeri zorunlu."** (DOGRULAMA) → 🧊 Saklama Yeri penceresinde dolap / raf yazın.
- **"Tamamlanmış muayeneye istem eklenemez."** (IS_KURALI) → kapalı muayene; yeni başvuru gerekir.
- **"Tetkik kataloğu boş."** → Tetkik Kataloğu'nu doldurun.
- Barkod geçersiz → barkod kontrol hanelidir; tek hane hatası kabul edilmez, tüpü yeniden okutun.
- **"Aynı tetkik iki kez gönderilemez"** (dış lab) → yalnız kabul edilmiş numune sevk edilir; dış lab reddettiyse yeni numuneyle tekrar gönderilebilir.

## Diğer modüllere etkisi
- Onaylı sonuçlar muayene kartına döner ve e-Nabız "Laboratuvar Sonuç" (105) paketi üretilir.
- Kabul edilmiş numune cihaz çalışma listesine düşer (host query); kabul edilmeyen düşmez.
- Panik değerler Sonuç Onay Kuyruğu'nda öne çıkar; kritik sonuç bildirimi orada yapılır.
- Kültür ve genetik istemleri aynı istem numarasıyla mikrobiyoloji / genetik listelerine geçer; sonuç raporu üçünü tek sayfada basar.

## Yapılmaması gerekenler
- Kaç tüp gerektiğini elle hesaplamayın; plan sunucuda üretilir.
- Kabul edilmemiş numuneyi cihazda çalıştırmayın; sonucu sonradan silinir.
- Aynı hastanın ikinci tüpünü listede ad arayarak kabul etmeyin; barkod okutun.

## Örnek sorular
- Laboratuvar istemi nasıl açılır?
- Tüp etiketini nereden basarım?
- İstemdeki tetkikleri toplu nasıl kabul ederim?
- TAT süresi ne zaman başlar?
- Dış kurumdan gelen numuneyi nasıl kaydederim?
- Sonucu elle nasıl girerim?
- Hastaya sonuç raporunu nereden basarım?
- Barkod okutunca istem neden bulunmuyor?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Laboratuvar.ts (lab-istem)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (lab-istem-liste)
- api/src/Gentegre.Cekirdek/Katalog/KartKatalogu.Saglik.LabIstem.cs, KaynakKatalogu.Saglik.LabIts.cs
- web/src/sayfalar/liste/labAksiyonlari.ts
- dokuman/01_API_SOZLESMELERI.md §9.3, §9.6, §9.8, §9.9, §9.11
- db/447_ai_rehber.sql (lab-istem konusu)

## Doğrulama durumu
Kod incelemesiyle yazıldı.
