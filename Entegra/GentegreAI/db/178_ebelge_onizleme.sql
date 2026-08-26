-- ============================================================================
--  Gentegre AI — e-BELGE ONIZLEME (HTML) ve MESAJ GECMISI
--  178_ebelge_onizleme.sql
--
--  Kullanici: aksiyon combo'suna "Ön İzle / PDF Kaydet / HTML Kaydet /
--  XML Kaydet / Mesaj Geçmişini Göster" maddeleri - hepsi calisir olsun.
--
--  HTML NEREDEN: Delphi de XSLT'yi DEGIL kendi HTML sablonunu kullaniyor
--  (UEBelgeOlusturucu.HTMLUret) - XSLT entegratorde belgeye gomulu gider,
--  ekranda gosterilen onizleme ayri ve daha sadedir. Ayni yaklasim: HTML burada
--  uretilir, PDF ise tarayicinin yazdirma penceresinden alinir (ayri bir PDF
--  motoru bagimliligi getirmemek icin).
--
--  GONDERILMEDEN ONCE de onizlenebilir: hazirlanmis belgenin numarasi ve turu
--  bellidir; kullanici "ne gidecek" sorusunu gondermeden gormek istiyor.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_ebelge_html(p_belge_id integer)
returns text
language plpgsql stable as $$
declare
    b        record;
    g        record;
    e        record;
    v_tur    text;
    v_satir  text := '';
    v_html   text;
    v_toplam text := '';
    r        record;
begin
    select bl.*, coalesce(bt.ad, '') as tur_adi
      into b
      from public.belge bl
      left join public.kasa_islem_turu bt on bt.kod = bl.tur
     where bl.id = p_belge_id;
    if not found then
        raise exception 'Belge bulunamadı (%).', p_belge_id;
    end if;

    select * into e from public.e_belge where belge_id = p_belge_id order by id desc limit 1;
    select * into g from public.v_ebelge_gonderici
     where sube_id = coalesce(nullif(b.sube_id, 0), (select min(id) from public.sube));

    v_tur := case coalesce(e.belge_turu, 0)
                  when 1 then 'e-Fatura' when 2 then 'e-Arşiv'
                  when 7 then 'e-İrsaliye' when 8 then 'e-SMM'
                  else coalesce(nullif(b.tur_adi, ''), 'Belge') end;

    -- Kalemler. Tutarlar belgenin dovizinde; HTML yalniz GOSTERIM oldugu icin
    --   bicimleme burada yapilir (to_char), hesaplama yok.
    for r in
        select bs.sira, coalesce(bs.aciklama, '') as ad, bs.miktar,
               bs.birim_fiyat, coalesce(bs.iskonto, 0) as iskonto,
               coalesce(bs.kdv, 0) as kdv, bs.tutar,
               coalesce(bs.tevkifat_kodu, '') as tevkifat
          from public.belge_satir bs
         where bs.belge_id = p_belge_id
         order by bs.sira, bs.id
    loop
        v_satir := v_satir ||
            '<tr><td>' || r.sira || '</td><td>' || replace(r.ad, '<', '&lt;') || '</td>' ||
            '<td class="s">' || to_char(r.miktar, 'FM999G999G990D00') || '</td>' ||
            '<td class="s">' || to_char(r.birim_fiyat, 'FM999G999G990D00') || '</td>' ||
            '<td class="s">' || to_char(r.iskonto, 'FM990D00') || '</td>' ||
            '<td class="s">' || r.kdv || '</td>' ||
            '<td class="s">' || coalesce(nullif(r.tevkifat, ''), '-') || '</td>' ||
            '<td class="s">' || to_char(r.tutar, 'FM999G999G990D00') || '</td></tr>';
    end loop;

    -- Dip toplam belgenin kendi alanlarindan (tek hesaplama kaynagi kurali).
    v_toplam :=
        '<tr><th>Matrah</th><td class="s">' || to_char(coalesce(b.matrah, 0), 'FM999G999G990D00') || '</td></tr>' ||
        '<tr><th>KDV</th><td class="s">' || to_char(coalesce(b.kdv_tutari, 0), 'FM999G999G990D00') || '</td></tr>' ||
        '<tr><th>Genel Toplam</th><td class="s"><b>' || to_char(coalesce(b.genel_toplam, 0), 'FM999G999G990D00') || '</b></td></tr>';

    v_html :=
'<!doctype html><html lang="tr"><head><meta charset="utf-8">' ||
'<title>' || v_tur || ' ' || coalesce(nullif(e.belge_no, ''), coalesce(b.belge_no, '')) || '</title>' ||
'<style>body{font-family:Segoe UI,Arial,sans-serif;margin:28px;color:#222;font-size:13px}' ||
'h1{margin:0 0 2px;font-size:20px}.muted{color:#666;font-size:11px}' ||
'.kutu{border:1px solid #ddd;padding:12px;margin:14px 0;border-radius:6px}' ||
'.iki{display:flex;gap:14px}.iki>div{flex:1}' ||
'table{border-collapse:collapse;width:100%;font-size:12px}' ||
'th,td{border:1px solid #ddd;padding:6px 8px}th{background:#f3f5f7;text-align:left}' ||
'.s{text-align:right}.toplam{width:320px;margin-left:auto;margin-top:12px}' ||
'@media print{body{margin:0}}</style></head><body>' ||
'<h1>' || v_tur || '</h1>' ||
'<div class="muted">Belge No: ' || coalesce(nullif(e.belge_no, ''), coalesce(b.belge_no, '-')) ||
'  ·  ETTN: ' || coalesce(nullif(e.uuid, ''), '-') ||
'  ·  Durum: ' || public.fn_ebelge_durum_aciklama(b.efatura_durum) || '</div>' ||
'<div class="iki">' ||
  '<div class="kutu"><b>SATICI</b><br>' || coalesce(g.unvan, '') ||
  '<br>VKN/TCKN: ' || coalesce(g.vkno, '') || '  ·  VD: ' || coalesce(g.vergi_dairesi, '') ||
  '<br>' || coalesce(g.adres, '') || '<br>' || coalesce(g.ilce, '') || ' / ' || coalesce(g.il, '') ||
  '</div>' ||
  '<div class="kutu"><b>ALICI</b><br>' || coalesce(b.taraf_unvan, '') ||
  '<br>VKN/TCKN: ' || coalesce(b.taraf_vkno, '') || '  ·  VD: ' || coalesce(b.taraf_vd, '') ||
  '<br>' || coalesce(b.taraf_adres, '') || '<br>' || coalesce(b.taraf_ilce, '') || ' / ' || coalesce(b.taraf_il, '') ||
  '</div>' ||
