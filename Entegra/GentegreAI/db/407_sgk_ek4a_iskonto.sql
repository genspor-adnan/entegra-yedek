-- ============================================================================
--  407 - SGK Ek-4/A ISKONTO KADEMELERI
--
--  Ek-4/A FIYAT VERMEZ, ISKONTO ORANI verir - ve tek bir oran da vermez:
--  iskonto ilacin DEPOCUYA SATIS FIYATI kademesine gore degisir (dosyada
--  dort ayri sutun: "151,25 TL ve uzeri", "100,38 - 151,24", "52,44 -
--  100,37", "52,43 TL ve altinda"). Kademe sinirlari her liste yayininda
--  degisiyor, bu yuzden sutun basligindan okunup satirla birlikte saklanir;
--  koda gomulen sinir bir sonraki yayinda sessizce yanlis iskonto uygular.
--
--  Tek "kamu_iskonto" kolonu tutmak, fiyat gelene kadar hangi kademenin
--  gecerli oldugu bilinemedigi icin yeterli degil: kademeler ham saklanir,
--  kamu_iskonto ise EN YUKSEK kademe olarak kalir (guvenli ust sinir).
-- ============================================================================

-- Esdeger grup bir ilacta BIRDEN COK olabiliyor ("E798A/E798B/E798C/..."),
--   20 karakter yetmiyordu - yukleme 22001 ile duruyordu.
alter table public.ilac      alter column esdeger_grup type varchar(64);
alter table public.ilac_fiyat add column if not exists iskonto_kademe  jsonb;
alter table public.ilac_fiyat add column if not exists eczaci_iskonto  numeric(9,4);

comment on column public.ilac_fiyat.iskonto_kademe is
    'SGK Ek-4/A kademeli iskonto: [{"alt":151.25,"ust":null,"oran":0.28}, ...] (TL, depocuya satis fiyati).';

-- Depocu fiyati bilinince gecerli kademeyi secer. Fiyat bilinmiyorsa (TITCK
--   detayli liste kapisi acilmadiysa) en yuksek oran doner - eksik odeme
--   riski, fazla odeme riskinden yeglenir.
create or replace function public.fn_ilac_kamu_iskonto(
        p_barkod varchar, p_depocu numeric default null, p_tarih date default current_date)
returns numeric language sql stable as $$
    with son as (
        select f.iskonto_kademe, f.kamu_iskonto
          from public.ilac_fiyat f
         where f.barkod = p_barkod and f.kaynak = 2
           and f.yururluk_bas <= p_tarih
         order by f.yururluk_bas desc
         limit 1
    )
    select coalesce(
        (select (k->>'oran')::numeric
           from son, jsonb_array_elements(son.iskonto_kademe) k
          where p_depocu is not null
            and (k->>'alt' is null or p_depocu >= (k->>'alt')::numeric)
            and (k->>'ust' is null or p_depocu <= (k->>'ust')::numeric)
          limit 1),
        (select kamu_iskonto from son),
        0);
$$;
