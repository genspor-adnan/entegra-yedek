-- =====================================================================
--  894_lab_panik_takip.sql
--  PANİK DEĞER: SÜRE TAKİBİ, OTOMATİK HEKİM BİLDİRİMİ VE YÜKSELTME
--  (KTS denetim maddesi L2: "Panik değerler hekime bildiriliyor mu?")
--
--  BUGÜN NE VAR: `lab_sonuc.panik` bayrağı, `lab_panik_bildirim` kaydı
--  (kim/kime/kanal/okuma-geri teyidi), onay ekranında uyarı ve panoda
--  "açık panik" sayacı. Yani bildirim YAPILDIĞINDA iz kalıyor.
--
--  EKSİK OLAN, DENETİMİN ASIL SORDUĞU: bildirim YAPILMAZSA ne oluyor?
--    * Panik değerin ne kadar süredir beklediği hiçbir yerde ölçülmüyor.
--    * `lab_panik_bildirim.yukseltme` kolonu VAR ama hiçbir yerde
--      yazılmıyor/okunmuyor - yükseltme diye bir akış yok (887, 892, 893'te
--      görülen aynı desen: tanım var, işleten yok).
--    * Hekim kendiliğinden haberdar edilmiyor; teknisyen fark ederse
--      telefon ediyor. Panik değer, fark edilmesini bekleyemez.
--
--  BU DOSYA NE GETİRİYOR:
--    1. `v_lab_panik_acik` - açık panikler, geçen dakika ve durumu.
--    2. `fn_lab_panik_tara()` - süre eşiğini aşanı YÜKSELTİR ve hekime /
--       laboratuvar sorumlusuna bildirim kuyruğuna kayıt atar. Zamanlı iş
--       (`lab.panik`) her saat çalışır.
--    3. Eşikler ayardan (`referans`): bildirim süresi ve yükseltme süresi
--       kurumun kendi prosedürüdür - SKS "tanımlı süre" der, sayıyı kurum
--       yazar.
--
--  BİLDİRİM İNSAN İŞİDİR, SİSTEM YERİNE GEÇMEZ. Otomatik bildirim hekimi
--  UYARIR; panik kaydı ancak OKUMA-GERİ teyidi alınınca kapanır (kim, ne
--  zaman, ne dedi). Kuyruğa mesaj atmayı "bildirildi" saymak, denetimde de
--  klinikte de yanlış olurdu.
-- =====================================================================

-- --------------------------------------------------------------- ayar ----
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, 1, 'lab', v.aciklama
  from (values
    ('lab.panik_bildirim_dk', '30',
     'Panik değer kaç dakika içinde hekime bildirilmeli (SKS: tanımlı süre).'),
    ('lab.panik_yukseltme_dk', '60',
     'Bildirilmeyen panik değer kaç dakika sonra üst sorumluya yükseltilir.')
  ) as v(anahtar, deger, aciklama)
 on conflict (anahtar) do nothing;

-- -------------------------------------------------------------- döküm ----
create or replace view public.v_lab_panik_acik as
select r.id as sonuc_id, s.id as satir_id, i.id as istem_id, i.istem_no,
       t.kod, t.ad as tetkik,
       coalesce(nullif(r.deger_metin, ''),
                trim(to_char(r.deger_sayisal, 'FM999999990.999999'))) as deger,
       r.birim, r.bayrak, r.olcum_zamani, r.onay_zamani,
       i.taraf_id as hasta_id,
       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan) as hasta,
       i.personel_id as hekim_id, coalesce(p.unvan, '') as hekim,
       -- SÜRE ÖLÇÜMÜ ÖLÇÜMDEN BAŞLAR, onaydan değil: panik değer onay
       --   beklemez; "sonuç onaylanmadı" bildirimi geciktirmenin gerekçesi
       --   olamaz.
       (extract(epoch from (now() - coalesce(r.olcum_zamani, r.ekleme_tarihi))) / 60)::int
           as gecen_dk,
       b.id as bildirim_id, b.bildirim_zamani, b.bildirilen_ad, b.kanal,
       b.teyit_zamani, b.teyit_eden, coalesce(b.yukseltme, 0) as yukseltme,
       -- 1 hiç bildirilmedi · 2 bildirildi, teyit bekliyor · 3 teyit alındı
       case when b.id is null then 1
            when b.teyit_zamani is null then 2
            else 3 end as durum,
       r.sube_id
  from public.lab_sonuc r
  join public.lab_istem_satir s on s.id = r.istem_satir_id
  join public.lab_istem i on i.id = s.istem_id
  join public.lab_tetkik t on t.id = r.tetkik_id
  left join public.taraf h on h.id = i.taraf_id
  left join public.taraf p on p.id = i.personel_id
  -- EN SON BİLDİRİM: tekrar aranmışsa sonuncusu geçerlidir.
  left join lateral (
        select x.* from public.lab_panik_bildirim x
         where x.sonuc_id = r.id
         order by x.teyit_zamani desc nulls last, x.id desc limit 1) b on true
 where r.panik = 1 and r.durum <> 4
   -- Teyit alınmış panik KAPANMIŞTIR: listede durmaz, kaydı tarihte kalır.
   and (b.id is null or b.teyit_zamani is null);

comment on view public.v_lab_panik_acik is
  '894: acik panik degerler (KTS L2) - gecen dakika, bildirim/teyit durumu, '
  'hekim. Teyit alinan panik listeden duser.';

