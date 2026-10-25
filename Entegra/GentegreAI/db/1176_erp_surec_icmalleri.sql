-- =============================================================================
--  1176  ERP SÜREÇ İCMALLERİ: SİPARİŞ / KÂRLILIK / SATINALMA SÜREÇ / KDV /
--        TEKNİK SERVİS / ÜRETİM
--
--  Kullanıcı (25.10.2026): mockup'ları (Ekranlar/İcmal/siparis_icmali.html,
--  karlilik_icmali.html, satinalma_icmali.html, kdv_icmali.html,
--  teknik_servis_icmali.html, uretim_icmali.html) onaylanan kararlarla kodla.
--
--  1) Ekran kodları (1003 ilkesi: bir kod bir menü ekranı) - hakları ilgili listenin
--     kodundan KOPYALANIR (o listeyi gören rol icmali de görür), yalnız Gör:
--       siparis.icmali          <- belge.satis.siparis (Satış Siparişi Listesi)
--       satis.karlilik_icmali   <- belge.satis.fatura  (Satış Faturası Listesi)
--       satinalma.icmali        <- satinalma.talep.liste
--       muhasebe.kdv_icmali     <- muhasebe_fis        (Muhasebe Fişi Listesi)
--       servis.icmali           <- servis.is_emri
--       uretim.icmali           <- uretim.liste
--  2) Asistan ekran kataloğu (ai_rehber_ekran); "ne yapılır" metni dokuman/yardim/icmal-*.md.
--  3) Kararlardan gelen yeni yapılar:
--       servis_ariza_kodu + demirbas_is_emri.ariza_kodu_id  (arıza kodu, marka / model bazlı, isteğe bağlı;
--                                                            tanım listesi kodu servis.ariza_kodu)
--       servis_ziyaret.memnuniyet_puan                     (kapanışta 1-5, isteğe bağlı)
--       kdv_devreden                                       (muhasebe yoksa elle devreden KDV, dönem başına bir değer)
--       satinalma_hatirlatma                               (onaycıya hatırlatma: belge başına günde bir, ikincisi üst basamağa)
--       siparis_satir_kapanis + v_belge_acik_satir          (sipariş "kalanı kapat": kapanan satır açık sayılmaz)
--  4) Düzeltme: v_butce_durum kesin belgeleri sayar (724'te durum süzgeci tersti).
--  Ayarlar (referans, AyarDeposu beyaz listesi; boş = uç varsayılanı): satis.hedef_marj (15), muhasebe.babs_sinir (5000),
--  satinalma.hedef_gun_{onay,teklif,siparis,kabul,odeme} (boş = hedef yok), servis.tekrar_ariza_gun (30),
--  uretim.sapma_maliyet_yuzde (5), uretim.sapma_sarf_yuzde (5), uretim.fire_hedef_kat (1.5).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120), grup varchar(40))
  on commit drop;
insert into _bolme values
  ('siparis.icmali',         'belge.satis.siparis',   'Sipariş İcmali (Satış)',            'Satış'),
  ('satis.karlilik_icmali',  'belge.satis.fatura',    'Kârlılık İcmali (Satış)',           'Satış'),
  ('satinalma.icmali',       'satinalma.talep.liste', 'Satınalma Süreç İcmali (Satınalma)', 'Satınalma'),
  ('muhasebe.kdv_icmali',    'muhasebe_fis',          'KDV İcmali (Muhasebe)',             'Muhasebe'),
  ('servis.icmali',          'servis.is_emri',        'Teknik Servis İcmali (Teknik Servis)', 'Teknik Servis'),
  ('uretim.icmali',          'uretim.liste',          'Üretim İcmali (Üretim)',            'Üretim');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1176: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, 0, 0, 0, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

