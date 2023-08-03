using './dcr_and_monitoring_metrics_publisher_template.bicep'

param tableName = 'Your Table Name' // Your custom table name before _CL. This is used to configure the stream name but this behavior can be changed in the bicep file.

// Your custom columns. Mine all have _s appended to the column name and are of type string.
param columns = [
  'YourColumnA_s'
  'YourColumnB_s'
  'YourColumnC_s'
  'YourColumnD_s'
  'YourColumnE_s'
  'YourColumnF_s'
]
