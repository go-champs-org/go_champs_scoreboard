import React from 'react';
import { pdf } from '@react-pdf/renderer';
import reportHttpClient from './reportHttpClient';
import { getReportConfig, ReportSlug } from '../../shared/reportRegistry';

async function generate(reportSlug: ReportSlug, gameId: string): Promise<Blob> {
  const reportConfig = getReportConfig(reportSlug);
  if (!reportConfig) {
    throw `No report configuration for ${reportSlug}`;
  }

  const reportData = await reportHttpClient.getReportData<any>(
    gameId,
    reportSlug,
  );
  const parsedData = reportConfig.parseData(JSON.stringify(reportData));
  const ReportComponent = reportConfig.component;
  return await pdf(<ReportComponent data={parsedData} />).toBlob();
}

export { generate };
