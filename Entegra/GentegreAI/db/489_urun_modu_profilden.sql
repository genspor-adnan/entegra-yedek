-- =====================================================================
--  489_urun_modu_profilden.sql
--  Urun modu (HBYS/ERP) SUBENIN PROFILINDEN okunur.
--
--  Sorun (kullanici: "genotipai hbys moduna gecmiyor"): Firma Bilgileri >
--  Kurum Profili ekrani modu `kurum_profil.urun_modu`ya yazar, ama giris
--  yaniti, /ben, rol yetkileri ve AI Rehber `referans` tablosundaki
--  `genel.urun_modu` anahtarini okuyordu. Ekrandan HBYS secilse bile bu
--  anahtar 1 (ERP) kaldigi icin uygulama ERP gibi aciliyordu - ekranda
--  "HBYS" yazip menunun ERP olmasi.
--
--  Cozum: TEK KAYNAK profil. `fn_urun_modu(sube)` once subenin satirini,
--  yoksa kurum genelini (sube 0), o da yoksa referans anahtarini okur -
--  boylece profili hic doldurmamis kurulumlar da eski davranisi surdurur.
--  Okuyucularin hepsi (API) bu fonksiyona gecer.
-- =====================================================================

create or replace function public.fn_urun_modu(p_sube integer default 0)
returns smallint
language sql
stable
as $$
    select coalesce(
             (select p.urun_modu from public.fn_kurum_profil(p_sube) p),
             (select nullif(r.deger, '')::smallint from public.referans r
               where r.anahtar = 'genel.urun_modu'),
             1::smallint);
$$;

comment on function public.fn_urun_modu(integer) is
  'Urun modu (489): 1 ERP (Gentegre AI), 2 HBYS (GenoTIP AI), 3 ikisi. '
  'Once subenin kurum_profil satiri, yoksa kurum geneli (0), yoksa '
  'referans genel.urun_modu.';

-- Eski anahtar da tutarli kalsin: raporlar/eski sorgular hala okuyor ve
-- iki kaynagin farkli deger soylemesi bu hatanin ta kendisiydi. Yalniz
-- kurum geneli (sube 0) profili VARSA ve farkliysa dokunulur.
do $$
declare v_mod smallint;
begin
    select urun_modu into v_mod from public.kurum_profil where sube_id = 0;
    if v_mod is null then
        raise notice '489: kurum geneli profil yok, referans dokunulmadi.';
        return;
    end if;

    if exists (select 1 from public.referans
                where anahtar = 'genel.urun_modu' and deger is distinct from v_mod::text) then
        update public.referans set deger = v_mod::text
         where anahtar = 'genel.urun_modu';
        raise notice '489: referans genel.urun_modu -> % (profilden).', v_mod;
    elsif not exists (select 1 from public.referans where anahtar = 'genel.urun_modu') then
        insert into public.referans (anahtar, deger, tip, aciklama)
        values ('genel.urun_modu', v_mod::text, 'sayi', 'Urun modu: 1 ERP, 2 HBYS, 3 ikisi');
        raise notice '489: referans genel.urun_modu eklendi (%).', v_mod;
    end if;
end $$;
