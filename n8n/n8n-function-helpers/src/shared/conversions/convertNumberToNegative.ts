export const convertNumberToNegative = (numberAsString: string
) => {
    return numberAsString.length > 0 && !numberAsString.includes('-')
        ? `-${numberAsString}`
        : numberAsString;
}