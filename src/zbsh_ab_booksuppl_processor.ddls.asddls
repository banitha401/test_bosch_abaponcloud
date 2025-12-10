@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Booking suppliment s'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZBSH_AB_BOOKSUPPL_PROCESSOR as projection on ZBSH_AB_BOOKSUPPL1
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking : redirected to parent ZBSH_AB_BOOKING_PROCESSOR,
    _Product,
    _SupplementText,
    _Travel: redirected to  ZBSH_AB_TRAVEL_PROCESSOR
}
