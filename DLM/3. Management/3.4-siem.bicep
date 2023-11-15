// General parameters
param custPrefix string
param location string
param Tags object

//Create Log Analytics Workspace
resource lawman 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${custPrefix}-law-pl-man-prd-001'
  location: location
  tags: Tags
}

// Create Solution Insight
resource SecurityInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: '${custPrefix}-si-pl-man-prd-001'
  location: location
  tags: Tags
  plan: {
    name: 'SecurityInsights'
    product: 'SecurityInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: lawman.id
  }
}
