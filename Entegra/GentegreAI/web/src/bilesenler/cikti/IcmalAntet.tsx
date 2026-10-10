import { AntetLogo } from '../AntetLogo';

/**
 * İCMAL ANTETİ - bütün icmal A4'lerinde (önizleme, yazdırma, Word / HTML /
 * Excel) tek düzen (kullanıcı 10.10.2026): solda logo; logonun sağında alt
 * alta kurum adı, adres, telefon; en sağda düzenleme tarihi ve düzenleyen.
 *
 * On icmal bu bloğu ayrı ayrı kopyalıyordu (adres · il · telefon tek satır);
 * düzen tek yerde değişsin diye ortak bileşen. Excel bu sınıfları okur
 * (ciktiDonustur.excelBloklari) - sınıf adları değişirse orası da değişmeli.
 */
export function IcmalAntet({ antet, duzenleyen }: { antet: Record<string, unknown> | null; duzenleyen: string }) {
  const metin = (x: unknown) => (x == null ? '' : String(x).trim());
  const adres = [metin(antet?.adres), [metin(antet?.ilce), metin(antet?.il)].filter(Boolean).join(' / ')]
    .filter(Boolean).join(' · ');
  const tel = metin(antet?.telefon);
  return (
    <div className="a4-bas">
      <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
      <div className="a4-kurum">
        <div className="kurum">{metin(antet?.unvan)}</div>
        {adres && <div className="kurum-alt">{adres}</div>}
        {tel && <div className="kurum-alt">Tel: {tel}</div>}
      </div>
      <div className="a4-tarih">Düzenleme: {new Date().toLocaleDateString('tr-TR')}<br />Düzenleyen: {duzenleyen}</div>
    </div>
  );
}
