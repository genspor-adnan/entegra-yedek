-- ============================================================================
--  410 - HEKIM CALISMA LISTESI ve SIRA CAGIRMA (Faz 1 · Muayene v1)
--
--  Kaynak: Ekranlar/Muayene/muayene_listesi.html + muayene_sureci.html adim 3.
--
--  Liste YENI BIR TABLO DEGILDIR: kayit kabulun actigi basvurulardan (belge
--  tur 19 + belge_basvuru) turer. Ayri bir "calisma listesi" tablosu tutmak,
--  ayni hastanin iki yerde iki farkli durumda gorunmesi demekti.
--
--  Eksik olan tek sey CAGIRMA ANIYDI. Uc zaman birbirinden farklidir ve
--  ucu de ayri sorularin cevabi:
--     * belge.belge_tarihi   - hasta kayda ne zaman geldi (kabul)
--     * cagirma_zamani       - hekim ne zaman cagirdi (bekleme suresi burada biter)
--     * muayene.baslangic    - hasta iceri ne zaman girdi (USS Muayene Baslangic)
--  Tek alanla idare etmek "bekleme suresi" ve "muayene suresi" olculerinin
--  ikisini birden kaybettirirdi.
-- ============================================================================

alter table public.belge_basvuru
    add column if not exists cagirma_zamani timestamp,
    add column if not exists cagiran_id     integer,
    -- 0 normal · 1 oncelikli (yasli/gebe/engelli) · 2 acil. Sira SIRALAMASINI
    --   degistirir; kayit sirasini bozmadan one almanin tek dogru yolu.
    add column if not exists oncelik        smallint not null default 0;

comment on column public.belge_basvuru.cagirma_zamani is
    'Hekimin cagirdigi an (410). Bekleme suresi = cagirma_zamani - belge_tarihi.';

create index if not exists ix_belge_basvuru_bekleyen
    on public.belge_basvuru(personel_id) where cagirma_zamani is null;

-- ---------------------------------------------------------------------------
--  SIRADAKI HASTA
--
--  Sira kurali: once ONCELIK (acil > oncelikli > normal), sonra KAYIT SIRASI.
--  Cagrilmis ama iceri girmemis hasta listede kalir (yeniden cagrilabilir),
--  fakat "siradaki" sayilmaz - yoksa ayni hasta sonsuza kadar cagrilirdi.
-- ---------------------------------------------------------------------------
create or replace function public.fn_siradaki_hasta(p_hekim_id integer,
                                                    p_sube_id integer default null)
returns integer language sql stable as $$
    select b.id
      from public.belge b
      join public.belge_basvuru bb on bb.id = b.id
      left join public.muayene m on m.belge_id = b.id and m.ust_muayene_id is null
     where b.tur = 19
       and coalesce(b.durum, 0) <> 2          -- iptal edilmis basvuru sirada degil
       and bb.personel_id = p_hekim_id
       and (p_sube_id is null or b.sube_id = p_sube_id)
       and b.belge_tarihi >= current_date
       and bb.cagirma_zamani is null
       -- Muayenesi baslamis ya da bitmis hasta sirada degildir.
       and (m.id is null or (m.baslangic is null and m.durum = 1))
     order by bb.oncelik desc, b.belge_tarihi asc, b.id asc
     limit 1;
$$;

comment on function public.fn_siradaki_hasta(integer, integer) is
    'Hekimin siradaki bekleyen basvurusu (410): once oncelik, sonra kayit sirasi.';
