import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataAyristir, hataMetni } from '../api/sozlesme';
import type { TeletipAyar as Ayar } from '../api/uclar/teletip';
import { guvenli, mesaj } from '../bilesenler/mesaj';
import { c } from '../dil/ceviri';

/**
 * KURUM TELETIP AYARLARI (kullanıcı 11.11.2026: "kurum Teletıp ayar ekranını yap"; mockup Ekranlar/Radyoloji/
 * teletip_mirth.html §5). Kurumun Bakanlık kimliği (SKRS, MEDULA tesis, şube no, MSH-3 firma kodu, karakter seti),
 * Mirth K1 adresi ve gönderim aç / kapat. Mirth REST bağlantısı ve Mirth'teki Teletıp hedefi YALNIZ GÖRÜNTÜLENİR
 * (API ortam değişkeni / Mirth configuration map - bu ekrandan değişmez). Açmak için kimlik tam olmalı (sunucu
 * doğrular). Test değerleri (999999 / 99999999 / TEST) üstte uyarılır. CSS öneki `tta-`.
 */
export function TeletipAyar() {
  const [v, setV] = useState<Ayar | null>(null);
  const [f, setF] = useState<Ayar | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHata, setAlanHata] = useState<Record<string, string>>({});
  const [test, setTest] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);

  const yukle = useCallback(async () => {
    try { const y = await api.teletipAyar(); setV(y); setF(y); setHata(null) } catch (e) { setHata(hataMetni(e)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!v || !f) return <div className="fm-sayfa"><div className="yukleniyor">{c('Yükleniyor…')}</div></div>;

  const degisti = JSON.stringify(ayarGovdesi(f)) !== JSON.stringify(ayarGovdesi(v));
  const ata = (k: keyof Ayar, d: string | boolean) => { setF({ ...f, [k]: d }); setAlanHata(h => ({ ...h, [k]: '' })) };

  const kaydet = async () => {
    setMesgul(true);
    try {
      const y = await api.teletipAyarKaydet(ayarGovdesi(f));
      setV(y); setF(y); setAlanHata({});
      mesaj(c('Teletıp ayarları kaydedildi.'));
    } catch (e) {
      // Alan hataları ilgili kutunun altına; genel metin bildirime.
      const h = hataAyristir(e);
      setAlanHata(h.alanlar);
      mesaj(h.mesaj);
    } finally { setMesgul(false) }
  };
  const baglantiTesti = () => guvenli(async () => {
    const y = await api.teletipBaglantiTesti();
    setTest([
      y.hl7.acik ? `✓ ${c('Teletıp HL7')} ${y.hl7.adres} (${y.hl7.sureMs} ms)` : `✖ ${c('Teletıp HL7')} ${y.hl7.adres || '—'}: ${y.hl7.hata}`,
      !y.mirth.tanimli ? `– ${c('Mirth tanımlı değil')}` : y.mirth.erisilebilir
        ? `✓ Mirth ${y.mirth.surum} · ${y.mirth.kanalSayisi} ${c('kanal')}` : `✖ Mirth: ${y.mirth.hata}`,
    ].join('   '));
  });

  const kutu = (k: keyof Ayar, etiket: string, ipucu: string, ek?: { genislik?: number; yerTutucu?: string }) => (
    <>
      <label htmlFor={`tta-${k}`}>{c(etiket)}</label>
      <div>
        <input id={`tta-${k}`} value={String(f[k] ?? '')} placeholder={ek?.yerTutucu}
          style={ek?.genislik ? { width: ek.genislik } : undefined} onChange={e => ata(k, e.target.value)} />
        <span className="tta-ip">{c(ipucu)}</span>
        {alanHata[k] && <div className="tta-hata">{alanHata[k]}</div>}
      </div>
    </>
  );

  return (
    <div className="fm-sayfa tta" data-testid="teletip-ayar">
      <style>{TTA_STIL}</style>
      <div className="tta-bas">
        <h1>⚙ {c('Teletıp Ayarları')}</h1>
        <span className={`rozet ${v.aktif ? 'olumlu' : 'gri'}`}>{v.aktif ? c('gönderim açık') : c('gönderim kapalı')}</span>
        <div className="tta-sag">
          <button type="button" className="d bir" disabled={!degisti || mesgul} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>
          <button type="button" className="d" disabled={!degisti || mesgul} onClick={() => { setF(v); setAlanHata({}) }}>↩ {c('Vazgeç')}</button>
          <button type="button" className="d" onClick={() => void baglantiTesti()}>🧪 {c('Bağlantı Testi')}</button>
        </div>
      </div>
      {v.uyarilar.length > 0 && <div className="tta-uyari">{v.uyarilar.map(u => <div key={u}>⚠ {u}</div>)}</div>}
      {test && <div className="tta-test">{test}</div>}

      <div className="tta-govde">
        <div className="tta-blok">
          <h4>{c('Gönderim')}</h4>
          <div className="tta-form">
            <label htmlFor="tta-aktif">{c('Teletıp gönderimi')}</label>
            <div>
              <label className="tta-onay"><input id="tta-aktif" type="checkbox" checked={f.aktif} onChange={e => ata('aktif', e.target.checked)} />
                {c('Açık - radyoloji istemleri kabulde HL7 ORM ile kuyruğa girer')}</label>
              {alanHata.aktif && <div className="tta-hata">{alanHata.aktif}</div>}
            </div>
            {kutu('hl7Adres', 'Mirth K1 (HL7) adresi', 'host:port - Mirth TELETIP_HL7 dinleyicisi; Bakanlık\'a Mirth bağlanır', { genislik: 220, yerTutucu: '10.0.0.12:6661' })}
            {kutu('xdsAdres', 'Mirth K2 (KOS) adresi', 'Mirth TELETIP_KOS - sonda / olmalı (…/kos/)', { genislik: 260, yerTutucu: 'http://10.0.0.12:8082/kos/' })}
            {kutu('xdsHastaOid', 'XDS hasta OID', 'TCKN^^^&OID&ISO - Bakanlık: 1.3.6.1.4.1.21367.13.20.3000', { genislik: 220 })}
            <label htmlFor="tta-encoding">{c('Karakter seti (MSH-18)')}</label>
            <div>
              <select id="tta-encoding" value={f.encoding} onChange={e => ata('encoding', e.target.value)}>
                <option value="UTF8">UTF8</option><option value="Windows1254">Windows1254</option>
              </select>
              <span className="tta-ip">{c('Windows1254 Bakanlık\'a önceden bildirilir')}</span>
            </div>
          </div>
        </div>

        <div className="tta-blok">
          <h4>{c('Kurum kimliği')} <span className="tta-ip">· {c('Bakanlık\'a bildirilen - yanlış kod mesajı başka kurumun hesabına düşürür')}</span></h4>
          <div className="tta-form">
            {kutu('kurumSkrs', 'Kurum SKRS kodu', 'ORC-21 - kurum.skrs_kodu (e-Nabız ile ortak)', { genislik: 140 })}
            {kutu('medulaTesisKodu', 'MEDULA tesis kodu', '8 hane - ORC-21 son bileşeni (kurum profili, genel)', { genislik: 140 })}
            {kutu('subeNo', 'Şube no', 'ORC-21 - genelde 1', { genislik: 70 })}
            {kutu('firmaKodu', 'Firma uygulama kodu (MSH-3)', 'e-Nabız sisteminde kayıtlı olduğu gibi (yanlışsa 0275)', { genislik: 220 })}
          </div>
          {v.subeTesisleri.length > 0 && (
            <div className="tta-not">
              {c('Şubeye özel MEDULA tesis kodu var - o şubenin istemlerinde bu değer geçerli:')}{' '}
              {v.subeTesisleri.map(s => `${s.subeAdi || s.subeId}: ${s.tesisKodu}`).join(' · ')}
            </div>
          )}
        </div>

        <div className="tta-blok">
          <h4>Mirth Connect <span className="tta-ip">· {c('yalnız görüntülenir - API ortam değişkenleri ve Mirth\'te değişir')}</span></h4>
          <div className="tta-form tta-salt">
            <label>{c('REST adresi (pano)')}</label><div>{v.mirth.url || <span className="tta-ip">{c('tanımsız (Mirth__Url)')}</span>}</div>
            <label>{c('Kullanıcı')}</label><div>{v.mirth.kullanici}{' '}
              <span className={`rozet ${v.mirth.parolaTanimli ? 'olumlu' : 'hata'}`}>{v.mirth.parolaTanimli ? c('parola tanımlı') : c('parola yok (Mirth__Parola)')}</span></div>
            <label>{c('Sertifika')}</label><div>{v.mirth.sertifikaDogrula ? c('doğrulanıyor') : c('kendinden imzalı kabul (yalnız bu Mirth adresi)')}</div>
            <label>{c('Mirth\'teki Teletıp hedefi')}</label>
            <div>{Object.keys(v.mirth.harita).length === 0 ? <span className="tta-ip">{c('okunamadı')}</span>
              : <>{v.mirth.harita.teletip_hl7_host ?? '?'}:{v.mirth.harita.teletip_hl7_port ?? '?'}
                {v.mirth.harita.teletip_hl7_host === '127.0.0.1' && v.mirth.harita.teletip_hl7_port === '6671'
                  && <> <span className="rozet uyari">{c('dev benzetimi (TELETIP_SIMULATOR)')}</span></>}
                <span className="tta-ip"> · {c('Mirth configuration map (mirth-kanallar.ps1 -TeletipHost / -TeletipPort)')}</span></>}
            </div>
          </div>
        </div>

        <div className="tta-blok">
          <h4>{c('Bakanlık uçları')} <span className="tta-ip">· {c('bilgi')}</span></h4>
          <div className="tta-form tta-salt">
            <label>{c('HL7 alıcı')}</label><div>{c('Bakanlık\'ın verdiği IP : port - Mirth K1 hedefi')}</div>
            <label>{c('Doz (RDSR)')}</label><div>dicom.teletip.saglik.gov.tr : 443 · AE TELETIP_MGA (TLS)</div>
            <label>{c('Bildirim')}</label><div>{c('Mirth sunucusunun çıkış IP\'si ve SKRS kodu teletip@saglik.gov.tr\'ye önceden bildirilir; tanımsız IP\'den gelen bağlantı kesilir.')}</div>
          </div>
        </div>
      </div>
    </div>
  );
}

/** Kaydedilen alanlar (karşılaştırma ve PUT gövdesi). */
function ayarGovdesi(a: Ayar) {
  return { aktif: a.aktif, kurumSkrs: a.kurumSkrs, medulaTesisKodu: a.medulaTesisKodu, subeNo: a.subeNo,
           firmaKodu: a.firmaKodu, encoding: a.encoding, hl7Adres: a.hl7Adres, xdsAdres: a.xdsAdres, xdsHastaOid: a.xdsHastaOid };
}

const TTA_STIL = `
.tta .tta-bas{display:flex;align-items:center;gap:10px;padding:10px 18px;border-bottom:1px solid #e3e9f0}
.tta .tta-bas h1{font-size:16px;margin:0;color:var(--baslik,#14315a)}
.tta .tta-sag{margin-left:auto;display:flex;gap:6px}
.tta .tta-uyari{margin:8px 18px 0;padding:6px 10px;border:1px solid #f2ddbf;background:#fdf9f1;color:#8a6218;border-radius:3px;font-size:12px;line-height:1.6}
.tta .tta-test{margin:8px 18px 0;padding:6px 10px;border:1px solid #cfe0f5;background:#eef4fc;border-radius:3px;font-size:12px}
.tta .tta-govde{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;padding:12px 18px}
@media (max-width:1100px){.tta .tta-govde{grid-template-columns:1fr}}
.tta .tta-blok{border:1px solid #e3e9f0;border-radius:4px;background:#fff}
.tta .tta-blok h4{margin:0;padding:7px 10px;font-size:12px;background:linear-gradient(#f6f9fc,#eef3f9);border-bottom:1px solid #e3e9f0;color:#2c4a6b}
.tta .tta-form{display:grid;grid-template-columns:190px 1fr;gap:8px 12px;padding:10px;align-items:start;font-size:12px}
.tta .tta-form > label{color:var(--soluk,#6b7a8b);font-size:11.5px;padding-top:5px}
.tta .tta-form input:not([type=checkbox]),.tta .tta-form select{height:26px}
.tta .tta-salt > div{padding-top:5px}
.tta .tta-ip{color:var(--soluk,#6b7a8b);font-size:11px;margin-left:8px}
.tta .tta-hata{color:#9d3434;font-size:11px;margin-top:2px}
.tta .tta-onay{display:flex;gap:6px;align-items:center}
.tta .tta-not{margin:0 10px 10px;padding:6px 8px;background:#fdf9f1;border:1px solid #f2ddbf;border-radius:3px;font-size:11.5px;color:#8a6218}
`;
