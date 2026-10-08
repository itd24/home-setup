import moment from 'moment';

export const convertDateToUnifiedFormat = (dateStr: string): string => {
    // Define the possible formats
    const formats = [
        'DD-MM-YYYY',
        'DD.MM.YYYY',
        'DD.MM.YYYY HH:mm:ss'
    ];

    // Try to parse the date string using the defined formats
    const momentDate = moment(dateStr, formats, true); // `true` for strict parsing

    // Check if the date is valid and format it
    if (momentDate.isValid()) {
        return momentDate.format('DD-MM-YYYY');
    } else {
        throw new Error(`Invalid date format: ${dateStr}`);
    }
}
