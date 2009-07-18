(function () {

  if (!window.console) {
    window.console = {
      debug: function(_){}
    };
  }

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
      $.ajax({
        dataType:'jsonp',
        error: function(request) { context.onReloadError(request, context) },
        success: function(request) { context.onReloadSuccess(request, context) },
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

    insertStatus: function(status_obj, context) {
      context = context || this;
      user = status_obj.user || status_obj
      icon = context.resizeProfileImage(user.profile_image_url, context.scale);
      screen_name = user.screen_name || user.from_user;
      $(
        '<li class="cell hentry '+context.scale+'">'
          +'<div class="icon">'
            +'<img src="'+icon+'" />'
          +'</div>'
          +'<div class="status-body">'
            +'<span class="screen-name">'+screen_name+'</span>'
            +'<span class="status">'+status_obj.text+'</span>'
            +'<div class="info">'
              +'<p class="created-at">'+context.convertDateFormat(status_obj.created_at)+'</p>'
            +'</div>'
          +'</div>'
        +'</li>'
      )
      .prependTo(context.target);
    },

    onReloadSuccess: function(request, context) {
      context = context || this;
      for (var i=request.results.length-1; i>=0; i--) {
        var result = request.results[i];
        if (result.id <= context.maxId) {
          continue;
        }
        context.insertStatus(result, context);
      }
      context.maxId = request.max_id;
    },

    onReloadError: function(request) {
      context = context || this;
      alert(request);
    },

    resizeProfileImage: function(profile_image_url, size_str) {
      return profile_image_url.replace(
        /^(.*)(_normal).([a-z]+)$/i,
        function(m0, pre, src_size_str, exp) {
          return pre+'_'+size_str+'.'+exp;
        });
    },

    convertDateFormat: function(src_date_str) {
      d = new Date(src_date_str);
      return d;
    }
  }

  window.Juicr = Juicr;
})();

