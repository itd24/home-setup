export const sanitizeString = (input: string): string => {
    return input
        .toLowerCase()                         // Convert text to lowercase
        .replace(/[^a-z0-9\s]/g, '-')          // Replace special characters and dots with "-"
        .replace(/\s+/g, '-');                 // Replace spaces with "-"
}