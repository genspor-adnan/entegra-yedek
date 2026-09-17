-- =====================================================================
--  748_izin_calisma_plani.sql
--  ONAYLI İZİN ÇALIŞMA PLANINI ETKİLESİN.
--
--  743'te izin onaydan geçmeye başladı ama plana dokunmuyordu: onaylı
--  izindeki hekimin takvimi açık kalıyor, randevu yazılabiliyordu. İzni
--  onaylayan kişi "tamam" diyor, kayıt kabul aynı gün o hekime hasta
--  yazıyor - ikisi de sistemi kullanıyor ve ikisi de haklı.
--
--  ============= İZİN KOPYALANMAZ, OKUNUR ==============================
--  `hekim_calisma_istisna`ya satır ÜRETMİYORUZ. Üretseydik izin kaydı iki
--  yerde dururdu: izin tarihi değişince (ya da iptal edilince) istisna eski
--  hâlinde kalır ve plan yanlış gösterirdi. Blok fonksiyonu izni doğrudan
--  `personel_izin`den okur - tek kaynak.
--
--  ============= RANDEVU ENGELİ AYARLA GEVŞETİLEBİLİR ==================
--  Varsayılan: izinli hekime randevu YAZILAMAZ. Ama kurum bilerek yazmak
--  isteyebilir (izin dönüşü ilk gün planlanan kontrol, yarım gün izin).
--  `randevu.izinli_hekim` ayarı: 0 engelle (varsayılan) · 1 yalnız uyar.
--  Sert kuralı seçenek olmadan koymak, kurumu sistemin dışında iş yapmaya
--  iter - randevuyu kâğıda yazarlar ve takvim bir daha hiç doğru olmaz.
-- =====================================================================

-- ======================================================== AYAR
insert into public.referans (anahtar, deger, aciklama)
select 'randevu.izinli_hekim', '0',
       'Izinli hekime randevu: 0 engelle (varsayilan) - 1 yalniz uyar.'
 where not exists (select 1 from public.referans
                    where anahtar = 'randevu.izinli_hekim');

-- ============================================ HEKİM O GÜN İZİNLİ Mİ
-- YALNIZ ONAYLI İZİN (durum 2): taslak ya da onaydaki talep henüz bir
--   karar değildir - planı ona göre kapatmak, onaylanmamış bir izni
--   uygulamak olurdu.
create or replace function public.fn_hekim_izinli(
    p_hekim integer, p_gun date)
returns table (izin_id integer, tur smallint, baslangic date, bitis date)
language sql stable as $$
    select i.id, i.tur, i.baslangic_tarihi, i.bitis_tarihi
      from public.personel_izin i
     where i.taraf_id = p_hekim
       and i.durum = 2
       and p_gun between i.baslangic_tarihi and i.bitis_tarihi
     order by i.id
     limit 1
$$;

comment on function public.fn_hekim_izinli(integer, date) is
  '748: hekim o gun ONAYLI izinde mi. Taslak/onaydaki talep plani kapatmaz.';

-- ================================== ÇALIŞMA BLOKLARI İZNİ TANISIN
-- 718'in fonksiyonu; tek fark `ist` kümesine ONAYLI İZİNLERİN eklenmesi
--   ve izinden gelen kapalı günün `kaynak = 4` ile işaretlenmesi (ekran
--   "İK izni" ile "plan istisnası"nı ayırt edebilsin - ikisi ayrı yerden
--   düzeltilir).
create or replace function public.fn_hekim_calisma_bloklari(
    p_sube integer, p_bas date, p_bit date, p_hekim integer default null, p_departman integer default null)
returns table (
    hekim_id integer, hekim varchar, sube_id integer, departman_id integer, departman varchar,
    gun date, saat_bas time, saat_bit time, slot_dk smallint, kanallar varchar, kaynak smallint,
    istisna_tur smallint, sablon_id integer, istisna_id integer, aciklama varchar)
