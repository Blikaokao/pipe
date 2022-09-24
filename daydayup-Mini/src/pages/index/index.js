Page({
  onShow: function () {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({
        selected: 0 //0,1，2 0-导航一  1-导航二  2-个人中心
      })
    }
    this.info();
  },
  //点击我显示底部弹出框
  clickme: function () {
    this.showModal();
  },

  //显示对话框
  showModal: function () {
    // 显示遮罩层
    var animation = wx.createAnimation({
      duration: 200,
      timingFunction: "linear",
      delay: 0
    })
    this.animation = animation
    animation.translateY(300).step()
    this.setData({
      animationData: animation.export(),
      showModalStatus: true
    })
    setTimeout(function () {
      animation.translateY(0).step()
      this.setData({
        animationData: animation.export()
      })
    }.bind(this), 200)
  },
  //隐藏对话框
  hideModal: function () {
    // 隐藏遮罩层
    var animation = wx.createAnimation({
      duration: 200,
      timingFunction: "linear",
      delay: 0
    })
    this.animation = animation
    animation.translateY(300).step()
    this.setData({
      animationData: animation.export(),
    })
    setTimeout(function () {
      animation.translateY(0).step()
      this.setData({
        animationData: animation.export(),
        showModalStatus: false
      })
    }.bind(this), 200)
  },
  info(){
    var that = this;
    wx.getUserInfo({
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

  




    })
  },

  
});