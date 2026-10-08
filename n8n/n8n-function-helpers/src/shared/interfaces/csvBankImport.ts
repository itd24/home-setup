export interface CsvBankImportRow {
    json: {
        description: string,
        amount: string,
        currency: string,
        date: string,
        counterPartyName: string
        status: string
        transactionId: string
        purpose: string,
        account: string
        category: string
        tags: string
    }
}