-- =============================================================================
--  1180  DELPHI GENINI KOD LİSTELERİ AKTARIMI (fn_aktar_kod_listesi)
--
--  Kullanıcı (25.10.2026): "tanımlamadaki kategori, ilk temas gibi combo'ların içi boş, mssql'den gelmesi
--  gerekirdi". Tam kurulum (kur.ps1 + 013_goc_faz1) Delphi GENINI'nin ÇOK SATIRLI bölümlerini kod_liste /
--  kod_deger'e taşır; aktarım için kurulan veritabanı (kur.ps1 -SadeceSema -AktarimIcin, ör. UNIVERSE) bu
--  adımı atlıyordu - cari kartının Kategori / İlk Temas / Sektör / Sınıf / Bölge, stok kartının Marka / Grup
--  kutuları boş geliyordu (değerler aktarılıyor, karşılık geldiği liste yok).
--
--  fn_aktar_kod_listesi(): stg.genini'den (aktar_ek.ps1 GENINI'yi stg'ye çeker) EKLEYİCİ aktarım:
--    · Liste adı tam kurulumdakiyle aynı (eski_bolum -> kod; adı olmayan "liste_<bolum>").
--    · Liste YOKSA açılır; VARSA (kurulum tohumu, elle açılmış) DEĞERLERİNE DOKUNULMAZ - yalnız eksik
--      (deger, dil) satırları eklenir, eski_bolum boşsa yazılır. Kullanıcının web'de verdiği ad ezilmez.
--    · Tek satırlık bölümler (ayar) TAŞINMAZ - web'in Genel Ayarlar'ı kaynak; ayrı karar. İstisna: adı bilinen
--      liste (cari sektör vb.) tek değerli de olsa listedir.
--    · Delphi DIL -1 ile web dil 0 aynı sayılır (mükerrer değer açılmaz).
--    · Tekrar çalıştırılabilir (idempotent).
--  Dönüş: {liste_yeni, liste_doldurulan, deger_eklenen, deger_mevcut}.
-- =============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_aktar_kod_listesi()
returns jsonb
language plpgsql
as $$
declare
  v_yeni int := 0; v_dolan int := 0; v_eklenen int := 0; v_mevcut int := 0;
  r record; v_liste int; v_n int;
begin
  if to_regclass('stg.genini') is null then
    raise exception 'fn_aktar_kod_listesi: stg.genini yok - önce aktar_ek.ps1 (GENINI) ile çekin';
  end if;

  -- Tam kurulumdaki anlamlı adlar (035 / 043 / 044 / stok kartı göçleri ile aynı).
  create temp table _ad (bolum int primary key, kod varchar(60), ad varchar(100)) on commit drop;
  insert into _ad values
    (-2200, 'taraf.grup', 'Cari Grup'), (-2203, 'taraf.sinif', 'Cari Sinif'), (-2204, 'taraf.sektor', 'Cari Sektor'),
    (-2207, 'taraf.ilk_temas', 'Cari Ilk Temas'), (-2208, 'taraf.kategori', 'Cari Kategori'),
    (-2209, 'taraf.statu', 'Cari Statu'), (-2210, 'taraf.bolge', 'Cari Bolge'), (-2251, 'taraf.departman', 'Departman'),
    (-2701, 'stok.marka', 'Stok Marka'), (-2702, 'stok.ana_birim', 'Stok Ana Birim'), (-2703, 'stok.tipi', 'Stok Tipi'),
    (-2704, 'stok.grubu', 'Stok Grubu'), (-2706, 'stok.izleme', 'Stok Izleme');

  for r in
    select g.bolum, coalesce(a.kod, 'liste_' || abs(g.bolum)) as kod, coalesce(a.ad, 'Liste ' || g.bolum) as ad
      -- Çok satırlı bölümler + ADI BİLİNEN listeler tek satırlı da olsa (UNIVERSE'te Sektör tek değerli).
      from (select bolum from stg.genini group by bolum
             having count(*) > 1 or bolum in (select bolum from _ad)) g
      left join _ad a on a.bolum = g.bolum
  loop
    select id into v_liste from public.kod_liste where kod = r.kod;
    if v_liste is null then
      select id into v_liste from public.kod_liste where eski_bolum = r.bolum order by id limit 1;
    end if;
    if v_liste is null then
      insert into public.kod_liste (kod, ad, eski_bolum) values (r.kod, r.ad, r.bolum) returning id into v_liste;
      v_yeni := v_yeni + 1;
    else
      update public.kod_liste set eski_bolum = r.bolum where id = v_liste and eski_bolum is null;
      if not exists (select 1 from public.kod_deger where liste_id = v_liste) then v_dolan := v_dolan + 1; end if;
    end if;

    insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
    select v_liste, x.deger, x.dil, x.ad, x.sira, 1
      from (select coalesce(g.deger, 0)::int as deger, coalesce(g.dil, 0)::smallint as dil,
                   coalesce(btrim(coalesce(g.anahtar, '')), '') as ad, coalesce(g.sira, 0)::smallint as sira,
                   row_number() over (partition by coalesce(g.deger, 0), coalesce(g.dil, 0) order by coalesce(g.sira, 0)) as sn
              from stg.genini g where g.bolum = r.bolum) x
     where x.sn = 1
       -- Delphi DIL -1 (dilden bağımsız) ile web dil 0 AYNI listedir (web ikisini birden okur): biri varsa öteki eklenmez.
       and not exists (select 1 from public.kod_deger d
                        where d.liste_id = v_liste and d.deger = x.deger
                          and (d.dil = x.dil or (d.dil in (0, -1) and x.dil in (0, -1))));
    get diagnostics v_n = row_count;
    v_eklenen := v_eklenen + v_n;
    v_mevcut := v_mevcut + (select count(*) from (select 1 from stg.genini g where g.bolum = r.bolum
                                                    group by coalesce(g.deger, 0), coalesce(g.dil, 0)) y) - v_n;
    -- Tek satırlı adlı bölüm (sektör) aynı zamanda referans olarak da taşınmış olabilir - ona dokunulmaz.
  end loop;

  return jsonb_build_object('liste_yeni', v_yeni, 'liste_doldurulan', v_dolan,
                            'deger_eklenen', v_eklenen, 'deger_mevcut', v_mevcut);
end $$;

comment on function public.fn_aktar_kod_listesi() is
  '1180: Delphi GENINI cok satirli bolumleri -> kod_liste / kod_deger (eklemeli, idempotent; aktar_ek.ps1).';
