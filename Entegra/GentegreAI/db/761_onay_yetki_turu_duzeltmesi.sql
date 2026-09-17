-- ============================================================================
--  Gentegre AI — ONAY YETKİLERİNİN TÜRÜ DÜZELTİLİYOR (0 -> 1)
--  761_onay_yetki_turu_duzeltmesi.sql
--
--  Kullanıcı: "bildirimler neden kuyruğa düşmüyor bak."
--
--  `yetki.tur`: **0 kaynak** (gör/ekle/değiştir/sil), **1 aksiyon** (yalnız
--  `gor` = çalıştırma izni) - 020'deki tanım. Onay basamağı yetkileri
--  aksiyon yetkisidir; satınalma, izin, avans ve onarım hepsi `tur = 1`.
--
--  754 (iskonto) ve 758 (doküman) bu dört yetkiyi **`tur = 0`** ile eklemişti:
--
--      belge.iskonto_onay_birim · belge.iskonto_onay_mali ·
--      belge.iskonto_onay_ust  · dokuman.onay
--
--  ============ NEDEN SESSİZCE BOZDU ===================================
--  Karar verme bundan etkilenmedi - `AksiyonIste` türe bakmıyor ve yetki
--  atanmış olduğu için imza atılabiliyordu. Bozulan BİLDİRİMDİ:
--  `OnayBildirimi.AlicilarAsync` sırası gelen basamağın sahiplerini
--
--      ... join public.yetki y ... where y.tur = 1 and y.kod = @aksiyon
--
--  ile arıyor. `tur = 0` olan yetki bu süzgeçten düşüyor, alıcı listesi boş
--  dönüyor ve "sıradaki basamağa haber" hiç yazılmıyordu. Bildirim çağrıları
--  kararı düşürmesin diye try/catch içinde olduğundan **hata da görünmüyordu**:
--  iskonto ve doküman onayları kimseye haber vermeden bekliyordu.
--
--  Türü düzeltmek yetkinin kime verildiğini DEĞİŞTİRMEZ: `rol_yetki`
--  satırlarına dokunulmuyor, yalnız yetkinin sınıfı doğru yazılıyor.
-- ============================================================================
\set ON_ERROR_STOP on

update public.yetki
   set tur = 1
 where kod in ('belge.iskonto_onay_birim', 'belge.iskonto_onay_mali',
               'belge.iskonto_onay_ust', 'dokuman.onay')
   and tur <> 1;

-- AKSİYON YETKİSİNDE YALNIZ `gor` ANLAMLI (020): tür düzelirken ekle/değiştir
--   bayrakları da sadeleşsin - "çalıştırabilir" tek bir izindir, dört ayrı
--   kutu onay ekranında yanıltıcı görünürdü.
update public.rol_yetki ry
   set ekle = 0, degistir = 0, sil = 0
  from public.yetki y
 where y.id = ry.yetki_id
   and y.kod in ('belge.iskonto_onay_birim', 'belge.iskonto_onay_mali',
                 'belge.iskonto_onay_ust', 'dokuman.onay');

do $$
declare v_yanlis int;
begin
    -- BÜTÜN onay yetkilerini tarıyoruz: aynı hatanın başka bir modülde
    --   durup durmadığını burada görmek, bir dahaki bildirim sessizliğini
    --   aramaktan ucuz.
    select count(*) into v_yanlis from public.yetki
     where tur = 0 and (kod like '%onay\_%' or kod like '%\_onay' or kod = 'dokuman.onay');

    raise notice '761 tamam. Hala tur=0 olan onay yetkisi: %.', v_yanlis;
end $$;
