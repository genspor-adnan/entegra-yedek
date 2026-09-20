import { useCallback, useEffect, useState } from 'react';
import { Modal } from './Modal';
import { api } from '../api/istemci';
import type { GebeIzlemi, GebelikDosyasi, GebelikSonucu } from '../api/uclar/gebelik';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, metinSor } from './mesaj';
import { gunNokta } from './bicim';
import { c as cev } from '../dil/ceviri';

/**
 * GEBELİK DOSYASI VE İZLEMİ (900 — KTS maddesi H10, USS 221).
 *
 * <b>Önce dosya, sonra izlem.</b> "Kaçıncı izlem" ancak bir gebelik içinde
 * anlamlıdır; dosyasız izlem iki ayrı gebeliğin kayıtlarını karıştırırdı.
 * Açık dosya yoksa pencere önce dosya açtırır.
 *
 * <b>Hafta sunucudan gelir</b> (SAT ya da beklenen doğumdan); ekran
 * hesaplamaz - iki yerde hesaplanan bir sayı, bir gün ayrışır.
 *
 * <b>Kilo kilogramdır</b> - 209 çocuk izleminde pakete gram gidiyor, burada
 * kilogram; çevrim sunucuda ve yalnız gereken pakette.
 */
const SAYI = (v: string): number | null => {
  const t = v.trim().replace(',', '.');
  if (t === '') return null;
  const s = Number(t);
  return Number.isFinite(s) ? s : null;
};

