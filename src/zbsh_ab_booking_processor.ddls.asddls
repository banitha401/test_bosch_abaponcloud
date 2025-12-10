@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BProjection view for Booking'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZBSH_AB_BOOKING_PROCESSOR as projection on ZBSH_AB_BOOKING
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _BookingStatus,
    _BookingSupplement: redirected to composition child ZBSH_AB_BOOKSUPPL_PROCESSOR,
    _Carrier,
    _Connections,
    _Customer,
    _Travel : redirected to parent ZBSH_AB_TRAVEL_PROCESSOR
}
