export const BLUE = '#3185FC';
export const RED = '#A4031F';

export const textColorForPeriod = (period: number) => {
  return {
    color: period === 1 || period === 3 ? RED : BLUE,
  };
};

export const backgroundColorForPeriod = (period: number) => {
  return {
    backgroundColor: period === 1 || period === 3 ? RED : BLUE,
  };
};