language sql stable as $$
    with g as (select d::date as gun from generate_series(p_bas, p_bit, interval '1 day') d),
    sab as (
        select s.*, g.gun
          from public.hekim_calisma_sablon s
          join g on g.gun >= s.gecerli_bas and (s.gecerli_bit is null or g.gun <= s.gecerli_bit)
         where s.aktif = 1
           and (p_sube = 0 or s.sube_id is null or s.sube_id = p_sube)
           and (p_hekim is null or s.hekim_id = p_hekim)
           and (p_departman is null or s.departman_id = p_departman)
           and (',' || s.gunler || ',') like ('%,' || extract(isodow from g.gun)::text || ',%')
           and (s.tekrar = 1 or (((g.gun - s.gecerli_bas) / 7) % 2) = 0)),
    bl as (
        select s.hekim_id, coalesce(s.sube_id, p_sube) as sube_id, s.departman_id, s.gun,
               s.bas1::time as saat_bas, s.bit1::time as saat_bit, s.slot_dk, s.kanallar, s.id as sablon_id from sab s
        union all
        select s.hekim_id, coalesce(s.sube_id, p_sube), s.departman_id, s.gun,
               s.bas2::time, s.bit2::time, s.slot_dk, s.kanallar, s.id from sab s where nullif(s.bas2, '') is not null),
    ist as (
        select i.id, i.sube_id, i.hekim_id, i.departman_id, i.tur,
               i.saat_bas, i.saat_bit, i.slot_dk, i.kanallar, i.aciklama,
               0::smallint as izin_mi, g.gun
          from public.hekim_calisma_istisna i
          join g on g.gun between i.bas_tarih and i.bit_tarih
         where i.durum = 1
           and (p_sube = 0 or i.sube_id is null or i.sube_id = p_sube)
           and (p_hekim is null or i.hekim_id = p_hekim)
           and (p_departman is null or i.departman_id is null or i.departman_id = p_departman)
        union all
        -- ONAYLI İZİN (748): kaydı İK'da durur, plana buradan yansır.
        --   `tur = 1` (izin) olarak ele alınıyor - aşağıdaki "ezilen" ve
        --   "kapalı gün" dalları zaten 1'i tanıyor, ikinci bir kural
        --   yazmak aynı davranışı iki yerde tarif etmek olurdu.
        select z.id, z.sube_id, z.taraf_id, null::integer, 1::smallint,
               null::varchar, null::varchar, null::smallint, null::varchar,
               case z.tur when 1 then 'Yıllık izin' when 2 then 'Mazeret izni'
                          when 3 then 'Rapor' when 4 then 'Ücretsiz izin'
                          else 'İzin' end::varchar,
               1::smallint, g.gun
          from public.personel_izin z
          join g on g.gun between z.baslangic_tarihi and z.bitis_tarihi
         where z.durum = 2
           and (p_sube = 0 or z.sube_id is null or z.sube_id = p_sube)
           and (p_hekim is null or z.taraf_id = p_hekim)),
    ezilen as (   -- izin / kongre / kapalı / saat değişikliği o günün şablon bloklarını kaldırır
        select b.* from bl b
         where exists (select 1 from ist i
                        where i.hekim_id = b.hekim_id and i.gun = b.gun and i.tur in (1, 2, 3, 5)
                          and (i.departman_id is null or i.departman_id = b.departman_id)
                          and (i.sube_id is null or i.sube_id = b.sube_id)))
    select b.hekim_id, t.unvan as hekim, b.sube_id, b.departman_id, d.ad as departman, b.gun, b.saat_bas, b.saat_bit, b.slot_dk, b.kanallar,
           1::smallint, null::smallint, b.sablon_id, null::integer, ''::varchar
      from bl b join public.taraf t on t.id = b.hekim_id join public.departman d on d.id = b.departman_id
     where not exists (select 1 from ezilen e where e.sablon_id = b.sablon_id and e.gun = b.gun and e.saat_bas = b.saat_bas)
    union all   -- saat değişikliği (3) ve ek mesai (4): yeni blok
    select i.hekim_id, t.unvan, coalesce(i.sube_id, p_sube),
           coalesce(i.departman_id, (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1),
                    (select s.departman_id from public.hekim_calisma_sablon s where s.hekim_id = i.hekim_id and s.aktif = 1 order by s.id limit 1)),
           coalesce(d.ad, ''), i.gun, i.saat_bas::time, i.saat_bit::time,
           coalesce(i.slot_dk, (select b.slot_dk from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1), 15),
           coalesce(i.kanallar, 'B'), 2::smallint, i.tur, null::integer, i.id, i.aciklama
      from ist i join public.taraf t on t.id = i.hekim_id
      left join public.departman d on d.id = coalesce(i.departman_id,
           (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1))
     where i.tur in (3, 4) and i.izin_mi = 0
    union all   -- kapalı günler (izin / kongre / kapalı): görünsün, slot üretmesin
    --   KAYNAK 4 = İK İZNİ: ekran "plan istisnası" ile "İK izni"ni ayırsın -
    --   birincisi plan ekranından, ikincisi izin ekranından düzeltilir.
    select i.hekim_id, t.unvan, coalesce(i.sube_id, p_sube), coalesce(i.departman_id, 0), coalesce(d.ad, ''), i.gun,
           null::time, null::time, 0::smallint, ''::varchar,
           case when i.izin_mi = 1 then 4 else 3 end::smallint,
           i.tur, null::integer, i.id, i.aciklama
      from ist i join public.taraf t on t.id = i.hekim_id left join public.departman d on d.id = i.departman_id
     where i.tur in (1, 2, 5)
     order by gun, hekim, saat_bas
