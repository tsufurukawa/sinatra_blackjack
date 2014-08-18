$(document).ready(function() {
  playerHit('#hit-btn', '/game/player_hit');
  stayOrDealerTurn('#stay-btn', '/game/player_stay');
  stayOrDealerTurn('#dealer-turn-btn', '/game/player_stay');
  dealerNextCard('#dealer-next-card', '/game/dealer_hit');
});

function playerHit(btn, toUrl) {
  $(document).on('click', btn, function() {
    $.ajax({
      type: 'POST',
      url: toUrl
    }).done(function(msg) {
      $('#show-result').replaceWith($(msg).find('#show-result'));
      $('#play-again').replaceWith($(msg).find('#play-again'));
      $('#display-dealer-turn-btn').replaceWith($(msg).find('#display-dealer-turn-btn'));
      $('.hand').last().children('h3').replaceWith($(msg).find('.hand').last().children('h3'));
      $('.card-container').last().append($(msg).find('.card-container').last().children('img').last());
      $('.btn-container').replaceWith($(msg).find('.btn-container'));
      $('.row-fluid').replaceWith($(msg).find('.row-fluid'));
    });
  return false;
  });  
}

// ajaxify 'stay' and 'dealer turn' buttons
function stayOrDealerTurn(btn, toUrl) {
  $(document).on('click', btn, function() {
    $.ajax({
      type: 'POST',
      url: toUrl,
    }).done(function(msg) {
      $('#show-result').replaceWith($(msg).find('#show-result'));
      $('#play-again').replaceWith($(msg).find('#play-again'));
      $('.hand').first().children('h3').replaceWith($(msg).find('.hand').first().children('h3'));
      $('.card-container').first().children('img').first().replaceWith($(msg).find('.card-container').first().children('img').first());
      $('#display-dealer-turn-btn').replaceWith($(msg).find('#display-dealer-turn-btn'));
      $('.btn-container').replaceWith($(msg).find('.btn-container'));
      $('.row-fluid').replaceWith($(msg).find('.row-fluid'));
    });
  return false;
  });  
}

// ajaxify 'click to reveal dealers card' button
function dealerNextCard(btn, toUrl) {
  $(document).on('click', btn, function() {
    $.ajax({
      type: 'POST',
      url: toUrl,
    }).done(function(msg) {
      $('#show-result').replaceWith($(msg).find('#show-result'));
      $('#play-again').replaceWith($(msg).find('#play-again'));
      $('.hand').first().children('h3').replaceWith($(msg).find('.hand').first().children('h3'));
      $('.card-container').first().append($(msg).find('.card-container').first().children('img').last());
      $('#display-dealer-turn-btn').replaceWith($(msg).find('#display-dealer-turn-btn'));
      $('.row-fluid').replaceWith($(msg).find('.row-fluid'));
    });
  return false;
  });  
}