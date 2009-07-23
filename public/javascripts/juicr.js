(function () {

  if (!window.console) {
    window.console = {
      debug: function(_){}
    };
  }

  var SEARCH_ENGINE_OFFICIAL = 0;
  var SEARCH_ENGINE_YATS = 1;

  var Juicr = {
    Timeline: {},
    SearchEngine: {}
  }

////////////////////////////////////////////////////////////
// Timeline
////////////////////////////////////////////////////////////

  Juicr.Timeline = function() {
    this.maxId = 0;
    this.query = '';
    this.target = '#timeline';
    this.scale = 'mini';
    this.searchEngine = null;
    //this.searchEngine = SEARCH_ENGINE_OFFICIAL;
  }

  Juicr.Timeline.prototype = {

    reload: function() {
      context = this;
      $.ajax({
        dataType: 'jsonp',
        jsonp: context.searchEngine.getCallback(),
        error: function(response) { context.onReloadError(response, context) },
        //success: function(response) { context.searchEngine.onReloadSuccess(response, context) },
        success: function(response) { context.onReloadSuccess(response, context) },
        type: 'get',
        url: (function(){c=context.searchEngine.getUrl(); console.debug(c); return c})(),
        data: (function(){d=context.searchEngine.getData(context.query, context); console.debug(d); return d;})()
      });
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
      context.maxId = Math.max(status_obj.id, context.maxId);
      console.debug('status_obj.id='+status_obj.id+' context.maxId='+context.maxId);
    },

    onReloadSuccess: function(response, context) {
      context = context || this;
      results = context.searchEngine.convertResponse(response);
      console.debug(response);
//*
      context = context || this;
      for (var i=results.length-1; i>=0; i--) {
        var result = results[i];
        console.debug(result);
        if (result.id <= context.maxId) {
          continue;
        }
        context.insertStatus(result, context);
      }
      //context.maxId = response.max_id;
//*/
    },

    onReloadError: function(response) {
      context = context || this;
      alert(response);
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
    },

    setSearchEngine: function(searchEngineNum) {
      this.searchEngine = Juicr.SearchEngine.select(searchEngineNum);
    }
  }

////////////////////////////////////////////////////////////
// SearchEngine
////////////////////////////////////////////////////////////

  Juicr.SearchEngine = {
    select: function(engine) {
      switch (engine) {
      case SEARCH_ENGINE_OFFICIAL:
        return Juicr.SearchEngine.Official;
      case SEARCH_ENGINE_YATS:
        return Juicr.SearchEngine.Yats;
      }
      return null;
    }
  }

  Juicr.SearchEngine.Official = {
    getData: function(encodedQuery, timeline) {
      return {
        q:        encodedQuery,
        rpp:      timeline.rpp,
        page:     timeline.page,
        since_id: timeline.maxId
      }
    },

    getUrl: function() {
      return 'http://search.twitter.com/search.json'
    },

    getCallback: function() {
      return 'callback'
    },

    convertResponse: function(response) {
      return response.results;
    }
  }
  
  Juicr.SearchEngine.Yats = {
    getData: function(encodedQuery, timeline) {
      return {
        query: encodedQuery
      }
    },

    getUrl: function() {
      return 'http://pcod.no-ip.org/yats/search'
    },

    getCallback: function() {
      return 'json'
    },

    convertResponse: function(response) {
      obj = [];
      for (i=0; i<response.length; i++) {
        res = response[i];
        obj.push({
          id:                Number(res.id),
          text:              res.content,
          from_user:         res.user,
          created_at:        res.time2,
          profile_image_url: res.image
        })
      }
      return obj;
    }
  }
  

////////////////////////////////////////////////////////////
  window.Juicr = Juicr;
})();

