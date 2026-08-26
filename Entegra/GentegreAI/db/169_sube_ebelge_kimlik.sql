-- ============================================================================
--  Gentegre AI — SUBE e-BELGE KIMLIGI: kendi bilgisi mi, merkezin mi?
--  169_sube_ebelge_kimlik.sql
--
--  Kullanici: "subeler e-faturayi kendi bilgileriyle de gonderebilirler,
--  merkezin bilgileriyle de gonderebilirler; buna gore yapi kurmak lazim."
--
--  GERCEK DURUM UC TURLU:
--    1 KENDI      — sube AYRI MUKELLEF (kendi VKN'si, kendi posta kutusu).
--                   Grup sirketlerinde her sirket ayri "sube" kaydidir.
--    2 MERKEZ     — belge tamamen merkezin kimligi ve adresiyle gider; sube
--                   yalniz ic organizasyon (magaza/depo).
--    3 MERKEZ_KIMLIK — ayni tuzel kisilik: unvan/VKN/vergi dairesi ve GIB posta
--                   kutusu MERKEZIN, adres ve iletisim SUBENIN. Fatura merkez
--                   adina kesilir ama "hangi subeden" bilgisi belgede gorunur.
--                   Cok subeli tek sirkette en yaygin hal.
--
--  VKN kimin oldugu belirleyicidir: GIB posta kutusu (alias) VKN'ye baglidir,
--  dolayisiyla kimlik merkezden geliyorsa alias da merkezden gelmelidir - aksi
--  halde belge "gonderici bulunamadi" ile doner. Gorunum bunu birlikte cozer.
--
--  MERKEZ KIM: `ust_sube_id` doluysa o (zincir tek adim; sube-ninsubesi
--  senaryosu yok). Bos ise varsayilan sube, o da yoksa en kucuk id.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.sube
    add column if not exists ebelge_kimlik smallint not null default 1;

comment on column public.sube.ebelge_kimlik is
  'e-Belgede gonderici kimligi: 1 kendi · 2 merkezin (kimlik+adres) · 3 merkez kimligi + sube adresi (169).';

-- Kod listesi (kart combo'su).
insert into public.kod_liste (kod, ad)
select 'sube.ebelge_kimlik', 'e-Belge Gönderici Kimliği'
 where not exists (select 1 from public.kod_liste where kod = 'sube.ebelge_kimlik');

insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select l.id, v.deger, -1, v.ad, v.sira, 1
  from public.kod_liste l,
       (values (1, 'Kendi bilgileriyle (ayrı mükellef)',        1::smallint),
               (2, 'Merkezin bilgileriyle',                     2::smallint),
               (3, 'Merkez kimliği + şube adresi',              3::smallint))
         as v(deger, ad, sira)
 where l.kod = 'sube.ebelge_kimlik'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger and d.dil = -1);

-- --------------------------------------------------------------- merkez ----
create or replace function public.fn_sube_merkez_id(p_sube_id integer)
returns integer language sql stable as $$
    select coalesce(
        (select nullif(s.ust_sube_id, 0) from public.sube s where s.id = p_sube_id),
        (select s.id from public.sube s where s.varsayilan = 1 and s.aktif = 1
          order by s.id limit 1),
        (select min(s.id) from public.sube s))
$$;

comment on function public.fn_sube_merkez_id(integer) is
  'Subenin bagli oldugu merkez: ust_sube_id, yoksa varsayilan sube (169).';

-- --------------------------------------------- gonderici taraf (yeniden) ----
-- 165'teki gorunum yalnizca subenin KENDI kolonlarini okuyordu. Artik kimlik
--   secimine gore merkezden devraliyor. Kolon adlari ve `ebelge_hazir` sozlesmesi
--   AYNI kaldi - JSON ureteci (166) degismeden calisir.
-- Kolon kumesi degistigi icin gorunum DUSURULUP kurulur: PostgreSQL
--   `create or replace view` mevcut kolonlarin adini/sirasini degistiremez.
drop view if exists public.v_ebelge_gonderici;
create view public.v_ebelge_gonderici as
    with k as (
        select s.id as sube_id,
               s.ebelge_kimlik,
               -- KIMLIK kaynagi: 2/3 -> merkez, 1 -> kendisi.
               case when s.ebelge_kimlik in (2, 3)
                    then coalesce(m.id, s.id) else s.id end as kimlik_id,
               -- ADRES kaynagi: yalniz 2'de merkez; 3'te sube adresi kalir.
               case when s.ebelge_kimlik = 2
                    then coalesce(m.id, s.id) else s.id end as adres_id
          from public.sube s
          left join public.sube m on m.id = public.fn_sube_merkez_id(s.id)
    )
    select k.sube_id,
           k.ebelge_kimlik,
           ki.id as kimlik_sube_id,
           ad.id as adres_sube_id,
           coalesce(nullif(btrim(ki.unvan), ''), ki.ad)          as unvan,
           regexp_replace(coalesce(ki.vkno, ''), '\D', '', 'g')  as vkno,
           btrim(coalesce(ki.vd, ''))                            as vergi_dairesi,
           btrim(coalesce(ad.adres, ''))                         as adres,
           btrim(coalesce(ad.ilce, ''))                          as ilce,
           btrim(coalesce(ad.il, ''))                            as il,
           coalesce(nullif(btrim(ad.ulke), ''), 'Türkiye')       as ulke,
           btrim(coalesce(ad.posta_kodu, ''))                    as posta_kodu,
           btrim(coalesce(ad.telefon, ''))                       as telefon,
           btrim(coalesce(ad.eposta, ''))                        as eposta,
           btrim(coalesce(ad.web, ''))                           as web,
           -- Mersis / ticaret sicil KIMLIKLE gider: tuzel kisiligin numaralari.
           btrim(coalesce(ki.mersis_no, ''))                     as mersis_no,
           btrim(coalesce(ki.ticaret_sicil_no, ''))              as ticaret_sicil_no,
           -- GIB posta kutusu VKN'ye bagli: kimlik kimdeyse alias da onun.
           btrim(coalesce(ki.efatura_alias, ''))                 as gonderici_alias,
           -- Gonderim dogrulamasi: kimlik alanlari kimlik subesinden, adres
           --   alanlari adres subesinden - hangisi eksikse gonderim durur.
           (coalesce(nullif(btrim(ki.unvan), ''), ki.ad) <> ''
            and regexp_replace(coalesce(ki.vkno, ''), '\D', '', 'g') <> ''
            and btrim(coalesce(ki.vd, '')) <> ''
            and btrim(coalesce(ad.adres, '')) <> ''
            and btrim(coalesce(ad.il, '')) <> '')                as ebelge_hazir
      from k
      join public.sube ki on ki.id = k.kimlik_id
      join public.sube ad on ad.id = k.adres_id;

comment on view public.v_ebelge_gonderici is
  'e-Belge gonderici tarafi (supplierParty): sube kendi bilgisiyle mi merkezin kimligiyle mi gonderiyor - 169 kuralina gore cozulmus.';

-- Sube listesindeki "e-Belge Bilgileri" rozeti de ayni gorunumden beslensin ki
--   merkez kimligi kullanan sube "Eksik" gorunmesin (kendi VKN'si yok ama
--   merkezinki var). Liste katalogu bu fonksiyonu cagirir.
create or replace function public.fn_sube_ebelge_hazir(p_sube_id integer)
returns boolean language sql stable as $$
    select coalesce((select g.ebelge_hazir from public.v_ebelge_gonderici g
                      where g.sube_id = p_sube_id), false)
$$;

comment on function public.fn_sube_ebelge_hazir(integer) is
  'Sube e-Belge gonderebilir mi (kendi ya da merkez kimligiyle) - 169.';

do $$
declare r record;
begin
    for r in select g.sube_id, s.ad, g.ebelge_kimlik, g.unvan, g.vkno, g.ebelge_hazir
               from public.v_ebelge_gonderici g join public.sube s on s.id = g.sube_id
              order by g.sube_id loop
        raise notice '169: sube % (%) kimlik=% -> % / % | hazir=%',
            r.sube_id, r.ad, r.ebelge_kimlik, r.unvan, r.vkno, r.ebelge_hazir;
    end loop;
    raise notice '169 tamam: sube.ebelge_kimlik + merkez devralma.';
end $$;
