# Gentegre AI — düzeltmelerin tekrar denetimi

Tarih: 28.09.2026. Kapsam: yalnız GentegreAI. Önceki denetim, Claude uygulama promptu ve düzeltme sonuç raporu esas alınarak mevcut kaynaklar incelendi; derlemeler ve testler yeniden çalıştırıldı.

## Sonuç

Önemli iyileşme var; ancak prompt tamamen kapanmış değil. **Doküman erişimindeki alternatif yol ve migration atomiklik hatası giderilmeden yayın onayı verilmemeli.** Boş kurulum, migration geçmişinin uzlaştırılması ve iki başarısız API testi de açık.

Bu çalışma düzeltme uygulaması değildir. Üretim ortamına bağlanılmadı. Paylaşılan geliştirme DB'sine yazılmadı. Testler `gentegre_ai_test` üzerinde; migration hata deneyi ayrıca bu denetim için oluşturulan ayrı bir veritabanında yürütüldü. Doküman açığı kaynak akışıyla doğrulandı; gerçek kullanıcı belgesi paylaşılmadı veya silinmedi.

## 1. Yüksek: doküman paylaşımı laboratuvar erişim kapısını aşabiliyor

Kanıt: `api/src/Gentegre.Api/Uclar/DokumanUclari.cs:97`, `:125`, `:149`; `api/src/Gentegre.Veri/Depolar/DokumanDeposu.cs:381`, `:388`, `:403`.

Doğrudan içerik ucuna `lab-sonuc` için kayıt/tetkik erişim denetimi eklenmiş. Ancak `POST /api/dokuman/{kartAdi}/{kaynakId}/{dokumanId}/paylas` yetkiyi URL'deki kart türünden çözüyor; dokümanın gerçek kaynağının bu kart ve kayıtla eşleştiğini doğrulamıyor. Depo yalnız doküman ID'siyle paylaşım kodu üretiyor. Anonim paylaşım ucu bu kodla içeriği döndürüyor.

Dolayısıyla `cari` değiştirme yetkisi bulunan, fakat hedef laboratuvar kaydına erişemeyen kullanıcı; cari yolu altında hedef doküman ID'sini vererek paylaşım kodu oluşturabilir. Yeni laboratuvar kontrolü bu yolda çalışmıyor. Tahmin edilemez paylaşım kodu, kodun yetkisiz üretilebilmesini önlemiyor.

Aynı bağlama eksikliği silmede de var: `DokumanUclari.cs:86–92` kendi personel kartı URL'sinde genel yetki kontrolünü atlıyor; `DokumanDeposu.cs:311–320` hedefi yalnız doküman ID'siyle siliyor. Ayrıca doğrudan içerik kapısında laboratuvar dışındaki kaynaklar için kayıt kapsamı denetlenmiyor.

Gerekli düzeltme: dokümanın gerçek kaynak/kayıt ilişkisini sunucudan çöz; URL ile eşleştir; okuma, değiştirme, silme ve paylaşım üretiminde aynı kayıt kapsamı kapısını uygula. Kendi kartı istisnasını URL'ye değil gerçek sahipliğe bağla. Başka şube/hasta dokümanını farklı kart yolu altında paylaşma ve silme denemeleri için HTTP regresyon testleri ekle.

## 2. Yüksek: migration uygulayıcısı PL/pgSQL END satırını transaction sanıyor

Kanıt: `db/araclar/goc_uygula.ps1:70`, `:139`, `:157`, `:207`; `yayin/goc_uygula.sh:85`, `:132–133`.

Her iki uygulayıcıdaki satır tabanlı regex, fonksiyon/DO gövdesindeki `end;` satırını üst düzey transaction komutu kabul ediyor. Böylece kendi transaction'ı bulunmayan normal migration dosyaları da işlem dışı sarmalayıcıya yönleniyor. Depodaki `db/037_kisi_karti.sql` bu desene gerçek bir örnek.

