-- =============================================================================
--  1146  DELPHI AKTARIMI - DÖKÜMANLAR + EKLER (IMAJ) + e-BELGE GEÇMİŞİ  (FETA geçişi)
--
--  Bir kerelik aktarım (1143; db/araclar/aktar_ek.ps1 stg'yi doldurur, fn_aktar_ek
--  çağırır). Web yüklemesinin yazdığını yazar (DokumanDeposu.EkleAsync +
--  DokumanYonetimUclari klasöre yükleme): dokuman_icerik (sha256 BÜYÜK harf hex,
--  tekilleştirilmiş), dokuman, dokuman_surum, ek bağlar dokuman_iliski'de.
--
--  DOKUMAN (Delphi döküman modülü) -> KURUMSAL döküman: kaynak 'klasor', kaynak_id =
--    klasör. Delphi dökümanlarının çoğu bir klasörde DEĞİL, bir kaydın eki
--    (FETA: MODUL 12 aktivite 236, 210 görev yorumu 194; KLASOR boş ya da modülün
--    sanal klasörü < 0). Hepsi "Delphi Arşivi" kök klasörü altına (Aktivite Ekleri /
--    Görev Yorum Ekleri / Genel); Delphi DOKUMANKLASOR ağacı da aynı kökün altına.
--    Bağlı olduğu kayıt dokuman_iliski'ye: cari (REHBERID), aktivite / görev (MODUL
--    12, yorumun görevi 210), yorumun carisi / projesi. Görev henüz aktarılmadıysa
--    bağ sonraki çalıştırmada kurulur ('bag_bekleyen').
--  Sürümler: dökümanın her IMAJ satırı (YERI=1) bir dokuman_surum; yürürlükteki =
--    VARSAYILAN, yoksa en büyük SURUM (3 yayında), diğerleri 4 arşiv.
--  İÇERİĞİ OLMAYAN döküman (ICDIS=1, .OBJ müşterinin diskinde, FETA'da 266 satır)
--    KARTSIZ kalır: dokuman.hash NOT NULL + dokuman_icerik FK - boş kart açılamaz.
--    Klasör verilip aktar_ek.ps1 yeniden çalıştırılınca açılır ('icerik_yok').
--  Kayıt ekleri (IMAJ YERI): 71/72 REHBER -> 'taraf', 88 STOKLAR -> 'stok', 402
--    FATBASLIK -> 'belge'. Diğer YERI'ler (aktivite resmi 12, çek 15/21, kredi 65,
--    kart logosu 132, duyuru 151, bilinmeyen 0/3/13/22/31) web'de karşılığı olan bir
--    kaynak/kart olmadığı için aktarılmaz ('eslesmeyen_yer').
--
--  e-BELGE (GENDEPO.EBELGE / EBELGEMESAJ) -> e_belge / e_belge_mesaj: belge_turu
--    151 e-Fatura -> 1, 150 e-Arşiv -> 2; durum Delphi 2 (gönderildi) -> 2 / 12
--    (web e_belge.durum = belge.efatura_durum kodları). Web'in kendi yazdığı aynı
--    UUID'li satıra dokunulmaz.
-- =============================================================================

begin;

