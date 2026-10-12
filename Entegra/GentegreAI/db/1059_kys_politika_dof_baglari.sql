-- =============================================================================
--  1059  KURUMSAL KALİTE (KALİTE 2 / SADE) - POLİTİKA & KAPSAM, DÖF BAĞLARI
--
--  Kullanıcı (12.10.2026): "Kalite 2 ile devam et" - Ekranlar/Kalite2 sade seti.
--  1048-1054 dilimleri ile mockup arasındaki boşluklar:
--    POLİTİKA & KAPSAM (ISO 4.3 / 5.2): tek metin - referans anahtarları
--      kys.politika, kys.kapsam, kys.politika_onaylayan, kys.politika_tarih.
--      "Politika & Hedefler" ekranının (gösterge listesi) üst şeridinde
--      okunur / düzenlenir (/api/kys-politika, yetki kys.gosterge).
--    DÖF TERMİNİ: yeni DÖF'te termin boşsa bugün + kys.dof_termin_gun.
--      Kart varsayılanı sabit olduğu için (katalog bir kez derlenir) INSERT
--      tetiğiyle sunucuda verilir; kart alanı zorunlu değil.
--    DENETİM BULGULARI: v_kalite_denetim_bulgu - bulgu satırından "DÖF aç"
--      (kaynak_tur 1). Generic kart detay satırında düğme olmadığı için
--      bulgular ayrı (menüde görünmeyen) listede, denetim listesinden açılır.
--  Hedef dışı gösterge (7) ve toplantı kararı (6) "DÖF aç" yalnız liste
--  aksiyonudur, şema gerektirmez. İdempotent.
-- =============================================================================

begin;

-- --------------------------------------------------------- politika metni --
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, '', 'metin', 'firma', v.aciklama
  from (values
    ('kys.politika',            'Kalite politikası metni - ISO 9001 5.2 (1059).'),
    ('kys.kapsam',              'Kalite yönetim sistemi kapsamı ve uygulanmayan maddeler - ISO 9001 4.3 (1059).'),
    ('kys.politika_onaylayan',  'Politikayı onaylayan (ör. Genel Müdür) (1059).'),
    ('kys.politika_tarih',      'Politika onay / yayın tarihi, metin (1059).'))
    as v(anahtar, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

-- ------------------------------------------------------- DÖF termin tetiği --
create or replace function public.fn_kalite_dof_termin()
returns trigger language plpgsql as $$
begin
  if new.termin is null then
    new.termin := current_date + coalesce(
      (select nullif(r.deger, '')::integer from public.referans r
        where r.anahtar = 'kys.dof_termin_gun' and r.deger ~ '^[0-9]+$'), 30);
  end if;
  return new;
end $$;

drop trigger if exists trg_kalite_dof_termin on public.kalite_dof;
create trigger trg_kalite_dof_termin before insert on public.kalite_dof
  for each row execute function public.fn_kalite_dof_termin();

-- ---------------------------------------------------- denetim bulguları --
create or replace view public.v_kalite_denetim_bulgu as
select b.id, b.denetim_id, d.no as denetim_no, d.departman_id,
       coalesce(dp.ad, '')::varchar(100) as birim_adi,
       coalesce(d.gerceklesen, d.plan_tarih) as tarih,
       b.sinif, case b.sinif when 1 then 'Majör' when 2 then 'Minör' when 3 then 'Gözlem' else '' end::varchar(10) as sinif_adi,
       b.aciklama, b.madde,
       coalesce(f.no, '')::varchar(20) as dof_no,
       coalesce(f.durum_adi, '')::varchar(20) as dof_durum_adi,
       d.sube_id
  from public.kalite_denetim_bulgu b
  join public.kalite_denetim d on d.id = b.denetim_id
  left join public.departman dp on dp.id = d.departman_id
  left join lateral (
       select x.no, case x.durum when 5 then 'Kapandı' when 9 then 'İptal' else 'Açık' end as durum_adi
         from public.kalite_dof x
        where x.kaynak_tur = 1 and x.kaynak_id = b.id and x.durum <> 9
        order by x.id desc limit 1) f on true;

-- --------------------------------------------------------- yardım rehberi --
update public.ai_rehber_ekran
   set baslik = 'Politika & Hedefler', yol = 'Kalite › Politika & Hedefler', menu_ad = 'Politika & Hedefler',
       aciklama = 'Kalite politikası ve kapsam metni (üst şerit) + hedefler / göstergeler: hedef, son değer, hedefte / hedef dışı; '
                  || 'hedef dışı satırdan DÖF açılır. Müşteri memnuniyeti bir hedef satırıdır.'
 where kaynak = 'kys-gosterge' and menu_ad <> 'Politika & Hedefler';

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, modul, anahtar, aciklama, aksiyon_ekrani)
select 'kys-denetim-bulgu', '/kys-denetim-bulgu', 'Denetim Bulguları', 'Kalite › İç Denetimler › Bulgular', 'Kalite', 'Denetim Bulguları',
       'kys.denetim', 0, 'kys',
       'denetim bulgusu majör minör gözlem DÖF aç uygunsuzluk iç denetim',
       'İç denetim bulguları (denetim listesinden "Bulgular" ile açılır); bulgu satırından DÖF açılır, açılan DÖF no ve durumu görünür.',
       'kys-denetim-bulgu-liste'
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'kys-denetim-bulgu');

commit;
