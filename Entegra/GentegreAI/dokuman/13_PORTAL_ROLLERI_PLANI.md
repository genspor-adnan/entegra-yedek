# Portal rolleri planı — Dış Doktor · Dış Kurum · Hasta

**Durum:** tasarım. Kod yazılmadı (kullanıcı: *"şimdilik yalnız tasarla"*).
**İstek (18.09.2026):** *"Dışardan hasta gönderen 'Dış Doktor' gönderdiği
hastaların sonuçlarını görecek, dışardan hasta gönderen 'Dış Kurum' gönderdiği
hastaların sonuçlarını görecek. Hasta rolü olan hastalar randevu alıp
sonuçlarını, kullanacakları ilaçları vb. görebilecekler."*

---

## 1. Asıl iş rol değil, KAPSAM

Üç rolün yetki listesini yazmak yarım saatlik iş. Tehlike şurada: bir role
`lab.sonuc` yetkisi verildiği anda o kişi **bütün hastaların** sonucunu görür.
Portal rolünü kapsamsız açmak, rolü doğru görünen bir veri sızıntısı yapar.

Bugün elimizde ne var:

| Parça | Durum |
|---|---|
| `kullanici_kapsam` (kullanici_id · tur · hedef_id) | **var** |
| `KaynakTanimi.KapsamKolonu` → `SorguUretici` WHERE ekler | **var** |
| Bağlı kaynaklar | yalnız **cari · belge · kasa** (`KapsamKolonu` verilmiş olanlar) |
| lab-sonuc · lab-istem · radyoloji · muayene · randevu | **kapsam kolonu YOK** |

Yani altyapı yarım: ticari tarafta çalışıyor, klinik tarafta hiç bağlanmamış.

**Kapsam, kayıt sahipliğine göre de farklı okunuyor.** "Bu satır bana ait mi"
sorusunun cevabı üç rolde üç ayrı yoldan geliyor; tek bir `hedef_id` listesi
bunu anlatmıyor:

| Rol | "Benim" demek | Bağ |
|---|---|---|
| Dış Doktor | gönderdiğim hasta | `belge_satir_rol` (rol = 1 "Gönderen", `taraf_id` = ben) |
| Dış Kurum | gönderdiğim istem | `lab_istem.dis_kurum_id` = ben |
| Hasta | kendi kaydım | `belge_basvuru.hasta_id` / `belge.taraf_id` / `randevu.hasta_id` = ben |

---

## 2. Önerilen mekanizma: portal koşulu

`KaynakTanimi`'ye **`PortalKosulu`** eklenir: `{kullanici}` yer tutuculu bir SQL
parçası. İstek sahibinin rolü **portal türündeyse** (`rol.portal_turu`, yeni
smallint kolon: 0 iç kullanıcı · 1 dış doktor · 2 dış kurum · 3 hasta) sorguya
o koşul **parametreyle** eklenir. Metin istekten gelmez, katalogda durur.

```
lab-sonuc:
  1 → exists (select 1 from belge_satir_rol bsr
               join belge_satir bs on bs.id = bsr.belge_satir_id
              where bs.belge_id = i.belge_id and bsr.rol = 1
                and bsr.taraf_id = {kullanici})
  2 → i.dis_kurum_id = {kullanici}
  3 → i.taraf_id = {kullanici}
```

Aynı üçlü `lab-istem`, `radyoloji-istem`, `muayene`, `randevu`, `belge` ve
`hasta` kaynakları için de yazılır. **Koşulu olmayan kaynak portal rolüne
kapalıdır** (beyaz liste mantığı): yeni bir ekran eklenince portal rolü onu
kendiliğinden görmez — unutulan kaynak "hepsini göster" değil "hiç gösterme"
olmalı.

**Kural veritabanında da dursun.** Ekran/API katmanı tek duvar olmamalı; satır
düzeyi güvenlik (RLS) ya da portal rolünün yalnız `v_portal_*` görünümlerini
okuyabilmesi değerlendirilmeli. Bugüne kadarki desen budur: kural DB'de,
ekran yalnız kullanıcıyı boşa uğraştırmamak için bilir.

---

## 3. Rol taslakları

### Dış Doktor (`dis_doktor`)
Kendi gönderdiği hastanın **sonuç ve raporları**; hasta listesine erişimi
kapsamla sınırlı. Yeni istem AÇABİLİR (kurum isterse kapatır).
`lab.sonuc` (gör) · `lab` (gör) · `radyoloji` (gör) · `hasta` (gör, kapsamlı) ·
`randevu` (gör + ekle, kurum tercihi) · `dokum` (kendi dökümü).
**Görmez:** ücret/tahsilat, başka hekimin hastası, kurum içi ekranlar.

### Dış Kurum (`dis_kurum`)
`dis_istem_kurumu` şablonu zaten var (lab modülü) ama **kapsamı yok** - bu
plan onu da kapsıyor: aynı portal koşulu ona da bağlanmalı, yoksa mevcut rol
de geniş görüyor.
Kendi gönderdiği istemler, numune durumu, sonuç ve dış lab iş emri.
**Görmez:** başka kurumun istemi, fiyat/anlaşma detayı (kurum tercihi).

### Hasta (`hasta_portal`)
Kendi randevusu (alma/iptal), kendi sonuçları (hekim onaylı olanlar), reçete /
kullanacağı ilaçlar, onam metinleri, kendi belgeleri.
**Görmez:** başkasının hiçbir kaydı; **onaylanmamış** sonuç (hekim onayından
önce sonuç hastaya gösterilmez - bu klinik bir karardır, teknik değil).

---

## 4. Hasta portalının ayrı sorunları

Hasta girişi kurum içi kullanıcıdan farklı bir yüzeydir:

- **Kimlik:** TC + doğum tarihi + SMS doğrulama; parola yerine tek kullanımlık
  kod tercih edilebilir.
- **Hesap açma:** hasta kaydından otomatik mi, başvuruda talep üzerine mi?
  (`taraf_kullanici` satırı hasta `taraf` id'siyle açılır - şema hazır.)
- **KVKK:** aydınlatma metni + açık rıza kaydı, erişim günlüğü (kim ne zaman
  hangi sonuca baktı).
- **Reşit olmayan / vekâlet:** veli ya da vasi kendi hesabından çocuğun
  kayıtlarını görebilmeli - `kullanici_kapsam` bunu taşıyabilir.
- **Onaylı sonuç kuralı:** hangi sonuç ne zaman görünür (hekim onayı, kritik
  değer bildirimi sonrası bekletme).

---

## 5. Sıra önerisi

1. `PortalKosulu` + `rol.portal_turu` + katalog koşulları (lab/radyoloji/
   muayene/randevu/belge/hasta) ve testleri.
2. Dış Kurum: mevcut `dis_istem_kurumu` rolünü kapsama bağla (var olan rol,
   bugün geniş görüyor - **öncelik**).
3. Dış Doktor rolü.
4. Hasta portalı (ayrı giriş yüzeyi + KVKK + onaylı sonuç kuralı).

ERP standart rolleri bu plandan bağımsız olarak **tamamlandı** (795).
