export const BLUE = '#3185FC';
export const RED = '#A4031F';

export const colorForPeriod = (period: number) => {
  return period === 1 || period === 3 ? RED : BLUE;
};

export const textColorForPeriod = (period: number) => {
  return {
    color: colorForPeriod(period),
  };
};

export const backgroundColorForPeriod = (period: number) => {
  return {
    backgroundColor: colorForPeriod(period),
  };
};
