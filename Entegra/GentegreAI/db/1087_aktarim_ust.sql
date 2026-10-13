-- =============================================================================
--  1087  DELPHI AKTARIMI - ADIM 5: SİLİNEN ALT SATIRIN ÜSTÜ   (dokuman/18 §11)
--
--  Paket bir TOPLAM taşır (belge + bütün satırları, cari + adresleri, stok +
--  barkod / fiyat / seri-lot, kalem + fiyatları, reçete + satır / operasyon);
--  pakette olmayan alt satır web'de silinir. Ajan değişen alt satırın üstünü
--  satırdan okur, ama SİLİNEN satır Delphi'de artık yok - Change Tracking yalnız
--  birincil anahtarı verir. Eşleme web'de duruyor: alt satırın aktarım kimliği
--  -> bağlı olduğu üst kaydın Delphi kimliği. Ajan o üstleri yeniden yollar.
--
--  Girdi  {"FATURA": [id, ...], "STOKBARKOD": [...], ...}
--  Çıktı  {"FATBASLIK": [id, ...], "STOKLAR": [...], ...}   (bulunamayan atlanır)
--  REHBERBILGI'nin web karşılığı satırı yok (cari kolonlarına katılır): üstü
--  bulunamaz, ajan o silmeyi günlüğe yazar (gece mutabakatı / tam eşitleme düzeltir).
-- =============================================================================

begin;

create or replace function public.fn_aktarim_ust(p jsonb)
returns jsonb language sql stable as $$
    with g as (
        select k as tablo, (e #>> '{}')::bigint as id
          from jsonb_each(coalesce(p, '{}')) x(k, v), jsonb_array_elements(case when jsonb_typeof(v) = 'array' then v else '[]' end) e
    ), u as (
        select 'FATBASLIK' ust, b.aktarim_id from g
          join public.belge_satir s on s.aktarim_kaynak = 1 and s.aktarim_tablo = 'FATURA' and s.aktarim_id = g.id
          join public.belge b on b.id = s.belge_id and b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK'
         where g.tablo = 'FATURA'
        union
        select 'FATBASLIK', b.aktarim_id from g
          join public.stok_izleme s on s.aktarim_kaynak = 1 and s.aktarim_tablo = 'STOKIZLEME' and s.aktarim_id = g.id
          join public.belge b on b.id = s.belge_id and b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK'
         where g.tablo = 'STOKIZLEME'
        union
        select 'REHBER', t.aktarim_id from g
          join public.taraf_adres a on a.aktarim_kaynak = 1 and a.aktarim_tablo = 'REHBERILETISIM' and a.aktarim_id = g.id
          join public.taraf t on t.id = a.taraf_id and t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER'
         where g.tablo = 'REHBERILETISIM'
        union
        select 'STOKLAR', s.aktarim_id from g
          join public.stok_barkod x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKBARKOD' and x.aktarim_id = g.id
          join public.stok s on s.id = x.stok_id and s.aktarim_kaynak = 1 and s.aktarim_tablo = 'STOKLAR'
         where g.tablo = 'STOKBARKOD'
        union
        select 'STOKLAR', s.aktarim_id from g
          join public.stok_fiyat x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKFIYAT' and x.aktarim_id = g.id
          join public.stok s on s.id = x.stok_id and s.aktarim_kaynak = 1 and s.aktarim_tablo = 'STOKLAR'
         where g.tablo = 'STOKFIYAT'
        union
        select 'STOKLAR', s.aktarim_id from g
          join public.stok_seri_lot x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKSERILOT' and x.aktarim_id = g.id
          join public.stok s on s.id = x.stok_id and s.aktarim_kaynak = 1 and s.aktarim_tablo = 'STOKLAR'
         where g.tablo = 'STOKSERILOT'
        union
        select 'MASRAFGELIR', h.aktarim_id from g
          join public.hizmet_fiyat x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FIYATLAR' and x.aktarim_id = g.id
          join public.hizmet h on h.id = x.hizmet_id and h.aktarim_kaynak = 1 and h.aktarim_tablo = 'MASRAFGELIR'
         where g.tablo = 'FIYATLAR'
        union
        select 'MASRAFGELIR', m.aktarim_id from g
          join public.masraf_fiyat x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FIYATLAR' and x.aktarim_id = g.id
          join public.masraf m on m.id = x.masraf_id and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'MASRAFGELIR'
         where g.tablo = 'FIYATLAR'
        union
        select 'URETIMRECETE', a.aktarim_id from g
          join public.urun_agaci_satir x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETEDETAY' and x.aktarim_id = g.id
          join public.urun_agaci a on a.id = x.agac_id and a.aktarim_kaynak = 1 and a.aktarim_tablo = 'URETIMRECETE'
         where g.tablo = 'URETIMRECETEDETAY'
        union
        select 'URETIMRECETE', a.aktarim_id from g
          join public.urun_agaci_operasyon x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'URETIMRECETEOPR' and x.aktarim_id = g.id
          join public.urun_agaci a on a.id = x.agac_id and a.aktarim_kaynak = 1 and a.aktarim_tablo = 'URETIMRECETE'
         where g.tablo = 'URETIMRECETEOPR'
    )
    select coalesce(jsonb_object_agg(ust, ids), '{}')
      from (select ust, jsonb_agg(distinct aktarim_id) ids from u group by ust) y
$$;

comment on function public.fn_aktarim_ust(jsonb) is
    '1087: silinen Delphi alt satırı -> web eşlemesinden üst kaydın Delphi kimliği (ajan toplamı yeniden yollar).';

commit;
