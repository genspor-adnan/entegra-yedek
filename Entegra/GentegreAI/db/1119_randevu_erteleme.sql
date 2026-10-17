-- ============================================================================
--  1119_randevu_erteleme.sql
--  RANDEVU ERTELEME (kullanıcı 17.10.2026: "randevu ertelemeyi nasıl yapacağız?" → "ilk yol, yap").
--
--  Erteleme = eski randevu "Ertelendi" (durum 5) kalır + aynı hasta / hekim / cihaz / hizmet ile
--  yeni randevu açılır. Saat değiştirip üstüne yazmak geçmişi siliyordu (raporda ertelenen
--  görünmüyor, neden tutulmuyordu).
--    * randevu.onceki_randevu_id : yeni randevu → ertelenen eski randevu
--    * randevu.erteleme_nedeni   : eski randevuya yazılır (zorunlu, uç doğrular)
--    * durum 5 İPTAL GİBİ davranır: slotu boşaltır, çakışma / izin / mesai kontrolü dışı,
--      panel sayılarına girmez. Aşağıdaki nesnelerin yürürlükteki tanımlarında "(3, 4)" ve
--      "<> 4" koşulları 5'i de kapsayacak şekilde genişletildi - başka değişiklik yok:
--        tg_randevu_cakisma (317) · tg_randevu_izin_kontrol, tg_randevu_mesai_kontrol (950)
--        fn_gosterge_kutu, fn_gosterge_blok (1103) · fn_panel_profil, v_dis_lab_isemri (940)
--        v_radyoloji_cihaz_durum (967) · ux_randevu_hekim_saat (243)
--  HEKİM + CİHAZ BİRLİKTE (kullanıcı 17.10.2026: "göz merkezlerinde cihaza (lazer) ve doktora aynı
--  anda randevu veriliyor"): tg_randevu_cakisma cihaz seçiliyse doktoru hiç denetlemiyor, doktorun
--  çakışma sorgusu da cihazlı randevuları saymıyordu - doktora aynı saatte hem lazer hem poliklinik
--  randevusu verilebiliyordu. Artık cihaz kapasitesi VE doktorun boşluğu birlikte aranır.
--  Tekrar çalıştırılabilir.
-- ============================================================================

alter table public.randevu
    add column if not exists onceki_randevu_id integer references public.randevu(id) on delete set null,
    add column if not exists erteleme_nedeni   varchar(200) not null default '';
create index if not exists ix_randevu_onceki on public.randevu (onceki_randevu_id) where onceki_randevu_id is not null;

comment on column public.randevu.durum is '1 planlandı / 2 geldi / 3 gelmedi / 4 iptal / 5 ertelendi (1119)';
comment on column public.randevu.onceki_randevu_id is '1119: bu randevu ertelemeyle açıldıysa ertelenen eski randevu';
comment on column public.randevu.erteleme_nedeni is '1119: ertelenen (durum 5) randevunun nedeni';

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, 5, 'Ertelendi', 50, 1, 0
  from public.kod_liste l
 where l.kod = 'randevu.durum'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = 5);

-- Aynı hekime aynı anda iki randevu: iptal ve ertelenenler hariç (ertelenen slot yeniden verilebilir).
drop index if exists public.ux_randevu_hekim_saat;
create unique index ux_randevu_hekim_saat
  on public.randevu (hekim_id, baslangic) where hekim_id is not null and durum not in (4, 5);

-- tg_randevu_cakisma: Ertelendi (5) iptal gibi kontrol dışı; hekim + cihaz birlikteyse İKİSİ de denetlenir
CREATE OR REPLACE FUNCTION public.tg_randevu_cakisma()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_bit   timestamp;
  v_adet  integer;
  v_kap   integer;
  v_ad    text;
