const teamBorderStyle = (
  teamType: 'home' | 'away',
  teamPrimaryColor: string | null,
) => {
  const borderConfiguration = teamPrimaryColor
    ? `12px solid ${teamPrimaryColor}`
    : '';
  return teamType === 'home'
    ? { borderRight: borderConfiguration }
    : { borderLeft: borderConfiguration };
};

export { teamBorderStyle };
