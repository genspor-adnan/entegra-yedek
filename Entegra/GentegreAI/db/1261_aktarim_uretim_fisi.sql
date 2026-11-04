-- =============================================================================
--  1261  DELPHI AKTARIMI - ÜRETİM FİŞLERİ (FATBASLIK TUR 6 -> uretim_fisi)
--
--  Kullanıcı 04.11.2026 (ZONE yerel kopyası): "zone sql den üretim fişleri aktarıldı mı" -> aktarım
--  Delphi üretim fişini (FATBASLIK TUR = 6, tek belge: malzeme satırları eksi, mamul satırı artı) belge
--  tür 6 "Üretim" olarak taşımıştı (ZONE 6.036 belge, 120.977 satır). Stok hareketi doğru (v_stok_hareket),
--  ama yeni Üretim Fişi Listesi (1253 uretim_fisi) bu kayıtları görmüyordu; reçete kartı "Üretimler" boş.
--  Karar: "2 yap" = göçle dönüştürme. Eski belge stokta OLDUĞU GİBİ kalır (hareket tek hattan); üstüne
--  uretim_fisi başlığı + satırları kurulur, belge fişe bağlanır (belge.kaynak_tur 61 / kaynak_id = fiş).
--
--  EŞLEME
--    fiş.no            = Delphi FATURANO (belge_no; benzersiz)      fiş.durum = belge 0 kesin -> 2 gerçekleşti,
--    fiş.seviye        = 'aktarim' (hangi kurallarla kesildiği belli değil; denetimli SAYILMAZ)   2 iptal -> 0 ters kayıt
--    fiş.stok_id       = artı miktarlı ilk satırın stoğu (ana ürün); diğer artı satırlar yan ürün (grup 4, ana_urun 0)
--    fiş.miktar = uretilen = ana satır miktarı · birim = satırın birimi
--    fiş.malzeme       = Σ|eksi satır tutarı| · toplam = ana satır tutarı (Delphi'nin yazdığı mamul maliyeti - YENİDEN
--                        HESAPLANMAZ, Σ sarf ile farklı olabilir) · birim_maliyet = tutar / miktar (Delphi BIRIMFIYAT ile TUTAR
--                        aynı para biriminde değil - ZONE 1124 TL / 820 EUR; satırlarda da öyle) · yan_urun = Σ yan satır
--    fiş.sarf_belge_id = giris_belge_id = AYNI belge (Delphi tek belge keser; fire belgesi yok)
--    fiş.agac_id       = mamulün varsayılan ağacı, yoksa tek ağacı varsa o (reçete kartı "Üretimler" için); yoksa boş
--    satır grup        = eksi -> 1 sarf · artı -> 4 çıktı (sıfır miktarlı satır sarf olarak kalır, 16 satır)
--    aktarim_tablo / aktarim_id = 'FATBASLIK' / Delphi ID (fişte yeni kolonlar; belge ile aynı desen)
--  ATLANAN: artı satırı olmayan belge (mamul belirsiz; ZONE'da 2) ve TASLAK belge (durum 1; stok etkisi yok,
--  web taslağı olarak devam ettirilemez - 1). Sayıları döner.
--  TERS KAYIT YOK: aktarılan fiş tek belgedir, API ters kayıtı 422 ile reddeder (UretimFisiUclari) - belge
--  stok hareketlerinden silinir. Kart "Delphi aktarımı" rozeti gösterir, Sil gizlenir.
--  MALİYET: fn_uretim_stok_son_maliyeti / fn_uretim_stok_maliyeti giriş türlerine 6 eklendi - Delphi üretiminden
--  gelen mamul girişi "son giriş" ve ağırlıklı ortalamada sayılır (miktar > 0 süzgeci sarf satırlarını zaten dışlar).
--  İDEMPOTENT: aktarim_tablo / aktarim_id olan belge atlanır. Göç sonunda çalışır (aktarımsız kurulumda 0 iş);
--  fn_aktar_ek zinciri de 'uretim_fisi' adımıyla sonraki aktarımlarda otomatik kurar (lot_durum'dan önce).
-- =============================================================================
\set ON_ERROR_STOP on
begin;

alter table public.uretim_fisi add column if not exists aktarim_tablo varchar(30) not null default '';
alter table public.uretim_fisi add column if not exists aktarim_id    bigint;
create unique index if not exists ux_uretim_fisi_aktarim on public.uretim_fisi(aktarim_tablo, aktarim_id) where aktarim_tablo <> '';
comment on column public.uretim_fisi.aktarim_tablo is '1261: Delphi kaynağı (FATBASLIK) - aktarılan fiş tek belgedir, ters kayıt yapılmaz.';

create or replace function public.fn_aktarim_uretim_fisi_kur()
returns jsonb language plpgsql as $$
declare
    v_b          record;
    v_ana        record;
    v_fis_id     integer;
    v_agac_id    integer;
    v_agac_surum smallint;
    v_eklenen    integer := 0;
    v_satir      integer := 0;
    v_agacli     integer := 0;
    v_mamulsuz   integer := 0;
    v_taslak     integer := 0;
    v_no_catisan integer := 0;
    v_n          integer;
begin
    perform set_config('gentegre.aktarim', '1', true);

    for v_b in
        select b.*
          from public.belge b
         where b.tur = 6 and b.aktarim_tablo = 'FATBASLIK' and b.aktarim_id is not null
           and not exists (select 1 from public.uretim_fisi f
                            where f.aktarim_tablo = 'FATBASLIK' and f.aktarim_id = b.aktarim_id)
         order by b.belge_tarihi, b.id
    loop
        if v_b.durum = 1 then v_taslak := v_taslak + 1; continue; end if;

        select s.* into v_ana
          from public.belge_satir s
         where s.belge_id = v_b.id and s.tur = 1 and s.stok_id is not null and s.miktar > 0
         order by s.sira, s.id limit 1;
        if not found then v_mamulsuz := v_mamulsuz + 1; continue; end if;

        -- Fiş numarası Delphi'den; aynı no'lu web fişi varsa belge kimliğiyle ayrıştırılır.
        if exists (select 1 from public.uretim_fisi f where f.no = v_b.belge_no) then v_no_catisan := v_no_catisan + 1; end if;

        -- Reçete: mamulün varsayılan ağacı, yoksa tek ağacı.
        select u.id, u.surum into v_agac_id, v_agac_surum
          from public.urun_agaci u where u.stok_id = v_ana.stok_id and u.varsayilan = 1 order by u.id limit 1;
        if v_agac_id is null then
            select count(*) into v_n from public.urun_agaci u where u.stok_id = v_ana.stok_id;
            if v_n = 1 then
                select u.id, u.surum into v_agac_id, v_agac_surum from public.urun_agaci u where u.stok_id = v_ana.stok_id;
            end if;
        end if;
        if v_agac_id is not null then v_agacli := v_agacli + 1; end if;

        insert into public.uretim_fisi
               (no, durum, seviye, stok_id, agac_id, agac_surum, emir_id, miktar, uretilen, birim, bas, bit,
                sarf_depo_id, giris_depo_id, proje_id, maliyet_yontemi, otomatik_hesap, doviz_cinsi, doviz_kuru,
                malzeme, iscilik, fire_normal, fire_anormal, yan_urun, toplam, birim_maliyet,
                sarf_belge_id, giris_belge_id, fire_belge_id, gerceklesme_an, gerceklestiren,
                ters_an, ters_kullanici_id, ters_neden, aciklama, sube_id,
                ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi, aktarim_tablo, aktarim_id)
        select case when exists (select 1 from public.uretim_fisi f where f.no = v_b.belge_no)
                    then v_b.belge_no || '/' || v_b.id else v_b.belge_no end,
               case v_b.durum when 2 then 0 else 2 end,
               'aktarim', v_ana.stok_id, v_agac_id, coalesce(v_agac_surum, 0), null,
               v_ana.miktar, v_ana.miktar, coalesce(v_ana.birim, 0), v_b.belge_tarihi, null,
               coalesce(v_b.cikis_depo_id, v_b.giris_depo_id), coalesce(v_b.giris_depo_id, v_b.cikis_depo_id),
               v_b.proje_id, 1, 0, coalesce(nullif(v_b.doviz_cinsi, ''), 'TL'), coalesce(nullif(v_b.doviz_kuru, 0), 1),
               coalesce((select sum(abs(s.tutar)) from public.belge_satir s where s.belge_id = v_b.id and s.miktar < 0), 0),
               0, 0, 0,
               coalesce((select sum(s.tutar) from public.belge_satir s where s.belge_id = v_b.id and s.miktar > 0 and s.id <> v_ana.id), 0),
               coalesce(v_ana.tutar, 0), case when v_ana.miktar > 0 then round(coalesce(v_ana.tutar, 0) / v_ana.miktar, 4) else 0 end,
               v_b.id, v_b.id, null, v_b.belge_tarihi, coalesce(v_b.ekleyen, 0),
               case when v_b.durum = 2 then coalesce(v_b.degistirme_tarihi, v_b.belge_tarihi) end,
               case when v_b.durum = 2 then v_b.degistiren end,
               case when v_b.durum = 2 then 'Delphi: iptal edilmiş üretim fişi' else '' end,
               left(coalesce(v_b.aciklama, ''), 500), coalesce(v_b.sube_id, 0),
               coalesce(v_b.ekleyen, 0), coalesce(v_b.ekleme_tarihi, v_b.belge_tarihi), coalesce(v_b.degistiren, 0), v_b.degistirme_tarihi,
               'FATBASLIK', v_b.aktarim_id
        returning id into v_fis_id;
        v_eklenen := v_eklenen + 1;

        insert into public.uretim_fisi_satir
               (fis_id, sira, grup, stok_id, ad, ana_urun, birim_ihtiyac, plan_miktar, miktar, birim, birim_maliyet, tutar,
                elle_maliyet, fire_turu, belge_satir_id, aciklama, ekleyen, ekleme_tarihi)
        select v_fis_id, coalesce(s.sira, 0), case when s.miktar > 0 then 4 else 1 end, s.stok_id, '',
               case when s.id = v_ana.id then 1 else 0 end, 0, abs(coalesce(s.miktar, 0)), abs(coalesce(s.miktar, 0)),
               coalesce(s.birim, 0), case when coalesce(s.miktar, 0) <> 0 then round(abs(coalesce(s.tutar, 0) / s.miktar), 4) else 0 end, abs(coalesce(s.tutar, 0)),
               case when s.miktar > 0 and s.id <> v_ana.id then 1 else 0 end, 1, s.id, left(coalesce(s.aciklama, ''), 300),
               coalesce(s.ekleyen, 0), coalesce(s.ekleme_tarihi, v_b.belge_tarihi)
          from public.belge_satir s
         where s.belge_id = v_b.id and s.tur = 1 and s.stok_id is not null
         order by s.sira, s.id;
        get diagnostics v_n = row_count;
        v_satir := v_satir + v_n;

        -- Belge fişe bağlanır (kart "Belgeler", v_uretim_hareket). Dönüşüm bağı olan belgeye dokunulmaz.
        update public.belge set kaynak_tur = 61, kaynak_id = v_fis_id
         where id = v_b.id and coalesce(kaynak_tur, 0) = 0;
    end loop;

    return jsonb_build_object('fis_eklenen', v_eklenen, 'satir_eklenen', v_satir, 'agac_baglanan', v_agacli,
                              'mamulsuz_atlanan', v_mamulsuz, 'taslak_atlanan', v_taslak, 'no_catisan', v_no_catisan);
end $$;

comment on function public.fn_aktarim_uretim_fisi_kur() is
    '1261: Delphi üretim fişi (belge tür 6, aktarım FATBASLIK) -> uretim_fisi başlık + satır; belge fişe bağlanır (kaynak_tur 61). '
    'Ana ürün = ilk artı satır, sarf = eksi satırlar; maliyet Delphi değerleri. Mamulsüz / taslak belge atlanır. İdempotent.';

-- fn_aktar_ek zinciri (1192 + 'uretim_fisi'): çekirdek aktarım belgeleri getirdikten sonra, lot defterinden önce.
create or replace function public.fn_aktar_ek_uretim_fisi()
returns jsonb language plpgsql as $$
begin
    return public.fn_aktarim_uretim_fisi_kur();
end $$;

create or replace function public.fn_aktar_ek()
returns jsonb language plpgsql as $$
declare
    v_sonuc jsonb := '{}';
    v_m text;
    v_r jsonb;
begin
    perform set_config('gentegre.aktarim', '1', true);
    foreach v_m in array array['kategori', 'kisi', 'hesap_plani', 'demirbas', 'cek', 'teklif', 'siparis', 'gorev', 'dokuman', 'ebelge',
                               'uretim_fisi', 'lot_durum'] loop
        begin
            execute format('select public.fn_aktar_ek_%s()', v_m) into v_r;
            v_sonuc := v_sonuc || jsonb_build_object(v_m, v_r);
        exception when others then
            v_sonuc := v_sonuc || jsonb_build_object(v_m, jsonb_build_object('hata', sqlerrm));
        end;
    end loop;
    return v_sonuc;
end $$;

comment on function public.fn_aktar_ek() is
    '1149/1171/1172/1192/1261: Delphi ek modülleri (stg) sırayla aktarır - kategori, kişi, hesap planı, demirbaş, çek, teklif, sipariş, '
    'görev, döküman, e-Belge, üretim fişi; sonda lot defteri kurulur. Modül hatası diğerlerini durdurmaz.';

-- Mamul maliyeti: Delphi üretim girişi (tür 6, artı satır) da giriş sayılır.
create or replace function public.fn_uretim_stok_maliyeti(p_stok_id integer)
returns numeric language sql stable as $$
    select coalesce(
      (select case when sum(bs.miktar) > 0
                   then round(sum(bs.tutar) / sum(bs.miktar), 4) else null end
         from public.belge_satir bs
         join public.belge b on b.id = bs.belge_id
        where bs.stok_id = p_stok_id
          and bs.miktar > 0
          and b.tur in (3, 6, 10, 11, 12, 109, 122)),
      (select f.fiyat from public.stok_fiyat f
        where f.stok_id = p_stok_id and f.satis = 0 and f.fiyat > 0
        order by f.id limit 1),
      0);
$$;

create or replace function public.fn_uretim_stok_son_maliyeti(p_stok_id integer)
returns numeric language sql stable as $$
    select coalesce(
      (select case when bs.miktar > 0 then round(bs.tutar / bs.miktar, 4) else null end
         from public.belge_satir bs
         join public.belge b on b.id = bs.belge_id
        where bs.stok_id = p_stok_id and bs.miktar > 0 and b.durum = 0
          and b.tur in (3, 6, 10, 11, 12, 109, 122)
        order by b.belge_tarihi desc, b.id desc, bs.id desc
        limit 1),
      public.fn_uretim_stok_maliyeti(p_stok_id));
$$;

-- Aktarılmış kurulumda hemen kurar; aktarımsız kurulumda 0 iş.
select public.fn_aktarim_uretim_fisi_kur();

commit;
