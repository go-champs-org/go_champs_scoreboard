import React from 'react';
import { PDFViewer } from '@react-pdf/renderer';
import {
  REPORT_REGISTRY,
  ReportComponentProps,
  ReportConfig,
} from './reportRegistry';

interface ReportViewerProps {
  report_data: string;
  report_slug: string;
}

function ReportViewer({ report_data, report_slug }: ReportViewerProps) {
  const reportConfig = REPORT_REGISTRY[report_slug];
  if (!reportConfig) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h3>Report not found: {report_slug}</h3>
        <p>Available reports: {Object.keys(REPORT_REGISTRY).join(', ')}</p>
      </div>
    );
  }

  try {
    const parsedData = reportConfig.parseData(report_data);
    const ReportComponent = reportConfig.component;
    return (
      <PDFViewer width="100%" height="100%">
        <ReportComponent data={parsedData} />
      </PDFViewer>
    );
  } catch (error) {
    return (
      <div style={{ padding: '20px', textAlign: 'center', color: 'red' }}>
        <h3>Error rendering report: {report_slug}</h3>
        <p>
          {error instanceof Error ? error.message : 'Unknown error occurred'}
        </p>
      </div>
    );
  }
}

export default ReportViewer;
