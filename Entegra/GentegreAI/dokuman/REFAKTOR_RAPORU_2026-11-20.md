# GentegreAI refaktör raporu — 20.11.2026

Kapsam: `api/src` (sunucu) ve `web/src` (istemci). Bu rapor yalnız **tarama sonucudur; kod değiştirilmedi**.
Sayılar arama (grep / satır sayımı) sonuçlarından gelir, yaklaşık kabul edilmelidir; bulgular tek tek elle
doğrulanmadı, testler bu tarama için koşulmadı.

Ölçek: sunucuda 678 C# dosyası (Api ~133 bin, Cekirdek ~48 bin, Veri ~15 bin satır; 278 uç, 95 servis, 45 depo
dosyası, 204 test dosyası). Web'de ~1250 TypeScript dosyası; `tema.css` 10.171 satır.

Öneri: A grubunun tamamı, ardından B1 ve B2.

## A — Hemen yapılabilir (düşük risk, küçük iş)

| # | İş | Yer | Neden |
|---|---|---|---|
| A1 | Lab gönderim planlama hatasını gerçek günlüğe yaz | `Servisler/LabServisi.cs:442` | `System.Diagnostics.Trace` kullanılıyor, dinleyici yok - hata hiçbir yere yazılmıyor. Kod tabanındaki tek `Trace` kullanımı. |
| A2 | `DateTime.Now/Today` kullanan 14 yeri `Saat`'e çevir | `MwlSunucusu.cs:62,154,326,483`, `DicomKaynagi.cs:164`, `GarantiCevirici.cs:76`, `BasvuruKvkkUclari.cs:102`, `DisHekimUclari.cs:107`, `GundemUclari.Kartlar.cs:60,115`, `GundemUclari.Oneriler.cs:46`, `RandevuUclari.Sms.cs:49`, `SahaPerformansUclari.cs:34`, `Cekirdek/Kimlik/MrzCozucu.cs:52` | Sunucu UTC çalışır; gece yarısı civarında yanlış gün üretir. Projenin kendi kuralı (`Saat.cs:4-13`). |
| A3 | SQL'e gömülü `'Europe/Istanbul'` yerine şube dilimi | `RadyolojiUclari.Cihaz.cs:66-76` (13 yer), `TeletipUclari.cs:125` | Şube saat dilimi ayarı (`fn_sube_zaman_dilimi`, başka yerde 51 kullanım) bu sorgularda yok sayılıyor. |
| A4 | Kısaltma / maskeleme yardımcılarını tek sınıfa topla | ~30 kısaltma (`BildirimGondericileri.cs:239`, `EFaturaServisi.cs:706`, `SterilUclari.cs:91`, `CagriUclari.cs:92`, `GunlukDeposu.cs:55`, `EFaturaIcmalUclari.cs:233` …), 8 maske (`ParolaSifirlamaServisi.cs:309`, `PortalDavetServisi.cs:182`, `RaporGonderimi.cs:276`, `RaporGonderimi.Lab.cs:207`, `FormUclari.cs:638`, `HastaIcmalUclari.cs:205`, `PortalDavetUclari.cs:37`, `BelgeTalebiUclari.Kart.cs:148`) | Kopyalar farklı davranıyor (kimi "…" ekliyor, kimi null döndürüyor). Hiçbirinin testi yok. İlk adım: Cekirdek'te `Metin` sınıfı + birim testleri. |
| A5 | Rapor gönderimi dosyalarını web'de `radyoloji/` klasöründen ortak yere taşı | `sayfalar/radyoloji/RaporAcik.tsx`, `LabSonucRaporu.tsx`, `RaporGonderimAyari.tsx`, `bilesenler/radyoloji/raporGonderimMenusu.ts`, `TeslimModali.tsx` (~14 içe aktarma) | Artık laboratuvara da hizmet ediyor. Yalnız dosya taşıma. |
| A6 | Gönderim ayarını tek yerden oku | `RaporGonderimi.cs:47-53` ve `RaporGonderimUclari.cs:53-65` | Aynı ayar iki yerde, varsayılanları kopya; her yeni alan iki yere ekleniyor. |

## B — Değerli ama dikkat ister (orta risk)

