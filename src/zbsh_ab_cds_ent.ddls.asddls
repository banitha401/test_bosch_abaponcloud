@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS entity for bpa'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZBSH_AB_CDS_ENT
 with parameters 
    p_ctry : abap.char(4) 
  as select from zbsh_ab_bpa
{
    key bp_id as BpId,
    --Data Expression Language
    case bp_role 
        when '01' then 'Customer'
        when '02' then 'Supplier'
        end as BpRole,
    company_name as CompanyName,
    street as Street,
    country as Country,
    region as Region,
    city as City
} where country = $parameters.p_ctry
