@export()
var region = 'westeurope'

@export()
type ContainerVolumeData = {
  name: string
  azureFile: {
    readOnly: bool
    shareName: string
    storageAccountName: string
    storageAccountKey: string
  }
}

@export()
type EnvironmentVariable = {
  name: string
  value: string
}

@export()
type Resources = {
  cpu: int
  memoryInGB: int
}
