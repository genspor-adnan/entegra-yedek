---
id: icmal-hasta-borc-takibi
baslik: Hasta Borç Takibi
modul: kayit_kabul
ekran: hasta-borc-takibi
rota: /hasta-borc-takibi
surec: icmal
roller: vezne, banko, muhasebe
dil: tr
surum: 1
urun_modu: 2
yetki: hasta.borc_takip
erisim: kullanici
ozet: Açık borcu olan hastaları listeler; toplu SMS / e-posta hatırlatma, tahsilata çağırma, ödeme sözü / planı, not ve A4 borç bildirim mektubu buradan yapılır.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hangi hastaların ödenmemiş hasta payı var, kime hatırlatma yapıldı, kim ödeme sözü verdi?" sorusunu cevaplar ve takibin kendisini yürütür: hatırlatma gönderme, söz / plan kaydı, tahsilata çağırma işareti ve not. Vezne, banko ve muhasebe görevlileri kullanır. Yalnız HBYS kurulumunda vardır.

## Bu ekranda neler yapabilirsiniz
- **Durum çipine göre süzmek** — Tümü, Hatırlatma bekliyor, Hatırlatıldı, Söz verdi, Planlı, Söz tutulmadı, Tahsilata çağrılacak.
- **En az borç tutarı vermek** — "En az borç" kutusuna tutar yazın; altındaki borçlar gizlenir.
- **Hasta seçmek** — satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); başlıktaki kutu hepsini seçer.
- **SMS / e-posta hatırlatması göndermek** — hastaları seçip "📱 SMS Hatırlat" ya da "✉ E-posta Hatırlat"; onaydan sonra bildirim kuyruğuna konur.
- **Tahsilata çağırmak** — seçili hastalar için "📞 Tahsilata Çağır" işareti koyun.
- **Ödeme sözü / planı kaydetmek** — tek hasta seçip "🤝 Ödeme Sözü / Plan"; tür, tutar, vade (planda ilk taksit ve taksit sayısı) girip Kaydet.
- **Not eklemek** — tek hasta seçip "📝 Not".
- **Borç mektubu yazdırmak** — hastaları seçip "🖨️ Mektup Yazdır"; "Borç Mektubu (A4)" sekmesi açılır ve yazdırma penceresi gelir.
- **Hasta icmalini açmak** — hasta adına tıklayın; satırdaki ▸ işareti açık protokolleri gösterir.
- **Geçmişi ve sözleri izlemek** — Hatırlatma Geçmişi ve Ödeme Sözleri / Planları sekmeleri; bir kaydı "kaldır" ile geri alın. "⏳ Alacak Yaşlandırma" düğmesi yaşlandırmaya geçer.

## Ekrana giriş
- Sol menü **Kayıt Kabul › Hasta Borç Takibi** (`/hasta-borc-takibi`), yalnız HBYS modunda.
- Alacak Yaşlandırma ekranındaki "📞 Hasta Borç Takibi" düğmesi.
- Görmek için `hasta.borc_takip` Gör; hatırlatma, söz / plan, işaret ve not için Ekle; kayıt kaldırmak için Değiştir yetkisi gerekir.

## Süzgeçler
- Durum çipleri (yanında sayıları) ve **En az borç** (₺). Süzgeç değişince seçim temizlenir.
- Tarih süzgeci yoktur; liste bugünkü açık borçları gösterir.

## Özet ve sekmeler
Özet kutuları: **Borçlu Hasta** (tahsilata çağrılacak sayısı) · **Toplam Açık** (hasta payı − tahsilat) · **30+ Gün** · **Hatırlatma Bekleyen** (son 7 günde hatırlatılmadı) · **Bu Ay Tahsil** · **Söz Verilen** ve **Ödeme Planı** (vadesi gelmemiş) · **Tutulmayan Söz**.

Sekmeler:
- **Borçlular** — Hasta, Dosya No, Telefon (maskeli), Son Başvuru, Protokol, Açık Borç, Gün, Son Tahsilat, Son Hatırlatma, Söz / Plan, Durum.
- **Hatırlatma Geçmişi** — Zaman, Hasta, İşlem, Kanal, Tutar, Vade, Açıklama, Yapan, Sonuç.
- **Ödeme Sözleri / Planları** — Hasta, Tür, Tutar, Vade / İlk Taksit, Taksit, Açık Borç, Durum.
- **🖨️ Borç Mektubu (A4)** — seçili hastaların borç bildirim mektubu önizlemesi.

## Rakamlar nereden gelir
- Uç: `GET /api/hasta-borc-takibi` ve işlem uçları (`/hatirlat`, `/soz`, `/isaret`, `/not`, `/islem/{id}/kaldir`) — `HastaBorcTakipUclari.cs`.
- Borç tek kaynaktan (`HastaBorcSorgusu`, Hasta İcmali ve Alacak Yaşlandırma ile aynı): başvuru başına hasta payı = genel toplam − kurum payı (SGK + ÖSS); kalan = hasta payı − net tahsilat (iade düşülür, iptal sayılmaz).
- **Gün** = en eski açık başvurudan bu yana geçen gün.
- **Durum**: işaret varsa "Tahsilata çağrılacak"; söz / plan vadesi geçmiş ve borç açıksa "Söz tutulmadı" (ayrıca saklanmaz, hesaplanır); son 7 günde hatırlatıldıysa "Hatırlatıldı"; değilse "Hatırlatma bekliyor".

## Çıktı
Bu ekranda çıktı menüsü yoktur. **🖨️ Mektup Yazdır** seçili hastalar için A4 borç bildirim mektubunu tarayıcının yazdırma penceresiyle basar (PDF olarak kaydetme yazdırma penceresinden).

## Dikkat edilecekler
- Aynı hastaya aynı kanaldan 24 saat içinde ikinci hatırlatma konmaz; telefonu / e-postası olmayan hasta atlanır ve nedeni bildirilir.
- Yeni söz / plan kaydedilince hastanın önceki söz / planı kaldırılır.
- Kaldırılan kayıt silinmez; geçmişte "kaldırıldı" görünür.
- Söz ve plan tahsilat değildir; borç ancak vezneden tahsilat alınınca düşer.

## Örnek sorular
- Borcu 30 günü geçen hastalara toplu SMS nasıl gönderirim?
- Ödeme sözünü tutmayan hastalar kimler?
- Bir hastaya taksitli ödeme planı nasıl kaydederim?
- Seçtiğim hastalara borç bildirim mektubu nasıl yazdırırım?
- Bu ay borçlu hastalardan ne kadar tahsil ettik?
