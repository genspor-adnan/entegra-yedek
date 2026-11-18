-- =============================================================================
--  1374  RADYOLOJİ RAPORU REVİZE (kullanıcı 18.11.2026: "onaylanıp / e-imzalanıp teslim edildiyse veya teleradyoloji
--        gönderimi yapıldıysa onay iptal dendiğinde onay geri alınamaz ama revize yapılabilir denmeli.. devam edilirse
--        raporun kopyası çıkarılmalı, eski rapor da revize olarak kalmalı")
--
--  Dışarı çıkmış (teslim / e-Nabız / Teletıp) raporun onayı iptal edilemez; REVİZE edilir:
--   * Raporun o anki hâli (metin, alanlar, lezyonlar, rapor no, onay, e-imza) bir ARŞİV KOPYASINA yazılır:
--     radyoloji_rapor.revize = 1, ust_rapor_id = ana rapor. Teslim ve Teletıp gönderim kayıtları kopyaya taşınır -
--     "hastaya / Bakanlık'a hangi metin gitti" sorusunun cevabı değişmez.
--   * ANA rapor (aynı kimlik - listeler, istem, e-Nabız bağı onu gösterir) taslağa döner, numarası revize ekiyle
--     (R-…-R1) düzeltilir ve yeniden onaylanır. Yeniden onayda Teletıp'a DÜZELTME (Duzeltme bayrağı) ve e-Nabız'a
--     güncel sonuç gider; teslim listesinde yeniden "Hazır" olur (düzeltilmiş rapor teslim edilmeli).
--  Bu dosya: kolonlar + revize kopyasını dışlayan görünüm / tetik / ORU verisi. Revize işlemi API'de
--  (POST /api/radyoloji/rapor/{id}/revize). Veri onarımı yok.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

alter table public.radyoloji_rapor add column if not exists revize smallint not null default 0;
alter table public.radyoloji_rapor add column if not exists revize_no smallint not null default 0;
alter table public.radyoloji_rapor add column if not exists revize_tarihi timestamptz;
alter table public.radyoloji_rapor add column if not exists revize_eden_id integer references public.taraf(id);
alter table public.radyoloji_rapor add column if not exists revize_nedeni varchar(300) not null default '';
comment on column public.radyoloji_rapor.revize is
  '1374: 1 = revize edilmiş eski hâlin arşiv kopyası (ust_rapor_id = ana rapor; salt okunur, ek rapor DEĞİL).';
comment on column public.radyoloji_rapor.revize_no is
  '1374: ana raporda kaç kez revize edildiği (rapor no eki -R<n>); kopyada o revizenin numarası.';
create index if not exists ix_radyoloji_rapor_revize on public.radyoloji_rapor (ust_rapor_id) where revize = 1;

create or replace view public.v_radyoloji_teslim_takip as
 SELECT i.id AS istem_id,
    i.sube_id,
    i.accession_no,
    i.modalite,
    i.hasta_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta,
    -- 1373: hastanın telefonu CEP alanında (taraf.cep_tel); sabit hat yalnız cep yoksa.
    COALESCE(NULLIF(btrim(h.cep_tel), ''), h.telefon, '')::character varying AS telefon,
    COALESCE(hz.ad, ''::character varying) AS tetkik,
    r.onay_tarihi,
    COALESCE(public.fn_taraf_ad(ry.unvan, ry.ad, ry.soyad)::character varying(120), ''::character varying) AS radyolog,
    i.durum AS istem_durum,
    COALESCE(i.cd_istendi::integer, 0) AS cd_istendi,
    t.id AS teslim_id,
    t.teslim_zamani,
    COALESCE(t.alan_ad, ''::character varying) AS alan_ad,
    COALESCE(t.alan_yakinlik, ''::character varying) AS alan_yakinlik,
    COALESCE(public.fn_taraf_ad(te.unvan, te.ad, te.soyad)::character varying(120), ''::character varying) AS teslim_eden,
    COALESCE(t.rapor_verildi::integer, 0) AS rapor_verildi,
    COALESCE(t.film_verildi::integer, 0) AS film_verildi,
    COALESCE(t.cd_verildi::integer, 0) AS cd_verildi,
    COALESCE(t.dijital_verildi::integer, 0) AS dijital_verildi,
        CASE
            WHEN t.id IS NULL THEN 1
            ELSE 2
        END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(t.teslim_zamani, now()::timestamp without time zone::timestamp with time zone) - COALESCE(r.onay_tarihi, i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.sablon_id,
            x.sablon_surum,
            x.durum,
            x.yazan_id,
            x.yazma_tarihi,
            x.onaylayan_id,
            x.onay_tarihi,
            x.kilit,
            x.ust_rapor_id,
            x.ekleyen,
            x.ekleme_tarihi,
            x.degistiren,
            x.degistirme_tarihi,
            x.rapor_no
           FROM radyoloji_rapor x
          WHERE x.istem_id = i.id AND COALESCE(x.revize, 0) = 0     -- 1374: revize edilmiş eski hâl seçilmez
          ORDER BY x.id DESC
         LIMIT 1) r ON true
     LEFT JOIN taraf ry ON ry.id = COALESCE(r.onaylayan_id, r.yazan_id)
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.rapor_id,
            x.tur,
            x.teslim_zamani,
            x.teslim_eden_id,
            x.alan_ad,
            x.alan_yakinlik,
            x.kimlik_dogrulandi,
            x.aciklama,
            x.ekleyen,
            x.ekleme_tarihi,
            x.rapor_verildi,
            x.film_verildi,
            x.cd_verildi,
            x.dijital_verildi
           FROM radyoloji_teslim x
          WHERE x.istem_id = i.id
            -- 1374: revize edilmiş hâle yapılmış teslim, düzeltilmiş rapor için teslim sayılmaz (yeniden teslim bekler).
            AND NOT EXISTS (SELECT 1 FROM radyoloji_rapor rv WHERE rv.id = x.rapor_id AND rv.revize = 1)
          ORDER BY x.id DESC
         LIMIT 1) t ON true
     LEFT JOIN taraf te ON te.id = t.teslim_eden_id
  WHERE COALESCE(i.durum::integer, 1) >= 5;

