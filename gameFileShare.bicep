param storageAccountName string
param fileShareName string 

resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource Fileservices 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' existing = {
  parent: StorageAccount
  name: 'default'
}

resource FileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: Fileservices
  name: fileShareName
}

output fileShareName string = FileShare.name