-- ------------------------------------------------------------ teknik servis --
create table if not exists public.servis_ariza_kodu (
  id                bigint generated always as identity primary key,
  kod               varchar(30)  not null,
  ad                varchar(150) not null default '',
  marka             varchar(60)  not null default '',   -- boş = bütün markalar
  model             varchar(60)  not null default '',   -- boş = markanın bütün modelleri
  aktif             smallint     not null default 1,
  ekleyen           integer      not null default 0,
  ekleme_tarihi     timestamptz  not null default now(),
  degistiren        integer      not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_servis_ariza_kodu on public.servis_ariza_kodu (marka, model, kod);

alter table public.demirbas_is_emri add column if not exists ariza_kodu_id bigint
  references public.servis_ariza_kodu(id);

alter table public.servis_ziyaret add column if not exists memnuniyet_puan smallint;
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'ck_servis_ziyaret_memnuniyet') then
    alter table public.servis_ziyaret add constraint ck_servis_ziyaret_memnuniyet
      check (memnuniyet_puan is null or memnuniyet_puan between 1 and 5);
  end if;
end $$;

-- Arıza kodu tanımı (Teknik Servis › Ayarlar › Arıza Kodları): kendi kodu, hakları iş emri
--   kodundan BÜTÜN işlemleriyle kopyalanır (iş emrini yöneten kodu da yönetir).
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'servis.ariza_kodu', 'Arıza Kodları (Teknik Servis)', 'Teknik Servis', 0, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye where ye.kod = 'servis.is_emri'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'servis.ariza_kodu'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'servis.is_emri'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where y.kod = 'servis.ariza_kodu' and ry.rol_id = r.id);

-- ---------------------------------------------------------------------- KDV --
create table if not exists public.kdv_devreden (
  id                bigint generated always as identity primary key,
  vkn               varchar(11)   not null,
  donem             char(7)       not null,              -- 'yyyy-MM': bu döneme devreden (önceki dönemin sonu)
  tutar             numeric(18,2) not null default 0,
  aciklama          varchar(300)  not null default '',
  ekleyen           integer       not null default 0,
  ekleme_tarihi     timestamptz   not null default now(),
  degistiren        integer       not null default 0,
  degistirme_tarihi timestamptz,
  constraint ck_kdv_devreden_donem check (donem ~ '^[0-9]{4}-[0-9]{2}$')
);
create unique index if not exists ux_kdv_devreden on public.kdv_devreden (vkn, donem);

-- ---------------------------------------------------------------- satınalma --
create table if not exists public.satinalma_hatirlatma (
  id         bigint generated always as identity primary key,
  belge_tur  varchar(20) not null,          -- 'talep' | 'teklif' | 'fatura'
  belge_id   bigint      not null,
  alici_id   integer     not null,          -- hatırlatılan kullanıcı
  ust_bilgi  smallint    not null default 0, -- 1 = ikinci hatırlatma, üst basamağa bilgi
  gonderen   integer     not null default 0,
  an         timestamptz not null default now()
);
create index if not exists ix_satinalma_hatirlatma on public.satinalma_hatirlatma (belge_tur, belge_id, an);

-- ------------------------------------------------------------------ sipariş --
-- "KALANI KAPAT" (karar 25.10.2026): sipariş satırının teslim edilmeyecek kalanı kapatılır;
--   sipariş belgesi DEĞİŞMEZ (teslim edilen kısım ve belge toplamı olduğu gibi), kapanış
--   bu tabloda + islem_log'da (neden zorunlu). Satır başına tek kapanış.
create table if not exists public.siparis_satir_kapanis (
  id             bigint generated always as identity primary key,
  belge_id       integer       not null references public.belge(id) on delete cascade,
  belge_satir_id integer       not null references public.belge_satir(id) on delete cascade,
  miktar         numeric(24,6) not null,            -- kapatılan (iptal edilen) kalan
  teslim         numeric(24,6) not null default 0,  -- kapanış anındaki kesin teslim (bilgi)
  neden          varchar(400)  not null,
  sube_id        integer       not null default 0,
  ekleyen        integer       not null default 0,
  ekleme_tarihi  timestamptz   not null default now()
);
create unique index if not exists ux_siparis_satir_kapanis on public.siparis_satir_kapanis (belge_satir_id);
create index if not exists ix_siparis_satir_kapanis_belge on public.siparis_satir_kapanis (belge_id);

