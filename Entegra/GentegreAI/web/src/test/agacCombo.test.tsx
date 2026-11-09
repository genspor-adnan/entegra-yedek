// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { AgacCombo } from '../bilesenler/AgacCombo';

// DAL / YAPRAK kuralı (kullanıcı 09.11.2026): dala tıklamak açar, pano kapanmaz;
//   yaprağa tıklamak seçer ve pano kapanır.
const kodlar = { '1': 'İlaç', '2': 'Analjezik', '3': 'Antibiyotik', '4': 'Sarf' };
const kodUst = { '2': '1', '3': '1' };

function ac(onDegis = vi.fn()) {
  render(<AgacCombo kodlar={kodlar} kodUst={kodUst} deger="" onDegis={onDegis} />);
  fireEvent.click(screen.getByRole('button'));
  return onDegis;
}

describe('AgacCombo dal / yaprak tıklaması', () => {
  it('dala tıklamak altını açar, seçmez, pano açık kalır', () => {
    const onDegis = ac();
    expect(screen.queryByText(/Analjezik/)).toBeNull();
    fireEvent.click(screen.getByText(/İlaç/));
    expect(screen.getByText(/Analjezik/)).toBeTruthy();
    expect(onDegis).not.toHaveBeenCalled();
    expect(screen.getByPlaceholderText('Ara…')).toBeTruthy();
    fireEvent.click(screen.getByText(/İlaç/));
    expect(screen.queryByText(/Analjezik/)).toBeNull();
  });

  it('yaprağa tıklamak seçer ve panoyu kapatır', () => {
    const onDegis = ac();
    fireEvent.click(screen.getByText(/Sarf/));
    expect(onDegis).toHaveBeenCalledWith('4');
    expect(screen.queryByPlaceholderText('Ara…')).toBeNull();
  });
});
