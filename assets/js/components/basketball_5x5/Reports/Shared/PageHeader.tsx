import React, { useMemo } from 'react';
import { View, Text, Image } from '@react-pdf/renderer';
import QRCode from 'qrcode';
import { useTranslation } from 'react-i18next';

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
    logosContainer: {
      position: 'absolute',
      display: 'flex',
      left: 0,
      top: 0,
      height: 24,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'flex-start',
      logo: {
        height: 24,
        width: 24,
        marginRight: 2,
      },
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

interface Sponsor {
  name: string;
  logo_url: string;
}

interface PageHeaderProps {
  organizationLogoUrl?: string;
  tournamentLogoUrl?: string;
  sponsors?: Sponsor[];
  organizationName: string;
  tournamentName: string;
  qrCodeUrl?: string;
}

function PageHeader({
  tournamentLogoUrl,
  sponsors = [],
  organizationLogoUrl,
  organizationName,
  tournamentName,
  qrCodeUrl,
}: PageHeaderProps) {
  const { t } = useTranslation();
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
      <View style={styles.pageHeader.logosContainer}>
        {organizationLogoUrl && (
          <View style={styles.pageHeader.logosContainer.logo}>
            <Image
              src={organizationLogoUrl}
              style={{ height: '100%', width: '100%' }}
            />
          </View>
        )}
        {tournamentLogoUrl && (
          <View style={styles.pageHeader.logosContainer.logo}>
            <Image
              src={tournamentLogoUrl}
              style={{ height: '100%', width: '100%' }}
            />
          </View>
        )}
        {sponsors.map((sponsor) => (
          <View
            key={sponsor.name}
            style={styles.pageHeader.logosContainer.logo}
          >
            <Image
              src={sponsor.logo_url}
              style={{ height: '100%', width: '100%' }}
            />
          </View>
        ))}
      </View>
      <View style={styles.pageHeader.nameContainer}>
        <Text>{organizationName.toUpperCase()}</Text>
        <Text>{`${t(
          'basketball.reports.pageHeader.competition',
        ).toUpperCase()}: ${tournamentName.toUpperCase()}`}</Text>
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