create or replace view public.v_radyoloji_kritik_takip as
 SELECT i.id AS istem_id,
    i.sube_id,
    i.accession_no,
    i.modalite,
    i.hasta_id,
    COALESCE(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120), ''::character varying) AS hasta,
    COALESCE(hz.ad, ''::character varying) AS tetkik,
    r.onay_tarihi,
    i.cekim_tarihi,
    kb.id AS bildirim_id,
    COALESCE(kb.bulgu, ''::character varying) AS bulgu,
    COALESCE(kb.bildirilen_ad, ''::character varying) AS bildirilen_ad,
    kb.bildiren_id,
    COALESCE(public.fn_taraf_ad(bd.unvan, bd.ad, bd.soyad)::character varying(120), ''::character varying) AS bildiren,
    kb.yol,
    kb.bildirim_zamani,
    COALESCE(kb.teyit_alindi::integer, 0) AS teyit_alindi,
    kb.kapatma_zamani,
        CASE
            WHEN kb.id IS NULL THEN 1
            WHEN kb.kapatma_zamani IS NOT NULL THEN 4
            WHEN COALESCE(kb.teyit_alindi::integer, 0) = 1 THEN 3
            ELSE 2
        END AS takip_durum,
    (EXTRACT(epoch FROM COALESCE(kb.bildirim_zamani, now()::timestamp without time zone::timestamp with time zone) - COALESCE(r.onay_tarihi, r.yazma_tarihi, i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS gecen_dk
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN LATERAL ( SELECT x.id,
            x.istem_id,
            x.sablon_id,
            x.sablon_surum,
            x.durum,
            x.yazan_id,
            x.yazma_tarihi,
            x.onaylayan_id,
            x.onay_tarihi,
            x.kilit,
            x.ust_rapor_id,
            x.ekleyen,
            x.ekleme_tarihi,
            x.degistiren,
            x.degistirme_tarihi,
            x.rapor_no
           FROM radyoloji_rapor x
          WHERE x.istem_id = i.id AND COALESCE(x.revize, 0) = 0     -- 1374
          ORDER BY x.id DESC
         LIMIT 1) r ON true
     LEFT JOIN LATERAL ( SELECT k.id,
            k.istem_id,
            k.rapor_id,
            k.bulgu,
            k.bildiren_id,
            k.bildirilen_id,
            k.bildirilen_ad,
            k.yol,
            k.bildirim_zamani,
            k.geri_bildirim,
            k.ekleyen,
            k.ekleme_tarihi,
            k.teyit_alindi,
            k.kapatan_id,
            k.kapatma_zamani
           FROM radyoloji_kritik_bulgu k
          WHERE k.istem_id = i.id
          ORDER BY k.id DESC
         LIMIT 1) kb ON true
     LEFT JOIN taraf bd ON bd.id = kb.bildiren_id
  WHERE COALESCE(i.kritik::integer, 0) = 1 AND COALESCE(i.durum::integer, 1) > 0;

create or replace function public.fn_teletip_oru_verisi(p_rapor_id integer)
returns jsonb language sql stable as $$
  select jsonb_build_object(
    'RaporId',            r.id,
    'IstemId',            r.istem_id,
    'Teknik',             coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 1), ''),
    'Karsilastirma',      coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 2), ''),
    'Bulgular',           coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 3), ''),
    'Sonuc',              coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira) from public.radyoloji_rapor_bolum b
                                     where b.rapor_id = r.id and b.bakanlik_parca = 4), ''),
    'TeknikHtml',         public.fn_rad_bakanlik_parca_html(r.id, 1),
    'KarsilastirmaHtml',  public.fn_rad_bakanlik_parca_html(r.id, 2),
    'BulgularHtml',       public.fn_rad_bakanlik_parca_html(r.id, 3),
    'SonucHtml',          public.fn_rad_bakanlik_parca_html(r.id, 4),
    'OnayZamani',         to_char(r.onay_tarihi at time zone public.fn_sube_zaman_dilimi(i.sube_id), 'YYYY-MM-DD"T"HH24:MI:SS'),
    'CekimZamani',        to_char(i.cekim_tarihi at time zone public.fn_sube_zaman_dilimi(i.sube_id), 'YYYY-MM-DD"T"HH24:MI:SS'),
    'IstemNedeniPuan',    coalesce(r.istem_nedeni_puan, 0),
    'CekimKalitePuan',    coalesce(r.cekim_kalite_puan, 0),
    'RadyologTckn',       case when coalesce(rd.vkno, '') ~ '^[1-9][0-9]{10}$' then rd.vkno else '' end,
    'RadyologSoyad',      upper(coalesce(rd.soyad, '')),
    'RadyologAd',         upper(coalesce(nullif(rd.ad, ''), rd.unvan, '')),
    'KontrastObx17',      coalesce(public.fn_rad_kontrast_obx17(i.id), ''),
    -- 1374: revize edilip yeniden onaylanan rapor da DÜZELTMEDİR (Bakanlık önceki sonucu almıştı).
    'Duzeltme',           r.ust_rapor_id is not null or coalesce(r.revize_no, 0) > 0,
    'RaporEksik',         coalesce(public.fn_rad_bakanlik_eksik(r.id), '')
  )
    from public.radyoloji_rapor r
    join public.radyoloji_istem i on i.id = r.istem_id
    left join public.taraf rd on rd.id = coalesce(r.onaylayan_id, r.yazan_id)
   where r.id = p_rapor_id
