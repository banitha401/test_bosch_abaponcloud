@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Understanding joins'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBSH_AB_ASSOCIATION as select from ZBSH_AB_VOV as bpa
association of one to many zbsh_ab_so_hdr as _Sales
on $projection.BpKey = _Sales.buyer
{
    key bpa.BpId as BpKey,
    bpa.BpRole,
    bpa.CompanyName,
    bpa.Country,
    bpa.City,    
    --exposed association - join will be applied @ runtime
    _Sales
    --adhoc association
    --_Sales.order_no
    
}
