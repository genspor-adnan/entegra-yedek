-- ============================================================================
--  Gentegre AI — TÜRKÇE PARA BİÇİMİ ve e-BELGE ÖNİZLEMESİNİN DÜZELTİLMESİ
--  769_para_bicimi_tr.sql
--
--  Kullanıcı: "178'deki para biçimi kusurunu da düzelt" (kalan iş 4.6).
--
--  ============ KUSUR ==================================================
--  `to_char(x, 'FM999G999G990D00')` içindeki `G` (grup ayıracı) ve `D`
--  (ondalık ayıracı) LOCALE'DEN gelir - sunucunun `lc_numeric` ayarından.
--  Bu kurulumda (ve tipik docker imajında) `lc_numeric = C`, yani:
--
--      68500.00  ->  "68,500.00"      (beklenen: "68.500,00")
--
--  Sonuç: e-Belge önizlemesinde matrah, KDV ve genel toplam İNGİLİZCE
--  biçimle çıkıyordu. Tutar doğruydu ama ayıraç terstir ve tam da bu iki
--  işaretin yer değiştirmesi, sayıyı bin kat yanlış OKUTUR - "68,500.00"
--  Türkçe okuyan biri için altmış sekiz bin beş yüz değil, altmış sekiz
--  virgül beş'tir. Müşteriye gösterilen bir belgede kabul edilemez.
--
--  178 bir GÖÇTÜR, düzenlenmez: düzeltme burada, yeni dosyada.
--
--  ============ ÇÖZÜM: AYIRAÇ LOCALE'E BIRAKILMIYOR ====================
--  `G`/`D` yerine ŞABLONDA LİTERAL `,` ve `.` yazılıyor (bunlar PG sayı
--  şablonunda locale'e bakmaz), sonra `translate` ile yer değiştiriliyor.
--  Sunucu ayarından bağımsız, her kurulumda aynı sonuç.
--
--  `lc_numeric`i değiştirmek de bir seçenekti ama YANLIŞ olurdu: kurulum
--  genelinde bir ayarı, tek bir ekranın biçimi için zorlamak; üstelik
--  müşteri sunucusunda değiştirme hakkımız da yok.
--
--  ============ TEK YAZAN: fn_para_tr ==================================
--  Biçim bir yerde duruyor. 768'de aynı düzeltme `fn_belge_talep_yazi`
--  içinde satır içi yazılmıştı; o fonksiyon bir daha elden geçtiğinde
--  buraya bağlanmalı. `fn_lab_kultur_ozet` (436) de aynı kusuru kendi
--  içinde çözmüş durumda - orada biçim para değil KOLONİ SAYISI ve
--  tam sayıda ondalık basamak İSTENMİYOR; o yüzden bilerek bırakıldı.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------- 1
--  TÜRKÇE SAYI BİÇİMİ
--
--  `p_hane = 0` ondalıksız yazar (yüzde/oran gibi tam değerler için).
--  NULL girdi BOŞ metindir, "0,00" değil: yazılmamış bir tutarı sıfır gibi
--  göstermek, belgede olmayan bir bilgiyi varmış gibi gösterirdi.
create or replace function public.fn_para_tr(p_tutar numeric,
                                             p_hane integer default 2)
returns text language sql immutable as $$
    select case
        when p_tutar is null then ''
        else translate(
                 trim(to_char(p_tutar,
                     case when coalesce(p_hane, 2) <= 0 then 'FM999,999,999,990'
                          else 'FM999,999,999,990.'
                               || repeat('0', least(p_hane, 6)) end)),
                 ',.', '.,')
    end;
$$;

comment on function public.fn_para_tr(numeric, integer) is
  '769: Turkce sayi bicimi (1.234,56). Ayirac locale''e (lc_numeric) '
  'BIRAKILMAZ - sablonda literal, sonra translate. to_char G/D kullanan '
  'her yer buraya baglanmali.';

-- ---------------------------------------------------------------------- 2
--  e-BELGE ÖNİZLEME HTML'İ (178'in düzeltilmiş hâli)
--
--  178'den TEK FARK sayı biçimidir; gövdenin geri kalanı aynen korundu.
--  KDV ORANI da biçimden geçiyor: tam sayı oran "20" yazılır, küsuratlı
--  oran "8,50". Önceki hâlinde ham `numeric` birleştiriliyordu ve satırda
--  "20.00" görünüyordu - düzeltilmiş tutarların yanında tek başına
--  İngilizce kalan bir sayı olurdu.
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
    --   bicimleme burada yapilir (fn_para_tr), hesaplama yok.
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
            '<td class="s">' || public.fn_para_tr(r.miktar) || '</td>' ||
            '<td class="s">' || public.fn_para_tr(r.birim_fiyat) || '</td>' ||
            '<td class="s">' || public.fn_para_tr(r.iskonto) || '</td>' ||
            '<td class="s">' || public.fn_para_tr(r.kdv,
                 case when r.kdv = trunc(r.kdv) then 0 else 2 end) || '</td>' ||
            '<td class="s">' || coalesce(nullif(r.tevkifat, ''), '-') || '</td>' ||
            '<td class="s">' || public.fn_para_tr(r.tutar) || '</td></tr>';
    end loop;

    -- Dip toplam belgenin kendi alanlarindan (tek hesaplama kaynagi kurali).
    v_toplam :=
        '<tr><th>Matrah</th><td class="s">' || public.fn_para_tr(coalesce(b.matrah, 0)) || '</td></tr>' ||
        '<tr><th>KDV</th><td class="s">' || public.fn_para_tr(coalesce(b.kdv_tutari, 0)) || '</td></tr>' ||
        '<tr><th>Genel Toplam</th><td class="s"><b>' || public.fn_para_tr(coalesce(b.genel_toplam, 0)) || '</b></td></tr>';

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
  'Belgenin onizleme HTML''i (Delphi HTMLUret karsiligi, 178; sayi bicimi '
  '769''da fn_para_tr''ye baglandi - to_char G/D locale''e bagimliydi).';

-- ---------------------------------------------------------------------- 3
do $$
declare v_ornek text;
begin
    select public.fn_para_tr(68500) || ' · ' || public.fn_para_tr(1234567.5)
        || ' · ' || public.fn_para_tr(20, 0) || ' · [' || public.fn_para_tr(null) || ']'
      into v_ornek;
    raise notice '769 tamam. Bicim ornegi: %', v_ornek;
end $$;
