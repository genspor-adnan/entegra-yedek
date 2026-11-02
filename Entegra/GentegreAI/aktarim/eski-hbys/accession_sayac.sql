-- =============================================================================
--  ACCESSION NUMARASI - ESKİ HBYS'DEN DEVAM (göç 1229)
--
--  Eski HBYS (GEN3000) her şubede accession'ı "Teletıp kurum öneki" + sıfır dolgulu sıra olarak verir
--  (KOSUYOLU: KGM + 13 hane = 16 karakter; SUBELER.TELETIPKURUMONEK / TELETIPACCNOHANESAYISI).
--  Yeni sistemde aynı biçim şube bazlı numara şablonudur (tür 903): bu betik her eski şube için şablonu
--  kurar ve sayacı eski programın son numarasından devam ettirir.
--
--  NE ZAMAN: esle.sql'den sonra VE geçiş günü (al.ps1 ile eski veri tazelendikten sonra) yeniden - eski
--  program o güne kadar numara vermeye devam eder. Tekrar çalıştırmak güvenli: sayaç yalnız ileri alınır.
--  Şube eşlemesi: eski SUBELER.SUBE / KOD yeni sube.ad / kod ile; bulunamazsa varsayılan şube.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create temp table zz_acc on commit drop as
select es.id as eski_sube,
       coalesce((select s.id from public.sube s
                  where upper(btrim(s.ad)) = upper(btrim(es.sube)) or upper(btrim(s.kod)) = upper(btrim(es.kod))
                  order by s.id limit 1),
                (select s.id from public.sube s where s.varsayilan = 1 order by s.id limit 1), 1) as sube_id,
       btrim(es.teletipkurumonek) as onek,
       greatest(coalesce(es.teletipaccnohanesayisi, 16), length(btrim(es.teletipkurumonek)) + 1) as hane
  from eski.subeler es
 where coalesce(btrim(es.teletipkurumonek), '') <> '';

-- Eski programın son numarası: önekle başlayan, tam boyda, öneki dışında yalnız rakam olanlar.
alter table zz_acc add column son_no bigint;
update zz_acc a set son_no = coalesce((
    select max(substr(p.accessionnum, length(a.onek) + 1)::bigint)
      from eski.para p
     where p.accessionnum like a.onek || '%' and length(p.accessionnum) = a.hane
       and substr(p.accessionnum, length(a.onek) + 1) ~ '^[0-9]+$'), 0);
-- Yeni sistemde (aktarım ya da canlı kullanım) aynı önekle verilmiş daha büyük numara varsa o esas.
update zz_acc a set son_no = greatest(a.son_no, coalesce((
    select max(substr(i.accession_no, length(a.onek) + 1)::bigint)
      from public.radyoloji_istem i
     where i.accession_no like a.onek || '%' and length(i.accession_no) = a.hane
       and substr(i.accession_no, length(a.onek) + 1) ~ '^[0-9]+$'), 0));

-- Şablon: şube başına tek aktif tür 903 satırı (varsa önek / hane güncellenir).
update public.numara_sablonu n
   set on_ek = a.onek, baslama_no = lpad((a.son_no + 1)::text, a.hane - length(a.onek), '0'),
       aciklama = 'Radyoloji accession (eski HBYS ' || a.onek || ', 1229)', degistirme_tarihi = now()
  from zz_acc a
 where n.tur = 903 and n.sube_id = a.sube_id and n.durum = 1
   and (n.on_ek <> a.onek or n.hane <> a.hane - length(a.onek));
insert into public.numara_sablonu (tur, baslama_tarihi, on_ek, baslama_no, sube_id, durum, aciklama)
select 903, current_date, a.onek, lpad((a.son_no + 1)::text, a.hane - length(a.onek), '0'), a.sube_id, 1,
       'Radyoloji accession (eski HBYS ' || a.onek || ', 1229)'
  from zz_acc a
 where not exists (select 1 from public.numara_sablonu n where n.tur = 903 and n.sube_id = a.sube_id and n.durum = 1);

-- Sayaç ileri alınır (634: anahtar tablo.alan|SUBE<id>|N<şablon id>; yıllı önek yok).
insert into public.belge_no_sayac (anahtar, tablo_adi, alan_adi, kapsam, son_no)
select 'radyoloji_istem.accession_no|SUBE' || a.sube_id || '|N' || n.id, 'radyoloji_istem', 'accession_no',
       'radyoloji_istem / sablon ' || n.id || ' / sube ' || a.sube_id, a.son_no
  from zz_acc a
  join lateral (select * from public.fn_numara_sablonu_bul(903, a.sube_id, current_date)) n on n.id is not null
on conflict (anahtar) do update set son_no = greatest(public.belge_no_sayac.son_no, excluded.son_no), guncelleme = now()::timestamp;

select 'accession', a.sube_id, a.onek, a.hane, a.son_no as son,
       a.onek || lpad((a.son_no + 1)::text, a.hane - length(a.onek), '0') as siradaki
  from zz_acc a;
commit;