begin
  -- KAYNAK ZORUNLULUGU: randevu ya hekime ya cihaza verilir.
  --   Kart alanlarindaki "zorunlu" bayragi ikisini birden zorunlu tutamaz
  --   (radyolojide hekim yok, poliklinikte cihaz yok) - kural burada.
  if new.cihaz_id is null and new.hekim_id is null then
    raise exception 'Randevu için hekim ya da cihaz seçilmeli.' using errcode = 'GK422';
  end if;
  if new.cihaz_id is null and coalesce(new.bolum, 0) = 0 then
    raise exception 'Poliklinik randevusunda bölüm seçilmeli.' using errcode = 'GK422';
  end if;

  if coalesce(new.durum, 1) in (3, 4, 5) then return new; end if;

  v_bit := new.baslangic + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1));

  -- 1) CİHAZ kaynağı: kapasite kadar üst üste binebilir.
  if new.cihaz_id is not null then
    select coalesce(eszaman, 1) into v_kap
      from public.radyoloji_cihaz where id = new.cihaz_id;

    select count(*) into v_adet
      from public.randevu r
     where r.cihaz_id = new.cihaz_id
       and r.id is distinct from new.id
       and coalesce(r.durum, 1) not in (3, 4, 5)
       and r.baslangic < v_bit
       and (r.baslangic + make_interval(mins => greatest(coalesce(r.sure_dk, 0), 1))) > new.baslangic;

    if v_adet >= coalesce(v_kap, 1) then
      raise exception 'Cihaz bu saatte dolu (aynı anda en fazla % hasta).', coalesce(v_kap, 1)
        using errcode = 'GK422';
    end if;

    -- 2) Cihazın kapalı aralığı (bakım / arıza / tatil).
    select coalesce(nullif(k.aciklama, ''),
                    (select d.ad from public.kod_deger d
                       join public.kod_liste l on l.id = d.liste_id
                      where l.kod = 'rad.kapatma' and d.deger = k.neden_tur))
      into v_ad
      from public.radyoloji_cihaz_kapatma k
     where k.cihaz_id = new.cihaz_id
       and k.baslangic < v_bit and k.bitis > new.baslangic
     limit 1;

    if v_ad is not null then
      raise exception 'Cihaz bu aralıkta randevuya kapalı: %', v_ad using errcode = 'GK422';
    end if;

  end if;

  -- 3) HEKİM kaynağı: aynı hekime çakışan randevu olamaz. Cihazlı randevuda da (1119, göz
  --    merkezi: lazer + doktor aynı randevuda) - doktorun cihazlı randevuları da sayılır.
  if new.hekim_id is not null then
    select count(*) into v_adet
      from public.randevu r
     where r.hekim_id = new.hekim_id
       and r.id is distinct from new.id
       and coalesce(r.durum, 1) not in (3, 4, 5)
       and r.baslangic < v_bit
       and (r.baslangic + make_interval(mins => greatest(coalesce(r.sure_dk, 0), 1))) > new.baslangic;

    if v_adet > 0 then
      raise exception 'Hekimin bu saatte başka randevusu var.' using errcode = 'GK422';
    end if;
  end if;

  return new;
end $function$;

-- tg_randevu_izin_kontrol: Ertelendi (5) iptal gibi kontrol dışı
CREATE OR REPLACE FUNCTION public.tg_randevu_izin_kontrol()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_izin   record;
  v_ayar   text;
  v_hekim  text;
  v_yerel  timestamp;
  v_bas    time;
  v_bit    time;
begin
  if coalesce(new.durum, 1) in (3, 4, 5) then return new; end if;
  if new.hekim_id is null then return new; end if;

  select new.baslangic at time zone coalesce(nullif(s.zaman_dilimi, ''), 'Europe/Istanbul') into v_yerel
    from public.sube s where s.id = new.sube_id;
  v_yerel := coalesce(v_yerel, new.baslangic at time zone 'Europe/Istanbul');
  v_bas := v_yerel::time;
  v_bit := v_bas + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1)::int);

  select * into v_izin from public.fn_hekim_izin_cakisan(new.hekim_id, v_yerel::date, v_bas, v_bit);
  if not found then return new; end if;

  select coalesce(nullif(deger, ''), '0') into v_ayar
    from public.referans where anahtar = 'randevu.izinli_hekim';
  if coalesce(v_ayar, '0') = '1' then
    raise warning 'Hekim % tarihinde izinli (izin #%).', v_yerel::date, v_izin.izin_id;
    return new;
  end if;

  select coalesce(nullif(public.fn_taraf_ad(unvan, ad, soyad), ''), 'Hekim') into v_hekim
    from public.taraf where id = new.hekim_id;

  if v_izin.saat_bas is not null then
    raise exception '% % tarihinde % - % arası izinli. İzinli saate randevu yazılamaz; başka saat ya da başka hekim seçin.',
      v_hekim, to_char(v_yerel::date, 'DD.MM.YYYY'), v_izin.saat_bas, v_izin.saat_bit
      using errcode = 'GK422';
  end if;
  raise exception '% % tarihinde izinli (% - %). İzinli hekime randevu yazılamaz; izni iptal edin ya da başka hekim seçin.',
    v_hekim, to_char(v_yerel::date, 'DD.MM.YYYY'),
    to_char(v_izin.baslangic, 'DD.MM.YYYY'), to_char(v_izin.bitis, 'DD.MM.YYYY')
    using errcode = 'GK422';
