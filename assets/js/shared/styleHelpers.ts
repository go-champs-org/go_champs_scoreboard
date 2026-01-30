const getContrastColor = (hex: string): string => {
  // Remove the hash at the start if it's there
  hex = hex.replace(/^#/, '');

  // Parse the r, g, b values
  let r = parseInt(hex.substring(0, 2), 16);
  let g = parseInt(hex.substring(2, 4), 16);
  let b = parseInt(hex.substring(4, 6), 16);

  // Calculate the luminance
  let luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

  // Return black for light colors and white for dark colors
  return luminance > 0.5 ? '#1e1200' : '#fdfdff';
};

const teamPlayersCaptionStyle = (teamPrimaryColor: string | null) => {
  const contrastColor = teamPrimaryColor
    ? getContrastColor(teamPrimaryColor)
    : null;
  return teamPrimaryColor
    ? { backgroundColor: teamPrimaryColor, color: contrastColor || 'inherit' }
    : {};
};

export { getContrastColor, teamPlayersCaptionStyle };
