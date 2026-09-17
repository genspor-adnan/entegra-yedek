-- ============================================================================
--  Gentegre AI — DOKÜMAN ONAYI OMURGAYA TAŞINIYOR
--  758_dokuman_onay_omurga.sql
--
--  Kullanıcı: "doküman onayını da omurgaya taşı."
--
--  419'da doküman yönetimi KENDİ akış motorunu getirmişti: `dokuman_akis` +
--  `dokuman_akis_adim` (tanım) ve `dokuman_onay` + `dokuman_onay_adim`
--  (yürüyen süreç). 738'in omurgası yazıldığında bu yapı yerinde bırakılmış,
--  başlığına da "akış motoru ama yalnız dokümana bağlı" notu düşülmüştü.
--
--  Aynı işi yapan iki motor tutmak, her yeni özelliğin (vekâlet, hatırlatma,
--  gelen kutusu, bilgi isteme, sözlü onay) iki kez yazılması demek. Bugün
--  omurgada olan hiçbiri dokümanda yok: doküman onayı kimseye atanmıyor,
--  zil'e düşmüyor, vekâlet tanımıyor ve geciken adımı göstermiyor.
--
--  ============ KAYNAK = SÜRÜM, DOKÜMAN DEĞİL ==========================
--  `kaynak_tur = 976` (`dokuman_surum`), `kaynak_id = surum.id`. Onay bir
--  SÜRÜME verilir: "v3 onaylandı" cümlesi doğrudur, "doküman onaylandı"
--  eksiktir. Omurganın `ux_onay_acik (kaynak_tur, kaynak_id) where durum = 0`
--  kısıtı da bu sayede doğru şeyi korur - aynı dokümanın iki farklı sürümü
--  aynı anda onayda olabilir, aynı sürüm iki kez olamaz.
--
--  ============ YENİ SAHİP TÜRÜ: 4 = KAYDIN SAHİBİ =====================
--  `dokuman_akis_adim.dinamik` üç değer tanımlıyordu: 1 sahip · 2 klasör
--  sorumlusu · 3 bölüm sorumlusu. Bunlardan YALNIZ 1'i uygulanmıştı; 2 ve 3
--  için kod hiç yazılmamış, adım kimseye atanmadan bırakılıyordu.
--
--  Omurgaya `sahip_turu = 4` (kaydın sahibi) ekliyoruz - bu modüle özel
--  değil, genel bir kavram: satınalmada "talebi açan", dokümanda "dosyanın
--  sahibi" aynı basamak türüdür. Klasör/bölüm sorumlusu TAŞINMIYOR: var
--  olmayan bir davranışı göç sırasında uydurmak, çalıştığı sanılan ama hiç
--  denenmemiş bir kural bırakırdı. O adımlar bugünkü davranışlarını koruyor
--  (rol basamağı, kimseye atanmamış).
--
--  ============ KARARIN SONUCUNU MODÜL YAZAR ===========================
--  Zincir bitince sürümü yayınlamak (öncekini arşive düşürmek, başlık
--  hash/sürüm no'sunu güncellemek) ya da reddetmek dokümanın kendi işi.
--  Bu mantık C# içinde `YayinlaIcAsync`'teydi ve omurga oradan çağıramazdı;
--  `fn_dokuman_onay_sonuc`a taşındı - iskontodaki `fn_iskonto_talep_karar`
--  ile aynı desen: satıra yazan tek yer, onu da yalnız omurga çağırır.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) SAHİP TÜRÜ 4 BELGELENİR
-- ---------------------------------------------------------------------------
comment on column public.onay_akis_adim.sahip_turu is
  '738/758: 1 rol · 2 kullanici · 3 amir (taraf_personel.yonetici_taraf_id) · '
  '4 kaydin sahibi (BaslatAsync sahipTarafId).';
