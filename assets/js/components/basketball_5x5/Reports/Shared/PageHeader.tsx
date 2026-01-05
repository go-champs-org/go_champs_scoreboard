import React, { useMemo } from 'react';
import { View, Text, Image } from '@react-pdf/renderer';
import QRCode from 'qrcode';

const styles = {
  pageHeader: {
    display: 'flex',
    flexDirection: 'row',
    width: '100%',
    position: 'relative',
    nameContainer: {
      alignItems: 'center',
      fontSize: 10,
      fontWeight: 'bold',
      width: '100%',
    },
    organizationLogo: {
      height: 24,
      width: 24,
      position: 'absolute',
      left: 0,
      top: 0,
    },
    qrCodeContainer: {
      position: 'absolute',
      right: 0,
      top: 0,
      height: 24,
      width: 24,
    },
  },
};

interface PageHeaderProps {
  organizationLogoUrl?: string;
  organizationName: string;
  tournamentName: string;
  qrCodeUrl?: string;
}

function PageHeader({
  organizationLogoUrl,
  organizationName,
  tournamentName,
  qrCodeUrl,
}: PageHeaderProps) {
  const qrCodeDataUrl = useMemo(() => {
    if (!qrCodeUrl) return null;

    try {
      return QRCode.toDataURL(qrCodeUrl, {
        width: 24,
        margin: 1,
        color: {
          dark: '#000000',
          light: '#FFFFFF',
        },
      });
    } catch (error) {
      console.warn('Failed to generate QR code:', error);
      return null;
    }
  }, [qrCodeUrl]);

  return (
    <View style={styles.pageHeader}>
      {organizationLogoUrl && (
        <View style={styles.pageHeader.organizationLogo}>
          <Image
            src={organizationLogoUrl}
            style={{ height: '100%', width: '100%' }}
          />
        </View>
      )}
      <View style={styles.pageHeader.nameContainer}>
        <Text>{organizationName.toUpperCase()}</Text>
        <Text>{`COMPETIÇÃO: ${tournamentName.toUpperCase()}`}</Text>
      </View>
      {qrCodeDataUrl && (
        <View style={styles.pageHeader.qrCodeContainer}>
          <Image
            src={qrCodeDataUrl}
            style={{ height: '100%', width: '100%' }}
          />
        </View>
      )}
    </View>
  );
}

export default PageHeader;
