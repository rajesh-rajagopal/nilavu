export default Ember.Component.extend({

    resourceChanged: function() {
        this.set('flavorcost', this.get('model.flavorcost'));
    }.observes('model.flavorcost'),

    currency: function() {
        const regionCurrency = this.get('flavorcost.currency');
        if (regionCurrency) {
            return new Handlebars.SafeString(regionCurrency);
        }
    }.property('flavorcost'),


    totalHourlyCost: function() {
        return this.get('flavorcost').unitCostPerHour();
    }.property('flavorcost'),

    monthlyCost: function() {
        return this.get('flavorcost').unitCostPerMonth();
    }.property('flavorcost'),

    _rerenderOnChange: function() {
        this.rerender();
    }.observes('flavorcost')

})
