-- =====================================================================
--  742_onay_akis_ekrani.sql
--  Onay akışı TANIM ekranı (738-741 omurgasının yönetici yüzü).
--
--  Akışlar bugüne kadar göçle geliyordu: kurum eşiği değiştirmek istediğinde
--  bir SQL dosyası yazmak gerekiyordu. Kurallar veri olduğu hâlde onları
--  düzenleyecek ekranın olmaması, kuralı yine koda gömmek demekti.
-- =====================================================================

-- ============================================= AKIŞ LİSTESİ GÖRÜNÜMÜ
-- Sayaçlar listede: "kaç basamak, kaç onay yürüyor, kaçı gecikmiş".
--   Bunlar olmadan akış listesi bir ad listesi olurdu - oysa yöneticinin
--   sorusu "bu akış işliyor mu".
create or replace view public.v_onay_akis as
select k.id,
       k.kod,
       k.ad,
       k.kaynak_tur,
       k.olcu_adi,
       k.aktif,
       k.aciklama,
       k.sube_id,
       (select count(*) from public.onay_akis_adim a
         where a.akis_id = k.id and a.aktif = 1)               as basamak,
       -- HER TALEPTE ÇIKAN basamak: eşiği ve bayrağı olmayan. Akışın
       --   "taban"ıdır; sıfırsa küçük tutarlı talep hiç imzasız geçer.
       (select count(*) from public.onay_akis_adim a
         where a.akis_id = k.id and a.aktif = 1
           and a.esik_alt is null and coalesce(a.bayrak, '') = '')
                                                               as taban_basamak,
       (select count(*) from public.onay o
         where o.akis_id = k.id and o.durum = 0)               as yuruyen,
       (select count(*) from public.v_onay_bekleyen v
         where v.akis_kod = k.kod and v.gecikme_gun > 0)       as geciken,
       (select max(o.baslama) from public.onay o where o.akis_id = k.id) as son_kullanim,
       k.ekleme_tarihi,
       k.degistirme_tarihi
  from public.onay_akis k;

comment on view public.v_onay_akis is
  '742: onay akisi listesi. taban_basamak = esigi/bayragi olmayan, her '
  'kayitta cikan basamak sayisi - sifirsa kucuk kayit imzasiz gecer.';

-- ========================================= BASAMAK DETAYI (kart sekmesi)
-- Kart detayı doğrudan `onay_akis_adim` üzerinde çalışır (yazılabilir);
--   bu görünüm yalnız LİSTE tarafı için - rol ve sahip türü adlarıyla.
create or replace view public.v_onay_akis_adim as
select a.id,
       a.akis_id,
       a.sira,
       a.ad,
       a.sahip_turu,
       a.rol,
       a.kullanici_id,
       coalesce(nullif(t.unvan, ''), ku.kod, '')               as kullanici_ad,
       a.esik_alt,
       a.bayrak,
       a.karar_turu,
       a.sure_gun,
       a.e_imza_zorunlu,
       a.aktif,
       -- KOŞUL METNİ: "50.000 ₺ ve üstü" / "bütçe bayrağı" / "her kayıtta".
       --   Üç kolona bakıp kuralı kafada birleştirmek, eşik ile bayrağın
       --   birlikte çalıştığı satırda hataya açık.
       case when a.esik_alt is not null and coalesce(a.bayrak, '') <> ''
                 then a.esik_alt::text || ' ve üstü + ' || a.bayrak
            when a.esik_alt is not null then a.esik_alt::text || ' ve üstü'
            when coalesce(a.bayrak, '') <> '' then a.bayrak || ' bayrağı'
            else 'her kayıtta' end                             as kosul
  from public.onay_akis_adim a
  left join public.taraf_kullanici ku on ku.id = a.kullanici_id
  left join public.taraf t            on t.id = a.kullanici_id;

comment on view public.v_onay_akis_adim is
  '742: akis basamagi listesi, kosulu metne cevrilmis halde.';
