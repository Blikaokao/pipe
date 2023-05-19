var app = getApp();
var index;
var nav_centent_list =['lina','sister','brother','mom'];
Page({
  data: {
    'showMenu': false,
    nav_centent: null
  },
  click_nav: function (e) {
    var that = this;
    if(!that.data.showMenu){
        that.setData({
            'nav_centent' : nav_centent_list,//每点击一次就取反
            'showMenu': true,
        });
    }else{
        that.setData({
            'nav_centent' : null,//每点击一次就取反
            'showMenu': false,
        });
    }
  },
  click_item: function(e){
    console.log("=====choseitem====",e.currentTarget.dataset.choseitem);
  }
})