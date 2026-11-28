"""Convertit les .rgba bruts du test en PNG RGB 8 bits sans alpha (sRGB),
format exigé par App Store Connect. Python standard seulement."""
import struct
import sys
import zlib
from pathlib import Path


def ecrire_png(rgba: bytes, largeur: int, hauteur: int, chemin: Path) -> None:
    lignes = bytearray()
    pas = largeur * 4
    for y in range(hauteur):
        ligne = rgba[y * pas:(y + 1) * pas]
        lignes.append(0)
        # Supprime le canal alpha (l'image est opaque : fond plein).
        rgb = bytearray(largeur * 3)
        rgb[0::3] = ligne[0::4]
        rgb[1::3] = ligne[1::4]
        rgb[2::3] = ligne[2::4]
        lignes += rgb

    def bloc(type_: bytes, donnees: bytes) -> bytes:
        return (struct.pack(">I", len(donnees)) + type_ + donnees
                + struct.pack(">I", zlib.crc32(type_ + donnees) & 0xFFFFFFFF))

    png = b"\x89PNG\r\n\x1a\n"
    png += bloc(b"IHDR", struct.pack(">IIBBBBB", largeur, hauteur, 8, 2, 0, 0, 0))
    png += bloc(b"sRGB", b"\x00")
    png += bloc(b"IDAT", zlib.compress(bytes(lignes), 9))
    png += bloc(b"IEND", b"")
    chemin.write_bytes(png)


def main() -> None:
    source, destination = Path(sys.argv[1]), Path(sys.argv[2])
    destination.mkdir(parents=True, exist_ok=True)
    for brut in sorted(source.glob("*.rgba")):
        largeur, hauteur = map(int, Path(f"{brut}.taille").read_text().split("x"))
        cible = destination / f"{brut.stem}.png"
        ecrire_png(brut.read_bytes(), largeur, hauteur, cible)
        print(f"{cible} {largeur}x{hauteur}")


if __name__ == "__main__":
    main()