$$;

create or replace function public.tg_radyoloji_rapor_teletip()
returns trigger language plpgsql as $$
declare
  i record;
begin
  if not public.fn_teletip_aktif() then return new; end if;
  if new.durum <> 3 or (tg_op = 'UPDATE' and old.durum = 3) then return new; end if;   -- yalnız onaya geçiş
  -- 1374: revize edilmiş eski hâlin arşiv kopyası (onaylı olarak eklenir) gönderilmez.
  if coalesce(new.revize, 0) = 1 then return new; end if;
  select * into i from public.radyoloji_istem where id = new.istem_id;
  if not found or i.durum = 0 or coalesce(i.accession_no, '') = '' then return new; end if;
  -- İstemin NW'si yoksa (Teletıp istemden sonra açıldı) önce NW.
  if not exists (select 1 from public.teletip_gonderim g where g.istem_id = i.id and g.kanal = 1 and g.emir = 1 and g.durum <> 4) then
    perform public.fn_teletip_orm_kuyrukla(i.id, i.accession_no, 1::smallint, i.sube_id, coalesce(new.onaylayan_id, new.degistiren, 0));
  end if;
  if not exists (select 1 from public.teletip_gonderim g where g.rapor_id = new.id and g.emir = 4 and g.durum in (0, 3, 5)) then
    insert into public.teletip_gonderim (istem_id, accession_no, kanal, emir, durum, rapor_id, sube_id, ekleyen)
    values (i.id, i.accession_no, 1, 4, 0, new.id, coalesce(i.sube_id, 0), coalesce(new.onaylayan_id, new.degistiren, 0));
  end if;
  return new;
end $$;

-- ------------------------------------------------------------------ revize işlemi --
-- Ana raporun onaylı hâli arşiv kopyasına (revize = 1) yazılır, ana rapor taslağa döner. Yetki / parola / dışarı çıkma
-- denetimi API'de (RadyolojiUclari.OnayAdina); burada yalnız veri. Döner: arşiv kopyasının kimliği.
create or replace function public.fn_radyoloji_rapor_revize(p_rapor integer, p_kullanici integer, p_neden text)
returns integer language plpgsql as $$
declare
    v_r     public.radyoloji_rapor%rowtype;
    v_kol   text;
    v_yeni  integer;
    v_n     smallint;
    v_taban text;
    v_tablo text;
