-- =============================================================================
--  1265  DELPHI AKTARIMI - e-BELGE SÜREKLİ ADIM (GENDEPO.EBELGE + EBELGEMESAJ)  (dokuman/18 §11)
--
--  KULLANICI (05.11.2026, ZONE #26315): "gönderilmiş fatura, baskı önizleme göremedim... eski programdan
--  gelmişti" -> "ebelge aktarımını yap". Aktarılan belgelerin efatura_durum'u gönderildi ama e_belge kaydı
--  (ETTN, UBL) yoktu: EBELGE yalnız bir kerelik ek aktarımla (1146 fn_aktar_ek_ebelge, aktar_ek.ps1 - Delphi
--  KAPANIRKEN) taşınıyordu; Delphi'yi kullanmaya devam eden kurumda hiç gelmiyordu.
--
--  Bu dosya e-Belge'yi ajanın 14. adımı yapar: fn_aktar_ebelge(jsonb) paket biçimiyle (U/D), toplam =
--  EBELGE satırı + bütün EBELGEMESAJ satırları (EBELGEID). Kaynak tablolar ANA DB'de değil depo DB'sinde
--  (<ANA>_GENDEPO, Delphi ULog kuralı); ajan ikinci bağlantıyla okur (ayar DepoBaglanti, yoksa ana
--  bağlantının veritabanı + _GENDEPO), CT versiyon sayacı depo DB'sinin kendisinindir (Update_SQL_221
--  sp_Aktarim_Depo_Hazirla CT'yi depo DB'sinde açar).
--
--  KURALLAR (1146 ile aynı eşleme):
--   * belge_turu 151 e-Fatura -> 1, 150 e-Arşiv -> 2; durum Delphi 2 (gönderildi) -> 2 / 12, 1 -> 1 / 11.
--   * Belgesi web'de olmayan EBELGE (hareket başlangıcından eski belge, ya da belge adımı henüz gelmedi)
--     YAZILMAZ ('belgesiz' sayılır; gece mutabakatı yeniden yollar, belge gelince bağlanır). 1146'nın
--     bir kerelik aktarımı belge_id boş yazıyordu - sürekli akışta boş satır birikirdi.
--   * Web'in kendi yazdığı aynı UUID'li satıra dokunulmaz ('web_uuid_atlanan').
--   * D.EBELGE: e_belge_mesaj önce, sonra e_belge; pakette olmayan mesaj satırı silinir (toplam kuralı).
--   * Zipli UBL (Delphi COMPRESS, opsiyon açıkken) olduğu gibi taşınır (bytea); sunucu okurken açar.
--  İdempotent (fn_aktarim_esitle); mutabakat EBELGE kimliğiyle (fn_aktarim_web_kimlikleri).
-- =============================================================================

begin;