comment on column public.onay_adim.sahip_turu is
  '738/758: 1 rol · 2 kullanici · 3 amir · 4 kaydin sahibi. Cozum ZINCIR '
  'KURULURKEN yapilir; atanan_kullanici_id sonradan degismez.';

-- ---------------------------------------------------------------------------
--  2) YETKİ
--     Doküman akış adımlarında `rol_id` bugün hiç kullanılmıyor (hepsi NULL),
--     bu yüzden basamak başına ayrı yetki kodu ÜRETMİYORUZ - tek bir karar
--     yetkisi var. Rol bazlı ayrım gerektiğinde buraya kod eklenir.
-- ---------------------------------------------------------------------------
insert into public.yetki (kod, ad, grup, tur, aktif)
select 'dokuman.onay', 'Doküman onayı - karar verme', 'Doküman', 0, 1
 where not exists (select 1 from public.yetki where kod = 'dokuman.onay');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod in ('yonetici', 'kalite')
   and y.kod = 'dokuman.onay'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ---------------------------------------------------------------------------
--  3) AKIŞ TANIMI TAŞINIR
--     Her doküman akışı omurgada bir `onay_akis` satırı olur. Kod
--     `dokuman.<id>` biçiminde üretiliyor: akış adları kullanıcı tarafından
--     değiştirilebilir, koda ad koymak göçü tekrarlanamaz yapardı.
--
--     ÖLÇÜ YOK: dokümanda eşiğe konu bir sayı (tutar, gün, oran) yok; bütün
--     basamaklar koşulsuz. `olcu_adi` boş bırakılıyor ve gelen kutusu ölçü
--     sütununu boş gösteriyor - uydurma bir "1" yazmak, ekranda anlamsız bir
--     sayı bırakırdı.
-- ---------------------------------------------------------------------------
insert into public.onay_akis (kod, ad, kaynak_tur, olcu_adi, aktif, aciklama, ekleyen)
select 'dokuman.' || a.id::text, a.ad, 976, '', 1,
       '419 dokuman akisinin omurga karsiligi (758). Kaynak dokuman_surum.', 0
  from public.dokuman_akis a
 where not exists (select 1 from public.onay_akis k
                    where k.kod = 'dokuman.' || a.id::text);

insert into public.onay_akis_adim
       (akis_id, sira, ad, sahip_turu, rol, kullanici_id, esik_alt, bayrak,
        karar_turu, sure_gun, e_imza_zorunlu, aktif, ekleyen)
select k.id, d.sira, d.ad,
       -- 4 = kaydın sahibi (dinamik 1) · 2 = belirli kullanıcı · 1 = rol.
       --   Klasör/bölüm sorumlusu (dinamik 2/3) hiç uygulanmamıştı: rol
       --   basamağı olarak, kimseye atanmadan taşınıyor.
       case when d.dinamik = 1        then 4
            when d.kullanici_id is not null then 2
            else 1 end,
       coalesce(d.rol_id, 0)::smallint,
       d.kullanici_id, null, '',
       d.karar_turu, d.sure_gun, d.e_imza_zorunlu, 1, 0
  from public.dokuman_akis_adim d
  join public.onay_akis k on k.kod = 'dokuman.' || d.akis_id::text
 where not exists (select 1 from public.onay_akis_adim a
                    where a.akis_id = k.id and a.sira = d.sira);

-- `dokuman.akis_id` ARTIK OMURGANIN AKIŞINI GÖSTERİR: iki ayrı akış tanımı
--   tutmak, birini güncelleyip ötekini unutmaya davetiye olurdu.
update public.dokuman d
   set akis_id = k.id
  from public.onay_akis k
 where k.kod = 'dokuman.' || d.akis_id::text
   and d.akis_id is not null;

comment on column public.dokuman.akis_id is
  '758: ARTIK onay_akis.id (onceden dokuman_akis.id).';

