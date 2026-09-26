-- =====================================================================
--  912_istem_banko_kapisi.sql
--  İSTEM BANKO KAPISI — poliklinikte tetkik isteği önce bankoda ücretlenir,
--  SONRA lab/radyoloji çalışma listesine düşer.
--
--  İŞLEYİŞ (kullanıcı): hasta gelir → kimlik + başvuru → doktor muayenede
--  lab/radyoloji ister → istek ÖNCE başvuruya düşer → bankoda tetkik girişi
--  + ücretlendirme (ödeme şimdi ya da sonra) → banko SERBEST bırakınca istem
--  lab/rad worklist'inde görünür.
--
--  ============ NEDEN SERT DEĞİL, YAPILANDIRILABİLİR ==================
--  Kliniği mali akışa TAM bağlamak acil/yatan hastada tehlikeli: stat tetkik
--  veznede beklemez. Bu yüzden kapı SADECE poliklinikte (varsayılan):
--    * kaynak muayene DIŞI (banko/dış/checkup/teletıp) → zaten kayıt-kabulden
--      geçti, serbest.
--    * öncelik ACİL (2) → beklemez, serbest.
--    * başvuru ACİL(2)/YATAN(3) → beklemez, serbest.
--    * yalnız POLİKLİNİK(1) muayene isteği banko bekler (serbest=0).
--  kurum_profil.istem_banko_kapisi: 0 kapalı · 1 poliklinik (varsayılan) ·
--  2 tümü (poliklinik+günübirlik+lab/görüntüleme; acil/yatan hep bypass).
--
--  ============ KLİNİK ≠ TİCARİ KAYIT KORUNUR =========================
--  serbest bırakmak = "bankoda kaydedildi / ücretlendirildi", ÖDEME değil.
--  Tahsilat ayrı aşamadır ve sonraya kalabilir (mevcut açık-borç mantığı).
--  Mevcut satırlar serbest=1 (görünür) - geçmiş worklist boşalmaz.
-- =====================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------- kurum profili ayarı ----
alter table public.kurum_profil
  add column if not exists istem_banko_kapisi smallint not null default 1;
comment on column public.kurum_profil.istem_banko_kapisi is
  '912: tetkik isteği banko kapısı — 0 kapalı · 1 poliklinik · 2 tümü.';

-- ------------------------------------------------- istem serbest kolonu ----
-- default 1: hem mevcut satırlar hem kapı-dışı yeni istemler görünür kalır.
alter table public.lab_istem
  add column if not exists serbest smallint not null default 1;
alter table public.radyoloji_istem
  add column if not exists serbest smallint not null default 1;
comment on column public.lab_istem.serbest is
  '912: 1 kabule açık · 0 banko ücretlendirmesi bekliyor (poliklinik kapısı).';
comment on column public.radyoloji_istem.serbest is
  '912: 1 çekime açık · 0 banko ücretlendirmesi bekliyor (poliklinik kapısı).';

create index if not exists ix_lab_istem_serbest
  on public.lab_istem (sube_id, serbest) where serbest = 0;
create index if not exists ix_radyoloji_istem_serbest
  on public.radyoloji_istem (sube_id, serbest) where serbest = 0;

-- ------------------------------------------------------ karar fonksiyonu ----
/**
 * İstem açılırken SERBEST değerini tek yerde hesaplar (muayene/lab/radyoloji
 * uçları hepsi bunu çağırır - kural üç yere kopyalanmaz, sapmaz).
 *   döner: 1 = kabule açık (worklist görür) · 0 = banko bekliyor (gizli)
 */
create or replace function public.fn_istem_serbest(
    p_sube         smallint,
    p_basvuru_turu smallint,
    p_oncelik      smallint,
    p_kaynak       smallint)
