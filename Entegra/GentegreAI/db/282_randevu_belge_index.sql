-- 282: BAŞVURU LİSTESİNDE POLİKLİNİK / DOKTOR KOLONLARI İÇİN İNDEKS.
--
-- Liste artık her satırda belgeye bağlı randevuyu okuyor (poliklinik ve hekim
-- adı randevudan gelir - belgede o alanlar yok). `randevu.belge_id` üzerinde
-- indeks yoktu: her satır için tam tarama, liste büyüdükçe ekran yavaşlardı.

create index if not exists ix_randevu_belge on public.randevu (belge_id)
  where belge_id is not null;

comment on index public.ix_randevu_belge is
  'Başvuru listesinin poliklinik/doktor kolonları belgeden randevuya bu indeksle iner (282).';