-- KATEGORİNİN AKIŞI DA: yeni doküman türünün akışı buradan kopyalanıyor;
--   burayı güncellemeseydik bundan sonra açılan her doküman var olmayan bir
--   akışı gösterir ve onaya hiç gönderilemezdi.
update public.dokuman_kategori t
   set akis_id = k.id
  from public.onay_akis k
 where k.kod = 'dokuman.' || t.akis_id::text
   and t.akis_id is not null;

comment on column public.dokuman_kategori.akis_id is
  '758: ARTIK onay_akis.id (onceden dokuman_akis.id).';

-- ---------------------------------------------------------------------------
--  4) YÜRÜYEN VE BİTMİŞ SÜREÇLER TAŞINIR
--     Durum eşlemesi: dokuman_onay 1 sürüyor / 2 tamamlandı / 3 reddedildi /
--     4 geri çekildi  ->  onay 0 / 1 / 2 / 3.
-- ---------------------------------------------------------------------------
insert into public.onay (akis_id, kaynak_tur, kaynak_id, sube_id, olcu, bayraklar,
                         durum, baslatan_id, baslama, bitis, ekleyen, ekleme_tarihi)
select k.id, 976, o.surum_id, 0, 0, '',
       case o.durum when 1 then 0 when 2 then 1 when 3 then 2 else 3 end,
       o.baslatan_id, o.baslama, o.bitis, 0, o.baslama
  from public.dokuman_onay o
  join public.onay_akis k on k.kod = 'dokuman.' || o.akis_id::text
 where o.surum_id is not null
   and not exists (select 1 from public.onay n
                    where n.kaynak_tur = 976 and n.kaynak_id = o.surum_id);

-- Adım durumu: dokuman_onay_adim.karar 0 bekliyor / 1 onay / 2 ret /
--   3 geri gönder  ->  onay_adim.durum 0 / 1 / 2 / 3 (bilgi istendi).
--   SIRASI GEÇİLMİŞ ama kararı yazılmamış adım KALMAZ: reddedilen zincirde
--   arkadaki basamaklar 5 (atlandı) olur - omurgada ret zinciri kapatır.
insert into public.onay_adim (onay_id, sira, ad, sahip_turu, rol,
                              atanan_kullanici_id, durum, karar_veren_id,
                              karar_zamani, gerekce, ekleyen, ekleme_tarihi)
select n.id, a.sira, a.ad,
       case when a.atanan_kullanici_id is not null then 2 else 1 end,
       coalesce(a.atanan_rol_id, 0)::smallint,
       a.atanan_kullanici_id,
       case when a.karar in (1, 2, 3) then a.karar
            when o.durum in (2, 3) then 5      -- kapanmış zincirin artığı
            else 0 end,
       a.karar_veren_id, a.karar_zamani, a.not_metni, 0, o.baslama
  from public.dokuman_onay_adim a
  join public.dokuman_onay o on o.id = a.onay_id
  join public.onay n on n.kaynak_tur = 976 and n.kaynak_id = o.surum_id
 where not exists (select 1 from public.onay_adim x
                    where x.onay_id = n.id and x.sira = a.sira);

comment on table public.dokuman_onay is
  '419: ESKI dokuman onay sureci - 758 omurgasina tasindi (onay/onay_adim). '
  'Veri korunuyor; yeni yazma buraya YAPILMAZ.';
comment on table public.dokuman_akis is
  '419: ESKI dokuman akis tanimi - 758 omurgasina tasindi (onay_akis). '
  'Veri korunuyor; yeni yazma buraya YAPILMAZ.';

-- ---------------------------------------------------------------------------
--  5) KARARIN SONUCU: yayın ya da ret
--     Tek fonksiyon, çünkü "önceki yayını arşivle" ile "bu sürümü yayınla"
--     ayrılamaz: biri olup öteki olmazsa ya iki yayın ya hiç yayın kalır -
--     ve "hangisi yürürlükte" sorusu cevapsız kalır.
-- ---------------------------------------------------------------------------
create or replace function public.fn_dokuman_onay_sonuc(
    p_surum_id  integer,
    p_onaylandi smallint,        -- 1 onay · 0 ret
    p_not       varchar,
    p_kullanici integer)
