-- =====================================================================
--  543 - FIYAT LISTESI SILME KORUMASI
--  (kullanici: "fiyat listesinde kopyala butonu soluna Sil butonu (ikon)
--   ekle.. herhangi bir yerde kullanılmamışsa liste ve satırlarını
--   silsin")
--
--  Silme dugmesi listenin arac cubuguna cikiyor; "kullanilmamissa" kurali
--  DUGMENIN degil VERITABANININ isi - listeyi kart ekranindan, sag tustan,
--  API'den ya da bir betikten silen herkes ayni cevabi almali.
--
--  Satirlar zaten `fk_sls_liste ... on delete cascade` ile gidiyor; buradaki
--  is, listeyi HALA KULLANAN bir kayit varken silmeyi engellemek. FK'lar
--  bunu zaten reddediyor ama mesaji "fiyat_listesi tablosundaki satir hala
--  basvurulmakta" oluyor - kullanici hangi kayittan bahsedildigini
--  anlamiyor ve kacinin oldugunu gormuyordu.
-- =====================================================================

create or replace function public.fn_fiyat_listesi_kullanim(p_liste integer)
returns text language plpgsql stable as $$
declare
    v_belge   bigint;
    v_cari    bigint;
    v_kamp    bigint;
    v_sozl    bigint;
    v_parca   text[] := '{}';
begin
    select count(*) into v_belge from public.belge
     where fiyat_listesi_id = p_liste;
    select count(*) into v_cari from public.taraf
     where satis_fiyat_listesi_id = p_liste or alis_fiyat_listesi_id = p_liste;
    select count(*) into v_kamp from public.kampanya
     where fiyat_listesi_id = p_liste;
    select count(*) into v_sozl from public.kurum_sozlesme
     where fiyat_listesi_id = p_liste or sgk_fiyat_listesi_id = p_liste;

    if v_belge > 0 then v_parca := v_parca || format('%s belge', v_belge); end if;
    if v_cari  > 0 then v_parca := v_parca || format('%s cari kartı', v_cari); end if;
    if v_kamp  > 0 then v_parca := v_parca || format('%s kampanya', v_kamp); end if;
    if v_sozl  > 0 then v_parca := v_parca || format('%s kurum sözleşmesi', v_sozl); end if;

    return array_to_string(v_parca, ', ');
end $$;

comment on function public.fn_fiyat_listesi_kullanim(integer) is
  'Listeyi kullanan kayitlarin okunabilir ozeti (543); bos metin = hicbir yerde kullanilmiyor.';

create or replace function public.fn_fiyat_listesi_sil_kontrol()
returns trigger language plpgsql as $$
declare v_kullanim text;
begin
    -- VARSAYILAN LISTE: silinirse fiyati listeden okuyan her yeni belge
    --   sessizce fiyatsiz kalirdi. Once bayrak baska listeye tasinmali.
    if old.varsayilan = 1 then
        raise exception 'Varsayılan liste silinemez - önce başka bir listeyi varsayılan yapın.'
              using errcode = 'GK422';
    end if;

    v_kullanim := public.fn_fiyat_listesi_kullanim(old.id);
    if v_kullanim <> '' then
        raise exception '"%" listesi kullanımda (%) - silinemez. Kullanılmıyorsa listeyi Pasif yapabilirsiniz.',
              old.ad, v_kullanim using errcode = 'GK422';
    end if;

    return old;
end $$;

drop trigger if exists trg_fiyat_listesi_sil_kontrol on public.fiyat_listesi;
create trigger trg_fiyat_listesi_sil_kontrol
    before delete on public.fiyat_listesi
    for each row execute function public.fn_fiyat_listesi_sil_kontrol();
