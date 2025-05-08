import React from 'react';
import { PDFViewer } from '@react-pdf/renderer';
import FibaScoresheet, {
  FibaScoresheetData,
} from '../components/basketball_5x5/Reports/FibaScoresheet';

function ReportViewer({ report_data }: { report_data: string }) {
  const scoresheetData = JSON.parse(report_data) as FibaScoresheetData;
  return (
    <PDFViewer width="100%" height="100%">
      <FibaScoresheet scoresheetData={scoresheetData} />
    </PDFViewer>
  );
}

export default ReportViewer;
