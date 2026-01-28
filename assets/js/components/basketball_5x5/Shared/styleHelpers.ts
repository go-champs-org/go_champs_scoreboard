const teamBorderStyle = (teamPrimaryColor: string | null) => {
  return teamPrimaryColor
    ? { border: `3px solid ${teamPrimaryColor}`, borderRadius: '5px' }
    : {};
};

export { teamBorderStyle };
