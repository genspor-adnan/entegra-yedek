-- 922 — Lab referans aralıkları yaş/cinsiyete göre. Kullanıcı: "klorür, albümin,
-- ALP gibi tetkiklerin referansı yok/gelmiyor; yaş ve cinsiyete göre ekle."
--
-- KÖK NEDEN: mevcut generic satırlar yas_alt_gun=0 VE yas_ust_gun=0 ile
-- eklenmiş; fn_lab_referans "v_yas_gun between yas_alt and yas_ust" ile eşlediği
-- için erişkin (6570 gün) hiçbir zaman 0..0 aralığına düşmüyor → referans
-- görünmüyordu.
--
-- A) Tüm generic (0..0) satırları yaş-sınırsıza çevir (0..43800 gün ≈ 120 yıl).
-- B) Klinik olarak yaş/cinsiyete bağlı analitlere gerçek bantlar (erişkin E/K +
--    gerekli yerde pediatrik). Idempotent: kaynak='seed922' işaretli satır varsa
--    o tetkik atlanır.

-- A) GENERIC SATIRLARI YAŞ-SINIRSIZ YAP -----------------------------------------
update public.lab_tetkik_referans
   set yas_ust_gun = 43800
 where yas_alt_gun = 0 and yas_ust_gun = 0;

-- B) YAŞ/CİNSİYET BANTLARI -------------------------------------------------------
-- cinsiyet: 0 farketmez · 1 Erkek · 2 Kadın. Yaş gün cinsinden (14y≈5110, 15y≈5475).
do $$
declare
  v jsonb := $j$[
    {"kod":"ALP","satir":[
      {"c":0,"ya":0,"yu":5110,"a":100,"u":400},
      {"c":1,"ya":0,"yu":43800,"a":45,"u":129},
      {"c":2,"ya":0,"yu":43800,"a":35,"u":104}
    ]},
    {"kod":"ALT","satir":[
      {"c":1,"ya":0,"yu":43800,"a":0,"u":41},
      {"c":2,"ya":0,"yu":43800,"a":0,"u":33}
    ]},
    {"kod":"AST","satir":[
      {"c":1,"ya":0,"yu":43800,"a":0,"u":40},
      {"c":2,"ya":0,"yu":43800,"a":0,"u":32}
    ]},
    {"kod":"GGT","satir":[
      {"c":1,"ya":0,"yu":43800,"a":8,"u":61},
      {"c":2,"ya":0,"yu":43800,"a":5,"u":36}
    ]},
    {"kod":"KRE","satir":[
      {"c":0,"ya":0,"yu":5475,"a":0.3,"u":0.7},
      {"c":1,"ya":0,"yu":43800,"a":0.74,"u":1.35},
      {"c":2,"ya":0,"yu":43800,"a":0.59,"u":1.04}
    ]},
    {"kod":"URIC","satir":[
      {"c":1,"ya":0,"yu":43800,"a":3.4,"u":7.0,"pu":12},
      {"c":2,"ya":0,"yu":43800,"a":2.4,"u":6.0,"pu":12}
    ]},
    {"kod":"FERR","satir":[
      {"c":1,"ya":0,"yu":43800,"a":30,"u":400},
      {"c":2,"ya":0,"yu":43800,"a":13,"u":150}
    ]},
    {"kod":"HGB","satir":[
      {"c":0,"ya":183,"yu":2190,"a":10.5,"u":14.0,"pa":7,"pu":20},
      {"c":0,"ya":2190,"yu":5110,"a":11.5,"u":15.5,"pa":7,"pu":20},
      {"c":1,"ya":0,"yu":43800,"a":13.5,"u":17.5,"pa":7,"pu":20},
      {"c":2,"ya":0,"yu":43800,"a":12.0,"u":15.5,"pa":7,"pu":20}
    ]},
    {"kod":"HCT","satir":[
      {"c":1,"ya":0,"yu":43800,"a":41,"u":53},
      {"c":2,"ya":0,"yu":43800,"a":36,"u":46}
    ]},
    {"kod":"RBC","satir":[
      {"c":1,"ya":0,"yu":43800,"a":4.7,"u":6.1},
      {"c":2,"ya":0,"yu":43800,"a":4.2,"u":5.4}
    ]}
  ]$j$;
  s jsonb; a jsonb; tid integer; sr smallint;
begin
  for s in select jsonb_array_elements(v) loop
    select id into tid from public.lab_tetkik where kod = s->>'kod';
    if tid is null then continue; end if;
    -- Idempotent: bu tetkik için seed922 zaten uygulandıysa atla.
    if exists (select 1 from public.lab_tetkik_referans where tetkik_id = tid and kaynak = 'seed922') then
      continue;
    end if;
    -- Eski (generic) satırları temizle, yerine yaş/cinsiyet bantları.
    delete from public.lab_tetkik_referans where tetkik_id = tid;
    sr := 0;
    for a in select jsonb_array_elements(s->'satir') loop
      sr := sr + 1;
      insert into public.lab_tetkik_referans
        (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, gebelik, alt, ust,
         panik_alt, panik_ust, metin, kaynak, sira)
      values (tid, (a->>'c')::smallint, (a->>'ya')::int, (a->>'yu')::int, 0,
              (a->>'a')::numeric, (a->>'u')::numeric,
              nullif(a->>'pa','')::numeric, nullif(a->>'pu','')::numeric,
              '', 'seed922', sr);
    end loop;
  end loop;
end $$;
