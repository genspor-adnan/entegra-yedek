-- ============================================================================
--  Gentegre AI — TEKNİK SERVİS MODÜL KAPISI
--  774_teknik_servis_modulu.sql
--
--  773 tabloları, uçları ve yetkileri getirdi; ekranlar `modul: 'servis'`
--  kapısına bağlandı ama **`servis` diye bir modül tanımı yoktu**. Sonuç:
--  liste rotaları hiç kaydolmuyor, menüde grup görünmüyor ve adrese elle
--  gidildiğinde başka bir ekrana düşülüyordu - sessizce.
--
--  Aynı şey 17.09.2026'da sunucuda da yaşandı: "Acil" menüde yoktu, kod ve
--  yetki doğruydu, eksik olan `kurum_profil.moduller`de bayraktı. Modül
--  kapısı bilerek böyle: kurumun kullanmadığı modül menüyü şişirmesin. Ama
--  kapının ARDINDA bir tanım yoksa kimse onu açamaz.
--
--  ============ HANGİ KURUM TİPİNDE VARSAYILAN AÇIK ====================
--  Hiçbirinde. Teknik servis, cihaz satıp servisini veren ya da biyomedikal
--  ekibi olan kurumun işidir; muayenehanede yoktur. Varsayılan açık gelseydi
--  her kurulumda kimsenin bakmadığı altı liste menüde dururdu.
--
--  `kurum_tipi_modul`e satır yazılmıyor: kurum Kurum Profili ekranından
--  kendisi açar (Acil'de olduğu gibi).
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.kurum_modul (kod, ad, sira)
select 'servis', 'Teknik Servis', 96
 where not exists (select 1 from public.kurum_modul where kod = 'servis');

comment on table public.kurum_modul is
  'Kurum profilinde acilip kapanabilen modul katalogu. Ekranlarin modul '
  'kapisi buradaki KOD ile eslesir - tanim yoksa kimse modulu acamaz (774).';


-- ---------------------------------------------------------------------- 2
--  ÇOK DEĞERLİ DURUM KOLONLARI METİN DE DÖNER
--
--  Ekranın ortak kuralı: `durum` adlı kolon 0/1 taşıyorsa her listede AYNI
--  görünsün diye yeşil "Aktif" / kırmızı "Pasif" rozetine çevrilir. Servis
--  çağrısının durumu ise 0-8 arası ÇOK DEĞERLİ (açık · atandı · yolda ·
--  yerinde · parça bekliyor · çözüldü · iptal) - kural onu da yakalıyor ve
--  **açık bir çağrı ekranda "Pasif" görünüyordu**.
--
--  Aynı tuzağa 301'de başvuru listesi düşmüştü (orada kolon listeden
--  çıkarılmıştı). Çözüm ekranı değiştirmek değil, konvansiyona uymak: çok
--  değerli durum SUNUCUDA metne çevrilir ve rozet olarak çizilir; sayısal
--  kolon süzgeç/çip için görünmez olarak kalır.
drop view if exists public.v_servis_cagri;
create or replace view public.v_servis_cagri as
select g.id, g.cagri_no, g.sube_id, g.taraf_id, t.unvan as taraf_adi,
       g.taraf_cihaz_id,
       coalesce(nullif(g.cihaz_metni, ''),
                trim(both ' ' from coalesce(c.ad, '') || ' ' ||
                     coalesce(c.marka, '') || ' ' || coalesce(c.model, ''))) as cihaz,
       c.seri_no, g.sozlesme_id, g.kapsam_tur,
       case g.kapsam_tur when 1 then 'Ücretli' when 2 then 'Sözleşme'
                         when 3 then 'Üretici garantisi'
                         else 'Kendi garantimiz' end        as kapsam_adi,
       g.oncelik, g.bildiren, g.telefon, g.acilis, g.sla_bitis, g.ilk_yanit,
       g.kapanis, g.durum, g.sikayet, g.sonuc,
       coalesce(c.bolge, '') as bolge,
       -- SLA KALAN DAKİKA: eksi değer aşımdır. Kapanmış çağrıda null - geçmiş
       --   bir taahhüdü "gecikiyor" diye göstermek listeyi kirletirdi.
       case when g.durum >= 5 or g.sla_bitis is null then null
            else floor(extract(epoch from (g.sla_bitis - now())) / 60)::int end
                                                            as sla_kalan_dk,
       (select count(*) from public.demirbas_is_emri e where e.cagri_id = g.id)
                                                            as is_emri_sayisi,
       (select count(*) from public.servis_ziyaret z
          join public.demirbas_is_emri e2 on e2.id = z.is_emri_id
         where e2.cagri_id = g.id)                          as ziyaret_sayisi,
       case g.durum when 0 then 'Açık' when 1 then 'Atandı'
                    when 2 then 'Yolda' when 3 then 'Yerinde'
                    when 4 then 'Parça bekliyor' when 5 then 'Çözüldü'
                    when 8 then 'İptal' else '' end as durum_adi
  from public.servis_cagri g
  join public.taraf t on t.id = g.taraf_id
  left join public.taraf_cihaz c on c.id = g.taraf_cihaz_id;