'</div>' ||
'<div class="kutu">Tarih: <b>' || to_char(b.belge_tarihi, 'DD.MM.YYYY HH24:MI') || '</b>' ||
'  ·  Para birimi: <b>' || public.fn_ebelge_para_kodu(coalesce(nullif(b.belge_dovizi, ''), b.doviz_cinsi)) || '</b>' ||
case when coalesce(btrim(b.aciklama), '') <> ''
     then '<br>Açıklama: ' || replace(b.aciklama, '<', '&lt;') else '' end || '</div>' ||
'<table><thead><tr><th>#</th><th>Ürün / Hizmet</th><th class="s">Miktar</th>' ||
'<th class="s">Birim Fiyat</th><th class="s">İsk.%</th><th class="s">KDV%</th>' ||
'<th class="s">Tevkifat</th><th class="s">Tutar</th></tr></thead><tbody>' ||
coalesce(nullif(v_satir, ''), '<tr><td colspan="8">Kalem yok</td></tr>') ||
'</tbody></table>' ||
'<table class="toplam">' || v_toplam || '</table>' ||
'<div class="muted" style="margin-top:18px">Bu görüntü ÖN İZLEMEDİR; ' ||
'GİB''e gönderilen belgenin görüntüsü entegratördeki XSLT şablonuyla üretilir.</div>' ||
'</body></html>';

    return v_html;
end $$;

comment on function public.fn_ebelge_html(integer) is
  'Belgenin onizleme HTML''i (Delphi HTMLUret karsiligi, 178). Gonderilen belgenin resmi goruntusu XSLT ile entegratorde uretilir.';

-- ------------------------------------------------------- mesaj gecmisi -----
-- Belgenin e-Belge yolculugu: hazirlama, gonderim, entegrator/GIB yanitlari.
--   Tek yerde toplanir ki "ne oldu" sorusu tek ekranda cevaplansin.
create or replace function public.fn_ebelge_mesajlar(p_belge_id integer)
returns table (sira integer, tarih timestamp, olay text, durum text,
               kod text, aciklama text)
language sql stable as $$
    select row_number() over (order by x.tarih, x.oncelik)::integer,
           x.tarih, x.olay, x.durum, x.kod, x.aciklama
      from (
        -- 1) Hazirlama
        select e.ekleme_tarihi as tarih, 1 as oncelik,
               'Hazırlandı' as olay,
               public.fn_ebelge_tur_adi(e.belge_turu) as durum,
               e.belge_no::text as kod,
               ('Seri ' || left(coalesce(e.belge_no, ''), 3) ||
                ' · ETTN ' || coalesce(nullif(e.uuid, ''), '-'))::text as aciklama
          from public.e_belge e where e.belge_id = p_belge_id
        union all
        -- 2) Gonderim / servis yaniti (varsa)
        select coalesce(e.degistirme_tarihi, e.ekleme_tarihi), 2,
               case when e.durum in (2, 12, 52) then 'Gönderildi' else 'Gönderim denemesi' end,
               coalesce(nullif(e.servis_durum_adi, ''), '-'),
               coalesce(nullif(e.servis_durum_kodu, ''), '-'),
               ('Entegratör: ' || coalesce(nullif(e.entegrator, ''), '-') ||
                case when coalesce(e.api_json, '') <> ''
                     then ' · yanıt ' || length(e.api_json) || ' karakter' else '' end)::text
          from public.e_belge e
         where e.belge_id = p_belge_id
           and (coalesce(e.servis_durum_kodu, '') <> '' or e.durum in (2, 12, 52))
        union all
        -- 3) GIB yaniti (varsa)
        select coalesce(e.degistirme_tarihi, e.ekleme_tarihi), 3,
               'GİB yanıtı',
               coalesce(nullif(e.gib_durum_aciklama, ''), '-'),
               coalesce(nullif(e.gib_durum_kodu, ''), '-'),
               coalesce(nullif(e.yanit_durum_adi, ''), '')::text
          from public.e_belge e
         where e.belge_id = p_belge_id and coalesce(e.gib_durum_kodu, '') <> ''
      ) x
$$;

comment on function public.fn_ebelge_mesajlar(integer) is
  'Belgenin e-Belge gecmisi: hazirlama, gonderim ve GIB yanitlari (178).';

do $$
begin
    raise notice '178 tamam: fn_ebelge_html + fn_ebelge_mesajlar.';
end $$;
