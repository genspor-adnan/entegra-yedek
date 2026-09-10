-- =====================================================================
--  512_panel_tip_merkezi_tam.sql
--  Tıp merkezi paneli MOCKUP'LA BİREBİR: 6 kutu + 6 blok.
--
--  Kullanıcı: "dashboard_tip_merkezi.html baz al, başlıkta 6 kutu, altında
--  6 grid birebir aynı görünüm olsun".
--
--  508'de dört kutu ve tek blok vardı. Mockup'taki düzen:
--    KUTULAR : Bugünkü randevu · Açık başvuru · Sonuç bekleyen ·
--              Bugün tahsilat · Açık tahsilat · Açık belge
--    BLOKLAR : Poliklinik akışı · Kurum & sözleşme · Yardımcı birimler ·
--              e-Nabız/bildirim · Hekim üretimi · Dikkat gerektiren
--
--  "AÇIK TAHSİLAT" ve "AÇIK BELGE" başvuru kartındaki şeritle AYNI hesaptır
--  (kalan kova toplamı ve belgeye dönüşmemiş tutar): iki yerde farklı sayı
--  çıkarsa biri yanlıştır, o yüzden ikisi de `v_belge_acik_satir` ve dönüşüm
--  zincirinden okunur - panel kendi formülünü uydurmaz.
-- =====================================================================

create or replace function public.fn_panel_profil(p_sube integer)
returns jsonb language plpgsql stable as $$
declare
    v_tip     text;
    v_baslik  text;
    v_kutular jsonb := '[]'::jsonb;
    v_bloklar jsonb := '[]'::jsonb;
