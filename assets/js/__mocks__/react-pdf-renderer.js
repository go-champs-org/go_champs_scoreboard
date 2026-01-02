// Mock for @react-pdf/renderer to avoid ES module issues in Jest
module.exports = {
  Document: 'Document',
  Page: 'Page',
  Text: 'Text',
  View: 'View',
  StyleSheet: {
    create: (styles) => styles,
  },
  PDFDownloadLink: 'PDFDownloadLink',
  BlobProvider: 'BlobProvider',
  pdf: () => ({
    toBlob: () => Promise.resolve(new Blob()),
  }),
};
