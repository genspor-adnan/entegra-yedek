# -*- coding: utf-8 -*-
"""
"İşe Giriş ve Muayene.xlsx" (resmi Ek-2) sablonundan IKI dosya uretir:

  1) GenForms/İşe Giriş ve Muayene_XLSForm.xlsx  -> KoBo'ya YUKLENECEK form tanimi
  2) Dosya/isg2_eslesme.json                     -> alan -> hucre eslemesi (uretici bunu okur)

Ikisi de asagidaki TEK tanim listesinden uretilir; alan adi ile hucre bir arada
durur, birbirinden kayamaz. Sablonun kendisine dokunulmaz.

  python isg2_form_tanimi_uret.py

KoBo'ya yukledikten sonra formun yeni uid'sini uretici betige gecir:
  python isg2_form_uret.py --token <KEY> --form <UID>
"""
import io, json, os

try:
    from openpyxl import Workbook
except ImportError:
    raise SystemExit("openpyxl gerekli:  pip install openpyxl")

BURASI   = os.path.dirname(os.path.abspath(__file__))
GENFORMS = os.path.join(os.path.dirname(BURASI), "GenForms")
# Ad SABLONA benzemesin: yanlislikla dolu sablon yuklenince KoBo 0 soruluk form uretiyor.
XLSFORM  = os.path.join(GENFORMS, "KOBO_FORM_Ise_Giris_Muayene.xlsx")
ESLESME  = os.path.join(BURASI, "isg2_eslesme.json")

DIL = "Türkçe (tr)"      # Enketo tarih/sayi bicimini form DILINE gore secer;
                         #   dilsiz formda tarih ISO/ABD duzeninde gorunuyordu.
survey  = [["type", "name", "label::" + DIL, "hint::" + DIL,
            "relevant", "calculation", "appearance", "parameters"]]
duz     = {}
isaret  = {}      # etiketli kutucuk: secilen ☒, digeri ☐
kutu    = {}      # bos hucreye X
metin_kutu = {}   # tek hucreye EVET/HAYIR yazar
onekli  = {}
birlesik = {}
imza    = {}
_grup   = []


def yol(ad):
    return "/".join(_grup + [ad]) if _grup else ad


def sat(tip, ad="", etiket="", ipucu="", relevant="", calc="", gorunum="", parametre=""):
    # Fotograf/imza sorularinda max-pixels: gonderim boyutunu kucultur (KoBo onerisi)
    if tip == "image" and not parametre:
        parametre = "max-pixels=1200"
    survey.append([tip, ad, etiket, ipucu, relevant, calc, gorunum, parametre])


def grup(ad, etiket):
    sat("begin_group", ad, etiket)
    _grup.append(ad)


def grup_son():
    _grup.pop()
    sat("end_group")


def A(tip, ad, etiket, hucre=None, relevant="", calc="", ipucu=""):
    if tip == "date" and not ipucu:
        ipucu = "gg/aa/yyyy"          # Excel ciktisinda gun/ay/yil yazilir
    sat(tip, ad, etiket, ipucu, relevant, calc)
    if hucre:
        duz[yol(ad)] = hucre


def EH(ad, etiket, hayir, evet, relevant=""):
    """Sablonda 'Hayır'/'Evet' YAZISI olan kutucuk cifti."""
    sat("select_one evet_hayir", ad, etiket, "", relevant)
    isaret[yol(ad)] = {"hayir": hayir, "evet": evet}


# ============================================================== ISYERININ
grup("isyeri", "İŞYERİNİN")
A("text", "isyeri_unvan",     "Ünvanı",                  "I4")
A("text", "isyeri_sgk_sicil", "SGK/Bölge Müd. Sicil No", "I5")
A("text", "isyeri_adres",     "Adresi",                  "I6")
A("text", "isyeri_tel",       "Telefon No",              "I8")
A("text", "isyeri_faks",      "Faks No",                 "I9")
A("text", "isyeri_eposta",    "E-Posta",                 "I10")
grup_son()

