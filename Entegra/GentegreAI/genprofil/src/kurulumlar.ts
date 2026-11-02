/**
 * BİLİNEN KURULUMLAR (kullanıcı 02.11.2026: "genprofili de gentegreai.com'daki yayınları ayarlayabilecek duruma
 * getir"): giriş ekranında seçilince adres kendiliğinden yazılır; liste dışı bir sunucu için adres yine elle girilir.
 *
 * gentegreai.com müşterileri kendi alt alan adlarında: `https://<kod>.gentegreai.com/<kod>` - kod yayin/
 * nginx-gentegreai.conf'taki firma haritasıyla aynı. Profil kurulumları henüz IP adresinde (`/genotipai/<ad>`,
 * basic auth) - yayin/yayinla.ps1 profil listesiyle aynı.
 * Yeni müşteri gentegreai.com haritasına eklenince buraya da bir satır eklenir.
 */
export interface Kurulum { ad: string; etiket: string; adres: string; grup: string }

const GENTEGREAI = (kod: string, etiket: string): Kurulum =>
  ({ ad: kod, etiket, adres: `https://${kod}.gentegreai.com/${kod}`, grup: 'gentegreai.com' });
const PROFIL = (ad: string, etiket: string): Kurulum =>
  ({ ad, etiket, adres: `http://46.36.201.170/genotipai/${ad}`, grup: 'Profiller (46.36.201.170)' });

export const KURULUMLAR: Kurulum[] = [
  GENTEGREAI('feta', 'FETA (ERP)'),
  GENTEGREAI('zone', 'ZONE (ERP)'),
  GENTEGREAI('medx', 'MEDX (ERP)'),
  GENTEGREAI('bilim', 'BİLİM (ERP)'),
  PROFIL('hastane', 'Hastane'),
  PROFIL('tipmerkezi', 'Tıp Merkezi'),
  PROFIL('dis', 'Ağız-Diş'),
  PROFIL('lab', 'Laboratuvar'),
  PROFIL('osgb', 'OSGB'),
  PROFIL('goz', 'Göz (dal)'),
  PROFIL('ftr', 'FTR (dal)'),
  PROFIL('goruntuleme', 'Görüntüleme Merkezi'),
  PROFIL('muayene', 'Muayene'),
];