end $function$;

-- tg_randevu_mesai_kontrol: Ertelendi (5) iptal gibi kontrol dışı
CREATE OR REPLACE FUNCTION public.tg_randevu_mesai_kontrol()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    v_ayar  text;
    v_hekim text;
    v_dilim text;
    v_yerel timestamp;
    v_gun   date;
    v_bas   time;
    v_bit   time;
begin
    if coalesce(new.durum, 1) in (3, 4, 5) then return new; end if;
    if new.hekim_id is null then return new; end if;
    if tg_op = 'UPDATE'
       and new.hekim_id is not distinct from old.hekim_id
       and new.baslangic = old.baslangic
       and new.sure_dk = old.sure_dk
       and coalesce(old.durum, 1) not in (3, 4, 5) then
        return new;
    end if;
    if public.fn_hekim_planli(new.hekim_id) <> 1 then return new; end if;

    select coalesce(nullif(s.zaman_dilimi, ''), 'Europe/Istanbul') into v_dilim
      from public.sube s where s.id = new.sube_id;
    v_yerel := new.baslangic at time zone coalesce(v_dilim, 'Europe/Istanbul');
    v_gun   := v_yerel::date;
    v_bas   := v_yerel::time;
    v_bit   := v_bas + make_interval(mins => greatest(coalesce(new.sure_dk, 0), 1)::int);

    -- İzinle ÇAKIŞAN randevu: kararı izin tetiği verir (kendi ayarıyla) - aynı
    --   randevuya iki mesaj çıkmasın. Saatli izinde çakışmayan saat normal denetlenir (950).
    if exists (select 1 from public.fn_hekim_izin_cakisan(new.hekim_id, v_gun, v_bas, v_bit)) then
        return new;
    end if;

    if exists (select 1
                 from public.fn_hekim_calisma_bloklari(new.sube_id, v_gun, v_gun, new.hekim_id) b
                where b.saat_bas is not null
                  and v_bas >= b.saat_bas and v_bit <= b.saat_bit
                  and v_bit > v_bas) then
        return new;
    end if;

    select coalesce(nullif(deger, ''), '0') into v_ayar
      from public.referans where anahtar = 'randevu.mesai_disi';
    if coalesce(v_ayar, '0') = '1' then
        raise warning 'Randevu % calisma plani disinda (hekim #%).',
            to_char(v_yerel, 'DD.MM.YYYY HH24:MI'), new.hekim_id;
        return new;
    end if;

    select coalesce(nullif(public.fn_taraf_ad(unvan, ad, soyad), ''), 'Doktor') into v_hekim
      from public.taraf where id = new.hekim_id;

    raise exception '% % saat % - %: çalışma planının dışında. Randevu doktorun çalışma saatleri içinde verilmeli; gerekirse Çalışma Planı''ndan saat değişikliği ya da ek mesai ekleyin.',
        v_hekim, to_char(v_gun, 'DD.MM.YYYY'),
        to_char(v_bas, 'HH24:MI'), to_char(v_bit, 'HH24:MI')
        using errcode = 'GK422';
end $function$;