begin
    select kurum_tipi into v_tip
      from public.kurum_profil
     where sube_id in (p_sube, 0)
     order by (sube_id = p_sube) desc
     limit 1;
    v_tip := coalesce(v_tip, '');

    -- ------------------------------------------------------ LABORATUVAR --
    if v_tip in ('lab', 'goruntuleme_lab') then
        v_baslik := 'Laboratuvar';
        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object('sira','1','kod','numune','baslik','Kabul bekleyen numune',
                'deger',(select count(*) from public.lab_numune where durum in (1,2)),
                'alt','etiketlendi / alındı','vurgu','normal','rota','/lab-numune') k
            union all select jsonb_build_object('sira','2','kod','cihazda','baslik','Cihazda çalışılıyor',
                'deger',(select count(*) from public.lab_numune where durum = 4),
                'alt','sonuç bekleniyor','vurgu','normal','rota','/lab-numune')
            union all select jsonb_build_object('sira','3','kod','onay','baslik','Onay bekleyen sonuç',
                'deger',(select count(*) from public.lab_sonuc where durum not in (3,4)),
                'alt','teknik onay / onay','vurgu','uyari','rota','/lab-sonuc')
            union all select jsonb_build_object('sira','4','kod','panik','baslik','Teyit bekleyen panik değer',
                'deger',(select count(*) from public.lab_panik_bildirim where teyit_zamani is null),
                'alt','bildirim teyidi yok','vurgu','tehlike','rota','/lab-sonuc')
        ) t(k);

        select jsonb_build_array(jsonb_build_object(
            'kod','bolum','baslik','Bölüm kuyruğu','ipucu','çalışılmayı bekleyen tetkik',
            'kolonlar', jsonb_build_array('Bölüm','Bekleyen'),
            'bicimler', jsonb_build_array('metin','sayi'),
            'satirlar', coalesce((
                select jsonb_agg(jsonb_build_array(b.ad, s.adet::text) order by s.adet desc)
                  from (select t.bolum, count(*) adet
                          from public.lab_istem_satir i
                          join public.lab_tetkik t on t.id = i.tetkik_id
                         where i.durum < 3 group by t.bolum) s
                  left join lateral (
                        select coalesce(d.ad, 'Bölüm ' || s.bolum) ad
                          from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                         where l.kod = 'lab.bolum' and d.deger = s.bolum) b on true
            ), '[]'::jsonb))) into v_bloklar;

    -- ------------------------------------------------------ GÖRÜNTÜLEME --
    elsif v_tip = 'goruntuleme' then
        v_baslik := 'Görüntüleme Merkezi';
        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object('sira','1','kod','istem','baslik','Bekleyen istem',
                'deger',(select count(*) from public.radyoloji_istem where durum = 1),
                'alt','çekim bekliyor','vurgu','normal','rota','/radyoloji-istem') k
            union all select jsonb_build_object('sira','2','kod','cekildi','baslik','Çekildi',
                'deger',(select count(*) from public.radyoloji_istem where durum = 2),
                'alt','rapor yazılacak','vurgu','normal','rota','/radyoloji-istem')
            union all select jsonb_build_object('sira','3','kod','rapor','baslik','Rapor bekleyen',
                'deger',(select count(*) from public.radyoloji_istem where durum in (2,3,4)),
                'alt','onaylanmamış','vurgu','uyari','rota','/radyoloji-rapor')
            union all select jsonb_build_object('sira','4','kod','bugun','baslik','Bugün onaylanan',
                'deger',(select count(*) from public.radyoloji_istem
                          where durum >= 5 and degistirme_tarihi::date = current_date),
                'alt','tamamlanan rapor','vurgu','olumlu','rota','/radyoloji-rapor')
        ) t(k);

        select jsonb_build_array(jsonb_build_object(
            'kod','modalite','baslik','Modalite kuyruğu','ipucu','bekleyen istem sayısı',
            'kolonlar', jsonb_build_array('Modalite','Bekleyen'),
            'bicimler', jsonb_build_array('metin','sayi'),
            'satirlar', coalesce((
                select jsonb_agg(jsonb_build_array(coalesce(d.ad,'Tanımsız'), s.adet::text)
                                 order by s.adet desc)
                  from (select i.modalite, count(*) adet from public.radyoloji_istem i
                         where i.durum in (1,2,3,4) group by i.modalite) s
                  left join public.kod_liste l on l.kod = 'rad.modalite'
                  left join public.kod_deger d on d.liste_id = l.id and d.deger = s.modalite
            ), '[]'::jsonb))) into v_bloklar;

    -- ------------------------------------------------------ TIP MERKEZİ --
    elsif v_tip in ('tip_merkezi','hastane','muayenehane','dal_goz','dal_ftr','dis') then
        v_baslik := 'Klinik';

        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object('sira','1','kod','randevu','baslik','Bugünkü randevu',
                'deger',(select count(*) from public.randevu
                          where baslangic::date = current_date and durum <> 4),
                'alt',(select 'geldi ' || count(*) filter (where durum = 2)
                            || ' · gelmedi ' || count(*) filter (where durum = 3)
                         from public.randevu
                        where baslangic::date = current_date and durum <> 4),
                'vurgu','normal','rota','/randevu') k
            union all select jsonb_build_object('sira','2','kod','basvuru','baslik','Açık başvuru',
                'deger',(select count(*) from public.belge b
                          join public.belge_basvuru bb on bb.id = b.id
                         where b.durum <> 2 and coalesce(b.kapanma_durum, 0) <> 2),
                'alt',(select 'bugün ' || count(*) from public.belge b
                        join public.belge_basvuru bb on bb.id = b.id
                       where b.belge_tarihi::date = current_date and b.durum <> 2),
                'vurgu','normal','rota','/basvuru')
            union all select jsonb_build_object('sira','3','kod','sonuc','baslik','Sonuç bekleyen',
                'deger',(select count(*) from public.lab_istem_satir where durum < 3)
                      + (select count(*) from public.radyoloji_istem where durum in (1,2,3,4)),
                'alt',(select 'lab ' || (select count(*) from public.lab_istem_satir where durum < 3)
                            || ' · radyoloji ' || (select count(*) from public.radyoloji_istem
                                                    where durum in (1,2,3,4))),
                'vurgu','uyari','rota','/lab-istem')
            union all select jsonb_build_object('sira','4','kod','tahsilat','baslik','Bugün tahsilat',
                'deger',(select coalesce(sum(k2.tutar),0) from public.kasa_islem k2
                          where k2.islem_tarihi::date = current_date and k2.durum <> 2
                            and k2.tur in (21,22,25)),
                'bicim','para',
                'alt',(select 'nakit ' || count(*) filter (where tur = 21)
                            || ' · pos ' || count(*) filter (where tur = 25)
                            || ' · havale ' || count(*) filter (where tur = 22)
                         from public.kasa_islem
                        where islem_tarihi::date = current_date and durum <> 2
                          and tur in (21,22,25)),
                'vurgu','olumlu','rota','/kasa-islem')
            -- ACIK TAHSILAT: hasta kovalarinin (1 provizyon · 4 ek katki)
            --   kalani - basvuru kartindaki "Açık Tahsilat" seridiyle AYNI.
            union all select jsonb_build_object('sira','5','kod','acikTahsilat','baslik','Açık tahsilat',
                'deger',(select coalesce(sum(coalesce(a.hasta_provizyon_kalan,0)
                                           + coalesce(a.hasta_ek_katki_kalan,0)),0)
                           from public.v_belge_acik_satir a),
                'bicim','para',
                'alt',(select coalesce(count(distinct a.belge_id),0) || ' başvuru'
                         from public.v_belge_acik_satir a
                        where coalesce(a.hasta_provizyon_kalan,0)
                            + coalesce(a.hasta_ek_katki_kalan,0) > 0),
                'vurgu','tehlike','rota','/basvuru')
            -- ACIK BELGE: ucretlendirilmis ama BELGEYE DONMEMIS tutar.
            --   Donusen tutar hedef satirin YAZILAN brutudur (BelgeDeposu ile
            --   ayni ifade) - matrahtan yeniden hesaplamak 500 TL'yi 500,01
            --   gosteriyordu.
            union all select jsonb_build_object('sira','6','kod','acikBelge','baslik','Açık belge',
                'deger',(select coalesce(sum(greatest(x.tutar - x.donusen, 0)),0) from (
                            select b.id,
                                   coalesce(b.genel_toplam,0) tutar,
                                   coalesce((select sum(case when coalesce(hs.tutar_kdvli,0) > 0
                                                             then hs.tutar_kdvli
                                                             else round(hs.tutar * (1+coalesce(hs.kdv,0)/100.0),2) end)
                                               from public.belge_satir ks
                                               join public.belge_satir hs
                                                 on hs.kaynak_tur = 30 and hs.kaynak_id = ks.id
                                               join public.belge hb on hb.id = hs.belge_id and hb.durum <> 2
                                              where ks.belge_id = b.id), 0) donusen
                              from public.belge b
                              join public.belge_basvuru bb on bb.id = b.id
                             where b.durum <> 2) x),
                'bicim','para',
                'alt',(select coalesce(count(*),0) || ' başvuru' from (
                            select b.id from public.belge b
                              join public.belge_basvuru bb on bb.id = b.id
                             where b.durum <> 2
                               and coalesce(b.genel_toplam,0) >
                                   coalesce((select sum(case when coalesce(hs.tutar_kdvli,0) > 0
                                                             then hs.tutar_kdvli
                                                             else round(hs.tutar * (1+coalesce(hs.kdv,0)/100.0),2) end)
                                               from public.belge_satir ks
                                               join public.belge_satir hs
                                                 on hs.kaynak_tur = 30 and hs.kaynak_id = ks.id
                                               join public.belge hb on hb.id = hs.belge_id and hb.durum <> 2
                                              where ks.belge_id = b.id), 0)) y),
                'vurgu','uyari','rota','/basvuru')
        ) t(k);

        v_bloklar := jsonb_build_array(
          -- 1 · POLİKLİNİK AKIŞI
          jsonb_build_object('kod','poliklinik','baslik','Poliklinik akışı','ipucu','bugün',
            'kolonlar', jsonb_build_array('Bölüm','Randevu','Bekleyen'),
            'bicimler', jsonb_build_array('metin','sayi','sayi'),
            'satirlar', coalesce((
              select jsonb_agg(jsonb_build_array(x.ad, x.randevu::text, x.bekleyen::text)
                               order by x.randevu desc)
                from (select coalesce(d.ad,'Bölümsüz') ad,
                             count(*) randevu,
                             count(*) filter (where r.durum = 1) bekleyen
                        from public.randevu r
                        -- Randevu bolumu `bolum` (departman id) kolonunda.
                        left join public.departman d on d.id = r.bolum
                       where r.baslangic::date = current_date and r.durum <> 4
                       group by 1 limit 8) x), '[]'::jsonb)),

          -- 2 · KURUM & SÖZLEŞME
          jsonb_build_object('kod','kurum','baslik','Kurum & sözleşme','ipucu','açık tahakkuk',
            'kolonlar', jsonb_build_array('Kurum','Tip','Başvuru','Açık'),
            'bicimler', jsonb_build_array('metin','metin','sayi','para'),
            'satirlar', coalesce((
              select jsonb_agg(jsonb_build_array(x.unvan, x.tip, x.adet::text, round(x.acik,2)::text)
                               order by x.acik desc)
                from (select t.unvan,
                             case tk.tur when 1 then 'Özel' when 2 then 'ÖSS'
                                         when 3 then 'SGK'  when 4 then 'Kurumu Öder'
                                         else '—' end tip,
                             count(*) adet,
                             sum(coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0)) acik
                        from public.v_belge_acik_satir a
                        join public.taraf t on t.id = a.taraf_id
                        left join public.taraf_kurum tk on tk.id = t.id
                       where coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0) > 0
                       group by t.unvan, tk.tur limit 8) x), '[]'::jsonb)),

          -- 3 · YARDIMCI BİRİMLER
          jsonb_build_object('kod','birim','baslik','Yardımcı birimler','ipucu','kuyruk',
            'kolonlar', jsonb_build_array('Birim','Bekleyen','Bugün biten'),
            'bicimler', jsonb_build_array('metin','sayi','sayi'),
            'satirlar', jsonb_build_array(
              jsonb_build_array('Laboratuvar',
                (select count(*) from public.lab_istem_satir where durum < 3)::text,
                (select count(*) from public.lab_sonuc
                  where durum = 3 and degistirme_tarihi::date = current_date)::text),
              jsonb_build_array('Radyoloji',
                (select count(*) from public.radyoloji_istem where durum in (1,2,3,4))::text,
                (select count(*) from public.radyoloji_istem
                  where durum >= 5 and degistirme_tarihi::date = current_date)::text),
              jsonb_build_array('Mikrobiyoloji / kültür',
                (select count(*) from public.lab_kultur where durum < 3)::text,
                (select count(*) from public.lab_kultur
                  where durum >= 3 and degistirme_tarihi::date = current_date)::text))),

          -- 4 · e-NABIZ / BİLDİRİM
          jsonb_build_object('kod','enabiz','baslik','e-Nabız / bildirim','ipucu','son 24 saat',
            'kolonlar', jsonb_build_array('Paket','Üretilen','Gönderilen'),
            'bicimler', jsonb_build_array('metin','sayi','sayi'),
            'satirlar', coalesce((
              -- Gruplama ALT SORGUDA: jsonb_agg icinde count() ic ice
              --   toplama olur (42803).
              select jsonb_agg(jsonb_build_array(x.ad, x.uretilen::text, x.gonderilen::text)
                               order by x.uretilen desc)
                from (select coalesce(pt.ad, 'Paket ' || p.paket_turu_id) ad,
                             count(*) uretilen,
                             count(*) filter (where p.durum >= 3) gonderilen
                        from public.enabiz_paket p
                        left join public.enabiz_paket_turu pt on pt.id = p.paket_turu_id
                       where p.ekleme_tarihi >= now() - interval '24 hours'
                       group by 1 limit 8) x), '[]'::jsonb)),

          -- 5 · HEKİM ÜRETİMİ
          jsonb_build_object('kod','hekim','baslik','Hekim üretimi','ipucu','bugün',
            'kolonlar', jsonb_build_array('Hekim','Hasta','Ciro'),
            'bicimler', jsonb_build_array('metin','sayi','para'),
            'satirlar', coalesce((
              select jsonb_agg(jsonb_build_array(x.ad, x.hasta::text, round(x.ciro,2)::text)
                               order by x.ciro desc)
                from (select coalesce(t.unvan,'Atanmamış') ad,
                             count(*) hasta,
                             sum(coalesce(b.genel_toplam,0)) ciro
                        from public.belge b
                        join public.belge_basvuru bb on bb.id = b.id
                        left join public.taraf t on t.id = bb.personel_id
                       where b.belge_tarihi::date = current_date and b.durum <> 2
                       group by 1 limit 8) x), '[]'::jsonb)),

          -- 6 · DİKKAT GEREKTİREN
          jsonb_build_object('kod','dikkat','baslik','Dikkat gerektiren','ipucu','iş listesi',
            'kolonlar', jsonb_build_array('Konu','Adet','Etki'),
            'bicimler', jsonb_build_array('metin','sayi','metin'),
            'satirlar', jsonb_build_array(
              jsonb_build_array('Provizyon alınmamış başvuru',
                (select count(*) from public.belge b
                   join public.belge_basvuru bb on bb.id = b.id
                   left join public.belge_provizyon bp on bp.id = b.id
                  where b.durum <> 2 and bb.odeyen_kurum_id is not null
                    and bp.id is null)::text,
                'Tahakkuk edilemez'),
              jsonb_build_array('Onaylanmamış tetkik sonucu',
                (select count(*) from public.lab_sonuc where durum not in (3,4))::text,
                'Hasta bekliyor'),
              jsonb_build_array('Faturası kesilmemiş kurum icmali',
                (select count(*) from public.kurum_icmal where durum < 2)::text,
                'Dönem kapanmaz'),
              jsonb_build_array('e-Nabız hatalı paket',
                (select count(*) from public.enabiz_paket where durum = 9)::text,
                'Bildirim eksik')))
        );
    else
        v_baslik := '';
    end if;

    return jsonb_build_object(
        'kurumTipi', v_tip,
        'baslik',    coalesce(v_baslik, ''),
        'kutular',   coalesce(v_kutular, '[]'::jsonb),
        'bloklar',   coalesce(v_bloklar, '[]'::jsonb));
end $$;
