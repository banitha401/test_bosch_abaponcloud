@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Consumption, For Analytic use case'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #CONSUMPTION
@Analytics.query: true
define view entity ZC_BSH_AB_ANA as select from ZI_BSH_AB_CUBE
{
    @AnalyticsDetails.query.axis: #ROWS
    key Customer,
    key Country,
    key Category,
    key Product,
    Amount,
    @AnalyticsDetails.query.axis: #COLUMNS
    @Consumption.filter.defaultValue: 'INR'
    @Consumption.filter.selectionType: #SINGLE
    Currency,
    Quantity,
    @AnalyticsDetails.query.axis: #COLUMNS
    @Consumption.filter.defaultValue: 'EA'
    @Consumption.filter.selectionType: #SINGLE
    Unit   
}
