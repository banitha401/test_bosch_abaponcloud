--this is the name of HANA view and DDIC view which will get created
@AbapCatalog.sqlViewName: 'ZBSHABCDSVIEW'
--tell hana engine to inject all where conditions in the database
@AbapCatalog.compiler.compareFilter: true
--if we do not mark key fields in view, it will consider table keys are key for view
@AbapCatalog.preserveKey: true
--Authorization - securing our data
@AccessControl.authorizationCheck: #NOT_REQUIRED
--Description of the view
@EndUserText.label: 'CDS view basics'
@Metadata.ignorePropagatedAnnotations: true
define view ZBSH_AB_CDS_VIEW as select from zbsh_ab_bpa
{
    --press Ctrl+space here to load all columns
    key bp_id as BpId,
    bp_role as BpRole,
    company_name as CompanyName,
    street as Street,
    country as Country,
    region as Region,
    city as City
}
