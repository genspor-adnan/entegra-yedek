-- 291: KATILIM PAYI (SGK) — SUT bedeliyle birlikte tanımlanır.
--
-- Kullanıcı: "SGK için katkı ücretini nereye kaydetmem gerekir ki bir işlem
-- seçildiğinde hem SUT fiyatı hem de katkısı gelsin" — SABİT TUTAR.
--
-- NEREYE: fiyat listesi satırına. Katılım payı hizmetin doğal özelliği değil,
-- KURUMLA YAPILAN ANLAŞMANIN parçasıdır: aynı tetkikte SGK 15 TL katılım alır,
-- ÖSS almaz, kendi ödeyende hiç yoktur. Hizmet kartına yazılsa üç kurum için
-- tek değer tutmak gerekirdi. Fiyat listesi zaten kuruma bağlı
-- (sözleşme → kampanya → fiyat_listesi_id), yani "SUT 2026" listesi SGK'nındır.
--
-- AKIŞ: satır tutarı = SUT bedeli. Hastadan katılım payı alınır, kuruma kalanı
-- faturalanır:  hasta_tutar = katkı,  kurum_tutar = tutar − katkı.
-- İlave ücret (SUT üstü fark) katılım payı DEĞİLDİR - ayrı "ek katkı" satırı
-- olarak girilir ve tamamı hastaya yazılır (289).

alter table public.fiyat_listesi_satir
  add column if not exists katki_tutar numeric(19,4) not null default 0;
-- Liste geneli varsayılan: her satıra tek tek girmek yerine "bu listede
--   muayene katılım payı 15 TL" denebilsin. Satırdaki değer listeyi EZER.
alter table public.fiyat_listesi
  add column if not exists katki_tutar numeric(19,4) not null default 0;

comment on column public.fiyat_listesi_satir.katki_tutar is
  'Hastadan alınacak katılım payı - SABİT tutar (291). 0 ise listenin varsayılanı geçerli.';
comment on column public.fiyat_listesi.katki_tutar is
  'Listenin varsayılan katılım payı (291). Satırdaki değer bunu ezer.';

-- ------------------------------------------------------------ paylaşım modu --
-- SGK katılım payı SABİT TUTAR; sigorta şirketleri ORAN üzerinden çalışır.
-- Hangi kuralın işleyeceği sözleşmede belirlenir.
alter table public.taraf_kurum
  add column if not exists paylasim_modu smallint not null default 1;

comment on column public.taraf_kurum.paylasim_modu is
  'Pay nasıl hesaplanır (291): 1 karşılama ORANI (ÖSS) · 2 KATILIM PAYI sabit tutar (SGK).';

insert into public.kod_liste (kod, ad)
select 'kurum.paylasim_modu', 'Pay Hesaplama Modu'
 where not exists (select 1 from public.kod_liste where kod = 'kurum.paylasim_modu');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  cross join (values (1, 'Karşılama Oranı (%)'), (2, 'Katılım Payı (sabit tutar)'))
        as v(deger, ad)
 where l.kod = 'kurum.paylasim_modu'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ------------------------------------------------------- katkı çözümlemesi --
-- Satırdaki katkı > listenin varsayılanı > taban listenin katkısı (zincir).
-- Fiyat fonksiyonuna (fn_fiyat_listesi_fiyat) DOKUNULMADI: o 200 satırlık
-- kural zinciri taşıyor, dönüş tipini değiştirmek tüm çağrı yerlerini kırardı.
create or replace function public.fn_fiyat_listesi_katki(
    p_liste_id  integer,
    p_stok_id   integer default null,
    p_hizmet_id integer default null,
    p_derinlik  integer default 0)
returns numeric
language plpgsql stable as $$
declare
  l       public.fiyat_listesi%rowtype;
  v_katki numeric;
begin
  if p_derinlik > 20 or p_liste_id is null then return 0; end if;

  select * into l from public.fiyat_listesi where id = p_liste_id;
  if not found then return 0; end if;

  select s.katki_tutar into v_katki
    from public.fiyat_listesi_satir s
   where s.liste_id = p_liste_id and s.durum = 1
     and (p_stok_id   is not null and s.stok_id   = p_stok_id
       or p_hizmet_id is not null and s.hizmet_id = p_hizmet_id)
   limit 1;

  if coalesce(v_katki, 0) > 0 then return v_katki; end if;
  if coalesce(l.katki_tutar, 0) > 0 then return l.katki_tutar; end if;

  -- Taban listeden devral: "SUT 2026" listesi "SUT taban"dan türetildiyse
  --   katılım payı da oradan gelsin.
  if l.taban_liste_id is not null then
    return public.fn_fiyat_listesi_katki(l.taban_liste_id, p_stok_id, p_hizmet_id,
                                         p_derinlik + 1);
  end if;
  return 0;
end $$;

comment on function public.fn_fiyat_listesi_katki(integer, integer, integer, integer) is
  'Kalemin katılım payı (291): satır > liste varsayılanı > taban liste.';

-- ------------------------------------------------------------- paylaştırma --
-- Katkı modu eklendi. Eski 3 argümanlı imza DÜŞÜRÜLÜR: yeni parametre
-- default'lu olduğu için ikisi birden dururken çağrı belirsiz kalırdı.
drop function if exists public.fn_belge_satir_paylastir(numeric, numeric, integer);

create or replace function public.fn_belge_satir_paylastir(
    p_tutar     numeric,
    p_karsilama numeric,
    p_kurum_id  integer default null,
    p_katki     numeric default null)
returns table (kurum_tutar numeric, hasta_tutar numeric, karsilama numeric)
language plpgsql stable as $$
declare
  v_mod   smallint;
  v_oran  numeric;
  v_katki numeric;
  v_tutar numeric := coalesce(p_tutar, 0);
  v_kurum numeric;
begin
  select tk.paylasim_modu, tk.varsayilan_karsilama
    into v_mod, v_oran
    from public.taraf_kurum tk where tk.id = p_kurum_id;

  -- KATILIM PAYI MODU (SGK): hastadan sabit tutar, kalanı kuruma.
  if coalesce(v_mod, 1) = 2 then
    v_katki := least(greatest(coalesce(p_katki, 0), 0), v_tutar);
    return query select v_tutar - v_katki, v_katki, 0::numeric;
    return;
  end if;

  -- ORAN MODU (ÖSS): çağrıdan gelen oran, yoksa kurumun varsayılanı.
  v_oran  := coalesce(nullif(p_karsilama, 0), v_oran, 0);
  v_kurum := round(v_tutar * v_oran / 100.0, 2);
  return query select v_kurum, v_tutar - v_kurum, v_oran;
end $$;

comment on function public.fn_belge_satir_paylastir(numeric, numeric, integer, numeric) is
  'Satır tutarını kurum/hasta payına böler (289/291): kuruma göre ORAN ya da KATILIM PAYI.';