-- İçerik türü: önce dosyanın imzası, sonra uzantı (web yüklemesinin beyaz listesi).
create or replace function public.fn_aktarim_icerik_tipi(p_ad text, p_icerik bytea)
returns varchar language sql immutable as $f$
    select case
        when substring(p_icerik from 1 for 4) = '\x25504446'::bytea then 'application/pdf'
        when substring(p_icerik from 1 for 3) = '\xffd8ff'::bytea then 'image/jpeg'
        when substring(p_icerik from 1 for 4) = '\x89504e47'::bytea then 'image/png'
        when substring(p_icerik from 1 for 4) = '\x47494638'::bytea then 'image/gif'
        when substring(p_icerik from 1 for 2) = '\x424d'::bytea then 'image/bmp'
        when substring(p_icerik from 1 for 4) in ('\x49492a00'::bytea, '\x4d4d002a'::bytea) then 'image/tiff'
        when substring(p_icerik from 1 for 5) = '\x7b5c727466'::bytea then 'application/rtf'
        when substring(p_icerik from 1 for 4) = '\xd0cf11e0'::bytea then
            case e.uz when 'xls' then 'application/vnd.ms-excel' when 'ppt' then 'application/vnd.ms-powerpoint'
                      when 'msg' then 'application/octet-stream' else 'application/msword' end
        when substring(p_icerik from 1 for 2) = '\x504b'::bytea then
            case e.uz when 'docx' then 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                      when 'xlsx' then 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                      when 'pptx' then 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
                      when 'odt' then 'application/vnd.oasis.opendocument.text'
                      when 'ods' then 'application/vnd.oasis.opendocument.spreadsheet'
                      else 'application/zip' end
        else case e.uz when 'xml' then 'text/xml' when 'txt' then 'text/plain' when 'csv' then 'text/csv'
                       when 'json' then 'application/json' when 'rar' then 'application/vnd.rar'
                       when '7z' then 'application/x-7z-compressed' when 'rtf' then 'application/rtf'
                       when 'pdf' then 'application/pdf' when 'jpg' then 'image/jpeg' when 'jpeg' then 'image/jpeg'
                       when 'png' then 'image/png'
                       else 'application/octet-stream' end
    end
      from (select lower(substring(btrim(coalesce(p_ad, '')) from '\.([A-Za-z0-9]{1,5})$')) as uz) e
$f$;
comment on function public.fn_aktarim_icerik_tipi(text, bytea) is
    '1146: Delphi ekinin içerik türü - dosya imzası, yoksa uzantı.';

-- ============================================================== dökümanlar ===
create or replace function public.fn_aktar_ek_dokuman()
returns jsonb language plpgsql as $$
declare
    v_sube int := coalesce((select min(id) from public.sube where aktif = 1), 1);
    v_kok int; v_k1 int; v_k2 int; v_k3 int;
    v_klasor int := 0; v_icerik int := 0; v_de int := 0; v_dg int := 0; v_yok int := 0;
    v_se int := 0; v_sg int := 0; v_ie int := 0; v_ig int := 0; v_bekleyen int := 0;
    v_ee int := 0; v_eg int := 0; v_eyok int := 0; v_eslesmeyen jsonb;
