import { region, ContainerVolumeData, EnvironmentVariable, Resources } from 'shared.bicep'

param managedIdentityResourceId string

param containerResources Resources = { cpu: 1, memoryInGB: 2 }
param imageName string 
param environmentVariables EnvironmentVariable[]
param gameSlug string

param shouldUseVolume bool = false
param containerVolumeData ContainerVolumeData

resource GameServerContainer 'Microsoft.ContainerInstance/containerGroups@2023-05-01'= {
  name:  'ci-${gameSlug}-server'
  location: region
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  }
  properties: {
    containers: [
      {
        name: '${gameSlug}container'
        properties: {
          volumeMounts: [
            {
              name: containerVolumeData.name
              mountPath: '/data'
            }
          ]
          image: imageName
          ports: [
            {
              port: 25565
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: containerResources.cpu
              memoryInGB: containerResources.memoryInGB
            }
          }
          environmentVariables: environmentVariables
        }
      }
    ]
    volumes: (shouldUseVolume) ? [
      {
        name: containerVolumeData.name
        azureFile: {
          readOnly: containerVolumeData.azureFile.readOnly
          shareName: containerVolumeData.azureFile.shareName
          storageAccountName: containerVolumeData.azureFile.storageAccountName
          storageAccountKey: containerVolumeData.azureFile.storageAccountKey
        }
      }
    ] : []
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 25565
        }
      ]
    }
    restartPolicy: 'OnFailure'
  }
}
