# İhracat e-Fatura — Özet ve Müşteri Dağıtım Checklist'i

izibiz üzerinden GİB İhracat e-Faturası entegrasyonu. Bu oturumda uçtan uca çalışır
hale getirildi (izibiz kabul etti). Aşağıda: yapılan değişiklikler, müşteriye dağıtım
adımları ve bilinen sınırlar.

---

## 1. GİB İhracat kuralları (öğrenilenler)

| Kural | Uygulama |
|---|---|
| Belge tipi + senaryo | `documentTypeCode=ISTISNA`, `profile=IHRACAT` (Senaryo=3) |
| Muhasebe alıcısı | **Gümrük** ve Ticaret Bakanlığı, VKN **1460415308** (ULUS/ANKARA) — `customerParty` |
| Gerçek (yurt dışı) alıcı | `buyerCustomerParty` + `schemeId:"PARTYTYPE"`, `partyType:"EXPORT"` |
| Satır delivery | En az bir satırda `delivery/deliveryAddress` **zorunlu** |
| Alıcı alias | İhracat'ta `receiverAlias` **gönderilmez** (izibiz Gümrük'e otomatik yönlendirir) |
| KDV | %0 → `taxExemptionCode` **zorunlu** (varsayılan **301** Mal ihracatı; hizmet=302) |
| KDV typeCode | Her zaman `0015` (izibiz'de `9015` geçersiz) |
| Gönderim formatı | JSON (`_IzibizJSONOlustur` → `SendInvoice`), XML değil |

---

## 2. Kod değişiklikleri (UEBelgeOlusturucu.pas) — **müşteri EXE'si yeniden derlenmeli**

- **Record alanları:** `TEBelgeSatir.GTIP`; `TEBelgeBaslik`: IhracatVar, TeslimSartiKodu, TasimaSekliKodu, KapCinsiKodu, FOBDeger, KapAdedi
- **Okuma helper'ları:** `IhracatKodOnEk`, `IhracatSayiParse`, `IhracatBilgisiOku` (REHBERBILGI YERI=132 BOLUM='İhracat'), `IhracatEksikAlanlar`
- **Emisyon helper'ları:** `GumrukCustomerPartyOlustur`, `IhracatSatirDeliveryOlustur`
- **VerileriOku:** Senaryo=3'te İhracat şablonu + satır GTIP okur; KDV istisna Senaryo=3'te de okunur (boşsa 301)
- **MenuHazirla:** İhracat eksik-alan **validasyonu** (Teslim/Taşıma/Kap/FOB + ürün GTIP → uyarı+dur, numara tüketmeden) + İhracat'ta **alias sorgusu atlanır** (zorla e-Fatura)
- **_IzibizJSONOlustur:** docType→ISTISNA, customerParty→Gümrük + buyerCustomerParty(EXPORT), satır `delivery`, taxExemptionCode(KDV=0), `9015→0015`, İhracat'ta receiverAlias yok
- **AliciIletisimGetir:** yanlış `REHBER.EMAIL` sorgusu düzeltildi (kaynak REHBERILETISIM); customerParty email/tel yalnız e-Arşiv'de

### Bu oturumdaki diğer e-Fatura düzeltmeleri (İhracat dışı)
- Tevkifat: withholding `TaxableAmount` = KDV tutarı (net değil) — JSON+XML
- İstisna (Tipi=24): header `taxExemptionCode/Reason` — JSON+XML

### UFaturalar.pas
- Grid'de `EFATURASONUC`=3 ("Hata/Red") hücresine **çift tık → Mesaj Geçmişi** açılır

---

## 3. DB scriptleri — **müşteri DB'sine (ana DB, GENDEPO değil) deploy edilmeli**

### a) `ihracat_sablon_kur.sql` — GENINI kod listeleri + şablon
```
sqlcmd -S <SUNUCU> -U sa -P <SIFRE> -d <MUSTERI_DB> -C -f 65001 -i ihracat_sablon_kur.sql
```
- 3 GENINI listesi: İhracat_Teslim_Şartı (15 INCOTERMS), İhracat_Taşıma_Şekli (8), İhracat_Paket_Kap (27)
- REHBERAYAR 'İhracat' şablonu (YERI=132): 5 alan (3 combo + FOB + Kap Adedi)
- İdempotent (tekrar çalıştırılabilir; kayıtlı liste varsa yeniden kullanır)

### b) `sp_Prog_EBelge_GidenFaturaDetay.sql` — GTIP kolonu eklendi
```
sqlcmd -S <SUNUCU> -U sa -P <SIFRE> -d <MUSTERI_DB> -C -I -f 65001 -i sp_Prog_EBelge_GidenFaturaDetay.sql
```
- **`-I` ŞART** (SET QUOTED_IDENTIFIER ON). QI OFF olursa SP filtered-index/computed-column'da patlar (Msg 1934).
- Dosyada `SET QUOTED_IDENTIFIER ON` header'ı da var; app/FireDAC normalde QI ON çalışır.

---

## 4. Kullanıcı/veri ön koşulları (müşteri)

- [ ] İhraç edilecek **ürünlerin stok kartında GTIP** dolu olmalı (`STOKLAR.GTIP`, UStokWizard "GTIP" alanı)
- [ ] İhracat faturası **Senaryo = İhracat (3)** seçilmeli
- [ ] Fatura detayında **"İhracat" şablonu** doldurulmalı: Teslim Şartı, Taşıma Şekli, Kap Cinsi, FOB Değeri, (Kap Adedi)

---

## 5. Kullanım akışı

1. İhracat faturası oluştur (Senaryo=3) → satırları + ürün GTIP'leri
2. Detay > "İhracat" şablonunu doldur
3. **Hazırla** → eksik alan varsa uyarır ve durur; tamamsa numara+ETTN üretir
4. **Gönder** (test/üretim) → izibiz'e JSON
5. **Mükerrer (10009 duplicate) gelirse:** **Sıfırla → Hazırla** (taze ETTN+numara) → tekrar gönder
   - *Not: "Seri Değiştir" ETTN'yi yenilemez, duplicate'i çözmez.*

---

## 6. Bilinen sınırlar / sonraki işler

- **FOB başlık düzeyinde** tutulur → her satıra aynı yazılır. Tek satırlı ihracatta doğru; çok satırlıda FOB tekrarlanır (gerekirse satır-bazlı FOB'a çevrilir).
- **deliveryAddress.country = 'TR'** sabit (şablonda yapısal yurt dışı ülke alanı yok; schematron sadece elementin varlığına bakıyor). Gerçek destinasyon ülkesi gerekirse alan eklenir.
- **Hizmet ihracatı**: varsayılan istisna kodu 301 (Mal). Hizmet için fatura KDV istisna nedeninden 302 seçilerek override edilir.
- **İhraç Kayıtlı (Tipi=9): YAPILMADI** — izibiz örneği yok; tecil-terkin yapısı için gerçek örnek/spec gerekli.
- **Tıbbi cihaz ihracatı** (İhracat profili + UTS kimliği birlikte): şu an desteklenmiyor (UTS kimlik mantığı yalnız Senaryo=8'de). Gerekirse ayrıca ele alınır.

---

## 7. Dağıtım checklist (özet)

- [ ] `ihracat_sablon_kur.sql` müşteri DB'sine (`-f 65001`)
- [ ] `sp_Prog_EBelge_GidenFaturaDetay.sql` müşteri DB'sine (**`-I`** + `-f 65001`)
- [ ] Yeniden derlenmiş EXE müşteriye
- [ ] Ürün stok kartlarına GTIP girişi
- [ ] Bir test faturasıyla uçtan uca doğrulama (Senaryo=3 → şablon → Hazırla → Gönder)
