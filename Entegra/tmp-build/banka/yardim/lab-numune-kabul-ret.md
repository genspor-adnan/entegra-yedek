---
id: lab-numune-kabul-ret
baslik: Numune kabul ve ret
modul: lab
ekran: lab-numune
rota: /lab-numune
surec: lab
roller: lab_teknisyen, hemsire
dil: tr
surum: 1
urun_modu: 2
yetki: lab.numune
erisim: kullanici
ozet: Laboratuvar › Numune Kabul ekranında tüp bazlı alındı / kabul / ret işlemleri, kalite ve ret nedeni seçimi, dış laba sevk ve barkod etiketi.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Numune Kabul laboratuvarın giriş kapısıdır: satır = tüp. Kabul edilen numunenin süresi (TAT) başlar ve cihaz çalışma listesine düşer; reddedilen numune kapanır ve tetkikler yeniden numune bekler. İstem düzeyinde toplu kabul / ret İstemler ekranındadır; tüp bazlı işlem burada yapılır.

## Ekrana giriş yolları
- Sol menü: **Laboratuvar › Numune Kabul**.
- Komut paleti (Ctrl+K) › "Numune".
- Tüp barkodu okutulduğunda İstemler ekranındaki **📷 Barkod Okut** ilgili kaydı getirir.

## Ön koşullar
- **lab.numune** yetkisi (Değiştir).
- Tüp etiketlenmiş olmalı (istem kaydedilince barkodlar üretilir; etiket İstemler ekranından basılır).
- Dış laba sevk için **lab.dislab** yetkisi ve tanımlı dış laboratuvar.

## Alanlar
Bu ekranın kartı yoktur; işlemler listeden düğmelerle yapılır. Kabulde **Numune kalitesi** (1 Uygun, 2 Hemolizli, 3 Lipemik, 4 İkterik, 5 Yetersiz miktar, 6 Pıhtılı, 7 Yanlış tüp, 8 Etiketsiz); rette **Ret nedeni** (aynı liste + 9 Diğer) ve isteğe bağlı açıklama sorulur.
Saklama yeri ve sıcaklık İstemler ekranındaki **🧊 Saklama Yeri** ile yazılır.

## Liste kolonları ve çipler
Kolonlar: Barkod · İstem No · Hasta · Tüp · Tetkik (sayı) · Öncelik · Alındı · Kabul · Bekleme (dk) · Kalite · Durum · HIL İndeks (hemoliz / lipemi / ikter). Dosya No, Ret Nedeni kolon seçicisinden açılır.
Çipler: **Kabul Bekleyen (varsayılan) · Etiketlendi · Kabul · Reddedilen · Tümü**; tarih süzgeci alım zamanına göre.

## İşlemler (düğmeler)
- `lab.numune-alindi` **🩸 Alındı İşaretle**: tüpün hastadan alındığını yazar.
- `lab.numune-kabul` **✔ Kabul Et**: kalite seçilir; "Süre (TAT) şimdi başladı" mesajı döner.
- `lab.numune-ret` **✖ Reddet**: ret nedeni + açıklama + onay; numune kapanır.
- `lab.dis-gonder` **🏍️ Dış Lab'a Gönder**: laboratuvar, tetkikler, taşıma koşulu ve kurye bilgisiyle sevk.
- `lab.barkod-yazdir` **🏷 Barkod Etiketi** (sağ tuş): tek tüp etiketi.
- `genel.yazdir` **🖨️ Yazdır**.

## Adım adım
1. **Laboratuvar › Numune Kabul** ekranını açın; "Kabul Bekleyen" çipi açık gelir.
2. Tüpün barkodunu okutun ya da listeden satırı seçin.
3. Hastadan yeni alındıysa **🩸 Alındı İşaretle**.
4. Tüp uygunsa **✔ Kabul Et** → kalite "1 - Uygun" (hafif kusurlu ama kabul edilen tüpte 2-8 seçilebilir; rapora düşer).
5. Uygun değilse **✖ Reddet** → ret nedenini seçin, açıklama yazın, onaylayın.
6. Numune kurumda çalışılmayacaksa **🏍️ Dış Lab'a Gönder**; takibi **Laboratuvar › Dış Lab Gönderimleri**'nden yapın.
7. Reddedilen numune için hastadan yeniden numune alın; tetkikler "numune bekliyor"a dönmüştür.

## Durumlar
- **Etiketlendi (1)** → **Alındı (2)** → **Kabul (3)** → cihazda / saklamada; **Ret (0)** numuneyi kapatır.
- Kabul zamanı TAT'ın başlangıcıdır; "Bekleme (dk)" alımdan kabule geçen süredir.
- HIL indeksi eşiği aşan sonuçlar Sonuç Onay Kuyruğu'nda "Numune Uygunsuz" çipinde toplanır.

## Yetki
- Kabul / ret / alındı / etiket: **lab.numune**. Dış lab sevki: **lab.dislab**. Listeyi görmek için **lab.numune** Gör.

## Sık görülen hata ve uyarılar
- **"Numune REDDEDİLECEK (…). …"** → onay sorusu; ret geri alınmaz.
- **"Geçerli bir ret nedeni seçin."** → listeden neden seçilmeden ret gönderilmez.
- **Kabul edilmiş tüp cihazda görünmüyor** → cihaz yalnız kabul edilmiş numuneyi çeker; kabul yapılmamış olabilir.
- **"Yalnız kabul edilmiş numune gönderilebilir"** (dış lab) → önce kabul edin.
- **YASAK (403)** → lab.numune yetkiniz yok.

## Diğer modüllere etkisi
- Kabul, İstemler ekranında istem durumunu "Kabul Edildi"ye çeker ve tetkik satırlarını cihaz çalışma listesine açar.
- Ret, hekimin muayene kartında "sonuç bekleniyor" olarak görünmeye devam eder; yeni tüp gerekir.
- Kalite işareti (hemoliz vb.) sonuç raporunda numune notu olarak basılır.

## Yapılmaması gerekenler
- Sebep seçmeden reddetmeyin; hasta ikinci kez kan verdiğinde aynı hata tekrarlanır.
- Kabul etmeden cihazda çalıştırmayın.
- "Diğer" nedenini kabul kalitesi olarak kullanmayın; o yalnız ret gerekçesidir.

## Örnek sorular
- Numuneyi nasıl kabul ederim?
- Hemolizli tüpü nasıl reddederim?
- Ret nedenleri neler?
- Reddedilen numunede tetkikler ne olur?
- TAT ne zaman başlar?
- Numuneyi dış laboratuvara nasıl gönderirim?
- Tek tüp etiketini nereden basarım?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Laboratuvar.ts (lab-numune)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (lab-numune-liste)
- api/src/Gentegre.Cekirdek/Katalog/KaynakKatalogu.Lab.cs (lab-numune)
- web/src/sayfalar/liste/labAksiyonlari.ts (kalite ve ret nedeni listeleri)
- dokuman/01_API_SOZLESMELERI.md §9.3, §9.10, §9.11
- db/447_ai_rehber.sql (lab-numune-kabul konusu)

## Doğrulama durumu
Kod incelemesiyle yazıldı.
