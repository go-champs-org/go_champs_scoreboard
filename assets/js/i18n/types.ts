import 'react-i18next';

declare module 'react-i18next' {
  interface CustomTypeOptions {
    defaultNS: 'translation';
    resources: {
      translation: {
        basketball: {
          navigation: {
            boxScore: string;
            editPlayers: string;
            editCoaches: string;
            editOfficials: string;
            eventLogs: string;
            streamViews: string;
            startLive: string;
            endLive: string;
            undoLastPlayerEvent: string;
          };
          clock: {
            timeout: string;
            pause: string;
            start: string;
            endQuarter: string;
            endGame: string;
            tooltips: {
              minusOneMinute: string;
              minusOneSecond: string;
              plusOneSecond: string;
              plusOneMinute: string;
            };
          };
          modals: {
            gameEnded: {
              title: string;
              message: string;
            };
          };
          stats: {
            abbreviations: {
              rebounds: string;
              offensiveRebounds: string;
              defensiveRebounds: string;
              assists: string;
              steals: string;
              blocks: string;
              turnovers: string;
              personalFouls: string;
              technicalFouls: string;
            };
            controls: {
              onePt: string;
              twoPts: string;
              threePts: string;
              missOnePt: string;
              missTwoPts: string;
              missThreePts: string;
              oneRebOff: string;
              oneRebDef: string;
              oneReb: string;
              oneStl: string;
              oneAss: string;
              oneBlk: string;
              oneTo: string;
              personalFault: string;
              technicalFault: string;
              flagrantFault: string;
            };
          };
          players: {
            controls: {
              substitute: string;
              cancel: string;
            };
            instructions: {
              selectStarting: string;
            };
          };
        };
      };
    };
  }
}
