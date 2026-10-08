import {convertNumberToNegative} from "../../../shared/conversions/convertNumberToNegative";
import {CsvBankImportRow} from "../../../shared/interfaces/csvBankImport";
import {convertDateToUnifiedFormat} from "../../../shared/conversions/convertToValidDate";

enum transactionStatus {
    PENDING = "PENDING",
}

export const mapMainAccountJson = (items: any[]): CsvBankImportRow[] => {

    return items.filter(item => item.json['Status/Status'] !== transactionStatus.PENDING).map(item => {
        if(item.json['+/-'] == '-')
            item.json['Znesek/Amount'] = convertNumberToNegative(item.json['Znesek/Amount']);
        return {json: {
            account: 'main',
            amount: item.json['Znesek/Amount'] as string,
            category: '',
            counterPartyName: item.json['Naziv prejemnika/plačnika/Counter party name'] as string,
            transactionId: item.json['ID transakcije/Transaction ID'] as string,
            date: convertDateToUnifiedFormat(item.json['Datum plačila/Value date'] as string),
            description: item.json['Opis/Description'] as string,
            currency: item.json['Valuta/Currency'] as string,
            tags: '',
            purpose: item.json['Namen/Purpose'] as string,
            status: item.json['Status/Status'] as string,
        }};
    });
}