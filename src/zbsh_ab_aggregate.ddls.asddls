@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggregate data'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBSH_AB_AGGREGATE as select from ZBSH_AB_JOIN
{
    key CompanyName,
    key Country,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    sum(GrossAmount) as TotalSales,
    CurrencyCode
} group by CompanyName, Country, CurrencyCode
