// pages/introInput/introinput.js
const app = getApp()
Page({

    /**
     * 页面的初始数据
     */
    data: {

    },

    /**
     * 生命周期函数--监听页面加载
     */
    onLoad: function (options) {
        var windowWidth = wx.getSystemInfoSync().windowWidth;
        var windowHeight = wx.getSystemInfoSync().windowHeight;
        //rpx与px单位之间的换算 : 750/windowWidth = 屏幕的高度（rpx）/windowHeight
        var photo_height = (750 * windowHeight / windowWidth) / 4;
    
        var scroll_height = (750 * windowHeight / windowWidth) - photo_height;
        this.setData({
          scroll_height: scroll_height,
          photo_height: photo_height,
          windowHeight:windowHeight
        })
    
       
        var card_width = windowWidth / 4;
        var card_heigh = windowHeight / 4;
    
        this.setData({
          card_width: card_width,
          card_heigh: card_heigh
        })
        this.app = getApp()
    },

    //页面展示时，触发动画
    onShow: function () {
        app.slideupshow(this, 'slide_up1', -200, 1)

        setTimeout(function () {
        app.slideupshow(this, 'slide_up2', -200, 1)
        }.bind(this), 200);
    },
    //页面隐藏时，触发渐出动画
    onHide: function () {
        //你可以看到，动画参数的200,0与渐入时的-200,1刚好是相反的，其实也就做到了页面还原的作用，使页面重新打开时重新展示动画
        app.slideupshow(this, 'slide_up1', 200, 0)
        //延时展现容器2，做到瀑布流的效果，见上面预览图
        setTimeout(function () {
        app.slideupshow(this, 'slide_up2', 200, 0)
        }.bind(this), 200);
    },
    inputphoto: function () {
      wx.navigateTo({
        url: '/pages/photo/index',
      })
  
    },
    inputtext: function () {
      wx.navigateTo({
        url: '/pages/text/index',
      })
    },
    inputvoice: function () {
      wx.navigateTo({
        url: '/pages/voice/index',
      })
    },
})