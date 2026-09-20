-- =====================================================================
--  874_dis_protez_barkot.sql
--  PROTEZ İŞ EMRİ BARKOTLAMA (KTS denetim maddesi D1: "Protez iş
--  süreçlerini takip edebilmek için barkotlama işlemi yapılabiliyor mu?")
--
--  YENİ NUMARA ÜRETİLMEZ. İş emrinin zaten benzersiz bir kimliği var:
--  `isemri_no` (LB-yyyy/nnnn, 706 + 709 tetiği, benzersiz indeks). Barkod
--  ona İKİNCİ bir numara eklemek değil, AYNI numarayı makinenin okuyacağı
--  biçimde basmaktır. İkinci sayaç açmak, laboratuvara giden kâğıtta bir
--  numara, sistemde başka bir numara bırakırdı - kaybolan işin izini bu
--  ikilik siler.
--
--  BARKOT ETİKETİ İŞİN ÜZERİNDE GİDER: ölçü kabıyla laboratuvara çıkar,
--  iş geri geldiğinde okutulur. Denetimin sorduğu "takip" budur: aşama
--  ilerletmek için listede iş aramak yerine etiketi okutmak.
--
--  OKUTMA AYRI KAYNAK OLARAK İŞARETLENİR (`dis_lab_isemri_asama.kaynak`):
--  denetimde "barkotla takip ediliyor" iddiası, aşama satırlarının
--  gerçekten okutmayla yazıldığı gösterilerek kanıtlanır. Ekrandan elle
--  ilerletme de serbest kalır - barkot okuyucusu bozulunca iş durmaz.
--
--  ETİKET BASIMI SAYILIR (`etiket_basim`, `son_etiket_tarihi`): yeniden
--  basılan etiket, kaybolmuş ya da laboratuvarda yırtılmış bir iş demektir;
--  sayı kalite kaydıdır. Basım kaydı iş emrini DEĞİŞTİRMİŞ saymaz
--  (degistiren/degistirme_tarihi'ne dokunulmaz) - basmak bir iş kararı değil.
-- =====================================================================

-- ------------------------------------------------------- kod listesi ----
insert into public.kod_liste (kod, ad)
select 'dis.asama_kaynak', 'Lab Aşama Kaynağı'
 where not exists (select 1 from public.kod_liste k where k.kod = 'dis.asama_kaynak');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('dis.asama_kaynak', 1, 'Ekran'),
    ('dis.asama_kaynak', 2, 'Barkot okutma')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- --------------------------------------------------------- kolonlar ----
alter table public.dis_lab_isemri_asama
  add column if not exists kaynak smallint not null default 1;   -- dis.asama_kaynak

comment on column public.dis_lab_isemri_asama.kaynak is
  '874: asamayi kim ilerletti - 1 ekran, 2 barkot okutma (dis.asama_kaynak).';

alter table public.dis_lab_isemri
  add column if not exists etiket_basim      smallint     not null default 0,
  add column if not exists son_etiket_tarihi timestamptz;

comment on column public.dis_lab_isemri.etiket_basim is
  '874: barkot etiketi kac kez basildi. Tekrar basim = kaybolan/yirtilan etiket.';

-- --------------------------------------------- barkot çözümleme ----
--  Okuyucu klavye gibi yazar: baştaki/sondaki boşluk, küçük harf ve bazı
--  okuyucularda '/' yerine gelen karakter olağandır. Bu yüzden çözümleme
--  TOLERANSLI: harf-rakam dışındaki her şey atılır, büyük harfe çevrilir,
--  önce tam eşleşme aranır. Eşleşme yoksa NULL döner - çağıran "bulunamadı"
--  hatasını kendi diliyle verir.
create or replace function public.fn_dis_isemri_barkod_coz(p_barkod text)
returns integer language sql stable as $$
    select i.id
      from public.dis_lab_isemri i
     where regexp_replace(upper(i.isemri_no), '[^A-Z0-9]', '', 'g')
         = regexp_replace(upper(coalesce(p_barkod, '')), '[^A-Z0-9]', '', 'g')
       and coalesce(p_barkod, '') <> ''
     order by i.id desc
     limit 1;
$$;

comment on function public.fn_dis_isemri_barkod_coz(text) is
  '874: okutulan barkodu (isemri_no) is emri idsine cevirir; noktalama ve '
  'buyuk/kucuk harf farki yok sayilir. Eslesme yoksa NULL.';

-- --------------------------------------------------- etiket görünümü ----
--  Etikette ne yazacağı KLİNİĞİN değil laboratuvarın ihtiyacıdır: hangi
--  hasta, hangi diş, hangi iş, hangi malzeme/renk, ne zamana. Hasta adı
--  tam yazılır - etiket ölçü kabında kliniğin içinde kalır, tüp etiketi
--  gibi kısaltma gerekmez.
create or replace view public.v_dis_lab_isemri_etiket as
select i.id,
       i.sube_id,
       i.isemri_no,
       i.hasta_id,
       t.unvan                              as hasta_adi,
       th.dogum_tarihi,
       coalesce(h.unvan, '')                as hekim_adi,
       i.lab_id,
       l.ad                                 as lab_adi,
       i.is_turu,
       coalesce(kt.ad, '')                  as is_turu_adi,
       i.dis_nolar,
       i.malzeme,
       i.renk,
       i.olcu_tipi,
       coalesce(ko.ad, '')                  as olcu_tipi_adi,
       i.ek_istek,
       i.gonderim_tarihi,
       i.beklenen_tarih,
       i.asama,
       coalesce(ka.ad, '')                  as asama_adi,
       i.etiket_basim,
       i.son_etiket_tarihi
  from public.dis_lab_isemri i
  join public.dis_lab l  on l.id = i.lab_id
  join public.taraf t    on t.id = i.hasta_id
  left join public.taraf_hasta th on th.id = i.hasta_id
  left join public.taraf h on h.id = i.hekim_id
  left join public.kod_liste lt on lt.kod = 'dis.lab_is_turu'
  left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = i.is_turu
  left join public.kod_liste lo on lo.kod = 'dis.olcu_tipi'
  left join public.kod_deger ko on ko.liste_id = lo.id and ko.deger = i.olcu_tipi
  left join public.kod_liste la on la.kod = 'dis.lab_asama'
  left join public.kod_deger ka on ka.liste_id = la.id and ka.deger = i.asama;

comment on view public.v_dis_lab_isemri_etiket is
  '874: protez is emri barkot etiketinin icerigi (KTS D1). Barkod govdesi '
  'isemri_no - ikinci numara uretilmez.';

do $$
begin
    raise notice '874 tamam: protez barkotu (% is emri etiketlenebilir)',
        (select count(*) from public.dis_lab_isemri);
end $$;
