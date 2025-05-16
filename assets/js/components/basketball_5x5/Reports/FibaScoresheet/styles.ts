export const textPeriodColor = (period: number) => {
  return {
    color: period === 1 || period === 3 ? '#A4031F' : '#3185FC',
  };
};
