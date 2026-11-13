-- 1335 - Depolu belgede BOŞ depo onarımı: şubenin varsayılan deposu yazılır.
--
-- Kullanıcı 13.11.2026 (UNIVERSE alış faturası 10290, düzenlemede giriş deposu boş ve değiştirilemiyordu):
--   "depo boş diye bir şey olmamalı.. bütün alım satım belgelerinde depo bulunmalı",
--   "depo olmadan kayıt olmaz (satır eklenmez)".
--
-- Sunucu bu kuralı 11.11.2026'dan beri uyguluyor (BelgeDeposu.KaydetIcAsync: "Depo seçilmeli." - başlık ve
-- satırlar aynı kayıtta doğrulanır, satır tek başına yazılamaz). Kuraldan ÖNCE açılmış belgelerde depo boş
-- kalmış olabilir; böyle bir belge düzenlenemez (istemci kalem varken depo combosunu kilitler, sunucu boş depoyu
-- reddeder). Bu göç o belgeleri onarır.
--
-- KAPSAM (BelgeTuru.DepoZorunlu ile aynı küme):
--   depolu tür = tür 13/17/18/19 dışında, çıkış türleri (4 14 15 16 17 29 105 119 121 123 133) + 9 10 11 12 109
--   20 122 + stok fişleri (3 4). İki depolu türler (20 transfer, 105 talep) TAHMİN EDİLMEZ - yalnız listelenir.
--   Tek depolu türde yön = BelgeTuru.CikisMi(tur, tipi): tipi 2 (iade) iadesi olan türde yönü çevirir
--   (iadesiz: 9 18 19 20 105 3 4). Yönün deposu YAZILIR; öteki alan dokunulmaz.
--
-- YALNIZ KANITLI YANLIŞ SATIRLAR: iki depo alanı da boş olan depolu belge. Depo kaynağı şubenin varsayılan
--   aktif deposu (depo.varsayilan = 1 and durum = 1), yoksa şubenin TEK aktif deposu; ikisi de yoksa belge
--   onarılmaz ve raise notice ile listelenir (kullanıcı ekrandan seçer - istemci 13.11.2026'dan beri boş depoyu
--   kilitlemiyor).
--
-- YEDEK: public.yedek_1335_belge_depo (belge id + eski değerler). Stok hareketi BU GÖÇTE YAZILMAZ - belge
--   kaydedildiğinde sunucu başlıktaki depoya göre etkiyi yeniden yazar; yalnız başlık doldurulur.
\set ON_ERROR_STOP on
begin;

create table if not exists public.yedek_1335_belge_depo (
    belge_id          integer primary key,
    tur               integer,
    tipi              integer,
    sube_id           integer,
    eski_giris_depo   integer,
    eski_cikis_depo   integer,
    yeni_giris_depo   integer,
    yeni_cikis_depo   integer,
    tarih             timestamptz not null default now()
);
comment on table public.yedek_1335_belge_depo is
  '1335: depolu belgede boş depo onarımının yedeği (eski/yeni başlık deposu). Geri almak: eski değerleri belge''ye yaz.';

do $$
declare
    r record;
    v_depo integer;
    v_cikis boolean;
    v_onarilan integer := 0;
    v_atlanan integer := 0;
begin
    for r in
        select b.id, b.tur, coalesce(b.tipi, 0) as tipi, b.sube_id
          from public.belge b
         where b.giris_depo_id is null and b.cikis_depo_id is null
           and b.tur not in (13, 17, 18, 19)
           and (b.tur in (4, 14, 15, 16, 17, 29, 105, 119, 121, 123, 133)
                or b.tur in (9, 10, 11, 12, 109, 20, 122)
                or b.tur in (3, 4))
         order by b.id
    loop
        if r.tur in (20, 105) then
            raise notice '1335 ATLANDI: belge % (tür %) iki depolu, iki depo da boş - ekrandan seçilmeli', r.id, r.tur;
            v_atlanan := v_atlanan + 1;
            continue;
        end if;

        select d.id into v_depo
          from public.depo d
         where d.sube_id = r.sube_id and d.durum = 1 and d.varsayilan = 1
         order by d.id limit 1;
        if v_depo is null then
            select min(d.id) into v_depo
              from public.depo d
             where d.sube_id = r.sube_id and d.durum = 1
            having count(*) = 1;  -- şubenin TEK aktif deposu varsa o, birden çoksa null
        end if;
        if v_depo is null then
            raise notice '1335 ATLANDI: belge % (tür %, şube %) - şubede varsayılan / tek aktif depo yok', r.id, r.tur, r.sube_id;
            v_atlanan := v_atlanan + 1;
            continue;
        end if;

        -- Yön: çıkış türü mü; iade (tipi 2) iadesi olan türde yönü çevirir.
        v_cikis := r.tur in (4, 14, 15, 16, 17, 29, 105, 119, 121, 123, 133);
        if r.tipi = 2 and r.tur not in (9, 18, 19, 20, 105, 3, 4) then
            v_cikis := not v_cikis;
        end if;

        insert into public.yedek_1335_belge_depo (belge_id, tur, tipi, sube_id, eski_giris_depo, eski_cikis_depo,
                                                  yeni_giris_depo, yeni_cikis_depo)
        values (r.id, r.tur, r.tipi, r.sube_id, null, null,
                case when v_cikis then null else v_depo end,
                case when v_cikis then v_depo else null end)
        on conflict (belge_id) do nothing;

        if v_cikis then
            update public.belge set cikis_depo_id = v_depo where id = r.id;
        else
            update public.belge set giris_depo_id = v_depo where id = r.id;
        end if;
        v_onarilan := v_onarilan + 1;
    end loop;

    raise notice '1335: % belgeye depo yazıldı, % belge atlandı (yedek: yedek_1335_belge_depo)', v_onarilan, v_atlanan;
end $$;

commit;
