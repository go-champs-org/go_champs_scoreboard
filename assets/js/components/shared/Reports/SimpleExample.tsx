import React from 'react';
import { Document, Page, Text } from '@react-pdf/renderer';

function SimpleExample() {
  return (
    <Document>
      <Page>
        <Text>Simple Example</Text>
      </Page>
    </Document>
  );
}

export default SimpleExample;
