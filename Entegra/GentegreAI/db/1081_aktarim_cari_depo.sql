-- =============================================================================
--  1081  DELPHI AKTARIMI - ALTYAPI + İLK DİLİM: DEPO, CARİ (dokuman/18 §11 adım 3)
--
--  Ajan Delphi satırlarını JSON olarak gönderir; fonksiyonlar onları
--  `jsonb_populate_recordset(null::stg.<tablo>, ...)` ile stg tablo şekline
--  çevirir (stg = MSSQL kolonlarının PG karşılığı, her kurulumda var). Böylece
--  ilk kurulum göçünün SQL'i neredeyse aynen kullanılır ve ajan, ilk tam yükleme,
--  eşdeğerlik testi AYNI fonksiyonu çağırır.
--
--  PAKET:  {"U": {"REHBER": [ {..satır..} ], "REHBERBILGI": [...], ...},
--           "D": {"REHBER": [id, ...]}}
--  Satır anahtarları MSSQL kolon adlarının KÜÇÜK harflisi (stg ile aynı).
--  Bir TOPLAM (cari) gönderilirken bütün parçaları gelir: REHBER satırı + o
--  carinin bütün REHBERILETISIM ve REHBERBILGI satırları. Pakette olmayan
--  parça (silinmiş adres) web'de pasifleşir.
--
--  KİMLİK (1080): web id'yi kendi üretir; eşleme aktarim_kaynak = 1 +
--  aktarim_tablo + aktarim_id ile. Web'de açılmış kayda (aktarim_kaynak null)
--  ASLA yazılmaz.
--
--  GÖÇTEN BİLEREK FARKLI (eşdeğerlik raporunda beklenen fark):
--   * Zaman: Delphi yerel saati kurum dilimiyle çevrilir (göç UTC sayıyordu,
--     kayıtlar 3 saat kayıktı); 1901 öncesi "boş tarih" null.
--   * temsilci / ekleyen / degistiren: Delphi KULLANICI kimlikleri - kullanıcılar
--     aktarılmıyor, web'de başka kişiye işaret ederlerdi -> boş.
--   * Rol: yeni cari varsayılan MÜŞTERİ (bag_id doluysa ayrıca KİŞİ); tedarikçi
--     bayrağı alış belgesi gelince belge diliminde. Var olan kartta web'in
--     verdiği roller (hasta, kurum...) EZİLMEZ.
--   * REHBER.ID < 0 kurumun kendi şubeleridir -> cari değil, atlanır.
--   * WEB'İN SAHİP OLDUĞU KART GÜNCELLENMEZ: personel (kadro web'de - unvan yalnız
--     önek, ad/soyad ayrı, 940) ve hasta kartı Delphi verisiyle ezilmez; yalnız
--     eşleşmesi kalır ('web_sahipli' sayacı).
--   * İÇERİĞİ AYNI SATIRA YAZILMAZ: web tetiği her UPDATE'te degistirme_tarihi'ni
--     şimdi yapar; tam yeniden eşitlemede binlerce boş "değişiklik" ve günlük
--     gürültüsü olurdu (eşdeğerlik testi 13.10.2026: 2.364 cari).
--  İdempotent.
-- =============================================================================

begin;

-- ---------------------------------------------------------------- ayarlar ---
create table if not exists public.aktarim_ayar (
    anahtar  varchar(60) primary key,
    deger    varchar(200) not null,
    aciklama varchar(300)
);
insert into public.aktarim_ayar (anahtar, deger, aciklama) values
    ('saat_dilimi', 'Europe/Istanbul', 'Delphi tarihleri (saat dilimsiz) bu dilimde yorumlanır'),
    ('varsayilan_sube', '', 'Eşlemesi olmayan Delphi SUBEID için web şube id; boşsa en küçük şube')
on conflict (anahtar) do nothing;

create table if not exists public.aktarim_sube_esleme (
    delphi_sube_id integer primary key,
    sube_id        integer not null references public.sube (id)
);

