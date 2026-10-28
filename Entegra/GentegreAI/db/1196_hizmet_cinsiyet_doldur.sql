-- =============================================================================
--  1196  HİZMET CİNSİYET KISITI - ADDAN DOLDURMA
--
--  Kullanıcı (27.10.2026): "başvuruda erkek hastaya Obstetrik Renkli Doppler US girebildim", "erkek hastaya
--  yapılamaz". Kural 482'den beri var (hizmet.cinsiyet + tg_belge_satir_uygunluk / tg_radyoloji_istem_uygunluk);
--  ama SUT'tan gelen hizmetlerin cinsiyeti hiç doldurulmamıştı (0 = farketmez) - kural hiç tetiklenmiyordu.
--
--  YALNIZ cinsiyeti 0 (girilmemiş) olan ve ADI açıkça tek cinsiyete özgü olan hizmetler işaretlenir:
--    2 yalnız kadın : obstetrik, gebelik, sezaryen, jinekoloji, vajen / vajina, serviks, kolposkopi,
--                     histeroskopi / histerektomi, uterus, endometrium, ooforektomi, amniyo / kordosentez,
--                     NST, fetal (anneye yapılan), plasenta, follikülometri
--    1 yalnız erkek : prostat, testis, skrotum, orşiyektomi, sünnet, varikosel, hidrosel, penil / penis,
--                     vazektomi, sperm / semen
--  BİLEREK DIŞARIDA: invajinasyon (bağırsak), penisilin / penisilyum, antisperm antikoru, oosit hazırlama,
--  deri-mukoza smear, fetus otopsisi / diseksiyonu, yarık dudak doğum sonrası (hasta bebek).
--  Kurumun elle girdiği cinsiyete (≠ 0) DOKUNULMAZ. İstisna (ör. erkekte meme taraması) 482'nin gerekçeli
--  geçişiyle yapılır: satırda uygunluk_notu.
--  Değişen satırların eski hali hizmet_cinsiyet_yedek_1196'ya yazılır. İdempotent: ikinci koşu bir şey bulmaz.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create table if not exists public.hizmet_cinsiyet_yedek_1196 (
  hizmet_id integer primary key,
  eski_cinsiyet smallint not null,
  yeni_cinsiyet smallint not null,
  tarih timestamptz not null default now()
);

with k as (
  select id, lower(ad) as a from public.hizmet where cinsiyet = 0
), s as (
  select id,
    case
      when a ~ '(otopsi|diseksiyon|yarık dudak|antisperm|oosit|penisil|smearleri|invajinasyon)' then null
      when a ~ '(obstetri|gebelik|sezaryen|jinekoloj|\mvaj(in|en)|(trans|para|rekto|veziko|üretro)vajin|\mserviks|servikal (veya vajinal|/endometrial)|endoserviks|kolposkop|histerosalpingo|histeroskop|histerektomi|\muterus|uterina|intrauterin|endometri|ooforek|ooferek|amniyosentez|kordosentez|nonstres|non-stres|\mfetal|plasenta|follikülometri)' then 2
      when a ~ '(prostat|\mtestis|testik|skrot|orşi|sünnet|varikosel|hidrosel|\mpenil|\mpenis\M|penis rek|penoskrotal|vazektomi|\msperm|spermiogram|spermogram|\msemen)' then 1
    end::smallint as yeni
  from k
), yedek as (
  insert into public.hizmet_cinsiyet_yedek_1196 (hizmet_id, eski_cinsiyet, yeni_cinsiyet)
  select id, 0, yeni from s where yeni is not null
  on conflict (hizmet_id) do nothing
  returning hizmet_id, yeni_cinsiyet
)
update public.hizmet h set cinsiyet = y.yeni_cinsiyet
  from yedek y
 where h.id = y.hizmet_id and h.cinsiyet = 0;

do $$
declare v_k integer; v_e integer;
begin
  select count(*) filter (where yeni_cinsiyet = 2), count(*) filter (where yeni_cinsiyet = 1)
    into v_k, v_e from public.hizmet_cinsiyet_yedek_1196;
  raise notice '1196: % hizmet yalnız kadın, % hizmet yalnız erkek olarak işaretli (yedek hizmet_cinsiyet_yedek_1196).', v_k, v_e;
end $$;

commit;