# ============================================================== ISCININ
grup("calisan", "İŞÇİNİN")
sat("image", "calisan_foto", "Fotoğraf")
imza["calisan/calisan_foto"] = {"hucre": "X4", "genislik": 110, "yukseklik": 120}
A("text",    "calisan_ad_soyad",     "Adı ve Soyadı",        "I13")
A("integer", "calisan_cocuk_sayisi", "Çocuk Sayısı",         "X13")
A("text",    "calisan_tc",           "T.C. Kimlik No",       "I14")
A("text",    "calisan_ev_tel",       "Ev Tel",               "X14")
A("text",    "calisan_dogum_yeri",   "Doğum Yeri")
A("date",    "calisan_dogum_tarihi", "Doğum Tarihi")
birlesik["I15"] = {"alanlar": ["calisan/calisan_dogum_yeri", "calisan/calisan_dogum_tarihi"],
                   "ayrac": " "}
A("text",    "calisan_tel",          "Cep Tel",              "X15")
A("select_one cinsiyet", "calisan_cinsiyet", "Cinsiyeti",    "I16")
A("text",    "calisan_meslek",       "Mesleği",              "X16")
A("select_one egitim",   "calisan_egitim",   "Eğitim Durumu", "I17")
A("text",    "calisan_yaptigi_is",   "Yaptığı İş",           "X17")
A("select_one medeni",   "calisan_medeni",   "Medeni Durumu", "I18")
A("text",    "calisan_bolum",        "Çalıştığı Bölüm",      "X18")
A("text",    "calisan_ev_adresi",    "Ev Adresi",            "I19")
grup_son()

# ============================================================== ONCEKI ISYERLERI (4 satir)
grup("onceki", "Daha Önce Çalıştığı İşyerleri")
for i in range(1, 5):
    A("text", "onceki%d_isyeri" % i,     "%d. İşyeri" % i,            "A%d" % (21 + i))
    A("text", "onceki%d_is_kolu" % i,    "%d. İş Kolu" % i,           "I%d" % (21 + i))
    A("text", "onceki%d_yaptigi_is" % i, "%d. Yaptığı İş" % i,        "P%d" % (21 + i))
    A("text", "onceki%d_tarih" % i,      "%d. Giriş-Çıkış Tarihi" % i, "W%d" % (21 + i))
grup_son()

# ============================================================== OZGECMIS
grup("ozgecmis", "ÖZGEÇMİŞİ")
for i in range(1, 5):
    A("text", "kronik_%d" % i, "Konjenital/Kronik Hastalık %d" % i)
    onekli["A%d" % (29 + i)] = {"alan": "ozgecmis/kronik_%d" % i, "onek": "%d) " % i}
A("select_one kan_grubu", "kan_grubu", "Kan Grubu", "S29")
for ad, etiket, satir in (("tetanoz", "Tetanoz", 29), ("hepatit", "Hepatit", 30),
                          ("grip", "Grip", 31), ("diger1", "Diğer (1)", 32),
                          ("diger2", "Diğer (2)", 33)):
    sat("select_one var_yok", "bag_%s" % ad, "Bağışıklama - %s" % etiket)
    isaret["ozgecmis/bag_%s" % ad] = {"yok": "N%d" % satir, "var": "N%d" % satir}
    A("text", "bag_%s_tarih" % ad, "Bağışıklama tarihi - %s" % etiket, "P%d" % satir,
      relevant="${bag_%s} = 'var'" % ad)
grup_son()

grup("soygecmis", "SOYGEÇMİŞİ")
sat("select_one sag_olu", "soy_anne", "Anne")
isaret["soygecmis/soy_anne"] = {"sag": "Y29", "olu": "Y29"}
sat("select_one sag_olu", "soy_baba", "Baba")
isaret["soygecmis/soy_baba"] = {"sag": "Y30", "olu": "Y30"}
A("integer", "soy_kardes", "Kardeş (kaç tane)", "Y31")
A("integer", "soy_cocuk",  "Çocuk (kaç tane)",  "Y32")
A("text",    "soy_aciklama", "Soygeçmiş açıklama", "W33")
grup_son()