create or replace function public.fn_aktarim_sube(p_delphi integer)
returns integer language sql stable as $$
    select coalesce(
        (select e.sube_id from public.aktarim_sube_esleme e where e.delphi_sube_id = p_delphi),
        (select nullif(a.deger, '')::integer from public.aktarim_ayar a where a.anahtar = 'varsayilan_sube'),
        (select min(s.id) from public.sube s))
$$;

-- Delphi "boş tarih" için 1899-12-30 / 1900-01-01 yazar; o yıllara saat dilimi
--   uygulanınca İstanbul'un tarihsel yerel saati (+1:56:56) anlamsız değer verir
--   (eşdeğerlik testi: 1900-01-01 -> 1899-12-31 22:03:04). 1901 öncesi = boş.
create or replace function public.fn_aktarim_zaman(p timestamp)
returns timestamptz language sql stable as $$
    select case when p is null or p < timestamp '1901-01-01' then null
                else p at time zone coalesce(
                    (select a.deger from public.aktarim_ayar a where a.anahtar = 'saat_dilimi'),
                    'Europe/Istanbul') end
$$;

-- Delphi kimliği -> web id (yoksa null).
create or replace function public.fn_aktarim_web_id(p_tablo text, p_kaynak_tablo text, p_delphi bigint)
returns integer language plpgsql stable as $$
declare v integer;
begin
    if p_delphi is null then return null; end if;
    execute format('select id from public.%I where aktarim_kaynak = 1 and aktarim_tablo = $1 and aktarim_id = $2',
                   p_tablo) into v using p_kaynak_tablo, p_delphi;
    return v;
end $$;

-- ------------------------------------------------------------------ depo ---
create or replace function public.fn_aktar_depo(p jsonb)
returns jsonb language plpgsql as $$
declare v_yaz int := 0; v_sil int := 0;
begin
    with r as (select * from jsonb_populate_recordset(null::stg.depolar, coalesce(p->'U'->'DEPOLAR', '[]')))
    insert into public.depo (ad, durum, varsayilan, maliyeti_etkilesin, son_sayim_tarihi, sube_id,
                             ekleme_tarihi, degistirme_tarihi, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select coalesce(nullif(btrim(r.depoadi), ''), '(adsız depo)'), coalesce(r.durum, 1),
           0, coalesce(r.maliyeti_etkilesin, 1),
           public.fn_aktarim_zaman(r.sonsayimtarihi), public.fn_aktarim_sube(r.subeid),
           coalesce(public.fn_aktarim_zaman(r.eklemetarihi), now()), public.fn_aktarim_zaman(r.degistirmetarihi),
           1, 'DEPOLAR', r.id
      from r
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set ad = excluded.ad, durum = excluded.durum,
                  maliyeti_etkilesin = excluded.maliyeti_etkilesin,
                  son_sayim_tarihi = excluded.son_sayim_tarihi, sube_id = excluded.sube_id,
                  degistirme_tarihi = excluded.degistirme_tarihi
     where (public.depo.ad, public.depo.durum, public.depo.maliyeti_etkilesin,
            public.depo.son_sayim_tarihi, public.depo.sube_id)
           is distinct from
           (excluded.ad, excluded.durum, excluded.maliyeti_etkilesin,
            excluded.son_sayim_tarihi, excluded.sube_id);
    get diagnostics v_yaz = row_count;

    -- VARSAYILAN AYRI ADIMDA (web: tek varsayılan, trg_depo_varsayilan_tek öbürlerini
    --   sıfırlar). Delphi'de birden çok varsayılan olabiliyor (BILIM: 1, 8, 9, 12) -
    --   aynı komutta yazınca tetik satırları ikinci kez değiştiriyor ("cannot affect
    --   row a second time"). En küçük Delphi kimliği kazanır (lokasyon kuralıyla aynı).
    update public.depo d set varsayilan = 1, durum = 1
     where d.aktarim_kaynak = 1 and d.aktarim_tablo = 'DEPOLAR' and d.varsayilan <> 1
       and d.aktarim_id = (select min(r.id) from jsonb_populate_recordset(null::stg.depolar,
                              coalesce(p->'U'->'DEPOLAR', '[]')) r where r.varsayilan = 1);

    -- Silinen depo: hareketlere bağlı olabilir -> silinmez, pasifleşir (varsayılan
    --   depo pasif olamaz: önce varsayılanlığı kalkar).
    update public.depo d set varsayilan = 0, durum = 0
     where d.aktarim_kaynak = 1 and d.aktarim_tablo = 'DEPOLAR'
       and d.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'DEPOLAR', '[]'))::bigint);
    get diagnostics v_sil = row_count;
    return jsonb_build_object('depo', v_yaz, 'depo_pasif', v_sil);
