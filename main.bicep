import { region, ContainerVolumeData } from 'shared.bicep'

targetScope = 'resourceGroup'

resource ManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-game-server'
  location: region
}

module StorageAccount 'storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    managedIdentityPrincipalId: ManagedIdentity.properties.principalId
  }
}

module MinecraftFileShare 'gameFileShare.bicep' = {
  dependsOn: [
    StorageAccount
  ]
  name: 'minecraftFileShare'
  params: {
    storageAccountName: StorageAccount.outputs.storageAccountName
    fileShareName: 'minecraft-server'
  }
}

module MinecraftServer 'gameServerContainerInstance.bicep' = {
  name: 'minecraftServer'
  dependsOn: [
    MinecraftFileShare
  ]
  params: {
    managedIdentityResourceId: ManagedIdentity.id
    imageName: 'itzg/minecraft-server:latest'
    environmentVariables: [
      {
        name: 'EULA'
        value: 'TRUE'
      }
      {
        name: 'SERVER_NAME'
        value: 'MineCady'
      }
      {
        name: 'RCON_PASSWORD'
        value: 'password'
      }
    ]
    gameSlug: 'minecraft'

    shouldUseVolume: true
    containerVolumeData: {
      name: 'minecraft-server'
      azureFile: {
        readOnly: false
        shareName: MinecraftFileShare.outputs.fileShareName
        storageAccountName: StorageAccount.outputs.storageAccountName
        storageAccountKey: StorageAccount.outputs.storageAccountKey
      }
    }
  }
}