# ============================================================== YAKINMALAR
grup("yakinmalar", "1-) Aşağıdaki yakınmalardan herhangi birini geçirdiniz mi?")
for ad, etiket, satir in (
        ("yak_balgamli_oksuruk", "Balgamlı Öksürük", 38),
        ("yak_nefes_darligi",    "Nefes Darlığı",    39),
        ("yak_gogus_agrisi",     "Göğüs Ağrısı",     40),
        ("yak_carpinti",         "Çarpıntı",         41),
        ("yak_boyun_agrisi",     "Boyun Ağrısı",     42),
        ("yak_sirt_agrisi",      "Sırt-Bel Ağrısı",  43),
        ("yak_eklem_agrisi",     "Eklemlerde Ağrı",  44),
        ("yak_ishal_kabizlik",   "İshal veya Kabızlık", 45)):
    EH(ad, etiket, "L%d" % satir, "N%d" % satir)
A("text", "yak_digerleri", "Diğer (belirtiniz)", "L46")
grup_son()

# ============================================================== HASTALIKLAR
grup("hastaliklar", "2-) Aşağıdaki hastalıklardan herhangi birini geçirdiniz mi?")
for ad, etiket, satir in (
        ("hst_kalp",              "Kalp Hastalığı",             38),
        ("hst_seker",             "Şeker Hastalığı",            39),
        ("hst_bobrek",            "Böbrek Rahatsızlığı",        40),
        ("hst_sarilik",           "Sarılık",                    41),
        ("hst_ulser",             "Mide / Oniki Parmak Ülseri", 42),
        ("hst_isitme_kaybi",      "İşitme Kaybı",               43),
        ("hst_gorme_bozuklugu",   "Görme Bozukluğu",            44),
        ("hst_sinir_sistemi",     "Sinir Sistemi Hastalığı",    45),
        ("hst_deri",              "Deri Hastalığı",             46),
        ("hst_besin_zehirlenmesi", "Besin Zehirlenmesi",        47)):
    EH(ad, etiket, "Z%d" % satir, "AB%d" % satir)
A("text", "hst_diger", "Diğer (belirtiniz)", "P48")
grup_son()

# ============================================================== DIGER ANAMNEZ
grup("anamnez_diger", "Tıbbi anamnez (devam)")
for ad, etiket, satir in (
        ("hastane",    "3-) Hastanede yattınız mı?",                        52),
        ("ameliyat",   "4-) Ameliyat geçirdiniz mi?",                       53),
        ("is_kazasi",  "5-) İş kazası geçirdiniz mi?",                      54),
        ("meslek_hst", "6-) Meslek Hastalıkları Hastanesi'ne gittiniz mi?", 55),
        ("maluliyet",  "7-) Maluliyet aldınız mı?",                         56),
        ("tedavi",     "8-) Şu anda herhangi bir tedavi görüyor musunuz?",  57)):
    EH(ad, etiket, "R%d" % satir, "T%d" % satir)
    A("text", "%s_aciklama" % ad, "Evet ise açıklayınız", "V%d" % satir,
      relevant="${%s} = 'evet'" % ad)
grup_son()

# ============================================================== ALISKANLIKLAR
grup("aliskanlik", "Alışkanlıklar")
sat("select_one sigara_durumu", "sigara", "9-) Sigara içiyor musunuz?")
kutu["aliskanlik/sigara"] = {"icmiyor": "D59", "birakmis": "D60", "iciyor": "D61"}
A("integer", "sigara_birakma_ay",  "Bırakalı kaç ay oldu?",  "F60", relevant="${sigara} = 'birakmis'")
A("integer", "sigara_birakma_yil", "Bırakalı kaç yıl oldu?", "J60", relevant="${sigara} = 'birakmis'")
A("integer", "sigara_icmis_ay",    "Kaç ay içmiş?",          "N60", relevant="${sigara} = 'birakmis'")
A("integer", "sigara_icmis_yil",   "Kaç yıl içmiş?",         "R60", relevant="${sigara} = 'birakmis'")
A("integer", "sigara_icmis_adet",  "İçtiği dönemde günde kaç adet?", None, relevant="${sigara} = 'birakmis'")
onekli["V60"] = {"alan": "aliskanlik/sigara_icmis_adet", "sablon": "{deger} / Gün"}
A("integer", "sigara_suren_ay",    "Kaç aydır içiyor?",      "N61", relevant="${sigara} = 'iciyor'")
A("integer", "sigara_suren_yil",   "Kaç yıldır içiyor?",     "R61", relevant="${sigara} = 'iciyor'")
A("integer", "sigara_adet",        "Günde kaç adet?",        None,  relevant="${sigara} = 'iciyor'")
onekli["V61"] = {"alan": "aliskanlik/sigara_adet", "sablon": "{deger} / Gün"}