returns smallint
language plpgsql stable
as $$
declare v_kapi smallint;
begin
    -- Muayene DIŞI kaynak (banko 3 · dış 4 · checkup 5 · teletıp 2): istek
    --   zaten kayıt-kabulden geçti, ayrıca banko beklemez.
    if coalesce(p_kaynak, 1) <> 1 then return 1; end if;
    -- Acil öncelik (rad.oncelik/lab: 2 = Acil): stat tetkik beklemez.
    if coalesce(p_oncelik, 1) >= 2 then return 1; end if;

    select coalesce(
        (select istem_banko_kapisi from public.kurum_profil where sube_id = coalesce(p_sube, 0)),
        (select istem_banko_kapisi from public.kurum_profil where sube_id = 0),
        1) into v_kapi;

    if v_kapi = 0 then return 1; end if;                         -- kapı kapalı
    -- Acil(2) / Yatan(3) başvuru: her kapı ayarında bypass.
    if coalesce(p_basvuru_turu, 0) in (2, 3) then return 1; end if;

    if v_kapi = 1 then                                           -- yalnız poliklinik
        return case when p_basvuru_turu = 1 then 0 else 1 end;
    end if;
    -- v_kapi = 2 (tümü): poliklinik(1) + günübirlik(4) + lab/görüntüleme(5).
    return case when coalesce(p_basvuru_turu, 0) in (1, 4, 5) then 0 else 1 end;
end $$;

comment on function public.fn_istem_serbest(smallint, smallint, smallint, smallint) is
  '912: istem serbest kararı (1 worklist görür / 0 banko bekliyor). Tek kaynak.';

-- ----------------------------------------- worklist görünümüne serbest ----
-- Rapor/dış sorgu için görünüme de eklenir (worklist ekran süzmesi SabitKosul
--   ile kaynak katalogunda yapılır - ikisi de i.serbest okur).
create or replace view public.v_radyoloji_worklist as
 SELECT i.id,
    i.sube_id,
    i.accession_no,
    i.durum,
    i.oncelik,
    i.modalite,
    coalesce(md.ad, ''::character varying) AS modalite_adi,
    coalesce(dd.ad, ''::character varying) AS durum_adi,
    i.cekim_tarihi,
    i.hasta_id,
    coalesce(h.unvan, ''::character varying) AS hasta_adi,
    coalesce(hz.kod, ''::character varying) AS tetkik_kodu,
    coalesce(hz.ad, ''::character varying) AS tetkik_adi,
    coalesce(ih.unvan, nullif(i.dis_hekim_ad::text, ''::text)::character varying) AS isteyen,
    coalesce(ik.unvan, ''::character varying) AS isteyen_kurum,
    i.belge_id,
    b.belge_no,
    coalesce(ok.unvan, ''::character varying) AS odeyen_kurum,
    r.id AS rapor_id,
    coalesce(r.durum::integer, 0) AS rapor_durum,
    coalesce(ry.unvan, ''::character varying) AS raporlayan,
    round(extract(epoch from now()::timestamp without time zone
                  - coalesce(i.cekim_tarihi, i.ekleme_tarihi)) / 60::numeric)::integer AS bekleme_dk,
    i.serbest
   FROM radyoloji_istem i
     LEFT JOIN taraf h ON h.id = i.hasta_id
     LEFT JOIN hizmet hz ON hz.id = i.hizmet_id
     LEFT JOIN taraf ih ON ih.id = i.istek_hekim_id
     LEFT JOIN taraf ik ON ik.id = i.istek_kurum_id
     LEFT JOIN belge b ON b.id = i.belge_id
     LEFT JOIN belge_basvuru bb ON bb.id = b.id
     LEFT JOIN taraf ok ON ok.id = bb.odeyen_kurum_id
     LEFT JOIN radyoloji_rapor r ON r.istem_id = i.id AND r.ust_rapor_id IS NULL
     LEFT JOIN taraf ry ON ry.id = coalesce(r.onaylayan_id, r.yazan_id)
     LEFT JOIN kod_deger md ON md.deger = i.modalite AND md.liste_id =
         (SELECT kod_liste.id FROM kod_liste WHERE kod_liste.kod::text = 'rad.modalite'::text)
     LEFT JOIN kod_deger dd ON dd.deger = i.durum AND dd.liste_id =
         (SELECT kod_liste.id FROM kod_liste WHERE kod_liste.kod::text = 'rad.istem_durum'::text);

do $$
begin
    raise notice '912 tamam: banko kapisi kolonu + serbest (lab %, rad %) + fn_istem_serbest',
        (select count(*) from public.lab_istem where serbest = 0),
        (select count(*) from public.radyoloji_istem where serbest = 0);
end $$;
