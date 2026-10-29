#!/bin/bash
# Installe LaTeX (xelatex), la police DejaVu, pdftotext et Pillow. Compter 3 à 6 minutes.
set -e
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  texlive-xetex texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended \
  texlive-lang-french fonts-dejavu-core poppler-utils
pip3 install --quiet pillow || pip3 install --quiet --break-system-packages pillow
python3 -c "import PIL; print('Pillow OK', PIL.__version__)"
xelatex --version | head -1
echo "Dépendances installées."