sat("select_one alkol_durumu", "alkol", "10-) Alkol alıyor musunuz?")
kutu["aliskanlik/alkol"] = {"almiyor": "D63", "birakmis": "D64", "aliyor": "D65"}
A("integer", "alkol_birakma_ay",  "Bırakalı kaç ay oldu?",  "F64", relevant="${alkol} = 'birakmis'")
A("integer", "alkol_birakma_yil", "Bırakalı kaç yıl oldu?", "J64", relevant="${alkol} = 'birakmis'")
A("integer", "alkol_icmis_ay",    "Kaç ay almış?",          "N64", relevant="${alkol} = 'birakmis'")
A("integer", "alkol_icmis_yil",   "Kaç yıl almış?",         "R64", relevant="${alkol} = 'birakmis'")
A("integer", "alkol_suren_ay",    "Kaç aydır alıyor?",      "N65", relevant="${alkol} = 'aliyor'")
A("integer", "alkol_suren_yil",   "Kaç yıldır alıyor?",     "R65", relevant="${alkol} = 'aliyor'")
A("text",    "alkol_miktar",      "Miktar",                 "V65", relevant="${alkol} != 'almiyor'")
A("text",    "alkol_siklik",      "Sıklık",                 "Z65", relevant="${alkol} != 'almiyor'")
grup_son()

# ============================================================== FIZIK MUAYENE
grup("fizik_muayene", "FİZİK MUAYENE SONUÇLARI")
for ad, etiket, satir in (
        ("fm_goz",         "Duyu Organları - Göz",             69),
        ("fm_kbb",         "Duyu Organları - KBB",             70),
        ("fm_deri",        "Duyu Organları - Deri",            71),
        ("fm_kardiyovaskuler", "Kardiyovasküler Sistem",       72),
        ("fm_solunum",     "Solunum Sistemi",                  73),
        ("fm_sindirim",    "Sindirim Sistemi",                 74),
        ("fm_urogenital",  "Ürogenital Sistem",                75),
        ("fm_kas_iskelet", "Kas-İskelet Sistemi",              76),
        ("fm_norolojik",   "Nörolojik Muayene",                77),
        ("fm_psikiyatrik", "Psikiyatrik Muayene",              78),
        ("fm_diger",       "Diğerleri",                        79)):
    sat("select_one evet_hayir", ad, etiket + " - patoloji var mı?")
    isaret["fizik_muayene/%s" % ad] = {"hayir": "O%d" % satir, "evet": "Q%d" % satir}
    A("text", "%s_aciklama" % ad, etiket + " - açıklama", "S%d" % satir)
grup_son()

grup("olcumler", "Ölçümler")
A("text",    "ta",   "TA - Tansiyon (mmHg)", "A81")
A("integer", "nb",   "Nb - Nabız (dk)",      "H81")
A("integer", "boy",  "Boy (cm)",             "M81")
A("decimal", "kilo", "Kilo (kg)",            "Q81")
A("calculate", "vki", "", "U81",
  calc="if(${boy} > 0, round(${kilo} div ((${boy} div 100) * (${boy} div 100)), 1), '')")
A("decimal", "bel",  "Bel Çevresi (cm)",     "Y81")
grup_son()

