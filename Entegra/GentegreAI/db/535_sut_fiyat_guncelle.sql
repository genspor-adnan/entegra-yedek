-- =====================================================================
--  535_sut_fiyat_guncelle.sql
--  SUT listesini SKRS ambarından tazeleyen fonksiyon.
--
--  Kullanıcı: "SUT fiyat tipi için Durum Değiştir sağına 'SKRS'den Güncelle'
--  ekle, basınca SKRS'den güncellesin."
--
--  SUT fiyatı elle değişmez (518/533 kilidi) - tek meşru yazma yolu budur.
--  Fonksiyon `set local gentegre.sut_yukleme = '1'` diyerek kilidi kendi
--  işlemi boyunca açar; kilit kuralı tek yerde kalır, ikinci bir "yükleyici
--  modu" icat edilmez.
--
--  KAYNAK AMBAR, SERVİS DEĞİL (520): fonksiyon SKRS'ye gitmez, `skrs_sut`
--  tablosunu okur. Servis çağrısı yavaş ve kesilebilir; ambar dolu olduğu
--  sürece liste saniyeler içinde tazelenir. Ambarı yenilemek ayrı bir iş
--  (POST /api/entegrasyon/{id}/skrs-ham?ad=SUT).
--
--  YALNIZ FİYATI DEĞİŞENLER yazılır: 14 bin satırın tamamını her seferinde
--  güncellemek, `degistirme_tarihi` ve denetim kaydını gereksiz yere
--  kabartırdı - "bu satır ne zaman değişti" sorusu cevapsız kalırdı.
-- =====================================================================

create or replace function public.fn_fiyat_sut_yukle(
    p_liste integer, p_kategori integer default null)
returns table (guncellenen integer, eslesmeyen integer, ambar integer)
language plpgsql as $$
declare
    v_guncel integer := 0;
    v_eksik  integer := 0;
    v_ambar  integer;
begin
    select count(*) into v_ambar from public.skrs_sut where aktif = 1;
    if v_ambar = 0 then
        raise exception 'SKRS ambarı boş - önce SUT listesi çekilmeli '
                        '(Entegrasyon › SKRS › ham çekim).'
              using errcode = 'GK422';
    end if;

    -- SATIR -> KOD haritası BİR KEZ kurulur. İlk sürüm her satır için iki
    --   korelasyonlu alt sorgu çalıştırıyordu: 14 bin satırda 45 saniye
    --   sürüyor ve API zaman aşımına düşüyordu ("SUNUCU: beklenmeyen hata").
    create temporary table zz_sut_satir on commit drop as
    select s.id, coalesce(h.kod, t.kod) as kod,
           coalesce(h.kategori, t.kategori) as kategori
      from public.fiyat_listesi_satir s
      left join public.hizmet h on h.id = s.hizmet_id
      left join public.stok   t on t.id = s.stok_id
     where s.liste_id = p_liste;
    create index on zz_sut_satir (kod);

    -- SUT KİLİDİNİ KENDİ İŞLEMİ BOYUNCA AÇAR (518).
    perform set_config('gentegre.sut_yukleme', '1', true);

    with recursive dal as (
        select p_kategori::integer id
        union all
        select k.id from public.kategori k join dal d on k.ust_id = d.id
    )
    update public.fiyat_listesi_satir s
       set fiyat = sk.fiyat,
           yazim = 2                       -- kuraldan (hesap) geldi
      from zz_sut_satir k
      join public.skrs_sut sk on sk.kod = k.kod
                             and sk.aktif = 1
                             and coalesce(sk.fiyat, 0) > 0
     where s.id = k.id
       and s.fiyat is distinct from sk.fiyat
       and (p_kategori is null or k.kategori in (select id from dal));
    get diagnostics v_guncel = row_count;

    perform set_config('gentegre.sut_yukleme', '', true);

    -- SKRS'de karşılığı olmayan satır: kod değişmiş ya da kalem SUT dışı.
    --   Sayısı raporlanır ki liste sessizce eksik kalmasın.
    select count(*) into v_eksik
      from zz_sut_satir k
     where not exists (select 1 from public.skrs_sut sk2
                        where sk2.kod = k.kod and sk2.aktif = 1);

    return query select v_guncel, v_eksik, v_ambar;
end $$;

comment on function public.fn_fiyat_sut_yukle(integer, integer) is
    'SUT listesini `skrs_sut` ambarından tazeler; 518 fiyat kilidini kendi işlemi boyunca açar (535).';
