-- =====================================================================
--  751_dini_bayram_ve_yerel_tatil.sql
--  Dinî bayram tohumu (2026-2027) + yerel tatil süzmesindeki hata.
--
--  ============= YEREL TATİL ZATEN VARDI, SÜZMESİ HATALIYDI ============
--  `resmi_tatil.sube_id` 749'da vardı: boşsa kurum geneli, doluysa yalnız
--  o şube (İzmir'in kurtuluş günü). Ama `fn_izin_gun`un süzgeci
--  "p_sube is null ise hepsini al" diyordu - şube verilmeden çağrıldığında
--  (izin ucu öyle çağırıyordu) İzmir'e özgü tatil BÜTÜN şubelerin izin
--  hesabından düşüyordu. Şube verilmezse yalnız kurum geneli sayılmalı:
--  hangi şubede olduğu bilinmeyen bir hesap, yerel tatili varsaymamalı.
--
--  ============= DİNÎ BAYRAM: GİRİLDİ AMA "DOĞRULANDI" DEĞİL ===========
--  749 dinî bayramları algoritmayla üretmeyi reddetti - o karar duruyor.
--  Burada 2026-2027 tarihleri TOHUM olarak yazılıyor ve `dogrulandi = 0`
--  ile işaretleniyor: bunlar takvim hesabıdır, Diyanet'in ilanı değildir.
--  Kurum ilan çıkınca tarihi kontrol edip bayrağı 1 yapar. Bayrak olmadan
--  yazsaydık kurum bu tarihlere kesin gözüyle bakar ve bir gün kayma
--  bordroya kadar giderdi.
-- =====================================================================

-- ==================================================== DOĞRULAMA BAYRAĞI
alter table public.resmi_tatil
  add column if not exists dogrulandi smallint not null default 1;

comment on column public.resmi_tatil.dogrulandi is
  '751: 0 = takvim hesabi, resmi ilanla DOGRULANMADI (dini bayram tohumu). '
  '1 = kesin. Milli tatiller sabit tarihli oldugu icin varsayilan 1.';

-- ============================== ŞUBE SÜZMESİ: YEREL TATİL SIZMASIN
create or replace function public.fn_izin_gun(
    p_bas date, p_bit date, p_is_gunu smallint default 0, p_sube integer default null)
returns numeric
language sql stable as $$
    select case
      when p_bas is null or p_bit is null or p_bit < p_bas then 0
      when coalesce(p_is_gunu, 0) = 0 then (p_bit - p_bas + 1)::numeric
      else (
        select coalesce(sum(
                 case
                   when extract(isodow from g) >= 6 then 0
                   when t.yarim_gun = 1 then 0.5
                   when t.tarih is not null then 0
                   else 1
                 end), 0)
          from generate_series(p_bas, p_bit, interval '1 day') g
          left join public.resmi_tatil t
                 on t.tarih = g::date and t.aktif = 1
                -- ŞUBE VERİLMEZSE YALNIZ KURUM GENELİ (751): eskiden
                --   "p_sube is null ise hepsi" idi ve bir şubeye özgü
                --   tatil bütün kurumun hesabından düşüyordu.
                and (t.sube_id is null or t.sube_id = p_sube))
    end $$;

comment on function public.fn_izin_gun(date, date, smallint, integer) is
  '743/749/751: izin gun sayisi. is_gunu=1 ise hafta sonu ve resmi tatil '
  'dusulur (arife 0,5). Sube verilmezse YALNIZ kurum geneli tatiller.';

-- ================================================= DİNÎ BAYRAM TOHUMU
--
--  Tarihler hicrî takvim hesabına göredir; Diyanet ilanıyla BİR GÜN
--  kayabilir. `dogrulandi = 0` tam da bunu söylüyor - Resmî Tatiller
--  ekranında "Doğrulanmadı" çipiyle süzülür ve kontrol edilir.
--
--  Arife günleri yarım gündür (13:00'ten sonra).
insert into public.resmi_tatil (tarih, ad, tur, yarim_gun, dogrulandi, aciklama, ekleyen)
select x.tarih, x.ad, 2, x.yarim, 0,
       'Hicrî takvim hesabı - Diyanet ilanıyla doğrulanmalı', 0
  from (values
    -- 2026 · Ramazan Bayramı (Hicrî 1447)
    ('2026-03-19'::date, 'Ramazan Bayramı arifesi',  1::smallint),
    ('2026-03-20'::date, 'Ramazan Bayramı 1. gün',   0::smallint),
    ('2026-03-21'::date, 'Ramazan Bayramı 2. gün',   0::smallint),
    ('2026-03-22'::date, 'Ramazan Bayramı 3. gün',   0::smallint),
    -- 2026 · Kurban Bayramı (Hicrî 1447)
    ('2026-05-26'::date, 'Kurban Bayramı arifesi',   1::smallint),
    ('2026-05-27'::date, 'Kurban Bayramı 1. gün',    0::smallint),
    ('2026-05-28'::date, 'Kurban Bayramı 2. gün',    0::smallint),
    ('2026-05-29'::date, 'Kurban Bayramı 3. gün',    0::smallint),
    ('2026-05-30'::date, 'Kurban Bayramı 4. gün',    0::smallint),
    -- 2027 · Ramazan Bayramı (Hicrî 1448)
    ('2027-03-09'::date, 'Ramazan Bayramı arifesi',  1::smallint),
    ('2027-03-10'::date, 'Ramazan Bayramı 1. gün',   0::smallint),
    ('2027-03-11'::date, 'Ramazan Bayramı 2. gün',   0::smallint),
    ('2027-03-12'::date, 'Ramazan Bayramı 3. gün',   0::smallint),
    -- 2027 · Kurban Bayramı (Hicrî 1448)
    ('2027-05-16'::date, 'Kurban Bayramı arifesi',   1::smallint),
    ('2027-05-17'::date, 'Kurban Bayramı 1. gün',    0::smallint),
    ('2027-05-18'::date, 'Kurban Bayramı 2. gün',    0::smallint),
    ('2027-05-19'::date, 'Kurban Bayramı 3. gün',    0::smallint),
    ('2027-05-20'::date, 'Kurban Bayramı 4. gün',    0::smallint)
  ) as x(tarih, ad, yarim)
 where not exists (select 1 from public.resmi_tatil t
                    where t.tarih = x.tarih and t.sube_id is null);

-- ============================================= GÖRÜNÜM: DOĞRULAMA BİLGİSİ
-- DROP + CREATE: yeni kolon ortaya giriyor ve `create or replace` kolon
--   SIRASI değişince reddediyor ("cannot change name of view column").
drop view if exists public.v_resmi_tatil;
create view public.v_resmi_tatil as
select t.id,
       t.tarih,
       t.ad,
       t.tur,
       t.yarim_gun,
       t.calisma_var,
       t.dogrulandi,
       t.aciklama,
       t.sube_id,
       coalesce(s.ad, '')                                   as sube_ad,
       -- YEREL Mİ: şubesi olan tatil yalnız o şubeyi bağlar. Listede
       --   görünmezse kullanıcı "neden bu tatil bende yok" sorusunu
       --   sorar ve cevabı hiçbir yerde bulamaz.
       (t.sube_id is not null)::int                         as yerel,
       t.aktif,
       extract(year from t.tarih)::int                      as yil,
       (extract(isodow from t.tarih) >= 6)::int             as hafta_sonu,
       case extract(isodow from t.tarih)
            when 1 then 'Pazartesi' when 2 then 'Salı' when 3 then 'Çarşamba'
            when 4 then 'Perşembe'  when 5 then 'Cuma' when 6 then 'Cumartesi'
            else 'Pazar' end                                as gun_adi,
       t.ekleme_tarihi,
       t.degistirme_tarihi
  from public.resmi_tatil t
  left join public.sube s on s.id = t.sube_id;

comment on view public.v_resmi_tatil is
  '749/750/751: resmi tatil listesi. dogrulandi=0 dini bayram tohumu - '
  'takvim hesabi, Diyanet ilaniyla dogrulanmali.';

-- ====================== AYNI GÜNE DENK GELEN İKİ TATİL
-- 19 Mayıs 2027 hem Gençlik Bayramı hem Kurban Bayramı'nın 3. günü.
--   Benzersiz indeks (bir gün = bir satır) ikincisini almadı; iş günü
--   hesabı için fark yok (gün zaten tatil) ama listede "Kurban 3. gün"
--   satırı görünmüyor - kullanıcı bayramı eksik sanmasın diye var olan
--   satırın açıklamasına yazılıyor.
update public.resmi_tatil
   set aciklama = 'Kurban Bayramı 3. günü ile aynı güne denk geliyor'
 where tarih = date '2027-05-19' and sube_id is null
   and coalesce(nullif(aciklama, ''), '') not like 'Kurban%';
