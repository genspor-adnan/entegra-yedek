-- =============================================================================
--  1185  DELPHI e-BELGE AYARLARI AKTARIMI (REHBERALIAS -> taraf; fn_aktar_ebelge_alias)
--
--  Kullanıcı (25.10.2026): "e-belge ayarları (alias falan) migrate olmamış". Delphi carinin e-Belge
--  ayarı REHBERALIAS'ta (ebelge-akis.md §1.2): BELGETURU 151 e-Fatura (GİB alias), 150 e-Arşiv (e-posta;
--  EPOSTA 0 = e-posta gitmesin, Update_SQL_214), 141 e-İrsaliye (alias), 140 kâğıt irsaliye.
--  Web'de tek satır: taraf.efatura / alias_eposta / efatura_sorgu_tarihi / earsiv_eposta_yok (1184) /
--  eirsaliye / alias_irsaliye. Çekirdek cari aktarımı bunları taşımıyordu.
--
--  fn_aktar_ebelge_alias(): stg.rehberalias'tan (aktar_ek.ps1 çeker), yalnız AKTİF satırlar; aynı cari +
--  tür için varsayılan, sonra en son kontrol edilen. EKLEYİCİ - web'de dolu değer EZİLMEZ (web GİB
--  sorgusu daha yeni bilgidir):
--    · 151 -> efatura = 1, alias_eposta (boşsa), efatura_sorgu_tarihi (boşsa; Delphi saati yerel -> İstanbul).
--    · 150 -> e-Fatura olmayan caride alias_eposta (boşsa) = e-posta; EPOSTA = 0 ise earsiv_eposta_yok = 1.
--    · 141 -> eirsaliye = 1, alias_irsaliye (boşsa).   140 taşınmaz (kâğıt irsaliye, ayar yok).
--  Tekrar çalıştırılabilir. Dönüş: {efatura, earsiv, eirsaliye, eslesmeyen}.
-- =============================================================================
\set ON_ERROR_STOP on

-- Kaynak stg tablosu (aktar_ek.ps1 / goc_al.ps1 doldurur; tablo burada tanımlı olmalı).
create schema if not exists stg;
create table if not exists stg.rehberalias (
    id integer, rehberid integer, belgeturu smallint, alias varchar(300), varsayilan smallint, aktif smallint,
    ilkkayittarihi timestamp, sonkontroltarihi timestamp, pasiftarihi timestamp, eposta smallint);

create or replace function public.fn_aktar_ebelge_alias()
returns jsonb
language plpgsql
as $$
declare
  v_ef int := 0; v_ea int := 0; v_ei int := 0; v_yok int := 0;
begin
  if to_regclass('stg.rehberalias') is null then
    raise exception 'fn_aktar_ebelge_alias: stg.rehberalias yok - önce aktar_ek.ps1 (REHBERALIAS) ile çekin';
  end if;

  create temp table _al on commit drop as
  select distinct on (r.rehberid, r.belgeturu)
         public.fn_aktarim_kisi_id(r.rehberid) as taraf_id, r.belgeturu::int as tur,
         btrim(coalesce(r.alias, '')) as alias, coalesce(r.eposta::int, 1) as eposta,
         (r.sonkontroltarihi at time zone 'Europe/Istanbul') as son
    from stg.rehberalias r
   where coalesce(r.aktif::int, 0) = 1 and r.belgeturu in (141, 150, 151)
   order by r.rehberid, r.belgeturu, coalesce(r.varsayilan::int, 0) desc, r.sonkontroltarihi desc nulls last, r.id desc;

  select count(*) into v_yok from _al a
   where a.taraf_id is null or not exists (select 1 from public.taraf t where t.id = a.taraf_id);
  delete from _al a where a.taraf_id is null or not exists (select 1 from public.taraf t where t.id = a.taraf_id);

  update public.taraf t
     set efatura = 1,
         alias_eposta = case when coalesce(btrim(t.alias_eposta), '') = '' and a.alias <> '' then a.alias else t.alias_eposta end,
         efatura_sorgu_tarihi = coalesce(t.efatura_sorgu_tarihi, a.son)
    from _al a
   where a.tur = 151 and a.taraf_id = t.id
     and (coalesce(t.efatura, 0) <> 1 or coalesce(btrim(t.alias_eposta), '') = '' or t.efatura_sorgu_tarihi is null);
  get diagnostics v_ef = row_count;

  update public.taraf t
     set alias_eposta = case when coalesce(btrim(t.alias_eposta), '') = '' and a.alias <> '' then a.alias else t.alias_eposta end,
         earsiv_eposta_yok = case when a.eposta = 0 then 1 else t.earsiv_eposta_yok end
    from _al a
   where a.tur = 150 and a.taraf_id = t.id and coalesce(t.efatura, 0) <> 1
     and ((coalesce(btrim(t.alias_eposta), '') = '' and a.alias <> '') or (a.eposta = 0 and t.earsiv_eposta_yok <> 1));
  get diagnostics v_ea = row_count;

  update public.taraf t
     set eirsaliye = 1,
         alias_irsaliye = case when coalesce(btrim(t.alias_irsaliye), '') = '' and a.alias <> '' then a.alias else t.alias_irsaliye end
    from _al a
   where a.tur = 141 and a.taraf_id = t.id
     and (coalesce(t.eirsaliye, 0) <> 1 or coalesce(btrim(t.alias_irsaliye), '') = '');
  get diagnostics v_ei = row_count;

  return jsonb_build_object('efatura', v_ef, 'earsiv', v_ea, 'eirsaliye', v_ei, 'eslesmeyen', v_yok);
end $$;

comment on function public.fn_aktar_ebelge_alias() is
  '1185: Delphi REHBERALIAS (151/150/141) -> taraf e-Belge ayarlari (eklemeli; aktar_ek.ps1).';