returns void language plpgsql as $$
declare
  v_dokuman int;
  v_yayin   int;
begin
    select s.dokuman_id into v_dokuman
      from public.dokuman_surum s where s.id = p_surum_id;
    if v_dokuman is null then
        raise exception 'Doküman sürümü bulunamadı: %', p_surum_id
              using errcode = 'GK404';
    end if;

    if p_onaylandi = 1 then
        -- ÖNCEKİ YAYIN ARŞİVE: yayında en fazla bir sürüm olabilir
        --   (ux_dokuman_surum_yayin).
        update public.dokuman_surum
           set durum = 4, arsiv_tarihi = now()
         where dokuman_id = v_dokuman and durum = 3 and id <> p_surum_id;

        update public.dokuman_surum
           set durum = 3, yayin_tarihi = coalesce(yayin_tarihi, now())
         where id = p_surum_id;

        -- BAŞLIKTAKİ HASH ŞART: kart galerisi ve indirme ucu oradan okur;
        --   güncellenmezse onaylanan sürüm hiç görünmez.
        update public.dokuman d
           set hash = s.hash, content_type = s.content_type, boyut = s.boyut,
               surum_no = s.surum_no, durum = 3, degistirme_tarihi = now()
          from public.dokuman_surum s
         where s.id = p_surum_id and d.id = v_dokuman and s.hash <> '';

        insert into public.dokuman_olay (dokuman_id, surum_id, kullanici_id, olay, gerekce)
        values (v_dokuman, p_surum_id, p_kullanici, 9, coalesce(p_not, ''));
    else
        -- RET: sürüm reddedilir, hazırlayan düzeltip YENİ sürüm açar.
        --   Reddedilen sürümü yeniden onaya göndermek, neyin değiştiğini
        --   görünmez kılardı.
        update public.dokuman_surum set durum = 5 where id = p_surum_id;

        -- ÖNCEKİ YAYIN YÜRÜRLÜKTE KALIR: doküman ancak hiç yayını yoksa
        --   taslağa döner.
        select count(*) into v_yayin from public.dokuman_surum s
         where s.dokuman_id = v_dokuman and s.durum = 3;

        update public.dokuman
           set durum = case when v_yayin > 0 then 3 else 1 end,
               degistirme_tarihi = now()
         where id = v_dokuman;

        insert into public.dokuman_olay (dokuman_id, surum_id, kullanici_id, olay, gerekce)
        values (v_dokuman, p_surum_id, p_kullanici, 8, coalesce(p_not, ''));
    end if;
end $$;

comment on function public.fn_dokuman_onay_sonuc is
  '758: zincir bitince surumu yayinlar ya da reddeder. YALNIZ onay omurgasi '
  'cagirir; yayin ve arsiv ayrilamaz iki istir.';