export function GebeIzlemModali({ hastaId, hastaAdi, belgeId, onKapat }: {
  hastaId: number; hastaAdi?: string; belgeId?: number | null; onKapat(): void;
}) {
  const [dosyalar, setDosyalar] = useState<GebelikDosyasi[]>([]);
  const [acik, setAcik] = useState<number | null>(null);
  const [izlemler, setIzlemler] = useState<GebeIzlemi[]>([]);
  const [sonuclar, setSonuclar] = useState<GebelikSonucu[]>([]);
  const [sonraki, setSonraki] = useState(1);
  const [sat, setSat] = useState('');
  // 223'ÜN ZORUNLU ÖGESİ (901): SKRS "bir önceki doğum durumu". Kod listesi
  //   henüz çekilmediği için sayı olarak giriliyor; liste dolunca seçime
  //   döner. Boş bırakılırsa dosya yine açılır, yalnız bildirim gitmez.
  const [oncekiDogum, setOncekiDogum] = useState('');
  const [kilo, setKilo] = useState('');
  const [sistolik, setSistolik] = useState('');
  const [diastolik, setDiastolik] = useState('');
  const [fks, setFks] = useState('');
  const [hb, setHb] = useState('');
  const [oneri, setOneri] = useState('');
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      const y = await api.gebelikGecmisi(hastaId);
      setDosyalar(y.dosyalar ?? []);
      setAcik(y.acikGebelikId);
      setIzlemler(y.izlemler ?? []);
      setSonuclar(y.sonuclar ?? []);
      setSonraki(y.sonraki ?? 1);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);
  useEffect(() => { void yukle() }, [yukle]);

  const dosyaAc = async () => {
    if (!sat) { mesaj('Son adet tarihi girin.'); return }
    await guvenli(async () => {
      const y = await api.gebelikAc({
        tarafId: hastaId, sat,
        oncekiDogum: oncekiDogum.trim() === '' ? undefined : Number(oncekiDogum) });
      mesaj(y.mesaj);
      setSat('');
      await yukle();
    });
  };

  const izlemEkle = async () => {
    if (!acik) { mesaj('Önce gebelik dosyası açın.'); return }
    await guvenli(async () => {
      const y = await api.gebeIzlemEkle({
        gebelikId: acik, kacinciIzlem: sonraki, belgeId: belgeId ?? null,
        kiloKg: SAYI(kilo), sistolik: SAYI(sistolik), diastolik: SAYI(diastolik),
        fetusKalpSesi: SAYI(fks), hemoglobin: SAYI(hb), oneri: oneri.trim(),
      });
      mesaj(y.mesaj);
      setKilo(''); setSistolik(''); setDiastolik(''); setFks(''); setHb(''); setOneri('');
      await yukle();
    });
  };

  /**
   * GEBELİĞİ SONUÇLANDIR (902, USS 224).
   *
   * Sonuç YALNIZ DOĞUM DEĞİLDİR: düşük ve tıbbi tahliye de bildirilir.
   * SKRS kod listesi henüz çekilmediği için kod sayı olarak isteniyor;
   * liste dolunca seçime döner. Kayıt dosyayı kapatır ve paketi doğurur -
   * ikisini ayırmak, kapanmış ama bildirilmemiş gebelikler üretirdi.
   */
  const sonucla = async (id: number) => {
    const kod = await metinSor(
      'Gebelik sonucu (SKRS kodu) - doğum, düşük ya da tıbbi tahliye:',
      '', 'Gebelik Sonucu');
    if (kod === null || kod.trim() === '') return;

    const canli = await metinSor('Canlı doğan bebek sayısı (boş geçilebilir):',
                                 '', 'Gebelik Sonucu');
    if (canli === null) return;

    await guvenli(async () => {
      const y = await api.gebelikSonucla(id, {
        sonuc: Number(kod),
        canliBebek: canli.trim() === '' ? undefined : Number(canli),
      });
      mesaj(y.mesaj);
      await yukle();
    });
  };

  const acikDosya = dosyalar.find(d => d.id === acik);

  return (
    <Modal baslik={`🤰 ${cev('Gebelik İzlemi')}${hastaAdi ? ' · ' + hastaAdi : ''}`}
           onKapat={onKapat}
           alt={<button type="button" className="d" onClick={onKapat}>{cev('Kapat')}</button>}>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {!acik && (
        <div className="kagrup">
          <h6>{cev('Gebelik dosyası aç')}</h6>
          <div className="ds-sr">
            <div className="alan">
              <label>{cev('Son adet tarihi')}</label>
              <input type="date" value={sat} onChange={e => setSat(e.target.value)} />
            </div>
            <div className="alan">
              <label>{cev('Bir önceki doğum durumu (SKRS)')}</label>
              <input value={oncekiDogum} onChange={e => setOncekiDogum(e.target.value)}
                     inputMode="numeric" placeholder={cev('kod')} />
            </div>
            <button type="button" className="b" onClick={() => void dosyaAc()}>
              {cev('Dosya Aç')}
            </button>
          </div>
          <div className="not">
            {cev('Hafta ve tahmini doğum bu tarihten hesaplanır.')}
          </div>
        </div>
      )}

      {acikDosya && (
        <div className="ds-ic">
          <b>{acikDosya.gebelikNo}. {cev('gebelik')}</b>
          {acikDosya.hafta !== null && ` · ${acikDosya.hafta}. ${cev('hafta')}`}
          {acikDosya.tahminiDogum && ` · ${cev('tahmini doğum')} ${gunNokta(acikDosya.tahminiDogum)}`}
          {/* 223 BİLDİRİMİ İKİ ALANI DA İSTER (901): eksikse gönderilmiyor -
              bunu söylemek, sessizce göndermemekten iyidir. */}
          {!acikDosya.bildirimeHazir && (
            <span className="rozet uyari" style={{ marginLeft: 6 }}>
              {cev('Gebelik bildirimi için son adet tarihi ve önceki doğum durumu gerekli')}
            </span>
          )}
          {' · '}
          <button type="button" className="d kucuk" onClick={() => void sonucla(acikDosya.id)}>
            {cev('Gebeliği sonuçlandır')}
          </button>
        </div>
      )}

      {acik && (
        <div className="kagrup" style={{ marginTop: 8 }}>
          <h6>
            {sonraki}. {cev('izlem')}
            <span className="sp">{cev('izlem sırasını sistem veriyor')}</span>
          </h6>
          <div className="ds-sr">
            <div className="alan">
              <label>{cev('Kilo (kg)')}</label>
              <input value={kilo} onChange={e => setKilo(e.target.value)} inputMode="decimal" />
            </div>
            <div className="alan">
              <label>{cev('Sistolik')}</label>
              <input value={sistolik} onChange={e => setSistolik(e.target.value)}
                     inputMode="numeric" />
            </div>
            <div className="alan">
              <label>{cev('Diastolik')}</label>
              <input value={diastolik} onChange={e => setDiastolik(e.target.value)}
                     inputMode="numeric" />
            </div>
            <div className="alan">
              <label>{cev('Fetüs kalp sesi')}</label>
              <input value={fks} onChange={e => setFks(e.target.value)} inputMode="numeric" />
            </div>
            <div className="alan">
              <label>{cev('Hemoglobin')}</label>
              <input value={hb} onChange={e => setHb(e.target.value)} inputMode="decimal" />
            </div>
          </div>
          <div className="alan">
            <label>{cev('Öneri')}</label>
            <input value={oneri} onChange={e => setOneri(e.target.value)} />
          </div>
          <button type="button" className="b" onClick={() => void izlemEkle()}>
            {cev('İzlemi Kaydet')}
          </button>
        </div>
      )}

      {sonuclar.length > 0 && (
        <>
          <div className="ds-gb" style={{ marginTop: 10 }}>
            {cev('Gebelik sonuçları')}
            <span className="ds-sp sonuk">{cev('USS 224 ile bildirilir')}</span>
          </div>
          <div className="ds-dg"><table>
            <thead><tr>
              <th className="orta">{cev('Sonlanma')}</th>
              <th className="sag">{cev('Hafta')}</th>
              <th className="orta">{cev('Sonuç')}</th>
              <th className="sag">{cev('Canlı')}</th>
              <th className="sag">{cev('Ölü')}</th>
            </tr></thead>
            <tbody>
              {sonuclar.map(s => (
                <tr key={s.id}>
                  <td className="orta">{gunNokta(s.sonlanmaTarihi)}</td>
                  <td className="sag">{s.sonlanmaHaftasi ?? '—'}</td>
                  <td className="orta">{s.sonuc}</td>
                  <td className="sag">{s.canliBebek ?? '—'}</td>
                  <td className="sag">{s.oluBebek ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table></div>
        </>
      )}

      <div className="ds-gb" style={{ marginTop: 10 }}>
        {cev('İzlemler')}
        <span className="ds-sp sonuk">{izlemler.length} {cev('kayıt')}</span>
      </div>
      <div className="ds-dg"><table>
        <thead><tr>
          <th className="orta">{cev('İzlem')}</th><th className="sag">{cev('Hafta')}</th>
          <th className="orta">{cev('Tarih')}</th><th className="sag">{cev('Kilo')}</th>
          <th className="orta">TA</th><th className="sag">FKS</th>
          <th className="sag">Hb</th><th className="orta">{cev('Durum')}</th>
        </tr></thead>
        <tbody>
          {izlemler.map(i => (
            <tr key={i.id} className={i.durum === 0 ? 'sonuk' : undefined}>
              <td className="orta">{i.kacinciIzlem}</td>
              <td className="sag">{i.hafta ?? '—'}</td>
              <td className="orta">{gunNokta(i.izlemTarihi)}</td>
              <td className="sag">{i.kiloKg ?? '—'}</td>
              <td className="orta">
                {i.sistolik || i.diastolik ? `${i.sistolik ?? '?'}/${i.diastolik ?? '?'}` : '—'}
              </td>
              <td className="sag">{i.fetusKalpSesi ?? '—'}</td>
              <td className="sag">{i.hemoglobin ?? '—'}</td>
              <td className="orta">
                {i.durum === 1
                  ? <span className="rozet olumlu">{cev('Geçerli')}</span>
                  : <span className="rozet gri" title={i.iptalNeden}>{cev('İptal')}</span>}
              </td>
            </tr>
          ))}
          {izlemler.length === 0 && (
            <tr><td colSpan={8} className="not">{cev('Kayıtlı izlem yok.')}</td></tr>
          )}
        </tbody>
      </table></div>
    </Modal>
  );
}