-- fn_gosterge_kutu
CREATE OR REPLACE FUNCTION public.fn_gosterge_kutu(p_kod text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
  return case p_kod
    when 'randevu' then jsonb_build_object('baslik','Bugünkü randevu',
        'deger',(select count(*) from public.randevu where baslangic::date = current_date and durum not in (4, 5)),
        'alt',(select 'geldi ' || count(*) filter (where durum = 2) || ' · gelmedi ' || count(*) filter (where durum = 3)
                 from public.randevu where baslangic::date = current_date and durum not in (4, 5)),
        'vurgu','normal','rota','/randevu')
    when 'basvuru' then jsonb_build_object('baslik','Açık başvuru',
        'deger',(select count(*) from public.belge b join public.belge_basvuru bb on bb.id = b.id
                  where b.durum <> 2 and coalesce(b.kapanma_durum, 0) <> 2),
        'alt',(select 'bugün ' || count(*) from public.belge b join public.belge_basvuru bb on bb.id = b.id
                where b.belge_tarihi::date = current_date and b.durum <> 2),
        'vurgu','normal','rota','/basvuru')
    when 'muayeneBekleyen' then jsonb_build_object('baslik','Bekleyen muayene',
        'deger',(select count(*) from public.muayene where muayene_tarihi::date = current_date and durum in (1, 2)),
        'alt',(select 'sonuç bekleyen ' || count(*) filter (where durum = 2) from public.muayene
                where muayene_tarihi::date = current_date and durum in (1, 2)),
        'vurgu','uyari','rota','/muayene')
    when 'konsultasyon' then jsonb_build_object('baslik','Açık konsültasyon',
        'deger',(select count(*) from public.muayene where tur = 3 and durum in (1, 2)),
        'alt','yanıt bekleyen','vurgu','uyari','rota','/muayene')
    when 'sonuc' then jsonb_build_object('baslik','Sonuç bekleyen',
        'deger',(select count(*) from public.lab_istem_satir where durum < 3)
              + (select count(*) from public.radyoloji_istem where durum in (1,2,3,4)),
        'alt','lab ' || (select count(*) from public.lab_istem_satir where durum < 3)
              || ' · radyoloji ' || (select count(*) from public.radyoloji_istem where durum in (1,2,3,4)),
        'vurgu','uyari','rota','/lab-istem')
    when 'yatan' then jsonb_build_object('baslik','Yatan hasta',
        'deger',(select count(*) from public.yatis where durum in (1, 2, 3)),
        'alt','taburcu planlanan ' || (select count(*) from public.yatis where durum = 3),
        'vurgu','normal','rota','/yatan')
    when 'order' then jsonb_build_object('baslik','Aktif order',
        'deger',(select count(*) from public.yatis_order where durum = 1),
        'alt','yatan hastalarda','vurgu','normal','rota','/yatis-order')
    when 'tahsilat' then jsonb_build_object('baslik','Bugün tahsilat','bicim','para',
        'deger',(select coalesce(sum(k.tutar),0) from public.kasa_islem k
                  where k.islem_tarihi::date = current_date and k.durum <> 2 and k.tur in (21,22,25)),
        'alt',(select 'nakit ' || count(*) filter (where tur = 21) || ' · pos ' || count(*) filter (where tur = 25)
                      || ' · havale ' || count(*) filter (where tur = 22)
                 from public.kasa_islem where islem_tarihi::date = current_date and durum <> 2 and tur in (21,22,25)),
        'vurgu','olumlu','rota','/kasa-islem')
    when 'acikTahsilat' then jsonb_build_object('baslik','Açık tahsilat','bicim','para',
        'deger',(select coalesce(sum(coalesce(a.hasta_provizyon_kalan,0) + coalesce(a.hasta_ek_katki_kalan,0)),0)
                   from public.v_belge_acik_satir a),
        'alt',(select coalesce(count(distinct a.belge_id),0) || ' başvuru' from public.v_belge_acik_satir a
                where coalesce(a.hasta_provizyon_kalan,0) + coalesce(a.hasta_ek_katki_kalan,0) > 0),
        'vurgu','tehlike','rota','/basvuru')
    when 'labNumune' then jsonb_build_object('baslik','Kabul bekleyen numune',
        'deger',(select count(*) from public.lab_numune where durum in (1,2)),
        'alt','etiketlendi / alındı','vurgu','normal','rota','/lab-numune')
    when 'labOnay' then jsonb_build_object('baslik','Onay bekleyen sonuç',
        'deger',(select count(*) from public.lab_sonuc where durum not in (3,4)),
        'alt','teknik onay / onay','vurgu','uyari','rota','/lab-sonuc')
    when 'labPanik' then jsonb_build_object('baslik','Teyit bekleyen panik',
        'deger',(select count(*) from public.lab_panik_bildirim where teyit_zamani is null),
        'alt','bildirim teyidi yok','vurgu','tehlike','rota','/lab-sonuc')
    when 'radIstem' then jsonb_build_object('baslik','Bekleyen görüntüleme',
        'deger',(select count(*) from public.radyoloji_istem where durum = 1),
        'alt','çekim bekliyor','vurgu','normal','rota','/radyoloji-istem')
    when 'aySatis' then jsonb_build_object('baslik','Bu ay satış','bicim','para',
        'deger',(select coalesce(sum(genel_toplam),0) from public.belge
                  where durum = 0 and tur in (14,15,16,119) and belge_tarihi >= date_trunc('month', now())),
        'alt',(select count(*) || ' belge' from public.belge
                where durum = 0 and tur in (14,15,16,119) and belge_tarihi >= date_trunc('month', now())),
        'vurgu','olumlu','rota','/belge')
    when 'ayAlis' then jsonb_build_object('baslik','Bu ay alış','bicim','para',
        'deger',(select coalesce(sum(genel_toplam),0) from public.belge
                  where durum = 0 and tur in (10,11,12,109) and belge_tarihi >= date_trunc('month', now())),
        'alt',(select count(*) || ' belge' from public.belge
                where durum = 0 and tur in (10,11,12,109) and belge_tarihi >= date_trunc('month', now())),
        'vurgu','normal','rota','/alis-fatura')
    when 'kritikStok' then jsonb_build_object('baslik','Kritik stok',
        'deger',(select count(*) from (
                   select s.id from public.stok_durum sd join public.stok s on s.id = sd.stok_id
                    group by s.id, s.min_stok
                   having coalesce(nullif(sum(coalesce(sd.min_stok,0)),0), max(s.min_stok)) > 0
                      and sum(sd.kalan) < coalesce(nullif(sum(coalesce(sd.min_stok,0)),0), max(s.min_stok))) x),
        'alt','eşiğin altında','vurgu','uyari','rota','/stok')
    when 'enabizHata' then jsonb_build_object('baslik','e-Nabız hatalı',
        'deger',(select count(*) from public.enabiz_paket where durum = 4),
        'alt','yeniden gönderilecek','vurgu','tehlike','rota','/enabiz-paket')
    else null end;
end $function$;

-- fn_gosterge_blok
CREATE OR REPLACE FUNCTION public.fn_gosterge_blok(p_kod text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
  return case p_kod
    when 'poliklinik' then jsonb_build_object('baslik','Poliklinik akışı','ipucu','bugün',
        'kolonlar', jsonb_build_array('Bölüm','Randevu','Bekleyen'), 'bicimler', jsonb_build_array('metin','sayi','sayi'),
        'satirlar', coalesce((select jsonb_agg(jsonb_build_array(x.ad, x.randevu::text, x.bekleyen::text) order by x.randevu desc)
          from (select coalesce(d.ad,'Bölümsüz') ad, count(*) randevu, count(*) filter (where r.durum = 1) bekleyen
                  from public.randevu r left join public.departman d on d.id = r.bolum
                 where r.baslangic::date = current_date and r.durum not in (4, 5) group by 1 limit 8) x), '[]'::jsonb))
    when 'birim' then jsonb_build_object('baslik','Yardımcı birimler','ipucu','kuyruk',
        'kolonlar', jsonb_build_array('Birim','Bekleyen','Bugün biten'), 'bicimler', jsonb_build_array('metin','sayi','sayi'),
        'satirlar', jsonb_build_array(
          jsonb_build_array('Laboratuvar', (select count(*) from public.lab_istem_satir where durum < 3)::text,
            (select count(*) from public.lab_sonuc where durum = 3 and degistirme_tarihi::date = current_date)::text),
          jsonb_build_array('Radyoloji', (select count(*) from public.radyoloji_istem where durum in (1,2,3,4))::text,
            (select count(*) from public.radyoloji_istem where durum >= 5 and degistirme_tarihi::date = current_date)::text)))
    when 'kurum' then jsonb_build_object('baslik','Kurum & sözleşme','ipucu','açık tahakkuk',
        'kolonlar', jsonb_build_array('Kurum','Başvuru','Açık'), 'bicimler', jsonb_build_array('metin','sayi','para'),
        'satirlar', coalesce((select jsonb_agg(jsonb_build_array(x.unvan, x.adet::text, round(x.acik,2)::text) order by x.acik desc)
          from (select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) unvan, count(*) adet,
                       sum(coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0)) acik
                  from public.v_belge_acik_satir a join public.taraf t on t.id = a.taraf_id
                 where coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0) > 0
                 group by 1 limit 8) x), '[]'::jsonb))
    when 'hekim' then jsonb_build_object('baslik','Hekim üretimi','ipucu','bugün',
        'kolonlar', jsonb_build_array('Hekim','Hasta','Ciro'), 'bicimler', jsonb_build_array('metin','sayi','para'),
        'satirlar', coalesce((select jsonb_agg(jsonb_build_array(x.ad, x.hasta::text, round(x.ciro,2)::text) order by x.ciro desc)
          from (select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120),'Atanmamış') ad, count(*) hasta,
                       sum(coalesce(b.genel_toplam,0)) ciro
                  from public.belge b join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf t on t.id = bb.personel_id
                 where b.belge_tarihi::date = current_date and b.durum <> 2 group by 1 limit 8) x), '[]'::jsonb))
    when 'enabiz' then jsonb_build_object('baslik','e-Nabız / bildirim','ipucu','son 24 saat',
        'kolonlar', jsonb_build_array('Paket','Üretilen','Gönderilen'), 'bicimler', jsonb_build_array('metin','sayi','sayi'),
        'satirlar', coalesce((select jsonb_agg(jsonb_build_array(x.ad, x.uretilen::text, x.gonderilen::text) order by x.uretilen desc)
          from (select coalesce(pt.ad, 'Paket ' || p.paket_turu_id) ad, count(*) uretilen, count(*) filter (where p.durum >= 3) gonderilen
                  from public.enabiz_paket p left join public.enabiz_paket_turu pt on pt.id = p.paket_turu_id
                 where p.ekleme_tarihi >= now() - interval '24 hours' group by 1 limit 8) x), '[]'::jsonb))
    when 'labBolum' then jsonb_build_object('baslik','Bölüm kuyruğu','ipucu','çalışılmayı bekleyen tetkik',
        'kolonlar', jsonb_build_array('Bölüm','Bekleyen'), 'bicimler', jsonb_build_array('metin','sayi'),
        'satirlar', coalesce((select jsonb_agg(jsonb_build_array(coalesce(d.ad, 'Bölüm ' || s.bolum), s.adet::text) order by s.adet desc)
          from (select t.bolum, count(*) adet from public.lab_istem_satir i join public.lab_tetkik t on t.id = i.tetkik_id
                 where i.durum < 3 group by t.bolum) s
          left join public.kod_liste l on l.kod = 'lab.bolum'
          left join public.kod_deger d on d.liste_id = l.id and d.deger = s.bolum and d.dil = 0), '[]'::jsonb))
    when 'dikkat' then jsonb_build_object('baslik','Dikkat gerektiren','ipucu','iş listesi',
        'kolonlar', jsonb_build_array('Konu','Adet'), 'bicimler', jsonb_build_array('metin','sayi'),
        'satirlar', jsonb_build_array(
          jsonb_build_array('Onaylanmamış tetkik sonucu', (select count(*) from public.lab_sonuc where durum not in (3,4))::text),
          jsonb_build_array('Faturası kesilmemiş kurum icmali', (select count(*) from public.kurum_icmal where durum < 2)::text),
          jsonb_build_array('e-Nabız hatalı paket', (select count(*) from public.enabiz_paket where durum = 4)::text),
          jsonb_build_array('Açık konsültasyon', (select count(*) from public.muayene where tur = 3 and durum in (1, 2))::text)))
    else null end;
