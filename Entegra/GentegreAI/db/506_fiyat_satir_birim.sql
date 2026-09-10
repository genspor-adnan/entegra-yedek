-- =====================================================================
--  506_fiyat_satir_birim.sql
--  Fiyat listesi satırında BİRİM kalemden gelir.
--
--  Kullanıcı: "fiyat liste satırlarda birim boş geliyor oysa hizmette
--  tanımlı". Doğru: `fiyat_listesi_satir.birim` 3.102 satırda 0 - satır
--  yazılırken kalemin birimi KOPYALANMIYORDU, kolon da 0'ın karşılığı
--  olmadığı için ekranda boş görünüyordu.
--
--  Birim satırda TUTULUR (kalemden okunup gösterilmez): fiyat "kutu" ya da
--  "seans" başına olabilir ve kalemin birimi sonradan değişse bile listede
--  yazılı fiyatın hangi birime ait olduğu DEĞİŞMEMELİ. O yüzden çözüm
--  "boşsa kalemden doldur"dur:
--    * mevcut satırlar geri doldurulur,
--    * yeni satırda birim verilmezse tetik kalemden alır.
--
--  Ayrıca hizmet birimleri (504: Seans) stok listesinde yoktu; fiyat satırı
--  ikisini birden gösterdiği için "Seans" boş çıkardı - ortak listeye eklendi.
-- =====================================================================

do $$
declare
    v_liste integer;
    v_dolan integer;
begin
    select id into v_liste from public.kod_liste where kod = 'stok.ana_birim';
    if v_liste is not null then
        insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
        select v_liste, 13, 'Seans', 13, 1
         where not exists (select 1 from public.kod_deger
                            where liste_id = v_liste and deger = 13);
    end if;

    update public.fiyat_listesi_satir s
       set birim = coalesce(
             (select h.birim from public.hizmet h where h.id = s.hizmet_id),
             (select st.ana_birim from public.stok st where st.id = s.stok_id), 0)
     where coalesce(s.birim, 0) = 0;
    get diagnostics v_dolan = row_count;
    raise notice 'Fiyat satiri birimi: % satir kalemden dolduruldu.', v_dolan;
end $$;

create or replace function public.tg_fiyat_satir_birim() returns trigger
language plpgsql as $$
begin
    if coalesce(new.birim, 0) = 0 then
        new.birim := coalesce(
            (select h.birim from public.hizmet h where h.id = new.hizmet_id),
            (select s.ana_birim from public.stok s where s.id = new.stok_id), 0);
    end if;
    return new;
end $$;

drop trigger if exists tg_fiyat_satir_birim on public.fiyat_listesi_satir;
create trigger tg_fiyat_satir_birim
    before insert or update of hizmet_id, stok_id, birim
    on public.fiyat_listesi_satir
    for each row execute function public.tg_fiyat_satir_birim();
