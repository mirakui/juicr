var SEARCH_ENGINE_OFFICIAL = 0;
var SEARCH_ENGINE_YATS = 1;

var Juicr = {
  Timeline: {}
}

Juicr.Timeline = function() {
  this.maxId = 0;
  this.query = '';
  this.target = '#timeline';
  this.scale = 'mini';
  this.searchEngine = SEARCH_ENGINE_OFFICIAL;
}

Juicr.Timeline.prototype = {

  reload: function() {
    context = this;
    console.debug('hello');
    $.ajax({
      dataType:'jsonp',
      error: function(request) { context.onReloadError(context, request) },
      success: function(request) { context.onReloadSuccess(context, request) },
      type: 'get',
      url: this.searchEngineUri(this.searchEngine, this.query)
    });
  },

  searchEngineUri: function(searchEngine, encodedQuery) {
    if (searchEngine==SEARCH_ENGINE_OFFICIAL) {
      return 'http://search.twitter.com/search.json?rpp='+context.rpp+'&page='+context.page+'&q='+encodedQuery;
    }
    else if (searchEngine==SEARCH_ENGINE_YATS) {
      return 'http://pcod.no-ip.org/yats/search?query='+encodedQuery;
    }
    return null;
  },

  onReloadSuccess: function(context, request) {
    console.debug(request);
    for (var i=request.results.length-1; i>=0; i--) {
      var result = request.results[i];
      if (result.id <= context.maxId) {
        continue;
      }
      $(
        '<li class="cell hentry '+context.scale+'">'
          +'<div class="icon">'
            +'<img src="'+context.resizeProfileImage(result.profile_image_url, context.scale)+'" />'
          +'</div>'
          +'<div class="status-body">'
            +'<span class="screen-name">'+result.from_user+'</span>'
            +'<span class="status">'+result.text+'</span>'
            +'<div class="info">'
              +'<p class="created-at">'+result.created_at+'</p>'
            +'</div>'
          +'</div>'
        +'</li>'
      )
      .prependTo(context.target);
    //});
    }
    context.maxId = request.max_id;
  },

  onReloadError: function(context, request) {
    alert('error');
    console.debug(request);
  },

  resizeProfileImage: function(profile_image_url, size_str) {
    return profile_image_url.replace(
      /^(.*)(_normal).([a-z]+)$/i,
      function(m0, pre, src_size_str, exp) {
        return pre+'_'+size_str+'.'+exp;
      });
  }
}