$$;

comment on function public.fn_hekim_calisma_bloklari(integer, date, date, integer, integer) is
  '718/748: hekim calisma bloklari. ONAYLI IZIN de kapali gun uretir '
  '(kaynak 4) - izin kopyalanmaz, personel_izinden okunur.';

-- ================================ RANDEVU: İZİNLİ HEKİME YAZILMAZ
-- Kural TETİKLEYİCİDE, çünkü randevu birden çok yoldan yazılıyor (kart,
--   diş akışı, radyoloji panosu, epikriz). Uçlardan birine koysaydık
--   öteki yollar kuralsız kalırdı.
create or replace function public.tg_randevu_izin_kontrol()
returns trigger
language plpgsql as $$
declare
  v_izin   record;
  v_ayar   text;
  v_hekim  text;
begin
  -- İPTAL/GELMEDİ randevusu kontrol edilmez: geçmişi düzeltmek serbest.
  if coalesce(new.durum, 1) in (3, 4) then return new; end if;
  if new.hekim_id is null then return new; end if;

  select * into v_izin
    from public.fn_hekim_izinli(new.hekim_id, new.baslangic::date);
  if not found then return new; end if;

  select coalesce(nullif(deger, ''), '0') into v_ayar
    from public.referans where anahtar = 'randevu.izinli_hekim';

  -- 1 = YALNIZ UYAR: kurum bilerek yazmak isteyebilir (izin dönüşü ilk
  --   gün kontrolü, yarım gün izin). Uyarı istemci günlüğüne düşer.
  if coalesce(v_ayar, '0') = '1' then
    raise warning 'Hekim % tarihinde izinli (izin #%).',
      new.baslangic::date, v_izin.izin_id;
    return new;
  end if;

  select coalesce(nullif(unvan, ''), 'Hekim') into v_hekim
    from public.taraf where id = new.hekim_id;

  raise exception '% % tarihinde izinli (% - %). İzinli hekime randevu '
                  'yazılamaz; izni iptal edin ya da başka hekim seçin.',
    v_hekim, to_char(new.baslangic::date, 'DD.MM.YYYY'),
    to_char(v_izin.baslangic, 'DD.MM.YYYY'), to_char(v_izin.bitis, 'DD.MM.YYYY')
    using errcode = 'GK422';
end $$;

drop trigger if exists tr_randevu_izin on public.randevu;
create trigger tr_randevu_izin
  before insert or update of hekim_id, baslangic, durum on public.randevu
  for each row execute function public.tg_randevu_izin_kontrol();

comment on function public.tg_randevu_izin_kontrol() is
  '748: izinli hekime randevu engeli. randevu.izinli_hekim ayari 1 ise '
  'yalniz uyarir - sert kural secenegi olmadan kurumu sistem disina iter.';