-- ------------------------------------------------------- tarama / yükselt ----
/**
 * SÜRESİ GEÇEN PANİKLERİ YÜKSELTİR VE BİLDİRİM KUYRUĞUNA KAYIT ATAR.
 *
 * İki eşik: `lab.panik_bildirim_dk` geçtiyse hekime uyarı gider (uygulama
 * içi bildirim), `lab.panik_yukseltme_dk` geçtiyse kayıt YÜKSELTİLİR
 * (`yukseltme = 1`) ve laboratuvar sorumlusuna da bildirim düşer.
 *
 * <b>Aynı sonuç için aynı aşamada İKİNCİ kayıt atılmaz</b> - iş saat başı
 * çalışıyor; her turda yeni bildirim üretmek, kuyruğu anlamsız kılardı.
 *
 * Dönüş: (uyarilan, yukseltilen).
 */
create or replace function public.fn_lab_panik_tara()
returns table(uyarilan integer, yukseltilen integer)
language plpgsql as $fn$
declare
    v_bildirim_dk  integer := coalesce((select deger::int from public.referans
                                         where anahtar = 'lab.panik_bildirim_dk'), 30);
    v_yukselt_dk   integer := coalesce((select deger::int from public.referans
                                         where anahtar = 'lab.panik_yukseltme_dk'), 60);
    v_uyari  integer := 0;
    v_yuksel integer := 0;
    r record;
begin
    for r in
        select * from public.v_lab_panik_acik
         where gecen_dk >= v_bildirim_dk
    loop
        -- 1) HEKİME UYARI: yalnız bir kez (kaynak_tur 7 = laboratuvar).
        if r.hekim_id is not null and r.hekim_id > 0
           and not exists (select 1 from public.bildirim b
                            where b.kaynak_tur = 7 and b.kaynak_id = r.sonuc_id
                              and b.kullanici_id = r.hekim_id) then
            -- KANAL 3 = PUSH (uygulama içi). SMS (1) BİLEREK KULLANILMIYOR:
            --   panik bildirimi telefonla, okuma-geri teyidiyle yapılır;
            --   SMS ne teyit alır ne de hasta adını dışarı taşımamalıdır.
            --   Push sağlayıcısı tanımlı değilse kayıt kuyrukta bekler ve
            --   ekranda görünür - zararsız, ama iz kalır.
            insert into public.bildirim
                   (kanal, alici, kullanici_id, taraf_id, konu, govde,
                    kaynak_tur, kaynak_id, oncelik, durum)
            values (3, '', r.hekim_id, r.hasta_id,
                    'PANİK DEĞER: ' || r.tetkik,
                    r.hasta || ' · ' || r.tetkik || ' = ' || coalesce(r.deger, '')
                      || ' ' || coalesce(r.birim, '')
                      || ' (' || r.gecen_dk || ' dakikadır bildirilmedi). '
                      || 'Laboratuvarla teyitleşin.',
                    7, r.sonuc_id, 1, 1);
            v_uyari := v_uyari + 1;
        end if;

        -- 2) YÜKSELTME: süre iyice geçtiyse kayıt işaretlenir. Bildirim
        --    kaydı yoksa önce "bildirilmedi" kaydı açılır - yükseltmenin
        --    kendisi de bir olaydır, izi kalmalı.
        if r.gecen_dk >= v_yukselt_dk then
            if r.bildirim_id is null then
                insert into public.lab_panik_bildirim
                       (sonuc_id, bildiren_id, bildirilen_ad, kanal, yukseltme, aciklama)
                values (r.sonuc_id, 0, '', 9, 1,
                        'Süresinde bildirilmedi - sistem yükseltti ('
                        || r.gecen_dk || ' dk).');
                v_yuksel := v_yuksel + 1;
            elsif coalesce(r.yukseltme, 0) = 0 then
                update public.lab_panik_bildirim
                   set yukseltme = 1,
                       aciklama = left(coalesce(aciklama, '')
                                  || case when coalesce(aciklama, '') = '' then '' else ' · ' end
                                  || 'Teyit alınmadı, yükseltildi (' || r.gecen_dk || ' dk).', 300)
                 where id = r.bildirim_id;
                v_yuksel := v_yuksel + 1;
            end if;
        end if;
    end loop;

    return query select v_uyari, v_yuksel;
end $fn$;

comment on function public.fn_lab_panik_tara() is
  '894: suresi gecen panik degerleri hekime bildirir ve yukseltir (KTS L2). '
  'Ayni sonuc icin ayni asamada ikinci kayit atmaz.';

-- ---------------------------------------------------------- zamanlı iş ----
--  SAAT BAŞI: panik değer dakikalarla ölçülür; günlük iş anlamsız olurdu.
insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aktif, aciklama)
select 'lab.panik', 'Panik değer takibi ve yükseltme', 1, 1, 0, 25, 1,
       'Süresinde bildirilmemiş panik değerleri hekime bildirir ve üst '
       || 'sorumluya yükseltir (KTS L2).'
 where not exists (select 1 from public.zamanli_is z where z.kod = 'lab.panik');

-- -------------------------------------------------------------- yetki ----
insert into public.yetki (kod, ad, grup, tur, sira, aktif, urun_modu, modul)
select 'lab.panik', 'Panik Değerler', 'Laboratuvar', 0, 55, 1, 2, 'lab'
 where not exists (select 1 from public.yetki y where y.kod = 'lab.panik');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'lab.panik'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

do $$
begin
    raise notice '894 tamam: % acik panik (bildirim esigi % dk)',
        (select count(*) from public.v_lab_panik_acik),
        (select deger from public.referans where anahtar = 'lab.panik_bildirim_dk');
end $$;