end $function$;

-- fn_panel_profil
CREATE OR REPLACE FUNCTION public.fn_panel_profil(p_sube integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
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
                          where baslangic::date = current_date and durum not in (4, 5)),
                'alt',(select 'geldi ' || count(*) filter (where durum = 2)
                            || ' · gelmedi ' || count(*) filter (where durum = 3)
                         from public.randevu
                        where baslangic::date = current_date and durum not in (4, 5)),
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
          -- 1 · KURUM & SÖZLEŞME
          jsonb_build_object('kod','kurum','baslik','Kurum & sözleşme','ipucu','açık tahakkuk',
            'kolonlar', jsonb_build_array('Kurum','Tip','Başvuru','Açık'),
            'bicimler', jsonb_build_array('metin','metin','sayi','para'),
            'satirlar', coalesce((
              select jsonb_agg(jsonb_build_array(x.unvan, x.tip, x.adet::text, round(x.acik,2)::text)
                               order by x.acik desc)
                from (select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) as unvan,
                             case tk.tur when 1 then 'Özel' when 2 then 'ÖSS'
                                         when 3 then 'SGK'  when 4 then 'Kurumu Öder'
                                         else '—' end tip,
                             count(*) adet,
                             sum(coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0)) acik
                        from public.v_belge_acik_satir a
                        join public.taraf t on t.id = a.taraf_id
                        left join public.taraf_kurum tk on tk.id = t.id
                       where coalesce(a.sgk_kalan,0) + coalesce(a.oss_kalan,0) > 0
                       group by public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120), tk.tur limit 8) x), '[]'::jsonb)),

          -- 2 · POLİKLİNİK AKIŞI
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
                       where r.baslangic::date = current_date and r.durum not in (4, 5)
                       group by 1 limit 8) x), '[]'::jsonb)),

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
                from (select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120),'Atanmamış') ad,
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
end $function$;

