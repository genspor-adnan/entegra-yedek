-- =============================================================================
--  1005 - NAKİT TAHSİLAT AÇIK BANKO OTURUMUNUN KASASINA
--
--  Kullanıcı (09.10.2026): "hasan olarak başvuruya ücret ve nakit tahsilat
--  ekle.. tahsilata bak bankoda belirttiğimiz kasaya mı giriyor".
--
--  TEŞHİS. Nakit işlemde açılacak kasayı `fn_kullanici_kasa` seçiyor (196):
--  önce kullanıcıya atanmış kasa, yoksa şubenin ana kasası. Banko oturumu
--  (987) bu sırada YOKTU: Hasan B-01 bankosunda oturum açmışken (bankonun
--  kasası hesap 174) başvuru tahsilatı şubenin "TL KASASI"na (120)
--  yazılıyordu. 997 damgası yüzünden işlem oturum kartında görünür, ama para
--  bankonun kasa hesabına girmez - gün sonunda kasa hesabı ile oturum
--  sayımı tutmazdı.
--
--  ÇÖZÜM. En öncelikli aday: kullanıcının AÇIK banko oturumunun (durum 2)
--  bankosuna bağlı kasa hesabı (aynı tür, aktif). Oturum yoksa ya da banko
--  kasasız (danışma) ise eski sıra aynen: kendi kasası, sonra ana kasa.
--  Karar yine tek yerde (fonksiyon) - ekranlar ikinci kez yazmıyor.
-- =============================================================================

create or replace function public.fn_kullanici_kasa(
    p_kullanici_id integer, p_sube_id integer, p_tur character varying default 'K')
returns table(hesap_id integer, ad character varying, doviz_cinsi character varying, kendi_kasasi boolean)
language sql stable as $$
    with oturum_kasasi as (
        -- Açık banko oturumu: vardiyadaki para bankonun kasasına girer.
        select h.id, h.ad, h.doviz_cinsi, true as kendi, 0 as oncelik
          from public.banko_oturum o
          join public.banko b  on b.id = o.banko_id
          join public.hesap h  on h.id = b.hesap_id
         where o.id = public.fn_banko_acik_oturum(p_kullanici_id)
           and h.tur = p_tur and h.durum = 1
    ),
    aday as (
        select h.id, h.ad, h.doviz_cinsi,
               (h.atama = p_kullanici_id) as kendi,
               -- Kendi kasası önce, sonra ana kasa.
               case when h.atama = p_kullanici_id then 1 else 2 end as oncelik
          from public.hesap h
         where h.tur = p_tur and h.durum = 1
           and (p_sube_id is null or h.sube_id = p_sube_id)
           and (h.atama = p_kullanici_id or h.atama = -1)
        union all
        select * from oturum_kasasi
    )
    select id, ad, doviz_cinsi, kendi from aday order by oncelik, id limit 1
$$;

do $$
begin
  raise notice '1005: fn_kullanici_kasa açık banko oturumunun kasasını önceliyor';
end $$;
