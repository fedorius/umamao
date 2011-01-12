$(document).ready(function() {

  // TODO: place this somewhere else
  if ($("#landing_signup").length > 0 ) {
	  Utils.clickObject("input#affiliation_submit", signUpAjaxRequest);
  }
	
  $("form.nestedAnswerForm").hide();
  $("#add_comment_form").hide();

  $("form").live('submit', function() {
    window.onbeforeunload = null;
  });

  $('.confirm-domain').submit(function(){
      var bool = confirm($(this).attr('data-confirm'));
      if(bool==false) return false;

  });
  $("#feedbackform").dialog({ title: "Feedback", autoOpen: false, modal: true, width:"420px" });
  $('#feedbackform .cancel-feedback').click(function(){
    $("#feedbackform").dialog('close');
    return false;
  });
  $('#feedback').click(function(){
    var isOpen = $("#feedbackform").dialog('isOpen');
    if (isOpen){
      $("#feedbackform").dialog('close');
    } else {
      $("#feedbackform").dialog('open');
    }
    return false;
  });

  initAutocomplete();

  $("a#hide_announcement").click(function() {
    $("#announcement").fadeOut();
    $.post($(this).attr("href"), "format=js");
    return false;
  });

  $(".highlight_for_user").effect("highlight", {}, 2000);
  sortValues('group_language', ':last');
  sortValues('language_filter', ':lt(2)');
  sortValues('user_language', false);

  $('.langbox.jshide').hide();
  $('.show-more-lang').click(function(){
      $('.langbox.jshide').toggle();
      return false;
  });

  if($('#new_user #user_email').val() == ""){
    $('#new_user #user_email').focus();
  } else {
    $('#new_user #user_password').focus();
  };

  $('#login_form > #email_field > input').focus();

  // TODO: internationalize.
  $('#news_items .answer').each(function(){
    if ($(this).height() > 85) {
      $(this).addClass('large');
    }
  }).filter('.large').append(
    '<div class="more"><span class="more-link">(mais)</span></div>'
  ).find('.more-link').click(function(){
    $(this).parents('.answer').addClass('expanded');
  });
});

// Init autocompletable boxes.
function initAutocomplete() {
  initSearchBox();

  // TODO: load for each right page with the HTML.
  if ($("#reclassify-autocomplete").length > 0) {
    initTopicAutocompleteForReclassifying();
  }

  if ($("#follow-topics-autocomplete").length > 0) {
    initTopicAutocompleteForFollowing();
  }

  if ($("#view_university").length > 0) {
    initUniversityAutocomplete();
  }

  var searchField = $("#search-field");

  // Keyboard shortcuts for search box
  $(document).bind("keypress", "/", function () { searchField.focus(); return false; });
  $(searchField).bind("keydown", "esc", function () { searchField.blur(); return false; });
}

// FIXME: remove this later
window.manageAjaxError = Utils.manageAjaxError;
window.showMessage = Utils.showMessage;

function sortValues(selectID, keepers){
  if(keepers){
    var any = $('#'+selectID+' option'+keepers);
    any.remove();
  }
  var sortedVals = $.makeArray($('#'+selectID+' option')).sort(function(a,b){
    return $(a).text() > $(b).text() ? 1: -1;
  });
  $('#'+selectID).empty().html(sortedVals);
  if(keepers)
    $('#'+selectID).prepend(any);
};

function highlightEffect(object) {
  if(typeof object != "undefined") {
    object.fadeOut(400, function() {
      object.fadeIn(400);
    });
  }
}
