import { useContext, useState } from 'react';
import { GenForm } from '../bilesenler/GenForm';
import { EBELGE_EK_SEKMELERI, EBELGE_SEKME_BASLIKLARI, ebelgeSekmeSarmalayici } from '../bilesenler/ebelge/EBelgeSekmesi';
import { EkranSekmesiBaglami } from '../bilesenler/sekmeBaglami';
import { c } from '../dil/ceviri';
import { useOturum } from '../kimlik/OturumBaglami';

/**
 * FATURA AYARLARI (1270, Satış › Ayarlar › Fatura Ayarları).
 *
 * Kullanıcı 05.11.2026: "firma/şube bilgilerinde e-belge sekmesini satış ana menüsü altında ayarlar altına
 * 'Fatura Ayarları' menüsü olarak taşı" ve sonra "üstteki şubeyi kaldır.. hangi şube olarak girdiysek onun
 * ayarı yapılsın": ekran OTURUMUN AKTİF ŞUBESİNİ düzenler (üst çubuktaki şube seçimi), ayrı şube combosu yok.
 *
 * İçerik aynı `sube` kartının YALNIZ e-Belge sekmesi (GenForm `yalnizSekmeler`): Genel (Baz Alınacak Şube =
 * gönderici kimliği hangi şubeden, gönderici etiketi, varsayılan seri, mükellefiyet) + Seri Bilgileri / XSLT /
 * tür ayarları SEKMELERİ (EBelgeSekmesi; kullanıcı: "butonları sekme haline getir"). Veri şube satırında, yazma yetkisi yine `sube`; bu ekranın kodu
 * `satis.fatura_ayar` yalnız menü / rota kapısıdır. Kaydet kartı KAPATMAZ (ayar ekranı deseni).
 */
export function FaturaAyarlari() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const { kullanici } = useOturum();
  const subeId = kullanici?.subeId ?? 0;
  const sube = kullanici?.subeler.find(s => s.id === subeId);
  const [tazele, setTazele] = useState(0);
  const kapat = () => ekranSekmesi?.kapat();

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{c('Fatura Ayarları')}</h1>
          <span className="yol">{c('Satış › Ayarlar › Fatura Ayarları')}</span>
          {sube && <span style={{ marginLeft: 'auto', fontSize: 12.5, color: 'var(--soluk, #6b7a8b)' }}>🏢 {sube.ad}</span>}
        </div>
      </div>
      <div className="sahne">
        {subeId > 0 ? (
          // key = şube: üst çubuktan şube değişince kart o şubeyle yeniden okunur. Kayıttan sonra GenForm
          //   kendisi yeniden okur (onKaydedildi true = sayfa yerinde); tazele yalnız şube özetini yeniler.
          <GenForm key={String(subeId)} kaynak="sube" id={subeId} sayfaKipi sayfaBaslikYok silYok hatirlatYok
                   seritAlanlari={SERIT_YOK}
                   ekSekmeler={EBELGE_EK_SEKMELERI} sekmeSarmalayici={ebelgeSekmeSarmalayici(tazele)}
                   sekmeBasliklari={EBELGE_SEKME_BASLIKLARI} yalnizSekmeler={YALNIZ_EBELGE}
                   onKapat={kapat}
                   onKaydedildi={() => { setTazele(t => t + 1); return true }} />
        ) : <div className="bilgi-kutusu">{c('Aktif şube yok; üst çubuktan şube seçin.')}</div>}
      </div>
    </>
  );
}

const YALNIZ_EBELGE = ['e-Belge'];
const SERIT_YOK: string[] = [];

export default FaturaAyarlari;
