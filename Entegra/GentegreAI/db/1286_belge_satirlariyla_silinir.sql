-- =============================================================================
--  1286  HER BELGE SATIRLARIYLA SİLİNİR  (kullanıcı 10.11.2026: "bütün alış/satış belgeleri için artık silme deseni
--        böyle")
--
--  1267 (05.11.2026) "satırları olan belge silinemez; önce satırları silin" kuralını tüm türlere koymuştu; 1284 iç stok
--  belgelerini, 1285 faturayı istisna yapmıştı. Kullanıcı deseni genelleştirdi: Sil (listeden ya da karttan) satırları
--  aynı işlemde götürür (BelgeDeposu.SilAsync - stok / lot / cari etkisi geri alınır, silme logu tablo 30 tam satırla
--  DELETE'ten önce yazılır, geri alma oradan). Satır kuralı fonksiyondan çıkar.
--
--  KALAN KORUMALAR AYNEN: e-Belge hazırlanmış / gönderilmiş, iptal edilmiş belge, bu belgeden dönüştürülmüş belge,
--  bağlı kasa işlemi, başarılı ÜTS bildirimi. Başka kaydın kullandığı satır (radyoloji istemi, hakediş, provizyon...)
--  belge_satir'a bakan FK'larla korunur.
-- =============================================================================

begin;

create or replace function public.fn_belge_silinebilir(p_belge_id integer)
returns text
language plpgsql stable as $$
declare
    b       record;
    v_adet  integer;
begin
    select bl.durum, bl.efatura_durum, bl.belge_no, bl.kapanma_durum, bl.tur
      into b from public.belge bl where bl.id = p_belge_id;
    if not found then
        return 'Belge bulunamadı.';
    end if;

    -- e-BELGE: hazirlanmis belgenin numarasi seri sayacindan alinmistir;
    --   silinirse numara bosa duser ve GIB'e giden/gidecek belge izi kaybolur.
    if coalesce(b.efatura_durum, 0) in (2, 12, 52) then
        return 'e-Belge gönderilmiş; belge silinemez. Düzeltme için iade faturası kesin.';
    end if;
    if coalesce(b.efatura_durum, 0) <> 0 then
        return 'e-Belge hazırlanmış; önce "Hazırı Geri Al" ile e-Belge kaydını kaldırın.';
    end if;

    -- IPTAL EDILMIS belge muhasebe izidir, silinmez.
    if coalesce(b.durum, 0) = 2 then
        return 'İptal edilmiş belge silinemez; iptal kaydı belgenin izidir.';
    end if;

    -- SATIR KURALI YOK (1286): satırlar belgeyle birlikte aynı işlemde silinir (BelgeDeposu.SilAsync).

    -- DONUSUM: bu belgeden uretilmis irsaliye/fatura varsa silme zinciri kirar.
    select count(*) into v_adet
      from public.belge_satir hs
      join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
      join public.belge hb on hb.id = hs.belge_id and hb.durum <> 2
     where ks.belge_id = p_belge_id;
    if v_adet > 0 then
        return 'Bu belgeden dönüştürülmüş belge var; önce onu kaldırın.';
    end if;

    -- KASA: tahsilat/odeme baglanmissa silme cari bakiyeyi bozar.
    select count(*) into v_adet from public.kasa_islem ki where ki.belge_id = p_belge_id;
    if v_adet > 0 then
        return 'Belgeye bağlı kasa işlemi var; önce tahsilatı/ödemeyi kaldırın.';
    end if;

    -- ÜTS (226): başarılı bildirim resmi kayıttır.
    select count(*) into v_adet
      from public.uts_bildirim ub
     where ub.belge_id = p_belge_id and ub.durum = 1;
    if v_adet > 0 then
        return 'Belgenin başarılı ÜTS bildirimi var; önce ÜTS''de iptal edin.';
    end if;

    return '';                                   -- bos = silinebilir
end $$;

comment on function public.fn_belge_silinebilir(integer) is
    '1267/1286: silme ön koşulu (boş = silinebilir): e-belge hazır/gönderilmiş, iptal, dönüşüm, kasa, ÜTS. '
    'Satır kuralı yok - belge satırlarıyla silinir (BelgeDeposu.SilAsync).';

commit;
