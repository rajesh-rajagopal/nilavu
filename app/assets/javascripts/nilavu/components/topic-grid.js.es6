
export default Ember.Component.extend({
  classNames: ['topic-grid'],
  showTopicPostBadges: true,

  _observeHideCategory: function(){
    this.addObserver('hideCategory', this.rerender);
    this.addObserver('order', this.rerender);
    this.addObserver('ascending', this.rerender);
  }.on('init'),

  toggleInTitle: function(){
    return !this.get('bulkSelectEnabled') && this.get('canBulkSelect');
  }.property('bulkSelectEnabled'),

  sortable: function(){
    return !!this.get('changeSort');
  }.property(),

  skipHeader: function() {
    return this.site.mobileView;
  }.property(),

  showLikes: function(){
    return this.get('order') === "likes";
  }.property('order'),

  showOpLikes: function(){
    return this.get('order') === "op_likes";
  }.property('order'),

  filteredTopics: function() {
    const cat = this.get('showCategory');
    return this.get('topics').filter(function(topic) {
      return topic.get('filteredCategory').match(cat);
    });
  }.property(),

  click(e) {
    var self = this;
    var on = function(sel, callback){
      var target = $(e.target).closest(sel);

      if(target.length === 1){
        callback.apply(self, [target]);
      }
    };

    on('button.bulk-select', function(){
      this.sendAction('toggleBulkSelect');
      this.rerender();
    });

    on('th.sortable', function(e2){
      this.sendAction('changeSort', e2.data('sort-order'));
      this.rerender();
    });
  },

  actions: {

  }
});
