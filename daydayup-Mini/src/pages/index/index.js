var App = getApp();
Page({
  data: {
    imgUrls: [
      'http://101.33.248.42:8051/group1/M00/00/00/rBEACmMvx7uARQBaAAPMwKn59Rc978.jpg',
      'http://101.33.248.42:8051/group1/M00/00/00/rBEACmMvx5CAYVPOABuYFOU9SLA089.jpg',
      'http://101.33.248.42:8051/group1/M00/00/00/rBEACmMvx1yARokuABl0pXz4DwI462.jpg'
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

    /*wx.getUserProfile({
          desc:"用于完善用户资料",
          //成功后会返回
          success:(res)=>{
            console.log(res);
            // 把你的用户信息存到一个变量中方便下面使用
            let userInfo= res.userInfo
            //获取openId（需要code来换取）这是用户的唯一标识符
            // 获取code值
            wx.login({
              //成功放回
              success:(res)=>{
                console.log(res);
                let code=res.code
                // 通过code换取openId
                wx.request({
                  url: 'https://api.weixin.qq.com/sns/jscode2session?appid=wxc9c73915eeb63d6c&secret=83ac589ce417001b23c7191d3cb2fc4e&js_code=' + res.code + '&grant_type=authorization_code',
                  method:'POST',
                  success:(res)=>{
                    console.log(res);
                    userInfo.openid=res.data.openid;
                    
                    //请求成功之后，把openid放到储存里面
                      wx.setStorage({
                        key: 'openid',
                        data: userInfo.openid
                      })
                }
              })
             
    
          }
        })
      },
        })*/
  },
  onLoad: function () {
    this.setData({
      'openid': App.globalData.openid
    })
    var self = this
  /////////////////////////////////////////////
    
  },
  delete(){
    wx.showModal({
      title: '提示',
      content: '需要用户授予昵称',
      success (res) {
        if (res.confirm) {
          wx.getUserProfile({
            desc: '用于完善用户资料',
            //成功后会返回
            success: (resdata) => {
              console.log("======", resdata);
              wx.setStorage({
                data: authUser,
                key: true,
              })
            }
          })
        } else if (res.cancel) {
          console.log('用户点击拒绝')
        }
      }
    })
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


});