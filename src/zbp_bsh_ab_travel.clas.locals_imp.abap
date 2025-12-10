CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Travel.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
      IMPORTING entities FOR CREATE Travel\_Booking.

    METHODS copyTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~copyTravel.

    METHODS reCalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalcTotalPrice.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS validateHeaderData FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateHeaderData.


        types:  t_entity_create type table for create zBSH_AB_travel,
             t_entity_update TYPE table for update zBSH_AB_travel,
             t_entity_rep type table for REPORTED zBSH_AB_travel,
             t_entity_err type table for FAILED zBSH_AB_travel.
   methods precheck_anubhav_reuse
       importing
           entities_u type t_entity_update optional
           entities_c type t_entity_create optional
        exporting
           reported type t_entity_rep
           failed type t_entity_err.



ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    data: entity type STRUCTURE FOR CREATE zbsh_ab_travel,
         travel_id_max type /dmo/travel_id.
   ""Step 1: Ensure that Travel id is not set for the record which is coming
   loop at entities into entity where TravelId is not initial.
       APPEND CORRESPONDING #( entity ) to mapped-travel.
   ENDLOOP.
   data(entities_wo_travelid) = entities.
   delete entities_wo_travelid where TravelId is not INITIAL.
   ""Step 2: Get the seuquence numbers from the SNRO
   try.
       cl_numberrange_runtime=>number_get(
         EXPORTING
           nr_range_nr       = '01'
           object            = CONV #( '/DMO/TRAVL' )
           quantity          =  conv #( lines( entities_wo_travelid ) )
         IMPORTING
           number            = data(number_range_key)
           returncode        = data(number_range_return_code)
           returned_quantity = data(number_range_returned_quantity)
       ).
