@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic Interface, Sales, Fact data'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
@Analytics.dataCategory: #FACT
define view entity ZI_BSH_AB_SALES as select from zbsh_ab_so_hdr
association of one to many zbsh_ab_so_item as _Items on
$projection.OrderId = _Items.order_id
{
    key zbsh_ab_so_hdr.order_id as OrderId,
    zbsh_ab_so_hdr.order_no as OrderNo,
    zbsh_ab_so_hdr.buyer as Buyer,
    _Items.product as ProductId,
    @Semantics.amount.currencyCode: 'Currency'
    _Items.amount as Amount,
    _Items.currency as Currency,
    _Items.qty as Quantity,
    _Items.uom as Unit
}
