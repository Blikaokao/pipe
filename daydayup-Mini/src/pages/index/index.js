var App = getApp();
Page({
  data: {
    imgUrls: [
      'http://8.130.89.28:8051/group1/M00/00/00/rBEACmQ2QnmATwVAABl0pXz4DwI063.jpg',
      'http://8.130.89.28:8051/group1/M00/00/00/rBEACmQ2Qs6AKbbjABuYFOU9SLA427.jpg',
      'http://8.130.89.28:8051/group1/M00/00/00/rBEACmQ2Qv6Ae_SYAAPMwKn59Rc664.jpg'
    ],
    indicatorDots: true, //是否显示面板指示点
    autoplay: true, //是否自动切换
    interval: 3000, //自动切换时间间隔
    duration: 1000, //滑动动画时长
    inputShowed: false,
    inputVal: "",
    index: 0,
  },
  onShow: function () {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({
        selected: 0 //0,1，2 0-导航一  1-导航二  2-个人中心
      })
    }
    
  },
  info() {
    var that = this;

  },
  onLoad: function () {
    
    this.setData({
      'openid': App.globalData.openid
    })
    var self = this
  /////////////////////////////////////////////
     this.showComponent();
  },
 
  redirectToPhoto: function () {
    wx.navigateTo({
      url: '/pages/photo/index',
    })

  },
  redirectToVoice: function () {
    wx.navigateTo({
      url: '/pages/voice/index',
    })
  },
  redirectToIndex: function () {
    wx.switchTab({
      url: '/pages/mycalen/index',
    })
  },

  introdata: function () {
    wx.navigateTo({
      url: '/pages/introData/introdata',
    })
  },
  intromulti: function () {
    wx.navigateTo({
      url: '/pages/introMulti/intromulti',
    })
  },
  introinput: function () {
    wx.navigateTo({
      url: '/pages/introInput/introinput',
    })
  },
  showComponent: function () {
    this.myComponent = this.selectComponent('#tabbar')
    console.log("111111111")
    let myComponent = this.myComponent
    
    myComponent.takeback()  // 调用自定义组件中的方法
 },

});