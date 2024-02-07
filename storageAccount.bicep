import { region } from './shared.bicep'

param managedIdentityPrincipalId string

resource StorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'saarcadygameserver'
  location: region
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource Fileservices 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: StorageAccount
  name: 'default'
}

param RoleDefinitionId string = '/providers/Microsoft.Authorization/roleDefinitions/0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'

resource assignContainerPermissions 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('storage-acc-rbac', StorageAccount.id, resourceGroup().id, managedIdentityPrincipalId, RoleDefinitionId)
  scope: StorageAccount
  properties: {
    principalId: managedIdentityPrincipalId
    roleDefinitionId: RoleDefinitionId
  }
}

output storageAccountName string = StorageAccount.name
output storageAccountKey string = StorageAccount.listKeys().keys[0].value
