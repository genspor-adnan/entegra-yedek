-- =============================================================================
--  1182  DELPHI CARİ KİŞİ BÖLÜM / GÖREV LİSTELERİ AKTARIMI (fn_aktar_kisi_listeleri)
--
--  Kullanıcı (25.10.2026): "bölüm ve görev listesinin de migrate olması gerekir".
--  Delphi cari kişisinde Bölüm = GENINI -2206 (Ops_CariKart_Bolum), Görev = GENINI -2205
--  (Ops_CariKart_Gorev); firmanın kendi departmanları -2251 (Ops_Bizim_Departman). Web'de
--  bölüm `departman` tablosu (251), görev `personel_gorev` tablosu (255) - kurulum tohumu
--  (hastane bölümleri / görevleri) dolu, Delphi'nin listesi yoktu.
--
--  fn_aktar_kisi_listeleri(): stg.genini'den EKLEYİCİ:
--    · Adı (büyük/küçük harf, baş/son boşluk farkı yok sayılarak) zaten olan satır eklenmez -
--      tohum ve kullanıcının açtığı kayıt ezilmez.
--    · Yeni satırlar yeni id alır (Delphi değer numaraları web'de başka kayda ait olabilir;
--      Delphi'de kişi bölüm / görev değeri taşıyan veri yok - UNIVERSE'te tek serbest metin).
--      Kimlik dizisi sonra en büyük id'ye çekilir.
--    · Görevler bağımsız (departman_id 0) - her bölümde seçilebilir.
--    · Tekrar çalıştırılabilir. Dönüş: {bolum_eklenen, gorev_eklenen}.
-- =============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_aktar_kisi_listeleri()
returns jsonb
language plpgsql
as $$
declare
  v_bolum int := 0; v_gorev int := 0;
begin
  if to_regclass('stg.genini') is null then
    raise exception 'fn_aktar_kisi_listeleri: stg.genini yok - önce aktar_ek.ps1 (GENINI) ile çekin';
  end if;

  insert into public.departman (id, ad, durum, sira)
  select (select coalesce(max(id), 0) from public.departman) + row_number() over (order by y.sira, y.ad),
         y.ad, 1, y.sira
    from (select distinct on (lower(btrim(g.anahtar))) btrim(g.anahtar) as ad, coalesce(g.sira, 0) as sira
            from stg.genini g
           where g.bolum in (-2206, -2251) and btrim(coalesce(g.anahtar, '')) <> ''
           order by lower(btrim(g.anahtar)), g.bolum, g.deger) y
   where not exists (select 1 from public.departman d where lower(btrim(d.ad)) = lower(y.ad));
  get diagnostics v_bolum = row_count;

  insert into public.personel_gorev (id, ad, departman_id, durum, sira)
  select (select coalesce(max(id), 0) from public.personel_gorev) + row_number() over (order by y.sira, y.ad),
         y.ad, 0, 1, y.sira
    from (select distinct on (lower(btrim(g.anahtar))) btrim(g.anahtar) as ad, coalesce(g.sira, 0) as sira
            from stg.genini g
           where g.bolum = -2205 and btrim(coalesce(g.anahtar, '')) <> ''
           order by lower(btrim(g.anahtar)), g.deger) y
   where not exists (select 1 from public.personel_gorev p where lower(btrim(p.ad)) = lower(y.ad));
  get diagnostics v_gorev = row_count;

  perform setval(pg_get_serial_sequence('public.departman', 'id'),
                 greatest((select coalesce(max(id), 1) from public.departman), 1));
  perform setval(pg_get_serial_sequence('public.personel_gorev', 'id'),
                 greatest((select coalesce(max(id), 1) from public.personel_gorev), 1));

  return jsonb_build_object('bolum_eklenen', v_bolum, 'gorev_eklenen', v_gorev);
end $$;

comment on function public.fn_aktar_kisi_listeleri() is
  '1182: Delphi GENINI -2206/-2251 (bolum) -> departman, -2205 (gorev) -> personel_gorev (eklemeli; aktar_ek.ps1).';