# ============================================================== LABORATUVAR
grup("laboratuvar", "LABORATUVAR BULGULARI")
for ad, etiket, satir in (
        ("lab_biyolojik",  "Biyolojik Analizler",            84),
        ("lab_kan",        "Kan",                            85),
        ("lab_idrar",      "İdrar",                          86),
        ("lab_radyolojik", "Radyolojik Analizler",           87),
        ("lab_fizyolojik", "Fizyolojik Analizler",           88),
        ("lab_odyometre",  "İşitme Testi (Odyometre)",       89),
        ("lab_sft",        "Solunum Fonksiyon Testi (SFT)",  90),
        ("lab_psikolojik", "Psikolojik Testler",             91),
        ("lab_diger",      "Diğerleri",                      92)):
    A("text", ad, etiket, "O%d" % satir)
grup_son()

# ============================================================== KANAAT / HEKIM
grup("sonuc", "KANAAT VE SONUÇ")
A("text", "kanaat_sart", "Hangi işte/işyerinde çalışmaya elverişli")
onekli["A95"] = {"alan": "sonuc/kanaat_sart",
                 "sablon": "1-) {deger} işinde/işyerinde bedenen çalışmaya elverişlidir."}
sat("select_one kanaat", "kanaat", "Kanaat")
kutu["sonuc/kanaat"] = {"elverisli": "AB95", "kkd_sartiyla": "AB96", "elverisli_degil": None}
grup_son()

grup("hekim", "Hekim")
A("text", "hekim_ad_soyad",       "Hekim Adı Soyadı")
A("text", "hekim_diploma",        "Diploma")
A("text", "hekim_diploma_tescil", "Diploma Tescil No")
A("text", "hekim_belge",          "Belge No")
for ad, etiket, hucre in (("vardiyali", "Vardiyalı çalışabilir", "N98"),
                          ("gece",      "Gece çalışabilir",      "N99"),
                          ("yuksekte",  "Yüksekte çalışabilir",  "N100")):
    sat("select_one evet_hayir", ad, etiket)
    metin_kutu["hekim/%s" % ad] = {"hucre": hucre, "metin": {"evet": "EVET", "hayir": "HAYIR"}}
A("date", "muayene_tarihi", "Muayene Tarihi", "U100")
sat("image", "hekim_kase_imza", "Kaşe / İmza")
imza["hekim/hekim_kase_imza"] = {"hucre": "A99", "genislik": 150, "yukseklik": 50}
grup_son()

grup("onay", "Çalışan Beyanı")
sat("note", "onay_metin",
    "İşe giriş/periyodik muayene olmayı kabul ettiğimi ve muayene sırasında verdiğim "
    "bilgilerin doğru ve eksiksiz olduğunu beyan ederim.")
sat("image", "calisan_imza", "Çalışanın imzası")
imza["onay/calisan_imza"] = {"hucre": "T11", "genislik": 130, "yukseklik": 28}
grup_son()

# ---------------------------------------------------------------- secim listeleri
choices = [["list_name", "name", "label::" + DIL]]
for liste, ogeler in (
    ("evet_hayir",     [("hayir", "Hayır"), ("evet", "Evet")]),
    ("var_yok",        [("yok", "Yok"), ("var", "Var")]),
    ("sag_olu",        [("sag", "Sağ"), ("olu", "Ölü")]),
    ("cinsiyet",       [("erkek", "Erkek"), ("kadin", "Kadın")]),
    ("medeni",         [("evli", "Evli"), ("bekar", "Bekâr"), ("diger", "Diğer")]),
    ("egitim",         [("okuryazar_degil", "Okur-yazar değil"), ("ilkokul", "İlkokul"),
                        ("ortaokul", "Ortaokul"), ("lise", "Lise"), ("onlisans", "Ön lisans"),
                        ("lisans", "Lisans"), ("lisansustu", "Lisansüstü")]),
    ("kan_grubu",      [("0_rh_pozitif", "0 Rh +"), ("0_rh_negatif", "0 Rh −"),
                        ("a_rh_pozitif", "A Rh +"), ("a_rh_negatif", "A Rh −"),
                        ("b_rh_pozitif", "B Rh +"), ("b_rh_negatif", "B Rh −"),
                        ("ab_rh_pozitif", "AB Rh +"), ("ab_rh_negatif", "AB Rh −"),
                        ("bilinmiyor", "Bilinmiyor")]),
    ("sigara_durumu",  [("icmiyor", "İçmiyor"), ("birakmis", "Bırakmış"), ("iciyor", "İçiyor")]),
    ("alkol_durumu",   [("almiyor", "Almıyor"), ("birakmis", "Bırakmış"), ("aliyor", "Alıyor")]),
    ("kanaat",         [("elverisli", "İşinde/işyerinde bedenen çalışmaya elverişlidir"),
                        ("kkd_sartiyla", "KKD kullanması şartıyla çalışmaya elverişlidir"),
                        ("elverisli_degil", "Çalışmaya elverişli değildir")]),
):
    for ad, etiket in ogeler:
        choices.append([liste, ad, etiket])

