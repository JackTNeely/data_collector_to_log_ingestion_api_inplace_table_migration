param tableName string // Assigned in .bicepparam
param columns array // Assigned in .bicepparam

param dcrPrefix string // Your custom prefix for the DCR name.
param dcrName string = '${dcrPrefix}${tableName}'

param kqlTransformation string = 'source | extend TimeGenerated = now()' // Or your own ingestion transformation KQL query.
param defaultColumnType string = 'string' // Optional param for setting a default column type.

param workspaceName string = 'Your Workspace Name' // Your Log Analytics
param workspaceId string = 'Your Log Aanalytics Workspace ID' // Your Log Analytics Workspace ID.
param resourceGroupName string = 'Your Resource Group Name' // Your Resource Group name.
param subscriptionId string = 'Your Subscription ID' // Your Subscription ID.
param principalId string = 'Your Log Ingestion API Azure AD App Registration Object ID' // Your Log Ingestion API Azure AD App Registration Object ID. Not Application ID.
param dceName string = 'Your Data Collection Endpoint Name' // Your Data Collection Endpoint name for the Log Ingestion API.

param principalType string = 'ServicePrincipal' // Leave set to ServicePrincipal.
param RoleDefinitionId string = '3913510d-42f4-4e42-8a64-420c390055eb' // Role definition ID for Monitoring Metrics Publisher to assign to the Log Ingestion API.

param location string = resourceGroup().location
param stream string = 'Custom-${tableName}_CL'

param dataCollectionEndpointId string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Insights/dataCollectionEndpoints/${dceName}'
param resourceId string = '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/microsoft.operationalinsights/workspaces/${workspaceName}'

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: dcrName
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      '${stream}': {
        columns: [for column in columns: {
          name: column
          type: defaultColumnType
        }]
      }
    }
    dataSources: {}
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: resourceId
          name: workspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          stream
        ]
        destinations: [
          workspaceId
        ]
        transformKql: kqlTransformation
        outputStream: stream
      }
    ]
  }
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: dataCollectionRule
  name: RoleDefinitionId
}

resource RoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(dataCollectionRule.id, RoleDefinitionId, principalId)
  scope: dataCollectionRule
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: principalId
    principalType: principalType
  }
}