*        CATCH cx_nr_object_not_found.
*        CATCH cx_number_ranges.
     catch cx_number_ranges into data(lx_number_ranges).
       ""Step 3: If there is an exception, we will throw the error
       loop at entities_wo_travelid into entity.
           append value #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges )
               to reported-travel.
           append value #( %cid = entity-%cid %key = entity-%key ) to failed-travel.
       ENDLOOP.
       exit.
   endtry.
   case number_range_return_code.
       when '1'.
           ""Step 4: Handle especial cases where the number range exceed critical %
           loop at entities_wo_travelid into entity.
               append value #( %cid = entity-%cid %key = entity-%key
                               %msg = new /dmo/cm_flight_messages(
                                           textid = /dmo/cm_flight_messages=>number_range_depleted
                                           severity = if_abap_behv_message=>severity-warning
                               ) )
                   to reported-travel.
           ENDLOOP.
       when '2' OR '3'.
           ""Step 5: The number range return last number, or number exhaused
           append value #( %cid = entity-%cid %key = entity-%key
                               %msg = new /dmo/cm_flight_messages(
                                           textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                           severity = if_abap_behv_message=>severity-warning
                               ) )
                   to reported-travel.
           append value #( %cid = entity-%cid
                           %key = entity-%key
                           %fail-cause = if_abap_behv=>cause-conflict
                            ) to failed-travel.
   ENDCASE.
   ""Step 6: Final check for all numbers
   ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).
   ""Step 7: Loop over the incoming travel data and asign the numbers from number range and
   ""        return MAPPED data which will then go to RAP framework
   travel_id_max = number_range_key - number_range_returned_quantity.
   loop at entities_wo_travelid into entity.
       travel_id_max += 1.
       entity-TravelId = travel_id_max.
       reported-%other = VALUE #( ( new_message_with_text(
                                severity = if_abap_behv_message=>severity-success
                                text     = 'Travel id has been created now!' ) ) ).
       append value #( %cid = entity-%cid
                       %is_draft = entity-%is_draft
                       %key = entity-%key ) to mapped-travel.
   ENDLOOP.

  ENDMETHOD.

  METHOD precheck_create.
     precheck_anubhav_reuse(
     EXPORTING
*        entities_u =
        entities_c = entities
     IMPORTING
       reported   = reported-travel
       failed     = failed-travel
   ).
 ENDMETHOD.
 METHOD precheck_update.
   precheck_anubhav_reuse(
     EXPORTING
       entities_u = entities
*         entities_c =
     IMPORTING
       reported   = reported-travel
       failed     = failed-travel
   ).
 ENDMETHOD.
 METHOD precheck_anubhav_reuse.
   ""Step 1: Data declaration
   data: entities type t_entity_update,
          operation type if_abap_behv=>t_char01,
          agencies type sorted table of /dmo/agency WITH UNIQUE KEY agency_id,
          customers type sorted table of /dmo/customer WITH UNIQUE key customer_id.
   ""Step 2: Check either entity_c was passed or entity_u was passed
   ASSERT not ( entities_c is initial equiv entities_u is initial ).
   ""Step 3: Perform validation only if agency OR customer was changed
   if entities_c is not initial.
       entities = CORRESPONDING #( entities_c ).
       operation = if_abap_behv=>op-m-create.
   else.
       entities = CORRESPONDING #( entities_u ).
       operation = if_abap_behv=>op-m-update.
   ENDIF.
   delete entities where %control-AgencyId = if_abap_behv=>mk-off and %control-CustomerId = if_abap_behv=>mk-off.
   ""Step 4: get all the unique agencies and customers in a table
   agencies = CORRESPONDING #( entities discarding DUPLICATES MAPPING agency_id = AgencyId EXCEPT * ).
   customers = CORRESPONDING #( entities discarding DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
   ""Step 5: Select the agency and customer data from DB tables
   select from /dmo/agency fields agency_id, country_code
   for all ENTRIES IN @agencies where agency_id = @agencies-agency_id
   into table @data(agency_country_codes).
   select from /dmo/customer fields customer_id, country_code
   for all ENTRIES IN @customers where customer_id = @customers-customer_id
   into table @data(customer_country_codes).
   ""Step 6: Loop at incoming entities and compare each agency and customer country
   loop at entities into data(entity).
       read table agency_country_codes with key agency_id = entity-AgencyId into data(ls_agency).
       CHECK sy-subrc = 0.
       read table customer_country_codes with key customer_id = entity-CustomerId into data(ls_customer).
       CHECK sy-subrc = 0.
       if ls_agency-country_code <> ls_customer-country_code.
           ""Step 7: if country doesnt match, throw the error
           append value #(    %cid = cond #( when operation = if_abap_behv=>op-m-create then entity-%cid_ref )
                                     %is_draft = entity-%is_draft
                                     %fail-cause = if_abap_behv=>cause-conflict
             ) to failed.
           append value #(    %cid = cond #( when operation = if_abap_behv=>op-m-create then entity-%cid_ref )
                                     %is_draft = entity-%is_draft
                                     %msg = new /dmo/cm_flight_messages(
                                                                                             textid                = value #(
                                                                                                                                    msgid = 'SY'
                                                                                                                                    msgno = 499
                                                                                                                                    attr1 = 'The country codes for agency and customer not matching'
                                                                                                                                 )
                                                                                             agency_id             = entity-AgencyId
                                                                                             customer_id           = entity-CustomerId
                                                                                             severity  = if_abap_behv_message=>severity-error
                                                                                           )
                                     %element-agencyid = if_abap_behv=>mk-on
             ) to reported.
       ENDIF.
   ENDLOOP.

 ENDMETHOD.



  METHOD earlynumbering_cba_Booking.
  ENDMETHOD.

  METHOD copyTravel.
  ENDMETHOD.

  METHOD reCalcTotalPrice.

     "Call the internal action which you created as reusable action
     MODIFY ENTITIES OF ZBSH_AB_travel IN LOCAL MODE
       ENTITY travel
           EXECUTE reCalcTotalPrice
           FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD calculateTotalPrice.
  ENDMETHOD.

  METHOD validateHeaderData.
   "Step 1: Read the travel data
   READ ENTITIES OF ZBSH_AB_travel IN LOCAL MODE
       ENTITY travel
       FIELDS ( CustomerId BeginDate EndDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_travel).
   "Step 2: Declare a sorted table for holding customer ids
   DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
   "Step 3: Extract the unique customer IDs in our table
   customers = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING
                                      customer_id = CustomerId EXCEPT *
    ).
   DELETE customers WHERE customer_id IS INITIAL.
   ""Get the validation done to get all customer ids from db
   ""these are the IDs which are present
   IF customers IS NOT INITIAL.
     SELECT FROM /dmo/customer FIELDS customer_id
     FOR ALL ENTRIES IN @customers
     WHERE customer_id = @customers-customer_id
     INTO TABLE @DATA(lt_cust_db).
   ENDIF.
   ""loop at travel data
   LOOP AT lt_travel INTO DATA(ls_travel).
     IF ( ls_travel-CustomerId IS INITIAL OR
          NOT  line_exists(  lt_cust_db[ customer_id = ls_travel-CustomerId ] ) ).
       ""Inform the RAP framework to terminate the create
       APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
       APPEND VALUE #( %tky = ls_travel-%tky
                       %element-customerid = if_abap_behv=>mk-on
                       %msg = NEW /dmo/cm_flight_messages(
                                     textid                = /dmo/cm_flight_messages=>customer_unkown
                                     customer_id           = ls_travel-CustomerId
                                     severity              = if_abap_behv_message=>severity-error
       )
       ) TO reported-travel.
     ENDIF.
     IF ls_travel-enddate < ls_travel-begindate.  "end_date before begin_date
       APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel.
       APPEND VALUE #( %tky = ls_travel-%tky
                       %msg = NEW /dmo/cm_flight_messages(
                                  textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                  severity   = if_abap_behv_message=>severity-error
                                  begin_date = ls_travel-begindate
                                  end_date   = ls_travel-enddate
                                  travel_id  = ls_travel-travelid )
                       %element-begindate   = if_abap_behv=>mk-on
                       %element-enddate     = if_abap_behv=>mk-on
                    ) TO reported-travel.
     ELSEIF ls_travel-begindate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future
       APPEND VALUE #( %tky        = ls_travel-%tky ) TO failed-travel.
       APPEND VALUE #( %tky = ls_travel-%tky
                       %msg = NEW /dmo/cm_flight_messages(
                                   textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                   severity = if_abap_behv_message=>severity-error )
                       %element-begindate  = if_abap_behv=>mk-on
                       %element-enddate    = if_abap_behv=>mk-on
                     ) TO reported-travel.
     ENDIF.
   ENDLOOP.
   ""Exercise: Validations
   "check if begin and end date is empty
  ENDMETHOD.

ENDCLASS.