PowerShell uygulayıcısıyla ayrı test DB'sinde yeniden üretildi:

```sql
create table public.__reaudit_partial (id integer);
insert into public.__reaudit_partial values (1);
do $$
begin
    perform 1;
end;
$$;
select 1 / 0;
```

Sonuç: uygulayıcı exit 1 verdi; buna rağmen tablo ve 1 satır kaldı, migration geçmişine 0 kayıt yazıldı. Hata mesajındaki “kendi işlemi geri alındı” ifadesi de bu dosya için yanlış. PowerShell davranışı çalıştırılarak doğrulandı; bash tarafında aynı hatalı sınıflandırma kaynakta mevcut, bu özel senaryo bash ile ayrıca koşturulmadı.

Deney dosyası: `api/TestResults/Reaudit/migration-repro/001_yarim.sql`.

Yalnız bu deney için oluşturulan `gentegre_reaudit_partial_test_20260928` veritabanı kanıt alındıktan sonra temizlendi; deney SQL'i korundu. Mevcut kullanıcı/test veritabanları silinmedi.

Gerekli düzeltme: işlem dışı dosyaları güvenilir/açık metadata ile sınıflandır veya SQL gövde ve yorumlarını ayırabilen bir yöntem kullan. Normal dosya ile defter kaydını aynı transaction'da tut. Gerçek fonksiyon/DO gövdeli, ortada hata veren fixture'ı hem PS hem bash testlerine ekle; hiçbir nesne/veri/defter kaydı kalmadığını doğrula. Mevcut 8 migration testinin geçmesi bu senaryoyu kapsamıyor.

## Bağımsız doğrulama sonuçları

| Kontrol | Sonuç |
|---|---|
| API build | Başarılı; 0 hata, test projesinde 10 uyarı, üretim projelerinde 0 uyarı |
| Tam API testleri | 577 toplam: **575 başarılı, 2 başarısız, 0 atlanan** |
| Yeni güvenlik + migration testleri | 22/22 başarılı; yukarıdaki alternatif yollar kapsanmıyor |
| Web testleri | **75 dosya, 736/736 başarılı** |
| Web üretim build | Başarılı; ana JS 1.556,24 kB, gzip 423,63 kB |
| Paket uyarıları | Büyük ana parça ve bazı statik importların dinamik bölmeyi engellemesi devam ediyor |
| Migration hata deneyi | **Başarısız atomiklik: hata sonrası tablo ve veri kaldı** |

API test kanıtı: `api/TestResults/Reaudit/reaudit.trx`. Testler `GENTEGRE_TEST_ZORUNLU=1` ile gerçek test DB bağlantısında yürütüldü; sessiz yeşil/atlama yok.

Başarısız testler:

- `StandartRolModulTestleri.Haritadaki_modul_kodlari_KATALOGDA_var`: rol haritasındaki `steril`, modül kataloğunda yok.
- `BankoSefiTestleri.Ust_yonetim_SALT_OKUMA_ama_imza_atar`: beklenen 0 yerine 1; üst yönetim salt okuma beklentisi ile mevcut yetkiler çelişiyor.

Claude raporu da bu ikisini açıkça bildiriyor. Mevcut yeniden çalıştırma başarısızlıkları doğruluyor; düzeltme öncesi tam test koşusu olmadığı için “bu değişikliklerle oluşmadı” iddiası bu denetimde bağımsız olarak kanıtlanmış sayılmadı. Ürün kuralı netleştirilip veri/kod/test aynı kurala getirilmeden test kapısı yeşil değil.

## Önceki 12 bulgunun durumu

