@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite, Cube for sales data'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #COMPOSITE
@Analytics.dataCategory: #CUBE
define view entity ZI_BSH_AB_CUBE as select from ZI_BSH_AB_CO_S
association of many to one ZI_BSH_AB_PROD as _Product
on $projection.ProductId = _Product.ProductId
{
  key ZI_BSH_AB_CO_S.OrderId,
  ZI_BSH_AB_CO_S.OrderNo,
  ZI_BSH_AB_CO_S.Buyer,
  ZI_BSH_AB_CO_S.ProductId,
  @DefaultAggregation: #SUM
  ZI_BSH_AB_CO_S.Amount,
  ZI_BSH_AB_CO_S.Currency,
  @DefaultAggregation: #SUM
  ZI_BSH_AB_CO_S.Quantity,
  ZI_BSH_AB_CO_S.Unit,
  /* Associations */
  ZI_BSH_AB_CO_S._BusinessPartner.CompanyName as Customer,
  ZI_BSH_AB_CO_S._BusinessPartner.Country as Country,
  _Product.Category as Category,
  _Product.Name as Product  
}