begin
    select * into v_r from public.radyoloji_rapor where id = p_rapor for update;
    if not found then raise exception 'Rapor bulunamadı.'; end if;
    if v_r.ust_rapor_id is not null or coalesce(v_r.revize, 0) = 1 then
        raise exception 'Yalnız ana rapor revize edilir.';
    end if;
    if v_r.durum <> 3 or v_r.kilit <> 1 then raise exception 'Rapor onaylı değil.'; end if;

    v_n := coalesce(v_r.revize_no, 0) + 1;
    v_taban := regexp_replace(coalesce(v_r.rapor_no, ''), '-R[0-9]+$', '');

    -- Numara arşiv kopyasına geçer (ux_radyoloji_rapor_no tekil): önce ana boşaltılır.
    update public.radyoloji_rapor set rapor_no = '' where id = p_rapor;

    select string_agg(quote_ident(column_name), ', ' order by ordinal_position) into v_kol
      from information_schema.columns
     where table_schema = 'public' and table_name = 'radyoloji_rapor'
       and identity_generation is null and is_generated = 'NEVER'
       and column_name not in ('id', 'ust_rapor_id', 'revize', 'revize_no', 'revize_tarihi', 'revize_eden_id',
                               'revize_nedeni', 'rapor_no');
    execute format(
        'insert into public.radyoloji_rapor (%1$s, ust_rapor_id, revize, revize_no, revize_tarihi, revize_eden_id, revize_nedeni, rapor_no)
         select %1$s, $1, 1, $2, now(), $3, $4, $5 from public.radyoloji_rapor where id = $1 returning id', v_kol)
      into v_yeni using p_rapor, v_n, nullif(p_kullanici, 0), left(coalesce(p_neden, ''), 300), coalesce(v_r.rapor_no, '');

    -- Metin, yapısal alanlar, lezyonlar: arşive KOPYALANIR (ana rapor düzeltilmek üzere aynı içerikle kalır).
    foreach v_tablo in array array['radyoloji_rapor_bolum', 'radyoloji_rapor_alan', 'radyoloji_rapor_lezyon'] loop
        select string_agg(quote_ident(column_name), ', ' order by ordinal_position) into v_kol
          from information_schema.columns
         where table_schema = 'public' and table_name = v_tablo
           and identity_generation is null and is_generated = 'NEVER' and column_name not in ('id', 'rapor_id');
        execute format('insert into public.%1$I (rapor_id, %2$s) select $1, %2$s from public.%1$I where rapor_id = $2',
                       v_tablo, v_kol) using v_yeni, p_rapor;
    end loop;

    -- Dışarı giden izler arşive TAŞINIR: teslim (bu istemin, rapor bağı bu rapor ya da boş) ve Teletıp gönderimleri.
    --   Gitmemiş Teletıp / e-Nabız kayıtları düşer (eski metin artık gönderilmez; yeniden onayda yenisi üretilir).
    update public.radyoloji_teslim set rapor_id = v_yeni
     where istem_id = v_r.istem_id and (rapor_id = p_rapor or rapor_id is null);
    update public.teletip_gonderim set durum = 4 where rapor_id = p_rapor and durum in (0, 3, 5);
    update public.teletip_gonderim set rapor_id = v_yeni where rapor_id = p_rapor;
    update public.enabiz_paket set durum = 5, degistirme_tarihi = now()
     where kaynak_tur = 5 and kaynak_id = p_rapor and durum in (0, 1, 4);

    -- Ana rapor taslağa: onay / e-imza bağı kalkar, numara revize ekiyle.
    update public.radyoloji_rapor
       set durum = 1, kilit = 0, onaylayan_id = null, onay_tarihi = null,
           imza_zamani = null, imzalayan_id = null, imza_sertifika = null, imza_dokuman_id = null, imza_ozet = null,
           revize_no = v_n,
           rapor_no = case when v_taban = '' then '' else left(v_taban || '-R' || v_n, 30) end,
           degistiren = coalesce(p_kullanici, 0), degistirme_tarihi = now()
     where id = p_rapor;
    update public.radyoloji_istem set durum = 3 where id = v_r.istem_id and durum in (5, 6);
    return v_yeni;
end $$;

comment on function public.fn_radyoloji_rapor_revize(integer, integer, text) is
    '1374: onaylı ana raporu revize eder - o anki hâl arşiv kopyasına (revize = 1), teslim / Teletıp izi kopyaya, ana rapor taslağa (no -R<n>).';

commit;
