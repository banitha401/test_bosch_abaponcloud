@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Understanding joins'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBSH_AB_JOIN as select from ZBSH_AB_VOV as bpa
inner join zbsh_ab_so_hdr as sales
on bpa.BpId = sales.buyer
{
    key bpa.BpId,
    key sales.order_id as OrderNo,
    bpa.BpRole,
    bpa.CompanyName,
    bpa.Country,
    bpa.City,    
    sales.gross_amount as GrossAmount,
    sales.currency_code as CurrencyCode
    
}
