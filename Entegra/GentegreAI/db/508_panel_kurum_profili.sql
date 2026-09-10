-- =====================================================================
--  508_panel_kurum_profili.sql
--  ANA SAYFA KURUM PROFİLİNE GÖRE: lab · görüntüleme · tıp merkezi …
--
--  Kullanıcı: "kurum profiline göre dashboard gösteren sistemi yap (yani lab
--  da, görüntüleme merkezinde veya tıp merkezinde ayrı dashboardlar olsun)".
--  Mockup'lar: Ekranlar/Dashboard/dashboard_{lab,goruntuleme,tip_merkezi}.html
--
--  Panel İÇERİĞİ SUNUCUDAN gelir (katalog deseni): hangi kutu, hangi blok,
--  hangi sayı ve tıklanınca hangi ekran - hepsi burada. İstemci yalnız çizer;
--  yeni bir profil ya da yeni bir gösterge, ekran kodu değiştirmeden bu
--  fonksiyonla eklenir.
--
--  KUTU ≠ RAPOR: her kutu kullanıcının BUGÜN yapacağı bir işi gösterir
--  (bekleyen numune, teyit edilmemiş panik değer, rapor kuyruğu). "Toplam
--  hasta sayısı" gibi geriye bakan sayılar panelde durmaz.
--
--  Profil yoksa ya da tanınmayan bir tipse: ERP/genel kutular (mevcut panel)
--  kullanılmaya devam eder - fonksiyon boş `kutular` döner ve istemci eski
--  düzeni çizer.
-- =====================================================================

create or replace function public.fn_panel_profil(p_sube integer)
returns jsonb language plpgsql stable as $$
declare
    v_tip     text;
    v_baslik  text;
    v_kutular jsonb := '[]'::jsonb;
    v_bloklar jsonb := '[]'::jsonb;
