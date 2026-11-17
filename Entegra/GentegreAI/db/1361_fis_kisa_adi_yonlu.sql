-- 1361 - Fiş kısa adı yönlü: "Satış Fişi" / "Alış Fişi" (17.11.2026).
--   Kullanıcı: "Belgelerde Fiş rename Satış Fişi" · "alış fişi de Alış Fişi olsun". Hasta Fişi (128, 1360) yanında
--   yönsüz "Fiş" hangi belge olduğunu söylemiyordu. İstemcideki belgeKisaAdi ile aynı tanım (web/src/sayfalar/belgeTuru.ts).
--   Yeni tahsilat açıklamaları "Satış Fişi Tahsilatı" olur; eski kayıtların açıklaması değiştirilmez (kullanıcının
--   gördüğü / yazdırdığı metin). Stok giriş / çıkış fişi (3, 4) "Fiş" kalır. Tekrar çalıştırılabilir.
create or replace function public.fn_belge_kisa_adi(p_tur integer, p_tipi integer default 0)
returns varchar
language sql
immutable
as $$
    select case
        when p_tur = 19 and p_tipi = 30 then 'Başvuru'
        when p_tur = 18                 then 'Teklif'
        when p_tur = 20                 then 'Transfer'
        when p_tur = 105                then 'Talep'
        when p_tur in (9, 19)           then 'Sipariş'
        when p_tur in (109, 119)        then 'Konsinye'
        when p_tur in (13, 17)          then 'Tahakkuk'
        when p_tur = 128                then 'Hasta Fişi'
        when p_tur in (10, 14)          then 'İrsaliye'
        when p_tur = 16                 then 'Satış Fişi'
        when p_tur = 12                 then 'Alış Fişi'
        when p_tur in (3, 4)            then 'Fiş'
        when p_tur in (11, 15)          then 'Fatura'
        else 'Belge'
    end::varchar;
$$;

comment on function public.fn_belge_kisa_adi(integer, integer) is
  'Belgenin kisa adi - fislerde yonlu (Satış / Alış / Hasta Fişi, 1361). Tahsilat aciklamasi bundan kurulur '
  '("Satış Fişi Tahsilatı"). Istemcideki belgeKisaAdi ile ayni tanim.';
