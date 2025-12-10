@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Composite view'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #COMPOSITE
@Analytics.dataCategory: #FACT
define view entity ZI_BSH_AB_CO_S as select from ZI_BSH_AB_SALES
association of many to one ZI_BSH_AB_BPA as _BusinessPartner
on $projection.Buyer = _BusinessPartner.BpId
{
    key ZI_BSH_AB_SALES.OrderId,
    ZI_BSH_AB_SALES.OrderNo,
    ZI_BSH_AB_SALES.Buyer,
    ZI_BSH_AB_SALES.ProductId,
    ZI_BSH_AB_SALES.Amount,
    ZI_BSH_AB_SALES.Currency,
    ZI_BSH_AB_SALES.Quantity,
    ZI_BSH_AB_SALES.Unit,
    _BusinessPartner
}