create or replace function public.fn_aktar_ebelge(p jsonb)
returns jsonb language plpgsql as $$
declare
    v_sube int := coalesce((select min(id) from public.sube where aktif = 1), 1);
    v_be int := 0; v_bg int := 0; v_web int := 0; v_belgesiz int := 0;
    v_me int := 0; v_mg int := 0; v_msil int := 0; v_sil int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);

    create temp table if not exists _ae on commit drop as select * from stg.ebelge      with no data;
    create temp table if not exists _am on commit drop as select * from stg.ebelgemesaj with no data;
    truncate _ae, _am;
    insert into _ae select * from jsonb_populate_recordset(null::stg.ebelge,      coalesce(p->'U'->'EBELGE', '[]'));
    insert into _am select * from jsonb_populate_recordset(null::stg.ebelgemesaj, coalesce(p->'U'->'EBELGEMESAJ', '[]'));
    delete from _am m where not exists (select 1 from _ae e where e.id = m.ebelgeid);

    -- 0) D: Delphi'de silinen e-belge (mesajları önce).
    create temp table if not exists _ad (id bigint primary key) on commit drop;
    truncate _ad;
    insert into _ad select distinct (x #>> '{}')::bigint from jsonb_array_elements(coalesce(p->'D'->'EBELGE', '[]')) x
     where jsonb_typeof(x) = 'number' on conflict do nothing;
    delete from public.e_belge_mesaj m using public.e_belge x, _ad d
     where m.e_belge_id = x.id and x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE' and x.aktarim_id = d.id;
    delete from public.e_belge x using _ad d
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE' and x.aktarim_id = d.id;
    get diagnostics v_sil = row_count;

    -- 1) e_belge
    create temp table if not exists _aeb on commit drop as select e.* from public.e_belge e with no data;
    truncate _aeb;
    insert into _aeb (aktarim_id, belge_id, taraf_id, belge_turu, yon, uuid, belge_no, gonderici_alias,
                      alici_alias, durum, api_json, ubl_xml, ubl_xml_zip, servis_durum_kodu, servis_durum_adi,
                      gib_durum_kodu, gib_durum_aciklama, yanit_durum_kodu, yanit_durum_adi, ekleyen,
                      ekleme_tarihi, sube_id, gonderici_vkno, gonderici_unvan, entegrator, belge_tarihi, tutar,
                      vergi_tutar, para_birimi, profil)
    select e.id, b.id, coalesce(b.taraf_id, public.fn_aktarim_kisi_id(e.rehberid)),
           t.tur, coalesce(nullif(e.yon, 0), 1), nullif(btrim(e.uuid), ''),
           left(coalesce(e.belgeno, ''), 50), left(coalesce(e.gondericialias, ''), 500),
           left(coalesce(e.alicialias, ''), 500),
           case when e.durum = 2 then case t.tur when 2 then 12 else 2 end
                when e.durum = 1 then case t.tur when 2 then 11 else 1 end else coalesce(e.durum, 0) end,
           coalesce(e.api_json, ''), coalesce(e.ubl_xml, ''), e.ubl_xml_zip,
           left(coalesce(e.servis_durum_kodu, ''), 100), left(coalesce(e.servis_durum_adi, ''), 250),
           left(coalesce(e.gib_durum_kodu, ''), 50), left(coalesce(e.gib_durum_aciklama, ''), 500),
           left(coalesce(e.yanit_durum_kodu, ''), 100), left(coalesce(e.yanit_durum_adi, ''), 250),
           coalesce(public.fn_aktarim_kisi_id(e.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(e.eklemetarihi), timestamptz '1901-01-01'),
           coalesce(b.sube_id, v_sube),
           coalesce(s.vkno, ''), left(coalesce(nullif(s.unvan, ''), s.ad, ''), 200), 'izibiz',
           (b.belge_tarihi at time zone 'Europe/Istanbul')::date,
           coalesce(round(b.genel_toplam, 2), 0), coalesce(round(b.kdv_tutari, 2), 0),
           left(coalesce(nullif(case when b.belge_dovizi in ('', 'TL') then 'TRY' else b.belge_dovizi end, ''), 'TRY'), 3),
           case when t.tur = 2 then 'EARSIVFATURA'
                else case b.senaryo when 2 then 'TICARIFATURA' when 3 then 'IHRACAT' when 7 then 'KAMU'
                                    when 8 then 'ILAC_TIBBICIHAZ' else 'TEMELFATURA' end end
      from _ae e
      cross join lateral (select case e.belgeturu when 151 then 1 when 150 then 2
                                                  else e.belgeturu end::smallint as tur) t
      join public.belge b on b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK' and b.aktarim_id = e.fatbaslikid
      left join public.sube s on s.id = coalesce(b.sube_id, v_sube);
    v_belgesiz := (select count(*) from _ae) - (select count(*) from _aeb);

    -- web'in kendi yazdığı aynı UUID: dokunulmaz
    delete from _aeb w using public.e_belge x
     where x.uuid = w.uuid and w.uuid is not null
       and not (x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE' and x.aktarim_id = w.aktarim_id);
    get diagnostics v_web = row_count;

    select eklenen, guncellenen into v_be, v_bg from public.fn_aktarim_esitle('e_belge', 'EBELGE', '_aeb',
        array['belge_id', 'taraf_id', 'belge_turu', 'yon', 'uuid', 'belge_no', 'gonderici_alias', 'alici_alias',
              'durum', 'api_json', 'ubl_xml', 'ubl_xml_zip', 'servis_durum_kodu', 'servis_durum_adi',
              'gib_durum_kodu', 'gib_durum_aciklama', 'yanit_durum_kodu', 'yanit_durum_adi', 'ekleyen',
              'ekleme_tarihi', 'sube_id', 'gonderici_vkno', 'gonderici_unvan', 'entegrator', 'belge_tarihi',
              'tutar', 'vergi_tutar', 'para_birimi', 'profil']);

    -- 2) mesajlar: toplam kuralı - pakette olmayan satır silinir, kalanlar eşitlenir.
    delete from public.e_belge_mesaj m using public.e_belge x
     where m.e_belge_id = x.id and x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE'
       and x.aktarim_id in (select w.aktarim_id from _aeb w)
       and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'EBELGEMESAJ'
       and not exists (select 1 from _am a where a.id = m.aktarim_id);
    get diagnostics v_msil = row_count;

    create temp table if not exists _aem on commit drop as select m.* from public.e_belge_mesaj m with no data;
    truncate _aem;
    insert into _aem (aktarim_id, belge_id, e_belge_id, islem, tip, mesaj, http_kodu, servis, ekleyen, ekleme_tarihi)
    select m.id, x.belge_id, x.id, coalesce(m.islemturu, 0),
           case when coalesce(btrim(m.hatakodu), '') <> '' or coalesce(btrim(m.hatamesaji), '') <> '' then 9
                else coalesce(m.mesajtipi, 1) end,
           coalesce(m.mesaj, '')
             || coalesce(E'\nHata ' || nullif(btrim(m.hatakodu), ''), '')
             || coalesce(E'\n' || nullif(btrim(m.hatamesaji), ''), '')
             || coalesce(E'\nDurum ' || nullif(btrim(m.onceki_durum_kodu), '') || ' -> ' || coalesce(m.yeni_durum_kodu, ''), ''),
           coalesce(m.httpkodu, 0), left(coalesce(m.serviskodu, ''), 10), 0,
           coalesce(public.fn_aktarim_zaman(m.eklemetarihi), x.ekleme_tarihi)
      from _am m
      join public.e_belge x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE' and x.aktarim_id = m.ebelgeid;
    select eklenen, guncellenen into v_me, v_mg from public.fn_aktarim_esitle('e_belge_mesaj', 'EBELGEMESAJ', '_aem',
        array['belge_id', 'e_belge_id', 'islem', 'tip', 'mesaj', 'http_kodu', 'servis', 'ekleyen', 'ekleme_tarihi']);

    return jsonb_build_object('e_belge', v_be + v_bg, 'eklenen', v_be, 'guncellenen', v_bg, 'silinen', v_sil,
                              'belgesiz', v_belgesiz, 'web_uuid_atlanan', v_web,
                              'mesaj', v_me + v_mg, 'mesaj_silinen', v_msil);
end $$;

comment on function public.fn_aktar_ebelge(jsonb) is
    '1265: ajan paketi U/D EBELGE + EBELGEMESAJ (GENDEPO) -> e_belge / e_belge_mesaj; belgesi web''de olmayan atlanır.';

-- ------------------------------------------------------- 14. adım (1086) ---
create or replace function public.fn_aktarim_adimlari()
returns table (sira int, fonksiyon text, tablolar text[]) language sql immutable as $$
    values (1,  'fn_aktar_depo',           array['DEPOLAR']),
           (2,  'fn_aktar_doviz',          array['DOVIZ']),
           (3,  'fn_aktar_masraf_merkezi', array['SRMMERKEZI']),
           (4,  'fn_aktar_cari',           array['REHBER', 'REHBERILETISIM', 'REHBERBILGI']),
           (5,  'fn_aktar_proje',          array['PROJELER']),
           (6,  'fn_aktar_kalem',          array['MASRAFGELIR', 'FIYATLAR']),
           (7,  'fn_aktar_stok',           array['STOKLAR', 'STOKBARKOD', 'STOKFIYAT', 'STOKSERILOT']),
           (8,  'fn_aktar_hesap',          array['KASALAR', 'BANKAHESAPLAR', 'POS', 'KREDIKARTI', 'KREDILER']),
           (9,  'fn_aktar_is_merkezi',     array['LOKASYON']),
           (10, 'fn_aktar_recete',         array['URETIMRECETE', 'URETIMRECETEDETAY', 'URETIMRECETEOPR']),
           (11, 'fn_aktar_stok_durum',     array['STOKDURUM']),
           (12, 'fn_aktar_belge',          array['FATBASLIK', 'FATURA', 'STOKIZLEME']),
           (13, 'fn_aktar_kasa',           array['KASA']),
           -- 1265: e-Belge geçmişi depo DB'sinden (GENDEPO); belge adımından SONRA (belge bağı).
           (14, 'fn_aktar_ebelge',         array['EBELGE', 'EBELGEMESAJ'])
$$;

-- ---------------------------------------------- mutabakat kimlikleri (1091) ---
create or replace function public.fn_aktarim_web_kimlikleri(p_tablo text)
returns table (aktarim_id bigint, aktif boolean) language plpgsql stable as $$
begin
    case p_tablo
    when 'DEPOLAR' then
        return query select x.aktarim_id, x.durum <> 0 from public.depo x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'SRMMERKEZI' then   -- D yok: fazla raporlanmaz
        return query select x.aktarim_id, false from public.masraf_merkezi x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'REHBER' then       -- 0 = Tanımsız Cari (1085): Delphi'de REHBER satırı değil, web kartı
        return query select x.aktarim_id, x.durum <> 0 and x.aktarim_id <> 0 from public.taraf x
                      where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'PROJELER' then
        return query select x.aktarim_id, x.durum <> 0 from public.proje x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'MASRAFGELIR' then
        return query select x.aktarim_id, bool_or(x.aktif) from (
                         select h.aktarim_id, h.durum <> 0 aktif from public.hizmet h where h.aktarim_kaynak = 1 and h.aktarim_tablo = p_tablo
                         union all
                         select m.aktarim_id, m.durum <> 0 from public.masraf m where m.aktarim_kaynak = 1 and m.aktarim_tablo = p_tablo) x
                      group by x.aktarim_id;
    when 'STOKLAR' then
        return query select x.aktarim_id, x.durum <> 0 from public.stok x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'KASALAR', 'BANKAHESAPLAR', 'POS', 'KREDIKARTI', 'KREDILER' then
        return query select x.aktarim_id, x.durum <> 0 from public.hesap x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'LOKASYON' then     -- iş merkezinde pasif = 1 (1083)
        return query select x.aktarim_id, x.durum <> 1 from public.is_merkezi x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'URETIMRECETE' then -- ürün ağacında pasif = 1 (1083)
        return query select x.aktarim_id, x.durum <> 1 from public.urun_agaci x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'FATBASLIK' then    -- D belgeyi siler: her satır "aktif"
        return query select x.aktarim_id, true from public.belge x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    when 'KASA' then         -- cari satırı mali_hareket, hesap satırı kasa_islem (1085)
        return query select x.aktarim_id, true from (
                         select m.aktarim_id from public.mali_hareket m where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA'
                         union
                         select k.aktarim_id from public.kasa_islem k where k.aktarim_kaynak = 1 and k.aktarim_tablo = 'KASA') x;
    when 'EBELGE' then       -- 1265: D e-belgeyi siler; belgesi olmayan EBELGE web'e yazılmaz (eksik = kural gereği atlanan)
        return query select x.aktarim_id, true from public.e_belge x where x.aktarim_kaynak = 1 and x.aktarim_tablo = p_tablo;
    else
        raise exception using errcode = 'GK422', message = format('AKTARIM_TABLO: %s mutabakata girmez', p_tablo);
    end case;
end $$;

commit;