# ---------------------------------------------------------------- XLSForm yaz
wb = Workbook()
ws = wb.active
ws.title = "survey"
for s in survey:
    ws.append(s)
wc = wb.create_sheet("choices")
for c in choices:
    wc.append(c)
wa = wb.create_sheet("settings")
wa.append(["form_title", "form_id", "default_language", "version"])
wa.append(["İşe Giriş / Periyodik Muayene Formu (Ek-2)", "ise_giris_muayene_ek2", DIL, "3"])
os.makedirs(GENFORMS, exist_ok=True)
wb.save(XLSFORM)

# ---------------------------------------------------------------- esleme yaz
esl = {
    "_aciklama": [
        "KoBo alan adi -> Excel hucresi eslesmesi.",
        "SABLON: GenForms/İşe Giriş ve Muayene.xlsx (resmi Ek-2), sayfa 'İşe Giriş'.",
        "BU DOSYA ELLE YAZILMADI: isg2_form_tanimi_uret.py hem XLSForm'u hem bunu",
        "  ayni tanimdan uretir. Hucre duzeltmesi burada yapilabilir; ama betik",
        "  yeniden calistirilirsa uzerine yazar.",
        "Birlesik hucrelerde SOL UST hucre yazilir; bicim/kenarlik bozulmaz.",
    ],
    "sayfa": "İşe Giriş",
    "duz": duz,
    "isaret": dict({"_aciklama": "Hucrede etiket (Hayır/Evet/VAR-YOK/SAĞ-ÖLÜ) var; secilen ☒, digeri ☐."},
                   **isaret),
    "kutu": dict({"_aciklama": "Bos hucreye X konur."}, **kutu),
    "metin_kutu": dict({"_aciklama": "Tek hucreye EVET/HAYIR yazilir."}, **metin_kutu),
    "birlesik": dict({"_aciklama": "Birden fazla alan tek hucrede."}, **birlesik),
    "onekli": dict({"_aciklama": "Hucredeki etiket korunur / sablona gore yazilir."}, **onekli),
    "imza": dict({"_aciklama": "Ek (question_xpath) -> hucre ve boyut (piksel)."}, **imza),
    "_supheli": [
        "Sigara/alkol bloklarindaki Ay/Yil deger hucreleri (F/J/N/R/V, 60-65 satirlari)",
        "  sablon duzeninden cikarildi; ilk ciktida gozle dogrulanmali.",
        "Bagisiklama VAR/YOK ve soygecmis SAĞ/ÖLÜ hucreleri TEK hucrede iki secenek",
        "  tasiyor ('VAR/YOK'); secilen ☒ ile isaretlenip hucre yeniden yazilir.",
    ],
}
with io.open(ESLESME, "w", encoding="utf-8") as f:
    json.dump(esl, f, ensure_ascii=False, indent=2)

print("XLSForm :", XLSFORM)
print("Esleme  :", ESLESME)
print("survey satiri: %d | secim: %d | duz: %d | isaret: %d | kutu: %d"
      % (len(survey) - 1, len(choices) - 1, len(duz), len(isaret), len(kutu)))
