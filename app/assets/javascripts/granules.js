/// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require jquery-1.7.2.min
//= require jquery-ui-1.8.20.custom.min
//= require jquery-ui-sliderAccess
//= require jquery-ui-timepicker-addon
//= require sweetalert.min
//= require results

$(function() {
    $('#granules-search-form').on("submit", function (e) {
        collectionConceptId = $('#parentIdentifier').val();
        shortName = $('#shortName').val();
        uniqueId = $('#uid').val();
        // search must have at least one of the collection concept id, collection short name of granule unique id
        if (collectionConceptId === '' && shortName === '' && uniqueId === '') {
            swal({
                title: "Granules search error!",
                text: "Granule searches require at least the Collection Concept ID or Short Name or Unique ID fields.",
                icon: "error"
            });
            // consume the submit
            return false;
        }
        else {
            return true;
        }

    });
});