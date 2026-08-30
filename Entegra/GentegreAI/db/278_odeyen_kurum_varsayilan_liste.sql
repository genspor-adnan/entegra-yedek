-- 278: ÖDEYEN KURUMUN FİYAT LİSTESİ (274 boşluğu).
--
-- Başvuruda baz liste HASTADAN çözülüyordu; ödeyen kurumun kendi listesi
-- yok sayılıyordu. Kurumun kampanyası varsa liste zaten kampanyadan gelir
-- (kampanya.fiyat_listesi_id) - ama KAMPANYASIZ bir kurumda ("liste bizde
-- anlaşmalı, indirim yok") kurumun listesi devreye girmiyordu.
--
-- Sıra artık: ödeyen kurumun listesi > carinin (hastanın) listesi > yönün
-- varsayılanı. Kampanya listesi bunların da ÜSTÜNDEDİR ve uçta uygulanır
-- (FiyatListesiUclari): sözleşmenin dayandığı liste her zaman kazanır.
--
-- İmzaya EK parametre eklenir, mevcut iki argümanlı çağrılar aynen çalışır.

-- ESKI IMZA DUSURULUR: yeni parametre DEFAULT'lu oldugu icin iki argumanli
-- cagri (uc: /api/belge/varsayilan-liste) iki adaya birden uyup
-- "function ... is not unique" hatasi veriyordu.
drop function if exists public.fn_belge_varsayilan_liste(integer, integer, date);

create or replace function public.fn_belge_varsayilan_liste(
    p_tur             integer,
    p_taraf_id        integer,
    p_tarih           date default current_date,
    p_odeyen_kurum_id integer default null)
returns integer
language sql stable parallel safe as $$
    select coalesce(
        -- Ödeyen kurum bir caridir: listesi de cari kuralından okunur.
        case when coalesce(p_odeyen_kurum_id, 0) > 0
             then public.fn_cari_fiyat_listesi(p_odeyen_kurum_id,
                                               public.fn_belge_yon(p_tur), p_tarih)
        end,
        public.fn_cari_fiyat_listesi(p_taraf_id, public.fn_belge_yon(p_tur), p_tarih));
$$;

comment on function public.fn_belge_varsayilan_liste(integer, integer, date, integer) is
  'Belge açılırken gelecek fiyat listesi (205/278): ödeyen kurumun listesi > cari listesi > yönün varsayılanı.';
