-- ============================================================================
--  Gentegre AI — DIŞ DOKTOR PORTAL ROLÜ
--  796_dis_doktor_portal_rolu.sql
--
--  Kullanıcı: *"dış doktor rolünü de ekle"* (794/795'in devamı).
--  Plan: dokuman/13_PORTAL_ROLLERI_PLANI.md — 3. adım.
--  Mockup: Ekranlar/Portal/portal_dis_doktor.html
--
--  ============ KİM ===================================================
--  Dışarıdan hasta gönderen hekim. Kurumun personeli DEĞİL: kendi
--  muayenehanesinden ya da başka bir kurumdan hasta yollar, karşılığında
--  gönderdiği hastanın istemini, numune durumunu ve sonucunu görür.
--
--  ============ "BENİM HASTAM" BAĞI İKİ YERDE =========================
--  Laboratuvarda istemi açan hekim `lab_istem.personel_id`de; başvuru
--  üzerinden gelen işte ise satırın "Gönderen" rolünde
--  (`belge_satir_rol`, rol = 1). İkisinden biri tutuyorsa kayıt bu hekimindir -
--  birini seçmek ötekini görünmez yapardı. Radyolojide bağ daha doğrudan:
--  `radyoloji_istem.istek_hekim_id`.
--
--  ============ NE GÖRÜR ==============================================
--  `lab` (gör + istem aç) · `lab.sonuc` · `lab.numune` · `radyoloji-istem`
--  (gör + istem aç) · `hasta` · `ai.rehber`.
--
--  RADYOLOJIDE DAR YETKI: `radyoloji` yetkisi YEDİ kaynağı birden açıyor
--  (cihaz · şablon · protokol · kritik · konsültasyon · teslim · çalışma
--  listesi). Dış hekime "sonucunu görsün" demek için kurumun bütün radyoloji
--  ayarlarını açmak gerekiyordu. `radyoloji-istem` yetkisi zaten VARDI ama
--  hiçbir kaynağa bağlı değildi - on rolde duruyor, hiçbir işe yaramıyordu.
--  Artık çalışma listesi ve kartı ona bağlı; `radyoloji` taşıyan her role bu
--  yetki de veriliyor (aşağıda) - kimse ekran kaybetmiyor.
--
--  ISTEM AÇABİLİR: dış hekim portalı "sonuç bakma" ekranı değil, iş akışının
--  bir ucu - hastayı gönderen kişi istemi de oradan girer. Kurum istemiyorsa
--  yetkiyi Yönetim › Roller'den kaldırır.
--
--  ============ NE GÖRMEZ =============================================
--  Ücret/tahsilat, kurum içi ekranlar (görev · mesaj · doküman · pano), başka
--  hekimin hastası ve aynı hastanın BAŞKA bir hekimle yaptırdığı tetkik.
--  Kuralı yazılmamış her kaynak bu rol için kapalıdır (794).
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_rol integer;
    v_var integer;
begin
    select id into v_rol from public.rol where kod = 'dis_doktor';
    if v_rol is not null then
        update public.rol set portal_turu = 1 where id = v_rol and portal_turu <> 1;
        raise notice '796: dis_doktor rolu zaten var (id %) - portal damgasi dogrulandi.', v_rol;
    else
        insert into public.rol (kod, ad, amac, sistem, aktif, portal_turu, ekleyen)
        values ('dis_doktor', 'Dış Doktor (portal)',
                'Dışarıdan hasta gönderen hekim: kendi gönderdiği hastanın istemi, numunesi ve sonucu.',
                1, 1, 1, 0)
        returning id into v_rol;

        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
        select v_rol, y.id, 1,
               case when y.kod in ('lab', 'radyoloji-istem') then 1 else 0 end,
               case when y.kod in ('lab', 'radyoloji-istem') then 1 else 0 end, 0, ''
          from public.yetki y
         where y.kod in ('ai.rehber', 'lab', 'lab.sonuc', 'lab.numune',
                         'radyoloji-istem', 'hasta')
           and y.aktif = 1;

        insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen)
        select v_rol, s.id, s.varsayilan, 1, 0 from public.sube s where s.aktif = 1
        on conflict do nothing;

        select count(*) into v_var from public.rol_yetki where rol_id = v_rol;
        raise notice '796: "Dış Doktor (portal)" rolu kuruldu (id %, % yetki).', v_rol, v_var;
    end if;
end $$;

-- ------------------------------------------------- dar yetki dagitimi -----
-- `radyoloji` tasiyan HER ROL `radyoloji-istem`i de alir: calisma listesi
--   artik dar yetkiye bagli, yoksa radyolog kendi ekranini kaybederdi.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select ry.rol_id, yi.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ''
  from public.rol_yetki ry
  join public.yetki y  on y.id = ry.yetki_id and y.kod = 'radyoloji'
  join public.yetki yi on yi.kod = 'radyoloji-istem'
 where not exists (select 1 from public.rol_yetki r2
                    where r2.rol_id = ry.rol_id and r2.yetki_id = yi.id);

-- KURUM ICI EKRAN SIZMASIN: rol elle duzenlenmis olabilir.
do $$
declare v_sildi integer;
begin
    delete from public.rol_yetki ry
     using public.yetki y, public.rol r
     where ry.yetki_id = y.id and ry.rol_id = r.id and r.kod = 'dis_doktor'
       and y.kod in ('gorev', 'mesaj', 'dokuman', 'dokum', 'panel', 'ai',
                     'belge', 'kasa_islem', 'mali_hareket', 'fiyat_listesi',
                     'radyoloji');
    get diagnostics v_sildi = row_count;
    if v_sildi > 0 then
        raise notice '796: dis doktor rolunden % kurum ici / ucret yetkisi kaldirildi.', v_sildi;
    end if;
end $$;

do $$
declare r record;
begin
    for r in select kod, ad, portal_turu,
                    (select count(*) from public.taraf_kullanici k where k.rol_id = rol.id) kisi
               from public.rol where portal_turu > 0 order by portal_turu
    loop
        raise notice '796: portal rolu % (%) tur % - % kullanici', r.ad, r.kod, r.portal_turu, r.kisi;
    end loop;
end $$;