| # | İş | Yer | Neden |
|---|---|---|---|
| B1 | Transaction'sız çoklu yazma | `MedulaUclari.Fatura.cs:289-330` (5 yazma + log), `/kesinti` (234-255), `AriziUclari.Takip.cs:427-445` ve `/vazgec` | Yarıda kalırsa tutarsız veri. Testi yok. Ayrıca 3+ yazması olup hiç transaction açmayan 22 uç dosyası ve bağımsız bağlantıyla log yazan 87 çağrı **denetim listesi**dir (hata listesi değil). |
| B2 | Hata biçimini bozan uçlar | `TercihUclari.cs:34,49,53,60`, `CagriUclari.Webhook.cs:93`; gövdesiz 61 `Results.NotFound()`; uçlarda 6 `InvalidOperationException` (`DokumanUclari.cs:282`, `EntegrasyonUclari.cs:1017,1019`, `IstemSahipligi.cs:60`, `MedulaUclari.Fatura.cs:207`) | Sözleşme §1.2 `{hata:{kod,mesaj,izlemeNo}}` biçimi bozuluyor; istemci mesajı gösteremiyor, bazıları 500 dönüyor. |
| B3 | İcmal ailesinde ortak yardımcı | 38 dosya, 19.106 satır. `SubeCoz` 7 kopya (`KarlilikIcmalUclari.cs:435`, `MasrafIcmalUclari.cs:281`, `SiparisIcmalUclari.cs:273`, `TeklifIcmalUclari.cs:220`, `TemsilciPerformansUclari.cs:91`, `TicariIcmalUclari.cs:457`, `UretimIcmalUclari.cs:65`), `R(decimal)` 14 dosyada, `Ort` 11 dosyada, tarih varsayılanı 17 kez, şube SQL parçası 16 kez | Şube süzgeci güvenlikle ilgili (bugün güvenli: `subeler` dizisi ayrıca uygulanıyor). ~36 icmal ucundan yalnız 1'i testte. İlk adım: `IcmalYardimci` + birim testleri. |
| B4 | `Liste.tsx` ekrana özel dalları tanıma taşı | 36 `kaynak ===` (18 ekran), satır açma merdiveni `:1358-1377` (10 ekran), 49 `useState`'in ~25'i ekrana özel pencere | Mevcut `liste/*Aksiyonlari.ts` ve `listeEkranlari.tsx` düzeni taşıyabilir. İlk adım: tanıma `satirAc` alanı. |
| B5 | `ListeKarti.tsx` muayene / göz durumlarını kancaya al | 61 `kaynak ===` (27 ekran; muayene 19, göz muayene 10), 43 `useState`, 18 `useEffect` | Aynı desen `useRadyolojiModallari` / `useUtsModallari` olarak var. Test yalnız dolaylı. |
| B6 | Çıktı sayfalarına ortak kabuk | `LabRaporCikti` 678, `RadyolojiRaporCikti` 273, `GozSemaCikti` 194 satır | Araç çubuğu, antet, kimlik satırı, karekod üçünde de kopya. |
| B7 | Sessiz hata yutan yerler | `KimlikServisi.cs:668-673` (`AyarAsync` her hatayı yutup varsayılan kimlik ayarı döner), `EntegrasyonUclari.cs:960` (SKRS çekme döngüsü), `EnabizGonderimi.cs:469,577,598,638` | Arıza fark edilmeden yanlış davranış. 145 `catch (Exception…)` tek tek incelenmedi. |

## C — Büyük ve riskli (ayrı karar ister)