drop view if exists public.v_servis_is_emri;
create or replace view public.v_servis_is_emri as
select e.id, e.is_emri_no, e.sube_id, e.sahiplik,
       case e.sahiplik when 2 then 'Dış iş' else 'İç iş' end as sahiplik_adi,
       e.cagri_id, g.cagri_no,
       e.demirbas_id, e.musteri_taraf_id,
       coalesce(mt.unvan, d.ad, '')                          as sahip_adi,
       e.taraf_cihaz_id,
       coalesce(nullif(tc.ad, ''), d.ad, '')                 as cihaz,
       e.tur, e.oncelik, e.durum, e.kapsam_tur,
       case e.kapsam_tur when 1 then 'Ücretli' when 2 then 'Sözleşme'
                         when 3 then 'Üretici garantisi'
                         else 'Kendi garantimiz' end         as kapsam_adi,
       e.bildirim_zamani, e.ilk_mudahale, e.tamamlanma, e.planlanan,
       e.ariza_metni, e.yapilan_is,
       e.iscilik_tutar, e.parca_tutar, e.diger_tutar, e.toplam_tutar,
       e.teklif_no, e.belge_id, e.onay_durum, e.onayli_tutar,
       (select count(*) from public.servis_ziyaret z where z.is_emri_id = e.id)
                                                             as ziyaret_sayisi,
       (select count(*) from public.servis_emanet m
         where m.is_emri_id = e.id and m.durum = 1)          as acik_emanet,
       case e.durum when 0 then 'Açık' when 1 then 'Planlandı'
                    when 2 then 'Sürüyor' when 3 then 'Parça bekliyor'
                    when 4 then 'Dış serviste' when 5 then 'Tamamlandı'
                    when 8 then 'İptal' else '' end as durum_adi
  from public.demirbas_is_emri e
  left join public.servis_cagri g  on g.id  = e.cagri_id
  left join public.taraf mt        on mt.id = e.musteri_taraf_id
  left join public.taraf_cihaz tc  on tc.id = e.taraf_cihaz_id
  left join public.demirbas d      on d.id  = e.demirbas_id;

drop view if exists public.v_servis_emanet;
create or replace view public.v_servis_emanet as
select m.id, m.emanet_no, m.sube_id, m.is_emri_id, e.is_emri_no,
       m.taraf_id, coalesce(t.unvan, '') as taraf_adi,
       m.demirbas_id, coalesce(nullif(m.cihaz_metni, ''), d.ad, '') as cihaz,
       m.veris, m.iade, m.durum, m.aciklama,
       case when m.durum = 1
            then (current_date - m.veris::date) else null end as gun,
       case m.durum when 1 then 'Dışarıda' when 2 then 'İade alındı'
                    else '' end as durum_adi
  from public.servis_emanet m
  left join public.demirbas_is_emri e on e.id = m.is_emri_id
  left join public.taraf t on t.id = m.taraf_id
  left join public.demirbas d on d.id = m.demirbas_id;

do $$
declare v_acik int;
begin
    select count(*) into v_acik from public.kurum_profil
     where coalesce((moduller ->> 'servis')::int, 0) = 1;
    raise notice '774 tamam: servis modulu tanimlandi. Su an acik sube: % '
                 '(Kurum Profili ekranindan acilir).', v_acik;
end $$;
