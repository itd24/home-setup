import {CsvBankImportRow} from "../../../shared/interfaces/csvBankImport";
import {convertDateToUnifiedFormat} from "../../../shared/conversions/convertToValidDate";
import {sanitizeString} from "../../../shared/conversions/sanitizeString";

export const mapCreditCardAccountJson = (items: any[]): CsvBankImportRow[] => {
    return items.map(item => {
        //datum, opis, value, valuta
        return {
            json: {
                account: 'creditCard',
                amount: item.json['value'] as string,
                category: '',
                counterPartyName: '',
                transactionId: sanitizeString(`${item.json['datum']}-${item.json['opis']}-${item.json['value']}`),
                date: convertDateToUnifiedFormat(item.json['datum'] as string),
                description: item.json['opis'] as string,
                currency: item.json['valuta'] as string,
                tags: 'visa',
                purpose: item.json['opis'] as string,
                status: '',
            }
        };
    });
}