const teamBackgroundStyle = (teamPrimaryColor: string | null) => {
  return teamPrimaryColor
    ? { backgroundColor: teamPrimaryColor + '30' } // Adding '30' for 12.5% opacity
    : {};
};

export { teamBackgroundStyle };