-- ---------------------------------------------------------------------------
--  6) GELEN KUTUSU DOKÜMANI DA TANISIN
--     Konu = doküman adı + sürüm no: onaylayanın sorusu "hangi belge, kaçıncı
--     sürüm" - kod tek başına hangi metni imzaladığını söylemez.
-- ---------------------------------------------------------------------------
create or replace view public.v_onay_kutusu as
select v.adim_id                                as id,
       v.onay_id, v.kaynak_tur, v.kaynak_id, v.sube_id,
       v.akis_kod, v.akis_ad, v.olcu, v.olcu_adi, v.sira, v.adim_ad, v.rol,
       v.atanan_kullanici_id, v.durum, v.gerekce, v.baslama, v.termin,
       v.gecikme_gun,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.talep_no, ''), '#' || v.kaynak_id::text)
            when 904  then coalesce(nullif(z.izin_no, ''), 'İzin #' || v.kaynak_id::text)
            when 1224 then coalesce(nullif(w.is_emri_no, ''),
                                    'İş emri #' || v.kaynak_id::text)
            when 1257 then coalesce(nullif(av.avans_no, ''),
                                    'Avans #' || v.kaynak_id::text)
            when 1256 then coalesce(nullif(ib.belge_no, ''),
                                    'Başvuru #' || coalesce(isk.belge_id, 0)::text)
            when 976  then coalesce(nullif(dk.kod, ''), 'DOK-' || dk.id::text)
                           || ' v' || ds.surum_no::text
            else '#' || v.kaynak_id::text
       end                                      as kayit_no,
       case v.kaynak_tur
            when 1241 then coalesce(nullif(t.gerekce, ''), 'Satınalma talebi')
            when 904  then case z.tur when 1 then 'Yıllık izin'
                                      when 2 then 'Mazeret izni'
                                      when 3 then 'Rapor'
                                      when 4 then 'Ücretsiz izin'
                                      else 'İzin' end
                           || ' · ' || to_char(z.baslangic_tarihi, 'DD.MM')
                           || '-' || to_char(z.bitis_tarihi, 'DD.MM.YYYY')
            when 1224 then coalesce(nullif(dm.ad, ''), 'Cihaz')
                           || ' · ' || coalesce(nullif(w.ariza_metni, ''), 'onarım')
            when 1257 then coalesce(nullif(av.gerekce, ''), 'Avans')
                           || ' · ' || av.taksit_sayisi::text || ' taksit'
            when 1256 then coalesce(nullif(isk.gerekce, ''), 'İskonto talebi')
                           || ' · ' || (select count(*)::text
                                          from public.iskonto_talep_satir ts
                                         where ts.talep_id = isk.id) || ' kalem'
            when 976  then coalesce(nullif(dk.ad, ''), 'Doküman')
                           || coalesce(' · ' || nullif(ds.degisiklik_notu, ''), '')
            else ''
       end                                      as konu,
       case v.kaynak_tur
            when 1241 then coalesce(d.ad, '')
            when 904  then coalesce(nullif(zp.gorev, ''), '')
            when 1224 then coalesce(wd.ad, '')
            when 1257 then coalesce(nullif(ap.gorev, ''), '')
            when 1256 then coalesce(ih.unvan, '')
            when 976  then coalesce(dkat.ad, '')
            else ''
       end                                      as birim,
       case v.kaynak_tur
            when 1241 then coalesce(p.unvan, '')
            when 904  then coalesce(zt.unvan, '')
            when 1224 then coalesce(wb.unvan, '')
            when 1257 then coalesce(at.unvan, '')
            when 1256 then coalesce(ii.unvan, '')
            when 976  then coalesce(dy.unvan, '')
            else ''
       end                                      as talep_eden
  from public.v_onay_bekleyen v
  left join public.satinalma_talep t on v.kaynak_tur = 1241 and t.id = v.kaynak_id
  left join public.departman d on d.id = t.departman_id
  left join public.taraf p     on p.id = t.isteyen_id
  left join public.personel_izin z on v.kaynak_tur = 904 and z.id = v.kaynak_id
  left join public.taraf zt          on zt.id = z.taraf_id
  left join public.taraf_personel zp on zp.id = z.taraf_id
  left join public.demirbas_is_emri w on v.kaynak_tur = 1224 and w.id = v.kaynak_id
  left join public.demirbas dm  on dm.id = w.demirbas_id
  left join public.departman wd on wd.id = w.departman_id
  left join public.taraf wb     on wb.id = w.bildiren_id
  left join public.personel_avans av on v.kaynak_tur = 1257 and av.id = v.kaynak_id
  left join public.taraf at          on at.id = av.taraf_id
  left join public.taraf_personel ap on ap.id = av.taraf_id
  left join public.iskonto_talep isk on v.kaynak_tur = 1256 and isk.id = v.kaynak_id
  left join public.belge ib on ib.id = isk.belge_id
  left join public.taraf ih on ih.id = ib.taraf_id
  left join public.taraf ii on ii.id = isk.isteyen_id
  left join public.dokuman_surum ds on v.kaynak_tur = 976 and ds.id = v.kaynak_id
  left join public.dokuman dk        on dk.id = ds.dokuman_id
  left join public.dokuman_kategori dkat on dkat.id = dk.kategori_id
  left join public.taraf dy          on dy.id = ds.yukleyen_id;

