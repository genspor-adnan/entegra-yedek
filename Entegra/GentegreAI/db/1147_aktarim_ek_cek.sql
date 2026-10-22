-- =============================================================================
--  1147  DELPHI AKTARIMI - ÇEK / SENET  (CEKLER, CEKHAREKET; bir kerelik, 1143)
--
--  CEKLER -> cek_senet, CEKHAREKET -> cek_senet_hareket ve hareketin CARİ satırı.
--
--  CARİ ETKİ: Delphi çek hareketine KASA satırı yazmaz; cari listesi ve ekstresi
--  CEKHAREKET'i doğrudan okur (sp_Prog_Cari_Liste_Json2, fn_Cari_Ekstre UNION).
--  Web ekstresi yalnız mali_hareket okur -> aktarım cari satırını kendisi yazar
--  (faturanın cari satırı gibi, kasa_islem'siz), Delphi kuralıyla:
--    BORÇ  : ISLEM 140 satıcıya verildi, 131 ciro, 132 teminata (cari), 134 icra, 137 iade
--    ALACAK: ISLEM 130 portföye giriş, 141 satıcıdan iade
--    (133 takas, 135/136/138/142/143 cariyi etkilemez - Delphi de saymaz; Delphi
--    sıfır tarihli 1899-12-29 hareketi de saymaz)
--    tutar: CEKHAREKET.EKSTREDEKULLAN=1 ise hareketin TUTAR/KUR'u, değilse çekin.
--  Web türü: 130 -> 23/24 (çek/senet ile tahsilat), 140 -> 33/34 (çek/senet ile
--  ödeme), 131/132 -> 52 Çek Ciro, 134/137/141 -> 56 Karşılıksız / İade; Delphi
--  işlem adı açıklamanın başında.
--
--  DURUM (CEKLER.TUR = güncel durum, GENINI -2601/-2602) -> cek_senet.durum:
--    130 Portföyde 10 · 131 Cirolu 20 · 132 Teminatta (cari) 40 · 133 Takasta 30 ·
--    134 İcrada 60 · 135 Karşılıksız 60 · 136 Tahsil 50 · 137 İade 70 ·
--    138 Teminatta (banka) 40 · 140 Satıcıda 10 · 141 Satıcıdan iade 70 ·
--    142 İptal 0 · 143 Ödendi 50.  (web'de "icrada" yok: karşılıksıza en yakın.)
--  İŞLEM (CEKHAREKET.ISLEM = o hareketle gelen durum) -> cek_senet_hareket.islem:
--    130 130 · 131 131 · 132/138 137 teminata · 133 132 bankaya tahsile ·
--    134/135 134 karşılıksız · 136 133 tahsil · 137/141 135 iade · 140 130 ·
--    142 139 iptal · 143 136 ödendi. ISLEM'siz satır (13) atlanır.
--  Tür / yön: CEKSENET 101 alınan çek (1/1), 103 verilen çek (1/2),
--             121 alınan senet (2/1), 321 verilen senet (2/2).
-- =============================================================================

begin;

create or replace function public.fn_aktar_ek_cek()
returns jsonb language plpgsql as $$
declare
    v_ce int := 0; v_cg int := 0; v_he int := 0; v_hg int := 0; v_me int := 0; v_mg int := 0;
    v_atla int := 0; v_hatla int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);

    -- 1) çek / senet kartı
    create temp table if not exists _cs on commit drop as select c.* from public.cek_senet c with no data;
    truncate _cs;
    insert into _cs (aktarim_id, tur, yon, durum, taraf_id, kesideci, hesap_id, tarih, vade, tutar, doviz_cinsi,
                     doviz_kuru, yerel_tutar, seri_no, banka_adi, hesap_no, makbuz_no, proje_id, sube_id, aciklama,
                     ekleme_tarihi)
    select c.id,
           case when c.ceksenet in (121, 321) then 2 else 1 end,
           case when c.ceksenet in (103, 321) then 2 else 1 end,
           case c.tur when 130 then 10 when 131 then 20 when 132 then 40 when 133 then 30 when 134 then 60
                      when 135 then 60 when 136 then 50 when 137 then 70 when 138 then 40 when 140 then 10
                      when 141 then 70 when 142 then 0 when 143 then 50 else 10 end,
           public.fn_aktarim_web_id('taraf', 'REHBER', c.rehberid),
           left(coalesce(c.borclu, ''), 150),
           case when c.ceksenet in (103, 321) then public.fn_aktarim_web_id('hesap', 'BANKAHESAPLAR', c.hesapid) end,
           coalesce(c.tarih, c.eklemetarihi, c.vade, timestamp '1901-01-01')::date,
           coalesce(c.vade, c.tarih, c.eklemetarihi, timestamp '1901-01-01')::date,
           coalesce(c.tutar, 0), d.cins,
           case when d.cins <> 'TL' and coalesce(c.tutar, 0) <> 0 and y.yerel <> c.tutar
                then abs(round(y.yerel / c.tutar, 6)) else 1 end,
           y.yerel,
           left(coalesce(c.serino::text, ''), 30), left(coalesce(c.odemeyeri, ''), 60), left(coalesce(c.hesapno, ''), 30),
           left(coalesce(c.makbuzno, ''), 30),
           public.fn_aktarim_web_id('proje', 'PROJELER', c.projeid),
           public.fn_aktarim_sube(c.subeid), left(coalesce(c.aciklama, ''), 200),
           coalesce(public.fn_aktarim_zaman(c.eklemetarihi), public.fn_aktarim_zaman(c.tarih), timestamptz '1901-01-01')
      from stg.cekler c
      cross join lateral (select public.fn_aktarim_doviz(c.kur) as cins) d
      cross join lateral (
          select case when d.cins = 'TL' then coalesce(c.tutar, 0)
                      when public.fn_aktarim_doviz(c.doviz_kuru) = 'TL' and coalesce(btrim(c.doviz_kuru), '') <> ''
                           and coalesce(c.doviz_tutari, 0) <> 0 then c.doviz_tutari
                      else coalesce(c.tutar, 0) end as yerel) y;
    select eklenen, guncellenen into v_ce, v_cg from public.fn_aktarim_esitle('cek_senet', 'CEKLER', '_cs',
        array['tur', 'yon', 'durum', 'taraf_id', 'kesideci', 'hesap_id', 'tarih', 'vade', 'tutar', 'doviz_cinsi',
              'doviz_kuru', 'yerel_tutar', 'seri_no', 'banka_adi', 'hesap_no', 'makbuz_no', 'proje_id', 'sube_id',
              'aciklama', 'ekleme_tarihi']);

    -- 2) hareketler (eski durum = aynı çekin bir önceki hareketinin yeni durumu)
    create temp table if not exists _csh on commit drop as select h.* from public.cek_senet_hareket h with no data;
    truncate _csh;
    insert into _csh (aktarim_id, cek_senet_id, islem, tarih, eski_durum, yeni_durum, taraf_id, hesap_id, aciklama,
                      ekleme_tarihi)
    select x.id, x.cek, x.islem, x.tarih,
           coalesce(lag(x.yeni) over (partition by x.cek order by x.tarih, x.id), 0), x.yeni,
           x.taraf, x.hesap, x.aciklama, x.eklendi
      from (select h.id, public.fn_aktarim_web_id('cek_senet', 'CEKLER', h.ceksenetlerid) as cek,
                   case h.islem when 130 then 130 when 131 then 131 when 132 then 137 when 138 then 137
                                when 133 then 132 when 134 then 134 when 135 then 134 when 136 then 133
                                when 137 then 135 when 141 then 135 when 140 then 130 when 142 then 139
                                when 143 then 136 end as islem,
                   case h.islem when 130 then 10 when 131 then 20 when 132 then 40 when 133 then 30 when 134 then 60
                                when 135 then 60 when 136 then 50 when 137 then 70 when 138 then 40 when 140 then 10
                                when 141 then 70 when 142 then 0 when 143 then 50 end as yeni,
                   coalesce(h.tarih, h.eklemetarihi, timestamp '1901-01-01')::date as tarih,
                   public.fn_aktarim_web_id('taraf', 'REHBER', h.rehberid) as taraf,
                   public.fn_aktarim_web_id('hesap', 'BANKAHESAPLAR', h.bankahesaplarid) as hesap,
                   left(coalesce(h.aciklama, ''), 200) as aciklama,
                   coalesce(public.fn_aktarim_zaman(h.eklemetarihi), public.fn_aktarim_zaman(h.tarih), timestamptz '1901-01-01') as eklendi
              from stg.cekhareket h) x
     where x.cek is not null and x.islem is not null;
    select count(*) - (select count(*) from _csh) into v_hatla from stg.cekhareket;
    select eklenen, guncellenen into v_he, v_hg from public.fn_aktarim_esitle('cek_senet_hareket', 'CEKHAREKET', '_csh',
        array['cek_senet_id', 'islem', 'tarih', 'eski_durum', 'yeni_durum', 'taraf_id', 'hesap_id', 'aciklama',
              'ekleme_tarihi']);

    -- 3) hareketin cari satırı (Delphi cari listesi kuralı)
    create temp table if not exists _csm on commit drop as select m.* from public.mali_hareket m with no data;
    truncate _csm;
    insert into _csm (aktarim_id, tur, hesap_turu, taraf_id, belge_no, islem_tarihi, borc, alacak, yerel_borc,
                      yerel_alacak, doviz_cinsi, doviz_kuru, aciklama, ekstrede_kullan, sube_id, proje_id, durum)
    select h.id,
           case when h.islem = 130 then case when c.ceksenet in (121, 321) then 24 else 23 end
                when h.islem = 140 then case when c.ceksenet in (121, 321) then 34 else 33 end
                when h.islem in (131, 132) then 52 else 56 end,
           'C', t.id, left(coalesce(nullif(h.belgeno, ''), c.makbuzno, ''), 30),
           coalesce(public.fn_aktarim_zaman(h.tarih), public.fn_aktarim_zaman(h.eklemetarihi), timestamptz '1901-01-01'),
           case when b.borc then a.tutar else 0 end, case when b.borc then 0 else a.tutar end,
           case when b.borc then a.yerel else 0 end, case when b.borc then 0 else a.yerel end,
           a.cins, case when a.tutar <> 0 then abs(round(a.yerel / a.tutar, 6)) else 1 end,
           left('[Delphi: ' || case h.islem when 130 then 'Portföye giriş' when 131 then 'Ciro'
                                            when 132 then 'Teminata verildi' when 134 then 'İcraya verildi'
                                            when 137 then 'İade edildi' when 140 then 'Satıcıya verildi'
                                            when 141 then 'Satıcıdan iade' end
                || ' · ' || case when c.ceksenet in (121, 321) then 'senet' else 'çek' end
                || coalesce(' ' || nullif(c.serino::text, ''), '') || '] ' || coalesce(h.aciklama, ''), 100),
           coalesce(h.ekstredekullan, 0), public.fn_aktarim_sube(coalesce(h.subeid, c.subeid)),
           public.fn_aktarim_web_id('proje', 'PROJELER', coalesce(nullif(h.projeid, 0), c.projeid)), 0
      from stg.cekhareket h
      join stg.cekler c on c.id = h.ceksenetlerid
      join public.taraf t on t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER' and t.aktarim_id = h.rehberid
      cross join lateral (select h.islem in (140, 131, 132, 134, 137) as borc) b
      cross join lateral (
          select case when h.ekstredekullan = 1 then public.fn_aktarim_doviz(h.kur) else public.fn_aktarim_doviz(c.kur) end as cins,
                 case when h.ekstredekullan = 1 then coalesce(h.tutar, 0) else coalesce(c.tutar, 0) end as tutar) a0
      cross join lateral (
          select a0.cins, a0.tutar,
                 case when a0.cins = 'TL' then a0.tutar
                      when public.fn_aktarim_doviz(c.doviz_kuru) = 'TL' and coalesce(btrim(c.doviz_kuru), '') <> ''
                           and coalesce(c.doviz_tutari, 0) <> 0 and h.ekstredekullan is distinct from 1 then c.doviz_tutari
                      else a0.tutar end as yerel) a
     where h.rehberid > 0 and h.islem in (130, 131, 132, 134, 137, 140, 141)
       and h.tarih >= timestamp '1900-01-01';
    -- Delphi sıfır tarihli (1899-12-29) hareket cariyi etkilemez: cari listesi ve
    --   ekstresi tarih süzgeciyle dışarıda bırakır (FETA: aynı çekin mükerrer girişi).
    select count(*) - (select count(*) from _csm) into v_atla
      from stg.cekhareket h where h.rehberid > 0 and h.islem in (130, 131, 132, 134, 137, 140, 141);
    -- Delphi'de artık cariyi etkilemeyen (satırı/carisi silinmiş) hareketin cari satırı kalkar.
    delete from public.mali_hareket m
     where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'CEKHAREKET'
       and not exists (select 1 from _csm x where x.aktarim_id = m.aktarim_id);
    select eklenen, guncellenen into v_me, v_mg from public.fn_aktarim_esitle('mali_hareket', 'CEKHAREKET', '_csm',
        array['tur', 'hesap_turu', 'taraf_id', 'belge_no', 'islem_tarihi', 'borc', 'alacak', 'yerel_borc',
              'yerel_alacak', 'doviz_cinsi', 'doviz_kuru', 'aciklama', 'ekstrede_kullan', 'sube_id', 'proje_id', 'durum']);

    return jsonb_build_object('cek_eklenen', v_ce, 'cek_guncellenen', v_cg,
                              'hareket_eklenen', v_he, 'hareket_guncellenen', v_hg, 'hareket_atlanan', v_hatla,
                              'cari_eklenen', v_me, 'cari_guncellenen', v_mg, 'cari_atlanan', v_atla);
end $$;

comment on function public.fn_aktar_ek_cek() is
    '1147: Delphi CEKLER / CEKHAREKET (stg) -> cek_senet / cek_senet_hareket + hareketin cari satırı (Delphi cari listesi kuralı). İdempotent.';

commit;