-- Açık satır görünümü (yürürlükteki tanım 471) - kolonlar aynı, yalnız kapanış koşulu eklendi.
create or replace view public.v_belge_acik_satir as
select s.id            as satir_id,
       s.belge_id,
       b.tur           as belge_tur,
       kt.ad           as belge_tur_adi,
       b.belge_no,
       b.belge_tarihi,
       b.taraf_id,
       b.taraf_unvan,
       b.belge_dovizi,
       b.sube_id,
       s.sira,
       s.tur           as satir_tur,
       s.stok_id, st.kod as stok_kodu, st.ad as stok_adi,
       s.hizmet_id, s.masraf_id,
       s.aciklama,
       s.miktar,
       s.kapatilan_miktar,
       s.kalan_miktar,
       s.birim,
       s.birim_fiyat,
       s.iskonto,
       s.kdv,
       b.kapanma_durum,
       coalesce(dg.rota, 1)                as rota,
       coalesce(dg.sgk, 0)                 as sgk,
       coalesce(dg.oss, 0)                 as oss,
       coalesce(dg.hasta_provizyon, 0)     as hasta_provizyon,
       coalesce(dg.hasta_ek_katki, 0)      as hasta_ek_katki,
       coalesce(dg.sgk_katilim_payi, 0)    as sgk_katilim_payi,
       greatest(coalesce(dg.sgk, 0) - coalesce(dg.sgk_kapatilan, 0), 0) as sgk_kalan,
       greatest(coalesce(dg.oss, 0) - coalesce(dg.oss_kapatilan, 0), 0) as oss_kalan,
       greatest(coalesce(dg.hasta_provizyon, 0)
              - coalesce(dg.hasta_provizyon_kapatilan, 0), 0) as hasta_provizyon_kalan,
       greatest(coalesce(dg.hasta_ek_katki, 0)
              - coalesce(dg.hasta_ek_katki_kapatilan, 0), 0)  as hasta_ek_katki_kalan,
       coalesce(st.kod, hz.kod, ms.kod, '') as kalem_kodu,
       coalesce(st.ad,  hz.ad,  ms.ad,  '') as kalem_adi,
       s.tutar,
       -- Tahsil edilen MATRAH: tahsilat KDV dahil dağıtılır (321), kovalar
       --   matrahtır; öneri aynı düzlemde olsun.
       round(coalesce(dg.hasta_provizyon_tahsil + dg.hasta_ek_katki_tahsil, 0)
             / (1 + coalesce(s.kdv, 0) / 100.0), 4) as hasta_tahsil_matrah,
       round(coalesce(dg.sgk_tahsil + dg.oss_tahsil, 0)
             / (1 + coalesce(s.kdv, 0) / 100.0), 4) as kurum_tahsil_matrah,
       case when coalesce(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 0) > 0
            then greatest(coalesce(dg.sgk, 0) - coalesce(dg.sgk_kapatilan, 0), 0)
               + greatest(coalesce(dg.oss, 0) - coalesce(dg.oss_kapatilan, 0), 0)
               + greatest(coalesce(dg.hasta_provizyon, 0)
                        - coalesce(dg.hasta_provizyon_kapatilan, 0), 0)
               + greatest(coalesce(dg.hasta_ek_katki, 0)
                        - coalesce(dg.hasta_ek_katki_kapatilan, 0), 0)
            when s.miktar > 0 then round(s.tutar * s.kalan_miktar / s.miktar, 4)
            else 0 end                       as tutar_kalan
  from public.belge_satir s
  join public.belge b on b.id = s.belge_id
  left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
  left join public.kasa_islem_turu kt on kt.kod = b.tur
  left join public.stok   st on st.id = s.stok_id
  left join public.hizmet hz on hz.id = s.hizmet_id
  left join public.masraf ms on ms.id = s.masraf_id
 where (   coalesce(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 0) = 0
           and s.kalan_miktar > 0
        or coalesce(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 0) > 0
           and (dg.sgk - dg.sgk_kapatilan > 0
             or dg.oss - dg.oss_kapatilan > 0
             or dg.hasta_provizyon - dg.hasta_provizyon_kapatilan > 0
             or dg.hasta_ek_katki - dg.hasta_ek_katki_kapatilan > 0))
   and b.durum = 0
   -- 1176: Sipariş İcmali'nde "Kalanı kapat" ile kapatılan satır açık değildir (satır
   --   ve belge değişmez; kapanış kaydı + log). Dönüşüm penceresi de görmez.
   and not exists (select 1 from public.siparis_satir_kapanis k where k.belge_satir_id = s.id);

