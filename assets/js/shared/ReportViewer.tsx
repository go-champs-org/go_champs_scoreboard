import React from 'react';
import { PDFViewer } from '@react-pdf/renderer';
import FibaScoresheet from '../components/basketball_5x5/Reports/FibaScoresheet';

function ReportViewer() {
  return (
    <PDFViewer width="100%" height="100%">
      <FibaScoresheet />
    </PDFViewer>
  );
}

export default ReportViewer;