end $$;

-- ------------------------------------------------------------------ cari ---
create or replace function public.fn_aktar_cari(p jsonb)
returns jsonb language plpgsql as $$
declare
    v_taraf int := 0; v_adres int := 0; v_adres_pasif int := 0; v_atla int := 0; v_sil int := 0;
    v_web int := 0;
begin
    create temp table if not exists _r  (like stg.rehber)         on commit drop;
    create temp table if not exists _ri (like stg.rehberiletisim) on commit drop;
    create temp table if not exists _rb (like stg.rehberbilgi)    on commit drop;
    truncate _r, _ri, _rb;
    insert into _r  select * from jsonb_populate_recordset(null::stg.rehber,         coalesce(p->'U'->'REHBER', '[]'));
    insert into _ri select * from jsonb_populate_recordset(null::stg.rehberiletisim, coalesce(p->'U'->'REHBERILETISIM', '[]'));
    insert into _rb select * from jsonb_populate_recordset(null::stg.rehberbilgi,    coalesce(p->'U'->'REHBERBILGI', '[]'));

    select count(*) into v_atla from _r where id <= 0;      -- kurumun kendi şubeleri
    delete from _r where id <= 0;

    -- Web'in sahip olduğu kart (personel / hasta): eşleşme durur, içerik yazılmaz.
    create temp table if not exists _web (rehber_id int) on commit drop;
    truncate _web;
    insert into _web
    select r.id from _r r
      join public.taraf t on t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER' and t.aktarim_id = r.id
     where t.personel = 1 or t.hasta = 1;
    get diagnostics v_web = row_count;
    delete from _r r using _web w where w.rehber_id = r.id;

    -- 1) kart
    insert into public.taraf
          (kod, eski_tip, unvan, statu, grup, kategori, sinif, durum, sektor, alt_sektor,
           bolge, alt_bolge, posta_izin, eposta_izin, efatura, notlar, ozel_kod, ozel,
           yetki_kodu, muh_kodu, muh_aktar, konum, peryot, giris_kaynak, d_tarih, resim, sube_id,
           ekleme_tarihi, degistirme_tarihi, musteri, tedarikci, personel, kisi, hasta,
           aktarim_kaynak, aktarim_tablo, aktarim_id)
    select r.kod, 1, coalesce(nullif(btrim(r.firma), ''), '(adsiz)'),
           r.statu, r.grup, r.kategori, r.sinif, coalesce(r.durum, 0), r.sektor, r.altsektor,
           r.bolge, r.altbolge, coalesce(r.posta, 0), coalesce(r.eposta, 0), coalesce(r.efatura, 0),
           r.notlar, r.ozelkod, r.ozel, r.yetkikodu, r.muhkodu, r.muhaktar, r.konum, r.peryot,
           r.giriskaynak, public.fn_aktarim_zaman(r.dtarih), r.resim, public.fn_aktarim_sube(r.subeid),
           coalesce(public.fn_aktarim_zaman(r.eklemetarihi), now()), public.fn_aktarim_zaman(r.degistirmetarihi),
           1, 0, 0, 0, 0,
           1, 'REHBER', r.id
      from _r r
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set kod = excluded.kod, unvan = excluded.unvan, statu = excluded.statu, grup = excluded.grup,
                  kategori = excluded.kategori, sinif = excluded.sinif, durum = excluded.durum,
                  sektor = excluded.sektor, alt_sektor = excluded.alt_sektor, bolge = excluded.bolge,
                  alt_bolge = excluded.alt_bolge, posta_izin = excluded.posta_izin,
                  eposta_izin = excluded.eposta_izin, efatura = excluded.efatura, notlar = excluded.notlar,
                  ozel_kod = excluded.ozel_kod, ozel = excluded.ozel, yetki_kodu = excluded.yetki_kodu,
                  muh_kodu = excluded.muh_kodu, muh_aktar = excluded.muh_aktar, konum = excluded.konum,
                  peryot = excluded.peryot, giris_kaynak = excluded.giris_kaynak, d_tarih = excluded.d_tarih,
                  resim = excluded.resim, sube_id = excluded.sube_id,
                  degistirme_tarihi = excluded.degistirme_tarihi
                  -- rol bayraklari EZILMEZ (kisi bag baglaninca asagida)
     where (public.taraf.kod, public.taraf.unvan, public.taraf.statu, public.taraf.grup,
            public.taraf.kategori, public.taraf.sinif, public.taraf.durum, public.taraf.sektor,
            public.taraf.alt_sektor, public.taraf.bolge, public.taraf.alt_bolge, public.taraf.posta_izin,
            public.taraf.eposta_izin, public.taraf.efatura, public.taraf.notlar, public.taraf.ozel_kod,
            public.taraf.ozel, public.taraf.yetki_kodu, public.taraf.muh_kodu, public.taraf.muh_aktar,
            public.taraf.konum, public.taraf.peryot, public.taraf.giris_kaynak, public.taraf.d_tarih,
            md5(coalesce(public.taraf.resim, '')), public.taraf.sube_id)
           is distinct from
           (excluded.kod, excluded.unvan, excluded.statu, excluded.grup,
            excluded.kategori, excluded.sinif, excluded.durum, excluded.sektor,
            excluded.alt_sektor, excluded.bolge, excluded.alt_bolge, excluded.posta_izin,
            excluded.eposta_izin, excluded.efatura, excluded.notlar, excluded.ozel_kod,
            excluded.ozel, excluded.yetki_kodu, excluded.muh_kodu, excluded.muh_aktar,
            excluded.konum, excluded.peryot, excluded.giris_kaynak, excluded.d_tarih,
            md5(coalesce(excluded.resim, '')), excluded.sube_id);
    get diagnostics v_taraf = row_count;

    -- 2) bağlı kişi (BAGID -> üst cari). Üst cari aynı pakette ya da önceden gelmiş olmalı.
    update public.taraf c
       set bag_id = u.id
      from _r r
      join public.taraf u on u.aktarim_kaynak = 1 and u.aktarim_tablo = 'REHBER' and u.aktarim_id = r.bagid
     where coalesce(r.bagid, 0) > 0
       and c.aktarim_kaynak = 1 and c.aktarim_tablo = 'REHBER' and c.aktarim_id = r.id
       and c.bag_id is distinct from u.id;

    -- "kişi" rolü yalnız üst cari BAĞLANABİLDİYSE (göç 018 ile aynı kural).
    update public.taraf c set kisi = 1
      from _r r
     where c.aktarim_kaynak = 1 and c.aktarim_tablo = 'REHBER' and c.aktarim_id = r.id
       and c.bag_id is not null and c.kisi = 0;

    -- 3) mali kimlik (REHBERBILGI YERI=2, YER_ID = REHBER.ID)
    with b as (
        select bi.yer_id as rehber_id, public.fn_etiket_anahtar(bi.etiket) as anahtar, btrim(bi.bilgi) as deger,
               row_number() over (partition by bi.yer_id, public.fn_etiket_anahtar(bi.etiket)
                                  order by bi.sira, bi.id) as sn
          from _rb bi
         where bi.yeri = 2 and coalesce(btrim(bi.bilgi), '') <> ''
    ), m as (
        select r.id as rehber_id,
               max(b.deger) filter (where b.anahtar = 'vergi no')      as vkno,
               max(b.deger) filter (where b.anahtar = 'vergi dairesi') as vd
          from _r r left join b on b.rehber_id = r.id and b.sn = 1
         group by r.id
    )
    update public.taraf t
       set vkno = left(m.vkno, 20), vd = left(m.vd, 60)
      from m
     where t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER' and t.aktarim_id = m.rehber_id
       and (t.vkno is distinct from left(m.vkno, 20) or t.vd is distinct from left(m.vd, 60));

    -- 4) lokasyonlar (REHBERILETISIM + REHBERBILGI YERI=1, YER_ID = ILETISIM.ID)
    create temp table if not exists _lok (
        iletisim_id int, rehber_id int, baslik text, varsayilan int, aktif int, subeid int,
        eklemetarihi timestamp, degistirmetarihi timestamp,
        adres text, ilce text, il text, ulke text, posta_kodu text, telefon text, cep_tel text,
        eposta text, web text, yetkili text, varsayilan_tek int) on commit drop;
    truncate _lok;
    insert into _lok
    with b as (
        select bi.yer_id as iletisim_id, public.fn_etiket_anahtar(bi.etiket) as anahtar, btrim(bi.bilgi) as deger,
               row_number() over (partition by bi.yer_id, public.fn_etiket_anahtar(bi.etiket)
                                  order by bi.sira, bi.id) as sn
          from _rb bi
         where bi.yeri = 1 and coalesce(btrim(bi.bilgi), '') <> ''
    ), l as (
        select i.id as iletisim_id, i.rehberid as rehber_id,
               coalesce(nullif(btrim(i.ad), ''), 'Merkez') as baslik,
               coalesce(i.varsayilan, 0) as varsayilan, coalesce(i.aktif, 1) as aktif, i.subeid,
               i.eklemetarihi, i.degistirmetarihi,
               max(b.deger) filter (where b.anahtar = 'adres')                       as adres,
               max(b.deger) filter (where b.anahtar = 'ilce')                        as ilce,
               max(b.deger) filter (where b.anahtar = 'il')                          as il,
               max(b.deger) filter (where b.anahtar = 'ulke')                        as ulke,
               max(b.deger) filter (where b.anahtar = 'pk')                          as posta_kodu,
               max(b.deger) filter (where b.anahtar in ('is tel','tel','telefon'))   as telefon,
               max(b.deger) filter (where b.anahtar = 'cep tel')                     as cep_tel,
               max(b.deger) filter (where b.anahtar in ('eposta','e-posta','email')) as eposta,
               max(b.deger) filter (where b.anahtar = 'web')                         as web,
               max(b.deger) filter (where b.anahtar = 'iletisimi')                   as yetkili
          from _ri i
          join _r r on r.id = i.rehberid
          left join b on b.iletisim_id = i.id and b.sn = 1
         group by i.id, i.rehberid, i.ad, i.varsayilan, i.aktif, i.subeid, i.eklemetarihi, i.degistirmetarihi
    )
    select l.*,
           case when l.varsayilan = 1
                 and l.iletisim_id = min(case when l.varsayilan = 1 then l.iletisim_id end)
                                     over (partition by l.rehber_id)
                then 1 else 0 end
      from l;

    insert into public.taraf_adres
          (taraf_id, tur, baslik, adres, ilce, il, ulke, posta_kodu, yetkili, telefon, eposta,
           varsayilan, aktif, sube_id, ekleme_tarihi, degistirme_tarihi,
           aktarim_kaynak, aktarim_tablo, aktarim_id)
    select t.id, 1, left(l.baslik, 60), left(l.adres, 300), left(l.ilce, 60), left(l.il, 60),
           coalesce(nullif(left(l.ulke, 60), ''), 'Turkiye'), left(l.posta_kodu, 10),
           left(l.yetkili, 60), left(l.telefon, 30), left(l.eposta, 120),
           l.varsayilan_tek, l.aktif, public.fn_aktarim_sube(l.subeid),
           coalesce(public.fn_aktarim_zaman(l.eklemetarihi), now()), public.fn_aktarim_zaman(l.degistirmetarihi),
           1, 'REHBERILETISIM', l.iletisim_id
      from _lok l
      join public.taraf t on t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER' and t.aktarim_id = l.rehber_id
     where coalesce(l.adres, l.il, l.ilce, l.posta_kodu, l.telefon, l.eposta) is not null
    on conflict (aktarim_kaynak, aktarim_tablo, aktarim_id) where aktarim_kaynak is not null
    do update set taraf_id = excluded.taraf_id, baslik = excluded.baslik, adres = excluded.adres,
                  ilce = excluded.ilce, il = excluded.il, ulke = excluded.ulke, posta_kodu = excluded.posta_kodu,
                  yetkili = excluded.yetkili, telefon = excluded.telefon, eposta = excluded.eposta,
                  varsayilan = excluded.varsayilan, aktif = excluded.aktif, sube_id = excluded.sube_id,
                  degistirme_tarihi = excluded.degistirme_tarihi
     where (public.taraf_adres.taraf_id, public.taraf_adres.baslik, public.taraf_adres.adres,
            public.taraf_adres.ilce, public.taraf_adres.il, public.taraf_adres.ulke,
            public.taraf_adres.posta_kodu, public.taraf_adres.yetkili, public.taraf_adres.telefon,
            public.taraf_adres.eposta, public.taraf_adres.varsayilan, public.taraf_adres.aktif,
            public.taraf_adres.sube_id)
           is distinct from
           (excluded.taraf_id, excluded.baslik, excluded.adres, excluded.ilce, excluded.il,
            excluded.ulke, excluded.posta_kodu, excluded.yetkili, excluded.telefon, excluded.eposta,
            excluded.varsayilan, excluded.aktif, excluded.sube_id);
    get diagnostics v_adres = row_count;

    -- Pakette olmayan (Delphi'de silinmiş) adres: belgede kullanılmış olabilir -> pasif.
    update public.taraf_adres a set aktif = 0
      from public.taraf t
      join _r r on t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER' and t.aktarim_id = r.id
     where a.taraf_id = t.id and a.aktarim_kaynak = 1 and a.aktarim_tablo = 'REHBERILETISIM'
       and a.aktif <> 0
       and not exists (select 1 from _lok l where l.iletisim_id = a.aktarim_id
                         and coalesce(l.adres, l.il, l.ilce, l.posta_kodu, l.telefon, l.eposta) is not null);
    get diagnostics v_adres_pasif = row_count;

    -- 5) kartın iletişim kolonları = varsayılan lokasyon
    with s as (
        select distinct on (r.id) r.id as rehber_id, l.telefon, l.cep_tel, l.eposta, l.web
          from _r r left join _lok l on l.rehber_id = r.id
         order by r.id, l.varsayilan_tek desc nulls last, l.aktif desc nulls last, l.iletisim_id
    )
    update public.taraf t
       set telefon = left(s.telefon, 30), cep_tel = left(s.cep_tel, 30),
           eposta = left(s.eposta, 120), eposta_web = left(s.web, 200)
      from s
     where t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER' and t.aktarim_id = s.rehber_id
       and (t.telefon, t.cep_tel, t.eposta, t.eposta_web)
           is distinct from (left(s.telefon, 30), left(s.cep_tel, 30), left(s.eposta, 120), left(s.web, 200));

    -- 6) Delphi'de silinen cari: belgelere bağlı olabilir -> silinmez, pasifleşir (durum 0).
    update public.taraf t set durum = 0
     where t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER'
       and t.aktarim_id in (select jsonb_array_elements_text(coalesce(p->'D'->'REHBER', '[]'))::bigint);
    get diagnostics v_sil = row_count;

    return jsonb_build_object('taraf', v_taraf, 'adres', v_adres, 'adres_pasif', v_adres_pasif,
                              'sube_atlandi', v_atla, 'taraf_pasif', v_sil, 'web_sahipli', v_web);
end $$;

comment on function public.fn_aktar_cari(jsonb) is
    '1081: Delphi carisi (REHBER + REHBERILETISIM + REHBERBILGI) -> taraf / taraf_adres. Toplam bazlı, idempotent.';

commit;
