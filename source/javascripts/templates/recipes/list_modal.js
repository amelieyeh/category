(function() {
  var template = Handlebars.template, templates = window.HandlebarsTempaltes = window.HandlebarsTempaltes || {};
templates['recipes/list_modal'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class=\"modal-header\">\n  <h3>�����嗉�</h3>\n</div>\n<div class=\"modal-body\">\n  <div style='height: 300px;'>\n    <div id=\"recipe-info\" align=\"center\">\n      <h4 class=\"modal-title\">";
  if (stack1 = helpers.name) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.name; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "</h4>\n      <img src=\"";
  if (stack1 = helpers.cover_picture) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = depth0.cover_picture; stack1 = typeof stack1 === functionType ? stack1.apply(depth0) : stack1; }
  buffer += escapeExpression(stack1)
    + "\">\n    </div>\n    <div id=\"list-info\">\n      <h5>�����嚗�</h5>\n      <div class='lists'>\n        <ul>\n        </ul>\n      </div>\n      <div id=\"add-list\">\n        <h5>�啣���嚗�</h5>\n        <input type=\"text\" placeholder=\"���迂\" />\n        <span class=\"btn add-btn\">\n          +��\n        </span>\n      </div>\n    </div>\n  </div>\n</div>\n<div style=\"clear: both;\"></div>\n<div class=\"modal-footer\">\n  <span class=\"list-recipe-now\">\n    <input type=\"checkbox\" checked>�嗉�敺��喲＊蝷箏�憿��\n  </span>\n  <span class=\"btn cancel-btn\">��</span>\n  <span class=\"btn btn-primary submit-btn\">蝣箏�</span>\n</div>";
  return buffer;
  });
console.log(typeof HandlebarsTempaltes["recipes/list_modal"]);
})();