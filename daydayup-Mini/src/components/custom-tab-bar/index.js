// custom-tab-bar/index.js
const App = getApp();
Component({
  /**
   * 组件的属性列表
   */
  properties: {

  },

  /**
   * 组件的初始数据
   */

  data: {

    half_show: false,
    isPopping: false, //是否已经弹出
    animPlus: {}, //旋转动画
    animCollect: {}, //item位移,透明度
    animTranspond: {}, //item位移,透明度
    animInput: {}, //item位移,透明度


    selected: 0,
    color: "#ffffffff",
    selectedColor: "#000000",
    listTab: [

      {
        pagePath: "/pages/index/index",
        text: "首页",
        iconPath: "http://8.130.89.28:8051/group1/M00/00/00/rBEACmQ2TjaAJ96TAAAR9jceINg878.png",
        selectedIconPath: "http://8.130.89.28:8051/group1/M00/00/00/rBEACmQ2TiSANqUSAAAR9PPjtGw188.png"
      },
      {
        pagePath: "/pages/mycalen/index",
        text: "日历",
        iconPath: "http://8.130.89.28:8051/group1/M00/00/00/rBEACmQ2TtGAGDn-AAAq2IHmUy8116.png",
        selectedIconPath: "http://8.130.89.28:8051/group1/M00/00/00/rBEACmQ2Tt-Aa0qZAAAqbKZ9SxA189.png"
      }
    ]
  },

  /**
   * 组件的方法列表
   */
  methods: {
    redirectAuth: function () {
      console.log(App.globalData.authUser)
      if (!App.globalData.authUser) {
        wx.navigateTo({
          url: '/pages/grantAuth/index',
        })
      }
    },
    grantAuth: function () {
      if (!App.globalData.authUser) {
        wx.showModal({
          title: '提示',
          content: '需要用户授予昵称',
          success(res) {
            if (res.confirm) {
              wx.getUserProfile({
                desc: '获取你的昵称、头像、地区及性别',
                //成功后会返回
                success: (resdata) => {
                  console.log("======", resdata);
                  App.globalData.authUser = true;
                  App.globalData.nickName = resdata.userInfo.nickName;
                  App.globalData.avatarUrl = resdata.userInfo.avatarUrl
                  console.log("======", App.globalData.nickName);
                  App.openSocket();
                }
              })
            } else if (res.cancel) {
              console.log('用户点击拒绝')
              wx.showToast({
                title: '拒绝',
                icon: 'error',
                duration: 2000
              })
            }
          }
        })
      }
    },
    plus: function () {
      if (this.data.isPopping) {
        //缩回动画
        this.popp();
        this.setData({
          isPopping: false,
          half_show: true
        })
      } else if (!this.data.isPopping) {
        //弹出动画
        if (!App.globalData.authUser)
          this.redirectAuth();
        this.takeback();
        this.setData({
          isPopping: true,
          half_show: false
        })
      }
    },
    input: function () {
      wx.navigateTo({
        url: '../../pages/text/index',
        title: "文本添加"
      })
      console.log("input")
    },
    transpond: function () {
      wx.navigateTo({
        url: '../../pages/photo/index',
        title: "图片添加"
      })
      console.log("transpond")
    },
    collect: function () {
      wx.navigateTo({
        url: '../../pages/voice/index',
        title: "语音添加"
      })
      console.log("collect")
    },

    //弹出动画
    popp: function () {
      //plus顺时针旋转
      var animationPlus = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      var animationcollect = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      var animationTranspond = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      var animationInput = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      animationPlus.rotateZ(180).step();
      animationcollect.translate(69, -8).opacity(1).step();
      animationTranspond.translate(0, -55).opacity(1).step();
      animationInput.translate(-70, -8).opacity(1).step();
      this.setData({
        animPlus: animationPlus.export(),
        animCollect: animationcollect.export(),
        animTranspond: animationTranspond.export(),
        animInput: animationInput.export(),
      })
    },
    //收回动画
    takeback: function () {
      //plus逆时针旋转
      var animationPlus = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      var animationcollect = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      var animationTranspond = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      var animationInput = wx.createAnimation({
        duration: 500,
        timingFunction: 'ease-out'
      })
      animationPlus.rotateZ(0).step();
      animationcollect.translate(0, 0).rotateZ(0).opacity(0).step();
      animationTranspond.translate(0, 0).rotateZ(0).opacity(0).step();
      animationInput.translate(0, 0).rotateZ(0).opacity(0).step();
      this.setData({
        animPlus: animationPlus.export(),
        animCollect: animationcollect.export(),
        animTranspond: animationTranspond.export(),
        animInput: animationInput.export(),
      })
    },

    switchTab(e) {
      if (!App.globalData.authUser)
        this.redirectAuth()
      const data = e.currentTarget.dataset;
      console.log("=========================data========", data);
      const url = data.path;
      wx.switchTab({
        url
      });
      this.setData({
        selected: data.index
      })
    }
  }
})