-- v_dis_lab_isemri: sonraki randevu ertelenmiş olanı göstermez
create or replace view public.v_dis_lab_isemri as
SELECT i.id,
    i.sube_id,
    i.isemri_no,
    i.lab_id,
    l.ad AS lab_adi,
    i.hasta_id,
    fn_taraf_ad(t.unvan, t.ad, t.soyad)::character varying(120) AS hasta_adi,
    i.hekim_id,
    fn_taraf_ad(h.unvan, h.ad, h.soyad)::character varying(120) AS hekim_adi,
    i.plan_satir_id,
    i.is_turu,
    i.dis_nolar,
    i.malzeme,
    i.renk,
    i.gonderim_tarihi,
    i.beklenen_tarih,
    i.teslim_tarihi,
    i.asama,
    i.lab_fiyat,
    i.hasta_fiyat,
        CASE
            WHEN i.asama = ANY (ARRAY[8, 9]) THEN 0
            WHEN i.beklenen_tarih IS NOT NULL AND i.beklenen_tarih < CURRENT_DATE THEN 1
            ELSE 0
        END AS gecikti,
    ( SELECT r.baslangic
           FROM randevu r
          WHERE r.lab_isemri_id = i.id AND r.durum not in (4, 5)
          ORDER BY r.baslangic DESC
         LIMIT 1) AS sonraki_randevu
   FROM dis_lab_isemri i
     JOIN dis_lab l ON l.id = i.lab_id
     JOIN taraf t ON t.id = i.hasta_id
     LEFT JOIN taraf h ON h.id = i.hekim_id;

