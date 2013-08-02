(function($) {
var modal =
                '<div class="modal-header">\
                        <h3>分類我的收藏</h3>\
                    </div>\
                    <div class="modal-body">\
                        <div style="height: 300px; width: 100%">\
                            <div id="recipe-info" align="center" style="width: 57%; height: 100%; float: left;">\
                                <h4 class="modal-title">${name}</h4>\
                                <img src="${cover_picture}" style="height: 60%; padding: 10px; background-color: white;">\
                            </div>\
                            <div id="list-info" style="width: 40%; height: 100%; float: left; padding-left: 3%;">\
                                <h5>加入我的分類：</h5>\
                                <div style="height: 50%; overflow-y: scroll;">\
                                    <ul style="cursor: pointer; list-style-type: none;">\
                                    </ul>\
                                </div>\
                                <div id="add-list">\
                                    <h5>新增分類：</h5>\
                                    <input type="text" placeholder="分類名稱" style="width: 48%;">\
                                    <span class="btn add-btn" style="margin-bottom: 10px">\
                                        +分類\
                                    </span>\
                                </div>\
                            </div>\
                        </div>\
                    </div>\
                    <div style="clear: both;"></div>\
                    <div class="modal-footer">\
                        <span class="btn cancel-btn">取消</span>\
                        <span class="btn btn-primary submit-btn">確定</span>\
                    </div>';
            $.template("modalTemplate", modal);

            var listItem = '<input type="checkbox" ${checked}><span style="margin-left: 5px;">${name}</span>';
            $.template("listItemTemplate", listItem);    
})(window.jQuery);