comment on view public.v_onay_kutusu is
  '739/744/752/753/754/755/758: butun modullerin bekleyen onaylari (satinalma '
  'talebi · izin · masrafli onarim · avans · iskonto · dokuman surumu).';

do $$
declare v_akis int; v_onay int; v_adim int;
begin
    select count(*) into v_akis from public.onay_akis where kaynak_tur = 976;
    select count(*) into v_onay from public.onay where kaynak_tur = 976;
    select count(*) into v_adim from public.onay_adim a
      join public.onay n on n.id = a.onay_id where n.kaynak_tur = 976;
    raise notice '758 tamam: dokuman omurgada (akis %, zincir %, basamak %).',
                 v_akis, v_onay, v_adim;
end $$;

-- ---------------------------------------------------------------------------
--  7) KARTIN "ONAY AKIŞI" SEKMESİ VE AKIŞ SEÇİM LİSTESİ OMURGADAN OKUSUN
--     Görünümlerin ADI ve KOLONLARI korunuyor: kart tanımı, liste kaynağı ve
--     beyaz liste onları adıyla tanıyor. Değişen yalnız NEREDEN okudukları -
--     eski tablolar artık yazılmıyor, oradan okumak kartı boş bırakırdı.
-- ---------------------------------------------------------------------------
create or replace view public.v_dokuman_akis_lookup as
select k.id,
       k.kod::text                        as kod,
       k.ad::varchar(80)                  as ad,
       k.aktif
  from public.onay_akis k
 where k.kaynak_tur = 976;

comment on view public.v_dokuman_akis_lookup is
  '419/758: dokuman akis secim listesi - artik onay_akis (kaynak_tur 976).';

-- Kolon adları 419'daki haliyle: `karar` (adım kararı), `onay_durum`,
--   `guncel_adim`. Omurgada karşılıkları `onay_adim.durum`, `onay.durum` ve
--   "sırası gelen basamak" - eşleme burada yapılıyor ki kart tanımına
--   dokunmak gerekmesin.
-- TİPLER KORUNUYOR: omurgada `onay_adim.id` / `onay.id` bigint, eski
--   görünümde integer'dı ve `create or replace` tip değişikliğini reddeder.
--   Daraltma güvenli - kart tanımı zaten integer bekliyor.
create or replace view public.v_dokuman_onay_adim as
select a.id::integer                      as id,
       s.dokuman_id,
       n.id::integer                      as onay_id,
       s.surum_no,
       a.sira,
       a.ad,
       a.durum                            as karar,
       a.karar_veren_id,
       a.karar_zamani,
       a.gerekce                          as not_metni,
       -- onay.durum 0/1/2/3 -> eski 1 süren / 2 tamamlandı / 3 reddedildi /
       --   4 geri çekildi.
       (case n.durum when 0 then 1 when 1 then 2 when 2 then 3 else 4 end)::smallint
                                          as onay_durum,
       coalesce((select min(x.sira) from public.onay_adim x
                  where x.onay_id = n.id and x.durum in (0, 3)),
                a.sira)::smallint         as guncel_adim,
       n.baslama
  from public.onay_adim a
  join public.onay n on n.id = a.onay_id and n.kaynak_tur = 976
  join public.dokuman_surum s on s.id = n.kaynak_id;

comment on view public.v_dokuman_onay_adim is
  '419/758: dokuman kartinin "Onay Akisi" sekmesi - artik onay/onay_adim.';
