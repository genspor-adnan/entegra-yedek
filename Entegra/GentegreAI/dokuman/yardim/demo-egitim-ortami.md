---
id: demo-egitim-ortami
baslik: DEMO / EĞİTİM ORTAMI etiketi ve programı deneyerek öğrenme
modul: genel
ekran:
rota:
surec: egitim
roller: tum_kullanicilar
dil: tr
surum: 1
urun_modu: 0
yetki:
erisim: kullanici
ozet: Üst şeritteki DEMO ORTAMI / EĞİTİM ORTAMI etiketinin anlamı, gerçek (canlı) kurulumdan farkı, eğitim kurulumunda güvenle deneme yapma ve örnek kullanıcılar.
guncelleme: 2026-10-10
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Programı öğrenirken gerçek hasta ve kasa kayıtlarına dokunmamak için kurumlara ayrı bir **demo** ya da **eğitim** kurulumu verilebilir. Hangi kurulumda olduğunuzu karıştırmamanız için ekranın üst şeridinde belirgin bir etiket görünür.

## Etiketin anlamı
- **DEMO ORTAMI** (turuncu): tanıtım / deneme kurulumu. Veriler örnektir.
- **EĞİTİM ORTAMI** (mor): personel eğitimi için kurulum. Veriler örnektir; hata yapmaktan çekinmeden pratik yapabilirsiniz.
- **Etiket yoksa** gerçek (canlı) kurulumdasınız: girdiğiniz her kayıt gerçektir, tahsilat kasaya, rapor hastanın dosyasına ve e-Nabız'a gider.

## Eğitim ortamında nasıl çalışılır
1. Size verilen eğitim kullanıcısıyla giriş yapın; üstte **EĞİTİM ORTAMI** yazdığını kontrol edin.
2. Rolünüzün günlük akışını baştan sona deneyin; görüntüleme merkezi için bkz. `goruntuleme-gunluk-akis`.
3. Örnek hasta açın, randevu verin, kabul yapın, tahsilat alın, gün sonunu kapatın; teknisyen ve radyolog rolleriyle çekim ve rapor adımlarını deneyin.
4. Takıldığınız yerde sağdaki yardım asistanına ekranınızla ilgili soru sorun.

## Örnek kullanıcılar
Eğitim / demo kurulumunda genellikle her rol için ayrı örnek kullanıcı tanımlanır (ör. banko görevlisi, banko sorumlusu, radyoloji teknisyeni, radyolog). Kullanıcı adları ve parolaları kurumunuzun sistem yöneticisi ya da eğitmeniniz tarafından verilir. Her rol yalnız kendi yetkisindeki menüleri görür; başka rolün işini denemek için o rolün kullanıcısıyla girin.

## Ayar
Etiket kurulumun **genel.ortam** ayarından gelir: `canli`, `demo` ya da `egitim`. Bu ayarı bilgi işlem / sistem yöneticisi kurulum sırasında belirler; tanınmayan değer canlı sayılır. Ayar değiştirildiğinde etiket bir sonraki girişte görünür.

## Sık karşılaşılan sorunlar
- **Eğitimde girdiğim kayıt canlıda yok** → doğru; iki kurulum ayrı veritabanıdır, kayıtlar birbirine geçmez.
- **Etiketi görmüyorum ama eğitimde olduğumu sanıyorum** → canlıdasınız; çıkış yapıp eğitim adresinden girin ya da yöneticinize sorun.
- **Eğitim ortamında e-Nabız / SMS gönderilir mi?** → eğitim kurulumunda dış servislerin test ya da kapalı modda olması gerekir; emin değilseniz gerçek hasta bilgisi ve gerçek telefon numarası kullanmayın.

## Yapılmaması gerekenler
- Eğitim ortamına gerçek hasta bilgisi (TC kimlik no, telefon) girmeyin.
- Canlı kurulumda "deneme" kaydı açmayın; deneme için eğitim ortamını kullanın.

## Örnek sorular
- Üstte DEMO ORTAMI yazıyor, bu ne demek?
- Eğitim ortamında yaptığım kayıtlar gerçek mi?
- Canlı ortamda olduğumu nasıl anlarım?
- Eğitim kullanıcısı nereden alınır?
- Programı denemek için hangi ortamı kullanmalıyım?

## Kaynaklar
- web/src/sayfalar/Kabuk.tsx (ust-ortam etiketi), web/src/tema.css
- api/src/Gentegre.Api/Servisler/KimlikServisi.cs (OrtamAsync), api/src/Gentegre.Veri/Depolar/AyarDeposu.cs (genel.ortam)

## Doğrulama durumu
Etiket ve ayar kod incelemesiyle yazıldı. Örnek kullanıcıların adları ve eğitim kurulumunda dış servislerin (e-Nabız, SMS) davranışı kurulum başına değişir; insan doğrulaması bekliyor.