- **Genel bileşenlerin ekran tanıması.** `GenForm.tsx` 33 dal (14 ekran; `:1876-1992` kaynağa özel arama bloğu), `GenDetayTablo.tsx` ~40 dal ve alan adına özel sabitler (`:230-240`), `kart/KartGrupSekmesi` 46, `kart/KartKimlikSeridi` 45, `kartSekmeleri.ts` 26. Önce davranışı sabitleyen testler yazılmalı (`GenDetayTablo` 1, `GenForm` 3 test).
- **Dev dosyaları bölmek.** Web: `BelgeKarti.tsx` 2493 satır (51 `useState`, 20 `useEffect`; sekmeye göre bölünür), `RadyolojiRapor.tsx` 1608 (44 `useState`, 19 uç). Sunucu: `StandartRolUclari.cs` 1362 (1-990 sabit rol verisi → Cekirdek kataloğu), `BelgeUclari.cs` 1298 (1081-1298 erişim yardımcıları), `IceriAlma.cs` 1283 (bölüm çizgileri hazır). 100 satırı aşan 80 uç gövdesi var; en uzunları icmal uçları (`SatinalmaIcmalUclari.cs:152` 606 satır).
- **Uçlardaki SQL'i depo katmanına taşımak.** 278 uç dosyasının 259'unda SQL var (~2300 sorgu); bu fiilen projenin düzeni ve `OKUBENI` yasaklamıyor. Toplu taşıma **önerilmez**; yalnız başka iş için dokunulan dosyada yapılmalı.
- **Rapor gönderimi tablo ve yetki adları** (`radyoloji_rapor_gonderim*`, `radyoloji.rapor_gonderim`, şablon kodları). Veri göçü ve rol yetkisi taşıma gerektirir, kazancı küçük: **önerilmez**. `radyoloji_teslim`, `radyoloji_rapor`, `radyoloji_istem` gerçekten radyoloji tablolarıdır, dokunulmaz.
- **İstemcideki iş kuralları.** Belge tutar hesabı (`belgeSatir.ts:269`, `belgeKartiKurallari.ts:412-414`, `belgeDonusumHesap.ts:74-106`), avans taksit planı (`ik/AvansKarti.tsx:121-130`), izin günü (`GenDetayTablo.tsx:601`), boş taslak kararı + silme (`ListeKarti.tsx:362`), 596 sayısal `durum === N` karşılaştırması. Tutar hesabının yalnız önizleme mi kesin tutar mı olduğu **doğrulanamadı**; önce bu netleşmeli.
- **Tip güvenliği.** `as unknown as` 92, `: any` 20 (`AvansKarti` 9, `MasrafKarti` 8), sunucu satırı olarak `Record<string, unknown>` 556 (`api/uclar/lab.ts` 39, `radyoloji.ts` 35), `eslint-disable` 158 (130'u `exhaustive-deps`).
- **`tema.css`.** 3182 sınıf adından 185'i kodda düz metin olarak geçmiyor (üst sınır; 18'i örneklenip ölü bulundu), 46 seçici birden çok kez tanımlı, 42 kısa küresel kök (`.b`, `.d`, `.k`).
- **Tekrarlar (web).** 325 `[hata, setHata]`, 84 elle yükleniyor bayrağı, 241 boş / sessiz catch; `Modal` yerine elle `kaperde` kuran 12 kart; `bicim` dışında 435 yerel tarih / para biçimleme.

## Testi olmayan büyük parçalar

- Web: `ListeKarti` (yalnız dolaylı), `RadyolojiRapor`, `BankoOturumu`, `KalemSekmesi`, `KasaIslemKarti`, `KurumTipiAyarlari`, `KartGrupSekmesi`, `BelgeBaslik`, `tedarikAksiyonlari`.
- Sunucu: Medula fatura, arıza takip, tercih uçları, icmal uçlarının neredeyse tamamı, `StandartRolUclari` rotaları.

## Sağlam bulunanlar

- Sunucuda TODO / HACK / FIXME notu, yorum satırına alınmış blok ve kullanılmayan özel metot bulunmadı.
- Hata biçimi genel olarak tutarlı (~2640 `GentegreHatasi` kullanımı).
- Web'de `as any` yok.
- Ortak mantık SQL fonksiyonlarında toplanmış (`fn_taraf_ad` 471 kullanım); tekrar iş kuralında değil birleştirmelerde.

## Doğrulanamayanlar

- İstemcideki tutar hesabının önizleme mi kesin tutar mı olduğu.
- Ölü CSS sınıflarının kesin sayısı (185 üst sınırdır).
- Medula ve arıza dışındaki dosyalarda transaction bulguları (sezgisel sayım).
- Test kapsamı ad ve rota eşleşmesiyle ölçüldü; servisler üzerinden dolaylı kapsam ölçülmedi.
