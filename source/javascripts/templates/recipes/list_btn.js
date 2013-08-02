(function() {
  var template = Handlebars.template, templates = window.HandlebarsTempaltes = window.HandlebarsTempaltes || {};
templates['recipes/list_btn'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<a href=\"#myModal\" class=\"list-btn btn-favorite\" style=\"margin-left: 5px;\">\n    <i class=\"icon-reorder\"></i>\n    <span>��</span>\n</a>";
  });
})();