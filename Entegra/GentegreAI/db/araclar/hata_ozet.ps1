# =============================================================================
#  hata_ozet.ps1 - hata günlüğü özeti (1078, dokuman/17 §2.1)
#
#  Son N günün hatalarını TÜRÜNE göre listeler: önce sunucu (5xx), sonra
#  ilk kez görülen ("yeni") türler, sonra sıklık. Oturum başında / yayından
#  sonra bakılacak ilk yer. Salt okur.
#
#    powershell -File db\araclar\hata_ozet.ps1              # dün + bugün
#    powershell -File db\araclar\hata_ozet.ps1 -Gun 7       # son 7 gün
#    powershell -File db\araclar\hata_ozet.ps1 -Hepsi       # 401/403/404 dahil
#
#  Ayrıntı (yığın): select * from hata_log where izleme_no = '<no>';
# =============================================================================
param(
    [int]$Gun = 2,
    [switch]$Hepsi,
    [string]$Konteyner = 'gentegre-pg18',
    [string]$Veritabani = 'gentegre_ai'
)

$suz = if ($Hepsi) { '' } else { 'and (http_durum >= 500 or yeni = 1)' }
$sql = @"
select to_char(gun, 'DD.MM') as gun, sinif, http_durum as http, adet,
       case when yeni = 1 then 'YENİ' else '' end as yeni,
       left(yontem || ' ' || yol_imza, 60) as yol,
       left(regexp_replace(ornek_mesaj, '\s+', ' ', 'g'), 90) as mesaj, son_izleme_no
  from public.v_hata_gunluk
 where gun > (now() at time zone 'Europe/Istanbul')::date - $Gun $suz
 order by gun desc, (http_durum >= 500) desc, yeni desc, adet desc;
"@
$ozet = "select public.fn_hata_ozet_metin(d::date) from generate_series((now() at time zone 'Europe/Istanbul')::date - $Gun + 1, (now() at time zone 'Europe/Istanbul')::date, interval '1 day') d order by d desc;"

$env:MSYS_NO_PATHCONV = '1'
docker exec -e PGCLIENTENCODING=UTF8 $Konteyner psql -U postgres -d $Veritabani -tA -c $ozet
''
docker exec -e PGCLIENTENCODING=UTF8 $Konteyner psql -U postgres -d $Veritabani -P pager=off -c $sql