-- ---------------------------------------------------------- bütçe düzeltmesi --
-- HATA (724'ten beri): v_butce_durum harcanan / taahhüdü `durum <> 0` ile süzüyordu; belge.durum
--   0 = KESİN, 1 = taslak (BelgeDeposu). Yani kesin fatura / sipariş bütçeye HİÇ yazılmıyor,
--   taslak / iptal yazılıyordu - talep onayındaki bütçe kontrolü (ButceDurumuAsync) ve Satınalma
--   Süreç İcmali'nin Bütçe sekmesi aynı görünümü okur. Kolonlar aynı, yalnız süzgeç `durum = 0`.
create or replace view public.v_butce_durum as
select b.id, b.sube_id, b.yil, b.kod, b.ad, b.tutar,
       coalesce(h.harcanan, 0) as harcanan,
       coalesce(t.taahhut, 0) as taahhut,
       b.tutar - coalesce(h.harcanan, 0) - coalesce(t.taahhut, 0) as kalan,
       case when b.tutar > 0
            then round((coalesce(h.harcanan, 0) + coalesce(t.taahhut, 0))
                       / b.tutar * 100, 1) else 0 end as kullanim_yuzde
  from public.butce_kalem b
  -- HARCANAN: kesinleşmiş alış faturaları (tür 11, belge.durum 0 = kesin).
  left join lateral (
      select sum(f.genel_toplam) as harcanan
        from public.belge f
        join public.satinalma_fatura_kontrol k on k.fatura_belge_id = f.id
        join public.belge s on s.id = k.siparis_belge_id
        join public.belge_satinalma bs on bs.id = s.id
        join public.satinalma_talep tl on tl.id = bs.talep_id
       where f.tur = 11 and f.durum = 0
         and tl.butce_kalem_id = b.id
         and extract(year from f.belge_tarihi) = b.yil) h on true
  -- TAAHHÜT: açık siparişler (tür 9, takip_durum 0/1).
  left join lateral (
      select sum(s.genel_toplam) as taahhut
        from public.belge s
        join public.belge_satinalma bs on bs.id = s.id
        join public.satinalma_talep tl on tl.id = bs.talep_id
       where s.tur = 9 and s.durum = 0 and bs.takip_durum in (0, 1)
         and tl.butce_kalem_id = b.id
         and extract(year from s.belge_tarihi) = b.yil) t on true
 where b.aktif = 1;

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.grup, v.baslik, v.yetki_kodu, v.urun_modu, v.anahtar, v.aciklama, ''
  from (values
    ('siparis-icmali', '/siparis-icmali', 'Sipariş İcmali', 'Satış › İcmaller › Sipariş İcmali', 'Satış', 'siparis.icmali', 1::smallint,
     'sipariş icmal açık sipariş kalan miktar termin gecikme teslim performansı otif zamanında tam teslim stok karşılama eksik rezerve yoldaki irsaliyeye dönüştür kalanı kapat tedarikçi gecikmesi alış siparişi konsinye',
     'Satış ve alış siparişlerinin açık kalan miktar ve tutarı, termin takvimi, gecikenler, zamanında ve tam teslim (OTIF) oranı, açık siparişlerin eldeki stokla karşılanması; '
     || 'irsaliyeye dönüştürme, kalanı kapatma, termin hatırlatması ve satınalma talebi.'),
    ('karlilik-icmali', '/karlilik-icmali', 'Kârlılık İcmali', 'Satış › İcmaller › Kârlılık İcmali', 'Satış', 'satis.karlilik_icmali', 1::smallint,
     'kârlılık icmal kâr marj brüt kâr müşteri abc ürün kârlılığı temsilci kategori şube para birimi zararlı satış maliyet altı hedef marj ciro marj matrisi maliyetsiz satır iade maliyeti trend',
     'Satış anındaki ortalama maliyetle müşteri / ürün / temsilci / kategori / şube bazında brüt kâr ve marj; müşteri ABC, ciro × marj tablosu, maliyetin altında satışlar, '
     || 'hedef marjın altı uyarısı, maliyeti bilinmeyen satır rozeti ve 12 aylık trend.'),
    ('satinalma-icmali', '/satinalma-icmali', 'Satınalma Süreç İcmali', 'Satınalma › İcmaller › Satınalma Süreç İcmali', 'Satınalma', 'satinalma.icmali', 0::smallint,
     'satınalma icmal süreç huni talep onay teklif sipariş mal kabul fatura kontrol ödeme bekleyen onaycı hatırlat tedarikçi karnesi fiyat analizi tasarruf bütçe aşım taahhüt kritik stoktan gelen talep',
     'Talepten ödemeye her aşamadaki belge sayısı ve süresi, onaycısında bekleyen belgeler (hatırlatma), tedarikçi karnesi, teklif tasarrufu ve fiyat artışı, '
     || 'bütçe kullanımı ve kritik stoktan otomatik açılan talepler.'),
    ('kdv-icmali', '/kdv-icmali', 'KDV İcmali', 'Muhasebe › İcmaller › KDV İcmali', 'Muhasebe', 'muhasebe.kdv_icmali', 0::smallint,
     'kdv icmal hesaplanan indirilecek ödenecek devreden oran tevkifat istisna iade ba bs form beyanname öncesi kontrol gib gönderilmemiş muhasebe 191 391 360 karşılaştırma mükellef vkn',
     'Beyandan önce KDV kontrolü: orana göre hesaplanan ve indirilecek KDV, tevkifat, istisnalar, iadeler, Ba/Bs listesi, GİB''e gitmemiş belgeler ve '
     || 'muhasebedeki 191 / 391 / 360 bakiyeleriyle karşılaştırma; devreden KDV muhasebeden ya da elle.'),
    ('teknik-servis-icmali', '/teknik-servis-icmali', 'Teknik Servis İcmali', 'Teknik Servis › İcmaller › Teknik Servis İcmali', 'Teknik Servis', 'servis.icmali', 0::smallint,
     'teknik servis icmal çağrı iş emri ziyaret sla müdahale süresi ilk ziyarette çözüm teknisyen performansı cihaz model arıza kodu tekrar arıza parça emanet sözleşme kârlılığı faturalanmamış garanti memnuniyet',
     'Servis çağrıları ve iş emirleri: kapsam (ücretli / sözleşme / garanti), taahhüt edilen müdahale süresi, ilk ziyarette çözüm, teknisyen ve cihaz / model bazında performans, '
     || 'tekrar arıza, parça, emanet cihaz, sözleşme kârlılığı ve faturalanmamış işler.'),
    ('uretim-icmali', '/uretim-icmali', 'Üretim İcmali', 'Üretim › İcmaller › Üretim İcmali', 'Üretim', 'uretim.icmali', 1::smallint,
     'üretim icmal üretim emri plan gerçekleşen sarf fire maliyet sapması iş merkezi yükü kapasite malzeme ihtiyacı eksik hammadde fason alt emir yarı mamul',
     'Üretim emirlerinde plan ve gerçekleşen miktar, malzeme sarfı, fire, plan / gerçek maliyet sapması, iş merkezi yükü ve açık emirlerin eksik hammadde ihtiyacı.'))
    as v(kaynak, rota, baslik, yol, grup, yetki_kodu, urun_modu, anahtar, aciklama)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
