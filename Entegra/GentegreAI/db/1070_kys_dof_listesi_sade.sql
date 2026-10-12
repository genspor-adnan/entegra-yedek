-- =============================================================================
--  1070  KURUMSAL KALİTE - DÖF LİSTESİ MOCKUP'A UYDU (Kalite2/dof_listesi.html)
--
--  Kullanıcı (12.10.2026): "DÖF listesini mockup gibi yap". Liste No · Açılış ·
--  Tür · Konu · Kaynak · Birim · Sorumlu · Termin · Faaliyet · Durum.
--    kaynak_metin : "İç denetim · DEN-2026-005", "Olay · OLY-2026-0039"
--    tamamlanma   : tamamlanan faaliyet yüzdesi (faaliyet yoksa boş) - liste
--                   ilerleme çizgisi olarak çizer (gridHucre yuzde)
--    durum_adi    : termini geçen açık DÖF "Gecikti" (eskiden "GECİKTİ · n gün")
--  Yeni kolonlar görünümün SONUNA eklenir. İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_dof as
select d.id, d.no, d.tur,
       case d.tur when 2 then 'Önleyici' else 'Düzeltici' end::varchar(20) as tur_adi,
       d.kaynak_tur,
       case d.kaynak_tur when 1 then 'İç denetim' when 2 then 'Olay bildirimi' when 3 then 'Şikâyet / görüş'
                         when 4 then 'Risk' when 5 then 'Dış denetim' when 6 then 'YGG / toplantı'
                         when 7 then 'Gösterge' when 8 then 'Tedarikçi' else 'Diğer' end::varchar(30) as kaynak_adi,
       d.kaynak_id, d.kaynak_no,
       left(d.tanim, 300)::varchar(300) as tanim,
       d.departman_id, coalesce(dp.ad, '')::varchar(100) as birim_adi,
       d.sorumlu_id, coalesce(public.fn_taraf_ad(ts.unvan, ts.ad, ts.soyad), '')::varchar(120) as sorumlu_adi,
       d.ekleme_tarihi::date as acilis, d.termin, d.dogrulama_tarihi, d.dogrulama_sonuc,
       d.durum,
       case when d.durum < 5 and d.termin < current_date then 'Gecikti'
            else case d.durum when 1 then 'Açık' when 3 then 'Faaliyette' when 4 then 'Doğrulamada'
                              when 5 then 'Kapandı' when 9 then 'İptal' else '?' end
       end::varchar(40) as durum_adi,
       case when d.durum < 5 then 1 else 0 end::smallint as acik,
       case when d.durum < 5 and d.termin < current_date then 1 else 0 end::smallint as vadesi_gecti,
       d.sube_id, d.ekleme_tarihi,
       (case d.kaynak_tur when 1 then 'İç denetim' when 2 then 'Olay' when 3 then 'Şikâyet'
                          when 4 then 'Risk' when 5 then 'Dış denetim' when 6 then 'YGG'
                          when 7 then 'Hedef' when 8 then 'Tedarikçi' else 'Diğer' end
        || coalesce(' · ' || nullif(d.kaynak_no, ''), ''))::varchar(80) as kaynak_metin,
       (select case when count(*) = 0 then null
                    else round(100.0 * count(*) filter (where f.durum = 2) / count(*)) end
          from public.kalite_dof_faaliyet f where f.dof_id = d.id)::integer as tamamlanma
  from public.kalite_dof d
  left join public.departman dp on dp.id = d.departman_id
  left join public.taraf ts on ts.id = d.sorumlu_id;

commit;
