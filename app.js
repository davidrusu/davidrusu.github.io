var Header = {
  ACTIONS: {
    SELECT: 'SELECT'
  },
  
  initModel: {
    items: ['a', 'b', 'c'],
    selected: 0
  },

  update: function (model, action) {
    var m = Object.assign({}, model);
    switch (action.type) {
    case Header.ACTIONS.SELECT:
      m.selected = action.selected;
      break;
    default:
      console.log('INVALID HEADER ACTION TYPE', action);
    }
    return m;
  },
  
  actions: {
    select: function (index) {
      return {
	type: Header.ACTIONS.SELECT,
	selected: index
      };
    }
  },

  headerItem: function (model, item, index, dispatch) {
    var isSelected = model.selected === index;
    var style = {
      'display': 'inline-block',
      'padding': '5px',
      'margin': '2px',
      'background': isSelected ? '#333' : '#aaa',
      'color': isSelected ? '#fff' : '#000'
    };
    
    return $('<div>')
      .text(item)
      .css(style)
      .click(function() {dispatch(Header.actions.select(index));});
  },

  render: function (model, dispatch) {
    var style = {
      width: '100%',
      height: '50px'
    };
    return $('<div class="header">').css(style).append(
      $('<div class="header-home">').text('David Rusu').css({display: 'inline-block'}),
      model.items.map(
	function (item, index) {
	  return Header.headerItem(model, item, index, dispatch);
	}
      )
    );
  }
};

var App = {
  ACTIONS: {
    HEADER: 'HEADER'
  },
  
  initModel: {
    header: Header.initModel
  },

  update: function(model, action) {
    var m = Object.assign({}, model);
    switch (action.type) {
    case App.ACTIONS.HEADER:
      m.header = Header.update(m.header, action.action);
      break;
    default:
      console.log('INVALID ACTION TYPE', action);
    }
    return m;
  },
  
  actions: {
    header: function (action) {
      return {
	type: App.ACTIONS.HEADER,
	action: action
      };
    }
  },

  render: function (model, dispatch) {
    var headerDispatch = function (action) {dispatch(App.actions.header(action));};
    
    return $('<div id="app">').append(
      Header.render(model.header,headerDispatch)
    );
  }
};

function init(root, app) {
  var dispatcher = $(document);
  var dispatch = function (action) {dispatcher.trigger('flux:action', action);};
  var model = app.initModel;
  
  dispatcher.on('flux:action', function (_, action) {
    model = app.update(model, action);
    dispatcher.trigger('flux:render', model);
  });

  dispatcher.on('flux:render',
		function (_, model) {
		  return $(root)
		    .empty()
		    .append(app.render(model, dispatch));
		});
  
  dispatcher.trigger('flux:render', model);
}

init('#root', App);