begin
    -- Şubenin profili, yoksa kurum geneli (sube_id = 0) - fn_urun_modu deseni.
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
            select jsonb_build_object(
                'sira', '1', 'kod', 'numune', 'baslik', 'Kabul bekleyen numune',
                'deger', (select count(*) from public.lab_numune where durum in (1, 2)),
                'alt', 'etiketlendi / alındı', 'vurgu', 'normal', 'rota', '/lab-numune') k
            union all select jsonb_build_object(
                'sira', '2', 'kod', 'cihazda', 'baslik', 'Cihazda çalışılıyor',
                'deger', (select count(*) from public.lab_numune where durum = 4),
                'alt', 'sonuç bekleniyor', 'vurgu', 'normal', 'rota', '/lab-numune')
            union all select jsonb_build_object(
                'sira', '3', 'kod', 'onay', 'baslik', 'Onay bekleyen sonuç',
                'deger', (select count(*) from public.lab_sonuc where durum not in (3, 4)),
                'alt', 'teknik onay / onay', 'vurgu', 'uyari', 'rota', '/lab-sonuc')
            union all select jsonb_build_object(
                'sira', '4', 'kod', 'panik', 'baslik', 'Teyit bekleyen panik değer',
                'deger', (select count(*) from public.lab_panik_bildirim where teyit_zamani is null),
                'alt', 'bildirim teyidi yok', 'vurgu', 'tehlike', 'rota', '/lab-sonuc')
        ) t(k);

        select jsonb_build_array(jsonb_build_object(
            'kod', 'bolum', 'baslik', 'Bölüm kuyruğu',
            'ipucu', 'çalışılmayı bekleyen tetkik',
            'kolonlar', jsonb_build_array('Bölüm', 'Bekleyen'),
            'bicimler', jsonb_build_array('metin', 'sayi'),
            'satirlar', coalesce((
                select jsonb_agg(jsonb_build_array(b.ad, s.adet::text) order by s.adet desc)
                  from (select t.bolum, count(*) adet
                          from public.lab_istem_satir i
                          join public.lab_tetkik t on t.id = i.tetkik_id
                         where i.durum < 3
                         group by t.bolum) s
                  left join lateral (
                        select coalesce(d.ad, 'Bölüm ' || s.bolum) ad
                          from public.kod_deger d
                          join public.kod_liste l on l.id = d.liste_id
                         where l.kod = 'lab.bolum' and d.deger = s.bolum) b on true
            ), '[]'::jsonb))) into v_bloklar;

    -- ------------------------------------------------------ GÖRÜNTÜLEME --
    elsif v_tip = 'goruntuleme' then
        v_baslik := 'Görüntüleme Merkezi';
        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object(
                'sira', '1', 'kod', 'istem', 'baslik', 'Bekleyen istem',
                'deger', (select count(*) from public.radyoloji_istem where durum = 1),
                'alt', 'çekim bekliyor', 'vurgu', 'normal', 'rota', '/radyoloji-istem') k
            union all select jsonb_build_object(
                'sira', '2', 'kod', 'cekildi', 'baslik', 'Çekildi',
                'deger', (select count(*) from public.radyoloji_istem where durum = 2),
                'alt', 'rapor yazılacak', 'vurgu', 'normal', 'rota', '/radyoloji-istem')
            union all select jsonb_build_object(
                'sira', '3', 'kod', 'rapor', 'baslik', 'Rapor bekleyen',
                'deger', (select count(*) from public.radyoloji_istem where durum in (2, 3, 4)),
                'alt', 'onaylanmamış', 'vurgu', 'uyari', 'rota', '/radyoloji-rapor')
            union all select jsonb_build_object(
                'sira', '4', 'kod', 'bugun', 'baslik', 'Bugün onaylanan',
                'deger', (select count(*) from public.radyoloji_istem
                           where durum >= 5 and degistirme_tarihi::date = current_date),
                'alt', 'tamamlanan rapor', 'vurgu', 'olumlu', 'rota', '/radyoloji-rapor')
        ) t(k);

        select jsonb_build_array(jsonb_build_object(
            'kod', 'modalite', 'baslik', 'Modalite kuyruğu',
            'ipucu', 'bekleyen istem sayısı',
            'kolonlar', jsonb_build_array('Modalite', 'Bekleyen'),
            'bicimler', jsonb_build_array('metin', 'sayi'),
            'satirlar', coalesce((
                select jsonb_agg(jsonb_build_array(coalesce(d.ad, 'Tanımsız'), s.adet::text)
                                 order by s.adet desc)
                  from (select i.modalite, count(*) adet
                          from public.radyoloji_istem i
                         where i.durum in (1, 2, 3, 4)
                         group by i.modalite) s
                  left join public.kod_liste l on l.kod = 'rad.modalite'
                  left join public.kod_deger d on d.liste_id = l.id and d.deger = s.modalite
            ), '[]'::jsonb))) into v_bloklar;

    -- ------------------------------------------------------ TIP MERKEZİ --
    elsif v_tip in ('tip_merkezi', 'hastane', 'muayenehane', 'dal_goz', 'dal_ftr', 'dis') then
        v_baslik := 'Klinik';
        select jsonb_agg(k order by k->>'sira') into v_kutular from (
            select jsonb_build_object(
                'sira', '1', 'kod', 'randevu', 'baslik', 'Bugünkü randevu',
                'deger', (select count(*) from public.randevu
                           where baslangic::date = current_date and durum <> 4),
                'alt', 'planlı / gelen', 'vurgu', 'normal', 'rota', '/randevu') k
            union all select jsonb_build_object(
                'sira', '2', 'kod', 'basvuru', 'baslik', 'Bugünkü başvuru',
                'deger', (select count(*) from public.belge b
                           join public.belge_basvuru bb on bb.id = b.id
                          where b.belge_tarihi::date = current_date and b.durum <> 2),
                'alt', 'kayıt kabul', 'vurgu', 'normal', 'rota', '/basvuru')
            union all select jsonb_build_object(
                'sira', '3', 'kod', 'sonuc', 'baslik', 'Sonuç bekleyen',
                'deger', (select count(*) from public.lab_istem_satir where durum < 3)
                       + (select count(*) from public.radyoloji_istem where durum in (1, 2, 3, 4)),
                'alt', 'lab + radyoloji', 'vurgu', 'uyari', 'rota', '/lab-istem')
            union all select jsonb_build_object(
                'sira', '4', 'kod', 'tahsilat', 'baslik', 'Bugün tahsilat',
                'deger', (select coalesce(sum(k2.tutar), 0) from public.kasa_islem k2
                           where k2.islem_tarihi::date = current_date and k2.durum <> 2),
                'bicim', 'para', 'alt', 'kasa + banka', 'vurgu', 'olumlu', 'rota', '/kasa-islem')
        ) t(k);

        select jsonb_build_array(jsonb_build_object(
            'kod', 'kurum', 'baslik', 'Kurumlara açık tahakkuk',
            'ipucu', 'kapanmamış kurum payı',
            'kolonlar', jsonb_build_array('Kurum', 'Satır', 'Açık'),
            -- Sayi BICIMI ISTEMCININ: veritabani yerel ayari C, to_char burada
            --   "13,720.47" uretiyordu - Turkce bicim tek yerde (istemci).
            'bicimler', jsonb_build_array('metin', 'sayi', 'para'),
            'satirlar', coalesce((
                select jsonb_agg(jsonb_build_array(x.unvan, x.adet::text,
                                                   round(x.acik, 2)::text)
                                 order by x.acik desc)
                  from (select t.unvan,
                               count(*) adet,
                               sum(coalesce(a.sgk_kalan, 0) + coalesce(a.oss_kalan, 0)) acik
                          from public.v_belge_acik_satir a
                          join public.taraf t on t.id = a.taraf_id
                         where coalesce(a.sgk_kalan, 0) + coalesce(a.oss_kalan, 0) > 0
                         group by t.unvan
                         limit 8) x
            ), '[]'::jsonb))) into v_bloklar;
    else
        v_baslik := '';
    end if;

    return jsonb_build_object(
        'kurumTipi', v_tip,
        'baslik',    coalesce(v_baslik, ''),
        'kutular',   coalesce(v_kutular, '[]'::jsonb),
        'bloklar',   coalesce(v_bloklar, '[]'::jsonb));
end $$;

comment on function public.fn_panel_profil(integer) is
    'Ana sayfa kutu/blokları kurum profiline göre (508) - içerik sunucudan.';