| No | Durum | Değerlendirme |
|---|---|---|
| 1 — Şubesiz erişim | Düzeltilmiş; politika notu var | Boş şubede ret/default yazma kapalı. Eski kullanıcı/rol/tek şube fallback politikası korunmuş; açık yetki kaldırma semantiği bu politikayla değerlendirilmelidir. |
| 2 — Salt okunur şubede aksiyon | Düzeltilmiş | Yazma aksiyonu merkezi şube yazma kontrolünden geçiyor; okuma aksiyonu ayrılmış. |
| 3 — Lab grafik kayıt kapsamı | Kısmen | Grafik ve doğrudan lab dosyası kontrol edilmiş; doküman paylaşım alternatif yolu açık. |
| 4 — Zorunlu parola değişimi | Düzeltilmiş | Sunucu oturum kapısı iş uçlarını sınırlıyor. |
| 5 — İlk parola denemeleri | İyileştirilmiş | Doğrulama kodu/deneme kontrolleri eklenmiş; varsayılan personel parolası politikası ayrıca açık ürün kararı. |
| 6 — Refresh atomikliği | Düzeltilmiş | Satır kilidi ve tek transaction; eşzamanlılık güvenlik testleri başarılı. |
| 7 — Güncel rol kümesi | Kod/test düzeyinde düzeltilmiş | Güncel roller kullanılıyor; hedef DB için 923 önkoşulu henüz sağlanmamış. |
| 8 — Migration defteri | Açık | Uzlaştırma hazırlıkları var; geçmişin bütünü doğrulanmış değil. |
| 9 — Boş DB kurulumu | Açık | Güncel ürünün uçtan uca boş kurulumu tamamlanmamış. |
| 10 — Migration atomikliği | Açık / yeniden üretildi | Yeni sınıflandırıcı gerçek SQL gövdelerinde atomikliği bozuyor. |
| 11 — Geçici /ben hatası | Düzeltilmiş | Geçici hata ile kesin oturum reddi ayrılmış; token korunuyor. |
| 12 — Web mock sözleşmesi | Düzeltilmiş | Önceki kırmızı testler dahil 736 test geçti. |

## DB ve yayına hazırlık sınırları

- Salt okunur kontrolde paylaşılan `gentegre_ai` defteri 640 kayıt / en yüksek 922. `fn_lab_tetkik_izin_roller(integer,integer[],character varying)` burada yok. Yeni kod bu DB ile doğrudan çalıştırılmadan önce 923 gerekir; bu denetimde uygulanmadı.
- `gentegre_ai_test` defteri 642 kayıt / en yüksek 924; yeni fonksiyon mevcut. Başarılı güvenlik testleri bu güncellenmiş DB'ye aittir.
- `gentegre_ai_bos_test` geçmişi 559'da kalmış. Claude raporuna göre 560'ta `ux_departman_ad` çakışması ve dış referans veri bağımlılıkları boş kurulumu engelliyor. Baştan sona başarılı kurulum kanıtı yok.
- Migration geçmişini topluca uygulanmış saymak veya eski dosyaları körlemesine yeniden koşturmak çözüm değildir. Önce uygulayıcı atomikliği, ardından dosya bazlı uzlaştırma ve temiz kurulum kanıtı gerekir.
- Eski verideki hasta doğum tarihi/cinsiyet eksiklerini gerçek bilgi olmadan doldurmamak doğru; bu veri kalitesi işi açık kalıyor.

## Kapatma sırası

1. Doküman sahiplik/kapsam kapısı ve alternatif paylaşım/silme HTTP testleri.
2. Migration sınıflandırıcısı ve PL/pgSQL gövdeli hata/rollback testleri.
3. İki API testindeki ürün kuralı çelişkilerini çözme.
4. Migration geçmişini uzlaştırma ve tamamen boş DB kurulumunu doğrulama.
5. Onaylı yedek/migration süreciyle hedef DB'yi hazırlama, ardından tüm kapıları yeniden çalıştırma.

Uygulama kodu veya mevcut migration dosyası bu tekrar denetiminde düzeltilmedi. Değerlendirme kaynak incelemesi ve belirtilen testlerle sınırlıdır; bütün modüllerin veya üretim ortamının güvenlik sertifikasyonu değildir.
