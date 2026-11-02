-- =============================================================================
--  1248  DELPHI AKTARIMI - TRANSFERİN LOT VARIŞ TARAFI
--
--  Kullanıcı 02.11.2026: "universe tüm lotlar düzgün aktarılmış mı" -> UNIVERSE'te Delphi lot bakiyesi
--  (STOKDURUMIZLEME) ile web (stok_lot_durum) karşılaştırıldı: 2.932 aynı, 28 satır yalnız TRANSFER yüzünden
--  farklı (web'de 581 adet eksik, 10 lot eksi bakiyede).
--
--  SEBEP: Delphi transferi TEK STOKIZLEME satırı + iki STOKIZLEMEDEPO kaydıyla (çıkış deposu -, varış deposu +)
--  tutar. Aktarım (1084 fn_aktar_belge) satırı tek depoya indirir: DONUSID = 0 olan transfer satırı ÇIKIŞ
--  deposuna yazılır; varış satırını DONUSID <> 0 bekler, Delphi'de öyle bir satır yok. Varış deposu hiç artmaz.
--  Lot defteri kuralı (1172 fn_stok_izleme_etki) varış satırını `belge_tur = 20 and donus_id <> 0` ile tanır.
--
--  1) fn_aktarim_transfer_varis_tamamla(): aktarılmış her transfer çıkış satırı için eksik VARIŞ satırını
--     ekler (aktarim_tablo 'STOKIZLEME_VARIS', donus_id = çıkış satırı, depo = belge satırının / belgenin giriş
--     deposu) ve lot bakiyesine varış deposunda +adet yazar. İdempotent: varışı olan satır atlanır.
--     UNIVERSE'te doğrulandı: 26 transferin hepsinde türetilen varış deposu Delphi STOKIZLEMEDEPO'nun artı
--     satırıyla aynı, adetler aynı.
--  2) fn_aktar_ek_lot_durum (1172, ek aktarımın son adımı) önce bunu çağırır: sonraki aktarımlarda lot defteri
--     transferi doğru kurar.
--  Veri onarımı bu dosyada YAPILMAZ (her kurulumda aktarım yok); aktarımla kurulmuş DB'de elle çağrılır:
--     select public.fn_aktarim_transfer_varis_tamamla();
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create or replace function public.fn_aktarim_transfer_varis_tamamla()
returns jsonb language plpgsql as $$
declare
    v_eklenen integer;
    v_adet numeric;
begin
    create temp table _varis on commit drop as
    select i.id as cikis_id, i.stok_id, i.seri_lot_id, i.izlem_tur, i.belge_id, i.belge_satir_id,
           i.adet, i.kalan, i.aktarim_id,
           coalesce(bs.giris_depo_id, b.giris_depo_id) as varis_depo
      from public.stok_izleme i
      left join public.belge_satir bs on bs.id = i.belge_satir_id
      join public.belge b on b.id = i.belge_id
     where i.aktarim_kaynak = 1 and i.aktarim_tablo = 'STOKIZLEME'
       and i.belge_tur = 20 and coalesce(i.donus_id, 0) = 0
       and coalesce(bs.giris_depo_id, b.giris_depo_id) is not null
       and coalesce(bs.giris_depo_id, b.giris_depo_id) is distinct from i.depo_id
       and not exists (select 1 from public.stok_izleme v
                        where v.belge_tur = 20 and v.donus_id = i.id);

    insert into public.stok_izleme
           (stok_id, seri_lot_id, izlem_tur, belge_tur, belge_id, belge_satir_id, adet, kalan,
            donus_id, depo_id, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select stok_id, seri_lot_id, izlem_tur, 20, belge_id, belge_satir_id, adet, kalan,
           cikis_id, varis_depo, 1, 'STOKIZLEME_VARIS', aktarim_id
      from _varis;
    get diagnostics v_eklenen = row_count;

    -- Lot bakiyesi: varış deposuna +adet (çıkış tarafı aktarımda zaten düşülmüştü).
    insert into public.stok_lot_durum (stok_id, depo_id, seri_lot_id, kalan)
    select stok_id, varis_depo, seri_lot_id, sum(adet) from _varis group by 1, 2, 3
    on conflict (stok_id, depo_id, seri_lot_id) do update
       set kalan = public.stok_lot_durum.kalan + excluded.kalan;
    select coalesce(sum(adet), 0) into v_adet from _varis;

    return jsonb_build_object('varis_eklenen', v_eklenen, 'adet', v_adet);
end $$;

comment on function public.fn_aktarim_transfer_varis_tamamla() is
  '1248: Delphi transferinin (tek STOKIZLEME + iki STOKIZLEMEDEPO) eksik varış lot hareketini ekler ve lot bakiyesine yazar.';

-- Ek aktarımın son adımı: önce varışlar, sonra lot defteri.
create or replace function public.fn_aktar_ek_lot_durum()
returns jsonb language plpgsql as $$
declare v_varis jsonb;
begin
    v_varis := public.fn_aktarim_transfer_varis_tamamla();
    return public.fn_stok_lot_durum_kur() || jsonb_build_object('transfer_varis', v_varis);
end $$;

commit;
