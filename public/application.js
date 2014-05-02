$(document).ready(function() {
  playerHit('#hit-btn', '/game/player_hit');
  stayOrDealerTurn('#stay-btn', '/game/player_stay');
  stayOrDealerTurn('#dealer-turn-btn', '/game/player_stay');
  dealerNextCard('#dealer-next-card', '/game/dealer_hit');

  // dealerCardAnimate('#inner-container');
  // playerCardAnimate('#inner-container')
});


function dealerCardAnimate() {
  var $dealerCards = $('.card-container').first().children('img');
  $.each($dealerCards, function(index, el) {
    var numDealerCards = $dealerCards.length
    
    $(el).css({'top': '-1000px'});
    setTimeout(function() {
      $(el).animate({
        'top': 0
      }, 450);
    }, 500 + (index * 500));    
  });
}

function playerCardAnimate(msg) {
  var $playerCards = $(msg).find('.card-container').last().children('img');
  $.each($playerCards, function(index, el) {
    var numPlayerCards = $playerCards.length

    $(el).css({'top': '-1000px'});
    setTimeout(function() {
      $(el).animate({
        'top': 0
      }, 450);
    }, 1500 + (index * 500));
  });
}

function flipCard() {
  // var dealerCards = $('.card-container').first().children('img').first();
  
  // var timeoutID = window.setTimeout(function() {
  //   $('img').css({
  //     '-webkit-perspective': 600,
  //     '-webkit-transform': 'rotateY(360deg)'
  //   });
  // }, 3000);

  // $('dealerCards').animate({
  //   border: '10px solid black'
  // });
}

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
      playerCardAnimate('#inner-container');
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
      flipCard();
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
      dealerCardAnimate('#inner-container')
    });
  return false;
  });  
}











