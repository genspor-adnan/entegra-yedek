-- =============================================================================
--  1145  DELPHI AKTARIMI - GÖREVLER, AKTİVİTELER, NOTLAR / YORUMLAR  (bir kerelik, 1143)
--
--  Kaynak stg tabloları (db/araclar/aktar_ek.ps1 doldurur): gorevler, gorevkullanici,
--  gorevyorum, aktiviteler, aktivitenotlar, animsat. Hedef: public.gorev (tek tablo:
--  tur 1 Görev · 2 Hatırlatma · 3 Görüşme/Aktivite · 4 Toplantı · 9 Diğer).
--
--  * GOREVLER -> gorev (aktarim_tablo 'GOREVLER'). Durum (GENINI -21042): 1 Yeni / 3
--    Ertelenmiş -> 0 Bekliyor; 2 Sürüyor / 4 Başkasında / 10 Sonlandırma onayı -> 1
--    Devam; 9 Tamamlanmış -> 2; 8 İptal -> 3. Tür (-21044): 1 Telefon / 3 Ziyaret -> 3,
--    2 Toplantı -> 4, diğerleri (Kontrol, Yazılım, Bakım sözleşmesi...) -> 1 Görev.
--    Bayrak -> öncelik 3 Yüksek, yoksa 2 Normal. Sorumlu = GOREVKULLANICI TUR 11
--    (görevli; ilk kayıt), yoksa açan. Hatırlatma = ANIMSAT (TUR 1) en son tarih.
--  * AKTIVITELER -> gorev (aktarim_tablo 'AKTIVITELER'; kimlikler GOREVLER'le çakışır,
--    tablo adı ayırır). Tip (-2101): 59 Telefon / 61 Ziyaret -> 3, 60 Toplantı -> 4,
--    70 Hatırlatma -> 2, diğerleri 3. Durum (-2105): 1 Yeni / 2 Erteleme -> 0,
--    9 Onay bekliyor -> 1, 8 Tamamlandı -> 2, 4 İptal -> 3.
--  * GÖREV YORUMLARI: web'de göreve bağlı yorum/sohbet yok (mesaj_sohbet kaynak
--    bağlantısını hiçbir ekran okumuyor) -> görevin AÇIKLAMASINA eklenir:
--    "--- Delphi notları ---" altında "gg.aa.yyyy ss:dd Kişi: metin", tarih sırasıyla.
--    GOREVYORUM TUR 1 (görev notu) / 33 (görev yorumu) -> GOREVLER, TUR 12 ve
--    AKTIVITENOTLAR -> AKTIVITELER. Açıklama her çalıştırmada aynı biçimde kurulur
--    (idempotent).
--  * KAYIT NOTLARI: GOREVYORUM TUR 11 (cari notu - Delphi cari listesinin NOTLAR
--    kolonu), 71 (rehber yorumu), 73 (İK notu) -> carinin, TUR 70 -> projenin
--    "Diğer" (9) türünde TAMAMLANMIŞ görevi (aktarim_tablo 'GOREVYORUM'): konu =
--    "Not: <ilk satır>", açıklama = tam metin, tarih = not tarihi. taraf.notlar 400
--    karakter ve cari aktarımı her turda üzerine yazar; görev listesi carinin /
--    projenin altında görünür.
--  * ATLANAN: GOREVYORUM TUR 2 (kredi kayıtlarının notu - KREDILER/plan satırına
--    bağlı, web'de karşılık yok), 18 demirbaş, 83 servis, 91 sipariş, 485 ayar;
--    görev listeleri (LISTEID), tekrarlar, aktivite takipçi/bilgilendirilecek.
-- =============================================================================

begin;

create or replace function public.fn_aktar_ek_gorev()
returns jsonb language plpgsql as $$
declare
    v_kol text[] := array['gorev_no', 'konu', 'aciklama', 'tur', 'kategori', 'oncelik', 'durum', 'ilerleme',
        'sorumlu_id', 'acan_id', 'baslangic', 'termin', 'hatirlatma', 'tamamlanma', 'taraf_id', 'proje_id',
        'sube_id', 'giris_kaynak', 'ekleyen', 'ekleme_tarihi'];
    v_ge int := 0; v_gg int := 0; v_ae int := 0; v_ag int := 0; v_ne int := 0; v_ng int := 0;
    v_yorum int := 0; v_atla int := 0; v_anim int := 0; v_anim_yetim int := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);

    -- görev / aktivite yorumları: hedef (tablo, delphi id) başına tek metin
    create temp table if not exists _gy
        (tablo varchar(30), delphi bigint, metin text, primary key (tablo, delphi)) on commit drop;
    truncate _gy;
    insert into _gy
    select x.tablo, x.delphi,
           string_agg(to_char(public.fn_aktarim_zaman(x.zaman), 'DD.MM.YYYY HH24:MI')
                      || coalesce(' ' || nullif(btrim(t.unvan), ''), '') || ': ' || btrim(x.metin),
                      E'\n' order by x.zaman nulls first, x.sira)
      from (select case when y.tur = 12 then 'AKTIVITELER' else 'GOREVLER' end as tablo,
                   y.gorevid as delphi, coalesce(y.tarih, y.eklemetarihi) as zaman, y.ekleyen,
                   y.yorum as metin, y.id as sira
              from stg.gorevyorum y
             where y.tur in (1, 33, 12) and nullif(btrim(coalesce(y.yorum, '')), '') is not null
               and left(y.yorum, 5) <> '{\rtf'
            union all
            select 'AKTIVITELER', n.aktiviteid, coalesce(n.tarih, n.eklemetarihi), n.ekleyen, n.aciklama, n.id
              from stg.aktivitenotlar n
             where nullif(btrim(coalesce(n.aciklama, '')), '') is not null) x
      left join public.taraf t on t.id = public.fn_aktarim_kisi_id(x.ekleyen)
     group by x.tablo, x.delphi;
    select count(*) into v_yorum from _gy;

    create temp table if not exists _gw on commit drop as select g.* from public.gorev g with no data;

    -- 1) GOREVLER
    truncate _gw;
    insert into _gw (aktarim_id, gorev_no, konu, aciklama, tur, kategori, oncelik, durum, ilerleme, sorumlu_id,
                     acan_id, baslangic, termin, hatirlatma, tamamlanma, taraf_id, proje_id, sube_id,
                     giris_kaynak, ekleyen, ekleme_tarihi)
    select g.id, 'D-' || g.id,
           left(coalesce(nullif(btrim(g.konusu), ''), '(konusuz)'), 200),
           coalesce(E'--- Delphi notları ---\n' || y.metin, ''),
           case g.turu when 1 then 3 when 3 then 3 when 2 then 4 else 1 end,
           0,
           case when g.bayrak = 1 then 3 else 2 end,
           d.durum,
           case when d.durum = 2 then 100 else 0 end,
           coalesce(public.fn_aktarim_kisi_id(s.rehberid), public.fn_aktarim_kisi_id(g.ekleyen)),
           coalesce(public.fn_aktarim_kisi_id(g.ekleyen), 0),
           public.fn_aktarim_zaman(g.baslamatarihi), public.fn_aktarim_zaman(g.bitistarihi),
           public.fn_aktarim_zaman(a.tarih),
           case when d.durum = 2 then coalesce(public.fn_aktarim_zaman(g.degistirmetarihi),
                                               public.fn_aktarim_zaman(g.bitistarihi)) end,
           public.fn_aktarim_web_id('taraf', 'REHBER', g.rehberid),
           public.fn_aktarim_web_id('proje', 'PROJELER', g.projeid),
           public.fn_aktarim_sube(null), coalesce(g.giriskaynak, 0),
           coalesce(public.fn_aktarim_kisi_id(g.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(g.eklemetarihi), timestamptz '1901-01-01')
      from stg.gorevler g
      cross join lateral (select case g.durum when 2 then 1 when 4 then 1 when 10 then 1
                                              when 9 then 2 when 8 then 3 else 0 end as durum) d
      left join lateral (select k.rehberid from stg.gorevkullanici k
                          where k.listgorevid = g.id and k.tur = 11 and coalesce(k.rehberid, 0) > 0
                          order by k.id limit 1) s on true
      left join lateral (select max(n.tarih) as tarih from stg.animsat n where n.tur = 1 and n.id = g.id) a on true
      left join _gy y on y.tablo = 'GOREVLER' and y.delphi = g.id;
    select eklenen, guncellenen into v_ge, v_gg from public.fn_aktarim_esitle('gorev', 'GOREVLER', '_gw', v_kol);
    select count(*) into v_anim from stg.animsat n where n.tur = 1 and exists (select 1 from stg.gorevler g where g.id = n.id);
    select count(*) into v_anim_yetim from stg.animsat n where not (n.tur = 1 and exists (select 1 from stg.gorevler g where g.id = n.id));

    -- 2) AKTIVITELER
    truncate _gw;
    insert into _gw (aktarim_id, gorev_no, konu, aciklama, tur, kategori, oncelik, durum, ilerleme, sorumlu_id,
                     acan_id, baslangic, termin, hatirlatma, tamamlanma, taraf_id, proje_id, sube_id,
                     giris_kaynak, ekleyen, ekleme_tarihi)
    select a.id, 'D-A' || a.id,
           left(coalesce(nullif(btrim(a.konusu), ''), '(konusuz)'), 200),
           concat_ws(E'\n\n', nullif(btrim(coalesce(a.notlar, '')), ''),
                     E'--- Delphi notları ---\n' || y.metin),
           case a.tipi when 59 then 3 when 61 then 3 when 60 then 4 when 70 then 2 else 3 end,
           0,
           least(greatest(coalesce(nullif(a.oncelik, 0), 2), 1), 4),
           d.durum,
           case when d.durum = 2 then 100 else least(greatest(coalesce(a.tamamlanmaorani, 0), 0), 100) end,
           coalesce(public.fn_aktarim_kisi_id(a.sorumlu), public.fn_aktarim_kisi_id(a.atayan),
                    public.fn_aktarim_kisi_id(a.ekleyen)),
           coalesce(public.fn_aktarim_kisi_id(a.atayan), public.fn_aktarim_kisi_id(a.ekleyen), 0),
           public.fn_aktarim_zaman(a.baslamatarihi), public.fn_aktarim_zaman(a.bitistarihi),
           public.fn_aktarim_zaman(a.animsatmatarihi),
           case when d.durum = 2 then coalesce(public.fn_aktarim_zaman(a.degistirmetarihi),
                                               public.fn_aktarim_zaman(a.bitistarihi)) end,
           public.fn_aktarim_web_id('taraf', 'REHBER', a.musteriid),
           public.fn_aktarim_web_id('proje', 'PROJELER', a.projeid),
           public.fn_aktarim_sube(a.subeid), 0,
           coalesce(public.fn_aktarim_kisi_id(a.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(a.eklemetarihi), timestamptz '1901-01-01')
      from stg.aktiviteler a
      cross join lateral (select case a.durum when 9 then 1 when 8 then 2 when 4 then 3 else 0 end as durum) d
      left join _gy y on y.tablo = 'AKTIVITELER' and y.delphi = a.id;
    select eklenen, guncellenen into v_ae, v_ag from public.fn_aktarim_esitle('gorev', 'AKTIVITELER', '_gw', v_kol);

    -- 3) cari / rehber / İK / proje notları -> kaydın "Diğer" görevi
    truncate _gw;
    insert into _gw (aktarim_id, gorev_no, konu, aciklama, tur, kategori, oncelik, durum, ilerleme, sorumlu_id,
                     acan_id, baslangic, termin, hatirlatma, tamamlanma, taraf_id, proje_id, sube_id,
                     giris_kaynak, ekleyen, ekleme_tarihi)
    select y.id, 'D-N' || y.id,
           left('Not: ' || split_part(btrim(y.yorum), E'\n', 1), 200),
           btrim(y.yorum),
           9, 0, 2, 2, 100,
           public.fn_aktarim_kisi_id(y.ekleyen), coalesce(public.fn_aktarim_kisi_id(y.ekleyen), 0),
           public.fn_aktarim_zaman(coalesce(y.tarih, y.eklemetarihi)), null, null,
           public.fn_aktarim_zaman(coalesce(y.tarih, y.eklemetarihi)),
           case when y.tur in (11, 71, 73) then h.taraf
                else (select p.taraf_id from public.proje p where p.id = h.proje) end,
           h.proje,
           public.fn_aktarim_sube(null), 0,
           coalesce(public.fn_aktarim_kisi_id(y.ekleyen), 0),
           coalesce(public.fn_aktarim_zaman(coalesce(y.eklemetarihi, y.tarih)), timestamptz '1901-01-01')
      from stg.gorevyorum y
      cross join lateral (select case when y.tur in (11, 71, 73)
                                      then public.fn_aktarim_web_id('taraf', 'REHBER', y.gorevid) end as taraf,
                                 case when y.tur = 70
                                      then public.fn_aktarim_web_id('proje', 'PROJELER', y.gorevid) end as proje) h
     where y.tur in (11, 70, 71, 73)
       and nullif(btrim(coalesce(y.yorum, '')), '') is not null and left(y.yorum, 5) <> '{\rtf'
       and coalesce(h.taraf, h.proje) is not null;
    select eklenen, guncellenen into v_ne, v_ng from public.fn_aktarim_esitle('gorev', 'GOREVYORUM', '_gw', v_kol);
    select count(*) into v_atla from stg.gorevyorum y
     where y.tur not in (1, 12, 33, 11, 70, 71, 73)
        or (y.tur in (11, 70, 71, 73) and not exists (
                select 1 from public.gorev g where g.aktarim_kaynak = 1 and g.aktarim_tablo = 'GOREVYORUM'
                                               and g.aktarim_id = y.id));

    return jsonb_build_object(
        'gorev', v_ge + v_gg, 'gorev_eklenen', v_ge,
        'aktivite', v_ae + v_ag, 'aktivite_eklenen', v_ae,
        'kayit_notu', v_ne + v_ng, 'kayit_notu_eklenen', v_ne,
        'yorumlu_gorev', v_yorum, 'hatirlatma', v_anim, 'hatirlatma_yetim', v_anim_yetim,
        'yorum_atlanan', v_atla);
end $$;

comment on function public.fn_aktar_ek_gorev() is
    '1145: Delphi GOREVLER / AKTIVITELER (+ yorumlar, ANIMSAT) ve GOREVYORUM kayıt notları -> gorev. Bir kerelik, idempotent.';

commit;