begin
    perform set_config('gentegre.aktarim', '1', true);

    -- 1) klasörler: kök + modül klasörleri (Delphi kimliği <= 0) + Delphi ağacı
    create temp table if not exists _ekk on commit drop as
        select k.* from public.dokuman_klasor k with no data;
    truncate _ekk;
    insert into _ekk (aktarim_id, ust_id, ad, aktif) values (0, null, 'Delphi Arşivi', 1);
    select eklenen + guncellenen into v_klasor
      from public.fn_aktarim_esitle('dokuman_klasor', 'DOKUMANKLASOR', '_ekk', array['ust_id', 'ad', 'aktif']);
    -- kök Delphi kimliği 0 (fn_aktarim_web_id 0'ı "yok" sayar): doğrudan
    v_kok := (select id from public.dokuman_klasor
               where aktarim_kaynak = 1 and aktarim_tablo = 'DOKUMANKLASOR' and aktarim_id = 0);

    truncate _ekk;
    insert into _ekk (aktarim_id, ust_id, ad, aktif, sira) values
        (-1, v_kok, 'Genel', 1, 1), (-12, v_kok, 'Aktivite Ekleri', 1, 2), (-210, v_kok, 'Görev Yorum Ekleri', 1, 3);
    v_klasor := v_klasor + (select eklenen + guncellenen
      from public.fn_aktarim_esitle('dokuman_klasor', 'DOKUMANKLASOR', '_ekk', array['ust_id', 'ad', 'aktif', 'sira']));
    truncate _ekk;
    -- Delphi ağacı: önce hepsi kökün altına, sonra üst bağları (sıra bağımsız)
    insert into _ekk (aktarim_id, ust_id, ad, aktif)
    select k.id, v_kok, left(coalesce(nullif(btrim(k.ad), ''), 'Klasör ' || k.id), 150),
           case when coalesce(k.durum, 1) = 0 then 0 else 1 end
      from stg.dokumanklasor k where k.id > 0;
    v_klasor := v_klasor + (select eklenen + guncellenen
      from public.fn_aktarim_esitle('dokuman_klasor', 'DOKUMANKLASOR', '_ekk', array['ad', 'aktif']));
    update public.dokuman_klasor x set ust_id = coalesce(u.id, v_kok)
      from stg.dokumanklasor k
      left join public.dokuman_klasor u on u.aktarim_kaynak = 1 and u.aktarim_tablo = 'DOKUMANKLASOR'
                                       and u.aktarim_id = k.ustid and k.ustid > 0 and k.ustid <> k.id
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'DOKUMANKLASOR' and x.aktarim_id = k.id
       and x.ust_id is distinct from coalesce(u.id, v_kok);
    v_k1 := (select id from public.dokuman_klasor where aktarim_kaynak = 1 and aktarim_tablo = 'DOKUMANKLASOR' and aktarim_id = -1);
    v_k2 := (select id from public.dokuman_klasor where aktarim_kaynak = 1 and aktarim_tablo = 'DOKUMANKLASOR' and aktarim_id = -12);
    v_k3 := (select id from public.dokuman_klasor where aktarim_kaynak = 1 and aktarim_tablo = 'DOKUMANKLASOR' and aktarim_id = -210);

    -- 2) içerikli IMAJ satırları (ham; hash = web'in sha256 büyük harf hex'i)
    create temp table if not exists _eki on commit drop as
        select i.id, i.yeri, i.yer_id, i.varsayilan, i.surum, i.belgeadi, i.ekleyen, i.eklemetarihi, i.subeid,
               i.aciklama, i.icerik, ''::varchar(64) as hash, ''::varchar(100) as tip, 0 as boyut
          from stg.imaj i with no data;
    truncate _eki;
    insert into _eki
    select i.id, i.yeri, i.yer_id, i.varsayilan, i.surum, i.belgeadi, i.ekleyen, i.eklemetarihi, i.subeid,
           i.aciklama, i.icerik, upper(encode(sha256(i.icerik), 'hex')),
           public.fn_aktarim_icerik_tipi(i.belgeadi, i.icerik), length(i.icerik)
      from stg.imaj i
     where i.icerik is not null and length(i.icerik) > 0;

    insert into public.dokuman_icerik (hash, icerik, content_type, boyut, referans_sayisi)
    select distinct on (e.hash) e.hash, e.icerik, e.tip, e.boyut, 0
      from _eki e
     where e.yeri in (1, 71, 72, 88, 402)
     order by e.hash, e.id
    on conflict (hash) do nothing;
    get diagnostics v_icerik = row_count;

    -- 3) DOKUMAN kartları: yürürlükteki sürüm = VARSAYILAN, yoksa en büyük SURUM
    create temp table if not exists _eks on commit drop as
        select e.*, 0::smallint as no, false as son from _eki e with no data;
    truncate _eks;
    insert into _eks
    select e.*, (row_number() over (partition by e.yer_id
                   order by coalesce(nullif(regexp_replace(e.surum, '[^0-9.]', '', 'g'), '')::numeric, 0), e.id))::smallint,
           false
      from _eki e where e.yeri = 1;
    update _eks s set son = true
      from (select distinct on (yer_id) id from _eks
             order by yer_id, coalesce(varsayilan, 0) desc, no desc) x
     where x.id = s.id;

    create temp table if not exists _ekd on commit drop as
        select d.* from public.dokuman d with no data;
    truncate _ekd;
    insert into _ekd (aktarim_id, kaynak, kaynak_id, ad, content_type, boyut, hash, sube_id, ekleyen,
                      ekleme_tarihi, yon, durum, kod, klasor_id, aciklama, etiketler, gizlilik, sahip_id,
                      surum_no, gecerli_bit, belge_turu)
    select d.id, 'klasor', k.klasor,
           left(case when btrim(coalesce(d.ad, '')) = '' then btrim(s.belgeadi)
                     when btrim(d.ad) !~ '\.[A-Za-z0-9]{1,5}$' and btrim(s.belgeadi) ~ '\.[A-Za-z0-9]{1,5}$'
                     then btrim(d.ad) || substring(btrim(s.belgeadi) from '(\.[A-Za-z0-9]{1,5})$')
                     else btrim(d.ad) end, 200),
           s.tip, s.boyut, s.hash,
           coalesce(public.fn_aktarim_sube(d.subeid), v_sube),
           coalesce(public.fn_aktarim_kisi_id(d.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(d.eklemetarihi), public.fn_aktarim_zaman(d.tarih), timestamptz '1901-01-01'),
           case when d.yon in (1, 2) then d.yon else 0 end,
           3,
           case when btrim(coalesce(d.belgeno, '')) = '' then ''
                when count(*) over (partition by btrim(d.belgeno)) = 1 then left(btrim(d.belgeno), 30)
                else left(btrim(d.belgeno), 30 - length('-' || d.id)) || '-' || d.id end,
           k.klasor,
           left(btrim(coalesce(d.konu, '')), 400),
           coalesce((select array_agg(distinct left(btrim(t), 40)::varchar(40))
                       from regexp_split_to_table(coalesce(d.anahtar, ''), '[,;]') t where btrim(t) <> ''),
                    '{}'),
           case when d.gizlilikderecesi in (3, 4) then 3 when d.gizlilikderecesi = 5 then 4 else 2 end,
           public.fn_aktarim_kisi_id(d.ekleyen),
           s.no,
           (public.fn_aktarim_zaman(d.gecerlilik_tarihi) at time zone 'Europe/Istanbul')::date,
           left(btrim(coalesce(d.kategori, '')), 80)
      from stg.dokuman d
      join _eks s on s.yer_id = d.id and s.son
      cross join lateral (select case when coalesce(d.klasor, 0) > 0 and exists
                                          (select 1 from stg.dokumanklasor x where x.id = d.klasor)
                                     then (select id from public.dokuman_klasor
                                            where aktarim_kaynak = 1 and aktarim_tablo = 'DOKUMANKLASOR'
                                              and aktarim_id = d.klasor)
                                     when d.modul = 12 then v_k2 when d.modul = 210 then v_k3
                                     else v_k1 end as klasor) k;
    v_yok := (select count(*) from stg.dokuman d where not exists (select 1 from _eks s where s.yer_id = d.id));

    -- web'in kendi dökümanında kullanılan kod çakışırsa Delphi kimliği eklenir
    update _ekd w set kod = left(w.kod, 30 - length('-' || w.aktarim_id)) || '-' || w.aktarim_id
     where w.kod <> '' and exists (select 1 from public.dokuman x where x.kod = w.kod
                                     and not (x.aktarim_kaynak = 1 and x.aktarim_tablo = 'DOKUMAN'
                                              and x.aktarim_id = w.aktarim_id));

    select eklenen, guncellenen into v_de, v_dg from public.fn_aktarim_esitle('dokuman', 'DOKUMAN', '_ekd',
        array['kaynak', 'kaynak_id', 'ad', 'content_type', 'boyut', 'hash', 'sube_id', 'ekleyen', 'ekleme_tarihi',
              'yon', 'durum', 'kod', 'klasor_id', 'aciklama', 'etiketler', 'gizlilik', 'sahip_id', 'surum_no',
              'gecerli_bit', 'belge_turu']);

    -- 4) sürümler
    create temp table if not exists _eksw on commit drop as
        select s.* from public.dokuman_surum s with no data;
    truncate _eksw;
    insert into _eksw (aktarim_id, dokuman_id, surum_no, hash, content_type, boyut, degisiklik_notu,
                       yukleyen_id, yukleme, durum, yayin_tarihi, arsiv_tarihi)
    select s.id, x.id, s.no, s.hash, s.tip, s.boyut,
           left(btrim(coalesce('Delphi sürüm ' || nullif(btrim(s.surum), ''), '') ||
                      coalesce(' · ' || nullif(btrim(s.aciklama), ''), '')), 400),
           coalesce(public.fn_aktarim_kisi_id(s.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(s.eklemetarihi), x.ekleme_tarihi),
           case when s.son then 3 else 4 end,
           coalesce(public.fn_aktarim_zaman(s.eklemetarihi), x.ekleme_tarihi),
           case when s.son then null else coalesce(public.fn_aktarim_zaman(s.eklemetarihi), x.ekleme_tarihi) end
      from _eks s
      join public.dokuman x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'DOKUMAN' and x.aktarim_id = s.yer_id;
    -- yayın (durum 3) dokuman başına tek: önce eski yayınlar arşive, sonra eşitle
    update public.dokuman_surum t set durum = 4
      from _eksw w
     where t.aktarim_kaynak = 1 and t.aktarim_tablo = 'IMAJ' and t.aktarim_id = w.aktarim_id
       and t.durum = 3 and w.durum <> 3;
    select eklenen, guncellenen into v_se, v_sg from public.fn_aktarim_esitle('dokuman_surum', 'IMAJ', '_eksw',
        array['dokuman_id', 'surum_no', 'hash', 'content_type', 'boyut', 'degisiklik_notu', 'yukleyen_id',
              'yukleme', 'durum', 'yayin_tarihi', 'arsiv_tarihi']);

    -- 5) bağlar: cari, aktivite / görev, yorumun carisi / projesi
    create temp table if not exists _ekb on commit drop as
        select i.* from public.dokuman_iliski i with no data;
    truncate _ekb;
    create temp table if not exists _ekb0 (aktarim_id bigint, dokuman_id int, kaynak varchar(20),
                                           kaynak_id int, rol varchar(60), cozuldu boolean) on commit drop;
    truncate _ekb0;
    insert into _ekb0
    select v.aktarim_id, x.id, v.kaynak, v.kaynak_id, v.rol, v.kaynak_id is not null
      from stg.dokuman d
      join public.dokuman x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'DOKUMAN' and x.aktarim_id = d.id
      left join stg.gorevyorum y on d.modul = 210 and y.id = d.modulid
      cross join lateral (values
          -- aktarim_id: dokuman kimliği * 10 + bağ türü (tek satır = tek bağ)
          (d.id * 10 + 1, 'taraf', public.fn_aktarim_kisi_id(d.rehberid), 'ilgili cari', coalesce(d.rehberid, 0) > 0),
          (d.id * 10 + 2, 'gorev', public.fn_aktarim_web_id('gorev', 'AKTIVITELER', d.modulid), 'aktivite eki',
               d.modul = 12 and coalesce(d.modulid, 0) > 0),
          (d.id * 10 + 3, 'gorev',
               case when y.tur in (1, 33) then public.fn_aktarim_web_id('gorev', 'GOREVLER', y.gorevid)
                    when y.tur = 12 then public.fn_aktarim_web_id('gorev', 'AKTIVITELER', y.gorevid) end,
               'görev yorum eki', y.tur in (1, 12, 33)),
          (d.id * 10 + 4, 'taraf',
               case when y.tur in (11, 71) then public.fn_aktarim_kisi_id(y.gorevid) end,
               'cari yorum eki', y.tur in (11, 71)),
          (d.id * 10 + 5, 'proje',
               case when y.tur = 70 then public.fn_aktarim_web_id('proje', 'PROJELER', y.gorevid) end,
               'proje yorum eki', y.tur = 70)
      ) v(aktarim_id, kaynak, kaynak_id, rol, gerekli)
     where v.gerekli;
    v_bekleyen := (select count(*) from _ekb0 where not cozuldu);
    -- aynı kayda iki yoldan bağ (dökümanın carisi = yorumun carisi): ilki
    insert into _ekb (aktarim_id, dokuman_id, kaynak, kaynak_id, rol, ekleyen)
    select distinct on (b.dokuman_id, b.kaynak, b.kaynak_id) b.aktarim_id, b.dokuman_id, b.kaynak, b.kaynak_id, b.rol, 0
      from _ekb0 b
     where b.cozuldu
       and not exists (select 1 from public.dokuman_iliski i
                        where i.dokuman_id = b.dokuman_id and i.kaynak = b.kaynak and i.kaynak_id = b.kaynak_id
                          and not (i.aktarim_kaynak = 1 and i.aktarim_tablo = 'DOKUMAN' and i.aktarim_id = b.aktarim_id))
     order by b.dokuman_id, b.kaynak, b.kaynak_id, b.aktarim_id;
    select eklenen, guncellenen into v_ie, v_ig from public.fn_aktarim_esitle('dokuman_iliski', 'DOKUMAN', '_ekb',
        array['dokuman_id', 'kaynak', 'kaynak_id', 'rol']);

    -- 6) kayıt ekleri: cari / stok resmi, fatura eki
    truncate _ekd;
    insert into _ekd (aktarim_id, kaynak, kaynak_id, ad, content_type, boyut, hash, varsayilan, sube_id,
                      ekleyen, ekleme_tarihi, aciklama, durum)
    select e.id, b.kaynak, b.kaynak_id,
           left(coalesce(nullif(btrim(e.belgeadi), ''), 'Ek ' || e.id), 200), e.tip, e.boyut, e.hash, 0,
           coalesce(public.fn_aktarim_sube(e.subeid), v_sube),
           coalesce(public.fn_aktarim_kisi_id(e.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(e.eklemetarihi), timestamptz '1901-01-01'),
           left(btrim(coalesce(e.aciklama, '')), 400), 3
      from _eki e
      cross join lateral (select case when e.yeri in (71, 72) then 'taraf' when e.yeri = 88 then 'stok'
                                      when e.yeri = 402 then 'belge' end as kaynak,
                                 case when e.yeri in (71, 72) then public.fn_aktarim_kisi_id(e.yer_id)
                                      when e.yeri = 88 then public.fn_aktarim_web_id('stok', 'STOKLAR', e.yer_id)
                                      when e.yeri = 402 then public.fn_aktarim_web_id('belge', 'FATBASLIK', e.yer_id)
                                 end as kaynak_id) b
     where e.yeri in (71, 72, 88, 402) and b.kaynak_id is not null;
    -- kartın resmi: Delphi VARSAYILAN, yoksa ilk resim - web'in kendi varsayılanı varsa o kalır
    update _ekd w set varsayilan = 1
      from (select distinct on (w2.kaynak, w2.kaynak_id) w2.aktarim_id
              from _ekd w2 join _eki e on e.id = w2.aktarim_id
             where w2.content_type like 'image/%'
             order by w2.kaynak, w2.kaynak_id, coalesce(e.varsayilan, 0) desc, w2.aktarim_id) x
     where x.aktarim_id = w.aktarim_id
       and not exists (select 1 from public.dokuman d
                        where d.kaynak = w.kaynak and d.kaynak_id = w.kaynak_id and d.yon = 0 and d.varsayilan = 1
                          and not (d.aktarim_kaynak = 1 and d.aktarim_tablo = 'IMAJ'));
    select eklenen, guncellenen into v_ee, v_eg from public.fn_aktarim_esitle('dokuman', 'IMAJ', '_ekd',
        array['kaynak', 'kaynak_id', 'ad', 'content_type', 'boyut', 'hash', 'varsayilan', 'sube_id', 'ekleyen',
              'ekleme_tarihi', 'aciklama', 'durum']);
    insert into public.dokuman_surum (dokuman_id, surum_no, hash, content_type, boyut, yukleyen_id, yukleme,
                                      durum, yayin_tarihi)
    select d.id, 1, d.hash, d.content_type, d.boyut, d.ekleyen, d.ekleme_tarihi, 3, d.ekleme_tarihi
      from public.dokuman d
     where d.aktarim_kaynak = 1 and d.aktarim_tablo = 'IMAJ'
       and not exists (select 1 from public.dokuman_surum s where s.dokuman_id = d.id);

    v_eyok := (select count(*) from stg.imaj i where i.yeri in (71, 72, 88, 402)
                 and (i.icerik is null or length(i.icerik) = 0));
    v_eslesmeyen := (select coalesce(jsonb_object_agg(yeri, n), '{}') from
                       (select i.yeri::text as yeri, count(*) n from stg.imaj i
                         where i.yeri not in (1, 71, 72, 88, 402)
                            or (i.yeri in (71, 72, 88, 402) and i.icerik is not null and length(i.icerik) > 0
                                and not exists (select 1 from public.dokuman d where d.aktarim_kaynak = 1
                                                  and d.aktarim_tablo = 'IMAJ' and d.aktarim_id = i.id))
                         group by i.yeri) z);

    -- 7) içerik referansı: web her dokuman satırında +1 sayar (silmede -1, 0'da siler);
    --   eski sürümün içeriği de silinmesin diye o sürümler de sayılır
    update public.dokuman_icerik c set referans_sayisi = r.n
      from (select h.hash,
                   (select count(*) from public.dokuman d where d.hash = h.hash)
                 + (select count(*) from public.dokuman_surum s join public.dokuman d on d.id = s.dokuman_id
                     where s.hash = h.hash and d.hash <> h.hash) as n
              from (select distinct hash from _eki) h) r
     where c.hash = r.hash and c.referans_sayisi is distinct from r.n;

    return jsonb_build_object('klasor', v_klasor, 'icerik', v_icerik, 'dokuman', v_de + v_dg,
                              'icerik_yok', v_yok, 'surum', v_se + v_sg, 'bag', v_ie + v_ig,
                              'bag_bekleyen', v_bekleyen, 'kayit_eki', v_ee + v_eg,
                              'kayit_eki_icerik_yok', v_eyok, 'eslesmeyen_yer', v_eslesmeyen);
end $$;

comment on function public.fn_aktar_ek_dokuman() is
    '1146: Delphi DOKUMAN + DOKUMANKLASOR + IMAJ (stg) -> dokuman / dokuman_icerik / dokuman_surum / dokuman_iliski; bir kerelik, idempotent.';

-- ================================================================ e-Belge ===
create or replace function public.fn_aktar_ek_ebelge()
returns jsonb language plpgsql as $$
declare
    v_sube int := coalesce((select min(id) from public.sube where aktif = 1), 1);
    v_be int := 0; v_bg int := 0; v_web int := 0; v_me int := 0; v_mg int := 0; v_myok int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);

    create temp table if not exists _eeb on commit drop as select e.* from public.e_belge e with no data;
    truncate _eeb;
    insert into _eeb (aktarim_id, belge_id, taraf_id, belge_turu, yon, uuid, belge_no, gonderici_alias,
                      alici_alias, durum, api_json, ubl_xml, ubl_xml_zip, servis_durum_kodu, servis_durum_adi,
                      gib_durum_kodu, gib_durum_aciklama, yanit_durum_kodu, yanit_durum_adi, ekleyen,
                      ekleme_tarihi, sube_id, gonderici_vkno, gonderici_unvan, entegrator, belge_tarihi, tutar,
                      vergi_tutar, para_birimi, profil)
    select e.id, b.id, coalesce(b.taraf_id, public.fn_aktarim_kisi_id(e.rehberid)),
           t.tur, coalesce(nullif(e.yon, 0), 1), nullif(btrim(e.uuid), ''),
           left(coalesce(e.belgeno, ''), 50), left(coalesce(e.gondericialias, ''), 500),
           left(coalesce(e.alicialias, ''), 500),
           case when e.durum = 2 then case t.tur when 2 then 12 else 2 end
                when e.durum = 1 then case t.tur when 2 then 11 else 1 end else coalesce(e.durum, 0) end,
           coalesce(e.api_json, ''), coalesce(e.ubl_xml, ''), e.ubl_xml_zip,
           left(coalesce(e.servis_durum_kodu, ''), 100), left(coalesce(e.servis_durum_adi, ''), 250),
           left(coalesce(e.gib_durum_kodu, ''), 50), left(coalesce(e.gib_durum_aciklama, ''), 500),
           left(coalesce(e.yanit_durum_kodu, ''), 100), left(coalesce(e.yanit_durum_adi, ''), 250),
           coalesce(public.fn_aktarim_kisi_id(e.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(e.eklemetarihi), timestamptz '1901-01-01'),
           coalesce(b.sube_id, v_sube),
           coalesce(s.vkno, ''), left(coalesce(nullif(s.unvan, ''), s.ad, ''), 200), 'izibiz',
           (b.belge_tarihi at time zone 'Europe/Istanbul')::date,
           coalesce(round(b.genel_toplam, 2), 0), coalesce(round(b.kdv_tutari, 2), 0),
           left(coalesce(nullif(case when b.belge_dovizi in ('', 'TL') then 'TRY' else b.belge_dovizi end, ''), 'TRY'), 3),
           case when t.tur = 2 then 'EARSIVFATURA'
                else case b.senaryo when 2 then 'TICARIFATURA' when 3 then 'IHRACAT' when 7 then 'KAMU'
                                    when 8 then 'ILAC_TIBBICIHAZ' else 'TEMELFATURA' end end
      from stg.ebelge e
      cross join lateral (select case e.belgeturu when 151 then 1 when 150 then 2
                                                  else e.belgeturu end::smallint as tur) t
      left join public.belge b on b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK' and b.aktarim_id = e.fatbaslikid
      left join public.sube s on s.id = coalesce(b.sube_id, v_sube);
    -- web'in kendi yazdığı aynı UUID: dokunulmaz
    delete from _eeb w using public.e_belge x
     where x.uuid = w.uuid and not (x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE' and x.aktarim_id = w.aktarim_id);
    get diagnostics v_web = row_count;
    select eklenen, guncellenen into v_be, v_bg from public.fn_aktarim_esitle('e_belge', 'EBELGE', '_eeb',
        array['belge_id', 'taraf_id', 'belge_turu', 'yon', 'uuid', 'belge_no', 'gonderici_alias', 'alici_alias',
              'durum', 'api_json', 'ubl_xml', 'ubl_xml_zip', 'servis_durum_kodu', 'servis_durum_adi',
              'gib_durum_kodu', 'gib_durum_aciklama', 'yanit_durum_kodu', 'yanit_durum_adi', 'ekleyen',
              'ekleme_tarihi', 'sube_id', 'gonderici_vkno', 'gonderici_unvan', 'entegrator', 'belge_tarihi',
              'tutar', 'vergi_tutar', 'para_birimi', 'profil']);

    create temp table if not exists _eem on commit drop as select m.* from public.e_belge_mesaj m with no data;
    truncate _eem;
    insert into _eem (aktarim_id, belge_id, e_belge_id, islem, tip, mesaj, http_kodu, servis, ekleyen, ekleme_tarihi)
    select m.id, x.belge_id, x.id, coalesce(m.islemturu, 0),
           case when coalesce(btrim(m.hatakodu), '') <> '' or coalesce(btrim(m.hatamesaji), '') <> '' then 9
                else coalesce(m.mesajtipi, 1) end,
           coalesce(m.mesaj, '')
             || coalesce(E'\nHata ' || nullif(btrim(m.hatakodu), ''), '')
             || coalesce(E'\n' || nullif(btrim(m.hatamesaji), ''), '')
             || coalesce(E'\nDurum ' || nullif(btrim(m.onceki_durum_kodu), '') || ' -> ' || coalesce(m.yeni_durum_kodu, ''), ''),
           coalesce(m.httpkodu, 0), left(coalesce(m.serviskodu, ''), 10), 0,
           coalesce(public.fn_aktarim_zaman(m.eklemetarihi), x.ekleme_tarihi)
      from stg.ebelgemesaj m
      join public.e_belge x on x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE' and x.aktarim_id = m.ebelgeid
     where x.belge_id is not null;
    v_myok := (select count(*) from stg.ebelgemesaj) - (select count(*) from _eem);
    select eklenen, guncellenen into v_me, v_mg from public.fn_aktarim_esitle('e_belge_mesaj', 'EBELGEMESAJ', '_eem',
        array['belge_id', 'e_belge_id', 'islem', 'tip', 'mesaj', 'http_kodu', 'servis', 'ekleyen', 'ekleme_tarihi']);

    return jsonb_build_object('e_belge', v_be + v_bg, 'web_uuid_atlanan', v_web,
                              'belgesiz', (select count(*) from _eeb where belge_id is null),
                              'mesaj', v_me + v_mg, 'mesaj_atlanan', v_myok);
end $$;

comment on function public.fn_aktar_ek_ebelge() is
    '1146: Delphi GENDEPO EBELGE / EBELGEMESAJ (stg) -> e_belge / e_belge_mesaj; bir kerelik, idempotent.';

commit;
