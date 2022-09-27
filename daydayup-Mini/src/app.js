//app.js
import touch from 'pages/utils/touch.js' //新加
App({
  globalData: {
    userInfo: null,
    socketStatus: 'closed',
    openid: null,
    unReadLetter: 0
  },
  touch: new touch(), //实例化这个touch对象
  //渐入，渐出实现 
  show: function (that, param, opacity) {
    var animation = wx.createAnimation({
      //持续时间800ms
      duration: 800,
      timingFunction: 'ease',
    });
    //var animation = this.animation
    animation.opacity(opacity).step()
    //将param转换为key
    var json = '{"' + param + '":""}'
    json = JSON.parse(json);
    json[param] = animation.export()
    //设置动画
    that.setData(json)
  },

  //滑动渐入渐出
  slideupshow: function (that, param, px, opacity) {
    var animation = wx.createAnimation({
      duration: 800,
      timingFunction: 'ease',
    });
    animation.translateY(px).opacity(opacity).step()
    //将param转换为key
    var json = '{"' + param + '":""}'
    json = JSON.parse(json);
    json[param] = animation.export()
    //设置动画
    that.setData(json)
  },

  //向右滑动渐入渐出
  sliderightshow: function (that, param, px, opacity) {
    var animation = wx.createAnimation({
      duration: 800,
      timingFunction: 'ease',
    });
    animation.translateX(px).opacity(opacity).step()
    //将param转换为key
    var json = '{"' + param + '":""}'
    json = JSON.parse(json);
    json[param] = animation.export()
    //设置动画
    that.setData(json)
  },
  onLaunch: function () {
    var that = this;
    if (that.globalData.socketStatus === 'closed') {
      that.openSocket();
    }
  },

  //////websocket内容//////
  openSocket() {
    //打开时的动作
    wx.onSocketOpen(() => {
      console.log('WebSocket 已连接')
      this.globalData.socketStatus = 'connected';
      
      this.login();

    })
    //断开时的动作
    wx.onSocketClose(() => {
      console.log('WebSocket 已断开')
      this.globalData.socketStatus = 'closed'
    })
    //报错时的动作
    wx.onSocketError(error => {
      console.error('socket error:', error)
    })
    // 监听服务器推送的消息
    wx.onSocketMessage(message => {
      //把JSONStr转为JSON
      message = message.data.replace(" ", "");
      if (typeof message != 'object') {
        message = message.replace(/\ufeff/g, ""); //重点
        var jj = JSON.parse(message);
        message = jj;
      }
      console.log("【websocket监听到消息】内容如下：");
      console.log(message);
      //未读消息加一
      if(message.type == 3)
        this.globalData.unReadLetter = this.globalData.unReadLetter + 1;
    })
    // 打开信道
    wx.connectSocket({
      url: "ws://" + "localhost" + ":8084",
    })
  },

  //关闭信道
  closeSocket() {
    if (this.globalData.socketStatus === 'connected') {
      wx.closeSocket({
        success: () => {
          this.globalData.socketStatus = 'closed'
        }
      })
    }
  },

  //发送消息函数
  sendMessage(message) {
    if (this.globalData.socketStatus === 'connected') {
      //自定义的发给后台识别的参数 ，我这里发送的是name
      console.log("发送的消息", message)
      wx.sendSocketMessage({
        data: message
      })
    }
  },
  //登录的时候做连接的通信
  //暂时不做心跳
  login() {
    var that = this;
    wx.login({
      //成功放回
      success: (res) => {
        console.log(res);
        let code = res.code
        // 通过code换取openId
        wx.request({
          url: 'https://api.weixin.qq.com/sns/jscode2session?appid=wxc9c73915eeb63d6c&secret=83ac589ce417001b23c7191d3cb2fc4e&js_code=' + res.code + '&grant_type=authorization_code',
          method: 'POST',
          success(res) {
            console.log("初始化时完成openid的获取", res);
            that.globalData.openid = res.data.openid;
            var message = {};
            message.did = that.globalData.openid;
            /**
             * 1:连接
             * 2:心跳
             * 3:好友添加
             */
            message.type = 1;
            message = JSON.stringify(message)
            console.log("message 的值",message)
            that.sendMessage(message);
          }
        })
      }
    })
  },


  
  //app 全局属性监听
  watch:function(method){
    var obj = this.globalData;
    var val = this.globalData.unReadLetter;
    Object.defineProperty(obj,"unReadLetter", {
      configurable: true,
      enumerable: true,
      set: function (value) {
        val = value;
        console.log('是否会被执行2',value)
        method();
      },
      get:function(){
      // 可以在这里打印一些东西，然后在其他界面调用getApp().globalData.name的时候，这里就会执行。
        return val;
      }
    })
  },
})