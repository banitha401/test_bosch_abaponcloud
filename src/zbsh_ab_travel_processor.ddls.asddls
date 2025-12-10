@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Travel'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define  root view entity ZBSH_AB_TRAVEL_PROCESSOR as projection on ZBSH_AB_TRAVEL
{
    key TravelId,
    AgencyId,
    CustomerId,
    BeginDate,
    EndDate,
    BookingFee,
    TotalPrice,
    CurrencyCode,
    Description,
    OverallStatus,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
       AgencyName,
   CustomerName,  StatusDescription,
  IconColor,
   
    /* Associations */
    _Agency,
    _Booking : redirected to composition child ZBSH_AB_BOOKING_PROCESSOR,
    _Currency,
    _Customer,
    _Status,
    
   @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BSH_AB_VE_CALC'
   @EndUserText.label: 'CO2 Tax'
   virtual CO2Tax : abap.int4,
   @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BSH_AB_VE_CALC'
   @EndUserText.label: 'Week Day'
   virtual dayOfTheFlight : abap.char( 9 )
    
}
