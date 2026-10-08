export const multiplyPrice = ({
                                  numberAsString,
                                  decimalSeparator = ',',
                                  thousandsSeparator = '.',
                                  multiplier = -1
                              }: {
    numberAsString: string,
    decimalSeparator: string,
    thousandsSeparator: string
    multiplier: number
}) => {
    const preparedString = numberAsString.replace(thousandsSeparator, '').replace(decimalSeparator, '.');
    const negativeNum = parseFloat(preparedString) * multiplier;
    return negativeNum.toLocaleString('de-DE', {minimumFractionDigits: 2});
}