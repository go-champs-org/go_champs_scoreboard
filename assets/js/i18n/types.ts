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
            editTeams: string;
            editOfficials: string;
            eventLogs: string;
            streamViews: string;
            startLive: string;
            endLive: string;
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
            endLiveConfirmation: {
              title: string;
              endSoonWarning: string;
              message: string;
              messageWithReports: string;
              reportGenerationInfo: string;
              generatingReports: string;
              cannotClose: string;
              errorTitle: string;
              retry: string;
              processing: string;
              endLive: string;
              cancel: string;
            };
          };
          stats: {
            abbreviations: {
              points: string;
              assists: string;
              rebounds: string;
              offensiveRebounds: string;
              defensiveRebounds: string;
              steals: string;
              blocks: string;
              turnovers: string;
              personalFouls: string;
              flagrantFouls: string;
              technicalFouls: string;
              onePoint: string;
              onePointPercentage: string;
              twoPoints: string;
              twoPointPercentage: string;
              threePoints: string;
              threePointPercentage: string;
              player: string;
              missOnePoint: string;
              missTwoPoints: string;
              missThreePoints: string;
              defensiveReboundsShort: string;
              offensiveReboundsShort: string;
              personalFoulsShort: string;
              technicalFoulsShort: string;
              flagrantFoulsShort: string;
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
              unsportsmanlikeFault: string;
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
            modal: {
              title: string;
              addPlayer: string;
              name: string;
              delete: string;
            };
          };
          coaches: {
            modal: {
              title: string;
              addCoach: string;
              name: string;
              type: string;
              actions: string;
            };
            types: {
              headCoach: string;
              assistantCoach: string;
            };
          };
          officials: {
            modal: {
              title: string;
              addOfficial: string;
              name: string;
              type: string;
              licenseNumber: string;
              federation: string;
              edit: string;
              delete: string;
            };
            types: {
              scorer: string;
              assistantScorer: string;
              timekeeper: string;
              shotClockOperator: string;
              crewChief: string;
              umpire1: string;
              umpire2: string;
            };
            placeholders: {
              officialName: string;
              licenseNumber: string;
              federation: string;
            };
            alerts: {
              enterName: string;
            };
          };
          reports: {
            fibaScoresheet: string;
          };
        };
      };
    };
  }
}