-- v_radyoloji_cihaz_durum: bugün / hafta randevu sayısı
create or replace view public.v_radyoloji_cihaz_durum as
WITH simdi AS (
         SELECT now() AS an,
            (now() AT TIME ZONE 'Europe/Istanbul'::text)::date AS gun
        )
 SELECT c.id AS cihaz_id,
        CASE
            WHEN c.durum <> 1 THEN 0
            WHEN k.neden_tur = 2 THEN 3
            WHEN k.id IS NOT NULL THEN 2
            ELSE 1
        END::smallint AS su_an_kod,
        CASE
            WHEN c.durum <> 1 THEN 'Pasif'::text
            WHEN k.neden_tur = 2 THEN 'Arızada'::text
            WHEN k.neden_tur = 1 THEN 'Bakımda'::text
            WHEN k.id IS NOT NULL THEN 'Kapalı'::text
            ELSE 'Çalışıyor'::text
        END::character varying(20) AS su_an,
    k.bitis AS kapali_bitis,
    (( SELECT count(*) AS count
           FROM radyoloji_istem i
          WHERE i.cihaz_id = c.id AND (i.cekim_tarihi AT TIME ZONE 'Europe/Istanbul'::text)::date = s.gun))::integer AS bugun_cekim,
    (( SELECT count(*) AS count
           FROM randevu r
          WHERE r.cihaz_id = c.id AND r.durum not in (4, 5) AND (r.baslangic AT TIME ZONE 'Europe/Istanbul'::text)::date = s.gun))::integer AS bugun_randevu,
    (( SELECT count(*) AS count
           FROM radyoloji_istem i
          WHERE i.cihaz_id = c.id AND i.durum = 1 AND (i.ekleme_tarihi AT TIME ZONE 'Europe/Istanbul'::text)::date = s.gun))::integer AS sirada,
    (( SELECT count(*) AS count
           FROM randevu r
          WHERE r.cihaz_id = c.id AND r.durum not in (4, 5) AND r.baslangic >= date_trunc('week'::text, s.an) AND r.baslangic < (date_trunc('week'::text, s.an) + '7 days'::interval)))::integer AS hafta_randevu,
        CASE
            WHEN c.randevu_verilir = 1 AND COALESCE(c.slot_dk::integer, 0) > 0 AND c.baslangic_saat::text ~ '^\d{1,2}:\d{2}$'::text AND c.bitis_saat::text ~ '^\d{1,2}:\d{2}$'::text THEN (GREATEST(0::numeric, EXTRACT(epoch FROM c.bitis_saat::time without time zone - c.baslangic_saat::time without time zone) / 60::numeric -
            CASE
                WHEN c.ogle_baslangic::text ~ '^\d{1,2}:\d{2}$'::text AND c.ogle_bitis::text ~ '^\d{1,2}:\d{2}$'::text THEN EXTRACT(epoch FROM c.ogle_bitis::time without time zone - c.ogle_baslangic::time without time zone) / 60::numeric
                ELSE 0::numeric
            END) / c.slot_dk::numeric)::integer * GREATEST(COALESCE(c.eszaman::integer, 1), 1) * GREATEST(cardinality(string_to_array(NULLIF(c.calisma_gunleri::text, ''::text), ','::text)), 0)
            ELSE NULL::integer
        END AS hafta_kapasite,
    (( SELECT count(*) AS count
           FROM radyoloji_protokol_cihaz pc
          WHERE pc.cihaz_id = c.id))::integer AS protokol_sayisi,
    (( SELECT count(*) AS count
           FROM radyoloji_istem i
          WHERE i.cihaz_id = c.id AND i.durum >= 2 AND COALESCE(i.study_uid, ''::character varying)::text = ''::text AND i.cekim_tarihi > (s.an - '2 days'::interval)))::integer AS goruntu_eksik,
    (( SELECT count(*) AS count
           FROM radyoloji_cihaz_qa q
          WHERE q.cihaz_id = c.id AND q.periyot_gun IS NOT NULL AND (q.son_tarih IS NULL OR (q.son_tarih + q.periyot_gun) < s.gun)))::integer AS qa_geciken,
    (( SELECT count(*) AS count
           FROM radyoloji_cihaz_qa q
          WHERE q.cihaz_id = c.id AND q.periyot_gun IS NOT NULL AND q.son_tarih IS NOT NULL AND (q.son_tarih + q.periyot_gun) >= s.gun AND (q.son_tarih + q.periyot_gun) <= (s.gun + 30)))::integer AS qa_yaklasan,
    ( SELECT string_agg(q.ad::text, ', '::text ORDER BY q.sira) AS string_agg
           FROM radyoloji_cihaz_qa q
          WHERE q.cihaz_id = c.id AND q.periyot_gun IS NOT NULL AND (q.son_tarih IS NULL OR (q.son_tarih + q.periyot_gun) < s.gun)) AS qa_geciken_ad
   FROM radyoloji_cihaz c
     CROSS JOIN simdi s
     LEFT JOIN LATERAL ( SELECT x.id,
            x.neden_tur,
            x.bitis
           FROM radyoloji_cihaz_kapatma x
          WHERE x.cihaz_id = c.id AND s.an >= x.baslangic AND s.an <= x.bitis
          ORDER BY (x.neden_tur = 2) DESC, x.bitis DESC
         LIMIT 1) k ON true;
