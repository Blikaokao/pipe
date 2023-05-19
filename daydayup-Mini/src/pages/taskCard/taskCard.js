// pages/index/index.js
Page({

    /**
     * 页面的初始数据
     */
    data: {
      shouye: ['首页', '日程', '闹钟', '课程', '娱乐'],
      page: 0
    },
    change: function (event) {
      var a = event.currentTarget.dataset.pageid
      this.setData({
        page: a
      })
    },
    changepage: function (event) {
      console.log(event)
      var a = event.detail.current
      this.setData({
        page: a
      })
    },
    onLoad: function (options) {
      var windowWidth = wx.getSystemInfoSync().windowWidth;
      var windowHeight = wx.getSystemInfoSync().windowHeight;
      //rpx与px单位之间的换算 : 750/windowWidth = 屏幕的高度（rpx）/windowHeight

      /*
        获取数组的大小  取得平均一个card的大小
      */
      var length = this.data.shouye.length;
      var card_width = windowWidth/length;
      var card_heigh = windowHeight/14;
      
       this.setData({
         card_width: card_width,
         card_heigh: card_heigh
      })    
    },
})