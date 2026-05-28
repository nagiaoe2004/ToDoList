const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const AdmZip = require('adm-zip');
const { buildReport } = require('./report_content');

const OUT = path.join(__dirname, '..', 'Bao Cao Todo Flutter (fix).docx');
const SRC = OUT;

function esc(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function run(text, opts = {}) {
  const { bold = false, size = 24, font = 'Times New Roman', spacing = 200 } = opts;
  const rPr = [
    bold ? '<w:b/>' : '',
    `<w:rFonts w:ascii="${font}" w:hAnsi="${font}" w:cs="${font}"/>`,
    `<w:sz w:val="${size}"/>`,
    `<w:szCs w:val="${size}"/>`,
  ].join('');
  return `<w:p><w:pPr><w:spacing w:after="${spacing}"/></w:pPr><w:r><w:rPr>${rPr}</w:rPr><w:t xml:space="preserve">${esc(text)}</w:t></w:r></w:p>`;
}

function heading(text, level = 1) {
  const sizes = { 1: 32, 2: 28, 3: 26 };
  return run(text, { bold: true, size: sizes[level] || 24, spacing: level === 1 ? 240 : 180 });
}

function blank() {
  return '<w:p/>';
}

function codeBlock(text) {
  return text.split('\n').map((line) => run(line, { font: 'Consolas', size: 20, spacing: 0 })).join('');
}

function tableRow(cells, bold = false) {
  const tcs = cells
    .map(
      (c) =>
        `<w:tc><w:tcPr><w:tcW w:w="2000" w:type="dxa"/></w:tcPr><w:p><w:r><w:rPr>${bold ? '<w:b/>' : ''}<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:sz w:val="20"/></w:rPr><w:t xml:space="preserve">${esc(c)}</w:t></w:r></w:p></w:tc>`
    )
    .join('');
  return `<w:tbl><w:tblPr><w:tblW w:w="5000" w:type="pct"/><w:tblBorders><w:top w:val="single" w:sz="4"/><w:left w:val="single" w:sz="4"/><w:bottom w:val="single" w:sz="4"/><w:right w:val="single" w:sz="4"/><w:insideH w:val="single" w:sz="4"/><w:insideV w:val="single" w:sz="4"/></w:tblBorders></w:tblPr><w:tr>${tcs}</w:tr></w:tbl>`;
}

function image(relId, widthCx = 5715000, heightCy = 3810000) {
  return [
    '<w:p>',
      '<w:pPr>',
        '<w:jc w:val="center"/>',
        '<w:spacing w:before="120" w:after="120"/>',
      '</w:pPr>',
      '<w:r>',
        '<w:drawing>',
          `<wp:inline distT="0" distB="0" distL="0" distR="0">`,
            `<wp:extent cx="${widthCx}" cy="${heightCy}"/>`,
            '<wp:effectExtent l="0" t="0" r="0" b="0"/>',
            `<wp:docPr id="1" name="Picture 1"/>`,
            '<wp:cNvGraphicFramePr>',
              '<a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>',
            '</wp:cNvGraphicFramePr>',
            '<a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">',
              '<a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">',
                '<pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">',
                  '<pic:nvPicPr>',
                    '<pic:cNvPr id="1" name="Picture 1"/>',
                    '<pic:cNvPicPr/>',
                  '</pic:nvPicPr>',
                  '<pic:blipFill>',
                    `<a:blip r:embed="${relId}" cstate="print"/>`,
                    '<a:stretch>',
                      '<a:fillRect/>',
                    '</a:stretch>',
                  '</pic:blipFill>',
                  '<pic:spPr>',
                    '<a:xfrm>',
                      '<a:off x="0" y="0"/>',
                      `<a:ext cx="${widthCx}" cy="${heightCy}"/>`,
                    '</a:xfrm>',
                    '<a:prstGeom prst="rect">',
                      '<a:avLst/>',
                    '</a:prstGeom>',
                  '</pic:spPr>',
                '</pic:pic>',
              '</a:graphicData>',
            '</a:graphic>',
          '</wp:inline>',
        '</w:drawing>',
      '</w:r>',
    '</w:p>'
  ].join('');
}

const sections = [];
buildReport(sections, { heading, run, blank, codeBlock, tableRow });

const body = sections.join('');
const documentXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
  xmlns:wp="http://schemas.openxmlformats.org/wordprocessingml/2006/wordprocessingDrawing"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
  xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
  mc:Ignorable="w14 w15 wp14">
  <w:body>${body}<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr></w:body>
</w:document>`;

const tmpDir = path.join(__dirname, '_docx_tmp');
if (fs.existsSync(tmpDir)) fs.rmSync(tmpDir, { recursive: true });
fs.mkdirSync(tmpDir, { recursive: true });

let outZip = '';
try {
  fs.copyFileSync(SRC, path.join(tmpDir, 'src.zip'));
  
  // Extract using adm-zip to bypass any powershell script policy limitations
  const srcZip = new AdmZip(path.join(tmpDir, 'src.zip'));
  srcZip.extractAllTo(path.join(tmpDir, 'extracted'), true);
  
  // Write the updated document.xml
  fs.writeFileSync(path.join(tmpDir, 'extracted', 'word', 'document.xml'), documentXml, 'utf8');
  
  // Package back to a zip file using adm-zip
  const zip = new AdmZip();
  zip.addLocalFolder(path.join(tmpDir, 'extracted'), '');
  
  outZip = path.join(tmpDir, 'out.zip');
  zip.writeZip(outZip);
  
  try {
    fs.copyFileSync(outZip, OUT);
    console.log('Generated:', OUT);
  } catch (copyErr) {
    if (copyErr.code === 'EBUSY') {
      const alt = path.join(__dirname, '..', 'Bao Cao Todo Flutter (moi).docx');
      fs.copyFileSync(outZip, alt);
      console.log('File goc dang mo — da ghi:', alt);
    } else {
      throw copyErr;
    }
  }
} finally {
  if (fs.existsSync(tmpDir)) fs.rmSync(tmpDir, { recursive: true, force: true });
}
